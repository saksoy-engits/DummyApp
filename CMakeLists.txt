cmake_minimum_required(VERSION 3.15)
project(MyApp CXX)

# Ensure Git is available
find_package(Git REQUIRED)
if(NOT GIT_FOUND)
  message(FATAL_ERROR "Git is required but not found!")
endif()

# Option to update MyLib submodule to the latest commit
option(UPDATE_MYLIB "Update MyLib to the latest commit" OFF)

# Option to build MyLib with a special compile flag
option(BUILD_MYLIB_SPECIAL "Compile MyLib with special flag" OFF)

# Set default build type to Release
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Detect platform and set appropriate flags
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(OS_NAME "Windows")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPLATFORM_WINDOWS")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(OS_NAME "Linux")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPLATFORM_LINUX")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(OS_NAME "macOS")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPLATFORM_MACOS")
endif()
message(STATUS "Compiling for: ${OS_NAME}")

# Define path to the MyLib submodule
set(MYLIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/MyLib")

# Check if MyLib exists and is a Git repo
if(EXISTS "${MYLIB_DIR}/.git")
  execute_process(
    COMMAND ${GIT_EXECUTABLE} -C ${MYLIB_DIR} rev-parse HEAD
    OUTPUT_VARIABLE MYLIB_COMMIT
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  message(STATUS "Current MyLib commit: ${MYLIB_COMMIT}")

  # Optionally update MyLib
  if(UPDATE_MYLIB)
    message(STATUS "Updating MyLib submodule...")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} -C ${MYLIB_DIR} pull origin main
      RESULT_VARIABLE PULL_RESULT
    )
    if(NOT PULL_RESULT EQUAL 0)
      message(FATAL_ERROR "Failed to update MyLib to the latest commit!")
    endif()
    execute_process(
      COMMAND ${GIT_EXECUTABLE} -C ${MYLIB_DIR} rev-parse HEAD
      OUTPUT_VARIABLE MYLIB_NEW_COMMIT
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(STATUS "MyLib updated to commit: ${MYLIB_NEW_COMMIT}")
  endif()
else()
  message(WARNING "MyLib submodule not found at ${MYLIB_DIR}")
endif()

# Propagate the special build flag to MyLib
if(BUILD_MYLIB_SPECIAL)
  set(MYLIB_SPECIAL_FLAG ON CACHE BOOL "Compile MyLib with special flag" FORCE)
  message(STATUS "Building MyLib with special flag enabled.")
endif()

# Cross-Compilation Toolchain (if needed)
if(CMAKE_TOOLCHAIN_FILE)
  message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")
endif()

# Add MyLib as a subdirectory (uses its own CMakeLists.txt)
add_subdirectory(${MYLIB_DIR})

# Add OpenVDB (assumed as a submodule)
set(OPENVDB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/OpenVDB")
if(EXISTS "${OPENVDB_DIR}/CMakeLists.txt")
  set(OPENVDB_BUILD_STATIC ON CACHE BOOL "Build OpenVDB as a static library" FORCE)
  add_subdirectory(${OPENVDB_DIR})
else()
  message(FATAL_ERROR "OpenVDB submodule not found! Run `git submodule update --init --recursive`")
endif()

# Add MyApp executable
add_executable(MyApp src/main.cpp)

# Link MyLib and OpenVDB with MyApp
target_link_libraries(MyApp PRIVATE MyLib openvdb_static)

# Require C++17 for MyApp (adjust if needed)
target_compile_features(MyApp PRIVATE cxx_std_17)

# Set rpath for macOS & Linux (so MyApp finds shared libraries)
if(UNIX)
  set_target_properties(MyApp PROPERTIES INSTALL_RPATH "$ORIGIN/lib")
endif()
