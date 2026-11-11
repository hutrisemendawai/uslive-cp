package agent

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
)

type PostgresStore struct {
	DB *sql.DB
}

func (s PostgresStore) UnreadMessages(ctx context.Context, userID, conversationID string, limit int) ([]Message, error) {
	var valid bool
	err := s.DB.QueryRowContext(ctx, `
		SELECT cm.last_read_message_id IS NULL OR (last.id IS NOT NULL AND last.conversation_id = cm.conversation_id)
		FROM conversation_members cm
		JOIN conversations c ON c.id = cm.conversation_id AND c.type = 'GROUP'
		JOIN users u ON u.id = cm.user_id AND u.is_active
		LEFT JOIN messages last ON last.id = cm.last_read_message_id
		WHERE cm.user_id = $1 AND cm.conversation_id = $2`, userID, conversationID).Scan(&valid)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, errors.New("active group membership required")
	}
	if err != nil {
		return nil, err
	}
	if !valid {
		return nil, errors.New("last read message does not belong to conversation")
	}
	rows, err := s.DB.QueryContext(ctx, `
		SELECT m.id::text, COALESCE(m.sender_id::text, ''), m.type,
		       LEFT(COALESCE(m.content, ''), 2000), m.created_at,
		       LENGTH(COALESCE(m.content, '')) > 2000
		FROM conversation_members cm
		JOIN conversations c ON c.id = cm.conversation_id AND c.type = 'GROUP'
		JOIN users u ON u.id = cm.user_id AND u.is_active
		LEFT JOIN messages last ON last.id = cm.last_read_message_id AND last.conversation_id = cm.conversation_id
		JOIN messages m ON m.conversation_id = cm.conversation_id
		WHERE cm.user_id = $1 AND cm.conversation_id = $2 AND m.deleted_at IS NULL
		  AND (cm.last_read_message_id IS NULL OR
		       (last.id IS NOT NULL AND (m.created_at, m.id) > (last.created_at, last.id)))
		ORDER BY m.created_at, m.id
		LIMIT $3`, userID, conversationID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	messages := make([]Message, 0)
	for rows.Next() {
		var m Message
		if err := rows.Scan(&m.ID, &m.SenderID, &m.Type, &m.Content, &m.CreatedAt, &m.ContentTruncated); err != nil {
			return nil, fmt.Errorf("scan unread message: %w", err)
		}
		messages = append(messages, m)
	}
	return messages, rows.Err()
}
