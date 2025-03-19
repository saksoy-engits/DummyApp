### **MyApp - CMake Build Guide**  

This project uses **CMake** for cross-platform compilation and integrates **MyLib** and **OpenVDB** as submodules.  
Supports **Windows, Linux, macOS**, and **cross-compilation** for ARM/Linux (e.g., Raspberry Pi).  

---

## **Project Structure**  
```
MyApp/
├── external/
│   ├── MyLib/       # Git submodule for MyLib
│   ├── OpenVDB/     # Git submodule for OpenVDB
├── src/
│   ├── main.cpp     # Main application file
├── build/           # Generated build files (not committed)
├── CMakeLists.txt   # CMake configuration
└── .gitmodules      # Git submodule references
```

---

## **How This Supports Cross-Compilation**
**Detects OS & Sets Compilation Flags**  
   - Windows → `-DPLATFORM_WINDOWS`  
   - Linux → `-DPLATFORM_LINUX`  
   - macOS → `-DPLATFORM_MACOS`  

**Supports Toolchain Files for Cross-Compilation**  
   - Use `-DCMAKE_TOOLCHAIN_FILE=toolchains/arm-linux-gnueabihf.cmake` for ARM/Linux.  

**Statically Links MyLib & OpenVDB**  
   - Ensures portability by embedding dependencies.  

**Handles rpath for macOS/Linux**  
   - Ensures MyApp finds shared libraries at runtime.  

---

## **Build Instructions**
### **Windows (MinGW)**
```bash
cmake -B build -G "MinGW Makefiles"
cmake --build build --config Release
```
**Output:** `build/MyApp.exe`  

---

### **Linux (x86_64) & macOS**
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```
**Output:** `build/MyApp`  

---

### **Cross-Compile for ARM/Linux (e.g., Raspberry Pi)**
```bash
cmake -B build -DCMAKE_TOOLCHAIN_FILE=toolchains/arm-linux-gnueabihf.cmake
cmake --build build --config Release
```
**Output:** `build/MyApp` (ready for ARM/Linux devices)  

---

## **Additional Options**
### **Update MyLib Submodule**
```bash
cmake -B build -DUPDATE_MYLIB=ON
```
Automatically fetches the latest commit of **MyLib**.  

### **Build MyLib with a Special Compile Flag**
```bash
cmake -B build -DBUILD_MYLIB_SPECIAL=ON
```
Enables a special compile mode for **MyLib**.  

---

## **Summary**
| **Feature** | **Implemented?** |
|------------|----------------|
| **Windows, Linux, macOS Support** | |
| **ARM/Linux Cross-Compilation** | |
| **Static Linking for MyLib & OpenVDB** | |
| **Git Submodule Updates for MyLib** | |

