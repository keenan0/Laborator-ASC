.data
m: .long 0
n: .long 0
p: .long 0
k: .long 0

x: .long 0
y: .long 0

mainBuffer: .long 1

suma: .long 0

BUF1: .space 400
BUF2: .space 400

formatString3: .asciz "%ld %ld %ld"
formatString2: .asciz "%ld %ld"
formatString1: .asciz "%ld"

afisat0: .asciz "0 "
afisat1: .asciz "1 "

nl: .ascii "\n"

.text
.global main

main:

# SET_ZERO - seteaza pseudo matricea buf1 cu zero-uri
set_zero1:
	lea BUF1, %edi
	movl $0, %ecx

	for_zero:
		cmp $400, %ecx
		je input

		movl $0, (%edi, %ecx, 4)

		incl %ecx
		jmp for_zero

# INPUT - citeste numarul de linii, coloane si celule vii
input:
	pushl $p
	pushl $n
	pushl $m

	pushl $formatString3

	call scanf

	popl %ebx
	popl %ebx
	popl %ebx
	popl %ebx

movl p, %ecx

jmp afisari
for_cells:
# practic forul urmator:

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

	#adauga celula in buffer1
	add_buffer:
		lea BUF1, %edi

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
			cmp $1, mainBuffer
			je update_buffer2

			jmp update_buffer1

		update_buffer1:
			pushl $BUF2
			pushl x
			pushl y
			test:
			call get_cell_state

			popl %ebx
			popl %ebx
			popl %ebx

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
	jge exit

	movl $1, x
	afisare_matrice_x:
		movl x, %ecx
		cmp n, %ecx
		jge continua_afisare

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
		afisat_1:
			movl $afisat1, %ecx

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
