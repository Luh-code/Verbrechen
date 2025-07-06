const std = @import("std");
const v = @import("verbrechen");
const c = v.c;
const ecs = v.ecs;

const expect = std.testing.expect;

test "create ECS" {
    const ECS_Component_Types = [_]type {u32};

    const EntityType = comptime ecs.generateEntityType(&ECS_Component_Types);

    const ECS_Component_Struct_Type = comptime ecs.GenerateComponentStructType(&ECS_Component_Types);
    const ECS_Type = comptime ecs.GenerateECSType(EntityType, ECS_Component_Struct_Type, &ECS_Component_Types);
   
    const SystemType = ecs.GenerateSystem(&ECS_Component_Types);
    var ecs0: ECS_Type = try ECS_Type.init(std.testing.allocator, .{
        .on = &[_]*SystemType {},
    });

    ecs0.deinit();
}
