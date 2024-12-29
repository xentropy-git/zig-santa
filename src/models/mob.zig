const rl = @import("raylib");
const sprite = @import("../sprite.zig");

pub const Mob = struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    acc: rl.Vector2,
    max_speed: f32,
    on_ground: bool,
    sprite: sprite.Sprite,
    flying: bool,

    pub fn init(
        pos: rl.Vector2,
        max_speed: f32,
        mob_sprite: sprite.Sprite,
    ) Mob {
        return Mob{
            .pos = pos,
            .vel = rl.Vector2.zero(),
            .acc = rl.Vector2.zero(),
            .max_speed = max_speed,
            .on_ground = false,
            .sprite = mob_sprite,
            .flying = false,
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
