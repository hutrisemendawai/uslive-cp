# Agents Architecture & Design (System + AI)

This document maps conceptual agents to concrete Spring Boot endpoints, PostgreSQL/Redis/MinIO data paths, and the Google Stitch-generated Flutter UI flow used by this repository.

## 1. Frontend Architecture: Google Stitch Screens + Runtime Wiring

The current Flutter presentation layer is generated as static UI shells from Google Stitch and then connected to runtime services:

- **Call Screen** (`mobile/lib/presentation/pages/call_screen.dart`)
  - Real-time meeting UI wired to `LiveKitManager` (`mobile/lib/data/datasources/remote/livekit_manager.dart`).
  - Uses LiveKit SDK room state and controls (`connect`, `toggleMicrophone`, `toggleCamera`, `setShareScreenEnabled`, `disconnect`).
  - Receives in-call data messages and persists them through `AppDatabase` message DAO.
- **Today Hub** (`mobile/lib/presentation/pages/today_hub_screen.dart`)
  - Stitch-generated static layout for daily summary + agenda.
  - Backend contract: `GET /api/v1/dashboard` for `aiMorningBriefing` + `upcomingMeetings`.
- **Team Chat & Channels** (`mobile/lib/presentation/pages/team_chat_screen.dart`)
  - Stitch-generated static chat list and **Smart Chat Catch-up** banner.
  - Backend contract for banner CTA: `POST /api/v1/conversations/{id}/summarize`.
- **Meeting Details & AI Recap** (`mobile/lib/presentation/pages/meeting_details_screen.dart`)
  - Stitch-generated recap UI (executive summary, action items, recording chapters).
  - Backend contract: `GET /api/v1/meetings/{id}/recap`.

Integration layer:

- HTTP client: `mobile/lib/data/datasources/remote/api_client.dart` (`Dio` wrapper for `get`/`post`).
- Repositories/view-models should bind Stitch static widgets to these API responses while preserving generated visual structure.
- Live session UX remains on LiveKit path (`CallScreen` + `LiveKitManager`), while recap/catch-up/dashboard consume REST responses.

## 2. AI Agents Mapped to Concrete APIs and Storage

### A. Meeting Assistant & Summarizer Agent

**Role:** joins LiveKit meeting audio, transcribes, summarizes, and serves recap data.

**API mapping:**

- `GET /api/v1/meetings/{id}/recap` (`MeetingRecapController`) returns recap payload for Meeting Details.
- Service path: `MeetingRecapService` reads meeting metadata + recap content.

**Database/object storage mapping:**

- Source row: `meetings` table.
- Recording asset: `meetings.recording_url` points to MinIO object.
- AI recap payload: `meetings.ai_recap` (`JSONB`) parsed into:
  - `executive_summary`
  - `action_items[]`
- Participant access guard: `meeting_participants` membership check via join query.

**Processing flow:**

1. Agent joins LiveKit room as hidden participant.
2. Captures SFU audio stream, performs STT + LLM summarization.
3. Writes structured JSON recap into `meetings.ai_recap` and recording URL into `meetings.recording_url`.
4. Meeting Details screen consumes recap via `GET /api/v1/meetings/{id}/recap`.

### B. Smart Triage / Catch-up Agent

**Role:** generates short catch-up summaries for missed channel activity.

**API mapping (direct):**

- `POST /api/v1/conversations/{id}/summarize` (`ConversationSummaryController`).
- Called from Team Chat **Smart Chat Catch-up** banner CTA (“Generate 30-sec summary”).

**Eventing + storage mapping:**

- Service: `ConversationSummaryService`.
- Validates user membership using `conversation_members`.
- Publishes `SummarizeRequestedEvent` to Redis Pub/Sub channel:
  - default: `agents:chat-summarization`
  - transport: `StringRedisTemplate.convertAndSend(...)`
- Source text is read from `messages` scoped by `conversation_id`.

**UI integration point:**

- Banner component in `team_chat_screen.dart` is the trigger surface for this endpoint and should display the returned/streamed summary result.

### C. AI Morning Briefing Agent

**Role:** generates a daily personalized briefing for the Today Hub.

**API mapping:**

- `GET /api/v1/dashboard` (`DashboardController`) returns:
  - `aiMorningBriefing`
  - `upcomingMeetings[]`

**Data mapping:**

- Agenda source already queried from `meetings` + `meeting_participants` in `DashboardService`.
- Briefing field is currently placeholder-backed in service; production agent should populate `aiMorningBriefing` from generated output (persisted cache/table or Redis-backed materialization) before dashboard reads.

**UI integration point:**

- Today Hub screen consumes `aiMorningBriefing` and meeting list for personalized morning context.

### D. Internal Knowledge Chatbot (RAG Agent)

**Role:** responds in DM/channel threads using internal knowledge.

**System mapping:**

- Bot identity stored in `users` (`is_bot = true`).
- Message IO through `messages` / `conversations`.
- Triggered from Redis Pub/Sub (mention/message events), retrieves context from pgvector/knowledge index, replies via backend messaging channel.

## 3. System Agents (Background Workers)

### A. Media Processing & Transcoding Agent

- Triggered by LiveKit egress/webhook completion events.
- Processes recordings with FFmpeg, stores object in MinIO, updates `meetings.recording_url`.
- Notifies conversation stream when recording is ready.

### B. Presence & Notification Router Agent

- Consumes heartbeat/session events from Redis.
- Updates online state + `users.last_seen_at`.
- Routes offline notifications to FCM/APNs.

### C. Data Archiving & Cleanup Agent

- Scheduled jobs archive old `messages` data to cold storage.
- Cleans stale Redis session/token keys.

## 4. Concrete Endpoint-to-Agent Matrix

| Endpoint | Spring Handler | Agent | Primary UI Surface | Main Data Path |
|---|---|---|---|---|
| `POST /api/v1/conversations/{id}/summarize` | `ConversationSummaryController` + `ConversationSummaryService` | Smart Triage / Catch-up Agent | Team Chat `Smart Chat Catch-up` banner | `conversation_members` authorization → Redis Pub/Sub (`agents:chat-summarization`) → summarize `messages` |
| `GET /api/v1/meetings/{id}/recap` | `MeetingRecapController` + `MeetingRecapService` | Meeting Assistant & Summarizer Agent | Meeting Details & AI Recap screen | `meetings.ai_recap` (JSONB), `meetings.recording_url` (MinIO), `meeting_participants` membership |
| `GET /api/v1/dashboard` | `DashboardController` + `DashboardService` | AI Morning Briefing Agent | Today Hub screen | Meeting agenda from `meetings` + `meeting_participants`; briefing text generated daily by agent |

## 5. Event-Driven Communication Flow (Explicit Spring Boot → Redis Pub/Sub)

```text
[Flutter App (Stitch screens + LiveKit UI)]
    ├─ Call Screen ──> LiveKitManager ──> LiveKit SFU
    └─ REST (Today/Chat/Recap)
          └─> [Spring Boot API]
                ├─ Persist/query PostgreSQL (users, conversations, messages, meetings, meeting_participants)
                ├─ Store/fetch recording objects in MinIO (meeting recording_url targets)
                └─ Publish domain events to Redis Pub/Sub
                      ├─ summarize.requested  -> Smart Triage / Catch-up Agent
                      ├─ meeting.ended / recording.ready -> Meeting Assistant + Media Processing Agents
                      └─ dashboard.briefing.requested (or scheduled) -> AI Morning Briefing Agent

[Agents Workers]
    ├─ Consume Redis events
    ├─ Run STT/LLM/RAG or media processing
    └─ Write outputs back (PostgreSQL/MinIO/notifications) for API read models
```

Why this pattern: Spring Boot remains low-latency for user-facing requests while heavy AI/media workloads run asynchronously in agents triggered through Redis Pub/Sub.