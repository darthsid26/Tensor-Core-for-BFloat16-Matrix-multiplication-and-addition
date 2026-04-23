`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:22:09 03/17/2026 
// Design Name: 
// Module Name:    top_upper_tensor 
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
module top_upper_tensor(clk,rst,addressA,addressB,dinA,dinB,wenA,wenB,start,result_final,dinC,wenC,addressC,start_final,addressD,addressD_final);
input clk,rst,start,wenA,wenB;
input [63:0]dinA,dinB;
input [2:0] addressA,addressB;
input [1:0]addressC;
input wenC;
input [63:0]dinC;
input [8:0]addressD;
output reg [8:0]addressD_final;
output reg [63:0]result_final;
output reg start_final;
wire start_t;
wire [15:0]dout_mult;
wire [8:0] addressD_stage9;
tensor_top tt(.addressA(addressA),.addressB(addressB),.dinA(dinA),.dinB(dinB),.wenA(wenA),.wenB(wenB),.start(start),.clk(clk),.rst(rst),.doutC(dout_mult),.start_t(start_t),.addressD(addressD),.addressD_final(addressD_stage9));

reg [15:0]dout_mult_stage1;
reg start_t_stage1;
reg [8:0] addressD_stage10;
always@(posedge clk)
begin
if(rst)
begin
dout_mult_stage1<=16'b0;
start_t_stage1<=1'b0;
addressD_stage10<=9'b0;
end
else
begin
dout_mult_stage1<=dout_mult;
start_t_stage1<=start_t;
addressD_stage10<=addressD_stage9;
end
end
reg [63:0]dinC_new;
reg wenC_new;
reg [1:0] addressC_calc;
reg start_imm;
reg [15:0]dout_mult_new;
reg [1:0]slot;
reg [8:0]addressD_stage11;
always@(posedge clk)
begin
dinC_new<=dinC;
wenC_new<=wenC;
dout_mult_new<=dout_mult_stage1;
start_imm<=start_t_stage1;
addressD_stage11<=addressD_stage10;
if(rst|start_t_stage1)
begin
addressC_calc<=2'b00;
slot<=2'b0;
end
else if (wenC)
begin
addressC_calc<=addressC;
end
else
begin
slot<=slot+1'b1;
if(slot==2'b11)
addressC_calc<=addressC_calc+2'b01;
end
end
wire [63:0]doutC;

C_mem cmem(.addr(addressC_calc),.we(wenC_new),.din(dinC_new),.dout(doutC),.clk(clk));

reg [15:0]dout_mult_stage2,dout_mult_stage3,doutC_stage2;
reg [1:0]slot_stage1;
reg start_t_stage3;
reg [8:0]addressD_stage12;
always@(posedge clk)
begin
if(rst)
begin
dout_mult_stage2<=16'b0;
slot_stage1<=0;
start_t_stage3<=0;
addressD_stage12<=9'b0;
end
else
dout_mult_stage2<=dout_mult_new;
slot_stage1<=slot;
start_t_stage3<=start_imm;
addressD_stage12<=addressD_stage11;
end
reg start_t_stage4;
reg [8:0]addressD_stage13;
always@(posedge clk)
begin
if(rst)
begin
dout_mult_stage3<=16'b0;
doutC_stage2<=16'b0;
start_t_stage4<=0;
addressD_stage13<=9'b0;
end
else
dout_mult_stage3<=dout_mult_stage2;
start_t_stage4<=start_t_stage3;
addressD_stage13<=addressD_stage12;
if(slot_stage1==2'b00)
doutC_stage2<=doutC[15:0];
if(slot_stage1==2'b01)
doutC_stage2<=doutC[31:16];
if(slot_stage1==2'b10)
doutC_stage2<=doutC[47:32];
if(slot_stage1==2'b11)
doutC_stage2<=doutC[63:48];
end

wire sub,sign1,sign2;
wire [7:0] exp_max;
wire [7:0] sig1_aligned, sig2_aligned;
bfloat16_add_stage1 bas1 (.input1(dout_mult_stage3),.input2(doutC_stage2),.sub(sub),.sign1(sign1),.sign2(sign2),.exp_max(exp_max),.sig1_aligned(sig1_aligned),.sig2_aligned(sig2_aligned));

reg sub_stage1,sign1_stage1,sign2_stage1;
reg [7:0]exp_max_stage1;
reg [7:0]sig1_aligned_stage1,sig2_aligned_stage1;
reg [15:0]dout_mult_stage4,doutC_stage4;
reg start_t_stage5;
reg [8:0]addressD_stage14;
always@(posedge clk)
begin
if(rst)
begin
sub_stage1<=1'b0;
sign1_stage1<=1'b0;
sign2_stage1<=1'b0;
exp_max_stage1<=8'b0;
sig1_aligned_stage1<=8'b0;
sig2_aligned_stage1<=8'b0;
dout_mult_stage4<=16'b0;
doutC_stage4<=16'b0;
start_t_stage5<=0;
addressD_stage14<=9'b0;
end
else
begin
addressD_stage14<=addressD_stage13;
sub_stage1<=sub;
sign1_stage1<=sign1;
sign2_stage1<=sign2;
exp_max_stage1<=exp_max;
sig1_aligned_stage1<=sig1_aligned;
sig2_aligned_stage1<=sig2_aligned;
dout_mult_stage4<=dout_mult_stage3;
doutC_stage4<=doutC_stage2;
start_t_stage5<=start_t_stage4;
end
end

wire [15:0] result_imm;
bfloat16_add_stage2 bas2 (.input1(dout_mult_stage4),.input2(doutC_stage4),.sub(sub_stage1),.sign1(sign1_stage1),.sign2(sign2_stage2),.exp_max(exp_max_stage1),.sig1_aligned(sig1_aligned_stage1),.sig2_aligned(sig2_aligned_stage1),.result(result_imm));

reg [3:0]i;
reg [1:0]j;
reg [15:0]result;
reg start_final_t;
reg [8:0]addressD_stage15;
always@(posedge clk)
begin
if(rst)
begin
i<=0;
addressD_stage15<=9'b0;
end
else
begin
result<=result_imm;
if(start_t_stage5)
begin
i<=4'b0;
start_final_t<=1;
end
else begin
i<=i+1;
if(start_final_t)
begin
if(i==4'b0011)
begin
j<=2'b00;
addressD_stage15<=addressD_stage14+9'h0;
end
if(i==4'b0111)
begin
j<=2'b01;
addressD_stage15<=addressD_stage14+9'h1;
end
if(i==4'b1011)
begin
j<=2'b10;
addressD_stage15<=addressD_stage14+9'h2;
end
if(i==4'b1111)
begin
j<=2'b11;
start_final_t<=0;
addressD_stage15<=addressD_stage14+9'h3;
end
end
end
end
end
wire [15:0] dout1,dout2,dout3,dout4;
register_file4 rf(.addressA(i),.dinA(result),.wenA(start_final_t),.dout1(dout1),.dout2(dout2),.dout3(dout3),.dout4(dout4),.addressB(j),.clk(clk),.rst(rst));
reg [1:0]j_next;
always@(posedge clk)
begin
if(rst)
begin
result_final<=64'b0;
j_next<=0;
addressD_final<=9'b0;
end
else
begin
j_next<=j;
if(j_next!=2'b11)
start_final<=1;
else
start_final<=0;
result_final[15:0]<=dout1;
result_final[31:16]<=dout2;
result_final[47:32]<=dout3;
result_final[63:48]<=dout4;
addressD_final<=addressD_stage15;
end
end
endmodule
