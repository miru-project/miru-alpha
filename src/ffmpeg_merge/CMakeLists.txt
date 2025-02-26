cmake_minimum_required(VERSION 3.10)
project(ffmpeg_merge)




if (LINUX)
    set (LIB_PATH ${CMAKE_SOURCE_DIR}/../src/ffmpeg_merge/linux_x64)
endif()

if (WIN32)
    set (LIB_PATH ${CMAKE_SOURCE_DIR}/../src/ffmpeg_merge/windows_x64)
endif()

if (ANDROID)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
    set (LIB_PATH ${CMAKE_SOURCE_DIR}/android_${CMAKE_ANDROID_ARCH_ABI})
    set(cpp_DIR ${CMAKE_SOURCE_DIR})
    set(ffmpeg_DIR ${CMAKE_SOURCE_DIR}/android_${CMAKE_ANDROID_ARCH_ABI})
    add_library(avcodec SHARED IMPORTED)
    # add ffmpeg dependecy
    set_target_properties(avcodec 
                            PROPERTIES 
                            IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/android/lib/${CMAKE_ANDROID_ARCH_ABI}/libavcodec.so
                            INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/android/include/${CMAKE_ANDROID_ARCH_ABI})
    add_library(avformat SHARED IMPORTED)
    set_target_properties(avformat 
                            PROPERTIES 
                            IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/android/lib/${CMAKE_ANDROID_ARCH_ABI}/libavformat.so
                            INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/android/include/${CMAKE_ANDROID_ARCH_ABI})
    add_library(avutil SHARED IMPORTED)
    set_target_properties(avutil 
                            PROPERTIES 
                            IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/android/lib/${CMAKE_ANDROID_ARCH_ABI}/libavutil.so
                            INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/android/include/${CMAKE_ANDROID_ARCH_ABI})

    add_library(swresample SHARED IMPORTED)
    set_target_properties(swresample 
                            PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/android/lib/${CMAKE_ANDROID_ARCH_ABI}/libswresample.so
                            INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/android/include/${CMAKE_ANDROID_ARCH_ABI})
    add_library(swscale SHARED IMPORTED)
    set_target_properties(swscale 
                            PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/android/lib/${CMAKE_ANDROID_ARCH_ABI}/libswscale.so
                            INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/android/include/${CMAKE_ANDROID_ARCH_ABI})
    
    
                            
    add_library(ffmpeg_merge SHARED ${CMAKE_SOURCE_DIR}/cpp/main.cpp)
    target_include_directories(ffmpeg_merge PRIVATE ${CMAKE_SOURCE_DIR}/cpp)
    target_link_libraries(ffmpeg_merge
                            avcodec
                            avformat
                            avutil
                            swresample
                            swscale
                            )
    
    
else()

    # Create shared library
    add_library(ffmpeg_merge SHARED ${CMAKE_SOURCE_DIR}/../src/ffmpeg_merge/cpp/main.cpp)

    message(STATUS "FFMPEG_INCLUDE_DIR: ${FFMPEG_INCLUDE_DIR}")

    # Find FFmpeg library from Flutter plugin
    find_library(FFMPEG_LIB
        NAMES "libffmpeg.so.7" 
        PATHS 
        "${CMAKE_BINARY_DIR}/bundle/lib"
        "${CMAKE_BINARY_DIR}/../../../build/linux/x64/debug/bundle/lib"
        "${LIB_PATH}"
        NO_DEFAULT_PATH
    )

    if(FFMPEG_LIB)
    message(STATUS "Found FFMPEG library: ${FFMPEG_LIB}")
else()
    message(WARNING "FFMPEG library not found in search paths!")
endif()

# Set library properties with RPATH to look in the same directory
set_target_properties(ffmpeg_merge PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "ffmpeg_merge"
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BUILD_DIR}/lib"
    INSTALL_RPATH "$ORIGIN"
    BUILD_WITH_INSTALL_RPATH TRUE
)

# Link against FFmpeg, libc++ and libc++abi
target_link_libraries(ffmpeg_merge
    PRIVATE
    ${FFMPEG_LIB}
    -lc++
    -lc++abi
)

# Install rules for our library
install(TARGETS ffmpeg_merge
    LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime
)

# CRITICAL: Copy the FFmpeg shared library to the output directory
if(FFMPEG_LIB AND EXISTS "${FFMPEG_LIB}")
    get_filename_component(FFMPEG_LIB_NAME "${FFMPEG_LIB}" NAME)
    message(STATUS "Installing ${FFMPEG_LIB} to ${CMAKE_INSTALL_PREFIX}/lib")
    
    # Copy for installation
    install(FILES "${FFMPEG_LIB}" 
            DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
            COMPONENT Runtime)
    
    # Also copy to build directory for development testing
    add_custom_command(TARGET ffmpeg_merge POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${FFMPEG_LIB}"
        "${PROJECT_BUILD_DIR}/lib/${FFMPEG_LIB_NAME}")
else()
    message(FATAL_ERROR "FFmpeg library not found or doesn't exist at ${FFMPEG_LIB}. Cannot continue build.")
endif()

endif()



# if(NOT FFMPEG_LIB)
#     message(FATAL_ERROR "FFmpeg library not found!")
# endif()

# target_compile_definitions(ffigen_app PUBLIC DART_SHARED_LIB)