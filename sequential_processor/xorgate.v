// `include "andgate.v"
// `include "orgate.v"
module xorgate(
    a,b,out
);
    input a,b;
    output out;
    notgate na(a,nota);
    notgate nb(b,notb);
    andgate first(a,notb,outa);
    andgate second(b,nota,outb);
    orgate ans(outa,outb,out);
endmodule