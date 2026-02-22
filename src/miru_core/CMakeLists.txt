cmake_minimum_required(VERSION 3.10)
project(miru_core)
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
    set(INSTALL_PREFIX "")
elseif (LINUX)
    set(OUT "libmiru_core.so")
    set(GOOS "linux")
    set(FOLDER_NAME "linux_x64")
    set(INSTALL_PREFIX "/lib")
endif()
# Make Script for Linux
set(GO_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${FOLDER_NAME}/${OUT})

# default ldflags for go build (can be overridden via -DLD_FLAG="..." when invoking cmake)
if (NOT DEFINED LD_FLAG)
    set(LD_FLAG "-s -w")
endif()

# build the shared library
add_custom_command(
OUTPUT ${GO_OUTPUT}
COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/${FOLDER_NAME}
COMMAND go build -tags nosqlite -o ${GO_OUTPUT} "-ldflags=${LD_FLAG}" -trimpath -buildmode=c-shared main.go
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/miru-core
COMMENT "Building Go shared library"
VERBATIM
)
message(STATUS "go build -tags nosqlite -o ${GO_OUTPUT} -ldflags=\"${LD_FLAG}\" -trimpath -buildmode=c-shared main.go")
add_custom_target(
    miru_core_build ALL
    DEPENDS ${GO_OUTPUT}
)

# Install the library
if (LINUX)
    set (LIB_PATH ${CMAKE_SOURCE_DIR}/../src/miru_core/${FOLDER_NAME})
else()
    set (LIB_PATH ${CMAKE_SOURCE_DIR}/../src/miru_core/${FOLDER_NAME})
endif()

set (MIRU_CORE ${LIB_PATH}/${OUT})
add_library(MIRU_CORE SHARED IMPORTED)
set_target_properties(MIRU_CORE PROPERTIES
    IMPORTED_LOCATION "${LIB_PATH}/${OUT}"
    IMPORTED_SONAME "${OUT}"
)


install(FILES "${LIB_PATH}/${OUT}" DESTINATION "${CMAKE_INSTALL_PREFIX}${INSTALL_PREFIX}")





message(STATUS "miru_core built")
