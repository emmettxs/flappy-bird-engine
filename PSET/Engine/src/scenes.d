/**
 * Scene Implementations
 * This creates the menu, playing and game over scenes
 */
module game.scenes;
import main_game;
import renderer;
import input;
import level_loader;
import gameobject;
import resource_manager;
import bindbc.sdl;
import std.stdio;
import std.conv;

/**
 * Menu Scene 
 * Main menu of the game
 */
class MenuScene:Scene {
    private bool startPressed = false;
    private bool editorPressed = false;
    private int selectedOption = 0;
    private double blinkTimer = 0.0;
    private bool showText = true;
    private int currentLevelIndex = 0;
    private string[] levelNames;
    private bool leftPressed = false;
    private bool rightPressed = false;
    private SDL_Texture* backgroundTexture;

    this() {
        levelNames = [];
        backgroundTexture = ResourceManager.Get().LoadTexture("assets/start.bmp");
    }

    void setLevels(string[] levels, int startIndex = 0) {
        levelNames = levels;
        currentLevelIndex = startIndex;
    }
    int getSelectedLevel() {
        return currentLevelIndex;
    }
    override string getName() {
        return "MenuScene";
    }

    override void update(double deltaTime) {
        blinkTimer += deltaTime;
        if (blinkTimer >= 0.5) {
            showText = !showText;
            blinkTimer = 0.0;
        }
    }
    override void render(Renderer renderer) {
        // draws the bmp and centers it
        if (backgroundTexture !is null) {
            int texWidth = 300;
            int texHeight = 250;
            int texX = (800 - texWidth) / 2;  
            int texY = (600 - texHeight) / 2;  
            renderer.drawTexture(backgroundTexture, texX, texY, texWidth, texHeight);
        }
    }
    bool shouldStart() {
        return startPressed;
    }

    /// checks what key is pressed
    void checkInput(InputManager input) {
        if (input.isKeyPressed(SDLK_SPACE)||input.isKeyPressed(SDLK_RETURN)) {
            startPressed = true;
        }
        if (input.isKeyPressed(SDLK_e)) {
            editorPressed = true;
        }

        // level selection with arrow keys
        bool leftNow = input.isKeyPressed(SDLK_LEFT);
        bool rightNow = input.isKeyPressed(SDLK_RIGHT);

        if (leftNow && !leftPressed && levelNames.length > 0) {
            currentLevelIndex--;
            if (currentLevelIndex < 0) {
                currentLevelIndex = cast(int)levelNames.length - 1;
            }
            writeln("Selected level: ", levelNames[currentLevelIndex]);
        }

        if (rightNow && !rightPressed && levelNames.length > 0) {
            currentLevelIndex++;
            if (currentLevelIndex >= levelNames.length) {
                currentLevelIndex = 0;
            }
            writeln("Selected level: ", levelNames[currentLevelIndex]);
        }

        leftPressed = leftNow;
        rightPressed = rightNow;
    }
}

/**
 * Gameplay Scene 
 * this is the main playing scene
 */
class GameplayScene : Scene {
    private Level currentLevel;
    private Renderer renderer;
    private bool levelComplete = false;
    private bool gameFailed = false;
    private int score = 0;

    this(Renderer r, string levelFile = null) {
        renderer = r;
        if (levelFile !is null) {
            LevelManager.Get().setLevelsPath("levels/");
            LevelManager.Get().loadLevel(levelFile);
            currentLevel = LevelManager.Get().getCurrentLevel();
        } else {
            currentLevel = createDefaultLevel();
        }
    }

    private Level createDefaultLevel() {
        Level level = new Level("Default Level");
        LevelConfig cfg;
        cfg.name = "Default Level";
        cfg.width = 800;
        cfg.height = 600;
        cfg.gravity = 800.0;
        cfg.bgR = 135;
        cfg.bgG = 206;
        cfg.bgB = 235;
        level.setConfig(cfg);

        GameObject ground = new GameObject("Ground");
        ground.getTransform().x = 0;
        ground.getTransform().y = 550;
        SpriteComponent groundSprite = new SpriteComponent(ground.getTransform());
        groundSprite.width = 800;
        groundSprite.height = 50;
        groundSprite.r = 139;
        groundSprite.g = 69;
        groundSprite.b = 19;
        ground.addComponent(groundSprite);
        level.addGameObject(ground);
        return level;
    }

    override string getName() {
        return "GameplayScene";
    }
    override void update(double deltaTime) {
        if (currentLevel !is null) {
            currentLevel.update(deltaTime);
        }
    }
    override void render(Renderer renderer) {
        if (currentLevel !is null) {
            LevelConfig cfg = currentLevel.getConfig();
            renderer.clear();
            currentLevel.render(renderer);}
    }

    Level getLevel() {
        return currentLevel;
    }
    void setLevel(Level level) {
        currentLevel = level;
    }
    bool isLevelComplete() {
        return levelComplete;
    }
    bool hasGameFailed() {
        return gameFailed;
    }
    void setGameFailed(bool failed) {
        gameFailed = failed;
    }
    int getScore() {
        return score;
    }
    void addScore(int points) {
        score += points;
    }
}

/**
 * Game Over scene
 * Displayed when the game ends
 */
class GameOverScene : Scene {
    private int score;
    private bool restartPressed = false;
    private bool menuPressed = false;
    private double blinkTimer = 0.0;
    private bool showText = true;
    private SDL_Texture* backgroundTexture;

    this(int finalScore) {
        score = finalScore;
        backgroundTexture = ResourceManager.Get().LoadTexture("assets/end.bmp");
    }
    override string getName() {
        return "GameOverScene";
    }

    override void update(double deltaTime) {
        blinkTimer += deltaTime;
        if (blinkTimer >= 0.5) {
            showText = !showText;
            blinkTimer = 0.0;}
    }

    override void render(Renderer renderer) {
        renderer.drawRect(0, 0, 800, 600, 135, 206, 235);

        if (backgroundTexture !is null) {
            int texWidth = 250;
            int texHeight = 150;
            int texX = (800 - texWidth) / 2; 
            int texY = (600 - texHeight) / 2;  
            renderer.drawTexture(backgroundTexture, texX, texY, texWidth, texHeight);
        }
    }
    bool shouldRestart() {
        return restartPressed;
    }
    bool shouldReturnToMenu() {
        return menuPressed;
    }
    void checkInput(InputManager input) {
        if (input.isKeyPressed(SDLK_r)) {
            restartPressed = true;
        }
        if (input.isKeyPressed(SDLK_m) || input.isKeyPressed(SDLK_ESCAPE)) {
            menuPressed = true;
        }
    }
    int getScore() {
        return score;
    }
}
