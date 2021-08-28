// This is the block where the pc is updated 
// I have taken the constant values and the program counters as 8 bytes here. Find out if they are 4bytes or not and then accordingly change the 63 to 31.
module updatePC (
    icode,Cnd,valC,valM,valP,newpc
);
    input [3:0] icode;
    input Cnd,clk;
    input [63:0] valC,valM,valP;
    output [63:0] newpc;
    assign newpc = ((icode==4'h7 & Cnd) | icode==4'h8)? valC :(icode==4'h9) ?valM:valP;     
endmodule

// 4'h7 is for jump and valC is the new program counter, 4'h8 is for call and again valC is the new program counter, 4'h9 is for return and the valM is the program counter

// During call how do i send the valP-current program counter to the memory
//here my newpc is a wire so what I am thinking is to create a separate register that is driven by this wire but is clocked, so it only changes the input pc of the fetch module when the posedge of the clock is triggered.