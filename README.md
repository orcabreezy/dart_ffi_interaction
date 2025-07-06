# dart-FFI interaction

Examples of how dart-code can interact with native c++-code via the Foreign Function Interface (ffi)

## examples
- native_notifications: c++ sends periodic notifications, which are receivable by dart streams

- native_state: c++ saves a peristtend object

- native_simple_ble_interaction: shows how a custom bluetoothLE library could look like for windows

## usage

### prerequesits

#### required
- cmake
- a valid c++ compiler (MSVC, clang, ...)
- dart-sdk
#### optional for some samples
- simple-BLE library (free only for non-commercial use)

### building

to build a project navigate to one of the examples native-folder, create a build folder
and build the project with cmake: 

```sh
cd <sample>/native
mkdir build
cd build
cmake .. -A x64                     # generates build files
cmake --build . --config Release    # actually build the library
```

in the folder `<sample>/native/build/Release` should appear a `win_native.dll` file containing the compiled library (or similar, if renamed)

then this file can be used from dart:
```dart
import 'dart:ffi';
final dylib = DynamicLibrary.open('native/build/Release/win_native.dll');
```
(path should match the folder from which dart is ru)

and functions can be implemented in dart
```dart
final int Function(int) myFunction = dyLib
    .lookupFunction<Int64 Function(Int64), int Function(int)>('my_function');
```