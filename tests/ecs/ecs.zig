const std = @import("std");
pub const v = @import("verbrechen");
pub const c = v.c;

pub const expect = std.testing.expect;

// test "archetype creation" {
//     const alloc = std.testing.allocator;

//     const Archetype = v.archetype.Archetype(u32, 2);

//     const a0: *Archetype = try Archetype.init(&alloc, 0);
//     a0.deinit();
// }

test "ArchetypeManager creation" {
    const alloc = std.testing.allocator;

    const ArchetypeManager = v.archetypeManager.ArchetypeManager(3);

    const a_man: *ArchetypeManager = try ArchetypeManager.init(&alloc);
    a_man.deinit();
}

test "ArchetypeManager create archetype" {
    const alloc = std.testing.allocator;

    const ArchetypeManager = v.archetypeManager.ArchetypeManager(3);

    const a_man: *ArchetypeManager = try ArchetypeManager.init(&alloc);
    defer a_man.deinit();

    const a0 = try a_man.getArchetype(0);
    //defer a0.deinit();
    _ = a0;
}

test "ArchetypeManager get archetype" {
    const alloc = std.testing.allocator;

    const ArchetypeManager = v.archetypeManager.ArchetypeManager(3);

    const a_man: *ArchetypeManager = try ArchetypeManager.init(&alloc);
    defer a_man.deinit();

    const a0 = try a_man.getArchetype(0);
    const a1 = try a_man.getArchetype(0);

    try expect(a0 == a1);
}

test "ArchetypeManager create multiple archetypes" {
    const alloc = std.testing.allocator;

    const ArchetypeManager = v.archetypeManager.ArchetypeManager(3);

    const a_man: *ArchetypeManager = try ArchetypeManager.init(&alloc);
    defer a_man.deinit();

    const a0 = try a_man.getArchetype(0);
    const a1 = try a_man.getArchetype(1);

    try expect(a0 != a1);
}

test "control" {
    try expect(1 == 1);
}
