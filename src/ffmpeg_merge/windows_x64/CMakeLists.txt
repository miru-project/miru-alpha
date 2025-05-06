cmake_minimum_required(VERSION 3.10)
project(ffmpeg_merge_windows)

# Set output directories for binaries
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Create the library first
add_library(ffmpeg_merge SHARED ${CMAKE_CURRENT_SOURCE_DIR}/../cpp/main.cpp)

# Setting FFmpeg library
set(LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(FFMPEG_URL "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2025-05-05-12-59/ffmpeg-n7.1.1-6-g48c0f071d4-win64-lgpl-shared-7.1.zip")
set(FFMPEG_ZIP "${LIB_PATH}/ffmpeg.zip")
set(FFMPEG_ROOT "${LIB_PATH}/ffmpeg-n7.1.1-6-g48c0f071d4-win64-lgpl-shared-7.1")

# Create directory if it doesn't exist
if(NOT EXISTS "${LIB_PATH}")
    file(MAKE_DIRECTORY "${LIB_PATH}")
endif()

# Download FFmpeg if not already downloaded
if(NOT EXISTS "${FFMPEG_ZIP}")
    message(STATUS "Downloading FFmpeg from ${FFMPEG_URL}")
    file(DOWNLOAD "${FFMPEG_URL}" "${FFMPEG_ZIP}" SHOW_PROGRESS)
endif()

# Extract FFmpeg if not already extracted
if(NOT EXISTS "${FFMPEG_ROOT}")
    message(STATUS "Extracting FFmpeg to ${LIB_PATH}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${FFMPEG_ZIP}"
        WORKING_DIRECTORY "${LIB_PATH}"
    )
endif()

message(STATUS "FFmpeg root directory: ${FFMPEG_ROOT}")

# Debug - list contents of the FFmpeg lib directory to verify library names
file(GLOB FFMPEG_LIB_FILES "${FFMPEG_ROOT}/lib/*.lib")
message(STATUS "Available FFmpeg libraries:")
foreach(lib_file ${FFMPEG_LIB_FILES})
    message(STATUS "Found library: ${lib_file}")
endforeach()

# Setup proper FFmpeg paths
include_directories(${FFMPEG_ROOT}/include)
link_directories(${FFMPEG_ROOT}/lib)

# Set direct paths to each library file to ensure they are found during linkage
set(AVCODEC_LIB "${FFMPEG_ROOT}/lib/avcodec.lib")
set(AVFORMAT_LIB "${FFMPEG_ROOT}/lib/avformat.lib")
set(AVFILTER_LIB "${FFMPEG_ROOT}/lib/avfilter.lib")
set(AVDEVICE_LIB "${FFMPEG_ROOT}/lib/avdevice.lib")
set(SWRESAMPLE_LIB "${FFMPEG_ROOT}/lib/swresample.lib")
set(SWSCALE_LIB "${FFMPEG_ROOT}/lib/swscale.lib")
set(AVUTIL_LIB "${FFMPEG_ROOT}/lib/avutil.lib")

# Verify the libraries exist
foreach(lib ${AVCODEC_LIB} ${AVFORMAT_LIB} ${AVFILTER_LIB} ${AVDEVICE_LIB} ${SWRESAMPLE_LIB} ${SWSCALE_LIB} ${AVUTIL_LIB})
    if(NOT EXISTS "${lib}")
        message(FATAL_ERROR "Required library does not exist: ${lib}")
    endif()
endforeach()

# Link against FFmpeg libraries with full paths
target_link_libraries(ffmpeg_merge PRIVATE 
    ${AVCODEC_LIB}
    ${AVFORMAT_LIB}
    ${AVFILTER_LIB}
    ${AVDEVICE_LIB}
    ${SWRESAMPLE_LIB}
    ${SWSCALE_LIB}
    ${AVUTIL_LIB}
)

# Add compile definitions if needed (may help with some FFmpeg API issues)
target_compile_definitions(ffmpeg_merge PRIVATE
    __STDC_CONSTANT_MACROS
    __STDC_LIMIT_MACROS
    __STDC_FORMAT_MACROS
)

# Copy FFmpeg DLLs to the output directory
file(GLOB FFMPEG_DLLS "${FFMPEG_ROOT}/bin/*.dll")
file(COPY ${FFMPEG_DLLS} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

# Add post-build command to copy DLLs to binary directory if needed
add_custom_command(TARGET ffmpeg_merge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${FFMPEG_ROOT}/bin"
    "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    COMMENT "Copying FFmpeg DLLs to output directory"
)

# Install rules for our library
install(TARGETS ffmpeg_merge
    RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"  # For Windows DLLs
    LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime
)

# Install FFmpeg DLLs alongside the target
install(FILES ${FFMPEG_DLLS} 
    DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime
)