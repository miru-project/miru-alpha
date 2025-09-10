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
set(FFMPEG_URL "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linux64-lgpl-shared-7.1.tar.xz")
set(FFMPEG_ARCHIVE "${LIB_PATH}/ffmpeg.tar.xz")
set(FFMPEG_ROOT "${LIB_PATH}/ffmpeg-n7.1-latest-linux64-lgpl-shared-7.1")

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
set(AVCODEC_LIB "/lib/libavcodec.so")
set(AVFORMAT_LIB "/lib/libavformat.so")
set(AVFILTER_LIB "/lib/libavfilter.so")
set(AVDEVICE_LIB "/lib/libavdevice.so")
set(SWRESAMPLE_LIB "/lib/libswresample.so")
set(SWSCALE_LIB "/lib/libswscale.so")
set(AVUTIL_LIB "/lib/libavutil.so")


foreach(lib ${AVCODEC_LIB} ${AVFORMAT_LIB} ${AVFILTER_LIB} ${AVDEVICE_LIB} ${SWRESAMPLE_LIB} ${SWSCALE_LIB} ${AVUTIL_LIB})
    if(NOT EXISTS "${FFMPEG_ROOT}${lib}")
        message(FATAL_ERROR "Required library does not exist: ${lib}")
    endif()
    message(STATUS "Found FFmpeg library: ${FFMPEG_ROOT}${lib}")
endforeach()


# Setup proper FFmpeg paths
include_directories(${FFMPEG_ROOT}/include)
link_directories(${CMAKE_INSTALL_PREFIX}/lib)




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

install(DIRECTORY "${FFMPEG_ROOT}/lib/"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime
    FILES_MATCHING PATTERN "*.so*"
)