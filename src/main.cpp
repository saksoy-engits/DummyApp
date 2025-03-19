#include <iostream>
#include "MyLib.h"

int main() {
    std::cout << "MyApp is running!" << std::endl;
    // Call a function from MyLib
    MyLib::say_hello();
    return 0;
}
