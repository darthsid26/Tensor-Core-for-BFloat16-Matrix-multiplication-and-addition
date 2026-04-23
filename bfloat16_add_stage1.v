module bfloat16_add_stage1(
    input  [15:0] input1,
    input  [15:0] input2,
    output sub,
    output sign1,
    output sign2,
    output [7:0]  exp_max,
    output [7:0]  sig1_aligned,
    output [7:0]  sig2_aligned
);

    assign sign1 = input1[15];
    wire [7:0]  exp1 = input1[14:7];
    wire [6:0]  mant1 = input1[6:0];
    wire [7:0]  sig1 = (exp1 == 8'h00) ? {1'b0, mant1} : {1'b1, mant1};

    assign sign2 = input2[15];
    wire [7:0]  exp2 = input2[14:7];
    wire [6:0]  mant2 = input2[6:0];
    wire [7:0]  sig2 = (exp2 == 8'h00) ? {1'b0, mant2} : {1'b1, mant2};

    // align
    assign sub = sign1 ^ sign2;
    assign exp_max = (exp1 > exp2) ? exp1 : exp2;
    assign sig1_aligned  = (exp1 < exp_max) ? (sig1 >> (exp_max - exp1)) : sig1;
    assign sig2_aligned  = (exp2 < exp_max) ? (sig2 >> (exp_max - exp2)) : sig2;

endmodule