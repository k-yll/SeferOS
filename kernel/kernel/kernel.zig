pub fn kernel_main(framebufferRequest: limine.Framebuffer.Request) noreturn {
    // Initialize serial with proper error handling
    const debug = serial.getSerial(null) catch {
        @panic("Serial initialization failed");
    };
    debug.write("Kernel took control!\n");
    
    if (framebufferRequest.response == null) @panic("Framebuffer not present");

    const framebufferResponse: *limine.Framebuffer.Response = framebufferRequest.response.?;
    const framebuffers = framebufferResponse.fetchFramebuffer() catch @panic("Failed to fetch framebuffer");
    if (framebuffers.len == 0) @panic("No framebuffers available");
    
    const framebuffer = framebuffers[0];
    
    // Validate pitch alignment
    if (framebuffer.pitch % 4 != 0) @panic("Framebuffer pitch not 4-byte aligned");
    
    const fb_ptr: [*]volatile u32 = @ptrCast(@alignCast(framebuffer.address));
    const pitch_u32 = framebuffer.pitch / 4;
    
    // Validate pixel format (adjust as needed for your format)
    // const fmt = framebuffer.pixel_format; // Use this instead of hardcoded format
    
    var y: usize = 0;
    while (y < framebuffer.height) : (y += 1) {
        var x: usize = 0;
        while (x < framebuffer.width) : (x += 1) {
            const nX: u32 = @intCast(x * 255 / framebuffer.width);
            const nY: u32 = @intCast(y * 255 / framebuffer.height);
            
            fb_ptr[y * pitch_u32 + x] = (nY << 8) | nX;
        }
    }

    debug.write("Halting the CPU...\n");
    while (true) {
        cpu.halt();
    }
}
