`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: tensor_top
//////////////////////////////////////////////////////////////////////////////////
module tensor_top(
    input  [2:0] addressA,
    input  [2:0] addressB,
    input  [63:0] dinA,
    input  [63:0] dinB,
    input        wenA,
    input        wenB,
    input        start,
    input        clk,
    input        rst,
    input [8:0]addressD,
    output reg [15:0] doutC,
	output reg start_t,
    output reg [8:0]addressD_final 
);

// Internal wires
wire [63:0] doutA, doutB;
wire [15:0] inter1, inter2, inter3, inter4, inter5, inter6;

// Address calculation registers
reg [2:0] addressA_calc, addressB_calc;
reg wenA_new,wenB_new;
reg [63:0]dinA_new;
reg [63:0]dinB_new;
reg start_imm;
reg [8:0]addressD_stage1;
// Address generation / control
always @(posedge clk) begin
wenA_new<=wenA;
wenB_new<=wenB;
dinA_new<=dinA;
dinB_new<=dinB;
addressD_stage1<=addressD;
start_imm<=start;
    if (rst|start) begin
        addressA_calc <= 3'b000;
        addressB_calc <= 3'b100; // sentinel start column (4)
    end
    else if (wenA | wenB) begin
        // loads from external writes have priority
        if(wenA)
		  addressA_calc <= addressA;
		  
        if(wenB)
		  addressB_calc <= addressB;
    end
    else begin	 
	         // start new sequence begin
        // iterate B fastest, then A; stop advancing when A reaches 3'b100 (sentinel)
        if (addressA_calc != 3'b100) begin
            if (addressB_calc != 3'b111) begin
                addressB_calc <= addressB_calc + 3'b001;
            end
            else begin
                addressB_calc <= 3'b100;
                addressA_calc <= addressA_calc + 3'b001;
            end
        end
    end
end



A_B_mem abmem(.addra(addressA_calc),.addrb(addressB_calc),.dina(dinA_new),.dinb(dinB_new),.wea(wenA_new),.web(wenB_new),.clka(clk),.clkb(clk),.douta(doutA),.doutb(doutB));

reg start_stage1;
reg [8:0]addressD_stage2;

always@(posedge clk)
begin
if(rst) begin
start_stage1<=1'b0;
addressD_stage2<=9'b0;
end
else begin
start_stage1<=start_imm;
addressD_stage2<=addressD_stage1;
end
end

// Stage 1 registers (pipeline)
reg [63:0] doutA_stage1, doutB_stage1;
reg start_stage2,start_action;
reg [8:0] addressD_stage3;
always @(posedge clk) begin
    if (rst) begin
        doutA_stage1 <= 64'b0;
        doutB_stage1 <= 64'b0;
		start_stage2<=1'b0;
        addressD_stage3<=9'b0;
    end else begin
        doutA_stage1 <= doutA;
        doutB_stage1 <= doutB;
		start_stage2<=start_stage1;
        addressD_stage3<=addressD_stage2;
    end
	 if(start_stage2)
	 start_action<=1'b1;
end

wire done1,done2,done3,done4;
wire [15:0] result_decode1,result_decode2,result_decode3,result_decode4;
wire result_sign_r1,result_sign_r2,result_sign_r3,result_sign_r4;
wire [9:0] result_exp1,result_exp2,result_exp3,result_exp4;
wire [15:0] product1,product2,product3,product4;
// BF16 elementwise multipliers (each produces a 16-bit bf16)
bfloat16_mult_stage1 bm1 (.a(doutA_stage1[15:0]),.b(doutB_stage1[15:0]),.start(start_action),.done(done1),.result_decode(result_decode1),.result_sign_r(result_sign_r1),.result_exp(result_exp1),.product(product1));
bfloat16_mult_stage1 bm2 (.a(doutA_stage1[31:16]),.b(doutB_stage1[31:16]),.start(start_action),.done(done2),.result_decode(result_decode2),.result_sign_r(result_sign_r2),.result_exp(result_exp2),.product(product2));
bfloat16_mult_stage1 bm3 (.a(doutA_stage1[47:32]),.b(doutB_stage1[47:32]),.start(start_action),.done(done3),.result_decode(result_decode3),.result_sign_r(result_sign_r3),.result_exp(result_exp3),.product(product3));
bfloat16_mult_stage1 bm4 (.a(doutA_stage1[63:48]),.b(doutB_stage1[63:48]),.start(start_action),.done(done4),.result_decode(result_decode4),.result_sign_r(result_sign_r4),.result_exp(result_exp4),.product(product4));

reg done1_stage1,done2_stage1,done3_stage1,done4_stage1,start_stage3;
reg [15:0] result_decode1_stage1,result_decode2_stage1,result_decode3_stage1,result_decode4_stage1;
reg result_sign_r1_stage1,result_sign_r2_stage1,result_sign_r3_stage1,result_sign_r4_stage1;
reg [9:0] result_exp1_stage1,result_exp2_stage1,result_exp3_stage1,result_exp4_stage1;
reg [15:0] product1_stage1,product2_stage1,product3_stage1,product4_stage1;
reg [8:0]addressD_stage4;
always@(posedge clk) begin
    if (rst) begin
	 start_stage3<=0;
        done1_stage1<=1'b0;
        done2_stage1<=1'b0;
        done3_stage1<=1'b0;
        done4_stage1<=1'b0;
        result_decode1_stage1<=16'b0;
        result_decode2_stage1<=16'b0;
        result_decode3_stage1<=16'b0;
        result_decode4_stage1<=16'b0;
        result_sign_r1_stage1<=1'b0;
        result_sign_r2_stage1<=1'b0;
        result_sign_r3_stage1<=1'b0;
        result_sign_r4_stage1<=1'b0;
        result_exp1_stage1<=10'b0;
        result_exp2_stage1<=10'b0;
        result_exp3_stage1<=10'b0;
        result_exp4_stage1<=10'b0;
        product1_stage1<=16'b0;
        product2_stage1<=16'b0;
        product3_stage1<=16'b0; 
        product4_stage1<=16'b0;
        addressD_stage4<=9'b0;
    end
    else
    begin
	 start_stage3<=start_stage2;
        done1_stage1<=done1;
        done2_stage1<=done2;
        done3_stage1<=done3;
        done4_stage1<=done4;
        result_decode1_stage1<=result_decode1;
        result_decode2_stage1<=result_decode2;
        result_decode3_stage1<=result_decode3;
        result_decode4_stage1<=result_decode4;
        result_sign_r1_stage1<=result_sign_r1;
        result_sign_r2_stage1<=result_sign_r2;
        result_sign_r3_stage1<=result_sign_r3;
        result_sign_r4_stage1<=result_sign_r4;
        result_exp1_stage1<=result_exp1;
        result_exp2_stage1<=result_exp2;
        result_exp3_stage1<=result_exp3;
        result_exp4_stage1<=result_exp4;
        product1_stage1<=product1;
        product2_stage1<=product2;
        product3_stage1<=product3;
        product4_stage1<=product4;
        addressD_stage4<=addressD_stage3;
    end
end

bfloat16_mult_stage2 bm5 (.result_decode(result_decode1_stage1),.done(done1_stage1),.result_sign(result_sign_r1_stage1),.result_exp(result_exp1_stage1),.product(product1_stage1),.result(inter1));
bfloat16_mult_stage2 bm6 (.result_decode(result_decode2_stage1),.done(done2_stage1),.result_sign(result_sign_r2_stage1),.result_exp(result_exp2_stage1),.product(product2_stage1),.result(inter2));
bfloat16_mult_stage2 bm7 (.result_decode(result_decode3_stage1),.done(done3_stage1),.result_sign(result_sign_r3_stage1),.result_exp(result_exp3_stage1),.product(product3_stage1),.result(inter3));
bfloat16_mult_stage2 bm8 (.result_decode(result_decode4_stage1),.done(done4_stage1),.result_sign(result_sign_r4_stage1),.result_exp(result_exp4_stage1),.product(product4_stage1),.result(inter4));

// Stage registers for the multiplier outputs (16-bit BF16 values)
reg [15:0] inter1_stage1, inter2_stage1, inter3_stage1, inter4_stage1;
reg start_stage4;
reg [8:0]addressD_stage5;
always @(posedge clk) begin
    if (rst) begin
	 start_stage4<=0;
        inter1_stage1 <= 16'b0;
        inter2_stage1 <= 16'b0;
        inter3_stage1 <= 16'b0;
        inter4_stage1 <= 16'b0;
        addressD_stage5<=9'b0;
    end else begin
	 start_stage4<=start_stage3;
        inter1_stage1 <= inter1;
        inter2_stage1 <= inter2;
        inter3_stage1 <= inter3;
        inter4_stage1 <= inter4;
        addressD_stage5<=addressD_stage4;
    end
end

// Pairwise additions (16-bit BF16 adders)
wire sub1,sub2,sign1_1,sign2_1,sign1_2,sign2_2;
wire [7:0] exp_max1, exp_max2;
wire [7:0] sig1_aligned1, sig2_aligned1, sig1_aligned2, sig2_aligned2;
bfloat16_add_stage1 bas1 (.input1(inter1_stage1),.input2(inter2_stage1),.sub(sub1),.sign1(sign1_1),.sign2(sign2_1),.exp_max(exp_max1),.sig1_aligned(sig1_aligned1),.sig2_aligned(sig2_aligned1));
bfloat16_add_stage1 bas2 (.input1(inter3_stage1),.input2(inter4_stage1),.sub(sub2),.sign1(sign1_2),.sign2(sign2_2),.exp_max(exp_max2),.sig1_aligned(sig1_aligned2),.sig2_aligned(sig2_aligned2));

reg sub1_stage1,sub2_stage1;
reg start_stage5;
reg sign1_1_stage1,sign2_1_stage1,sign1_2_stage1,sign2_2_stage1;
reg [15:0]inter1_stage2, inter2_stage2, inter3_stage2, inter4_stage2;
reg [7:0] exp_max1_stage1, exp_max2_stage1;
reg [7:0] sig1_aligned1_stage1, sig2_aligned1_stage1, sig1_aligned2_stage1, sig2_aligned2_stage1;
reg [8:0]addressD_stage6;
always @(posedge clk) begin
    if (rst) begin
	 start_stage5<=1'b0;
        sub1_stage1 <= 1'b0;
        sub2_stage1 <= 1'b0;
        sign1_1_stage1 <= 1'b0;
        sign2_1_stage1 <= 1'b0;
        sign1_2_stage1 <= 1'b0;
        sign2_2_stage1 <= 1'b0;
        exp_max1_stage1 <= 8'b0;
        exp_max2_stage1 <= 8'b0;
        sig1_aligned1_stage1 <= 8'b0;
        sig2_aligned1_stage1 <= 8'b0;
        sig1_aligned2_stage1 <= 8'b0;
        sig2_aligned2_stage1 <= 8'b0;
        inter1_stage2 <= 16'b0;
        inter2_stage2 <= 16'b0;
        inter3_stage2 <= 16'b0;
        inter4_stage2 <= 16'b0;
        addressD_stage6<=9'b0;
    end else begin
	 start_stage5<=start_stage4;
        sub1_stage1 <= sub1;
        sub2_stage1 <= sub2;
        sign1_1_stage1 <= sign1_1;
        sign2_1_stage1 <= sign2_1;
        sign1_2_stage1 <= sign1_2;
        sign2_2_stage1 <= sign2_2;
        exp_max1_stage1 <= exp_max1;
        exp_max2_stage1 <= exp_max2;
        sig1_aligned1_stage1 <= sig1_aligned1;
        sig2_aligned1_stage1 <= sig2_aligned1;
        sig1_aligned2_stage1 <= sig1_aligned2;
        sig2_aligned2_stage1 <= sig2_aligned2;
        inter1_stage2 <= inter1_stage1;
        inter2_stage2 <= inter2_stage1;
        inter3_stage2 <= inter3_stage1;
        inter4_stage2 <= inter4_stage1;
        addressD_stage6<=addressD_stage5;
    end
end 

bfloat16_add_stage2 bas3 (.input1(inter1_stage2),.input2(inter2_stage2),.sub(sub1_stage1),.sign1(sign1_1_stage1),.sign2(sign2_1_stage1),.exp_max(exp_max1_stage1),.sig1_aligned(sig1_aligned1_stage1),.sig2_aligned(sig2_aligned1_stage1),.result(inter5));
bfloat16_add_stage2 bas4 (.input1(inter3_stage2),.input2(inter4_stage2),.sub(sub2_stage1),.sign1(sign1_2_stage1),.sign2(sign2_2_stage1),.exp_max(exp_max2_stage1),.sig1_aligned(sig1_aligned2_stage1),.sig2_aligned(sig2_aligned2_stage1),.result(inter6));

// Stage registers for the pairwise sums (16-bit)
reg [15:0] inter5_stage1, inter6_stage1;
reg [8:0]addressD_stage7;
reg start_stage6;
always @(posedge clk) begin
    if (rst) begin
	 start_stage6<=1'b0;
        inter5_stage1 <= 16'b0;
        inter6_stage1 <= 16'b0;
        addressD_stage7<=9'b0;
    end else begin
	 start_stage6<=start_stage5;
        inter5_stage1 <= inter5;
        inter6_stage1 <= inter6;
        addressD_stage7<=addressD_stage6;
    end
end

// Final BF16 add: produces doutC (16-bit)
wire sub3,sign1_3,sign2_3;
wire [7:0] exp_max3;
wire [7:0] sig1_aligned3, sig2_aligned3;  
bfloat16_add_stage1 bas5 (.input1(inter5_stage1),.input2(inter6_stage1),.sub(sub3),.sign1(sign1_3),.sign2(sign2_3),.exp_max(exp_max3),.sig1_aligned(sig1_aligned3),.sig2_aligned(sig2_aligned3));
reg sub3_stage1,sign1_3_stage1,sign2_3_stage1;
reg [7:0] exp_max3_stage1;
reg [7:0] sig1_aligned3_stage1, sig2_aligned3_stage1;
reg start_stage7;
reg [3:0] i;
reg [3:0] i_imm;
reg [8:0]addressD_stage8;
always@(posedge clk) begin
    if(rst)
    begin
	 start_stage7<=1'b0;
        sub3_stage1<=1'b0;
        sign1_3_stage1<=1'b0;
        sign2_3_stage1<=1'b0;
        exp_max3_stage1<=8'b0;
        sig1_aligned3_stage1<=8'b0;
        sig2_aligned3_stage1<=8'b0;
        addressD_stage8<=9'b0;
    end
    else
    begin
	 start_stage7<=start_stage6;
        sub3_stage1<=sub3;
        sign1_3_stage1<=sign1_3;
        sign2_3_stage1<=sign2_3;
        exp_max3_stage1<=exp_max3;
        sig1_aligned3_stage1<=sig1_aligned3;
        sig2_aligned3_stage1<=sig2_aligned3;
        addressD_stage8<=addressD_stage7;
		  if(start_stage6)
		  begin
		  i<=4'b0;
		  end
    end
end
wire [15:0] dout_imm;
bfloat16_add_stage2 bas6 (.input1(inter5_stage1),.input2(inter6_stage1),.sub(sub3_stage1),.sign1(sign1_3_stage1),.sign2(sign2_3_stage1),.exp_max(exp_max3_stage1),.sig1_aligned(sig1_aligned3_stage1),.sig2_aligned(sig2_aligned3_stage1),.result(dout_imm));
    reg done;
	 always@(posedge clk)
	 begin
	 start_t<=start_stage7;
	 doutC<=dout_imm;
     addressD_final<=addressD_stage8;
	 end
endmodule