package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/redis/go-redis/v9"

	"github.com/hutrisemendawai/uslive-cp/agents/chat-summarizer/agent"
)

func required(key string) (string, error) {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return "", fmt.Errorf("%s is required", key)
	}
	return value, nil
}

func env(key, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(key)); value != "" {
		return value
	}
	return fallback
}

func run(ctx context.Context) error {
	databaseURL, err := required("DATABASE_URL")
	if err != nil {
		return err
	}
	model, err := required("LLM_MODEL")
	if err != nil {
		return err
	}
	triggerChannel := env("SUMMARY_TRIGGER_CHANNEL", "summarizer:trigger")
	resultChannel := env("SUMMARY_RESULT_CHANNEL", "summarizer:prepared")
	if triggerChannel == resultChannel {
		return errors.New("trigger and result channels must differ")
	}
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return err
	}
	defer db.Close()
	redisClient := redis.NewClient(&redis.Options{
		Addr:     env("REDIS_ADDR", "127.0.0.1:6379"),
		Password: os.Getenv("REDIS_PASSWORD"),
	})
	defer redisClient.Close()
	checkCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	if err := db.PingContext(checkCtx); err != nil {
		return fmt.Errorf("connect postgres: %w", err)
	}
	if err := redisClient.Ping(checkCtx).Err(); err != nil {
		return fmt.Errorf("connect redis: %w", err)
	}
	worker := &agent.Agent{
		Store:     agent.PostgresStore{DB: db},
		Publisher: agent.RedisPublisher{Client: redisClient, Channel: resultChannel},
		Model:     model,
	}
	return agent.Listen(ctx, redisClient, triggerChannel, worker)
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := run(ctx); err != nil {
		log.Fatal(err)
	}
}
