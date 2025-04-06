
module hilo(
    input wire clk,
    input wire rst,
    input wire [63:0] InputOverflow,
    output reg [31:0] hilo_out,
    input wire hilo_ctrl
);


    reg [31:0] HI; // one for hi one for lo
    reg [31:0] LO;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            HI <= 0;
            LO <= 0;
         end
        else begin
            HI<= {InputOverflow[63:32]};
            LO<= {InputOverflow[31:0]};
            
            /*case(hilo_ctrl)
                1'b0:hilo_out <= LO;
                1'b1:hilo_out <= HI;

           endcase*/
            $display("hilo:0x%h",hilo_out);
        end

    end
    
     always @(*) begin
        case (hilo_ctrl)
            1'b0: hilo_out = LO;
            1'b1: hilo_out = HI;
        endcase
    end

endmodule
