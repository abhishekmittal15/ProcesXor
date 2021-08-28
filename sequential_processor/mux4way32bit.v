// `include "mux4way.v"
module mux4way32bit (
    a,b,c,d,sel,out
);
    input [31:0] a,b,c,d;
    input [1:0] sel;
    output [31:0] out;
    mux4way m0(a[0],b[0],c[0],d[0],sel,out[0]);
    mux4way m1(a[1],b[1],c[1],d[1],sel,out[1]);
    mux4way m2(a[2],b[2],c[2],d[2],sel,out[2]);
    mux4way m3(a[3],b[3],c[3],d[3],sel,out[3]);
    mux4way m4(a[4],b[4],c[4],d[4],sel,out[4]);
    mux4way m5(a[5],b[5],c[5],d[5],sel,out[5]);
    mux4way m6(a[6],b[6],c[6],d[6],sel,out[6]);
    mux4way m7(a[7],b[7],c[7],d[7],sel,out[7]);
    mux4way m8(a[8],b[8],c[8],d[8],sel,out[8]);
    mux4way m9(a[9],b[9],c[9],d[9],sel,out[9]);
    mux4way m10(a[10],b[10],c[10],d[10],sel,out[10]);
    mux4way m11(a[11],b[11],c[11],d[11],sel,out[11]);
    mux4way m12(a[12],b[12],c[12],d[12],sel,out[12]);
    mux4way m13(a[13],b[13],c[13],d[13],sel,out[13]);
    mux4way m14(a[14],b[14],c[14],d[14],sel,out[14]);
    mux4way m15(a[15],b[15],c[15],d[15],sel,out[15]);
    mux4way m16(a[16],b[16],c[16],d[16],sel,out[16]);
    mux4way m17(a[17],b[17],c[17],d[17],sel,out[17]);
    mux4way m18(a[18],b[18],c[18],d[18],sel,out[18]);
    mux4way m19(a[19],b[19],c[19],d[19],sel,out[19]);
    mux4way m20(a[20],b[20],c[20],d[20],sel,out[20]);
    mux4way m21(a[21],b[21],c[21],d[21],sel,out[21]);
    mux4way m22(a[22],b[22],c[22],d[22],sel,out[22]);
    mux4way m23(a[23],b[23],c[23],d[23],sel,out[23]);
    mux4way m24(a[24],b[24],c[24],d[24],sel,out[24]);
    mux4way m25(a[25],b[25],c[25],d[25],sel,out[25]);
    mux4way m26(a[26],b[26],c[26],d[26],sel,out[26]);
    mux4way m27(a[27],b[27],c[27],d[27],sel,out[27]);
    mux4way m28(a[28],b[28],c[28],d[28],sel,out[28]);
    mux4way m29(a[29],b[29],c[29],d[29],sel,out[29]);
    mux4way m30(a[30],b[30],c[30],d[30],sel,out[30]);
    mux4way m31(a[31],b[31],c[31],d[31],sel,out[31]);
endmodule