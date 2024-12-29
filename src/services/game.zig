const std = @import("std");
const rl = @import("raylib");
const map = @import("../models/map.zig");
const tile = @import("../models/tile.zig");
const renderer = @import("renderer.zig");
const player = @import("../models/player.zig");
const physics = @import("physics.zig");
const Mob = @import("../models/mob.zig").Mob;
const SpriteDirection = @import("../sprite.zig").SpriteDirection;

pub const gameState = enum {
    titleScreen,
    game,
};

pub const GameKey = enum {
    enter,
    player_1_jump,
    player_1_down,
    player_1_left,
    player_1_right,
    player_1_jet,
};

pub const Game = struct {
    state: gameState,
    map: *map.Map,
    mapWidth: u32,
    mapHeight: u32,
    renderer: renderer.Renderer,
    player_1: player.Player,
    physics: physics.Physics,

    pub fn init(
        allocator: std.mem.Allocator,
        mapWidth: u32,
        mapHeight: u32,
    ) !Game {
        std.log.info("Initializing game", .{});
        std.log.info("Creating map: {d}x{d}", .{ mapWidth, mapHeight });
        var gameMap = try allocator.create(map.Map);
        gameMap.* = try map.Map.init(allocator, mapWidth, mapHeight);
        for (0..mapHeight) |y| {
            for (0..mapWidth) |x| {
                var pos = &gameMap.data[x][y];
                if (x == 0 or x == mapWidth - 1 or y == 0 or y == mapHeight - 1) {
                    pos.tile_type = tile.TileType.wall;
                } else {
                    pos.tile_type = tile.TileType.floor;
                }
                pos.x = x;
                pos.y = y;
            }
        }
        std.log.info("Map created", .{});
        std.log.info("{d}x{d}", .{ gameMap.data.len, gameMap.data[0].len });

        std.log.info("Creating game object", .{});
        return .{
            .state = gameState.titleScreen,
            .mapWidth = mapWidth,
            .mapHeight = mapHeight,
            .map = gameMap,
            .renderer = renderer.Renderer.init(
                @floatFromInt(mapWidth * 16 * 4),
                @floatFromInt(mapHeight * 16 * 4),
                16,
            ),
            .player_1 = player.Player.init(rl.Vector2.init(12, 2), 100),
            .physics = .{ .gravity = 24 },
        };
    }

    pub fn HandleKeyPressed(self: *Game, key: GameKey, deltaTime: f32) void {
        switch (key) {
            GameKey.enter => {
                self.state = gameState.game;
            },
            GameKey.player_1_jump => {
                if (self.player_1.mob.on_ground) {
                    self.player_1.mob.vel.y = -12.0;
                }
            },
            GameKey.player_1_down => {
                self.player_1.input_vector.y = 1.0;
            },
            GameKey.player_1_left => {
                if (self.player_1.mob.on_ground) {
                    self.player_1.input_vector.x = -1.0;
                } else {
                    self.player_1.mob.vel.x -= 10.0 * deltaTime;
                }
                self.player_1.mob.sprite.direction = SpriteDirection.left;
            },
            GameKey.player_1_right => {
                if (self.player_1.mob.on_ground) {
                    self.player_1.input_vector.x = 1.0;
                } else {
                    self.player_1.mob.vel.x += 10.0 * deltaTime;
                }
                self.player_1.mob.sprite.direction = SpriteDirection.right;
            },
            GameKey.player_1_jet => {
                self.player_1.mob.vel.y = -400 * deltaTime;
                self.player_1.mob.flying = true;
            },
        }
    }

    pub fn Refresh(self: *Game) void {
        // reset input vectors
        self.player_1.input_vector = rl.Vector2.zero();
        self.player_1.mob.flying = false;
    }

    pub fn Update(self: *Game, deltaTime: f32) void {
        if (self.state == gameState.titleScreen) {
            return;
        }

        // Update
        //---------------------------------------------------------------------
        self.player_1.input_vector = self.player_1.input_vector.normalize();
        if (self.player_1.input_vector.length() > 0.0) {
            self.player_1.mob.vel = self.player_1.mob.vel.add(self.player_1.input_vector.multiply(.{
                .x = 25.0 * deltaTime,
                .y = 25.0 * deltaTime,
            }));
        } else {
            // apply friction when santa is on ground.
            if (self.player_1.mob.on_ground) {
                self.player_1.mob.vel = self.player_1.mob.vel.moveTowards(rl.Vector2.zero(), 20.0 * deltaTime);
            }
        }

        self.physics.moveAndCollide(&self.player_1.mob, deltaTime, self.map);
        self.player_1.mob.updateSprite(deltaTime);
    }

    pub fn Render(self: *Game) !void {
        switch (self.state) {
            gameState.titleScreen => {
                try self.renderer.drawTitleScreen();
            },
            gameState.game => {
                self.renderer.beginDraw();
                defer self.renderer.endDraw();

                try self.renderer.drawGameScreen(self.map);

                self.renderer.drawMob(&self.player_1.mob);
            },
        }
    }

    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        self.map.deinit(allocator);
        allocator.destroy(self.map);
    }
};
