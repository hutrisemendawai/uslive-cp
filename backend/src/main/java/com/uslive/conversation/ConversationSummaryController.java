package com.uslive.conversation;

import java.security.Principal;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/conversations")
public class ConversationSummaryController {

    private final ConversationSummaryService summaryService;

    public ConversationSummaryController(ConversationSummaryService summaryService) {
        this.summaryService = summaryService;
    }

    @PostMapping("/{id}/summarize")
    public ResponseEntity<SummarizeAcceptedDto> summarize(@PathVariable("id") UUID conversationId, Principal principal) {
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }
        UUID userId;
        try {
            userId = UUID.fromString(principal.getName());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid user identity");
        }
        UUID requestId = summaryService.requestSummary(conversationId, userId);
        return ResponseEntity.accepted().body(new SummarizeAcceptedDto(requestId));
    }
}
