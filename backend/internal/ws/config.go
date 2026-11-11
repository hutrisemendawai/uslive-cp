package ws

import (
	"net/http"
	"net/url"
	"time"

	"github.com/gorilla/websocket"
)

type Config struct {
	ServerID         string
	ChannelPrefix    string
	WriteWait        time.Duration
	PongWait         time.Duration
	PingPeriod       time.Duration
	MaxMessageSize   int64
	SendBufferSize   int
	ReadBufferSize   int
	WriteBufferSize  int
	AllowedOrigins   []string
	PublishTimeout   time.Duration
	ReconnectBackoff time.Duration
}

func DefaultConfig(serverID string) Config {
	pongWait := 60 * time.Second
	return Config{
		ServerID:         serverID,
		ChannelPrefix:    "chat:conversation:",
		WriteWait:        10 * time.Second,
		PongWait:         pongWait,
		PingPeriod:       pongWait * 9 / 10,
		MaxMessageSize:   64 * 1024,
		SendBufferSize:   256,
		ReadBufferSize:   1024,
		WriteBufferSize:  1024,
		PublishTimeout:   5 * time.Second,
		ReconnectBackoff: time.Second,
	}
}

func (c Config) Upgrader() websocket.Upgrader {
	return websocket.Upgrader{
		ReadBufferSize:  c.ReadBufferSize,
		WriteBufferSize: c.WriteBufferSize,
		CheckOrigin:     c.checkOrigin,
	}
}

func (c Config) checkOrigin(r *http.Request) bool {
	origin := r.Header.Get("Origin")
	if origin == "" {
		return true
	}
	u, err := url.Parse(origin)
	if err != nil {
		return false
	}
	if u.Host == r.Host {
		return true
	}
	for _, allowed := range c.AllowedOrigins {
		if allowed == "*" || allowed == origin {
			return true
		}
	}
	return false
}
