const std = @import("std");
const gameService = @import("../services/game.zig");
const TileType = @import("../models/tile.zig").TileType;

pub const FeatureType = enum {
    None,
    Jumper,
    Crawler,
    Player,
};

pub const Tile = struct {
    tile_type: TileType,
    feature_type: FeatureType,
    x: u32,
    y: u32,
};

pub const Map = struct {
    data: [][]Tile,
    width: u32,
    height: u32,

    pub fn writeJson(self: *Map, allocator: std.mem.Allocator) ![]u8 {
        const j = std.json.stringifyAlloc(allocator, self, .{});
        return j;
    }

    pub fn loadJsonToGame(allocator: std.mem.Allocator, j: []u8, game: *gameService.Game) !void {
        const map = try std.json.parseFromSlice(Map, allocator, j, .{});
        std.log.info("Map from json: {d}x{d}", .{ map.value.width, map.value.height });
        std.log.info("Array size: {d}x{d}", .{ map.value.data.len, map.value.data[0].len });
        defer map.deinit();

        const m = map.value;

        for (0..m.height) |y| {
            for (0..m.width) |x| {
                game.map.data[x][y].tile_type = m.data[x][y].tile_type;
            }
        }
    }

    pub fn init(allocator: std.mem.Allocator, game: *gameService.Game) !Map {
        var map: [][]Tile = try allocator.alloc([]Tile, game.mapWidth);
        for (0..game.mapWidth) |y| {
            map[y] = try allocator.alloc(Tile, game.mapHeight);
            for (0..game.mapHeight) |x| {
                map[y][x] = Tile{
                    .tile_type = game.map.data[y][x].tile_type,
                    .feature_type = FeatureType.None,
                    .x = @intCast(x),
                    .y = @intCast(y),
                };
            }
        }

        // loop over npcs and set feature type
        for (game.npcs.items) |npc| {
            const x: u32 = @intFromFloat(npc.pos.x);
            const y: u32 = @intFromFloat(npc.pos.y);

            if (std.mem.eql(u8, npc.name, "player")) {
                map[y][x].feature_type = FeatureType.Jumper;
            } else if (std.mem.eql(u8, npc.name, "crawler")) {
                map[y][x].feature_type = FeatureType.Crawler;
            }
        }

        return Map{ .width = game.mapWidth, .height = game.mapHeight, .data = map };
    }

    pub fn deinit(self: *Map, allocator: std.mem.Allocator) void {
        for (0..self.width) |y| {
            allocator.free(self.data[y]);
        }
        allocator.free(self.data);
    }
};