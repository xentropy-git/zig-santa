const rl = @import("raylib");
const sprite = @import("../sprite.zig");
const AiType = @import("aitype.zig").AiType;

pub const Mob = struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    acc: rl.Vector2,
    max_speed: f32,
    on_ground: bool,
    sprite: sprite.Sprite,
    flying: bool,
    name: []const u8,
    ai_type: AiType,

    pub fn init(
        pos: rl.Vector2,
        max_speed: f32,
        mob_sprite: sprite.Sprite,
        name: []const u8,
        ai_type: AiType,
    ) Mob {
        return Mob{
            .pos = pos,
            .vel = rl.Vector2.zero(),
            .acc = rl.Vector2.zero(),
            .max_speed = max_speed,
            .on_ground = false,
            .sprite = mob_sprite,
            .flying = false,
            .name = name,
            .ai_type = ai_type,
        };
    }

    pub fn updateSprite(self: *Mob, deltaTime: f32) void {
        if (self.vel.x != 0.0 and self.on_ground) {
            self.sprite.setState(sprite.SpriteState.walk);
        } else {
            if (self.flying) {
                self.sprite.setState(sprite.SpriteState.jet);
            } else if (self.vel.y < 0.0) {
                self.sprite.setState(sprite.SpriteState.jump);
            } else if (self.vel.y > 0.0) {
                self.sprite.setState(sprite.SpriteState.fall);
            } else {
                self.sprite.setState(sprite.SpriteState.idle);
            }
        }
        self.sprite.update(deltaTime);
    }
};
