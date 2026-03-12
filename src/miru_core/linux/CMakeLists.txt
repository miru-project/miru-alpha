cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "miru_core")
project(${PROJECT_NAME} LANGUAGES CXX)

find_package(Git QUIET)
if (NOT GIT_FOUND)
    message(FATAL_ERROR "Git not found")
else()
    execute_process(COMMAND git submodule update --init --recursive
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/..
                    OUTPUT_VARIABLE GIT_ROOT
                    ERROR_QUIET)
endif()

set(OUT "libmiru_core.so")
set(GOOS "linux")

set(GO_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${OUT})

# Default ldflags for go build
if (NOT DEFINED LD_FLAG)
    set(LD_FLAG "-s -w")
endif()

# Build the shared library
add_custom_command(
    OUTPUT ${GO_OUTPUT}
    COMMAND go build -tags nosqlite -o ${GO_OUTPUT} "-ldflags=${LD_FLAG}" -trimpath -buildmode=c-shared main.go
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../miru-core
    COMMENT "Building Go shared library for Linux"
    VERBATIM
)

add_custom_target(
    ${PROJECT_NAME}_build ALL
    DEPENDS ${GO_OUTPUT}
)

# Reference-style properties
add_library(${PROJECT_NAME} SHARED IMPORTED GLOBAL)
add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}_build)

set_target_properties(${PROJECT_NAME} PROPERTIES
    IMPORTED_LOCATION "${GO_OUTPUT}"
    IMPORTED_SONAME "${OUT}"
    OUTPUT_NAME "${PROJECT_NAME}"
)

target_compile_definitions(${PROJECT_NAME} INTERFACE DART_SHARED_LIB)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(miru_core_bundled_libraries
  $<TARGET_FILE:${PROJECT_NAME}>
  PARENT_SCOPE
)

message(STATUS "miru_core setup complete for linux")
