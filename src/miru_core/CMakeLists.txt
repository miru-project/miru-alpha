cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "miru_core")
project(${PROJECT_NAME} LANGUAGES CXX)

find_package(Git QUIET)
if (NOT GIT_FOUND)
    message(FATAL_ERROR "Git not found")
else()
    execute_process(COMMAND git submodule update --init --recursive
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    OUTPUT_VARIABLE GIT_ROOT
                    ERROR_QUIET)
endif()

if (WIN32)
    set(OUT "miru_core.dll")
    set(GOOS "windows")
    set(FOLDER_NAME "windows_x64")
elseif (LINUX)
    set(OUT "libmiru_core.so")
    set(GOOS "linux")
    set(FOLDER_NAME "linux_x64")
endif()

set(GO_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${FOLDER_NAME}/${OUT})

# Default ldflags for go build
if (NOT DEFINED LD_FLAG)
    set(LD_FLAG "-s -w")
endif()

# Build the shared library
add_custom_command(
    OUTPUT ${GO_OUTPUT}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/${FOLDER_NAME}
    COMMAND go build -tags nosqlite -o ${GO_OUTPUT} "-ldflags=${LD_FLAG}" -trimpath -buildmode=c-shared main.go
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/miru-core
    COMMENT "Building Go shared library"
    VERBATIM
)

add_custom_target(
    ${PROJECT_NAME}_build ALL
    DEPENDS ${GO_OUTPUT}
)

# Reference-style properties
add_library(${PROJECT_NAME} SHARED IMPORTED GLOBAL)
set_target_properties(${PROJECT_NAME} PROPERTIES
    IMPORTED_LOCATION "${GO_OUTPUT}"
    IMPORTED_SONAME "${OUT}"
    OUTPUT_NAME "${PROJECT_NAME}"
)

target_compile_definitions(${PROJECT_NAME} INTERFACE DART_SHARED_LIB)

# List of absolute paths to libraries that should be bundled with the application.
set(${PROJECT_NAME}_bundled_libraries
    ${GO_OUTPUT}
    PARENT_SCOPE
)

message(STATUS "miru_core built")
