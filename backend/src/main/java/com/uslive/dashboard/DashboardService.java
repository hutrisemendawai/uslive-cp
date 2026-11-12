package com.uslive.dashboard;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DashboardService {

    private static final String BRIEFING_PLACEHOLDER = "AI Morning Briefing is not available yet.";

    private static final String UPCOMING_MEETINGS_SQL = """
            SELECT m.id, m.title, m.start_time, m.end_time, m.conversation_id
            FROM meetings m
            JOIN meeting_participants mp ON mp.meeting_id = m.id
            WHERE mp.user_id = ?
              AND m.start_time >= ?
              AND m.start_time < ?
            ORDER BY m.start_time ASC
            """;

    private final JdbcTemplate jdbcTemplate;
    private final Clock clock = Clock.systemUTC();

    public DashboardService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional(readOnly = true)
    public DashboardResponseDto getDashboard(UUID userId, ZoneId zone) {
        ZonedDateTime now = ZonedDateTime.now(clock).withZoneSameInstant(zone);
        ZonedDateTime endOfDay = now.toLocalDate().plusDays(1).atStartOfDay(zone);

        List<MeetingSummaryDto> meetings = jdbcTemplate.query(
                UPCOMING_MEETINGS_SQL,
                (rs, i) -> new MeetingSummaryDto(
                        rs.getObject("id", UUID.class),
                        rs.getString("title"),
                        toOffset(rs.getTimestamp("start_time")),
                        toOffset(rs.getTimestamp("end_time")),
                        rs.getObject("conversation_id", UUID.class)),
                userId,
                Timestamp.from(now.toInstant()),
                Timestamp.from(endOfDay.toInstant()));

        return new DashboardResponseDto(BRIEFING_PLACEHOLDER, meetings);
    }

    private static OffsetDateTime toOffset(Timestamp ts) {
        return ts == null ? null : ts.toInstant().atOffset(ZoneOffset.UTC);
    }
}
