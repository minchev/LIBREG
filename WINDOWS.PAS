{**********************************}
{*                                *}
{*    Windows unit (c) 1994       *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Windows;
interface
uses Colors;

type
  TTitle = string[80];
  TCurs = record
           X,Y : Byte;
         end;
  TWindow = object
    Saver : ^Pointer;
    X1, Y1, X2, Y2 : ^Byte;
    Title : ^TTitle;
    Attr : ^Byte;
    Curs : ^TCurs;
    constructor Init;
    procedure TestSize; virtual;
    procedure DefineWindow(_X1,_Y1,_X2,_Y2 : Byte; _Title : String;
              AttrP : Byte); virtual;
    procedure OpenWindow; virtual;
    procedure CloseWindow; virtual;
    procedure MoveSizeWindow; virtual;
    procedure SaveBar(_X1,_Y1,_X2,_Y2 : Byte); virtual;
    procedure LoadBar(_X1,_Y1,_X2,_Y2 : Byte); virtual;
    procedure Shadow; virtual;
    destructor Done; virtual;
  end; { TWindow }

  procedure DrawBox(X1,Y1,X2,Y2 : Byte);

implementation
uses Crt, Crt_drv, Views, Drivers;
var
  Dest : Integer;
  Index : Byte;

procedure DrawBox;
  type Box_rec = record
                   UL, UH, UR, RV, LR, LH, LL, LV : Char;
                 end;
  const Boxes : Box_rec =
           (UL : #192; UH : #193; UR : #195; RV : #196;
            LR : #198; LH : #200; LL : #201; LV : #203);
begin { DrawBox }
  Dest := VideoAddr(X1,Y1);
  Scr[Dest] := Ord(Boxes.UL); Scr[Dest+1] := TextAttr;
  for Index := (X1+1) to (X2-1) do
    begin
      Dest := VideoAddr(Index,Y1);
      Scr[Dest] := Ord(Boxes.UH); Scr[Dest+1] := TextAttr;
    end;
  Dest := VideoAddr(X2,Y1);
  Scr[Dest] := Ord(Boxes.UR); Scr[Dest+1] := TextAttr;
  for Index := (Y1+1) to (Y2-1) do
    begin
      Dest := VideoAddr(X1,Index);
      Scr[Dest] := Ord(Boxes.LV); Scr[Dest+1] := TextAttr;
      Dest := VideoAddr(X2,Index);
      Scr[Dest] := Ord(Boxes.RV); Scr[Dest+1] := TextAttr;
    end;
  Dest := VideoAddr(X1,Y2);
  Scr[Dest] := Ord(Boxes.LL); Scr[Dest+1] := TextAttr;
  for Index := (X1+1) to (X2-1) do
    begin
      Dest := VideoAddr(Index,Y2);
      Scr[Dest] := Ord(Boxes.LH); Scr[Dest+1] := TextAttr;
    end;
  Dest := VideoAddr(X2,Y2);
  Scr[Dest] := Ord(Boxes.LR); Scr[Dest+1] := TextAttr;
end; { DrawBox }

procedure TWindow.TestSize;
begin { TWindow.TestSize }
  if X1^ < 1 then X1^ := 1;
    if Y1^ < 2 then Y1^ := 2;
  if X2^ > 80 then X2^ := 80;
    if Y2^ > 24 then Y2^ := 24;
  if Length(Title^) > (X2^-X1^-1) then
    Title^ := Copy(Title^,1,X2^-X1^-1);
end; { TWindow.TestSize }

procedure TWindow.Shadow;
var Lng : Byte;
begin { TWindow.Shadow }
  Lng := 0;
    for Index := (Y1^+1) to Y2^ do
      begin
          if (X2^ < 80) and (X2^ <> 79) then begin
            Lng := 2;
            Dest := 160 * (Index-1) + 2 * (X2^+1);
            Scr[Dest+1] := $08; end;
          if X2^ <= 79 then begin
            If X2^ < 79 then Lng := 2 else Lng := 1;
            Dest := 160 * (Index-1) + 2 * X2^;
            Scr[Dest+1] := $08; end;
      end;
 if Y2^ < 24 then
    for Index := (X1^+2) to (X2^+Lng) do
      begin
        Dest := 160 * Y2^ + 2 * (Index-1);
        Scr[Dest+1] := $08;
      end;
end; { TWindow.Shadow }

constructor TWindow.Init;
begin { TWindow.Init }
  New(Saver);
  New(X1); New(Y1); New(X2); New(Y2);
  New(Title);
  New(Attr);
  New(Curs);
end; { TWindow.Init }

procedure TWindow.SaveBar;
begin { TWindow.SaveBar }
  Curs^.X := WhereX; Curs^.Y := WhereY;
  Allocate_scr(_Y1,_X1,(_Y2-_Y1)+1,(_X2-_X1)+1,Saver^);
end; { TWindow.SaveBar }

procedure TWindow.LoadBar;
begin { TWindow.LoadBar }
  Load_scr(_Y1,_X1,(_Y2-_Y1)+1,(_X2-_X1)+1,Saver^,True);
  Release_mem((_Y2-_Y1)+1,(_X2-_X1)+1,Saver^);
  GotoXY(Curs^.X,Curs^.Y);
end; { TWindow.LoadBar }

procedure TWindow.DefineWindow;
begin { TWindow.DefineWindow }
  X1^ := _X1; Y1^ := _Y1; X2^ := _X2; Y2^ := _Y2;
  Title^ := _Title;
  Attr^ := AttrP;
    TestSize;
end; { TWindow.DefineWindow }

procedure TWindow.OpenWindow;
begin { TWindow.OpenWindow }
  SaveBar(X1^,Y1^,X2^+2,Y2^+1);
  Color(Attr^); DrawBox(X1^,Y1^,X2^,Y2^);
     Color(Attr^);  Window(X1^+1,Y1^+1,X2^-1,Y2^-1);
  ClrScr; Shadow;
end; { TWindow.OpenWindow }

procedure TWindow.CloseWindow;
begin { TWindow.CloseWindows }
  LoadBar(X1^,Y1^,X2^+2,Y2^+1);
end; { TWindow.CloseWindows }

procedure TWindow.MoveSizeWindow;
var dgMoveSize : TWindow;
    _X1, _Y1, _X2, _Y2 : Byte;
    Key : Word;
begin { TWindow.MoveSizeWindow }
  _X1 := X1^; _Y1 := Y1^; _X2 := X2^; _Y2 := Y2^;
  FullWin;
  dgMoveSize.Init;
  dgMoveSize.DefineWindow(X1^,Y1^,X2^,Y2^,Title^,Attr^);
  dgMoveSize.SaveBar(X1^,Y1^,X2^,Y2^);
  repeat
    dgMoveSize.LoadBar(dgMoveSize.X1^,dgMoveSize.Y1^,dgMoveSize.X2^,dgMoveSize.Y2^);
    Color(1);
    dgMoveSize.X1^ := _X1; dgMoveSize.Y1^ := _Y1;
    dgMoveSize.X2^ := _X2; dgMoveSize.Y2^ := _Y2;
    dgMoveSize.SaveBar(_X1, _Y1, _X2, _Y2);
      DrawBox(dgMoveSize.X1^,dgMoveSize.Y1^,dgMoveSize.X2^,dgMoveSize.Y2^);
      GotoXY((_X1+((_X2-_X1+1) - Length(Title^)) div 2),_Y1); Write(Title^);
      Key := GetEvent;
      case Key of
        kbUp : if _Y1 > 2 then
                 begin
                   Dec(_Y1); Dec(_Y2);
                 end;
      kbDown : if _Y2 < 24 then
                 begin
                   Inc(_Y1); Inc(_Y2);
                 end;
      kbLeft : if _X1 > 1 then
                 begin
                   Dec(_X1); Dec(_X2);
                 end;
     kbRight : if _X2 < 80 then
                 begin
                   Inc(_X1); Inc(_X2);
                 end;
       kbShiftUp : if _Y2 > _Y1 + 2 then Dec(_Y2);
     kbShiftDown : if _Y2 < 24 then Inc(_Y2);
     kbShiftLeft : if (_X2 > _X1+2) and ((_X2-_X1-1) > Length(Title^)) then
                     Dec(_X2);
     kbShiftRght : if _X2 < 80 then Inc(_X2);
            kbF5 : begin
                     _X1 := 1; _Y1 := 2; _X2 := 80; _Y2 := 25;
                   end;
         kbEnter : begin
                     dgMoveSize.LoadBar(dgMoveSize.X1^,dgMoveSize.Y1^,
                                        dgMoveSize.X2^,dgMoveSize.Y2^);
                     CloseWindow;
                     DefineWindow(_X1, _Y1, _X2, _Y2, Title^, Attr^);
                     OpenWindow; FullWin;
                   end;
           kbEsc : dgMoveSize.LoadBar(dgMoveSize.X1^,dgMoveSize.Y1^,
                                      dgMoveSize.X2^,dgMoveSize.Y2^);
      end;
  until (Key = kbEnter) or (Key = kbEsc);
  dgMoveSize.Done;
end; { TWindow.MoveSizeWindow }

destructor TWindow.Done;
begin { TWindow.Done }
  Dispose(Saver);
  Dispose(X1); Dispose(Y1); Dispose(X2); Dispose(Y2);
  Dispose(Title); Dispose(Attr);
  Dispose(Curs);
end; { TWindow.Done }

end. { Windows }
