`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:09:21 03/23/2026 
// Design Name: 
// Module Name:    register_file4 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module register_file4(addressA,dinA,wenA,dout1,dout2,dout3,dout4,addressB,clk,rst);
input [3:0]addressA;
input [15:0]dinA;
input wenA;
input [1:0]addressB;
input clk,rst;
output [15:0]dout1;
output [15:0]dout2;
output [15:0]dout3;
output [15:0]dout4;

reg [15:0]rf[15:0];
always@(posedge clk)
begin
if(rst)
begin
rf[0]<=16'b0;
rf[1]<=16'b0;
rf[2]<=16'b0;
rf[3]<=16'b0;
rf[4]<=16'b0;
rf[5]<=16'b0;
rf[6]<=16'b0;
rf[7]<=16'b0;
rf[8]<=16'b0;
rf[9]<=16'b0;
rf[10]<=16'b0;
rf[11]<=16'b0;
rf[12]<=16'b0;
rf[13]<=16'b0;
rf[14]<=16'b0;
rf[15]<=16'b0;
end
if (wenA) begin
rf[addressA] <= dinA;
end
end
assign dout1=rf[{addressB,2'b00}];
assign dout2=rf[{addressB,2'b01}];
assign dout3=rf[{addressB,2'b10}];
assign dout4=rf[{addressB,2'b11}];
endmodule
