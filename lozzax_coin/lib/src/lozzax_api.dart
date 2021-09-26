import 'dart:ffi';
import 'dart:io';

final DynamicLibrary lozzaxApi = Platform.isAndroid
    ? DynamicLibrary.open('liblozzax_coin.so')
    : DynamicLibrary.process();
