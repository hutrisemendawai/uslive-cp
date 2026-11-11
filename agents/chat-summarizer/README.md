# Chat summarization agent

This independent Go service prepares an OpenAI Chat Completions-shaped request for an unread group conversation. It does not call an LLM, persist a summary, or return one to a client. A separate trusted consumer must send the prepared payload to the chosen provider and deliver the resulting summary. Other providers may require translating the payload.

Run `go run ./cmd/summarizer` from this directory, or build the Dockerfile with this directory as its build context. Set `DATABASE_URL` to the PostgreSQL connection string and `LLM_MODEL` to the intended model. `REDIS_ADDR` defaults to `127.0.0.1:6379`; `REDIS_PASSWORD` is optional. `SUMMARY_TRIGGER_CHANNEL` and `SUMMARY_RESULT_CHANNEL` default to `summarizer:trigger` and `summarizer:prepared` and must differ.

After authenticating a user and authorizing the request, a trusted backend publishes a JSON trigger containing UUIDs:

```json
{"request_id":"21405dc7-5206-4bdb-b6e5-bf15f8b86c7b","conversation_id":"4473df3d-d3c4-4356-8055-746f061a5091","user_id":"85926126-f6e4-4a75-96b8-2d47f64f948a"}
```

The agent verifies active group membership, reads the member's `last_read_message_id`, and selects nondeleted messages after that cursor in `(created_at, id)` order. When there are at most 50 unread messages, it publishes a `below_threshold` result without a payload. Otherwise it publishes a `prepared` result containing `request_id`, `user_id`, `conversation_id`, `message_count`, `truncated`, and an OpenAI-compatible `payload` with `model` and `messages`. The transcript is serialized as JSON inside the user message, not interpolated into the system instructions.

At most the oldest 200 unread messages are included, and each content field is limited to 2,000 characters. `message_count` is the number included; `truncated` indicates either more unread messages or truncated content. The transcript carries the same truncation flag, so the model can identify a partial summary. File URLs are not included.

Redis Pub/Sub is ephemeral: subscribe to the result channel before publishing, run only one agent instance per trigger channel to avoid duplicate results, and retry requests on timeout. A disconnected subscriber can miss triggers or results; failed requests are logged and do not produce a result. Use a durable queue and request tracking if delivery guarantees are required. The API server currently does not publish these triggers or consume the results.

Both channels and PostgreSQL contain private chat data. Restrict Redis publish/subscribe permissions to trusted services and do not expose these channels directly to clients. A result consumer must verify the requester and conversation before delivering a summary, and apply the organization's LLM data-handling policy before sending transcripts to an external provider.
