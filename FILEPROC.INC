{ Include file FILEPROC.INC }

function CreateDataBase(FileName : string) : Integer;
var
  F : file;  I : Byte;  J : Word;
begin { CreateDataBase }
  Assign(F, FileName); J := 1;
  Reset(F); I := IOResult;
    if I = 0 then
      J := Question('База▓а данни ' + FileName + ^C +
		    ' ве╖е ▒║╣е▒▓в│ва!'^C +
		    'Да запи╕а ли нова в║░╡│ не┐?'^C);
    if J = _Cancel then J := 3;
    if (J = 3) or (J = 2) then
      begin CreateDataBase := J; Exit; end;
    repeat
      Rewrite(F, 1); I := IOResult;
	if I <> 0 then
	  J := RetryDialog('Не мога да ▒║здам' + ^C +
			   'база данни ~' + FileName + '~' + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin CreateDataBase := J; Exit; end;
    until I = 0;
    repeat
      Close(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да за▓во░┐ база▓а' + ^C +
			 'данни' + FileName + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin CreateDataBase := J; Exit; end;
    until I = 0;
  CreateDataBase := 0;
  SelectedDataBase := True;
end; { CreateDataBase }

procedure SaveCard(FileName : string; var Data; Size, Offs : Word);
var
  F, F2 : file;
  Buff : array[1..512] of Byte;
  I, J : Integer;
  Flag : Boolean;
  R : TCCard; T : TBCard;
begin { SaveCard }
  Assign(F, FileName);
  Assign(F2, 'CREATE.TMP');
  repeat
    Reset(F, 1);
    J := IOResult;
    if J <> 0 then
      I := RetryDialog('Не мога да о▓во░┐ ▓ек│╣а▓а' + ^C +
		       'база данни: ' + FileName + ^C);
    if (I = 2) or (I = _Cancel) then Exit;
  until J = 0;

  Flag := True;
  if Offs > 0 then Seek(F, Size * Pred(Offs)) else
    begin
      Rewrite(F2, 1);
      repeat
        BlockRead(F, Buff, Size, I);
        if I = 0 then Break;
        Move(Buff, R, SizeOf(R)); Move(Buff, T, SizeOf(T));
          if (SizeOf(TCCard) = Size) and Flag and
             (SourceC(R) >= SourceC(TCCard(Data))) then
            begin
              BlockWrite(F2, Data, Size); Flag := False;
            end;
          if (SizeOf(TBCard) = Size) and Flag and
             (SourceB(T) >= SourceB(TBCard(Data))) then
            begin
              BlockWrite(F2, Data, Size); Flag := False;
            end;
        BlockWrite(F2, Buff, Size);
      until I = 0;
      Seek(F, FileSize(F));
      if Flag then
        begin
          BlockWrite(F2, Data, Size);
          Size := 0;
        end;
    end;
  BlockWrite(F, Data, Size);
  Close(F);
  if Offs = 0 then
    begin
      Close(F2); Erase(F); Rename(F2, FileName);
    end;
end; { SaveCard }

     {****************************************************************}

procedure Print(BList : PSList);
var
  I, J, N : Byte;
begin
  J := 0;
  for N := 1 to MaxSList(BList) do
    repeat
      Write(Lst, SElement(N, BList)); I := IOResult;
      if I <> 0 then J := RetryDialog('Го▓ов ли е п░ин▓е░а?'^C);
      if J > 1 then Exit;
    until I = 0;
  WriteLn(Lst);
end;

procedure PrintCCard(B : PSList);
type
  TCode = array[1..12] of string[50];
const
  LnE = #13#10; { Line end }
  Prefix : TCode = (prBold, ' ', '          ад░е▒: ', '          ▓ел.: ',
    '          п░о┤е▒и┐: ', '          об░азование: ', '          в║з░а▒▓: ',
    '          ме▒▓о░або▓а: ', '          дл║жно▒▓: ', '          па▒по░▓: ',
    '', '');
  Suffix : TCode = (prNormal, LnE, LnE, LnE, LnE, LnE, LnE, LnE, LnE, ' ',
    ' ', LnE+'          да▓а на ▒║здаване на ка░▓она: ');

var
  P : PSList;
  I, J : Byte;
  S, U : string;
  N : Longint;
begin { PrintCCard }
  J := 0;
  repeat
    WriteLn(Lst, prBold+prItalic+'СПИСЪК НА ЧИТАТЕЛИ:'+prNormal);
      I := IOResult;
    if I <> 0 then J := RetryDialog('Го▓ов ли е п░ин▓е░а?'^C);
    if J > 1 then Exit;
  until I = 0;

  for N := 1 to MaxSList(B) do
    begin
      if SStrBool(N, B) then
	begin
	  NewSList(P, 'PRNC'); J := 0; S := ''; U := SElement(N, B);
	  for I := 1 to Length(U) do
	    begin
	      if U[I] <> #21 then S := S + U[I] else
		begin
		  Inc(J);
		  ScanSListNS(Prefix[J] + S + Suffix[J], False, P);
		  S := '';
		end;
	      if I = Length(U) then ScanSListNS(S, False, P);
	    end;
	  Print(P);
	  DelSList(P);
	end;
    end;
end; { PrintCCard }

procedure PrintBCard(B : PSList);
type
  TCode = array[1..7] of string[50];
const
  LnE = #13#10; { Line end }
  Prefix : TCode =
    (#211 + prItalic + ' заглавие:      ' + prNormal,
     #211 + prItalic + ' УДК:           ' + prNormal,
     #211 + prItalic + ' ав▓о░:         ' + prNormal + prBold,
     #211 + prItalic + ' жан░:          ' + prNormal,
     #211 + prItalic + ' едини╖на ╢ена: ' + prNormal,
     #211 + prItalic + ' изда▓ел▒▓во:   ' + prNormal,
     #211 + prItalic + ' екземпл┐░и:    ' + prNormal);
  Suffix : TCode = (#211 + LnE, #211 + LnE, prNormal + #211 + LnE, #211 + LnE,
                    #211 + LnE, #211 + LnE, #211 + LnE);
var
  P : PSList;
  I, J : Byte;
  S, U : string;
  N : Longint;
  R : array[1..7] of string; { Re-order }
begin { PrintBCard }
  for N := 1 to MaxSList(B) do
    begin
      if SStrBool(N, B) then
	begin
	  NewSList(P, 'PRNB'); J := 0;
	  S := CharStr(#196, 71);
	  S := LnE + #218 + S + #207 + LnE;
	  ScanSListNS(S, False, P); S := ''; U := SElement(N, B);
	  for I := 1 to Length(U) do
	    begin
	      if U[I] <> #21 then S := S + U[I] else
		begin
		  Inc(J);
		  R[J] := FormStr(S, 55, Left);
		  S := '';
		end;
	      if I = Length(U) then R[7] := FormStr(S, 55, Left);
	    end;
          J := 0;
          for I := 1 to 7 do R[I] := Prefix[I] + R[I] + Suffix[I];
          ScanSListNS(R[3], False, P); ScanSListNS(R[1], False, P);
          ScanSListNS(R[4], False, P); ScanSListNS(R[6], False, P);
          ScanSListNS(R[2], False, P); ScanSListNS(R[7], False, P);
          ScanSListNS(R[5], False, P);
	  S := CharStr(#196, 71);
	  S := #192 + S + #217 + LnE;
	  ScanSListNS(S, False, P);
	  Print(P);
	  DelSList(P);
	end;
    end;
end; { PrintBCard }

procedure PrintICard(_Item : Pointer; P : PSList; T : Boolean);
{ T - True-CCard; False-BCard }
{ _Item - pointer to True-TCCard, False-TBCard }
type
  TCodeC = array[1..12] of string[50];
  TCodeB = array[1..7] of string[50];
const
  LnE = #13#10; { Line end }
  PrefixC : TCodeC = (LnE + prBold, ' ', '          ад░е▒: ',
    '          ▓ел.: ', '          п░о┤е▒и┐: ', '          об░азование: ',
    '          в║з░а▒▓: ', '          ме▒▓о░або▓а: ', '          дл║жно▒▓: ',
    '          па▒по░▓: ', '', '');
  SuffixC : TCodeC = (prNormal, LnE, LnE, LnE, LnE, LnE, LnE, LnE, LnE,
    ' ', ' ', LnE+'          да▓а на ▒║здаване на ка░▓она: ');
  PrefixB : TCodeB =
    (prItalic + ' заглавие:      ' + prNormal,
     prItalic + ' УДК:           ' + prNormal,
     prItalic + ' ав▓о░:         ' + prNormal + prBold,
     prItalic + ' жан░:          ' + prNormal,
     prItalic + ' едини╖на ╢ена: ' + prNormal,
     prItalic + ' изда▓ел▒▓во:   ' + prNormal,
     prItalic + ' екземпл┐░и:    ' + prNormal);
  SuffixB : TCodeB = (LnE, LnE, prNormal + LnE, LnE, LnE, LnE, LnE);

var
  B : PSList;
  Data : TICard;
  ItemC : ^TCCard;
  ItemB : ^TBCard;
  S, U : string;
  N : Longint;
  I, J : Byte;
begin { PrintICard }
  if T then ItemC := _Item else ItemB := _Item;
  NewSList(B, 'PRNI');
  ScanSListNS(CharStr(#196, 70) + LnE, False, B);
  if T then S := SourceC(ItemC^) else S := SourceB(ItemB^); J := 0; U := '';
    for I := 1 to Length(S) do
      begin
	if S[I] <> #21 then U := U + S[I] else
          begin
	    Inc(J);
            if T then ScanSListNS(PrefixC[J] + U + SuffixC[J], False, B)
              else ScanSListNS(PrefixB[J] + U + SuffixB[J], False, B);
	    U := '';
	  end;

	if I = Length(S) then
          if T then ScanSListNS(U + LnE, False, B)
            else ScanSListNS(PrefixB[7] + U + SuffixB[7], False, B);
      end;
     ScanSListNS(CharStr(#196, 70) + LnE, False, B);
  for N := 1 to MaxSList(P) do
    begin
      J := 0; U := ''; S := SElement(N, P);
      for I := 1 to Length(S) do
        begin
          if S[I] <> #21 then U := U + S[I] else
            begin
              Inc(J);
              if T then
                case J of
                  1 : ScanSListNS(prBold + ']' + U + prNormal, False, B);
                  2 : ScanSListNS(LnE + prItalic + ' ' +
                        FormStr(U, 21, Left) + prNormal, False, B);
                  3 : ScanSListNS(prBold + ' ' + U + prNormal, False, B);
                  6 : ScanSListNS(LnE + ' ' + U, False, B);
                end else
                case J of
                  1 : ScanSListNS(prBold + '] ' + U + prNormal, False, B);
                  2 : ScanSListNS(' ' + U + LnE, False, B);
                end;
              U := '';
            end;
          if (I = Length(S)) and T then
            ScanSListNS(' ' + U + LnE, False, B);
        end;
    end;
  Print(B);
  DelSList(B);
end; { PrintICard }

     {****************************************************************}

function Available(Book : TBCard) : Longint;
var
  F : file of TICard;
  I, J : Integer;
  El : TICard;
  N : Longint;
begin { Available }
  N := 0;
  Assign(F, LibraryICard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryICard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin Available := -1; Exit; end;
    until I = 0;

    while not Eof(F) do
      begin
	Read(F, El); I := IOResult;
	if (SourceB(El.Title) = SourceB(Book)) and (not(El.Back)) then
	  Inc(N);
      end;
    Close(F);
  Available := Book.Number - N;
end; { Available }

function CopyBaseAs(FromF, ToF : string) : Boolean;
var
  F1, F2 : file;
  Buffer : array[1..2048] of Byte;
  NumRead, NumWritten : Word;
  I, J : Integer;
begin { CopyBaseAs }
  Assign(F1, FromF); Assign(F2, ToF);
  repeat
    Reset(F1, 1); J := IOResult;
    Rewrite(F2, 1); J := IOResult;
    if J <> 0 then
      I := RetryDialog('Не мога да о▓во░┐ ▓ек│╣а▓а' + ^C +
		       'база данни'^C);
    if (I = 2) or (I = _Cancel) then Exit;
  until J = 0;

  repeat
    BlockRead(F1, Buffer, SizeOf(Buffer), NumRead); J := IOResult;
    BlockWrite(F2, Buffer, NumRead, NumWritten); J := IOResult;
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(F1); J := IOResult;
  Close(F2); J := IOResult;
  CopyBaseAs := (J = 0);
end; { CopyBaseAs }

function Equal(P : Pointer; Base : Boolean) : Boolean;
{ Base: False - TCCard.Number, True - TBCard.ID }
type TID = string[20];
var
  F1 : file of TCCard;
  F2 : file of TBCard;
  R : ^Longint; A : TCCard;
  T : ^TID; B : TBCard;
  I : Word; J : Integer;
  C : Boolean;
begin { SaveCard }
  C := False;
  if Base then Assign(F2, LibraryBCard) else Assign(F1, LibraryCCard);
  repeat
    if Base then Reset(F2) else Reset(F1);
    J := IOResult;
    if J <> 0 then
      I := RetryDialog('Не мога да о▓во░┐ ▓ек│╣а▓а' + ^C +
		       'база данни'^C);
    if (I = 2) or (I = _Cancel) then Exit;
  until J = 0;

  if Base then
    begin
      T := P;
      while not Eof(F2) do
	begin
	  Read(F2, B); I := IOResult;
	  if T^ = B.ID then C := True;
	end;
    end else
    begin
      R := P;
      while not Eof(F1) do
	begin
	  Read(F1, A); I := IOResult;
	  if R^ = A.Number then C := True;
	end;
    end;
  if Base then Close(F2) else Close(F1);
  Equal := C;
end; { Equal }

     {****************************************************************}

function SearchCBase(Data : TCCard; var BList : PSList) : Integer;
var
  F : file of TCCard;
  A : TCCard;
  Valid : Boolean;
  N : Longint;
  I, J : Word;
  Source, S1, S2 : string;
  dt : DateTime;
begin { SearchCBase }
  N := 0; Valid := True;
  Assign(F, LibraryCCard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryCCard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin SearchCBase := -1; Exit; end;
    until I = 0;

  while not Eof(F) do
    begin
      repeat
	Read(F, A); I := IOResult;
	if I <> 0 then
	  J := RetryDialog('Г░е╕ка п░и ╖е▓ене на ┤айла'^C +
			    LibraryCCard + ^C);
	  if J = _Cancel then J := 3;
	  if (J = 2) or (J = _Cancel) then
	    begin SearchCBase := -1; Exit; end;
      until I = 0;

      with Data do
	begin
	  Str(Number, S1); Str(A.Number, S2);
	  for I := 8 downto 2 do
	    begin
	      if A.Number < Power(10, I) then S2 := '0' + S2;
	      if Number < Power(10, I) then S1 := '0' + S1;
	    end;

  { Filter conditions }

  Valid := True;
    if Number > 0 then
      if (Pos(UpStr(S1), UpStr(S2)) = 0) then Valid := False;
    if Name <> '' then
      if (Pos(UpStr(Name), UpStr(A.Name)) = 0) then Valid := False;
    if Address <> '' then
      if (Pos(UpStr(Address), UpStr(A.Address)) = 0) then Valid := False;
    if Phone <> '' then
      if (Pos(UpStr(Phone), UpStr(A.Phone)) = 0) then Valid := False;
    if Profession <> '' then
      if (Pos(UpStr(Profession), UpStr(A.Profession)) = 0) then Valid := False;
    if Age > 0 then if Age <> A.Age then Valid := False;
    if WorkPlace <> '' then
      if (Pos(UpStr(WorkPlace), UpStr(A.WorkPlace)) = 0) then Valid := False;
    if Post <> '' then
      if (Pos(UpStr(Post), UpStr(A.Post)) = 0) then Valid := False;
    if PassBool then
      begin
	if (Passport <> A.Passport) or (Serial <> A.Serial) then Valid := False;
	if DateOfPass <> 0 then if DateOfPass <> A.DateOfPass then Valid := False;
	if PlaceOfPass <> '' then if PlaceOfPass <> A.PlaceOfPass then Valid := False;
      end;
   if Date <> ZeroDate then if Date <> A.Date then Valid := False;

  { Push card to list if filter get's it }

  if Valid then
    begin ScanSListNS(SourceC(A), False, BList); Inc(N); end;
    end;
  end;

  Close(F);  I := IOResult;
  SearchCBase := N;
end; { SearchCBase }

function SearchBBase(Data : TBCard; var BList : PSList; Take : Boolean) : Integer;
var
  F : file of TBCard;
  A : TBCard;
  Valid : Boolean;
  N : Longint;
  I, J : Word;
  dt : DateTime;
begin { SearchBBase }
  N := 0; Valid := True;
  Assign(F, LibraryBCard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryBCard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin SearchBBase := -1; Exit; end;
    until I = 0;

  while not Eof(F) do
    begin
      repeat
	Read(F, A); I := IOResult;
	if I <> 0 then
	  J := RetryDialog('Г░е╕ка п░и ╖е▓ене на ┤айла'^C +
			    LibraryBCard + ^C);
	  if J = _Cancel then J := 3;
	  if (J = 2) or (J = _Cancel) then
	    begin SearchBBase := -1; Exit; end;
      until I = 0;

      with Data do
	begin

  { Filter conditions }

  Valid := True;
    if ID <> '' then
      if (Pos(UpStr(ID), UpStr(A.ID)) = 0) then Valid := False;
    if Title <> '' then
      if (Pos(UpStr(Title), UpStr(A.Title)) = 0) then Valid := False;
    if Autor <> '' then
      if (Pos(UpStr(Autor), UpStr(A.Autor)) = 0) then Valid := False;
    if Topic <> '' then
      if (Pos(UpStr(Topic), UpStr(A.Topic)) = 0) then Valid := False;
    if Number > 0 then
      if Number <> A.Number then Valid := False;
    if Take then if Available(A) < 1 then Valid := False;

  { Push card to list if filter get's it }

    if Valid then
      begin ScanSListNS(SourceB(A), False, BList); Inc(N); end;
    end;
  end;

  Close(F); I := IOResult;
  SearchBBase := N;
end; { SearchBBase }

function SearchIBase(P1, P2 : Pointer; var B : PSList; Ret : Boolean) : Integer;
{ P1 - pointer to TCCard }
{ P2 - pointer to TBCard }
{ P1 <> nil & P2 <> nil = ERROR }
var
  F : file of TICard;
  A : TICard;
  R : ^TCCard;
  T : ^TBCard;
  Valid : Boolean;
  N : Longint;
  I, J : Word;
  dt : DateTime;
begin { SearchIBase }
  N := 0; Valid := True;
  R := P1; T := P2;
  Assign(F, LibraryICard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryICard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin SearchIBase := -1; Exit; end;
    until I = 0;

  while not Eof(F) do
    begin
      repeat
	Read(F, A); I := IOResult;
	if I <> 0 then
	  J := RetryDialog('Г░е╕ка п░и ╖е▓ене на ┤айла'^C +
			    LibraryICard + ^C);
	  if J = _Cancel then J := 3;
	  if (J = 2) or (J = _Cancel) then
	    begin SearchIBase := -1; Exit; end;
      until I = 0;

    { Filter conditions }

    Valid := True;
    if P1 <> nil then if SourceC(A.Reader) <> SourceC(R^) then Valid := False;
    if P2 <> nil then if SourceB(A.Title ) <> SourceB(T^) then Valid := False;
    if Ret or (P2 <> nil) then if A.Back then Valid := False;
    if Valid then
      begin
	 if P1 <> nil then
	   begin ScanSListNS(SourceI(A), A.Back, B); Inc(N); end;
	 if P2 <> nil then
	   begin ScanSListNS(SourceC(A.Reader), A.Back, B); Inc(N); end;
      end;
  end;
  Close(F);  I := IOResult;
  SearchIBase := N;
end; { SearchIBase }

function SearchITBase(var B : PSList; S : Boolean) : Longint;
var
  F : file of TICard;
  N, Q, W : Longint;
  I, J : Integer;
  El : TICard;
  dtG, dtT : DateTime;
begin { SearchITBase }
  N := 0;
  Assign(F, LibraryICard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryICard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin SearchITBase := -1; Exit; end;
    until I = 0;

    while not Eof(F) do
      begin
	Read(F, El); I := IOResult;
	if S then
	  begin
	    if not El.Back then
	      ScanSListNS(SourceIT(El, El.DateOfBack), El.Back, B);
	    Inc(N);
	  end else
	  begin
	    if not El.Back then
	      begin
		UnpackTime(El.DateOfBack, dtG);
		GetDate(dtT.Year, dtT.Month, dtT.Day, dtT.Sec);
		{ SubDates }
		with dtG do
		  begin
		    Hour := 0; Min := 0; Sec := 0;
		  end;
		Q := AddDates(dtG, BorrowPeriod);
		PackTime(dtT, W);
		if W > Q then
		  begin
		    ScanSListNS(SourceIT(El, Q), El.Back, B);
		    Inc(N);
		  end;
	      end;
	  end;
      end;
  Close(F);
  SearchITBase := N;
end; { SearchITBase }

function EraseCCard(var BList : PSList) : Integer;
var
  F, T : file of TCCard;
  I, J, N : Longint;
  El : TCCard;
  Valid : Boolean;
begin { EraseCCard }
  Assign(F, LibraryCCard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryCCard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin EraseCCard := -1; Exit; end;
    until I = 0;
  Assign(T, 'TEMP');
    repeat
      Rewrite(T); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐'^C'в░еменни┐ ┤айл'^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin EraseCCard := -1; Exit; end;
    until I = 0;

    while not Eof(F) do
      begin
	Read(F, El); I := IOResult;
	Valid := True;
        for N := 1 to MaxSList(BList) do
          if (SourceC(El) = SElement(N, BList)) and SStrBool(N, BList) then
            Valid := False;
	 if Valid then Write(T, El);
      end;
  Close(T); Close(F); I := IOResult;
  Erase(F); Rename(T, LibraryCCard); I := IOResult;
end; { EraseCCard }

function EraseBCard(var BList : PSList) : Integer;
var
  F, T : file of TBCard;
  I, J, N : Longint;
  El : TBCard;
  Valid : Boolean;
begin { EraseBCard }
  Assign(F, LibraryBCard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryBCard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin EraseBCard := -1; Exit; end;
    until I = 0;
  Assign(T, 'TEMP');
    repeat
      Rewrite(T); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐'^C'в░еменни┐ ┤айл'^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin EraseBCard := -1; Exit; end;
    until I = 0;

    while not Eof(F) do
      begin
	Read(F, El); I := IOResult;
	Valid := True;
        for N := 1 to MaxSList(BList) do
          if (SourceB(El) = SElement(N, BList)) and SStrBool(N, BList) then
            Valid := False;
	 if Valid then Write(T, El);
      end;
  Close(T); Close(F); I := IOResult;
  Erase(F); Rename(T, LibraryBCard); I := IOResult;
end; { EraseBCard }

function ReadCCard(Data : TCCard; S : string; Action : TAction) : Longint;
var
  F : file of TCCard;
  El : TCCard;
  I : Longint; J : Byte;
begin { ReadCCard }
  Assign(F, LibraryCCard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryCCard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin ReadCCard := -1; Exit; end;
    until I = 0;

    I := 1;
    while not Eof(F) do
      begin
	Read(F, El); J := IOResult;
	if SourceC(El) = S then
	  begin
	    case Action of
	      Edit : if EditReader
		(El, 'Редак▓и░ане на ╖и▓а▓ел▒ки ка░▓он', Primary, False) then
		 SaveCard(LibraryCCard, El, SizeOf(El), I);
	      Search : Reader(El);
	    end;
	    Break;
	  end;
	Inc(I);
      end;
    ReadCCard := I;
  Close(F);
end; { ReadCCard }

function ReadBCard(Data : TBCard; S : string; Action : TAction) : Longint;
var
  F : file of TBCard;
  El : TBCard;
  I : Longint; J : Byte;
begin { ReadBCard }
  Assign(F, LibraryBCard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryBCard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin ReadBCard := -1; Exit; end;
    until I = 0;

    I := 1;
    while not Eof(F) do
      begin
	Read(F, El); J := IOResult;
	if SourceB(El) = S then
	  begin
	    case Action of
	      Edit : if EditTitle(El, 'Редак▓и░ане на заглавие', Primary, False) then
		SaveCard(LibraryBCard, El, SizeOf(El), I);
	      Search : Title(El);
	    end;
	    Break;
	  end;
	Inc(I);
      end;
    ReadBCard := I;
  Close(F);
end; { ReadBCard }

function SaveICard(P : Pointer; B : PSList; E : Boolean) : Integer;
{ P - pointer to : [T] True-TCCard, False-TBCare }
{ P1&P2 <> nil = ERROR }
var
  Data : TICard;
  R : ^TCCard; CCard : TCCard;
  T : ^TBCard; BCard : TBCard;
  F1 : file of TCCard;
  F2 : file of TBCard;
  I, J : Integer;
  N, Z : Longint;
  dt : DateTime;
begin { SaveICard }
  Data.Back := False;
  GetDate(dt.Year, dt.Month, dt.Day, dt.Sec);
  PackTime(dt, Data.DateOfBack);

  if E then
    begin
      R := P; Data.Reader := R^;
    end else
    begin
      T := P; Data.Title := T^;
    end;

  if E then begin Assign(F2, LibraryBCard); Data.Reader := R^; end else
    begin Assign(F1, LibraryCCard); Data.Title := T^; end;

  repeat
    if E then Reset(F2) else Reset(F1); I := IOResult;
    if I <> 0 then
      begin
	if E then
          J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C+ LibraryBCard+ ^C)
        else
	  J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C+ LibraryCCard+ ^C);
      end;
      if J = _Cancel then J := 3;
      if (J = 2) or (J = _Cancel) then begin SaveICard := -1; Exit; end;
    until I = 0;

  if E then
    while not Eof(F2) do
      begin
        Read(F2, BCard); J := IOResult;
        for Z := 1 to MaxSList(B) do
          begin
            if (SStrBool(Z, B)) and (SElement(Z, B) = SourceB(BCard)) then
              begin
                Data.Title := BCard;
                if Available(BCard) > 0 then
                  begin
                    SaveCard(LibraryICard, Data, SizeOf(Data), 0);
                    Inc(N);
                  end;
                Break;
              end;
          end;
      end else
    while not Eof(F1) do
      begin
        Read(F1, CCard); J := IOResult;
        for Z := 1 to MaxSList(B) do
          begin
            if (SStrBool(Z, B)) and (SElement(Z, B) = SourceC(CCard)) then
              begin
                Data.Reader := CCard;
                SaveCard(LibraryICard, Data, SizeOf(Data), 0);
                Inc(N);
                Break;
              end;
          end;
      end;

  if E then Close(F2) else Close(F1);
  SaveICard := N;
end; { SaveICard }

function WriteICard(P1, P2, P3 : Pointer) : Integer;
{ P1 - pointer to TCCard }
{ P2 - pointer to TBCard }
{ P1&P2 <> nil = ERROR }
var
  F : file of TICard;
  I, J : Integer;
  R : ^TCCard; T : ^TBCard;
  N : Word;
  Z : Longint;
  El : TICard;
  A : PSList;
begin { WriteICard }
  R := P1; T := P2;
  Assign(F, LibraryICard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C+ LibraryICard+ ^C);
      if J = _Cancel then J := 3;
      if (J = 2) or (J = _Cancel) then
	begin WriteICard := -1; Exit; end;
    until I = 0;
    N := 0;
    while not Eof(F) do
      begin
	Read(F, El); I := IOResult;
	Inc(N);
	if ((P1 <> nil) and (SourceC(R^) = SourceC(El.Reader))) or
	   ((P2 <> nil) and (SourceB(T^) = SourceB(El.Title))) then
	  begin
	    A := P3;
            for Z := 1 to MaxSList(A) do
	      begin
		if SStrBool(Z, A) and
		  ((SourceI(El) = (SElement(Z, A))) and (P1 <> nil)) or
		  ((SourceC(El.Reader) = (SElement(Z, A))) and (P2 <> nil)) then
		  begin
		    El.Back := True;
		    SaveCard(LibraryICard, El, SizeOf(El), N);
		    Break;
		  end;
	      end;
	  end;
      end;
  Close(F);
end; { WriteICard }

function DeleteBackTitles : Integer;
var
  F, TEMP : file of TICard;
  A : TICard;
  I, J : Integer;
begin { DeleteBackTitles }
  Assign(F, LibraryICard);
    repeat
      Reset(F); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да о▓во░┐ ┤айла'^C + LibraryICard + ^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin DeleteBackTitles := -1; Exit; end;
    until I = 0;

  Assign(TEMP, 'TEMP');
    repeat
      Rewrite(TEMP); I := IOResult;
      if I <> 0 then
	J := RetryDialog('Не мога да ▒║здам'^C+'в░емени┐ ┤айл'^C);
	if J = _Cancel then J := 3;
	if (J = 2) or (J = _Cancel) then
	  begin DeleteBackTitles := -1; Exit; end;
    until I = 0;

    while not Eof(F) do
      begin
	Read(F, A); I := IOResult;
	if not A.Back then Write(TEMP, A);
      end;

  Close(TEMP); Close(F);
  Erase(F); Rename(TEMP, LibraryICard);
end; { DeleteBackTitles }