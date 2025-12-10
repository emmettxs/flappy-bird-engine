/**
 * Handles the input
 */
 module input;

import bindbc.sdl;
import std.stdio;

class InputManager {
    private bool shouldQuit = false;
    private const(ubyte)* keyState;
    private int numKeys = 0;
    this() {
        keyState = SDL_GetKeyboardState(&numKeys);
    }
    void processInput() {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT:
                    shouldQuit = true;
                    break;
                default:
                    break;
            }}
        keyState = SDL_GetKeyboardState(&numKeys);
    }

    bool isKeyPressed(int keycode) {
        if (keyState is null) return false;
        int scancode = SDL_GetScancodeFromKey(keycode);
        if (scancode < 0 || scancode >= numKeys) {
            return false;
        }

        bool pressed = keyState[scancode] != 0;
        return pressed;
    }
    bool getQuitSignal() {
        return shouldQuit;
    }
}
