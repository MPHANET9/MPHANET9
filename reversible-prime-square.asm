#================================================================================
#AUTHOR: Thabang Mphane
#DATE: 24 October 2022
#STUDENT NUMBER: 202000689
#DESCRIPTION: A code that prints the first 10 reversible square primes
#==============================================================================
.data
	myArray: .space 40000
	message: .asciiz "These are the first 10 reversible square primes"
	newLine: .asciiz "\n"
	
.text
.globl main

	main:
#===============================================================================
#R E G I S T E R  M A P P I N G
#$t0 -> int number
#$t1 -> bool isprime && remainder
#$t2 -> int count
#$t3 -> int length
#$t4 -> int i; index
#$s0 -> number * number
#===============================================================================
	li $t0, 2					#Set the first number to 2
	li $t3, 0					#Set the length at 0
	la $t4, myArray				#Load the base address for the array
	while:
		beq $t0, 10000, exit	#If the number equals to 10000, exit loop
		
		li $t1, 1				#Set isprime to true
		li $t2, 2				#Set the checking number from 2
		isprime:				#A condition to check if the number is a prime number
			beq $t2, $t0, done	#If the count equals the number, exit loop
			beqz $t1, done		#If the remainder == 0, set isprime to false and exit loop
			
			div $t0, $t2		#Check if the number is fully divisible
			mfhi $t1			#If its not, $t1 == 0, isprime == false
			
			addi $t2, $t2, 1	#Increment to the next number
			
			j isprime
		done:
		
		sq_primes:				#Populate the array
			beqz $t1, skip		#isprime == false, Skip, dont populate
			
			mult $t0, $t0		#Square the prime number
			mflo $s0
			
			sw $s0, 0($t4)			#Populate the array
				addi $t4, $t4, 4	#Increment to the next position
			
			addi $t3, $t3, 1		#Count the number of elements in the array	
		skip:	
		
		addi $t0, $t0, 1		#Increment to the next number
		
		j while
	exit:
	
	li $v0, 4
	la $a0, message
	syscall
	
#===========================================================================================
#R E G I S T E R - M A P P I N G  F O R  T H E  P R I N T I N G
#$a1 -> int sq_primes[counter]; argument for the Reverse procedure
#$v1 -> Return value from the Reverse procedure
#$s1 -> memory base address for the array
#$t0 -> int exit
#$t1 -> int counter; indexing through the array for the numbers to print
#$t2 -> int count; indexing through the array for number less than the number before
#$t3 -> int length; number of numbers in the array
#$t4 -> memory base address for the array
#$t5 -> int sq_primes[count]
#===========================================================================================	

	la $t4, myArray				#Load base address for the array
	li $t0, 1					#int exit = 0
	li $t1, 0					#Set the indexing at 0, for first number
	
	while_1:
		beq $t1, $t3, exit_1	#IF counter<length; keep iterating
		
		lw $a1, 0($t4)			#Load a integer from the array, sq_primes[counter]
			addi $t4, $t4, 4		#Increment to the next word in the array
		
		addi $sp, $sp, -20		#Allocate memory in the stack to store the argument, number
		sw $a1, 0($sp)			#Store the argument in the stack, before calling the procedure
		sw $t0, 4($sp)			#Store the temporary registers that are in use in the main procedure
		sw $t1, 8($sp)
		sw $t3, 12($sp)
		sw $t4, 16($sp)
			jal Reverse				#Call the Reverse procedure, to reverse the number
		lw $t4, 16($sp)
		lw $t3, 12($sp)		
		lw $t1, 8($sp)			#Load the temporary registers that are in use in the main procedure
		lw $t0, 4($sp)
		lw $a1, 0($sp)			#Load the argument from the stack, after calling the procedure
		addi $sp, $sp, 20		#Deallocate memory in the stack; 12 = 4 * 3
		
		non_palindrome:
			beq $a1, $v1, palindrome	#sq_primes[counter] == Reverse(sq_primes[counter])
			
			li $t2, 0					#Set the indexing at 0, int count = 0
			la $t5, myArray				#Load base memory address for the array
			tester:
				beq $t2, $t3, tested	#if count < length, keep iterating
				
				lw $s1, 0($t5)			#Load integer from array, sq_primes[count]
					addi $t5, $t5, 4	#Increment to the next word in the array
					
				reversible_sq_primes:
					bne $s1, $v1, not_reversible_sq_primes		#If the numbers being matched are not equal dont print
					beq $t0, 10, not_reversible_sq_primes		#If 10 numbers are printed stop print 

					li $v0, 4									#Print newLine
					la $a0, newLine
					syscall
					
					li $v0, 1									#Print number
					add $a0, $a1, $zero
					syscall
					
				not_reversible_sq_primes:
				
				addi $t2, $t2, 1		#Increment to the second number
				
				j tester
			tested:
		palindrome:
		
		addi $t1, $t1, 1		#Increment to the next number, counter++
		j while_1
	exit_1:
	
	li $v0, 10
	syscall
	
# P R O C E D U R E S  F R O M  T H E  C O D E

#THIS IS A PROCEDURE THAT CALCULATES THE NUMBER OF DIGITS A NUMBER HAS
#=========================================================================
#R E G I S T E R - M A P P I N G
#$a1 -> int sq_primes[counter]; procedure argument
#$v1 -> int width; the return value in the procedure
#$t0 -> const 10
#=========================================================================
	#THIS PROCEDURE IS A CALLEE FROM Exponent; s registers to stack
	digitSize:
		li $v1, 0					#Set the width as 0
		li $t0, 10					#Set the constant to 10
		reduce:
			beqz $a1, stop			#If argument == 0, stop loop
		
			div $a1, $t0			#Divide the argument by 10, to remove one digit from it
			mflo $a1				#Store the quotient as the new number in the procedure
			
			addi $v1, $v1, 1		#Increment, width with 1
			
			j reduce
		stop:
	
		jr $ra
	
#THIS IS A PROCEDURE THAT CALCULATES OUR NUMBER'S PLACE VALUE EQUIVALENT
#========================================================================
#R E G I S T E R - M A P P I N G
#$a1 -> int sq_primes[counter]; procedure argument and argument for digitSize procedure
#$a2 -> int exit; procedure argument
#$v1 -> return value from the digitSize procedure
#$t0 -> int expo
#$t1 -> int std_form; the return value 
#$t2 -> const 10
#========================================================================
	#THIS PROCEDURE IS A CALLEE FROM Reverse; s registers to stack
	#THIS PROCEDURE IS A CALLER TO digitSize; ra register to stack at prologue
	Exponent:
		addi $sp, $sp, -4			#Allocate memory in the stack for one word
		sw $ra, 0($sp)				#Store the procedure's return address in the stack

		addi $sp, $sp, -8			#Allocate memory in the stack for our a registers
		sw $a1, 0($sp)				#Store the first argument, $a1
		sw $a2, 4($sp)				#Store the second argument, $a2
			jal digitSize				#Call the procedure digitSize
		lw $a2, 4($sp)				#Load the second argument to register, $a2
		lw $a1, 0($sp)				#Load the first argument to register, $a1
		addi $sp, $sp, 8 			#Deallocate memory in the stack
		
		sub $t0, $v1, $a2 			#expo = digitSize(sq_primes[counter]) - exit
		
		li $t1, 1					#Set std_form to 1
		li $t2, 10					#const 10
		
		reduce_1:
			beqz $t0, stop_1		#If the expo == 0, stop loop
			
			mult $t1, $t2			#Keep increasing the place value
			mflo $t1				#Store the quotient of the product
			
			addi $t0, $t0, -1		#Decrement by 1
			
			j reduce_1
		stop_1:
		
		addi $v1, $zero, 0			#Clear the return register
		add $v1, $zero, $t1			#Move the std_form into the return register for the procedure
		
		lw $ra, 0($sp)				#Load the return address for the procedure
		addi $sp, $sp, 4			#Deallocate memory in the stack
		jr $ra
	
#THIS IS A PROCEDURE THAT REVERSES OUR NUMBER
#=========================================================================
#R E G I S T E R - M A P P I N G
#$a1 -> int integer,procedure argument and argument for Exponent procedure 
#$a2 -> int exit, argument for Exponent procedure
#$v1 -> Return value from the Exponent procedure
#$t0 -> int rev
#$t1 -> int temporary
#$t2 -> temporary%const 10 && $t2 *= v1
#$t3 -> const 10
#=========================================================================
	#THIS PROCEDURE IS A CALLEE FROM main; s registers to stack
	#THIS PROCEDURE IS A CALLER TO Exponent; ra register to stack
	Reverse: 
		addi $sp, $sp, -4			#Allocate memory in the stack for one word
		sw $ra, 0($sp)				#Store the return address in the stack
		
		li $t0, 0					#int rev = 0
		li $a2, 1					#int exit = 1
		
		add $t1, $zero, $a1 		#int temporary = integer
		
		reduce_2:
			beqz $t1, stop_2		#if temporary == 0, stop loop
			
			li $t3, 10				#const 10
			
			addi $sp, $sp, -20		#Allocate memory for a registers + t registers
			sw $a1, 0($sp)			#Store the a registers in the stack
			sw $a2, 4($sp)
			sw $t0, 8($sp)			#Store the t registers in the stack
			sw $t1, 12($sp)
			sw $t3, 16($sp)
				jal Exponent		#Call the Exponent procedure
			lw $t3, 16($sp)
			lw $t1, 12($sp)
			lw $t0, 8($sp)			#Load the t registers from the stack
			lw $a2, 4($sp)
			lw $a1, 0($sp)			#Load the a registers from the stack
			addi $sp, $sp, 20		#Deallocate memory in the stack
			
			div $t1, $t3			#temporary%10
			mfhi $t2				#Store the remainder in the register, not the quotient
			
			mult $t2, $v1			#(temporary%10)*(Exponent(integer, exit))
			mflo $t2				#For more control on the numbers, each is a 32 bit
			
			add $t0, $t0, $t2		#rev += (temporary%10)*(Exponent(integer, exit))
			
			div $t1, $t3			#temporary/10
			mflo $t1				#Reduce the number by 1 unit
			
			addi $a2, $a2, 1		#exit += 1
			
			j reduce_2
		stop_2:
		
		addi $v1, $zero, 0			#Clear the return register
		add $v1, $zero, $t0			#Set rev as the procedure's return value
		
		lw $ra, 0($sp)				#Load the return address for the procedure 
		addi $sp, $sp, 4

		jr $ra