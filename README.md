# Lozzax Wallet

The Lozzax Wallet was originally Forked from Lozzax Wallet.

## Build

1. Get Dependencies from pub
    ```shell script
    flutter pub get
    ```

2. Run the build_runner
    ```shell script
    flutter pub run build_runner build
    ```

3. To download the latest build of the Lozzax Dependencies run 
   ```
   ./tool/download-android-deps.sh https://lozzax.rocks/lozzax-io/lozzax-core/lozzax-stable-android-deps-LATEST.tar.xz
   ./tool/download-ios-deps.sh https://lozzax.rocks/lozzax-io/lozzax-core/lozzax-stable-ios-deps-LATEST.tar.xz
   ```
   Or build the Lozzax Dependencies and copy the Android deps into `lozzax_coin/ios/External/android/lozzax`
   and the ios into `lozzax_coin/ios/External/ios/lozzax`

4. Generate Launcher Icons
    ```shell script
    flutter pub run flutter_launcher_icons:main
    ```

5. Create Encryption Keys (Only needed if .secrets-<env>.json is empty)
    ```shell script
    dart tool/create_secrets.dart
    ```

6. Add Key to the application
    ```shell script
    dart tool/secrets.dart
    ```

7. Run the app
    ```shell script
    flutter run
    ```

## Copyright
Copyright (c) 2020 Konstantin Ullrich.\
Copyright (c) 2020 Cake Technologies LLC.\
Copyright (c) 2022 Oxen Project.

