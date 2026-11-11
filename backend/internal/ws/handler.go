package ws

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

type Authenticator interface {
	Authenticate(r *http.Request) (userID string, err error)
}

type MembershipChecker interface {
	IsMember(ctx context.Context, userID, conversationID string) (bool, error)
}

type InboundMessage struct {
	Type           string `json:"type"`
	ConversationID string `json:"conversation_id"`
	Content        string `json:"content,omitempty"`
	ReplyToID      string `json:"reply_to_id,omitempty"`
}

type OutboundMessage struct {
	ID             string    `json:"id,omitempty"`
	Type           string    `json:"type"`
	ConversationID string    `json:"conversation_id,omitempty"`
	SenderID       string    `json:"sender_id,omitempty"`
	Content        string    `json:"content,omitempty"`
	ReplyToID      string    `json:"reply_to_id,omitempty"`
	OriginServer   string    `json:"origin_server,omitempty"`
	CreatedAt      time.Time `json:"created_at,omitempty"`
}

type Handler struct {
	hub      *Hub
	auth     Authenticator
	members  MembershipChecker
	upgrader websocket.Upgrader
}

func NewHandler(hub *Hub, auth Authenticator, members MembershipChecker) *Handler {
	return &Handler{
		hub:      hub,
		auth:     auth,
		members:  members,
		upgrader: hub.cfg.Upgrader(),
	}
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	userID, err := h.auth.Authenticate(r)
	if err != nil {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("ws: upgrade failed: %v", err)
		return
	}

	client := &Client{
		hub:           h.hub,
		conn:          conn,
		userID:        userID,
		send:          make(chan []byte, h.hub.cfg.SendBufferSize),
		conversations: make(map[string]struct{}),
	}

	go client.writePump()
	go client.readPump(context.Background(), h)
}

func (h *Handler) handleInbound(ctx context.Context, c *Client, in InboundMessage) {
	if _, err := uuid.Parse(in.ConversationID); err != nil {
		c.sendError("invalid_conversation_id")
		return
	}

	switch in.Type {
	case "join":
		if !h.authorize(ctx, c, in.ConversationID) {
			return
		}
		c.conversations[in.ConversationID] = struct{}{}
		h.hub.subscribe(c, in.ConversationID)
	case "leave":
		delete(c.conversations, in.ConversationID)
		h.hub.unsubscribe(c, in.ConversationID)
	case "message":
		if _, joined := c.conversations[in.ConversationID]; !joined {
			c.sendError("not_joined")
			return
		}
		h.publishMessage(ctx, c, in)
	default:
		c.sendError("unknown_type")
	}
}

func (h *Handler) authorize(ctx context.Context, c *Client, conversationID string) bool {
	ok, err := h.members.IsMember(ctx, c.userID, conversationID)
	if err != nil {
		log.Printf("ws: membership check failed: %v", err)
		c.sendError("internal_error")
		return false
	}
	if !ok {
		c.sendError("forbidden")
		return false
	}
	return true
}

func (h *Handler) publishMessage(ctx context.Context, c *Client, in InboundMessage) {
	out := OutboundMessage{
		ID:             uuid.NewString(),
		Type:           "message",
		ConversationID: in.ConversationID,
		SenderID:       c.userID,
		Content:        in.Content,
		ReplyToID:      in.ReplyToID,
		OriginServer:   h.hub.cfg.ServerID,
		CreatedAt:      time.Now().UTC(),
	}
	payload, err := json.Marshal(out)
	if err != nil {
		c.sendError("internal_error")
		return
	}
	if err := h.hub.publish(ctx, in.ConversationID, payload); err != nil {
		log.Printf("ws: publish failed: %v", err)
		c.sendError("publish_failed")
	}
}
