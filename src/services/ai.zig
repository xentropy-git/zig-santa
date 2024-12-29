const Mob = @import("../models/mob.zig").Mob;
const Player = @import("../models/player.zig").Player;
const AiType = @import("../models/aitype.zig").AiType;

pub fn updateMob(mob: *Mob, player: *Player, deltaTime: f32) void {
    switch (mob.ai_type) {
        AiType.None => {},
        AiType.Basic => updateBasicAi(mob, player, deltaTime),
        AiType.Jumper => updateJumperAi(mob, player, deltaTime),
    }
}

pub fn updateBasicAi(mob: *Mob, player: *Player, deltaTime: f32) void {
    if (mob.on_ground) {
        if (player.mob.pos.x < mob.pos.x) {
            mob.acc.x = -mob.max_speed * deltaTime;
        } else {
            mob.acc.x = mob.max_speed * deltaTime;
        }
    }
}

pub fn updateJumperAi(mob: *Mob, player: *Player, deltaTime: f32) void {
    if (mob.on_ground) {
        mob.vel.y = -12.0;
        if (player.mob.pos.x < mob.pos.x) {
            mob.acc.x = -mob.max_speed * deltaTime;
        } else {
            mob.acc.x = mob.max_speed * deltaTime;
        }
    } else {
        // us air drifting to guide motion
        if (player.mob.pos.x < mob.pos.x) {
            mob.acc.x = -mob.max_speed * deltaTime;
        } else {
            mob.acc.x = mob.max_speed * deltaTime;
        }
    }
}
