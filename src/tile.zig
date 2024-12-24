pub const TyleType = enum {
    empty,
    wall,
    floor,
};

pub const Tile = struct {
    tyleType: TyleType,
    x: u64,
    y: u64,
};
