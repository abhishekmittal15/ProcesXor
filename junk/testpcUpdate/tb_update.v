module updatetb ();
    reg [3:0] icode;
    reg Cnd;
    reg [63:0] valC,valM,valP;
    wire [63:0] newpc;
    updatePC up(icode,Cnd,valC,valM,valP,newpc);
    initial begin
        $monitor("time=%g,icode=%d,PC=%d ",$time,icode,newpc);
        valC=64'hA;
        valM=64'h20;
        valP=64'h2;
        Cnd=1'b1;
        icode=4'b0;
        #10 icode=4'h7;
        #10 icode=4'h8;
        #10 icode=4'h9;
        #50 $finish;
    end    
endmodule