
`timescale 1ns / 1ps

module testbench_user_input();

    parameter CLOCK_PERIOD = 10;

    reg CLOCK_50;
    reg [0:0] KEY;
    reg [7:0] received_data;
    reg received_data_en;

    wire reset, run;

    initial begin
        KEY[0] <= 1'b0;
        #10 KEY[0] <= 1'b1;
    end

    initial begin
        CLOCK_50 <= 1'b0;
    end

    always begin
        #(CLOCK_PERIOD / 2);
        CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        received_data = 8'h00;
        received_data_en = 1'b0;

        #20;


        received_data = 8'h1B;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'h1B;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'hF0;
        received_data_en = 1'b1;

        #10;
        received_data = 8'h1B;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'h4D;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'hF0;
        received_data_en = 1'b1;

        #10;
        received_data = 8'h4D;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'h1B;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'hF0;
        received_data_en = 1'b1;

        #10;
        received_data = 8'h1B;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'h2D;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'h2D;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'hF0;
        received_data_en = 1'b1;

        #10;
        received_data = 8'h2D;

        #10;
        received_data_en = 1'b0;

        #10;


        received_data = 8'h1B;
        received_data_en = 1'b1;

        #10;
        received_data_en = 1'b0;

        #10;


        KEY[0] = 1'b0;

        #10;

        KEY[0] = 1'b1;

        #10 $stop;
    end

    user_input_registration U1(
        CLOCK_50, KEY, received_data,
        received_data_en, reset, run
    );

endmodule
