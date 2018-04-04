; 6805C4/C8 test

	ORG	$50
; Constants
bitdata1:	FCB	$01,$02,$04,$08,$10,$20,$40,$80	;Single bit 0..7 set
bitdata2:	FCB	$fe,$fd,$fb,$f7,$ef,$df,$bf,$7f	;Single bit 0..7 clear
bitdata3:	FCB	$01,$03,$07,$0f,$1f,$3f,$7f,$ff	;Bits 0..7 set
bitdata4:	FCB	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00 ;Bits 0..7 clear

; Data
v0:		FCB	$00

; Code
	ORG	$100
;
; brclrset - test brclr/brset operations
;
brclrset:
	;
	; Test brclr
	;
	brclr	0,bitdata1+0,*		;Bit is 1 - dont branch
	brclr	1,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+0,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+1,*		;Bit is 1 - dont branch
	brclr	2,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+1,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+2,*		;Bit is 1 - dont branch
	brclr	3,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+2,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+3,*		;Bit is 1 - dont branch
	brclr	4,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+3,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+4,*		;Bit is 1 - dont branch
	brclr	5,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+4,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+5,*		;Bit is 1 - dont branch
	brclr	6,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+5,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+6,*		;Bit is 1 - dont branch
	brclr	7,bitdata1+6,*+5	;Bit is 0 - branch
	bra	*

	brclr	0,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	1,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	2,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	3,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	4,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	5,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	6,bitdata1+7,*+5	;Bit is 0 - branch
	bra	*
	brclr	7,bitdata1+7,*		;Bit is 1 - dont branch

	;
	; Test brset
	;
	brset	0,bitdata2+0,*		;Bit is 0 - dont branch
	brset	1,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+0,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+1,*		;Bit is 0 - dont branch
	brset	2,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+1,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+2,*		;Bit is 0 - dont branch
	brset	3,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+2,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+3,*		;Bit is 0 - dont branch
	brset	4,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+3,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+4,*		;Bit is 0 - dont branch
	brset	5,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+4,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+5,*		;Bit is 0 - dont branch
	brset	6,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+5,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+6,*		;Bit is 0 - dont branch
	brset	7,bitdata2+6,*+5	;Bit is 1 - branch
	bra	*

	brset	0,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	1,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	2,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	3,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	4,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	5,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	6,bitdata2+7,*+5	;Bit is 1 - branch
	bra	*
	brset	7,bitdata2+7,*		;Bit is 0 - dont branch


;
; bset/bclr test
;
; Assumes (lda/sta direct) and (cmp direct) has been tested
;
bclrset:
	;
	; Set bits 0..7 of v0 (v0=0)
	;
	bset	0,v0
	lda	v0
	cmp	bitdata3+0
	bne	*
	bset	1,v0
	lda	v0
	cmp	bitdata3+1
	bne	*
	bset	2,v0
	lda	v0
	cmp	bitdata3+2
	bne	*
	bset	3,v0
	lda	v0
	cmp	bitdata3+3
	bne	*
	bset	4,v0
	lda	v0
	cmp	bitdata3+4
	bne	*
	bset	5,v0
	lda	v0
	cmp	bitdata3+5
	bne	*
	bset	6,v0
	lda	v0
	cmp	bitdata3+6
	bne	*
	bset	7,v0
	lda	v0
	cmp	bitdata3+7
	bne	*

	;
	; Clear bits 0..7 of v0 (v0=$ff)
	;
	bclr	0,v0
	lda	v0
	cmp	bitdata4+0
	bne	*
	bclr	1,v0
	lda	v0
	cmp	bitdata4+1
	bne	*
	bclr	2,v0
	lda	v0
	cmp	bitdata4+2
	bne	*
	bclr	3,v0
	lda	v0
	cmp	bitdata4+3
	bne	*
	bclr	4,v0
	lda	v0
	cmp	bitdata4+4
	bne	*
	bclr	5,v0
	lda	v0
	cmp	bitdata4+5
	bne	*
	bclr	6,v0
	lda	v0
	cmp	bitdata4+6
	bne	*
	bclr	7,v0
	lda	v0
	cmp	bitdata4+7
	bne	*

	bra	*

