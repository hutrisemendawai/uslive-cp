# AGENTS.md

Enterprise e-Support Ticketing & Project Tracking System. This file is the single source of truth for AI agents working in this repository.

## Project Overview

A full-stack enterprise helpdesk and project-tracking platform:

- Users submit support tickets.
- Local support triages tickets within their region.
- ERP/TD specialists work escalated issues and project tasks.
- ERP/TD managers oversee assignment.
- Real-time chat, audio, and video are powered by LiveKit.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Next.js (App Router) REST APIs + webhooks |
| ORM / DB | Prisma ORM + PostgreSQL |
| Frontend | Flutter (Web, Android, iOS) |
| State | Riverpod |
| Real-time | LiveKit (video, audio, data channels) |
| AI | Mock OpenAI summarization function |
| Email | Mock Resend/SMTP function |

## Repository Layout

```
liveus/
├── AGENTS.md                 # This file (canonical agent context)
├── docs/                     # Detailed reference docs (see below)
│   ├── architecture.md
│   ├── data-model.md
│   ├── api-spec.md
│   ├── frontend.md
│   └── roadmap.md
├── backend/                  # Next.js App Router (REST + webhooks)
│   ├── prisma/
│   │   └── schema.prisma
│   └── src/
│       ├── app/api/          # Route handlers (App Router)
│       └── lib/
│           ├── prisma.ts
│           ├── livekit.ts
│           └── services/
└── frontend/                 # Flutter app (clean architecture)
    └── lib/
```

## Current Build Status

**Done:**
- `backend/prisma/schema.prisma` — all enums, models, and relations (Step 1).
- `backend/src/lib/prisma.ts` — Prisma client singleton.
- `backend/src/lib/livekit.ts` — token creation + data-channel broadcast helpers.
- `backend/src/lib/services/notification-ai.service.ts` — mock `generateAISummary()` and `sendEmailAlert()`.

**Pending:**
- Next.js project scaffolding (`package.json`, `tsconfig.json`, `.env.example`, `next.config`).
- All `app/api` route handlers (Step 2).
- Flutter app (Step 3).

See `docs/roadmap.md` for the full checklist.

## Build Order

1. **Step 0 — Prerequisites:** scaffold Next.js + Prisma config, env vars, run first migration.
2. **Step 1 — Prisma schema:** already complete in `backend/prisma/schema.prisma`.
3. **Step 2 — Next.js API routes:** implement the 9 routes in `docs/api-spec.md`.
4. **Step 3 — Flutter frontend:** implement the app in `docs/frontend.md`.

## Key Domain Rules

- **Roles:** `USER`, `LOCAL_SUPPORT`, `MANAGER_ERP`, `MANAGER_TD`, `ERP_SUPPORT`, `TD_SUPPORT`.
- **Team mapping:** ERP team = `MANAGER_ERP` + `ERP_SUPPORT`; TD team = `MANAGER_TD` + `TD_SUPPORT`.
- **Ticket lifecycle:** `OPEN -> IN_PROGRESS -> ESCALATED -> RESOLVED`.
- **Pooling:** an "issue" is either an `ESCAPALTED` Ticket or an unassigned `ProjectTask` (`assigneeId = null`).
- **Escalation:** status becomes `ESCALATED`, `assigneeId` cleared, `isEscalated = true`, then mock AI summary + manager email fire.

## Commands

```bash
# Backend (from backend/)
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run dev

# Frontend (from frontend/)
flutter pub get
flutter run -d chrome
```

## Hard Constraints (non-negotiable)

- Do **not** add unnecessary comments to code. Comments only where logic is non-obvious.
- Strict **clean architecture** layering — no layer bypassing (see `docs/architecture.md`).
- Follow existing file naming and conventions; do not introduce parallel patterns.
- Mock AI/email via the existing service functions — do not call external APIs yet.
- Role-based authorization must be enforced server-side on every protected route.

## Conventions

- TypeScript for backend, strict typing; Dart for frontend.
- API route files follow Next.js App Router: `route.ts` under `src/app/api/...`.
- Prisma client accessed only through `src/lib/prisma.ts` singleton.
- LiveKit SDK usage goes through `src/lib/livekit.ts` helpers.
- Flutter state via Riverpod; feature-first structure (see `docs/frontend.md`).

## Reference Docs

| Doc | Purpose |
|-----|---------|
| `docs/architecture.md` | System architecture and clean-architecture layers |
| `docs/data-model.md` | Full Prisma schema spec (enums, models, relations) |
| `docs/api-spec.md` | Complete REST + LiveKit endpoint spec |
| `docs/frontend.md` | Flutter models, services, and screens spec |
| `docs/roadmap.md` | Step-by-step progress tracker |
