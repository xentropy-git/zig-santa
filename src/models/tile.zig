pub const TileType = enum {
    empty,
    wall,
    floor,
    tree_bottom,
    tree_top,
    snowman,
};

pub const Tile = struct {
    tile_type: TileType,
    x: u64,
    y: u64,
};
