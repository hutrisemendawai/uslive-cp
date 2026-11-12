package com.uslive.meeting;

import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ActionItemDto(
        String description,
        String assignee,
        @JsonAlias("due_date") LocalDate dueDate,
        boolean completed) {
}
