cmake_minimum_required(VERSION 3.10)
project(native-notifications)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(DART_SDK_PATH "C:/users/eric/flutter/bin/cache/dart-sdk/")

add_library(win_native SHARED win_native.cpp win_native.def)

target_include_directories(win_native PRIVATE
    ${DART_SDK_PATH}/include/
)