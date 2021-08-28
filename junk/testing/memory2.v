module readmemh_demo;

reg [31:0] Mem [0:11];

initial $readmemh("data.txt",Mem,0,5);

integer k;
initial begin
#10;
// $display("Contents of Mem after reading data file:");
for (k=0; k<6; k=k+1) $display("%d:%h",k,Mem[k]);
end

endmodule