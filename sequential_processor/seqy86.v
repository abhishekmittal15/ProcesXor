module alu(
    a,b,fun,out
);

    input [63:0] a,b;
    input [3:0] fun;
    wire [1:0] sel;
    wire addof1,addof2,subof1,subof2;
    assign sel=fun[1:0];
    output [63:0] out;
    wire [63:0] out1,out2,out3,out4,nega;
    fulladder32bit addition1(a[31:0],b[31:0],1'b0,out1[31:0],addof1);
    fulladder32bit addition2(a[63:32],b[63:32],addof1,out1[63:32],addof2);
    // inverse32bit binv(a,nega);
    notgate32bit anot1(a[31:0],nega[31:0]);
    notgate32bit anot2(a[63:32],nega[63:32]);
    fulladder32bit subtraction1(nega[31:0],b[31:0],1'b1,out2[31:0],subof1);
    fulladder32bit subtraction2(nega[63:32],b[63:32],subof1,out2[63:32],subof2);
    andgate32bit andition1(a[31:0],b[31:0],out3[31:0]);
    andgate32bit andition2(a[63:32],b[63:32],out3[63:32]);
    xorgate32bit xorition1(a[31:0],b[31:0],out4[31:0]);
    xorgate32bit xorition2(a[63:32],b[63:32],out4[63:32]);
    mux4way32bit m1(out1[31:0],out2[31:0],out3[31:0],out4[31:0],sel,out[31:0]);
    mux4way32bit m2(out1[63:32],out2[63:32],out3[63:32],out4[63:32],sel,out[63:32]);
endmodule

module processor();
    reg [63:0] pc;
    reg clk;
    integer k;
    // wire [63:0] newpc;
    reg [63:0] newpc;
    reg [79:0] instruction;
    reg [3:0] icode,ifun;
    reg [3:0] rA,rB;
    reg [63:0] valC,valP,valM,valE;
    reg need_regids,need_valC;
    reg [3:0] dstE,dstM,srcA,srcB;
    reg [63:0] valA,valB;
    reg [63:0] aluA,aluB;
    reg [3:0] alufun;
    reg sf,of,zf;
    reg set_cc,Cnd;
    reg read,write;
    reg [63:0] mem_addr,mem_data;
    reg [79:0] ins_mem[1023:0];
    reg signed [63:0] reg_mem[15:0];
    reg signed [63:0] ram_mem[1023:0];
    wire signed [63:0] rax;
    wire signed [63:0] rcx;
    wire signed [63:0] rdx;
    wire signed [63:0] rbx;
    wire signed [63:0] RSP;

    // icode
    parameter halt =4'h0 ;
    parameter nop =4'h1 ;
    parameter rrmovq =4'h2 ;
    parameter irmovq =4'h3 ;
    parameter rmmovq =4'h4 ;
    parameter mrmovq =4'h5 ;
    parameter opq =4'h6 ;
    parameter jxx =4'h7;
    parameter call =4'h8 ;
    parameter ret =4'h9 ;
    parameter pushq =4'hA ;
    parameter popq =4'hB ;

    // ifun
    parameter ADD = 4'h0;
    parameter SUB = 4'h1;
    parameter AND = 4'h2;
    parameter XOR = 4'h3;

    // Branch Conditions
    parameter C_YES = 4'h0;
    parameter C_LE = 4'h1;
    parameter C_L = 4'h2;
    parameter C_E = 4'h3;
    parameter C_NE = 4'h4;
    parameter C_GE = 4'h5;
    parameter C_G = 4'h6;

    // Registers
    parameter rsp = 4'h4 ;
    parameter rnone =4'hF ;
    //fetch stage

    //instruction memory. The reason all of this had to be put together was in the always block everthing is executed sequentially one by one
    always @(posedge clk)
    begin
        pc=newpc;
        instruction=ins_mem[pc];
        // $display("time=%g,clk=%b,%h",$time,clk,instruction);
        
        //Icode and Ifun
        icode=instruction[7:4];
        ifun =instruction[3:0];

        // need registers and valC
        need_regids=(icode==rrmovq | icode==opq | icode==pushq |icode==popq | icode==irmovq | icode===rmmovq | icode==mrmovq)?1'b1:1'b0;

        //register A and register B and valC
        rA=need_regids?instruction[15:12]:rnone;
        rB=need_regids?instruction[11:8]:rnone;
        valC=need_regids?instruction[79:16]:instruction[71:8];

        //to implement the halt condition I just make the valP some arbitrary number. For the nop I just need to increment the pc and everything will be rnone and nothing will be written.
        //ValP -incrementing the pointer
        valP=(icode==halt)?64'h101000:(pc+64'b1);

        //SrcA
        srcA=(icode==rrmovq | icode==rmmovq | icode==opq | icode==pushq)?rA:(icode==popq | icode==ret)?rsp:rnone;

        //SrcB
        srcB=(icode==opq | icode==rmmovq | icode==mrmovq)?rB:(icode==pushq | icode==popq | icode==call | icode==ret)?rsp:rnone;

        //valA and valB
        valA=reg_mem[srcA];
        valB=reg_mem[srcB];

        //AluA
        aluA=(icode==rrmovq | icode==opq)?valA:(icode==irmovq | icode==rmmovq | icode==mrmovq)?valC:(icode==call | icode==pushq)?-64'h1:64'h1;

        //AluB
        aluB=(icode==opq | icode==rmmovq | icode==mrmovq | icode==pushq | icode==popq | icode==call | icode==ret)?valB:(icode==rrmovq | icode==irmovq)?64'b0:64'b0;

        //alufun
        alufun=(icode==opq)?ifun:ADD;

        //ALU-ValE
        valE=   (alufun == SUB) ? aluB-aluA:(alufun == AND) ? aluA & aluB:(alufun == XOR) ? (aluA ^ aluB):(aluA+aluB);
        // alu cpu(aluA,aluB,alufun,valE);
        //ALU-set_cc
        set_cc=(icode==opq)?1'b1:1'b0;

        //ALU-condition codes
        if(set_cc==1'b1)
        begin
        zf = (valE == 64'b0); // ZF
        sf = valE[63]; // SF
        of = (alufun == ADD) ? (aluA[63] == aluB[63]) & (aluA[63] != valE[63]) :
                        alufun == SUB ? (~aluA[63] == aluB[63]) & (aluB[63] != valE[63]) :
                        1'b0; // OF
        end

        //ALU-Cnd
        Cnd= ((ifun == C_YES) |
                (ifun == C_LE & ((sf^of)|zf)) | 
                (ifun == C_L & (sf^of)) |
                (ifun == C_E & zf) | 
                (ifun == C_NE & ~zf) | 
                (ifun == C_GE & (~sf^of)) | 
                (ifun == C_G & (~sf^of)&~zf)); 

        // Memory Stage 

        //Assigning the memory address
        mem_addr=(icode==rmmovq | icode==pushq | icode==call | icode==mrmovq)?valE:(icode==popq | icode==ret)?valA:64'h0;
        //Assigning the data in case of read
        mem_data=(icode==rmmovq | icode==pushq )?valA:(icode==call)?valP:64'b0;
        //Assigning the read control
        read=(icode==mrmovq | icode==popq | icode==ret)?1'b1:1'b0;
        //Assigning the write control
        write=(icode==rmmovq | icode==pushq | icode==call)?1'b1:1'b0;
        //Ram Module
    
        //read
        valM=(read==1'b1)?ram_mem[mem_addr]:64'b0;
        

        //DstE
        dstE=((Cnd & icode==rrmovq) | icode==irmovq | icode==opq)?rB:(icode==pushq | icode==popq | icode==call | icode==ret)?rsp:rnone;
        
        //DstM
        dstM=(icode==mrmovq | icode==popq)? rA:rnone;

        newpc = (icode==call | (icode==jxx & Cnd))?valC:(icode==ret)?valM:valP;
    end
    always @(negedge clk) begin
        reg_mem[dstE]=valE;
        reg_mem[dstM]=valM;
    end
    
    always @(negedge clk) begin
       if (write==1'b1)
        ram_mem[mem_addr]=mem_data;
    end

    assign rax=reg_mem[0];
    assign rcx=reg_mem[1];
    assign rdx=reg_mem[2];
    assign rbx=reg_mem[3];
    assign RSP=reg_mem[4];

    initial begin
        $readmemh("gcd_jmp_call.txt",ins_mem);
        $dumpfile("test.vcd");
        $dumpvars(0,processor);
        newpc=64'b0;
        Cnd=1'b0;
        clk=1'b0;
        //below is for the pc stage
        // $monitor("pc=%d,valP=%d,newpc=%d",pc,valP,newpc);
        //below is for the fetch block
        // $monitor("time=%g,clk=%b,icode=%h,ifun=%h,rA=%h,rB=%h,valC=%d",$time,clk,icode,ifun,rA,rB,valC);
        //below is for the decode block
        // $monitor("time=%g,clk=%b,srcA=%d,srcB=%d,valA=%d,valB=%d,dstE=%d,dstM=%d",$time,clk,srcA,srcB,valA,valB,dstE,dstM);
        //below is for the execute block
        // $monitor("time=%g,clk=%b,aluA=%d,aluB=%d,valE=%d,set_cc=%b,Cnd=%b",$time,clk,pc,aluA,aluB,valE,set_cc,Cnd);
        //below is for the memory block
        // $monitor("time=%g,clk=%b,aluA=%d,aluB=%d,valE=%d,mem_addr=%d,mem_data=%d,read=%b,write=%b,valM=%d",$time,clk,aluA,aluB,valE,mem_addr,mem_data,read,write,valM);
        #500
        begin
        $display("REGISTER\t\t\t\tRAM");
        for(k=0;k<16;k++)
            $display("%d:%d   %d",k,reg_mem[k],ram_mem[k]);
        $finish;
        end
    end
    always #1 clk=~clk;
endmodule


