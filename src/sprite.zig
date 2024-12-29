const std = @import("std");
const rl = @import("raylib");
const Vector2 = rl.Vector2;

pub const SpriteState = enum {
    idle,
    walk,
    jump,
    fall,
    jet,
};

pub const SpriteDirection = enum { left, right };

pub const SpriteTile = struct {
    x: u64,
    y: u64,

    pub fn init(x: u64, y: u64) SpriteTile {
        return SpriteTile{ .x = x, .y = y };
    }
};

pub const SpriteSpec = struct {
    state: SpriteState,
    maxFrames: u64,
    repeat: bool,
    fps: f64,
    frames: []const SpriteTile,

    pub fn init(
        state: SpriteState,
        maxFrames: u64,
        repeat: bool,
        fps: f64,
        frames: []const SpriteTile,
    ) SpriteSpec {
        return SpriteSpec{
            .state = state,
            .maxFrames = maxFrames,
            .repeat = repeat,
            .fps = fps,
            .frames = frames,
        };
    }
};

pub const Sprite = struct {
    state: SpriteState,
    direction: SpriteDirection,
    frame: u64,
    specs: []const SpriteSpec,
    lastFrameTime: f64,

    pub fn init(
        state: SpriteState,
        direction: SpriteDirection,
        frame: u64,
        specs: []const SpriteSpec,
    ) Sprite {
        return Sprite{
            .state = state,
            .direction = direction,
            .frame = frame,
            .specs = specs,
            .lastFrameTime = 0.0,
        };
    }

    pub fn getSpec(self: *Sprite) ?*const SpriteSpec {
        for (self.specs) |spec| {
            if (spec.state == self.state) {
                return &spec;
            }
        }

        // return default idle state
        for (self.specs) |spec| {
            if (spec.state == SpriteState.idle) {
                return &spec;
            }
        }

        return null;
    }
    pub fn getSrcRect(self: *Sprite) rl.Rectangle {
        const maybeSpec = self.getSpec();
        if (maybeSpec) |spec| {
            const tile = spec.frames[self.frame];
            return rl.Rectangle{
                .x = @floatFromInt(tile.x * 16),
                .y = @floatFromInt(tile.y * 16),
                .width = 16,
                .height = 16,
            };
        } else {
            return rl.Rectangle{
                .x = 0,
                .y = 0,
                .width = 16,
                .height = 16,
            };
        }
    }

    pub fn update(self: *Sprite, dt: f64) void {
        self.lastFrameTime += dt;
        const maybeSpec = self.getSpec();
        if (maybeSpec) |spec| {
            if (self.lastFrameTime >= 1.0 / spec.fps) {
                self.lastFrameTime = 0.0;
                self.frame += 1;
                if (self.frame >= spec.maxFrames) {
                    if (spec.repeat) {
                        self.frame = 0;
                    } else {
                        self.frame = spec.maxFrames - 1;
                    }
                }
            }
        }
    }

    pub fn setState(self: *Sprite, state: SpriteState) void {
        if (self.state != state) {
            self.state = state;
            self.frame = 0;
        }
    }

    pub fn draw(self: *Sprite, pos: Vector2) void {
        const destRect = rl.Rectangle{
            .x = pos.x * 16 * 4,
            .y = pos.y * 16 * 4,
            .width = 16 * 4,
            .height = 16 * 4,
        };

        var srcRect = self.getSrcRect();
        // flip texture if direction is left
        if (self.direction == SpriteDirection.left) {
            srcRect.width *= -1;
        }

        rl.drawTexturePro(
            self.texture,
            srcRect,
            destRect,
            .{ .x = 0, .y = 0 },
            0.0,
            rl.Color.white,
        );
    }
};
