
module hilo(
    input wire clk,
    input wire rst,
    input wire [63:0] InputOverflow,
    output reg [31:0] hilo,
    input wire hilo_ctrl
);


    reg [31:0] HI; // one for hi one for lo
    reg [31:0] LO;

    always @(posedge clk, rst, hilo_ctrl) begin
        if(rst) begin
            HI <= 0;
            LO <= 0;
         end
        else begin
            HI<= {InputOverflow[63:32]};
            LO<= {InputOverflow[31:0]};
            
            case(hilo_ctrl)
                1'b0:hilo <= LO;
                1'b1:hilo <= HI;

           endcase
            $display("hilo:0x%h",hilo);
        end

    end

endmodule
