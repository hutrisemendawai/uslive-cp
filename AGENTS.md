Agents Architecture & Design (System & AI)
To build a scalable and intelligent internal communication application (equivalent to MS Teams with AI features), the architecture must be equipped with an Agents system. These agents run in the backend (as microservices or background workers), separated from the main API so they do not overload the signaling and chat channels.

Here is the design for the agents integrated with your LiveKit, Redis, and PostgreSQL architecture.

1. AI Agents (Productivity & Intelligence)
These agents interact directly with user data (audio/text) to provide Artificial Intelligence (NLP/LLM) based value-adds.

A. Meeting Assistant & Summarizer Agent
Role: Attends video/voice meetings to generate automated minutes, transcriptions, and Action Items.

How it Works (LiveKit Integration):

When a meeting starts, this agent joins the LiveKit Room as a hidden participant (participant without video).

The agent receives the audio stream from the LiveKit SFU.

The audio is processed using a Speech-to-Text (STT) model like Whisper in real-time or via post-processing.

The transcribed text is sent to an LLM (Large Language Model) for summarization.

The summary results are saved to the messages table in PostgreSQL (with type: 'FILE' or as long text) under that meeting's conversation_id.

Tech Stack: Python, LiveKit Python SDK, OpenAI API / Local LLM (Ollama), Redis (for task queues).

B. Internal Knowledge Chatbot (RAG Agent)
Role: Answers employee questions related to HR, IT Support, or company SOPs directly in Direct Message rooms.

How it Works:

The agent has an account in the users table (e.g., "IT Support Bot").

Listens (subscribes) to Redis Pub/Sub for incoming messages to its conversation_id, or for mentions of its name (e.g., @HRBot).

Uses RAG (Retrieval-Augmented Generation) techniques to search for SOP documents in a Vector Database (such as pgvector in PostgreSQL).

Sends replies via WebSocket API just like a regular user.

C. Smart Triage / Catch-up Agent
Role: Summarizes group conversations if a user has been offline for too long and missed hundreds of messages.

How it Works:

When the Flutter client sends an online signal, the system checks the last_read_message_id.

If the message gap is > 50, the client triggers a REST API to request a summary.

The agent reads the text history from PostgreSQL, summarizes it using an LLM, and returns it to the client without permanently saving it to the main database.

2. System Agents (Background Workers)
These infrastructure agents are tasked with maintaining performance, performing cleanups, and processing heavy-lifting tasks asynchronously.

A. Media Processing & Transcoding Agent
Role: Manages meeting recordings and large file attachments.

How it Works:

LiveKit Egress is instructed to record composite video and save it to MinIO (S3).

After the recording is complete, a LiveKit webhook triggers this agent.

The agent performs additional video compression (using FFmpeg) or generates thumbnails.

Updates the meetings table in PostgreSQL with the MinIO URL of the recording and sends a notification to the group chat that the recording is ready.

B. Presence & Notification Router Agent
Role: Manages Online/Offline status synchronization and Push Notification routing.

How it Works:

Listens to WebSocket heartbeats from Redis. If a user disconnects without a logout signal (e.g., connection lost), this agent waits for a grace period (e.g., 10 seconds).

If the user remains disconnected, the agent updates the user's status in Redis to offline and updates last_seen_at in PostgreSQL.

Takes over pending message delivery: If there is an incoming message for an offline user, the agent formats the FCM (Android) or APNs (iOS) payload, adds the badge count, and calls the Firebase/Apple API.

C. Data Archiving & Cleanup Agent
Role: Prevents the PostgreSQL database (messages table) from bloating and consuming too much memory.

How it Works:

Runs as a Cron Job (e.g., every 2 AM).

Moves chat messages older than 1 year to Cold Storage (archive tables or log files in MinIO), depending on the company's data retention policy.

Cleans up stale session caches or expired LiveKit tokens in Redis.

3. Agents Communication Flow with the Core System
To avoid bottlenecks, the Agents use an Event-Driven pattern:

Plaintext
[Flutter Client] 
   └─> (WebSocket/REST) 
         └─> [Backend (Spring/Go)] 
                 ├─> [PostgreSQL] (Save Data)
                 └─> [Redis Pub/Sub or Message Queue (RabbitMQ/Kafka)]
                         │
                         ├─> Consumes Event ──> [AI RAG Bot] 
                         ├─> Consumes Event ──> [Notification Agent]
                         └─> Consumes Event ──> [Media Processing Agent]
Advantage: The main backend (Go/Spring Boot) will respond to user messages in milliseconds because heavy tasks are offloaded to a Message Broker (Redis/RabbitMQ) to be executed by the Agents separately.