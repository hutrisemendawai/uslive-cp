package api

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"

	"github.com/google/uuid"
)

var (
	ErrMeetingNotFound = errors.New("meeting not found")
	ErrNotParticipant  = errors.New("not a participant")
)

type User struct {
	ID          string
	DisplayName string
}

type Meeting struct {
	ID             string
	ConversationID string
	Title          string
	LiveKitRoom    string
	Status         string
}

type Authenticator interface {
	Authenticate(r *http.Request) (User, error)
}

type MeetingStore interface {
	CreateMeeting(ctx context.Context, hostID, conversationID, title, room string) (Meeting, error)
	GetMeeting(ctx context.Context, id string) (Meeting, error)
	IsConversationMember(ctx context.Context, userID, conversationID string) (bool, error)
	MarkParticipantJoined(ctx context.Context, meetingID, userID string) error
}

type TokenGenerator interface {
	Generate(room, identity, name string) (string, error)
}

type Handler struct {
	auth       Authenticator
	store      MeetingStore
	tokens     TokenGenerator
	livekitURL string
}

func NewHandler(auth Authenticator, store MeetingStore, tokens TokenGenerator, livekitURL string) *Handler {
	return &Handler{auth: auth, store: store, tokens: tokens, livekitURL: livekitURL}
}

func (h *Handler) Register(mux *http.ServeMux) {
	mux.HandleFunc("POST /calls/initiate", h.initiateCall)
	mux.HandleFunc("POST /meetings/{id}/join", h.joinMeeting)
}

type initiateRequest struct {
	ConversationID string `json:"conversation_id"`
	Title          string `json:"title"`
}

type tokenResponse struct {
	MeetingID string `json:"meeting_id"`
	Room      string `json:"room"`
	Token     string `json:"token"`
	URL       string `json:"url"`
}

func (h *Handler) initiateCall(w http.ResponseWriter, r *http.Request) {
	user, err := h.auth.Authenticate(r)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req initiateRequest
	if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20)).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body")
		return
	}
	if _, err := uuid.Parse(req.ConversationID); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_conversation_id")
		return
	}
	if req.Title == "" {
		req.Title = "Call"
	}

	member, err := h.store.IsConversationMember(r.Context(), user.ID, req.ConversationID)
	if err != nil {
		log.Printf("api: membership check failed: %v", err)
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}
	if !member {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}

	meeting, err := h.store.CreateMeeting(r.Context(), user.ID, req.ConversationID, req.Title, "call-"+uuid.NewString())
	if err != nil {
		log.Printf("api: create meeting failed: %v", err)
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}

	h.respondWithToken(w, r, user, meeting, http.StatusCreated)
}

func (h *Handler) joinMeeting(w http.ResponseWriter, r *http.Request) {
	user, err := h.auth.Authenticate(r)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	id := r.PathValue("id")
	if _, err := uuid.Parse(id); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_meeting_id")
		return
	}

	meeting, err := h.store.GetMeeting(r.Context(), id)
	if errors.Is(err, ErrMeetingNotFound) {
		writeError(w, http.StatusNotFound, "meeting_not_found")
		return
	}
	if err != nil {
		log.Printf("api: get meeting failed: %v", err)
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}
	if meeting.Status == "ENDED" || meeting.Status == "CANCELLED" {
		writeError(w, http.StatusGone, "meeting_closed")
		return
	}

	member, err := h.store.IsConversationMember(r.Context(), user.ID, meeting.ConversationID)
	if err != nil {
		log.Printf("api: membership check failed: %v", err)
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}
	if !member {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}

	h.respondWithToken(w, r, user, meeting, http.StatusOK)
}

func (h *Handler) respondWithToken(w http.ResponseWriter, r *http.Request, user User, meeting Meeting, status int) {
	token, err := h.tokens.Generate(meeting.LiveKitRoom, user.ID, user.DisplayName)
	if err != nil {
		log.Printf("api: token generation failed: %v", err)
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}
	if err := h.store.MarkParticipantJoined(r.Context(), meeting.ID, user.ID); err != nil {
		log.Printf("api: mark participant failed: %v", err)
		writeError(w, http.StatusInternalServerError, "internal_error")
		return
	}
	writeJSON(w, status, tokenResponse{
		MeetingID: meeting.ID,
		Room:      meeting.LiveKitRoom,
		Token:     token,
		URL:       h.livekitURL,
	})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, code string) {
	writeJSON(w, status, map[string]string{"error": code})
}
