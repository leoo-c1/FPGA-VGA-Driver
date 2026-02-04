module bouncing_ball_2d (
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
    
    // The x-coordinate of the top left corner of the square
    reg [9:0] square_xpos = h_video /2;
    // The y-coordinate of the top left corner of the square
    reg [9:0] square_ypos = v_video/2;

    parameter velocity = 200;       // Velocity in pixels/second
    parameter vel_psc = 25_000_000/ velocity;   // Clock prescaler for velocity
    reg [18:0] vel_count = 0;       // Velocity ticker
    reg vel_xdir = 0;               // Square's direction of velocity along x, 0 = left, 1 = right
    reg vel_ydir = 0;               // Square's direction of velocity along y, 0 = up, 1 = down

    always @ (posedge clk_0) begin
        if (!rst) begin             // If we press the reset button, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
            // Reset the square's position and velocity 
            square_xpos <= h_video /2;
            square_ypos <= v_video /2;
            vel_count <= 0;
            vel_xdir <= 0;
            vel_ydir <= 0;

        end else if (video_on) begin    // If we are in the active video region
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

        end else begin          // If we are outside the active video region, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end

        // Control square's x and y velocity
        // If we hit the right wall
        if (square_xpos >= h_video - square_width - 1) begin
            vel_xdir <= ~vel_xdir;              // Change direction along x-axis
            square_xpos <= square_xpos - 1;     // Move to the left by one pixel

        end else if (square_xpos <= 0) begin    // If we hit the left wall
            vel_xdir <= ~vel_xdir;              // Change direction along y-axis
            square_xpos <= square_xpos + 1;     // Move to the right one pixel
        end

        // If we hit the bottom wall
        if (square_ypos >= v_video - square_width - 1) begin
            vel_ydir <= ~vel_ydir;              // Change direction along y-axis
            square_ypos <= square_ypos - 1;     // Move up by one pixel

        // If we hit the top wall
        end else if (square_ypos <= 0) begin
            vel_ydir <= ~vel_ydir;              // Change direction along y-axis
            square_ypos <= square_ypos + 1;     // Move down one pixel
        end

        // Control square's x and y position
        if (vel_count < vel_psc) begin
            vel_count <= vel_count + 1;
        end else begin                          // Increment square position every velocity tick
            vel_count <= 0;
            square_xpos <= square_xpos + 2*vel_xdir - 1;
            square_ypos <= square_ypos + 2*vel_ydir - 1;
        end

    end

endmodule