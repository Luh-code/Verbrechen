const std = @import("std");
const c = @import("c_include.zig").c;

const ArrayList = std.ArrayList;

pub const CustomComponent = struct {
    custom_type: type,
    custom: *anyopaque,
};

// TODO: Implement a bitset for Components associated with Entities
pub const Entity = struct {

};

pub fn generateECS(comptime Components: []const type) type {
    const base_struct = struct {
        custom_component: std.AutoHashMap(u32, CustomComponent),
    };
    const fixed_fields: []const std.builtin.Type.StructField = @typeInfo(base_struct).@"struct".fields;
    //const fixed_decls: []const std.builtin.Type.Declaration = @typeInfo(base_struct).@"struct".decls;
    //@compileLog(fixed_fields);

    var struct_fields: [fixed_fields.len+Components.len]std.builtin.Type.StructField = undefined;
    //var field_decls: [fixed_decls.len]std.builtin.Type.Declaration = undefined;

    std.mem.copyForwards(std.builtin.Type.StructField, struct_fields[0..fixed_fields.len], fixed_fields);
    //std.mem.copyForwards(std.builtin.Type.Declaration, field_decls[0..fixed_decls.len], fixed_decls);
    for (struct_fields[fixed_fields.len..], Components) |*struct_field, t| {
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
}

pub fn initECS(comptime ECS_Type: type, Components: []const type, allocator: std.mem.Allocator) ECS_Type {
    var ecs: ECS_Type = undefined;
    @field(ecs, "custom_component") = std.AutoHashMap(u32, CustomComponent).init(allocator);
    inline for (Components) |comp| {
        @field(ecs, "component_"++@typeName(comp)) = std.AutoHashMap(u32, comp).init(allocator);
    }


    return ecs;
}

