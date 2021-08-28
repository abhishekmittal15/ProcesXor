module demo ();
    wire [3:0] out;
    reg clk;
    reg [3:0] in;
    notgate demogate(in,out);
    initial begin
        in=4'b0;
        clk=1'b1;
        $monitor("time=%g, in=%b,out=%b",$time,in,out);
        #5 $finish;
    end
    always #1 clk=~clk;
    always @(posedge clk)
    begin
        in<=out;
    end
endmodule