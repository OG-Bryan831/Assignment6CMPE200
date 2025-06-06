module datapath (
        input  wire        clk,
        input  wire        rst,
        input  wire        branch,
        input  wire  [1:0] jump, 
        input  wire  [1:0] reg_dst, 
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire [1:0] dm2reg, 
        input  wire [3:0]  alu_ctrl,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3,
        output wire [63:0] overflow,
        input wire hilo_ctrl,
        input wire hilo_sel_mux
        
    );

    wire [4:0]  rf_wa;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_pre;
    wire [31:0] pc_next;
    wire [31:0] sext_imm;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire [31:0] wd_rf;
    wire        zero;
    
    wire [31:0] mux_ha;
    wire [31:0] hilo_out;
    
    wire [4:0] shamt;
    
    
    assign pc_src = branch & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_plus4[31:28], instr[25:0], 2'b00};
    
  
    assign pc_next = (jump == 2'b10) ? alu_pa : // JR (Jump Register)
                     (jump == 2'b01) ? jta :    // J or JAL
                     (branch & zero) ? bta :   // Branch Taken
                     pc_plus4;                 // Default case
 
    
    // --- PC Logic --- //
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .d              (pc_next),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4)
        );

    adder pc_plus_br (
            .a              (pc_plus4),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_plus4),
            .b              (bta),
            .y              (pc_pre)
        );

    mux3 #(32) pc_jmp_mux (
            .sel            (jump),
            .a              (pc_pre),
            .b              (jta),
            .c             (alu_pa),
            .y              (pc_next)
        );

    // --- RF Logic --- //
    mux3 #(5) rf_wa_mux (
            .sel            (reg_dst),
            .a              (instr[20:16]),
            .b              (instr[15:11]),
            .c              (5'b11111),
            .y              (rf_wa)
        );

    regfile rf (
            .clk            (clk),
            .we             (we_reg),
            .ra1            (instr[25:21]),
            .ra2            (instr[20:16]),
            .ra3            (ra3),
            .wa             (rf_wa),
            .wd             (wd_rf),
            .rd1            (alu_pa),
            .rd2            (wd_dm),
            .rd3            (rd3),
            .rst            (rst)
        );

    signext se (
            .a              (instr[15:0]),
            .y              (sext_imm)
        );

    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (
            .sel            (alu_src),
            .a              (wd_dm),
            .b              (sext_imm),
            .y              (alu_pb)
        );

    alu alu (
            .op             (alu_ctrl),
            .a              (alu_pa),
            .b              (alu_pb),
            .shamt          (instr[10:6]),
            .zero           (zero),
            .y              (alu_out),
            .OverflowResult (overflow)
        );
        
   hilo hilo(
    .rst (rst),
    .clk (clk),
    .InputOverflow (overflow),
    .hilo_ctrl (hilo_ctrl),
    
    .hilo_out (hilo_out)   
   );

    mux2 #(32) hi_alu_mux(
    .sel (hilo_sel_mux),
    .a (alu_out),
    .b (hilo_out),
    .y (mux_ha)
    
    );
    // --- MEM Logic --- //
    mux3 #(32) rf_wd_mux (
            .sel            (dm2reg),
            .a              (mux_ha), //
            .b              (rd_dm),
            .c               (pc_plus4), 
            .y              (wd_rf)
        );

endmodule
