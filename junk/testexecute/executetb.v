module executetb ();
    reg [3:0] icode,ifun;
    reg [31:0] valA,valB,valC;
    wire signed [31:0] valE;
    wire Cnd;
    execute ex(icode,ifun,valC,valA,valB,valE,Cnd);
    initial begin
        icode=4'h6;
        ifun=4'h1;
        valA=32'd5;
        valB=32'd7;
        $monitor("time=%g a=%d b=%d out=%d code=%b",$time,valA,valB,valE,Cnd);
    end
endmodule