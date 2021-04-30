.data
.eqv ITERATION_COUNT 20
.eqv WIDTH 512
.eqv HEIGHT 256
.eqv MAX_PIX 131072
frameBuffer: .space 0x80000
newline: .asciiz "\n"
test_space: .asciiz "TEST"

.text

main:
	li $s4,4	#$s0 keeps width ratio
	sll $s4,$s4,24
	div $s4,$s4,WIDTH
	li $s6,4	#$s1 keeps height ratio
	sll $s6,$s6,24
	div $s6,$s6,HEIGHT
	
	li $s3,-2	#load minimum x and y value
	sll $s3,$s3,24
	li $s2,4	#$s3 keeps maximum of x^2+y^2
	sll $s2,$s2,24

	la $t0,frameBuffer	#load row counter
	li $t1,0	#X counter
	li $t2,0	#Y counter
	
pixels_loop:
	#li $v0,1
	#move $a0,$t1
	#syscall
	#li $v0,4
	#la $a0,test_space
	#syscall
	#li $v0,1
	#move $a0,$t2
	#syscall
	#li $v0,4
	#la $a0,newline
	#syscall
	
	move $t4,$s6 #load Y ratio
	mul $t4,$t4,$t2 #multiply ratio by y counter
	add $t4,$t4,$s3 #add minY to multiplied ratio
	move $t9,$t4
	#t4,t9 contains initial imaginary part (y) of the number
	
	move $t3,$s4 #load X ratio
	mul $t3,$t3,$t1 #multiply ratio by x counter
	add $t3,$t3,$s3 #add minX to multiplied ratio
	move $t8,$t3
	#t3,t8 contains initial real part (x) of the number
	
	li $s7,0 #s7 holds current number of calculate_loop iteration
calculate_loop:
	mul $t5,$t3,$t3 #x^2
	mfhi $s1
	sll $s1,$s1,8
	srl $t5,$t5,24
	or $t5,$s1,$t5
	
	mul $t6,$t4,$t4 #y^2
	mfhi $s1
	sll $s1,$s1,8
	srl $t6,$t6,24
	or $t6,$s1,$t6
	
	sub $t7,$t5,$t6 #x^2-y^2
	add $t7,$t7,$t8 #Re(x2)+x0
	#t7 contains x2
	
	mul $t5,$t3,$t4 #x*y
	mfhi $s1
	sll $s1,$s1,8
	srl $t5,$t5,24
	or $t5,$s1,$t5
	sll $t5,$t5,1 #2xy = xy+xy
	add $t5,$t5,$t9 #Im(y2)+y0
	#t5 contains y2
	move $t3,$t7
	move $t4,$t5
	#t3 contains x2, t4 contains y2
	
	mul $t7,$t7,$t7
	mfhi $s1
	sll $s1,$s1,8
	srl $t7,$t7,24
	or $t7,$s1,$t7
	
	mul $t5,$t5,$t5
	mfhi $s1
	sll $s1,$s1,8
	srl $t5,$t5,24
	or $t5,$s1,$t5
	
	add $t6,$t7,$t5 #x^2+y^2
	#t6 should be compared with boundary $s2
	add $s7,$s7,1 # iterations count
check_conditions:
	bge $t6,$s2,put_white
	blt $s7,ITERATION_COUNT,calculate_loop
put_pixel:
	li $s0,0x000000FF
	sw $s0,0($t0)
	addi $t0,$t0,4
	j next_pixel
put_white:
	li $s0,0x00FFFFFF
	sw $s0,0($t0)
	addi $t0,$t0,4
next_pixel:
	bge $t1,WIDTH,next_row
	add $t1,$t1,1
	j pixels_loop
next_row:
	add $t2,$t2,1
	bge $t2,HEIGHT,end
	li $t1,0
	j pixels_loop
end:
	li $v0,10
	syscall 
