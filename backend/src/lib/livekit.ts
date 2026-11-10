import { AccessToken, RoomServiceClient, WebhookReceiver } from 'livekit-server-sdk';

const livekitHost = process.env.LIVEKIT_URL || 'http://localhost:7880';
const apiKey = process.env.LIVEKIT_API_KEY || 'devkey';
const apiSecret = process.env.LIVEKIT_API_SECRET || 'secret';

export const roomService = new RoomServiceClient(livekitHost, apiKey, apiSecret);
export const webhookReceiver = new WebhookReceiver(apiKey, apiSecret);

export async function createLiveKitToken(
  roomName: string,
  participantIdentity: string,
  participantName: string
): Promise<string> {
  const token = new AccessToken(apiKey, apiSecret, {
    identity: participantIdentity,
    name: participantName,
  });

  token.addGrant({
    roomJoin: true,
    room: roomName,
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
  });

  return await token.toJwt();
}

export async function broadcastDataChannelMessage(
  roomName: string,
  payload: Record<string, unknown>
): Promise<void> {
  const data = new TextEncoder().encode(JSON.stringify(payload));
  await roomService.sendData(roomName, data, 1, {});
}
