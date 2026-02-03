module fill_with_border (
    input clk_0,            // 25MHz clock
    input rst,              // Reset button

    input [9:0] pixel_x,    // Horizontal position of pixel
    input [9:0] pixel_y,    // Vertical position of pixel
    input video_on,         // Whether or not we are in the active video region

    output reg red,         // Red colour (either 0v or 0.7v)
    output reg green,       // Green colour (either 0v or 0.7v)
    output reg blue         // Blue colour (either 0v or 0.7v)
    );

    parameter h_video = 640;        // Horizontal active video (in pixels)
    parameter v_video = 480;        // Vertical active video (in lines)

    parameter border_width = 10;    // Width of the surrounding border

    // Render a white screen in the active video area, red outside
    always @ (posedge clk_0) begin
        if (!rst) begin                 // If we press the reset button, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end else if (video_on) begin    // Show white with red border in active video region
            if (pixel_x < border_width || (pixel_x >= h_video - border_width && pixel_x < h_video)) begin
                red <= 1'b1;
                green <= 1'b0;
                blue <= 1'b0;
            end else if (pixel_y < border_width || (pixel_y >= v_video - border_width && pixel_y < v_video)) begin
                red <= 1'b1;
                green <= 1'b0;
                blue <= 1'b0;
            end else begin
                red <= 1'b1;
                green <= 1'b1;
                blue <= 1'b1;
            end
        end else begin                  // If we are outside the active video region, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end
    end


endmodule