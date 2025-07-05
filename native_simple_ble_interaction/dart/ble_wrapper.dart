import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

// Define the path to the compiled DLL
final DynamicLibrary bleLibrary = Platform.isWindows
    ? DynamicLibrary.open('build/Release/c_export.dll')
    : throw UnsupportedError('This library is only supported on Windows');

// Define the DeviceInfo structure
final class DeviceInfo extends Struct {
  @Array<Uint8>(256)
  external Array<Uint8> identifier;

  @Array<Uint8>(256)
  external Array<Uint8> address;
}

final class Peripheral extends Struct {
  @Array<Uint8>(24)
  external Array<Uint8> data;
}

// Define the CharacteristicInfo structure
final class CharacteristicInfo extends Struct {
  @Array<Uint8>(256)
  external Array<Uint8> serviceUuid;

  @Array<Uint8>(256)
  external Array<Uint8> characteristicUuid;
}

typedef _BluetoothEnabledNative = Int32 Function();
typedef _BluetoothEnabledDart = int Function();

typedef _GetPeripheralSizeNative = Int32 Function();
typedef _GetPeripheralSizeDart = int Function();

// typedef _GetAdapterNative = Int32 Function(Pointer<DeviceInfo>);
// typedef _GetAdapterDart = int Function(Pointer<DeviceInfo>);

typedef _ScanForDevicesNative =
    Pointer<Void> Function(Pointer<DeviceInfo>, Int32, Int32);
typedef _ScanForDevicesDart =
    Pointer<Void> Function(Pointer<DeviceInfo>, int, int);

typedef _ConnectToDeviceNative = Pointer<Void> Function(Pointer<Utf8>);
typedef _ConnectToDeviceDart = Pointer<Void> Function(Pointer<Utf8>);

typedef _ConnectToPredeterminedNative = Int32 Function(Pointer<Peripheral>);
typedef _ConnectToPredeterminedDart = int Function(Pointer<Peripheral>);

typedef _DisconnectDeviceNative = Void Function(Pointer<Void>);
typedef _DisconnectDeviceDart = void Function(Pointer<Void>);

// typedef _ListCharacteristicsNative =
//     Int32 Function(Pointer<Void>, Pointer<CharacteristicInfo>, Int32);
// typedef _ListCharacteristicsDart =
//     int Function(Pointer<Void>, Pointer<CharacteristicInfo>, int);

// typedef _ReadCharacteristicNative =
//     Int32 Function(
//       Pointer<Void>,
//       Pointer<Utf8>,
//       Pointer<Utf8>,
//       Pointer<Uint8>,
//       Int32,
//     );
// typedef _ReadCharacteristicDart =
//     int Function(
//       Pointer<Void>,
//       Pointer<Utf8>,
//       Pointer<Utf8>,
//       Pointer<Uint8>,
//       int,
//     );

// Load the functions from the DLL

final _BluetoothEnabledDart _bluetoothEnabled = bleLibrary
    .lookupFunction<_BluetoothEnabledNative, _BluetoothEnabledDart>(
      'bluetooth_enabled',
    );

final _GetPeripheralSizeDart _getPeripheralSize = bleLibrary
    .lookupFunction<_GetPeripheralSizeNative, _GetPeripheralSizeDart>(
      'get_peripheral_size',
    );

// final _GetAdapterDart _getAdapter = bleLibrary
//     .lookupFunction<_GetAdapterNative, _GetAdapterDart>('get_adapter');

final _ScanForDevicesDart _scanForDevices = bleLibrary
    .lookupFunction<_ScanForDevicesNative, _ScanForDevicesDart>(
      'scan_for_devices',
    );

final _ConnectToDeviceDart _connectToDevice = bleLibrary
    .lookupFunction<_ConnectToDeviceNative, _ConnectToDeviceDart>(
      'connect_to_device',
    );

final _ConnectToPredeterminedDart _connectToPredetermined = bleLibrary
    .lookupFunction<_ConnectToPredeterminedNative, _ConnectToPredeterminedDart>(
      'connect_to_predetermined',
    );

final _DisconnectDeviceDart _disconnectDevice = bleLibrary
    .lookupFunction<_DisconnectDeviceNative, _DisconnectDeviceDart>(
      'disconnect_device',
    );

// final _ListCharacteristicsDart _listCharacteristics = bleLibrary.lookupFunction<
//     _ListCharacteristicsNative,
//     _ListCharacteristicsDart>('list_characteristics');

// final _ReadCharacteristicDart _readCharacteristic = bleLibrary.lookupFunction<
//     _ReadCharacteristicNative, _ReadCharacteristicDart>('read_characteristic');

// Dart-friendly API
class BLEWrapper {
  static bool isBluetoothEnabled() {
    return _bluetoothEnabled() != 0;
  }

  // should return 24 bytes
  static int getPeripheralSize() {
    return _getPeripheralSize();
  }

  // static DeviceInfo? getAdapter() {
  //   final adapterInfo = calloc<DeviceInfo>();
  //   final result = _getAdapter(adapterInfo);
  //   if (result == 0) {
  //     calloc.free(adapterInfo);
  //     return null;
  //   }
  //   return adapterInfo.ref;
  // }

  static (List<DeviceInfo>, Pointer<Void>) scanForDevices(
    int durationMs,
    int maxDevices,
  ) {
    final devices = calloc<DeviceInfo>(maxDevices);

    final firstDevicePtr = _scanForDevices(devices, maxDevices, durationMs);
    final resultInfos = <DeviceInfo>[];
    // randomly stating that there would be 5 devices
    for (var i = 0; i < 5; i++) {
      resultInfos.add((devices + i).ref);
    }

    calloc.free(devices);
    // calloc.free(peripherals);
    return (resultInfos, firstDevicePtr);
  }

  static Pointer<Void>? connectToDevice(String address) {
    final addressPtr = address.toNativeUtf8();
    final devicePtr = _connectToDevice(addressPtr);
    calloc.free(addressPtr);
    return devicePtr == nullptr ? null : devicePtr;
  }

  static bool connectToPredetermined(Pointer<Peripheral> peripheral) {
    return _connectToPredetermined(peripheral) != 0;
  }

  static void disconnectDevice(Pointer<Void> devicePtr) {
    _disconnectDevice(devicePtr);
  }

  // static List<CharacteristicInfo> listCharacteristics(
  //   Pointer<Void> devicePtr,
  //   int maxCharacteristics,
  // ) {
  //   final characteristics = calloc<CharacteristicInfo>(maxCharacteristics);
  //   final count = _listCharacteristics(
  //     devicePtr,
  //     characteristics,
  //     maxCharacteristics,
  //   );
  //   final result = <CharacteristicInfo>[];
  //   for (var i = 0; i < count; i++) {
  //     result.add((characteristics + i).ref);
  //   }
  //   calloc.free(characteristics);
  //   return result;
  // }

  // static Uint8List readCharacteristic(Pointer<Void> devicePtr,
  //     String serviceUuid, String characteristicUuid, int bufferSize) {
  //   final serviceUuidPtr = serviceUuid.toNativeUtf8();
  //   final characteristicUuidPtr = characteristicUuid.toNativeUtf8();
  //   final buffer = calloc<Uint8>(bufferSize);

  //   final size = _readCharacteristic(
  //       devicePtr, serviceUuidPtr, characteristicUuidPtr, buffer, bufferSize);

  //   final result = Uint8List.fromList(buffer.asTypedList(size));
  //   calloc.free(serviceUuidPtr);
  //   calloc.free(characteristicUuidPtr);
  //   calloc.free(buffer);
  //   return result;
  // }
}
