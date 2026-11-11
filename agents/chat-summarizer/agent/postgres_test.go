package agent

import (
	"context"
	"database/sql"
	"os"
	"strings"
	"testing"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func TestPostgresUnreadMessages(t *testing.T) {
	databaseURL := os.Getenv("TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("TEST_DATABASE_URL is not set")
	}
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	db.SetMaxOpenConns(1)
	ctx := context.Background()
	statements := []string{
		`CREATE TEMP TABLE users (id uuid PRIMARY KEY, is_active boolean NOT NULL)`,
		`CREATE TEMP TABLE conversations (id uuid PRIMARY KEY, type text NOT NULL)`,
		`CREATE TEMP TABLE messages (id uuid PRIMARY KEY, conversation_id uuid NOT NULL, sender_id uuid, type text NOT NULL, content text, created_at timestamptz NOT NULL, deleted_at timestamptz)`,
		`CREATE TEMP TABLE conversation_members (conversation_id uuid NOT NULL, user_id uuid NOT NULL, last_read_message_id uuid)`,
		`INSERT INTO users VALUES ('85926126-f6e4-4a75-96b8-2d47f64f948a', true)`,
		`INSERT INTO conversations VALUES ('4473df3d-d3c4-4356-8055-746f061a5091', 'GROUP')`,
		`INSERT INTO messages
		 SELECT md5(n::text)::uuid, '4473df3d-d3c4-4356-8055-746f061a5091'::uuid,
		        '85926126-f6e4-4a75-96b8-2d47f64f948a'::uuid, 'TEXT',
		        CASE WHEN n = 11 THEN repeat('x', 2100) ELSE n::text END,
		        TIMESTAMPTZ '2026-01-01 00:00:00+00' + n * INTERVAL '1 second',
		        CASE WHEN n = 12 THEN NOW() ELSE NULL END
		 FROM generate_series(1, 80) n`,
		`INSERT INTO conversation_members VALUES ('4473df3d-d3c4-4356-8055-746f061a5091', '85926126-f6e4-4a75-96b8-2d47f64f948a', md5('10')::uuid)`,
	}
	for _, statement := range statements {
		if _, err := db.ExecContext(ctx, statement); err != nil {
			t.Fatal(err)
		}
	}
	store := PostgresStore{DB: db}
	unread, err := store.UnreadMessages(ctx, userID, conversationID, MaxMessages+1)
	if err != nil {
		t.Fatal(err)
	}
	if len(unread) != 69 || unread[0].Content != strings.Repeat("x", 2000) || !unread[0].ContentTruncated || unread[1].Content != "13" || unread[len(unread)-1].Content != "80" {
		t.Fatalf("unexpected unread messages: %+v", unread)
	}
	if _, err := store.UnreadMessages(ctx, requestID, conversationID, MaxMessages+1); err == nil {
		t.Fatal("nonmember was accepted")
	}
	if _, err := db.ExecContext(ctx, `UPDATE users SET is_active = false`); err != nil {
		t.Fatal(err)
	}
	if _, err := store.UnreadMessages(ctx, userID, conversationID, MaxMessages+1); err == nil {
		t.Fatal("inactive user was accepted")
	}
}
