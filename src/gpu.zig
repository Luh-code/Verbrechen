const std = @import("std");

const c = @import("c_include.zig").c;

pub const GPU = struct {
    debug: bool,
    gpuDevice: ?*c.SDL_GPUDevice = null
};

pub fn setupGPU(gpu: *GPU, window: *c.SDL_Window) !void {
    _ = window;
    gpu.gpuDevice = c.SDL_CreateGPUDevice(c.SDL_GPU_SHADERFORMAT_SPIRV, gpu.debug, null);
    if (gpu.gpuDevice == null) {
        std.debug.panic("SDL_CreateGPUDevice() Error: {s}\n", .{c.SDL_GetError()});
    }
}
