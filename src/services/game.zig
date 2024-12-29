const std = @import("std");
const rl = @import("raylib");
const map = @import("../models/map.zig");
const tile = @import("../models/tile.zig");
const renderer = @import("renderer.zig");
const player = @import("../models/player.zig");
const physics = @import("physics.zig");
const Mob = @import("../models/mob.zig").Mob;
const SpriteDirection = @import("../sprite.zig").SpriteDirection;
const ai = @import("ai.zig");

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
    npcs: std.ArrayList(Mob),
    dev_mode: bool = true,

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
            .player_1 = player.Player.init(rl.Vector2.init(12, 2), 100, "player1"),
            .physics = .{ .gravity = 24 },
            .npcs = std.ArrayList(Mob).init(allocator),
            .dev_mode = true,
        };
    }

    pub fn CacheNpcs(self: *Game) !void {
        for (0..self.npcs.items.len) |i| {
            const npc = &self.npcs.items[i];
            npc.start_pos = npc.pos;
        }
    }

    pub fn RestoreNpcs(self: *Game) void {
        for (0..self.npcs.items.len) |i| {
            const npc = &self.npcs.items[i];
            npc.pos = npc.start_pos;
            npc.vel = rl.Vector2.zero();
            npc.acc = rl.Vector2.zero();
        }
    }

    pub fn ToggleDevMode(self: *Game) !void {
        if (self.dev_mode) {
            try self.CacheNpcs();
            self.dev_mode = false;
        } else {
            self.dev_mode = true;
            self.RestoreNpcs();
        }
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

    pub fn AddNpc(self: *Game, mob: Mob) !void {
        try self.npcs.append(mob);
    }

    pub fn RemoveNpc(self: *Game, x: f32, y: f32) void {
        for (0..self.npcs.items.len) |i| {
            const npc = &self.npcs.items[i];
            if (@floor(npc.pos.x) == @floor(x) and @floor(npc.pos.y) == @floor(y)) {
                _ = self.npcs.orderedRemove(i);
                return;
            }
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

        if (self.dev_mode) {
            return;
        }

        for (0..self.npcs.items.len) |i| {
            const npc_ptr = @constCast(&self.npcs.items[i]);
            ai.updateMob(npc_ptr, &self.player_1, deltaTime);
            std.debug.print("NPC: {d} {d}\n", .{ npc_ptr.pos.x, npc_ptr.pos.y });
            self.physics.moveAndCollide(npc_ptr, deltaTime, self.map);

            if (npc_ptr.vel.x < 0.0) {
                npc_ptr.sprite.direction = SpriteDirection.left;
            } else {
                npc_ptr.sprite.direction = SpriteDirection.right;
            }
            npc_ptr.updateSprite(deltaTime);
        }
    }

    pub fn Render(self: *Game) !void {
        self.renderer.beginDraw();
        defer self.renderer.endDraw();
        switch (self.state) {
            gameState.titleScreen => {
                try self.renderer.drawTitleScreen();
            },
            gameState.game => {
                try self.renderer.drawGameScreen(self.map);

                self.renderer.drawMob(&self.player_1.mob);

                for (self.npcs.items) |npc| {
                    // coerce to const pointer
                    self.renderer.drawMob(@constCast(&npc));
                }
            },
        }
    }

    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        self.map.deinit(allocator);
        self.npcs.deinit();
        allocator.destroy(self.map);
    }
};
