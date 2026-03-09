cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "ffmpeg_merge")
project(${PROJECT_NAME} LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Setting FFmpeg library
set(FFMPEG_URL "https://sourceforge.net/projects/avbuild/files/windows-desktop/ffmpeg-8.0-mingw-gcc-lite.tar.xz/download")
set(FFMPEG_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-8.0-mingw-gcc-lite")
set(FFMPEG_ZIP "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg.zip")

# Download and extract FFmpeg if not present
if(NOT EXISTS "${FFMPEG_ROOT}")
    if(NOT EXISTS "${FFMPEG_ZIP}")
        message(STATUS "Downloading FFmpeg from ${FFMPEG_URL}")
        file(DOWNLOAD "${FFMPEG_URL}" "${FFMPEG_ZIP}" SHOW_PROGRESS)
    endif()
    message(STATUS "Extracting FFmpeg to ${CMAKE_CURRENT_SOURCE_DIR}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${FFMPEG_ZIP}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    )
endif()

# Define the library target
add_library(${PROJECT_NAME} SHARED 
  "${CMAKE_CURRENT_SOURCE_DIR}/../cpp/main.cpp"
)

# Apply standard settings from the parent if available
if(COMMAND APPLY_STANDARD_SETTINGS)
    APPLY_STANDARD_SETTINGS(${PROJECT_NAME})
endif()

# Symbols are hidden by default
set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  OUTPUT_NAME "${PROJECT_NAME}"
)

target_include_directories(${PROJECT_NAME} PRIVATE "${FFMPEG_ROOT}/include")
target_compile_definitions(${PROJECT_NAME} PRIVATE
    FLUTTER_PLUGIN_IMPL
    __STDC_CONSTANT_MACROS
    __STDC_LIMIT_MACROS
    __STDC_FORMAT_MACROS
)

# Export definition as per reference
target_compile_definitions(${PROJECT_NAME} PUBLIC DART_SHARED_LIB)

# Reference-style options
if(MSVC)
    # /WX- to avoid treating warnings as errors (common in external headers)
    target_compile_options(${PROJECT_NAME} PRIVATE /Os /GR- /EHsc /WX-)
    target_link_options(${PROJECT_NAME} PRIVATE -opt:ref,icf,lbr)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Os -fno-rtti)
endif()

# Link against FFmpeg libraries
set(FFMPEG_LIBS avcodec avformat avfilter avdevice swresample swscale avutil)
set(FFMPEG_LIB_DIR "${FFMPEG_ROOT}/lib/x86_64")
set(FFMPEG_BIN_DIR "${FFMPEG_ROOT}/bin/x86_64")

foreach(lib ${FFMPEG_LIBS})
    set(LIB_FILE "${FFMPEG_LIB_DIR}/${lib}.lib")
    if(NOT EXISTS "${LIB_FILE}")
        message(FATAL_ERROR "Required library does not exist: ${LIB_FILE}")
    endif()
    target_link_libraries(${PROJECT_NAME} PRIVATE "${LIB_FILE}")
endforeach()

# List of absolute paths to libraries that should be bundled with the plugin.
file(GLOB FFMPEG_DLLS "${FFMPEG_BIN_DIR}/*.dll")
set(${PROJECT_NAME}_bundled_libraries
  $<TARGET_FILE:${PROJECT_NAME}>
  ${FFMPEG_DLLS}
  PARENT_SCOPE
)