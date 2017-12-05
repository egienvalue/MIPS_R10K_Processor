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
_factorial:
	# BeginFunc 56
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 56, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = 2
	  lda		$r3, 2		# load (unsigned) int constant value 2 into $r3
	  stq		$r3, -16($r15)	# spill _tmp0 from $r3 to $r15-16
	# _tmp1 = N < _tmp0
	  ldq		$r1, 8($r15)	# fill N to $r1 from $r15+8
	  ldq		$r2, -16($r15)	# fill _tmp0 to $r2 from $r15-16
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill _tmp1 from $r3 to $r15-24
	# IfZ _tmp1 Goto __L0
	  ldq		$r1, -24($r15)	# fill _tmp1 to $r1 from $r15-24
	  blbc		$r1, __L0	# branch if _tmp1 is zero
	# _tmp2 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -32($r15)	# spill _tmp2 from $r3 to $r15-32
	# Return _tmp2
	  ldq		$r3, -32($r15)	# fill _tmp2 to $r3 from $r15-32
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
__L0:
	# _tmp3 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -40($r15)	# spill _tmp3 from $r3 to $r15-40
	# _tmp4 = N - _tmp3
	  ldq		$r1, 8($r15)	# fill N to $r1 from $r15+8
	  ldq		$r2, -40($r15)	# fill _tmp3 to $r2 from $r15-40
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -48($r15)	# spill _tmp4 from $r3 to $r15-48
	# PushParam _tmp4
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -48($r15)	# fill _tmp4 to $r1 from $r15-48
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp5 = LCall _factorial
	  bsr		$r26, _factorial	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -56($r15)	# spill _tmp5 from $r3 to $r15-56
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# _tmp6 = N * _tmp5
	  ldq		$r1, 8($r15)	# fill N to $r1 from $r15+8
	  ldq		$r2, -56($r15)	# fill _tmp5 to $r2 from $r15-56
	  mulq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp6 from $r3 to $r15-64
	# Return _tmp6
	  ldq		$r3, -64($r15)	# fill _tmp6 to $r3 from $r15-64
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
main:
	# BeginFunc 144
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 144, $r30	# decrement sp to make space for locals/temps
	# _tmp7 = 15
	  lda		$r3, 15		# load (signed) int constant value 15 into $r3
	  stq		$r3, -24($r15)	# spill _tmp7 from $r3 to $r15-24
	# _tmp8 = _tmp7 < ZERO
	  ldq		$r1, -24($r15)	# fill _tmp7 to $r1 from $r15-24
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -32($r15)	# spill _tmp8 from $r3 to $r15-32
	# IfZ _tmp8 Goto __L1
	  ldq		$r1, -32($r15)	# fill _tmp8 to $r1 from $r15-32
	  blbc		$r1, __L1	# branch if _tmp8 is zero
	# Throw Exception: Array size is <= 0
	  call_pal	0xDECAF		# (exception: Array size is <= 0)
	  call_pal	0x555		# (halt)
__L1:
	# _tmp9 = _tmp7 + 1
	  ldq		$r1, -24($r15)	# fill _tmp7 to $r1 from $r15-24
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -40($r15)	# spill _tmp9 from $r3 to $r15-40
	# PushParam _tmp9
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -40($r15)	# fill _tmp9 to $r1 from $r15-40
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp10 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -48($r15)	# spill _tmp10 from $r3 to $r15-48
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp10) = _tmp7
	  ldq		$r1, -24($r15)	# fill _tmp7 to $r1 from $r15-24
	  ldq		$r3, -48($r15)	# fill _tmp10 to $r3 from $r15-48
	  stq		$r1, 0($r3)	# store with offset
	# _tmp11 = _tmp10 + 8
	  ldq		$r1, -48($r15)	# fill _tmp10 to $r1 from $r15-48
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp11 from $r3 to $r15-56
	# results = _tmp11
	  ldq		$r3, -56($r15)	# fill _tmp11 to $r3 from $r15-56
	  stq		$r3, 0($r29)	# spill results from $r3 to $r29+0
	# _tmp12 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -64($r15)	# spill _tmp12 from $r3 to $r15-64
	# i = _tmp12
	  ldq		$r3, -64($r15)	# fill _tmp12 to $r3 from $r15-64
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L2:
	# _tmp13 = 15
	  lda		$r3, 15		# load (unsigned) int constant value 15 into $r3
	  stq		$r3, -72($r15)	# spill _tmp13 from $r3 to $r15-72
	# _tmp14 = i <= _tmp13
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -72($r15)	# fill _tmp13 to $r2 from $r15-72
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp14 from $r3 to $r15-80
	# IfZ _tmp14 Goto __L3
	  ldq		$r1, -80($r15)	# fill _tmp14 to $r1 from $r15-80
	  blbc		$r1, __L3	# branch if _tmp14 is zero
	# _tmp15 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -88($r15)	# spill _tmp15 from $r3 to $r15-88
	# _tmp16 = i - _tmp15
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -88($r15)	# fill _tmp15 to $r2 from $r15-88
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp16 from $r3 to $r15-96
	# _tmp17 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -104($r15)	# spill _tmp17 from $r3 to $r15-104
	# _tmp18 = _tmp17 u<= _tmp16
	  ldq		$r1, -104($r15)	# fill _tmp17 to $r1 from $r15-104
	  ldq		$r2, -96($r15)	# fill _tmp16 to $r2 from $r15-96
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp18 from $r3 to $r15-112
	# IfZ _tmp18 Goto __L4
	  ldq		$r1, -112($r15)	# fill _tmp18 to $r1 from $r15-112
	  blbc		$r1, __L4	# branch if _tmp18 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L4:
	# _tmp19 = _tmp16 << 3
	  ldq		$r1, -96($r15)	# fill _tmp16 to $r1 from $r15-96
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp19 from $r3 to $r15-120
	# _tmp20 = results + _tmp19
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -120($r15)	# fill _tmp19 to $r2 from $r15-120
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp20 from $r3 to $r15-128
	# _tmp21 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -136($r15)	# spill _tmp21 from $r3 to $r15-136
	# _tmp22 = i - _tmp21
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -136($r15)	# fill _tmp21 to $r2 from $r15-136
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp22 from $r3 to $r15-144
	# PushParam _tmp22
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -144($r15)	# fill _tmp22 to $r1 from $r15-144
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp23 = LCall _factorial
	  bsr		$r26, _factorial	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -152($r15)	# spill _tmp23 from $r3 to $r15-152
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp20) = _tmp23
	  ldq		$r1, -152($r15)	# fill _tmp23 to $r1 from $r15-152
	  ldq		$r3, -128($r15)	# fill _tmp20 to $r3 from $r15-128
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L2
	  br		__L2		# unconditional branch
__L3:
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
