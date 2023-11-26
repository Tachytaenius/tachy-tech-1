INCLUDE "constants/joypad.inc"

SECTION "Main Loop Variables", WRAM0

wPlayerPosition::
.y::
	ds 2 ; unsigned 12.4
.x::
	ds 2 ; unsigned 12.4

wPlayerTargetVelocity::
.y::
	ds 1 ; signed 3.4
.x::
	ds 1; signed 3.4

wPlayerVelocity::
.y::
	ds 1 ; signed 3.4
.x::
	ds 1; signed 3.4

wPlayerDirection::
	ds 1

wPlayerAnimation::
.type::
	ds 1
.frame::
	ds 1
.timer::
	ds 1

wPlayerEntitySkinId::
	ds 1

wPlayerMetaspriteFlags::
	ds 1 ; Same for all sprites

wUpdatePlayerSprite::
	ds 1 ; boolean

SECTION "Main Loop", ROM0

MainLoop::
	call WaitVBlank

	; Graphics

	ld a, [wUpdatePlayerSprite]
	and a
	jr z, :+
	call Update2x2MetaspriteGraphics
	xor a
	ld [wUpdatePlayerSprite], a
:

	ld hl, wPlayerPosition
	ld d, NUM_TILES
	call Render2x2Metasprite

	; Update logic

	call UpdateJoypad
	call ResetShadowOAM

	call StepEntityAnimation
	call ProcessPlayerInput
	call AcceleratePlayer
	call ApplyPlayerVelocity

	; TEMP
	ldh a, [hJoypad.pressed]
	and JOY_B_MASK
	jr z, :++
	ld a, [wPlayerEntitySkinId]
	inc a
	cp 3
	jr nz, :+
	xor a
:
	ld [wPlayerEntitySkinId], a
	ld a, 1
	ld [wUpdatePlayerSprite], a
:

	jp MainLoop
