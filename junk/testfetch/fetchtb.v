module fetchtb ();
    reg [3:0] pc;
    wire [3:0]icode,ifun,rA,rB;
    wire [63:0] valC;
    wire [3:0] valP;
    fetch fet( pc,icode,ifun,rA,rB,valC,valP);
    initial begin
        pc=4'b0;
        $monitor("t=%g,icode=%b ifun=%b rA=%b rB=%b val_C=%b valP=%b",$time,icode,ifun,rA,rB,valC,valP);
    end
endmodule