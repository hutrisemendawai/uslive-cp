package com.uslive.conversation;

import java.time.Instant;
import java.util.UUID;

public record SummarizeRequestedEvent(
        UUID requestId,
        UUID conversationId,
        UUID userId,
        Instant requestedAt) {
}
