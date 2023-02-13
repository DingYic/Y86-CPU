`include "define.v"
module memory_access (
    input wire clk_i,

    input wire[3:0] icode_i,

    input wire[63:0] valE_i,//alu ->valE,address

    input wire[63:0] valA_i,//write data->memory

    input wire[63:0] valP_i,//下一条

    output wire[63:0] valM_o,//read data from memory

    output wire dmem_error_o
);
    reg r_en;
    reg w_en;
    reg[63:0] mem_addr;
    reg[63:0] mem_data;

    always @(*) begin
        case(icode_i)
            `IRMMOVQ :begin
                r_en <=1'b0;
                w_en <=1'b1;
                mem_addr <=valE_i;
                mem_data <=valA_i;
            end
            `ICALL :begin
                r_en <= 1'b0;
                w_en <= 1'b1;
                mem_addr <=valE_i;
                mem_data <=valP_i;
            end
            `IPUSHQ:begin
                r_en <= 1'b0;
                w_en <= 1'b1;
                mem_addr <=valE_i;
                mem_data <=valA_i;
            end
            `IMRMOVQ :begin
                r_en <=1'b1;
                w_en <=1'b0;
                mem_addr <=valE_i;
            end 
            `IRET:begin
                r_en <= 1'b1;
                w_en <= 1'b0;
                mem_addr <=valA_i;
            end
            `IPOPQ:begin
                r_en <= 1'b1;
                w_en <= 1'b0;
                mem_addr <=valA_i;
            end  
            default:begin
                r_en <= 1'b0;
                w_en <= 1'b0;
            end    
        endcase
    end

    ram RAM(
        .clk_i(clk_i),
        .r_en(r_en),
        .w_en(w_en),

        .icode_i(icode_i),
        .addr_i(mem_addr),
        .wdata_i(mem_data),

        .rdata_o(valM_o),
        .dmem_error_o(dmem_error_o)
    );
endmodule

module ram (
    input wire clk_i,
    input wire r_en,
    input wire w_en,
    //
    input reg[3:0] icode_i, 

    input wire[63:0] addr_i,
    input wire [63:0] wdata_i,

    output wire [63:0]rdata_o,

    output reg dmem_error_o
);
    reg[7:0] mem[0:1023];

    always @(*) begin
        dmem_error_o = (addr_i > 1023) ? 1 : 0;
        case(icode_i)
            `IHALT :begin
                dmem_error_o = 0;
            end
            `INOP :begin
                dmem_error_o = 0;
            end
            `ICMOVQ :begin
                dmem_error_o = 0;
            end
            `IOPQ :begin
                dmem_error_o = 0;
            end
            `IRRMOVQ :begin
                dmem_error_o = 0;
            end
            `IIRMOVQ :begin
                dmem_error_o = 0;
            end
            `IJXX :begin
                dmem_error_o = 0;
            end
        endcase
    end
    
    assign rdata_o = (r_en == 1'b1) ? ({
        mem[addr_i + 7],
        mem[addr_i + 6],
        mem[addr_i + 5],
        mem[addr_i + 4],
        mem[addr_i + 3],
        mem[addr_i + 2],
        mem[addr_i + 1],
        mem[addr_i + 0]
    }):64'b0;

    always@(posedge clk_i)
        if(w_en) begin
        {
            mem[addr_i + 7],
            mem[addr_i + 6],
            mem[addr_i + 5],
            mem[addr_i + 4],
            mem[addr_i + 3],
            mem[addr_i + 2],
            mem[addr_i + 1],
            mem[addr_i + 0]
        } <= wdata_i;
    end

initial begin
    mem[0] = 8'h00;
    mem[1] = 8'h01;
    mem[2] = 8'h02;
    mem[3] = 8'h03;
    mem[4] = 8'h04;
    mem[5] = 8'h05;
    mem[6] = 8'h06;
    mem[7] = 8'h07;
    mem[8] = 8'h08;
    mem[9] = 8'h09;
    mem[10] = 8'h0A;
    mem[11] = 8'h0B;
    mem[12] = 8'h0C;
    mem[13] = 8'h0D;
    mem[14] = 8'h0E;
end    

initial begin
		$monitor(
			"
			mem[0]=%h
			mem[1]=%h
			mem[2]=%h
			mem[3]=%h
			mem[4]=%h
			mem[5]=%h
			mem[6]=%h
			mem[7]=%h
			mem[8]=%h
			mem[9]=%h
			mem[10]=%h
			mem[11]=%h
			mem[12]=%h
			mem[13]=%h
			mem[14]=%h
			",
			mem[0],mem[1],mem[2],mem[3],mem[4],mem[5],mem[6],mem[7],
			mem[8],mem[9],mem[10],mem[11],mem[12],mem[13],mem[14]);
	end
endmodule
