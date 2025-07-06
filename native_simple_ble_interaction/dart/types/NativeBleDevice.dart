import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../native_bluetooth.dart';

class Uuid {
  Uuid(this.uuidString);
  final String uuidString;

  @override
  String toString() {
    return uuidString;
  }
}

final class NativeBleDevice {
  NativeBleDevice(this.refId, this.remoteId);

  /// internal id to link it to a cpp side object
  final int refId;
  final String remoteId;

  final List<NativeBleService> services = [];

  Future<void> connect() async {
    await runAsyncNative(() => connectToDevice(refId));
  }

  Future<void> disconnect() async {
    await runAsyncNative(() => disconnectFromDevice(refId));
  }

  Future<void> initialize() async {
    discoverDeviceServices(refId);
    final numOfServices = getNumberOfServices(refId);

    for (int svcId = 0; svcId < numOfServices; svcId++) {
      final svcUuid = Uuid(getServiceUuid(refId, svcId).toDartString());
      discoverServiceCharacteristics(refId, svcId);
      final numOfCharacteristics = getNumberOfCharacteristics(refId, svcId);

      final characteristics = <NativeBleCharacteristic>[];
      for (int chrstcId = 0; chrstcId < numOfCharacteristics; chrstcId++) {
        final chrstcUuid = Uuid(
          getCharacteristicUuid(refId, svcId, chrstcId).toDartString(),
        );
        characteristics.add(
          NativeBleCharacteristic(refId, svcId, chrstcId, chrstcUuid),
        );
      }

      services.add(NativeBleService(refId, svcId, svcUuid, characteristics));
    }
  }
}

final class NativeBleService {
  NativeBleService(
    this.deviceId,
    this.serviceId,
    this.uuid,
    this.characteristics,
  );

  final int deviceId;
  final int serviceId;

  final List<NativeBleCharacteristic> characteristics;

  final Uuid uuid;
}

final class NativeBleCharacteristic {
  NativeBleCharacteristic(
    this.deviceId,
    this.serviceId,
    this.characteristicId,
    this.uuid,
  );

  final int deviceId;
  final int serviceId;
  final int characteristicId;

  final Uuid uuid;
}
