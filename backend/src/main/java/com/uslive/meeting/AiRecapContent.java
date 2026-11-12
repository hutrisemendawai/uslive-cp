package com.uslive.meeting;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record AiRecapContent(
        @JsonAlias("executive_summary") String executiveSummary,
        @JsonAlias("action_items") List<ActionItemDto> actionItems) {
}
