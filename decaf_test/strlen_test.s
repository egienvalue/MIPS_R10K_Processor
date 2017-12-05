/*
  Assembly code compiled from Decaf by 'decaf470', written by Doug Li.
*/

	  .set noat
	  .set noreorder
	  .set nomacro
	  data = 0x1000
	  global = 0x2000
	  lda		$r30, 0x7FF0	# set stack ptr to a sufficiently high addr
	  lda		$r15, 0x0000	# initialize frame ptr to something
	  lda		$r29, global	# initialize global ptr to 0x2000
	  bsr		$r26, main	# branch to subroutine
	  call_pal	0x555		# (halt)
	  .data
	  L_DATA:			# this is where the locals and temps end up at run-time
	  .text
main:
	# BeginFunc 64
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 64, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = "apple"
	  .data				# create string constant marked with label
	  .quad 6			# for bounds checking on char access
	  __string1: .asciz "apple"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string1-L_DATA+data # a hack!
	  stq		$r3, -32($r15)	# spill _tmp0 from $r3 to $r15-32
	# a = _tmp0
	  ldq		$r3, -32($r15)	# fill _tmp0 to $r3 from $r15-32
	  stq		$r3, -16($r15)	# spill a from $r3 to $r15-16
	# _tmp1 = "bob"
	  .data				# create string constant marked with label
	  .quad 4			# for bounds checking on char access
	  __string2: .asciz "bob"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string2-L_DATA+data # a hack!
	  stq		$r3, -40($r15)	# spill _tmp1 from $r3 to $r15-40
	# b = _tmp1
	  ldq		$r3, -40($r15)	# fill _tmp1 to $r3 from $r15-40
	  stq		$r3, -24($r15)	# spill b from $r3 to $r15-24
	# PushParam b
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill b to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam a
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill a to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp2 = LCall __StringEqual
	  bsr		$r26, __StringEqual	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -48($r15)	# spill _tmp2 from $r3 to $r15-48
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# _tmp3 = !_tmp2
	  ldq		$r2, -48($r15)	# fill _tmp2 to $r2 from $r15-48
	  not		$r2, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp3 from $r3 to $r15-56
	# x = _tmp3
	  ldq		$r3, -56($r15)	# fill _tmp3 to $r3 from $r15-56
	  stq		$r3, 0($r29)	# spill x from $r3 to $r29+0
	# PushParam a
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill a to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp4 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -64($r15)	# spill _tmp4 from $r3 to $r15-64
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# y = _tmp4
	  ldq		$r3, -64($r15)	# fill _tmp4 to $r3 from $r15-64
	  stq		$r3, 8($r29)	# spill y from $r3 to $r29+8
	# PushParam b
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill b to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp5 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -72($r15)	# spill _tmp5 from $r3 to $r15-72
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# z = _tmp5
	  ldq		$r3, -72($r15)	# fill _tmp5 to $r3 from $r15-72
	  stq		$r3, 16($r29)	# spill z from $r3 to $r29+16
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# EndProgram
	#
	# (below is reserved for auto-appending of built-in functions)
	#
__StringEqual:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	  ldq		$r17, 16($r30)	# fill arg1 to $r17 from $r30+16
    __StringEqualLoop:
	  ldq		$r1, 0($r16)	# dereference LHS string
	  ldq		$r2, 0($r17)	# dereference RHS string
	  .rept 7		# asm directive to repeat next block of code 7 times
	  and		$r1, 0xFF, $r3	# bit-mask to grab next byte/char of LHS
	  and		$r2, 0xFF, $r4	# bit-mask to grab next byte/char of RHS
	  cmpeq		$r3, $r4, $r5	# do they match?
	  blbc		$r5, __StringEqualFalse	# branch if low-bit clear
	  beq		$r3, __StringEqualTrue	# was that the null-char?
	  srl		$r1, 8, $r1	# shift LHS down a byte/char
	  srl		$r2, 8, $r2	# shift RHS down a byte/char
	  .endr
	  and		$r1, 0xFF, $r3	# bit-mask to grab last byte/char of LHS
	  and		$r2, 0xFF, $r4	# bit-mask to grab last byte/char of RHS
	  cmpeq		$r3, $r4, $r5	# do they match?
	  blbc		$r5, __StringEqualFalse	# branch if low-bit clear
	  addq	$r16, 8, $r16	# move LHS to next memory location
	  addq	$r17, 8, $r17	# move RHS to next memory location
	  bne		$r3, __StringEqualLoop	# was that the null-char?
    __StringEqualTrue:
	  lda		$r0, -1		# return '~ 0' because the strings match
	  ret				# return to caller
    __StringEqualFalse:
	  cmpult		$r3, $r4, $r5	# is LHS < RHS?
	  blbs		$r5, __StringEqualLessThan
	  lda		$r0, -2		# return '~ 1' because LHS > RHS
	  ret				# return to caller
    __StringEqualLessThan:
	  lda		$r0, 0		# return '~ -1' because LHS < RHS
	  ret				# return to caller
	# EndFunc
__StringLength:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	  ldq		$r1, 0($r16)	# dereference, to get first 8 chars of string
	  clr		$r0		# set return value to 0
    __StringLengthLoop:
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass1
	  ret				# return to caller
    __StringLengthPass1:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass2
	  addq		$r0, 1, $r0
	  ret				# return to caller
    __StringLengthPass2:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass3
	  addq		$r0, 2, $r0
	  ret				# return to caller
    __StringLengthPass3:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass4
	  addq		$r0, 3, $r0
	  ret				# return to caller
    __StringLengthPass4:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass5
	  addq		$r0, 4, $r0
	  ret				# return to caller
    __StringLengthPass5:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass6
	  addq		$r0, 5, $r0
	  ret				# return to caller
    __StringLengthPass6:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass7
	  addq		$r0, 6, $r0
	  ret				# return to caller
    __StringLengthPass7:
	  srl		$r1, 8, $r1	# shift down a byte/char
	  and		$r1, 0xFF, $r2
	  bne		$r2, __StringLengthPass8
	  addq		$r0, 7, $r0
	  ret				# return to caller
    __StringLengthPass8:
	  ldq		$r1, 8($r16)	# dereference, to get next 8 chars of string
	  addq		$r16, 8, $r16	# after above load to reduce mem latnacy
	  addq		$r0, 8, $r0
	  br		__StringLengthLoop	# unconditional branch
	# EndFunc
