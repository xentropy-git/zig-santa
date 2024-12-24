const std = @import("std");
const rl = @import("raylib");
const tile = @import("tile.zig");
const map = @import("map.zig");
const mob = @import("mob.zig");
const sprite = @import("sprite.zig");
const Vect2 = @import("vect2.zig").Vect2;
const ZeroVect2 = @import("vect2.zig").ZeroVect2;

const tileSize = 16;
const scaleFactor = 4;
const mapWidth = 20;
const mapHeight = 15;

const screenWidth = tileSize * scaleFactor * mapWidth;
const screenHeight = tileSize * scaleFactor * mapHeight;

fn drawMap(
    data: *map.MapData,
    texture: rl.Texture,
    cameraX: f32,
    cameraY: f32,
) !void {
    const floorTileRect = rl.Rectangle{
        .x = 6 * 16,
        .y = 0,
        .width = tileSize,
        .height = tileSize,
    };
    const drawSize = 16 * 4;
    const camera = rl.Rectangle{
        .x = cameraX,
        .y = cameraY,
        .width = screenWidth,
        .height = screenHeight,
    };

    for (0..data.height) |y| {
        for (0..data.width) |x| {
            const pos = &data.data[x][y];
            const pixelX: f32 = @floatFromInt(x * drawSize);
            const pixelY: f32 = @floatFromInt(y * drawSize);
            const destRect = rl.Rectangle{
                .x = pixelX,
                .y = pixelY,
                .width = drawSize,
                .height = drawSize,
            };

            switch (pos.tyleType) {
                tile.TyleType.empty => {},
                tile.TyleType.wall => {
                    const srcRect = data.joinFlagToRect(
                        @intCast(x),
                        @intCast(y),
                    );
                    rl.drawTexturePro(
                        texture,
                        srcRect,
                        destRect,
                        .{ .x = 0, .y = 0 },
                        0.0,
                        rl.Color.white,
                    );
                },
                tile.TyleType.floor => {
                    rl.drawTexturePro(
                        texture,
                        floorTileRect,
                        destRect,
                        .{ .x = 0, .y = 0 },
                        0.0,
                        rl.Color.white,
                    );
                },
            }
        }

        // draw camera
        rl.drawRectangleLinesEx(
            camera,
            1,
            rl.Color.red,
        );
    }
}

pub fn main() anyerror!void {
    // Initialization
    //-------------------------------------------------------------------------

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var mapData = try map.MapData.init(allocator, mapWidth, mapHeight);
    defer mapData.free(allocator);

    for (0..mapHeight) |y| {
        for (0..mapWidth) |x| {
            var pos = &mapData.data[x][y];
            if (x == 0 or x == mapWidth - 1 or y == 0 or y == mapHeight - 1) {
                pos.tyleType = tile.TyleType.wall;
            } else {
                pos.tyleType = tile.TyleType.floor;
            }
            pos.x = x;
            pos.y = y;
        }
    }

    const cameraX: f32 = 0.0;
    const cameraY: f32 = 0.0;

    rl.initWindow(
        screenWidth,
        screenHeight,
        "raylib-zig [core] example - basic window",
    );

    defer rl.closeWindow(); // Close window and OpenGL context

    // load textures
    const santaSprites = rl.loadTexture("resources/santa.png");

    var santaMob: mob.Mob = mob.Mob.init(Vect2.init(12, 2), 100.0);
    santaMob.acc = Vect2.init(0.0, 24);

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

    // make spritesheet
    const santaSpec: [5]sprite.SpriteSpec = .{
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

    var santaSprite = sprite.Sprite.init(
        sprite.SpriteState.idle,
        sprite.SpriteDirection.right,
        0,
        &santaSpec,
        santaSprites,
    );

    //-------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //---------------------------------------------------------------------
        // TODO: Update your variables here
        //---------------------------------------------------------------------
        //
        const deltaTime = rl.getFrameTime();

        // on mouse press
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            const mousePos = rl.getMousePosition();
            const f_x: f32 = mousePos.x / (tileSize * scaleFactor);
            const f_y: f32 = mousePos.y / (tileSize * scaleFactor);
            const x: u32 = @intFromFloat(f_x);
            const y: u32 = @intFromFloat(f_y);
            if (x >= 0 and x < mapWidth and y >= 0 and y < mapHeight) {
                var pos = &mapData.data[x][y];
                if (pos.tyleType == tile.TyleType.floor) {
                    pos.tyleType = tile.TyleType.wall;
                } else {
                    pos.tyleType = tile.TyleType.floor;
                }
            }
        }

        var flying = false;
        var inputVector = Vect2.init(0.0, 0.0);
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            if (santaMob.onGround) {
                santaMob.vel.y = -12.0;
            }
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            inputVector.y = 1.0;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
            if (santaMob.onGround) {
                inputVector.x = -1.0;
            } else santaMob.vel.x -= 10.0 * deltaTime;

            santaSprite.direction = sprite.SpriteDirection.left;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
            if (santaMob.onGround) {
                inputVector.x = 1.0;
            } else santaMob.vel.x += 10.0 * deltaTime;

            santaSprite.direction = sprite.SpriteDirection.right;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_space)) {
            santaMob.vel.y = -4.0;
            flying = true;
        }
        inputVector = inputVector.normalized();
        if (inputVector.magnitude() > 0.0) {
            santaMob.vel = santaMob.vel.add(inputVector.mul(25.0 * deltaTime));
        } else {
            // apply friction when santa is on ground.
            if (santaMob.onGround) {
                santaMob.vel = santaMob.vel.moveTowards(ZeroVect2, 20.0 * deltaTime);
            }
        }

        std.debug.print("santaMob.vel: {d} {d}\n", .{ santaMob.vel.x, santaMob.vel.y });
        std.debug.print("santaMob.pos: {d} {d}\n", .{ santaMob.pos.x, santaMob.pos.y });
        std.debug.print("santaMob.acc: {d} {d}\n", .{ santaMob.acc.x, santaMob.acc.y });
        std.debug.print("santaMob.onGround: {?}\n", .{santaMob.onGround});
        santaMob.moveAndCollide(deltaTime, &mapData);

        // Draw
        //---------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        const bgColor = rl.Color.init(18, 18, 20, 255);

        rl.clearBackground(bgColor);

        try drawMap(&mapData, santaSprites, cameraX, cameraY);

        // draw santa
        if (santaMob.vel.x != 0.0 and santaMob.onGround) {
            santaSprite.setState(sprite.SpriteState.walk);
        } else {
            if (flying) {
                santaSprite.setState(sprite.SpriteState.jet);
            } else if (santaMob.vel.y < 0.0) {
                santaSprite.setState(sprite.SpriteState.jump);
            } else if (santaMob.vel.y > 0.0) {
                santaSprite.setState(sprite.SpriteState.fall);
            } else {
                santaSprite.setState(sprite.SpriteState.idle);
            }
        }
        santaSprite.update(deltaTime);
        santaSprite.draw(santaMob.pos);
        //---------------------------------------------------------------------
    }
}
