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
	# BeginFunc 304
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 304	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = "Hello World!"
	  .data				# create string constant marked with label
	  .quad 13			# for bounds checking on char access
	  __string1: .asciz "Hello World!"
	  .align 3			# force everything to start on quadword-aligned addresses
	  .text
	  lda		$r3, __string1-L_DATA+data # a hack!
	  stq		$r3, -32($r15)	# spill _tmp0 from $r3 to $r15-32
	# str = _tmp0
	  ldq		$r3, -32($r15)	# fill _tmp0 to $r3 from $r15-32
	  stq		$r3, -24($r15)	# spill str from $r3 to $r15-24
	# PushParam str
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp1 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -40($r15)	# spill _tmp1 from $r3 to $r15-40
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# _tmp2 = _tmp1 + 1
	  ldq		$r1, -40($r15)	# fill _tmp1 to $r1 from $r15-40
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -48($r15)	# spill _tmp2 from $r3 to $r15-48
	# PushParam _tmp2
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -48($r15)	# fill _tmp2 to $r1 from $r15-48
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp3 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -56($r15)	# spill _tmp3 from $r3 to $r15-56
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp3) = _tmp1
	  ldq		$r1, -40($r15)	# fill _tmp1 to $r1 from $r15-40
	  ldq		$r3, -56($r15)	# fill _tmp3 to $r3 from $r15-56
	  stq		$r1, 0($r3)	# store with offset
	# _tmp4 = _tmp3 + 8
	  ldq		$r1, -56($r15)	# fill _tmp3 to $r1 from $r15-56
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp4 from $r3 to $r15-64
	# array1 = _tmp4
	  ldq		$r3, -64($r15)	# fill _tmp4 to $r3 from $r15-64
	  stq		$r3, 0($r29)	# spill array1 from $r3 to $r29+0
	# PushParam str
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp5 = LCall __StringLength
	  bsr		$r26, __StringLength	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -72($r15)	# spill _tmp5 from $r3 to $r15-72
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# _tmp6 = _tmp5 + 1
	  ldq		$r1, -72($r15)	# fill _tmp5 to $r1 from $r15-72
	  addq		$r1, 1, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp6 from $r3 to $r15-80
	# PushParam _tmp6
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -80($r15)	# fill _tmp6 to $r1 from $r15-80
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp7 = LCall __Alloc
	  bsr		$r26, __Alloc	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -88($r15)	# spill _tmp7 from $r3 to $r15-88
	# PopParams 8
	  addq		$r30, 8, $r30	# pop params off stack
	# *(_tmp7) = _tmp5
	  ldq		$r1, -72($r15)	# fill _tmp5 to $r1 from $r15-72
	  ldq		$r3, -88($r15)	# fill _tmp7 to $r3 from $r15-88
	  stq		$r1, 0($r3)	# store with offset
	# _tmp8 = _tmp7 + 8
	  ldq		$r1, -88($r15)	# fill _tmp7 to $r1 from $r15-88
	  addq		$r1, 8, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp8 from $r3 to $r15-96
	# array2 = _tmp8
	  ldq		$r3, -96($r15)	# fill _tmp8 to $r3 from $r15-96
	  stq		$r3, 8($r29)	# spill array2 from $r3 to $r29+8
	# _tmp9 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -104($r15)	# spill _tmp9 from $r3 to $r15-104
	# i = _tmp9
	  ldq		$r3, -104($r15)	# fill _tmp9 to $r3 from $r15-104
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L0:
	# _tmp10 = *(array1 + -8)
	  ldq		$r1, 0($r29)	# fill array1 to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -112($r15)	# spill _tmp10 from $r3 to $r15-112
	# _tmp11 = i < _tmp10
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -112($r15)	# fill _tmp10 to $r2 from $r15-112
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp11 from $r3 to $r15-120
	# IfZ _tmp11 Goto __L1
	  ldq		$r1, -120($r15)	# fill _tmp11 to $r1 from $r15-120
	  blbc		$r1, __L1	# branch if _tmp11 is zero
	# _tmp12 = *(array1 + -8)
	  ldq		$r1, 0($r29)	# fill array1 to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -128($r15)	# spill _tmp12 from $r3 to $r15-128
	# _tmp13 = _tmp12 u<= i
	  ldq		$r1, -128($r15)	# fill _tmp12 to $r1 from $r15-128
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -136($r15)	# spill _tmp13 from $r3 to $r15-136
	# IfZ _tmp13 Goto __L2
	  ldq		$r1, -136($r15)	# fill _tmp13 to $r1 from $r15-136
	  blbc		$r1, __L2	# branch if _tmp13 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L2:
	# _tmp14 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp14 from $r3 to $r15-144
	# _tmp15 = array1 + _tmp14
	  ldq		$r1, 0($r29)	# fill array1 to $r1 from $r29+0
	  ldq		$r2, -144($r15)	# fill _tmp14 to $r2 from $r15-144
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -152($r15)	# spill _tmp15 from $r3 to $r15-152
	# _tmp16 = *(str + -8)
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -160($r15)	# spill _tmp16 from $r3 to $r15-160
	# _tmp17 = _tmp16 u<= i
	  ldq		$r1, -160($r15)	# fill _tmp16 to $r1 from $r15-160
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -168($r15)	# spill _tmp17 from $r3 to $r15-168
	# IfZ _tmp17 Goto __L3
	  ldq		$r1, -168($r15)	# fill _tmp17 to $r1 from $r15-168
	  blbc		$r1, __L3	# branch if _tmp17 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L3:
	# _tmp18 = *(str + i) // extract byte
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  addq		$r1, $r2, $r1	# compute address
	  bic		$r1, 7, $r1
	  ldq		$r3, 0($r1)
	  sll		$r2, 3, $r2
	  srl		$r3, $r2, $r3
	  and		$r3, 0xFF, $r3	# mask to get low-byte
	  stq		$r3, -176($r15)	# spill _tmp18 from $r3 to $r15-176
	# *(_tmp15) = _tmp18
	  ldq		$r1, -176($r15)	# fill _tmp18 to $r1 from $r15-176
	  ldq		$r3, -152($r15)	# fill _tmp15 to $r3 from $r15-152
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L0
	  br		__L0		# unconditional branch
__L1:
	# _tmp19 = 6
	  lda		$r3, 6		# load (signed) int constant value 6 into $r3
	  stq		$r3, -184($r15)	# spill _tmp19 from $r3 to $r15-184
	# _tmp20 = _tmp19 < ZERO
	  ldq		$r1, -184($r15)	# fill _tmp19 to $r1 from $r15-184
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -192($r15)	# spill _tmp20 from $r3 to $r15-192
	# _tmp21 = *(str + -8)
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -200($r15)	# spill _tmp21 from $r3 to $r15-200
	# _tmp22 = _tmp21 <= _tmp19
	  ldq		$r1, -200($r15)	# fill _tmp21 to $r1 from $r15-200
	  ldq		$r2, -184($r15)	# fill _tmp19 to $r2 from $r15-184
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp22 from $r3 to $r15-208
	# _tmp23 = _tmp20 || _tmp22
	  ldq		$r1, -192($r15)	# fill _tmp20 to $r1 from $r15-192
	  ldq		$r2, -208($r15)	# fill _tmp22 to $r2 from $r15-208
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -216($r15)	# spill _tmp23 from $r3 to $r15-216
	# IfZ _tmp23 Goto __L4
	  ldq		$r1, -216($r15)	# fill _tmp23 to $r1 from $r15-216
	  blbc		$r1, __L4	# branch if _tmp23 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L4:
	# _tmp24 = 'w'
	  mov		119, $r3		# load constant value 119 into $r3
	  stq		$r3, -224($r15)	# spill _tmp24 from $r3 to $r15-224
	# _tmp25 = str u< HEAP
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  cmpult	$r1, $r28, $r3	# perform the ALU op
	  stq		$r3, -232($r15)	# spill _tmp25 from $r3 to $r15-232
	# IfZ _tmp25 Goto __L5
	  ldq		$r1, -232($r15)	# fill _tmp25 to $r1 from $r15-232
	  blbc		$r1, __L5	# branch if _tmp25 is zero
	# Throw Exception: Store outside heap not allowed (indexing string referring to const literal)
	  call_pal	0xDECAF		# (exception: Store outside heap not allowed (indexing string referring to const literal))
	  call_pal	0x555		# (halt)
__L5:
	# *(str + _tmp19) = _tmp24 // insert byte
	  ldq		$r3, -24($r15)	# fill str to $r3 from $r15-24
	  ldq		$r2, -184($r15)	# fill _tmp19 to $r2 from $r15-184
	  addq		$r3, $r2, $r3	# compute address
	  bic		$r3, 7, $r3
	  ldq		$r4, 0($r3)
	  lda		$r1, 0xFF
	  sll		$r2, 3, $r2
	  sll		$r1, $r2, $r1
	  bic		$r4, $r1, $r4	# clear the byte
	  ldq		$r1, -224($r15)	# fill _tmp24 to $r1 from $r15-224
	  and		$r1, 0xFF, $r1	# for good measure
	  sll		$r1, $r2, $r1
	  bis		$r4, $r1, $r4	# insert the byte
	  stq		$r4, 0($r3)
	# _tmp26 = 0
	  lda		$r3, 0		# load (unsigned) int constant value 0 into $r3
	  stq		$r3, -240($r15)	# spill _tmp26 from $r3 to $r15-240
	# i = _tmp26
	  ldq		$r3, -240($r15)	# fill _tmp26 to $r3 from $r15-240
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L6:
	# _tmp27 = *(array2 + -8)
	  ldq		$r1, 8($r29)	# fill array2 to $r1 from $r29+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -248($r15)	# spill _tmp27 from $r3 to $r15-248
	# _tmp28 = i < _tmp27
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -248($r15)	# fill _tmp27 to $r2 from $r15-248
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -256($r15)	# spill _tmp28 from $r3 to $r15-256
	# IfZ _tmp28 Goto __L7
	  ldq		$r1, -256($r15)	# fill _tmp28 to $r1 from $r15-256
	  blbc		$r1, __L7	# branch if _tmp28 is zero
	# _tmp29 = *(array2 + -8)
	  ldq		$r1, 8($r29)	# fill array2 to $r1 from $r29+8
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -264($r15)	# spill _tmp29 from $r3 to $r15-264
	# _tmp30 = _tmp29 u<= i
	  ldq		$r1, -264($r15)	# fill _tmp29 to $r1 from $r15-264
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -272($r15)	# spill _tmp30 from $r3 to $r15-272
	# IfZ _tmp30 Goto __L8
	  ldq		$r1, -272($r15)	# fill _tmp30 to $r1 from $r15-272
	  blbc		$r1, __L8	# branch if _tmp30 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L8:
	# _tmp31 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -280($r15)	# spill _tmp31 from $r3 to $r15-280
	# _tmp32 = array2 + _tmp31
	  ldq		$r1, 8($r29)	# fill array2 to $r1 from $r29+8
	  ldq		$r2, -280($r15)	# fill _tmp31 to $r2 from $r15-280
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp32 from $r3 to $r15-288
	# _tmp33 = *(str + -8)
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -296($r15)	# spill _tmp33 from $r3 to $r15-296
	# _tmp34 = _tmp33 u<= i
	  ldq		$r1, -296($r15)	# fill _tmp33 to $r1 from $r15-296
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmpule	$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -304($r15)	# spill _tmp34 from $r3 to $r15-304
	# IfZ _tmp34 Goto __L9
	  ldq		$r1, -304($r15)	# fill _tmp34 to $r1 from $r15-304
	  blbc		$r1, __L9	# branch if _tmp34 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L9:
	# _tmp35 = *(str + i) // extract byte
	  ldq		$r1, -24($r15)	# fill str to $r1 from $r15-24
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  addq		$r1, $r2, $r1	# compute address
	  bic		$r1, 7, $r1
	  ldq		$r3, 0($r1)
	  sll		$r2, 3, $r2
	  srl		$r3, $r2, $r3
	  and		$r3, 0xFF, $r3	# mask to get low-byte
	  stq		$r3, -312($r15)	# spill _tmp35 from $r3 to $r15-312
	# *(_tmp32) = _tmp35
	  ldq		$r1, -312($r15)	# fill _tmp35 to $r1 from $r15-312
	  ldq		$r3, -288($r15)	# fill _tmp32 to $r3 from $r15-288
	  stq		$r1, 0($r3)	# store with offset
	# i += 1
	  ldq		$r3, -16($r15)	# fill i to $r3 from $r15-16
	  addq		$r3, 1, $r3	# perform the ALU op
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L6
	  br		__L6		# unconditional branch
__L7:
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
