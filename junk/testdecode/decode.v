// This is the decoding block and write back block, since the same set of registers are used

module register_file (
    dstE,dstM,srcA,srcB,valM,valE,valA,valB
);
    input [3:0] dstE,dstM,srcA,srcB;
    input [31:0] valM,valE;
    input read,write;
    output [31:0] valA,valB;
    reg [31:0] reg_mem[15:0];
    initial begin
        $readmemb("reg_data.txt",reg_mem);
    end
    
    integer k;
    initial begin
        for(k=0;k<16;k=k+1) $display("%d",reg_mem[k]);
    end

    assign valA=reg_mem[srcA];
    assign valB=reg_mem[srcB];
    
    always @(dstE,dstM) begin
        reg_mem[dstE]=valE;
        reg_mem[dstM]=valM;
    end
endmodule

module destE (
    Cnd,icode,rB,dstE
);
    input Cnd;
    input [3:0] icode;
    input [3:0] rB;
    output [3:0] dstE;
    assign dstE= (icode ==4'h6 | icode==4'h3 | icode==4'h2)?rB:4'hF; 
endmodule

module decode_write(
    icode,rA,rB,Cnd,valA,valB,valM,valE
);
    input [3:0] icode,rA,rB;
    input [31:0] valE,valM;
    input Cnd;
    output [31:0] valA,valB;
    wire [3:0] dstE,dstM;
    destE de(Cnd,icode,rB,dstE);
    assign dstM=4'hF;
    register_file regfile(dstE,dstM,rA,rB,valM,valE,valA,valB);
endmodule