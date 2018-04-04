	TTL  AS6811 brclr/brset Test


*	Memory start addresses
*
_DATA	EQU	0
_CODE	EQU	$8000
_RESET	EQU	$FFFE

	ORG	_DATA

dir_00	FCB	$00
dir_ff	FCB	$ff

offset	EQU	$44


	ORG	_CODE


test_brclr_dir:
	brclr   dir_ff #$01 *
	brclr   dir_ff #$02 *
	brclr   dir_ff #$04 *
	brclr   dir_ff #$08 *
	brclr   dir_ff #$10 *
	brclr   dir_ff #$20 *
	brclr   dir_ff #$40 *
	brclr   dir_ff #$80 *

test_brset_dir:
	brset   dir_00 #$01 *
	brset   dir_00 #$02 *
	brset   dir_00 #$04 *
	brset   dir_00 #$08 *
	brset   dir_00 #$10 *
	brset   dir_00 #$20 *
	brset   dir_00 #$40 *
	brset   dir_00 #$80 *

test_brset_x:
	ldx	#dir_ff-offset
        brclr	offset,x #$01 *
        brclr	offset,x #$02 *
        brclr	offset,x #$04 *
        brclr	offset,x #$08 *
        brclr	offset,x #$10 *
        brclr	offset,x #$20 *
        brclr	offset,x #$40 *
        brclr	offset,x #$80 *

test_brclr_x:
	ldx	#dir_00-offset
        brset	offset,x #$01 *
        brset	offset,x #$02 *
        brset	offset,x #$04 *
        brset	offset,x #$08 *
        brset	offset,x #$10 *
        brset	offset,x #$20 *
        brset	offset,x #$40 *
        brset	offset,x #$80 *

test_brset_y:
	ldy	#dir_ff-offset
        brclr	offset,y #$01 *
        brclr	offset,y #$02 *
        brclr	offset,y #$04 *
        brclr	offset,y #$08 *
        brclr	offset,y #$10 *
        brclr	offset,y #$20 *
        brclr	offset,y #$40 *
        brclr	offset,y #$80 *

test_brclr_y:
	ldy	#dir_00-offset
        brset	offset,y #$01 *
        brset	offset,y #$02 *
        brset	offset,y #$04 *
        brset	offset,y #$08 *
        brset	offset,y #$10 *
        brset	offset,y #$20 *
        brset	offset,y #$40 *
        brset	offset,y #$80 *

test_ok:
	bra	*
 
	ORG	_RESET
	FDB	test_brclr_dir
