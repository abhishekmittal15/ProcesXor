// `include "fulladder.v"
module fulladder32bit (
    a,b,c_in,out,c_out
);
    input [31:0] a,b;
    input c_in;
    output [31:0] out;
    output c_out;
    wire [31:0] c;
    fulladder bit0(a[0],b[0],c_in,out[0],c[0]);
    fulladder bit1(a[1],b[1],c[0],out[1],c[1]);
    fulladder bit2(a[2],b[2],c[1],out[2],c[2]);
    fulladder bit3(a[3],b[3],c[2],out[3],c[3]);
    fulladder bit4(a[4],b[4],c[3],out[4],c[4]);
    fulladder bit5(a[5],b[5],c[4],out[5],c[5]);
    fulladder bit6(a[6],b[6],c[5],out[6],c[6]);
    fulladder bit7(a[7],b[7],c[6],out[7],c[7]);
    fulladder bit8(a[8],b[8],c[7],out[8],c[8]);
    fulladder bit9(a[9],b[9],c[8],out[9],c[9]);
    fulladder bit10(a[10],b[10],c[9],out[10],c[10]);
    fulladder bit11(a[11],b[11],c[10],out[11],c[11]);
    fulladder bit12(a[12],b[12],c[11],out[12],c[12]);
    fulladder bit13(a[13],b[13],c[12],out[13],c[13]);
    fulladder bit14(a[14],b[14],c[13],out[14],c[14]);
    fulladder bit15(a[15],b[15],c[14],out[15],c[15]);
    fulladder bit16(a[16],b[16],c[15],out[16],c[16]);
    fulladder bit17(a[17],b[17],c[16],out[17],c[17]);
    fulladder bit18(a[18],b[18],c[17],out[18],c[18]);
    fulladder bit19(a[19],b[19],c[18],out[19],c[19]);
    fulladder bit20(a[20],b[20],c[19],out[20],c[20]);
    fulladder bit21(a[21],b[21],c[20],out[21],c[21]);
    fulladder bit22(a[22],b[22],c[21],out[22],c[22]);
    fulladder bit23(a[23],b[23],c[22],out[23],c[23]);
    fulladder bit24(a[24],b[24],c[23],out[24],c[24]);
    fulladder bit25(a[25],b[25],c[24],out[25],c[25]);
    fulladder bit26(a[26],b[26],c[25],out[26],c[26]);
    fulladder bit27(a[27],b[27],c[26],out[27],c[27]);
    fulladder bit28(a[28],b[28],c[27],out[28],c[28]);
    fulladder bit29(a[29],b[29],c[28],out[29],c[29]);
    fulladder bit30(a[30],b[30],c[29],out[30],c[30]);
    fulladder bit31(a[31],b[31],c[30],out[31],c[31]);
    assign c_out=c[31];
endmodule