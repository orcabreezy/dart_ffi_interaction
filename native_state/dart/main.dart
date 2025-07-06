import 'dart:isolate';

import 'native_state.dart';

Future<T> runAsyncNative<T>(T Function() nativeFunc) async {
  final responsePort = ReceivePort();
  await Isolate.spawn((SendPort sendPort) {
    final result = nativeFunc();
    sendPort.send(result);
  }, responsePort.sendPort);

  return await responsePort.first as T;
}

void blocking() {
  print('initializing the object');
  initGlobalObject('finrod felagund', 2233, <int>[10, 38, 92, -23]);

  print('now read out the age');
  final age = getGlobalObjectAge();
  print('the age is: ${age}');

  print('now read out some data');
  final dataAtOne = getGlobalObjectDataAt(1);
  print('data at index one: ${dataAtOne}');
}

Future<void> nonblocking() async {
  print('initializing the object');
  await runAsyncNative(
    () => initGlobalObject('finrod felagund', 2233, <int>[10, 38, 92, -23]),
  );

  print('now read out the age');
  final age = await runAsyncNative(getGlobalObjectAge);
  print('the age is: ${age}');

  print('now read out some data');
  final dataAtOne = await runAsyncNative(() => getGlobalObjectDataAt(1));
  print('data at index one: ${dataAtOne}');
}

void main() async {
  // await nonblocking();
  blocking();
}
