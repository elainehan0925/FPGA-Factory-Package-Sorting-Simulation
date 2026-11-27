`timescale 1ns/1ns

module testbench_automatic_sorting_system;

    reg package_status;
    reg package_type;
    reg full_A;
    reg full_B;

    wire valid;
    wire bin;

    automatic_sorting_system dut (
        .package_status(package_status),
        .package_type(package_type),
        .full_A(full_A),
        .full_B(full_B),
        .valid(valid),
        .bin(bin)
    );

    initial begin
        // No package: valid=0, bin=0
        package_status = 0;
        package_type = 0;
        full_A = 0;
        full_B = 0;

        // Package A, bin A available: valid=1, bin=0
        #20;
        package_status = 1;

        // Bin B full should not block A: valid=1, bin=0
        #20;
        full_B = 1;

        // Bin A also full: valid=0, bin=0
        #20;
        full_A = 1;

        // Package B, bin B full: valid=0, bin=1
        #20;
        package_type = 1;

        // Bin B available, A still full: valid=1, bin=1
        #20;
        full_B = 0;

        // Both bins available: valid=1, bin=1
        #20;
        full_A = 0;

        // Remove package: valid=0, bin=0
        #20;
        package_status = 0;

        #20;
        $stop;
    end

endmodule