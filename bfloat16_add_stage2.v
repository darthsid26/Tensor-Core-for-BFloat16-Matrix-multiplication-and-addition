module bfloat16_add_stage2(
    input  [15:0] input1,
    input  [15:0] input2,
    input sub,
    input sign1,
    input sign2,
    input  [7:0]  exp_max,
    input  [7:0]  sig1_aligned,
    input  [7:0]  sig2_aligned,
    output reg [15:0] result
);

    wire [7:0]  exp1 = input1[14:7];
    wire [6:0]  mant1 = input1[6:0];
    wire [7:0]  exp2 = input2[14:7];
    wire [6:0]  mant2 = input2[6:0];

    wire [8:0] sum = sub ?
                     (sig1_aligned >= sig2_aligned ?
                         {1'b0, sig1_aligned} - {1'b0, sig2_aligned} :
                         {1'b0, sig2_aligned} - {1'b0, sig1_aligned}) :
                     {1'b0, sig1_aligned} + {1'b0, sig2_aligned};

    wire result_sign = sub ?
                       (sig1_aligned >= sig2_aligned ? sign1 : sign2) :
                       sign1;

    wire [7:0] norm_mant = sum[8] ? sum[8:1]  : sum[7:0];
    wire [7:0] norm_exp  = sum[8] ? (exp_max + 1) : exp_max;

    always @(*) begin
        if (input1 == 16'h7fc0 || input2 == 16'h7fc0) begin
            result = 16'h7fc0;
        end
        else if ((exp1 == 8'hFF && mant1 == 7'h00) &&
                 (exp2 == 8'hFF && mant2 == 7'h00) &&
                 (sign1 != sign2)) begin
            result = 16'h7fc0;
        end
        else if (exp1 == 8'hFF && mant1 == 7'h00) begin
            result = input1;
        end
        else if (exp2 == 8'hFF && mant2 == 7'h00) begin
            result = input2;
        end
        else if (sum == 9'b0) begin
            result = 16'h0000;
        end
        else begin
            result = {result_sign, norm_exp, norm_mant[6:0]};
        end
    end

endmodule