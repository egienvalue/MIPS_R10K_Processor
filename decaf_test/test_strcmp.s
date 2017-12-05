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
	# BeginFunc 48
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 48, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = "hello San Francisco12345"
	  .data				# create string constant marked with label
	  .quad 25			# for bounds checking on char access
	  __string1: .asciz "hello San Francisco12345"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string1-L_DATA+data # a hack!
	  stq		$r3, -40($r15)	# spill _tmp0 from $r3 to $r15-40
	# a = _tmp0
	  ldq		$r3, -40($r15)	# fill _tmp0 to $r3 from $r15-40
	  stq		$r3, -16($r15)	# spill a from $r3 to $r15-16
	# _tmp1 = "hello San Francisco1234"
	  .data				# create string constant marked with label
	  .quad 24			# for bounds checking on char access
	  __string2: .asciz "hello San Francisco1234"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string2-L_DATA+data # a hack!
	  stq		$r3, -48($r15)	# spill _tmp1 from $r3 to $r15-48
	# b = _tmp1
	  ldq		$r3, -48($r15)	# fill _tmp1 to $r3 from $r15-48
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
	  stq		$r3, -56($r15)	# spill _tmp2 from $r3 to $r15-56
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# matches = _tmp2
	  ldq		$r3, -56($r15)	# fill _tmp2 to $r3 from $r15-56
	  stq		$r3, -32($r15)	# spill matches from $r3 to $r15-32
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
