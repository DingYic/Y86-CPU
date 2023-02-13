`include "define.v"

module fetch(
   input wire [63:0] PC_i,
   output wire [3:0] icode_o,
   output wire[3:0] ifun_o,
   output wire[3:0] rA_o,
   output wire[3:0] rB_o,
   output wire[63:0] valC_o,
   output wire[63:0] valP_o,
   output wire instr_valid_o,
   output wire imem_error_o

);

   reg[7:0]  instr_mem[0:1023];
   wire[79:0] instr;
   wire     need_regids;
   wire     need_valC;
    
   assign imem_error_o = (PC_i > 1023);
   assign instr={
   instr_mem[PC_i + 9],instr_mem[PC_i + 8],instr_mem[PC_i + 7],
   instr_mem[PC_i + 6],instr_mem[PC_i + 5],instr_mem[PC_i + 4],
   instr_mem[PC_i + 3],instr_mem[PC_i + 2],instr_mem[PC_i + 1],
   instr_mem[PC_i + 0]
};

initial begin
   //push
    instr_mem[0] = 8'ha0;
    instr_mem[1] = 8'h2f;
    instr_mem[2] = 8'h08;
    instr_mem[3] = 8'h00;
    instr_mem[4] = 8'h00;
    instr_mem[5] = 8'h00;
    instr_mem[6] = 8'h00;
    instr_mem[7] = 8'h00;
    instr_mem[8] = 8'h00;
    instr_mem[9] = 8'h00;
    //pop
    instr_mem[10] = 8'hb0;
    instr_mem[11] = 8'h4f;
    instr_mem[12] = 8'h15;
    instr_mem[13] = 8'h00;
    instr_mem[14] = 8'h00;
    instr_mem[15] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;



   //opq 0
    instr_mem[20] = 8'h60;
    instr_mem[21] = 8'h28;
    instr_mem[22] = 8'h08;
    instr_mem[23] = 8'h00;
    instr_mem[24] = 8'h00;
    instr_mem[25] = 8'h00;
    instr_mem[26] = 8'h00;
    instr_mem[27] = 8'h00;
    instr_mem[28] = 8'h00;
    instr_mem[29] = 8'h00;
   //opq 1
    instr_mem[30] = 8'h61;
    instr_mem[31] = 8'h43;
    instr_mem[32] = 8'h15;
    instr_mem[33] = 8'h00;
    instr_mem[34] = 8'h00;
    instr_mem[35] = 8'h00;
    instr_mem[16] = 8'h00;
    instr_mem[17] = 8'h00;
    instr_mem[18] = 8'h00;
    instr_mem[19] = 8'h00;
   //opq 2
    instr_mem[20] = 8'h62;
    instr_mem[21] = 8'h65;
    instr_mem[22] = 8'h12;
    instr_mem[23] = 8'h00;
    instr_mem[24] = 8'h00;
    instr_mem[25] = 8'h00;
    instr_mem[26] = 8'h00;
    instr_mem[27] = 8'h00;
    instr_mem[28] = 8'h00;
    instr_mem[29] = 8'h00;
   //irmovq
    instr_mem[30] = 8'h30;
    instr_mem[31] = 8'hf8;
    instr_mem[32] = 8'h08;
    instr_mem[33] = 8'h00;
    instr_mem[34] = 8'h00;
    instr_mem[35] = 8'h00;
    instr_mem[36] = 8'h00;
    instr_mem[37] = 8'h00;
    instr_mem[38] = 8'h00;
    instr_mem[39] = 8'h00;
   //rrmovq
    instr_mem[40] = 8'h22;
    instr_mem[41] = 8'h25;
    instr_mem[42] = 8'h12;
    instr_mem[43] = 8'h00;
    instr_mem[44] = 8'h00;
    instr_mem[45] = 8'h00;
    instr_mem[46] = 8'h00;
    instr_mem[47] = 8'h00;
    instr_mem[48] = 8'h00;
    instr_mem[49] = 8'h00;
       
   
end

assign icode_o = instr[7:4];
assign ifun_o  = instr[3:0];
assign instr_valid_o = (icode_o < 4'hC);
assign need_regids = (icode_o == `ICMOVQ)||(icode_o == `IIRMOVQ)||
(icode_o == `IRMMOVQ)||(icode_o == `IMRMOVQ)||
(icode_o == `IOPQ)||(icode_o == `IPUSHQ)||
(icode_o == `IPOPQ);

assign need_valC = (icode_o == `IIRMOVQ)||
(icode_o == `IRMMOVQ)||(icode_o == `IMRMOVQ)||
(icode_o == `IJXX)||(icode_o == `ICALL);

assign rA_o = need_regids?instr[15:12] : 4'hF;
assign rB_o = need_regids?instr[11:8] : 4'hF;

assign valC_o = need_regids ? instr[79:16] : instr[71:8];

assign valP_o = PC_i + 1 + 8*need_valC + need_regids;



endmodule
