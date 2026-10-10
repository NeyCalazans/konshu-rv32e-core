#------------------------------------------------------------------------------
# UFSC_V (RV32E) - a program to test the instructions this core implements
#
# Adapted from the MIPS_S test program "Allinsts_MIPS_S.txt"
# (original author: Ney Calazans, nlvcalazans@gmail.com), keeping the same
# verification intent (each instruction class is exercised at least once,
# followed by a vector-add loop and a nested subroutine call test).
#
# This testbench was developed considering the compact memory format presented in
# the RISC-V simulator RARS. The text base addres is 0x00000000 and the data segment
# base address is 0x00002000.
#
# What changed relative to the MIPS_S original:
#
#  1. Removed entirely: multu, mfhi, mflo, divu.
#     RV32I/E has no Hi/Lo registers, and this core's ALU has no multiply or
#     divide opcode.
#
#  2. Removed: nor, RV32I has no NOR instruction.
#
#  3. Register renaming (this core is RV32E: only x0-x15 exist).
#     Mapping used below:
#       $t0,$t1,$t2                -> t0, t1, t2      (kept as-is)
#       $t3,$t4,$t5,$t6,$t7,$t8    -> a0, a1, a2, a3, a4, a5
#       $s2 (shift-amount reg)     -> s1
#       $zero, $sp, $ra            -> zero, sp, ra
#     a0-a5 are reused across the file's independent sections exactly like
#     the original reused $t3 for unrelated purposes across sections.
#
#  4. Immediate values recomputed for RV32I encoding.
#     MIPS andi/ori/xori take a 16-bit ZERO-extended immediate; RV32I
#     andi/ori/xori/addi take a 12-bit SIGN-extended immediate. A few of the
#     original's 16-bit literals (e.g. 0xffab) do not fit in 12 bits at all,
#     so new immediates were chosen for those steps. This changes some
#     intermediate numeric values (documented per instruction below), but
#     each instruction still gets exercised the same way. One instruction
#     was added (`ori t0,t0,0x80`) purely to set the sign bit before the
#     right-shift-by-register sequence, so `srai`/`sra` actually demonstrate
#     sign propagation.
#
#  5. Branch/jump mnemonics.
#     bgez rs,label  -> bge  rs, zero, label
#     blez rs,label  -> bge  zero, rs, label
#     j label        -> j label (standard RISC-V pseudo-op for jal zero,label)
#     jr rs          -> jr rs   (standard pseudo-op for jalr zero,rs,0)
#     la/li          -> la/li  (both are RISC-V pseudo-ops too, same names)
#
#  7. Added: lh/lhu/sh test (array+8), right after the lbu/sb one.
#    
#------------------------------------------------------------------------------
        .text
        .globl  main
#------------------------------------------------------------------------------
# First, individual instruction tests
#------------------------------------------------------------------------------
main:
        lui     t0,0xf30        #
        ori     t0,t0,0x23      # t0<= 0x00f30000 | 0x23 = 0x00f30023
        lui     t1,0x520        #
        ori     t1,t1,0xe2      # t1<= 0x00520000 | 0xe2 = 0x005200e2
        lui     t2,0            #
        ori     t2,t2,0x8f      # t2<= 0x0000008f
        beq     t1,t2,loop      # This instruction must never jump
        bne     t1,t2,next_i    # This instruction must always jump
        addi    t2,t2,0x8f      # This instruction must never execute  
next_i:
        add     a0,t0,t1        # a0<= 0x00f30023 + 0x005200e2 = 0x01450105 ---CHECK---
        sub     a1,t0,t1        # a1<= 0x00f30023 - 0x005200e2 = 0x00a0ff41 ---CHECK---
        sub     a2,t1,t1        # a2<= 0x00000000                          ---CHECK---
        and     a3,t0,t1        # a3<= 0x00f30023 and 0x005200e2 = 0x00520022
        or      a4,t0,t1        # a4<= 0x00f30023 or  0x005200e2 = 0x00f300e3
        xor     a5,t0,t1        # a5<= 0x00f30023 xor 0x005200e2 = 0x00a100c1
        addi    t0,t0,0xab      # t0<= 0x00f30023 + 0x000000ab = 0x00f300ce
        andi    t0,t0,0xab      # t0<= 0x00f300ce and 0x000000ab = 0x0000008a
        xori    t0,t0,0x2ab     # t0<= 0x0000008a xor 0x000002ab = 0x00000221
        slli    t0,t0,4         # t0<= 0x00002210 (shifts 4 bits to the left)
        srli    t0,t0,9         # t0<= 0x00000011 (shifts 9 bits to the right)
        ori     t0,t0,0x80      # t0<= 0x00000091 (sets bit 7, so the shifts
                                 #     below have a sign bit worth preserving)
        addi    s1,zero,8       # s1<= 0x00000008
        sll     t0,t0,s1
                # t0<= 0x00009100 - shifts t0 8 bits to the left, inserting 0s
        sll     t0,t0,s1
                # t0<= 0x00910000 - shifts t0 8 bits to the left, inserting 0s
        sll     t0,t0,s1
                # t0<= 0x91000000 - shifts t0 8 bits to the left, inserting 0s
        srai    t0,t0,4
                # t0<= 0xf9100000 - shifts t0 4 bits to the right, keeping sign
        sra     t0,t0,s1
                # t0<= 0xfff91000 - shifts t0 8 bits to the right, keeping sign
        srl     t0,t0,s1
                # t0<= 0x00fff910 - shifts t0 8 bits to the right, inserting 0s
        la      t0,array
                # puts in t0 the array start vector address (0x00002000)
        lbu     t1,6(t0)
                # t1<= 0x000000ef - LSB of t1 is 3rd byte (from right)
                # of array 2nd element
        xori    t1,t1,0xff      # t1<= 0x00000010, invert the LSB of t1
        sb      t1,6(t0)
                # 2nd byte of array's 2nd element <= 0x10 over previous value 0xEF
                # BEWARE, an element of array to be processed by soma_ct changed
        lh      a0,8(t0)
                # a0<= 0xffffcd35 - sign-extended halfword at array's 3rd element,
                # low half (0xcd35, top bit set so it sign-extends)
        lhu     a1,8(t0)
                # a1<= 0x0000cd35 - same halfword, zero-extended this time
        xori    a0,a0,0x2ab     # a0<= 0xffffcf9e, new halfword to write back
        sh      a0,8(t0)
                # low halfword of array's 3rd element <= 0xcf9e, over previous
                # value 0xcd35 (element becomes 0xefabcf9e)
                # BEWARE, another array element to be processed by soma_ct changed
        addi    t0,zero,0x1     # t0<= 0x00000001
        sub     t0,zero,t0      # t0<= 0xffffffff
        bge     t0,zero,loop
                # This instruction must never jump, since here t0 = -1
        slt     a0,t0,t1        # a0<= 0x00000001, since as integers -1 < 16
        sltu    a0,t0,t1        # a0<= 0x00000000, since as naturals (2^32)-1 > 16
        slti    a0,t0,0x1       # a0<= 0x00000001, since as integers -1 < 1
        sltiu   a0,t0,0x1       # a0<= 0x00000000, since as naturals (2^32)-1 > 1
#------------------------------------------------------------------------------
# Add a constant (const) to a every element of a vector (array)
#------------------------------------------------------------------------------
soma_ct:
        la      t0,array        # puts in t0 the vector address (0x00002000)
        la      t1,size         # puts in t1 the address of the vector size
        lw      t1,0(t1)        # puts in t1 the vector size (0x8)
        la      t2,const        # puts in t2 the address of the constant
        lw      t2,0(t2)        # puts in t2 the constant (0xFFFFFFFF) (integer -1)
#------------------------------------------------------------------------------
# Now t2 has a constant stored, t1 has the vector size and t0 has the array address
#------------------------------------------------------------------------------
loop:
        bge     zero,t1,end_add # if/when t1 becomes 0, end of processing
        lw      a0,0(t0)        # puts in a0 the next vector element
        add     a0,a0,t2        # adds constant to element and puts it back in a0
        sw      a0,0(t0)        # updates the value of the element in the vector
        addi    t0,t0,4         # updates the vector pointer.
                # Remember 1 word = 4 memory addresses
        addi    t1,t1,-1        # decrements number of elements to treat in vector
        j       loop            # proceed with execution
#------------------------------------------------------------------------------
# Nested subroutine call test
#------------------------------------------------------------------------------
end_add:
        li      sp,0x00003ffc   # To enable Hw simulation, initialize sp with an
                # adequate value. Here, the assumption is that the data memory
                # is an 8 Kbytes-long RAM, and sp is made to point to the first
                # memory position after the RAM end.
        addi    sp,sp,-4        # After sp is initialized, allocate 4 bytes in stack
        sw      ra,0(sp)        # saves return address from whom called this program
        jal     sum_tst         # jumps to the sum_tst subroutine
        lw      ra,0(sp)        # after returning from sum_tst, retrieves the return
                # address from the stack to the ra register
        addi    sp,sp,4         # destroys stack previously allocated using sp
end:    j       end             # THIS PROGRAM ENDS HERE (halts in RARS; nothing
                                 # called this program via jal, so ra was never
                                 # set and jr ra would fault at address 0).
#------------------------------------------------------------------------------
# Start of non-leaf subroutine: sum_tst
#------------------------------------------------------------------------------
sum_tst:
        la      t0,var_a        # takes address of a first variable
        lw      t0,0(t0)        # takes value of var_a and puts it in t0 (0x000000FF)
        la      t1,var_b        # takes address of a second variable
        lw      t1,0(t1)        # takes value of var_b and puts it in t1 (0x00000100)
        add     t2,t1,t0        # t2 <= var_a + var_b (0x000001FF)
        addi    sp,sp,-8        # allocate 8-byte stack space
        sw      ra,4(sp)        # puts the return address in the stack
        sw      t2,0(sp)        # puts the sum result in the stack top
        la      a0,ver_ev       # takes address of ver_ev subroutine
        jalr    ra,a0,0         # calls ver_ev subroutine which tests if sum is even
        lw      ra,4(sp)        # on return, retrieve return address
        addi    sp,sp,8         # destroys un-needed allocated stack
        jr      ra              # subroutine ends HERE. Return to caller
#------------------------------------------------------------------------------
# Start of the leaf subroutine: ver_ev. Stack is only read here, not written.
#------------------------------------------------------------------------------
ver_ev:
        lw      a0,0(sp)        # takes data from top of the stack (parameter)
                # (0x000001FF), and puts it in a0
        andi    a0,a0,1         # a0 <= 1 if parameter odd, 0 otherwise (0x00000001)
        jr      ra              # and returns to caller
#------------------------------------------------------------------------------
        .data                   # Static data memory
#------------------------------------------------------------------------------
# data for soma_ct loop test
array:      .word   0xABCDEF03, 0xCDEFAB18, 0xEFABCD35, 0xBADCFEAB, 0xDCFEBACD
            .word   0xFEBADC77, 0xDEFABC53, 0xCBAFED45
                # 3rd byte of the second word (0xEF) will become 0x10 before
                # executing code after soma_ct label
size:       .word   0x8
const:      .word   0xffffffff  # constant -1 in 2's complement
# data for nested subroutine call test
var_a:      .word   0xff
var_b:      .word   0x100
