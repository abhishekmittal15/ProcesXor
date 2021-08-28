// `include "andgate.v"
module andgate32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] out
);
    andgate bit0(a[0],b[0],out[0]);
    andgate bit1(a[1],b[1],out[1]);
    andgate bit2(a[2],b[2],out[2]);
    andgate bit3(a[3],b[3],out[3]);
    andgate bit4(a[4],b[4],out[4]);
    andgate bit5(a[5],b[5],out[5]);
    andgate bit6(a[6],b[6],out[6]);
    andgate bit7(a[7],b[7],out[7]);
    andgate bit8(a[8],b[8],out[8]);
    andgate bit9(a[9],b[9],out[9]);
    andgate bit10(a[10],b[10],out[10]);
    andgate bit11(a[11],b[11],out[11]);
    andgate bit12(a[12],b[12],out[12]);
    andgate bit13(a[13],b[13],out[13]);
    andgate bit14(a[14],b[14],out[14]);
    andgate bit15(a[15],b[15],out[15]);
    andgate bit16(a[16],b[16],out[16]);
    andgate bit17(a[17],b[17],out[17]);
    andgate bit18(a[18],b[18],out[18]);
    andgate bit19(a[19],b[19],out[19]);
    andgate bit20(a[20],b[20],out[20]);
    andgate bit21(a[21],b[21],out[21]);
    andgate bit22(a[22],b[22],out[22]);
    andgate bit23(a[23],b[23],out[23]);
    andgate bit24(a[24],b[24],out[24]);
    andgate bit25(a[25],b[25],out[25]);
    andgate bit26(a[26],b[26],out[26]);
    andgate bit27(a[27],b[27],out[27]);
    andgate bit28(a[28],b[28],out[28]);
    andgate bit29(a[29],b[29],out[29]);
    andgate bit30(a[30],b[30],out[30]);
    andgate bit31(a[31],b[31],out[31]);
endmodule