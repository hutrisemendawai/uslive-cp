package agent

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/redis/go-redis/v9"
)

type RedisPublisher struct {
	Client  *redis.Client
	Channel string
}

func (p RedisPublisher) Publish(ctx context.Context, result Result) error {
	data, err := json.Marshal(result)
	if err != nil {
		return err
	}
	count, err := p.Client.Publish(ctx, p.Channel, data).Result()
	if err != nil {
		return err
	}
	if count == 0 {
		return errors.New("no subscribers for prepared summaries")
	}
	return nil
}

func Listen(ctx context.Context, client *redis.Client, channel string, agent *Agent) error {
	sub := client.Subscribe(ctx, channel)
	defer sub.Close()
	if _, err := sub.Receive(ctx); err != nil {
		return fmt.Errorf("subscribe to triggers: %w", err)
	}
	messages := sub.Channel()
	for {
		select {
		case <-ctx.Done():
			return nil
		case msg, ok := <-messages:
			if !ok {
				if ctx.Err() != nil {
					return nil
				}
				return errors.New("trigger subscription closed")
			}
			if len(msg.Payload) > 4096 {
				log.Print("summarizer: trigger exceeds size limit")
				continue
			}
			jobCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
			err := agent.Handle(jobCtx, []byte(msg.Payload))
			cancel()
			if err != nil && ctx.Err() == nil {
				log.Printf("summarizer: trigger failed: %v", err)
			}
		}
	}
}
