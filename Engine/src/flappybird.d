/**
 * Flappy Bird Game Implementation
 * Uses component system and the power-ups
 */
module game.flappybird;

import main_game;
import renderer;
import input;
import gameobject;
import level_loader;
import particle_system;
import powerup_system;
import screen_effects;

import bindbc.sdl;
import std.stdio;
import std.random;
import std.conv;

/**
 * Pipe structure 
 */
struct Pipe {
    int x;
    int gapY;
    bool scoredPoint;
}

/**
 * Main Flappy Bird Scene
 */
class FlappyBirdScene : Scene {
    private int birdX = 40;
    private int birdY = 200;
    private int birdWidth = 25;
    private int birdHeight = 25;
    private double birdVelocity = 0.0;
    private double gravity = 800.0;
    private double jumpPower = -300.0;
    private int score = 0;
    private int screenWidth;
    private int screenHeight;
    private bool gameOver = false;
    private bool levelComplete = false;
    private bool jumpPressed = false;

    // pipe parameters
    private Pipe[] pipes;
    private int pipeWidth = 60;
    private int pipeGap = 150;
    private int pipeSpacing = 250;
    private double pipeSpeed = -200.0;
    private double pipeTimer = 0.0;
    private double pipeSpawnRate = 2.5;

    private Level currentLevel;
    private ParticleEmitter birdTrail;
    private string levelFile;
    private string[] scoredPipes; 

    this(Renderer renderer, string levelFileName = null) {
        screenWidth = renderer.getWidth();
        screenHeight = renderer.getHeight();
        levelFile = levelFileName;

        // loads the level from the json
        if (levelFile !is null) {
            LevelManager.Get().setLevelsPath("levels/");
            LevelManager.Get().loadLevel(levelFile);
            currentLevel = LevelManager.Get().getCurrentLevel();

            if (currentLevel !is null) {
                writeln("FlappyBirdScene loaded level: ", currentLevel.getName());
                LevelConfig config = currentLevel.getConfig();
                gravity = config.gravity;
            } else {
            }
        } else {
            writeln("FlappyBirdScene created (no level file specified)");
        }

        EmitterConfig trailConfig;
        trailConfig.emissionRate = 20.0;
        trailConfig.particleLifetime = 0.5;
        trailConfig.spread = 45.0;
        trailConfig.speed = 30.0;
        trailConfig.minSize = 2;
        trailConfig.maxSize = 4;
        trailConfig.r = 255;
        trailConfig.g = 200;
        trailConfig.b = 0;
        trailConfig.useGravity = false;
        birdTrail = ParticleSystem.Get().createEmitter(birdX, birdY, trailConfig);
        birdTrail.start();
    }

    override string getName() {
        return "FlappyBirdScene";
    }
    override void update(double deltaTime) {
        if (gameOver || levelComplete) return;
        ScreenEffectsManager.Get().update(deltaTime);

        int effectiveBirdWidth = birdWidth;
        int effectiveBirdHeight = birdHeight;
        if (PowerUpManager.Get().hasActivePowerUp(PowerUpType.SHRINK)) {
            effectiveBirdWidth = birdWidth / 2;
            effectiveBirdHeight = birdHeight / 2;
        }

        double effectiveGravity = gravity;
        if (PowerUpManager.Get().hasActivePowerUp(PowerUpType.SPEED_BOOST)) {
            effectiveGravity *= 0.7; 
        }

        birdVelocity += effectiveGravity * deltaTime;
        birdY += cast(int)(birdVelocity * deltaTime);

        if (birdTrail !is null) {
            birdTrail.setPosition(birdX + effectiveBirdWidth / 2, birdY + effectiveBirdHeight / 2);
        }

        // checks the boundary collisions (unless invincible)
        if (birdY + effectiveBirdHeight >= screenHeight || birdY <= 0) {
            if (!PowerUpManager.Get().hasActivePowerUp(PowerUpType.INVINCIBILITY)) {
                triggerGameOver();
                return;}
        }

        // update the power-ups
        PowerUpManager.Get().update(deltaTime, birdX, birdY, effectiveBirdWidth, effectiveBirdHeight);

        // move the pipes toward the bird
        if (currentLevel !is null) {
            movePipes(deltaTime);
            PowerUpManager.Get().movePowerUps(-200.0, deltaTime);
            currentLevel.update(deltaTime);
            checkLevelCollisions(effectiveBirdWidth, effectiveBirdHeight);
            checkPipePassage();
            checkLevelCompletion();
        }
    }

    /// this will move the pipes toward the birds
    private void movePipes(double deltaTime) {
        if (currentLevel is null) return;
        float scrollSpeed = -200.0; 
        foreach (obj; currentLevel.getGameObjects()) {
            if (!obj.isActive()) continue;
            ColliderComponent collider = obj.getComponent!ColliderComponent();
            if (collider !is null) {
                if (collider.tag == "pipe" || collider.tag == "wall" || collider.tag == "ceiling") {
                    TransformComponent transform = obj.getTransform();
                    if (transform !is null) {
                        transform.x += scrollSpeed * deltaTime;}}
            }
        }
    }

    private void checkLevelCollisions(int effectiveWidth, int effectiveHeight) {
        if (currentLevel is null) return;
        // skip collision if invincible
        if (PowerUpManager.Get().hasActivePowerUp(PowerUpType.INVINCIBILITY)) {
            return;
        }

        foreach (obj; currentLevel.getGameObjects()) {
            if (!obj.isActive()) continue;

            ColliderComponent collider = obj.getComponent!ColliderComponent();
            TransformComponent transform = obj.getTransform();

            if (collider !is null && transform !is null) {
                // check if bird collides with this object
                bool collision = (
                    birdX < transform.x + collider.width &&
                    birdX + effectiveWidth > transform.x &&
                    birdY < transform.y + collider.height &&
                    birdY + effectiveHeight > transform.y
                );

                if (collision) {
                    if (collider.tag == "pipe" || collider.tag == "ground" || collider.tag == "wall" || collider.tag == "ceiling") {
                        triggerGameOver();
                        break;}
                }
            }
        }
    }
    private void triggerGameOver() {
        gameOver = true;
        if (birdTrail !is null) {
            birdTrail.stop();
        }

        // screen shake and the flash
        ScreenEffectsManager.Get().triggerShake(20.0, 0.5);
        ParticleSystem.createExplosion(birdX + birdWidth / 2, birdY + birdHeight / 2, 255, 200, 0);
    }

    private void checkPipePassage() {
        if (currentLevel is null) return;
        foreach (obj; currentLevel.getGameObjects()) {
            if (!obj.isActive()) continue;
            ColliderComponent collider = obj.getComponent!ColliderComponent();
            TransformComponent transform = obj.getTransform();
            if (collider !is null && transform !is null && collider.tag == "pipe") {
                // check if bird has passed the pipe
                if (transform.x + collider.width < birdX) {
                    string pipeName = obj.getName();

                    // check if we've already scored this pipe
                    bool alreadyScored = false;
                    foreach (scoredName; scoredPipes) {
                        if (scoredName == pipeName) {
                            alreadyScored = true;
                            break;}
                    }

                    // Only score if this pipe hasn't been scored yet
                    if (!alreadyScored) {
                        import std.algorithm : canFind;
                        if (pipeName.canFind("_Bottom")) {
                            score++;
                            writeln("Score: ", score);
                            ParticleSystem.createExplosion(birdX, birdY + birdHeight/2, 0, 255, 0);}
                        scoredPipes ~= pipeName;
                    }
                }
            }
        }
    }
    private void checkLevelCompletion() {
        if (currentLevel is null || levelComplete || gameOver) return;
        float rightmostPipeX = -1000.0;
        bool foundAnyPipe = false;

        foreach (obj; currentLevel.getGameObjects()) {
            if (!obj.isActive()) continue;
            ColliderComponent collider = obj.getComponent!ColliderComponent();
            TransformComponent transform = obj.getTransform();
            if (collider !is null && transform !is null && collider.tag == "pipe") {
                foundAnyPipe = true;
                float pipeRightEdge = transform.x + collider.width;
                if (pipeRightEdge > rightmostPipeX) {
                    rightmostPipeX = pipeRightEdge;
                }
            }
        }

        if (foundAnyPipe && birdX > rightmostPipeX + 100) {
            levelComplete = true;
            writeln("Level Complete! Passed all pipes!");
            ScreenEffectsManager.Get().triggerFlash(0, 255, 0, 0.5);
            ParticleSystem.createExplosion(birdX + birdWidth / 2, birdY + birdHeight / 2, 0, 255, 0);

            if (birdTrail !is null) {
                birdTrail.stop();
            }
        }
    }

    private void updatePipes(double deltaTime) {
        pipeTimer += deltaTime;
        if (pipeTimer >= pipeSpawnRate) {
            spawnPipe();
            pipeTimer = 0.0;
        }
        for (size_t i = 0; i < pipes.length; i++) {
            pipes[i].x += cast(int)(pipeSpeed * deltaTime);
            if (!pipes[i].scoredPoint && pipes[i].x + pipeWidth < birdX) {
                pipes[i].scoredPoint = true;
                score++;
                writeln("Score: ", score);
            }
        }
        Pipe[] newPipes;
        foreach (pipe; pipes) {
            if (pipe.x + pipeWidth > 0) {
                newPipes ~= pipe;
            }
        }
        pipes = newPipes;
    }

    private void spawnPipe() {
        int minGapY = 50;
        int maxGapY = screenHeight - pipeGap - 50;
        int gapY = minGapY + (uniform(0, maxGapY - minGapY));

        Pipe newPipe;
        newPipe.x = screenWidth;
        newPipe.gapY = gapY;
        newPipe.scoredPoint = false;
        pipes ~= newPipe;
    }
    private void checkPipeCollisions() {
        foreach (pipe; pipes) {
            if (birdX + birdWidth > pipe.x && birdX < pipe.x + pipeWidth) {
                if (birdY < pipe.gapY || birdY + birdHeight > pipe.gapY + pipeGap) {
                    gameOver = true;}}
        }
    }
    override void render(Renderer renderer) {
        int shakeX = ScreenEffectsManager.Get().getShakeOffsetX();
        int shakeY = ScreenEffectsManager.Get().getShakeOffsetY();
        if (currentLevel !is null) {
            currentLevel.render(renderer);
        }

        // render the power-ups
        PowerUpManager.Get().render(renderer);
        int effectiveBirdWidth = birdWidth;
        int effectiveBirdHeight = birdHeight;
        ubyte birdR = 255;
        ubyte birdG = 200;
        ubyte birdB = 0;

        if (PowerUpManager.Get().hasActivePowerUp(PowerUpType.SHRINK)) {
            effectiveBirdWidth = birdWidth / 2;
            effectiveBirdHeight = birdHeight / 2;
            birdR = 255; birdG = 105; birdB = 180; // Pink when shrunk
        }
        ///turns to gold when invincible
        if (PowerUpManager.Get().hasActivePowerUp(PowerUpType.INVINCIBILITY)) {
            birdR = 255; birdG = 215; birdB = 0; 
        }
        /// turns cyan when speed boosted
        if (PowerUpManager.Get().hasActivePowerUp(PowerUpType.SPEED_BOOST)) {
            birdR = 0; birdG = 255; birdB = 255; 
        }

        int birdRenderX = birdX + shakeX;
        int birdRenderY = birdY + shakeY;
        renderer.drawRect(birdRenderX, birdRenderY, effectiveBirdWidth, effectiveBirdHeight, birdR, birdG, birdB);
        renderActivePowerUps(renderer);

        // Render screen flash effect 
        if (ScreenEffectsManager.Get().hasFlash()) {
            float intensity = ScreenEffectsManager.Get().getFlashIntensity();
            ubyte flashR = ScreenEffectsManager.Get().getFlashR();
            ubyte flashG = ScreenEffectsManager.Get().getFlashG();
            ubyte flashB = ScreenEffectsManager.Get().getFlashB();
            renderer.drawRect(0, 0, screenWidth, screenHeight, flashR, flashG, flashB);
        }
    }

    private void renderActivePowerUps(Renderer renderer) {
        auto activePowerUps = PowerUpManager.Get().getActivePowerUps();
        int yOffset = 60;

        foreach (powerUp; activePowerUps) {
            // power-up background
            renderer.drawRect(10, yOffset, 40, 40, 30, 30, 30);

            // power-up color indicator
            ubyte r, g, b;
            final switch (powerUp.type) {
                case PowerUpType.INVINCIBILITY:
                    r = 255; g = 215; b = 0; break;
                case PowerUpType.SPEED_BOOST:
                    r = 0; g = 255; b = 255; break;
                case PowerUpType.SHRINK:
                    r = 255; g = 105; b = 180; break;
            }
            renderer.drawRect(15, yOffset + 5, 30, 30, r, g, b);
            float timeRatio = powerUp.timeRemaining / powerUp.duration;
            int barWidth = cast(int)(30 * timeRatio);
            renderer.drawRect(15, yOffset + 37, barWidth, 3, 255, 255, 255);

            yOffset += 45;
        }
    }
    void handleInput(InputManager input) {
        bool spacePressed = input.isKeyPressed(SDLK_SPACE);
        bool upPressed = input.isKeyPressed(SDLK_UP);
        if ((spacePressed|| upPressed) && !jumpPressed) {
            birdVelocity = jumpPower;
            jumpPressed = true;
            ParticleSystem.createExplosion(
                birdX + birdWidth / 2,
                birdY + birdHeight, 200, 200, 255
            );
        } else if (!spacePressed && !upPressed) {
            jumpPressed = false;}
    }
    bool isGameOver() {
        return gameOver;
    }
    bool isLevelComplete() {
        return levelComplete;
    }
    int getScore() {
        return score;
    }
    void spawnTestPowerUps() {
        PowerUpManager.Get().spawnPowerUp(300, 200, PowerUpType.INVINCIBILITY);
        PowerUpManager.Get().spawnPowerUp(600, 150, PowerUpType.SPEED_BOOST);
        PowerUpManager.Get().spawnPowerUp(900, 250, PowerUpType.SHRINK);
    }

    void loadPowerUpsFromLevel() {
        /// load the power ups
        if (currentLevel is null) return;
        foreach (obj; currentLevel.getGameObjects()) {
            if (!obj.isActive()) continue;
            ColliderComponent collider = obj.getComponent!ColliderComponent();
            TransformComponent transform = obj.getTransform();

            if (collider !is null && transform !is null) {
                PowerUpType powerUpType;
                bool isPowerUp = false;
                if (collider.tag == "powerup_invincibility") {
                    powerUpType = PowerUpType.INVINCIBILITY;
                    isPowerUp = true;
                } else if (collider.tag == "powerup_speed") {
                    powerUpType = PowerUpType.SPEED_BOOST;
                    isPowerUp = true;
                } else if (collider.tag == "powerup_shrink") {
                    powerUpType = PowerUpType.SHRINK;
                    isPowerUp = true;}

                if (isPowerUp) {
                    PowerUpManager.Get().spawnPowerUp(transform.x, transform.y, powerUpType);
                    obj.setActive(false); 
                    writeln("Loaded power-up from level: ", powerUpType, " at (", transform.x, ", ", transform.y, ")");
                }
            }
        }
    }

    void destroy() {
        // clean up the level resources
        if (currentLevel !is null) {
            currentLevel.destroy();
            currentLevel = null;
        }
        // clean up the bird trail
        if (birdTrail !is null) {
            birdTrail.stop();
            birdTrail = null;
        }

        // clear scored pipes tracking
        scoredPipes = [];
    }
}

