.data
m: .long 5
n: .long 10
p: .long 15
k: .long 0

x: .long 0
y: .long 0

mainBuffer: .long 1

suma: .long 0

BUF1: .space 1600
BUF2: .space 1600

formatString3: .asciz "%ld %ld %ld"
formatString2: .asciz "%ld %ld"
formatString1: .asciz "%ld"

afisat0: .asciz "0 "
afisat1: .asciz "1 "

nl: .ascii "\n"

.text
.global main

main:

# seteaza pseudo matricea buf1 cu zero-uri
# inainte nu mergea inputul daca cmp X, %ecx avea X > $200 dar s a fixat bug ul de la sine??
# VERIFICAT

# CEL MAI MARE BUG BUF1 TREBUIA SA FIE DE 1600 de BYTES, NU DE 400!!!!
# DIN CAUZA ASTA PROGRAMUL ACCESA MEMORIA GRESITA LA CITIRE

set_zero1:
	lea BUF1, %edi
	xor %ecx, %ecx

	for_zero:
		cmp $400, %ecx
		jge input

		movl $0, (%edi, %ecx, 4)

		incl %ecx
		jmp for_zero

# nu stiu daca e necesar, dar merge cu ea
xor %edi, %edi

# citeste numarul de linii, coloane si celule vii
# VERIFICAT

input:
pushl $p
pushl $n
pushl $m

pushl $formatString3

call scanf

add $16, %esp
movl p, %ecx

# MERGE DACA DECOMENTEZI - jmp afisari

# VERIFICAT
lea BUF1, %edi
for_cells:
# for (int i = p; i >= 0; --i)
#	scanf("%ld %ld", &y, &x)
#	buf[y][x] = 1


	cmp $0, %ecx
	je input_iteratii

	pushl %ecx
	pushl $x
	pushl $y
	pushl $formatString2

	call scanf

	popl %ebx
	popl %ebx
	popl %ebx
	popl %ecx

	debug3:
	# MERG?
	incl x
	incl y

	#adauga celula in buffer1
	add_buffer:
		# BUF1 este o matrice de 20 x 20
		# BUF1[y][x] <=> y * 20 * 4 + x * 4

		movl y, %eax
		movl $20, %ebx
		mull %ebx

		addl x, %eax
		movl $1, (%edi, %eax, 4)

	decl %ecx
	jmp for_cells

input_iteratii:
	pushl $k
	pushl $formatString1

	call scanf

	add $8, %esp
for_k:
	movl k, %ecx
	cmp $0, %ecx
	je afisari

	decl k
	jmp emulate

# VERIFCAT ASA SI ASA
get_cell_state:
	pushl %ebp
	mov %esp, %ebp

	pushl %ebx
	pushl %eax
	pushl %ecx

	#  8(%ebp) = &suma
	# 12(%ebp) = y
	# 16(%ebp) = x
	# 20(%ebp) = buff

	#lea 20(%ebp), %edi

	# eax = y-1
	mov 12(%ebp), %eax
	decl %eax

	# ebx = x - 1
	mov 16(%ebp), %ebx
	decl %ebx

	# calculam adresa in matrice
	mov $20, %ecx
	mull %ecx

	add %ebx, %eax


	# suma = 0
	xor %ecx, %ecx
	NW:
	addl (%edi, %eax, 4), %ecx

	N:
	# x = x
	incl %eax
	addl (%edi, %eax, 4), %ecx

	NE:
	# x = x + 1
	incl %eax
	addl (%edi, %eax, 4), %ecx

	E:
	# y = y, x = x + 1
	addl $20, %eax
	add (%edi, %eax, 4), %ecx

	W:
	# y = y, x = x - 1
	decl %eax
	decl %eax
	add (%edi, %eax, 4), %ecx

	SW:
	# y = y + 1, x = x - 1
	addl $20, %eax
	add (%edi, %eax, 4), %ecx

	S:
	#y = y + 1, x = x
	incl %eax
	add (%edi, %eax, 4), %ecx

	SE:
	#y = y + 1, x = x + 1
	incl %eax
	add (%edi, %eax, 4), %ecx

	mov 8(%ebp), %ebx
	mov %ecx, 0(%ebx)

	# PANA AICI SE CALCULEAZA SUMA VECINILOR
	debug:
	movl %eax, %ebx
	xor %eax, %eax

	cmp $3, %ecx
	je vecini3
	jmp cmp2

	vecini3:
	incl %eax
	jmp return_cell_state

	cmp2:
	cmp $2, %ecx
	je vecini2
	jmp return_cell_state

	vecini2:
	subl $21, %ebx
	cmpl $0, (%edi, %ebx, 4)
	je return_cell_state

	mov $1, %eax

	# IN EAX VA FI MEMORATA VIITOAREA STARE A UNEI CELULE

	return_cell_state:
	movl 8(%ebp), %ebx
	movl %eax, 0(%ebx)

	popl %ecx
	popl %eax
	popl %ebx
	popl %ebp

	ret

# EMULATE - functia care rezolva cate o iteratie
emulate:

movl $1, y
for_y:
	movl y, %ecx
	cmp m, %ecx
	jg schimba_buffer

	movl $1, x
	for_x:
		movl x, %ecx
		cmp n, %ecx
		jg skip_y

		get_x_y:
			movl y, %eax
			movl $20, %ebx
			mull %ebx

			add x, %eax

		if:
			cmpl $1, mainBuffer
			je update_buffer2

			jmp update_buffer1

		update_buffer1:
			lea BUF2, %edi
			pushl $BUF1
			pushl x
			pushl y
			pushl $suma

			call get_cell_state

			addl $16, %esp

			# IN LOC DE 1 TERBUIE SUMA VECINILOR RETURNATA DE GET CELL STATE

			lea BUF1, %edi
			movl suma, %edx
			movl %edx, (%edi, %eax, 4)

			jmp inc_x

		update_buffer2:
			lea BUF1, %edi
			pushl $BUF2
			pushl x
			pushl y
			pushl $suma

			call get_cell_state

			addl $16, %esp

			debug2:
			lea BUF2, %edi
			movl suma, %edx
			movl %edx, (%edi, %eax, 4)
		inc_x:
		incl x
		jmp for_x

	skip_y:
	incl y
	jmp for_y

schimba_buffer:
	movl mainBuffer, %eax
	xor $1, %eax
	movl %eax, mainBuffer
	jmp for_k

# CE BUGURI AVEM? -> NICIUNUL !!!!
# ETICHETA FUNCTIONEAZA

# VERIFICAT
# daca (mainBuffer) print (buffer1) else print (buffer2)

afisari:
movl mainBuffer, %ecx
cmp $0, %ecx
je afis_buf2
jmp afis_buf1

afis_buf2:
lea BUF2, %edi
jmp matrice

afis_buf1:
lea BUF1, %edi

matrice:
movl $1, y
afisare_matrice:
	movl y, %ecx
	cmp m, %ecx
	jg exit

	movl $1, x
	afisare_matrice_x:
		movl x, %ecx
		cmp n, %ecx
		jg continua_afisare

		movl y, %eax
		movl $20, %ebx
		mull %ebx

		addl x, %eax
		movl (%edi, %eax, 4), %eax

		cmp $0, %eax
		je afisat_0
		jmp afisat_1

		afisat_0:
			movl $afisat0, %ecx
			jmp afis
		afisat_1:
			movl $afisat1, %ecx

		afis:
		mov $4, %eax
		mov $1, %ebx
		mov $3, %edx
		int $0x80

		incl x
		jmp afisare_matrice_x
	continua_afisare:

	mov $4, %eax
	mov $1, %ebx
	mov $nl, %ecx
	mov $1, %edx
	int $0x80

	incl y
	jmp afisare_matrice

exit:
mov $1, %eax
xor %ebx, %ebx
int $0x80


#@@@@@@@@@@@@@@@@@@@@@@@@@@
#
#   conway's game of life
#
#          problema 0x00
#
#
# mironescu claudiu, 131
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@
