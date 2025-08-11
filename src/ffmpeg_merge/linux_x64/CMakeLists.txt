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

# Debug - list contents of the FFmpeg lib directory to verify library names
file(GLOB FFMPEG_LIB_FILES "${FFMPEG_ROOT}/lib/*.so*")
message(STATUS "Available FFmpeg libraries:")
foreach(lib_file ${FFMPEG_LIB_FILES})
    message(STATUS "Found library: ${lib_file}")
endforeach()

# Setup proper FFmpeg paths
include_directories(${FFMPEG_ROOT}/include)
link_directories(${FFMPEG_ROOT}/lib)

# Set direct paths to each library file to ensure they are found during linkage
set(AVCODEC_LIB "${FFMPEG_ROOT}/lib/libavcodec.so")
set(AVFORMAT_LIB "${FFMPEG_ROOT}/lib/libavformat.so")
set(AVFILTER_LIB "${FFMPEG_ROOT}/lib/libavfilter.so")
set(AVDEVICE_LIB "${FFMPEG_ROOT}/lib/libavdevice.so")
set(SWRESAMPLE_LIB "${FFMPEG_ROOT}/lib/libswresample.so")
set(SWSCALE_LIB "${FFMPEG_ROOT}/lib/libswscale.so")
set(AVUTIL_LIB "${FFMPEG_ROOT}/lib/libavutil.so")

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

# Copy FFmpeg shared libraries to the output directory
file(GLOB FFMPEG_SHARED_LIBS "${FFMPEG_ROOT}/lib/*.so*")
file(COPY ${FFMPEG_SHARED_LIBS} DESTINATION ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

# Add post-build command to copy shared libraries to binary directory if needed
add_custom_command(TARGET ffmpeg_merge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${FFMPEG_ROOT}/lib"
    "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
    COMMENT "Copying FFmpeg shared libraries to output directory"
)

# Install rules for our library
install(TARGETS ffmpeg_merge
    LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime
)

# Install FFmpeg shared libraries alongside the target
install(FILES ${FFMPEG_SHARED_LIBS} 
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime
)