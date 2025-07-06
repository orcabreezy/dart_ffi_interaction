import 'dart:ffi';

import 'ble_wrapper.dart';

void main() async {
  if (!BLEWrapper.isBluetoothEnabled()) {
    print('Bluetooth is not enabled');
    return;
  }

  print('Bluetooth is enabled!');

  // final adapter = BLEWrapper.getAdapter();
  // if (adapter == null) {
  //   print('No Bluetooth adapter found');
  //   return;
  // }

  // print(
  //   'Adapter Identifier: ${String.fromCharCodes(adapter.identifier.elements.toList())}',
  // );
  // print(
  //   'Adapter Address: ${String.fromCharCodes(adapter.address.elements.toList())}',
  // );

  final (deviceInfos, devices) = BLEWrapper.scanForDevices(5000, 10);

  if (deviceInfos.isEmpty) {
    print('no devices found -_-');
    return;
  }

  for (var device in deviceInfos) {
    // if (device == devices.first) print('--');
    print(
      'Device Identifier: ${String.fromCharCodes(device.identifier.elements.toList())}',
    );
    print(
      'Device Address: ${String.fromCharCodes(device.address.elements.toList())}',
    );
    // if (device == devices.first) print('--');
  }

  final wantedAddress = String.fromCharCodes(
    deviceInfos.first.address.elements.toList(),
  );

  final device = BLEWrapper.connectToDevice(wantedAddress);

  if (device != null)
    print('successfully connected');
  else {
    print('connection error');
    return;
  }

  await Future.delayed(const Duration(seconds: 3));

  BLEWrapper.disconnectDevice(device);
  print('disconnected');
}
