const std = @import("std");
const c = @import("c_include.zig").c;

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
    
    const Entity_Type = comptime @import("ecs.zig").generateEntityType(ECS_Component_Types.len);
    var t_entity: Entity_Type = .{};
    t_entity.components_set.set(0);


    const ECS_Component_Struct_Type = comptime @import("ecs.zig").GenerateComponentStructType(&ECS_Component_Types);
    const ECS_Type = comptime @import("ecs.zig").GenerateECSType(Entity_Type, ECS_Component_Struct_Type);

    var ecs: ECS_Type = @import("ecs.zig").initECS(ECS_Type, Entity_Type, &ECS_Component_Types, std.heap.page_allocator);
    var t_u32_component: u32 = 3;
    try ecs.components.component_u32.put(0, &t_u32_component);
    
    const e0 = try ecs.addEntity();
    std.debug.print("Created new Entity with ID {d}\n", .{e0});

    const e1 = try ecs.addEntity();
    std.debug.print("Created new Entity with ID {d}\n", .{e1});

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

        _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 60, 255);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
