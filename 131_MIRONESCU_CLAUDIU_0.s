.data
# n,m < 18 --> n si m pot fi reprezentate pe 5 biti < 2 bytes
m: .long 0
n: .long 0

# p < 18 * 18 = 324 --> p poate fi reprezentat pe 9 biti < 3 bytes
p: .long 0

# k < 15 < 2^4 --> k poate fi reprezentat pe 4 biti = 1 byte
k: .long 0

# x si y - pozitiile unei celule la un moment dat
x: .long 0
y: .long 0

# matricea va fi de forma M[20][20] = 400 biti = 100 bytes

mainBuffer: .long 1

BUF1: .space 400
BUF2: .space 400

formatString3: .asciz "%ld %ld %ld"
formatString2: .asciz "%ld %ld"
formatString1: .asciz "%ld"

#variabile pentru functia getCellState
curent: .long 0

N: .long 0
S: .long 0
E: .long 0
W: .long 0

NE: .long 0
NW: .long 0

SE: .long 0
SW: .long 0

SUM_CELLS: .long 0

result: .long 0

.text
.global main

main:
jmp input

input:
# citeste numarul de linii, coloane si celule vii
	pushl $p
	pushl $n
	pushl $m

	pushl $formatString3

	call scanf

	popl %ebx
	popl %ebx
	popl %ebx
	popl %ebx

mov p, %ecx

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

# TODO: functia getCellState() returneaza statusul din generatia viitoare a celulei in functie de vecinii sai
get_cell_state:
xor %ebx, %ebx

# TODO: functia emulate care rezolva fiecare pas
emulate:
mov $1, y

for_y:
	mov y, %ecx
	cmp m, %ecx
	jg schimba_buffer

	mov $1, x
	for_x:
		mov x, %ecx
		cmp n, %ecx
		jg skip_y

		get_x_y:
			movl y, %eax
			mov $20, %ebx
			mull %ebx

			add x, %eax

		if:
			cmp $1, mainBuffer
			je update_buffer2

			jmp update_buffer1

		update_buffer1:
			lea BUF2, %edi

			mov $1, (%edi, %eax, 4)
		update_buffer2:
			lea BUF1, %edi

			mov $1, (%edi, %eax, 4)

		incl x
		jmp for_x

	skip_y:
	incl y
	jmp for_y

schimba_buffer:
	# TODO: mainBuffer = !mainBuffer

	ret

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
