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

# Path to the FFmpeg combined shared library
set(FFMPEG_LIB_PATH "${FFMPEG_ROOT}${LIBPREFIX}/libffmpeg.so.8.0")

# If the library exists, create an IMPORTED target and link against it.
if(EXISTS "${FFMPEG_LIB_PATH}")
    message(STATUS "Found FFmpeg library at ${FFMPEG_LIB_PATH}; creating IMPORTED target 'ffmpeg_shared'")
    add_library(ffmpeg_shared SHARED IMPORTED)

    # Point the imported target to the actual file we found (use the full filename)
    set_target_properties(ffmpeg_shared PROPERTIES
        IMPORTED_LOCATION "${FFMPEG_LIB_PATH}"
        IMPORTED_SONAME "libffmpeg.so.8"
    )

    target_link_libraries(ffmpeg_merge PRIVATE ffmpeg_shared)
else()
    message(WARNING "FFmpeg library not found at ${FFMPEG_LIB_PATH}; ffmpeg_merge will not be linked against ffmpeg_shared. Ensure download/extraction succeeded if you need FFmpeg functionality.")
endif()




# Add compile definitions if needed (may help with some FFmpeg API issues)
target_compile_definitions(ffmpeg_merge PRIVATE
    __STDC_CONSTANT_MACROS
    __STDC_LIMIT_MACROS
    __STDC_FORMAT_MACROS
)

# Install rules for our library
install(TARGETS ffmpeg_merge
    LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime
)

if(TARGET ffmpeg_shared)
    # Ensure the bundled ffmpeg shared library is installed alongside our other libs
    # and make sure our ffmpeg_merge library has an RPATH that finds sibling libraries.
    install(FILES "${FFMPEG_LIB_PATH}" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")
endif()

# Make the ffmpeg_merge target search for shared libraries in its own directory at runtime.
# This embeds a runpath ($ORIGIN) so the dynamic loader will look for "libffmpeg.so.8" in
# the same folder as libffmpeg_merge.so when the app is bundled.
set_target_properties(ffmpeg_merge PROPERTIES
    BUILD_WITH_INSTALL_RPATH TRUE
    INSTALL_RPATH "$ORIGIN"
    BUILD_RPATH "$ORIGIN"
)
