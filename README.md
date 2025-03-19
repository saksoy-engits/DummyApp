Here's how the project compiles and works step by step:

1. CMake Configuration:

When you create a build directory (e.g., using `mkdir build && cd build`) and run the configuration command (e.g., `cmake -DUPDATE_MYLIB=ON -DBUILD_MYLIB_SPECIAL=ON` ..), 
CMake will:

- Verify that Git is installed.

- Check the `external/MyLib` submodule by reading its current commit hash.

- If `UPDATE_MYLIB` is enabled, fetch and merge the latest changes from the remote Git repository using your SSH credentials.

- Set the special compile flag if `BUILD_MYLIB_SPECIAL` is enabled, so MyLib is built with extra options.

- Process both the MyApp and MyLib CMake files, configuring them for the selected build type (e.g., Debug, Release).

2. Building the Project:

After configuration, running `cmake --build .` compiles:

- MyLib:The submodule under `external/MyLib` is compiled as a static library. If the special flag is enabled, the build adds the `SPECIAL_FLAG_ENABLED` definition to alter its behavior.

- MyApp:The main application (located in `src/main.cpp`) is compiled and linked against the compiled MyLib library.

3. Running the Application:

- Once built, executing the resulting binary (e.g., `./MyApp`) will print a message from MyApp and then call a function from MyLib.

- Depending on whether the special flag was set, MyLib’s output will reflect the normal or the special build configuration (e.g., "Hello from MyLib!" versus "Hello from MyLib (Special Build)!").

---

In summary, the project is set up so that configuring and building MyApp not only compiles your application but also automatically manages the MyLib dependency by checking for Git updates, fetching the latest commits if needed, and compiling MyLib in the desired configuration.