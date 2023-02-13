`include "define.v"
module writeback (
    input wire[3:0] icode_i,
    input wire[63:0] valE_i,
    input wire[63:0] valM_i,

    input wire instr_valid_i,
    input wire imem_error_i,
    input wire dmem_error_i,

    output wire[63:0] valE_o,
    output wire[63:0] valM_o,

    output wire[3:0] stat_o
);
assign valE_o = valE_i;
assign valM_o = valM_i;

stat stat_module(
    .icode_i(icode_i),
    .instr_valid_i(instr_valid_i),
    .imem_error_i(imem_error_i),
    .dmem_error_i(dmem_error_i),
    .stat_o(stat_o)
);
endmodule

module stat(
    input wire [3:0] icode_i,
    input wire instr_valid_i,
    input wire imem_error_i,
    input reg dmem_error_i,
    output wire[3:0] stat_o
);

    //课后题4.27
    assign stat_o =(!instr_valid_i)? `SINS://4
    (icode_i == `IHALT)? `SHLT://2
     (imem_error_i|| dmem_error_i) ? `SADR://3
    `SAOK;//1


endmodule
