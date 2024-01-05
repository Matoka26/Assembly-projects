.data
	matrix: 	.space 1600
	matrixAux:	.space 1600
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
	formatScanf: 	.asciz "%ld"
	formatPrintf: 	.asciz "%ld "
	newLine: 	.asciz "\n"

.text

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

	# CLean stack frame
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
#	Print the inner matrix
#		0 1 0 0
#		0 0 0 1
#		0 0 0 0
#	


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


###################################################
# Step 5
	movl	n, %eax
	decl	%eax
	movl	%eax, nMinusOne

	movl	m, %eax
	decl	%eax
	movl	%eax, mMinusOne
	print_matrix:
		# i = 0
		movl 	$1, lineIndex
		for_lines:
		
			# if i == n exit
			movl 	lineIndex, %ecx
			cmp 	%ecx, nMinusOne
			je exit
			
			# j = 0
			movl 	$1, columnIndex
			for_columns:
				
				#if j == m print newline
				movl 	columnIndex, %ecx
				cmp 	%ecx, mMinusOne
				je cont
				
				#eax = i*n + j
				movl 	lineIndex, %eax
				movl 	$0, %edx
				mull 	n
				addl 	columnIndex, %eax
				
				# Take address of the matrix
				#lea 	matrix, %edi
				lea	matrix, %edi
				# ebx = matrix[i][j]
				movl 	(%edi, %eax, 4), %ebx
				
				# Print the element
				pushl 	%ebx
				pushl 	$formatPrintf
				call printf
				popl 	%ebx
				popl 	%ebx

				# Empty buffer
				pushl 	$0
				call fflush
				popl 	%ebx
				
				# j++
				incl 	columnIndex
				jmp for_columns

	#Prints a newline at the end of a row
	cont:		
		movl 	$4, %eax
		movl 	$1, %ebx
		movl 	$newLine, %ecx
		movl 	$2, %edx
		int 	$0x80
		
		#i++
		incl 	lineIndex
		jmp for_lines


exit:
	movl 	$1, %eax
	movl 	$0, %ebx
	int 	$0x80
	
