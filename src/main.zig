const std = @import("std");
const rl = @import("raylib");
const sprite = @import("sprite.zig");
const gameservice = @import("services/game.zig");
const tile = @import("models/tile.zig");
const mob = @import("models/mob.zig");
const npcfactory = @import("services/npcfactory.zig");
const mapdef = @import("models/mapdef.zig");

const tileSize = 16;
const scaleFactor = 4;
const mapWidth = 20;
const mapHeight = 15;

const screenWidth = tileSize * scaleFactor * mapWidth; // 800
const screenHeight = tileSize * scaleFactor * mapHeight; // 600

pub const PlacementType = enum {
    Wall,
    Jumper,
    Crawler,
};
pub fn main() anyerror!void {
    // Initialization
    //-------------------------------------------------------------------------
    rl.initWindow(
        screenWidth,
        screenHeight,
        "Jetpack Santa",
    );

    rl.setTargetFPS(60); // Set target frames-per-second

    defer rl.closeWindow(); // Close window and OpenGL context

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    std.log.info("Loading images", .{});
    const titleFile = @embedFile("./resources/title.png");
    const gameFile = @embedFile("./resources/santa.png");

    const titleImage = rl.loadImageFromMemory(".png", titleFile);
    const gameImage = rl.loadImageFromMemory(".png", gameFile);

    std.log.info("Loading images", .{});

    const titleTexture = rl.loadTextureFromImage(titleImage);
    const gameTexture = rl.loadTextureFromImage(gameImage);

    std.log.info("Initializing game", .{});
    var game = try gameservice.Game.init(
        allocator,
        mapWidth,
        mapHeight,
    );
    defer game.deinit(allocator);

    std.log.info("Loading textures", .{});
    game.renderer.loadTextures(&titleTexture, &gameTexture);

    try game.AddNpc(
        npcfactory.MakeJumper(5, 5),
    );

    try game.AddNpc(
        npcfactory.MakeCrawler(10, 10),
    );

    var placementType = PlacementType.Wall;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        game.Refresh();

        const deltaTime = rl.getFrameTime();

        if (rl.isKeyPressed(rl.KeyboardKey.key_enter)) {
            game.HandleKeyPressed(gameservice.GameKey.enter, deltaTime);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            game.HandleKeyPressed(gameservice.GameKey.player_1_jump, deltaTime);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            game.HandleKeyPressed(gameservice.GameKey.player_1_down, deltaTime);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
            game.HandleKeyPressed(gameservice.GameKey.player_1_left, deltaTime);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
            game.HandleKeyPressed(gameservice.GameKey.player_1_right, deltaTime);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_space)) {
            game.HandleKeyPressed(gameservice.GameKey.player_1_jet, deltaTime);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_f1)) {
            // Toggle dev mode
            try game.ToggleDevMode();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_f2)) {
            // Save map to file
            var m = try mapdef.Map.init(allocator, &game);
            defer m.deinit(allocator);
            const json = try m.writeJson(allocator);
            defer allocator.free(json);
            const file = try std.fs.cwd().createFile("map.json", .{});
            defer file.close();
            try file.writeAll(json);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_f3)) {
            // Load map from file
            const file = try std.fs.cwd().openFile("map.json", .{});
            defer file.close();
            const json = try file.readToEndAlloc(allocator, 100_000);
            defer allocator.free(json);
            try mapdef.Map.loadJsonToGame(allocator, json, &game);
        }

        if (rl.isGamepadAvailable(0)) {}

        game.Update(deltaTime);
        try game.Render();

        // God mode

        if (rl.isKeyPressed(rl.KeyboardKey.key_one)) {
            placementType = PlacementType.Wall;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_two)) {
            placementType = PlacementType.Jumper;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_three)) {
            placementType = PlacementType.Crawler;
        }
        //// on mouse press
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            const mousePos = rl.getMousePosition();
            const f_x: f32 = mousePos.x / (tileSize * scaleFactor);
            const f_y: f32 = mousePos.y / (tileSize * scaleFactor);
            const x: u32 = @intFromFloat(f_x);
            const y: u32 = @intFromFloat(f_y);
            game.RemoveNpc(f_x, f_y);
            if (x >= 0 and x < mapWidth and y >= 0 and y < mapHeight) {
                if (placementType == PlacementType.Wall) {
                    var pos = &game.map.data[x][y];
                    if (pos.tile_type == tile.TileType.floor) {
                        pos.tile_type = tile.TileType.wall;
                    } else {
                        pos.tile_type = tile.TileType.floor;
                    }
                }
                if (placementType == PlacementType.Jumper) {
                    try game.AddNpc(npcfactory.MakeJumper(@floor(f_x), @floor(f_y)));
                }
                if (placementType == PlacementType.Crawler) {
                    try game.AddNpc(npcfactory.MakeCrawler(@floor(f_x), @floor(f_y)));
                }
            }
        }

        //---------------------------------------------------------------------
    }
}
