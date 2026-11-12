package com.uslive.meeting;

import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class MeetingRecapService {

    private static final String RECAP_SQL = """
            SELECT m.id, m.title, m.start_time, m.end_time, m.conversation_id,
                   m.recording_url, m.ai_recap::text AS ai_recap
            FROM meetings m
            JOIN meeting_participants mp ON mp.meeting_id = m.id
            WHERE m.id = ? AND mp.user_id = ?
            """;

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public MeetingRecapService(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public MeetingRecapDto getRecap(UUID meetingId, UUID userId) {
        List<MeetingRecapDto> rows = jdbcTemplate.query(
                RECAP_SQL,
                (rs, i) -> {
                    AiRecapContent recap = parseRecap(rs.getString("ai_recap"));
                    return new MeetingRecapDto(
                            rs.getObject("id", UUID.class),
                            rs.getString("title"),
                            toOffset(rs.getTimestamp("start_time")),
                            toOffset(rs.getTimestamp("end_time")),
                            rs.getObject("conversation_id", UUID.class),
                            rs.getString("recording_url"),
                            recap.executiveSummary(),
                            recap.actionItems() == null ? List.of() : recap.actionItems());
                },
                meetingId,
                userId);

        if (rows.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Meeting not found");
        }
        return rows.get(0);
    }

    private AiRecapContent parseRecap(String json) {
        if (json == null || json.isBlank()) {
            return new AiRecapContent(null, List.of());
        }
        try {
            return objectMapper.readValue(json, AiRecapContent.class);
        } catch (JsonProcessingException e) {
            return new AiRecapContent(null, List.of());
        }
    }

    private static OffsetDateTime toOffset(Timestamp ts) {
        return ts == null ? null : ts.toInstant().atOffset(ZoneOffset.UTC);
    }
}
