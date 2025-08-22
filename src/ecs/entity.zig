const std = @import("std");
const Archetype = @import("archetype.zig").Archetype;

pub fn Entity(Signature: type, component_count: usize) type {
    return struct {
        signature: Signature,
        archetype: *const Archetype(Signature, component_count),

        const Self = @This();

        pub fn init() void {
            co        }
    };
}
