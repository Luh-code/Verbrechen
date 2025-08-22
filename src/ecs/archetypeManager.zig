const std = @import("std");
const archetype = @import("archetype.zig");

pub fn ArchetypeManager(componentCount: usize) type {
    const SignatureType =
        if (componentCount <= 8) u8 else if (componentCount <= 16) u16 else if (componentCount <= 32) u32 else if (componentCount <= 64) u64 else std.bit_set.StaticBitSet(componentCount);
    const Archetype = archetype.Archetype(SignatureType, componentCount);

    return struct {
        const Self = @This();

        allocator: *const std.mem.Allocator,
        archetypeMap: std.hash_map.AutoHashMap(SignatureType, *Archetype),

        pub fn init(allocator: *const std.mem.Allocator) !*Self {
            const new = try allocator.create(Self);
            new.* = .{ .allocator = allocator, .archetypeMap = std.hash_map.AutoHashMap(SignatureType, *Archetype).init(allocator.*) };

            return new;
        }

        pub fn deinit(self: *Self) void {
            // Destroy archetypes
            var it = self.archetypeMap.valueIterator();
            while (it.next()) |v| {
                v.*.deinit();
            }

            // Destroy archetypeMap
            self.archetypeMap.deinit();

            // Destroy rest
            self.allocator.destroy(self);
        }

        // Get an archetype
        // If it doesn't exist it's created first
        pub fn getArchetype(self: *Self, signature: SignatureType) !*const Archetype {
            const a = self.archetypeMap.get(signature);
            if (a) |val| {
                return val;
            }

            try self.archetypeMap.put(signature, Archetype.init(self.allocator, signature, self) catch |err| {
                return err;
            });
            return self.archetypeMap.get(signature).?;
        }
    };
}
