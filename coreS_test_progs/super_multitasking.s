# This program tests coherency control along with robustness of locking mechanism.
# It is written to primarily verify multicore and SMT systems. Running on a single core would not be very useful.
#
# First processor, finds sum of an array.
# Then copy the array from one mem location to another. 
# Now both processors try to multiply each array value by 2, at the new location. 
# The second processor then sorts them at the new location.
# Once it finishes, the first processor attempts to find the sum of all these terms again. 
# This should match four times the sum before sort.
# The old sum is found at "init_sum" aliased to 0x4000
# The new sum is found at "final_sum" aliased to 0x5000

        c1_status = 0x2000    # address of common status variable
        new_arr_loc = 0x6000  # address where the array is going to be copied into
        init_sum  = 0x4000    # address where the initial sum is stored
        final_sum = 0x5000    # address where the final sum is stored
        lock_addr = 0x1000    # address of lock variable
        zero_data = 0x0       

	br	start

	.align 3
	.quad	70, 77, 72, 78, 71, 85, 82, 79, 74, 80, 81, 76, 73, 89, 87, 86

	.align 3

start:	fbne $f1, core1         # cpuid branch
        
	lda	$r0,8		# r0 is a array base pointer
        lda     $r20, init_sum  # load init_sum addr into r20
        lda     $r21, final_sum # load final_sum addr into r21
	clr	$r5		# r5 is i (loop counter)
        clr     $r6             # we'll use this r6 for the sum 
        clr     $r7             # temp var to store sum
        clr     $r9             # status variable to hold cmplt status bit (for looping)
        mov     $r0, $r1        # we'll use r1 to index the array from now on for the sum
        
        # start sum calculation

iloop0: ldq $r10, 0($r1)        # load array value into r10
        ldq $r11, 8($r1)        # load next array value into r11
        addq $r10, $r11, $r7    # store sum temmporarily in r7
        ldq $r6, 0($r20)        # load previously calculated sum
        addq $r7, $r6, $r6      # get total sum, till this iteration
        stq $r6, 0($r20)        # store this back into the sum memory location
        addq $r1, 16, $r1       # move to the index of the next 2 array values
        addq $r5, 0x1, $r5      # loop count updation
        cmpult $r5, 0x8, $r9    
        bne $r9, iloop0

        # fall through - sum has been calculated
        # now copy the array from its current location to 0x6000       

	mov     $r0, $r3        # we'll use r3 to index the array from now on for the copy
        lda     $r4, new_arr_loc# load the new memory address for array into r4
        clr     $r5             # loop counter
        clr     $r9 

cpy_loop: ldq $r10, 0($r3)      # load value from old mem location into r10
          stq $r10, 0($r4)      # store above value into new mem location
          addq $r3, 8, $r3      # move the array index to the next value's position in old loc
          addq $r4, 8, $r4      # move the array index to the next value's position in new loc
          addq $r5, 1, $r5      # loop counter
          cmpult $r5, 16, $r9   # comparison for checking loop termination
          bne $r9, cpy_loop     

        # fall through - All the copying done.

        # setting the status for the processor 2. Only when P2 reads the status bit as 1, it will proceed
        lda $r15, c1_status     # load status mem location into r15
        lda $r2, 0x1            # status value to be set, here 0x2
        stq $r2, 0($r15)        # set the status bit in the status mem location
        
        # Now each processor will simultaneously attempt to multiply each value in the array by 2.

        lda $r1, lock_addr      
        lda $r14, new_arr_loc
        lda $r8,0x0
        mov $r14, $r5

tas0:   ldq_l $r2, 0($r1)      # load lock inst. grab lock value into r2   
        stq_c $r3, 0($r1)      # store cond inst. set store status in r3
        beq $r3, tas0          # branch if store was unsuccessful.  
        bne $r2, tas0          # branch if lock was not available
        ldq $r6, 0($r5)        # Coming here means core 0 grabbed the lock and can do the critical section. load common memory location into r5
        mulq $r6, 0x2, $r6     # multiply the afore-loaded value by 2
        stq $r6, 0($r5)        # store the multiplied result back into the common memory location
        lda $r7, zero_data
        stq $r7, 0($r1)        # release of lock

        addq $r5,8,$r5         # move the array value to next location
        addq $r8,1,$r8         # loop counter
        cmpult $r8,16,$r9      # check if the loop count value is less than 16
        bne $r9,tas0

        # Fall through done. This means P1 has successfully multiplied each arr value by 2
        # Now set the status bit to value 4 to tell P2 that P1 has also finished with the array multiplication

        # setting the status for the processor 2. Only when P2 reads the status bit as 4, it will proceed
        lda $r15, c1_status
        lda $r2, 0x4
        stq $r2, 0($r15)

        lda $r8, 0x2            # for status comparison in the 'wait' loop
        # wait till the other processor sets the status bit to 2. At this point, P1 gets control and resumes operation
wait:   ldq $r2, 0($r15)        # load status bit from the status address
        cmpeq $r2, $r8, $r16    # compare status against 0x2. 
        beq $r16, wait          # keep waiting if this is not 2 (P2 will set it once it's done)
       
       # Fall through. This means proc 2 has finished its operation (sorting the array). Now calculate sum again

	lda	$r0, new_arr_loc # r0 is a array base pointer
        lda     $r21, final_sum # r21 has the final sum's mem location
	clr	$r5		# r5 is i (loop counter)
        clr     $r6             # we'll use this for the sum 
        clr     $r7
        clr     $r9
        mov     $r0, $r1        # we'll use r1 to index the array from now on for the sum

iloop:  ldq $r10, 0($r1)        # load array value into r10
        ldq $r11, 8($r1)        # load next array value into r11
        addq $r10, $r11, $r7    # store sum temmporarily in r7
        ldq $r6, 0($r21)
        addq $r7, $r6, $r6      # get final sum, till this iteration
        stq $r6, 0($r21)
        addq $r1, 16, $r1       # move to the index of the next 2 array values
        addq $r5, 0x1, $r5
        cmpult $r5, 0x8, $r9
        bne $r9, iloop

        # Done

	call_pal        0x555

# the second core's code execution starts here...

core1:  lda $r15, c1_status   # load mem address of status bit reg in r15
        lda $r9, 0x1          # '1' is the status value to be checked for

wait1:  ldq $r10, 0($r15)     # load the status bit
        cmpeq $r10, $r9, $r8  # compare the status bit with 0x1, which is set by P1 after it finished copying
        beq $r8, wait1        # check comparison status 

        # Fall through done. This means P1 is done with the copying. Time to start the simultaneous multiplication by 2...

        lda $r14, new_arr_loc # r14 has the new location's address
        lda $r1, lock_addr    # lock variable mem location is put in r1
        lda $r8,0x0
        mov $r14, $r5         # we'll use r5 to track the new array location from now on

        # TAS check and critical section updation

tas1:   ldq_l $r2, 0($r1)     # load lock inst. grab lock value into r2   
        stq_c $r3, 0($r1)     # store cond inst. set store status in r3
        beq $r3, tas1         # branch if store was unsuccessful.  
        bne $r2, tas1         # branch if lock was not available
        ldq $r6, 0($r5)       # Coming here means core 1 grabbed the lock and can do the critical section. load common memory location into r5
        mulq $r6, 0x2, $r6    # multiply the afore-loaded value by 2
        stq $r6, 0($r5)       # store the multiplied result back into the common memory location
        lda $r7, zero_data                                                                                                                     
        stq $r7, 0($r1)       # release of lock        
                                                                                                                                               
        addq $r5,8,$r5        # move the array value to next location
        addq $r8,1,$r8        # loop counter
        cmpult $r8,16,$r9     # check if the loop count value is less than 16
        bne $r9,tas1

        # Fall through done. This means the P2 has finished multiplying each arr index by 2
        # Now do a check on the status bit to see if P1 has also finished with its multiplication of array values

        lda $r15, c1_status   # load status mem address in r15
        lda $r9, 0x4          # 0x4 is the status value to be checked against

wait12: ldq $r10, 0($r15)     # load the status bit
        cmpeq $r10, $r9, $r8  # compare the status bit with 0x4, which is set by P1 after it finished multiplying the array
        beq $r8, wait12       # check comparison status 

        # Fall through Done. This means the P1 has also finished multiplying the array. Time to sort it in the new location. The sorting technique employed here is bubble sort.

        lda $r0, new_arr_loc  # the array's new mem location is put into r0

	clr	$r5		# r5 is i (loop counter)

iloop11: clr	$r6		# r6 is j (inner loop counter)
	negq	$r5,$r7		# r7 is -i
	addq	$r7,15,$r7	# r7 is now 16-i

	mov	$r0,$r1		# we'll use $r1 to index a[j] in the loop

jloop11: ldq	$r2,0($r1)	# r2 <- a[j]
	ldq	$r3,8($r1)	# r3 <- a[j+1]

	cmpult	$r2,$r3,$r4
	bne	$r4,noswap11	#  branch if $r2 < $r3

	# do swap
	stq	$r2,8($r1)
	stq	$r3,0($r1)

noswap11: # increment j (and a[j] ptr) and test
	addq	$r1,8,$r1
	addq	$r6,1,$r6
	cmpult	$r6,$r7,$r4
	bne	$r4,jloop11	# branch if $r6 < $r7

	# fall through: inner loop done, check outer loop (i)
	addq	$r5,1,$r5
	cmpult	$r5,16,$r4
	bne	$r4,iloop11

	# fall through:	done. Now set the status bit to 2, for processor 1 to begin its next phase of operation
	lda $r15, c1_status   # load status mem address in r15
        lda $r9, 0x2          # status value to be set
        stq $r9, 0($r15)      # store the status value in the status mem location

        call_pal 0x555

