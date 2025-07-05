import 'dart:ffi';

final dylib = DynamicLibrary.open('native/build/Release/win_native.dll');

typedef DartInitializeApiDlNative = Void Function(Pointer<Void>);
typedef DartInitializeApiDl = void Function(Pointer<Void>);

final DartInitializeApiDl dartInitializeApiDl = dylib
    .lookupFunction<DartInitializeApiDlNative, DartInitializeApiDl>(
      'dartInitializeApiDl',
    );

typedef RegisterSendPortNative = Void Function(Int64);
typedef RegisterSendPort = void Function(int);

final RegisterSendPort registerSendPort = dylib
    .lookupFunction<RegisterSendPortNative, RegisterSendPort>(
      'registerSendPort',
    );

typedef SendMessageNative = Void Function();
typedef SendMessage = void Function();
final SendMessage sendMessage = dylib
    .lookupFunction<SendMessageNative, SendMessage>('sendMessage');

// typedef StartMessageLoopNative = Void Function();
// typedef StartMessageLoop = void Function();

// final StartMessageLoop startMessageLoop = dylib
//     .lookupFunction<StartMessageLoopNative, StartMessageLoop>(
//       'startMessageLoop',
//     );
