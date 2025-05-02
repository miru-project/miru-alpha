cmake_minimum_required(VERSION 3.10)
project(miru_core)


if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/miru_core)
    message(STATUS "miru_core found")
else()
    message(STATUS "miru_core not found")
    execute_process(
        COMMAND git clone  https://github.com/miru-project/miru-core.git ${CMAKE_CURRENT_SOURCE_DIR}/miru_core
    )
    
endif()

# # Reference: https://cmake.org/cmake/help/v3.10/manual/cmake-variables.7.html
# # Make Script for Android 
# if(ANDROID)
    
#     set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android/${CMAKE_ANDROID_ARCH_ABI})
#     set(GO_OUTPUT ${OUTPUT_DIR}/libmiru_core.so)
#     message(STATUS "CMAKE_ANDROID_NDK: ${CMAKE_ANDROID_NDK}")


#     # For Debugging
#     message(STATUS "NDK_CLANG_PATH: ${NDK_CLANG_PATH}")
#     message(STATUS "CMAKE_ANDROID_API: ${CMAKE_ANDROID_API}")
#     message(STATUS "OUTPUT_DIR: ${OUTPUT_DIR}")
#     message(STATUS "GOARCH: ${GOARCH}")
#     message(STATUS "GO_OUTPUT: ${GO_OUTPUT}")
#     message(STATUS "Using compiler: ${CC_COMPILER}")
#     message(STATUS "CMAKE_CURRENT_SOURCE_DIR : ${CMAKE_CURRENT_SOURCE_DIR}")

#     add_library(miru_core SHARED ${GO_OUTPUT})
#     set_target_properties(miru_core PROPERTIES LINKER_LANGUAGE CXX) 

# Make Script for Linux
if (LINUX)
    set(GO_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64/libmiru_core.so)

    # build the shared library
    add_custom_command(
    OUTPUT ${GO_OUTPUT}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/linux_x64
    COMMAND GOOS=linux GOARCH=amd64 go build -o ${GO_OUTPUT} -ldflags=${LD_FLAG} -trimpath -buildmode=c-shared main.go
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/miru_core
    COMMENT "Building Go shared library"
    VERBATIM
    )
    add_custom_target(
        miru_core_build ALL
        DEPENDS ${GO_OUTPUT}
    )

    # Install the library
    set (LIB_PATH ${CMAKE_SOURCE_DIR}/../src/miru_core/linux_x64)
    set (MIRU_CORE ${LIB_PATH}/libmiru_core.so)
    add_library(MIRU_CORE SHARED IMPORTED)
    set_target_properties(MIRU_CORE PROPERTIES
        IMPORTED_LOCATION "${LIB_PATH}/libmiru_core.so"
        IMPORTED_SONAME "libmiru_core.so"
    )
    install(FILES "${LIB_PATH}/libmiru_core.so" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib")

endif()





message(STATUS "miru_core built")
