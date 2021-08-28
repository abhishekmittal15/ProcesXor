# Processor based on the y86 architecture

The sequantial processor finishes executing one instruction in 1 clock cycle. So the entire processor can be just triggered at the posedge of the clock. Now to prevent any sort of clashes, I write the data which is calculated from either valM or valE in the memory or the register file at the negative edge of the clock.
There are 5 stages in this processor
An overview of the sequential processor 
![](https://i.imgur.com/5YrzTi3.png)

## Sequential Block Diagrams
1. Fetch Stage
![](https://i.imgur.com/7YOP76L.png)
2. Decode Stage and Write Back
![](https://i.imgur.com/oiVY4fk.png)
3. Execute Stage
![](https://i.imgur.com/fhSNcfb.png)
4. Memory Stage
![](https://i.imgur.com/ox7vEak.png)
5. PC update stage 
![](https://i.imgur.com/pfdlGs2.png)

## Processor Features

In this implementation I have separated my instruction memory and RAM


| Memory | Number of register | Size of each Register |
| -------- | -------- | -------- |
| Instruction     | 1024| 10bytes/80bits   |
|RAM |1024|8bytes/64bits|
|Register file|16|8bytes/64bits|
The register file is quad ported, meaning it supports 2 simultaneous reads and writes. 

My processor reads a a txt file which contains the instructions line by line in hexadecimal format. This is done by the command in verilog called the ```$readmemh``` command. This command reads an entire line of text into a single 10 byte register. So my valP=pc+1 everytime.

To give instructions in the ins.txt file the format of the instruction is 
```valC/Dest/D:rA:rB:icode:ifun```

## Steps to run my processor 

Since my processor takes the input from a text file and then coverts it to hexadecimal and then stores the instructions in the memory.
Step1: You can feed in custom instruction encodings(according to the format given above) in a text file. 
Step2: In the seqy86.v file in the initial block there is a command $readmemh which loads the text file into the instruction memory. By default it is the gcd_jmp_call.txt file which uses jump,call and ret to calculate the gcd. You can change its input values by changing the numbers before 'f030' to your desired value
Step2: ```iverilog *.v``` to run all the files 
Step3: ```vvp a.out``` to see the output of the final state of the registers and ram.
Step 4: ```gtkwave test.vcd``` to see the clockwise output of various wires and registers in the processor. 
## List of instructions 
My sequential processor can execute all of the y86 instructions

| Instruction | Actual encoding | My encoding |
| -------- | -------- | -------- |
| halt    | 00     | 00     |
|nop|10 |10|
|rrmovq|20 rA rB| rA rB 20|
|irmovq |30 F rB valC| valC F rB 30|
|rmmovq |40 rA rB D|D rA rB 40|
|mrmovq |50 rA rB D|D rA rB 50|
|opq|6 fn rA rB|rA rB 6 fn|
|jXX|7 fn D|D 7 fn|
|cmovXX| 2 fn rA rB | rA rB 2 fn|
|call|80 D|D 80|
|ret| 90 | 90|
|pushq| A0 rA F| rA F A0|
|popq| B0 rA F| rA F B0|

## HCF 

The following is the C code that I used to design my assembly code. The logic is:
Step 1: Check if both the numbers are same or not. If they are then gcd is found else go to step 4
Step 2: Check which one is greater and subtract the smaller number from the larger number and carry forward the subtracted value and the smaller value in the next loop
Step 3: go to step1 
Step 4: Answer is found
```c=
#include <stdio.h>
int main()
{
    int n1, n2;
    
    printf("Enter two positive integers: ");
    scanf("%d %d",&n1,&n2);

    while(n1!=n2)
    {
        if(n1 > n2)
            n1 -= n2;
        else
            n2 -= n1;
    }
    printf("GCD = %d",n1);

    return 0;
}
```
The following is the y86 code that I wrote from the above C code

```yaml=
irmovq $999,%rsp  // initialising the stack pointer to a large value 
call main         // calling the main function
halt              // After the main function is executed we halt   
loop:             // The loop that actually finds the gcd
rrmovq %rcx,%rdx
subq %rax,%rdx
je ans            // if gcd is found then we jump to storing the answer
jl csmallerthana  // This is a part of finding the gcd logic
subq %rax,%rcx
jmp loop          // this jmp condition jumps to the loop back again   
csmallerthana:    
subq %rcx,%rax
jmp loop
ans:              // Here our answer is stored in the rbx register
rrmovq %rax,%rbx
ret               // After the answer is found we go back to the main 
main:
irmovq $10,%rax   // Initializing the registers(rax and rcx) with numbers 
irmovq $5,%rcx    // whose gcd we want to find 
call loop         // calling the loop to find gcd
ret               // transferring control back to the top
```
The below is the instructions file generated from the assembly code written. Here I have added the program counter at the start of each line for better readability.
```instructions file
pc=00:3e7f430  //irmovq $999,%rsp
pc=01:D80      //  call main
pc=02:00       //  halt
pc=03:1220     //  loop starts 
pc=04:0261     //  subq rax and rdx        
pc=05:1173     //  je ans         
pc=06:972      //  jl csmallerthana           
pc=07:0161     //  subq %rax,%rcx
pc=08:370      //  jmp loop
pc=09:1061     //  subq %rcx,%rax
pc=0A:370      //  jmp loop
pc=0B:0320     //  rrmovq %rax,%rbx   
pc=0C:90       //  ret
pc=0D:af030    //  irmovq $10,%rax   
pc=0E:5f130    //  irmovq $5,%rcx      
pc=0F:380      //  call loop   
pc=10:90       //  ret
```

#### I will demonstrate the 3 examples I used 

My inputs go into rax and rcx and my output is stored finally in rbx
##### Example 1

I am storing 10 in %rax and 5 in %rcx. Now at the end of the computation the %rbx register must have 5 in it.

The gtk wave output is below
![](https://i.imgur.com/QCCQqYL.png)


The instruction is read at the posedge of every clock. 

**Instruction pc=0**
Since I am using the call function I have to first store a large value in the stack pointer to have enough stacks to use. I hence put 999 stacks into the register using the irmovq command. 

**Instruction pc=1**
I am now calling my main function, where the values are stored into the registers and the necessary functions are called. From the gtkwave figure we can see that my pc now jumps from 1 to 13. 

**Instruction pc=13 and pc=14**
Now I am in my main function. The first instruction in this main function is to move 10 into %rax and the next instruction moves 5 into %rcx. On observing RSP we notice that we are the 998th stack. 

**Instruction pc=15**
I am calling another function called loop which calculates the gcd. Now I jump to that function 

**Instruction pc=3**
Again I am on another stack, so we can see that our stack pointer decrease. I am moving my %rcx to %rdx temporarily 

**Instruction pc=4**
To check their equality, we now subtract both of them. so subq %rax,%rdx. This sets our condition codes and the Cnd flag. In this case the value is -5. 

**Instruction pc=5**
Now I want to jump if they are equal to the answer block. It is not in this case, so we continue the execution without jumping . We can see the Cnd flag to be 0.

**Instruction pc=6**
Our condition codes dont change because we didnt encounter a new op instruction. So we recalculate the Cnd flag, since the sign flag was set, our Cnd flag is set. From the gtkwave we see that our Cnd is 1. Hence we now jump

**Instruction pc=9**
As mentioned in the logic, we need to carry forward the smaller value and the subtracted value. So we are doing the same. This block is executed when rcx is smaller than rax. So we subtract rcx from rax and then carry forward rax and rcx. 

**Instruction pc=10**
Now that we have calculated the new rax and rcx values we are jumping back to the loop

**Instruction pc=3**
The new rax and rcx is 5. Now, I move the rcx temporarily to rdx.

**Instruction pc=4**
Now I subtract both the registers %rax and %rdx and check their equality. They turn out to be equal, so we have found our gcd.

**Instruction pc=5**
 We jump out of the loop, and we go the ans block

**Instruction pc=11**
We are in the ans block, and this moves the value of the gcd in %rax to %rbx.

**Instruction pc=12**
Now that the computation is over, we return to the main function using the ret. Notice our stack pointer has increased since we have freed one stack(it becomes 998 from 997) 

**Instruction pc=16**
Now we are in the main function and we are performing another return, so out stack pointer increases again from 998 to 999, we go to the top of the program


**Instruction pc=2**
When the main function is executed then it returns back to this position to execute the next instruction. The instruction is halt which stops the processor, and our pc goes to some arbitrary location.

##### Example 2
I will store 100 and 80 in rax and rcx respectively. Finally rbx must have 20

![](https://i.imgur.com/JTWrLnD.png)

##### Example 3

I will store 9 and 5 in rax and rcx respectively. Since they are coprime, we must get 1 in rbx finally.

![](https://i.imgur.com/dmInpN2.png)

# Pipeline Processor

My pipeline processor doesnt work.
## Pipeline Block Diagrams 

Here instead of 5 stages we have 4 stages only because we merged the pc_update stage with the fetch stage. But here we introduce 5 pipeline registers which separate the stages. 

### Stage 1 : Fetch and  Pc update

![](https://i.imgur.com/ravy7Aa.png)
Here we can see that we have to carefully select our PC.
The program counter which has to fetch the instruction from the memory has 3 different sources. 
1. Mispredicted branch: so to get the correct program counter we have to use the M_valA value
2. return instruction : If the return instruction enters the write back stage then the return address is W_valM
3. Rest of the cases: valP is used
By default during the fetching of a jxx instruction we pick the valC program counter and continue(i.e. we assume the condition is true and continue forward)


### Stage 2: Decode and Write-back Stages

![](https://i.imgur.com/WY6N4Pn.png)

The most important part of this stage is the Sel+FwdA block. Right now we have to carry the valA and the valP signal(because if branch is mispredicted, then we must be able to correctly jump back to the right branch). But whenever there is such jump condition, then valA is not required, so we can just choose which to pass to the valA, either the actual valA or valP. 
Also in the Sel+Fwd A and then Fwd B blocks we notice a lot of outputs of the subsequent blocks. This is because we want to reduce our wastage of clock cycles by directly supplying input of the computations to the decode stage for the next set of computations. This is called data forwarding. 

### Stage 3: Execute Stage

![](https://i.imgur.com/74Wp7Hb.png)

Set_cc is the most important block, because it decides when the condition codes should get updated. The Cnd wire is either set or not based on these condition codes and it decides whether or not should the branch be chnaged or not in the PC_Update Stage. That is why the M_cnd is fed back to the Select_pc to inform it whether it should have jumped or not.
The rest of the executions remain the same as it was for the sequential design 

### Stage 4: Memory Stage 
![](https://i.imgur.com/0I1EgYe.png)


### Pipeline stalling and bubbling logic 

![](https://i.imgur.com/XgIfAxE.png)

1. Fetch Stage 

```c
assign F_bubble =1'b0;
assign F_stall =(((E_icode == mrmovq | E_icode == popq) & (E_dstM == d_srcA | E_dstM== d_srcB)) | (D_icode==ret | E_icode==ret | M_icode==ret));
```

We never bubble the fetch stage, we keep stalling it. So the need for stalling the fethc stage arises when 
* If its a return instruction in the subsequent stages(decode,execute,memory) then we want to wait for the rsp to get updated before we call the next instruction(valP).
* When we want to move something from the memory to the register and the decode stage needs those register's values. 


2. Decode Stage
```c=
assign D_stall =((E_icode == mrmovq | E_icode == popq) & (E_dstM == d_srcA | E_dstM== d_srcB));

assign D_bubble =(((E_icode == jxx) & ~e_Cnd) | (~D_stall & (D_icode==ret | E_icode==ret | M_icode==ret)));

```

We will stall our bubble stage only when the stages ahead are in bubble condition, that is their execution matters. The only case when this will happen is when the executs stage is computing some values that the current register need, that is when the E_dstM is either d_srcA or d_srcB

We will want to bubble our decode stage (i.e. keep executing the nop instruction) only when it is either 
* return instruction in the subsequent stages: if the decode is made to continue the execution it might change some register values which is not desired.
*  When the execute stage has a jump instruction but the branch condition is executed to be false. As mentioned above, the program counter automatically jumps to the Dest mentioned in the jXX instruction, so we need to stop the processor before it moves ahead
* The obvious condition is that the decode stage should not be in stall and in bubble at the same time. so we negate it 


3. Execute Stage 

```c=
assign E_stall =1'b0;
assign E_bubble =(((E_icode == jxx) & ~e_Cnd) | D_stall);
```

In this stage we dont need to stall it, because we dont want our alu to continuously keep operating on the same valA and valB, this can lead to memory overflow in case of addtion and other problems

We bubble our execute stage only when : 
* The previous stage Decode is stalling 
* The jump condition is false, so we finish the execution and dont operate on any more new values, rather we continue operating the nop instruction, to prevent affecting the registers


