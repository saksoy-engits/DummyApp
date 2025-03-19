# MyApp

MyApp is a sample C++ project that demonstrates how to integrate a custom library (MyLib) as a Git submodule. The project uses CMake for configuration and building, automatically checks for the latest Git commit of MyLib, and supports special build configurations. This README explains the project structure, build process, and how to extend the system.

## Table of Contents
- [Project Overview](#project-overview)
- [File Structure](#file-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Building the Project](#building-the-project)
- [Running the Application](#running-the-application)
- [CMake Options and Special Flags](#cmake-options-and-special-flags)
- [Adding New Libraries](#adding-new-libraries)
- [Contributing](#contributing)
- [License](#license)

## Project Overview
MyApp demonstrates:
- Integrating MyLib as a Git submodule.
- Automatically checking and updating MyLib’s Git commit during configuration.
- Building MyLib in different configurations (Debug, Release, or with a special compile flag).
- A modular structure that facilitates future integration of third-party libraries.

## File Structure
```
MyApp/
├── CMakeLists.txt         # Top-level CMake configuration for MyApp
├── README.md              # Project documentation (this file)
├── .gitignore             # Git ignore file (excludes build artifacts, etc.)
├── src/
│   └── main.cpp           # Main source file for MyApp
└── external/
    └── MyLib/             # MyLib submodule (cloned via SSH)
         ├── CMakeLists.txt  # CMake configuration for MyLib
         ├── include/
         │   └── MyLib.h     # Public header for MyLib
         └── src/
             └── MyLib.cpp   # Implementation of MyLib
```

### Key Directories
- **`src/`**: Contains MyApp’s source code.
- **`external/`**: Contains external dependencies. Currently, MyLib is managed here as a submodule.
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
   - **MyApp** as the main executable linked against MyLib.

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
