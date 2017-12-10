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
main:
	# BeginFunc 160
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 160, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = {895,-613,166,89,303,392,-300,465,-690,-334,-207,868,752,-64,646,258,26,-699...}
	  .data
	  .quad 20		# array size for the following int array
    __int_array1:
	  .quad 895		# [0]
	  .quad -613		# [1]
	  .quad 166		# [2]
	  .quad 89		# [3]
	  .quad 303		# [4]
	  .quad 392		# [5]
	  .quad -300		# [6]
	  .quad 465		# [7]
	  .quad -690		# [8]
	  .quad -334		# [9]
	  .quad -207		# [10]
	  .quad 868		# [11]
	  .quad 752		# [12]
	  .quad -64		# [13]
	  .quad 646		# [14]
	  .quad 258		# [15]
	  .quad 26		# [16]
	  .quad -699		# [17]
	  .quad 108		# [18]
	  .quad -472		# [19]
	  .text
	  lda		$r3, __int_array1-L_DATA+data # a hack!
	  stq		$r3, -40($r15)	# spill _tmp0 from $r3 to $r15-40
	# input = _tmp0
	  ldq		$r3, -40($r15)	# fill _tmp0 to $r3 from $r15-40
	  stq		$r3, -24($r15)	# spill input from $r3 to $r15-24
	# _tmp1 = *(input + -8)
	  ldq		$r1, -24($r15)	# fill input to $r1 from $r15-24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -48($r15)	# spill _tmp1 from $r3 to $r15-48
	# _tmp2 = _tmp1 + 1
	  ldq		$r1, -48($r15)	# fill _tmp1 to $r1 from $r15-48
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp2 from $r3 to $r15-56
	# PushParam _tmp2
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -56($r15)	# fill _tmp2 to $r1 from $r15-56
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp3 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -64($r15)	# spill _tmp3 from $r3 to $r15-64
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp3) = _tmp1
	  ldq		$r1, -48($r15)	# fill _tmp1 to $r1 from $r15-48
	  ldq		$r3, -64($r15)	# fill _tmp3 to $r3 from $r15-64
	  stq		$r1, 0($r3)	# store with offset
	# _tmp4 = _tmp3 + 8
	  ldq		$r1, -64($r15)	# fill _tmp3 to $r1 from $r15-64
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -72($r15)	# spill _tmp4 from $r3 to $r15-72
	# output = _tmp4
	  ldq		$r3, -72($r15)	# fill _tmp4 to $r3 from $r15-72
	  stq		$r3, -32($r15)	# spill output from $r3 to $r15-32
	# _tmp5 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -80($r15)	# spill _tmp5 from $r3 to $r15-80
	# i = _tmp5
	  ldq		$r3, -80($r15)	# fill _tmp5 to $r3 from $r15-80
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L0:
	# _tmp6 = *(input + -8)
	  ldq		$r1, -24($r15)	# fill input to $r1 from $r15-24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -88($r15)	# spill _tmp6 from $r3 to $r15-88
	# _tmp7 = i < _tmp6
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -88($r15)	# fill _tmp6 to $r2 from $r15-88
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp7 from $r3 to $r15-96
	# IfZ _tmp7 Goto __L1
	  ldq		$r1, -96($r15)	# fill _tmp7 to $r1 from $r15-96
	  blbc		$r1, __L1	# branch if _tmp7 is zero
	# _tmp8 = *(output + -8)
	  ldq		$r1, -32($r15)	# fill output to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -104($r15)	# spill _tmp8 from $r3 to $r15-104
	# _tmp9 = _tmp8 u<= i
	  ldq		$r1, -104($r15)	# fill _tmp8 to $r1 from $r15-104
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp9 from $r3 to $r15-112
	# IfZ _tmp9 Goto __L2
	  ldq		$r1, -112($r15)	# fill _tmp9 to $r1 from $r15-112
	  blbc		$r1, __L2	# branch if _tmp9 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L2:
	# _tmp10 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp10 from $r3 to $r15-120
	# _tmp11 = output + _tmp10
	  ldq		$r1, -32($r15)	# fill output to $r1 from $r15-32
	  ldq		$r2, -120($r15)	# fill _tmp10 to $r2 from $r15-120
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp11 from $r3 to $r15-128
	# _tmp12 = *(input + -8)
	  ldq		$r1, -24($r15)	# fill input to $r1 from $r15-24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -136($r15)	# spill _tmp12 from $r3 to $r15-136
	# _tmp13 = _tmp12 u<= i
	  ldq		$r1, -136($r15)	# fill _tmp12 to $r1 from $r15-136
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp13 from $r3 to $r15-144
	# IfZ _tmp13 Goto __L3
	  ldq		$r1, -144($r15)	# fill _tmp13 to $r1 from $r15-144
	  blbc		$r1, __L3	# branch if _tmp13 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L3:
	# _tmp14 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -152($r15)	# spill _tmp14 from $r3 to $r15-152
	# _tmp15 = input + _tmp14
	  ldq		$r1, -24($r15)	# fill input to $r1 from $r15-24
	  ldq		$r2, -152($r15)	# fill _tmp14 to $r2 from $r15-152
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp15 from $r3 to $r15-160
	# _tmp16 = *(_tmp15)
	  ldq		$r1, -160($r15)	# fill _tmp15 to $r1 from $r15-160
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -168($r15)	# spill _tmp16 from $r3 to $r15-168
	# *(_tmp11) = _tmp16
	  ldq		$r1, -168($r15)	# fill _tmp16 to $r1 from $r15-168
	  ldq		$r3, -128($r15)	# fill _tmp11 to $r3 from $r15-128
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L0
	  br		__L0		# unconditional branch
__L1:
	# PushParam output
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -32($r15)	# fill output to $r1 from $r15-32
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _mergeSort
	  bsr		$r26, _mergeSort	# branch to function
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
_mergeSort:
	# BeginFunc 360
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 360	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp17 = *(array + -8)
	  ldq		$r1, 8($r15)	# fill array to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -56($r15)	# spill _tmp17 from $r3 to $r15-56
	# end = _tmp17
	  ldq		$r3, -56($r15)	# fill _tmp17 to $r3 from $r15-56
	  stq		$r3, -32($r15)	# spill end from $r3 to $r15-32
	# _tmp18 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -64($r15)	# spill _tmp18 from $r3 to $r15-64
	# _tmp19 = end <= _tmp18
	  ldq		$r1, -32($r15)	# fill end to $r1 from $r15-32
	  ldq		$r2, -64($r15)	# fill _tmp18 to $r2 from $r15-64
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -72($r15)	# spill _tmp19 from $r3 to $r15-72
	# IfZ _tmp19 Goto __L4
	  ldq		$r1, -72($r15)	# fill _tmp19 to $r1 from $r15-72
	  blbc		$r1, __L4	# branch if _tmp19 is zero
	# Return 
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
__L4:
	# _tmp20 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -80($r15)	# spill _tmp20 from $r3 to $r15-80
	# _tmp21 = end >> _tmp20
	  ldq		$r1, -32($r15)	# fill end to $r1 from $r15-32
	  ldq		$r2, -80($r15)	# fill _tmp20 to $r2 from $r15-80
	  srl		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -88($r15)	# spill _tmp21 from $r3 to $r15-88
	# mid = _tmp21
	  ldq		$r3, -88($r15)	# fill _tmp21 to $r3 from $r15-88
	  stq		$r3, -24($r15)	# spill mid from $r3 to $r15-24
	# _tmp22 = mid + 1
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp22 from $r3 to $r15-96
	# PushParam _tmp22
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -96($r15)	# fill _tmp22 to $r1 from $r15-96
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp23 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -104($r15)	# spill _tmp23 from $r3 to $r15-104
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp23) = mid
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  ldq		$r3, -104($r15)	# fill _tmp23 to $r3 from $r15-104
	  stq		$r1, 0($r3)	# store with offset
	# _tmp24 = _tmp23 + 8
	  ldq		$r1, -104($r15)	# fill _tmp23 to $r1 from $r15-104
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp24 from $r3 to $r15-112
	# left = _tmp24
	  ldq		$r3, -112($r15)	# fill _tmp24 to $r3 from $r15-112
	  stq		$r3, -40($r15)	# spill left from $r3 to $r15-40
	# _tmp25 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -120($r15)	# spill _tmp25 from $r3 to $r15-120
	# i = _tmp25
	  ldq		$r3, -120($r15)	# fill _tmp25 to $r3 from $r15-120
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L5:
	# _tmp26 = i < mid
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -24($r15)	# fill mid to $r2 from $r15-24
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp26 from $r3 to $r15-128
	# IfZ _tmp26 Goto __L6
	  ldq		$r1, -128($r15)	# fill _tmp26 to $r1 from $r15-128
	  blbc		$r1, __L6	# branch if _tmp26 is zero
	# _tmp27 = *(left + -8)
	  ldq		$r1, -40($r15)	# fill left to $r1 from $r15-40
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -136($r15)	# spill _tmp27 from $r3 to $r15-136
	# _tmp28 = _tmp27 u<= i
	  ldq		$r1, -136($r15)	# fill _tmp27 to $r1 from $r15-136
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp28 from $r3 to $r15-144
	# IfZ _tmp28 Goto __L7
	  ldq		$r1, -144($r15)	# fill _tmp28 to $r1 from $r15-144
	  blbc		$r1, __L7	# branch if _tmp28 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L7:
	# _tmp29 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -152($r15)	# spill _tmp29 from $r3 to $r15-152
	# _tmp30 = left + _tmp29
	  ldq		$r1, -40($r15)	# fill left to $r1 from $r15-40
	  ldq		$r2, -152($r15)	# fill _tmp29 to $r2 from $r15-152
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp30 from $r3 to $r15-160
	# _tmp31 = *(array + -8)
	  ldq		$r1, 8($r15)	# fill array to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -168($r15)	# spill _tmp31 from $r3 to $r15-168
	# _tmp32 = _tmp31 u<= i
	  ldq		$r1, -168($r15)	# fill _tmp31 to $r1 from $r15-168
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp32 from $r3 to $r15-176
	# IfZ _tmp32 Goto __L8
	  ldq		$r1, -176($r15)	# fill _tmp32 to $r1 from $r15-176
	  blbc		$r1, __L8	# branch if _tmp32 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L8:
	# _tmp33 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -184($r15)	# spill _tmp33 from $r3 to $r15-184
	# _tmp34 = array + _tmp33
	  ldq		$r1, 8($r15)	# fill array to $r1 from $r15+8
	  ldq		$r2, -184($r15)	# fill _tmp33 to $r2 from $r15-184
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -192($r15)	# spill _tmp34 from $r3 to $r15-192
	# _tmp35 = *(_tmp34)
	  ldq		$r1, -192($r15)	# fill _tmp34 to $r1 from $r15-192
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -200($r15)	# spill _tmp35 from $r3 to $r15-200
	# *(_tmp30) = _tmp35
	  ldq		$r1, -200($r15)	# fill _tmp35 to $r1 from $r15-200
	  ldq		$r3, -160($r15)	# fill _tmp30 to $r3 from $r15-160
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L5
	  br		__L5		# unconditional branch
__L6:
	# PushParam left
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -40($r15)	# fill left to $r1 from $r15-40
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _mergeSort
	  bsr		$r26, _mergeSort	# branch to function
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# _tmp36 = end - mid
	  ldq		$r1, -32($r15)	# fill end to $r1 from $r15-32
	  ldq		$r2, -24($r15)	# fill mid to $r2 from $r15-24
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp36 from $r3 to $r15-208
	# _tmp37 = _tmp36 + 1
	  ldq		$r1, -208($r15)	# fill _tmp36 to $r1 from $r15-208
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -216($r15)	# spill _tmp37 from $r3 to $r15-216
	# PushParam _tmp37
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -216($r15)	# fill _tmp37 to $r1 from $r15-216
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp38 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -224($r15)	# spill _tmp38 from $r3 to $r15-224
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp38) = _tmp36
	  ldq		$r1, -208($r15)	# fill _tmp36 to $r1 from $r15-208
	  ldq		$r3, -224($r15)	# fill _tmp38 to $r3 from $r15-224
	  stq		$r1, 0($r3)	# store with offset
	# _tmp39 = _tmp38 + 8
	  ldq		$r1, -224($r15)	# fill _tmp38 to $r1 from $r15-224
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -232($r15)	# spill _tmp39 from $r3 to $r15-232
	# right = _tmp39
	  ldq		$r3, -232($r15)	# fill _tmp39 to $r3 from $r15-232
	  stq		$r3, -48($r15)	# spill right from $r3 to $r15-48
	# _tmp40 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -240($r15)	# spill _tmp40 from $r3 to $r15-240
	# i = _tmp40
	  ldq		$r3, -240($r15)	# fill _tmp40 to $r3 from $r15-240
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L9:
	# _tmp41 = end - mid
	  ldq		$r1, -32($r15)	# fill end to $r1 from $r15-32
	  ldq		$r2, -24($r15)	# fill mid to $r2 from $r15-24
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -248($r15)	# spill _tmp41 from $r3 to $r15-248
	# _tmp42 = i < _tmp41
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -248($r15)	# fill _tmp41 to $r2 from $r15-248
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -256($r15)	# spill _tmp42 from $r3 to $r15-256
	# IfZ _tmp42 Goto __L10
	  ldq		$r1, -256($r15)	# fill _tmp42 to $r1 from $r15-256
	  blbc		$r1, __L10	# branch if _tmp42 is zero
	# _tmp43 = *(right + -8)
	  ldq		$r1, -48($r15)	# fill right to $r1 from $r15-48
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -264($r15)	# spill _tmp43 from $r3 to $r15-264
	# _tmp44 = _tmp43 u<= i
	  ldq		$r1, -264($r15)	# fill _tmp43 to $r1 from $r15-264
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -272($r15)	# spill _tmp44 from $r3 to $r15-272
	# IfZ _tmp44 Goto __L11
	  ldq		$r1, -272($r15)	# fill _tmp44 to $r1 from $r15-272
	  blbc		$r1, __L11	# branch if _tmp44 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L11:
	# _tmp45 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -280($r15)	# spill _tmp45 from $r3 to $r15-280
	# _tmp46 = right + _tmp45
	  ldq		$r1, -48($r15)	# fill right to $r1 from $r15-48
	  ldq		$r2, -280($r15)	# fill _tmp45 to $r2 from $r15-280
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp46 from $r3 to $r15-288
	# _tmp47 = mid + i
	  ldq		$r1, -24($r15)	# fill mid to $r1 from $r15-24
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -296($r15)	# spill _tmp47 from $r3 to $r15-296
	# _tmp48 = *(array + -8)
	  ldq		$r1, 8($r15)	# fill array to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -304($r15)	# spill _tmp48 from $r3 to $r15-304
	# _tmp49 = _tmp48 u<= _tmp47
	  ldq		$r1, -304($r15)	# fill _tmp48 to $r1 from $r15-304
	  ldq		$r2, -296($r15)	# fill _tmp47 to $r2 from $r15-296
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -312($r15)	# spill _tmp49 from $r3 to $r15-312
	# IfZ _tmp49 Goto __L12
	  ldq		$r1, -312($r15)	# fill _tmp49 to $r1 from $r15-312
	  blbc		$r1, __L12	# branch if _tmp49 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L12:
	# _tmp50 = _tmp47 << 3
	  ldq		$r1, -296($r15)	# fill _tmp47 to $r1 from $r15-296
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -320($r15)	# spill _tmp50 from $r3 to $r15-320
	# _tmp51 = array + _tmp50
	  ldq		$r1, 8($r15)	# fill array to $r1 from $r15+8
	  ldq		$r2, -320($r15)	# fill _tmp50 to $r2 from $r15-320
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -328($r15)	# spill _tmp51 from $r3 to $r15-328
	# _tmp52 = *(_tmp51)
	  ldq		$r1, -328($r15)	# fill _tmp51 to $r1 from $r15-328
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -336($r15)	# spill _tmp52 from $r3 to $r15-336
	# *(_tmp46) = _tmp52
	  ldq		$r1, -336($r15)	# fill _tmp52 to $r1 from $r15-336
	  ldq		$r3, -288($r15)	# fill _tmp46 to $r3 from $r15-288
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L9
	  br		__L9		# unconditional branch
__L10:
	# PushParam right
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -48($r15)	# fill right to $r1 from $r15-48
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _mergeSort
	  bsr		$r26, _mergeSort	# branch to function
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# PushParam array
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 8($r15)	# fill array to $r1 from $r15+8
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam right
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -48($r15)	# fill right to $r1 from $r15-48
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam left
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -40($r15)	# fill left to $r1 from $r15-40
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _merge
	  bsr		$r26, _merge	# branch to function
	# PopParams 24
	  addq		$r30, 24, $r30	# pop params off stack
	# _tmp53 = *(left + -8)
	  ldq		$r1, -40($r15)	# fill left to $r1 from $r15-40
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -344($r15)	# spill _tmp53 from $r3 to $r15-344
	# _tmp53 += 1
	  ldq		$r3, -344($r15)	# fill _tmp53 to $r3 from $r15-344
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -344($r15)	# spill _tmp53 from $r3 to $r15-344
	# _tmp54 = left - 8
	  ldq		$r1, -40($r15)	# fill left to $r1 from $r15-40
	  subq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -352($r15)	# spill _tmp54 from $r3 to $r15-352
	# PushParam _tmp54
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -352($r15)	# fill _tmp54 to $r1 from $r15-352
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp53
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -344($r15)	# fill _tmp53 to $r1 from $r15-344
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall __Free
	  bsr		$r26, __Free	# branch to function
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# _tmp55 = *(right + -8)
	  ldq		$r1, -48($r15)	# fill right to $r1 from $r15-48
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -360($r15)	# spill _tmp55 from $r3 to $r15-360
	# _tmp55 += 1
	  ldq		$r3, -360($r15)	# fill _tmp55 to $r3 from $r15-360
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -360($r15)	# spill _tmp55 from $r3 to $r15-360
	# _tmp56 = right - 8
	  ldq		$r1, -48($r15)	# fill right to $r1 from $r15-48
	  subq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -368($r15)	# spill _tmp56 from $r3 to $r15-368
	# PushParam _tmp56
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -368($r15)	# fill _tmp56 to $r1 from $r15-368
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp55
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -360($r15)	# fill _tmp55 to $r1 from $r15-360
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
_merge:
	# BeginFunc 512
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 512	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp57 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -32($r15)	# spill _tmp57 from $r3 to $r15-32
	# posA = _tmp57
	  ldq		$r3, -32($r15)	# fill _tmp57 to $r3 from $r15-32
	  stq		$r3, -16($r15)	# spill posA from $r3 to $r15-16
	# _tmp58 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -40($r15)	# spill _tmp58 from $r3 to $r15-40
	# posB = _tmp58
	  ldq		$r3, -40($r15)	# fill _tmp58 to $r3 from $r15-40
	  stq		$r3, -24($r15)	# spill posB from $r3 to $r15-24
__L13:
	# _tmp59 = *(a + -8)
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -48($r15)	# spill _tmp59 from $r3 to $r15-48
	# _tmp60 = posA < _tmp59
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  ldq		$r2, -48($r15)	# fill _tmp59 to $r2 from $r15-48
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -56($r15)	# spill _tmp60 from $r3 to $r15-56
	# _tmp61 = *(b + -8)
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -64($r15)	# spill _tmp61 from $r3 to $r15-64
	# _tmp62 = posB < _tmp61
	  ldq		$r1, -24($r15)	# fill posB to $r1 from $r15-24
	  ldq		$r2, -64($r15)	# fill _tmp61 to $r2 from $r15-64
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -72($r15)	# spill _tmp62 from $r3 to $r15-72
	# _tmp63 = _tmp60 && _tmp62
	  ldq		$r1, -56($r15)	# fill _tmp60 to $r1 from $r15-56
	  ldq		$r2, -72($r15)	# fill _tmp62 to $r2 from $r15-72
	  and		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp63 from $r3 to $r15-80
	# IfZ _tmp63 Goto __L14
	  ldq		$r1, -80($r15)	# fill _tmp63 to $r1 from $r15-80
	  blbc		$r1, __L14	# branch if _tmp63 is zero
	# _tmp64 = *(a + -8)
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -88($r15)	# spill _tmp64 from $r3 to $r15-88
	# _tmp65 = _tmp64 u<= posA
	  ldq		$r1, -88($r15)	# fill _tmp64 to $r1 from $r15-88
	  ldq		$r2, -16($r15)	# fill posA to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp65 from $r3 to $r15-96
	# IfZ _tmp65 Goto __L15
	  ldq		$r1, -96($r15)	# fill _tmp65 to $r1 from $r15-96
	  blbc		$r1, __L15	# branch if _tmp65 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L15:
	# _tmp66 = posA << 3
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -104($r15)	# spill _tmp66 from $r3 to $r15-104
	# _tmp67 = a + _tmp66
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r2, -104($r15)	# fill _tmp66 to $r2 from $r15-104
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp67 from $r3 to $r15-112
	# _tmp68 = *(_tmp67)
	  ldq		$r1, -112($r15)	# fill _tmp67 to $r1 from $r15-112
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -120($r15)	# spill _tmp68 from $r3 to $r15-120
	# _tmp69 = *(b + -8)
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -128($r15)	# spill _tmp69 from $r3 to $r15-128
	# _tmp70 = _tmp69 u<= posB
	  ldq		$r1, -128($r15)	# fill _tmp69 to $r1 from $r15-128
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -136($r15)	# spill _tmp70 from $r3 to $r15-136
	# IfZ _tmp70 Goto __L16
	  ldq		$r1, -136($r15)	# fill _tmp70 to $r1 from $r15-136
	  blbc		$r1, __L16	# branch if _tmp70 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L16:
	# _tmp71 = posB << 3
	  ldq		$r1, -24($r15)	# fill posB to $r1 from $r15-24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp71 from $r3 to $r15-144
	# _tmp72 = b + _tmp71
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r2, -144($r15)	# fill _tmp71 to $r2 from $r15-144
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -152($r15)	# spill _tmp72 from $r3 to $r15-152
	# _tmp73 = *(_tmp72)
	  ldq		$r1, -152($r15)	# fill _tmp72 to $r1 from $r15-152
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -160($r15)	# spill _tmp73 from $r3 to $r15-160
	# _tmp74 = _tmp68 <= _tmp73
	  ldq		$r1, -120($r15)	# fill _tmp68 to $r1 from $r15-120
	  ldq		$r2, -160($r15)	# fill _tmp73 to $r2 from $r15-160
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -168($r15)	# spill _tmp74 from $r3 to $r15-168
	# IfZ _tmp74 Goto __L17
	  ldq		$r1, -168($r15)	# fill _tmp74 to $r1 from $r15-168
	  blbc		$r1, __L17	# branch if _tmp74 is zero
	# _tmp75 = posA + posB
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp75 from $r3 to $r15-176
	# _tmp76 = *(whole + -8)
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -184($r15)	# spill _tmp76 from $r3 to $r15-184
	# _tmp77 = _tmp76 u<= _tmp75
	  ldq		$r1, -184($r15)	# fill _tmp76 to $r1 from $r15-184
	  ldq		$r2, -176($r15)	# fill _tmp75 to $r2 from $r15-176
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -192($r15)	# spill _tmp77 from $r3 to $r15-192
	# IfZ _tmp77 Goto __L18
	  ldq		$r1, -192($r15)	# fill _tmp77 to $r1 from $r15-192
	  blbc		$r1, __L18	# branch if _tmp77 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L18:
	# _tmp78 = _tmp75 << 3
	  ldq		$r1, -176($r15)	# fill _tmp75 to $r1 from $r15-176
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -200($r15)	# spill _tmp78 from $r3 to $r15-200
	# _tmp79 = whole + _tmp78
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r2, -200($r15)	# fill _tmp78 to $r2 from $r15-200
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp79 from $r3 to $r15-208
	# _tmp80 = *(a + -8)
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -216($r15)	# spill _tmp80 from $r3 to $r15-216
	# _tmp81 = _tmp80 u<= posA
	  ldq		$r1, -216($r15)	# fill _tmp80 to $r1 from $r15-216
	  ldq		$r2, -16($r15)	# fill posA to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -224($r15)	# spill _tmp81 from $r3 to $r15-224
	# IfZ _tmp81 Goto __L19
	  ldq		$r1, -224($r15)	# fill _tmp81 to $r1 from $r15-224
	  blbc		$r1, __L19	# branch if _tmp81 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L19:
	# _tmp82 = posA << 3
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -232($r15)	# spill _tmp82 from $r3 to $r15-232
	# _tmp83 = a + _tmp82
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r2, -232($r15)	# fill _tmp82 to $r2 from $r15-232
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -240($r15)	# spill _tmp83 from $r3 to $r15-240
	# _tmp84 = *(_tmp83)
	  ldq		$r1, -240($r15)	# fill _tmp83 to $r1 from $r15-240
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -248($r15)	# spill _tmp84 from $r3 to $r15-248
	# *(_tmp79) = _tmp84
	  ldq		$r1, -248($r15)	# fill _tmp84 to $r1 from $r15-248
	  ldq		$r3, -208($r15)	# fill _tmp79 to $r3 from $r15-208
	  stq		$r1, 0($r3)	# store with offset
	# posA += 1
	  ldq		$r3, -16($r15)	# fill posA to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill posA from $r3 to $r15-16
	# Goto __L20
	  br		__L20		# unconditional branch
__L17:
	# _tmp85 = posA + posB
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -256($r15)	# spill _tmp85 from $r3 to $r15-256
	# _tmp86 = *(whole + -8)
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -264($r15)	# spill _tmp86 from $r3 to $r15-264
	# _tmp87 = _tmp86 u<= _tmp85
	  ldq		$r1, -264($r15)	# fill _tmp86 to $r1 from $r15-264
	  ldq		$r2, -256($r15)	# fill _tmp85 to $r2 from $r15-256
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -272($r15)	# spill _tmp87 from $r3 to $r15-272
	# IfZ _tmp87 Goto __L21
	  ldq		$r1, -272($r15)	# fill _tmp87 to $r1 from $r15-272
	  blbc		$r1, __L21	# branch if _tmp87 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L21:
	# _tmp88 = _tmp85 << 3
	  ldq		$r1, -256($r15)	# fill _tmp85 to $r1 from $r15-256
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -280($r15)	# spill _tmp88 from $r3 to $r15-280
	# _tmp89 = whole + _tmp88
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r2, -280($r15)	# fill _tmp88 to $r2 from $r15-280
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp89 from $r3 to $r15-288
	# _tmp90 = *(b + -8)
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -296($r15)	# spill _tmp90 from $r3 to $r15-296
	# _tmp91 = _tmp90 u<= posB
	  ldq		$r1, -296($r15)	# fill _tmp90 to $r1 from $r15-296
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -304($r15)	# spill _tmp91 from $r3 to $r15-304
	# IfZ _tmp91 Goto __L22
	  ldq		$r1, -304($r15)	# fill _tmp91 to $r1 from $r15-304
	  blbc		$r1, __L22	# branch if _tmp91 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L22:
	# _tmp92 = posB << 3
	  ldq		$r1, -24($r15)	# fill posB to $r1 from $r15-24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -312($r15)	# spill _tmp92 from $r3 to $r15-312
	# _tmp93 = b + _tmp92
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r2, -312($r15)	# fill _tmp92 to $r2 from $r15-312
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -320($r15)	# spill _tmp93 from $r3 to $r15-320
	# _tmp94 = *(_tmp93)
	  ldq		$r1, -320($r15)	# fill _tmp93 to $r1 from $r15-320
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -328($r15)	# spill _tmp94 from $r3 to $r15-328
	# *(_tmp89) = _tmp94
	  ldq		$r1, -328($r15)	# fill _tmp94 to $r1 from $r15-328
	  ldq		$r3, -288($r15)	# fill _tmp89 to $r3 from $r15-288
	  stq		$r1, 0($r3)	# store with offset
	# posB += 1
	  ldq		$r3, -24($r15)	# fill posB to $r3 from $r15-24
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill posB from $r3 to $r15-24
__L20:
	# Goto __L13
	  br		__L13		# unconditional branch
__L14:
__L23:
	# _tmp95 = *(a + -8)
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -336($r15)	# spill _tmp95 from $r3 to $r15-336
	# _tmp96 = posA < _tmp95
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  ldq		$r2, -336($r15)	# fill _tmp95 to $r2 from $r15-336
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -344($r15)	# spill _tmp96 from $r3 to $r15-344
	# IfZ _tmp96 Goto __L24
	  ldq		$r1, -344($r15)	# fill _tmp96 to $r1 from $r15-344
	  blbc		$r1, __L24	# branch if _tmp96 is zero
	# _tmp97 = posA + posB
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -352($r15)	# spill _tmp97 from $r3 to $r15-352
	# _tmp98 = *(whole + -8)
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -360($r15)	# spill _tmp98 from $r3 to $r15-360
	# _tmp99 = _tmp98 u<= _tmp97
	  ldq		$r1, -360($r15)	# fill _tmp98 to $r1 from $r15-360
	  ldq		$r2, -352($r15)	# fill _tmp97 to $r2 from $r15-352
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -368($r15)	# spill _tmp99 from $r3 to $r15-368
	# IfZ _tmp99 Goto __L25
	  ldq		$r1, -368($r15)	# fill _tmp99 to $r1 from $r15-368
	  blbc		$r1, __L25	# branch if _tmp99 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L25:
	# _tmp100 = _tmp97 << 3
	  ldq		$r1, -352($r15)	# fill _tmp97 to $r1 from $r15-352
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -376($r15)	# spill _tmp100 from $r3 to $r15-376
	# _tmp101 = whole + _tmp100
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r2, -376($r15)	# fill _tmp100 to $r2 from $r15-376
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -384($r15)	# spill _tmp101 from $r3 to $r15-384
	# _tmp102 = *(a + -8)
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -392($r15)	# spill _tmp102 from $r3 to $r15-392
	# _tmp103 = _tmp102 u<= posA
	  ldq		$r1, -392($r15)	# fill _tmp102 to $r1 from $r15-392
	  ldq		$r2, -16($r15)	# fill posA to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -400($r15)	# spill _tmp103 from $r3 to $r15-400
	# IfZ _tmp103 Goto __L26
	  ldq		$r1, -400($r15)	# fill _tmp103 to $r1 from $r15-400
	  blbc		$r1, __L26	# branch if _tmp103 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L26:
	# _tmp104 = posA << 3
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -408($r15)	# spill _tmp104 from $r3 to $r15-408
	# _tmp105 = a + _tmp104
	  ldq		$r1, 8($r15)	# fill a to $r1 from $r15+8
	  ldq		$r2, -408($r15)	# fill _tmp104 to $r2 from $r15-408
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -416($r15)	# spill _tmp105 from $r3 to $r15-416
	# _tmp106 = *(_tmp105)
	  ldq		$r1, -416($r15)	# fill _tmp105 to $r1 from $r15-416
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -424($r15)	# spill _tmp106 from $r3 to $r15-424
	# *(_tmp101) = _tmp106
	  ldq		$r1, -424($r15)	# fill _tmp106 to $r1 from $r15-424
	  ldq		$r3, -384($r15)	# fill _tmp101 to $r3 from $r15-384
	  stq		$r1, 0($r3)	# store with offset
	# posA += 1
	  ldq		$r3, -16($r15)	# fill posA to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill posA from $r3 to $r15-16
	# Goto __L23
	  br		__L23		# unconditional branch
__L24:
__L27:
	# _tmp107 = *(b + -8)
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -432($r15)	# spill _tmp107 from $r3 to $r15-432
	# _tmp108 = posB < _tmp107
	  ldq		$r1, -24($r15)	# fill posB to $r1 from $r15-24
	  ldq		$r2, -432($r15)	# fill _tmp107 to $r2 from $r15-432
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -440($r15)	# spill _tmp108 from $r3 to $r15-440
	# IfZ _tmp108 Goto __L28
	  ldq		$r1, -440($r15)	# fill _tmp108 to $r1 from $r15-440
	  blbc		$r1, __L28	# branch if _tmp108 is zero
	# _tmp109 = posA + posB
	  ldq		$r1, -16($r15)	# fill posA to $r1 from $r15-16
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -448($r15)	# spill _tmp109 from $r3 to $r15-448
	# _tmp110 = *(whole + -8)
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -456($r15)	# spill _tmp110 from $r3 to $r15-456
	# _tmp111 = _tmp110 u<= _tmp109
	  ldq		$r1, -456($r15)	# fill _tmp110 to $r1 from $r15-456
	  ldq		$r2, -448($r15)	# fill _tmp109 to $r2 from $r15-448
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -464($r15)	# spill _tmp111 from $r3 to $r15-464
	# IfZ _tmp111 Goto __L29
	  ldq		$r1, -464($r15)	# fill _tmp111 to $r1 from $r15-464
	  blbc		$r1, __L29	# branch if _tmp111 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L29:
	# _tmp112 = _tmp109 << 3
	  ldq		$r1, -448($r15)	# fill _tmp109 to $r1 from $r15-448
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -472($r15)	# spill _tmp112 from $r3 to $r15-472
	# _tmp113 = whole + _tmp112
	  ldq		$r1, 24($r15)	# fill whole to $r1 from $r15+24
	  ldq		$r2, -472($r15)	# fill _tmp112 to $r2 from $r15-472
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -480($r15)	# spill _tmp113 from $r3 to $r15-480
	# _tmp114 = *(b + -8)
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -488($r15)	# spill _tmp114 from $r3 to $r15-488
	# _tmp115 = _tmp114 u<= posB
	  ldq		$r1, -488($r15)	# fill _tmp114 to $r1 from $r15-488
	  ldq		$r2, -24($r15)	# fill posB to $r2 from $r15-24
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -496($r15)	# spill _tmp115 from $r3 to $r15-496
	# IfZ _tmp115 Goto __L30
	  ldq		$r1, -496($r15)	# fill _tmp115 to $r1 from $r15-496
	  blbc		$r1, __L30	# branch if _tmp115 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L30:
	# _tmp116 = posB << 3
	  ldq		$r1, -24($r15)	# fill posB to $r1 from $r15-24
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -504($r15)	# spill _tmp116 from $r3 to $r15-504
	# _tmp117 = b + _tmp116
	  ldq		$r1, 16($r15)	# fill b to $r1 from $r15+16
	  ldq		$r2, -504($r15)	# fill _tmp116 to $r2 from $r15-504
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -512($r15)	# spill _tmp117 from $r3 to $r15-512
	# _tmp118 = *(_tmp117)
	  ldq		$r1, -512($r15)	# fill _tmp117 to $r1 from $r15-512
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -520($r15)	# spill _tmp118 from $r3 to $r15-520
	# *(_tmp113) = _tmp118
	  ldq		$r1, -520($r15)	# fill _tmp118 to $r1 from $r15-520
	  ldq		$r3, -480($r15)	# fill _tmp113 to $r3 from $r15-480
	  stq		$r1, 0($r3)	# store with offset
	# posB += 1
	  ldq		$r3, -24($r15)	# fill posB to $r3 from $r15-24
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill posB from $r3 to $r15-24
	# Goto __L27
	  br		__L27		# unconditional branch
__L28:
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
