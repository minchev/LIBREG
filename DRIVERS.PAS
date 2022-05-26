{**********************************}
{*                                *}
{*    Drivers unit (c) 1996       *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Drivers;
interface
type
  TMouse = record
    X, Y, Lx, Ly: Byte;
    Gx, Gy, Lgx, Lgy : Integer;
    Left, Right, Middle : Boolean;
  end; { TMouse }

const
  MouseCursor : array[-15..16] of Byte =
     ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
      $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF,$F8,$D8,$8C,$0C,$06,$06,$03,$03);

{$I FONT.PAS}

  { Event codes }

  evNoKeyEvent = $FFFF;

  { Extended key codes }

  kbEsc       = $011B;  kbAltSpace  = $0200;  kbCtrlIns   = $0400;
  kbShiftIns  = $0500;  kbCtrlDel   = $0600;  kbShiftDel  = $0700;
  kbBack      = $0E08;  kbCtrlBack  = $0E7F;  kbShiftTab  = $0F00;
  kbTab       = $0F09;  kbAltQ      = $1000;  kbAltW      = $1100;
  kbAltE      = $1200;  kbAltR      = $1300;  kbAltT      = $1400;
  kbAltY      = $1500;  kbAltU      = $1600;  kbAltI      = $1700;
  kbAltO      = $1800;  kbAltP      = $1900;  kbCtrlEnter = $1C0A;
  kbEnter     = $1C0D;  kbAltA      = $1E00;  kbAltS      = $1F00;
  kbAltD      = $2000;  kbAltF      = $2100;  kbAltG      = $2200;
  kbAltH      = $2300;  kbAltJ      = $2400;  kbAltK      = $2500;
  kbAltL      = $2600;  kbAltZ      = $2C00;  kbAltX      = $2D00;
  kbAltC      = $2E00;  kbAltV      = $2F00;  kbAltB      = $3000;
  kbAltN      = $3100;  kbAltM      = $3200;  kbF1        = $3B00;
  kbF2        = $3C00;  kbF3        = $3D00;  kbF4        = $3E00;
  kbF5        = $3F00;  kbF6        = $4000;  kbF7        = $4100;
  kbF8        = $4200;  kbF9        = $4300;  kbF10       = $4400;
  kbHome      = $4700;  kbUp        = $4800;  kbPgUp      = $4900;
  kbGrayMinus = $4A2D;  kbLeft      = $4B00;  kbRight     = $4D00;
  kbGrayPlus  = $4E2B;  kbEnd       = $4F00;  kbDown      = $5000;
  kbPgDn      = $5100;  kbIns       = $5200;  kbDel       = $5300;
  kbShiftF1   = $5400;  kbShiftF2   = $5500;  kbShiftF3   = $5600;
  kbShiftF4   = $5700;  kbShiftF5   = $5800;  kbShiftF6   = $5900;
  kbShiftF7   = $5A00;  kbShiftF8   = $5B00;  kbShiftF9   = $5C00;
  kbShiftF10  = $5D00;  kbCtrlF1    = $5E00;  kbCtrlF2    = $5F00;
  kbCtrlF3    = $6000;  kbCtrlF4    = $6100;  kbCtrlF5    = $6200;
  kbCtrlF6    = $6300;  kbCtrlF7    = $6400;  kbCtrlF8    = $6500;
  kbCtrlF9    = $6600;  kbCtrlF10   = $6700;  kbAltF1     = $6800;
  kbAltF2     = $6900;  kbAltF3     = $6A00;  kbAltF4     = $6B00;
  kbAltF5     = $6C00;  kbAltF6     = $6D00;  kbAltF7     = $6E00;
  kbAltF8     = $6F00;  kbAltF9     = $7000;  kbAltF10    = $7100;
  kbCtrlPrtSc = $7200;  kbCtrlLeft  = $7300;  kbCtrlRight = $7400;
  kbCtrlEnd   = $7500;  kbCtrlPgDn  = $7600;  kbCtrlHome  = $7700;
  kbAlt1      = $7800;  kbAlt2      = $7900;  kbAlt3      = $7A00;
  kbAlt4      = $7B00;  kbAlt5      = $7C00;  kbAlt6      = $7D00;
  kbAlt7      = $7E00;  kbAlt8      = $7F00;  kbAlt9      = $8000;
  kbAlt0      = $8100;  kbAltMinus  = $8200;  kbAltEqual  = $8300;
  kbCtrlPgUp  = $8400;  kbAltBack   = $0800;  kbNoKey     = $0000;
  kbShiftEnd  = $4F31;  kbShiftDown = $5032;  kbShiftPgDn = $5133;

  { User defined key codes }

  kbShiftLeft = $4B34;  kbShiftRght = $4D36;  kbShiftHome = $4737;
  kbShiftUp   = $4838;  kbShiftPgUp = $4939;  kbSpace     = $3920;

  { Keyboard state and shift masks }

  kbRightShift  = $0001;
  kbLeftShift   = $0002;
  kbCtrlShift   = $0004;
  kbAltShift    = $0008;
  kbScrollState = $0010;
  kbNumState    = $0020;
  kbCapsState   = $0040;
  kbInsState    = $0080;

{ Mouse button state masks }

  mbLeftButton   = $01;
  mbRightButton  = $02;
  mbMiddleButton = $04;

  procedure InitMouse; far;
  procedure InitClock; far;
  procedure InitScreen(HWidth : Byte); far;
  procedure InitScroll; far;
  procedure SetSystemFont; far;
  procedure SetROMFont; far;
  function GetEvent : Word;
  function GetKey : Char;

  procedure CLI; inline($FA);
  procedure STI; inline($FB);

  var MouseStatus, CyrillicStatus,
      ClockStatus, ScrollStatus : Boolean;
      Mouse : TMouse;

implementation
uses Crt, Dos, Colors, Math, Views;
const CrtStatus = $3DA;
var SaveMouse : array[0..1,0..1] of Byte;
    MouseFont : array[0..3,1..16] of Byte;
    KeyStatus : Byte absolute $0000:$0417;

procedure SetMouseCursor;
var Regs : Registers;
    M, N : Byte;
begin { SetMouseCursor }
  for M := 1 to 16 do
    begin
      N := (Mouse.Gy mod 16);
      MouseFont[0,M] := Font[SaveMouse[1,1],M] or
        (MouseCursor[M-N] shr (Mouse.Gx mod 8));
      MouseFont[1,M] := Font[SaveMouse[1,0],M] or
        (MouseCursor[M-N] shl (8 - (Mouse.Gx mod 8)));
      MouseFont[2,M] := Font[SaveMouse[0,1],M] or
        (MouseCursor[M+(16-N)] shr (Mouse.Gx mod 8));
      MouseFont[3,M] := Font[SaveMouse[0,0],M] or
        (MouseCursor[M+(16-N)] shl (8 - (Mouse.Gx mod 8)));
    end;

  Regs.AX := $1100;
  Regs.CX := 4;
  Regs.BP := Ofs(MouseFont);
  Regs.ES := Seg(MouseFont);
  Regs.DX := $D0;
  Regs.BL := $00;
  Regs.BH := $10;
   repeat until Port[CrtStatus] and 8 = 0;
   repeat until Port[CrtStatus] and 8 = 8;
   Intr($10,Regs);
end; { SetMouseCursor }

procedure InitMouse;
var Regs : Registers;
begin { InitMouse }
  Regs.AX := $0000; Intr($33,Regs);
  if Regs.AX <> 0 then MouseStatus := True;
end; { InitMouse }

procedure InitClock;
begin { SetMouseStatus }
  ClockStatus := True;
end; { SetClockStatus }

procedure InitScreen;
const Sequencer = $3C4;
var Regs : Registers;
    X    : Byte;
begin { InitScreen }
  if (HWidth = 8) then Regs.BX := $0001 else Regs.BX := $0800;
    X := Port[$3CC] and not(4+8);
  if (HWidth = 9) then X := X or 4;
    Port[$3C2] := X;

  CLI;
  PortW[Sequencer] := $0100;
  PortW[Sequencer] := $01 + Regs.BL shl 8;
  PortW[Sequencer] := $0300;
  STI;

  Regs.AX := $1000;
  Regs.BL := $13;
    Intr($10, Regs);
end; { InitScreen }

procedure InitScroll;
begin { InitScroll }
  ScrollStatus := True;
end; { InitScroll }

procedure SetSystemFont;
var Regs: Registers;
begin { SetSystemFont }
  Regs.AX := $1100;
  Regs.CX := 256;
  Regs.BP := Ofs(Font);
  Regs.ES := Seg(Font);
  Regs.DX := 0;
  Regs.BL := 0;
  Regs.BH := $10;
   Intr($10,Regs);
end; { SetSystemFont }

procedure SetROMFont;
var Regs : Registers;
begin { SetROMFont }
  Regs.AX := $1130;
  Regs.BH := $06;
    Intr($10,Regs);
  Regs.AX := $1100;
  Regs.CX := 256;
  Regs.DX := 0;
  Regs.BL := 0;
  Regs.BH := $10;
    Intr($10,Regs);
end; { SetROMFont }

function GetEvent;
var Regs : Registers;
    H, M, S, S100, lH, lM, lS, Key : Word;
    CurrTime, CV : string[8];
    LoKey : array[1..2] of Char absolute Key;
    I, J : Shortint;
    LastCyrillicStatus : Boolean;
    C : Byte;
begin { GetEvent }
  Mouse.Lgx := -1; Mouse.Lgy := -1;
  if MouseStatus then
    begin
      for I := Mouse.Ly to Mouse.Ly + 1 do
        for J := Mouse.Lx to Mouse.Lx + 1 do
          if (I > 0) and (I < 26) and (J > 0) and (J < 81) then
        SaveMouse[Mouse.Ly-I+1,Mouse.Lx-J+1] := Scr[VideoAddr(J,I)];
    end;

  repeat
  if ScrollStatus then
    if (kbScrollState and KeyStatus <> 0) then
      CyrillicStatus := True else CyrillicStatus := False;

  if ClockStatus then GetTime(H, M, S, S100);
  if MouseStatus then
    if (Mouse.Lgx <> Mouse.Gx) or (Mouse.Lgy <> Mouse.Gy) or
       (H <> lH) or (M <> lM) or (S <> lS) or
       (LastCyrillicStatus <> CyrillicStatus) then
        begin
          for I := Mouse.Ly to Mouse.Ly + 1 do
            for J := Mouse.Lx to Mouse.Lx + 1 do
              if (I > 0) and (I < 26) and (J > 0) and (J < 81) then
              Scr[VideoAddr(J,I)] := SaveMouse[Mouse.Ly-I+1,Mouse.Lx-J+1];
            Mouse.Lx := Mouse.X; Mouse.Ly := Mouse.Y;
        end;

  if ClockStatus then
    begin
      if (H <> lH) or (M <> lM) or (S <> lS) then
        begin
          CurrTime := '';
          Str(H,CV); if H < 10 then CurrTime := CurrTime + '0';
            if S mod 2 = 0 then CurrTime := CurrTime + CV + ':'
              else CurrTime := CurrTime + CV + ' ';
          Str(M,CV); if M < 10 then CurrTime := CurrTime + '0';
            CurrTime := CurrTime + CV;
          if not MouseStatus then begin lH := H; lM := M; lS := S; end;
          Color(colMenuNormal);
          for I := 1 to Length(CurrTime) do
            begin
              Scr[VideoAddr(74 + I, 2)] := Ord(CurrTime[I]);
              Scr[VideoAddr(74 + I, 2) + 1] := TextAttr;
            end;
        end;
   end;

   if ScrollStatus then
   if LastCyrillicStatus <> CyrillicStatus then
     begin
       Color(colMenuNormalHotkey);
       if CyrillicStatus then Scr[VideoAddr(80, 2)] := $2A
         else Scr[VideoAddr(80, 2)] := 32;
       Scr[VideoAddr(80, 2) + 1] := TextAttr;
       if not MouseStatus then LastCyrillicStatus := CyrillicStatus;
     end;

   if MouseStatus then
   if (Mouse.Lgx <> Mouse.Gx) or (Mouse.Lgy <> Mouse.Gy) or
      (H <> lH) or (M <> lM) or (S <> lS) or
      (LastCyrillicStatus <> CyrillicStatus) then
     begin
        for I := Mouse.Y to Mouse.Y + 1 do
         for J := Mouse.X to Mouse.X + 1 do
           if (I > 0) and (I < 26) and (J > 0) and (J < 81) then
         SaveMouse[Mouse.Ly-I+1,Mouse.Lx-J+1] := Scr[VideoAddr(J,I)];
         lH := H; lM := M; lS := S;
         LastCyrillicStatus := CyrillicStatus;
         SetMouseCursor;
         C := $D0;
         for I := Mouse.Y to Mouse.Y + 1 do
           for J := Mouse.X to Mouse.X + 1 do
             begin
               if (I > 0) and (I < 26) and (J > 0) and (J < 81) then
                 Scr[VideoAddr(J,I)] := C;
               Inc(C);
             end;
        Mouse.Lgx := Mouse.Gx;  Mouse.Lgy := Mouse.Gy;
      end;

  if MouseStatus then
    begin
      Regs.AX := $000B; Intr($33,Regs);
      Inc(Mouse.Gx,Regs.CX);
        if Mouse.Gx < 0 then Mouse.Gx := 0;
        if Mouse.Gx > 639 then Mouse.Gx := 639;
      Inc(Mouse.Gy,Regs.DX);
        if Mouse.Gy < 0 then Mouse.Gy := 0;
        if Mouse.Gy > 399 then Mouse.Gy := 399;
      Mouse.X := Succ(Mouse.Gx div 8);
      Mouse.Y := Succ(Mouse.Gy div 16);

      Regs.AX := $0005; Intr($33,Regs);
      if Regs.BX > 0 then Mouse.Left := True else Mouse.Left := False;
    end;

  until KeyPressed or Mouse.Left or Mouse.Right or Mouse.Middle;
  if KeyPressed then
    begin
      Regs.AH := $00; Intr($16,Regs);
      Key := Regs.AX;
      if CyrillicStatus then
        case LoKey[1] of
          '`' : LoKey[1] := '·'; '=' : LoKey[1] := '¾'; '/' : LoKey[1] := '»';
          '\' : LoKey[1] := '½'; 'q' : LoKey[1] := '¿'; 'w' : LoKey[1] := '¢';
          'e' : LoKey[1] := '¥'; 'r' : LoKey[1] := '°'; 't' : LoKey[1] := '²';
          'y' : LoKey[1] := 'º'; 'u' : LoKey[1] := '³'; 'i' : LoKey[1] := '¨';
          'o' : LoKey[1] := '®'; 'p' : LoKey[1] := '¯'; '[' : LoKey[1] := '¸';
          ']' : LoKey[1] := '¹'; 'a' : LoKey[1] := ' '; 's' : LoKey[1] := '±';
          'd' : LoKey[1] := '¤'; 'f' : LoKey[1] := '´'; 'g' : LoKey[1] := '£';
          'h' : LoKey[1] := 'µ'; 'j' : LoKey[1] := '©'; 'k' : LoKey[1] := 'ª';
          'l' : LoKey[1] := '«'; 'z' : LoKey[1] := '§'; 'x' : LoKey[1] := '¼';
          'c' : LoKey[1] := '¶'; 'v' : LoKey[1] := '¦'; 'b' : LoKey[1] := '¡';
          'n' : LoKey[1] := '­'; 'm' : LoKey[1] := '¬';

          '~' : LoKey[1] := '—'; '+' : LoKey[1] := 'ž'; '?' : LoKey[1] := '›';
          '|' : LoKey[1] := ''; 'Q' : LoKey[1] := 'Ÿ'; 'W' : LoKey[1] := '‚';
          'E' : LoKey[1] := '…'; 'R' : LoKey[1] := ''; 'T' : LoKey[1] := '’';
          'Y' : LoKey[1] := 'š'; 'U' : LoKey[1] := '“'; 'I' : LoKey[1] := 'ˆ';
          'O' : LoKey[1] := 'Ž'; 'P' : LoKey[1] := ''; '{' : LoKey[1] := '˜';
          '}' : LoKey[1] := '™'; 'A' : LoKey[1] := '€'; 'S' : LoKey[1] := '‘';
          'D' : LoKey[1] := '„'; 'F' : LoKey[1] := '”'; 'G' : LoKey[1] := 'ƒ';
          'H' : LoKey[1] := '•'; 'J' : LoKey[1] := '‰'; 'K' : LoKey[1] := 'Š';
          'L' : LoKey[1] := '‹'; 'Z' : LoKey[1] := '‡'; 'X' : LoKey[1] := 'œ';
          'C' : LoKey[1] := '–'; 'V' : LoKey[1] := '†'; 'B' : LoKey[1] := '';
          'N' : LoKey[1] := ''; 'M' : LoKey[1] := 'Œ';
        end;
      GetEvent := Key;
    end
  else GetEvent := evNoKeyEvent;

  if MouseStatus then
    begin
      for I := Mouse.Ly to Mouse.Ly + 1 do
        for J := Mouse.Lx to Mouse.Lx + 1 do
          if (I > 0) and (I < 26) and (J > 0) and (J < 81) then
        Scr[VideoAddr(J,I)] := SaveMouse[Mouse.Ly-I+1,Mouse.Lx-J+1];
    end;
end; { GetEvent }

function GetKey;
var Key : Word;
begin { GetKey }
  repeat
    Key := GetEvent;
  until Key <> evNoKeyEvent;
  GetKey := Chr(Lo(Key));
end; { GetKey }

begin { Drivers }
  MouseStatus := False; ClockStatus := False;
  CyrillicStatus := False; ScrollStatus := False;
  Mouse.Gx := 320; Mouse.Gy := 192;
  Mouse.X := 41; Mouse.Y := 13;
end. { Drivers }
