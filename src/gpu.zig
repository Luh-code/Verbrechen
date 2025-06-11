const std = @import("std");

const c = @import("c_include.zig").c;

pub const GPU = struct {
    debug: bool,
    preferred_driver: ?[]const u8 = null,
    gpuDevice: ?*c.SDL_GPUDevice = null
};

pub fn setupGPU(gpu: *GPU, window: *c.SDL_Window) !void {
    gpu.gpuDevice = c.SDL_CreateGPUDevice(c.SDL_GPU_SHADERFORMAT_SPIRV, gpu.debug, if (gpu.preferred_driver) |str| str.ptr else null);
    if (gpu.gpuDevice == null) {
        std.debug.panic("SDL_CreateGPUDevice() Error: {s}\n", .{c.SDL_GetError()});
    }

    if (!c.SDL_ClaimWindowForGPUDevice(gpu.gpuDevice.?, window)) {
        std.debug.panic("SDL_ClaimWindowForGPUDevice() Error: {s}\n", .{c.SDL_GetError()}); 
    }

    std.debug.print("Set up GPU\n", .{});
}
