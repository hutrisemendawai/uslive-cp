package ws

import (
	"context"
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

var timeAfter = time.After

type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	userID string
	send   chan []byte

	conversations map[string]struct{}

	closeOnce sync.Once
}

func (c *Client) enqueue(payload []byte) {
	select {
	case c.send <- payload:
	default:
		go c.conn.Close()
	}
}

func (c *Client) closeSend() {
	c.closeOnce.Do(func() { close(c.send) })
}

func (c *Client) readPump(ctx context.Context, handler *Handler) {
	defer func() {
		c.hub.remove(c)
		c.conn.Close()
	}()

	c.conn.SetReadLimit(c.hub.cfg.MaxMessageSize)
	_ = c.conn.SetReadDeadline(time.Now().Add(c.hub.cfg.PongWait))
	c.conn.SetPongHandler(func(string) error {
		return c.conn.SetReadDeadline(time.Now().Add(c.hub.cfg.PongWait))
	})

	for {
		_, raw, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseNormalClosure) {
				log.Printf("ws: read error user=%s: %v", c.userID, err)
			}
			return
		}

		var in InboundMessage
		if err := json.Unmarshal(raw, &in); err != nil {
			c.sendError("invalid_json")
			continue
		}
		handler.handleInbound(ctx, c, in)
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(c.hub.cfg.PingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case payload, ok := <-c.send:
			_ = c.conn.SetWriteDeadline(time.Now().Add(c.hub.cfg.WriteWait))
			if !ok {
				_ = c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.conn.WriteMessage(websocket.TextMessage, payload); err != nil {
				return
			}
		case <-ticker.C:
			_ = c.conn.SetWriteDeadline(time.Now().Add(c.hub.cfg.WriteWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func (c *Client) sendError(code string) {
	payload, _ := json.Marshal(OutboundMessage{Type: "error", Content: code})
	c.enqueue(payload)
}
