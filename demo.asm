        .include "header.asm"
        .include "init.asm"

        .bank 0 slot 0
        .org 0
        .section "MainCode"

        .define PPU_INIDISP     $2100
        .define PPU_BG_MODE     $2105
        .define PPU_BG1SC       $2107
        .define PPU_BG2SC       $2108
        .define PPU_BG3SC       $2109
        .define PPU_BG4SC       $210a
        .define PPU_BG12NBA     $210b
        .define PPU_BG34NBA     $210c
        .define PPU_VMAINC      $2115
        .define PPU_VMADD       $2116
        .define PPU_VMDATA_OFF  $18
        .define PPU_VMDATA      $2118
        .define PPU_CGADD       $2121
        .define PPU_CGDATA_OFF  $22
        .define PPU_CGDATA      $2122
        .define PPU_TM          $212c
        .define PPU_TS          $212d
        .define PPU_TMW         $212e
        .define PPU_TSW         $212f

        .define DMA0_MODE       $4300
        .define DMA0_B_ADDR     $4301
        .define DMA0_A_ADDR     $4302
        .define DMA0_A_BANK     $4304
        .define DMA0_SIZE       $4305
        .define DMA_START       $420b

        .macro  SET_A8_XY8
        sep     #$30
        .endm

        .macro  SET_A16_XY8
        sep     #$10
        rep     #$20
        .endm

        .macro  SET_A8_XY16
        sep     #$20
        rep     #$10
        .endm

        .macro  SET_A16_XY16
        rep     #$30
        .endm


        ;; src-addr(24-bit) start-color color-count
        ;; requires A - 8-bit, X/Y - 16-bit
        .macro  LoadPalette
        SET_A8_XY16
        lda     #\2
        sta     PPU_CGADD
        lda     #:\1
        ldx     #\1
        ldy     #(\3 * 2)
        sta     DMA0_A_BANK
        stx     DMA0_A_ADDR
        sty     DMA0_SIZE
        stz     DMA0_MODE
        lda     #PPU_CGDATA_OFF
        sta     DMA0_B_ADDR
        lda     #$01
        sta     DMA_START
        .endm


        ;; src-addr(24-bit) dest-addr(16-bit) size(16-bit)
        .macro  LoadBlockToVRAM
        SET_A8_XY16
        lda     #$80
        sta     PPU_VMAINC
        ldx     #\2
        stx     PPU_VMADD
        lda     #:\1
        ldx     #\1
        ldy     #\3
        sta     DMA0_A_BANK
        stx     DMA0_A_ADDR
        sty     DMA0_SIZE
        lda     #$01
        sta     DMA0_MODE
        lda     #PPU_VMDATA_OFF
        sta     DMA0_B_ADDR
        lda     #$01
        sta     DMA_START
        .endm


        .macro  SetupVideo
        lda     #$00                              ; mode 0, 8x8
        sta     PPU_BG_MODE
        lda     #$04                              ; $0400, 32x32 tiles
        sta     PPU_BG1SC
        stz     PPU_BG12NBA
        lda     #$01
        sta     PPU_TM
        lda     #$00
        sta     PPU_TMW
        lda     #$0f
        sta     PPU_INIDISP
        .endm


Start:
        InitSNES

        LoadPalette     Palette, 0, 4
        LoadBlockToVRAM Tiles, $0000, $0020

        lda     #$80
        sta     PPU_VMAINC
        ldx     #$0400
        stx     PPU_VMADD
        lda     #$01
        sta     PPU_VMDATA
        ldx     #$0422
        stx     PPU_VMADD
        lda     #$01
        sta     PPU_VMDATA

        SetupVideo

Forever:
        jmp Forever

        .ends


        .bank 1 slot 0
        .org 0
        .section "Data"

Tiles:
        .db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
        .db $ff, $00, $db, $00, $db, $00, $db, $00, $ff, $00, $7e, $00, $00, $00, $ff, $00

Palette:
        .db $ff, $03, $1f, $00, $00, $00, $00, $00

        .ends
