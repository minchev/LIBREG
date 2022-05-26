{**********************************}
{*                                *}
{*    Menu unit (c) 1994          *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Menus;
interface
uses Windows;
const
  maxItems = 48;
  maxElements = 10;
  Separator : string = #7#255;
  mvUp    = 1;
  mvDown  = 2;
  mvLeft  = 3;
  mvRight = 4;
  StatusLineRow = 25;

type
  Proc = procedure;
  Direction = (Vert, Horiz, Fict);
  MenuStr = string[78];
  TMenu = object
    Numb, M, Lm, X, Y : ^Byte;
    Dir : ^Direction;
    dgActive, dgCon : TWindow;
    Pos : array[1..maxItems] of ^Byte;
    ShortKeys : array[1..maxItems] of ^Word;
    Item, StatLine : array[1..maxItems] of ^MenuStr;
    IStatus : array[1..maxItems] of ^Boolean;
    constructor Define(D : Direction; Xp,Yp : Byte);
    procedure GetShortKeys; virtual;
    procedure SetItem(IStr, SStr : MenuStr; Butt : Word); virtual;
    procedure SetStatusLine; virtual;
    procedure SetStatus(N : Byte; Status : Boolean); virtual;
    procedure WriteItem(N, Xp, Yp : Byte; Status : Boolean); virtual;
    procedure WriteSeparator(N, Xp, Yp : Byte); virtual;
    procedure DrawBar; virtual;
    procedure InitMenu; virtual;
    function ActiveMenu(sbPred : TMenu) : Byte; virtual;
    destructor Destruct; virtual;
  end; { TMenu }

var
  Fictive, sbSystem : TMenu;
  Prog : Proc;   { You must connect Prog to your Halt procedure }

implementation
uses Crt, Colors, Drivers, Views, Strings;

function RealSize(S : string) : Byte;
var Lng,Index : Byte;
begin { RealSize }
  Lng := 0;
  for Index := 1 to Length(S) do
    begin
      if S[Index] <> '~' then Inc(Lng);
    end;
  RealSize := Lng;
end; { RealSize }

constructor TMenu.Define;
begin { TMenu.Define }
  New(Numb); Numb^ := 0;
  New(X); X^ := Xp; New(Y); Y^ := Yp;
  New(M); New(Lm); M^ := 1; Lm^ := 1;
  New(Dir); Dir^ := D;
  dgActive.Init; dgCon.Init;
end; { TMenu.Define }

procedure TMenu.GetShortKeys;
var HighLight : Boolean;
    I, J : Byte;
    S : string;
begin { TMenu.GetShortKeys }
  for I := 1 to Numb^ do
    begin { ShortKeys }
      if ShortKeys[I]^ = evNoKeyEvent then
        begin
          S := Item[I]^; HighLight := False;
            for J := 1 to Length(S) do
              begin
                if S[J] = '~' then HighLight := not(HighLight);
                if HighLight and (S[J] <> '~') then
                  Inc(ShortKeys[I]^,Ord(S[J]));
             end;
           if ShortKeys[I]^ <> evNoKeyEvent then Inc(ShortKeys[I]^);
        end;
    end; { ShortKeys }
end; { TMenu.GetShortKeys }

procedure TMenu.SetItem;
begin { TMenu.SetItem }
  if Numb^ < maxItems then
    begin
      Inc(Numb^);
      New(Pos[Numb^]); Pos[Numb^]^ := 0;
      New(Item[Numb^]); Item[Numb^]^ := IStr;
      New(StatLine[Numb^]); StatLine[Numb^]^ := SStr;
        New(ShortKeys[Numb^]);
      New(IStatus[Numb^]); IStatus[Numb^]^ := True;
      if Butt <> kbNoKey then ShortKeys[Numb^]^ := Butt
        else ShortKeys[Numb^]^ := evNoKeyEvent;
      if Item[Numb^]^ = SEPARATOR then SetStatus(Numb^, False);
    end;
end; { TMenu.SetItem }

procedure TMenu.SetStatusLine;
begin { TMenu.SetStatLine }
  Color(colMenuNormal);
  GotoXY(1,StatusLineRow); Write(StatLine[M^]^); ClrEol;
end; { TMenu.SetStatLine }

procedure TMenu.WriteItem;
var HighLight : Boolean;
    S : string;
    DFAttr, DBAttr, I : Byte;
begin { TMenu.WriteItem }
  HighLight := False;
  S := Item[N]^;  GotoXY(Xp,Yp);
  for I := 1 to Length(S) do
    begin
      if S[I] = '~' then HighLight := not(HighLight);
      if HighLight then
        begin
          if Status then
            TextColor(Ord(_Color_string[2*colMenuSelectedHotkey])) else
            TextColor(Ord(_Color_string[2*colMenuNormalHotkey]));
        end else begin
          if Status then
            TextColor(Ord(_Color_string[2*colMenuSelected]))
            else TextColor(Ord(_Color_string[2*colMenuNormal]));
        end;
        if Status then
          TextBackground(Ord(_Color_string[2*colMenuSelected+1]))
          else TextBackground(Ord(_Color_string[2*colMenuNormal+1]));
        if not IStatus[N]^ then
          begin
            DFAttr := Ord(_Color_string[2*colMenuDisabledItem]);
            if Status then
              DBAttr := Ord(_Color_string[2*colMenuSelected])
            else DBAttr := Ord(_Color_string[2*colMenuNormal]);
              if DBAttr > 127 then
                begin if DFAttr < 128 then Inc(DFAttr, Blink) end
              else
                begin if DFAttr > 127 then Dec(DFAttr, Blink); end;
            TextColor(DFAttr);
          end;
      if S[I] <> '~' then Write(S[I]);
    end;
end; { TMenu.WriteItem }

procedure TMenu.SetStatus;
begin { TMenu.SetStatus }
  IStatus[N]^ := Status;
end; { TMenu.SetStatus }

procedure TMenu.WriteSeparator;
var J : Byte;
begin { TMenu.WriteSeparator }
  FullWin;
  Color(colMenuNormal);
  GotoXY(Xp,Yp); Write(#202);
    for J := 1 to RealSize(Item[1]^) do
      Write(#206);
  Write(#197);
end; { TMenu.WriteSeparator }

procedure TMenu.DrawBar;
begin { TMenu.DrawBar }
  FullWin;
  case Dir^ of
    Horiz : begin { Horiz }
              SetStatusLine;
              WriteItem(Lm^,X^+Pos[Lm^]^,Y^,False);
              WriteItem(M^,X^+Pos[M^]^,Y^,True);
            end; { Horiz }
     Vert : begin { Vert }
              SetStatusLine;
              WriteItem(Lm^,X^+1,Y^+Lm^,False);
              WriteItem(M^,X^+1,Y^+M^,True);
            end; { Vert }
  end; { case }
end; { TMenu.DrawBar }

procedure TMenu.InitMenu;
var I, J, L : Byte;
    S : string;
begin { TMenu.InitMenu }
  if Dir^ = Horiz then
    begin
      Pos[1]^ := 1;
        for I := 2 to Numb^ do
          begin
            Pos[I]^ := Pos[I-1]^;
            Inc(Pos[I]^,RealSize(Item[Pred(I)]^)+2);
           end;
        for I := 1 to Numb^ do
      WriteItem(I,X^+Pos[I]^,Y^,False);
    end;
    if Dir^ = Vert then
      begin
        L := RealSize(Item[1]^);
          for I := 2 to Numb^ do
            if RealSize(Item[I]^) > L then L := RealSize(Item[I]^);
          for I := 1 to Numb^ do
            begin
              if RealSize(Item[I]^) < L then
                for J := 1 to (L-RealSize(Item[I]^)) do
                  if Item[I]^ <> SEPARATOR then Item[I]^ := Item[I]^ + #32;
            end;
      end;
  GetShortKeys;
end; { TMenu.InitMenu }

function TMenu.ActiveMenu;
var
  Key : Word;
  E, I, J : Byte;
begin { TMenu.ActiveMenu }
  case Dir^ of
    Horiz : begin
              repeat
                DrawBar; Key := GetEvent;
                if (Key = evNoKeyEvent) and (ProgramName <> '') and
                  (((Mouse.X = 1) or (Mouse.X = 2)) and (Mouse.Y = 1)) then
                  begin
                    sbSystem.X^ := 1; sbSystem.Y^ := 2;
                    sbSystem.Item[1]^ := ' И~з~╡од о▓ ' + ProgramName + ' ';
                    if sbSystem.ActiveMenu(Fictive) = mvDown then
                      if sbSystem.M^ = 1 then Prog;
                  end;

                  for I := 1 to Numb^ do
                    begin
                      if ((Key = ShortKeys[I]^) and IStatus[I]^) or
                         ((Key = evNoKeyEvent) and
                         (Mouse.Y = Y^) and
                         ((Mouse.X >= Pos[I]^+ X^) and
                         (Mouse.X < Pos[I]^+X^+RealSize(Item[I]^)))) then
                        begin
                          J := Pos[I]^ + RealSize(Item[I]^);
                          Lm^ := M^; M^ := I; DrawBar;
                          ActiveMenu := mvDown; Exit;
                        end;
                    end;

                case Key of
                  kbLeft : begin
                             Lm^ := M^; Dec(M^);
                             if M^ < 1 then M^ := Numb^;
                           end;
                  kbRight : begin
                              Lm^ := M^; Inc(M^);
                              if M^ > Numb^ then M^ := 1;
                            end;
                  kbEsc : begin
                            ActiveMenu := mvUp; Exit;
                          end;
                  kbEnter, kbDown : begin
                                      if IStatus[M^]^ then
                                        begin
                                          ActiveMenu := mvDown; Exit;
                                        end;
                                    end;
                end;
              until (Key = kbEsc) or (Key = kbEnter) or (Key = kbDown);
            end;

    Vert : begin
             if sbPred.Dir^ = Vert then
               begin
                 FullWin;
                   dgCon.DefineWindow(sbPred.X^, sbPred.Y^, sbPred.X^ +
                   RealSize(sbPred.Item[1]^) + 1, sbPred.Y^ + sbPred.Numb^ +
                   1, '', colMenuNormal);
                   dgCon.OpenWindow; FullWin;
                 for I := 1 to sbPred.Numb^ do
                   begin
                     if sbPred.Item[I]^ <> SEPARATOR then
                       sbPred.WriteItem(I,sbPred.X^+1,sbPred.Y^+I,False)
                     else sbPred.WriteSeparator(I,sbPred.X^,sbPred.Y^+I);
                   end;
                   sbPred.DrawBar;
                end;

  dgActive.DefineWindow(X^,Y^,X^+RealSize(Item[1]^)+1, Y^+Numb^+1,'',
    colMenuNormal); dgActive.OpenWindow;  FullWin;

             for I := 1 to Numb^ do
               begin
                 if Item[I]^ <> SEPARATOR then
                   WriteItem(I,X^+1,Y^+I,False)
                 else WriteSeparator(I,X^,Y^+I);
               end;

             repeat
               DrawBar; Key := GetEvent;
               if (Key = evNoKeyEvent) and
                  (Item[Mouse.Y-Y^]^ <> SEPARATOR) and
                  ((Mouse.Y >= Y^+1) and (Mouse.Y <= Y^+Numb^)) and
                  ((Mouse.X >= X^) and
                  ((Mouse.X <= X^+RealSize(Item[1]^)))) and
                   IStatus[Mouse.Y-Y^]^ then
                 begin
                   Lm^ := M^; M^ := Mouse.Y - Y^;
                   DrawBar; ActiveMenu := mvDown;
                   dgActive.CloseWindow;
                     if sbPred.Dir^ = Vert then
                   dgCon.CloseWindow;
                   Exit;
                 end;

               for I := 1 to Numb^ do
                 begin
                   if (UpStr(Chr(Lo(Key))) = UpStr(Chr(ShortKeys[I]^))) and
                      IStatus[I]^ then
                     begin
                       Lm^ := M^; M^ := I;
                       DrawBar; ActiveMenu := mvDown;
                       dgActive.CloseWindow;
                         if sbPred.Dir^ = Vert then
                           dgCon.CloseWindow;
                       Exit;
                     end;
                 end;

              if Key = evNoKeyEvent then
                case sbPred.Dir^ of
                  Horiz : begin
                            for I := 1 to sbPred.Numb^ do
                              if (Mouse.Y = sbPred.Y^) and
                                 ((Mouse.X >= sbPred.Pos[I]^+sbPred.X^) and
                                 (Mouse.X < sbPred.Pos[I]^+sbPred.X^+
                                  RealSize(sbPred.Item[I]^))) then
                              begin
                                sbPred.Lm^ := sbPred.M^; sbPred.M^ := I; sbPred.DrawBar;
                                ActiveMenu := mvLeft;
                                dgActive.CloseWindow;
                                    if sbPred.Dir^ = Vert then
                                  dgCon.CloseWindow; Exit;
                              end;
                          end;
                  Vert : if ((Mouse.X >= sbPred.X^+1) and
                              (Mouse.X <= sbPred.X^+RealSize(Item[1]^)) and
                              ((Mouse.Y >= sbPred.Y^+1) and
                              (Mouse.Y <= sbPred.Y^+Numb^))) then
                                begin
                                  sbPred.Lm^ := sbPred.M^;
                                  sbPred.M^ := Mouse.Y-Y^;
                                  sbPred.DrawBar; ActiveMenu := mvLeft;
                                  dgActive.CloseWindow;
                                    if sbPred.Dir^ = Vert then
                                  dgCon.CloseWindow;
                                  Exit;
                                end;
                end else
                 for I := 1 to sbPred.Numb^ do
                   begin
                     if (Key = sbPred.ShortKeys[I]^) and
                         sbPred.IStatus[I]^ then
                       begin
                         dgActive.CloseWindow;
                           if sbPred.Dir^ = Vert then
                             dgCon.CloseWindow;
                             ActiveMenu := mvLeft;
                             sbPred.Lm^ := sbPred.M^; sbPred.M^ := I;
                             sbPred.DrawBar;
                           Exit;
                       end;
                   end;

          if Key <> evNoKeyEvent then
             case Key of
               kbUp : begin
                        Lm^ := M^;
                        repeat
                          Dec(M^); if M^ < 1 then M^ := Numb^;
                        until Item[M^]^ <> SEPARATOR;
                      end;
               kbDown : begin
                          Lm^ := M^;
                          repeat
                            Inc(M^); if M^ > Numb^ then M^ := 1;
                          until Item[M^]^ <> SEPARATOR;
                        end;
               kbLeft : begin
                          if sbPred.Dir^ = Horiz then
                            begin
                              sbPred.Lm^ := sbPred.M^;
                              Dec(sbPred.M^);
                                if sbPred.M^ < 1 then
                              sbPred.M^ := sbPred.Numb^;
                              sbPred.DrawBar;
                            end;
                            dgActive.CloseWindow;
                              if sbPred.Dir^ = Vert then
                                dgCon.CloseWindow;
                            ActiveMenu := mvLeft; Exit;
                        end;
               kbRight : begin
                           if sbPred.Dir^ = Horiz then
                             begin
                               sbPred.Lm^ := sbPred.M^;
                               Inc(sbPred.M^);
                               if sbPred.M^ > sbPred.Numb^ then
                                 sbPred.M^ := 1;
                               sbPred.DrawBar;
                             end;
                           dgActive.CloseWindow;
                           if sbPred.Dir^ = Vert then
                             dgCon.CloseWindow;
                           ActiveMenu := mvRight; Exit;
                         end;
               kbEnter : begin
                           dgActive.CloseWindow;
                             if sbPred.Dir^ = Vert then
                               dgCon.CloseWindow;
                             if IStatus[M^]^ then ActiveMenu := mvDown
                               else ActiveMenu := mvUp;
                            Exit;
                          end;
               kbEsc : begin
                         dgActive.CloseWindow;
                         if sbPred.Dir^ = Vert then
                           dgCon.CloseWindow;
                         ActiveMenu := mvUp; Exit;
                       end;
                     end else
                   begin
                     dgActive.CloseWindow;
                     if sbPred.Dir^ = Vert then
                       dgCon.CloseWindow;
                     ActiveMenu := mvUp; Exit;
                   end;

             until (Key = kbEnter) or (Key = kbLeft) or
                   (Key = kbRight) or (Key = kbEsc);
           end;
  end; { case }
end; { TMenu.ActiveMenu }

destructor TMenu.Destruct;
var I : Byte;
begin { TMenu.Destruct }
  for I := 1 to Numb^ do
    begin
      Dispose(Pos[I]); Dispose(Item[I]);
      Dispose(ShortKeys[I]); Dispose(StatLine[I]);
    end;
  Dispose(Numb); Dispose(X); Dispose(Y); Dispose(M); Dispose(Lm);
  dgActive.Done; dgCon.Done;
end; { TMenu.Destruct }

begin { Menus }
  Fictive.Define(Fict,0,0);
  sbSystem.Define(Vert,1,2);
    sbSystem.SetItem(' ~З~а▓во░и диалога ',
      ' Из╡од о▓ диалога', kbNoKey);
  sbSystem.InitMenu;
end. { Menus }
