#include <iostream>
#include <string>

extern "C" int mouse(int argc, char* argv[]);
extern "C" int screen(int argc, char* argv[]);

int main(int argc, char* argv[]) {
    std::string device;
    int id = 0;

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg.rfind("--device=", 0) == 0) device = arg.substr(9);
        else if (arg.rfind("--id=", 0) == 0) id = std::stoi(arg.substr(5));
    }

    if (device == "mouse") return mouse(argc, argv);
    if (device == "screen") return screen(argc, argv);
    return 1;
}