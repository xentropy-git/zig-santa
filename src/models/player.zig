const rl = @import("raylib");
const mob = @import("mob.zig");
const sprite = @import("../sprite.zig");
const santa_sprite = @import("../spritedefs/santasprite.zig");
const AiType = @import("aitype.zig").AiType;

pub const Player = struct {
    mob: mob.Mob,
    input_vector: rl.Vector2,
    flying: bool,
    name: []const u8,
    pub fn init(
        pos: rl.Vector2,
        max_speed: f32,
        name: []const u8,
    ) Player {
        return Player{
            .mob = mob.Mob.init(
                pos,
                max_speed,
                sprite.Sprite.init(
                    sprite.SpriteState.idle,
                    sprite.SpriteDirection.right,
                    0,
                    &santa_sprite.specs,
                ),
                name,
                AiType.None,
            ),
            .input_vector = rl.Vector2.zero(),
            .flying = false,
            .name = name,
        };
    }
};
