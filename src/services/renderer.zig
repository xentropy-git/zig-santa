const std = @import("std");
const rl = @import("raylib");
const Map = @import("../models/map.zig").Map;
const TileType = @import("../models/tile.zig").TileType;
const Mob = @import("../models/mob.zig").Mob;
const SpriteDirection = @import("../sprite.zig").SpriteDirection;

pub const Renderer = struct {
    screenWidth: f32,
    screenHeight: f32,
    tileSize: f32,
    drawSize: f32,
    titleTexture: ?*const rl.Texture2D,
    gameTexture: ?*const rl.Texture2D,

    pub fn init(
        screenWidth: f32,
        screenHeight: f32,
        tileSize: f32,
    ) Renderer {
        std.log.info("Initializing renderer", .{});
        return .{
            .screenWidth = screenWidth,
            .screenHeight = screenHeight,
            .tileSize = tileSize,
            .drawSize = tileSize * 4,
            .titleTexture = null,
            .gameTexture = null,
        };
    }

    pub fn loadTextures(
        self: *Renderer,
        titleTexture: *const rl.Texture2D,
        gameTexture: *const rl.Texture2D,
    ) void {
        self.titleTexture = titleTexture;
        self.gameTexture = gameTexture;
    }

    pub fn drawTitleScreen(self: *Renderer) !void {
        if (self.titleTexture) |texture| {
            rl.clearBackground(rl.Color.white);
            rl.drawTexturePro(
                texture.*,
                rl.Rectangle{
                    .x = 0,
                    .y = 0,
                    .width = 800,
                    .height = 600,
                },
                rl.Rectangle{
                    .x = 0,
                    .y = 0,
                    .width = self.screenWidth,
                    .height = self.screenHeight,
                },
                rl.Vector2.init(0, 0),
                0.0,
                rl.Color.white,
            );
        }
    }

    pub fn drawMob(self: *Renderer, mob: *Mob) void {
        const destRect = rl.Rectangle{
            .x = mob.pos.x * 16 * 4,
            .y = mob.pos.y * 16 * 4,
            .width = 16 * 4,
            .height = 16 * 4,
        };

        var srcRect = mob.sprite.getSrcRect();
        // flip texture if direction is left
        if (mob.sprite.direction == SpriteDirection.left) {
            srcRect.width *= -1;
        }

        if (self.gameTexture) |texture| {
            rl.drawTexturePro(
                texture.*,
                srcRect,
                destRect,
                .{ .x = 0, .y = 0 },
                0.0,
                rl.Color.white,
            );
        }
    }

    pub fn beginDraw(self: *Renderer) void {
        _ = self;
        rl.beginDrawing();
    }

    pub fn endDraw(self: *Renderer) void {
        _ = self;
        rl.endDrawing();
    }
    pub fn drawGameScreen(
        self: *Renderer,
        data: *Map,
    ) !void {
        const bgColor = rl.Color.init(18, 18, 20, 255);

        rl.clearBackground(bgColor);

        if (self.gameTexture) |texture| {
            for (0..data.height) |y| {
                for (0..data.width) |x| {
                    var pixelX: f32 = @floatFromInt(x);
                    var pixelY: f32 = @floatFromInt(y);
                    const pos = &data.data[x][y];
                    pixelX *= self.drawSize;
                    pixelY *= self.drawSize;
                    const destRect = rl.Rectangle{
                        .x = pixelX,
                        .y = pixelY,
                        .width = self.drawSize,
                        .height = self.drawSize,
                    };

                    switch (pos.tile_type) {
                        TileType.empty => {},
                        TileType.wall => {
                            const srcRect = data.joinFlagToRect(
                                @intCast(x),
                                @intCast(y),
                            );
                            rl.drawTexturePro(
                                texture.*,
                                srcRect,
                                destRect,
                                .{ .x = 0, .y = 0 },
                                0.0,
                                rl.Color.white,
                            );
                        },
                        TileType.floor => {
                            // noop
                        },
                        TileType.tree_top => {
                            const srcRect = rl.Rectangle{
                                .x = 0,
                                .y = 11 * 16,
                                .width = 16,
                                .height = 16,
                            };
                            rl.drawTexturePro(
                                texture.*,
                                srcRect,
                                destRect,
                                .{ .x = 0, .y = 0 },
                                0.0,
                                rl.Color.white,
                            );
                        },
                        TileType.tree_bottom => {
                            const srcRect = rl.Rectangle{
                                .x = 0,
                                .y = 12 * 16,
                                .width = 16,
                                .height = 16,
                            };
                            rl.drawTexturePro(
                                texture.*,
                                srcRect,
                                destRect,
                                .{ .x = 0, .y = 0 },
                                0.0,
                                rl.Color.white,
                            );
                        },
                        TileType.snowman => {
                            const srcRect = rl.Rectangle{
                                .x = 0,
                                .y = 3 * 16,
                                .width = 16,
                                .height = 16,
                            };
                            rl.drawTexturePro(
                                texture.*,
                                srcRect,
                                destRect,
                                .{ .x = 0, .y = 0 },
                                0.0,
                                rl.Color.white,
                            );
                        },
                    }
                }
            }
        }
    }
};
