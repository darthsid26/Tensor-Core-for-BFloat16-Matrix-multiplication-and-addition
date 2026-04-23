`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:58:57 03/22/2026
// Design Name:   top_upper_tensor
// Module Name:   C:/Documents and Settings/student/ee533_tensor_mmac/top_upper_tensor_tb.v
// Project Name:  ee533_tensor_mmac
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_upper_tensor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_upper_tensor_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [2:0] addressA;
	reg [2:0] addressB;
	reg [63:0] dinA;
	reg [63:0] dinB;
	reg wenA;
	reg wenB;
	reg start;
	reg [63:0] dinC;
	reg wenC;
	reg [1:0] addressC;
	reg [8:0]addressD;

	// Outputs
	wire [63:0] result_final;
	wire start_final;
	wire [8:0] addressD_final;

	// Instantiate the Unit Under Test (UUT)
	top_upper_tensor uut (
		.clk(clk), 
		.rst(rst), 
		.addressA(addressA), 
		.addressB(addressB), 
		.dinA(dinA), 
		.dinB(dinB), 
		.wenA(wenA), 
		.wenB(wenB), 
		.start(start), 
		.result_final(result_final), 
		.dinC(dinC), 
		.wenC(wenC), 
		.addressC(addressC),
		.start_final(start_final),
		.addressD(addressD),
		.addressD_final(addressD_final)
	);
 always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize
        clk      = 0;
        rst      = 1;
        start    = 0;
        wenA     = 0;
        wenB     = 0;
        addressA = 0;
        addressB = 0;
        dinA     = 0;
        dinB     = 0;
		  dinC	  = 0;
		  wenC	  = 0;
		  addressC = 0;
		  addressD=0;

        // Apply reset
        #20;
        rst = 0;

        // ------------------
		// Wait 100 ns for global reset to finish
		#100;
      // Apply reset
        #20;
        rst = 0;

        // --------------------------------------------------
        // Write data into Register File A
        // --------------------------------------------------
        @(posedge clk);
        wenA     = 1;
        addressA = 3'b000;
        dinA     = 64'h3f80_4000_4040_4080;  // Example BF16 packed data

        @(posedge clk);
        addressA = 3'b001;
        dinA     = 64'h4100_4110_4120_4130;
		  @(posedge clk);
        addressA = 3'b010;
        dinA     = 64'h3f80_4000_4040_4080;  // Example BF16 packed data

        @(posedge clk);
        addressA = 3'b011;
        dinA     = 64'h4100_4110_4120_4130;

        @(posedge clk);
        wenA = 0;

        // --------------------------------------------------
        // Write data into Register File B
        // --------------------------------------------------
        @(posedge clk);
        wenB     = 1;
        addressB = 3'b100;
        dinB     = 64'h3f80_3f80_3f80_3f80;

        @(posedge clk);
        addressB = 3'b101;
        dinB     = 64'h4000_4000_4000_4000;
		  @(posedge clk);
		  addressB = 3'b110;
        dinB     = 64'h3f80_3f80_3f80_3f80;

        @(posedge clk);
        addressB = 3'b111;
        dinB     = 64'h4000_4000_4000_4000;

        @(posedge clk);
        wenB = 0;

        // --------------------------------------------------
        // Write data into Register File C
        // --------------------------------------------------
        		  @(posedge clk);
        start = 1;
		   @(posedge clk);
        start = 0;
		  
		  @(posedge clk);
        wenC     = 1;
        addressC = 2'b00;
        dinC     = 64'h3f80_3f80_3f80_3f80;

        @(posedge clk);
        addressC = 2'b01;
        dinC     = 64'h4000_4000_4000_4000;
		  @(posedge clk);
		  addressC = 2'b10;
        dinC     = 64'h3f80_3f80_3f80_3f80;

        @(posedge clk);
        addressC = 2'b11;
        dinC     = 64'h4000_4000_4000_4000;

        @(posedge clk);
        wenC = 0;

        // --------------------------------------------------
        // Start computation
        // --------------------------------------------------


        // Wait for pipeline latency (adjust as needed)
        repeat (20) @(posedge clk);
		// Add stimulus here

	end
      
endmodule

