const std = @import("std");
const Mob = @import("../models/mob.zig").Mob;
const Map = @import("../models/map.zig").Map;
const Vector2 = @import("raylib").Vector2;
const TileType = @import("../models/tile.zig").TileType;

pub const Physics = struct {
    gravity: f32 = 24,

    pub fn testCollision(self: *Physics, pos: Vector2, map: *Map) bool {
        const tileX: u32 = @intFromFloat(pos.x);
        const tileY: u32 = @intFromFloat(pos.y);
        _ = self;

        const maybeTile = map.getTile(tileX, tileY);

        if (maybeTile) |tile| {
            if (tile.tile_type == TileType.wall) {
                return true;
            }
        }

        return false;
    }

    const offset = 0.1;
    pub fn testTopCorners(self: *Physics, pos: Vector2, map: *Map) bool {
        const topLeft = Vector2.init(pos.x + offset, pos.y + offset);
        const topRight = Vector2.init(pos.x + 1.0 - offset, pos.y + offset);

        return self.testCollision(topLeft, map) or
            self.testCollision(topRight, map);
    }

    pub fn testBottomCorners(self: *Physics, pos: Vector2, map: *Map) bool {
        const bottomLeft = Vector2.init(pos.x + offset, pos.y + 1.0 - offset);
        const bottomRight = Vector2.init(pos.x + 1.0 - offset, pos.y + 1.0 - offset);

        return self.testCollision(bottomLeft, map) or
            self.testCollision(bottomRight, map);
    }

    pub fn test4Corners(self: *Physics, pos: Vector2, map: *Map) bool {
        return self.testTopCorners(pos, map) or
            self.testBottomCorners(pos, map);
    }

    pub fn moveAndCollideX(self: *Physics, mob: *Mob, deltaTime: f32, map: *Map) void {
        if (mob.vel.x == 0.0) {
            return;
        }

        const newPos = Vector2.init(mob.pos.x + mob.vel.x * deltaTime, mob.pos.y);

        // dont test bottom corners if on ground, this is a hack to
        // prevent the player from getting stuck on the ground
        const collision = switch (mob.on_ground) {
            true => self.testTopCorners(newPos, map),
            false => self.test4Corners(newPos, map),
        };

        if (!collision) {
            mob.pos = newPos;
        } else {
            mob.vel.x = 0.0;
        }
    }

    pub fn moveAndCollideY(self: *Physics, mob: *Mob, deltaTime: f32, map: *Map) void {
        if (mob.vel.y == 0.0) {
            return;
        }
        const newPos = Vector2.init(mob.pos.x, mob.pos.y + mob.vel.y * deltaTime);
        const collision = self.test4Corners(newPos, map);

        if (!collision) {
            mob.pos = newPos;
        } else {
            mob.vel.y = 0.0;
        }

        if (collision and newPos.y > mob.pos.y) {
            const y: f32 = @floor(newPos.y);
            mob.pos.y = y + offset;
            mob.on_ground = true;
        } else {
            mob.on_ground = false;
        }
    }

    pub fn moveAndCollide(self: *Physics, mob: *Mob, deltaTime: f32, map: *Map) void {
        const deltaVector = Vector2.init(deltaTime, deltaTime);
        mob.vel = mob.vel.add(mob.acc.multiply(deltaVector));

        // apply gravity
        const gravity = Vector2.init(0.0, self.gravity);
        mob.vel = mob.vel.add(gravity.multiply(deltaVector));

        // limit x velocity
        if (mob.vel.x > mob.max_speed) {
            mob.vel.x = mob.max_speed;
        } else if (mob.vel.x < -mob.max_speed) {
            mob.vel.x = -mob.max_speed;
        }

        self.moveAndCollideX(mob, deltaTime, map);
        self.moveAndCollideY(mob, deltaTime, map);
    }
};
