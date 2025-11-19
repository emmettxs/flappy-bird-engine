module main;

import engine.game;
import engine.renderer;
import engine.input;
import game.flappybird;
import game.scenes;
import std.stdio;
import core.thread;
import core.time;

void main() {
    writeln("Starting Flappy Bird Game...");
    writeln("Engine: Simple 2D Game Engine with SDL");
    writeln("Game: Flappy Bird Clone\n");

    try {
        Game game = new Game(800, 600);

        writeln("Use SPACE or UP ARROW to make the bird jump.");
        FlappyBirdScene gameScene = new FlappyBirdScene(game.getRenderer());
        game.setScene(gameScene);

        // Main game loop
        while (!game.getInput().getQuitSignal()) {
            game.getInput().processInput();
            gameScene.handleInput(game.getInput());
            gameScene.update(0.016);

            game.getRenderer().clear();
            gameScene.render(game.getRenderer());
            game.getRenderer().present();

            if (gameScene.isGameOver()) {
                writeln("\n=== GAME OVER ===");
                writeln("Final Score: ", gameScene.getScore());
                break;
            }
            Thread.sleep(dur!"msecs"(16));
        }

        writeln("Game ended");
    } catch (Exception e) {
        writeln("Error: ", e.msg);
        return;
    }
}
