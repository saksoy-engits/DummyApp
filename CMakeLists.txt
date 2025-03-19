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

# Default to Release build if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Define path to the MyLib submodule
set(MYLIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/MyLib")

# Check if MyLib exists and is a Git repo
if(EXISTS "${MYLIB_DIR}/.git")
  # Retrieve current commit hash from MyLib
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
      COMMAND ${GIT_EXECUTABLE} -C ${MYLIB_DIR} fetch
      RESULT_VARIABLE FETCH_RESULT
    )
    if(NOT FETCH_RESULT EQUAL 0)
      message(WARNING "Failed to fetch updates for MyLib")
    endif()
    execute_process(
      COMMAND ${GIT_EXECUTABLE} -C ${MYLIB_DIR} merge origin/master
      RESULT_VARIABLE MERGE_RESULT
    )
    if(NOT MERGE_RESULT EQUAL 0)
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

# Propagate the special build flag to MyLib's configuration
if(BUILD_MYLIB_SPECIAL)
  set(MYLIB_SPECIAL_FLAG ON CACHE BOOL "Compile MyLib with special flag" FORCE)
  message(STATUS "Building MyLib with special flag enabled.")
endif()

# Add MyLib as a subdirectory (it will use its own CMakeLists.txt)
add_subdirectory(${MYLIB_DIR})

# Add MyApp executable
add_executable(MyApp src/main.cpp)

# Link MyLib with MyApp
target_link_libraries(MyApp PRIVATE MyLib)

# Require C++17 for MyApp (adjust if needed)
target_compile_features(MyApp PRIVATE cxx_std_17)
