const std = @import("std");
const ArchetypeManager = @import("archetypeManager.zig").ArchetypeManager;

pub fn Archetype(SignatureType: type, component_count: usize) type {
    return struct {
        const Self = @This();

        signature: SignatureType,
        allocator: *const std.mem.Allocator,
        transitions: [][]?*Archetype(SignatureType, component_count),
        manager: *const ArchetypeManager(component_count),

        pub fn init(allocator: *const std.mem.Allocator, signature: SignatureType, manager: *const ArchetypeManager(component_count)) !*Archetype(SignatureType, component_count) {
            const T = Archetype(SignatureType, component_count);

            // Create new Archetype
            const new = try allocator.create(T);
            new.* = .{
                .signature = signature,
                .allocator = allocator,
                .transitions = try allocator.alloc([]*T, component_count),
                .manager = manager,
            };

            // Populate transitions with null
            for (new.transitions) |*row| {
                row.* = try allocator.alloc(?*T, 2);
                //std.debug.print("allocating row: {}\n", .{row});
                for (row.*) |*cell| {
                    cell.* = null;
                }
            }

            return new;
        }

        pub fn deinit(self: *Self) void {
            // Delete transitions
            for (self.transitions) |*row| {
                self.allocator.free(row.*);
                //std.debug.print("deallocating row: {}\n", .{row});
            }
            self.allocator.free(self.transitions);

            // Destroy rest
            self.allocator.destroy(self);
        }
    };
}
