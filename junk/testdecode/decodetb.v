module decodetb ();
    reg [3:0] icode,rA,rB;
    reg Cnd;
    reg [31:0] valM,valE;
    wire [31:0] valA,valB;
    decode_write dw(icode,rA,rB,Cnd,valA,valB,valM,valE);
    initial begin
        icode=4'd6;
        rA=4'b0;
        rB=4'b1;
        valE=32'd8;
        $monitor("time=%g valA=%d valB=%d",$time,valA,valB);
        #40 $finish;
    end
    // always #10 rA=rA+1;
    // always #10 rB=rB+1;

endmodule