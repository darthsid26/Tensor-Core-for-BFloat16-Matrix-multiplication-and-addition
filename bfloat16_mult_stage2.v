module bfloat16_mult_stage2(
    input [15:0] result_decode,
    input done,
    input result_sign,
    input [9:0] result_exp,
    input [15:0] product,
    output reg [15:0] result
);

reg [9:0] exp_adj;
reg [7:0] result_mant;
reg guard;
reg sticky;

always @(*) begin
    exp_adj = result_exp;
    result_mant = 8'h00;
    guard  = 1'b0;
    sticky = 1'b0;
    if (done == 1'b1) begin
        result = result_decode;
    end
    else begin
        if (product[15]) begin
            exp_adj     = result_exp + 1;
            result_mant = product[15:8];
            guard       = product[7];
            sticky      = |product[6:0];
        end
        else begin
            result_mant = product[14:7];
            guard       = product[6];
            sticky      = |product[5:0];
        end

        if (guard && (sticky || result_mant[0])) begin
            result_mant = result_mant + 1;
            if (result_mant == 8'h00)
                exp_adj = exp_adj + 1;
        end

        if (exp_adj[9])
            result = {result_sign, 8'h00, 7'h00};           // underflow
        else if (exp_adj >= 10'd255)
            result = {result_sign, 8'hFF, 7'h00};           // overflow -> inf
        else if (exp_adj == 10'd0)
            result = {result_sign, 8'h00, 7'h00};           // underflow
        else
            result = {result_sign, exp_adj[7:0], result_mant[6:0]};
    end
end

endmodule