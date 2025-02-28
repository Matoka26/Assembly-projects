.data
	matrix:			.space 1048576
	n:			.space 4
	i:			.space 4
	j:			.space 4
	k:			.space 4
	operation:		.space 1
	noOperations:		.space 4

	noAdds:			.space 4
	countContigousZeros:	.space 4
	startIndexI:		.space 4
	startIndexJ:		.space 4
	endIndexJ:		.space 4


	fileDescriptor:		.space 4
	fileSize:		.space 4
	pagesNeeded:		.space 4	


	addFp:			.asciz "%d:  ((%d, %d), (%d, %d))\n"
	formatPrintf:		.asciz "%d "	
	formatScanfLD:		.asciz "%ld"
	formatScanfB:		.asciz "%d"
	newLine:		.asciz "\n"
.text

print_memory:
	# Prepare the stack frame
        pushl   %ebp
        movl    %esp, %ebp
        pushl   %ebx
        pushl   %edi
        pushl   %esi

	subl	$12, %esp
	# -16(%ebp) i
	# -20(%ebp) j
	# -24(%ebp) fs	

	movl	$0, -20(%ebp)
	movl	$0, -16(%ebp)
	for_pr_mem_i: 
		movl	-16(%ebp), %ecx
		cmp	n, %ecx
		je out_for_pr_mem_i		


		movl	$0, -20(%ebp)
		for_pr_mem_j:
			movl	-20(%ebp), %ecx
			cmp	n, %ecx
			je out_for_pr_mem_j
				
			# if matrix[i,j] ==0
			if_smth:				
				lea	matrix, %esi
				movl	-16(%ebp), %eax
				xorl	%edx, %edx
				movl	n, %ecx
				mull	%ecx
				addl	-20(%ebp), %eax
				movzbl	(%esi, %eax, 1), %eax				

				cmp	$0, %eax
				je out_if
			
				movl	%eax, -24(%ebp)

				movl	-16(%ebp), %eax
				movl	%eax, startIndexI
				movl	-20(%ebp), %eax
				movl	%eax, startIndexJ
				movl	%eax, endIndexJ
				
			
				while_smth:
					# if endJ == n 
					movl	n, %eax
					cmp	endIndexJ, %eax
					je out_while
					
					# if matrix[i, endJ] != matrix[i,j]
					lea 	matrix, %esi
					movl	-16(%ebp), %eax
					movl	n, %ecx
					xorl	%edx, %edx
					mull	%ecx
					pushl	%eax
					addl	-20(%ebp), %eax
					movzbl	(%esi, %eax, 1), %ecx
					
					popl	%eax
					addl	endIndexJ, %eax
					movzbl	(%esi, %eax, 1), %eax				
	
					cmp	%eax, %ecx
					jne	out_while
						

					incl	endIndexJ
					jmp while_smth			

				out_while:
			
			pushl endIndexJ
				decl endIndexJ

				pushl	endIndexJ
				pushl	startIndexI
				pushl	startIndexJ
				pushl	startIndexI
				pushl	-24(%ebp)
				pushl	$addFp
				call printf		
				popl	%ebx
				popl	%ebx
				popl	%ebx
				popl	%ebx
				popl	%ebx
				popl	%ebx
			popl endIndexJ

				decl	endIndexJ
				movl	endIndexJ, %eax
				movl	%eax,	-20(%ebp)
			out_if:
	
			incl	-20(%ebp)
			jmp for_pr_mem_j
		out_for_pr_mem_j:
		incl	-16(%ebp)
		jmp for_pr_mem_i
	out_for_pr_mem_i:

        # clean up
        addl    $12 , %esp
        popl    %esi
        popl    %edi
        popl    %ebx
        popl    %ebp
        ret



print_matrix:
# This function will print the matrix in a nice shape
	
	# Prepare the stack frame
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	
	# Make room for variables
	subl	$8, %esp
	# -16(%ebp) ~ i
	# -20(%ebp) ~ j
	
	# i = 0; j = 0
	movl	$0, -16(%ebp)
	movl	$0, -20(%ebp)


	for_i:

		# if i == n
		movl	-16(%ebp), %ecx
		cmp		n, %ecx
		je	out_print_matrix
	
		
		for_j:
			# if j == n
			movl	-20(%ebp), %ecx
			cmp		n, %ecx
			je	out_for_i

	
			# eax = i*n + j
			movl	-16(%ebp), %eax
			xorl	%edx, %edx
			movl	n, %ebx
			mull	%ebx
			addl	-20(%ebp), %eax
			
			lea		matrix, %esi
			movzbl		(%esi, %eax, 1), %ebx
			

			pushl	%ebx
			pushl	$formatPrintf
			call printf
			popl	%ebx
			popl	%ebx
			
			pushl	$0 
			call fflush
			popl	%ebx
			
			
			# j++
			incl	-20(%ebp)
			jmp	for_j

		out_for_i:
		
		# i++
		incl	-16(%ebp)
		
		# j = 0
		movl	$0, -20(%ebp)
		
		# print \n
		movl	$4 , %eax
		movl	$1 , %ebx
		movl	$newLine , %ecx
		movl	$1  , %edx
		int	$0x80
		
		jmp	for_i
		
		

	out_print_matrix:
	# clean up
	addl	$8 , %esp
	popl	%esi
	popl	%edi	
	popl	%ebx
	popl	%ebp
	ret	
	

.global main
main:    				
	movl	$1024, n

	pushl	$noOperations
	pushl	$formatScanfLD
	call scanf
	popl	%ebx
	popl	%ebx
	
	
	loop_operations:
		movl	noOperations, %ecx
		cmp	$0, %ecx		
		je	exit
		
	pushl	$operation
	pushl	$formatScanfLD
	call scanf
	popl	%ebx
	popl	%ebx

	movl	operation, %ecx
	cmp	$1, %ecx
	je  add
	
	cmp	$2, %ecx
	je get

	cmp	$3, %ecx
	je delete

	cmp	$4, %ecx
	je defragmentation

	jmp exit 


add:
	pushl	$noAdds
	pushl	$formatScanfB
	call scanf
	popl	%ebx
	popl	%ebx

	for_adds:
		movl	noAdds, %ecx
		cmp	$0, %ecx
		je	done_adds		

		# read file descriptor for an entry
		pushl	$fileDescriptor
		pushl	$formatScanfB
		call scanf
		popl	%ebx
		popl	%ebx

		# read file size
		pushl	$fileSize
		pushl	$formatScanfLD
		call scanf
		popl	%ebx
		popl	%ebx

		# needeed_pages = fileSize / 8
		xorl	%edx, %edx
		movl	fileSize, %eax
		movl	$8, %ecx
		divl	%ecx

		# if remainer of filerSize/8 !=0
		
		cmp	$0, %edx
		je	skip_internal_fragm	

		# needed_pages ++
		incl	%eax	

		skip_internal_fragm:
		movl	%eax, pagesNeeded
		

		# Find a hole
		movl	$0, i
		movl	$0, j
		add_for_i:
			# count = 0
			movl	$0, countContigousZeros
			
			# if i == n exit
			movl	i, %ecx
			cmp	n, %ecx
			je failed_add
			
			# j = 0
			movl	$0, j
			add_for_j:
				# if j == n exit
				movl	j, %ecx
				cmp	n, %ecx
				je out_add_for_j	

		
				lea	matrix, %esi
				xorl	%edx, %edx
				movl	i, %eax
				movl	n, %ecx
				mull	%ecx
				addl	j, %eax			
				movzbl	(%esi, %eax, 1), %ebx

				# if matrix[i,j] == 0, count++ else count=0
				cmp	$0, %ebx
				je skip_count_zero
				
				movl	$-1, countContigousZeros	
				skip_count_zero:
				incl	countContigousZeros


				# if count == 1, position = i,j
				movl	countContigousZeros, %ecx
				cmp	$1, %ecx
				jne skip_index

				movl	i, %ebx
				movl	%ebx, startIndexI
				movl	j, %ebx
				movl	%ebx, startIndexJ

				skip_index:		

				# if count == neededPages exit
				movl	countContigousZeros, %ecx
				cmp	pagesNeeded, %ecx
				je out_add_for_i

				## j++
				incl	j
				jmp add_for_j
						
			out_add_for_j:

			# i++
			incl	i
			jmp add_for_i
		out_add_for_i:

		# write the pages
		movl	$0, i
		lea 	matrix, %esi
		movl	startIndexI, %eax
		xorl	%edx, %edx
		movl	n, %ecx
		mull 	%ecx
		addl	startIndexJ, %eax
		for_write_page:
			movl	i, %ecx
			cmp	pagesNeeded, %ecx
			je out_for_write_page	

			movb	fileDescriptor, %dl
			movb	%dl, (%esi, %eax, 1)
			incl	%eax

			incl	i
			jmp for_write_page

		out_for_write_page:

		movl	startIndexJ, %eax
		addl	pagesNeeded, %eax	

	pusha
		decl	%eax
		pushl	%eax
		pushl	startIndexI
		pushl	startIndexJ
		pushl	startIndexI
		pushl	fileDescriptor
		pushl	$addFp
		call printf
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
	popa

		decl noAdds
		jmp for_adds
	
		failed_add:
		pushl	$0
		pushl	$0
		pushl	$0
		pushl	$0
		pushl	fileDescriptor
		pushl	$addFp
		call printf
		popl	%ebx	
		popl	%ebx	
		popl	%ebx	
		popl	%ebx	
		popl	%ebx	
		popl 	%ebx	

		decl noAdds
		jmp for_adds
	done_adds:
		decl noOperations
		jmp loop_operations

get:
	pushl	$fileDescriptor
	pushl	$formatScanfLD
	call scanf
	popl	%ebx
	popl	%ebx	

	movl	$0, i
	movl	$0, j
	for_get_i:
		movl	i, %ecx
		cmp	n, %ecx	
		je failed_get
			
		movl	$0, j
		for_get_j:	
			movl	j, %ecx
			cmp	n, %ecx
			je out_for_get_j		
	
			lea     matrix, %esi
			movl    i, %eax
			xorl    %edx, %edx
			movl    n, %ecx
			mull    %ecx
                	addl    j, %eax
		

			movzbl	(%esi, %eax, 1), %ebx
			cmp	fileDescriptor, %ebx
			jne incr_j
				
			# if we find the start
			movl	j, %edx
			movl	%edx, startIndexJ
			movl	i, %edx
			movl	%edx, startIndexI	

			
			# while it s the same descriptor ignore
			while_get:
				incl	j
				incl	%eax
				movzbl 	(%esi, %eax, 1) , %ebx
				cmp	fileDescriptor, %ebx
				je while_get

			decl	j
		pushl j
			decl	j
		
			pushl	j
			pushl	i
			pushl	startIndexJ
			pushl	startIndexI
			pushl	fileDescriptor
			pushl	$addFp
			call printf
			popl	%ebx
			popl	%ebx
			popl	%ebx
			popl	%ebx
			popl	%ebx
			popl	%ebx
		popl j
			jmp done_get

			incr_j:
				incl	j
				jmp for_get_j			

		out_for_get_j:
		incl	i
		jmp for_get_i	
		
	failed_get:

		pushl	$0
		pushl	$0
		pushl	$0
		pushl	$0
		pushl	fileDescriptor
		pushl	$addFp
		call printf
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
	done_get:
	decl	noOperations
	jmp loop_operations
delete:
	pushl	$fileDescriptor
	pushl	$formatScanfLD
	call scanf
	popl	%ebx
	popl	%ebx

	# we will iterate the matrix as an array cuz it doesnt matter on this one
	movl	n, %eax
	xorl	%edx, %edx
	movl	n, %ecx
	mull 	%ecx
	movl	%eax, %edx

	lea 	matrix, %esi
	movl	$0, i
	for_delete_loop:
		movl	i, %ecx
		cmp	%edx, %ecx			
		je	done_delete
			
		movzbl	(%esi, %ecx, 1), %eax
		cmp	fileDescriptor, %eax 
		jne	skip_delete

		movb	$0, (%esi, %ecx, 1)
		
		incl	i
		jmp for_delete_loop
		skip_delete:
		incl	i
		jmp for_delete_loop
	done_delete:
	call print_memory
	decl	noOperations
	jmp	loop_operations

defragmentation:

	movl	$0, i
	movl	$0, j
	for_def_i:
		movl	i, %ecx
		cmp	n, %ecx
		je out_for_def_i
		
		movl	$0, j	
		for_def_j:
			movl	j, %ecx
			cmp	n, %ecx
			je out_for_def_j
		
			lea 	matrix, %esi
			movl	i, %eax
			xorl	%edx, %edx
			movl	n, %ecx
			mull	%ecx
			addl	j, %eax			
			movb	(%esi, %eax, 1), %dl

			cmp	$0, %dl
			jne	skip_finding_zero

			# if we ve found a 0, seek the next number and swap
			movl	j, %eax
			movl	%eax, k
			for_def_k:
				movl	k, %ecx
				cmp	n, %ecx
				je	skip_finding_zero			
	
							
	                        lea     matrix, %esi
	                        movl    i, %eax
        	                xorl    %edx, %edx
                	        movl    n, %ecx
                           	mull    %ecx
                         	addl    k, %eax
                        	movb  (%esi, %eax, 1), %dl

			
				cmp	$0, %dl
				je after_swap
				
				swap:	
					movb	$0, (%esi, %eax, 1)
				
					subl	k, %eax
					addl	j, %eax
					movb	%dl, (%esi, %eax, 1) 
					jmp skip_finding_zero	
				after_swap:
				incl	k
				jmp for_def_k
			
			skip_finding_zero:
			incl	j
			jmp for_def_j
		out_for_def_j:
		incl	i
		jmp for_def_i
	out_for_def_i:
	call print_memory
	decl	noOperations
	jmp loop_operations

exit:
	# return 0
	xor	%eax, %eax		
	ret
