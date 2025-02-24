cmake_minimum_required(VERSION 3.10)
project(ffmpeg_merge)

# Force using Clang compiler
# set(CMAKE_C_COMPILER gvv)
# set(CMAKE_CXX_COMPILER clang++)

# set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)


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
    add_library(ffmpeg_merge SHARED ${CMAKE_SOURCE_DIR}/cpp/main.cpp)

    target_include_directories(ffmpeg_merge PRIVATE ${CMAKE_SOURCE_DIR}/cpp)
    target_link_libraries(ffmpeg_merge
                            avcodec
                            avformat
                            avutil
                            )
    
else()
    message(STATUS "Path: ${LIB_PATH}")
    message(STATUS "Found FFmpeg: ${FFMPEG_LIB}")

    # # Set RPATH settings
    # set(CMAKE_SKIP_BUILD_RPATH FALSE)
    # set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    # set(CMAKE_INSTALL_RPATH "$ORIGIN")
    # set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

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

    # Set library properties
    set_target_properties(ffmpeg_merge PROPERTIES
        PREFIX "lib"
        OUTPUT_NAME "ffmpeg_merge"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    )

    # Link against FFmpeg, libc++ and libc++abi
    target_link_libraries(ffmpeg_merge
        PRIVATE
        ${FFMPEG_LIB}
        -lc++
        -lc++abi
    )


    # Install rules
    install(TARGETS ffmpeg_merge
        LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
        COMPONENT Runtime
    )

endif()



# if(NOT FFMPEG_LIB)
#     message(FATAL_ERROR "FFmpeg library not found!")
# endif()

# target_compile_definitions(ffigen_app PUBLIC DART_SHARED_LIB)