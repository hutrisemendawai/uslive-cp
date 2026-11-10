# Data Model

Location: `backend/prisma/schema.prisma`. This schema is already implemented.

## Enums

```prisma
enum Role {
  USER
  LOCAL_SUPPORT
  MANAGER_ERP
  MANAGER_TD
  ERP_SUPPORT
  TD_SUPPORT
}

enum TicketCategory {
  HARDWARE
  NETWORK
  ERP
  TD
  GENERAL
}

enum TicketStatus {
  OPEN
  IN_PROGRESS
  ESCALATED
  RESOLVED
}

enum TaskStatus {
  BACKLOG
  TODO
  IN_PROGRESS
  REVIEW
  UAT
  DONE
}

enum MessageType {
  TEXT
  SYSTEM
  CALL_DURATION
}
```

## Models

### Region
| Field | Type |
|-------|------|
| id | String (uuid) |
| name | String (unique) |

Relations: `users User[]`, `tickets Ticket[]`.

### User
| Field | Type |
|-------|------|
| id | String (uuid) |
| name | String |
| email | String (unique) |
| role | Role (default `USER`) |
| regionId | String |
| createdAt / updatedAt | DateTime |

Relations: `region Region`, `createdTickets Ticket[]`, `assignedTickets Ticket[]`, `assignedTasks ProjectTask[]`, `sentMessages ChatMessage[]`.

Index: `[regionId, role]`.

### Project
| Field | Type |
|-------|------|
| id | String (uuid) |
| name | String |
| createdAt / updatedAt | DateTime |

Relations: `tasks ProjectTask[]`.

### Ticket
| Field | Type |
|-------|------|
| id | String (uuid) |
| title | String |
| description | String |
| category | TicketCategory (default `GENERAL`) |
| status | TicketStatus (default `OPEN`) |
| creatorId | String |
| assigneeId | String? (nullable for pooling) |
| regionId | String |
| isEscalated | Boolean (default false) |
| createdAt / updatedAt | DateTime |

Relations: `creator User`, `assignee User?`, `region Region`, `tasks ProjectTask[]`, `messages ChatMessage[]`, `callSessions CallSession[]`.

Indexes: `[regionId, status]`, `[category, status, assigneeId]`.

### ProjectTask
| Field | Type |
|-------|------|
| id | String (uuid) |
| ticketId | String? (nullable) |
| projectId | String |
| title | String |
| description | String |
| status | TaskStatus (default `BACKLOG`) |
| priority | Int (default 0) |
| assigneeId | String? (nullable for pooling) |
| createdAt / updatedAt | DateTime |

Relations: `ticket Ticket?` (SetNull), `project Project` (Cascade), `assignee User?` (SetNull).

Indexes: `[projectId, status]`, `[assigneeId]`.

### ChatMessage
| Field | Type |
|-------|------|
| id | String (uuid) |
| ticketId | String |
| senderId | String? |
| message | String |
| messageType | MessageType (default `TEXT`) |
| createdAt | DateTime |

Relations: `ticket Ticket` (Cascade), `sender User?` (SetNull).

Index: `[ticketId, createdAt]`.

### CallSession
| Field | Type |
|-------|------|
| id | String (uuid) |
| ticketId | String |
| startTime | DateTime |
| endTime | DateTime |
| durationSeconds | Int |
| createdAt | DateTime |

Relations: `ticket Ticket` (Cascade).

Index: `[ticketId]`.

## Relationship Summary

- `User -> Region` (many-to-one).
- `User -> Ticket` via two relations: `CreatedTickets` (creatorId) and `AssignedTickets` (assigneeId).
- `User -> ProjectTask` via `AssignedTasks` (assigneeId).
- `Ticket -> ChatMessage` and `Ticket -> CallSession` (one-to-many, cascade delete).
- `Project -> ProjectTask` (one-to-many, cascade delete).
- `Ticket -> ProjectTask` (one-to-many, SetNull when ticket deleted).
