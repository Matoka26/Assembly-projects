.data
	matrice: .space 40000
	matrice2: .space 40000
	matrice_aux: .space 40000
	vec_legaturi: .space 400
	k: .space 4
	n: .space 4
	aux: .space 4
	index: .space 4
	left: .space 4
	right: .space 4
	i: .space 4
	j: .space 4
	nod_start: .space 4
	nod_finish: .space 4
	lungimea_drumului: .space 4
	lineIndex: .space 4
	columnIndex: .space 4
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
	# -16(%ebp) ~ i
	# -20(%ebp) ~ j
	# -24(%ebp) ~ k

	# %esi = adresa primei matrice
	# %edi = adresa a2a matrice
	movl	8(%ebp) , %esi
	movl	12(%ebp) , %edi
	# %ebx = adresa matrice_aux
	movl	16(%ebp) , %ebx
	# i = 0
	movl	$0 , -16(%ebp)
		
	movl	20(%ebp) , %eax
	xorl	%edx , %edx
	mull	20(%ebp)
	
	movl	$0 , -20(%ebp)
	for_pun0:
		movl	-20(%ebp) , %ecx
		cmp 	%ecx , %eax
		je	for_i_matrice
	
		xorl	%edx , %edx
		movl	%edx , (%ebx , %ecx , 4)	
		
		addl	$1 , -20(%ebp)
		jmp	for_pun0

	for_i_matrice:
		#for i = 0,n
		# j = 0 
		movl	$0 , -20(%ebp)
		movl	-16(%ebp) , %ecx
		cmpl	%ecx , 20(%ebp)	
		je out_for_i_matrice
		
		for_j_matrice:
			#for j = 0,n
			# k =0
			movl	$0 , -24(%ebp)
			movl	-20(%ebp) , %ecx
			cmpl	%ecx , 20(%ebp)
			je out_for_j_matrice
			
			
			for_k_matrice:
				#for k = 0,n
				movl	-24(%ebp) , %ecx
				cmpl	%ecx , 20(%ebp)
				je out_for_k_matrice

				# %ecx =  a[i][k]
				movl	-16(%ebp) , %eax
				xorl	%edx , %edx
				mull 	20(%ebp) 
				addl	-24(%ebp) , %eax
				movl	(%esi , %eax , 4) , %ecx

				# %eax = b[k][j]
				movl	-24(%ebp) , %eax
				xorl	%edx , %edx
				mull	20(%ebp)
				addl	-20(%ebp) , %eax
				movl	(%edi , %eax , 4) , %eax
			
				# %ecx = a[i][k] * b[k][j]
				xorl	%edx , %edx
				mull	%ecx
				movl	%eax , %ecx

				# %eax = indexu lu matrice_aux[i][j]
				movl	-16(%ebp) , %eax
				xorl	%edx , %edx
				mull	20(%ebp)
				addl 	-20(%ebp) , %eax
			
				# matrice_aux[i][j] = a[i][k]*b[k][j]
				movl	(%ebx , %eax , 4) , %edx
				addl	%ecx , %edx
				movl	%edx , (%ebx , %eax , 4)

				addl	$1 , -24(%ebp)
				jmp for_k_matrice
			out_for_k_matrice:		
			addl	$1 , -20(%ebp)
			jmp for_j_matrice
		out_for_j_matrice:
		addl	$1 , -16(%ebp)
		jmp for_i_matrice
	out_for_i_matrice:
	addl	$12 , %esp

	popl	%esi
	popl	%edi	
	popl	%ebx
	popl	%ebp
	ret



.global main
main:
	# citesc pe k
	pushl	$k 
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx

	# citesc pe n
	pushl	$n 
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx


# vec_legaturi <- legaturile fiecarui nod
	lea vec_legaturi , %esi
	
	movl	$0 , index
for_in_vector:
	movl	index , %ecx
	cmp	%ecx , n
	je perechi
pusha
	pushl	$aux 
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx
popa
	movl	aux , %eax
	movl	%eax , (%esi , %ecx , 4)
	incl	index
	jmp	for_in_vector

# pune 1 in matrice 
perechi:
# ~for left=0,n-1 (parcurge vectoru)
movl	$0 , left
for_i:
	movl	left , %ecx
	cmp	 %ecx , n
	je	afisare

	lea	vec_legaturi , %esi
	movl	(%esi , %ecx , 4) , %ebx
	movl	%ebx , i
	# ~for j = 0,v[left]-1 (pt fiecare nod se uita cate legaturi are)
	movl	$0 , j
	for_j:
		movl	j , %edx
		cmp	 %edx , %ebx
		je 	 out_j
	
	pusha
		pushl	$right
		pushl	$fs
		call scanf
		popl	%ebx
		popl	%ebx
	popa
	# ~a[left][right] <-1 ?exista
	pusha
		movl	left , %eax
		xorl	%edx , %edx
		mull	n
		addl	right , %eax	
	
		lea	matrice , %edi
		movl	$1 , (%edi , %eax , 4)
	popa
		# j++
		incl	j
		jmp	for_j
	out_j:
	#left++i
	incl	left
	jmp	for_i

afisare:
	# pentru cerinta 1 doar afiseaza matricea,else o ridica la k
	movl	k , %eax
	cmp	$1 , %eax
	jne cazu2

	# for lineIndex =0,n-1
	movl	$0 , lineIndex
	for_lines:
		movl	lineIndex , %ecx
		cmp	%ecx , n
		je	et_exit
		# for columnIndex =0,n-1
		movl	$0 , columnIndex
		for_columns:
			movl	columnIndex , %ecx
			cmp	%ecx , n
			je cont
			# se duce pe a[lineIndex][columnIndex]
			movl	lineIndex , %eax
			movl	$0 , %edx
			mull	n
			addl	columnIndex , %eax
	
			lea 	matrice , %edi
			movl	(%edi , %eax , 4) , %ebx
			# print a[lineIndex][columnIndex]
			pushl	%ebx
			pushl	$fp
			call printf
			popl	%ebx
			popl	%ebx
	
			pushl	$0 
			call fflush
			popl	%ebx
			# columnIndex++
			incl	columnIndex
			jmp	for_columns
	cont:
		movl	$4 , %eax
		movl	$1 , %ebx
		movl	$newLine , %ecx
		movl	$1  , %edx
		int	$0x80
		# lineIndex++
		incl	lineIndex
		jmp	for_lines

cazu2:

	#citesc lungimea_drumului

	pushl	$lungimea_drumului
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx


	# i
	pushl	$nod_start
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx
	# j
	pushl	$nod_finish
	pushl	$fs
	call scanf
	popl	%ebx
	popl	%ebx
	
	movl	lungimea_drumului , %eax
	cmp	$1 , %eax
	je unusingur
	
	xorl	%edx , %edx
	movl	n , %eax
	mull	n
	#aici copiaza matricea de adiacenta in a2a matrice
	lea	matrice , %esi
	lea	matrice2 , %edi
	movl	$0 , index
for_copiere:
	movl	index , %ecx
	cmp	%ecx , %eax
	je	out_for_copiere
	
	movl	(%esi , %ecx , 4) , %edx
	movl	%edx , (%edi , %ecx , 4)

	incl	index
	jmp	for_copiere

out_for_copiere:
	movl	$1 , index
	for_ridic:
		movl	index , %ecx
		cmp	%ecx , lungimea_drumului
		je	final		

		# matrice_aux = matrice * matrice2
	pusha
		pushl	n
		pushl	$matrice_aux
		pushl	$matrice2
		pushl	$matrice
		call	matrix_mult
		popl	%ebx
		popl	%ebx
		popl	%ebx
		popl	%ebx
	popa	

		movl	$0 , aux
		movl	n , %eax
		xorl	%edx , %edx
		mull 	n
		lea	matrice2 , %esi
		lea	matrice_aux , %edi	
		# matrice2 = matrice_aux
		for_copiere_2:
			movl	aux , %ecx
			cmp	%ecx , %eax
			je	out_for_copiere2 	
		
			movl	(%edi , %ecx , 4) , %edx
			movl	%edx , (%esi , %ecx , 4) 	
				

			incl	aux
			jmp	for_copiere_2

		out_for_copiere2:
		incl	index
		jmp	for_ridic

final:
	# a[nod_start][nod_finish] ~ a[i][j]
	lea	matrice2 , %esi
	movl	nod_start , %eax
	xorl	%edx , %edx
	mull	n
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
	
	lea	matrice , %esi
	movl	(%esi , %eax , 4) , %ebx
	pushl	%ebx
	pushl	$fs
	call printf
	popl	%ebx
	popl	%ebx
	pushl	$0 
	call fflush
	popl	%ebx
	
et_exit:
	movl	$1 , %eax 
	xorl	%ebx , %ebx
	int	$0x80
