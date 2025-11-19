module game.scenes;
import engine.game;
import engine.renderer;
import engine.input;
import bindbc.sdl;
import std.stdio;

class MenuScene : Scene {
    private bool startPressed = false;
    override string getName() {
        return "MenuScene";}

    override void update(double deltaTime) {
    }

    override void render(Renderer renderer) {
        writeln("Press SPACE to start the game");
    }
    bool shouldStart() {
        return startPressed;
    }
    void checkInput(InputManager input) {
        if (input.isKeyPressed(SDLK_SPACE) || input.isKeyPressed(SDLK_RETURN)) {
            startPressed = true;}
    }
}

class GameOverScene : Scene {
    private int score;
    private bool restartPressed = false;
    this(int finalScore) {
        score = finalScore;}
    override string getName() {
        return "GameOverScene";
    }

    override void update(double deltaTime) {
        // Handled externally
    }

    override void render(Renderer renderer) {
        writeln("\n=== GAME OVER ===");
        writeln("Final Score: ", score);
    }
    bool shouldRestart() {
        return restartPressed;
    }
    void checkInput(InputManager input) {
        if (input.isKeyPressed(SDLK_SPACE) || input.isKeyPressed(SDLK_RETURN)) {
            restartPressed = true;
        }
    }
    int getScore() {
        return score;
    }
}
