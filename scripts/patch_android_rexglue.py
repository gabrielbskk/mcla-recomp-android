#!/usr/bin/env python3
"""Apply Android-specific Vulkan feature fallbacks to the external ReXGlue SDK."""

from pathlib import Path
import argparse


PATCHES = {
    "vulkan_require_geometry_shader": (
        "REXCVAR_DEFINE_BOOL(vulkan_require_geometry_shader, !REX_PLATFORM_MAC,",
        "REXCVAR_DEFINE_BOOL(vulkan_require_geometry_shader, !REX_PLATFORM_MAC && !REX_PLATFORM_ANDROID,",
    ),
    "vulkan_require_fill_mode_non_solid": (
        "REXCVAR_DEFINE_BOOL(vulkan_require_fill_mode_non_solid, !REX_PLATFORM_MAC,",
        "REXCVAR_DEFINE_BOOL(vulkan_require_fill_mode_non_solid, !REX_PLATFORM_MAC && !REX_PLATFORM_ANDROID,",
    ),
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--sdk", required=True, type=Path, help="ReXGlue SDK source directory")
    args = parser.parse_args()

    source = args.sdk / "src/ui/vulkan/vulkan_device.cpp"
    if not source.is_file():
        raise SystemExit(f"ReXGlue Vulkan source not found: {source}")

    text = source.read_text(encoding="utf-8")
    changed = False
    for name, (upstream, android) in PATCHES.items():
        if android in text:
            continue
        if text.count(upstream) != 1:
            raise SystemExit(f"Expected one known default for {name}; SDK may have changed: {source}")
        text = text.replace(upstream, android, 1)
        changed = True

    if changed:
        source.write_text(text, encoding="utf-8")
        print("Applied Android Vulkan fallback defaults for geometry shaders and non-solid fill.")
    else:
        print("Android Vulkan fallback defaults already applied.")


if __name__ == "__main__":
    main()
