CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username      VARCHAR(64)  NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    display_name  VARCHAR(128) NOT NULL,
    avatar_url    TEXT,
    is_bot        BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    last_seen_at  TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE conversations (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type       VARCHAR(16) NOT NULL CHECK (type IN ('DIRECT', 'GROUP', 'MEETING')),
    name       VARCHAR(255),
    created_by UUID REFERENCES users (id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID        NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
    sender_id       UUID        REFERENCES users (id) ON DELETE SET NULL,
    type            VARCHAR(16) NOT NULL DEFAULT 'TEXT' CHECK (type IN ('TEXT', 'FILE', 'IMAGE', 'SYSTEM')),
    content         TEXT,
    file_url        TEXT,
    reply_to_id     UUID        REFERENCES messages (id) ON DELETE SET NULL,
    edited_at       TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE conversation_members (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id      UUID        NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
    user_id              UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role                 VARCHAR(16) NOT NULL DEFAULT 'MEMBER' CHECK (role IN ('OWNER', 'ADMIN', 'MEMBER')),
    last_read_message_id UUID        REFERENCES messages (id) ON DELETE SET NULL,
    joined_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (conversation_id, user_id)
);

CREATE TABLE meetings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID         REFERENCES conversations (id) ON DELETE SET NULL,
    host_id         UUID         REFERENCES users (id) ON DELETE SET NULL,
    title           VARCHAR(255) NOT NULL,
    livekit_room    VARCHAR(255) NOT NULL UNIQUE,
    status          VARCHAR(16)  NOT NULL DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'LIVE', 'ENDED', 'CANCELLED')),
    scheduled_at    TIMESTAMPTZ,
    started_at      TIMESTAMPTZ,
    ended_at        TIMESTAMPTZ,
    recording_url   TEXT,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE meeting_participants (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id UUID        NOT NULL REFERENCES meetings (id) ON DELETE CASCADE,
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role       VARCHAR(16) NOT NULL DEFAULT 'PARTICIPANT' CHECK (role IN ('HOST', 'PARTICIPANT', 'AGENT')),
    joined_at  TIMESTAMPTZ,
    left_at    TIMESTAMPTZ,
    UNIQUE (meeting_id, user_id)
);

CREATE INDEX idx_messages_conversation_created_at ON messages (conversation_id, created_at DESC);
CREATE INDEX idx_conversation_members_user ON conversation_members (user_id);
CREATE INDEX idx_meetings_conversation ON meetings (conversation_id);
CREATE INDEX idx_meeting_participants_user ON meeting_participants (user_id);
