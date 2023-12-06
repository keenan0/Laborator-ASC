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
	#je input_iteratii #je afisari pt ca sa mearga
	je afisari

	pushl %ecx
	pushl $x
	pushl $y
	pushl $formatString2

	call scanf

	popl %ebx
	popl %ebx
	popl %ebx
	popl %ecx

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

	popl %ebx
	popl %ebx
jmp emulate

get_cell_state:
	pushl %ebp
	mov %esp, %ebp

	pushl %ebx
	pushl %eax
	pushl %ecx

	#  8(%ebp) = y
	# 12(%ebp) = x
	# 16(%ebp) = &BUFF

	lea 16(%ebp), %edi

	movl $0, suma
	movl 8(%ebp), %eax
	decl %eax

	movl $20, %ebx
	mull %ebx

	movl 12(%ebp), %ebx
	addl %ebx, %eax

	movl (%edi, %eax, 4), %ebx
	addl %ebx, suma

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
			pushl $BUF2
			pushl x
			pushl y

			call get_cell_state

			add $12, %esp

			# IN LOC DE 1 TERBUIE SUMA VECINILOR RETURNATA DE GET CELL STATE
			movl $1, (%edi, %eax, 4)
		update_buffer2:
			lea BUF1, %edi

			movl $1, (%edi, %eax, 4)

		incl x
		jmp for_x

	skip_y:
	incl y
	jmp for_y

schimba_buffer:
	movl mainBuffer, %eax
	not %eax
	movl %eax, mainBuffer

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

afis_buf1:
lea BUF1, %edi

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
