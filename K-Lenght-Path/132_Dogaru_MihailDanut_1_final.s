.data
	vec_legaturi: .space 400
	k: .space 4
	n: .space 4
	j: .space 4
	i: .space 4
	left: .space 4
	right: .space 4
	aux: .space 4
	dimensiune: .space 4
	lineIndex: .space 4
	columnIndex: .space 4
	lungimea_drumului: .space 4
	nod_finish: .space 4
	nod_start: .space 4
	matrice_aux: .space 4
	m1: .space 4
	m2: .space 4
	newLine: .asciz "\n"
	fs: .asciz "%ld"
	fp: .asciz "%ld "
.text

matrix_mult:
	pushl	%ebp	
	movl	%esp , %ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	
	subl	$12 , %esp

	movl	8(%ebp) , %esi
	movl	12(%ebp) , %edi
	movl	16(%ebp) , %ebx

	movl	20(%ebp) , %eax
	xorl	%edx , %edx
	mull	20(%ebp)
	movl	$0 , -20(%ebp)
	movl	$0 , -16(%ebp)
	for_pun0:
		movl	-20(%ebp) , %ecx
		cmp	%ecx , %eax
		je for_i_matrix_mult
	
		xorl	%edx , %edx
		movl	%edx , (%ebx , %ecx , 4)

		addl	$1 , -20(%ebp)		
		jmp	for_pun0
	for_i_matrix_mult:
		movl	$0 , -20(%ebp)
		movl	-16(%ebp) , %ecx
		cmp	%ecx , 20(%ebp)
		je out_for_i_matrix_mult

		for_j_matrix_mult:
			movl	$0 , -24(%ebp)
			movl	-20(%ebp) , %ecx
			cmp	%ecx , 20(%ebp)
			je out_for_j_matrix_mult
	
			for_k_matrix_mult:
				movl	-24(%ebp) , %ecx
				cmp	%ecx , 20(%ebp)
				je out_for_k_matrix_mult
			
				movl	-16(%ebp) , %eax
				xorl	%edx , %edx
				mull	20(%ebp)
				addl	-24(%ebp) , %eax
				movl	(%esi , %eax , 4) ,%ecx

				movl	-24(%ebp) , %eax
				xorl	%edx , %edx
				mull	20(%ebp)
				addl	-20(%ebp) , %eax
				movl	(%edi , %eax , 4) , %eax

				xorl	%edx , %edx
				mull	%ecx
				movl	%eax , %ecx

				movl	-16(%ebp) , %eax
				xorl	%edx , %edx
				mull	20(%ebp)
				addl	-20(%ebp) , %eax
						
				movl	(%ebx , %eax , 4) , %edx
				addl	%ecx , %edx
				movl	%edx , (%ebx , %eax , 4)
	
				addl	$1 , -24(%ebp)
				jmp for_k_matrix_mult
			out_for_k_matrix_mult:
			addl	$1 , -20(%ebp)
			jmp for_j_matrix_mult
		out_for_j_matrix_mult:
		addl	$1 , -16(%ebp)
		jmp for_i_matrix_mult
	out_for_i_matrix_mult:
	addl	$12 , %esp


	popl	%esi
	popl	%edi
	popl	%ebx
	popl	%ebp
	ret

.global main
main:

	pushl	$k
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx

	pushl	$n
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx

	movl	$4 , %eax
	xorl	%edx , %edx
	mull	n
	xorl	%edx , %edx
	mull	n
	movl	%eax , dimensiune

	lea	vec_legaturi , %esi
	movl	$0 , i
	for_in_vector:
		movl	i , %ecx
		cmp	%ecx , n
		je out_for_in_vector

		pusha
		pushl	$aux
		pushl	$fs
		call scanf
		popl	%ebx
		popl	%ebx
		popa
			

		movl	aux , %eax
		movl	%eax , (%esi , %ecx , 4)
		incl	i
		jmp	for_in_vector
out_for_in_vector:

	pushl	%ebp			#am salvat %ebp pe stiva pentru siguranta
	movl	$192 , %eax		#codul syscall-ului mmap2 e 192
	xorl	%ebx , %ebx		#0 in ebx ca sa las OS-ul sa aleaga zona de memorie
	movl	dimensiune , %ecx	#dimensiune = 4*n*n,fiind dimensiunea zonei de memorie pe care o vreau pt o matrice de long-uri
	movl	$3 , %edx		# 3 = 1(PROT_READ-ca sa pot citi din acea zona) + 2(PROT_WRITE-ca sa pot scrie in acea zona)
	movl	$34 , %esi		# 34 = 2(MAP_PRIVATE-ca procesul meu sa fie singurul care poate accesa zona) + 32(MAP_ANNONYMOUS-imi pune 0 pe toata zona) 
	xorl	%edi , %edi		#file description = 0 ca sa puna 0 pestetot dar e ignorat pentru ca e MAP_ANNONYMOUS
	xorl	%ebp , %ebp		# offset = 0
	int	$0x80			#rugam kernel-ul sa se ocupe
	popl	%ebp

	movl	%eax , %edi
	movl	%eax , m1		#adresa e returnata in %eax si o vom salva in alta variabila ca s-o folosim mai tarziu
	

	for_i:
		movl	left , %ecx
		cmp	%ecx , n
		je out_for_i
		
		lea	vec_legaturi , %esi 
		movl	(%esi , %ecx , 4) , %ebx
		movl	%ebx , i
		movl	$0 , j
		for_j:
			movl	j , %edx
			cmp	%edx , %ebx
			je out_for_j
		
			pusha
			pushl	$right
			pushl	$fs
			call scanf
			popl	%ebx
			popl	%ebx
			popa
		
			pusha
			movl	left , %eax
			xorl	%edx , %edx
			mull	n
			addl	right , %eax

			movl	$1 , (%edi , %eax , 4)
			popa
			
			incl	j
			jmp	for_j
		out_for_j:
		incl	left
		jmp	for_i

out_for_i:

	pushl	$lungimea_drumului
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx

	pushl	$nod_start
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx
	
	pushl	$nod_finish
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx

	movl	lungimea_drumului , %eax
	cmp	$1 , %eax
	je unusingur


	pushl	%ebp
	movl	$192 , %eax
	xorl	%ebx , %ebx
	movl	dimensiune , %ecx
	movl	$3 , %edx
	movl	$34 , %esi
	xorl	%edi , %edi
	xorl	%ebp , %ebp
	int	$0x80
	popl	%ebp
	
	movl	%eax , m2
	

	pushl	%ebp	
	movl	$192 , %eax
	xorl	%ebx , %ebx
	movl	dimensiune , %ecx
	movl	$3 , %edx
	movl	$34 , %esi
	xorl	%edi , %edi
	xorl	%ebp , %ebp
	int	$0x80
	popl	%ebp	
	movl	%eax , matrice_aux
	
	xorl	%edx , %edx
	movl	n , %eax
	mull	n
	movl	$0 , i
	for_copiere_matrici:
		
		movl	i , %ecx
		cmp	%ecx , %eax
		je out_for_copiere_matrici
		
		movl	m1 , %edi
		movl	m2 , %esi
		movl	(%edi , %ecx , 4) , %edx
		movl	%edx , (%esi , %ecx , 4)


		incl	i
		jmp	for_copiere_matrici

	out_for_copiere_matrici:
	movl	$1 , i
	for_inmultiri:
		movl	i , %ecx
		cmp	%ecx , lungimea_drumului
		je final
		
		


		pushl	n
		pushl	matrice_aux
		pushl	m2
		pushl	m1
		call matrix_mult	
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx

		movl	$0 , aux
		movl	n , %eax
		xorl	%edx , %edx
		mull 	n
		
		movl	m2 , %esi
		movl	matrice_aux , %edi
		for_copiere_inmultire:
			movl	aux , %ecx
			cmp	%ecx , %eax
			je out_for_copiere_inmultire

			movl	(%edi , %ecx , 4) , %edx
			movl	%edx , (%esi , %ecx , 4)
			incl	 aux
			jmp	for_copiere_inmultire
		
		
		out_for_copiere_inmultire:

		incl	i
		jmp	for_inmultiri
	
	final:
		movl	m2 , %esi
		movl	nod_start , %eax
		xorl	%edx , %edx
		addl	nod_finish , %eax

		movl	(%esi , %eax , 4) , %ebx
		pushl	%ebx
		pushl	$fs
		call printf
		popl	%ebx
		popl	%ebx

		pushl	$0 
		call fflush
		popl	%ebx
		
		
	jmp et_exit

	unusingur:
		movl	nod_start , %eax
		xorl	%edx , %edx 
		mull	n
		addl	nod_finish , %eax

		movl	m1 , %edi	
		movl	(%edi , %eax , 4) , %ebx
		pushl	%ebx
		pushl	$fs
		call printf
		popl	%ebx
		popl	%ebx
		pushl	$0
		call fflush
		popl	%ebx
	
		

 et_exit:
	movl	$91 , %eax		# 91 - codul sycall-ului munmap care dezaloca o zona de memorie
	movl	m1 , %ebx		# am dat in %ebx adresa zonei
	movl	dimensiune , %ecx	# in %ecx dimensiunea pe care vrem sa o dezaloce,aceeasi cu dimensiunea matricei
	int	$0x80			# chemam kernel-ul sa se ocupe

	movl	$91 , %eax
	movl	m2 , %ebx
	movl	dimensiune , %ecx
	int	$0x80	

	movl	$91 , %eax
	movl	matrice_aux , %ebx
	movl	dimensiune , %ecx
	int	$0x80



	movl	$1 , %eax
	xorl	%ebx , %ebx
	int	$0x80
