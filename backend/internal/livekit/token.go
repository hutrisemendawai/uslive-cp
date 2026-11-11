package livekit

import (
	"time"

	"github.com/livekit/protocol/auth"
)

type TokenService struct {
	apiKey    string
	apiSecret string
	ttl       time.Duration
}

func NewTokenService(apiKey, apiSecret string, ttl time.Duration) *TokenService {
	return &TokenService{apiKey: apiKey, apiSecret: apiSecret, ttl: ttl}
}

func (s *TokenService) Generate(room, identity, name string) (string, error) {
	enabled := true
	grant := &auth.VideoGrant{
		RoomJoin:          true,
		Room:              room,
		CanPublish:        &enabled,
		CanSubscribe:      &enabled,
		CanPublishData:    &enabled,
		CanPublishSources: []string{"microphone", "camera", "screen_share", "screen_share_audio"},
	}
	return auth.NewAccessToken(s.apiKey, s.apiSecret).
		SetVideoGrant(grant).
		SetIdentity(identity).
		SetName(name).
		SetValidFor(s.ttl).
		ToJWT()
}
