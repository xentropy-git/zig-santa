const std = @import("std");
const rl = @import("raylib");
const tile = @import("tile.zig");

pub const MapData = struct {
    width: u32,
    height: u32,
    data: [][]tile.Tile,

    pub fn getTile(self: *MapData, x: u32, y: u32) ?*tile.Tile {
        if (x >= self.width or y >= self.height) {
            return null;
        }
        if (x < 0 or y < 0) {
            return null;
        }
        return &self.data[x][y];
    }

    pub fn getJoinFlag(self: *MapData, x: u32, y: u32) i8 {
        if (x >= self.width or y >= self.height) {
            return 0;
        }
        if (x < 0 or y < 0) {
            return 0;
        }

        const tileType = self.data[x][y].tyleType;

        // check surrounding types
        var flags: i8 = 0;
        if (x > 0 and self.data[x - 1][y].tyleType == tileType) {
            flags |= 1;
        }
        if (x < self.width - 1 and self.data[x + 1][y].tyleType == tileType) {
            flags |= 2;
        }
        if (y > 0 and self.data[x][y - 1].tyleType == tileType) {
            flags |= 4;
        }
        if (y < self.height - 1 and self.data[x][y + 1].tyleType == tileType) {
            flags |= 8;
        }

        return flags;
    }

    pub fn joinFlagToRect(self: *MapData, x: u32, y: u32) rl.Rectangle {
        const joinFlag = self.getJoinFlag(x, y);

        return switch (joinFlag) {
            // none
            0 => rl.Rectangle{
                .x = 5 * 16,
                .y = 1 * 16,
                .width = 16,
                .height = 16,
            },
            // left
            1 => rl.Rectangle{
                .x = 3 * 16,
                .y = 1 * 16,
                .width = 16,
                .height = 16,
            },
            // right
            2 => rl.Rectangle{
                .x = 2 * 16,
                .y = 2 * 16,
                .width = 16,
                .height = 16,
            },
            // left-right
            3 => rl.Rectangle{
                .x = 3 * 16,
                .y = 0 * 16,
                .width = 16,
                .height = 16,
            },
            // up
            4 => rl.Rectangle{
                .x = 0 * 16,
                .y = 2 * 16,
                .width = 16,
                .height = 16,
            },
            // left-up
            5 => rl.Rectangle{
                .x = 4 * 16,
                .y = 2 * 16,
                .width = 16,
                .height = 16,
            },
            // right-up
            6 => rl.Rectangle{
                .x = 2 * 16,
                .y = 1 * 16,
                .width = 16,
                .height = 16,
            },
            // left-right-up
            7 => rl.Rectangle{
                .x = 1 * 16,
                .y = 1 * 16,
                .width = 16,
                .height = 16,
            },
            // down,
            8 => rl.Rectangle{
                .x = 1 * 16,
                .y = 2 * 16,
                .width = 16,
                .height = 16,
            },
            // left-down
            9 => rl.Rectangle{
                .x = 4 * 16,
                .y = 0 * 16,
                .width = 16,
                .height = 16,
            },
            // down-right
            10 => rl.Rectangle{
                .x = 2 * 16,
                .y = 0 * 16,
                .width = 16,
                .height = 16,
            },
            // left-right-down
            11 => rl.Rectangle{
                .x = 0 * 16,
                .y = 0 * 16,
                .width = 16,
                .height = 16,
            },
            // up-down
            12 => rl.Rectangle{
                .x = 4 * 16,
                .y = 1 * 16,
                .width = 16,
                .height = 16,
            },
            // left-up-down
            13 => rl.Rectangle{
                .x = 1 * 16,
                .y = 0 * 16,
                .width = 16,
                .height = 16,
            },
            // right-up-down
            14 => rl.Rectangle{
                .x = 0 * 16,
                .y = 1 * 16,
                .width = 16,
                .height = 16,
            },
            // all
            15 => rl.Rectangle{
                .x = 5 * 16,
                .y = 0 * 16,
                .width = 16,
                .height = 16,
            },
            else => rl.Rectangle{
                .x = 0,
                .y = 0,
                .width = 16,
                .height = 16,
            },
        };
    }

    pub fn init(
        allocator: std.mem.Allocator,
        width: u32,
        height: u32,
    ) !MapData {
        var map: [][]tile.Tile = try allocator.alloc([]tile.Tile, width);
        for (0..width) |y| {
            map[y] = try allocator.alloc(tile.Tile, height);
            for (0..height) |x| {
                map[y][x] = tile.Tile{
                    .tyleType = tile.TyleType.empty,
                    .x = 0,
                    .y = 0,
                };
            }
        }

        return MapData{ .width = width, .height = height, .data = map };
    }

    pub fn free(self: *MapData, allocator: std.mem.Allocator) void {
        for (0..self.width) |y| {
            allocator.free(self.data[y]);
        }
        allocator.free(self.data);
    }
};
