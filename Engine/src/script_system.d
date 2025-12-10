/**
 * Script System
 * Loads and manages gameplay scripts 
 */
module script_system;

import std.stdio;
import std.file;
import std.json;
import std.string;
import std.conv;

/**
 * script action types
 */
enum ScriptAction {
    SPAWN_OBJECT,
    MODIFY_PROPERTY,
    TRIGGER_EVENT,
    PLAY_SOUND,
    CUSTOM
}

/**
 * Script command structure
 */
struct ScriptCommand {
    ScriptAction action;
    string target;
    string parameter;
    float value;
    string stringValue;
}

/**
 * Script file structure
 */
class GameScript {
    private string name;
    private ScriptCommand[] commands;
    private bool[string] flags;
    private float[string] variables;
    this(string scriptName) {
        name = scriptName;
    }

    void addCommand(ScriptCommand cmd) {
        commands ~= cmd;
    }
    ScriptCommand[] getCommands() {
        return commands;
    }

    void setFlag(string flagName, bool value) {
        flags[flagName] = value;
    }

    bool getFlag(string flagName) {
        if (flagName in flags) {
            return flags[flagName];
        }
        return false;
    }

    void setVariable(string varName, float value) {
        variables[varName] = value;
    }
    float getVariable(string varName) {
        if (varName in variables) {
            return variables[varName];
        }
        return 0.0;
    }
    string getName() {
        return name;
    }

    static GameScript loadFromFile(string filepath) {
        if (!exists(filepath)) {
            return null;
        }

        try {
            string content = cast(string)std.file.read(filepath);
            JSONValue data = parseJSON(content);
            string scriptName = data["name"].str;
            GameScript script = new GameScript(scriptName);

            if ("variables" in data) {
                foreach (string key, value; data["variables"].object) {
                    script.setVariable(key, value.floating);
                }
            }

            if ("flags" in data) {
                foreach (string key, value; data["flags"].object) {
                    script.setFlag(key, value.boolean);
                }
            }

            if ("commands" in data) {
                foreach (cmdData; data["commands"].array) {
                    ScriptCommand cmd;
                    string actionStr = cmdData["action"].str;
                    switch (actionStr) {
                        case "spawn":
                            cmd.action = ScriptAction.SPAWN_OBJECT;
                            break;
                        case "modify":
                            cmd.action = ScriptAction.MODIFY_PROPERTY;
                            break;
                        case "trigger":
                            cmd.action = ScriptAction.TRIGGER_EVENT;
                            break;
                        case "sound":
                            cmd.action = ScriptAction.PLAY_SOUND;
                            break;
                        default:
                            cmd.action = ScriptAction.CUSTOM;
                            break;
                    }

                    if ("target" in cmdData) {
                        cmd.target = cmdData["target"].str;
                    }
                    if ("parameter" in cmdData) {
                        cmd.parameter = cmdData["parameter"].str;
                    }
                    if ("value" in cmdData) {
                        cmd.value = cmdData["value"].floating;
                    }
                    if ("stringValue" in cmdData) {
                        cmd.stringValue = cmdData["stringValue"].str;
                    }
                    script.addCommand(cmd);
                }
            }

            return script;
        } catch (Exception e) {
            writeln("Error loading script: ", e.msg);
            return null;
        }
    }

    void saveToFile(string filepath) {
        JSONValue data = ["type": "GameScript"];
        data["name"] = name;

        JSONValue varsData;
        foreach (key, value; variables) {
            varsData[key] = value;
        }
        data["variables"] = varsData;
        JSONValue flagsData;
        foreach (key, value; flags) {
            flagsData[key] = value;
        }
        data["flags"] = flagsData;

        JSONValue[] commandsData;
        foreach (cmd; commands) {
            JSONValue cmdData;

            string actionStr;
            final switch (cmd.action) {
                case ScriptAction.SPAWN_OBJECT:
                    actionStr = "spawn";
                    break;
                case ScriptAction.MODIFY_PROPERTY:
                    actionStr = "modify";
                    break;
                case ScriptAction.TRIGGER_EVENT:
                    actionStr = "trigger";
                    break;
                case ScriptAction.PLAY_SOUND:
                    actionStr = "sound";
                    break;
                case ScriptAction.CUSTOM:
                    actionStr = "custom";
                    break;
            }

            cmdData["action"] = actionStr;
            cmdData["target"] = cmd.target;
            cmdData["parameter"] = cmd.parameter;
            cmdData["value"] = cmd.value;
            cmdData["stringValue"] = cmd.stringValue;

            commandsData ~= cmdData;
        }
        data["commands"] = JSONValue(commandsData);

        string jsonString = data.toPrettyString();
        std.file.write(filepath, jsonString);
    }
}

/**
 * Script Manager 
 */
class ScriptManager {
    private static ScriptManager instance;
    private GameScript[string] loadedScripts;
    private string scriptsPath = "scripts/";
    private this() {}

    static ScriptManager Get() {
        if (instance is null) {
            instance = new ScriptManager();
        }
        return instance;
    }

    void setScriptsPath(string path) {
        scriptsPath = path;
    }

    GameScript loadScript(string filename) {
        string fullPath = scriptsPath ~ filename;
        GameScript script = GameScript.loadFromFile(fullPath);

        if (script !is null) {
            loadedScripts[filename] = script;
        }
        return script;
    }

    GameScript getScript(string filename) {
        if (filename in loadedScripts) {
            return loadedScripts[filename];
        }
        return loadScript(filename);
    }

    void unloadScript(string filename) {
        if (filename in loadedScripts) {
            loadedScripts.remove(filename);
        }
    }

    void unloadAll() {
        loadedScripts.clear();
    }
}
