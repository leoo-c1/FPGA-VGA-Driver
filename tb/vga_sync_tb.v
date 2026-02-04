`timescale 1ns/100ps

module vga_sync_tb;

    reg clk;                // 50MHz clock
    reg rst;                // Reset button

    wire clk_0;             // 25.175MHz divided clock

    wire h_sync;            // Horizontal sync signal
    wire v_sync;            // Vertical sync signal

    wire [9:0] pixel_x;     // Horizontal pixel coordinate (from 0)
    wire [9:0] pixel_y;     // Vertical pixel coordinate (from 0)

    wire video_on;          // Whether or not we are in the active video region

    vga_sync vga_sync_test (
        .clk(clk),
        .rst(rst),
        .clk_0(clk_0),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on)
    );

    initial begin
        clk = 0;            // Initially, clock is low
        rst = 0;            // Reset is active

        #200 rst = 1;       // After 200ns, turn off the reset signal
        #200;               // Wait another 200ns doing nothing

        #(20_000_000);      // Wait 20ms for full frame wrapover
        $stop(2);
    end

    always begin
        #10 clk = !clk;     // Generate 50MHz clock signal
    end

endmodule