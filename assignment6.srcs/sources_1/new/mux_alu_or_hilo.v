
module mux_alu_or_hilo(
    input wire sel,
    input wire [31:0] alu,
    input wire [31:0] hilo,
    output wire [31:0] muxout
    );
    
    assign muxout = (sel) ? hilo : alu;
    
endmodule
