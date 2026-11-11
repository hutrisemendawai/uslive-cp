import '../../domain/repositories/call_repository.dart';
import '../datasources/remote/callkit_service.dart';

class CallRepositoryImpl implements CallRepository {
  CallRepositoryImpl(this._callKitService);

  final CallKitService _callKitService;

  @override
  Future<void> showIncomingCall(
    String callId,
    String callerId,
    String callerName,
  ) {
    return _callKitService.showIncomingCall(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
    );
  }

  @override
  Future<void> endCall() {
    return _callKitService.endAllCalls();
  }
}
