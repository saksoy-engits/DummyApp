# MyApp

MyApp is a sample C++ project that demonstrates how to integrate a custom library (MyLib) as a Git submodule and third-party libraries like OpenVDB. The project uses CMake for configuration and building, automatically checks for the latest Git commit of MyLib, and supports special build configurations. This README explains the project structure, build process, how to extend the system, and how to integrate OpenVDB as a statically linked library for a fully portable executable.

## Table of Contents
- [Project Overview](#project-overview)
- [File Structure](#file-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Building the Project](#building-the-project)
- [Running the Application](#running-the-application)
- [CMake Options and Special Flags](#cmake-options-and-special-flags)
- [Adding New Libraries](#adding-new-libraries)

## Project Overview
MyApp demonstrates:
- Integrating **MyLib** as a Git submodule.
- Automatically checking and updating MyLib’s Git commit during configuration.
- Building **MyLib** in different configurations (Debug, Release, or with a special compile flag).
- A modular structure that facilitates future integration of third-party libraries, including **OpenVDB**.
- Statically linking **OpenVDB** into the executable for easy distribution with no external dependencies.

## File Structure
```
MyApp/
├── CMakeLists.txt         # Top-level CMake configuration for MyApp
├── README.md              # Project documentation (this file)
├── .gitignore             # Git ignore file (excludes build artifacts, etc.)
├── src/
│   └── main.cpp           # Main source file for MyApp
└── external/
    ├── MyLib/             # MyLib submodule (cloned via SSH)
    │   ├── CMakeLists.txt  # CMake configuration for MyLib
    │   ├── include/
    │   │   └── MyLib.h     # Public header for MyLib
    │   └── src/
    │       └── MyLib.cpp   # Implementation of MyLib
    └── OpenVDB/            # OpenVDB submodule (or built externally)
        └── ...             # OpenVDB source code and configuration
```

### Key Directories
- **`src/`**: Contains MyApp’s source code.
- **`external/`**: Contains external dependencies. Currently, MyLib and OpenVDB are managed here as submodules.
- **`build/`**: (Not tracked by Git) A directory to hold all build artifacts and generated files.

## Prerequisites
Ensure you have the following installed:
- **Git**: For cloning the repository and managing submodules.  
  Check with:  
  ```bash
  git --version
  ```
- **CMake (v3.15 or higher)**: For project configuration and build management.
- **C++ Compiler**: A modern compiler that supports C++17.
- **SSH Setup**: Your SSH key should be configured to access the MyLib Git repository (e.g., via GitHub).

## Setup Instructions
1. **Clone the Repository with Submodules**
   ```bash
   git clone --recursive git@github.com:YourOrg/MyApp.git
   ```
   If you cloned without submodules, initialize and update them:
   ```bash
   git submodule update --init --recursive
   ```

2. **Configure SSH**
   Ensure your SSH key is added to your GitHub account so that Git can access MyLib via its SSH URL.

## Building the Project
1. **Create a Build Directory**
   Use an out-of-source build to keep your repository clean:
   ```bash
   mkdir build && cd build
   ```

2. **Run CMake Configuration**
   Configure the project and optionally update MyLib or enable special build options:
   - **Update MyLib** (to fetch the latest commit):
     ```bash
     cmake -DUPDATE_MYLIB=ON ..
     ```
   - **Enable Special Build Flag for MyLib**:
     ```bash
     cmake -DBUILD_MYLIB_SPECIAL=ON ..
     ```
   - **Specify Build Type** (Debug, Release, etc.):
     ```bash
     cmake -DCMAKE_BUILD_TYPE=Release ..
     ```
   You can combine options as needed:
   ```bash
   cmake -DUPDATE_MYLIB=ON -DBUILD_MYLIB_SPECIAL=ON -DCMAKE_BUILD_TYPE=Release ..
   ```

3. **Compile the Project**
   Run the build command:
   ```bash
   cmake --build .
   ```
   This command compiles:
   - **MyLib** as a static library (with special flags if enabled).
   - **MyApp** as the main executable linked against MyLib and OpenVDB.

## Running the Application
After a successful build, run the application:
```bash
./MyApp
```
The output will display:
- A message from MyApp.
- A greeting from MyLib, which will differ if the special build flag is enabled (e.g., "Hello from MyLib!" vs. "Hello from MyLib (Special Build)!").

## CMake Options and Special Flags
The project supports several options at configuration time:

- **`UPDATE_MYLIB`**  
  - **Purpose**: Automatically updates the MyLib submodule to the latest commit from the remote repository.
  - **Usage**: `-DUPDATE_MYLIB=ON`

- **`BUILD_MYLIB_SPECIAL`**  
  - **Purpose**: Builds MyLib with an additional compile definition (`SPECIAL_FLAG_ENABLED`) to enable special behavior.
  - **Usage**: `-DBUILD_MYLIB_SPECIAL=ON`

- **`CMAKE_BUILD_TYPE`**  
  - **Purpose**: Specifies the build type, e.g., Debug or Release.
  - **Usage**: `-DCMAKE_BUILD_TYPE=Release`

These flags can be combined or omitted as necessary.

## Adding New Libraries
In the future, you can add new libraries by following these guidelines:
1. **Using Git Submodules**:  
   Add the new library as a submodule inside the `external/` directory:
   ```bash
   git submodule add git@github.com:YourOrg/YourLibrary.git external/YourLibrary
   ```
2. **Using CMake’s ExternalProject_Add**:  
   For libraries not hosted on Git or when you need to download them automatically, you can use `ExternalProject_Add` to manage the download and build process.
3. **Directory Organization**:  
   Place third-party libraries in `external/` or `third_party/` directories.
4. **Integration**:  
   Update your top-level `CMakeLists.txt` to include the new libraries (using `add_subdirectory()` or similar) and link them with your targets using `target_link_libraries()`.

### Example, Adding OpenVDB as a Git Submodule
Since OpenVDB is a large library with multiple dependencies, the best approach is **to add it as a submodule and build it within your project**.

1. Add OpenVDB as a Submodule
Run the following command in your project root:
```bash
git submodule add --depth=1 https://github.com/AcademySoftwareFoundation/openvdb.git external/OpenVDB
git submodule update --init --recursive
```

2. Configuring CMake to Build OpenVDB as a Static Library
Since we want **a single executable**, we should build **OpenVDB statically** instead of dynamically (.so / .dylib / .dll).
- Modify CMakeLists.txt to Include OpenVDB
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp)

# Enable C++17 or newer (OpenVDB requires C++17)
set(CMAKE_CXX_STANDARD 17)

# Add OpenVDB as a subdirectory (this will build it inside our project)
add_subdirectory(external/OpenVDB)

# Include OpenVDB headers
include_directories(external/OpenVDB/openvdb)

# Link OpenVDB statically to MyApp
add_executable(MyApp src/main.cpp)
target_link_libraries(MyApp PRIVATE openvdb_static)
```
-  Now, OpenVDB will be compiled as part of MyApp, and linked statically.
- This ensures MyApp.exe has no external dependencies, making it platform-independent.

3. Handling OpenVDB Dependencies
- OpenVDB relies on: Blosc, Boost, TBB (Threading Building Blocks), Zlib, OpenEXR
- To make sure they are included within your build, you can either:
   * Enable OpenVDB's built-in dependency management (preferred).
   * Manually add them as submodules.


- Enable OpenVDB’s Dependency Management, Modify OpenVDB’s build settings before adding it:

```cmake
set(OPENVDB_BUILD_STATIC ON CACHE BOOL "Build OpenVDB as a static library")
set(OPENVDB_USE_BLOSC OFF CACHE BOOL "Disable Blosc compression")
set(OPENVDB_USE_IMATH_HALF ON CACHE BOOL "Use OpenEXR/Imath for half float support")
set(OPENVDB_CORE_SHARED OFF CACHE BOOL "Disable OpenVDB shared core")
```
- This forces OpenVDB to bundle everything it needs inside MyApp.

4. Creating a Single Executable for Clients
- Now that MyApp is statically linked, it’s fully portable.
- You can distribute:

   * MyApp.exe (Windows)
   * MyApp (Linux/macOS)
   * No extra .dll / .so / .dylib files required!

```
MyApp/
├── external/
│   ├── OpenVDB/  (Git submodule)
│   ├── other_libs/
├── src/
│   ├── main.cpp
├── build/  (Generated build files)
│   ├── MyApp (Final binary)
├── CMakeLists.txt
└── .gitmodules
```

## Choosing the Build Directory for Submodules and Libraries
In our **CMake setup**, we are letting CMake handle the **build directories** for submodules (`MyLib`) and any additional libraries **automatically** inside our **CMake build directory** (e.g., `build/`).

### **Where is the Build Directory for Submodules Defined?**
- We do not manually set a separate build directory for `MyLib`.
- Instead, we include `MyLib` using `add_subdirectory(${MYLIB_DIR})` in `CMakeLists.txt` of **MyApp**.
- This means that MyLib is **compiled inside the same CMake build directory** as MyApp.

### **How Does This Work?** 
When we run:
```bash
mkdir build && cd build
cmake ..
cmake --build .
```
- CMake creates the `build/` directory.
- MyApp and MyLib both get built inside `build/` automatically.

The actual build directory for MyLib will be:
```bash
build/external/MyLib/
```
This structure is managed internally by CMake when `add_subdirectory(${MYLIB_DIR})` is used.

## What If We Want a Custom Build Directory for Submodules?
By default, CMake does not require setting a separate build directory for submodules. However, if you want **MyLib to have its own build directory separate from MyApp**, you can modify the `CMakeLists.txt` like this:
```cmake
set(MYLIB_BUILD_DIR "${CMAKE_BINARY_DIR}/mylib_build")
set(MYLIB_INSTALL_DIR "${CMAKE_BINARY_DIR}/mylib_install")

add_subdirectory(${MYLIB_DIR} ${MYLIB_BUILD_DIR})
```

### What This Does:
- Instead of MyLib compiling inside `build/external/MyLib/`, it will now be built inside `build/mylib_build/`.
- You can later install MyLib separately into `build/mylib_install/` if needed.

## What About Third-Party Libraries?
If third-party libraries are later added (e.g., OpenSSL, Boost), we might use `ExternalProject_Add()`, which downloads and builds them in a separate directory.
- Example:
```cmake
include(ExternalProject)

ExternalProject_Add(MyThirdPartyLib
    PREFIX "${CMAKE_BINARY_DIR}/third_party/MyThirdPartyLib"
    GIT_REPOSITORY git@github.com:YourOrg/MyThirdPartyLib.git
    GIT_TAG main
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/third_party/MyThirdPartyLib/install
)
```
The library is cloned and built separately in `build/third_party/MyThirdPartyLib/`.

## Where Do Submodules and Libraries Get Built?
- **By default**: Inside the main **CMake build directory** (`build/`).
- If using `add_subdirectory()`: The library is built under `build/external/MyLib/` automatically.
- If we manually set a **custom build directory**: We can define it using `add_subdirectory(${MYLIB_DIR} ${MYLIB_BUILD_DIR})`.
- If using `ExternalProject_Add()`: It allows fully custom build directories for third-party libraries.

---
