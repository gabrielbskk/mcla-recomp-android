# S23 runtime performance analysis — 2026-10-22

Source: exported diagnostics and runtime log `Documents/MCLA Recomp/log-mcla_010.log.txt` from the Samsung SM-S911B, Android 16. No ADB session was used for this review.

## Observations

- Vulkan initialized on the system Qualcomm Adreno 740 driver. The log contains no fatal exception; the exported previous-process reason is `USER_REQUESTED` with status 0.
- The game-frame sample starts at 30.1 ticks/s, then falls to 12.0 and 2.0–4.2 ticks/s; p95 tick intervals rise as high as 1,553 ms. This confirms severe stalls in the guest game loop.
- Process VmRSS rises from about 909 MiB to about 1,680 MiB during the same run. These values are process resident memory, not total Android PSS.
- The log contains 497 `Creating graphics pipeline state` INFO messages during the run, including after the initial warm-up period. The draw-call counter reports zero per tick throughout, so it is not useful for identifying the bottleneck and must not be trusted as a measurement.
- The exported run was produced by an older binary: it still emits per-pipeline INFO lines and contains no `android thread CPU` samples, although the current source contains the logging-level reduction and thread sampler. The existing log therefore cannot validate those changes.
- The `android perf` render-loop estimate is an ImGui/UI-loop estimate. It is not the number of frames successfully presented by Vulkan and does not contradict the much slower game-frame samples.

## Change made

The Android ReXGlue patch now logs per-pipeline creation details at DEBUG level while retaining INFO on desktop. This reduces high-volume formatting and log writes during pipeline warm-up. Pipeline creation itself is still expensive, so this change is a small overhead reduction and is not claimed to fix the 1–4 tick/s stall.

The Android FPS overlay now distinguishes UI render-loop FPS from guest game-loop ticks per second. The guest rate is smoothed from the timer hook and shown as unavailable if no game tick arrives for two seconds. This prevents the fast ImGui loop from being presented as the game's frame rate.

The guest timer hook no longer reads the ReXGlue draw-call snapshot counter on every game tick. That counter stayed at zero throughout the exported session, so it added hot-path work without providing usable data. The periodic game-frame sample now reports only measured tick rate and interval percentiles.

Cppcheck 2.22 analyzed all 14 project C++ source files with Android enabled. It found only `uninitMemberVarNoCtor` warnings for structs populated with aggregate initialization; source inspection confirmed those fields are supplied at each construction site. No null-pointer, bounds, or performance warnings were reported. This is static analysis only, not a native Android build.

## Build-station audit

The Void Linux notebook now has CMake 4.2.2, Ninja 1.13.2, Clang/LLD 21.1.8, OpenJDK 21, pkg-config, and Cppcheck 2.22. Its hardware is 1.9 GiB RAM, 4 CPU cores, and 4 GiB swap. The notebook still has no Android NDK/SDK CMake toolchain, host ReXGlue code generator, or `game/default.xex`, so it cannot currently produce or validate the Android native target. No full compile was attempted on the low-memory notebook or the S23 while the phone is in use. The Cppcheck run is the only validation of the latest patch; no runtime FPS gain is claimed.

## Next investigation

The Vulkan backend currently passes `VK_NULL_HANDLE` as the `VkPipelineCache` argument to `vkCreateGraphicsPipelines`. ReXGlue's persistent Xenos shader and pipeline-description storage therefore does not provide a persisted Vulkan driver pipeline cache. A device/driver-keyed Vulkan cache is a promising next target, but it needs careful synchronization and cache invalidation before implementation. The current Termux environment lacks the Android CMake toolchain and full SDK platform files, so the SDK-patch changes have not been compiled here.

No APK was generated or installed as part of this analysis.
