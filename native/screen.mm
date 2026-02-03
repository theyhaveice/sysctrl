#include <ApplicationServices/ApplicationServices.h>
#include <iostream>
#include <string>

extern "C" int screen(int argc, char* argv[]) {
    int id = 0;
    std::string action;

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg.rfind("--action=", 0) == 0) action = arg.substr(9);
        else if (arg.rfind("--id=", 0) == 0) id = std::stoi(arg.substr(5));
    }

    CGDirectDisplayID displays[32];
    uint32_t count = 0;
    CGGetActiveDisplayList(32, displays, &count);

    if (id < 0 || id >= (int)count) id = 0;

    CGDirectDisplayID target = displays[id];
    CGSize size = CGDisplayBounds(target).size;

    if (action == "getWidth") {
        std::cout << (int)size.width;
    } else if (action == "getHeight") {
        std::cout << (int)size.height;
    }

    return 0;
}