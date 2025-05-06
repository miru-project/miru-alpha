cmake_minimum_required(VERSION 3.10)
project(ffmpeg_merge)





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
    


