INCLUDE "hardware.inc"

SECTION "Init Variables", HRAM

hGBCFlag::
	ds 1

SECTION "Init", ROM0

Init::
	; Game Boy Colour?
	cp $11
	ld a, 1
	jr z, .cgb
	xor a
.cgb
	ldh [hGBCFlag], a

	; Initialise stack
	ld sp, wStack.bottom
	call StopLCD

	; Copy OAM DMA routine to HRAM
	ld hl, OAMDMASource
	ld bc, OAMDMASource.end - OAMDMASource
	ld de, hOAMDMA
	call CopyBytes
	; Reset OAM index and clear shadow OAM
	xor a
	ld [hOAMIndex], a
	ld hl, wShadowOAM
	ld bc, wShadowOAM.end - wShadowOAM
	call FillBytes
	; Init OAM
	call hOAMDMA

	; Set palettes
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0], a

	; Clear VBlank flag
	xor a
	ldh [hVBlankFlag], a
	; Clear joypad
	ld hl, hJoypad
	ld [hl+], a
	ld [hl+], a
	ld [hl], a

	; Enable sprites
	ldh a, [rLCDC]
	or LCDCF_OBJON
	ldh [rLCDC], a

	call GameInit

	; Start LCD and enable interrupts
	call StartLCD
	ei
	ld a, IEF_VBLANK
	ldh [rIE], a

	; Wait for VBlank for proper synchronisation of first main loop run
	jp MainLoop.waitVBlank
