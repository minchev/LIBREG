{**********************************}
{*                                *}
{*    Dialogs unit (c) 1996       *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Dialogs;
interface
uses Lists, Menus, Windows;
const
  CloseBox        = #212#213;
  OptionButtonOff = #214#215;
  OptionButtonOn  = #216#217;
  RadioButtonOff  = #218#219;
  RadioButtonOn   = #220#221;
  VertScrollBar   = #203#196;
  HorzScrollBar   = #20#20;
  LeftArrow       = #16#17;
  RightArrow      = #18#19;
  UpArrow         = #1#2;
  DownArrow       = #3#4;

  maxGroups = 50;
  maxItems = 100;

  _Move   = $FFFD;
  _Cancel = $FFFE;
  _Accept = $FFFF;

  { Help file }

  HelpFile : string[12] = '';

type
  PProc = ^TProc;
  TProc = procedure;
  PString = ^string;
  DialogStr = string[80];
  TStrings = (NormStr, PassStr, NumbStr);
  TDialogs = (Primary, Secondary, Alert, Help);
  TDialogsItem = (_txt, _box, _rbt, _obt, _str, _but, _fil, _lst);

  TDialogGroup = array[1..maxGroups] of ^TDialogsGroup;
  TDialogsGroup = record
    Item : array[1..maxItems] of ^DialogStr;
    X1, Y1, X2, Y2 : array[1..maxItems] of ^Byte;
    Switch, Status : array[1..maxItems] of ^Boolean;
    Shortkey : array[1..maxItems] of ^Word;
    Prog : array[1..maxItems] of PProc;
    Data : array[1..maxItems] of PString;
    M, N, P, H : array[1..maxItems] of ^Word;
    FileList : array[1..maxItems] of PFList;
    StrList : array[1..maxItems] of PSList;
    Numb : ^Byte;
    Kind : ^TDialogsItem;
    StrKind : ^TStrings;
  end; { TDialogsGroup }

  TDialog = object
    Numb, Gr, LGr, It, LIt : ^Byte;
    PKind : ^TDialogs;
    PWindow : ^TWindow;
    wX1, wY1, wX2, wY2 : ^Byte;
    Dialog : ^TDialogGroup;
    PHelp : ^Integer;
    constructor Init(Kindp : TDialogs; _Name : string;
      X1p, Y1p, X2p, Y2p : Byte; HLP : Byte);
    function EnterStr(var S : string; X, Y, Lng, Col : Byte;
      Kind : TStrings) : Word; virtual;
    function SelectFile(GV, IV : Byte; lKey : Word) : Word; virtual;
    function SelectStr(GV, IV : Byte; lKey : Word) : Word; virtual;
    procedure SetGroup(KindD : TDialogsItem; SKind : TStrings); virtual;
    procedure SetItem(_Name : DialogStr; Data : Pointer; Prog : Pointer;
      X1p, Y1p, X2p, Y2p : Byte; Switch, Status : Boolean; Shortkey : Word);
      virtual;
    procedure WriteItem(S : string; Switch, Status: Boolean); virtual;
    procedure WriteButton(S : string; Status : Boolean); virtual;
    function ActiveDialog : Word; virtual;
    procedure InitDialog(GV, IV : Byte); virtual;
    procedure HelpDialog; virtual;
    destructor Done; virtual;
  end; { TDialog }

implementation
uses Crt, Dos, Colors, Errors, Drivers, Strings, Views;

function DialogColor(Kind : TDialogs; Col : Byte) : Byte;
var Offset : Byte;
begin { DialogColor }
  case Kind of
    Primary : Offset := 0;
    Secondary : Offset := 8;
    Alert : Offset := 16;
    Help : Offset := 24;
  end;
  Color(Col + Offset);
  DialogColor := Col + Offset;
end; { DialogColor }

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

procedure TDialog.WriteItem;
var
  HighLight : Boolean;
  I, Offset : Byte;
begin { TDialog.WriteItem }
  HighLight := False;
    case PKind^ of
      Primary : Offset := 0;
      Secondary : Offset := 8;
      Alert : Offset := 16;
      Help : Offset := 24;
    end;

  for I := 1 to Length(S) do
    begin
      if S[I] = '~' then HighLight := not(HighLight);
      if HighLight then
        begin
        if Status then
          TextColor(Ord(_Color_string[2*(colDialogBright+Offset)]))
        end
        else begin
          if Status then
            TextColor(Ord(_Color_string[2*(colDialogNormal+Offset)]))
            else TextColor(Ord(_Color_string[2*(colDialogNormal+Offset)]));
        end;
        if Status then
          TextBackground(Ord(_Color_string[2*(colDialogNormal+Offset)+1]))
          else TextBackground(Ord(_Color_string[2*(colDialogNormal+Offset)+1]));
        if not Status then
          TextColor(Ord(_Color_string[2*(colDialogDisabled+Offset)]));
      if S[I] <> '~' then Write(S[I]);
    end;
end; { TDialog.WriteItem }

procedure TDialog.WriteButton;
var
  HighLight : Boolean;
  I : Byte;
begin { TDialog.WriteButton }
  HighLight := False;
  for I := 1 to Length(S) do
    begin
      if S[I] = '~' then HighLight := not(HighLight);
      if HighLight then
        begin
          if Status then
            TextColor(Ord(_Color_string[2*colButtonHotkeyActive])) else
            TextColor(Ord(_Color_string[2*colButtonHotkeyInactive]));
        end else begin
          if Status then
            TextColor(Ord(_Color_string[2*colButtonActive]))
            else TextColor(Ord(_Color_string[2*colButtonInactive]));
        end;
        if Status then
          TextBackground(Ord(_Color_string[2*colButtonActive+1]))
          else TextBackground(Ord(_Color_string[2*colButtonInactive+1]));
      if S[I] <> '~' then Write(S[I]);
    end;
end; { TDialog.WriteButton }

constructor TDialog.Init;
begin { TDialog.Init }
  New(Numb); Numb^ := 0; New(PHelp); PHelp^ := HLP;
  New(Gr); Gr^ := 0; New(LGr); LGr^ := 0;
  New(It); It^ := 0; New(LIt); LIt^ := 0;
  New(PKind); New(PWindow); PWindow^.Init;
  PKind^ := KindP;
  New(wX1); New(wY1); New(wX2); New(wY2);
  wX1^ := X1p; wY1^ := Y1p; wX2^ := X2p; wY2^ := Y2p;
  New(Dialog);
    case PKind^ of
      Primary : PWindow^.DefineWindow
                  (wX1^, wY1^, wX2^, wY2^, _Name, colDialogNormal);
      Secondary : PWindow^.DefineWindow
                    (wX1^, wY1^, wX2^, wY2^, _Name, colSDialogNormal);
      Alert : PWindow^.DefineWindow
                (wX1^, wY1^, wX2^, wY2^, _Name, colADialogNormal);
      Help : PWindow^.DefineWindow
                (wX1^, wY1^, wX2^, wY2^, _Name, colHDialogNormal);
    end;
  PWindow^.OpenWindow; FullWin;
end; { TDialog.Init }

function TDialog.EnterStr;
var
  C, H, I, J, L, R : Byte;
  Key : Word;
  Flag, Coma, Sign, Placed : Boolean;
begin { TDialog.EnterStr }
  Dec(Lng);
  Cursor(7,8); Color(Col);
  GotoXY(X, Y); Write(CharStr(#250, Lng + 1));
  Flag := False;

  S := Copy(S, 1 , Lng);
  L := Length(S);
  I := L + 1; J := I;

  Cursor(7,8); H := Length(Copy(S,Succ(Lng),L));

repeat
  L := Length(S);
  H := Length(Copy(S,Succ(Lng),L));

  Color(Col); GotoXY(X, Y);
    case Kind of
      NormStr, NumbStr : Write(Copy(S, 1, Lng));
      PassStr : Write(CharStr('*', Length(Copy(S, 1, Lng))));
    end;
  if H = 0 then Write(#250);

  GotoXY(X + I - 1, Y);

  Key := GetEvent;
  if (Key = evNoKeyEvent) then
    begin
      if ((Mouse.X >= X) and (Mouse.X <= X + Lng)) and
         (Mouse.Y = Y) then
          begin
            if (Mouse.X - X <= Lng + 1) and (Mouse.X - X <= L) then
              begin
                I := Mouse.X - X + 1; J := Mouse.X - X + 1;
              end else
            begin if (Mouse.X - X > L) then Key := kbEnd; end;
          end else
            begin
              EnterStr := Key; Cursor(32, 0); Exit;
            end;
    end;

  if (Key <> evNoKeyEvent) then
  case Key of
    kbBack : begin
               if I - 1 >= 1 then Dec(I);
               if J - 1 >= 1 then
                 begin
                   Dec(J); Delete(S, J, 1);
                   GotoXY(X + I - 1, Y); Write(#250);
                 end;
               end;
    kbDel : if J <= L then Delete(S, J, 1);
    kbLeft : begin
               if I - 1 >= 1 then Dec(I);
               if J - 1 >= 1 then Dec(J);
             end;
    kbRight : begin
               if (I + 1 <= Lng + 1) and (I + 1 <= Succ(L)) then Inc(I);
               if J <= L then Inc(J);
             end;
    kbHome : begin
               I := 1; J := 1;
             end;
    kbEnd : begin
              I := L + 1; J := I;
            end;
    kbF1 : begin HelpDialog; Cursor(7, 8); end;
  end else Key := kbNoKey;
    if (Key <> evNoKeyEvent) then
    case Lo(Key) of
      32..191 : begin
                  case Kind of
                    NormStr, PassStr : begin
                      if (J <= Lng) and (L < Lng) then
                        begin
                          Insert(Chr(Lo(Key)), S, J);
                          if I + 1 <= Lng + 1 then Inc(I);
                          if J + 1 <= Lng + 1 then Inc(J);
                        end;
                    end; { NormStr }

                    NumbStr : begin
                      Placed := False;
                      if Lo(Key) in [43 ,45..46, 48..57] then
                      if (J <= Lng) and (L < Lng) then
                        begin
                          Coma := False; Sign := False;
                          if Lo(Key) in [43 ,45..46] then
                            for C := 1 to Length(S) do
                              begin
                                if Ord(S[C]) = 46 then Coma := True;
                                if Ord(S[C]) in [43, 45] then Sign := True;
                              end;

                    if ((J = 1) and (Lo(Key) in [43, 45]) and not(Sign)) then
                      begin Insert(Chr(Lo(Key)), S, J); Placed := True; end;

                    if (not(Coma) and (Ord(S[J-1]) in [48..57]) and (J > 1)
                      and (Lo(Key) = 46)) then
                      begin Insert(Chr(Lo(Key)), S, J); Placed := True; end;

                    if (Lo(Key) in [48..57]) then
                      begin Insert(Chr(Lo(Key)), S, J); Placed := True; end;

                         if Placed then
                            begin
                              if I + 1 <= Lng + 1 then Inc(I);
                              if J + 1 <= Lng + 1 then Inc(J);
                            end;

                        end;
                    end; { NumbStr }
                  end;
                end;
  end { case };

    for R := 1 to Numb^ do
      for C := 1 to Dialog^[R]^.Numb^ do
        if (Dialog^[R]^.Shortkey[C]^ = Key) and
           (Dialog^[R]^.Shortkey[C]^ <> kbNoKey) then Flag := True;

until (Key=kbEnter) or (Key=kbEsc) or (Key=kbTab) or (Key=kbShiftTab) or
      (Key=kbUp) or (Key=kbDown) or Flag;
  EnterStr := Key;
  Cursor(32, 0);
end { TDialog.EnterStr };

procedure TDialog.SetGroup;
var I : Byte;
begin { TDialog.SetGroup }
  if Numb^ < maxGroups then
    begin
      Inc(Numb^);
      New(Dialog^[Numb^]);
      New(Dialog^[Numb^]^.Numb); Dialog^[Numb^]^.Numb^ := 0;
      New(Dialog^[Numb^]^.Kind); Dialog^[Numb^]^.Kind^ := KindD;
      New(Dialog^[Numb^]^.StrKind); Dialog^[Numb^]^.StrKind^ := SKind;
      for I := 1 to maxItems do
        begin
          Dialog^[Numb^]^.Data[I] := nil;
          Dialog^[Numb^]^.Shortkey[I] := nil;
        end;
    end;
end; { TDialog.SetGroup }

procedure TDialog.SetItem;
var
  I, E : Byte;
  S1, S2 : string;
begin { TDialog.SetItem }
  if Dialog^[Numb^]^.Numb^ < maxItems then
    begin
      Inc(Dialog^[Numb^]^.Numb^); E := Dialog^[Numb^]^.Numb^;
        New(Dialog^[Numb^]^.Item[E]); Dialog^[Numb^]^.Item[E]^ := _Name;
        New(Dialog^[Numb^]^.X1[E]); Dialog^[Numb^]^.X1[E]^ := X1p;
        New(Dialog^[Numb^]^.Y1[E]); Dialog^[Numb^]^.Y1[E]^ := Y1p;
        New(Dialog^[Numb^]^.X2[E]); Dialog^[Numb^]^.X2[E]^ := X2p;
        New(Dialog^[Numb^]^.Y2[E]); Dialog^[Numb^]^.Y2[E]^ := Y2p;
        Dialog^[Numb^]^.Data[E] := Data; Dialog^[Numb^]^.Prog[E] := Prog;
        New(Dialog^[Numb^]^.Switch[E]); Dialog^[Numb^]^.Switch[E]^ := Switch;
        New(Dialog^[Numb^]^.Status[E]); Dialog^[Numb^]^.Status[E]^ := Status;
        New(Dialog^[Numb^]^.Shortkey[E]); Dialog^[Numb^]^.Shortkey[E]^ :=
          Shortkey;
        New(Dialog^[Numb^]^.M[E]); New(Dialog^[Numb^]^.N[E]);
        New(Dialog^[Numb^]^.P[E]); New(Dialog^[Numb^]^.H[E]);
          with Dialog^[Numb^]^ do
            begin M[E]^ := 1; N[E]^ := 1; P[E]^ := 1; H[E]^ := 1; end;
        NewFList(Dialog^[Numb^]^.FileList[E]);
        Str(E, S1); if E < 10 then S1 := '0' + S1;
        Str(Numb^, S2); if E < 10 then S2 := '0' + S2;
        NewSList(Dialog^[Numb^]^.StrList[E], S1 + S2);
    end;
end; { TDialog.SetItem }

procedure TDialog.InitDialog;
type
  Box_rec = record
    UL, UR, LL, LR, Horiz, Vert : Char;
  end;
const Boxes : Box_rec =
  (UL : #7; UR : #9; LL : #12; LR : #11;
   Horiz : #8; Vert : #10);
var
  Dest : Word;
  K, B, L : Byte;
  S1, S2 : DialogStr;
  S : string;
begin { TDialog.InitDialog }
  FullWin;
  case Dialog^[GV]^.Kind^ of
    _txt :  begin
      DialogColor(PKind^,colDialogNormal);
      K := 0; B := 0;
      S1 := Dialog^[GV]^.Item[IV]^;
      repeat
        S2 := ''; Inc(K);
        while ((S1[K] <> ^C) and (S1[K] <> ^L) and
              (S1[K] <> ^R)) and (K < Length(S1)) do
          begin
            S2 := S2 + S1[K]; Inc(K);
          end;
          with Dialog^[GV]^ do
            case S1[K] of
              ^C : GotoXY((wX1^+((wX2^-wX1^+1) -
                   RealSize(S2)) div 2), wY1^+Y1[IV]^+B);
              ^L : GotoXY(wX1^+X1[IV]^, wY1^+Y1[IV]^+B);
              ^R : GotoXY(wX1^+((wX2^-wX1^) - RealSize(S2)) - X2[IV]^,
                         wY1^+Y1[IV]^ + B);
            end;
          WriteItem(S2, Dialog^[GV]^.Switch[IV]^, Dialog^[GV]^.Status[IV]^);
          Inc(B);
      until K >= Length(S1);
    end;
    _box : begin
      with Dialog^[GV]^ do
        begin
          DialogColor(PKind^,colDialogNormal);
          Dest := VideoAddr(wX1^+X1[IV]^, wY1^+Y1[IV]^);
          Scr[Dest] := Ord(Boxes.UL); Scr[Dest+1] := TextAttr;
          Dest := VideoAddr(wX2^-X2[IV]^, wY1^+Y1[IV]^);
          Scr[Dest] := Ord(Boxes.UR); Scr[Dest+1] := TextAttr;
          Dest := VideoAddr(wX1^+X1[IV]^, wY2^-Y2[IV]^);
          Scr[Dest] := Ord(Boxes.LL); Scr[Dest+1] := TextAttr;
          Dest := VideoAddr(wX2^-X2[IV]^, wY2^-Y2[IV]^);
          Scr[Dest] := Ord(Boxes.LR); Scr[Dest+1] := TextAttr;
            for K := (wX1^+X1[IV]^+1) to (wX2^-X2[IV]^-1) do
              begin
                Dest := VideoAddr(K, wY1^+Y1[IV]^);
                Scr[Dest] := Ord(Boxes.Horiz);
                Scr[Dest+1] := TextAttr;
                Dest := VideoAddr(K, wY2^-Y2[IV]^);
                Scr[Dest] := Ord(Boxes.Horiz);
                Scr[Dest+1] := TextAttr;
              end;
            for K := (wY1^+Y1[IV]^+1) to (wY2^-Y2[IV]^-1) do
              begin
                Dest := VideoAddr(wX1^+X1[IV]^, K);
                Scr[Dest] := Ord(Boxes.Vert);
                Scr[Dest+1] := TextAttr;
                Dest := VideoAddr(wX2^-X2[IV]^, K);
                Scr[Dest] := Ord(Boxes.Vert);
                Scr[Dest+1] := TextAttr;
              end;
            GotoXY(wX1^+X1[IV]^+1,wY1^+Y1[IV]^);
            WriteItem(Item[IV]^, Switch[IV]^, Status[IV]^);
          end;
        end;
        _obt : begin
                 with Dialog^[GV]^ do
                   begin
                     GotoXY(wX1^+X1[IV]^,wY1^+Y1[IV]^);
                     if Switch[IV]^ then
                       WriteItem(OptionButtonOn +' '+ Item[IV]^, Switch[IV]^,
                         Status[IV]^)
                     else
                       WriteItem(OptionButtonOff +' '+ Item[IV]^, Switch[IV]^,
                         Status[IV]^)
                 end;
               end;
        _rbt : begin
                 with Dialog^[GV]^ do
                   begin
                     GotoXY(wX1^+X1[IV]^,wY1^+Y1[IV]^);
                     if Switch[IV]^ then
                       WriteItem(RadioButtonOn + ' ' + Item[IV]^,
                         Switch[IV]^, Status[IV]^)
                     else
                       WriteItem(RadioButtonOff + ' ' + Item[IV]^,
                         Switch[IV]^, Status[IV]^)
                   end;
               end;
        _str : begin
                 with Dialog^[GV]^ do
                   begin
                     DialogColor(PKind^, colDialogNormal);
                     GotoXY(wX1^+X1[IV]^, wY1^+Y1[IV]^);
                     L := wX2^-wX1^- 1 -X1[IV]^-X2[IV]^ - RealSize(Item[IV]^);
                     K := Length(Data[IV]^); if K > L then K := L;
                     if Data[IV] = nil then
                     WriteItem(Item[IV]^ + '[' + CharStr(#250, L) + ']',
                       Switch[IV]^, Status[IV]^) else
                     case Dialog^[GV]^.StrKind^ of
                       NormStr, NumbStr :  WriteItem(Item[IV]^+ '['+
                         Copy(Data[IV]^, 1, L) + CharStr(#250, L - K) + ']',
                         Switch[IV]^, Status[IV]^);
                       PassStr :  WriteItem(Item[IV]^ + '[' + CharStr('*',
                           Length(Copy(Data[IV]^, 1, L))) + CharStr(#250, L -
                           K) + ']', Switch[IV]^, Status[IV]^);
                     end;
                   end;
               end;
        _but : with Dialog^[GV]^ do
                 begin
                   DialogColor(PKind^, colDialogNormal);
                   if Lo(TextAttr) > 128 then TextColor(Black + 128)
                     else TextColor(Black);
                   GotoXY(wX1^ + X1[IV]^+1, wY1^ + Y1[IV]^+1);
                     Write(CharStr(#5, RealSize(Item[IV]^)));
                   GotoXY(wX1^ + X1[IV]^ + RealSize(Item[IV]^),
                     wY1^ + Y1[IV]^); Write(#6);
                   Color(colButtonActive);
                   GotoXY(wX1^ + X1[IV]^, wY1^ + Y1[IV]^);
                   WriteButton(Item[IV]^, False);
                 end;
        _fil : with Dialog^[GV]^ do
               begin
                 if FileList[IV] <> nil then
                   begin DelFList(FileList[IV]); NewFList(FileList[IV]); end;
                 ReadFiles(FileList[IV]);
                 LFilter := Filter; M[IV]^ := 1; P[IV]^ := 1;
                 Color(colScrollBarArrowAndSlide);
                 GotoXY(wX2^- (X2[IV]^+ 1), wY1^+ Y1[IV]^); Write(UpArrow);
                 GotoXY(wX2^- (X2[IV]^+ 1), wY2^- Y2[IV]^); Write(DownArrow);
                 Color(colScrollBar);
                 for K := wY1^ + Y1[IV]^ + 1 to wY2^ - Y2[IV]^ - 1 do
                   begin
                     GotoXY(wX2^ - (X2[IV]^ + 1), K);
                     Write(VertScrollBar);
                   end;
                 Color(colScrollBarArrowAndSlide);
                 GotoXY(wX2^- (X2[IV]^+ 1), wY1^+ Y1[IV]^+ 1);
                 Write(VertScrollBar);
                 DialogColor(PKind^, colDialogInverse);
                 for K := 1 to wY2^ - wY1^ - (Y1[IV]^ + Y2[IV]^) + 1 do
                   begin
                     GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + K - 1);
                     S1 := ' ' + FElement(K, FileList[IV]);
                     B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S1) - 2;
                     if K = 1 then DialogColor(PKind^, colDialogBrightInverse);
                     Write(S1, CharStr(' ', B));
                     if K = 1 then DialogColor(PKind^, colDialogInverse);
                   end;
                   GotoXY(wX1^ + X1[IV]^, wY2^ - Y2[IV]^);
                   N[IV]^ := MaxFList(FileList[IV]);
               end;
        _lst : with Dialog^[GV]^ do
               begin
                 Color(colScrollBarArrowAndSlide);
                 GotoXY(wX2^- (X2[IV]^ + 1), wY1^ + Y1[IV]^); Write(UpArrow);
                 GotoXY(wX2^- (X2[IV]^+ 1), wY2^- Y2[IV]^-1); Write(DownArrow);
                 GotoXY(wX1^+ X1[IV]^ + 1, wY2^ - Y2[IV]^); Write(LeftArrow);
                 GotoXY(wX2^- X2[IV]^ - 3, wY2^- Y2[IV]^); Write(RightArrow);
                   DialogColor(PKind^, colDialogInverse);
                     Write(#32#32);
                 Color(colScrollBar);
                 M[IV]^ := 1; P[IV]^ := 1;
                 for K := wY1^ + Y1[IV]^ + 1 to wY2^ - Y2[IV]^ - 2 do
                   begin
                     GotoXY(wX2^ - (X2[IV]^ + 1), K);
                     Write(VertScrollBar);
                   end;
                 for K := wX1^ + X1[IV]^ + 3 to wX2^ - X2[IV]^ - 4 do
                   begin
                     GotoXY(K, wY2^ - Y2[IV]^); Write(#20);
                   end;
                 Color(colScrollBarArrowAndSlide);
                 GotoXY(wX2^- X2[IV]^- 1, wY1^ + Y1[IV]^+ 1);
                   Write(VertScrollBar);
                 GotoXY(wX1^ + X1[IV]^ + 3, wY2^ - Y2[IV]^);
                   Write(HorzScrollBar);
                 DialogColor(PKind^, colDialogInverse);

                 for K := 1 to wY2^ - wY1^ - (Y1[IV]^ + Y2[IV]^) do
                   begin
                     GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + K - 1);
                     if SStrBool(K, StrList[IV]) and
                       Switch[IV]^ then S := #32#251 else S := #32#32;
                     S := S + SElement(K, StrList[IV]);
                     S := Copy(S, H[IV]^, Length(S));
                     B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
                     if K = 1 then DialogColor(PKind^, colDialogBrightInverse);
                    Write(Copy(S + CharStr(' ', B), 1,
                               wX2^- wX1^- (X1[IV]^+ X2[IV]^) - 2));
                     if K = 1 then DialogColor(PKind^, colDialogInverse);
                  end;
                  N[IV]^ := MaxSList(StrList[IV]);
               end;
  end;
end; { TDialog.InitDialog }

function TDialog.SelectFile;
var
  I, L, C : Integer;
  B, K : Byte;
  S, S1, LastDir, CurrDir : string;
  DirInfo : SearchRec;
  dt : DateTime;
  dgInfo : TDialog;
  Key : Word;
  Flag : Boolean;
const
  Month : array[1..12] of string[9] =
    ('ü≠≥†∞®', 'î•¢∞≥†∞®', 'å†∞≤', 'ÄØ∞®´', 'å†©', 'û≠®', 'û´®',
     'Ä¢£≥±≤', 'ë•Ø≤•¨¢∞®', 'é™≤Æ¨¢∞®', 'çÆ•¨¢∞®', 'Ñ•™•¨∞¢®');

begin { TDialog.SelectFile }
  GetDir(0, LastDir); CurrDir := LastDir;
  Flag := False;
  with Dialog^[GV]^ do
    begin
      if LFilter <> Filter then
        begin
          DelFList(FileList[IV]); NewFList(FileList[IV]);
          ReadFiles(FileList[IV]);
          M[IV]^ := 1; P[IV]^ := 1; LFilter := Filter;
        end;
      N[IV]^ := MaxFList(FileList[IV]);
      C := wY2^ - wY1^ - (Y1[IV]^ + Y2[IV]^) + 1;
  end;

  repeat
    with Dialog^[GV]^ do
    begin
    Color(colScrollBar);
    for I := wY1^ + Y1[IV]^ + 1 to wY2^ - Y2[IV]^ - 1 do
      begin
        GotoXY(wX2^ - (X2[IV]^ + 1), I); Write(VertScrollBar);
      end;

    if N[IV]^ > (C - 2) then
      begin
        I := (M[IV]^ + P[IV]^ - 1) div (N[IV]^ div (C - 2)); L := 1;
        if I = 0 then I := 1; if I > C - 2 then I := C - 2;
      end else
      begin
        I := (M[IV]^ + P[IV]^ - 1); L := C - N[IV]^ - 1;
      end;

    Color(colScrollBarArrowAndSlide);
    for K := 1 to L do
      begin
        GotoXY(wX2^ - X2[IV]^ - 1, wY1^ + Y1[IV]^ + (I + K - 1));
        Write(VertScrollBar);
      end;
    DialogColor(PKind^, colDialogInverse);
    for K := 1 to C do
      begin
        GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + K - 1);
        S := ' ' + FElement(K + M[IV]^ - 1, FileList[IV]);
        B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
        Write(S, CharStr(' ', B));
      end;
    Color(colScrollBarArrowAndSlide);
    Data[IV]^ := FElement(M[IV]^ + P[IV]^ - 1, FileList[IV]);
    GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + P[IV]^ - 1);
    S := #203 + FElement(M[IV]^ + P[IV]^ - 1, FileList[IV]);
    B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
    Write(S, CharStr(' ', B));

    if lKey = kbNoKey then Key := GetEvent else Key := lKey;

    if Key = evNoKeyEvent then
      begin
        if (Mouse.X >= wX2^ - X2[IV]^ - 1) and (Mouse.X <= wX2^ - X2[IV]^) and
           (Mouse.Y = wY1^ + Y1[IV]^) then Key := kbUp;
        if (Mouse.X >= wX2^ - X2[IV]^ - 1) and (Mouse.X <= wX2^ - X2[IV]^) and
           (Mouse.Y = wY2^ - Y2[IV]^) then Key := kbDown;
        if (Mouse.X >= wX2^ - X2[IV]^ - 1) and (Mouse.X <= wX2^ - X2[IV]^) and
           (Mouse.Y >= wY1^ + Y1[IV]^ + 1) and (Mouse.Y <= wY2^ - Y2[IV]^ - 1)
           then
          begin
            if Mouse.Y < I + wY1^ + Y1[IV]^ then Key := kbPgUp;
            if Mouse.Y > I + (L - 1) + wY1^ + Y1[IV]^ then Key := kbPgDn;
          end;
        if (Mouse.X >= wX1^ + X1[IV]^) and (Mouse.X <= wX2^ - X2[IV]^ - 2) and
           (Mouse.Y >= wY1^ + Y1[IV]^) and (Mouse.Y <= wY2^ - Y2[IV]^) then
            if Mouse.Y - wY1^ - Y1[IV]^ + 1 <= N[IV]^ then
              P[IV]^ := Mouse.Y - wY1^ - Y1[IV]^ + 1;
        if not((Mouse.X >= wX1^ + X1[IV]^) and (Mouse.X <= wX2^ - X2[IV]^) and
          (Mouse.Y >= wY1^ + Y1[IV]^) and (Mouse.Y <= wY2^ - Y2[IV]^)) then
          Flag := True;
      end;

    if Key <> evNoKeyEvent then
    case Key of
      kbUp : if (P[IV]^ - 1) >= 1 then Dec(P[IV]^) else
               if M[IV]^ + P[IV]^ >= 3 then Dec(M[IV]^);
      kbDown : if (P[IV]^ + 1 <= C) and (P[IV]^ + 1 <= N[IV]^) then
                 Inc(P[IV]^) else
               if M[IV]^ + P[IV]^ <= N[IV]^ then Inc(M[IV]^);
      kbPgUp : if (M[IV]^- C >= 1) then Dec(M[IV]^, C) else
                 begin M[IV]^:= 1; P[IV]^:= 1; end;
      kbPgDn : if M[IV]^ + C <= N[IV]^ - C then Inc(M[IV]^, C) else
                 begin if N[IV]^ > C then
                 begin P[IV]^ := C; M[IV]^ := N[IV]^ - (C - 1); end
                   else begin P[IV]^ := N[IV]^; M[IV]^ := 1; end;
                 end;
      kbHome : begin M[IV]^ := 1; P[IV]^ := 1; end;
      kbEnd : if N[IV]^ < C then begin P[IV]^ := N[IV]^; M[IV]^ := 1; end
                else begin P[IV]^ := C; M[IV]^ := N[IV]^ - (C - 1); end;
      kbEnter : begin
                  FDirInfo(M[IV]^ + P[IV]^ - 1, FileList[IV], DirInfo);
                  if (DirInfo.Attr and VolumeID <> 0) then
                    ChDir(Copy(DirInfo.Name, 4, 2));
                  if (DirInfo.Attr and Directory <> 0) then
                    ChDir(Copy(DirInfo.Name, 1, Length(DirInfo.Name)));
                  GetDir(0, CurrDir);
                  DelFList(FileList[IV]); NewFList(FileList[IV]);
                  ReadFiles(FileList[IV]);
                  M[IV]^ := 1; P[IV]^ := 1;
                  N[IV]^ := MaxFList(FileList[IV]);
                end;
      kbF1 : HelpDialog;
      kbF5 : begin
               dgInfo.Init(Help, 'à≠¥Æ∞¨†∂®ø', 15, 8, 65, 18, 0);
                 dgInfo.SetGroup(_but, NormStr);
                   dgInfo.SetItem('  ~Ñ~Æ°∞•  ', nil, nil, 20, 8, 1, 1,
                     True, True, kbAltD);
                 dgInfo.SetGroup(_txt, NormStr);
                   dgInfo.SetItem('í•™≥π† §®∞•™≤Æ∞®ø:'^L, nil, nil, 1, 2, 1, 1,
                     True, True, kbNoKey);
                   dgInfo.SetItem('í•™≥π •´•¨•≠≤:'^L, nil, nil, 1, 4, 1, 1,
                     True, True, kbNoKey);
                   dgInfo.SetItem('Ñ†≤†:'^L, nil, nil, 1, 5, 1, 1,
                     True, True, kbNoKey);
                   dgInfo.SetItem('í®Ø:'^L, nil, nil, 30, 4, 1, 1,
                     True, True, kbNoKey);
                   dgInfo.SetItem('ó†±:'^L, nil, nil, 30, 5, 1, 1,
                     True, True, kbNoKey);
                     S := CurrDir;
                  FDirInfo(M[IV]^ + P[IV]^ - 1, FileList[IV], DirInfo);
                     if Length(S) > 30 then
                       S := '...' + Copy(S, Length(S) - 26, Length(S));
                   dgInfo.SetItem('~' + S + '~'^L, nil, nil,
                     20, 2, 1, 1, True, True, kbNoKey);
                   dgInfo.SetItem('~' + DirInfo.Name + '~'^L, nil, nil,
                     16, 4, 1, 1, True, True, kbNoKey);
                     S := 'î†©´';
                     if DirInfo.Attr and VolumeID <> 0 then
                       S := 'ì±≤∞Æ©±≤¢Æ';
                     if DirInfo.Attr and Directory <> 0 then
                       S := 'Ñ®∞•™≤Æ∞®ø';
                   dgInfo.SetItem('~' + S + '~'^L, nil, nil,
                     35, 4, 1, 1, True, True, kbNoKey);
                   FillChar(dt, SizeOf(dt), 0);
                   UnpackTime(DirInfo.Time, dt);
                   Str(dt.Day, S1); S := S1 + '/' + Month[dt.Month] + '/';
                   Str(dt.Year, S1); S := '~' + S + S1 + '~'^L;
                   dgInfo.SetItem(S, nil, nil, 7, 5, 1, 1, True, True, kbNoKey);
                   Str(dt.Hour, S1); S := S1 + ':';
                   if dt.Min < 10 then S := S + '0';
                   Str(dt.Min, S1); S := S + S1 + ':';
                   if dt.Sec < 10 then S := S + '0';
                   Str(dt.Sec, S1); S := '~' + S + S1 + '~'^L;
                   dgInfo.SetItem(S, nil, nil, 35, 5, 1, 1, True, True, kbNoKey);
                     Str(N[IV]^, S);
                     S := 'é°π °∞Æ© •´•¨•≠≤®: ~' + S + '~'^C;
                   dgInfo.SetItem(S, nil, nil, 1, 6, 1, 1, True, True, kbNoKey);
               dgInfo.ActiveDialog;
               dgInfo.Done;
             end;
      end;
    if lKey <> kbNoKey then begin Key := kbNoKey; lKey := Key; end;
  end;

    for B := 1 to Numb^ do
      for L := 1 to Dialog^[B]^.Numb^ do
        if (Dialog^[B]^.Shortkey[L]^ = Key) and
           (Dialog^[B]^.Shortkey[L]^ <> kbNoKey) then Flag := True;

  until (Key = kbTab) or (Key = kbShiftTab) or (Key = kbEsc) or Flag;
  with Dialog^[GV]^ do
    begin
      FDirInfo(M[IV]^ + P[IV]^ - 1, FileList[IV], DirInfo);
      DialogColor(PKind^, colDialogBrightInverse);
      S := '';
        if (DirInfo.Attr and Directory = 0) and
           (DirInfo.Attr and VolumeID = 0) then
          S := FElement(M[IV]^ + P[IV]^ - 1, FileList[IV]);
        if Data[IV] <> nil then Data[IV]^ := S;
      GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + P[IV]^ - 1);
      S := ' ' + FElement(M[IV]^ + P[IV]^ - 1, FileList[IV]);
      B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
      Write(S, CharStr(' ', B));
    end;
  ChDir(LastDir);
  SelectFile := Key;
end; { TDialog.SelectFile }

function TDialog.SelectStr;
var
  I, L, C : Integer;
  B, K, D, Q : Byte;
  A : PSList;
  S : string;
  Key : Word;
  Flag : Boolean;
begin { TDialog.SelectStr }
  Flag := False;
  with Dialog^[GV]^ do
    begin
      N[IV]^ := MaxSList(StrList[IV]);
      C := wY2^ - wY1^ - (Y1[IV]^ + Y2[IV]^);
    end;

  repeat
    with Dialog^[GV]^ do
    begin
    Color(colScrollBar);
    for I := wY1^ + Y1[IV]^ + 1 to wY2^ - Y2[IV]^ - 2 do
      begin
        GotoXY(wX2^ - (X2[IV]^ + 1), I); Write(VertScrollBar);
      end;
    for I := wX1^ + X1[IV]^ + 3 to wX2^ - X2[IV]^ - 5 do
      begin
        GotoXY(I, wY2^ - Y2[IV]^); Write(HorzScrollBar);
      end;

    if N[IV]^ > (C - 2) then
      begin
        I := (M[IV]^ + P[IV]^ - 1) div (N[IV]^ div (C - 2)); L := 1;
        if I = 0 then I := 1; if I > C - 2 then I := C - 2;
      end else
      begin
        I := (M[IV]^ + P[IV]^ - 1); L := C - N[IV]^ - 1;
        if N[IV]^ = 0 then L := 0;
      end;

    { Place of Scroll Bar }
    Q := (wX2^ - wX1^) - (X1[IV]^ + X2[IV]^) - 3;
    D := Round(H[IV]^ / (((255-Q) + 6) / (Q - 4)));

    Color(colScrollBarArrowAndSlide);
    for K := 1 to L do
      begin
        GotoXY(wX2^ - X2[IV]^ - 1, wY1^ + Y1[IV]^ + (I + K - 1));
        Write(VertScrollBar);
      end;
    GotoXY(wX1^ + X1[IV]^ + D + 3, wY2^ - Y2[IV]^); Write(HorzScrollBar);

    DialogColor(PKind^, colDialogInverse);
    for K := 1 to C do
      begin
       GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + K - 1);
        if SStrBool(K + M[IV]^ - 1, StrList[IV]) and Switch[IV]^ then
          S := #32#251 else S := #32#32;
        S := S + SElement(K + M[IV]^ - 1, StrList[IV]);
        S := Copy(S, H[IV]^, Length(S));
        B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
        Write(Copy(S + CharStr(' ', B), 1, wX2^- wX1^- (X1[IV]^+ X2[IV]^) - 2));
      end;
    Color(colScrollBarArrowAndSlide);
    GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + P[IV]^ - 1);
      if SStrBool(M[IV]^ + P[IV]^ - 1, StrList[IV]) and Switch[IV]^ then
        S := #203#251 else S := #203#32;
    S := S + SElement(M[IV]^ + P[IV]^ - 1, StrList[IV]);
    S := Copy(S, H[IV]^, Length(S));
    B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
     Write(Copy(S + CharStr(' ', B), 1, wX2^- wX1^- (X1[IV]^+ X2[IV]^) - 2));

    if lKey = kbNoKey then Key := GetEvent else Key := lKey;

    if Key = evNoKeyEvent then
      begin
        if (Mouse.X >= wX2^ - X2[IV]^ - 1) and (Mouse.X <= wX2^ - X2[IV]^) and
           (Mouse.Y = wY1^ + Y1[IV]^) then Key := kbUp;
        if (Mouse.X >= wX2^ - X2[IV]^ - 1) and (Mouse.X <= wX2^ - X2[IV]^) and
           (Mouse.Y = wY2^ - Y2[IV]^ - 1) then Key := kbDown;
        if (Mouse.X >= wX2^ - X2[IV]^ - 1) and (Mouse.X <= wX2^ - X2[IV]^) and
           (Mouse.Y >= wY1^ + Y1[IV]^ + 1) and (Mouse.Y <= wY2^ - Y2[IV]^ - 2)
           then
          begin
            if Mouse.Y < I + wY1^ + Y1[IV]^ then Key := kbPgUp;
            if Mouse.Y > I + (L - 1) + wY1^ + Y1[IV]^ then Key := kbPgDn;
          end;
        if (Mouse.X >= wX1^ + X1[IV]^ + 1) and (Mouse.X <= wX1^ + X1[IV]^ + 2) and
           (Mouse.Y = wY2^ - Y2[IV]^) then Key := kbLeft;
        if (Mouse.X >= wX2^ - X2[IV]^ - 3) and (Mouse.X <= wX2^ - X2[IV]^ - 2) and
           (Mouse.Y = wY2^ - Y2[IV]^) then Key := kbRight;
        if (Mouse.X >= wX1^ + X1[IV]^ + 3) and (Mouse.X <= wX2^ - X2[IV]^ - 4) and
           (Mouse.Y = wY2^ - Y2[IV]^) then
           begin
             if Mouse.X < D + wX1^ + X1[IV]^ + 3 then Key := kbCtrlLeft;
             if Mouse.X > D + wX1^ + X1[IV]^ + 4 then Key := kbCtrlRight;
           end;
        if (Mouse.X >= wX1^ + X1[IV]^) and (Mouse.X <= wX2^ - X2[IV]^ - 2) and
           (Mouse.Y >= wY1^ + Y1[IV]^) and (Mouse.Y <= wY2^ - Y2[IV]^ - 1) then
            if Mouse.Y - wY1^ - Y1[IV]^ + 1 <= N[IV]^ then
              P[IV]^ := Mouse.Y - wY1^ - Y1[IV]^ + 1;
        if not((Mouse.X >= wX1^ + X1[IV]^) and (Mouse.X <= wX2^ - X2[IV]^) and
          (Mouse.Y >= wY1^ + Y1[IV]^) and (Mouse.Y <= wY2^ - Y2[IV]^)) then
          Flag := True;
      end;

    if Key <> evNoKeyEvent then
      case Key of
        kbUp : if (P[IV]^ - 1) >= 1 then Dec(P[IV]^) else
               if M[IV]^ + P[IV]^ >= 3 then Dec(M[IV]^);
        kbDown : if (P[IV]^ + 1 <= C) and (P[IV]^ + 1 <= N[IV]^) then
                 Inc(P[IV]^) else
               if M[IV]^ + P[IV]^ <= N[IV]^ then Inc(M[IV]^);
        kbLeft : if (H[IV]^ - 1 >= 1) then Dec(H[IV]^);
        kbRight : if (H[IV]^ + 1 <= 255-Q) then Inc(H[IV]^);
        kbPgUp : if (M[IV]^- C >= 1) then Dec(M[IV]^, C) else
                   begin M[IV]^:= 1; P[IV]^:= 1; end;
        kbPgDn : if M[IV]^ + C <= N[IV]^ - C then Inc(M[IV]^, C) else
                   begin if N[IV]^ > C then
                   begin P[IV]^ := C; M[IV]^ := N[IV]^ - (C - 1); end
                     else begin P[IV]^ := N[IV]^; M[IV]^ := 1; end;
                   end;
        kbHome : begin M[IV]^ := 1; P[IV]^ := 1; end;
        kbEnd : if N[IV]^ < C then begin P[IV]^ := N[IV]^; M[IV]^ := 1; end
                  else begin P[IV]^ := C; M[IV]^ := N[IV]^ - (C - 1); end;
        kbEnter : Flag := True;
        kbSpace : if Switch[IV]^ then SetSBool(M[IV]^ + P[IV]^ - 1, StrList[IV],
                    not(SStrBool(M[IV]^ + P[IV]^ - 1, StrList[IV])));
        kbCtrlLeft  : if Integer((H[IV]^ - Q)) >= 1 then
                        Dec(H[IV]^, Q) else H[IV]^ := 1;
        kbCtrlRight : if Integer((H[IV]^ + Q)) <= 255-Q then
                        Inc(H[IV]^, Q) else H[IV]^ := 255-Q;
        kbCtrlHome : H[IV]^ := 1;
        kbCtrlEnd  : H[IV]^ := 255-Q;
        kbEnter, kbEsc : Flag := True;
        kbF1 : HelpDialog;
      end;

    if lKey <> kbNoKey then begin Key := kbNoKey; lKey := Key; end;
  end;

    for B := 1 to Numb^ do
      for L := 1 to Dialog^[B]^.Numb^ do
        if (Dialog^[B]^.Shortkey[L]^ = Key) and
           (Dialog^[B]^.Shortkey[L]^ <> kbNoKey) then Flag := True;

  until (Key = kbTab) or (Key = kbShiftTab) or (Key = kbEsc) or Flag;
  with Dialog^[GV]^ do
    begin
      DialogColor(PKind^, colDialogBrightInverse);
      S := SElement(M[IV]^ + P[IV]^ - 1, StrList[IV]);
        if Data[IV] <> nil then Data[IV]^ := S;
      GotoXY(wX1^ + X1[IV]^ + 1, wY1^ + Y1[IV]^ + P[IV]^ - 1);
      if SStrBool(M[IV]^ + P[IV]^ - 1, StrList[IV]) and Switch[IV]^ then
        S := #32#251 else S := #32#32;
      S := S + SElement(M[IV]^ + P[IV]^ - 1, StrList[IV]);
      B := wX2^ - wX1^ - (X1[IV]^ + X2[IV]^) - Length(S) - 2;
      Write(Copy(S+ CharStr(' ', B), H[IV]^, wX2^- wX1^- (X1[IV]^+ X2[IV]^) - 2));
    end;
  SelectStr := Key;
end; { TDialog.SelectStr }

function TDialog.ActiveDialog;
var
  Key : Word;
  I, J, K : Byte;
  Flag : Boolean;
  IDp : Word;
  S : string;
  PP : Pointer;
begin { TDialog.ActiveDialog }
    if PWindow^.Title^ <> '' then
      begin
        DialogColor(PKind^,colDialogCloseBox);
        GotoXY(wX1^, wY1^); Write(CloseBox);
        DialogColor(PKind^,colDialogActive);
        GotoXY(wX1^ + 2, wY1^); Write(CharStr(#32, wX2^-(wX1^+1)));
        GotoXY((wX1^+((wX2^-wX1^+1) - Length(PWindow^.Title^)) div 2), wY1^);
        Write(PWindow^.Title^);
      end;

   IDp := 0; Flag := False;
   for I := 1 to Numb^ do
     for J := 1 to Dialog^[I]^.Numb^ do
       InitDialog(I,J);

   Gr^ := 0; It^ := 0;
   for I := 1 to Numb^ do
     if Dialog^[I]^.Kind^ in [_rbt.._lst] then
       begin LGr^ := Gr^; Gr^ := I; Break; end;
   for I := 1 to Dialog^[Gr^]^.Numb^ do
     if Dialog^[Gr^]^.Status[I]^ then begin LIt^ := It^; It^ := I; Break; end;

   repeat
     if Dialog^[LGr^]^.Kind^ = _but then
       begin
         GotoXY(wX1^+Dialog^[LGr^]^.X1[LIt^]^, wY1^+Dialog^[LGr^]^.Y1[LIt^]^);
         WriteButton(Dialog^[LGr^]^.Item[LIt^]^, False);
       end;
     if Dialog^[Gr^]^.Kind^ = _but then
       begin
         GotoXY(wX1^+ Dialog^[Gr^]^.X1[It^]^, wY1^+ Dialog^[Gr^]^.Y1[It^]^);
         WriteButton(Dialog^[Gr^]^.Item[It^]^, True);
       end;

     if Dialog^[Gr^]^.Kind^ in [_rbt, _obt] then
       begin
         Cursor(7, 8);
         GotoXY(wX1^+Dialog^[Gr^]^.X1[It^]^+ 3, wY1^+Dialog^[Gr^]^.Y1[It^]^);
       end else Cursor(32, 0);

     if not Flag then Key := GetEvent;

      LGr^ := Gr^; LIt^ := It^;
      Flag := False;

  if Dialog^[LGr^]^.Kind^ = _but then
    begin
      GotoXY(wX1^+Dialog^[LGr^]^.X1[LIt^]^, wY1^+Dialog^[LGr^]^.Y1[LIt^]^);
      WriteButton(Dialog^[LGr^]^.Item[LIt^]^, False);
    end;

      case Key of
        kbTab, kbDown : begin
          I := Gr^; J := It^;
          repeat
            if J < Dialog^[I]^.Numb^ then Inc(J) else J := 1;
            if (J = 1) and (I < Numb^) then Inc(I) else
              if (J = 1) then I := 1;
            if (Dialog^[I]^.Kind^ in [_rbt.._lst]) and
               (Dialog^[I]^.Status[J]^) then
              begin
                Gr^ := I; It^ := J;
                Flag := True;
              end;
          until Flag;
        end;
        kbShiftTab, kbUp : begin
          I := Gr^; J := It^;
          repeat
            if J > 1 then Dec(J) else J := Dialog^[I]^.Numb^;
            if (J = Dialog^[I]^.Numb^) and (I > 1) then
              begin Dec(I); J := Dialog^[I]^.Numb^ end
            else
              if (J = Dialog^[I]^.Numb^) then
                begin I := Numb^; J := Dialog^[I]^.Numb^; end;
            if (Dialog^[I]^.Kind^ in [_rbt.._lst]) and
               (Dialog^[I]^.Status[J]^) then
              begin
                Gr^ := I; It^ := J;
                Flag := True;
              end;
          until Flag;
        end;
        kbEsc   : IDp := _Cancel;
        kbEnter : IDp := _Accept;
        kbF1    : HelpDialog;
      end;

     Flag := False;

   if Key <> evNoKeyEvent then
     with Dialog^[Gr^]^ do
       case Kind^ of
         _rbt : begin
           if Key = kbSpace then
             Switch[It^]^ := not(Switch[It^]^);
           InitDialog(Gr^, It^);
         end;
         _obt : begin
           if Key = kbSpace then
             begin
               for K := 1 to Dialog^[Gr^]^.Numb^ do
                 begin
                   Switch[K]^ := False;
                   InitDialog(Gr^, K);
                 end;
               Switch[It^]^ := True;
               InitDialog(Gr^, It^);
             end;
         end;
         _str : begin
           if (Key = kbTab) or (Key = kbShiftTab) or
              (Key = kbUp) or (Key = kbDown) then
             begin
               if Data[It^] = nil then
                 begin New(Data[It^]); Data[It^]^ := ''; end;
               Key := EnterStr(Data[It^]^, wX1^ + X1[It^]^ + 1 +
               RealSize(Item[It^]^), wY1^ + Y1[It^]^, wX2^ - wX1^- 1 -
               X1[It^]^- X2[It^]^- RealSize(Item[It^]^), DialogColor(PKind^,
               colDialogInverse), StrKind^);
               InitDialog(Gr^, It^);
               Flag := True;
             end;
         end;
         _but : begin
            if (Key = kbSpace) or (Key = kbEnter) then
              begin
                DialogColor(PKind^, colDialogNormal);
                GotoXY(wX1^ + X1[It^]^+1, wY1^ + Y1[It^]^+1);
                Write(CharStr(#32, RealSize(Item[It^]^)));
                GotoXY(wX1^+ X1[It^]^, wY1^ + Y1[It^]^); Write(#32);
                GotoXY(wX1^+ X1[It^]^+ RealSize(Item[It^]^),wY1^ + Y1[It^]^);
                Write(#32);
                Color(colButtonActive);
                GotoXY(wX1^ + X1[It^]^ + 1, wY1^ + Y1[It^]^);
                WriteButton(Dialog^[Gr^]^.Item[It^]^, True);
                Delay(50);
                DialogColor(PKind^,colDialogInactive);
                GotoXY(wX1^, wY1^); Write(CharStr(#32, wX2^-wX1^+1));
                GotoXY((wX1^+((wX2^-wX1^+1) - Length(PWindow^.Title^)) div 2), wY1^);
                Write(PWindow^.Title^);
                  PP := Prog[It^];
                  if PP = nil then IDp := It^ else Prog[It^]^;
                DialogColor(PKind^, colDialogNormal);
                if Lo(TextAttr) > 128 then TextColor(Black + 128) else
                  TextColor(Black);
                GotoXY(wX1^ + X1[It^]^+1, wY1^ + Y1[It^]^+1);
                Write(CharStr(#5, RealSize(Item[It^]^)));
                GotoXY(wX1^+ X1[It^]^+ RealSize(Item[It^]^), wY1^+ Y1[It^]^);
                Write(#6); Color(colButtonActive);
                GotoXY(wX1^ + X1[It^]^, wY1^ + Y1[It^]^);
                WriteButton(Item[It^]^, True);
                Delay(50);
              end;
         end;
         _fil : begin
            if Dialog^[Gr^]^.Data[It^] = nil then
              begin
                New(Dialog^[Gr^]^.Data[It^]); Dialog^[Gr^]^.Data[It^]^ := '';
              end;
               Key := SelectFile(Gr^, It^, Key);
               I := 1; J := 1;
             Flag := True;
         end;
         _lst : begin
            Key := SelectStr(Gr^, It^, Key);
            I := 1; J := 1;
            if (Key = kbNoKey) or (Key = kbTab) or (Key = kbShiftTab) or
              (Key = kbEsc) or (Key = kbEnter) or (Key = evNoKeyEvent) then
            Flag := True;
         end;
       end;
         I := 0; J := 0;
         repeat
           if J < Dialog^[I]^.Numb^ then Inc(J) else J := 1;
           if (J = 1) and (I < Numb^) then Inc(I) else
              if (J = 1) then I := 1;

            if Dialog^[I]^.Kind^ in [_rbt.._lst] then
              with Dialog^[I]^ do
              case Kind^ of
                _rbt : begin
                         if ((Key = evNoKeyEvent) and
                            (Mouse.X >= wX1^ + X1[J]^) and
                            (Mouse.X <= wX2^ - X2[J]^) and
                            (Mouse.Y = wY1^ + Y1[J]^) or
                            (Key = Shortkey[J]^)) and Status[J]^ then
                             begin
                               Switch[J]^ := not(Switch[J]^);
                               Gr^ := I; It^ := J;
                               InitDialog(Gr^, It^);
                             end;
                       end;
                _obt : begin
                         if ((Key = evNoKeyEvent) and
                            (Mouse.X >= wX1^ + X1[J]^) and
                            (Mouse.X <= wX2^ - X2[J]^) and
                            (Mouse.Y = wY1^ + Y1[J]^)) or
                            (Key = Shortkey[J]^) and Status[J]^ then
                           begin
                               for K := 1 to Dialog^[I]^.Numb^ do
                                 begin
                                   Switch[K]^ := False;
                                   InitDialog(I, K);
                                 end;
                                 Gr^ := I; It^ := J;
                             Switch[It^]^ := True; InitDialog(Gr^, It^);
                           end;
                       end;
                _str : begin
                         if ((Key = evNoKeyEvent) and
                            (Mouse.X >= wX1^ + X1[J]^) and
                            (Mouse.X <= wX2^ - X2[J]^) and
                            (Mouse.Y = wY1^ + Y1[J]^) or
                            (Key = Shortkey[J]^)) and Status[J]^ then
                            begin
                              if Data[J] = nil then
                                begin New(Data[J]); Data[J]^ := ''; end;
                                Key := EnterStr(Data[J]^, wX1^ + X1[J]^ + 1 +
                                RealSize(Item[J]^), wY1^ + Y1[J]^, wX2^- wX1^-
                                1 - X1[J]^-X2[J]^- RealSize(Item[J]^),
                               DialogColor(PKind^,colDialogInverse),
                               StrKind^);
                                 Gr^ := I; It^ := J;
                               InitDialog(Gr^, It^); Flag := True;
                               I := 1; J := 1;
                            end;
                       end;
                _but : begin
                         if ((Key = evNoKeyEvent) and
                             (Mouse.X >= wX1^ + X1[J]^) and
                             (Mouse.X <= wX1^ + X1[J]^ +
                             RealSize(Dialog^[I]^.Item[J]^)) and
                             (Mouse.Y = wY1^ + Y1[J]^)) or
                             (Key = Shortkey[J]^) then
                           begin
                             Gr^ := I; It^ := J;
                             DialogColor(PKind^, colDialogNormal);
                               GotoXY(wX1^ + X1[It^]^+1, wY1^ + Y1[It^]^+1);
                               Write(CharStr(#32, RealSize(Item[It^]^)));
                             GotoXY(wX1^+ X1[It^]^, wY1^ + Y1[It^]^);
                             Write(#32);
                             GotoXY(wX1^+ X1[It^]^+ RealSize(Item[It^]^),
                             wY1^ + Y1[It^]^); Write(#32);
                             Color(colButtonActive);
                             GotoXY(wX1^ + X1[It^]^ + 1, wY1^ + Y1[It^]^);
                             WriteButton(Dialog^[Gr^]^.Item[It^]^, True);
                               Delay(50);
                               DialogColor(PKind^,colDialogInactive);
                             GotoXY(wX1^, wY1^);
                             Write(CharStr(#32, wX2^-wX1^+1));
                             GotoXY((wX1^+((wX2^-wX1^+1) -
                               Length(PWindow^.Title^)) div 2), wY1^);
                             Write(PWindow^.Title^);
                             PP := Prog[It^];
                             if PP = nil then IDp := It^ else Prog[It^]^;
                             DialogColor(PKind^, colDialogNormal);
                             if Lo(TextAttr) > 128 then TextColor(Black + 128)
                               else TextColor(Black);
                             GotoXY(wX1^ + X1[It^]^+1, wY1^ + Y1[It^]^+1);
                             Write(CharStr(#5, RealSize(Item[It^]^)));
                             GotoXY(wX1^+ X1[It^]^+ RealSize(Item[It^]^),
                               wY1^+ Y1[It^]^);
                             Write(#6); Color(colButtonActive);
                             GotoXY(wX1^ + X1[It^]^, wY1^ + Y1[It^]^);
                             WriteButton(Item[It^]^, True);
                             Delay(50);
                           end;
                       end;
                _fil : begin
                         if ((Key = evNoKeyEvent) and
                            ((Mouse.X >= wX1^ + X1[J]^) and
                             (Mouse.X <= wX2^ - X2[J]^) and
                             (Mouse.Y >= wY1^ + Y1[J]^) and
                             (Mouse.Y <= wY2^ - Y2[J]^)) or
                            (Key = Shortkey[J]^)) then
                          begin
                            if Data[J] = nil then
                              begin New(Data[J]); Data[J]^ := ''; end;
                            Key := SelectFile(I, J, Key);
                            Flag := True;
                            I := 1; J := 1;
                          end;
                end;
                _lst : begin
                         if ((Key = evNoKeyEvent) and
                            ((Mouse.X >= wX1^ + X1[J]^) and
                             (Mouse.X <= wX2^ - X2[J]^) and
                             (Mouse.Y >= wY1^ + Y1[J]^) and
                             (Mouse.Y <= wY2^ - Y2[J]^)) or
                            (Key = Shortkey[J]^)) then
                          begin
                            Key := SelectStr(I, J, Key);
                            I := 1; J := 1;
                            if (Key = kbNoKey) or (Key = kbTab) or
                              (Key = kbShiftTab) or (Key = kbEsc) or
                              (Key = evNoKeyEvent) or (Key = kbEnter) then
                            Flag := True;
                          end;
                       end;
            end;
          until ((I >= Numb^) and (J >= Dialog^[I]^.Numb^)) or Flag;

   if (Key = evnoKeyEvent) and
      ((Mouse.X = wX1^) or (Mouse.X = wX1^ + 1)) and (Mouse.Y = wY1^) then
        begin
          Cursor(32, 0);
          sbSystem.X^ := wX1^; sbSystem.Y^ := wY1^ + 1;
          sbSystem.Item[1]^ := ' ~á~†≤¢Æ∞® §®†´Æ£† ';
          K := sbSystem.ActiveMenu(Fictive);
          if (K = mvDown) and (sbSystem.M^ = 1) then IDp := _Cancel;
        end;

   until IDp <> 0;

    ActiveDialog := IDp;
  Cursor(32, 0);
end; { TDialog.ActiveDialog }

procedure TDialog.HelpDialog;
var
  F : Text;
  _S : string;
  I, J : Integer;
  dgHelp : TDialog;
begin { TDialog.HelpDialog }
  if PHelp^ = 0 then Exit;
  Assign(F, HelpFile);
  Reset(F);
    I := 0;
    repeat
      ReadLn(F, _S); J := IOResult;
      if J <> 0 then
        begin
          ErrorDialog('ç•¢†´®§•≠'^C'ØÆ¨Æπ•≠ ¥†©´!'^C);
          Exit;
        end;
      if _S[1] = '@' then Inc(I);
    until I = PHelp^;
    with dgHelp do
      begin
        Init(Help, 'èÆ¨Æπ', 20, 5, 60, 21, 0);
        SetGroup(_but, NormStr);
          SetItem('  ~Ñ~Æ°∞•  ', nil, nil, 16, 14, 1, 1, True, True, kbAltD);
        SetGroup(_lst, NormStr);
          SetItem('', nil, nil, 1, 2, 1, 4, False, True, kbNoKey);
        _S[1] := #0;
        repeat
          begin
            ReadLn(F, _S); J := IOResult;
            if J <> 0 then
              begin
                ErrorDialog('ç•¢†´®§•≠'^C'ØÆ¨Æπ•≠ ¥†©´!'^C);
                Exit;
              end;
             if _S[1] <> '@' then
               ScanSListNS(FormStr(_S,255, Left), False,
                 dgHelp.Dialog^[2]^.StrList[1]);
          end;
        until _S[1] = '@';
        Close(F);
        ActiveDialog;
        Done;
      end;
end; { TDialog.HelpDialog }

destructor TDialog.Done;
var I, J : Byte;
begin { TDialog.Done }
  PWindow^.CloseWindow;
  for I := Numb^ downto 1 do
    begin
      for J := Dialog^[I]^.Numb^ downto 1 do
        begin
          if Dialog^[I]^.StrList[J] <> nil then
            DelSList(Dialog^[I]^.StrList[J]);
          if Dialog^[I]^.FileList[J] <> nil then
            DelFList(Dialog^[I]^.FileList[J]);
          Dispose(Dialog^[I]^.H[J]); Dispose(Dialog^[I]^.P[J]);
          Dispose(Dialog^[I]^.N[J]); Dispose(Dialog^[I]^.M[J]);
          Dispose(Dialog^[I]^.Shortkey[J]);
          Dispose(Dialog^[I]^.Status[J]); Dispose(Dialog^[I]^.Switch[J]);
          Dispose(Dialog^[I]^.Y2[J]); Dispose(Dialog^[I]^.X2[J]);
          Dispose(Dialog^[I]^.Y1[J]); Dispose(Dialog^[I]^.X1[J]);
          Dispose(Dialog^[I]^.Item[J]);
        end;
      Dispose(Dialog^[I]^.Kind); Dispose(Dialog^[I]^.Numb);
      Dispose(Dialog^[I]^.StrKind);
      Dispose(Dialog^[I]);
    end;
  Dispose(wX1); Dispose(wY1); Dispose(wX2); Dispose(wY2);
  PWindow^.Done; Dispose(PWindow); Dispose(PKind);
  Dispose(Gr); Dispose(LGr); Dispose(It); Dispose(LIt);
  Dispose(PHelp); Dispose(Numb); Dispose(Dialog);
end; { TDialog.Done }

end. { Dialogs }
