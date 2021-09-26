cmake_minimum_required(VERSION 3.10)
set (CMAKE_CXX_STANDARD 17)

add_library( lozzax_coin
             SHARED
             ./jni/lozzax_jni.cpp)

set(CMAKE_BUILD_TYPE Debug)

set(EXTERNAL_LIBS_DIR ${CMAKE_SOURCE_DIR}/../ios/External/android)

add_library(wallet_api STATIC IMPORTED)
set_target_properties(wallet_api PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lozzax/lib/${ANDROID_ABI}/libwallet_api.a)

include_directories( ${EXTERNAL_LIBS_DIR}/lozzax/include )

target_link_libraries( lozzax_coin PRIVATE wallet_api )
target_include_directories( lozzax_coin PRIVATE wallet_api )