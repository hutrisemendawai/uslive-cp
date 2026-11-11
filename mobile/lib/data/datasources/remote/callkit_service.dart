import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallKitService {
  Future<void> showIncomingCall({
    required String callId,
    required String callerId,
    required String callerName,
  }) {
    return FlutterCallkitIncoming.showCallkitIncoming(
      CallKitParams(
        id: callId,
        nameCaller: callerName,
        handle: callerId,
        appName: 'Uslive',
        type: CallkitParamsType.audio,
      ),
    );
  }

  Future<void> endAllCalls() {
    return FlutterCallkitIncoming.endAllCalls();
  }
}
