{**********************************}
{*                                *}
{*    Transfer unit (c) 1995      *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Transfer;
interface

  function Dec_Hex(Dec : Word) : string;
  function Dec_Oct(Dec : Word) : string;
  function Dec_Bin(Dec : Word) : string;

  function Bin_Dec(Bin : string) : Word;

  function Date2Long(Date : string) : Longint;      { dd-mm-yyyy }
  function Long2Date(Date : Longint) : string;

implementation
uses Dos, Math;
var N, C : Word;

function Dec_Hex;
var S : string;
begin { Dec_Hex }
  N := Dec; S := '';
  repeat
    C := N mod 16;
    N := N div 16;
    if C < 10 then Insert(Chr(48+C), S, 1)
      else Insert(Chr(55+C), S, 1);
  until (N = 0) and (Length(S) = 4);
  Dec_Hex := S;
end; { Dec_Hex }

function Dec_Oct;
var S : string;
begin { Dec_Oct }
  N := Dec; S := '';
  repeat
    C := N mod 8;
    N := N div 8;
    Insert(Chr(48+C), S, 1);
  until (N = 0) and (Length(S) = 6);
  Dec_Oct := S;
end; { Dec_Oct }

function Dec_Bin;
var S : string;
begin { Dec_Bin }
  N := Dec; S := '';
  repeat
    C := N mod 2;
    N := N div 2;
    Insert(Chr(48+C), S, 1);
  until (N = 0) and (Length(S) = 16);
  Dec_Bin := S;
end; { Dec_Bin }

function Bin_Dec;
begin { Bin_Dec }
  N := 0;
  for C := Length(Bin) downto 1 do
    if Bin[C] = '1' then
  Inc(N,Power(2,Length(Bin)-C));
 Bin_Dec := N;
end; { Bin_Dec }

function Date2Long;
var
  Valid : Boolean;
  dt : DateTime;
  L : Longint;
  Code : Word;
  I : Byte;
begin { Date2Long }
  Valid := True; L := MaxLongint;
  if (Date[3] <> #45) or (Date[6] <> #45) then Valid := False;
  Delete(Date, 6, 1); Delete(Date, 3, 1);
  for I := 1 to Length(Date) do
    if not (Ord(Date[I]) in [48..57]) then Valid := False;
  if Valid then
  with dt do
    begin
      Val(Copy(Date, 1, 2), Day, Code);
      Val(Copy(Date, 3, 2), Month, Code);
      Val(Copy(Date, 5, 4), Year, Code);
      PackTime(dt, L);
    end;
  Date2Long := L;
end; { Date2Long }

function Long2Date;
var
  dt : DateTime;
  S1, S2 : string;
begin { Long2Date }
  UnpackTime(Date, dt); S1 := '';
    Str(dt.Day, S2);   if dt.Day < 10 then S1 := '0';
      S1 := S1 + S2 + '-';
    Str(dt.Month, S2); if dt.Month < 10 then S1 := S1 + '0';
      S1 := S1 + S2 + '-';
    Str(dt.Year, S2); S1 := S1 + S2;
  Long2Date := S1;
end; { Long2Date }

end. { Transfer }
