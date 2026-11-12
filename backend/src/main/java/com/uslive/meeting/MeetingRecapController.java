package com.uslive.meeting;

import java.security.Principal;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/meetings")
public class MeetingRecapController {

    private final MeetingRecapService recapService;

    public MeetingRecapController(MeetingRecapService recapService) {
        this.recapService = recapService;
    }

    @GetMapping("/{id}/recap")
    public MeetingRecapDto getRecap(@PathVariable("id") UUID meetingId, Principal principal) {
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }
        UUID userId;
        try {
            userId = UUID.fromString(principal.getName());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid user identity");
        }
        return recapService.getRecap(meetingId, userId);
    }
}
