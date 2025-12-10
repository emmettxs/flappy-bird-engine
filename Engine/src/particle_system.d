/**
 * Particle System
 * This deals with the particle effects
 */
module particle_system;

import renderer;
import std.stdio;
import std.random;
import std.math;

/**
 * Individual particle structure
 */
struct Particle {
    float x;
    float y;
    float velocityX;
    float velocityY;
    float lifetime;
    float maxLifetime;
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte alpha;
    int size;
    bool active;
}
/**
 * Particle emitter configuration
 */
struct EmitterConfig {
    float emissionRate = 10.0;
    float particleLifetime = 1.0;
    float spread = 45.0;
    float speed = 100.0;
    int minSize = 2;
    int maxSize = 6;
    ubyte r = 255;
    ubyte g = 255;
    ubyte b = 255;
    bool useGravity = false;
    float gravity = 200.0;
}

/**
 * Particle Emitter class
 */
class ParticleEmitter {
    private Particle[] particles;
    private float x;
    private float y;
    private EmitterConfig config;
    private float emissionTimer = 0.0;
    private bool isEmitting = false;
    private int maxParticles = 100;

    this(float posX, float posY, EmitterConfig cfg) {
        x = posX;
        y = posY;
        config = cfg;
        particles = new Particle[maxParticles];
        foreach (ref particle; particles) {
            particle.active = false; }
    }
    void setPosition(float posX, float posY) {
        x = posX;
        y = posY;
    }

    void start() {
        isEmitting = true;
    }
    void stop() {
        isEmitting = false;
    }

    void emit(int count = 1) {
        for (int i = 0; i < count; i++) {
            emitSingleParticle();}
    }

    private void emitSingleParticle() {
        foreach (ref particle; particles) {
            if (!particle.active) {
                particle.x = x;
                particle.y = y;
                float angle = uniform(-config.spread, config.spread) * (PI / 180.0);
                float speed = config.speed + uniform(-config.speed * 0.3, config.speed * 0.3);
                particle.velocityX = cos(angle) * speed;
                particle.velocityY = -sin(angle) * speed;

                particle.lifetime = 0.0;
                particle.maxLifetime = config.particleLifetime + uniform(-0.2, 0.2);

                particle.r = cast(ubyte)(config.r + uniform(-20, 20));
                particle.g = cast(ubyte)(config.g + uniform(-20, 20));
                particle.b = cast(ubyte)(config.b + uniform(-20, 20));
                particle.alpha = 255;

                particle.size = uniform(config.minSize, config.maxSize + 1);
                particle.active = true;
                break;}
        }
    }

    void update(double deltaTime) {
        if (isEmitting) {
            emissionTimer += deltaTime;
            float timeBetweenEmissions = 1.0 / config.emissionRate;
            while (emissionTimer >= timeBetweenEmissions) {
                emitSingleParticle();
                emissionTimer -= timeBetweenEmissions;
            }
        }
        foreach (ref particle; particles) {
            if (!particle.active) continue;
            particle.lifetime += deltaTime;

            if (particle.lifetime >= particle.maxLifetime) {
                particle.active = false;
                continue;
            }
            if (config.useGravity) {
                particle.velocityY += config.gravity * deltaTime;
            }

            particle.x += particle.velocityX * deltaTime;
            particle.y += particle.velocityY * deltaTime;

            float lifeRatio = particle.lifetime / particle.maxLifetime;
            particle.alpha = cast(ubyte)(255 * (1.0 - lifeRatio));
        }
    }

    void render(Renderer renderer) {
        foreach (ref particle; particles) {
            if (!particle.active) continue;
            renderer.drawRect(
                cast(int)particle.x, cast(int)particle.y,
                particle.size, particle.size, particle.r,
                particle.g,particle.b
            );
        }
    }

    int getActiveParticleCount() {
        int count = 0;
        foreach (ref particle; particles) {
            if (particle.active) count++;}
        return count;
    }

    bool isActive() {
        return isEmitting || getActiveParticleCount() > 0;
    }
}

/**
 * The particle manager
 */
class ParticleSystem {
    private static ParticleSystem instance;
    private ParticleEmitter[] emitters;
    private this() {}

    static ParticleSystem Get() {
        if (instance is null) {
            instance = new ParticleSystem();
        }
        return instance;
    }

    ParticleEmitter createEmitter(float x, float y, EmitterConfig config) {
        ParticleEmitter emitter = new ParticleEmitter(x, y, config);
        emitters ~= emitter;
        return emitter;
    }

    void removeEmitter(ParticleEmitter emitter) {
        ParticleEmitter[] newEmitters;
        foreach (e; emitters) {
            if (e !is emitter) {
                newEmitters ~= e;}
        }
        emitters = newEmitters;
    }

    void update(double deltaTime) {
        ParticleEmitter[] activeEmitters;
        foreach (emitter; emitters) {
            emitter.update(deltaTime);
            if (emitter.isActive()) {
                activeEmitters ~= emitter;
            }
        }
        emitters = activeEmitters;
    }

    void render(Renderer renderer) {
        foreach (emitter; emitters) {
            emitter.render(renderer);
        }
    }
    void clear() {
        emitters = [];
    }
    int getEmitterCount() {
        return cast(int)emitters.length;
    }

    static ParticleEmitter createExplosion(float x, float y, ubyte r = 255, ubyte g = 200, ubyte b = 0) {
        EmitterConfig config;
        config.emissionRate = 0;
        config.particleLifetime = 0.5;
        config.spread = 180.0;
        config.speed = 200.0;
        config.minSize = 3;
        config.maxSize = 8;
        config.r = r;
        config.g = g;
        config.b = b;
        config.useGravity = true;
        config.gravity = 300.0;

        ParticleEmitter emitter = ParticleSystem.Get().createEmitter(x, y, config);
        emitter.emit(20);
        return emitter;
    }

    static ParticleEmitter createTrail(float x, float y, ubyte r = 255, ubyte g = 255, ubyte b = 255) {
        EmitterConfig config;
        config.emissionRate = 30.0;
        config.particleLifetime = 0.3;
        config.spread = 30.0;
        config.speed = 50.0;
        config.minSize = 2;
        config.maxSize = 4;
        config.r = r;
        config.g = g;
        config.b = b;
        config.useGravity = false;

        ParticleEmitter emitter = ParticleSystem.Get().createEmitter(x, y, config);
        emitter.start();
        return emitter;
    }
}
