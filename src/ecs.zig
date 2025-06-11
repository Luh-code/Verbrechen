const std = @import("std");
const c = @import("c_include.zig").c;

const ArrayList = std.ArrayList;

pub fn generateECS(comptime Components: []const type) type {
    var struct_fields: [Components.len]std.builtin.Type.StructField = undefined;

    for (&struct_fields, Components) |*struct_field, t| {
        struct_field.* = .{
            .name = "component_"++@typeName(t),
            .type = std.AutoHashMap(u32, t),
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = @alignOf(std.AutoHashMap(u32, t)),
        };
    }

    return @Type(.{ .@"struct" = .{
        .layout = .auto,
        .fields = &struct_fields,
        .decls = &.{},
        .is_tuple = false,
    }});

    //return struct {
    //    comptime { inline for (Components,) |ComponentType,|
    //        pub var @field(this, "component_" ++ @typeName(ComponentType)): std.AutoHashMap(u32, ComponentType);
    //    }
    //    pub const CustomComponent = struct {
    //        entity_id: u32,
    //        custom_type: type,
    //        custom: *anyopaque,
    //    };

    //    pub const Entity = struct {
    //        id: u32,
    //        //components: ArrayList(Component)
    //    };
    //
    //};
}

