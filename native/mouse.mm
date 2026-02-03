#include <ApplicationServices/ApplicationServices.h>
#include <map>
#include <string>
#include <sstream>
#include <thread>
#include <chrono>
#include <cmath>
#include <iostream>

static std::map<std::string, int> parseKeyValue(const std::string& str) {
    std::map<std::string, int> out;
    std::stringstream ss(str);
    std::string pair;
    while (std::getline(ss, pair, ',')) {
        size_t eq = pair.find('=');
        if (eq == std::string::npos) continue;
        out[pair.substr(0, eq)] = std::stoi(pair.substr(eq + 1));
    }
    return out;
}

static CGMouseButton mapButton(int b) {
    switch (b) {
        case 1: return kCGMouseButtonRight;
        case 2: return kCGMouseButtonCenter;
        default: return kCGMouseButtonLeft;
    }
}

static CGEventType downTypeFor(CGMouseButton b) {
    return b == kCGMouseButtonLeft  ? kCGEventLeftMouseDown :
           b == kCGMouseButtonRight ? kCGEventRightMouseDown :
                                      kCGEventOtherMouseDown;
}

static CGEventType upTypeFor(CGMouseButton b) {
    return b == kCGMouseButtonLeft  ? kCGEventLeftMouseUp :
           b == kCGMouseButtonRight ? kCGEventRightMouseUp :
                                      kCGEventOtherMouseUp;
}

static double ease(double t, int easeIn, int easeOut) {
    if (easeIn > 0 && t < 0.5)
        return std::pow(t * 2.0, easeIn) * 0.5;
    if (easeOut > 0 && t >= 0.5)
        return 1.0 - std::pow((1.0 - t) * 2.0, easeOut) * 0.5;
    return t;
}

static void animatedMove(
    CGPoint from,
    CGPoint to,
    int duration,
    int easeIn,
    int easeOut,
    CGMouseButton button,
    bool dragging
) {
    if (duration <= 0) {
        CGEventRef move = CGEventCreateMouseEvent(
            nullptr,
            dragging ? kCGEventLeftMouseDragged : kCGEventMouseMoved,
            to,
            button
        );
        CGEventPost(kCGHIDEventTap, move);
        CFRelease(move);
        return;
    }

    const int frameTime = 8;
    int steps = duration / frameTime;
    if (steps < 1) steps = 1;

    for (int i = 1; i <= steps; i++) {
        double t = (double)i / steps;
        double et = ease(t, easeIn, easeOut);

        CGPoint p;
        p.x = from.x + (to.x - from.x) * et;
        p.y = from.y + (to.y - from.y) * et;

        CGEventRef move = CGEventCreateMouseEvent(
            nullptr,
            dragging ? kCGEventLeftMouseDragged : kCGEventMouseMoved,
            p,
            button
        );

        CGEventPost(kCGHIDEventTap, move);
        CFRelease(move);

        std::this_thread::sleep_for(
            std::chrono::milliseconds(frameTime)
        );
    }
}

extern "C" int mouse(int argc, char* argv[]) {
    std::string device, action, paramsStr, optionsStr;
    int id = 0;

    static int currentButton = 0;

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg.rfind("--device=", 0) == 0) device = arg.substr(9);
        else if (arg.rfind("--action=", 0) == 0) action = arg.substr(9);
        else if (arg.rfind("--params=", 0) == 0) paramsStr = arg.substr(9);
        else if (arg.rfind("--options=", 0) == 0) optionsStr = arg.substr(10);
        else if (arg.rfind("--id=", 0) == 0) id = std::stoi(arg.substr(5));
    }

    if (device != "mouse") return 1;

    auto params = parseKeyValue(paramsStr);
    auto options = parseKeyValue(optionsStr);

    int duration = options.count("duration") ? options["duration"] : 0;
    int easeIn   = options.count("easeIn")   ? options["easeIn"]   : 0;
    int easeOut  = options.count("easeOut")  ? options["easeOut"]  : 0;

    CGPoint cur = CGEventGetLocation(CGEventCreate(nullptr));

    if (action == "getX") {
        std::cout << (int)cur.x;
        return 0;
    }
    if (action == "getY") {
        std::cout << (int)cur.y;
        return 0;
    }
    if (action == "getButton") {
        std::cout << currentButton;
        return 0;
    }

    if (action == "move") {
        CGPoint to = { (double)params["x"], (double)params["y"] };
        animatedMove(cur, to, duration, easeIn, easeOut, kCGMouseButtonLeft, false);
    }
    else if (action == "drag") {
        CGPoint from = { (double)params["x1"], (double)params["y1"] };
        CGPoint to   = { (double)params["x2"], (double)params["y2"] };
        int buttonInt = params.count("button") ? params["button"] : 0;
        CGMouseButton button = mapButton(buttonInt);
        currentButton = buttonInt;

        CGEventRef down = CGEventCreateMouseEvent(nullptr, downTypeFor(button), from, button);
        CGEventPost(kCGHIDEventTap, down);
        CFRelease(down);

        animatedMove(from, to, duration, easeIn, easeOut, button, true);

        CGEventRef up = CGEventCreateMouseEvent(nullptr, upTypeFor(button), to, button);
        CGEventPost(kCGHIDEventTap, up);
        CFRelease(up);
    }
    else if (action == "scroll") {
        int dx = params.count("dx") ? params["dx"] : 0;
        int dy = params.count("dy") ? params["dy"] : 0;

        if (duration <= 0) {
            CGEventRef scroll = CGEventCreateScrollWheelEvent(nullptr, kCGScrollEventUnitPixel, 2, dy, dx);
            CGEventPost(kCGHIDEventTap, scroll);
            CFRelease(scroll);
            return 0;
        }

        const int frameTime = 8;
        int steps = duration / frameTime;
        if (steps < 1) steps = 1;

        double lastX = 0, lastY = 0;
        for (int i = 1; i <= steps; i++) {
            double t = (double)i / steps;
            double et = ease(t, easeIn, easeOut);

            double curX = dx * et;
            double curY = dy * et;

            int sx = (int)std::round(curX - lastX);
            int sy = (int)std::round(curY - lastY);

            lastX = curX;
            lastY = curY;

            if (sx || sy) {
                CGEventRef scroll = CGEventCreateScrollWheelEvent(nullptr, kCGScrollEventUnitPixel, 2, sy, sx);
                CGEventPost(kCGHIDEventTap, scroll);
                CFRelease(scroll);
            }

            std::this_thread::sleep_for(std::chrono::milliseconds(frameTime));
        }
    }

    return 0;
}