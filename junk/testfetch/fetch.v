// The instruction is 10 bytes 
// 0th byte gives us the information about the icode and ifun. This would be extracted by the split module 
// The rest of the 9 bytes tells us about the registers and the immediate values and the destination. This will be extracted by the align module
module split (
    byte0,icode,ifun
);
    parameter w =0 ;
    input [7:0] byte0;
    output [3:0] icode,ifun;
    assign icode=byte0[7:4];
    assign ifun=byte0[3:0];
endmodule

module regids (
    icode,ifun,need_regids,need_valC
);
    parameter w =0 ;
    input [3:0] icode,ifun;
    output need_regids,need_valC;
    assign need_regids=1'b1;
    assign need_valC=1'b0;
endmodule
// I have assigned need_valC and need_regids to 1 for now, but it need not be the case. Need to calculate it.

module align (
    byte1_9,need_valC,need_regids,rA,rB,valC
);
    parameter w =0 ;
    input [71:0] byte1_9;
    input need_regids,need_valC;
    output [3:0] rA,rB;
    output [63:0] valC;
    assign rA=need_regids ? byte1_9[7:4] : 4'hF;
    assign rB=need_regids ? byte1_9[3:0] : 4'hF;
    assign valC= need_valC? byte1_9[71:8] : byte1_9[63:0];
endmodule

module pcIncrement (
    pc,valP
);
    parameter w =0 ;
    input [3:0] pc;
    output [3:0] valP;
    assign valP=pc+4'b1;
endmodule

module memory (read_addr,ins);
    parameter w =0 ;
    input [3:0] read_addr;
    output [w-1:0] ins;
    reg [w-1:0] mem_array[15:0];
    initial $readmemb("data.txt",mem_array);
    integer i=0;
    integer k;
    initial begin
    for (k=0; k<16; k=k+1) $display("%d:%b",k,mem_array[k]);
    end
    assign ins[w-1:0]=mem_array[read_addr];
    initial begin
        $display("%b",ins);
    end
endmodule

module fetch (
    pc,icode,ifun,rA,rB,valC,valP
);
    parameter w =0 ;
    parameter rw =w-8 ;
    parameter  = ;
    input [3:0] pc;
    output [3:0] icode,ifun,rA,rB;
    output [63:0] valC;
    output [3:0] valP;
    wire [79:0] instruction;
    wire need_valC,need_regids,c_needed;
    wire [3:0] code,fun;
    memory  #(.w(w)) instruction_mem(pc,instruction);
    split #(.w(w)) sp(instruction[7:0],code,fun);
    regids  #(.w(w)) re(icode,ifun,need_regids,c_needed);
    align  #(.w(w)) al(instruction[79:8],c_needed,need_regids,rA,rB,valC);
    pcIncrement  #(.w(w)) pci(pc,valP);
    assign icode=code;
    assign ifun=fun;
    assign need_valC=c_needed;
endmodule