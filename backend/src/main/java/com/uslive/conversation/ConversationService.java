package com.uslive.conversation;

import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ConversationService {

    private static final int SNIPPET_LENGTH = 100;

    private static final String CONVERSATIONS_SQL = """
            SELECT c.id,
                   c.type,
                   CASE WHEN c.type = 'DIRECT' THEN COALESCE(peer.display_name, c.name) ELSE c.name END AS name,
                   (SELECT COUNT(*)
                      FROM messages um
                     WHERE um.conversation_id = c.id
                       AND um.sender_id <> cm.user_id
                       AND um.id > COALESCE(cm.last_read_message_id, 0)) AS unread_count,
                   lm.content AS latest_content,
                   lm.created_at AS latest_created_at
            FROM conversation_members cm
            JOIN conversations c ON c.id = cm.conversation_id
            LEFT JOIN LATERAL (
                SELECT m.content, m.created_at
                  FROM messages m
                 WHERE m.conversation_id = c.id
                 ORDER BY m.id DESC
                 LIMIT 1
            ) lm ON TRUE
            LEFT JOIN LATERAL (
                SELECT u.display_name
                  FROM conversation_members pm
                  JOIN users u ON u.id = pm.user_id
                 WHERE pm.conversation_id = c.id
                   AND pm.user_id <> cm.user_id
                 LIMIT 1
            ) peer ON c.type = 'DIRECT'
            WHERE cm.user_id = ?
            ORDER BY lm.created_at DESC NULLS LAST, c.id
            """;

    private final JdbcTemplate jdbcTemplate;

    public ConversationService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional(readOnly = true)
    public List<ConversationDto> getConversations(UUID userId) {
        return jdbcTemplate.query(
                CONVERSATIONS_SQL,
                (rs, i) -> new ConversationDto(
                        rs.getObject("id", UUID.class),
                        rs.getString("type"),
                        rs.getString("name"),
                        rs.getLong("unread_count"),
                        snippet(rs.getString("latest_content")),
                        toOffset(rs.getTimestamp("latest_created_at"))),
                userId);
    }

    private static String snippet(String content) {
        if (content == null) {
            return null;
        }
        String normalized = content.strip().replaceAll("\\s+", " ");
        return normalized.length() <= SNIPPET_LENGTH
                ? normalized
                : normalized.substring(0, SNIPPET_LENGTH) + "…";
    }

    private static OffsetDateTime toOffset(Timestamp ts) {
        return ts == null ? null : ts.toInstant().atOffset(ZoneOffset.UTC);
    }
}
