# This is a program in which two cores attempt to increment a common memory location 
# by a fixed value. This incrementing is done 100 times by each processor. 
# Also, the first processor increments the mem location by 1 while the second processor 
# does increment by 2. This difference is to make debug a little easier.
# This is a good program to check locking mechanism implmentation (TAS) 
# with load_locked and store_conditional instructions in multicore and SMT systems


        fbne $f1, core1     #0  cpuid branch
        lock_addr = 0x1000  # address of lock variable
        cs_addr = 0x2000    # address of critical section (common mem loc)
        zero_data = 0x0          
        lda $r1, lock_addr  #4  store lock addr into r1
        lda $r8,0x0         #8  
tas0:   ldq_l $r2, 0($r1)   #c  load lock inst. grab lock value into r2
        stq_c $r3, 0($r1)   #10 store cond inst. set store status in r3
        beq $r3, tas0       #14 branch if store was unsuccessful.  
        bne $r2, tas0       #18 branch if lock was not available
        lda $r5, cs_addr    #1c Coming here means core 0 grabbed the lock and can do the critical section. load common mem addr loc into r5
        ldq $r6, 0($r5)     #20 load value from common mem location
        addq $r6, 0x1, $r6  #24 increment afore-loaded value here
        stq $r6, 0($r5)     #28 store it back into the common mem loc
        lda $r7, zero_data  #2c
        stq $r7, 0($r1)     #30 free the lock. write 0 into lock addr.
        addq $r8,1,$r8      #34 loop counter. to do the increment 100 times
        cmple $r8,0x63,$r9  #38 loop comparison
        bne $r9,tas0        #3c
        call_pal 0x555      #40

core1:  
        lock_addr = 0x1000
        cs_addr = 0x2000
        zero_data = 0x0        
        lda $r1, lock_addr  #44
        lda $r8,0x0         #48
tas1:   ldq_l $r2, 0($r1)   #4c
        stq_c $r3, 0($r1)   #50
        beq $r3, tas1       #54
        bne $r2, tas1       #58
        lda $r5, cs_addr    #5c
        ldq $r6, 0($r5)     #60
        addq $r6, 0x2, $r6  #64 Increment by 2
        stq $r6, 0($r5)     #68
        lda $r7, zero_data  #6c
        stq $r7, 0($r1)     #70 free the lock
        addq $r8,1,$r8      #74
        cmple $r8,0x63,$r9  #78 
        bne $r9,tas1        #7c
        call_pal 0x555      
                            
