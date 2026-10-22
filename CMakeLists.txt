# mcla - ReXGlue Recompiled Project
#
# SDK boilerplate lives in generated/rexglue.cmake.

cmake_minimum_required(VERSION 3.25)
project(mcla LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(generated/rexglue.cmake)
if(ANDROID)
    include_directories("${REXSDK_DIR}/thirdparty/libucontext/include"
                        "${REXSDK_DIR}/thirdparty/imgui"
                        "${REXSDK_DIR}/thirdparty/libucontext/arch/aarch64/include")
endif()

# Sources
set(MCLA_SOURCES
    src/main.cpp
    src/mcla_app.cpp
    src/crash_trace.cpp
    src/audio_fallback.cpp
    src/frame_timing.cpp
    src/render_perf.cpp
    src/perf_options.cpp
    src/warp_fix.cpp
    src/button_prompts.cpp
    src/settings_menu.cpp
    src/sampling_profiler.cpp
    src/code_pointer_scan.cpp
)

if(ANDROID)
    # SDL3 Android loads libmain.so and enters through SDL_main.
    add_library(mcla SHARED ${MCLA_SOURCES})
    set_target_properties(mcla PROPERTIES OUTPUT_NAME main)
    target_compile_options(mcla PRIVATE -include SDL3/SDL_main.h)
elseif(WIN32)
    add_executable(mcla WIN32 ${MCLA_SOURCES})
else()
    add_executable(mcla ${MCLA_SOURCES})
endif()

rexglue_setup_target(mcla)

if(WIN32)
    # timeBeginPeriod for the frame limiter.
    target_link_libraries(mcla PRIVATE winmm)
endif()
