module demo();
parameter f=0;
initial begin
    
$display("my f is %d",f);
end
endmodule

module controller ();
    parameter g=10 ;
    parameter h=g-9;
    demo #(.f(h)) dem();
endmodule