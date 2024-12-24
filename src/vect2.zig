const std = @import("std");
pub const Vect2 = struct {
    x: f32,
    y: f32,

    pub fn init(x: f32, y: f32) Vect2 {
        return Vect2{ .x = x, .y = y };
    }

    pub fn add(self: Vect2, other: Vect2) Vect2 {
        return Vect2.init(self.x + other.x, self.y + other.y);
    }

    pub fn sub(self: Vect2, other: Vect2) Vect2 {
        return Vect2.init(self.x - other.x, self.y - other.y);
    }

    pub fn mul(self: Vect2, other: f32) Vect2 {
        return Vect2.init(self.x * other, self.y * other);
    }

    pub fn div(self: Vect2, other: f32) Vect2 {
        return Vect2.init(self.x / other, self.y / other);
    }

    pub fn normalized(self: Vect2) Vect2 {
        const mag = self.magnitude();
        if (mag == 0.0) {
            return Vect2.init(0.0, 0.0);
        }
        return Vect2.init(self.x / mag, self.y / mag);
    }

    pub fn magnitude(self: Vect2) f32 {
        return std.math.sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn moveTowards(self: Vect2, target: Vect2, maxDistanceDelta: f32) Vect2 {
        const delta = target.sub(self);
        const magDelta = delta.magnitude();
        if (magDelta <= maxDistanceDelta) {
            return Vect2.init(target.x, target.y);
        }
        return self.add(target.sub(self).normalized().mul(maxDistanceDelta));
    }
};

pub const ZeroVect2 = Vect2.init(0.0, 0.0);
