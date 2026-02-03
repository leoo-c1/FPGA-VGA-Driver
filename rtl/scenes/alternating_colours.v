module alternating_colours (
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

    parameter number_of_bars = 32;  // Number of vertical bars to display
    parameter bar_width = h_video / number_of_bars;     // Width of each vertical bar

    /*
    Plan:
    First figure out generating red bars.
    First red bar has left edge at 0. Second has left edge at 0+3*bar_width (it is 3 bars away)
    So we need to check if pixel_x lies between these ranges: [0,w],[3w,4w],[6w,7w],...[3nw,(3n+1)w]
    Really, we just need to check if pixel_x is some integer multiple of 3w, then hold it red for bar_width duration
    Two strategies:
    1. Check if modulus of pixel_x and 3w == 0, set flag to red_on and draw red bar for that duration
    (May be costly to synthesise modulo)
    2. Instead, set up a count.
    The count starts at 0 when pixel_x == 0.
    Once we've counted w pixels, we stop showing red.
    We start counting how many pixels we haven't been showing red for.
    Once this new count hits 2w, stop the new counter and restart the first count.
    This indicates we are back at a red bar. Restart the first count.
    Continue this process until the condition if (video_on) isn't met and apply for other colours.
    How to apply for other colours? Start with green.

    */

    reg [9:0] red_counter = 0;
    reg [9:0] non_red_counter = 0;
    reg [9:0] green_counter = 0;
    reg [9:0] non_green_counter = 0;
    reg [9:0] blue_counter = 0;
    reg [9:0] non_blue_counter = 0;

    // Render a series of red, green and blue bars in the video region
    always @ (posedge clk_0) begin
        if (!rst) begin                 // If we press the reset button, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end else if (video_on) begin    // If we are in the active video region
            if (pixel_x == 0) begin     // Start at the first pixel
                // Show the colour red
                red <= 1'b1;
                green <= 1'b0;
                blue <= 1'b0;
                red_counter <= 0;       // Reset the red counter
                non_red_counter <= 0;   // Reset the non-red counter

            end else if (red_counter < bar_width) begin         // If we are in a red bar
                // Show the colour red
                red <= 1'b1;
                green <= 1'b0;
                blue <= 1'b0;
                red_counter <= red_counter + 1;
                non_red_counter <= 0;

            end else if (non_red_counter < 2 * bar_width) begin // If we are outside a red bar
                if (non_red_counter < bar_width) begin          // If we are in a green bar
                    // Show the colour green
                    red <= 1'b0;
                    green <= 1'b1;
                    blue <= 1'b0;
                    non_red_counter <= non_red_counter + 1;
                end else begin                                  // If we are in a blue bar
                    // Show the colour blue
                    red <= 1'b0;
                    green <= 1'b0;
                    blue <= 1'b1;
                    non_red_counter <= non_red_counter + 1;
                end
            end else begin
                red_counter <= 0;
                non_red_counter <= 0;
                red <= 1'b1;            // Show the colour red
                green <= 1'b0;
                blue <= 1'b0;
            end

        end else begin                  // If we are outside the active video region, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end
    end

endmodule