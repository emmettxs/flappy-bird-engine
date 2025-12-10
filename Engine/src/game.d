module main_game;
import renderer;
import input;
import resource_manager;
import std.stdio;
import core.thread;

abstract class Scene {
    abstract void update(double deltaTime);
    abstract void render(Renderer renderer);
    abstract string getName();
}

class Game {
    private Renderer renderer;
    private InputManager input;
    private ResourceManager resourceManager;
    private Scene currentScene;
    private bool isRunning = true;
    private double frameTime = 1.0 / 60.0;

    this(int windowWidth, int windowHeight) {
        renderer = new Renderer(windowWidth, windowHeight);
        input = new InputManager();
        resourceManager = ResourceManager.Get();
        resourceManager.SetRenderer(renderer.getSDLRenderer());
    }

    void setScene(Scene scene) {
        currentScene = scene;
    }
    void run() {
        import core.time;
        import std.datetime.stopwatch;

        StopWatch watch;
        while (isRunning && !input.getQuitSignal()) {
            watch.start();
            input.processInput();
            if (currentScene !is null) {
                currentScene.update(frameTime);
            }

            renderer.clear();
            if (currentScene !is null) {
                currentScene.render(renderer);
            }
            renderer.present();

            watch.stop();
            double elapsedTime = watch.peek().total!"msecs" / 1000.0;
            watch.reset();
            double sleepTime = frameTime - elapsedTime;
            if (sleepTime > 0) {
                Thread.sleep(dur!"msecs"(cast(long)(sleepTime * 1000)));}
        }
        writeln("Game ended");
    }

    void quit() {
        isRunning = false;
    }
    Renderer getRenderer() {
        return renderer;
    }
    InputManager getInput() {
        return input;
    }
    ResourceManager getResourceManager() {
        return resourceManager;
    }
    ~this() {
        if (resourceManager !is null) {
            resourceManager.UnloadAll();
        }
        if (renderer !is null) {
            destroy(renderer);
        }
    }
}
