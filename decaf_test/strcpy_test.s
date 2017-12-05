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
_strcpy:
	# BeginFunc 128
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 128, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -24($r15)	# spill _tmp0 from $r3 to $r15-24
	# i = _tmp0
	  ldq		$r3, -24($r15)	# fill _tmp0 to $r3 from $r15-24
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L0:
	# PushParam src
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 16($r15)	# fill src to $r1 from $r15+16
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp1 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -32($r15)	# spill _tmp1 from $r3 to $r15-32
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# _tmp2 = i < _tmp1
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -32($r15)	# fill _tmp1 to $r2 from $r15-32
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -40($r15)	# spill _tmp2 from $r3 to $r15-40
	# IfZ _tmp2 Goto __L1
	  ldq		$r1, -40($r15)	# fill _tmp2 to $r1 from $r15-40
	  blbc		$r1, __L1	# branch if _tmp2 is zero
	# _tmp3 = i + offset
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, 24($r15)	# fill offset to $r2 from $r15+24
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -48($r15)	# spill _tmp3 from $r3 to $r15-48
	# _tmp4 = *(dst + -8)
	  ldq		$r1, 8($r15)	# fill dst to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -56($r15)	# spill _tmp4 from $r3 to $r15-56
	# _tmp5 = _tmp4 u<= _tmp3
	  ldq		$r1, -56($r15)	# fill _tmp4 to $r1 from $r15-56
	  ldq		$r2, -48($r15)	# fill _tmp3 to $r2 from $r15-48
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp5 from $r3 to $r15-64
	# IfZ _tmp5 Goto __L2
	  ldq		$r1, -64($r15)	# fill _tmp5 to $r1 from $r15-64
	  blbc		$r1, __L2	# branch if _tmp5 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L2:
	# _tmp6 = *(src + -8)
	  ldq		$r1, 16($r15)	# fill src to $r1 from $r15+16
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -72($r15)	# spill _tmp6 from $r3 to $r15-72
	# _tmp7 = _tmp6 u<= i
	  ldq		$r1, -72($r15)	# fill _tmp6 to $r1 from $r15-72
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp7 from $r3 to $r15-80
	# IfZ _tmp7 Goto __L3
	  ldq		$r1, -80($r15)	# fill _tmp7 to $r1 from $r15-80
	  blbc		$r1, __L3	# branch if _tmp7 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L3:
	# _tmp8 = *(src + i) // extract byte
	  ldq		$r1, 16($r15)	# fill src to $r1 from $r15+16
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  addq		$r1, $r2, $r1	# compute address
	  bic		$r1, 7, $r1
	  ldq		$r3, 0($r1)
	  sll		$r2, 3, $r2
	  srl		$r3, $r2, $r3
	  and		$r3, 0xFF, $r3	# mask to get low-byte
	  stq		$r3, -88($r15)	# spill _tmp8 from $r3 to $r15-88
	# _tmp9 = dst u< HEAP
	  ldq		$r1, 8($r15)	# fill dst to $r1 from $r15+8
	  cmpult	$r1, $r28, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp9 from $r3 to $r15-96
	# IfZ _tmp9 Goto __L4
	  ldq		$r1, -96($r15)	# fill _tmp9 to $r1 from $r15-96
	  blbc		$r1, __L4	# branch if _tmp9 is zero
	# Throw Exception: Store outside heap not allowed (indexing string referring to const literal)
	  call_pal	0xDECAF		# (exception: Store outside heap not allowed (indexing string referring to const literal))
	  call_pal	0x555		# (halt)
__L4:
	# *(dst + _tmp3) = _tmp8 // insert byte
	  ldq		$r3, 8($r15)	# fill dst to $r3 from $r15+8
	  ldq		$r2, -48($r15)	# fill _tmp3 to $r2 from $r15-48
	  addq		$r3, $r2, $r3	# compute address
	  bic		$r3, 7, $r3
	  ldq		$r4, 0($r3)
	  lda		$r1, 0xFF
	  sll		$r2, 3, $r2
	  sll		$r1, $r2, $r1
	  bic		$r4, $r1, $r4	# clear the byte
	  ldq		$r1, -88($r15)	# fill _tmp8 to $r1 from $r15-88
	  and		$r1, 0xFF, $r1	# for good measure
	  sll		$r1, $r2, $r1
	  bis		$r4, $r1, $r4	# insert the byte
	  stq		$r4, 0($r3)
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L0
	  br		__L0		# unconditional branch
__L1:
	# _tmp10 = i + offset
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, 24($r15)	# fill offset to $r2 from $r15+24
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -104($r15)	# spill _tmp10 from $r3 to $r15-104
	# _tmp11 = *(dst + -8)
	  ldq		$r1, 8($r15)	# fill dst to $r1 from $r15+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -112($r15)	# spill _tmp11 from $r3 to $r15-112
	# _tmp12 = _tmp11 u<= _tmp10
	  ldq		$r1, -112($r15)	# fill _tmp11 to $r1 from $r15-112
	  ldq		$r2, -104($r15)	# fill _tmp10 to $r2 from $r15-104
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp12 from $r3 to $r15-120
	# IfZ _tmp12 Goto __L5
	  ldq		$r1, -120($r15)	# fill _tmp12 to $r1 from $r15-120
	  blbc		$r1, __L5	# branch if _tmp12 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L5:
	# _tmp13 = '\0'
	  mov		0, $r3		# load constant value 0 into $r3
	  stq		$r3, -128($r15)	# spill _tmp13 from $r3 to $r15-128
	# _tmp14 = dst u< HEAP
	  ldq		$r1, 8($r15)	# fill dst to $r1 from $r15+8
	  cmpult	$r1, $r28, $r3	# perform the ALU op
	  stq		$r3, -136($r15)	# spill _tmp14 from $r3 to $r15-136
	# IfZ _tmp14 Goto __L6
	  ldq		$r1, -136($r15)	# fill _tmp14 to $r1 from $r15-136
	  blbc		$r1, __L6	# branch if _tmp14 is zero
	# Throw Exception: Store outside heap not allowed (indexing string referring to const literal)
	  call_pal	0xDECAF		# (exception: Store outside heap not allowed (indexing string referring to const literal))
	  call_pal	0x555		# (halt)
__L6:
	# *(dst + _tmp10) = _tmp13 // insert byte
	  ldq		$r3, 8($r15)	# fill dst to $r3 from $r15+8
	  ldq		$r2, -104($r15)	# fill _tmp10 to $r2 from $r15-104
	  addq		$r3, $r2, $r3	# compute address
	  bic		$r3, 7, $r3
	  ldq		$r4, 0($r3)
	  lda		$r1, 0xFF
	  sll		$r2, 3, $r2
	  sll		$r1, $r2, $r1
	  bic		$r4, $r1, $r4	# clear the byte
	  ldq		$r1, -128($r15)	# fill _tmp13 to $r1 from $r15-128
	  and		$r1, 0xFF, $r1	# for good measure
	  sll		$r1, $r2, $r1
	  bis		$r4, $r1, $r4	# insert the byte
	  stq		$r4, 0($r3)
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
main:
	# BeginFunc 280
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 280	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp15 = "Hello"
	  .data				# create string constant marked with label
	  .quad 6			# for bounds checking on char access
	  __string1: .asciz "Hello"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string1-L_DATA+data # a hack!
	  stq		$r3, -56($r15)	# spill _tmp15 from $r3 to $r15-56
	# a = _tmp15
	  ldq		$r3, -56($r15)	# fill _tmp15 to $r3 from $r15-56
	  stq		$r3, -16($r15)	# spill a from $r3 to $r15-16
	# _tmp16 = " World!"
	  .data				# create string constant marked with label
	  .quad 8			# for bounds checking on char access
	  __string2: .asciz " World!"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string2-L_DATA+data # a hack!
	  stq		$r3, -64($r15)	# spill _tmp16 from $r3 to $r15-64
	# b = _tmp16
	  ldq		$r3, -64($r15)	# fill _tmp16 to $r3 from $r15-64
	  stq		$r3, -24($r15)	# spill b from $r3 to $r15-24
	# PushParam a
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill a to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp17 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -72($r15)	# spill _tmp17 from $r3 to $r15-72
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# PushParam b
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill b to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp18 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -80($r15)	# spill _tmp18 from $r3 to $r15-80
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# _tmp19 = _tmp17 + _tmp18
	  ldq		$r1, -72($r15)	# fill _tmp17 to $r1 from $r15-72
	  ldq		$r2, -80($r15)	# fill _tmp18 to $r2 from $r15-80
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -88($r15)	# spill _tmp19 from $r3 to $r15-88
	# _tmp20 = 1
	  lda		$r3, 1		# load (unsigned) int constant value 1 into $r3
	  stq		$r3, -96($r15)	# spill _tmp20 from $r3 to $r15-96
	# _tmp21 = _tmp19 + _tmp20
	  ldq		$r1, -88($r15)	# fill _tmp19 to $r1 from $r15-88
	  ldq		$r2, -96($r15)	# fill _tmp20 to $r2 from $r15-96
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -104($r15)	# spill _tmp21 from $r3 to $r15-104
	# _tmp22 = _tmp21 + 15
	  ldq		$r1, -104($r15)	# fill _tmp21 to $r1 from $r15-104
	  addq		$r1, 15, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp22 from $r3 to $r15-112
	# _tmp22 >>a= 3
	  ldq		$r3, -112($r15)	# fill _tmp22 to $r3 from $r15-112
	  sra		$r3, 3, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp22 from $r3 to $r15-112
	# PushParam _tmp22
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -112($r15)	# fill _tmp22 to $r1 from $r15-112
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp23 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -120($r15)	# spill _tmp23 from $r3 to $r15-120
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp23) = _tmp21
	  ldq		$r1, -104($r15)	# fill _tmp21 to $r1 from $r15-104
	  ldq		$r3, -120($r15)	# fill _tmp23 to $r3 from $r15-120
	  stq		$r1, 0($r3)	# store with offset
	# _tmp24 = _tmp23 + 8
	  ldq		$r1, -120($r15)	# fill _tmp23 to $r1 from $r15-120
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -128($r15)	# spill _tmp24 from $r3 to $r15-128
	# c = _tmp24
	  ldq		$r3, -128($r15)	# fill _tmp24 to $r3 from $r15-128
	  stq		$r3, -32($r15)	# spill c from $r3 to $r15-32
	# _tmp25 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -136($r15)	# spill _tmp25 from $r3 to $r15-136
	# PushParam _tmp25
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -136($r15)	# fill _tmp25 to $r1 from $r15-136
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam a
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill a to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam c
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -32($r15)	# fill c to $r1 from $r15-32
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _strcpy
	  bsr		$r26, _strcpy	# branch to function
	# PopParams 24
	  addq		$r30, 24, $r30	# pop params off stack
	# PushParam a
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill a to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp26 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -144($r15)	# spill _tmp26 from $r3 to $r15-144
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# PushParam _tmp26
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -144($r15)	# fill _tmp26 to $r1 from $r15-144
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam b
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill b to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam c
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -32($r15)	# fill c to $r1 from $r15-32
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _strcpy
	  bsr		$r26, _strcpy	# branch to function
	# PopParams 24
	  addq		$r30, 24, $r30	# pop params off stack
	# _tmp27 = 10
	  lda		$r3, 10		# load (unsigned) int constant value 10 into $r3
	  stq		$r3, -152($r15)	# spill _tmp27 from $r3 to $r15-152
	# _tmp28 = _tmp27 + 15
	  ldq		$r1, -152($r15)	# fill _tmp27 to $r1 from $r15-152
	  addq		$r1, 15, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp28 from $r3 to $r15-160
	# _tmp28 >>a= 3
	  ldq		$r3, -160($r15)	# fill _tmp28 to $r3 from $r15-160
	  sra		$r3, 3, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp28 from $r3 to $r15-160
	# PushParam _tmp28
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -160($r15)	# fill _tmp28 to $r1 from $r15-160
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp29 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -168($r15)	# spill _tmp29 from $r3 to $r15-168
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp29) = _tmp27
	  ldq		$r1, -152($r15)	# fill _tmp27 to $r1 from $r15-152
	  ldq		$r3, -168($r15)	# fill _tmp29 to $r3 from $r15-168
	  stq		$r1, 0($r3)	# store with offset
	# _tmp30 = _tmp29 + 8
	  ldq		$r1, -168($r15)	# fill _tmp29 to $r1 from $r15-168
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp30 from $r3 to $r15-176
	# d = _tmp30
	  ldq		$r3, -176($r15)	# fill _tmp30 to $r3 from $r15-176
	  stq		$r3, -40($r15)	# spill d from $r3 to $r15-40
	# _tmp31 = "blah blah"
	  .data				# create string constant marked with label
	  .quad 10			# for bounds checking on char access
	  __string3: .asciz "blah blah"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string3-L_DATA+data # a hack!
	  stq		$r3, -184($r15)	# spill _tmp31 from $r3 to $r15-184
	# _tmp32 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -192($r15)	# spill _tmp32 from $r3 to $r15-192
	# PushParam _tmp32
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -192($r15)	# fill _tmp32 to $r1 from $r15-192
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp31
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -184($r15)	# fill _tmp31 to $r1 from $r15-184
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam d
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -40($r15)	# fill d to $r1 from $r15-40
	  stq		$r1, 8($r30)	# copy param value to stack
	# LCall _strcpy
	  bsr		$r26, _strcpy	# branch to function
	# PopParams 24
	  addq		$r30, 24, $r30	# pop params off stack
	# _tmp33 = 4
	  lda		$r3, 4		# load (signed) int constant value 4 into $r3
	  stq		$r3, -200($r15)	# spill _tmp33 from $r3 to $r15-200
	# _tmp34 = _tmp33 < ZERO
	  ldq		$r1, -200($r15)	# fill _tmp33 to $r1 from $r15-200
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp34 from $r3 to $r15-208
	# _tmp35 = *(d + -8)
	  ldq		$r1, -40($r15)	# fill d to $r1 from $r15-40
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -216($r15)	# spill _tmp35 from $r3 to $r15-216
	# _tmp36 = _tmp35 <= _tmp33
	  ldq		$r1, -216($r15)	# fill _tmp35 to $r1 from $r15-216
	  ldq		$r2, -200($r15)	# fill _tmp33 to $r2 from $r15-200
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -224($r15)	# spill _tmp36 from $r3 to $r15-224
	# _tmp37 = _tmp34 || _tmp36
	  ldq		$r1, -208($r15)	# fill _tmp34 to $r1 from $r15-208
	  ldq		$r2, -224($r15)	# fill _tmp36 to $r2 from $r15-224
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -232($r15)	# spill _tmp37 from $r3 to $r15-232
	# IfZ _tmp37 Goto __L7
	  ldq		$r1, -232($r15)	# fill _tmp37 to $r1 from $r15-232
	  blbc		$r1, __L7	# branch if _tmp37 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L7:
	# _tmp38 = '\0'
	  mov		0, $r3		# load constant value 0 into $r3
	  stq		$r3, -240($r15)	# spill _tmp38 from $r3 to $r15-240
	# _tmp39 = d u< HEAP
	  ldq		$r1, -40($r15)	# fill d to $r1 from $r15-40
	  cmpult	$r1, $r28, $r3	# perform the ALU op
	  stq		$r3, -248($r15)	# spill _tmp39 from $r3 to $r15-248
	# IfZ _tmp39 Goto __L8
	  ldq		$r1, -248($r15)	# fill _tmp39 to $r1 from $r15-248
	  blbc		$r1, __L8	# branch if _tmp39 is zero
	# Throw Exception: Store outside heap not allowed (indexing string referring to const literal)
	  call_pal	0xDECAF		# (exception: Store outside heap not allowed (indexing string referring to const literal))
	  call_pal	0x555		# (halt)
__L8:
	# *(d + _tmp33) = _tmp38 // insert byte
	  ldq		$r3, -40($r15)	# fill d to $r3 from $r15-40
	  ldq		$r2, -200($r15)	# fill _tmp33 to $r2 from $r15-200
	  addq		$r3, $r2, $r3	# compute address
	  bic		$r3, 7, $r3
	  ldq		$r4, 0($r3)
	  lda		$r1, 0xFF
	  sll		$r2, 3, $r2
	  sll		$r1, $r2, $r1
	  bic		$r4, $r1, $r4	# clear the byte
	  ldq		$r1, -240($r15)	# fill _tmp38 to $r1 from $r15-240
	  and		$r1, 0xFF, $r1	# for good measure
	  sll		$r1, $r2, $r1
	  bis		$r4, $r1, $r4	# insert the byte
	  stq		$r4, 0($r3)
	# _tmp40 = 5
	  lda		$r3, 5		# load (signed) int constant value 5 into $r3
	  stq		$r3, -256($r15)	# spill _tmp40 from $r3 to $r15-256
	# x = _tmp40
	  ldq		$r3, -256($r15)	# fill _tmp40 to $r3 from $r15-256
	  stq		$r3, -48($r15)	# spill x from $r3 to $r15-48
	# _tmp41 = 31
	  lda		$r3, 31		# load (signed) int constant value 31 into $r3
	  stq		$r3, -264($r15)	# spill _tmp41 from $r3 to $r15-264
	# _tmp42 = x * _tmp41
	  ldq		$r1, -48($r15)	# fill x to $r1 from $r15-48
	  ldq		$r2, -264($r15)	# fill _tmp41 to $r2 from $r15-264
	  mulq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -272($r15)	# spill _tmp42 from $r3 to $r15-272
	# x = _tmp42
	  ldq		$r3, -272($r15)	# fill _tmp42 to $r3 from $r15-272
	  stq		$r3, -48($r15)	# spill x from $r3 to $r15-48
	# _tmp43 = *(c + -8)
	  ldq		$r1, -32($r15)	# fill c to $r1 from $r15-32
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -280($r15)	# spill _tmp43 from $r3 to $r15-280
	# _tmp43 += 17
	  ldq		$r3, -280($r15)	# fill _tmp43 to $r3 from $r15-280
	  addq		$r3, 17, $r3	# perform the ALU op
	  stq		$r3, -280($r15)	# spill _tmp43 from $r3 to $r15-280
	# _tmp43 >>a= 3
	  ldq		$r3, -280($r15)	# fill _tmp43 to $r3 from $r15-280
	  sra		$r3, 3, $r3	# perform the ALU op
	  stq		$r3, -280($r15)	# spill _tmp43 from $r3 to $r15-280
	# _tmp44 = c - 8
	  ldq		$r1, -32($r15)	# fill c to $r1 from $r15-32
	  subq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp44 from $r3 to $r15-288
	# PushParam _tmp44
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -288($r15)	# fill _tmp44 to $r1 from $r15-288
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp43
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -280($r15)	# fill _tmp43 to $r1 from $r15-280
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
