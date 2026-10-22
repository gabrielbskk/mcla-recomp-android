# S23 Android build preparation — 2026-10-22

## Change

The ReXGlue Android ARM64 patch now gates its Linux SDL backend options behind
`UNIX AND NOT APPLE AND NOT ANDROID`. The prior condition enabled X11,
Wayland, ALSA, PulseAudio, and PipeWire on Android, despite the Android port
using SDL's Android platform backend and the SDK's `ANativeWindow` Vulkan
surface. This would make configuration depend on desktop Linux libraries and
could prevent an Android build from configuring on the S23.

The patch is recorded in `patches/rexglue-v0.10.0-android-arm64.patch` and was
applied to the local ReXGlue v0.10.0 checkout. Reverse application checking
confirmed that the complete patch, including this new hunk, matches the
patched SDK tree.

## Build station status

- The Termux compiler targets `aarch64-unknown-linux-android24`; a separate
  earlier probe produced an Android ARM64 shared library.
- The Termux NDK sysroot r30 package, CMake, Ninja, Clang 21, Vulkan headers,
  glslang, and SPIR-V tools are installed.
- The Termux package set does not include Google's `android.toolchain.cmake`.
  A custom CMake configuration using Termux's Android-targeting Clang still
  needs to be evaluated against the complete SDK.
- SDL3 and the remaining ReXGlue submodules are still being initialized.
- No SDK or game target build has been run yet, and no APK was generated or
  installed. No runtime performance change is claimed.

## Next steps

Finish submodule initialization, configure the host ARM64 ReXGlue code
generator under Termux, run code generation from the locally provided
`default.xex`, then configure/build the Android ARM64 native target with the
Termux sysroot. Keep all generated game data and binaries local; do not upload
the XEX or generated proprietary game assets.
