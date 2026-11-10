# Architecture

## System Overview

```
Flutter Client (Web/Android/iOS)
        │  REST (HTTPS)                    WebRTC (LiveKit)
        ▼                                    ▼
Next.js App Router (REST + Webhooks)   LiveKit Server (SFU)
        │  Prisma                           │
        ▼                                    │
   PostgreSQL                              Data Channels (chat)
```

- The Flutter client calls REST endpoints on the Next.js backend.
- LiveKit handles real-time media (audio/video) and data channels (chat messages).
- The backend persists domain state in PostgreSQL via Prisma.
- AI summarization and email are mocked in `src/lib/services/notification-ai.service.ts`.

## Backend Clean Architecture

Layer boundaries (inside `backend/src/`):

```
app/api/<route>/route.ts   # HTTP layer: parse input, auth, delegate, respond
        │
        ▼
lib/ (services)            # Application/domain logic: orchestration + business rules
        │
        ▼
lib/prisma.ts              # Data access: Prisma singleton (single DB entry point)
```

Rules:

- Route handlers must **not** contain raw business logic or direct DB queries beyond simple delegation.
- All Prisma access flows through `lib/prisma.ts`.
- LiveKit SDK access flows through `lib/livekit.ts`.
- Mock AI/email flows through `lib/services/notification-ai.service.ts`.
- Input validation happens at the route boundary (the HTTP layer).

## Backend Directory (target)

```
backend/
├── prisma/
│   └── schema.prisma
├── src/
│   ├── app/api/
│   │   ├── tickets/
│   │   │   ├── create/route.ts
│   │   │   └── escalate/route.ts
│   │   ├── issues/
│   │   │   ├── unassigned/route.ts
│   │   │   ├── claim/route.ts
│   │   │   └── assign/route.ts
│   │   ├── chat/
│   │   │   ├── [ticketId]/route.ts
│   │   │   └── send/route.ts
│   │   └── livekit/
│   │       ├── token/route.ts
│   │       └── webhook/route.ts
│   └── lib/
│       ├── prisma.ts
│       ├── livekit.ts
│       └── services/
│           └── notification-ai.service.ts
```

## Frontend Clean Architecture (Flutter)

Feature-first modular structure under `frontend/lib/`:

```
frontend/lib/
├── core/               # Shared infra (no feature knowledge)
│   ├── network/        # HTTP client, ApiService
│   ├── livekit/        # LiveKit client wiring
│   └── theme/          # UI theme, constants
├── features/
│   ├── tickets/
│   │   ├── data/       # models, repositories
│   │   ├── domain/     # entities, use cases
│   │   └── presentation/ # providers, screens, widgets
│   ├── chat/
│   │   └── ...
│   └── board/
│       └── ...
└── main.dart
```

Rules:

- `data/` knows about JSON and APIs; `domain/` knows only business rules; `presentation/` knows only Riverpod + widgets.
- No widget talks directly to an HTTP client — always through a repository/provider.
- Real-time messages are appended to state via Riverpod, never by mutating widgets directly.

## Data Flow — Real-time Chat

1. Client sends `POST /api/chat/send`.
2. Backend persists `ChatMessage` to PostgreSQL.
3. Backend broadcasts the message over LiveKit data channel to the room.
4. Other clients receive the data-channel message and append it to chat state.

## Data Flow — Call Session

1. Client requests a token from `GET /api/livekit/token` (room = ticket ID).
2. Client connects to LiveKit room.
3. On `room_finished`, LiveKit POSTs to `/api/livekit/webhook`.
4. Backend computes duration, persists `CallSession`, and inserts a `CALL_DURATION` message.

## Authorization Model

| Role | Capability |
|------|------------|
| `USER` | Create tickets, send chat |
| `LOCAL_SUPPORT` | Auto-assigned to regional tickets |
| `ERP_SUPPORT` / `TD_SUPPORT` | Claim unassigned issues in their domain |
| `MANAGER_ERP` / `MANAGER_TD` | Manually assign issues in their domain |

Authorization is enforced per-route. See `docs/api-spec.md` for the exact role checks.
