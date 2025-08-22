const std = @import("std");
pub const c = @import("c_include.zig").c;
pub const ecs = @import("ecs.zig");

pub const archetype = @import("ecs/archetype.zig");

const gpu_utils = @import("gpu.zig");

var window: ?*c.SDL_Window = null;
var renderer: ?*c.SDL_Renderer = null;
pub fn main() !void {
    // Set up SDL Window
    std.debug.print("Setting up SDL\n", .{});    

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)){
        std.debug.panic("SDL_Init() Error: {s}\n", .{c.SDL_GetError()});
    }
    defer {
        std.debug.print("Quitting SDL\n", .{});
        c.SDL_Quit();
    }

    window = c.SDL_CreateWindow("Verbrechen", 1920, 1080, c.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        std.debug.panic("SDL_CreateWindow() Error: {s}\n", .{c.SDL_GetError()});
    }
    defer c.SDL_DestroyWindow(window);

    std.debug.print("SDL set up finished\n", .{});

    renderer = c.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.debug.panic("SDL_CreateRenderer() Error: {s}\n", .{c.SDL_GetError()});
    }
    defer c.SDL_DestroyRenderer(renderer);

    // Set up SDL GPU API
    var gpu: gpu_utils.GPU = .{
        .debug = true,
        .preferred_driver = "vulkan",
    };
    try gpu_utils.setupGPU(&gpu, window.?);

    // Set up ECS
    const ECS_Component_Types = [_]type {u32};
    
    const Entity_Type = comptime @import("ecs.zig").generateEntityType(&ECS_Component_Types);
    //var t_entity: Entity_Type = .{};
    //t_entity.components_set.set(0);


    const ECS_Component_Struct_Type = comptime @import("ecs.zig").GenerateComponentStructType(&ECS_Component_Types);
    const ECS_Type = comptime @import("ecs.zig").GenerateECSType(Entity_Type, ECS_Component_Struct_Type, &ECS_Component_Types);

    const SystemType = comptime @import("ecs.zig").GenerateSystem(&ECS_Component_Types);
    var test_system: SystemType = .{
        .callback = struct {
            pub fn f(dt: f32, linked_entities: *std.ArrayList(u32)) void {
                _ = dt;
                std.debug.print("Linked entities: {any}\n", .{linked_entities.items});
            }
        }.f,
        .signature = std.bit_set.StaticBitSet(ECS_Component_Types.len).initEmpty(),
        .linked_entities = std.ArrayList(u32).init(std.heap.page_allocator),
    };
    test_system.signature.set(0);

    var ecs0: ECS_Type = try ECS_Type.init(std.heap.page_allocator, .{
        .on = &[_]*SystemType {&test_system},
    });
    var t_u32_component: u32 = 3;
    try ecs0.components.component_u32.put(0, &t_u32_component);
    
    //const e0 = ecs.addEntity();
    //std.debug.print("Created new Entity with ID {d}\n", .{e0});
    //const e1 = ecs.addEntity();
    //std.debug.print("Created new Entity with ID {d}\n", .{e1});

    //_ = ecs.removeEntity(e0);
    //std.debug.print("Removed Entity with ID {d}\n", .{e0});

    const e2 = ecs0.addEntity();
    //std.debug.print("Created new Entity with ID {d}\n", .{e2});
    const e3 = ecs0.addEntity();
    std.debug.print("Created new Entity with ID {d}\n", .{e3});

    const c0: u32 = 32;
    const c1: u32 = 33;
    ecs0.addComponent(e2, &c1);
    ecs0.addComponent(e3, &c0);
    //ecs.addComponent(e3, &c1);
    //ecs.removeComponent(&c0);
    _ = ecs0.removeEntity(e2);

    // Start main loop
    var running = true;
    var event: c.SDL_Event = undefined;

    std.debug.print("Starting main loop\n", .{});
    while (running) {
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        ecs0.update();

        _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 60, 255);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }

    ecs0.deinit();
}
