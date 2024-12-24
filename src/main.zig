const std = @import("std");
const rl = @import("raylib");
const tile = @import("tile.zig");
const map = @import("map.zig");
const mob = @import("mob.zig");
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
            const joinFlag = data.getJoinFlag(@intCast(x), @intCast(y));

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
                    rl.drawText(
                        rl.textFormat("%02i", .{joinFlag}),
                        @intFromFloat(pixelX + 8),
                        @intFromFloat(pixelY + 8),
                        8,
                        rl.Color.black,
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
    const dungeon = rl.loadTexture("resources/santa.png");

    const santaSrcRect = rl.Rectangle{
        .x = 0,
        .y = 4 * 16,
        .width = 16,
        .height = 16,
    };

    var santaMob: mob.Mob = mob.Mob.init(Vect2.init(12, 2), 100.0);
    santaMob.acc = Vect2.init(0.0, 24);

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
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

        var inputVector = Vect2.init(0.0, 0.0);
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            if (santaMob.onGround) {
                santaMob.vel.y = -12.0;
            }
            //inputVector.y = -1.0;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            inputVector.y = 1.0;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
            if (santaMob.onGround) {
                inputVector.x = -1.0;
            } else santaMob.vel.x -= 10.0 * deltaTime;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
            if (santaMob.onGround) {
                inputVector.x = 1.0;
            } else santaMob.vel.x += 10.0 * deltaTime;
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

        try drawMap(&mapData, dungeon, cameraX, cameraY);

        // draw santa
        const santaDestRect = rl.Rectangle{
            .x = santaMob.pos.x * 16 * 4,
            .y = santaMob.pos.y * 16 * 4,
            .width = 16 * 4,
            .height = 16 * 4,
        };

        rl.drawTexturePro(
            dungeon,
            santaSrcRect,
            santaDestRect,
            .{ .x = 0, .y = 0 },
            0.0,
            rl.Color.white,
        );
        //---------------------------------------------------------------------
    }
}
