import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
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
    // await runAsyncNative(() => disconnectFromDevice(refId));
    disconnectFromDevice(refId);
  }

  Future<void> dispose() async {
    disposeDevice(refId);
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
  ) {
    _notificationStream = _notificationStreamController.stream;
  }

  final int deviceId;
  final int serviceId;
  final int characteristicId;

  final Uuid uuid;

  // TODO: lifetime management for these
  final ReceivePort _notificationPort = ReceivePort();
  final StreamController<Uint8List> _notificationStreamController =
      StreamController();
  late final Stream<Uint8List> _notificationStream;
  late StreamSubscription<dynamic> _portSubscription;

  Stream<Uint8List> get stream => _notificationStream;

  Uint8List read() {
    Pointer<Uint8> rawData = readCharacteristic(
      deviceId,
      serviceId,
      characteristicId,
    );

    if (rawData == 0) {
      throw Exception('cannot read from characteristic, nullptr received');
    }

    final dataSize = rawData[0];

    final intData = <int>[];
    for (int i = 0; i < dataSize; i++) {
      intData.add(rawData[i + 1]);
    }

    deleteUint8Array(rawData);
    return Uint8List.fromList(intData);
  }

  void write(Uint8List data) {
    Pointer<Uint8> dataPtr = calloc<Uint8>(data.length);

    writeToCharacteristic(
      deviceId,
      serviceId,
      characteristicId,
      dataPtr,
      data.length,
    );

    calloc.free(dataPtr);
  }

  void subscribe() {
    final notification_port_id = registerNotificationPort(
      _notificationPort.sendPort.nativePort,
    );
    _portSubscription = _notificationPort.listen((message) {
      print('dart: notification received');
      final intList = message as List<int>;

      _notificationStreamController.add(Uint8List.fromList(intList));
    });

    subscribeToCharacteristic(
      deviceId,
      serviceId,
      characteristicId,
      notification_port_id,
    );
  }

  void unsubscribe() {
    unsubscribeFromCharacteristic(deviceId, serviceId, characteristicId);

    _portSubscription.cancel();
    _notificationPort.close();
  }
}
