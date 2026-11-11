package ws

import (
	"context"
	"log"
	"strings"
	"sync"

	"github.com/redis/go-redis/v9"
)

type Hub struct {
	cfg   Config
	redis *redis.Client

	mu            sync.RWMutex
	conversations map[string]map[*Client]struct{}
}

func NewHub(cfg Config, rdb *redis.Client) *Hub {
	return &Hub{
		cfg:           cfg,
		redis:         rdb,
		conversations: make(map[string]map[*Client]struct{}),
	}
}

func (h *Hub) channel(conversationID string) string {
	return h.cfg.ChannelPrefix + conversationID
}

func (h *Hub) subscribe(c *Client, conversationID string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	set, ok := h.conversations[conversationID]
	if !ok {
		set = make(map[*Client]struct{})
		h.conversations[conversationID] = set
	}
	set[c] = struct{}{}
}

func (h *Hub) unsubscribe(c *Client, conversationID string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if set, ok := h.conversations[conversationID]; ok {
		delete(set, c)
		if len(set) == 0 {
			delete(h.conversations, conversationID)
		}
	}
}

func (h *Hub) remove(c *Client) {
	h.mu.Lock()
	for id := range c.conversations {
		if set, ok := h.conversations[id]; ok {
			delete(set, c)
			if len(set) == 0 {
				delete(h.conversations, id)
			}
		}
	}
	h.mu.Unlock()
	c.closeSend()
}

func (h *Hub) publish(ctx context.Context, conversationID string, payload []byte) error {
	ctx, cancel := context.WithTimeout(ctx, h.cfg.PublishTimeout)
	defer cancel()
	return h.redis.Publish(ctx, h.channel(conversationID), payload).Err()
}

func (h *Hub) broadcast(conversationID string, payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	for c := range h.conversations[conversationID] {
		c.enqueue(payload)
	}
}

func (h *Hub) RunSubscriber(ctx context.Context) {
	for ctx.Err() == nil {
		h.consume(ctx)
		select {
		case <-ctx.Done():
			return
		case <-timeAfter(h.cfg.ReconnectBackoff):
		}
	}
}

func (h *Hub) consume(ctx context.Context) {
	pubsub := h.redis.PSubscribe(ctx, h.cfg.ChannelPrefix+"*")
	defer pubsub.Close()

	if _, err := pubsub.Receive(ctx); err != nil {
		if ctx.Err() == nil {
			log.Printf("ws: redis subscribe failed: %v", err)
		}
		return
	}

	ch := pubsub.Channel()
	for {
		select {
		case <-ctx.Done():
			return
		case msg, ok := <-ch:
			if !ok {
				return
			}
			conversationID := strings.TrimPrefix(msg.Channel, h.cfg.ChannelPrefix)
			h.broadcast(conversationID, []byte(msg.Payload))
		}
	}
}
