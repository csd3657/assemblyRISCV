	.data
	.align 2
	.macro print_str (%value)
		addi    x17, x0, 4      	# environment call code for print_string
       	 	la      x10, %value 		# pseudo-instruction: address of string
        	ecall                   	# print the string from str_n
	.end_macro	
	.macro print_int(%value)
		addi x17, x0, 1			# environment call code for print_int
		add x10, x0, %value		
		ecall				# print the int from kataxwriti-> %value
	.end_macro
str_n:  .asciz "\nGive integers and <= 0 when you like to stop:\n"
str_m:  .asciz "\nNow, give an integer > 0 to print the greaters:\n"
	.text
	
	j main
	
read_int:
	addi x17, x0, 5
	add x10, x17, x0
	ecall
	jr ra, 0
	
node_alloc:
	li x17, 9		# 9 is the sbrk code
	addi x10, x0, 8		# 8 are the bytes to allocate
        ecall
	jr ra, 0 
	
print_node:
	lw x31, 0(a0)
	bge a1, x31, print_node_return# if 25(node) > 23(number) print(node)
	print_int(x31)
print_node_return:
	jr ra, 0
		
search_list:
	addi sp, sp, -12	# take 4bytes for return address of function
	sw ra, 8(sp)		# saving return address
	sw a0, 4(sp)		# saving 1st arg = temp head
	sw a1, 0(sp)		# saving 2nd arg = number
	
	add a0, x0, x18		# 1st arg = temp head
	add a1, x0, a1		# 2nd arg = number
        jal ra, print_node
	lw ra, 8(sp)		# restore return address
	lw a0, 4(sp)		# restore 1st arg = temp head
	lw a1, 0(sp)		# restore 2nd arg = number
	addi sp, sp, 12		# return 4bytes for return address of function
	lw x31, 4(x18)		# add to a temp the next of tail
	beq x31, x0, search_list_return	# if (tail next != NULL)
	add x18, x31, x0		#tail = tail next
	j search_list
search_list_return:
	jr ra, 0
	
main:
	print_str(str_n)
	addi sp, sp, -4		# take 4bytes for return address of function
	sw ra, (sp)		# store ra to stack
	jal ra, node_alloc 	# dummy alloc
	lw ra, (sp) 		# restore ra from stack
	addi sp, sp, 4		# return 4bytes for return address of function
	
	sw x0, 0(x10) 		# init data
	sw x0, 4(x10) 		# init nxtPtr
	add x8, x10, x0		# init head
	add x9, x10, x0		# init tail

step1:
	addi sp, sp, -4		# take 4bytes for return address of function
	sw ra, (sp)		# store ra to stack
        jal ra, read_int
	lw ra, (sp) 		# restore ra from stack
	addi sp, sp, 4		# return 4bytes for return address of function
	add x31, x10, x0
	bge x0, x31, step2	# if input <= 0 goto step2
	
	addi sp, sp, -4		# take 4bytes for return address of function
	sw ra, (sp)		# store ra to stack
	jal ra, node_alloc
	lw ra, (sp) 		# restore ra from stack
	addi sp, sp, 4		# return 4bytes for return address of function
	
	sw x31, 0(x10) 		# init data
	sw x0, 4(x10) 		# init nxtPt->NULL(x0)
	sw x10, 4(x9) 		# tail -> node
	add x9, x0, x10		# tail = new node
	
	j step1
	
step2:
	print_str(str_m)
	addi sp, sp, -4		# take 4bytes for return address of function
	sw ra, (sp)		#store ra to stack
        jal ra, read_int
	lw ra, (sp) 		# restore ra from stack
	addi sp, sp, 4		# return 4bytes for return address of function
	add x9, x10, x0		# tail = arithmos pou diavasame
	bge x0, x9, exit 	# if number is <= 0 exit programm
	add x18, x8, x0		# temp = head
	
	addi sp, sp, -12	# take 4bytes for return address of function
	sw ra, 8(sp)		# saving return address
	sw x18, 4(sp)		# saving 1st arg = temp head
	sw x9, 0(sp)		# saving 2nd arg = number
	
	add a0, x0, x18		# 1st arg = temp head
	add a1, x0, x9		# 2nd arg = number
        jal ra, search_list
        
	lw ra, 8(sp)		# restore return address
	lw x18, 4(sp)		# restore 1st arg = temp head
	lw x9, 0(sp)		# restore 2nd arg = number
	addi sp, sp, 12		# return 4bytes for return address of function
	
	j step2
	
exit:
	li x17, 10		# 9 is the exit code
	add x10, x17, x10	
        ecall
