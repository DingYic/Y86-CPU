`timescale 1ns / 1ps
`include "define.v"

module testbench;
  reg clk_i;
  reg rst_n_i;
  reg [63:0] PC_i;
  wire [63:0] nextpc;
  wire [3:0] icode_o;
  wire[3:0] ifun_o;
  wire[3:0] rA_o;
  wire[3:0] rB_o;
  wire[63:0] valA_o;
  wire[63:0] valB_o;
   wire[63:0] valC_o;
   wire [63:0] valE_exe;
   wire [63:0] valM_mem;
   wire [63:0] valE_wb;
   wire [63:0] valM_wb;
   wire [3:0]  Stat;
   wire[63:0] valP_o;
   wire instr_valid_o;
   wire imem_error_o;
   wire 		dmem_error;
fetch fetch_tb(
   .PC_i(PC_i),
   .icode_o(icode_o),
   .ifun_o(ifun_o),
   .rA_o(rA_o),
   .rB_o(rB_o),
   .valC_o(valC_o),
   .valP_o(valP_o),
   .instr_valid_o(instr_valid_o),
   .imem_error_o(imem_error_o)
);
decode decode_stage(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
	.icode_i(icode_o),
    //read
	.rA_i(rA_o),
	.rB_i(rB_o),
    //write
    .valE_i(valE_wb),
    .valM_i(valM_wb),

	.valA_o(valA_o),
	.valB_o(valB_o),
    .Cnd_i(Cnd_o)
);

execute execute_stage(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),

    .icode_i(icode_o),
    .ifun_i(ifun_o),
    .valA_i(valA_o),
    .valB_i(valB_o),
    .valC_i(valC_o),

    .valE_o(valE_exe),
    .Cnd_o(Cnd_o)
);
memory_access mem_stage(
    .clk_i(clk_i),
    .icode_i(icode_o),
    .valE_i(valE_exe),
    .valA_i(valA_o),
    .valP_i(valP_o),
    .valM_o(valM_mem),
    .dmem_error_o(dmem_error)
);

writeback writeback_stage(
    .icode_i(icode_o),
    .valE_i(valE_exe),
    .valM_i(valM_mem),

    .instr_valid_i(instr_valid_o),
    .imem_error_i(imem_error_o),
    .dmem_error_i(dmem_error),

    .valE_o(valE_wb),
    .valM_o(valM_wb),
    .stat_o(Stat)
);
update update_stage(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .instr_valid_i(instr_valid_o),
    .Cnd_i(Cnd_o),

    .icode_i(icode_o),

    .valP(valP_o),
    .valC(valC_o),
    .valM(valM_wb),
    .nextpc(nextpc)
);
initial begin
   clk_i = 1;
   PC_i = 0;
   rst_n_i = 0;
end

always #10 clk_i = ~clk_i;

initial begin
    #200 $stop;
end

initial
    //nextPC计算出来后赋值
    forever @(posedge clk_i) #20 PC_i = nextpc;


initial begin
    PC_i = 0;
    #10 PC_i = 10;
    #10 PC_i = 20;
    #10 PC_i = 30;
    #10 PC_i = 40;
    #10 PC_i = 50;
    #10 PC_i = 55;
    #10 PC_i = 64;
    #10 PC_i = 65;
    #10 PC_i = 66;
    #10 PC_i = 265;
    #10 PC_i = 1024;


end
initial 
   $monitor("PC=%d\t, icode=%h\t, ifun=%h\t, rA=%h\t, rB=%h\nvalC=%h\nvalP=%h\n\nvalE_exe=%h\nnextpc=%h\nvalM_mem=%h\n\nvalE_wb=%h\nvalM_wb=%h\t\n\nStat=%h\t",
   PC_i, icode_o, ifun_o, rA_o, rB_o, valC_o, valP_o,valE_exe,nextpc,valM_mem,valE_wb,valM_wb,Stat);
endmodule