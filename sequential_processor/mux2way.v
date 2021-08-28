// sel a b y
// 0   0 0 0
// 0   0 1 0
// 0   1 0 1
// 0   1 1 1
// 1   0 0 0
// 1   0 1 1
// 1   1 0 0
// 1   1 1 1

// the logic is y=or(and(a,not(sel)),and(b,sel))
// `include "andgate.v"
// `include "orgate.v"
module mux2way (
    a,b,sel,y
);
    input a,b,sel;
    output y;
    wire anotsel,bsel,notsel;
    notgate nsel(sel,notsel);
    andgate anda(a,notsel,anotsel);
    andgate andb(b,sel,bsel);
    orgate op(anotsel,bsel,y);
endmodule