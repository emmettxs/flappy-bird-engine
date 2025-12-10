/**
 * Level Loader System
 * Loads level data from JSON files and creates game objects
 */
module level_loader;

import gameobject;
import renderer;
import std.stdio;
import std.json;
import std.file;
import std.conv;

/**
 * level configuration structure
 */
struct LevelConfig {
    string name;
    int width;
    int height;
    float gravity;
    ubyte bgR = 135;
    ubyte bgG = 206;
    ubyte bgB = 235;
}

/**
 * Level class that holds all game objects and configuration
 */
class Level {
    private GameObject[] gameObjects;
    private LevelConfig config;
    private string levelPath;
    this(string name = "Untitled Level") {
        config.name = name;
        config.width = 800;
        config.height = 600;
        config.gravity = 800.0;
    }
    void addGameObject(GameObject obj) {
        gameObjects ~= obj;
    }
    void removeGameObject(GameObject obj) {
        GameObject[] newObjects;
        foreach (gameObj; gameObjects) {
            if (gameObj !is obj) {
                newObjects ~= gameObj;
            }}
        gameObjects = newObjects;
    }
    GameObject[] getGameObjects() {
        return gameObjects;
    }
    GameObject findGameObjectByName(string name) {
        foreach (obj; gameObjects) {
            if (obj.getName() == name) {
                return obj;
            }
        }
        return null;
    }
    void update(double deltaTime) {
        foreach (obj; gameObjects) {
            obj.update(deltaTime);
        }
    }

    void render(Renderer renderer) {
        foreach (obj; gameObjects) {
            obj.render(renderer);
        }
    }
    void clear() {
        gameObjects = [];
    }

    void destroy() {
        foreach (obj; gameObjects) {
            obj.destroy();
        }
        gameObjects = [];
    }
    LevelConfig getConfig() {
        return config;
    }
    void setConfig(LevelConfig cfg) {
        config = cfg;
    }

    string getName() {
        return config.name;}

    JSONValue serialize() {
        JSONValue data = ["type": "Level"];
        data["name"] = config.name;
        data["width"] = config.width;
        data["height"] = config.height;
        data["gravity"] = config.gravity;
        data["bgR"] = config.bgR;
        data["bgG"] = config.bgG;
        data["bgB"] = config.bgB;
        JSONValue[] objectsData;
        foreach (obj; gameObjects) {
            objectsData ~= obj.serialize();
        }
        data["gameObjects"] = JSONValue(objectsData);
        return data;
    }

    static Level deserialize(JSONValue data) {
        Level level = new Level();
        if ("name" in data) {
            level.config.name = data["name"].str;
        }
        if ("width" in data) {
            level.config.width = cast(int)data["width"].integer;}
        if ("height" in data) {
            level.config.height = cast(int)data["height"].integer;
        }
        if ("gravity" in data) {
            level.config.gravity = data["gravity"].floating;
        }
        if ("bgR" in data) {
            level.config.bgR = cast(ubyte)data["bgR"].integer;
        }
        if ("bgG" in data) {
            level.config.bgG = cast(ubyte)data["bgG"].integer;
        }
        if ("bgB" in data) {
            level.config.bgB = cast(ubyte)data["bgB"].integer;
        }
        if ("gameObjects" in data) {
            foreach (objData; data["gameObjects"].array) {
                GameObject obj = GameObject.deserialize(objData);
                level.addGameObject(obj);
            }
        }
        return level;
    }

    void saveToFile(string filepath) {
        JSONValue data = serialize();
        string jsonString = data.toPrettyString();
        std.file.write(filepath, jsonString);
        writeln("Level saved to: ", filepath);
    }

    static Level loadFromFile(string filepath) {
        if (!exists(filepath)) {
            writeln("Level file not found: ", filepath);
            return null;
        }
        try {
            string content = cast(string)std.file.read(filepath);
            JSONValue data = parseJSON(content);
            Level level = Level.deserialize(data);
            return level;
        } catch (Exception e) {
            writeln("Error loading level: ", e.msg);
            return null;
        }
    }
}

/**
 * Level Manager for managing multiple levels
 */
class LevelManager {
    private static LevelManager instance;
    private Level currentLevel;
    private string levelsPath = "levels/";
    private this() {}

    static LevelManager Get() {
        if (instance is null) {
            instance = new LevelManager();
        }
        return instance;
    }

    void loadLevel(string filename) {
        string fullPath = levelsPath ~ filename;
        Level level = Level.loadFromFile(fullPath);
        if (level !is null) {
            currentLevel = level;
        }
    }
    void setLevel(Level level) {
        currentLevel = level;
    }

    Level getCurrentLevel() {
        return currentLevel;
    }
    void setLevelsPath(string path) {
        levelsPath = path;
    }
    void update(double deltaTime) {
        if (currentLevel !is null) {
            currentLevel.update(deltaTime);
        }
    }

    void render(Renderer renderer) {
        if (currentLevel !is null) {
            currentLevel.render(renderer);}
    }
}
