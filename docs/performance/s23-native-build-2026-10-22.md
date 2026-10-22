# S23 native Android build — 2026-10-22

## Result

The C++ recompilation and Android shared-library link completed successfully
on the S23 using Termux. The artifact is
`$PREFIX/tmp/mcla-s23-native-android-build/libmain.so` (77 MiB).

- ELF: 64-bit little-endian AArch64 shared object, Android API 24.
- SHA-256: `8015e6d14ea144a27ae560975783fe636d73b1944c4e73fb7bfb7c65ae9f5880`
- Direct dynamic dependencies: `librexruntime.so`, `libc.so`, `libm.so`,
  `libiconv.so`, `libOpenSLES.so`, `libdl.so`, `liblog.so`, `libandroid.so`,
  and `libc++_shared.so`.
- The build used the Android Vulkan backend and Android SDL platform/input/audio
  configuration. The Android API floor is 24.

## Build fixes

The first shared-library link exposed two missing position-independent-code
settings in the Termux-hosted Android build:

1. Static `adrenotools` and `linkernsbypass` archives are embedded in
   `librexruntime.so`. Their targets now explicitly enable PIC for Android.
2. Generated PPC translation units form the `mcla_recomp` object library linked
   into `libmain.so`. That target now explicitly enables PIC for Android.

The Android Vulkan loader callback is optional. Its declaration is weak and
the SDK checks it before calling, allowing the system Vulkan loader when no
custom loader callback is linked. The patch script also handles an already
patched checkout idempotently.

## Validation limits

This confirms compilation and ELF metadata only. No APK/XAPK was packaged or
installed, the S23 game process was not launched, and no FPS or stability
measurement was made. This build must not be described as a tested playable
release. It is not validated on Mali or other Android GPUs. A compiler warning
about the AArch64 FPCR inline assembly operand width remains to be reviewed.

The XEX and generated game assets remain local and are not included in this
repository record.
