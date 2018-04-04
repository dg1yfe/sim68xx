	lds	#255
	ldx	#10

main:
	jsr	loop
	dex
	bne	main
xit:
	jmp	xit

loop:
	subd	#1		;4
	bne	loop		;3
	rts
