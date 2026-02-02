module vga_sync (
    input wire clk,         // 50MHz clock
    input wire rst,         // Reset button

    output reg h_sync,      // Horizontal sync signal
    output reg v_sync       // Vertical sync signal
    );

    reg clk_0;              // 25MHz clock

    // Clock divider
    always @ (posedge clk) begin
        clk_0 <= !clk_0;            // clk_0 has half the frequency of clk, 50/2 = 25MHz
    end

    // Horizontal timing values (in pixels):
    parameter h_video = 640;        // Active video
    parameter h_frontp = 16;        // Front porch
    parameter h_pulsewidth = 96;    // Sync pulse
    parameter h_backp = 48;         // Back porch

    // Vertical timing values (in lines):
    parameter v_video = 480;        // Active video
    parameter v_frontp = 11;        // Front porch
    parameter v_pulsewidth = 2;     // Sync pulse
    parameter v_backp = 31;         // Back porch

    reg h_count = 0;        // Tracks horizontal pixel position
    reg v_count = 0;        // Counts the number of hsync signals

    always @ (posedge clk_0) begin
        if (h_count < h_video + h_frontp) begin     // If we haven't reached the sync pulse yet
            h_sync <= 1'b1;                         // Keep hsync inactive
            h_count <= h_count + 1;                 // Keep incrementing horizontal pixels

        end else begin                              // If we have reached the sync pulse
            if (h_count < h_video + h_frontp + h_pulsewidth) begin  // If we are still in sync pulse
                h_sync <= 1'b0;                     // Keep hsync active
                h_count <= h_count + 1;             // Keep incrementing horizontal pixels
            end

            else begin                              // If we reach the end of the sync pulse
                h_sync <= 1'b1;                     // Make hsync inactive
                h_count <= 0;                       // Reset horizontal count
            end

        end
    end

    always @ (negedge hsync) begin
        if (v_count < v_video + v_frontp) begin     // If we haven't reached the sync pulse yet
            v_sync <= 1'b1;                         // Keep vsync inactive
            v_count <= v_count + 1;                 // Keep incrementing vertical lines

        end else begin                              // If we have reached the sync pulse
            if (v_count < v_video + v_frontp + v_pulsewidth) begin  // If we are still in sync pulse
                v_sync <= 1'b0;                     // Keep vsync active
                v_count <= v_count + 1;             // Keep incrementing vertical lines

            end else begin                          // If we reach the end of the sync pulse
                v_sync <= 1'b1;                     // Make vsync inactive
                v_count <= 0;                       // Reset vertical count
            end

        end
    end

endmodule