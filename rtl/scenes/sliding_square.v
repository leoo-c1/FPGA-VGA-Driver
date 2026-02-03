module sliding_square (
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

    parameter square_width = 10;    // The side lengths of the square
    
    reg [9:0] square_xpos = 0;      // The x-coordinate of the bottom left corner of the square
    // The y-coordinate of the bottom left corner of the square depends on parity of side length
    reg [9:0] square_ypos = v_video/2 - 1 - (square_width - ~(square_width % 2))/2;

    parameter velocity = 500_000;
    reg [18:0] vel_count = 0;

    always @ (posedge clk_0) begin
        if (!rst) begin                 // If we press the reset button, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
            square_xpos <= 0;
            vel_count <= 0;
        end else if (video_on) begin    // If we are in the active video region
            if (vel_count < velocity) begin
                vel_count <= vel_count + 1;
            end else begin
                vel_count <= 0;
                square_xpos <= square_xpos + 1;
            end
            // If the pixel is within the horizontal limits of the square
            if (pixel_x >= square_xpos && pixel_x <= square_xpos + square_width) begin
                // If the pixel is within the vertical limits of the square
                if (pixel_y >= square_ypos && pixel_y <= square_ypos + square_width) begin
                    // Make these square-contained pixels white
                    red <= 1'b1;
                    green <= 1'b1;
                    blue <= 1'b1;
                end else begin
                    // Make non-square-contained pixels black
                    red <= 1'b0;
                    green <= 1'b0;
                    blue <= 1'b0;
                end
            end else begin
                // Make non-square-contained pixels black
                red <= 1'b0;
                green <= 1'b0;
                blue <= 1'b0;
            end
        end else begin                  // If we are outside the active video region, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
            if (vel_count < velocity) begin
                vel_count <= vel_count + 1;
            end else begin
                vel_count <= 0;
                square_xpos <= square_xpos + 1;
            end
        end

        if (square_xpos > h_video - 1) begin
            square_xpos <= 0;
        end

    end


endmodule