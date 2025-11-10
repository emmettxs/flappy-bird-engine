/**
 * Flappy Bird Game 
 * Authors: Emmett
 */

import std.stdio;
import std.random;
import std.math;

const int GAME_WIDTH = 400;

// height in pixels
const int GAME_HEIGHT = 600;

const float GRAVITY = 500.0f;

// represents the player-controlled bird character
class Bird
{
    float x, y;              
    float velocityY = 0;     
    const float WIDTH = 34;  
    const float HEIGHT = 24; 
    this(float startX, float startY)
    {
        x = startX;
        y = startY;
    }

    void update(float deltaTime)
    {
        velocityY += GRAVITY * deltaTime;
        y += velocityY * deltaTime;
    }

    void jump()
    {
        velocityY = -300;
    }

    float getY() const { return y; }

    bool isOutOfBounds() const
    {
        return y <= 0 || y >= GAME_HEIGHT;
    }
}

class Pipe
{
    float x;
    int gapY;
    const int GAP_SIZE = 120;
    const int PIPE_WIDTH = 52;
    bool scored = false;

    this(float startX, int gapPosition)
    {
        x = startX;
        gapY = gapPosition;
    }

    void update(float deltaTime)
    {
        x -= 200 * deltaTime; 
    }

    bool checkCollision(Bird bird) const
    {
        if (bird.x + bird.WIDTH < x || bird.x > x + PIPE_WIDTH)
            return false;
        if (bird.y < gapY || bird.y + bird.HEIGHT > gapY + GAP_SIZE)
            return true;
        return false;
    }
    void markScored() { scored = true; }
    bool hasScored() const { return scored; }
    float getX() const { return x; }
}

class FlappyBirdGame
{
    Bird bird;
    Pipe[] pipes;
    int score = 0;
    bool gameOver = false;
    int frameCount = 0;

    void initialize()
    {
        bird = new Bird(GAME_WIDTH / 2, GAME_HEIGHT / 2);
    }
    void run()
    {
        writeln("=== Flappy Bird ===");
        writeln("Game Size: ", GAME_WIDTH, "x", GAME_HEIGHT);
        writeln("Starting bird position: (", bird.x, ", ", bird.getY(), ")");

        for (int i = 0; i < 300 && !gameOver; i++)
        {
            float deltaTime = 1.0f / 60.0f;
            frameCount++;
            if (frameCount % 120 == 0)
                bird.jump();

            bird.update(deltaTime);

            if (frameCount % 90 == 0)
            {
                int randomGap = 100 + uniform(0, GAME_HEIGHT - 250);
                pipes ~= new Pipe(GAME_WIDTH, randomGap);
            }
            Pipe[] activePipes;
            foreach (pipe; pipes)
            {
                pipe.update(deltaTime);
                if (pipe.checkCollision(bird))
                {
                    gameOver = true;
                    writeln("COLLISION! Game Over");
                }
                if (pipe.getX() < bird.x && !pipe.hasScored())
                {
                    score++;
                    pipe.markScored();
                }
                if (pipe.getX() > -60)
                    activePipes ~= pipe;
            }
            pipes = activePipes;
            if (bird.isOutOfBounds())
            {
                gameOver = true;
                writeln("Out of bounds! Game Over");
            }
            if (frameCount % 60 == 0)
            {
                writef("Frame %d | Score: %d | Bird Y: %.1f | Pipes: %d\n",
                       frameCount, score, bird.getY(), pipes.length);
            }
        }
        writeln("Final Score: ", score);
    }
}

void main()
{
    writeln("Flappy Bird");
    writeln("");
    auto game = new FlappyBirdGame();
    game.initialize();
    game.run();
}
