cmake_minimum_required(VERSION 3.15)
project(MyApp CXX)

set(BOOST_ROOT "/usr") 
set(Boost_INCLUDE_DIR "/usr/include")  

find_package(Boost 1.83 REQUIRED COMPONENTS iostreams regex)
include_directories(${Boost_INCLUDE_DIR})

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

# Add OpenVDB as a submodule
set(OPENVDB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/OpenVDB")

# Use ExternalProject to fetch and build OpenVDB automatically if it's not found
include(ExternalProject)

# Define where to install OpenVDB
set(OPENVDB_INSTALL_DIR "${CMAKE_BINARY_DIR}/openvdb_install")

# If OpenVDB directory exists, we will use it, else we use ExternalProject to download and build it
if(EXISTS "${OPENVDB_DIR}/CMakeLists.txt")
  message(STATUS "Using OpenVDB submodule from: ${OPENVDB_DIR}")
  add_subdirectory(${OPENVDB_DIR})
else()
  # If OpenVDB submodule doesn't exist, use ExternalProject to fetch and build it
  ExternalProject_Add(
    OpenVDB
    GIT_REPOSITORY https://github.com/AcademySoftwareFoundation/openvdb.git
    GIT_TAG master  # Or specify a specific version
    PREFIX ${CMAKE_BINARY_DIR}/openvdb
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${OPENVDB_INSTALL_DIR}
               -DBUILD_SHARED_LIBS=OFF   # Force static libraries
               -DOPENVDB_BUILD_STATIC=ON
               -DOPENVDB_USE_IMATH_HALF=ON
               -DOPENVDB_USE_BLOSC=OFF    # Optional: Disable Blosc compression
               -DOPENVDB_CORE_SHARED=OFF  # Disable OpenVDB shared core
               -DBoost_USE_STATIC_LIBS=ON
               -DTBB_STATIC=ON
               -DZLIB_BUILD_STATIC=ON
               -DBLOSC_USE_STATIC_LIBS=ON
  )

  # Ensure the target OpenVDB is built before MyApp
  add_dependencies(MyApp OpenVDB)

  # Link the downloaded OpenVDB as needed after ExternalProject builds it
  ExternalProject_Get_Property(OpenVDB install_dir)
  set(OPENVDB_INCLUDE_DIR "${install_dir}/include")
  set(OPENVDB_LIBRARIES "${install_dir}/lib/libopenvdb_static.a")
endif()

# Add executable and Link libraries
add_executable(MyApp src/main.cpp)
target_include_directories(MyApp PRIVATE ${OPENVDB_INCLUDE_DIR})
target_link_libraries(MyApp PRIVATE MyLib openvdb_static)

# Require C++17 for MyApp (adjust if needed)
target_compile_features(MyApp PRIVATE cxx_std_17)

# Set rpath for macOS & Linux (so MyApp finds shared libraries)
if(UNIX)
  set_target_properties(MyApp PROPERTIES INSTALL_RPATH "$ORIGIN/lib")
endif()
