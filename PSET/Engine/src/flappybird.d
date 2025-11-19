module game.flappybird;

import engine.game;
import engine.renderer;
import engine.input;
import bindbc.sdl;
import std.stdio;
import std.random;

struct Pipe {
    int x;
    int gapY;
    bool scoredPoint;
}
class FlappyBirdScene : Scene {
    private int birdX = 50;
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
    private bool jumpPressed = false;

    // the pipe parameters
    private Pipe[] pipes;
    private int pipeWidth = 60;
    private int pipeGap = 150;
    private int pipeSpacing = 250;
    private double pipeSpeed = -200.0;
    private double pipeTimer = 0.0;
    private double pipeSpawnRate = 2.5;

    this(Renderer renderer) {
        screenWidth = renderer.getWidth();
        screenHeight = renderer.getHeight();
        writeln("FlappyBirdScene created");
    }

    override string getName() {
        return "FlappyBirdScene";
    }

    override void update(double deltaTime) {
        if (gameOver) return;
        // this is the bird dropping
        birdVelocity += gravity * deltaTime;
        birdY += cast(int)(birdVelocity * deltaTime);

        if (birdY + birdHeight >= screenHeight || birdY <= 0) {
            gameOver = true;
        }
        updatePipes(deltaTime);
        checkPipeCollisions();
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
                // Check if bird hits top or bottom pipe
                if (birdY < pipe.gapY || birdY + birdHeight > pipe.gapY + pipeGap) {
                    gameOver = true;}}
        }
    }

    override void render(Renderer renderer) {
        foreach (pipe; pipes) {
            renderer.drawRect(pipe.x, 0, pipeWidth, pipe.gapY, 34, 139, 34);
            int bottomPipeY = pipe.gapY + pipeGap;
            int bottomPipeHeight = screenHeight - bottomPipeY;
            renderer.drawRect(pipe.x, bottomPipeY, pipeWidth, bottomPipeHeight, 34, 139, 34);}
        renderer.drawRect(birdX, birdY, birdWidth, birdHeight, 255, 200, 0);
    }

    void handleInput(InputManager input) {
        bool spacePressed = input.isKeyPressed(SDLK_SPACE);
        bool upPressed = input.isKeyPressed(SDLK_UP);
        if ((spacePressed || upPressed) && !jumpPressed) {
            birdVelocity = jumpPower;
            jumpPressed = true;
        } else if (!spacePressed && !upPressed) {
            jumpPressed = false;}
    }
    bool isGameOver() {
        return gameOver;
    }
    int getScore() {
        return score;}
}
