
// this can be constructed using 3 single bit muxes 
// `include "mux2way.v"
module mux4way (
    in0,in1,in2,in3,sel,y
);
    input in0,in1,in2,in3;
    input [1:0] sel;
    output y;
    wire upper,lower;
    mux2way m11(in0,in1,sel[0],upper);
    mux2way m12(in2,in3,sel[0],lower);
    mux2way m2(upper,lower,sel[1],y);
endmodule