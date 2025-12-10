/**
 * Power-Up System 
 * This  is the powerup manager system
 */
module powerup_system;

import renderer;
import particle_system;
import std.stdio;
import std.random;
import std.math;

/**
 * Power-up types
 */
enum PowerUpType {
    INVINCIBILITY,  
    SPEED_BOOST,    
    SHRINK,        
}

/**
 * Individual power-up instance
 */
class PowerUp {
    float x, y;
    int width = 20;
    int height = 20;
    PowerUpType type;
    bool active = true;
    float rotationAngle = 0.0;
    float bobOffset = 0.0;
    float bobTimer = 0.0;
    ubyte r, g, b;

    this(float posX, float posY, PowerUpType powerType) {
        x = posX;
        y = posY;
        type = powerType;
        // set color based on type
        final switch (type) {
            case PowerUpType.INVINCIBILITY:
                r = 255; g = 215; b = 0; // gold
                break;
            case PowerUpType.SPEED_BOOST:
                r = 0; g = 255; b = 255; // cyan
                break;
            case PowerUpType.SHRINK:
                r = 255; g = 105; b = 180; // Pink
                break;}
    }

    void update(double deltaTime) {
        if (!active) return;
        rotationAngle += 180.0 * deltaTime;
        if (rotationAngle >= 360.0) rotationAngle -= 360.0;

        // animation for the up and down
        bobTimer += deltaTime * 3.0;
        bobOffset = sin(bobTimer) * 10.0;
    }

    void render(Renderer renderer) {
        if (!active) return;
        int drawY = cast(int)(y + bobOffset);
        int centerX = cast(int)(x + width / 2);
        int centerY = drawY + height / 2;
        renderer.drawRect(cast(int)(x - 5), drawY - 5, width + 10, height + 10, r/3, g/3, b/3);

        //different shapes for each power up
        final switch (type) {
            case PowerUpType.INVINCIBILITY:
                // Star shape 
                renderer.drawRect(centerX - 10, centerY - 2, 20, 4, r, g, b); // Horizontal
                renderer.drawRect(centerX - 2, centerY - 10, 4, 20, r, g, b); // Vertical
                renderer.drawRect(centerX - 7, centerY - 7, 14, 2, r, g, b); // Diagonal 1
                renderer.drawRect(centerX - 7, centerY + 5, 14, 2, r, g, b); // Diagonal 2
                renderer.drawRect(centerX - 2, centerY - 7, 2, 14, r, g, b); // Diagonal 3
                renderer.drawRect(centerX + 5, centerY - 7, 2, 14, r, g, b); // Diagonal 4
                renderer.drawRect(centerX - 4, centerY - 4, 8, 8, 255, 255, 255);
                break;

            case PowerUpType.SPEED_BOOST:
                // Arrow shape 
                renderer.drawRect(centerX - 8, centerY - 2, 12, 4, r, g, b); // Shaft
                renderer.drawRect(centerX + 2, centerY - 6, 6, 4, r, g, b); // Upper arrow
                renderer.drawRect(centerX + 2, centerY + 2, 6, 4, r, g, b); // Lower arrow
                renderer.drawRect(centerX + 6, centerY - 10, 2, 8, r, g, b); // Upper spike
                renderer.drawRect(centerX + 6, centerY + 2, 2, 8, r, g, b); // Lower spike
                break;

            case PowerUpType.SHRINK:
                // Two arrows pointing inward
                renderer.drawRect(centerX - 10, centerY - 2, 6, 4, r, g, b); // Left arrow
                renderer.drawRect(centerX - 14, centerY - 4, 4, 8, r, g, b); // Left point
                renderer.drawRect(centerX + 4, centerY - 2, 6, 4, r, g, b); // Right arrow
                renderer.drawRect(centerX + 10, centerY - 4, 4, 8, r, g, b); // Right point
                renderer.drawRect(centerX - 2, centerY - 2, 4, 4, 255, 255, 255);
                break;
        }
    }

    bool checkCollision(int birdX, int birdY, int birdWidth, int birdHeight) {
        if (!active) return false;
        return (birdX < x + width &&
                birdX + birdWidth > x &&
                birdY < y + height &&
                birdY + birdHeight > y);}
}

/**
 * Power-up effect on the player
 */
struct ActivePowerUp {
    PowerUpType type;
    float duration;
    float timeRemaining;
}

/**
 * Power Up Manager
 */
class PowerUpManager {
    private static PowerUpManager instance;
    private PowerUp[] powerUps;
    private ActivePowerUp[] activePowerUps;
    private this() {}

    static PowerUpManager Get() {
        if (instance is null) {
            instance = new PowerUpManager();
        }
        return instance;
    }

    void spawnPowerUp(float x, float y, PowerUpType type) {
        PowerUp powerUp = new PowerUp(x, y, type);
        powerUps ~= powerUp;
    }

    void update(double deltaTime, int birdX, int birdY, int birdWidth, int birdHeight) {
        foreach (powerUp; powerUps) {
            powerUp.update(deltaTime);
            //checks the collision
            if (powerUp.checkCollision(birdX, birdY, birdWidth, birdHeight)) {
                activatePowerUp(powerUp.type, powerUp.x + powerUp.width/2, powerUp.y + powerUp.height/2);
                powerUp.active = false;
            }
        }
        PowerUp[] newPowerUps;
        foreach (powerUp; powerUps) {
            if (powerUp.active) {
                newPowerUps ~= powerUp;
            }
        }
        powerUps = newPowerUps;

        // update active power up durations
        ActivePowerUp[] stillActive;
        foreach (ref activePowerUp; activePowerUps) {
            activePowerUp.timeRemaining -= deltaTime;
            if (activePowerUp.timeRemaining > 0) {
                stillActive ~= activePowerUp;
            } }
        activePowerUps = stillActive;
    }

    void render(Renderer renderer) {
        foreach (powerUp; powerUps) {
            powerUp.render(renderer);
        }
    }
    void activatePowerUp(PowerUpType type, float x, float y) {
        ActivePowerUp activePowerUp;
        activePowerUp.type = type;

        // set duration based on type
        final switch (type) {
            case PowerUpType.INVINCIBILITY:
                activePowerUp.duration = 5.0;
                break;
            case PowerUpType.SPEED_BOOST:
                activePowerUp.duration = 4.0;
                break;
            case PowerUpType.SHRINK:
                activePowerUp.duration = 6.0;
                break;
        }
        activePowerUp.timeRemaining = activePowerUp.duration;
        activePowerUps ~= activePowerUp;

        // create the collision effect
        ParticleSystem.createExplosion(x, y, 255, 255, 0);
        writeln("Activated power-up: ", type, " for ", activePowerUp.duration, " seconds");
    }

    bool hasActivePowerUp(PowerUpType type) {
        foreach (activePowerUp; activePowerUps) {
            if (activePowerUp.type == type) {
                return true;
            }
        }
        return false;
    }
    float getScoreMultiplier() {
        return 1.0;
    }

    void movePowerUps(float scrollSpeed, double deltaTime) {
        foreach (powerUp; powerUps) {
            powerUp.x += scrollSpeed * deltaTime;
        }
    }

    void clear() {
        powerUps = [];
        activePowerUps = [];
    }
    size_t getPowerUpCount() {
        return powerUps.length;
    }

    ActivePowerUp[] getActivePowerUps() {
        return activePowerUps;
    }
}
