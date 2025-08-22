const std = @import("std");
const Archetype = @import("archetype.zig").Archetype;

pub fn EntityManager(Signature: type, component_count: usize) type {
    return struct {
        const Self: @This();
        allocator: *const std.mem.Allocator,
        entity_holder: struct {
            signatures: []Signature,
            archetypes: []Archetype(Signature, component_count),
        },

        fn init() Self {
            const new = 
        }       
    };
}
