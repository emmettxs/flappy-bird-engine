/**
 * Screen Effects System 
 * This adds simple screen effects
 * Screen effects include screen shake, flash effects
 */
module screen_effects;

import std.random;
import std.math;

/**
 * screen shake effect
 */
class ScreenShake {
    private float intensity = 0.0;
    private float duration = 0.0;
    private float timeRemaining = 0.0;
    private int offsetX = 0;
    private int offsetY = 0;
    void trigger(float shakeIntensity, float shakeDuration) {
        if (shakeIntensity > intensity) {
            intensity = shakeIntensity;
            duration = shakeDuration;
            timeRemaining = shakeDuration;}
    }

    void update(double deltaTime) {
        if (timeRemaining > 0) {
            timeRemaining -= deltaTime;
            float currentIntensity = intensity * (timeRemaining / duration);
            offsetX = cast(int)(uniform(-currentIntensity, currentIntensity));
            offsetY = cast(int)(uniform(-currentIntensity, currentIntensity));
        } else {
            offsetX = 0;
            offsetY = 0;
            intensity = 0.0;
        }
    }
    int getOffsetX() { return offsetX; }
    int getOffsetY() { return offsetY; }
    bool isActive() { return timeRemaining > 0; }
}

/**
 * flash effect for screen
 */
class ScreenFlash {
    private float intensity = 0.0;
    private float duration = 0.0;
    private float timeRemaining = 0.0;
    private ubyte r, g, b;

    void trigger(ubyte red, ubyte green, ubyte blue, float flashDuration) {
        r = red;
        g = green;
        b = blue;
        duration = flashDuration;
        timeRemaining = flashDuration;
        intensity = 1.0;
    }
    void update(double deltaTime) {
        if (timeRemaining > 0) {
            timeRemaining -= deltaTime;
            intensity = timeRemaining / duration;
        } else {
            intensity = 0.0;
        }
    }
    bool isActive() { return intensity > 0.0; }
    float getIntensity() { return intensity; }
    ubyte getR() { return cast(ubyte)(r * intensity); }
    ubyte getG() { return cast(ubyte)(g * intensity); }
    ubyte getB() { return cast(ubyte)(b * intensity); }
}

/**
 * slow motion effect
 */
class SlowMotionEffect {
    private float timeRemaining = 0.0;
    private float slowFactor = 0.5;
    void trigger(float duration, float factor = 0.5) {
        timeRemaining = duration;
        slowFactor = factor;
    }
    void update(double deltaTime) {
        if (timeRemaining > 0) {
            timeRemaining -= deltaTime;
        }
    }
    bool isActive() { return timeRemaining > 0; }
    float getSlowFactor() { return slowFactor; }
    float getTimeRemaining() { return timeRemaining; }
}

/**
 * Screen Effects Manager
 */
class ScreenEffectsManager {
    private static ScreenEffectsManager instance;
    private ScreenShake screenShake;
    private ScreenFlash screenFlash;
    private SlowMotionEffect slowMotion;

    private this() {
        screenShake = new ScreenShake();
        screenFlash = new ScreenFlash();
        slowMotion = new SlowMotionEffect();
    }
    static ScreenEffectsManager Get() {
        if (instance is null) {
            instance = new ScreenEffectsManager();
        }
        return instance;
    }
    void update(double deltaTime) {
        screenShake.update(deltaTime);
        screenFlash.update(deltaTime);
        slowMotion.update(deltaTime);
    }
    void triggerShake(float intensity, float duration) {
        screenShake.trigger(intensity, duration);
    }
    void triggerFlash(ubyte r, ubyte g, ubyte b, float duration) {
        screenFlash.trigger(r, g, b, duration);
    }

    void triggerSlowMotion(float duration, float factor = 0.5) {
        slowMotion.trigger(duration, factor);
    }

    int getShakeOffsetX() { return screenShake.getOffsetX(); }
    int getShakeOffsetY() { return screenShake.getOffsetY(); }

    bool hasFlash() { return screenFlash.isActive(); }
    ubyte getFlashR() { return screenFlash.getR(); }
    ubyte getFlashG() { return screenFlash.getG(); }
    ubyte getFlashB() { return screenFlash.getB(); }
    float getFlashIntensity() { return screenFlash.getIntensity(); }

    bool hasSlowMotion() { return slowMotion.isActive(); }
    float getSlowFactor() { return slowMotion.getSlowFactor(); }

    void clear() {
        screenShake = new ScreenShake();
        screenFlash = new ScreenFlash();
        slowMotion = new SlowMotionEffect();
    }
}
