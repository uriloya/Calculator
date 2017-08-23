section .data
	format_number: 		db 		"%d", 0		
	format_string:		db 		"%s", 0
	format_hex:			db 		"%x", 0
	print_message: 		db 		">>calc: ", 0
	print_message2: 	db 		">>", 0
	newline:			db		10, 0
	error_message1: 	db 		">>Error: Operand Stack Overflow", 10, 0
	error_message2: 	db 		">>Error: Insufficient Number of Arguments on Stack", 10, 0
	error_message3: 	db 		">>Error: exponent too large", 10, 0
	error_message4: 	db		">>Error: Illegal Input", 10, 0
	ser1: 				dd 		0
	k_counter:			db 		0
	ser2: 				dd 		0
	little_carry:		db		0
	ser3: 				dd 		0
	big_carry:			db		0
	ser4: 				dd 		0
	prev_carry: 		db		0
	ser5: 				dd 		0

section .bss
    buffer: 	  		resb	100
    operand_stack:  	resb	20
    ptr_start_stack: 	resb	4
    ptr_curr_stack: 	resb	4
    ptr_prev_stack: 	resb	4
    counter_of_nums:	resb 	1
	next_link_ptr:		resb 	4
	op_current_size: 	resb 	4
	answer: 			resb 	4
	first_in_list: 		resb 	1
	new_node:			resb 	4
	num1:				resb	4	
	num2:				resb	4
	num_to_print:		resb	1
	odd_check:			resb	4
	link1_length:		resb	4
	link2_length:		resb	4
	after_trim:			resb	4
	op_count: 			resb	4
	bigger_list: 		resb	4
	debug:				resb 	4
	success:			resb 	4

section .text
    align  16
    global main
    extern exit
	extern printf
	extern fprintf
	extern malloc
	extern free
	extern fgets
	extern stderr
	extern stdin
	extern stdout

main:
	push 	ebp
	mov 	ebp, esp

	mov 	dword [debug], 0	
	mov		ebx, [ebp+8]
	cmp		ebx, 1
	jbe		continue
	mov 	ebx, [ebp+12]
	mov 	ecx, [ebx+4]
	cmp 	[ecx], byte '-'
	jne		continue
	cmp 	[ecx+1], byte 'd'
	jne		continue
	cmp 	[ecx+2], byte 0
	jne		continue
	mov 	dword [debug], 1

continue:
	pushad
	call 	my_clac
	mov 	dword [answer], eax				;return address from my_clac
	popad

	pushad
	push 	dword [answer]						;the ops_counter
	push 	format_number
	call	printf
	add 	esp, 8
	popad

	pushad
	push 	newline
	push 	format_string
	call 	printf
	add 	esp, 8
	popad

	push 	0							;exit program with status 0
	call 	exit

my_clac:
	push 	ebp
	mov 	ebp, esp						;;need to check if to save space for locals
	mov 	dword [op_count], 0
	mov	 	byte [first_in_list], 0
	mov 	byte [counter_of_nums], 0
	mov 	dword [next_link_ptr], 0
	mov 	dword [ptr_prev_stack], 0
	mov 	dword [operand_stack], 0
	mov 	dword [operand_stack + 4], 0
	mov 	dword [operand_stack + 8], 0
	mov 	dword [operand_stack + 12], 0
	mov 	dword [operand_stack + 16], 0
	mov 	dword [new_node], 0
	mov 	dword [num1], 0
	mov 	dword [num2], 0
	mov 	byte [num_to_print], 0
	mov 	dword [odd_check], 0
	mov 	dword [link1_length], 0
	mov 	dword [link2_length], 0
	mov 	dword [after_trim], 0
	mov 	dword [bigger_list], 0
	mov 	byte [little_carry], 0
	mov 	byte [big_carry], 0
	mov 	byte [prev_carry], 0
	mov		byte [k_counter], 0
	mov 	dword [ser1], 0
	mov 	dword [ser2], 0
	mov 	dword [ser3], 0
	mov 	dword [ser4], 0
	mov 	dword [ser5], 0
	mov 	eax, operand_stack
	mov 	dword [ptr_curr_stack], eax

read:
	pushad
	push 	print_message
	push 	format_string
	call	printf
	add 	esp, 8
	popad

	pushad
    push 	dword [stdin]
    push 	100
    push 	buffer
    call	fgets
    add 	esp, 12
    popad

    mov 	dword [success], 1
    jmp  	check_input

check_input:
	mov		edx, buffer 				;edx is running on the buffer
	cmp 	byte [edx], 'q'
	je 		quit
	cmp 	byte [edx], '+'
	je 		addition_f
	cmp 	byte [edx], 'r'
	je 		shift_right_f
	cmp 	byte [edx], 'l'
	je 		shift_left_f
	cmp 	byte [edx], 'd'
	je 		duplicate_f
	cmp 	byte [edx], 'p'
	je 		pop_and_print_f

	jmp 	numbercheck_f

addition_f:
	pushad
	call 	addition
	popad
	cmp 	dword [debug], 1
	jne 	read
	cmp		dword [success], 1
	je 		printd
	jmp 	read

shift_right_f:
	pushad
	call 	shift_right
	popad
	cmp 	dword [debug], 1
	jne 	read
	cmp		dword [success], 1
	je 		printd
	jmp 	read

shift_left_f:
	pushad
	call 	shift_left
	popad
	cmp 	dword [debug], 1
	jne 	read
	cmp		dword [success], 1
	je 		printd
	jmp 	read

duplicate_f:
	pushad
	call 	duplicate
	popad
	cmp 	dword [debug], 1
	jne 	read
	cmp		dword [success], 1
	je 		printd
	jmp 	read

pop_and_print_f:
	pushad
	call 	pop_and_print
	popad
	jmp 	read

numbercheck_f:
	pushad
	call 	numbercheck
	popad
	jmp 	read

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; quit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

quit:
	add 	edx, 1
	cmp 	byte [edx], 10			;check if input is legal
	jne 	error4	
	mov 	eax, [op_count]
	mov 	esp, ebp					;return to main
	pop 	ebp
	ret	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; number ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

numbercheck:
	push 	ebp
	mov 	ebp, esp
	cmp		byte [counter_of_nums], 5 
	je		error1
	cmp 	byte [edx], 10
	je 		error4
	mov 	dword [after_trim], 0

trim_number:
	cmp		byte [edx], '0'
	jne		number
	add 	edx, 1
	jmp 	trim_number

number:
	pushf
	cmp 	dword [debug], 1
	jne 	continue1	
	pushad
	push 	edx
	push 	dword [stderr]
	call	fprintf
	add 	esp, 8
	popad
	popf

continue1:
	cmp		byte [edx], 10
	je 		only_zeroes
	mov 	[after_trim], edx
	jmp 	length_loop

only_zeroes:
	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	ecx, dword [new_node]
	mov 	byte [ecx], 0

	mov 	dword [ecx + 1], 0
	mov 	dword [ecx + 5], 0

	mov 	eax, [ptr_curr_stack]
	mov 	[eax], ecx 

	jmp 	increase_stack

length_loop:
	cmp		byte [edx], 10
	je 		handle_length
	add 	edx, 1
	add 	dword [odd_check], 1
	jmp 	length_loop

handle_length:
	mov 	edx, [after_trim]
	mov 	ecx, [odd_check]
	and 	ecx, 1
	cmp 	ecx, 1
	je 		odd_number
	jmp 	even_number

odd_number:
	mov 	dword [odd_check], 0
	cmp 	byte [edx], '0'
	jb 		error4
	cmp 	byte [edx], '9'				;;need to check if input is entirly number
	ja 		error4

	mov 	bl, byte [edx]
	sub		bl, '0'						;;make num from string

	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	ecx, dword [new_node]
	mov 	[ecx], bl

	mov		byte [first_in_list], 1

	mov 	[next_link_ptr], ecx
	mov 	dword [ecx + 5], 0

	mov 	eax, [ptr_curr_stack]
	mov 	[eax], ecx 

	add 	edx, 1

	jmp 	even_number

even_number:
	cmp 	byte [edx], 10
	je 		increase_stack
	cmp 	byte [edx], '0'
	jb 		error4
	cmp 	byte [edx], '9'				;;need to check if input is entirly number
	ja 		error4

	mov 	bl, byte [edx]
	sub		bl, '0'						;;make num from string
	add 	edx, 1

	cmp 	byte [edx], '0'
	jb 		error4
	cmp 	byte [edx], '9'				;;need to check if input is entirly number
	ja 		error4

	mov 	bh, byte [edx]
	sub		bh, '0'	
	shl 	bl, 4
	add 	bl, bh

	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	ecx, dword [new_node]
	mov 	[ecx], bl

	cmp 	byte [first_in_list], 0
	je 		handle_first_in_list

	mov 	eax, [next_link_ptr]
	mov 	[next_link_ptr], ecx

	mov 	[eax + 1], ecx
	mov 	[ecx + 5], eax

	mov 	eax, [ptr_curr_stack]
	mov 	[eax], ecx 

	add 	edx, 1

	jmp 	even_number
	
handle_first_in_list:
	mov		byte [first_in_list], 1
	mov 	dword [next_link_ptr], ecx
	mov		dword [ecx + 5], 0
	mov 	eax, [ptr_curr_stack] 				;add to operand_stack
	mov 	[eax], ecx
	add 	edx, 1

	jmp 	even_number

increase_stack:
	mov 	eax, [ptr_curr_stack]
	mov 	[ptr_prev_stack], eax
	mov 	eax, [eax]
	mov 	dword [eax + 1], 0 						;set prev of first link to 0

	add 	dword [ptr_curr_stack], 4
	add 	byte [counter_of_nums], 1
	mov 	byte [first_in_list], 0

	mov 	esp, ebp					;return to main
	pop 	ebp
	ret	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; pop_and_print ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pop_and_print:
	push 	ebp
	mov 	ebp, esp
	cmp		byte [counter_of_nums], 0
	je 		error2

	mov 	eax, [ptr_prev_stack]
	mov 	ebx, [eax]

	cmp 	dword [ebx + 5], 0
	je 		sole_link

final_link_loop:
	mov 	ebx, [ebx + 5]
	cmp 	dword [ebx + 5], 0
	jne 	final_link_loop	
	mov 	eax, ebx

;;;; print 
	mov 	ecx, 0
	mov 	cl, byte [ebx]

	pushad
	push 	print_message2
	push 	format_string
	call	printf
	add 	esp, 8
	popad

	pushad
	push 	ecx
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	cmp 	dword [ebx + 1], 0
	je 		increase_op_count

print_loop:
	mov 	ebx, [ebx + 1]
	mov 	ecx, 0
	mov 	cl, byte [ebx]

	cmp 	cl, 0								;;check fo 00 situation
	je 		situation_zero

	cmp 	cl, 9
	jbe		one_digit

	pushad
	push 	ecx
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	cmp 	dword [ebx + 1], 0
	jne 	print_loop

	pushad
	push 	newline
	push 	format_string
	call 	printf
	add 	esp, 8
	popad

	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1

	jmp 	increase_op_count

one_digit:
	mov 	esi, 0

	pushad
	push 	esi
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	pushad
	push 	ecx
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	cmp 	dword [ebx + 1], 0
	jne 	print_loop

	pushad
	push 	newline
	push 	format_string
	call 	printf
	add 	esp, 8
	popad

	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1

	jmp 	increase_op_count


situation_zero:
	pushad
	push 	ecx
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	pushad
	push 	ecx
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	cmp 	dword [ebx + 1], 0
	jne 	print_loop

	pushad
	push 	newline
	push 	format_string
	call 	printf
	add 	esp, 8
	popad

	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1

	jmp 	increase_op_count

sole_link:
	mov 	ecx, 0
	mov 	cl, byte [ebx]

	pushad
	push 	print_message2
	push 	format_string
	call	printf
	add 	esp, 8
	popad

	pushad
	push 	ecx
	push 	format_hex
	call	printf
	add 	esp, 8
	popad

	pushad
	push 	newline
	push 	format_string
	call 	printf
	add 	esp, 8
	popad

	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1

	jmp 	increase_op_count

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; addition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

addition:
	push 	ebp
	mov 	ebp, esp
	cmp		byte [counter_of_nums], 2
	jb 		error2
	mov 	ebx, [ptr_prev_stack]
	mov		ecx, [ebx - 4]
	mov 	edx, [ebx]
	mov 	dword [link1_length], 0
	mov 	dword [link2_length], 0

find_length1:
	mov 	ecx, [ecx + 5]
	add 	dword [link1_length], 1
	cmp 	dword ecx, 0
	je 		find_length2
	jmp  	find_length1

find_length2:
	mov 	edx, [edx + 5]
	add 	dword [link2_length], 1
	cmp 	dword edx, 0
	je 		check_who_is_bigger
	jmp  	find_length2

check_who_is_bigger:
	mov		ecx, [ebx - 4]
	mov		esi, [ebx - 4]
	mov 	edx, [ebx]
	mov 	dword [bigger_list], 1
	mov 	eax, dword [link1_length]
	cmp 	eax, dword [link2_length]
	jb		link2_bigger
	jmp		sum_loop_first

link2_bigger:
	mov 	dword [bigger_list], 2
	mov		edx, [ebx - 4]
	mov 	ecx, [ebx]
	mov 	esi, [ebx]

sum_loop_first:
	clc

sum_loop:
	mov 	al, byte [ecx] 
	adc 	al, byte [edx]
	daa

	mov		byte [ecx], al 
	mov 	ecx, [ecx + 5]
	mov 	edx, [edx + 5]
	pushf
	cmp 	dword edx, 0
	je 		check_carry_first
	popf
	jmp 	sum_loop

check_carry_first:
	popf

check_carry:
	pushf
	jnc		remove_last_num
	cmp 	dword ecx, 0
	je 		build_node
	popf
	mov 	al, byte [ecx]
	adc 	al, 0
	daa
	mov 	byte [ecx], al
	jmp 	check_carry

build_node:
	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	ebx, dword [new_node]
	mov 	byte [ebx], 1

go_to_last:
	mov 	ecx, esi
	cmp 	dword [ecx + 5], 0
	je 		conncect_carry

go_loop:
	mov 	ecx, [ecx + 5]
	cmp 	dword [ecx + 5], 0
	jne 	go_loop	

conncect_carry:
	mov 	[ebx + 1], ecx
	mov 	[ecx + 5], ebx
	mov 	dword [ebx + 5], 0
	
remove_last_num:
	cmp 	dword [bigger_list], 2
	je 		remove_before_last
	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1
	jmp		finish_sum

remove_before_last:
	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	mov 	ebx, dword [ptr_curr_stack]
	mov 	ecx, dword [ptr_prev_stack]
	mov 	eax, [ebx]
	mov 	[ecx], eax
	sub 	byte [counter_of_nums], 1

finish_sum:	
	add 	dword[op_count], 1
	mov 	esp, ebp					;return to main
	pop 	ebp
	ret		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; duplicate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

duplicate:
	push 	ebp
	mov 	ebp, esp
	cmp		byte [counter_of_nums], 0
	je 		error2	
	cmp		byte [counter_of_nums], 5
	je 		error1

	mov 	ebx, [ptr_prev_stack]
	mov		ecx, [ebx]

	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	edx, dword [new_node]
	mov 	eax, [ptr_curr_stack]
	mov 	[eax], edx 

	mov 	al, byte [ecx]
	mov 	byte [edx], al
	mov 	dword [edx + 1], 0

copy_loop:
	cmp 	dword [ecx + 5], 0
	je 		last_link

	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	ebx, dword [new_node]
	mov 	[edx + 5], ebx
	mov 	[ebx + 1], edx

	mov 	ecx, [ecx + 5]
	mov 	al, byte [ecx]
	mov 	byte [ebx], al

	mov 	edx, ebx

	jmp 	copy_loop

last_link:
	mov 	dword [edx + 5], 0
	add 	byte [counter_of_nums], 1
	add 	dword [ptr_curr_stack], 4
	add 	dword [ptr_prev_stack], 4

	jmp 	increase_op_count

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; shift_right ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

shift_right:
	push 	ebp
	mov 	ebp, esp

	mov 	byte [big_carry], 0
	mov 	byte [little_carry], 0
	mov 	byte [prev_carry], 0
	mov		byte [k_counter], 0
	cmp		byte [counter_of_nums], 2
	jb 		error2
	mov 	ebx, [ptr_prev_stack]
	mov 	edx, [ebx]

shr_find_length:
	mov 	edx, [edx + 5]
	cmp 	dword edx, 0
	je 		shr_loop_first
	jmp  	error3

shr_loop_first:
	mov 	edx, [ebx]
	mov 	dl, byte [edx]
	shr 	dl, 4
	times 10 add 	byte [k_counter], dl

	mov 	edx, [ebx]
	mov 	dl, byte [edx]
	shl 	dl, 4
	shr 	dl, 4
	add 	byte [k_counter], dl

shr_loop:
	mov 	byte [big_carry], 0
	mov 	byte [little_carry], 0
	mov 	byte [prev_carry], 0
	mov 	ebx, [ptr_prev_stack]
	cmp 	byte [k_counter], 0
	je		end_of_shr
	sub 	byte [k_counter], 1
	mov		ecx, [ebx - 4]

rewind:
	cmp 	dword [ecx + 5], 0
	je		delete_zeroes
	mov 	ecx, [ecx + 5]
	jmp 	rewind

delete_zeroes:
	cmp 	byte [ecx], 0
	jne 	start_shr

	cmp 	dword [ecx + 1], 0
	je 		start_shr

	mov 	ecx, [ecx + 1]
	mov 	dword [ecx + 5], 0
	jmp 	delete_zeroes

start_shr:
	clc

shr_div_loop:
	mov 	edx, 0
	mov 	dl, byte [ecx]
	shl  	edx, 4
	shr 	dl, 4
	mov 	bl, dh

	shr 	bl, 1
	setc 	al
	mov 	byte [little_carry], al

	shr 	dl, 1
	setc 	al
	mov 	byte [big_carry], al

	cmp 	byte [little_carry], 1
	je 		shr_add5

	shl 	bl, 4
	or 		bl, dl
	mov  	byte [ecx], bl
	jmp 	finish_sole_treat

shr_add5:
	add 	dl, 5
	shl 	bl, 4
	or 		bl, dl
	mov  	byte [ecx], bl 

finish_sole_treat:
	cmp 	byte [prev_carry], 1
	je 		shr_add50

	cmp 	dword [ecx + 1], 0
	je 		dont_change_prev

	mov 	eax, [big_carry]
	mov 	[prev_carry], eax

dont_change_prev:
	mov 	ecx, [ecx + 1]
	cmp 	dword ecx, 0 
	jne		shr_div_loop
	jmp 	shr_loop

shr_add50:
	add 	byte [ecx], 50h 
	cmp 	dword [ecx + 1], 0
	je 		dont_change_prev2

	mov 	eax, [big_carry]
	mov 	[prev_carry], eax

dont_change_prev2:
	mov 	ecx, [ecx + 1]
	cmp 	dword ecx, 0 
	jne		shr_div_loop
	jmp 	shr_loop

end_of_shr:
	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1

	mov 	ebx, [ptr_prev_stack]					;; remove nodes that are with 0 value from MSB to LSB
	mov 	ecx, [ebx]

go_to_last_node:
	cmp 	dword [ecx + 5], 0
	je 		check_value
	mov 	ecx, [ecx + 5]
	jmp 	go_to_last_node

check_value:
	cmp 	byte [ecx], 0
	je 		maybe_delete_zero
	jmp		last_check

maybe_delete_zero:
	cmp 	dword [ecx + 1], 0
	je 		last_check
	mov 	ecx, [ecx + 1]
	jmp 	check_value

last_check:
	mov 	dword [ecx + 5], 0

finish_right_shift:
	add 	dword[op_count], 1

	mov 	esp, ebp					;return to main
	pop 	ebp
	ret		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; shift_left ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

shift_left:
	push 	ebp
	mov 	ebp, esp
	cmp		byte [counter_of_nums], 2
	jb 		error2
	mov 	ebx, [ptr_prev_stack]
	mov 	edx, [ebx]
	mov		byte [k_counter], 0

shl_find_length:
	mov 	edx, [edx + 5]
	cmp 	dword edx, 0
	je 		shl_loop_first
	jmp  	error3

shl_loop_first:
	mov 	edx, [ebx]
	mov 	dl, byte [edx]
	shr 	dl, 4
	times 10 add 	byte [k_counter], dl
	mov 	edx, [ebx]
	mov 	dl, byte [edx]
	shl 	dl, 4
	shr 	dl, 4
	add 	byte [k_counter], dl

shl_loop:
	cmp 	byte [k_counter], 0
	je		end_of_shl
	sub 	byte [k_counter], 1
	mov 	ebx, [ptr_prev_stack]
	mov		ecx, [ebx - 4]
	mov 	esi, [ebx - 4]
	clc

shl_sum_loop:
	mov 	al, byte [ecx]
	adc 	al, byte [ecx]
	daa

	mov		byte [ecx], al
	mov 	ecx, [ecx + 5]
	pushf
	cmp 	ecx, 0
	je 		shl_check_carry_first
	popf
	jmp 	shl_sum_loop

shl_check_carry_first:
	popf

shl_check_carry:
	pushf
	jnc		shl_loop
	cmp 	ecx, 0
	je 		shl_build_node
	popf
	mov 	al, byte [ecx]
	adc 	al, 0
	daa
	mov 	byte [ecx], al
	jmp		shl_check_carry

shl_build_node:
	pushad
	push 	9
	call 	malloc
	add 	esp, 4
	mov		[new_node], eax
	popad

	mov 	ebx, dword [new_node]
	mov 	byte [ebx], 1

shl_go_to_last:
	mov 	ecx, esi
	cmp 	dword [ecx + 5], 0
	je 		shl_conncect_carry

shl_go_loop:
	mov 	ecx, [ecx + 5]
	cmp 	dword [ecx + 5], 0
	jne 	shl_go_loop	

shl_conncect_carry:
	mov 	[ebx + 1], ecx
	mov 	[ecx + 5], ebx
	mov 	dword [ebx + 5], 0

	jmp		shl_loop

end_of_shl:
	sub 	dword [ptr_prev_stack], 4
	sub 	dword [ptr_curr_stack], 4
	sub 	byte [counter_of_nums], 1
	add 	dword[op_count], 1
	
	mov 	esp, ebp					;return to main
	pop 	ebp
	ret		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; error ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

increase_op_count:
	add 	dword [op_count], 1
	mov 	esp, ebp					;return to main
	pop 	ebp
	ret	
	
error1:
	mov 	ecx, error_message1
	jmp 	print_error
error2:
	mov 	ecx, error_message2
	jmp 	print_error
error3:
	mov 	ecx, error_message3
	jmp 	print_error
error4:
	mov 	ecx, error_message4
	jmp 	print_error
print_error:
	pushad
	push 	ecx
	push 	format_string
	call	printf
	add 	esp, 8
	popad

	mov 	dword [success], 0

	mov 	esp, ebp					;return to main
	pop 	ebp
	ret	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; printd ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printd:
	mov 	eax, [ptr_prev_stack]
	mov 	ebx, [eax]

	cmp 	dword [ebx + 5], 0
	je 		sole_link_printd

final_link_loop_printd:
	mov 	ebx, [ebx + 5]
	cmp 	dword [ebx + 5], 0
	jne 	final_link_loop_printd	
	mov 	eax, ebx

;;;; print 
	mov 	ecx, 0
	mov 	cl, byte [ebx]

	pushad
	push 	ecx
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	cmp 	dword [ebx + 1], 0
	je 		read

print_loop_printd:
	mov 	ebx, [ebx + 1]
	mov 	ecx, 0
	mov 	cl, byte [ebx]

	cmp 	cl, 0								;;check fo 00 situation
	je 		situation_zero_printd

	cmp 	cl, 9
	jbe		one_digit_printd

	pushad
	push 	ecx
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	cmp 	dword [ebx + 1], 0
	jne 	print_loop_printd

	pushad
	push 	newline
	push 	dword [stderr]
	call	fprintf
	add 	esp, 8
	popad

	jmp 	read

one_digit_printd:
	mov 	esi, 0

	pushad
	push 	esi
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	pushad
	push 	ecx
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	cmp 	dword [ebx + 1], 0
	jne 	print_loop_printd

	pushad
	push 	newline
	push 	dword [stderr]
	call	fprintf
	add 	esp, 8
	popad

	jmp 	read


situation_zero_printd:
	pushad
	push 	ecx
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	pushad
	push 	ecx
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	cmp 	dword [ebx + 1], 0
	jne 	print_loop_printd

	pushad
	push 	newline
	push 	dword [stderr]
	call	fprintf
	add 	esp, 8
	popad

	jmp 	read

sole_link_printd:
	mov 	ecx, 0
	mov 	cl, byte [ebx]

	pushad
	push 	ecx
	push 	format_hex
	push 	dword [stderr]
	call	fprintf
	add 	esp, 12
	popad

	pushad
	push 	newline
	push 	dword [stderr]
	call	fprintf
	add 	esp, 8
	popad

	jmp 	read
