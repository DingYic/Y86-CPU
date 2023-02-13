`include "define.v"
module decode(
	input wire clk_i,
	input wire rst_n_i, //0是复位
	input wire [3:0] icode_i,
	input wire [3:0] rA_i,
	input wire [3:0] rB_i,
	
	input wire[63:0] valM_i, 
	input wire[63:0] valE_i,

	input wire Cnd_i,//写回阶段的CMOVQ需要

	output wire [63:0] valA_o,
	output wire [63:0] valB_o	
);
	reg [63:0] regfile[14:0];
	reg [3:0] srcA,srcB;
	reg [3:0] dstE,dstM;
	always @(*) begin
		case(icode_i)
			`IHALT : begin
				srcA = `RNONE;
				srcB = `RNONE;
				dstE = `RNONE;
				dstM = `RNONE;
				end
			`INOP :begin
				srcA = `RNONE;
				srcB = `RNONE;
				dstE = `RNONE;
				dstM = `RNONE;
			end
			//1
			`ICMOVQ :begin
				srcA = rA_i;
				srcB = `RNONE;
				if(Cnd_i)begin
					dstE = rB_i;
				end
				dstM = `RNONE;
			end
			`IRRMOVQ :begin
				srcA = rA_i;
				srcB = `RNONE;
				dstE = rB_i;
				dstM = `RNONE;
			end
			`IIRMOVQ :begin
				srcA = `RNONE;
				srcB = `RNONE;
				dstE = rB_i;
				dstM = `RNONE;
			end
			`IRMMOVQ :begin
				srcA = rA_i;
				srcB = rB_i;
				dstE = `RNONE;
				dstM = `RNONE;
			end
			`IMRMOVQ :begin
				srcA = `RNONE;
				srcB = rB_i;
				dstE = `RNONE;
				dstM = rA_i;
			end
			`IOPQ :begin
				srcA = rA_i;
				srcB = rB_i;
				dstE = rB_i;
				dstM = `RNONE;
			end
			`IJXX :begin
				srcA = `RNONE;
				srcB = `RNONE;
				dstE = `RNONE;
				dstM = `RNONE;
			end
			`ICALL :begin
				srcA = `RNONE;
				srcB = `RESP;//%rsp = 4
				dstE = `RESP;
				dstM = `RNONE;
			end
			`IRET :begin
				srcA = `RESP;//%rsp = 4
				srcB = `RESP;//%rsp = 4
				dstE = `RESP;
				dstM = `RNONE;
			end
			`IPUSHQ :begin
				srcA = rA_i;
				srcB = `RESP;//%rsp = 4
				dstE = `RESP;
				dstM = `RNONE;
			end
			`IPOPQ:begin
				srcA = `RESP;
				srcB = `RESP;//%rsp = 4
				dstE = `RESP;
				dstM = rA_i;
			end
			default: begin
				srcA = `RNONE;
				srcB = `RNONE;
				dstE = `RNONE;
				dstM = `RNONE;
			end
		endcase
	end

	assign valA_o = (srcA == `RNONE)?64'b0 : regfile[srcA];
	assign valB_o = (srcB == `RNONE)?64'b0 : regfile[srcB];

	always @(posedge clk_i) begin
		if(~rst_n_i) begin
				regfile[0] <= 64'd0;
				regfile[1] <= 64'd1;
				regfile[2] <= 64'd2;
				regfile[3] <= 64'd3;
				regfile[4] <= 64'd4;
				regfile[5] <= 64'd5;
				regfile[6] <= 64'd6;
				regfile[7] <= 64'd7;
				regfile[8] <= 64'd8;
				regfile[9] <= 64'd9;
				regfile[10] <= 64'd10;
				regfile[11] <= 64'd11;
				regfile[12] <= 64'd12;
				regfile[13] <= 64'd13;
				regfile[14] <= 64'd14;
		end 
		else begin
			if(dstE != `RNONE) begin
				regfile[dstE] <= valE_i;
			end

			if(dstM != `RNONE) begin
				regfile[dstM] <= valM_i;
			end
		end
	end
	initial begin
			regfile[0] = 64'd0;
			regfile[1] = 64'd1;
			regfile[2] = 64'd2;
			regfile[3] = 64'd3;
			regfile[4] = 64'd4;
			regfile[5] = 64'd5;
			regfile[6] = 64'd6;
			regfile[7] = 64'd7;
			regfile[8] = 64'd8;
			regfile[9] = 64'd9;
			regfile[10] = 64'd10;
			regfile[11] = 64'd11;
			regfile[12] = 64'd12;
			regfile[13] = 64'd13;
			regfile[14] = 64'd14;
			end
endmodule
