{**********************************}
{*                                *}
{*    Math unit (c) 1994          *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Math;

interface
uses Dos;

  function Power(N,P : Integer) : Longint;
  function RealPower(N,P : Real) : Real;

  function AddDates(T, Q : DateTime) : Longint;

implementation

function Power;
begin { Power }
  Power := Round(Exp(P * Ln(N)));
end; { Power }

function RealPower;
begin { Power }
  RealPower := Exp(P * Ln(N));
end; { Power }

function AddDates;
type
  TMonths = array[1..12] of Byte;
const
  A : TMonths = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
var
  L : Longint;  I, J : Byte;
begin { AddDates }
  with T do
    begin
      if ((Year mod 4) = 0) and (Month = 2) then J := 1 else J := 0;
      if Sec + Q.Sec < 60 then begin Inc(Sec, Q.Sec); I := 0 end
        else begin Sec := Q.Sec - (60 - Sec); I := 1; end;
      if Min + (Q.Min+I) < 60 then begin Inc(Min, Q.Min+I); I := 0 end
        else begin Min := (Q.Min+I) - (60 - Min); I := 1; end;
      if Hour + (Q.Hour+I) < 23 then begin Inc(Hour, Q.Hour+I); I := 0 end
        else begin Hour := (Q.Hour+I) - (24 - Hour); I := 1; end;
      if Day + (Q.Day+I) < A[Month]+J then begin Inc(Day, Q.Day+I); I := 0 end
        else begin Day := (Q.Day+I) - (A[Month]+J - Day); I := 1; end;
      if Month + (Q.Month+I) < 12 then begin Inc(Month, Q.Month+I); I:= 0 end
        else begin Month := (Q.Month+I) - (12 - Month); I := 1; end;
      Inc(Year, Q.Year+I);
    end;
  PackTime(T, L); AddDates := L;
end; { AddDates }

end. { Math }