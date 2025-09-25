cmake_minimum_required(VERSION 3.10)
project(ffmpeg_merge)



set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

add_library(ffmpeg_shared SHARED IMPORTED)
set_target_properties(ffmpeg_shared PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-8.0-android-lite-lto/lib/${CMAKE_ANDROID_ARCH_ABI}/libffmpeg.so
    IMPORTED_SONAME "libffmpeg.so"
    INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-8.0-android-lite-lto/include
)
# add_library(avcodec SHARED IMPORTED)
# set_target_properties(avcodec 
#                         PROPERTIES 
#                         IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libavcodec.so
#                         INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include/${CMAKE_ANDROID_ARCH_ABI})

# add_library(avformat SHARED IMPORTED)
# set_target_properties(avformat 
#                         PROPERTIES 
#                         IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libavformat.so
#                         INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include/${CMAKE_ANDROID_ARCH_ABI})

# add_library(avutil SHARED IMPORTED)
# set_target_properties(avutil 
#                         PROPERTIES 
#                         IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libavutil.so
#                         INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include/${CMAKE_ANDROID_ARCH_ABI})

# add_library(swresample SHARED IMPORTED)
# set_target_properties(swresample 
#                         PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libswresample.so
#                         INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include/${CMAKE_ANDROID_ARCH_ABI})

# add_library(swscale SHARED IMPORTED)
# set_target_properties(swscale 
#                         PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/lib/${CMAKE_ANDROID_ARCH_ABI}/libswscale.so
#                         INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/include/${CMAKE_ANDROID_ARCH_ABI})

add_library(ffmpeg_merge SHARED ${CMAKE_CURRENT_SOURCE_DIR}/../cpp/main.cpp)

target_include_directories(ffmpeg_merge PRIVATE ${CMAKE_SOURCE_DIR}/../cpp)
target_include_directories(ffmpeg_merge PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-8.0-android-lite-lto/include)
target_link_libraries(ffmpeg_merge
ffmpeg_shared
                )
    


