const sprite = @import("../sprite.zig");

const idleSprite: [1]sprite.SpriteTile = .{
    .{ .x = 0, .y = 14 },
};

const spriteWalkTiles: [4]sprite.SpriteTile = .{
    .{ .x = 0, .y = 14 },
    .{ .x = 1, .y = 14 },
    .{ .x = 2, .y = 14 },
    .{ .x = 3, .y = 14 },
};

pub const specs: [2]sprite.SpriteSpec = .{
    .{
        .state = sprite.SpriteState.idle,
        .maxFrames = 1,
        .repeat = true,
        .fps = 1.0,
        .frames = &idleSprite,
    },
    .{
        .state = sprite.SpriteState.walk,
        .maxFrames = 4,
        .repeat = true,
        .fps = 4.0,
        .frames = &spriteWalkTiles,
    },
};
