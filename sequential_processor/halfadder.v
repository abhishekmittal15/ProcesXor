// `include "xorgate.v"
module halfadder (
    a,b,result,carry
);
    input a,b;
    output result,carry;
    xorgate bit0(a,b,result);
    andgate bit1(a,b,carry);
endmodule