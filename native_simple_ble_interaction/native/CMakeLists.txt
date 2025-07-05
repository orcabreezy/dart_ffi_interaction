cmake_minimum_required(VERSION 3.10)
project(BleScanner)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(simpleble REQUIRED CONFIG)

set(DART_SDK_PATH "C:/users/eric/flutter/bin/cache/dart-sdk/")

add_library(c_export SHARED c_export.cpp c_export.def)

target_include_directories(c_export PRIVATE
    ${DART_SDK_PATH}/include/
)




target_link_libraries(c_export simpleble::simpleble)

# target_link_libraries(c_export ${DART_SDK_PATH}/bin/dart.lib)




# add_executable(sample_walkthrough sample_walkthrough.cpp)


# target_link_libraries(sample_walkthrough simpleble::simpleble)