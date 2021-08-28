// This is the executing block 

module alu(aluA,aluB,alufun,valE,new_cc);
    input [31:0] aluA,aluB;
    input [3:0] alufun;
    output [31:0] valE;
    output [2:0] new_cc;

    parameter ALUADD = 4'h0;
    parameter ALUSUB = 4'h1;
    parameter ALUAND = 4'h2;
    parameter ALUXOR = 4'h3;

    assign  valE=
            alufun == ALUSUB ? aluA-aluB:
            alufun == ALUAND ? aluA & aluB:
            alufun == ALUXOR ? aluA ^ aluB:
            aluA+aluB;
    assign new_cc[2] = (valE == 0); // ZF
    assign new_cc[1] = valE[63]; // SF
    assign new_cc[0] = alufun == ALUADD ? (aluA[63] == aluB[63]) & (aluA[63] != valE[63]) :
                        alufun == ALUSUB ? (~aluA[63] == aluB[63]) & (aluB[63] != valE[63]) :
                        0; // OF
endmodule

module set (
    icode ,set_cc
);
    input [3:0] icode;
    output set_cc;
    assign set_cc=(icode!=4'h6);
endmodule

module condition_codes(
    cc,set_cc,alufun,Cnd
);
    input [2:0] cc;
    input set_cc;
    input [3:0] alufun;
    output Cnd;
    wire zf,sf,of;
    assign zf=cc[2];
    assign sf=cc[1];
    assign of=cc[0];
    parameter C_YES = 4'h0;
    parameter C_LE = 4'h1;
    parameter C_L = 4'h2;
    parameter C_E = 4'h3;
    parameter C_NE = 4'h4;
    parameter C_GE = 4'h5;
    parameter C_G = 4'h6;

    assign Cnd =(set_cc) & ((alufun == C_YES) |
                (alufun == C_LE & ((sf^of)|zf)) | 
                (alufun == C_L & (sf^of)) |
                (alufun == C_E & zf) | 
                (alufun == C_NE & ~zf) | 
                (alufun == C_GE & (~sf^of)) | 
                (alufun == C_G & (~sf^of)&~zf)); 
endmodule

module execute (
    icode,ifun,valC,valA,valB,valE,Cnd
);
    input [3:0] icode,ifun;
    input [31:0] valA,valB,valC;
    output [31:0] valE;
    output Cnd;
    wire set_cc;
    wire [31:0] aluA,aluB;
    wire [2:0] new_cc;
    wire [3:0] alufun;
    assign aluA=valA;
    assign aluB=valB;
    assign alufun=ifun;
    alu alublock(aluA,aluB,alufun,valE,new_cc);
    set cc(icode,set_cc);
    condition_codes ccc(new_cc,set_cc,alufun,Cnd);
endmodule