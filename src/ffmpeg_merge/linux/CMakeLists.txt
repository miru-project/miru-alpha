cmake_minimum_required(VERSION 3.10)
project(ffmpeg_merge_linux)

# Set output directories for binaries
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Create the library first
add_library(ffmpeg_merge SHARED ${CMAKE_CURRENT_SOURCE_DIR}/../cpp/main.cpp)

# Setting FFmpeg library
set(LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(FFMPEG_URL "https://sourceforge.net/projects/avbuild/files/linux/ffmpeg-8.0-linux-clang-lite-lto.tar.xz/download")
set(FFMPEG_ARCHIVE "${LIB_PATH}/ffmpeg.tar.xz")
set(FFMPEG_ROOT "${LIB_PATH}/ffmpeg-8.0-linux-clang-lite-lto")

# Create directory if it doesn't exist
if(NOT EXISTS "${LIB_PATH}")
    file(MAKE_DIRECTORY "${LIB_PATH}")
endif()

# Download FFmpeg if not already downloaded
if(NOT EXISTS "${FFMPEG_ARCHIVE}")
    message(STATUS "Downloading FFmpeg from ${FFMPEG_URL}")
    file(DOWNLOAD "${FFMPEG_URL}" "${FFMPEG_ARCHIVE}" SHOW_PROGRESS)
endif() 

# Extract FFmpeg if not already extracted
if(NOT EXISTS "${FFMPEG_ROOT}")
    message(STATUS "Extracting FFmpeg to ${LIB_PATH}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xf "${FFMPEG_ARCHIVE}"
        WORKING_DIRECTORY "${LIB_PATH}"
    )
endif()

message(STATUS "FFmpeg root directory: ${FFMPEG_ROOT}")


# Set direct paths to each library file to ensure they are found during linkage
set(LIBPREFIX "/lib/amd64")
# Setup proper FFmpeg paths
include_directories(${FFMPEG_ROOT}/include)

# Dynamically find all libffmpeg.so files for linking and bundling
file(GLOB FFMPEG_LIBS "${FFMPEG_ROOT}${LIBPREFIX}/libffmpeg.so*")

# Pick a library for linking (prefer libffmpeg.so.8 or libffmpeg.so)
if(FFMPEG_LIBS)
    set(FFMPEG_LINK_LIB "${FFMPEG_ROOT}${LIBPREFIX}/libffmpeg.so.8")
    if(NOT EXISTS "${FFMPEG_LINK_LIB}")
        set(FFMPEG_LINK_LIB "${FFMPEG_ROOT}${LIBPREFIX}/libffmpeg.so")
    endif()
    # Fallback to the first one found if preferred names don't exist
    if(NOT EXISTS "${FFMPEG_LINK_LIB}")
        list(GET FFMPEG_LIBS 0 FFMPEG_LINK_LIB)
    endif()

    message(STATUS "Found FFmpeg libraries: ${FFMPEG_LIBS}")
    message(STATUS "Linking against: ${FFMPEG_LINK_LIB}")

    add_library(ffmpeg_shared SHARED IMPORTED)
    set_target_properties(ffmpeg_shared PROPERTIES
        IMPORTED_LOCATION "${FFMPEG_LINK_LIB}"
        IMPORTED_SONAME "libffmpeg.so.8"
    )
    target_link_libraries(ffmpeg_merge PRIVATE ffmpeg_shared)
else()
    message(WARNING "No FFmpeg libraries (libffmpeg.so*) found at ${FFMPEG_ROOT}${LIBPREFIX}")
endif()

# Add compile definitions if needed (may help with some FFmpeg API issues)
target_compile_definitions(ffmpeg_merge PRIVATE
    __STDC_CONSTANT_MACROS
    __STDC_LIMIT_MACROS
    __STDC_FORMAT_MACROS
)

# List of absolute paths to libraries that should be bundled with the plugin.
set(ffmpeg_merge_bundled_libraries
  $<TARGET_FILE:ffmpeg_merge>
  ${FFMPEG_LIBS}
  PARENT_SCOPE
)

# Make the ffmpeg_merge target search for shared libraries in its own directory at runtime.
# This embeds a runpath ($ORIGIN) so the dynamic loader will look for "libffmpeg.so.8" in
# the same folder as libffmpeg_merge.so when the app is bundled.
set_target_properties(ffmpeg_merge PROPERTIES
    BUILD_WITH_INSTALL_RPATH TRUE
    INSTALL_RPATH "$ORIGIN"
    BUILD_RPATH "$ORIGIN"
)
