import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

// TODO: maybe wrap all functions as async
// TODO: correspond dart:int with native:Int64 instead of Int32
// TODO: copy docstring from win_native.cpp

final dylib = DynamicLibrary.open('native/build/Release/win_native.dll');

typedef _DartInitializeApiDl_Native = Void Function(Pointer<Void>);
typedef _DartInitializeApiDl = void Function(Pointer<Void>);
final _DartInitializeApiDl dartInitializeApiDl = dylib
    .lookupFunction<_DartInitializeApiDl_Native, _DartInitializeApiDl>(
      'dart_initialize_api_dl',
    );
typedef _RegisterScanUpdatePort_Native = Void Function(Int64);
typedef _RegisterScanUpdatePort = void Function(int);
final _RegisterScanUpdatePort registerScanUpdatePort = dylib
    .lookupFunction<_RegisterScanUpdatePort_Native, _RegisterScanUpdatePort>(
      'register_scan_update_port',
    );
typedef _DeleteUint8Array_Native = Void Function(Pointer<Uint8>);
typedef _DeleteUint8Array = void Function(Pointer<Uint8>);
final _DeleteUint8Array deleteUint8Array = dylib
    .lookupFunction<_DeleteUint8Array_Native, _DeleteUint8Array>(
      'delete_uint8_array',
    );

typedef _BluetoothIsEnabled_Native = Int32 Function();
typedef _BluetoothIsEnabled = int Function();
final _BluetoothIsEnabled bluetoothIsEnabled = dylib
    .lookupFunction<_BluetoothIsEnabled_Native, _BluetoothIsEnabled>(
      'bluetooth_is_enabled',
    );

typedef _InitializeAdapter_Native = Int32 Function();
typedef _InitializeAdapter = int Function();
final _InitializeAdapter initializeAdapter = dylib
    .lookupFunction<_InitializeAdapter_Native, _InitializeAdapter>(
      'initialize_adapter',
    );

typedef _ScanFor_Native = Void Function(Int32);
typedef _ScanFor = void Function(int);
final _ScanFor scanFor = dylib.lookupFunction<_ScanFor_Native, _ScanFor>(
  'scan_for',
);

typedef _Cleanup_Native = Void Function();
typedef _Cleanup = void Function();
final _Cleanup cleanup = dylib.lookupFunction<_Cleanup_Native, _Cleanup>(
  'cleanup',
);

typedef _ConnectToDevice_Native = Void Function(Int64);
typedef _ConnectToDevice = void Function(int);
final _ConnectToDevice connectToDevice = dylib
    .lookupFunction<_ConnectToDevice_Native, _ConnectToDevice>(
      'connect_to_device',
    );

typedef _DisconnectFromDevice_Native = Void Function(Int64);
typedef _DisconnectFromDevice = void Function(int);
final _DisconnectFromDevice disconnectFromDevice = dylib
    .lookupFunction<_DisconnectFromDevice_Native, _DisconnectFromDevice>(
      'disconnect_from_device',
    );

typedef _GetDeviceAddress_Native = Pointer<Utf8> Function(Int64);
typedef _GetDeviceAddress = Pointer<Utf8> Function(int);
final _GetDeviceAddress getDeviceAddress = dylib
    .lookupFunction<_GetDeviceAddress_Native, _GetDeviceAddress>(
      'get_device_address',
    );

// services
typedef _DiscoverDeviceServices_Native = Void Function(Int64);
typedef _DiscoverDeviceServices = void Function(int);
final _DiscoverDeviceServices discoverDeviceServices = dylib
    .lookupFunction<_DiscoverDeviceServices_Native, _DiscoverDeviceServices>(
      'discover_device_services',
    );

typedef _GetNumberOfServices_Native = Int64 Function(Int64);
typedef _GetNumberOfServices = int Function(int);
final _GetNumberOfServices getNumberOfServices = dylib
    .lookupFunction<_GetNumberOfServices_Native, _GetNumberOfServices>(
      'get_number_of_services',
    );

typedef _GetServiceUuid_Native = Pointer<Utf8> Function(Int64, Int64);
typedef _GetServiceUuid = Pointer<Utf8> Function(int, int);
final _GetServiceUuid getServiceUuid = dylib
    .lookupFunction<_GetServiceUuid_Native, _GetServiceUuid>(
      'get_service_uuid',
    );

// characteristics
typedef _DiscoverServiceCharacteristics_Native = Void Function(Int64, Int64);
typedef _DiscoverServiceCharacteristics = void Function(int, int);
final _DiscoverServiceCharacteristics discoverServiceCharacteristics = dylib
    .lookupFunction<
      _DiscoverServiceCharacteristics_Native,
      _DiscoverServiceCharacteristics
    >('discover_service_characteristics');

typedef _GetNumberOfCharacteristics_Native = Int64 Function(Int64, Int64);
typedef _GetNumberOfCharacteristics = int Function(int, int);
final _GetNumberOfCharacteristics getNumberOfCharacteristics = dylib
    .lookupFunction<
      _GetNumberOfCharacteristics_Native,
      _GetNumberOfCharacteristics
    >('get_number_of_characteristics');

typedef _GetCharacteristicUuid_Native =
    Pointer<Utf8> Function(Int64, Int64, Int64);
typedef _GetCharacteristicUuid = Pointer<Utf8> Function(int, int, int);
final _GetCharacteristicUuid getCharacteristicUuid = dylib
    .lookupFunction<_GetCharacteristicUuid_Native, _GetCharacteristicUuid>(
      'get_characteristic_uuid',
    );

typedef _ReadCharacteristic_Native =
    Pointer<Uint8> Function(Int64, Int64, Int64);
typedef _ReadCharacteristic = Pointer<Uint8> Function(int, int, int);
final _ReadCharacteristic readCharacteristic = dylib
    .lookupFunction<_ReadCharacteristic_Native, _ReadCharacteristic>(
      'read_characteristic',
    );
typedef _WriteToCharacteristic_Native =
    Void Function(Int64, Int64, Int64, Pointer<Uint8>, Int64);
typedef _WriteToCharacteristic =
    void Function(int, int, int, Pointer<Uint8>, int);
final _WriteToCharacteristic writeToCharacteristic = dylib
    .lookupFunction<_WriteToCharacteristic_Native, _WriteToCharacteristic>(
      'write_to_characteristic',
    );
typedef _RegisterNotificationPort_Native = Int64 Function(Int64);
typedef _RegisterNotificationPort = int Function(int);
final _RegisterNotificationPort registerNotificationPort = dylib
    .lookupFunction<
      _RegisterNotificationPort_Native,
      _RegisterNotificationPort
    >('register_notification_port');

typedef _SubscribeToCharacteristic_Native =
    Void Function(Int64, Int64, Int64, Int64);
typedef _SubscribeToCharacteristic = void Function(int, int, int, int);
final _SubscribeToCharacteristic subscribeToCharacteristic = dylib
    .lookupFunction<
      _SubscribeToCharacteristic_Native,
      _SubscribeToCharacteristic
    >('subscribe_to_characteristic');

typedef _UnsubscribeFromCharacteristic_Native =
    Void Function(Int64, Int64, Int64);
typedef _UnsubscribeFromCharacteristic = void Function(int, int, int);
final _UnsubscribeFromCharacteristic unsubscribeFromCharacteristic = dylib
    .lookupFunction<
      _UnsubscribeFromCharacteristic_Native,
      _UnsubscribeFromCharacteristic
    >('unsubscribe_from_characteristic');

typedef _DisposeDevice_Native = Void Function(Int64);
typedef _DisposeDevice = void Function(int);

final _DisposeDevice disposeDevice = dylib
    .lookupFunction<_DisposeDevice_Native, _DisposeDevice>('dispose_device');

Future<T> runAsyncNative<T>(T Function() nativeFunc) async {
  final responsePort = ReceivePort();
  await Isolate.spawn((SendPort sendPort) {
    final result = nativeFunc();
    sendPort.send(result);
  }, responsePort.sendPort);

  return await responsePort.first as T;
}
