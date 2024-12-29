const sprite = @import("../sprite.zig");

const spriteTiles: [1]sprite.SpriteTile = .{
    .{ .x = 0, .y = 4 },
};

const spriteWalkTiles: [4]sprite.SpriteTile = .{
    .{ .x = 0, .y = 4 },
    .{ .x = 1, .y = 4 },
    .{ .x = 2, .y = 4 },
    .{ .x = 3, .y = 4 },
};

const jumpTiles: [1]sprite.SpriteTile = .{
    .{ .x = 4, .y = 4 },
};

const fallTiles: [1]sprite.SpriteTile = .{
    .{ .x = 5, .y = 4 },
};

const jetTiles: [2]sprite.SpriteTile = .{
    .{ .x = 0, .y = 5 },
    .{ .x = 1, .y = 5 },
};

pub const specs: [5]sprite.SpriteSpec = .{
    .{
        .state = sprite.SpriteState.idle,
        .maxFrames = 1,
        .repeat = true,
        .fps = 1.0,
        .frames = &spriteTiles,
    },
    .{
        .state = sprite.SpriteState.walk,
        .maxFrames = 4,
        .repeat = true,
        .fps = 4.0,
        .frames = &spriteWalkTiles,
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
    .{
        .state = sprite.SpriteState.jet,
        .maxFrames = 2,
        .repeat = true,
        .fps = 4.0,
        .frames = &jetTiles,
    },
};
