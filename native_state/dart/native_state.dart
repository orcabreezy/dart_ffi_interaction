import 'dart:ffi';
import 'package:ffi/ffi.dart';

final dylib = DynamicLibrary.open('native/build/Release/win_native.dll');

typedef InitGlobalObjectNative =
    Void Function(Pointer<Utf8>, Int, Pointer<Int>, Int);
typedef InitGlobalObject = void Function(Pointer<Utf8>, int, Pointer<Int>, int);
final InitGlobalObject initGlobalObject_ = dylib
    .lookupFunction<InitGlobalObjectNative, InitGlobalObject>(
      'initGlobalObject',
    );

void initGlobalObject(String name, int age, List<int> data) {
  final dataArray = calloc<Int>(data.length);
  for (int i = 0; i < data.length; i++) {
    dataArray[i] = data[i];
  }

  initGlobalObject_(name.toNativeUtf8(), age, dataArray, data.length);
}

typedef GetGlobalObjectAgeNative = Int Function();
typedef GetGlobalObjectAge = int Function();
final GetGlobalObjectAge getGlobalObjectAge = dylib
    .lookupFunction<GetGlobalObjectAgeNative, GetGlobalObjectAge>(
      'getGlobalObjectAge',
    );

typedef GetGlobalObjectDataAtNative = Int Function(Int);
typedef GetGlobalObjectDataAt = int Function(int);
final GetGlobalObjectDataAt getGlobalObjectDataAt = dylib
    .lookupFunction<GetGlobalObjectDataAtNative, GetGlobalObjectDataAt>(
      'getGlobalObjectDataAt',
    );
