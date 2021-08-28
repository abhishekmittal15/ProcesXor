module memtb ();
    reg [7:0] din;
    reg [1:0] write_addr,read_addr,
    reg rd,wr,clk;
    wire dout;

    memory mem(din,write_addr,read_addr,dout,rd,wr,clk);
    initial begin
        $monitor("t=%g,output=%d",$time,dout);
        clk=0;
        rd=1;
        wr=0;
        read_addr=3'b000;
        write_addr=3'b010;
        din=2'b11;

        forever begin
            #5 clk=~clk;
        end
    end

    always #5 write_addr=write_addr+1;
endmodule