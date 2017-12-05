	bsr	$r26, itab									#PC:00
	mov	$r0, $r20	# r20 has tag of class i		#PC:04
	stq	$r1, 0($r0)	# return 1 if r2>r1.value, 0 otherwise (including no value)
#PC:08
	stq	$r2, 8($r0)	# return 1 if has a value		#PC:0c
	stq     $r3, 16($r0)	# r1=r1.next			#PC:10
	stq     $r4, 24($r0)	# r0=r1.value			#PC:14
	stq	$r5, 32($r0)	# link r1.next=r2			#PC:18
 	bsr     $r26, htab								#PC:1c
	mov	$r0, $r21	# r21 has tag of class h		#PC:20
        stq     $r1, 0($r0)							#PC:24
	stq     $r1, 8($r0)								#PC:28
	lda	$r22, 2048	# r22 has address of "heap"		#PC:2c
	bsr	$r26, makeh									#PC:30
	mov	$r0, $r14	# r14 holds current head of linked list	#PC:34
	lda	$r15, 1024	# r15 holds current address in original list	#PC:38
	ldq	$r2, 0($r15)								#PC:3c
	blt	$r2, print									#PC:40
oloop:	addq	$r15, 8, $r15						#PC:44
	ldq     $r6, 0($r14)							#PC:48
	ldq	$r5, 0($r6)									#PC:4c
	mov	$r14, $r1									#PC:50
	jsr     $r26, ($r5)	# call to greaterthan function	#PC:54
	bne	$r0, sloop									#PC:58
	bsr     $r26, makei								#PC:5c
	mov     $r0, $r14								#PC:60
	ldq     $r2, 0($r15)							#PC:64
        bge     $r2, oloop							#PC:68
	br	print										#PC:6c
sloop:	mov	$r1, $r16	# r16 holds object to link to this one	#PC:70
	ldq     $r5, 16($r6)							#PC:74
	jsr     $r26, ($r5)	# call to next function		#PC:78
	ldq	$r6, 0($r1)									#PC:7c
	ldq	$r5, 0($r6)									#PC:80
	jsr	$r26, ($r5)	# call to greaterthan function	#PC:84
	bne	$r0, sloop									#PC:88
	bsr	$r26, makei									#PC:8c
	mov	$r0, $r2									#PC:90
	mov     $r16, $r1								#PC:94
	ldq     $r6, 0($r1)								#PC:98
        ldq     $r5, 32($r6)						#PC:9c
	jsr     $r26, ($r5)     # call to link function	#PC:a0
	ldq     $r2, 0($r15)							#PC:a4
	bge	$r2, oloop									#PC:a8
print:	mov	$r14, $r1								#PC:ac
	lda	$r15, 4096									#PC:b0
prloop:	ldq     $r6, 0($r1)							#PC:b4
        ldq     $r5, 8($r6)							#PC:b8
	jsr     $r26, ($r5)     # call to cont function	#PC:bc
	beq	$r0, stop									#PC:c0
	ldq     $r5, 24($r6)							#PC:c4
	jsr     $r26, ($r5)	# call to value function	#PC:c8
	stq	$r0, 0($r15)								#PC:cc
	ldq     $r5, 16($r6)							#PC:d0	
	jsr     $r26, ($r5)     # call to next function	#PC:d4
	addq	$r15, 8, $r15							#PC:d8
	br	prloop										#PC:dc
stop:	call_pal 0x555								#PC:e0
makeh:	mov	$r22, $r0								#PC:e4
	stq	$r21, 0($r22)								#PC:e8
	addq	$r22, 8, $r22							#PC:ec
	ret												#PC:f0
makei:	mov	$r22, $r0								#PC:f4
	stq	$r20, 0($r22)								#PC:f8
	stq	$r1, 16($r22)								#PC:fc
	stq	$r2, 8($r22)								#PC:100
	addq	$r22, 24, $r22							#PC:104
	ret												#PC:108
igth:	ret	$r1										#PC:10c
	lda	$r0, 0										#PC:110
	ret												#PC:114
conti:	br	$r2, nexti								#PC:118
	addq	$r31, 1, $r0							#PC:11c
	ret												#PC:120
inti:	br	$r4, linki								#PC:124
	ldq	$r0, 8($r1)									#PC:128
	ret												#PC:12c
nexti:	br	$r3, inti								#PC:130
	ldq	$r1, 16($r1)								#PC:134
	ret												#PC:138
linki:	br      $r5, igti							#PC:13c
	stq	$r2, 16($r1)								#PC:140
	ret												#PC:144
igti:	ret	$r1										#PC:148
	ldq	$r3,8($r1)									#PC:14c
	cmplt	$r3,$r2,$r0								#PC:150
	ret												#PC:154
	.align 3
	lda	$r0, 0		# filler
htab:	br 	$r0, igth
	.quad	0
	.quad	0
        lda     $r0, 0          # filler
itab:   br	$r0, conti
        .quad   0
	.quad	0
	.quad 	0


	.align 10
	.quad	  2,   8,  23,   1,  17,   6,   7,  25
        .quad	 26,  29,   6,  30,  23,  39,   3,   3 
	.quad	 10,  11,  36,  40,  63,  34,  36, 187
        .quad	  5,  96,  0,  34,  58,  86,  99,  65
	.quad	 36,  74,  34,  88,  63,  48,  59,   5
	.quad	 83,  91, 202, 143, 126, 175, 153,   0
	.quad	137, 159, 137,   9,  17,  30,  20,  19
        .quad    44,  12,  78, 148, 284, 163, 149, 145	
	.quad	-1
