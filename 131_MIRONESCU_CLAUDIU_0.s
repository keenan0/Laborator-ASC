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

BUF1: .space 400
BUF2: .space 400

formatString1: .asciz "%ld %ld %ld"
formatString2: .asciz "%ld %ld"

.text
.global main

main:
jmp input

input:
# citeste numarul de linii, coloane si celule vii
	pushl $p
	pushl $n
	pushl $m

	pushl $formatString1

	call scanf

	popl %ebx
	popl %ebx
	popl %ebx
	popl %ebx

mov p, %ecx
for_celule:

# practic forul urmator:

# for (int i = p; i >= 0; --i)
#	scanf("%ld %ld", &y, &x)
#	buf[y][x] = 1


	cmp $0, %ecx
	je exit

	pushl $x
	pushl $y
	pushl $formatString2

	call scanf

	popl %ebx
	popl %ebx
	popl %ebx

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
	jmp for_celule

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
