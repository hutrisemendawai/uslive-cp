package com.uslive.dashboard;

import java.util.List;

public record DashboardResponseDto(
        String aiMorningBriefing,
        List<MeetingSummaryDto> upcomingMeetings) {
}
