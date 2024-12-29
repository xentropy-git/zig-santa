const rl = @import("raylib");
const mob = @import("../models/mob.zig");
const sprite = @import("../sprite.zig");
const jumper_sprite = @import("../spritedefs/jumpersprite.zig");
const baby_sprite = @import("../spritedefs/babysprite.zig");
const AiType = @import("../models/aitype.zig").AiType;

pub fn MakeJumper(x: f32, y: f32) mob.Mob {
    return mob.Mob.init(
        rl.Vector2.init(x, y),
        100.0,
        sprite.Sprite.init(
            sprite.SpriteState.idle,
            sprite.SpriteDirection.right,
            0,
            &jumper_sprite.specs,
        ),
        "jumper",
        AiType.Jumper,
    );
}

pub fn MakeCrawler(x: f32, y: f32) mob.Mob {
    return mob.Mob.init(
        rl.Vector2.init(x, y),
        45.0,
        sprite.Sprite.init(
            sprite.SpriteState.idle,
            sprite.SpriteDirection.right,
            0,
            &baby_sprite.specs,
        ),
        "crawler",
        AiType.Basic,
    );
}
