package com.uslive.meeting;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record MeetingRecapDto(
        UUID id,
        String title,
        OffsetDateTime startTime,
        OffsetDateTime endTime,
        UUID conversationId,
        String recordingUrl,
        String executiveSummary,
        List<ActionItemDto> actionItems) {
}
