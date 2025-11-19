module engine.resource_manager;

import std.stdio;
import std.string;
import std.file;
import std.json;
import bindbc.sdl;

class ResourceManager {
    private static ResourceManager instance;
    private SDL_Texture*[string] textures;
    private void*[string] genericResources;
    private SDL_Renderer* renderer;

    private this() {
        writeln("ResourceManager initialized (Singleton)");
    }

    static ResourceManager Get() {
        if (instance is null) {
            instance = new ResourceManager();}
        return instance;
    }

    void SetRenderer(SDL_Renderer* r) {
        renderer = r;}

    SDL_Texture* LoadTexture(string path) {
        if (path in textures) {
            return textures[path];
        }

        SDL_Surface* surface = SDL_LoadBMP(path.toStringz);
        if (surface is null) {
            return null;
        }

        SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
        SDL_FreeSurface(surface);
        if (texture !is null) {
            textures[path] = texture;
            writeln("Texture loaded and cached: ", path);
        }
        return texture;
    }

    SDL_Texture* GetTexture(string name) {
        if (name in textures) {
            return textures[name];}
        return null;
    }

    void LoadFromJSON(string jsonPath) {
        if (!exists(jsonPath)) {
            writeln("JSON file not found: ", jsonPath);
            return;
        }
        try {
            string content = cast(string) read(jsonPath);
            JSONValue root = parseJSON(content);
            if ("textures" in root) {
                foreach (tex; root["textures"].array) {
                    string name = tex["name"].str;
                    string path = tex["path"].str;
                    LoadTexture(path);
                    writeln("Loaded texture from JSON: ", name, " (", path, ")");}
            }
        } catch (Exception e) {
            writeln("Error loading JSON resources: ", e.msg);
        }
    }

    bool LoadGeneric(T)(string name, T data) {
        if (name in genericResources) {
            writeln("Generic resource already loaded: ", name);
            return false;
        }
        void* ptr = cast(void*) new T(data);
        genericResources[name] = ptr;
        return true;
    }

    T GetGeneric(T)(string name) {
        if (name !in genericResources) {
            throw new Exception("Generic resource not found: " ~ name);
        }
        return *cast(T*) genericResources[name];
    }
    bool HasTexture(string name) {
        return (name in textures) !is null;
    }

    bool HasGeneric(string name) {
        return (name in genericResources) !is null;}

    void UnloadTexture(string name) {
        if (name in textures) {
            SDL_DestroyTexture(textures[name]);
            textures.remove(name);}
    }

    void UnloadAll() {
        foreach (texture; textures) {
            SDL_DestroyTexture(texture);
        }
        textures.clear();
        genericResources.clear();
    }

    size_t TextureCount() {
        return textures.length;
    }
    size_t GenericResourceCount() {
        return genericResources.length;
    }
    ~this() {
        foreach (texture; textures) {
            SDL_DestroyTexture(texture);
        }
        textures.clear();
        genericResources.clear();}
}
