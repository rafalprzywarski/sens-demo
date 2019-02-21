        .include "header.asm"
        .include "init.asm"

        .bank 0 slot 0
        .org 0
        .section "MainCode"

        .define PPU_INIDISP     $2100
        .define PPU_CGADD       $2121
        .define PPU_CGDATA      $2122

Start:
        InitSNES
        stz     PPU_CGADD
        lda     #$e0                                  ; rrrrrggg
        sta     PPU_CGDATA
        lda     #5                                    ; ggbbbbb0
        sta     PPU_CGDATA

        lda     #$0f                                  ; max brightness
        sta     PPU_INIDISP

Forever:
        jmp Forever

        .ends
