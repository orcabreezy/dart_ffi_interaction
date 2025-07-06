import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

import 'native_bluetooth.dart';
import 'types/NativeBleDevice.dart';

void main() async {
  if (bluetoothIsEnabled() != 1) {
    print('bluetooth adapter has to be enabled');
  }

  final initializeApi = NativeApi.initializeApiDLData;
  dartInitializeApiDl(initializeApi);

  final scanUpdateReceivePort = ReceivePort();
  registerScanUpdatePort(scanUpdateReceivePort.sendPort.nativePort);

  final devices = <NativeBleDevice>[];

  final sub = scanUpdateReceivePort.listen((newDeviceId) async {
    final addr = getDeviceAddress(newDeviceId);
    devices.add(NativeBleDevice(newDeviceId, addr.toDartString()));
  });

  print('initializing the bluetooth adapter');
  initializeAdapter();

  print('scanning for devices');
  await runAsyncNative(() => scanFor(1000));

  sub.cancel();
  scanUpdateReceivePort.close();
  cleanup();

  print('printing now the device ids: ');
  for (final device in devices) {
    print(device.remoteId);
  }

  // Future.delayed(const Duration(seconds: 4)).then((_) async {
  //   sub.cancel();
  //   scanUpdateReceivePort.close();
  //   print('Cancelled subscription and closed ReceivePort');

  //   cleanup();
  // });

  final myDevice = devices[0];

  print('connecting to device: ${myDevice.remoteId}...');
  await myDevice.connect();

  print('connected');
  await Future.delayed(const Duration(seconds: 2));

  print('initializing device (services, characteristics)...');
  await myDevice.initialize();

  for (final svc in myDevice.services) {
    print('service: ${svc.uuid} ---');
    for (final char in svc.characteristics) {
      print('   characteristic: ${char.uuid}');
    }
    print('');
  }

  print('disconnecting...');
  await myDevice.disconnect();
  print('disconnected');
}
