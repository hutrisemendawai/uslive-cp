# Roadmap & Progress Tracker

## Step 0 — Prerequisites (Pending)

- [ ] Scaffold Next.js backend (`package.json`, `tsconfig.json`, `next.config`, `src/app/layout.tsx`).
- [ ] Add Prisma config and `.env.example` (`DATABASE_URL`, `LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`).
- [ ] Run initial Prisma migration + `prisma generate`.

## Step 1 — Prisma Schema (Done)

- [x] Enums: `Role`, `TicketCategory`, `TicketStatus`, `TaskStatus`, `MessageType`.
- [x] Models: `Region`, `User`, `Project`, `Ticket`, `ProjectTask`, `ChatMessage`, `CallSession`.
- [x] Relations and indexes.

## Step 2 — Next.js API Routes (Pending)

- [ ] `POST /api/tickets/create`
- [ ] `POST /api/tickets/escalate`
- [ ] `GET /api/issues/unassigned`
- [ ] `POST /api/issues/claim`
- [ ] `POST /api/issues/assign`
- [ ] `GET /api/chat/[ticketId]`
- [ ] `POST /api/chat/send`
- [ ] `GET /api/livekit/token`
- [ ] `POST /api/livekit/webhook`

## Step 3 — Flutter Frontend (Pending)

- [ ] Data models: `Ticket`, `ProjectTask`, `ChatMessage` (with `fromJson`/`toJson`).
- [ ] `ApiService` singleton.
- [ ] LiveKit service + data-channel listener.
- [ ] `ticket_chat_screen.dart` (chat + live session).
- [ ] `project_board_screen.dart` (Kanban + unassigned pool).
- [ ] Riverpod providers and app wiring.
