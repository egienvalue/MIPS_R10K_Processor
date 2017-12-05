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
	# Initialize Heap Management Table
	#   could be done at compile-time, but then we get a super large .mem file
	  heap_srl_3 = 0x1800
	  lda		$r28, heap_srl_3	# work-around since heap-start needs >15 bits
	  sll		$r28, 3, $r28	# using the $at as the heap-pointer
	# Do not write to heap-pointer!
	  stq		$r31, -32*8($r28)	# init heap table
	  stq		$r31, -31*8($r28)	# init heap table
	  stq		$r31, -30*8($r28)	# init heap table
	  stq		$r31, -29*8($r28)	# init heap table
	  stq		$r31, -28*8($r28)	# init heap table
	  stq		$r31, -27*8($r28)	# init heap table
	  stq		$r31, -26*8($r28)	# init heap table
	  stq		$r31, -25*8($r28)	# init heap table
	  stq		$r31, -24*8($r28)	# init heap table
	  stq		$r31, -23*8($r28)	# init heap table
	  stq		$r31, -22*8($r28)	# init heap table
	  stq		$r31, -21*8($r28)	# init heap table
	  stq		$r31, -20*8($r28)	# init heap table
	  stq		$r31, -19*8($r28)	# init heap table
	  stq		$r31, -18*8($r28)	# init heap table
	  stq		$r31, -17*8($r28)	# init heap table
	  stq		$r31, -16*8($r28)	# init heap table
	  stq		$r31, -15*8($r28)	# init heap table
	  stq		$r31, -14*8($r28)	# init heap table
	  stq		$r31, -13*8($r28)	# init heap table
	  stq		$r31, -12*8($r28)	# init heap table
	  stq		$r31, -11*8($r28)	# init heap table
	  stq		$r31, -10*8($r28)	# init heap table
	  stq		$r31, -9*8($r28)	# init heap table
	  stq		$r31, -8*8($r28)	# init heap table
	  stq		$r31, -7*8($r28)	# init heap table
	  stq		$r31, -6*8($r28)	# init heap table
	  stq		$r31, -5*8($r28)	# init heap table
	  stq		$r31, -4*8($r28)	# init heap table
	  stq		$r31, -3*8($r28)	# init heap table
	  stq		$r31, -2*8($r28)	# init heap table
	  stq		$r31, -1*8($r28)	# init heap table
	# End Initialize Heap Management Table
	  bsr		$r26, main	# branch to subroutine
	  call_pal	0x555		# (halt)
	  .data
	  L_DATA:			# this is where the locals and temps end up at run-time
	  .text
_fib:
	# BeginFunc 88
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 88, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -16($r15)	# spill _tmp0 from $r3 to $r15-16
	# _tmp1 = base <= _tmp0
	  ldq		$r1, 8($r15)	# fill base to $r1 from $r15+8
	  ldq		$r2, -16($r15)	# fill _tmp0 to $r2 from $r15-16
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill _tmp1 from $r3 to $r15-24
	# IfZ _tmp1 Goto __L0
	  ldq		$r1, -24($r15)	# fill _tmp1 to $r1 from $r15-24
	  blbc		$r1, __L0	# branch if _tmp1 is zero
	# Return base
	  ldq		$r3, 8($r15)	# fill base to $r3 from $r15+8
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# Goto __L1
	  br		__L1		# unconditional branch
__L0:
	# _tmp2 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -64($r15)	# spill _tmp2 from $r3 to $r15-64
	# f0 = _tmp2
	  ldq		$r3, -64($r15)	# fill _tmp2 to $r3 from $r15-64
	  stq		$r3, -40($r15)	# spill f0 from $r3 to $r15-40
	# _tmp3 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -72($r15)	# spill _tmp3 from $r3 to $r15-72
	# f1 = _tmp3
	  ldq		$r3, -72($r15)	# fill _tmp3 to $r3 from $r15-72
	  stq		$r3, -48($r15)	# spill f1 from $r3 to $r15-48
	# _tmp4 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -80($r15)	# spill _tmp4 from $r3 to $r15-80
	# i = _tmp4
	  ldq		$r3, -80($r15)	# fill _tmp4 to $r3 from $r15-80
	  stq		$r3, -32($r15)	# spill i from $r3 to $r15-32
__L2:
	# _tmp5 = i <= base
	  ldq		$r1, -32($r15)	# fill i to $r1 from $r15-32
	  ldq		$r2, 8($r15)	# fill base to $r2 from $r15+8
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -88($r15)	# spill _tmp5 from $r3 to $r15-88
	# IfZ _tmp5 Goto __L3
	  ldq		$r1, -88($r15)	# fill _tmp5 to $r1 from $r15-88
	  blbc		$r1, __L3	# branch if _tmp5 is zero
	# _tmp6 = f0 + f1
	  ldq		$r1, -40($r15)	# fill f0 to $r1 from $r15-40
	  ldq		$r2, -48($r15)	# fill f1 to $r2 from $r15-48
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp6 from $r3 to $r15-96
	# f2 = _tmp6
	  ldq		$r3, -96($r15)	# fill _tmp6 to $r3 from $r15-96
	  stq		$r3, -56($r15)	# spill f2 from $r3 to $r15-56
	# f0 = f1
	  ldq		$r3, -48($r15)	# fill f1 to $r3 from $r15-48
	  stq		$r3, -40($r15)	# spill f0 from $r3 to $r15-40
	# f1 = f2
	  ldq		$r3, -56($r15)	# fill f2 to $r3 from $r15-56
	  stq		$r3, -48($r15)	# spill f1 from $r3 to $r15-48
	# i += 1
	  ldq		$r3, -32($r15)	# fill i to $r3 from $r15-32
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -32($r15)	# spill i from $r3 to $r15-32
	# Goto __L2
	  br		__L2		# unconditional branch
__L3:
	# Return f2
	  ldq		$r3, -56($r15)	# fill f2 to $r3 from $r15-56
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
__L1:
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
main:
	# BeginFunc 168
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 168, $r30	# decrement sp to make space for locals/temps
	# _tmp7 = 10
	  lda		$r3, 10		# load (signed) int constant value 10 into $r3
	  stq		$r3, -32($r15)	# spill _tmp7 from $r3 to $r15-32
	# _tmp8 = _tmp7 < ZERO
	  ldq		$r1, -32($r15)	# fill _tmp7 to $r1 from $r15-32
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -40($r15)	# spill _tmp8 from $r3 to $r15-40
	# IfZ _tmp8 Goto __L4
	  ldq		$r1, -40($r15)	# fill _tmp8 to $r1 from $r15-40
	  blbc		$r1, __L4	# branch if _tmp8 is zero
	# Throw Exception: Array size is <= 0
	  call_pal	0xDECAF		# (exception: Array size is <= 0)
	  call_pal	0x555		# (halt)
__L4:
	# _tmp9 = _tmp7 + 1
	  ldq		$r1, -32($r15)	# fill _tmp7 to $r1 from $r15-32
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -48($r15)	# spill _tmp9 from $r3 to $r15-48
	# PushParam _tmp9
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -48($r15)	# fill _tmp9 to $r1 from $r15-48
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp10 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -56($r15)	# spill _tmp10 from $r3 to $r15-56
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp10) = _tmp7
	  ldq		$r1, -32($r15)	# fill _tmp7 to $r1 from $r15-32
	  ldq		$r3, -56($r15)	# fill _tmp10 to $r3 from $r15-56
	  stq		$r1, 0($r3)	# store with offset
	# _tmp11 = _tmp10 + 8
	  ldq		$r1, -56($r15)	# fill _tmp10 to $r1 from $r15-56
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp11 from $r3 to $r15-64
	# array = _tmp11
	  ldq		$r3, -64($r15)	# fill _tmp11 to $r3 from $r15-64
	  stq		$r3, -16($r15)	# spill array from $r3 to $r15-16
	# _tmp12 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -72($r15)	# spill _tmp12 from $r3 to $r15-72
	# i = _tmp12
	  ldq		$r3, -72($r15)	# fill _tmp12 to $r3 from $r15-72
	  stq		$r3, -24($r15)	# spill i from $r3 to $r15-24
__L5:
	# _tmp13 = 20
	  lda		$r3, 20		# load (signed) int constant value 20 into $r3
	  stq		$r3, -80($r15)	# spill _tmp13 from $r3 to $r15-80
	# _tmp14 = i < _tmp13
	  ldq		$r1, -24($r15)	# fill i to $r1 from $r15-24
	  ldq		$r2, -80($r15)	# fill _tmp13 to $r2 from $r15-80
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -88($r15)	# spill _tmp14 from $r3 to $r15-88
	# IfZ _tmp14 Goto __L6
	  ldq		$r1, -88($r15)	# fill _tmp14 to $r1 from $r15-88
	  blbc		$r1, __L6	# branch if _tmp14 is zero
	# _tmp15 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -96($r15)	# spill _tmp15 from $r3 to $r15-96
	# _tmp16 = i - _tmp15
	  ldq		$r1, -24($r15)	# fill i to $r1 from $r15-24
	  ldq		$r2, -96($r15)	# fill _tmp15 to $r2 from $r15-96
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -104($r15)	# spill _tmp16 from $r3 to $r15-104
	# _tmp17 = _tmp16 < ZERO
	  ldq		$r1, -104($r15)	# fill _tmp16 to $r1 from $r15-104
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp17 from $r3 to $r15-112
	# _tmp18 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -120($r15)	# spill _tmp18 from $r3 to $r15-120
	# _tmp19 = _tmp18 <= _tmp16
	  ldq		$r1, -120($r15)	# fill _tmp18 to $r1 from $r15-120
	  ldq		$r2, -104($r15)	# fill _tmp16 to $r2 from $r15-104
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp19 from $r3 to $r15-128
	# _tmp20 = _tmp17 || _tmp19
	  ldq		$r1, -112($r15)	# fill _tmp17 to $r1 from $r15-112
	  ldq		$r2, -128($r15)	# fill _tmp19 to $r2 from $r15-128
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -136($r15)	# spill _tmp20 from $r3 to $r15-136
	# IfZ _tmp20 Goto __L7
	  ldq		$r1, -136($r15)	# fill _tmp20 to $r1 from $r15-136
	  blbc		$r1, __L7	# branch if _tmp20 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L7:
	# _tmp21 = _tmp16 << 3
	  ldq		$r1, -104($r15)	# fill _tmp16 to $r1 from $r15-104
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp21 from $r3 to $r15-144
	# _tmp22 = array + _tmp21
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r2, -144($r15)	# fill _tmp21 to $r2 from $r15-144
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -152($r15)	# spill _tmp22 from $r3 to $r15-152
	# PushParam i
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill i to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp23 = LCall _fib
	  bsr		$r26, _fib	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -160($r15)	# spill _tmp23 from $r3 to $r15-160
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp22) = _tmp23
	  ldq		$r1, -160($r15)	# fill _tmp23 to $r1 from $r15-160
	  ldq		$r3, -152($r15)	# fill _tmp22 to $r3 from $r15-152
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -24($r15)	# fill i to $r3 from $r15-24
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill i from $r3 to $r15-24
	# Goto __L5
	  br		__L5		# unconditional branch
__L6:
	# _tmp24 = *(array + -8)
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -168($r15)	# spill _tmp24 from $r3 to $r15-168
	# _tmp24 += 1
	  ldq		$r3, -168($r15)	# fill _tmp24 to $r3 from $r15-168
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -168($r15)	# spill _tmp24 from $r3 to $r15-168
	# _tmp25 = array - 8
	  ldq		$r1, -16($r15)	# fill array to $r1 from $r15-16
	  subq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp25 from $r3 to $r15-176
	# PushParam _tmp25
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -176($r15)	# fill _tmp25 to $r1 from $r15-176
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp24
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -168($r15)	# fill _tmp24 to $r1 from $r15-168
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall __Free
	  bsr		$r26, __Free	# branch to function
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
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
__Alloc:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	#
	# $r28 holds addr of heap-start
	# $r16 is the number of lines we want
	# $r1 holds the number of lines remaining to be allocated
	# $r2 holds the curent heap-table-entry
	# $r3 holds temp results of various comparisons
	# $r4 is used to generate various bit-masks
	# $r24 holds the current starting "bit-addr" in the heap-table
	# $r25 holds the bit-pos within the current heap-table-entry
	# $r27 holds the addr of the current heap-table-entry
	#
	  lda		$r4, 0x100
	  subq		$r28, $r4, $r27	# make addr of heap-table start
    __AllocFullReset:
	  mov		$r16, $r1	# reset goal amount
	  sll		$r27, 3, $r24	# reset bit-addr into heap-table
	  clr		$r25		# clear bit-pos marker
    __AllocSearchStart:
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  cmpult	$r1, 64, $r3	# less than a page to allocate?
	  blbs		$r3, __AllocSearchStartLittle
	  blt		$r2, __AllocSearchStartSetup	# MSB set?
	  lda		$r4, -1		# for next code-block
    __AllocSearchStartShift:
	  and		$r2, $r4, $r3
	  beq		$r3, __AllocSearchStartDone
	  sll		$r4, 1, $r4
	  addq		$r24, 1, $r24
	  and		$r24, 63, $r25
	  bne		$r25, __AllocSearchStartShift
    __AllocSearchStartSetup:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  br		__AllocSearchStart	# unconditional branch
    __AllocSearchStartLittle:
	  lda		$r4, 1
	  sll		$r4, $r1, $r4
	  subq		$r4, 1, $r4
	  br		__AllocSearchStartShift	# unconditional branch
    __AllocSearchStartDone:
	  subq		$r1, 64, $r1
	  addq		$r1, $r25, $r1
	  bgt		$r1, __AllocNotSimple
    __AllocSimpleCommit:
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  br		__AllocReturnGood	# unconditional branch
    __AllocNotSimple:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
    __AllocSearchBlock:
	  cmpult	$r1, 64, $r3
	  blbs		$r3, __AllocSearchEnd
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  bne		$r2, __AllocFullReset
	  subq		$r1, 64, $r1
	  br		__AllocSearchBlock	# unconditional branch
    __AllocSearchEnd:
	  beq		$r1,__AllocCommitStart
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbc		$r3, __AllocReturnFail
	  ldq		$r2, 0($r27)	# dereference, to get current heap-table entry
	  lda		$r4, 1
	  sll		$r4, $r1, $r4
	  subq		$r4, 1, $r4
	  and		$r2, $r4, $r3
	  bne		$r3, __AllocFullReset
    __AllocCommitEnd:
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, $r1, $r16
    __AllocCommitStart:
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  ldq		$r2, 0($r27)
	  lda		$r4, -1
	  sll		$r4, $r25, $r4
	  bis		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, 64, $r16
	  addq		$r16, $r25, $r16
	  lda		$r4, -1		# for next code-block
    __AllocCommitBlock:
	  cmpult	$r16, 64, $r3
	  blbs		$r3, __AllocReturnCheck
	  addq		$r27, 8, $r27	# next heap-table entry
	  stq		$r4, 0($r27)	# set all bits in that entry
	  subq		$r16, 64, $r16
	  br		__AllocCommitBlock	# unconditional branch
    __AllocReturnCheck:
	  beq		$r16, __AllocReturnGood	# verify we are done
	  call_pal	0xDECAF		# (exception: this really should not happen in Malloc)
	  call_pal	0x555		# (halt)
    __AllocReturnGood:
	# magically compute address for return value
	  lda		$r0, 0x2F
	  sll		$r0, 13, $r0
	  subq		$r24, $r0, $r0
	  sll		$r0, 3, $r0
	  ret				# return to caller
    __AllocReturnFail:
	  call_pal	0xDECAF		# (exception: Malloc failed to find space in heap)
	  call_pal	0x555		# (halt)
	# EndFunc
__Free:
	  ldq		$r16, 8($r30)	# fill arg0 to $r16 from $r30+8
	  ldq		$r17, 16($r30)	# fill arg1 to $r17 from $r30+16
	  cmpult	$r17, $r28, $r3
	  blbc		$r3, __FreeCheck1Pass
	  call_pal	0xDECAF		# (exception: addr passed to Free is pass end of heap (and out-of-bounds memory access))
	  call_pal	0x555		# (halt)
    __FreeCheck1Pass:
	  srl		$r17, 3, $r24
	  lda		$r4, 0x2F
	  sll		$r4, 13, $r4
	  addq		$r24, $r4, $r24
	  srl		$r24, 6, $r27
	  sll		$r27, 3, $r27
	  and		$r24, 63, $r25
	  beq		$r25, __FreeBlock
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbs		$r3, __FreeCheck2Pass
	  call_pal	0xDECAF		# (exception: passed end of heap-table in Free)
	  call_pal	0x555		# (halt)
    __FreeCheck2Pass:
	  ldq		$r2, 0($r27)
	  addq		$r16, $r25, $r4	# compute ending bit-pos + 1
	  cmpult	$r4, 64, $r3
	  blbs		$r3, __FreeLittle
	  lda		$r4, 1
	  sll		$r4, $r25, $r4
	  subq		$r4, 1, $r4
	  and		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  subq		$r16, 64, $r16
	  addq		$r16, $r25, $r16
	  addq		$r27, 8, $r27	# next heap-table entry
	  br		__FreeBlock	# unconditional branch
    __FreeLittle:
	  lda		$r4, 1
	  sll		$r4, $r16, $r4
	  subq		$r4, 1, $r4
	  sll		$r4, $r25, $r4
	  bic		$r2, $r4, $r2
	  stq		$r2, 0($r27)
	  ret				# return to caller
    __FreeBlock:
	  cmpult	$r16, 64, $r3	# less than a page remaining?
	  blbs		$r3, __FreeEnd
	  addq		$r27, 8, $r27	# next heap-table entry
	  cmpult	$r27, $r28, $r3	# check if pass end of heap-table
	  blbs		$r3, __FreeCheck3Pass
	  call_pal	0xDECAF		# (exception: passed end of heap-table in Free)
	  call_pal	0x555		# (halt)
    __FreeCheck3Pass:
	  stq		$r31, 0($r27)
	  subq		$r16, 64, $r16
	  br		__FreeBlock	# unconditional branch
    __FreeEnd:
	  beq		$r16, __FreeDone
	  cmpult	$r27, $r28, $r3
	  blbs		$r3, __FreeCheck4Pass
	  call_pal	0xDECAF		# (exception: passed end of heap-table in Free)
	  call_pal	0x555		# (halt)
    __FreeCheck4Pass:
	  ldq		$r2, 0($r27)
	  lda		$r4, 1
	  sll		$r4, $r16, $r4
	  subq	$r4, 1, $r4
	  bic		$r2, $r4, $r2
	  stq		$r2, 0($r27)
    __FreeDone:
	  ret				# return to caller
	# EndFunc
