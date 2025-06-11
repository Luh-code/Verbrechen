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

    const ECS_type = comptime @import("ecs.zig").generateECS(&[_]type {u32});
    const ecs: ECS_type = .{
        .component_u32 = std.AutoHashMap(u32, u32).init(std.heap.page_allocator),
    };
    _ = ecs;
    
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
