module memory (
    // din,write_addr,read_addr,dout,rd,wr,cs,clk
);
    // input [1:0] din;
    // input [2:0] read_addr,write_addr;
    // output [1:0] dout;
    // input rd,wr,cs,clk;

    reg [1:0] memory_array[0:7];
    // reg [1:0] dout;

    initial $readmemb("data.txt",memory_array,0,7);

    // // Read operation
    // always @(posedge clk) begin
    //     if (rd) begin
    //         d_out=memory_array[read_addr];
    //     end
    // end

    // // Write operation
    // always @(posedge clk) begin
    //     if (wr) begin
    //         memory_array[write_addr]=din;
    //     end
    // end

    integer k;
    initial begin
    for (k=0; k<8; k=k+1) $display("%d:%b",k,memory_array[k]);
    end

endmodule