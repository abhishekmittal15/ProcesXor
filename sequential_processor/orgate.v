// the logic is or(a,b)=nand(nota,notb)
// `include "notgate.v"
module orgate (
    a,b,y
);
    input a,b;
    output y;
    wire nota,notb;
    notgate anot(a,nota);
    notgate bnot(b,notb);
    nand (y,nota,notb);
endmodule
