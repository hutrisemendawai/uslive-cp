package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"

	"github.com/hutrisemendawai/uslive-cp/backend/internal/ws"
)

type devAuthenticator struct{}

func (devAuthenticator) Authenticate(r *http.Request) (string, error) {
	id := r.URL.Query().Get("user_id")
	if _, err := uuid.Parse(id); err != nil {
		return "", errors.New("invalid user")
	}
	return id, nil
}

type allowAllMembership struct{}

func (allowAllMembership) IsMember(context.Context, string, string) (bool, error) {
	return true, nil
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	rdb := redis.NewClient(&redis.Options{
		Addr:     env("REDIS_ADDR", "127.0.0.1:6379"),
		Password: os.Getenv("REDIS_PASSWORD"),
	})
	defer rdb.Close()

	cfg := ws.DefaultConfig(env("SERVER_ID", uuid.NewString()))
	if origins := os.Getenv("WS_ALLOWED_ORIGINS"); origins != "" {
		cfg.AllowedOrigins = strings.Split(origins, ",")
	}

	hub := ws.NewHub(cfg, rdb)
	go hub.RunSubscriber(ctx)

	mux := http.NewServeMux()
	mux.Handle("/ws", ws.NewHandler(hub, devAuthenticator{}, allowAllMembership{}))

	srv := &http.Server{Addr: env("HTTP_ADDR", ":8080"), Handler: mux}
	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_ = srv.Shutdown(shutdownCtx)
	}()

	log.Printf("listening on %s (server=%s)", srv.Addr, cfg.ServerID)
	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
}
