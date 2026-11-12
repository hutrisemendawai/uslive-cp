package com.uslive.conversation;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ConversationDto(
        UUID id,
        String type,
        String name,
        long unreadCount,
        String latestMessageSnippet,
        OffsetDateTime latestMessageAt) {
}
