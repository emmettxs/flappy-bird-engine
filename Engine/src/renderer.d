module renderer;

import bindbc.sdl;
import std.stdio;
import core.stdc.string : strlen;
import std.string : fromStringz;

class Renderer {
    private SDL_Window* window;
    private SDL_Renderer* renderer;
    private int windowWidth;
    private int windowHeight;
    private bool initialized = false;

    this(int width, int height) {
        windowWidth = width;
        windowHeight = height;

        SDLSupport ret = loadSDL();
        if (ret == SDLSupport.noLibrary) {
            writeln("ERROR: SDL library not found");
            throw new Exception("SDL library not found");
        } else if (ret == SDLSupport.badLibrary) {
            writeln("ERROR: Failed to load SDL library - bad library");
            throw new Exception("Failed to load SDL library");}

        int initResult = SDL_Init(SDL_INIT_VIDEO);

        if (initResult < 0) {
            writeln("SDL initialization failed: ", SDL_GetError().fromStringz);
            throw new Exception("SDL initialization failed");}
        window = SDL_CreateWindow(
            "Flappy Bird", SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,width,
            height,
            SDL_WINDOW_SHOWN
        );

        if (window is null) {
            writeln("Window creation failed: ", SDL_GetError().fromStringz);
            throw new Exception("Window creation failed");}
        renderer = SDL_CreateRenderer(window, -1,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

        if (renderer is null) {
            writeln("Renderer creation failed: ", SDL_GetError().fromStringz);
            throw new Exception("Renderer creation failed");}
        initialized = true;
    }

    void clear() {
        if (!initialized) return;
        SDL_SetRenderDrawColor(renderer, 135, 206, 235, 255); // Sky blue
        SDL_RenderClear(renderer);
    }
    void present() {
        if (!initialized) return;
        SDL_RenderPresent(renderer);
    }
    void drawRect(int x, int y, int width, int height, ubyte r, ubyte g, ubyte b) {
        if (!initialized) return;
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_Rect rect = SDL_Rect(x, y, width, height);
        SDL_RenderFillRect(renderer, &rect);
    }

    void drawRect(int x, int y, int width, int height) {
        drawRect(x, y, width, height, 255, 255, 255);
    }

    void drawTexture(SDL_Texture* texture, int x, int y, int width, int height) {
        if (!initialized || texture is null) return;
        SDL_Rect destRect = SDL_Rect(x, y, width, height);
        SDL_RenderCopy(renderer, texture, null, &destRect);
    }

    int getWidth() {
        return windowWidth;
    }
    int getHeight() {
        return windowHeight;
    }
    SDL_Renderer* getSDLRenderer() {
        return renderer;
    }
    ~this() {
        if (renderer !is null) {
            SDL_DestroyRenderer(renderer);}
        if (window !is null) {
            SDL_DestroyWindow(window);}
        SDL_Quit();
    }
}
