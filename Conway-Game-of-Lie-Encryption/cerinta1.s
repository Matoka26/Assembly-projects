.data
	matrix:		.space 1600
	matrixAux:	.space 1600
	message:	.space 1600
	key:		.space 1600
	password:	.space 200
	out_cript:	.space 1600
	letter:		.space 1
	columnIndex: 	.space 4
	lineIndex: 	.space 4
	n: 		.space 4
	m:		.space 4
	k:		.space 4
	nMinusOne:	.space 4
	mMinusOne:	.space 4
	nrCeluleVii: 	.space 4
	index: 		.space 4
	left: 		.space 4
	right: 		.space 4
	criptare:	.space 4
	zerox:		.asciz "0x"
	formatScanf: 	.asciz "%ld"
	formatScanfChar:.asciz "%c"
	formatScanfStr: .asciz "%s"
	formatPrintfStr:.asciz "%s\n"
	formatPrintf: 	.asciz "%ld "
	formatPrintfX:	.asciz "%x"
	formatPrintfChar:.asciz "%c"
	newLine: 	.asciz "\n"

.text

xor_arrays:
# This function will take 2 arrays of 0's and 1's and their respective 
# length and xor the two
#
# If the second one is shorter than the first one,it will  be concatenated
# with itself until its at least the same size as the first one
#
#	str1 = 0111010011100101101
#	str2 = 0101
#
# =>
#	str1 = 0111010011100101101
#	str2 = 01010101010101010101
#	res  = 0010000110110000111
#
# If the first one is shorter, it will just xor with the coresponding element 
#
#	str1 = 0100110
#	str2 = 0110101001
#	res  = 0010011
#
# If they are the same size just xor each coresponding element
#
#	str1 = 11010010010101
#	str2 = 01000101010011
#	res  = 10010111000110
	
	# Prepare the stack frame
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%edi

	# 24(%ebp) ~ message array
	# 20(%ebp) ~ key array
	# 16(%ebo) ~ result
	# 12(%ebp) ~ m(message size) 
	#  8(%ebp) ~ n(key size)

	subl	$4, %esp
	# -16(%ebp) ~ i

	movl	24(%ebp), %edi
	movl	20(%ebp), %esi
	
	# cnt = 0	
	movl $0, -16(%ebp)
	for_xor:
		# if cnt > m	
		movl	 -16(%ebp), %ecx
		cmp	12(%ebp), %ecx
		je	end_xor_arrays
		
		# %eax =  message[index]
		movl	(%edi, %ecx, 4), %eax
	pushl %ecx
	pushl %eax
		# %ebx = key[index % n]
		movl	%ecx, %eax
		xorl	%edx, %edx
		divl	8(%ebp)
		movl	(%esi, %edx, 4), %ebx
	popl %eax
		# %eax = %eax XOR %ebx
		xorl	%ebx, %eax
	popl %ecx
		# result[index] = %eax
		movl	16(%ebp), %ebx
		movl	%eax, (%ebx, %ecx, 4)
		
		# cnt++
		incl	-16(%ebp)
		jmp for_xor
	

	end_xor_arrays:
	# Clear the stack frame
	addl	$4, %esp

	popl	%esi
	popl	%edi
	popl	%ebx
	popl	%ebp
	ret

count_neighbours:
# This function takes a matrix and it's number of rows and 2 indices 
# and return the number of adjacent 1's of that cell in %eax

	
	# Prepare the stack frame
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	
	# Make room for variables
	subl	$4, %esp
	# -16(%ebp) ~ cnt => counter of neighbours	
	
	# the matrix:
	#	20(%ebp)
	# the nr of lines:
	#	16(%ebp) ~ n
	# the coords:
	# 	12(%ebp) ~ i
	# 	8(%ebp) ~ j
	
	# %edi = the matrix
	movl	20(%ebp), %edi
	# cnt = 0
	movl	$0, -16(%ebp)	

	#NEIGHBOURS
	left_neighbour:

		# %eax = n*i + j-1  
		movl	16(%ebp), %eax
		xorl	%edx, %edx
		mull	12(%ebp)
		subl	$1, 8(%ebp)
		addl 	8(%ebp), %eax
		addl	$1, 8(%ebp)	

		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne right_neighbour
		
		incl	-16(%ebp)

	right_neighbour:
		# %eax = n*i + j+1		
		addl	$2, %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne up_right_neighbour
		
		incl	-16(%ebp)
	
	up_right_neighbour:
		# %eax = n*(i-1) + j+1	
		subl	16(%ebp), %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne up_neighbour

		incl	-16(%ebp)
	up_neighbour:
		# %eax = n*(i-1) + j
		subl	$1, %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne up_left_neighbour

		incl	-16(%ebp)

	up_left_neighbour:
		# %eax = n*(i-1) + j-1
		subl	$1, %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne down_left_neighbour

		incl	-16(%ebp)

	down_left_neighbour:
		# %eax = n*(i+1) + j-1
		addl	16(%ebp), %eax
		addl	16(%ebp), %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne down_neighbour

		incl	-16(%ebp)
		
	down_neighbour:
		# %eax = n*(i+1) + j
		addl	$1, %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne down_right_neighbour

		incl	-16(%ebp)
	
	down_right_neighbour:
		# %eax = n*(i+1) + j+1		
		addl	$1, %eax
		movl	(%edi, %eax, 4), %ecx
		cmp	$1, %ecx
		jne	cnt_exit
		
		incl	-16(%ebp)

	# Return value in %eax
	cnt_exit:
		movl	-16(%ebp), %eax

	# Clean stack frame
	addl	$4, %esp	

	popl	%esi
	popl	%edi
	popl	%ebx
	popl	%ebp
	ret


evolution:
# The function will simulate a generation of the game
# based on the state of each cell(1-alive, 0-dead)
#
# FROM:	   	      1				    0
#	  <2 OR >3   / \   2 OR 3             3    / \  else	
#	 neighbours /	\ neighbours	neigbours /   \ 
# TO:		   0	 1			 1     0
#
#
# It will take 2 matrices of the same size n * m and based
# on the cells of the first one, the second one will
# become it's evolution based on the rules above 
#
# NOTE:
#	The matrices are assumed to be extented with a layer of 0

	# Prepare the stack frame
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi

	# Make room for 2 variables
	subl	$16, %esp
	# -16(%ebp) ~ i
	# -20(%ebp) ~ j
	# -24(%ebp) ~ n-1
	# -28(%ebp) ~ cnt	

	# %esi = address of sourse matrix
	# %edi = address of the destination matrix
	movl	16(%ebp), %esi
	movl	20(%ebp), %edi
	# 8(%ebp) ~ m
	#12(%ebp) ~ n 
	
	movl	12(%ebp), %ecx
	decl	%ecx
	movl	%ecx, -24(%ebp)

	# i = 1
	movl	$1, -16(%ebp)
	evolution_for_i:
		# if i == n exit
		movl	-16(%ebp), %ecx
		cmp	%ecx, -24(%ebp)
		je out_evolution_for_i
		
		# j = 1
		movl	$1, -20(%ebp)
		evolution_for_j:
			# if j == m
			movl	-20(%ebp), %ecx
			cmp	%ecx, 12(%ebp)
			je out_evolution_for_j
		
			pushl	%edi		#matrix
			pushl	12(%ebp)	#n
			pushl	-16(%ebp)	#i
			pushl	-20(%ebp)	#j
			call count_neighbours
			popl	%ebx
			popl	%ebx
			popl	%ebx
			popl	%ebx

			# cnt = the value of the function
			movl	%eax, -28(%ebp)	

			movl	12(%ebp), %eax
			xorl	%edx, %edx
			mull	-16(%ebp)
			addl	-20(%ebp), %eax
			movl	(%edi, %eax, 4), %ecx
		
			# %edx = cnt	
			movl	-28(%ebp), %edx
			# If matrix[i][j] = 0 (is dead)								   
			cmp	$1, %ecx
			je	is_alive
			
			#else
				is_dead:
					# if cnt = 3
					cmp	$3, %edx
					je goes_alive				
					#else
					jmp goes_dead			

				is_alive:
					#if cnt == 2 || cnt == 3
					cmp	$2, %edx
					je goes_alive
					cmp	$3, %edx
					je goes_alive
					#else
					jmp goes_dead

			# update with 1
			goes_alive:
				movl	$1, (%esi, %eax, 4)
				jmp next
			# update with 0
			goes_dead:
				movl	$0, (%esi, %eax, 4)
				jmp next
			next:
			# j++	
			addl	$1, -20(%ebp)
			jmp evolution_for_j

		out_evolution_for_j:
		# i++
	

		addl	$1, -16(%ebp)
		jmp evolution_for_i

	out_evolution_for_i:
	# Clean the stack frame
	addl	$16, %esp

	popl	%esi
	popl	%edi
	popl	%ebx
	popl	%ebp
	ret

copy_matrix:
# The function will take 2 matrices of the same number of elements n 
# and copy the content of the first one into the second one

	# Prepare the stack frame
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	
	# %edi = address of sourse matrix
	# %esi = address of the destination matrix
	movl	12(%ebp), %edi
	movl	16(%ebp), %esi
	# 8(%ebp) ~ n

	# %eax = n  
	movl	8(%ebp), %eax
	# %ecx = 0
	xorl	%ecx, %ecx
	for_copy:
		# if n == i exit
		cmp	%ecx, %eax	
		je end_copy
	
		movl	(%esi, %ecx, 4), %edx
		movl	%edx, (%edi, %ecx, 4)

		# i++
		incl	%ecx
		jmp for_copy

	end_copy:

	# Clean the stack frame
	
	popl	%esi
	popl	%edi
	popl	%ebx
	popl	%ebp
	ret

.global main

# Step 1:
#	If we have a matrix like
#		0 1 1 0
#		1 0 0 0
#		0 0 1 1
#	
#	We'll extend the matrix with a line and a column
#	 for an easier check of neighbours and will look:
#	      0 0 0 0 0 0
#	      0 0 1 1 0 0 		
#	      0 1 0 0 0 0 	
#	      0 0 0 1 1 0
#	      0 0 0 0 0 0
#
# Step 2:
#	Make the evolution on a second matrix
#	      0 0 0 0 0 0	0 0 0 0 0 0 
#	      0 0 1 1 0 0 	0 0 1 0 0 0	
#	      0 1 0 0 0 0  ==> 	0 0 0 0 1 0 
#	      0 0 0 1 1 0 	0 0 0 0 0 0 
#	      0 0 0 0 0 0	0 0 0 0 0 0
#
# Step 3:
#	Copy the second matrix into the original
#
#	     0 0 0 0 0 0	0 0 0 0 0 0
#	     0 0 1 0 0 0	0 0 1 0 0 0
#	     0 0 0 0 1 0 <-     0 0 0 0 1 0
#	     0 0 0 0 0 0	0 0 0 0 0 0
#	     0 0 0 0 0 0 	0 0 0 0 0 0
#
# Step 4:
#	*Repeat 2-3 K times
#
# Step 5:
#	Make the matrix a vector
#
#	    0 0 0 0 0 0 
#	    0 0 1 0 0 0
#  	    0 0 0 0 1 0  ==> 0 0 0 0 0 0 0 0 1 0 0... (you got the point)
#	    0 0 0 0 0 0
#	    0 0 0 0 0 0
#	(Yes, i had to do that,i cant really tell why i didnt work if i just took the matrix)
#
# Step 6:
#	Cript/Decript  the message:
#		Cript:	
#			Take a string and transform to ascii:
#			
#			  "parola" ->  01110000 01100001 ...
#		Decript:
#
#			Take a number in hex and make it base2
#			  "0x2A10" -> 0010 1010 0001 0000 
#
# Step 7:
#	Xor with the key:
#	 If the message was cripted or not
#	 XOR  with the key will take it to the other state	
#
# Step 8:
#	Decript/Cript the message:
#		Cript:
#			Convert from an array of 1's and 0's
#			 to a hex representation 
#		  	  (picking groups of 4 from left to right)
#
#		Decript:
#			Convert from an array of 1's and 0's
#			 to char's representation
#			  (picking groups of 8 from left to right)

main:
	# Read n
	pushl 	$n
	pushl	$formatScanf
	call scanf
	popl 	%ebx
	popl 	%ebx

	# Read m
	pushl 	$m
	pushl 	$formatScanf
	call scanf
	popl 	%ebx
	popl 	%ebx

	# Extend the matrix with 2 lines and columns
	addl	$2, m	
	addl 	$2, n

	# Read number of cells
	pushl 	$nrCeluleVii
	pushl 	$formatScanf
	call scanf
	popl 	%ebx
	popl	%ebx

	
	# Populate the matrix
	movl	$0, index
	for_nr_celule_vii:
	
		movl	index, %ecx
		cmp	%ecx, nrCeluleVii
		je done_reading_cells
		
		# Read line of the cell
		pushl 	$left
		pushl 	$formatScanf
		call scanf
		popl 	%ebx
		popl 	%ebx
		
		# Read column of the cell
		pushl 	$right
		pushl 	$formatScanf
		call scanf
		popl 	%ebx
		popl 	%ebx

		# Shift everything right and down once
		addl	$1, right
		addl	$1, left
		
		#eax = i*n + j
		movl 	left, %eax
		xorl 	%edx, %edx
		mull 	n
		addl 	right, %eax
		
		# Take address of the matrix
		lea	matrix, %edi
		
		# matrix[i][j] = 1		
		movl 	$1, (%edi, %eax, 4)
		
		# index++
		incl	index	
		# Jump back to the for loop
		jmp for_nr_celule_vii
	
	done_reading_cells:
	
	# Read k
	pushl 	$k
	pushl 	$formatScanf
	call scanf
	popl 	%ebx
	popl 	%ebx		
	
####################################################	
# Step 4(Start)
	# i = 0
	movl	$0, index
	for_k_generations:
		
		# if i == k exit
		movl	index, %ecx
		cmp	%ecx, k
		je done_k_generations		

###################################################
# Step 2	 
	
	# matrixAux = nextGeneration of matrix
	pusha
		pushl	$matrix	
		pushl	$matrixAux
		pushl	n
		pushl	m
		call evolution
		popl	%ebx
		popl	%ebx
		popl	%ebx
	popa
	
###################################################
# Step 3	
	pusha
		# Get the number of elements of the matrix
		movl	n, %eax
		xorl	%edx, %edx
		mull	m	
	
		# matrix = matrixAux
		pushl	$matrixAux		
		pushl	$matrix
		pushl	%eax
		call copy_matrix
		popl	%ebx
		popl	%ebx
		popl	%ebx
	popa
							
		# i++
		incl	index
		jmp for_k_generations

	
	done_k_generations:

#################################################
# Step 5
	movl	$0, right	
	liniar_matrix:
		# i = 0
		movl 	$0, lineIndex
		for_lines:
		
			# if i == n exit
			movl 	lineIndex, %ecx
			cmp 	%ecx, n
			je i_cant_take_it_anymore
			
			# j = 0
			movl 	$0, columnIndex
			for_columns:
				
				#if j == m print newline
				movl 	columnIndex, %ecx
				cmp 	%ecx, m
				je cont
				
				#eax = i*n + j
				movl 	lineIndex, %eax
				movl 	$0, %edx
				mull 	n
				addl 	columnIndex, %eax
				
				# Take address of the matrix
				#lea 	matrix, %edi
				lea	matrix, %edi
				lea	key, %esi
				# key[right] = matrix[i][j]
				
				movl 	(%edi, %eax, 4), %ebx
				movl	right, %ecx					
				movl	%ebx, (%esi, %ecx, 4)
				incl right	

				
				# j++
				incl 	columnIndex
				jmp for_columns

	#Prints a newline at the end of a row
	cont:		
		#i++
		incl 	lineIndex
		jmp for_lines

	i_cant_take_it_anymore:

	movl	n, %eax
	xorl	%edx, %edx
	mull	m
	movl	%eax, n
	#AT THIS POINT n HAS THE LENGTH OF THE KEY


#############################################
# Step 6
	# this one will decide if we cript or decript a message
	pushl	$criptare
	pushl	$formatScanf
	call scanf
	popl	%ebx
	popl	%ebx

	#if it's 0 we cript
	movl	criptare, %ecx
	cmp	$1, %ecx
	je	decript
	
cript:
	# Read the message as a string
	pushl	$password
	pushl	$formatScanfStr
	call scanf
	popl	%ebx
	popl	%ebx

	
	# While meesajge[cnt] != '\0' 
	movl	$0, m
	lea	message, %esi
	lea	password, %edi
	for_letter:
		# The letter is in %al
		movl	m, %ecx
		movb	(%edi, %ecx, 1), %al
		cmp	$0, %al
		je	out_for_read_message				

		# For each bit of the letter check if it's 1 or 0
		# to append to the message array		
		
		# index = 0
		movl	$0, index
		for_8_bits:
			movl	index, %ecx
			cmp	$8, %ecx
			je out_for_8_bits


			#delete the first bit
			movzx	%al, %edx		
			shl 	$1, %al
			shr 	$1, %al	
			movzx	%al, %ebx
		
			# Calculate the next index of message
		pusha
			movl	$8, %ecx
			movl	m, %eax
			xorl	%edx, %edx
			mull	%ecx
			addl	index, %eax
			#left will keep the value of the index for a little 
			movl	%eax, left
		popa		
			#if they re the same,the bit was 0
			cmp	%ebx, %edx
			je was_0
		
			#else
			was_1:
				movl	left, %edx
				movl	$1, (%esi, %edx, 4)
				jmp next_for_8_bits
				
			was_0:
				movl	left, %edx
				movl	$0, (%esi, %edx, 4)
				jmp next_for_8_bits

			next_for_8_bits:
				shl	$1, %al
			
			#index++
			incl	index
			jmp for_8_bits	
		out_for_8_bits:
		# cnt++
		incl	m
		jmp for_letter
	
out_for_read_message:
########################################3
# Step 7
	#AT THIS POINT m HAS THE LENGTH OF THE MESSAGE
	movl	%ecx, %eax
	xorl	%edx, %edx
	movl	$8, %ecx
	mul	%ecx
	movl	%eax, m

	
	pushl	$message
	pushl	$key
	pushl	$out_cript
	pushl	m
	pushl	n
	call xor_arrays
	popl	%ebx
	popl	%ebx
	popl	%ebx
	popl	%ebx
	popl	%ebx

########################################################
# Step 8

	# transform each set of 4 bits of out_cript into hex coresp
	# the output will have m/4 letters

	mov	$4, %eax
	mov	$1, %ebx
	mov	$zerox, %ecx
	mov	$3, %edx
	int	$0x80

	# m = m / 4
	movl	m, %eax
	xorl	%edx, %edx
	movl	$4, %ecx
	divl	%ecx
	movl	%eax, m

	lea	out_cript, %edi
	# for(i = 0 ; i < m ; i++)
	movl	$0, index
	for_build_number:
		movl	index, %ecx
		cmp	m, %ecx
		je exit

		# k will be each 4bits converted in decimal
		movl	$0, k
		# we need groups of 4biti from out_cript
		xorl	%ecx, %ecx
		for_4_bits_out_cript:
			cmp	$4, %ecx
			je out_4_bits

			# k << ecx
			shll	$1, k

			# k += out_script[index*4 + ecx]				
			movl	$4, %ebx
			movl	index, %eax
			xorl	%edx, %edx
			mull	%ebx
			addl	%ecx, %eax

			movl	(%edi, %eax, 4), %eax
			
			addl	%eax, k
	
			incl	%ecx

			jmp for_4_bits_out_cript
		out_4_bits:
			
	pusha	
		addl	$48, k
		movl	k, %ecx
		cmp	$57, %ecx
		jle ok_hexa

		addl	$7, k

		ok_hexa: 
		push	k
		push	$formatPrintfChar
		call printf
		popl	%ebx
		popl	%ebx
	popa

		incl	index
		jmp for_build_number	
	
#################
decript:
	#The message will be read char by char
	# Read an empty line
	pushl	$letter
	pushl	$formatScanfChar
	call scanf
	popl	%ebx
	popl	%ebx
	# Read the 0
	pushl	$letter
	pushl	$letter
	pushl	$formatScanfChar
	call scanf
	popl	%ebx
	popl	%ebx
	#Read the x
	pushl	$formatScanfChar
	call scanf
	popl	%ebx
	popl	%ebx

	# Read the actuall message
	pushl	$password
	pushl	$formatScanfStr
	call scanf
	popl	%ebx
	popl	%ebx

	# index will iterate over message and fill with the 
	# bits from the password, it will step 4 cells,fill them 
	# from right to left and jump 7 more for each letter of
	# the password
	movl	$3, index	
	# m will hold the size of the message
	movl	$0, m
	lea	message, %esi
	lea 	password, %edi
	for_read_password:
		# THe letter is in %al
		movl	m, %ecx	
		movb	(%edi, %ecx, 1), %al
		cmp	$0, %al
		je done_convert_password

		# letter -'0' to convert to decimal
		movzx	%al, %eax
		subl	$48, %eax
	
		# if the letter is > 0 it must be converted again 
		cmp	$10, %eax
		jl no_more_convert

		subl	$7, %eax

		no_more_convert:
		# At this point we have the values in decimal
		# Now we go decimal => binary on 4bits algorithm
		
		# for k = 0 ; k < 4 ; j++
		movl	$0, k
		for_decimal_to_binary:
			movl	k, %ecx
			cmp	$4, %ecx
			je next_for_read_password			
			
			# nr = nr / 2, we save the reminder in message[index]
			xorl	%edx, %edx
			movl	$2, %ebx
			divl	%ebx
			movl	index,	%ecx	
			movl	%edx, (%esi, %ecx, 4)

			decl	index
			incl	k		
			jmp for_decimal_to_binary

		next_for_read_password:
	
		
		addl	$8, index
		incl	m
		jmp for_read_password
	
done_convert_password:
	# Update the size of m
	movl	$4, %eax
	xorl	%edx, %edx
	mull	m
	movl	%eax, m
			
	pushl	$message
	pushl	$key
	pushl	$out_cript
	pushl	m
	pushl	n
	call xor_arrays
	popl	%ebx
	popl	%ebx
	popl	%ebx
	popl	%ebx
	popl	%ebx

	
	# Convert from binary to ascii
		
	movl	m, %eax
	xorl	%edx, %edx
	movl	$8, %ecx
	divl	%ecx
	movl	%eax, m

	movl	$0, index
	lea	out_cript, %edi
	for_binary_to_ascii:
		movl	index, %ecx
		cmp	m, %ecx
		je exit

		movl	$0, right
		movl	$0, letter
		for_8_bits_b_to_a:
			movl	right, %ecx
			cmp	$8, %ecx
			je next_for_binary_to_ascii
	
			shlb	$1, letter
		
			movl	$8, %eax
			xorl	%edx, %edx
			mull	index
			addl	right, %eax
	
			movl	(%edi, %eax, 4), %ecx

			add	%ecx, letter

			incl	right
			jmp for_8_bits_b_to_a
		
		next_for_binary_to_ascii:
	
		pushl	letter
		pushl	$formatPrintfChar
		call printf
		popl	%ebx
		popl	%ebx

		incl	index
		jmp for_binary_to_ascii
	
exit:

	pushl	$0
	call fflush
	popl	%ebx
	
	mov	$4, %eax
	mov	$1, %ebx
	mov	$newLine,%ecx
	mov	$2, %edx
	int	$0x80
	
	movl 	$1, %eax
	movl 	$0, %ebx
	int 	$0x80
	
