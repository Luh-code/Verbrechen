const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

var window: ?*c.SDL_Window = null;
var renderer: ?*c.SDL_Renderer = null;
pub fn main() !void {
    std.debug.print("Setting up SDL\n", .{});    

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)){
        std.debug.panic("SDL_Init() Error: {s}\n", .{c.SDL_GetError()});
    }

    window = c.SDL_CreateWindow("Zylo", 1920, 1080, c.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        std.debug.panic("SDL_CreateWindow() Error: {s}\n", .{c.SDL_GetError()});
    }

    std.debug.print("SDL set up finished\n", .{});

    renderer = c.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.debug.panic("SDL_CreateRenderer() Error: {s}\n", .{c.SDL_GetError()});
    }

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

    std.debug.print("Quitting SDL\n", .{});

    c.SDL_DestroyWindow(window);
    c.SDL_Quit();
}
