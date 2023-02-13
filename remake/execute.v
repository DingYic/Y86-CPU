`include "define.v" 
module execute (
    input wire clk_i,
    input wire rst_n_i,

    input wire [3:0] icode_i,
    input wire [3:0] ifun_i,
    //常数 指令里面拿到的
    input wire signed[63:0] valA_i,
    input wire signed[63:0] valB_i,
    input wire signed[63:0] valC_i,

    output reg signed[63:0] valE_o,
    
    output wire Cnd_o //跳转或者不跳转 
);
    reg signed[63:0] aluA;
    reg signed[63:0] aluB;
    reg [3:0] alu_fun;
    reg [2:0] cc;
    reg [2:0] new_cc;
    
    wire set_cc;
    
always @(*) begin
    case(icode_i)
        //
        `ICMOVQ :begin
            aluA = valA_i;
            aluB = 0;
        end
        `IRRMOVQ :begin
            aluA = valA_i;
            aluB = 0;
        end
        `IIRMOVQ :begin
            aluA = valC_i;
            aluB = 0;
        end
        `IRMMOVQ :begin
            aluA = valC_i;
            aluB = valB_i;
        end
        `IMRMOVQ :begin
            aluA = valC_i;
            aluB = valB_i;
        end
        `IOPQ :begin
            aluA = valA_i;
            aluB = valB_i;
        end
        `ICALL :begin
            aluA = -8;
            aluB = valB_i;
        end
        //
        `IRET :begin
            aluA = 8;
            aluB = valB_i;
        end
        `IPUSHQ :begin
            aluA = -8;
            aluB = valB_i;
        end
        `IPOPQ :begin
            aluA = 8;
            aluB = valB_i;
        end
        default :begin
        end
    endcase
end

always @(*) begin
    if(icode_i == `IOPQ)
        alu_fun = ifun_i;
    else
        alu_fun = `ALUADD;
end

always @(*) begin
    case(alu_fun)
        `ALUADD :begin
            valE_o = aluA + aluB;
        end

        `ALUSUB :begin
            valE_o = aluB - aluA;
        end

        `ALUAND :begin
            valE_o = aluB & aluA;
        end

        `ALUXOR :begin
            valE_o = aluB ^ aluA;
        end
    endcase
end

always @(*) begin
    if(~rst_n_i) begin
        new_cc[2] = 1;//ZF
        new_cc[1] = 0;//SF
        new_cc[0] = 0;//OF
    end
    else if(alu_fun == `FADDQ)begin//修改前
    // else if(icode_i == `IOPQ)begin//修改后
        new_cc[2] = (valE_o == 0) ? 1 : 0;//ZF
        new_cc[1] = valE_o[63];//SF
        new_cc[0] = 
        (alu_fun == `ALUADD) ?
        (aluA[63] == aluB[63]) & (aluA[63]!=valE_o[63]):
        (alu_fun == `ALUSUB) ?
        (~aluA[63] == aluB[63]) & (aluB[63] != valE_o[63]) : 
        0;
    end
end

assign set_cc = (icode_i == `IOPQ) ? 1 : 0; //可不可以往里面存到cc里面去

always @(posedge clk_i) begin
    if(~rst_n_i)//n是取反的意思
        cc <= 3'b100;
    else if (set_cc) begin
        cc <= new_cc;
        end
end

wire sf,of,zf;
//default 1 0 0
assign zf = new_cc[2];//zf
assign of = new_cc[1];//sf
assign sf = new_cc[0];//of

assign Cnd_o =  //cnd 条件 是否传送
    (ifun_i == `C_YES) |
    (ifun_i == `C_LE  & ((sf^  of) | zf))| //<=
    (ifun_i == `C_L   & (sf ^ of)) | //<
    (ifun_i == `C_E   & zf)|  // ==
    (ifun_i == `C_NE  & ~zf)| //!=
    (ifun_i == `C_GE  & ~(sf ^ of))| //>=
    (ifun_i == `C_G   &(~(sf ^ of) & ~zf)); //>

endmodule
