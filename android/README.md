# Android ARM64 build (experimental)

This repository contains an experimental Android target for the C++ MCLA Recomp project. It uses SDL3 and the ReXGlue runtime and targets `arm64-v8a`.

## Current status

- The APK builds and has been installed on a Samsung Galaxy S23 running Android 16.
- The game found its data, initialized Vulkan on that device, and rendered the city scene.
- Performance is still poor. This is a development build, not a stable release; no 30 FPS claim is made.
- Only the S23 has been tested. Other Android devices and GPUs remain unverified.

## Game files

The APK does **not** include the game. Provide your own legally obtained and extracted Xbox 360 game data, including `default.xex` and the required RPF archives.

Preferred location:

```text
/storage/emulated/0/MLR/
```

Place the extracted game files directly in `MLR`, or put the game tree in `MLR/game`. The app checks these locations first. It also checks its app-specific storage as a fallback.

On Android 11 and newer, shared-storage scanning requires granting **Allow access to manage all files** in the Android settings page opened by the app. Return to the app after granting access; if it started before access was granted, close and reopen it. Keep the game files out of Git and do not distribute them with the APK.

## Full-data XAPK

The Android launcher can read a full-data OBB named `main.<versionCode>.org.mcla.recomp.obb`. On first launch it extracts the OBB into the app-owned `Android/data/org.mcla.recomp/files/game` directory before starting the native runtime. This avoids requiring broad storage access for an XAPK install. Existing data in `/MLR` remains supported and still requires **Allow access to manage all files** on Android 11 and newer.

To create a private XAPK from a signed APK and your own extracted game files, run:

```bash
python3 scripts/package_android_xapk.py \
  --apk android/app/build/outputs/apk/release/app-release.apk \
  --game-dir game \
  --output MCLA-Recomp-Android.xapk
```

XAPK is a third-party ZIP container, not an Android install format. Use an XAPK installer that installs the APK and places the declared OBB in `Android/obb/org.mcla.recomp/`. The first launch then prepares the game files. The output contains the supplied game data; keep it private and do not upload it to the public repository.

## In-game options

Open the game's pause menu, then **Settings**:

- **Display** includes the FPS counter toggle, frame-rate target, motion blur and depth of field.
- **Performance** includes Performance, Balanced and Original graphics presets, plus individual detail controls.
- Changes are saved to the app's settings file.

## Touch controls

The Android game view includes an on-screen virtual gamepad: left stick for steering, RT/ LT for throttle and brake, A/B/X/Y, and START. The overlay hides after five seconds without touch. Touch the screen to reveal it again, or use the persistent PAD/HIDE button in the upper-right corner. Touch input is forwarded through SDL as a virtual gamepad, so the game uses the same input path as a physical controller.

The Android native C++ targets use `-O3` for the `RelWithDebInfo` release configuration; Android Gradle selects that configuration for the current release variant. This may reduce CPU time, but FPS still needs to be measured on a device.

The renderer currently follows the Android display surface. The ReXGlue resolution-scale controls only support 1x and higher, so this build does not expose a misleading 720p/downscaling option yet.

## Build requirements

Use a Linux x86-64 build host with Java 21, Android SDK/NDK, CMake 3.31.6, Ninja, Python 3.12, and an Android-patched ReXGlue v0.10.0 SDK. The host-native `rexglue` code generator and its host libraries are also required.

For the configured GitHub Codespace, run this from the repository root:

```bash
./scripts/build_android_codespace.sh
```

The script uses the Codespace Android SDK and local ReXGlue host code generator, and writes the APK under `android/app/build/outputs/apk/release/`. It does not install the APK on a connected phone. Release lint analysis is skipped by default because the current Codespaces Android lint metadata makes that task fail; set `MCLA_RUN_ANDROID_LINT=1` to include it.

Set these environment variables to local tool paths:

```bash
export JAVA_HOME=/path/to/jdk-21
export ANDROID_HOME=/path/to/android-sdk
export REXSDK_DIR=/path/to/android-patched-rexglue-sdk
export REXGLUE_CODEGEN=/path/to/linux-amd64/bin/rexglue
export REXGLUE_HOST_LIB_DIR=/path/to/linux-amd64/lib
export PYTHON_EXECUTABLE=/usr/bin/python3.12
export CMAKE=/path/to/android-sdk/cmake/3.31.6/bin/cmake
```

Then build from the repository root:

```bash
./android/gradlew -p android :app:assembleRelease
```

The result is written to `android/app/build/outputs/apk/release/app-release.apk`. A local build may use the Android debug signing key when no custom signing variables are set; that key is for testing only. Never commit signing keys or passwords.

## Repository hygiene

Game dumps, generated game code, SDK contents, build outputs, logs, and signing keys are ignored by Git. Do not remove those ignore rules or commit those files.
