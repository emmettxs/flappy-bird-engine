/**
 * Game Object and Component System
 */
module gameobject;

import renderer;
import resource_manager;
import bindbc.sdl;
import std.stdio;
import std.conv;
import std.json;
import std.file;

/**
 * Base component interface 
 */
interface Component {
    void update(double deltaTime);
    void render(Renderer renderer);
    string getType();
    JSONValue serialize();
    void deserialize(JSONValue data);
}

/**
 * transform component handles position, rotation, and scale
 */
class TransformComponent:Component {
    float x = 0.0;
    float y = 0.0;
    float rotation = 0.0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    this() {}

    this(float px, float py) {
        x = px;
        y = py;
    }

    override void update(double deltaTime) {}
    override void render(Renderer renderer) {}

    override string getType() {
        return "Transform";
    }
    override JSONValue serialize() {
        JSONValue data = ["type": "Transform"];
        data["x"] = x;
        data["y"] = y;
        data["rotation"] = rotation;
        data["scaleX"] = scaleX;
        data["scaleY"] = scaleY;
        return data;}

    override void deserialize(JSONValue data) {
        if ("x" in data) x = data["x"].floating;
        if ("y" in data) y = data["y"].floating;
        if ("rotation" in data) rotation = data["rotation"].floating;
        if ("scaleX" in data) scaleX = data["scaleX"].floating;
        if ("scaleY" in data) scaleY = data["scaleY"].floating;}
}

/**
 * sprite component for rendering textures
 */
class SpriteComponent : Component {
    int width = 32;
    int height = 32;
    ubyte r = 255;
    ubyte g = 255;
    ubyte b = 255;
    string texturePath;
    private SDL_Texture* cachedTexture;
    TransformComponent transform;

    this(TransformComponent t) {
        transform = t;
    }

    override void update(double deltaTime) {}
    override void render(Renderer renderer) {
        if (transform !is null) {
            if (texturePath !is null && texturePath.length > 0) {
                if (cachedTexture is null) {
                    cachedTexture = ResourceManager.Get().LoadTexture(texturePath);
                }
                if (cachedTexture !is null) {
                    renderer.drawTexture(
                        cachedTexture, cast(int)transform.x,
                        cast(int)transform.y, width, height
                    );
                } else {
                    renderer.drawRect(
                        cast(int)transform.x,
                        cast(int)transform.y,
                        width, height,
                        r, g, b );
                }
            } else {
                renderer.drawRect(
                    cast(int)transform.x,
                    cast(int)transform.y,
                    width, height,
                    r, g, b
                );
            }
        }
    }
    override string getType() {
        return "Sprite";
    }

    override JSONValue serialize() {
        JSONValue data = ["type": "Sprite"];
        data["width"] = width;
        data["height"] = height;
        data["r"] = r;
        data["g"] = g;
        data["b"] = b;
        if (texturePath !is null) {
            data["texturePath"] = texturePath;
        }
        return data;
    }

    override void deserialize(JSONValue data) {
        if ("width" in data) width = cast(int)data["width"].integer;
        if ("height" in data) height = cast(int)data["height"].integer;
        if ("r" in data) r = cast(ubyte)data["r"].integer;
        if ("g" in data) g = cast(ubyte)data["g"].integer;
        if ("b" in data) b = cast(ubyte)data["b"].integer;
        if ("texturePath" in data) texturePath = data["texturePath"].str;
    }
}

/**
 * Physics component for basic simulation
 */
class PhysicsComponent : Component {
    float velocityX = 0.0;
    float velocityY = 0.0;
    float accelerationX = 0.0;
    float accelerationY = 0.0;
    float gravity = 0.0;
    float friction = 0.98;
    bool useGravity = false;

    TransformComponent transform;

    this(TransformComponent t) {
        transform = t;
    }

    override void update(double deltaTime) {
        if (transform is null) return;
        if (useGravity) {
            velocityY += gravity * deltaTime;
        }

        velocityX += accelerationX * deltaTime;
        velocityY += accelerationY * deltaTime;

        velocityX *= friction;
        velocityY *= friction;

        transform.x += velocityX * deltaTime;
        transform.y += velocityY * deltaTime;
    }

    override void render(Renderer renderer) {}

    override string getType() {
        return "Physics";
    }

    override JSONValue serialize() {
        JSONValue data = ["type": "Physics"];
        data["velocityX"] = velocityX;
        data["velocityY"] = velocityY;
        data["gravity"] = gravity;
        data["useGravity"] = useGravity;
        data["friction"] = friction;
        return data;
    }

    override void deserialize(JSONValue data) {
        if ("velocityX" in data) velocityX = data["velocityX"].floating;
        if ("velocityY" in data) velocityY = data["velocityY"].floating;
        if ("gravity" in data) gravity = data["gravity"].floating;
        if ("useGravity" in data) useGravity = data["useGravity"].boolean;
        if ("friction" in data) friction = data["friction"].floating;
    }
}

/**
 * collider component for collision detection
 */
class ColliderComponent : Component {
    int width = 32;
    int height = 32;
    bool isTrigger = false;
    string tag;

    TransformComponent transform;

    this(TransformComponent t) {
        transform = t;
    }

    bool checkCollision(ColliderComponent other) {
        if (transform is null || other.transform is null) return false;

        return (transform.x < other.transform.x + other.width &&
                transform.x + width > other.transform.x &&
                transform.y < other.transform.y + other.height &&
                transform.y + height > other.transform.y);
    }

    override void update(double deltaTime) {}
    override void render(Renderer renderer) {}

    override string getType() {
        return "Collider";
    }

    override JSONValue serialize() {
        JSONValue data = ["type": "Collider"];
        data["width"] = width;
        data["height"] = height;
        data["isTrigger"] = isTrigger;
        if (tag !is null) {
            data["tag"] = tag;
        }
        return data;
    }

    override void deserialize(JSONValue data) {
        if ("width" in data) width = cast(int)data["width"].integer;
        if ("height" in data) height = cast(int)data["height"].integer;
        if ("isTrigger" in data) isTrigger = data["isTrigger"].boolean;
        if ("tag" in data) tag = data["tag"].str;
    }
}

/**
 * Main GameObject class that holds components
 */
class GameObject {
    private Component[] components;
    private string name;
    private bool active = true;
    private TransformComponent transformComponent;

    this(string objName = "GameObject") {
        name = objName;
        transformComponent = new TransformComponent();
        addComponent(transformComponent);
    }

    void addComponent(Component component) {
        components ~= component;
    }

    T getComponent(T : Component)() {
        foreach (component; components) {
            T comp = cast(T)component;
            if (comp !is null) {
                return comp;
            }
        }
        return null;
    }

    TransformComponent getTransform() {
        return transformComponent;
    }

    void update(double deltaTime) {
        if (!active) return;
        foreach (component; components) {
            component.update(deltaTime);
        }
    }
    void render(Renderer renderer) {
        if (!active) return;
        foreach (component; components) {
            component.render(renderer);
        }
    }
    void setActive(bool isActive) {
        active = isActive;}

    bool isActive() {
        return active;
    }

    string getName() {
        return name;
    }
    void setName(string newName) {
        name = newName;
    }

    void destroy() {
        components = [];
        transformComponent = null;
    }
    JSONValue serialize() {
        JSONValue data = ["type": "GameObject"];
        data["name"] = name;
        data["active"] = active;
        JSONValue[] componentsData;
        foreach (component; components) {
            componentsData ~= component.serialize();
        }
        data["components"] = JSONValue(componentsData);

        return data;
    }

    static GameObject deserialize(JSONValue data) {
        string objName = "GameObject";
        if ("name" in data) {
            objName = data["name"].str;
        }

        GameObject obj = new GameObject(objName);

        if ("active" in data) {
            obj.setActive(data["active"].boolean);
        }
        if ("components" in data) {
            foreach (compData; data["components"].array) {
                if ("type" !in compData) continue;

                string compType = compData["type"].str;
                Component comp = null;

                switch (compType) {
                    case "Transform":
                        comp = obj.getTransform();
                        break;
                    case "Sprite":
                        comp = new SpriteComponent(obj.getTransform());
                        obj.addComponent(comp);
                        break;
                    case "Physics":
                        comp = new PhysicsComponent(obj.getTransform());
                        obj.addComponent(comp);
                        break;
                    case "Collider":
                        comp = new ColliderComponent(obj.getTransform());
                        obj.addComponent(comp);
                        break;
                    default:
                        break;
                }
                if (comp !is null) {
                    comp.deserialize(compData);
                }
            }
        }

        return obj;
    }
}
