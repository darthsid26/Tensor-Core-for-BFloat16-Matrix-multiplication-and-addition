module bfloat16_mult_stage1(
    input  [15:0] a,
    input  [15:0] b,
    input start,

    output reg done,
    output reg [15:0] result_decode,
    output reg result_sign_r,
    output reg [9:0]  result_exp,
    output reg [15:0] product
);

wire        sign_a  = a[15];
wire [7:0]  exp_a   = a[14:7];
wire [6:0]  mant_a  = a[6:0];

wire        sign_b  = b[15];
wire [7:0]  exp_b   = b[14:7];
wire [6:0]  mant_b  = b[6:0];

wire result_sign = sign_a ^ sign_b;

// special cases
wire a_zero = (exp_a == 8'h00) && (mant_a == 7'h00);
wire b_zero = (exp_b == 8'h00) && (mant_b == 7'h00);
wire a_inf  = (exp_a == 8'hFF) && (mant_a == 7'h00);
wire b_inf  = (exp_b == 8'hFF) && (mant_b == 7'h00);
wire a_nan  = (exp_a == 8'hFF) && (mant_a != 7'h00);
wire b_nan  = (exp_b == 8'hFF) && (mant_b != 7'h00);

// significands
wire [7:0] sig_a = (exp_a == 8'b0) ? {1'b0, mant_a} : {1'b1, mant_a};
wire [7:0] sig_b = (exp_b == 8'b0) ? {1'b0, mant_b} : {1'b1, mant_b};

always @(*) begin
    result_sign_r = result_sign;
    result_decode = 16'b0;
    done          = 1'b0;
    result_exp    = 10'd0;
    product       = 16'd0;

    if (start == 1'b0) begin
        result_decode = 16'h0;
        done          = 1'b1;
    end
    else begin
        if (a_nan || b_nan) begin
            result_decode = 16'h7fc0;
            done = 1'b1;
        end
        else if ((a_inf && b_zero) || (b_inf && a_zero)) begin
            result_decode = 16'h7fc0;
            done = 1'b1;
        end
        else if (a_inf || b_inf) begin
            result_decode = {result_sign, 8'hFF, 7'h00};
            done = 1'b1;
        end
        else if (a_zero || b_zero) begin
            result_decode = {result_sign, 8'h00, 7'h00};
            done = 1'b1;
        end

        if (!done) begin
            result_exp = {2'b00, exp_a} + {2'b00, exp_b} - 10'd127;
            product    = ({8'b0, sig_a} * {8'b0, sig_b});
        end
    end
end

endmodule