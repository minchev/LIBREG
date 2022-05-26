{**********************************}
{*                                *}
{*    Views unit (c) 1994         *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Views;
interface

type
  TPName = string[80];
  TView = object
    Upper, Lower : ^Byte;
    constructor Init(U, L : Byte);
    procedure InitDesktop(PrgName : TPName);               virtual;
    procedure InitStatusLine;                              virtual;
    procedure HighMode;                                    virtual;
    procedure LowMode;                                     virtual;
    destructor Done;
  end; { TDialog }

  var
    Scr : array[0..4000] of Byte absolute $B800:0000;
    ProgramName : TPName;

  procedure Cursor(Up,Down : Byte);
  procedure FullWin;
  function VideoAddr(X,Y : Byte) : Integer;

implementation
uses Crt, Dos, Colors;
const CloseBox = #212#213;

procedure FullWin;
begin { FullWin }
  Window(1,1,80,25);
end; { FullWin }

function VideoAddr;
begin { VideoAddr }
  VideoAddr := 160 * (Y - 1) + 2 * (X - 1);
end; { VideoAddr }

constructor TView.Init;
begin { TDialog.Init }
  Cursor(32,0);
    New(Upper); New(Lower);
    Upper^ := U; Lower^ := L;
end; { TDialog.Init }

procedure TView.InitDesktop;
var
  X,Y        : Byte;
  Dest       : Integer;
begin { TDialog.InitDesktop }
  for Y := 1 to 25 do
    for X := 1 to 80 do
      begin
        Dest := 160 * (Y-1) + 2 * (X-1);
        Scr[Dest] := Ord(#0);
        Scr[Dest+1] := 16 * Ord(_Color_string[2 * colDesktop]) +
          Ord(_Color_string[2 * colDesktop + 1]);
      end;
  ProgramName := PrgName;

    if ProgramName <> '' then
      begin
        Color(colMenuCloseBox);
        GotoXY(1,1); Write(CloseBox);
        Color(colProgram); ClrEol;
        GotoXY((80 - Length(ProgramName)) div 2,1);
        Write(ProgramName);
      end;
end; { TDialog.InitDesktop }

procedure TView.InitStatusLine;
begin { TDialog.InitStatusLine }
  Color(colMenuNormal);
  GotoXY(1,Upper^); ClrEol;
  GotoXY(1,Lower^); ClrEol;
end; { TDialog.InitStatusLine }

procedure TView.HighMode;
var Regs : Registers;
begin { TDialog.HighMode }
  Regs.AX := $1003; Regs.BL := $00;
    Intr($10,Regs);
end { TDialog.HighMode };

procedure TView.LowMode;
var Regs : Registers;
begin { TDialog.LowMode }
  Regs.AX := $1003; Regs.BL := $01;
    Intr($10,Regs);
end { TDialog.LowMode };

procedure Cursor;
var Regs : Registers;
begin { Cursor }
  Regs.AH := 01; Regs.CH := Up; Regs.CL := Down;
    Intr($10,Regs);
end; { Cursor }

destructor TView.Done;
begin { TDialog.Done }
  Dispose(Upper); Dispose(Lower);
end; { TDialog.Done }

begin { Desktop }
  Cursor(32,0);
end. { Desktop }
