pub const TileType = enum {
    empty,
    wall,
    floor,
};

pub const Tile = struct {
    tile_type: TileType,
    x: u64,
    y: u64,
};
