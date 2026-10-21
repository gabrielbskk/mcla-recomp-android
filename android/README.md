# Android ARM64 recomp target (experimental)

This target cross-compiles the ReXGlue MCLA recomp project to Android ARM64 and uses SDL3 with the Android Vulkan backend. It is intended to produce the native game library `libmain.so`; this does not create or install an APK.

The code generator must run on the Linux build host, then the generated C++ is compiled by the Android NDK for `arm64-v8a`. Keep the host ReXGlue v0.10.0 executable and its Linux runtime libraries separate from the Android SDK build tree.

## Required inputs

- A user-owned, supported MCLA Complete Edition Xbox 360 dump extracted to `game/`, including `game/default.xex`.
- Android NDK, CMake 3.25+, Ninja, and an Android-patched ReXGlue SDK v0.10.0 source tree.
- A host-native ReXGlue v0.10.0 `rexglue` executable and host runtime libraries.

The repository does not contain or distribute game code or assets. The build script stops before code generation if `game/default.xex` is absent.

## Build

```bash
export ANDROID_NDK_HOME=/path/to/android-ndk
export REXSDK_DIR=/path/to/android-patched-rexglue-sdk
export REXGLUE_CODEGEN=/path/to/linux-amd64/bin/rexglue
export REXGLUE_HOST_LIB_DIR=/path/to/linux-amd64/lib
export CMAKE=/path/to/cmake
scripts/build_android.sh
```

The configure preset targets arm64-v8a, Android API 26, Vulkan enabled, with D3D12 and Tracy disabled. The Android folder includes SDLActivity, Gradle, the manifest, and native-library packaging. After the game dump and Android SDK are available, run ./gradlew -p android :app:assembleRelease. Copy the full extracted game tree to Android/data/org.mcla.recomp/files/game/; the app searches that app-specific external and internal storage path. Game data is not bundled in the APK. File-picker import and device launch still need implementation and testing. No APK has been built or installed.

The Android SDK patch is `patches/rexglue-v0.10.0-android-arm64.patch`, based directly on clean ReXGlue v0.10.0. It is separate from the desktop/PS5 patch series; do not stack those patches without rebasing overlapping files. The current Codespaces build uses this patch in `/tmp`.
