# Frontend Specification (Flutter)

Flutter app under `frontend/`. Uses Riverpod for state and `livekit_client` for real-time media/data.

## Structure

```
frontend/lib/
├── core/
│   ├── network/
│   │   └── api_service.dart
│   ├── livekit/
│   │   └── livekit_service.dart
│   └── theme/
├── features/
│   ├── tickets/
│   │   ├── data/
│   │   │   └── models/
│   │   ├── domain/
│   │   └── presentation/
│   ├── chat/
│   │   └── presentation/
│   │       └── ticket_chat_screen.dart
│   └── board/
│       └── presentation/
│           └── project_board_screen.dart
└── main.dart
```

## Data Models

### Ticket
Fields mirror the backend: `id`, `title`, `description`, `category`, `status`, `creatorId`, `assigneeId?`, `regionId`, `isEscalated`, `createdAt`, `updatedAt`.

### ProjectTask
Fields: `id`, `ticketId?`, `projectId`, `title`, `description`, `status`, `priority`, `assigneeId?`, `createdAt`, `updatedAt`.

### ChatMessage
Fields: `id`, `ticketId`, `senderId?`, `message`, `messageType` (`TEXT`, `SYSTEM`, `CALL_DURATION`), `createdAt`.

Each model implements `fromJson(Map<String, dynamic>)` and `toJson()`.

## API Service

A singleton (`ApiService`) with:

- `createTicket(...)`
- `claimIssue(issueId, type)`
- `assignIssue(issueId, type, assigneeId)`
- `fetchUnassignedIssues(category)`
- `fetchChatHistory(ticketId)`
- `sendMessage(...)`
- `fetchLiveKitToken(room, identity, name)`

Handles JSON encoding, error handling, and base URL configuration.

## LiveKit Service

Wraps `livekit_client`:

- `connect(roomName, token)` — join room, enable audio/video, subscribe to data channel.
- `sendData(payload)` — publish a data-channel message.
- `disconnect()`.

## Screens

### `ticket_chat_screen.dart`

- `ListView` rendering `ChatMessage` list.
- `TEXT` messages → standard chat bubbles (sender vs. self alignment).
- `SYSTEM` and `CALL_DURATION` messages → centered timeline-style text.
- Connect to the LiveKit room using the ticket ID.
- Listen to LiveKit data channels; append incoming messages to state without full rebuild/refresh (Riverpod notifier).
- `Start Live Call` button → connects video/audio.

### `project_board_screen.dart`

- Kanban board for `ERP_SUPPORT` / `TD_SUPPORT`.
- Columns: To Do, In Progress, Done (mapped from `TaskStatus`).
- A separate "Unassigned Pool" section listing issues with a `Claim` button each.

## State Management

- One Riverpod `Notifier`/`AsyncNotifier` per feature screen (chat state, board state).
- Repository providers expose data access; screens depend on state providers only.
