// the logic is not(a)=nand(a,a)

module notgate (
    a,y
);
    input a;
    output y;
    nand (y,a,a);
endmodule