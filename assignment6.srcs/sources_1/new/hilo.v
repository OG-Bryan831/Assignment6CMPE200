
module hilo(
    input wire clk,
    input wire rst,
    input wire [63:0] InputOverflow,
    output reg [31:0] hilo
);


    reg [31:0] HI; // one for hi one for lo
    reg [31:0] LO;

    always @(posedge clk) begin
        if(rst) begin
            HI <= 0;
            LO <= 0;
         end
        else begin
            HI<= {InputOverflow[63:32]};
            LO<= {InputOverflow[31:0]};
        end

    end

endmodule
