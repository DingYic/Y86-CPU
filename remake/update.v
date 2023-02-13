`include "define.v"
module update(
    input wire clk_i,

    input wire rst_n_i,//0是复位
    input wire instr_valid_i,//???
    input wire[3:0] icode_i,
    input wire Cnd_i,
    input wire[63:0] valC,
    input wire[63:0] valM, 
    input wire[63:0] valP,
    output reg [63:0] nextpc
);
    // always @(*) begin
    //     case(icode_i)
    //         `IJXX :begin
    //             if(Cnd_i)
    //                 nextpc = valC;
    //             else
    //                 nextpc = valP;
    //         end
    //         `ICALL:begin
    //             nextpc = valC;
    //         end
    //         `IRET :begin
    //             nextpc = valM;
    //         end
    //         default:begin
    //             nextpc = valP;
    //         end
    //     endcase
    // end
    reg[63:0] tmpPC;
    always @(posedge clk_i) begin
        case(icode_i)
            `IJXX :begin
                if(Cnd_i)
                    tmpPC = valC;
                else
                    tmpPC = valP;
            end
            `ICALL:begin
                tmpPC = valC;
            end
            `IRET :begin
                tmpPC = valM;
            end
            default:begin
                tmpPC = valP;
            end
        endcase
        nextpc = tmpPC;
    end
endmodule
