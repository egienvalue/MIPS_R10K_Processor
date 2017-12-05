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
_QueueItem.Init:
	# BeginFunc 0
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	# *(this + 8) = data
	  ldq		$r1, 16($r15)	# fill data to $r1 from $r15+16
	  ldq		$r3, 8($r15)	# fill this to $r3 from $r15+8
	  stq		$r1, 8($r3)	# store with offset
	# *(this + 16) = next
	  ldq		$r1, 24($r15)	# fill next to $r1 from $r15+24
	  ldq		$r3, 8($r15)	# fill this to $r3 from $r15+8
	  stq		$r1, 16($r3)	# store with offset
	# *(next + 24) = this
	  ldq		$r1, 8($r15)	# fill this to $r1 from $r15+8
	  ldq		$r3, 24($r15)	# fill next to $r3 from $r15+24
	  stq		$r1, 24($r3)	# store with offset
	# *(this + 24) = prev
	  ldq		$r1, 32($r15)	# fill prev to $r1 from $r15+32
	  ldq		$r3, 8($r15)	# fill this to $r3 from $r15+8
	  stq		$r1, 24($r3)	# store with offset
	# *(prev + 16) = this
	  ldq		$r1, 8($r15)	# fill this to $r1 from $r15+8
	  ldq		$r3, 32($r15)	# fill prev to $r3 from $r15+32
	  stq		$r1, 16($r3)	# store with offset
	# EndFunc
	# (below handles reaching end of fn body with no explicit return)
	  mov		$r15, $r30	# pop callee frame off stack
	  ldq		$r26, -8($r15)	# restore saved ra
	  ldq		$r15, 0($r15)	# restore saved fp
	  ret				# return from function
_QueueItem.GetData:
	# BeginFunc 8
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
	  subq		$r30, 8, $r30	# decrement sp to make space for locals/temps
	# _tmp0 = *(this + 8)
	  ldq		$r1, 8($r15)	# fill this to $r1 from $r15+8
	  ldq		$r3, 8($r1)	# load with offset
	  stq		$r3, -16($r15)	# spill _tmp0 from $r3 to $r15-16
	# Return _tmp0
	  ldq		$r3, -16($r15)	# fill _tmp0 to $r3 from $r15-16
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
	# VTable for class QueueItem
	  .data
	  .align 3
	  QueueItem:		# label for class QueueItem vtable
	  .quad _QueueItem.Init
	  .quad _QueueItem.GetData
	  .text
main:
	# BeginFunc 0
	  subq		$r30, 16, $r30	# decrement sp to make space to save ra, fp
	  stq		$r15, 16($r30)	# save fp
	  stq		$r26, 8($r30)	# save ra
	  addq		$r30, 16, $r15	# set up new fp
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
