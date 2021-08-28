module pipereg(out,in,stall,bubble,resetval,clk);
    parameter width=5;
    output [width-1:0] out;
    reg [width-1:0] out;
    input [width-1:0] in,resetval;
    input stall,bubble,clk;
    always @(posedge clk) begin
        if(bubble==1'b1)
            out<=resetval;
        else if(stall==1'b0)
            out<=in;
    end
endmodule

module alu(aluA,aluB,alufun,valE,new_cc);
    input [63:0] aluA,aluB;
    input alufun;
    output [63:0] valE;
    output [2:0] new_cc;

    // Operations that CPU can do
    parameter ADD = 4'h0;
    parameter SUB = 4'h1;
    parameter AND = 4'h2;
    parameter XOR = 4'h3;

    assign valE=   (alufun == SUB) ? aluA-aluB:(alufun == AND) ? aluA & aluB:(alufun == XOR) ? (aluA ^ aluB):(aluA+aluB);

    assign new_cc[2] = (valE == 0); // ZF
    assign new_cc[1] = valE[63]; // SF
    assign new_cc[0] = (alufun == ADD) ? (aluA[63] == aluB[63]) & (aluA[63] != valE[63]) :
                        alufun == SUB ? (~aluA[63] == aluB[63]) & (aluB[63] != valE[63]) :
                        0; // OF

endmodule

module processor ();
    integer k;
    //icode
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
    parameter fnone=4'h0 ;

    // Operations that CPU can do
    parameter ADD = 4'h0;
    parameter SUB = 4'h1;
    parameter AND = 4'h2;
    parameter XOR = 4'h3;
    
    //jump conditions
    parameter uncond = 4'h0;

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

    //status conditions
    parameter sbub =3'h0 ;
    parameter saok =3'h1 ;
    parameter shlt =3'h2 ;
    parameter sadr =3'h3 ;
    parameter sins =3'h4 ;
    parameter spip =3'h5 ;

    //clk signal 
    reg clk;

    //fetch stage signals
    wire f_ok=1;
    wire imem_error=0;
    wire need_regids=1;
    wire need_valC=1;
    wire instr_valid=1;
    wire F_stall=1'b0;
    wire F_bubble=1'b0;
    wire [63:0] f_pc=0;
    wire [63:0] F_predpc=64'b0;
    wire [63:0] f_valC=0;
    wire [63:0] f_valP=0;
    wire [63:0] f_predpc=64'b0;
    wire [2:0] f_stat=1;
    wire [3:0] imem_code=0;
    wire [3:0] imem_ifun=0;
    wire [3:0] f_ifun=0;
    wire [3:0] f_rA=0;
    wire [3:0] f_rB=0;
    wire [3:0] f_icode=4'h0;
    wire [79:0] f_instr=0;

    //decode stage signals
    wire [2:0] D_stat=1;
    wire [63:0] D_pc=0;
    wire [63:0] D_valC=0;
    wire [63:0] D_valP=0;
    wire [63:0] d_valA=0;
    wire [63:0] d_valB=0;
    wire [63:0] d_rvalA=0;
    wire [63:0] d_rvalB=0;
    wire [3:0] D_ifun=0;
    wire [3:0] D_rA=0;
    wire [3:0] D_rB=0;
    wire [3:0] d_dstE=0;
    wire [3:0] d_dstM=0;
    wire D_stall=1'b0;
    wire D_bubble=1'b0;
    wire [3:0] d_srcA=4'h0;
    wire [3:0] d_srcB=4'h0;
    wire [3:0] D_icode=4'h0;

    //execute stage signals
    wire E_stall=1'b0;
    wire E_bubble=1'b0;
    wire [2:0] E_stat=1;
    wire [2:0] cc=0;
    wire [2:0] new_cc=0;
    wire [3:0] E_ifun=0;
    wire [3:0] E_dstE=0;
    wire [3:0] e_dstE=0;
    wire [3:0] E_dstM=4'h0;
    wire [3:0] E_srcA=4'h0;
    wire [3:0] E_srcB=4'h0;
    wire [63:0] E_pc=0;
    wire [63:0] E_valC=0;
    wire [63:0] E_valA=0;
    wire [63:0] E_valB=0;
    wire [63:0] aluA=0;
    wire [63:0] aluB=0;
    wire [63:0] e_valE=0;
    wire [63:0] e_valA=0;
    wire [3:0] E_icode=4'h0;

    //condition codes 
    wire zf=cc[2];
    wire sf=cc[1];
    wire of=cc[0];

    //memory stage signals
    wire M_Cnd=0;
    wire mem_read=0;
    wire mem_write=0;
    wire M_stall=1'b0;
    wire M_bubble=1'b0;
    wire m_ok=1;
    wire [2:0] M_stat=1;
    wire [2:0] m_stat=1;
    wire [3:0] M_ifun=0;
    wire [3:0] M_dstE=0;
    wire [3:0] M_dstM=0;
    wire [63:0] M_pc=0;
    wire [63:0] M_valE=0;
    wire [63:0] M_valA=0;
    wire [63:0] mem_addr=0;
    wire [63:0] mem_data=0;
    wire [63:0] m_valM=0;
    wire [3:0] M_icode=4'h0;

    //write-back stage signals 
    wire W_stall=1'b0;
    wire W_bubble=1'b0;
    wire [2:0] W_stat=1;
    wire [3:0] W_dstE=0;
    wire [3:0] W_dstM=0;
    wire [3:0] w_dstE=0;
    wire [3:0] w_dstM=0;
    wire [63:0] W_pc=0;
    wire [63:0] W_valE=0;
    wire [63:0] W_valM=0;
    wire [63:0] w_valE=0;
    wire [63:0] w_valM=0;
    wire [3:0] W_icode=4'h0;

    //Memories-instruction,register and ram
    reg [79:0] ins_mem[15:0];
    reg [63:0] reg_mem[15:0];
    reg [63:0] ram_mem[15:0];

    //global status
    wire [2:0] Stat=1;

    // Pipeline registers . It is similar to multiple always blocks which concurrently get trigerred at the posedge of the clk
    
    // This the pipeline register for the fetch block
    pipereg #(64) f_predpc_reg(F_predpc,f_predpc,F_stall,F_bubble,64'b0,clk);

    // This the pipeline register for the decode block
    
    pipereg #(3) D_stat_reg(D_stat, f_stat, D_stall, D_bubble, sbub, clk);
    pipereg #(64) D_pc_reg(D_pc, f_pc, D_stall, D_bubble, 64'b0, clk);
    pipereg #(4) D_icode_reg(D_icode, f_icode, D_stall, D_bubble, nop, clk);
    pipereg #(4) D_ifun_reg(D_ifun, f_ifun, D_stall, D_bubble, fnone, clk);
    pipereg #(4) D_rA_reg(D_rA, f_rA, D_stall, D_bubble, rnone, clk);
    pipereg #(4) D_rB_reg(D_rB, f_rB, D_stall, D_bubble, rnone, clk);
    pipereg #(64) D_valC_reg(D_valC, f_valC, D_stall, D_bubble, 64'b0, clk);
    pipereg #(64) D_valP_reg(D_valP, f_valP, D_stall, D_bubble, 64'b0, clk);
    
    // These are the pipeline registers for the Execute stage

    pipereg #(3) E_stat_reg(E_stat, D_stat, E_stall, E_bubble, sbub, clk);
    pipereg #(64) E_pc_reg(E_pc, D_pc, E_stall, E_bubble, 64'b0, clk);
    pipereg #(4) E_icode_reg(E_icode, D_icode, E_stall, E_bubble, nop, clk);
    pipereg #(4) E_ifun_reg(E_ifun, D_ifun, E_stall, E_bubble, fnone, clk);
    pipereg #(64) E_valC_reg(E_valC, D_valC, E_stall, E_bubble, 64'b0, clk);
    pipereg #(64) E_valA_reg(E_valA, d_valA, E_stall, E_bubble, 64'b0, clk);
    pipereg #(64) E_valB_reg(E_valB, d_valB, E_stall, E_bubble, 64'b0, clk);
    pipereg #(4) E_dstE_reg(E_dstE, d_dstE, E_stall, E_bubble, rnone, clk);
    pipereg #(4) E_dstM_reg(E_dstM, d_dstM, E_stall, E_bubble, rnone, clk);
    pipereg #(4) E_srcA_reg(E_srcA, d_srcA, E_stall, E_bubble, rnone, clk);
    pipereg #(4) E_srcB_reg(E_srcB, d_srcB, E_stall, E_bubble, rnone, clk);

    //These are the pipeline registers for the Memory stage
    pipereg #(3) M_stat_reg(M_stat, E_stat, M_stall, M_bubble, sbub, clk);
    pipereg #(64) M_pc_reg(M_pc, E_pc, M_stall, M_bubble, 64'b0, clk);
    pipereg #(4) M_icode_reg(M_icode, E_icode, M_stall, M_bubble, nop, clk);
    pipereg #(4) M_ifun_reg(M_ifun, E_ifun, M_stall, M_bubble, fnone, clk);
    pipereg #(1) M_Cnd_reg(M_Cnd, e_Cnd, M_stall, M_bubble, 1'b0, clk);
    pipereg #(64) M_valE_reg(M_valE, e_valE, M_stall, M_bubble, 64'b0, clk);
    pipereg #(64) M_valA_reg(M_valA, e_valA, M_stall, M_bubble, 64'b0, clk);
    pipereg #(4) M_dstE_reg(M_dstE, e_dstE, M_stall, M_bubble, rnone, clk);
    pipereg #(4) M_dstM_reg(M_dstM, E_dstM, M_stall, M_bubble, rnone, clk);

    //These are the pipeline registers for the Write Back stage

    pipereg #(3) W_stat_reg(W_stat, m_stat, W_stall, W_bubble, sbub, clk);
    pipereg #(64) W_pc_reg(W_pc, M_pc, W_stall, W_bubble, 64'b0, clk);
    pipereg #(4) W_icode_reg(W_icode, M_icode, W_stall, W_bubble, nop, clk);
    pipereg #(64) W_valE_reg(W_valE, M_valE, W_stall, W_bubble, 64'b0, clk);
    pipereg #(64) W_valM_reg(W_valM, m_valM, W_stall, W_bubble, 64'b0, clk);
    pipereg #(4) W_dstE_reg(W_dstE, M_dstE, W_stall, W_bubble, rnone, clk);
    pipereg #(4) W_dstM_reg(W_dstM, M_dstM, W_stall, W_bubble, rnone, clk);

    //Fetch Stage 

    // Fetch- Extract the instruction from the instruction memory
    assign f_instr=ins_mem[f_pc];
    // $display("instruction=%h",f_instr);
    //Fetch - split
    assign imem_icode=f_instr[7:4];
    assign imem_ifun=f_instr[3:0];

    //Fetch - align
    assign f_rA=need_regids?f_instr[15:12]:rnone;
    assign f_rB=need_regids?f_instr[11:8]:rnone;
    assign f_valC=need_regids?f_instr[79:16]:f_instr[71:8];

    //Fetch- pc Increment
    assign f_valP=f_pc+1;

    //Fetch- Pipeline control
    // assign f_pc=((M_icode==jxx)& ~M_Cnd)?M_valA:(W_icode==ret)?W_valM:F_predpc;
    assign f_icode=(imem_error)?nop:imem_icode;
    assign f_ifun=(imem_error)?fnone:imem_ifun;
    assign instr_valid=(f_icode==halt | f_icode==nop | f_icode==rrmovq | f_icode==irmovq| f_icode==rmmovq | f_icode==mrmovq| f_icode==opq | f_icode==jxx | f_icode==call | f_icode==ret | f_icode==pushq | f_icode==popq);
    assign f_stat=(imem_error ? sadr :(~instr_valid)?sins:(f_icode==halt)?shlt:saok);
    assign need_regids=(f_icode==rrmovq | f_icode==opq | f_icode==pushq | f_icode==popq | f_icode==irmovq | f_icode==rmmovq | f_icode==mrmovq);
    assign need_valC=(f_icode==irmovq | f_icode==rmmovq | f_icode==mrmovq | f_icode==jxx | f_icode==call);


    //Decode Stage 

    // Decode Stage- reading from the memory

    assign d_rvalA=reg_mem[d_srcA];
    assign d_rvalB=reg_mem[d_srcB];

    //Decode stage -pipeline logic
    assign d_srcA=((D_icode==rrmovq | D_icode==rmmovq | D_icode==opq | D_icode==pushq | D_icode==popq | D_icode==ret)?rsp:rnone);

    assign d_srcB =((D_icode == opq | D_icode == rmmovq | D_icode == mrmovq) ? D_rB : (
    D_icode == pushq | D_icode == popq | D_icode == call | D_icode
    == ret) ? rsp : rnone);

    assign d_dstE =((D_icode == rrmovq | D_icode == irmovq | D_icode == opq) ? D_rB : (
    D_icode == pushq | D_icode == popq | D_icode == call | D_icode
    == ret) ? rsp : rnone);

    assign d_dstM =((D_icode == mrmovq | D_icode == popq) ? D_rA : rnone);

    assign d_valA =((D_icode == call | D_icode == jxx) ? D_valP : (d_srcA == e_dstE) ?
    e_valE : (d_srcA == M_dstM) ? m_valM : (d_srcA == M_dstE) ? M_valE :
    (d_srcA == W_dstM) ? W_valM : (d_srcA == W_dstE) ? W_valE : d_rvalA);

    assign d_valB =((d_srcB == e_dstE) ? e_valE : (d_srcB == M_dstM) ? m_valM : (d_srcB
    == M_dstE) ? M_valE : (d_srcB == W_dstM) ? W_valM : (d_srcB ==
    W_dstE) ? W_valE : d_rvalB);

    //Decode- Storing the data at the negative edge of the clock
    always @(negedge clk) begin
        reg_mem[w_dstE]=w_valE;
        reg_mem[w_dstM]=w_valM;
    end

    

    //Execute stage 

    // Execute Stage-ALU

    alu cpu(aluA,aluB,alufun,e_valE,new_cc);
    
    // pipereg #(3) condition_codes(cc,new_cc,set_cc,reset,3'b100,clk);
    pipereg #(3) condition_codes(cc,new_cc,set_cc,1'b0,3'b100,clk);

    //Execute stage - Cnd signal

    assign Cnd=((E_ifun == C_YES) |
                (E_ifun == C_LE & ((sf^of)|zf)) | 
                (E_ifun == C_L & (sf^of)) |
                (E_ifun == C_E & zf) | 
                (E_ifun == C_NE & ~zf) | 
                (E_ifun == C_GE & (~sf^of)) | 
                (E_ifun == C_G & (~sf^of)&~zf)); 


    //Execute Stage -pipeline logic
    assign aluA =
    ((E_icode == rrmovq | E_icode == opq) ? E_valA : (E_icode == irmovq
    | E_icode == rmmovq | E_icode == mrmovq) ? E_valC : (E_icode ==
    call | E_icode == pushq) ? -64'b1 : (E_icode == ret | E_icode == popq
    ) ? 64'b1 : 64'b0);

    assign aluB =((E_icode == rmmovq | E_icode == mrmovq | E_icode == opq | E_icode
    == call | E_icode == pushq | E_icode == ret | E_icode == popq)
    ? E_valB : (E_icode == rrmovq | E_icode == irmovq) ? 0 : 0);

    assign alufun =((E_icode == opq) ? E_ifun : ADD);

    assign set_cc =(((E_icode == opq) & ~(m_stat == sadr | m_stat == sins | m_stat ==
    shlt)) & ~(W_stat == sadr | W_stat == sins | W_stat == shlt));

    assign e_valA =E_valA;

    assign e_dstE =(((E_icode == rrmovq) & ~e_Cnd) ? rnone : E_dstE);

    
    // Memory Stage 

    //Memory Stage -pipeline logic
    assign mem_addr =((M_icode == rmmovq | M_icode == pushq | M_icode == call | M_icode
    == mrmovq) ? M_valE : (M_icode == popq | M_icode == ret) ?
    M_valA : 0);
    
    assign mem_read =(M_icode == mrmovq | M_icode == popq | M_icode == ret);

    assign mem_write =(M_icode == rmmovq | M_icode == pushq | M_icode == call);

    assign m_stat =(dmem_error ? sadr : M_stat);

    // We have to write the logic for the f_ok and m_ok, but for now I will just assign it 1'b1
    assign f_ok=1'b1;
    assign m_ok=1'b1;
    assign imem_error=~f_ok;
    assign dmem_error=~m_ok;

    

    // Write-back Stage 

    // Write-back Stage pipeline logic
    
    assign w_dstE =W_dstE;
    assign w_valE =W_valE;
    assign w_dstM =W_dstM;
    assign w_valM =W_valM;
    assign Stat =((W_stat == sbub) ? saok : W_stat);

    //Fetch- stalling and bubbling

    // assign F_bubble =1'b0;

    // assign F_stall =(((E_icode == mrmovq | E_icode == popq) & (E_dstM == d_srcA | E_dstM== d_srcB)) | (D_icode==ret | E_icode==ret | M_icode==ret));

    //Decode stage-stalling and bubbling
    // assign D_stall =((E_icode == mrmovq | E_icode == popq) & (E_dstM == d_srcA | E_dstM
    //  == d_srcB));

    // assign D_bubble =(((E_icode == jxx) & ~e_Cnd) | (~((E_icode == mrmovq | E_icode ==
    //  popq) & (E_dstM == d_srcA | E_dstM == d_srcB)) & (ret ==
    //  D_icode | ret == E_icode | ret == M_icode)));


    //Execute Stage- stalling and bubbling

    // assign E_stall =1'b0;

    // assign E_bubble =(((E_icode == jxx) & ~e_Cnd) | ((E_icode == mrmovq | E_icode == popq
    // ) & (E_dstM == d_srcA | E_dstM == d_srcB)));

    // //Memory stage-stalling and bubbling
    // assign M_stall =1'b0;
    // assign M_bubble =((m_stat == sadr | m_stat == sins | m_stat == shlt) | (W_stat == sadr
    // | W_stat == sins | W_stat == shlt));

    //Write-back Stage- stalling and bubbling
    
    // assign W_stall =(W_stat == sadr | W_stat == sins | W_stat == shlt);
    // assign W_bubble =1'b0;
    
    //End of the processor
    
    initial begin
        $readmemh("ins.txt",ins_mem);
        clk=1'b0;
        // $display("Instruction memory");
        // for(k=0;k<5;k++)
        //     $display("k=%d:%h",k,ins_mem[k]);
        $monitor("time=%g ,clk=%b, F_stall=%b f_predpc=%d F_predpc=%d f_pc=%d f_instr=%h f_icode=%d",$time,clk,F_stall,f_predpc,F_predpc,f_pc,f_instr,f_icode);
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
        #5 $finish;
        // begin
        // $display("REGISTER\t\t\t\tRAM");
        // for(k=0;k<16;k++)
        //     $display("%d:%d   %d",k,reg_mem[k],ram_mem[k]);
        // $finish;
        // end
    end
    always #1 clk=~clk;
endmodule