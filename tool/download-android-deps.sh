#!/bin/bash

if [ "$#" -ne 1 ] || [[ "$1" != http* ]]; then
    echo "Usage: $0 URL -- download and extract an lozzax-core android-deps package (typically from https://rocks.lozzax.xyz)" >&2
    exit 1
fi

if ! [ -d lozzax_coin/ios/External/android/lozzax ]; then
    echo "This script needs to be invoked from the lozzax-wallet top-level project directory" >&2
    exit 1
fi

curl -sS "$1" | tar --strip-components=1 -C lozzax_coin/ios/External/android/lozzax/ -xJv
