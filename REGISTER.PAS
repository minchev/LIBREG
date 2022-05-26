{*******************************************}
{*                                         *}
{*    Library Register Install (c) 1997    *}
{*    Momchil Hristov Minchev              *}
{*                                         *}
{*******************************************}

{$I-}
uses Crt, Colors, Dos, Strings, Lists, Menus, Views, Dialogs, Drivers, Windows, Lib;
var
  vwStruct  : TView;
  wnSystem  : TWindow;
  dgInstall : TDialog;
  Code      : Word;
  S1, S2    : string[45];
  F         : file;

procedure ReadLicence;
begin { ReadLicence }
  Assign(F, 'LIBREG.EXE');
  Reset(F, 1); if IOResult = 0 then
  Seek(F, $1E604); if IOResult = 0 then
  BlockRead(F, S1, SizeOf(S1)); if IOResult = 0 then
  Seek(F, $1E632); if IOResult = 0 then
  BlockRead(F, S2, SizeOf(S2)); if IOResult = 0 then
  Close(F);
end; { ReadLicence }

procedure WriteLicence;
begin { ReadLicence }
  Assign(F, 'LIBREG.EXE');
  Reset(F, 1); if IOResult = 0 then
  Seek(F, $1E604); if IOResult = 0 then
  BlockWrite(F, S1, SizeOf(S1)); if IOResult = 0 then
  Seek(F, $1E632); if IOResult = 0 then
  BlockWrite(F, S2, SizeOf(S2)); if IOResult = 0 then
  Close(F);
end; { ReadLicence }

procedure Quit; far;
begin { Quit }
  vwStruct.LowMode;
  vwStruct.Done;
  wnSystem.LoadBar(1,1,80,25); wnSystem.Done;
  SetROMFont;
  InitScreen(9);
  Cursor(7,8);
  Halt(0);
end; { Quit }

procedure Define;
begin { Define }
  CheckBreak := False;
  InitScreen(8);
  InitScroll;
  wnSystem.Init;
  wnSystem.SaveBar(1, 1, 80, 25);
  SetSystemFont;
  vwStruct.Init(2, 25);
  vwStruct.HighMode;
  vwStruct.InitDesktop('Å®°´®Æ≤•∑•≠ ∞•£®±≤∫∞ * ê•£®±≤∞†∂®ø');
  vwStruct.InitStatusLine;
  InitClock; InitMouse;
  Prog := Quit;
end; { Define }

begin { Struct }
  ReadLicence;
  if (S1 <> CharStr('B', 45)) or (S2 <> CharStr('C', 45)) then Halt(1);
  S1 := ''; S2 := '';
  Define;
  with dgInstall do
    begin
      Filter := '';
      Init(Primary, 'è†∞†¨•≤∞® ≠† Ø∞Æ£∞†¨†≤†', 13, 7, 67, 20, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~ê~•£®±≤∞®∞†©  ', nil, nil, 10, 11, 1, 1, True, True, kbAltR);
        SetItem('     àß~µ~Æ§     ', nil, nil, 28, 11, 1, 1, True, True, kbAltH);
      SetGroup(_txt, NormStr);
        SetItem('é≤£Æ¢Æ∞≠Æ ~´~®∂•'^L,
          nil, nil, 3, 2, 3, 1, True, True, kbNoKey);
        SetItem('~é~∞£†≠®ß†∂®ø'^L,
          nil, nil, 3, 5, 3, 1, True, True, kbNoKey);
      SetGroup(_str, NormStr);
        SetItem('', @S1, nil, 3, 3, 4, 1, True, True, kbAltL);
        SetItem('', @S2, nil, 3, 6, 4, 1, True, True, kbAltO);
      Code := ActiveDialog;
      if not ((Code = _Cancel) or ((Gr^ = 1) and (It^ = 2))) then
        WriteLicence;
      Done;
    end;
  Quit;
end. { Struct }