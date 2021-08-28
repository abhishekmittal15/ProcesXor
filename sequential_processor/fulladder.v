// `include "halfadder.v"
module fulladder(a,b,c,result,carry);
input a,b,c;
output result,carry;
wire c1,c2,temp;
halfadder ha1(.a(a),.b(b),.result(temp),.carry(c1));
halfadder ha2(.a(temp),.b(c),.result(result),.carry(c2));
orgate car(c1,c2,carry);
endmodule