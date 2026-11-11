abstract class CallRepository {
  Future<void> showIncomingCall(
    String callId,
    String callerId,
    String callerName,
  );

  Future<void> endCall();
}
