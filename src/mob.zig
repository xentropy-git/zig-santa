const std = @import("std");
const vect2 = @import("vect2.zig");
const MapData = @import("map.zig").MapData;
const TyleType = @import("tile.zig").TyleType;
const Vect2 = vect2.Vect2;

pub const Mob = struct {
    pos: Vect2,
    vel: Vect2,
    acc: Vect2,
    maxSpeed: f32,
    onGround: bool,

    pub fn init(pos: Vect2, maxSpeed: f32) Mob {
        return Mob{
            .pos = pos,
            .vel = Vect2.init(0.0, 0.0),
            .acc = Vect2.init(0.0, 0.0),
            .maxSpeed = maxSpeed,
            .onGround = false,
        };
    }

    pub fn testCollision(self: *Mob, pos: Vect2, map: *MapData) bool {
        _ = self;
        const tileX: u32 = @intFromFloat(pos.x);
        const tileY: u32 = @intFromFloat(pos.y);

        const maybeTile = map.getTile(tileX, tileY);

        if (maybeTile) |tile| {
            if (tile.tyleType == TyleType.wall) {
                return true;
            }
        }

        return false;
    }

    const offset = 0.1;
    pub fn testTopCorners(self: *Mob, pos: Vect2, map: *MapData) bool {
        const topLeft = Vect2.init(pos.x + offset, pos.y + offset);
        const topRight = Vect2.init(pos.x + 1.0 - offset, pos.y + offset);

        return self.testCollision(topLeft, map) or
            self.testCollision(topRight, map);
    }

    pub fn testBottomCorners(self: *Mob, pos: Vect2, map: *MapData) bool {
        const bottomLeft = Vect2.init(pos.x + offset, pos.y + 1.0 - offset);
        const bottomRight = Vect2.init(pos.x + 1.0 - offset, pos.y + 1.0 - offset);

        return self.testCollision(bottomLeft, map) or
            self.testCollision(bottomRight, map);
    }

    pub fn test4Corners(self: *Mob, pos: Vect2, map: *MapData) bool {
        return self.testTopCorners(pos, map) or
            self.testBottomCorners(pos, map);
    }

    pub fn moveAndCollideX(self: *Mob, deltaTime: f32, map: *MapData) void {
        if (self.vel.x == 0.0) {
            return;
        }

        const newPos = Vect2.init(self.pos.x + self.vel.x * deltaTime, self.pos.y);

        // dont test bottom corners if on ground, this is a hack to
        // prevent the player from getting stuck on the ground
        const collision = switch (self.onGround) {
            true => self.testTopCorners(newPos, map),
            false => self.test4Corners(newPos, map),
        };

        if (!collision) {
            self.pos = newPos;
        } else {
            self.vel.x = 0.0;
        }
    }

    pub fn moveAndCollideY(self: *Mob, deltaTime: f32, map: *MapData) void {
        if (self.vel.y == 0.0) {
            return;
        }
        const newPos = Vect2.init(self.pos.x, self.pos.y + self.vel.y * deltaTime);

        const collision = self.test4Corners(newPos, map);

        if (!collision) {
            self.pos = newPos;
        } else {
            self.vel.y = 0.0;
        }

        if (collision and newPos.y > self.pos.y) {
            const y: f32 = @floor(newPos.y);
            self.pos.y = y + offset;
            self.onGround = true;
        } else {
            self.onGround = false;
        }
    }

    pub fn moveAndCollide(self: *Mob, deltaTime: f32, map: *MapData) void {
        self.vel = self.vel.add(self.acc.mul(deltaTime));

        // limit x velocity
        if (self.vel.x > self.maxSpeed) {
            self.vel.x = self.maxSpeed;
        } else if (self.vel.x < -self.maxSpeed) {
            self.vel.x = -self.maxSpeed;
        }

        self.moveAndCollideX(deltaTime, map);
        self.moveAndCollideY(deltaTime, map);

        const tileX: u32 = @intFromFloat(self.pos.x);
        const tileY: u32 = @intFromFloat(@ceil(self.pos.y));

        const maybeGroundTile = map.getTile(tileX, tileY + 1);
        if (maybeGroundTile) |tile| {
            if (tile.tyleType == TyleType.wall) {
                // self.onGround = true;
            } else {
                //self.onGround = false;
            }
        }
    }
};
