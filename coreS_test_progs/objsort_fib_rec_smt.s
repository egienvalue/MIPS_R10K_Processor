/*
	 Made by Aaron Mueller | Group 3 | EECS 470 University of Michigan

	 	Warning! This test case might not be right. I tried my best to stitch these
		two programs together without them conflicting in memory but objsort is crazy
		so who knows. I have made writeback.outs for each thread and a program.out. I'm quite
		sure the writeback.outs are 99% correct and the program.out might be a little off. 

		Bottom line don't take this test case as fact until it is confirmed to be right by multiple
		people/processors
	
	 	Objsort = thread0
		Fib_rec = thread1
*/

	data = 0x5000		/* used in fib_rec */
	stack = 0x6000	/* used in fib_rec */

/* Objsort */
				fbne  $f31, fork        #CHANGE THIS LINE TO YOUR FORK INSTR !!!!!!!!!!!!!!!!!!       #0x000
				bsr		$r26, itab 																																		 	#0x004
				mov		$r0, $r20					# r20 has tag of class i  																	 	#0x008
				stq		$r1, 0($r0)				# return 1 if r2>r1.value, 0 otherwise (including no value) 	#0x00c
				stq		$r2, 8($r0)				# return 1 if has a value																			#0x010
				stq   $r3, 16($r0)			# r1=r1.next																						 			#0x014
				stq   $r4, 24($r0)			# r0=r1.value 																								#0x018
				stq		$r5, 32($r0)			# link r1.next=r2 																						#0x01c
			 	bsr   $r26, htab 																																 			#0x020
				mov		$r0, $r21					# r21 has tag of class h 																			#0x024
				stq   $r1, 0($r0) 																															 			#0x028
				stq   $r1, 8($r0) 																															 			#0x02c
				lda		$r22, 2048				# r22 has address of "heap" 																	#0x030
				bsr		$r26, makeh 																																	 	#0x034
				mov		$r0, $r14					# r14 holds current head of linked list 											#0x038
				lda		$r15, 1024				# r15 holds current address in original list 									#0x03c
				ldq		$r2, 0($r15) 																																	 	#0x040
				blt		$r2, print 																																		 	#0x044
oloop:	addq	$r15, 8, $r15 																												 					#0x048
				ldq   $r6, 0($r14) 																															 			#0x04c
				ldq		$r5, 0($r6) 																																	 	#0x050
				mov		$r14, $r1 																																		 	#0x054
				jsr   $r26, ($r5)				# call to greaterthan function 																#0x058
				bne		$r0, sloop 																																		 	#0x05c
				bsr   $r26, makei 																															 			#0x060
				mov   $r0, $r14 																																 			#0x064
				ldq   $r2, 0($r15)																															 			#0x068
				bge   $r2, oloop 																													 						#0x06c
				br		print 																																				 	#0x070
sloop:	mov		$r1, $r16					# r16 holds object to link to this one 												#0x074
				ldq   $r5, 16($r6) 																															 			#0x078
				jsr   $r26, ($r5)				# call to next function 																			#0x07c
				ldq		$r6, 0($r1) 																																	 	#0x080
				ldq		$r5, 0($r6)																																		 	#0x084
				jsr		$r26, ($r5)				# call to greaterthan function 																#0x088
				bne		$r0, sloop 																																		 	#0x08c
				bsr		$r26, makei 																																	 	#0x090
				mov		$r0, $r2 																																			 	#0x094
				mov   $r16, $r1 																																 			#0x098
				ldq   $r6, 0($r1) 																															 			#0x09c
			  ldq   $r5, 32($r6) 																												 						#0x0a0
				jsr   $r26, ($r5)    		# call to link function 																			#0x0a4
				ldq   $r2, 0($r15) 																															 			#0x0a8
				bge		$r2, oloop 																																		 	#0x0ac
print:	mov		$r14, $r1 																															 				#0x0b0
				lda		$r15, 4096 																																		 	#0x0b4
prloop:	ldq   $r6, 0($r1) 																												 						#0x0b8
        ldq   $r5, 8($r6) 																												 						#0x0bc
				jsr   $r26, ($r5)     	# call to cont function 																			#0x0c0
				beq		$r0, stop																																			 	#0x0c4
				ldq   $r5, 24($r6) 																															 			#0x0c8
				jsr   $r26, ($r5)				# call to value function 																			#0x0cc
				stq		$r0, 0($r15) 																																	 	#0x0d0
				ldq   $r5, 16($r6) 																															 			#0x0d4
				jsr   $r26, ($r5)     	# call to next function 																			#0x0d8
				addq	$r15, 8, $r15 																															 		#0x0dc
				br		prloop 																																				 	#0x0e0
stop:		call_pal 0x555 																																 				#0x0e4
makeh:	mov		$r22, $r0 																															 				#0x0e8
				stq		$r21, 0($r22) 																																 	#0x0ec
				addq	$r22, 8, $r22 																															 		#0x0f0
				ret 																																							 		#0x0f4
makei:	mov		$r22, $r0 																															 				#0x0f8
				stq		$r20, 0($r22) 																																 	#0x0fc
				stq		$r1, 16($r22) 																																 	#0x100
				stq		$r2, 8($r22) 																																	 	#0x104
				addq	$r22, 24, $r22 																															 		#0x108
				ret 																																							 		#0x10c
igth:		ret		$r1																																				 			#0x110
				lda		$r0, 0																																				 	#0x114
				ret																																								 		#0x118
conti:	br		$r2, nexti																															 				#0x11c
				addq	$r31, 1, $r0																																 		#0x120
				ret																																								 		#0x124
inti:		br		$r4, linki																																 			#0x128
				ldq		$r0, 8($r1)																																		 	#0x12c
				ret																																								 		#0x130
nexti:	br		$r3, inti																																 				#0x134
				ldq		$r1, 16($r1)																																	 	#0x138
				ret																																								 		#0x13c
linki:	br    $r5, igti																														 						#0x140
				stq		$r2, 16($r1)																																	 	#0x144
				ret																																								 		#0x148
igti:		ret		$r1																																				 			#0x14c
				ldq		$r3,8($r1)																																		 	#0x150
				cmplt	$r3,$r2,$r0																																	 		#0x154
				ret																															                      #0x158									 		
	.align 3	                      #NOTE: Some of the PC's below this line are probably wrong
				lda		$r0, 0						# filler 																											#0x15c
htab:		br 		$r0, igth																																	 			#0x160
	.quad	0																																											#0x164 #0x168
	.quad	0																																											#0x16c #0x170
      	lda   $r0, 0          	# filler																											#0x174
itab:   br		$r0, conti																																			#0x178
  			.quad   0																																							#0x17c #0x180
	.quad	0
	.quad 	0


	.align 10
	.quad	  2,   8,  23,   1,  17,   6,   7,  25
        .quad	 26,  29,   6,  30,  23,  39,   3,   3 
	.quad	 10,  11,  36,  40,  63,  34,  36, 187
        .quad	  5,  96,  0,  34,  58,  86,  99,  65                                       		#0x420ish ( ͡° ͜ʖ ͡°)
	.quad	 36,  74,  34,  88,  63,  48,  59,   5
	.quad	 83,  91, 202, 143, 126, 175, 153,   0
	.quad	137, 159, 137,   9,  17,  30,  20,  19
        .quad    44,  12,  78, 148, 284, 163, 149, 145	
	.quad	-1
                                   #NOTE: All of the PC's below this line should be correct

/* fib_rec */
fork:		lda		$r30,stack				# initialize stack pointer 																		#0x608
				lda		$r16,14						# call fib(14)                                                #0x60c   
				bsr		$r26,fib  				#                                                             #0x610
				lda		$r1,data  				#                                                             #0x614
				stq		$r0,0($r1)				# save to mem                                                 #0x618
				call_pal 0x555 					#                                                             #0x61c
fib:		beq		$r16,fib_ret_1		# arg is 0: return 1                                          #0x620       
				cmpeq	$r16,1,$r1				# arg is 1: return 1                                          #0x624
				bne		$r1,fib_ret_1 		#                                                             #0x628
				subq	$r30,32,$r30			# allocate stack frame                                        #0x62c
				stq		$r26,24($r30)			# save off return address                                     #0x630
				stq		$r16,0($r30)			# save off arg                                                #0x634
				subq	$r16,1,$r16				# arg = arg-1                                                 #0x638
				bsr		$r26,fib					# call fib                                                    #0x63c
				stq		$r0,8($r30)				# save return value (fib(arg-1))                              #0x640
				ldq		$r16,0($r30)			# restore arg                                                 #0x644
				subq	$r16,2,$r16				# arg = arg-2                                                 #0x648
				bsr		$r26,fib					# call fib                                                    #0x64c
				ldq		$r1,8($r30)				# restore fib(arg-1)                                          #0x650
				addq	$r1,$r0,$r0				# fib(arg-1)+fib(arg-2)                                       #0x654
				ldq		$r26,24($r30)			# restore return address                                      #0x658
				addq	$r30,32,$r30			# deallocate stack frame                                      #0x65c
				ret											# return                                                      #0x660
fib_ret_1: mov		1,$r0					# set return value to 1                                       #0x664   
				  ret										# return                                                      #0x668
