package com.uslive.conversation;

import java.time.Instant;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class ConversationSummaryService {

    private static final String MEMBERSHIP_SQL = """
            SELECT EXISTS (
                SELECT 1 FROM conversation_members
                 WHERE conversation_id = ? AND user_id = ?
            )
            """;

    private final StringRedisTemplate redisTemplate;
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    private final String channel;

    public ConversationSummaryService(
            StringRedisTemplate redisTemplate,
            JdbcTemplate jdbcTemplate,
            ObjectMapper objectMapper,
            @Value("${uslive.agents.summarize-channel:agents:chat-summarization}") String channel) {
        this.redisTemplate = redisTemplate;
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
        this.channel = channel;
    }

    public UUID requestSummary(UUID conversationId, UUID userId) {
        Boolean member = jdbcTemplate.queryForObject(MEMBERSHIP_SQL, Boolean.class, conversationId, userId);
        if (!Boolean.TRUE.equals(member)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Conversation not found");
        }

        SummarizeRequestedEvent event = new SummarizeRequestedEvent(
                UUID.randomUUID(), conversationId, userId, Instant.now());
        try {
            redisTemplate.convertAndSend(channel, objectMapper.writeValueAsString(event));
        } catch (JsonProcessingException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to build summary request");
        }
        return event.requestId();
    }
}
