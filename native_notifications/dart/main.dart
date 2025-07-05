import 'dart:ffi';
import 'dart:isolate';

import 'ffi_notifications.dart';

void main() async {
  final initializeApi = NativeApi.initializeApiDLData;
  dartInitializeApiDl(initializeApi);

  final receivePort = ReceivePort();
  final sub = receivePort.listen(
    (message) => print("Received from C++: $message"),
  );

  registerSendPort(receivePort.sendPort.nativePort);
  await Isolate.spawn((_) => sendMessage(), null);
  print('ffi action done');

  Future.delayed(const Duration(seconds: 13)).then((_) {
    sub.cancel();
    print('manually cancelling subscription to platform channel');
  });
}
