MODULE Demo2; (* https://www.z88dk.org/forum/viewtopic.php?t=11003 *)

(*
 * Timmy's first gb demo, version 20200227
 * February 2020
 *
 * Compile with:
 *    zcc +gb -create-app -o gbdemo.o gbdemo.c
 *
 * Usage:
 *    Use joypad to move sprite
 *    Hold A and move joypad to move background
 *    Hold B and move joypad to move window
 *)

IMPORT gb := GB, hw := Hardware, SYSTEM;

TYPE
  BYTE = SYSTEM.BYTE;
  Backwall = ARRAY 16*11 OF BYTE;
  Background4 = ARRAY 4 OF BYTE;
  Background5 = ARRAY 5 OF BYTE;
  Sprites = ARRAY 16*4 OF BYTE;

  (* some tile data *)

CONST
  backwalls = Backwall (
    247,247,247,247,247,247,  0,  0,223,223,223,223,223,223,  0,  0,
    248,248,227,227,207,207,159,159,191,191, 63, 63,127,127,127,127,
    127,127,127,127, 63, 63,191,191,159,159,207,207,227,227,248,248,
     31, 31,199,199,243,243,249,249,253,253,252,252,254,254,254,254,
    254,254,254,254,252,252,253,253,249,249,243,243,199,199, 31, 31,
      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,
      0,  0, 63, 63, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 0, 0,
      0,  0, 63, 63, 12, 12, 12, 12, 12, 12, 12, 12, 63, 63, 0, 0,
      0,  0, 99, 99,119,119,127,127,107,107, 99, 99, 99, 99, 0, 0,
      0,  0, 51, 51, 51, 51, 30, 30, 12, 12, 12, 12, 12, 12, 0, 0
  );

  (* several backgrounds *)

  bkg_tiles = Background4 (4, 3, 2, 1);
  bkg_tiles2 = Background4 (0, 0, 0, 0);
  bkg_tiles3 = Background5 (7, 8, 9, 9, 10);

  (* sprite *)

  sprites = Sprites (
      7,  0, 31,  3, 63, 12,127, 16,127, 32,255, 32,255, 64,255, 64,
    255, 70,255, 73,255, 75,255, 70,255,  0,255,127,255,  6, 15,  0,
    224,  0,240,192,252, 48,254,  8,254,196,255, 36,255, 18,255, 18,
    255,210,255, 34,255, 98,255,194,255,  0,255,234,255,160,240, 0
  );

VAR      
  px1, py1: ARRAY 4 OF BYTE; pdx, pdy: ARRAY 4 OF INT8;
  i, j, x, y, px, py, winx, winy: BYTE; keys: SET;

BEGIN (*$MAIN*)
  gb.DisableInterrupts;
  gb.DISPLAY_OFF;

  hw.LCDC_REG := 67H;

  (* Set palettes *)
  hw.BGP_REG := 94;
  hw.OBP0_REG := 30;
  hw.OBP1_REG := 30;

  (* Initialise background *)
  gb.SetBkgData(0, 11, backwalls);

  FOR i := 0 TO 31 BY 2 DO
    FOR j := 0 TO 31 BY 2 DO
      IF ODD(i+j) THEN
        gb.SetBkgTiles(i, j, 2, 2, bkg_tiles);
      ELSE
        gb.SetBkgTiles(i, j, 2, 2, bkg_tiles2);
      END;
    END;
  END;
  gb.SetBkgTiles(14, 16, 5, 1, bkg_tiles3);

  (* Set Screen back to top left corner *)
  hw.SCX_REG := 0;
  hw.SCY_REG := 0;

  (* Push Sprite data to VRAM *)
  gb.SetSpriteData(0, 4, sprites);

  (* Regular sprites *)
  gb.SetSpriteTile(0, 0);
  gb.SetSpriteTile(1, 2);
  gb.MoveSprite(0, 8,   16);
  gb.MoveSprite(1, 8+8, 16);
  gb.SetSpriteProp(0, 0);
  gb.SetSpriteProp(1, 0);

  (* Y flipped sprites *)
  gb.SetSpriteTile(2, 0);
  gb.SetSpriteTile(3, 2);
  gb.MoveSprite(2, 8+16,   32);
  gb.MoveSprite(3, 8+16+8, 32);
  gb.SetSpriteProp(2, gb.S_FLIPY);
  gb.SetSpriteProp(3, gb.S_FLIPY);

  (* X flipped sprites *)
  (* Note: you have to flip the x positions of these 2 sprites too! *)
  gb.SetSpriteTile(4, 2);
  gb.SetSpriteTile(5, 0);
  gb.MoveSprite(4, 8+32+8, 48);
  gb.MoveSprite(5, 8+32,   48);
  gb.SetSpriteProp(4, gb.S_FLIPX);
  gb.SetSpriteProp(5, gb.S_FLIPX);

  gb.SetSpriteTile(6, 0);
  gb.SetSpriteTile(7, 2);
  gb.SetSpriteTile(8, 0);
  gb.SetSpriteTile(9, 2);

  winx := 7 + 40;
  winy := 128;
  hw.WX_REG := winx;
  hw.WY_REG := winy;
  gb.SetWinTiles(1, 1, 5, 1, bkg_tiles3);

  (* Ok! Done! *)
  (* Let's open the display again *)
  gb.DISPLAY_ON;
  gb.EnableInterrupts;

  x := 0; y := 0; px := 8; py := 16;

  px1[0] := 100; py1[0] :=  32; pdx[0] :=  1; pdy[0] := -2;
  px1[1] :=  64; py1[1] :=  80; pdx[1] :=  2; pdy[1] :=  2;
  px1[2] :=  32; py1[2] := 100; pdx[2] := -2; pdy[2] := -1;
  px1[3] := 140; py1[3] :=  64; pdx[3] := -1; pdy[3] :=  1;
  LOOP
    gb.WaitVblDone;

    keys := gb.JoyPad();

    IF gb.J_A IN keys THEN
      IF (gb.   J_UP IN keys) & (y>  0) THEN DEC(y) END;
      IF (gb. J_DOWN IN keys) & (y<128) THEN INC(y) END;
      IF (gb. J_LEFT IN keys) & (x>  0) THEN DEC(x) END;
      IF (gb.J_RIGHT IN keys) & (x<128) THEN INC(x) END;
    ELSIF gb.J_B IN keys THEN
      IF (gb.   J_UP IN keys) & (winy>  0) THEN DEC(winy, 2) END;
      IF (gb. J_DOWN IN keys) & (winy<160) THEN INC(winy, 2) END;
      IF (gb. J_LEFT IN keys) & (winx>  8) THEN DEC(winx, 2) END;
      IF (gb.J_RIGHT IN keys) & (winx<168) THEN INC(winx, 2) END;
    ELSE
      IF (gb.   J_UP IN keys) & (py>  0  ) THEN DEC(py, 2) END;
      IF (gb. J_DOWN IN keys) & (py<160  ) THEN INC(py, 2) END;
      IF (gb. J_LEFT IN keys) & (px>  0  ) THEN DEC(px, 2) END;
      IF (gb.J_RIGHT IN keys) & (px<160+8) THEN INC(px, 2) END;
    END;

    FOR j := 0 TO 3 DO
      INC(px1[j], pdx[j]);
      INC(py1[j], pdy[j]);
      IF px1[j] < 8      THEN pdx[j] := -pdx[j] END;
      IF px1[j] > 8+144  THEN pdx[j] := -pdx[j] END;
      IF py1[j] < 16     THEN pdy[j] := -pdy[j] END;
      IF py1[j] > 16+128 THEN pdy[j] := -pdy[j] END;
    END;

    gb.WaitVblDone;
    hw.SCX_REG := x;
    hw.SCY_REG := y;
    hw.WX_REG := winx;
    hw.WY_REG := winy;
    gb.MoveSprite(0, px,   py);
    gb.MoveSprite(1, px+8, py);
    FOR j := 0 TO 3 DO
      gb.MoveSprite(j*2+2, px1[j],   py1[j]);
      gb.MoveSprite(j*2+3, px1[j]+8, py1[j]);
    END;
  END (*LOOP*)

END Demo2.
