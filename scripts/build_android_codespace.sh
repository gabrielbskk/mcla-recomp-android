#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-${HOME}/Android/Sdk}}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME}}"
export REXSDK_DIR="${REXSDK_DIR:-${repo_root}/third_party/rexglue-sdk}"
export REXGLUE_CODEGEN="${REXGLUE_CODEGEN:-${REXSDK_DIR}/out/linux-amd64/Release/rexglue}"
export REXGLUE_HOST_LIB_DIR="${REXGLUE_HOST_LIB_DIR:-$(dirname "${REXGLUE_CODEGEN}")}"

if [[ ! -d "${ANDROID_HOME}" ]]; then
    echo "Android SDK not found: ${ANDROID_HOME}" >&2
    exit 1
fi
if [[ ! -f "${REXSDK_DIR}/CMakeLists.txt" ]]; then
    echo "ReXGlue SDK not found: ${REXSDK_DIR}" >&2
    exit 1
fi
if [[ ! -x "${REXGLUE_CODEGEN}" ]]; then
    echo "Host ReXGlue code generator is missing or not executable: ${REXGLUE_CODEGEN}" >&2
    exit 1
fi
if [[ ! -f "${repo_root}/game/default.xex" ]]; then
    echo "Missing game/default.xex. Provide your own extracted game dump in this private Codespace." >&2
    exit 1
fi

# Enable the SDK's existing primitive/fill fallbacks on Android GPUs that lack
# optional geometryShader or fillModeNonSolid Vulkan features.
python3 "${repo_root}/scripts/patch_android_rexglue.py" --sdk "${REXSDK_DIR}"

cd "${repo_root}"
gradle_args=(-p android :app:assembleRelease)

# The current Codespaces Android lint metadata makes lintVitalAnalyzeRelease
# fail independently of compilation. Set MCLA_RUN_ANDROID_LINT=1 to run it.
if [[ "${MCLA_RUN_ANDROID_LINT:-0}" != "1" ]]; then
    gradle_args+=(-x lintVitalRelease -x lintVitalAnalyzeRelease -x lintVitalReportRelease)
fi

./android/gradlew "${gradle_args[@]}"
echo "APK: ${repo_root}/android/app/build/outputs/apk/release/app-release.apk"
