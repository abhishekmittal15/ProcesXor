// `include "notgate.v"
module notgate32bit(a,out);
input [31:0] a;
output [31:0] out;
notgate bit0(a[0],out[0]);
notgate bit1(a[1],out[1]);
notgate bit2(a[2],out[2]);
notgate bit3(a[3],out[3]);
notgate bit4(a[4],out[4]);
notgate bit5(a[5],out[5]);
notgate bit6(a[6],out[6]);
notgate bit7(a[7],out[7]);
notgate bit8(a[8],out[8]);
notgate bit9(a[9],out[9]);
notgate bit10(a[10],out[10]);
notgate bit11(a[11],out[11]);
notgate bit12(a[12],out[12]);
notgate bit13(a[13],out[13]);
notgate bit14(a[14],out[14]);
notgate bit15(a[15],out[15]);
notgate bit16(a[16],out[16]);
notgate bit17(a[17],out[17]);
notgate bit18(a[18],out[18]);
notgate bit19(a[19],out[19]);
notgate bit20(a[20],out[20]);
notgate bit21(a[21],out[21]);
notgate bit22(a[22],out[22]);
notgate bit23(a[23],out[23]);
notgate bit24(a[24],out[24]);
notgate bit25(a[25],out[25]);
notgate bit26(a[26],out[26]);
notgate bit27(a[27],out[27]);
notgate bit28(a[28],out[28]);
notgate bit29(a[29],out[29]);
notgate bit30(a[30],out[30]);
notgate bit31(a[31],out[31]);
endmodule