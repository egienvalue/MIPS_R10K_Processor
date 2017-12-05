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
_Power:
	# BeginFunc 56
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 56, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -16($r15)	# spill _tmp0 from $r3 to $r15-16
	# _tmp1 = N ^~ _tmp0
	  ldq		$r1, 16($r15)	# fill N to $r1 from $r15+16
	  ldq		$r2, -16($r15)	# fill _tmp0 to $r2 from $r15-16
	  eqv		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -24($r15)	# spill _tmp1 from $r3 to $r15-24
	# IfZ _tmp1 Goto __L0
	  ldq		$r1, -24($r15)	# fill _tmp1 to $r1 from $r15-24
	  blbc		$r1, __L0	# branch if _tmp1 is zero
	# _tmp2 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -32($r15)	# spill _tmp2 from $r3 to $r15-32
	# Return _tmp2
	  ldq		$r3, -32($r15)	# fill _tmp2 to $r3 from $r15-32
	  mov		$r3, $r0		# assign return value into $v0
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
	# Goto __L1
	  br		__L1		# unconditional branch
__L0:
	# _tmp3 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -40($r15)	# spill _tmp3 from $r3 to $r15-40
	# _tmp4 = N - _tmp3
	  ldq		$r1, 16($r15)	# fill N to $r1 from $r15+16
	  ldq		$r2, -40($r15)	# fill _tmp3 to $r2 from $r15-40
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -48($r15)	# spill _tmp4 from $r3 to $r15-48
	# PushParam _tmp4
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -48($r15)	# fill _tmp4 to $r1 from $r15-48
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam X
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, 8($r15)	# fill X to $r1 from $r15+8
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp5 = LCall _Power
	  bsr		$r26, _Power	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -56($r15)	# spill _tmp5 from $r3 to $r15-56
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# _tmp6 = _tmp5 * X
	  ldq		$r1, -56($r15)	# fill _tmp5 to $r1 from $r15-56
	  ldq		$r2, 8($r15)	# fill X to $r2 from $r15+8
	  mulq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -64($r15)	# spill _tmp6 from $r3 to $r15-64
	# Return _tmp6
	  ldq		$r3, -64($r15)	# fill _tmp6 to $r3 from $r15-64
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
	# BeginFunc 1248
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  lda		$r2, 1248	# stack frame size
	  subq		$r30, $r2, $r30	# decrement sp to make space for locals/temps
	# _tmp7 = 16
	  lda		$r3, 16		# load (signed) int constant value 16 into $r3
	  stq		$r3, -32($r15)	# spill _tmp7 from $r3 to $r15-32
	# _tmp8 = _tmp7 < ZERO
	  ldq		$r1, -32($r15)	# fill _tmp7 to $r1 from $r15-32
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -40($r15)	# spill _tmp8 from $r3 to $r15-40
	# IfZ _tmp8 Goto __L2
	  ldq		$r1, -40($r15)	# fill _tmp8 to $r1 from $r15-40
	  blbc		$r1, __L2	# branch if _tmp8 is zero
	# Throw Exception: Array size is <= 0
	  call_pal	0xDECAF		# (exception: Array size is <= 0)
	  call_pal	0x555		# (halt)
__L2:
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
	# results = _tmp11
	  ldq		$r3, -64($r15)	# fill _tmp11 to $r3 from $r15-64
	  stq		$r3, 0($r29)	# spill results from $r3 to $r29+0
	# _tmp12 = 0
	  lda		$r3, 0		# load (signed) int constant value 0 into $r3
	  stq		$r3, -72($r15)	# spill _tmp12 from $r3 to $r15-72
	# _tmp13 = _tmp12 < ZERO
	  ldq		$r1, -72($r15)	# fill _tmp12 to $r1 from $r15-72
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -80($r15)	# spill _tmp13 from $r3 to $r15-80
	# _tmp14 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -88($r15)	# spill _tmp14 from $r3 to $r15-88
	# _tmp15 = _tmp14 <= _tmp12
	  ldq		$r1, -88($r15)	# fill _tmp14 to $r1 from $r15-88
	  ldq		$r2, -72($r15)	# fill _tmp12 to $r2 from $r15-72
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -96($r15)	# spill _tmp15 from $r3 to $r15-96
	# _tmp16 = _tmp13 || _tmp15
	  ldq		$r1, -80($r15)	# fill _tmp13 to $r1 from $r15-80
	  ldq		$r2, -96($r15)	# fill _tmp15 to $r2 from $r15-96
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -104($r15)	# spill _tmp16 from $r3 to $r15-104
	# IfZ _tmp16 Goto __L3
	  ldq		$r1, -104($r15)	# fill _tmp16 to $r1 from $r15-104
	  blbc		$r1, __L3	# branch if _tmp16 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L3:
	# _tmp17 = _tmp12 << 3
	  ldq		$r1, -72($r15)	# fill _tmp12 to $r1 from $r15-72
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -112($r15)	# spill _tmp17 from $r3 to $r15-112
	# _tmp18 = results + _tmp17
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -112($r15)	# fill _tmp17 to $r2 from $r15-112
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -120($r15)	# spill _tmp18 from $r3 to $r15-120
	# _tmp19 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -128($r15)	# spill _tmp19 from $r3 to $r15-128
	# *(_tmp18) = _tmp19
	  ldq		$r1, -128($r15)	# fill _tmp19 to $r1 from $r15-128
	  ldq		$r3, -120($r15)	# fill _tmp18 to $r3 from $r15-120
	  stq		$r1, 0($r3)	# store with offset
	# _tmp20 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -136($r15)	# spill _tmp20 from $r3 to $r15-136
	# _tmp21 = _tmp20 < ZERO
	  ldq		$r1, -136($r15)	# fill _tmp20 to $r1 from $r15-136
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -144($r15)	# spill _tmp21 from $r3 to $r15-144
	# _tmp22 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -152($r15)	# spill _tmp22 from $r3 to $r15-152
	# _tmp23 = _tmp22 <= _tmp20
	  ldq		$r1, -152($r15)	# fill _tmp22 to $r1 from $r15-152
	  ldq		$r2, -136($r15)	# fill _tmp20 to $r2 from $r15-136
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -160($r15)	# spill _tmp23 from $r3 to $r15-160
	# _tmp24 = _tmp21 || _tmp23
	  ldq		$r1, -144($r15)	# fill _tmp21 to $r1 from $r15-144
	  ldq		$r2, -160($r15)	# fill _tmp23 to $r2 from $r15-160
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -168($r15)	# spill _tmp24 from $r3 to $r15-168
	# IfZ _tmp24 Goto __L4
	  ldq		$r1, -168($r15)	# fill _tmp24 to $r1 from $r15-168
	  blbc		$r1, __L4	# branch if _tmp24 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L4:
	# _tmp25 = _tmp20 << 3
	  ldq		$r1, -136($r15)	# fill _tmp20 to $r1 from $r15-136
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -176($r15)	# spill _tmp25 from $r3 to $r15-176
	# _tmp26 = results + _tmp25
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -176($r15)	# fill _tmp25 to $r2 from $r15-176
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -184($r15)	# spill _tmp26 from $r3 to $r15-184
	# _tmp27 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -192($r15)	# spill _tmp27 from $r3 to $r15-192
	# *(_tmp26) = _tmp27
	  ldq		$r1, -192($r15)	# fill _tmp27 to $r1 from $r15-192
	  ldq		$r3, -184($r15)	# fill _tmp26 to $r3 from $r15-184
	  stq		$r1, 0($r3)	# store with offset
	# _tmp28 = 2
	  lda		$r3, 2		# load (signed) int constant value 2 into $r3
	  stq		$r3, -200($r15)	# spill _tmp28 from $r3 to $r15-200
	# _tmp29 = _tmp28 < ZERO
	  ldq		$r1, -200($r15)	# fill _tmp28 to $r1 from $r15-200
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -208($r15)	# spill _tmp29 from $r3 to $r15-208
	# _tmp30 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -216($r15)	# spill _tmp30 from $r3 to $r15-216
	# _tmp31 = _tmp30 <= _tmp28
	  ldq		$r1, -216($r15)	# fill _tmp30 to $r1 from $r15-216
	  ldq		$r2, -200($r15)	# fill _tmp28 to $r2 from $r15-200
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -224($r15)	# spill _tmp31 from $r3 to $r15-224
	# _tmp32 = _tmp29 || _tmp31
	  ldq		$r1, -208($r15)	# fill _tmp29 to $r1 from $r15-208
	  ldq		$r2, -224($r15)	# fill _tmp31 to $r2 from $r15-224
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -232($r15)	# spill _tmp32 from $r3 to $r15-232
	# IfZ _tmp32 Goto __L5
	  ldq		$r1, -232($r15)	# fill _tmp32 to $r1 from $r15-232
	  blbc		$r1, __L5	# branch if _tmp32 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L5:
	# _tmp33 = _tmp28 << 3
	  ldq		$r1, -200($r15)	# fill _tmp28 to $r1 from $r15-200
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -240($r15)	# spill _tmp33 from $r3 to $r15-240
	# _tmp34 = results + _tmp33
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -240($r15)	# fill _tmp33 to $r2 from $r15-240
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -248($r15)	# spill _tmp34 from $r3 to $r15-248
	# _tmp35 = 3
	  lda		$r3, 3		# load (signed) int constant value 3 into $r3
	  stq		$r3, -256($r15)	# spill _tmp35 from $r3 to $r15-256
	# *(_tmp34) = _tmp35
	  ldq		$r1, -256($r15)	# fill _tmp35 to $r1 from $r15-256
	  ldq		$r3, -248($r15)	# fill _tmp34 to $r3 from $r15-248
	  stq		$r1, 0($r3)	# store with offset
	# _tmp36 = 3
	  lda		$r3, 3		# load (signed) int constant value 3 into $r3
	  stq		$r3, -264($r15)	# spill _tmp36 from $r3 to $r15-264
	# _tmp37 = _tmp36 < ZERO
	  ldq		$r1, -264($r15)	# fill _tmp36 to $r1 from $r15-264
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -272($r15)	# spill _tmp37 from $r3 to $r15-272
	# _tmp38 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -280($r15)	# spill _tmp38 from $r3 to $r15-280
	# _tmp39 = _tmp38 <= _tmp36
	  ldq		$r1, -280($r15)	# fill _tmp38 to $r1 from $r15-280
	  ldq		$r2, -264($r15)	# fill _tmp36 to $r2 from $r15-264
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -288($r15)	# spill _tmp39 from $r3 to $r15-288
	# _tmp40 = _tmp37 || _tmp39
	  ldq		$r1, -272($r15)	# fill _tmp37 to $r1 from $r15-272
	  ldq		$r2, -288($r15)	# fill _tmp39 to $r2 from $r15-288
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -296($r15)	# spill _tmp40 from $r3 to $r15-296
	# IfZ _tmp40 Goto __L6
	  ldq		$r1, -296($r15)	# fill _tmp40 to $r1 from $r15-296
	  blbc		$r1, __L6	# branch if _tmp40 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L6:
	# _tmp41 = _tmp36 << 3
	  ldq		$r1, -264($r15)	# fill _tmp36 to $r1 from $r15-264
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -304($r15)	# spill _tmp41 from $r3 to $r15-304
	# _tmp42 = results + _tmp41
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -304($r15)	# fill _tmp41 to $r2 from $r15-304
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -312($r15)	# spill _tmp42 from $r3 to $r15-312
	# _tmp43 = 4
	  lda		$r3, 4		# load (signed) int constant value 4 into $r3
	  stq		$r3, -320($r15)	# spill _tmp43 from $r3 to $r15-320
	# *(_tmp42) = _tmp43
	  ldq		$r1, -320($r15)	# fill _tmp43 to $r1 from $r15-320
	  ldq		$r3, -312($r15)	# fill _tmp42 to $r3 from $r15-312
	  stq		$r1, 0($r3)	# store with offset
	# _tmp44 = 4
	  lda		$r3, 4		# load (signed) int constant value 4 into $r3
	  stq		$r3, -328($r15)	# spill _tmp44 from $r3 to $r15-328
	# _tmp45 = _tmp44 < ZERO
	  ldq		$r1, -328($r15)	# fill _tmp44 to $r1 from $r15-328
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -336($r15)	# spill _tmp45 from $r3 to $r15-336
	# _tmp46 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -344($r15)	# spill _tmp46 from $r3 to $r15-344
	# _tmp47 = _tmp46 <= _tmp44
	  ldq		$r1, -344($r15)	# fill _tmp46 to $r1 from $r15-344
	  ldq		$r2, -328($r15)	# fill _tmp44 to $r2 from $r15-328
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -352($r15)	# spill _tmp47 from $r3 to $r15-352
	# _tmp48 = _tmp45 || _tmp47
	  ldq		$r1, -336($r15)	# fill _tmp45 to $r1 from $r15-336
	  ldq		$r2, -352($r15)	# fill _tmp47 to $r2 from $r15-352
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -360($r15)	# spill _tmp48 from $r3 to $r15-360
	# IfZ _tmp48 Goto __L7
	  ldq		$r1, -360($r15)	# fill _tmp48 to $r1 from $r15-360
	  blbc		$r1, __L7	# branch if _tmp48 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L7:
	# _tmp49 = _tmp44 << 3
	  ldq		$r1, -328($r15)	# fill _tmp44 to $r1 from $r15-328
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -368($r15)	# spill _tmp49 from $r3 to $r15-368
	# _tmp50 = results + _tmp49
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -368($r15)	# fill _tmp49 to $r2 from $r15-368
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -376($r15)	# spill _tmp50 from $r3 to $r15-376
	# _tmp51 = 5
	  lda		$r3, 5		# load (signed) int constant value 5 into $r3
	  stq		$r3, -384($r15)	# spill _tmp51 from $r3 to $r15-384
	# *(_tmp50) = _tmp51
	  ldq		$r1, -384($r15)	# fill _tmp51 to $r1 from $r15-384
	  ldq		$r3, -376($r15)	# fill _tmp50 to $r3 from $r15-376
	  stq		$r1, 0($r3)	# store with offset
	# _tmp52 = 5
	  lda		$r3, 5		# load (signed) int constant value 5 into $r3
	  stq		$r3, -392($r15)	# spill _tmp52 from $r3 to $r15-392
	# _tmp53 = _tmp52 < ZERO
	  ldq		$r1, -392($r15)	# fill _tmp52 to $r1 from $r15-392
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -400($r15)	# spill _tmp53 from $r3 to $r15-400
	# _tmp54 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -408($r15)	# spill _tmp54 from $r3 to $r15-408
	# _tmp55 = _tmp54 <= _tmp52
	  ldq		$r1, -408($r15)	# fill _tmp54 to $r1 from $r15-408
	  ldq		$r2, -392($r15)	# fill _tmp52 to $r2 from $r15-392
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -416($r15)	# spill _tmp55 from $r3 to $r15-416
	# _tmp56 = _tmp53 || _tmp55
	  ldq		$r1, -400($r15)	# fill _tmp53 to $r1 from $r15-400
	  ldq		$r2, -416($r15)	# fill _tmp55 to $r2 from $r15-416
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -424($r15)	# spill _tmp56 from $r3 to $r15-424
	# IfZ _tmp56 Goto __L8
	  ldq		$r1, -424($r15)	# fill _tmp56 to $r1 from $r15-424
	  blbc		$r1, __L8	# branch if _tmp56 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L8:
	# _tmp57 = _tmp52 << 3
	  ldq		$r1, -392($r15)	# fill _tmp52 to $r1 from $r15-392
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -432($r15)	# spill _tmp57 from $r3 to $r15-432
	# _tmp58 = results + _tmp57
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -432($r15)	# fill _tmp57 to $r2 from $r15-432
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -440($r15)	# spill _tmp58 from $r3 to $r15-440
	# _tmp59 = 6
	  lda		$r3, 6		# load (signed) int constant value 6 into $r3
	  stq		$r3, -448($r15)	# spill _tmp59 from $r3 to $r15-448
	# *(_tmp58) = _tmp59
	  ldq		$r1, -448($r15)	# fill _tmp59 to $r1 from $r15-448
	  ldq		$r3, -440($r15)	# fill _tmp58 to $r3 from $r15-440
	  stq		$r1, 0($r3)	# store with offset
	# _tmp60 = 6
	  lda		$r3, 6		# load (signed) int constant value 6 into $r3
	  stq		$r3, -456($r15)	# spill _tmp60 from $r3 to $r15-456
	# _tmp61 = _tmp60 < ZERO
	  ldq		$r1, -456($r15)	# fill _tmp60 to $r1 from $r15-456
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -464($r15)	# spill _tmp61 from $r3 to $r15-464
	# _tmp62 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -472($r15)	# spill _tmp62 from $r3 to $r15-472
	# _tmp63 = _tmp62 <= _tmp60
	  ldq		$r1, -472($r15)	# fill _tmp62 to $r1 from $r15-472
	  ldq		$r2, -456($r15)	# fill _tmp60 to $r2 from $r15-456
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -480($r15)	# spill _tmp63 from $r3 to $r15-480
	# _tmp64 = _tmp61 || _tmp63
	  ldq		$r1, -464($r15)	# fill _tmp61 to $r1 from $r15-464
	  ldq		$r2, -480($r15)	# fill _tmp63 to $r2 from $r15-480
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -488($r15)	# spill _tmp64 from $r3 to $r15-488
	# IfZ _tmp64 Goto __L9
	  ldq		$r1, -488($r15)	# fill _tmp64 to $r1 from $r15-488
	  blbc		$r1, __L9	# branch if _tmp64 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L9:
	# _tmp65 = _tmp60 << 3
	  ldq		$r1, -456($r15)	# fill _tmp60 to $r1 from $r15-456
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -496($r15)	# spill _tmp65 from $r3 to $r15-496
	# _tmp66 = results + _tmp65
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -496($r15)	# fill _tmp65 to $r2 from $r15-496
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -504($r15)	# spill _tmp66 from $r3 to $r15-504
	# _tmp67 = 7
	  lda		$r3, 7		# load (signed) int constant value 7 into $r3
	  stq		$r3, -512($r15)	# spill _tmp67 from $r3 to $r15-512
	# *(_tmp66) = _tmp67
	  ldq		$r1, -512($r15)	# fill _tmp67 to $r1 from $r15-512
	  ldq		$r3, -504($r15)	# fill _tmp66 to $r3 from $r15-504
	  stq		$r1, 0($r3)	# store with offset
	# _tmp68 = 7
	  lda		$r3, 7		# load (signed) int constant value 7 into $r3
	  stq		$r3, -520($r15)	# spill _tmp68 from $r3 to $r15-520
	# _tmp69 = _tmp68 < ZERO
	  ldq		$r1, -520($r15)	# fill _tmp68 to $r1 from $r15-520
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -528($r15)	# spill _tmp69 from $r3 to $r15-528
	# _tmp70 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -536($r15)	# spill _tmp70 from $r3 to $r15-536
	# _tmp71 = _tmp70 <= _tmp68
	  ldq		$r1, -536($r15)	# fill _tmp70 to $r1 from $r15-536
	  ldq		$r2, -520($r15)	# fill _tmp68 to $r2 from $r15-520
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -544($r15)	# spill _tmp71 from $r3 to $r15-544
	# _tmp72 = _tmp69 || _tmp71
	  ldq		$r1, -528($r15)	# fill _tmp69 to $r1 from $r15-528
	  ldq		$r2, -544($r15)	# fill _tmp71 to $r2 from $r15-544
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -552($r15)	# spill _tmp72 from $r3 to $r15-552
	# IfZ _tmp72 Goto __L10
	  ldq		$r1, -552($r15)	# fill _tmp72 to $r1 from $r15-552
	  blbc		$r1, __L10	# branch if _tmp72 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L10:
	# _tmp73 = _tmp68 << 3
	  ldq		$r1, -520($r15)	# fill _tmp68 to $r1 from $r15-520
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -560($r15)	# spill _tmp73 from $r3 to $r15-560
	# _tmp74 = results + _tmp73
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -560($r15)	# fill _tmp73 to $r2 from $r15-560
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -568($r15)	# spill _tmp74 from $r3 to $r15-568
	# _tmp75 = 8
	  lda		$r3, 8		# load (signed) int constant value 8 into $r3
	  stq		$r3, -576($r15)	# spill _tmp75 from $r3 to $r15-576
	# *(_tmp74) = _tmp75
	  ldq		$r1, -576($r15)	# fill _tmp75 to $r1 from $r15-576
	  ldq		$r3, -568($r15)	# fill _tmp74 to $r3 from $r15-568
	  stq		$r1, 0($r3)	# store with offset
	# _tmp76 = 8
	  lda		$r3, 8		# load (signed) int constant value 8 into $r3
	  stq		$r3, -584($r15)	# spill _tmp76 from $r3 to $r15-584
	# _tmp77 = _tmp76 < ZERO
	  ldq		$r1, -584($r15)	# fill _tmp76 to $r1 from $r15-584
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -592($r15)	# spill _tmp77 from $r3 to $r15-592
	# _tmp78 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -600($r15)	# spill _tmp78 from $r3 to $r15-600
	# _tmp79 = _tmp78 <= _tmp76
	  ldq		$r1, -600($r15)	# fill _tmp78 to $r1 from $r15-600
	  ldq		$r2, -584($r15)	# fill _tmp76 to $r2 from $r15-584
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -608($r15)	# spill _tmp79 from $r3 to $r15-608
	# _tmp80 = _tmp77 || _tmp79
	  ldq		$r1, -592($r15)	# fill _tmp77 to $r1 from $r15-592
	  ldq		$r2, -608($r15)	# fill _tmp79 to $r2 from $r15-608
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -616($r15)	# spill _tmp80 from $r3 to $r15-616
	# IfZ _tmp80 Goto __L11
	  ldq		$r1, -616($r15)	# fill _tmp80 to $r1 from $r15-616
	  blbc		$r1, __L11	# branch if _tmp80 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L11:
	# _tmp81 = _tmp76 << 3
	  ldq		$r1, -584($r15)	# fill _tmp76 to $r1 from $r15-584
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -624($r15)	# spill _tmp81 from $r3 to $r15-624
	# _tmp82 = results + _tmp81
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -624($r15)	# fill _tmp81 to $r2 from $r15-624
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -632($r15)	# spill _tmp82 from $r3 to $r15-632
	# _tmp83 = 9
	  lda		$r3, 9		# load (signed) int constant value 9 into $r3
	  stq		$r3, -640($r15)	# spill _tmp83 from $r3 to $r15-640
	# *(_tmp82) = _tmp83
	  ldq		$r1, -640($r15)	# fill _tmp83 to $r1 from $r15-640
	  ldq		$r3, -632($r15)	# fill _tmp82 to $r3 from $r15-632
	  stq		$r1, 0($r3)	# store with offset
	# _tmp84 = 9
	  lda		$r3, 9		# load (signed) int constant value 9 into $r3
	  stq		$r3, -648($r15)	# spill _tmp84 from $r3 to $r15-648
	# _tmp85 = _tmp84 < ZERO
	  ldq		$r1, -648($r15)	# fill _tmp84 to $r1 from $r15-648
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -656($r15)	# spill _tmp85 from $r3 to $r15-656
	# _tmp86 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -664($r15)	# spill _tmp86 from $r3 to $r15-664
	# _tmp87 = _tmp86 <= _tmp84
	  ldq		$r1, -664($r15)	# fill _tmp86 to $r1 from $r15-664
	  ldq		$r2, -648($r15)	# fill _tmp84 to $r2 from $r15-648
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -672($r15)	# spill _tmp87 from $r3 to $r15-672
	# _tmp88 = _tmp85 || _tmp87
	  ldq		$r1, -656($r15)	# fill _tmp85 to $r1 from $r15-656
	  ldq		$r2, -672($r15)	# fill _tmp87 to $r2 from $r15-672
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -680($r15)	# spill _tmp88 from $r3 to $r15-680
	# IfZ _tmp88 Goto __L12
	  ldq		$r1, -680($r15)	# fill _tmp88 to $r1 from $r15-680
	  blbc		$r1, __L12	# branch if _tmp88 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L12:
	# _tmp89 = _tmp84 << 3
	  ldq		$r1, -648($r15)	# fill _tmp84 to $r1 from $r15-648
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -688($r15)	# spill _tmp89 from $r3 to $r15-688
	# _tmp90 = results + _tmp89
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -688($r15)	# fill _tmp89 to $r2 from $r15-688
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -696($r15)	# spill _tmp90 from $r3 to $r15-696
	# _tmp91 = 10
	  lda		$r3, 10		# load (signed) int constant value 10 into $r3
	  stq		$r3, -704($r15)	# spill _tmp91 from $r3 to $r15-704
	# *(_tmp90) = _tmp91
	  ldq		$r1, -704($r15)	# fill _tmp91 to $r1 from $r15-704
	  ldq		$r3, -696($r15)	# fill _tmp90 to $r3 from $r15-696
	  stq		$r1, 0($r3)	# store with offset
	# _tmp92 = 10
	  lda		$r3, 10		# load (signed) int constant value 10 into $r3
	  stq		$r3, -712($r15)	# spill _tmp92 from $r3 to $r15-712
	# _tmp93 = _tmp92 < ZERO
	  ldq		$r1, -712($r15)	# fill _tmp92 to $r1 from $r15-712
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -720($r15)	# spill _tmp93 from $r3 to $r15-720
	# _tmp94 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -728($r15)	# spill _tmp94 from $r3 to $r15-728
	# _tmp95 = _tmp94 <= _tmp92
	  ldq		$r1, -728($r15)	# fill _tmp94 to $r1 from $r15-728
	  ldq		$r2, -712($r15)	# fill _tmp92 to $r2 from $r15-712
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -736($r15)	# spill _tmp95 from $r3 to $r15-736
	# _tmp96 = _tmp93 || _tmp95
	  ldq		$r1, -720($r15)	# fill _tmp93 to $r1 from $r15-720
	  ldq		$r2, -736($r15)	# fill _tmp95 to $r2 from $r15-736
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -744($r15)	# spill _tmp96 from $r3 to $r15-744
	# IfZ _tmp96 Goto __L13
	  ldq		$r1, -744($r15)	# fill _tmp96 to $r1 from $r15-744
	  blbc		$r1, __L13	# branch if _tmp96 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L13:
	# _tmp97 = _tmp92 << 3
	  ldq		$r1, -712($r15)	# fill _tmp92 to $r1 from $r15-712
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -752($r15)	# spill _tmp97 from $r3 to $r15-752
	# _tmp98 = results + _tmp97
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -752($r15)	# fill _tmp97 to $r2 from $r15-752
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -760($r15)	# spill _tmp98 from $r3 to $r15-760
	# _tmp99 = 11
	  lda		$r3, 11		# load (signed) int constant value 11 into $r3
	  stq		$r3, -768($r15)	# spill _tmp99 from $r3 to $r15-768
	# *(_tmp98) = _tmp99
	  ldq		$r1, -768($r15)	# fill _tmp99 to $r1 from $r15-768
	  ldq		$r3, -760($r15)	# fill _tmp98 to $r3 from $r15-760
	  stq		$r1, 0($r3)	# store with offset
	# _tmp100 = 11
	  lda		$r3, 11		# load (signed) int constant value 11 into $r3
	  stq		$r3, -776($r15)	# spill _tmp100 from $r3 to $r15-776
	# _tmp101 = _tmp100 < ZERO
	  ldq		$r1, -776($r15)	# fill _tmp100 to $r1 from $r15-776
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -784($r15)	# spill _tmp101 from $r3 to $r15-784
	# _tmp102 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -792($r15)	# spill _tmp102 from $r3 to $r15-792
	# _tmp103 = _tmp102 <= _tmp100
	  ldq		$r1, -792($r15)	# fill _tmp102 to $r1 from $r15-792
	  ldq		$r2, -776($r15)	# fill _tmp100 to $r2 from $r15-776
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -800($r15)	# spill _tmp103 from $r3 to $r15-800
	# _tmp104 = _tmp101 || _tmp103
	  ldq		$r1, -784($r15)	# fill _tmp101 to $r1 from $r15-784
	  ldq		$r2, -800($r15)	# fill _tmp103 to $r2 from $r15-800
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -808($r15)	# spill _tmp104 from $r3 to $r15-808
	# IfZ _tmp104 Goto __L14
	  ldq		$r1, -808($r15)	# fill _tmp104 to $r1 from $r15-808
	  blbc		$r1, __L14	# branch if _tmp104 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L14:
	# _tmp105 = _tmp100 << 3
	  ldq		$r1, -776($r15)	# fill _tmp100 to $r1 from $r15-776
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -816($r15)	# spill _tmp105 from $r3 to $r15-816
	# _tmp106 = results + _tmp105
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -816($r15)	# fill _tmp105 to $r2 from $r15-816
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -824($r15)	# spill _tmp106 from $r3 to $r15-824
	# _tmp107 = 12
	  lda		$r3, 12		# load (signed) int constant value 12 into $r3
	  stq		$r3, -832($r15)	# spill _tmp107 from $r3 to $r15-832
	# *(_tmp106) = _tmp107
	  ldq		$r1, -832($r15)	# fill _tmp107 to $r1 from $r15-832
	  ldq		$r3, -824($r15)	# fill _tmp106 to $r3 from $r15-824
	  stq		$r1, 0($r3)	# store with offset
	# _tmp108 = 12
	  lda		$r3, 12		# load (signed) int constant value 12 into $r3
	  stq		$r3, -840($r15)	# spill _tmp108 from $r3 to $r15-840
	# _tmp109 = _tmp108 < ZERO
	  ldq		$r1, -840($r15)	# fill _tmp108 to $r1 from $r15-840
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -848($r15)	# spill _tmp109 from $r3 to $r15-848
	# _tmp110 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -856($r15)	# spill _tmp110 from $r3 to $r15-856
	# _tmp111 = _tmp110 <= _tmp108
	  ldq		$r1, -856($r15)	# fill _tmp110 to $r1 from $r15-856
	  ldq		$r2, -840($r15)	# fill _tmp108 to $r2 from $r15-840
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -864($r15)	# spill _tmp111 from $r3 to $r15-864
	# _tmp112 = _tmp109 || _tmp111
	  ldq		$r1, -848($r15)	# fill _tmp109 to $r1 from $r15-848
	  ldq		$r2, -864($r15)	# fill _tmp111 to $r2 from $r15-864
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -872($r15)	# spill _tmp112 from $r3 to $r15-872
	# IfZ _tmp112 Goto __L15
	  ldq		$r1, -872($r15)	# fill _tmp112 to $r1 from $r15-872
	  blbc		$r1, __L15	# branch if _tmp112 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L15:
	# _tmp113 = _tmp108 << 3
	  ldq		$r1, -840($r15)	# fill _tmp108 to $r1 from $r15-840
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -880($r15)	# spill _tmp113 from $r3 to $r15-880
	# _tmp114 = results + _tmp113
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -880($r15)	# fill _tmp113 to $r2 from $r15-880
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -888($r15)	# spill _tmp114 from $r3 to $r15-888
	# _tmp115 = 13
	  lda		$r3, 13		# load (signed) int constant value 13 into $r3
	  stq		$r3, -896($r15)	# spill _tmp115 from $r3 to $r15-896
	# *(_tmp114) = _tmp115
	  ldq		$r1, -896($r15)	# fill _tmp115 to $r1 from $r15-896
	  ldq		$r3, -888($r15)	# fill _tmp114 to $r3 from $r15-888
	  stq		$r1, 0($r3)	# store with offset
	# _tmp116 = 13
	  lda		$r3, 13		# load (signed) int constant value 13 into $r3
	  stq		$r3, -904($r15)	# spill _tmp116 from $r3 to $r15-904
	# _tmp117 = _tmp116 < ZERO
	  ldq		$r1, -904($r15)	# fill _tmp116 to $r1 from $r15-904
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -912($r15)	# spill _tmp117 from $r3 to $r15-912
	# _tmp118 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -920($r15)	# spill _tmp118 from $r3 to $r15-920
	# _tmp119 = _tmp118 <= _tmp116
	  ldq		$r1, -920($r15)	# fill _tmp118 to $r1 from $r15-920
	  ldq		$r2, -904($r15)	# fill _tmp116 to $r2 from $r15-904
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -928($r15)	# spill _tmp119 from $r3 to $r15-928
	# _tmp120 = _tmp117 || _tmp119
	  ldq		$r1, -912($r15)	# fill _tmp117 to $r1 from $r15-912
	  ldq		$r2, -928($r15)	# fill _tmp119 to $r2 from $r15-928
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -936($r15)	# spill _tmp120 from $r3 to $r15-936
	# IfZ _tmp120 Goto __L16
	  ldq		$r1, -936($r15)	# fill _tmp120 to $r1 from $r15-936
	  blbc		$r1, __L16	# branch if _tmp120 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L16:
	# _tmp121 = _tmp116 << 3
	  ldq		$r1, -904($r15)	# fill _tmp116 to $r1 from $r15-904
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -944($r15)	# spill _tmp121 from $r3 to $r15-944
	# _tmp122 = results + _tmp121
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -944($r15)	# fill _tmp121 to $r2 from $r15-944
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -952($r15)	# spill _tmp122 from $r3 to $r15-952
	# _tmp123 = 14
	  lda		$r3, 14		# load (signed) int constant value 14 into $r3
	  stq		$r3, -960($r15)	# spill _tmp123 from $r3 to $r15-960
	# *(_tmp122) = _tmp123
	  ldq		$r1, -960($r15)	# fill _tmp123 to $r1 from $r15-960
	  ldq		$r3, -952($r15)	# fill _tmp122 to $r3 from $r15-952
	  stq		$r1, 0($r3)	# store with offset
	# _tmp124 = 14
	  lda		$r3, 14		# load (signed) int constant value 14 into $r3
	  stq		$r3, -968($r15)	# spill _tmp124 from $r3 to $r15-968
	# _tmp125 = _tmp124 < ZERO
	  ldq		$r1, -968($r15)	# fill _tmp124 to $r1 from $r15-968
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -976($r15)	# spill _tmp125 from $r3 to $r15-976
	# _tmp126 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -984($r15)	# spill _tmp126 from $r3 to $r15-984
	# _tmp127 = _tmp126 <= _tmp124
	  ldq		$r1, -984($r15)	# fill _tmp126 to $r1 from $r15-984
	  ldq		$r2, -968($r15)	# fill _tmp124 to $r2 from $r15-968
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -992($r15)	# spill _tmp127 from $r3 to $r15-992
	# _tmp128 = _tmp125 || _tmp127
	  ldq		$r1, -976($r15)	# fill _tmp125 to $r1 from $r15-976
	  ldq		$r2, -992($r15)	# fill _tmp127 to $r2 from $r15-992
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1000($r15)	# spill _tmp128 from $r3 to $r15-1000
	# IfZ _tmp128 Goto __L17
	  ldq		$r1, -1000($r15)	# fill _tmp128 to $r1 from $r15-1000
	  blbc		$r1, __L17	# branch if _tmp128 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L17:
	# _tmp129 = _tmp124 << 3
	  ldq		$r1, -968($r15)	# fill _tmp124 to $r1 from $r15-968
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -1008($r15)	# spill _tmp129 from $r3 to $r15-1008
	# _tmp130 = results + _tmp129
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -1008($r15)	# fill _tmp129 to $r2 from $r15-1008
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1016($r15)	# spill _tmp130 from $r3 to $r15-1016
	# _tmp131 = 15
	  lda		$r3, 15		# load (signed) int constant value 15 into $r3
	  stq		$r3, -1024($r15)	# spill _tmp131 from $r3 to $r15-1024
	# *(_tmp130) = _tmp131
	  ldq		$r1, -1024($r15)	# fill _tmp131 to $r1 from $r15-1024
	  ldq		$r3, -1016($r15)	# fill _tmp130 to $r3 from $r15-1016
	  stq		$r1, 0($r3)	# store with offset
	# _tmp132 = 15
	  lda		$r3, 15		# load (signed) int constant value 15 into $r3
	  stq		$r3, -1032($r15)	# spill _tmp132 from $r3 to $r15-1032
	# _tmp133 = _tmp132 < ZERO
	  ldq		$r1, -1032($r15)	# fill _tmp132 to $r1 from $r15-1032
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -1040($r15)	# spill _tmp133 from $r3 to $r15-1040
	# _tmp134 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -1048($r15)	# spill _tmp134 from $r3 to $r15-1048
	# _tmp135 = _tmp134 <= _tmp132
	  ldq		$r1, -1048($r15)	# fill _tmp134 to $r1 from $r15-1048
	  ldq		$r2, -1032($r15)	# fill _tmp132 to $r2 from $r15-1032
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1056($r15)	# spill _tmp135 from $r3 to $r15-1056
	# _tmp136 = _tmp133 || _tmp135
	  ldq		$r1, -1040($r15)	# fill _tmp133 to $r1 from $r15-1040
	  ldq		$r2, -1056($r15)	# fill _tmp135 to $r2 from $r15-1056
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1064($r15)	# spill _tmp136 from $r3 to $r15-1064
	# IfZ _tmp136 Goto __L18
	  ldq		$r1, -1064($r15)	# fill _tmp136 to $r1 from $r15-1064
	  blbc		$r1, __L18	# branch if _tmp136 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L18:
	# _tmp137 = _tmp132 << 3
	  ldq		$r1, -1032($r15)	# fill _tmp132 to $r1 from $r15-1032
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -1072($r15)	# spill _tmp137 from $r3 to $r15-1072
	# _tmp138 = results + _tmp137
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -1072($r15)	# fill _tmp137 to $r2 from $r15-1072
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1080($r15)	# spill _tmp138 from $r3 to $r15-1080
	# _tmp139 = 16
	  lda		$r3, 16		# load (signed) int constant value 16 into $r3
	  stq		$r3, -1088($r15)	# spill _tmp139 from $r3 to $r15-1088
	# *(_tmp138) = _tmp139
	  ldq		$r1, -1088($r15)	# fill _tmp139 to $r1 from $r15-1088
	  ldq		$r3, -1080($r15)	# fill _tmp138 to $r3 from $r15-1080
	  stq		$r1, 0($r3)	# store with offset
	# _tmp140 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -1096($r15)	# spill _tmp140 from $r3 to $r15-1096
	# i = _tmp140
	  ldq		$r3, -1096($r15)	# fill _tmp140 to $r3 from $r15-1096
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
__L19:
	# _tmp141 = 16
	  lda		$r3, 16		# load (signed) int constant value 16 into $r3
	  stq		$r3, -1104($r15)	# spill _tmp141 from $r3 to $r15-1104
	# _tmp142 = i < _tmp141
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -1104($r15)	# fill _tmp141 to $r2 from $r15-1104
	  cmplt		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1112($r15)	# spill _tmp142 from $r3 to $r15-1112
	# IfZ _tmp142 Goto __L20
	  ldq		$r1, -1112($r15)	# fill _tmp142 to $r1 from $r15-1112
	  blbc		$r1, __L20	# branch if _tmp142 is zero
	# _tmp143 = i < ZERO
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -1120($r15)	# spill _tmp143 from $r3 to $r15-1120
	# _tmp144 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -1128($r15)	# spill _tmp144 from $r3 to $r15-1128
	# _tmp145 = _tmp144 <= i
	  ldq		$r1, -1128($r15)	# fill _tmp144 to $r1 from $r15-1128
	  ldq		$r2, -16($r15)	# fill i to $r2 from $r15-16
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1136($r15)	# spill _tmp145 from $r3 to $r15-1136
	# _tmp146 = _tmp143 || _tmp145
	  ldq		$r1, -1120($r15)	# fill _tmp143 to $r1 from $r15-1120
	  ldq		$r2, -1136($r15)	# fill _tmp145 to $r2 from $r15-1136
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1144($r15)	# spill _tmp146 from $r3 to $r15-1144
	# IfZ _tmp146 Goto __L21
	  ldq		$r1, -1144($r15)	# fill _tmp146 to $r1 from $r15-1144
	  blbc		$r1, __L21	# branch if _tmp146 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L21:
	# _tmp147 = i << 3
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -1152($r15)	# spill _tmp147 from $r3 to $r15-1152
	# _tmp148 = results + _tmp147
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -1152($r15)	# fill _tmp147 to $r2 from $r15-1152
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1160($r15)	# spill _tmp148 from $r3 to $r15-1160
	# _tmp149 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -1168($r15)	# spill _tmp149 from $r3 to $r15-1168
	# _tmp150 = i - _tmp149
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -1168($r15)	# fill _tmp149 to $r2 from $r15-1168
	  subq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1176($r15)	# spill _tmp150 from $r3 to $r15-1176
	# _tmp151 = _tmp150 < ZERO
	  ldq		$r1, -1176($r15)	# fill _tmp150 to $r1 from $r15-1176
	  cmplt		$r1, $r31, $r3	# perform the ALU op
	  stq		$r3, -1184($r15)	# spill _tmp151 from $r3 to $r15-1184
	# _tmp152 = *(results + -8)
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r3, -8($r1)	# load with offset
	  stq		$r3, -1192($r15)	# spill _tmp152 from $r3 to $r15-1192
	# _tmp153 = _tmp152 <= _tmp150
	  ldq		$r1, -1192($r15)	# fill _tmp152 to $r1 from $r15-1192
	  ldq		$r2, -1176($r15)	# fill _tmp150 to $r2 from $r15-1176
	  cmple		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1200($r15)	# spill _tmp153 from $r3 to $r15-1200
	# _tmp154 = _tmp151 || _tmp153
	  ldq		$r1, -1184($r15)	# fill _tmp151 to $r1 from $r15-1184
	  ldq		$r2, -1200($r15)	# fill _tmp153 to $r2 from $r15-1200
	  bis		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1208($r15)	# spill _tmp154 from $r3 to $r15-1208
	# IfZ _tmp154 Goto __L22
	  ldq		$r1, -1208($r15)	# fill _tmp154 to $r1 from $r15-1208
	  blbc		$r1, __L22	# branch if _tmp154 is zero
	# Throw Exception: Array subscript out of bounds
	  call_pal	0xDECAF		# (exception: Array subscript out of bounds)
	  call_pal	0x555		# (halt)
__L22:
	# _tmp155 = _tmp150 << 3
	  ldq		$r1, -1176($r15)	# fill _tmp150 to $r1 from $r15-1176
	  sll		$r1, 3, $r3	# perform the ALU op
	  stq		$r3, -1216($r15)	# spill _tmp155 from $r3 to $r15-1216
	# _tmp156 = results + _tmp155
	  ldq		$r1, 0($r29)	# fill results to $r1 from $r29+0
	  ldq		$r2, -1216($r15)	# fill _tmp155 to $r2 from $r15-1216
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1224($r15)	# spill _tmp156 from $r3 to $r15-1224
	# _tmp157 = *(_tmp156)
	  ldq		$r1, -1224($r15)	# fill _tmp156 to $r1 from $r15-1224
	  ldq		$r3, 0($r1)	# load with offset
	  stq		$r3, -1232($r15)	# spill _tmp157 from $r3 to $r15-1232
	# PushParam i
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  stq		$r1, 8($r30)	# copy param value to stack
	# PushParam _tmp157
	  subq		$r30, 8, $r30	# decrement stack ptr to make space for param
	  ldq		$r1, -1232($r15)	# fill _tmp157 to $r1 from $r15-1232
	  stq		$r1, 8($r30)	# copy param value to stack
	# _tmp158 = LCall _Power
	  bsr		$r26, _Power	# branch to function
	  mov		$r0, $r3	# copy function return value from $v0
	  stq		$r3, -1240($r15)	# spill _tmp158 from $r3 to $r15-1240
	# PopParams 16
	  addq		$r30, 16, $r30	# pop params off stack
	# *(_tmp148) = _tmp158
	  ldq		$r1, -1240($r15)	# fill _tmp158 to $r1 from $r15-1240
	  ldq		$r3, -1160($r15)	# fill _tmp148 to $r3 from $r15-1160
	  stq		$r1, 0($r3)	# store with offset
	# _tmp159 = 1
	  lda		$r3, 1		# load (signed) int constant value 1 into $r3
	  stq		$r3, -1248($r15)	# spill _tmp159 from $r3 to $r15-1248
	# _tmp160 = i + _tmp159
	  ldq		$r1, -16($r15)	# fill i to $r1 from $r15-16
	  ldq		$r2, -1248($r15)	# fill _tmp159 to $r2 from $r15-1248
	  addq		$r1, $r2, $r3	# perform the ALU op
	  stq		$r3, -1256($r15)	# spill _tmp160 from $r3 to $r15-1256
	# i = _tmp160
	  ldq		$r3, -1256($r15)	# fill _tmp160 to $r3 from $r15-1256
	  stq		$r3, -16($r15)	# spill i from $r3 to $r15-16
	# Goto __L19
	  br		__L19		# unconditional branch
__L20:
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

