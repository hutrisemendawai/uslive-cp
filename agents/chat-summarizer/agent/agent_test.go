package agent

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/alicebob/miniredis/v2"
	"github.com/redis/go-redis/v9"
)

const (
	requestID      = "21405dc7-5206-4bdb-b6e5-bf15f8b86c7b"
	conversationID = "4473df3d-d3c4-4356-8055-746f061a5091"
	userID         = "85926126-f6e4-4a75-96b8-2d47f64f948a"
)

type fakeStore struct {
	messages []Message
	err      error
}

func (s fakeStore) UnreadMessages(_ context.Context, user, conversation string, limit int) ([]Message, error) {
	if user != userID || conversation != conversationID || limit != MaxMessages+1 {
		return nil, errors.New("unexpected query parameters")
	}
	return s.messages, s.err
}

type fakePublisher struct {
	result Result
	calls  int
	err    error
}

func (p *fakePublisher) Publish(_ context.Context, result Result) error {
	p.result, p.calls = result, p.calls+1
	return p.err
}

func trigger() []byte {
	data, _ := json.Marshal(Trigger{RequestID: requestID, ConversationID: conversationID, UserID: userID})
	return data
}

func messages(n int) []Message {
	result := make([]Message, n)
	for i := range result {
		result[i] = Message{ID: fmt.Sprint(i), Type: "TEXT", Content: fmt.Sprintf("message %d", i), CreatedAt: time.Unix(int64(i), 0).UTC()}
	}
	return result
}

func TestThresholdAndPayload(t *testing.T) {
	for _, tt := range []struct {
		count     int
		status    string
		truncated bool
		included  int
	}{
		{50, "below_threshold", false, 50},
		{51, "prepared", false, 51},
		{200, "prepared", false, 200},
		{201, "prepared", true, 200},
	} {
		t.Run(fmt.Sprint(tt.count), func(t *testing.T) {
			publisher := &fakePublisher{}
			a := Agent{Store: fakeStore{messages: messages(tt.count)}, Publisher: publisher, Model: "test-model"}
			if err := a.Handle(context.Background(), trigger()); err != nil {
				t.Fatal(err)
			}
			result := publisher.result
			if publisher.calls != 1 || result.Status != tt.status || result.MessageCount != tt.included || result.Truncated != tt.truncated || result.RequestID != requestID || result.UserID != userID {
				t.Fatalf("unexpected result: %+v", result)
			}
			if tt.status == "below_threshold" {
				if result.Payload != nil {
					t.Fatal("unexpected LLM payload")
				}
				return
			}
			if result.Payload == nil || result.Payload.Model != "test-model" || len(result.Payload.Messages) != 2 || result.Payload.Messages[0].Role != "system" || result.Payload.Messages[1].Role != "user" {
				t.Fatalf("unexpected LLM payload: %+v", result.Payload)
			}
			var transcript struct {
				Truncated bool      `json:"truncated"`
				Messages  []Message `json:"messages"`
			}
			if err := json.Unmarshal([]byte(result.Payload.Messages[1].Content), &transcript); err != nil {
				t.Fatal(err)
			}
			if transcript.Truncated != tt.truncated || len(transcript.Messages) != tt.included || transcript.Messages[0].Content != "message 0" || transcript.Messages[len(transcript.Messages)-1].Content != fmt.Sprintf("message %d", tt.included-1) {
				t.Fatalf("unexpected transcript: %+v", transcript)
			}
		})
	}
}

func TestHandleErrorsAndContentTruncation(t *testing.T) {
	publisher := &fakePublisher{}
	a := Agent{Store: fakeStore{}, Publisher: publisher, Model: "model"}
	if err := a.Handle(context.Background(), []byte(`{"user_id":"bad"}`)); err == nil || publisher.calls != 0 {
		t.Fatal("invalid trigger was accepted")
	}
	a.Store = fakeStore{err: errors.New("database failure")}
	if err := a.Handle(context.Background(), trigger()); err == nil || publisher.calls != 0 {
		t.Fatal("database error was not returned")
	}
	contents := messages(51)
	contents[0].ContentTruncated = true
	a.Store = fakeStore{messages: contents}
	if err := a.Handle(context.Background(), trigger()); err != nil || !publisher.result.Truncated {
		t.Fatalf("content truncation not reported: %v", err)
	}
	publisher.err = errors.New("unavailable")
	if err := a.Handle(context.Background(), trigger()); err == nil || !strings.Contains(err.Error(), "publish result") {
		t.Fatalf("publisher error not propagated: %v", err)
	}
}

func TestRedisTriggerProducesPayload(t *testing.T) {
	server := miniredis.RunT(t)
	client := redis.NewClient(&redis.Options{Addr: server.Addr()})
	defer client.Close()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	resultSub := client.Subscribe(ctx, "results")
	defer resultSub.Close()
	if _, err := resultSub.Receive(ctx); err != nil {
		t.Fatal(err)
	}
	a := &Agent{Store: fakeStore{messages: messages(51)}, Publisher: RedisPublisher{Client: client, Channel: "results"}, Model: "model"}
	done := make(chan error, 1)
	go func() { done <- Listen(ctx, client, "triggers", a) }()
	deadline := time.Now().Add(2 * time.Second)
	for {
		count, err := client.PubSubNumSub(ctx, "triggers").Result()
		if err != nil {
			t.Fatal(err)
		}
		if count["triggers"] == 1 {
			break
		}
		if time.Now().After(deadline) {
			t.Fatal("listener did not subscribe")
		}
		time.Sleep(time.Millisecond)
	}
	if err := client.Publish(ctx, "triggers", trigger()).Err(); err != nil {
		t.Fatal(err)
	}
	receiveCtx, receiveCancel := context.WithTimeout(ctx, 2*time.Second)
	defer receiveCancel()
	msg, err := resultSub.ReceiveMessage(receiveCtx)
	if err != nil {
		t.Fatal(err)
	}
	var result Result
	if err := json.Unmarshal([]byte(msg.Payload), &result); err != nil {
		t.Fatal(err)
	}
	if result.Status != "prepared" || result.Payload == nil || result.RequestID != requestID {
		t.Fatalf("unexpected result: %+v", result)
	}
	cancel()
	if err := <-done; err != nil {
		t.Fatal(err)
	}
}

func TestRedisPublisherRequiresSubscriber(t *testing.T) {
	client := redis.NewClient(&redis.Options{Addr: miniredis.RunT(t).Addr()})
	defer client.Close()
	if err := (RedisPublisher{Client: client, Channel: "results"}).Publish(context.Background(), Result{}); err == nil {
		t.Fatal("missing subscriber not reported")
	}
}
