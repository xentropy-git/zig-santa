const sprite = @import("../sprite.zig");

const spriteIdle: [1]sprite.SpriteTile = .{
    .{ .x = 1, .y = 13 },
};

const jumpTiles: [1]sprite.SpriteTile = .{
    .{ .x = 0, .y = 13 },
};

const fallTiles: [1]sprite.SpriteTile = .{
    .{ .x = 0, .y = 13 },
};

pub const specs: [3]sprite.SpriteSpec = .{
    .{
        .state = sprite.SpriteState.idle,
        .maxFrames = 1,
        .repeat = true,
        .fps = 1.0,
        .frames = &spriteIdle,
    },
    .{
        .state = sprite.SpriteState.jump,
        .maxFrames = 1,
        .repeat = false,
        .fps = 1.0,
        .frames = &jumpTiles,
    },
    .{
        .state = sprite.SpriteState.fall,
        .maxFrames = 1,
        .repeat = false,
        .fps = 1.0,
        .frames = &fallTiles,
    },
};
