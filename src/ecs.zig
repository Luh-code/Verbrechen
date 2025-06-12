const std = @import("std");
const c = @import("c_include.zig").c;

const ArrayList = std.ArrayList;

pub const CustomComponent = struct {
    custom_type: type,
    custom: *anyopaque,
};


// TODO: Implement a bitset for Components associated with Entities
pub fn generateEntityType(comptime count: usize) type {
    return struct {
        components_set: std.bit_set.StaticBitSet(count) = std.bit_set.StaticBitSet(count).initEmpty()
    };
}

pub fn GenerateComponentStructType(comptime Components: []const type) type {
    const Base_Struct = struct {
        custom_component: std.AutoHashMap(u32, *CustomComponent),
    };
    const fixed_fields: []const std.builtin.Type.StructField = @typeInfo(Base_Struct).@"struct".fields;

    var struct_fields: [fixed_fields.len+Components.len]std.builtin.Type.StructField = undefined;

    std.mem.copyForwards(std.builtin.Type.StructField, struct_fields[0..fixed_fields.len], fixed_fields);
    for (struct_fields[fixed_fields.len..], Components) |*struct_field, t| {
        struct_field.* = .{
            .name = "component_"++@typeName(t),
            .type = std.AutoHashMap(u32, *t),
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = @alignOf(std.AutoHashMap(u32, *t)),
        };
    }

    return @Type(.{ .@"struct" = .{
        .layout = .auto,
        .fields = &struct_fields,
        .decls = &.{},
        .is_tuple = false,
    }});
}

pub fn GenerateECSType(comptime Entity_Type: type, comptime Component_Struct_Type: type) type {
    const Internal_Data_Type = struct {
        next_entity: u32 = 0,
    };

    return struct {
        internal_data: Internal_Data_Type = .{ .next_entity = 0 },
        entities: std.AutoHashMap(u32, *Entity_Type),
        components: Component_Struct_Type,
        
        const Self = @This();

        pub fn addEntity(self: *Self) !u32 {
            var entity: Entity_Type = .{};
            try self.entities.put(self.internal_data.next_entity, &entity);
            self.internal_data.next_entity+=1;
            return self.internal_data.next_entity-1;
        }
    };
}

pub fn initComponentStruct(comptime ECS_Component_Struct_Type: type, comptime Components: []const type, allocator: std.mem.Allocator) ECS_Component_Struct_Type {
    var comp_struct: ECS_Component_Struct_Type = undefined;
    @field(comp_struct, "custom_component") = std.AutoHashMap(u32, *CustomComponent).init(allocator);
    inline for (Components) |comp| {
        @field(comp_struct, "component_"++@typeName(comp)) = std.AutoHashMap(u32, *comp).init(allocator);
    }


    return comp_struct;
}

pub fn initECS(comptime ECS_Type: type, comptime Entitiy_Type: type, comptime Components: []const type, allocator: std.mem.Allocator) ECS_Type {
    const temp: ECS_Type = undefined;
    return .{
        .entities = std.AutoHashMap(u32, *Entitiy_Type).init(allocator),
        .components = initComponentStruct(@TypeOf(temp.components), Components, allocator),
    };

}
