# API Specification

Base: Next.js App Router route handlers under `backend/src/app/api/`.

## Domain Concepts

- An **issue** is a union of two things: an `ESCALATED` Ticket, or an unassigned `ProjectTask` (`assigneeId = null`).
- **Team mapping:** ERP team = `MANAGER_ERP` + `ERP_SUPPORT`; TD team = `MANAGER_TD` + `TD_SUPPORT`.
- `category` for escalation/claim/assign must be `ERP` or `TD`.

---

## 1. Create Ticket

```
POST /api/tickets/create
```

Body:
```json
{
  "title": "string",
  "description": "string",
  "category": "HARDWARE | NETWORK | ERP | TD | GENERAL",
  "regionId": "string",
  "creatorId": "string"
}
```

Response: `201` with the created `Ticket`.

Logic:
- Create ticket with `status = OPEN`, `isEscalated = false`.
- Auto-assign `assigneeId` to a `LOCAL_SUPPORT` user where `User.regionId == ticket.regionId`.

---

## 2. Escalate Ticket

```
POST /api/tickets/escalate
```

Body:
```json
{
  "ticketId": "string",
  "category": "ERP | TD"
}
```

Response: `200` with ticket, AI summary, and email result.

Logic:
- Set `status = ESCALATED`, `isEscalated = true`, `assigneeId = null`.
- Call `generateAISummary(...)`.
- Call `sendEmailAlert(...)` targeting the relevant manager (`MANAGER_ERP` or `MANAGER_TD`).

---

## 3. Fetch Unassigned Issues

```
GET /api/issues/unassigned?category=ERP|TD
```

Response: `200`
```json
{
  "tickets": [ /* escalated Tickets with assigneeId = null */ ],
  "tasks": [ /* ProjectTasks with assigneeId = null */ ]
}
```

Logic:
- Filter escalated tickets by `category`.
- Filter unassigned project tasks by the relevant team (ERP or TD).

---

## 4. Claim Issue

```
POST /api/issues/claim
```

Body:
```json
{
  "issueId": "string",
  "type": "TICKET | TASK",
  "assigneeId": "string"
}
```

Response: `200` with the updated issue.

Logic:
- Require claimant role `ERP_SUPPORT` or `TD_SUPPORT`.
- Set `assigneeId` to the claiming user on the unassigned issue.

---

## 5. Assign Issue

```
POST /api/issues/assign
```

Body:
```json
{
  "issueId": "string",
  "type": "TICKET | TASK",
  "assigneeId": "string"
}
```

Response: `200` with the updated issue.

Logic:
- Require assigner role `MANAGER_ERP` or `MANAGER_TD`.
- Set `assigneeId` to the target user.

---

## 6. Fetch Chat History

```
GET /api/chat/[ticketId]
```

Response: `200` with `ChatMessage[]` ordered ascending by `createdAt`.

---

## 7. Send Chat Message

```
POST /api/chat/send
```

Body:
```json
{
  "ticketId": "string",
  "senderId": "string",
  "message": "string",
  "messageType": "TEXT | SYSTEM | CALL_DURATION"
}
```

Response: `201` with the saved `ChatMessage`.

Logic:
- Persist `ChatMessage` to Prisma.
- Broadcast the message via LiveKit data channel using `broadcastDataChannelMessage(roomName, payload)` where `roomName = ticketId`.

---

## 8. Generate LiveKit Token

```
GET /api/livekit/token?room=<ticketId>&identity=<id>&name=<name>
```

Response: `200`
```json
{ "token": "string" }
```

Logic:
- Use `createLiveKitToken(room, identity, name)` from `src/lib/livekit.ts`.
- Room name is the ticket ID.

---

## 9. LiveKit Webhook

```
POST /api/livekit/webhook
```

Headers: `Authorization` (LiveKit webhook signature).

Body: LiveKit webhook payload.

Logic:
- Verify the webhook using `webhookReceiver.receive(...)`.
- On `room_finished`, compute call duration from the room start/end timestamps.
- Persist a `CallSession` (startTime, endTime, durationSeconds).
- Insert a `ChatMessage` with `messageType = CALL_DURATION`, e.g. `"Live Session Ended. Duration: 15m 30s"`.

---

## Authorization Summary

| Route | Required Role(s) |
|-------|------------------|
| tickets/create | `USER` (or any authenticated) |
| tickets/escalate | `LOCAL_SUPPORT` (or manager) |
| issues/unassigned | `ERP_SUPPORT`, `TD_SUPPORT`, `MANAGER_ERP`, `MANAGER_TD` |
| issues/claim | `ERP_SUPPORT`, `TD_SUPPORT` |
| issues/assign | `MANAGER_ERP`, `MANAGER_TD` |
| chat/send | any participant on the ticket |
| livekit/token | any participant on the ticket |
| livekit/webhook | verified LiveKit signature |
