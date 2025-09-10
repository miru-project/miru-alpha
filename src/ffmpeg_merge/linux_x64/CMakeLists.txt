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
set(FFMPEG_URL "https://sourceforge.net/projects/avbuild/files/linux/ffmpeg-master-linux-clang-lite-lto.tar.xz/download")
set(FFMPEG_ARCHIVE "${LIB_PATH}/ffmpeg.tar.xz")
set(FFMPEG_ROOT "${LIB_PATH}/ffmpeg-master-linux-clang-lite-lto")

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
set(AVCODEC_LIB "${LIBPREFIX}/libavcodec.so")
set(AVFORMAT_LIB "${LIBPREFIX}/libavformat.so")
set(AVFILTER_LIB "${LIBPREFIX}/libavfilter.so")
set(AVDEVICE_LIB "${LIBPREFIX}/libavdevice.so")
set(SWRESAMPLE_LIB "${LIBPREFIX}/libswresample.so")
set(SWSCALE_LIB "${LIBPREFIX}/libswscale.so")
set(AVUTIL_LIB "${LIBPREFIX}/libavutil.so")


foreach(lib ${AVCODEC_LIB} ${AVFORMAT_LIB} ${AVFILTER_LIB} ${AVDEVICE_LIB} ${SWRESAMPLE_LIB} ${SWSCALE_LIB} ${AVUTIL_LIB})
    if(NOT EXISTS "${FFMPEG_ROOT}${lib}")
        message(FATAL_ERROR "Required library does not exist: ${FFMPEG_ROOT}${lib}")
    endif()
    message(STATUS "Found FFmpeg library: ${FFMPEG_ROOT}${lib}")
endforeach()


# Setup proper FFmpeg paths
include_directories(${FFMPEG_ROOT}/include)
link_directories(${CMAKE_INSTALL_PREFIX}${LIBPREFIX})




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

install(DIRECTORY "${FFMPEG_ROOT}${LIBPREFIX}"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime
    FILES_MATCHING PATTERN "*.so*"
)