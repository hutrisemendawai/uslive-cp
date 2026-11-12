package com.uslive.dashboard;

import java.time.OffsetDateTime;
import java.util.UUID;

public record MeetingSummaryDto(
        UUID id,
        String title,
        OffsetDateTime startTime,
        OffsetDateTime endTime,
        UUID conversationId) {
}
