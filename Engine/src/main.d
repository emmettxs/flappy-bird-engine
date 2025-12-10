/**
 * The main engine 
 */
module main;

/// Imports the core engine systems
import main_game;
import renderer;
import input;
import gameobject;
import level_loader;
import script_system;
import particle_system;
import powerup_system;
import screen_effects;

/// Imports specific game logic. The end and start screen + logic
import game.flappybird;
import game.scenes;

import std.stdio;
import core.thread;
import core.time;
import bindbc.sdl;

enum GameState {
    MENU, PLAYING, GAME_OVER
}

void main(string[] args) {
    writeln("========================================");
    writeln("  Flappy Bird Game");
    writeln("Controls:");
    writeln("  SPACE/UP - Jump");
    writeln("  ESC - Return to Menu");
    writeln("  R - Restart");
    writeln("  M - Main Menu\n");

    /// Creates the new game
    try {
        Game game = new Game(800, 600);
        GameState currentState = GameState.MENU;
        MenuScene menuScene = null;
        FlappyBirdScene gameScene = null;
        GameOverScene gameOverScene = null;

        // scan levels directory 
        string[] levelFiles;
        import std.file: dirEntries, DirEntry, SpanMode;
        import std.algorithm: endsWith;
        import std.array: array;

        foreach (entry; dirEntries("levels", SpanMode.shallow)) {
            if (entry.name.endsWith(".json")) {
                import std.path : baseName;
                levelFiles ~= baseName(entry.name);}}

        if (levelFiles.length == 0) {
            levelFiles = [
                "level1_easy.json",
                "level2_medium.json",
                "level3_hard.json"];
        }

        int currentLevel = 0;
        GameScript gameConfig = ScriptManager.Get().loadScript("game_config.json");

        while (!game.getInput().getQuitSignal()) {
            game.getInput().processInput();
            final switch (currentState) {
                case GameState.MENU:
                    if (menuScene is null) {
                        menuScene = new MenuScene();
                        menuScene.setLevels(levelFiles, currentLevel);
                        game.setScene(menuScene);

                        /// Level Menu
                        writeln("\n\n");
                        writeln("╔═══════════════════════════════════════════════════╗");
                        writeln("║         FLAPPY BIRD - MAIN MENU                  ║");
                        writeln("╠═══════════════════════════════════════════════════╣");
                        writeln("║                                                   ║");
                        writeln("║  CONTROLS:                                        ║");
                        writeln("║  ← → (LEFT/RIGHT arrows) - Select Level           ║");
                        writeln("║  SPACE                   - Start Game             ║");
                        writeln("║                                                   ║");
                        writeln("╠═══════════════════════════════════════════════════╣");
                        writeln("║  AVAILABLE LEVELS:                                ║");
                        foreach (i, level; levelFiles) {
                            if (i == currentLevel) {
                                writeln("║  ▶▶ ", level, " ◀◀       ");
                            } else {
                                writeln("║     ", level);
                            }
                        }
                        writeln("║                                                   ║");
                        writeln("╚═══════════════════════════════════════════════════╝");
                        writeln("");
                        writeln("Look at the console window for controls!");
                        writeln("");
                    }

                    menuScene.update(0.016);
                    menuScene.checkInput(game.getInput());

                    if (menuScene.shouldStart()) {
                        currentLevel = menuScene.getSelectedLevel();
                        writeln("\nStarting game with ", levelFiles[currentLevel]);
                        gameScene = new FlappyBirdScene(game.getRenderer(), levelFiles[currentLevel]);
                        gameScene.loadPowerUpsFromLevel();  
                        game.setScene(gameScene);
                        currentState = GameState.PLAYING;
                        menuScene = null;
                    }

                    game.getRenderer().clear();
                    if (menuScene !is null) {
                        menuScene.render(game.getRenderer());
                    }
                    game.getRenderer().present();
                    break;

                case GameState.PLAYING:
                    gameScene.handleInput(game.getInput());
                    gameScene.update(0.016);
                    ParticleSystem.Get().update(0.016);

                    game.getRenderer().clear();
                    gameScene.render(game.getRenderer());
                    ParticleSystem.Get().render(game.getRenderer());
                    game.getRenderer().present();
                    if (gameScene.isLevelComplete()) {
                        int finalScore = gameScene.getScore();

                        writeln("\n\n");
                        writeln("╔═══════════════════════════════════════════════════╗");
                        writeln("║             LEVEL COMPLETE!                       ║");
                        writeln("╠═══════════════════════════════════════════════════╣");
                        writeln("║                                                   ║");
                        writeln("║  You cleared all the pipes!                       ║");
                        writeln("║  Final Score: ", finalScore, "                              ");
                        writeln("║                                                   ║");
                        writeln("║  CONTROLS:                                        ║");
                        writeln("║  R - Restart (play same level again)              ║");
                        writeln("║  M - Main Menu (choose different level)           ║");
                        writeln("║                                                   ║");
                        writeln("╚═══════════════════════════════════════════════════╝");
                        writeln("");
                        gameOverScene = new GameOverScene(finalScore);
                        game.setScene(gameOverScene);
                        currentState = GameState.GAME_OVER;
                    } else if (gameScene.isGameOver()) {
                        int finalScore = gameScene.getScore();

                        writeln("\n\n");
                        writeln("╔═══════════════════════════════════════════════════╗");
                        writeln("║              ☠ GAME OVER ☠                       ║");
                        writeln("╠═══════════════════════════════════════════════════╣");
                        writeln("║                                                   ║");
                        writeln("║  Final Score: ", finalScore, "                              ");
                        writeln("║                                                   ║");
                        writeln("║  CONTROLS:                                        ║");
                        writeln("║  R - Restart (play same level again)              ║");
                        writeln("║  M - Main Menu (choose different level)           ║");
                        writeln("║                                                   ║");
                        writeln("╚═══════════════════════════════════════════════════╝");
                        writeln("");
                        gameOverScene = new GameOverScene(finalScore);
                        game.setScene(gameOverScene);
                        currentState = GameState.GAME_OVER;
                    }
                    break;

                case GameState.GAME_OVER:
                    gameOverScene.update(0.016);
                    gameOverScene.checkInput(game.getInput());
                    ParticleSystem.Get().update(0.016);

                    game.getRenderer().clear();
                    if (gameScene !is null) {
                        gameScene.render(game.getRenderer());
                    }
                    gameOverScene.render(game.getRenderer());
                    ParticleSystem.Get().render(game.getRenderer());
                    game.getRenderer().present();

                    if (gameOverScene.shouldRestart()) {
                        writeln("\nRestarting game...");

                        // destroy old scene first
                        if (gameScene !is null) {
                            gameScene.destroy();
                            gameScene = null;
                        }
                        // clear all systems
                        ParticleSystem.Get().clear();
                        PowerUpManager.Get().clear();
                        ScreenEffectsManager.Get().clear();

                        // create new scene
                        gameScene = new FlappyBirdScene(game.getRenderer(), levelFiles[currentLevel]);
                        gameScene.loadPowerUpsFromLevel();
                        game.setScene(gameScene);
                        currentState = GameState.PLAYING;
                        gameOverScene = null;
                    } else if (gameOverScene.shouldReturnToMenu()) {
                        writeln("\nReturning to main menu...");

                        // destroy old scene first
                        if (gameScene !is null) {
                            gameScene.destroy();
                            gameScene = null;
                        }

                        // clear all systems
                        ParticleSystem.Get().clear();
                        PowerUpManager.Get().clear();
                        ScreenEffectsManager.Get().clear();

                        currentState = GameState.MENU;
                        gameOverScene = null;
                    }
                    break;
            }
        }

        writeln("Thanks for playing!");
    } catch (Exception e) {
        return;
    }
}
