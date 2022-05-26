{**********************************}
{*                                *}
{*    Library unit (c) 1997       *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Lib;
{$F+,I-}
interface
uses Dialogs;

type
  TCCard = record
    Number : Longint;
    Name : string[40];
    Address : string[50];
    Phone : string[10];
    Profession : string[20];
    Education : Byte;
    Age : Word;
    WorkPlace : string[30];
    Post : string[20];
    PassBool : Boolean;
    Passport : Longint;
    Serial : Char;
    DateOfPass : Longint;
    PlaceOfPass : string[20];
    Date : Longint;
  end; { TCCard }

  TBCard = record
    ID : string[20];
    Title : string[45];
    Autor : string[45];
    Topic : string[25];
    Company : string[25];
    Price : Real;
    Number : Word;
  end; { TBCard }

  TICard = record
    Reader : TCCard;
    Title  : TBCard;
    DateOfBack : Longint;
    Back   : Boolean;
  end; { TICard }

  { Menus }

  procedure NewFile;
  procedure SelectFile;
  procedure SaveAsFile;
  procedure EraseFile;
  procedure CloseFile;
  procedure BaseInfo;
  procedure About;

  procedure NewReader;
  procedure NewTitle;

  procedure SearchReader;
  procedure SearchTitle;
  procedure Refresh;

  procedure NotReturnedTitles;
  procedure BusyTitles;

  function Password(B : Boolean) : Boolean;

  { Dialogs }

  function EditReader
    (var Data : TCCard; Caption : string; TD : TDialogs; _New : Boolean) : Boolean;
  function EditTitle
    (var Data : TBCard; Caption : string; TD : TDialogs; _New : Boolean) : Boolean;
  function SelectReader
    (Data : TCCard; Title : string; TD : TDialogs; P : Pointer) : Boolean;
  function SelectTitle
    (Data : TBCard; Title : string; TD : TDialogs; P : Pointer) : Boolean;
  function ReturnBook
    (P1, P2 : Pointer) : Boolean;

  procedure Reader(Data : TCCard);
  procedure Title (Data : TBCard);

  { Info }

  function ReadLicence : Boolean;

  { Flags }

const
  SelectedDataBase : Boolean = False;

implementation
uses Crt, Dos, Drivers, Errors, Lists, Math, Printer, Strings, Transfer, Views;
type
  TPass = string[30];
  TLicence = string[45];
  TAction = (Edit, Search);
const
  ZeroDate =  2147483647;
  ICardExt = '.LRI'; BCardExt = '.LRB'; CCardExt = '.LRC';
  SPass : TPass = '';
  EXESeek : TPass  = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
  LName : TLicence = 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';
  LOrgz : TLicence = 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC';
  Educ : array[0..4] of string[12] =
    ('без об░азов.', 'о▒новно', '▒░едно', 'пол│-ви▒╕е', 'ви▒╕е');
  BorrowPeriod : DateTime = (Year:0; Month:0; Day:30; Hour:0; Min:0; Sec:0);

  { Printer code }

  prNormal = #27#70#27#53;
  prBold   = #27#69;
  prItalic = #27#52;

var
  LibraryICard, LibraryCCard, LibraryBCard : string[12];
  F : file;

function ReadLicence;
begin { ReadLicence }
  Assign(F, ParamStr(0));
  Reset(F, 1); if IOResult = 0 then
  Seek(F, $1E604); if IOResult = 0 then
  BlockRead(F, LName, SizeOf(TLicence)); if IOResult = 0 then
  Seek(F, $1E632); if IOResult = 0 then
  BlockRead(F, LOrgz, SizeOf(TLicence)); if IOResult = 0 then
  Close(F);
  ReadLicence := (LName <> CharStr('B', 45)) and (LOrgz <> CharStr('C', 45));
end; { ReadLicence }

    {****************************************************************}

function SourceC(Data : TCCard) : string;
var
  S, S1, S2, S3 : string;
  I : Byte;
begin { SourceC }
  with Data do
    begin
      Str(Number, S1); Str(Age, S2); Str(Passport, S3); S3 := S3 + ' ';
      for I := 8 downto 1 do if Number < Power(10, I) then S1 := '0' + S1;
      S:=S1+#21+FormStr(Name,40,Left)+#21+FormStr(Address,50,Left)+#21+
      FormStr(Phone,10,Left)+#21+FormStr(Profession,20,Left)+#21+
      FormStr(Educ[Education],12,Left)+#21+FormStr(S2,3,Left)+#21+
      FormStr(WorkPlace,30,Left)+#21+FormStr(Post,20,Left)+#21+
      FormStr(S3+Serial,9,Left)+#21+Long2Date(DateOfPass)+
      #21+FormStr(PlaceOfPass,20,Left)+#21+Long2Date(Date);
    end;
  SourceC := S;
end; { SourceC }

function SourceB(Data : TBCard) : string;
var S1, S2 : string;
begin { SourceB }
  with Data do
    begin
      Str(Price:-9 : 2, S1); Str(Number, S2);
      S1 := FormStr(Title,45,Left)+#21+FormStr(ID,20,Left)+#21+
      FormStr(Autor,45,Left)+#21+FormStr(Topic,25,Left)+#21+FormStr(S1,12,Left)+
      #21+FormStr(Company,25,Left)+#21+FormStr(S2,3,Left);
    end;
  SourceB := S1;
end; { SourceB }

function SourceI(Data : TICard) : string;
var
  S : string;
  dt : DateTime;
begin { SourceI }
  UnpackTime(Data.DateOfBack, dt);
  dt.Hour := 0; dt.Min := 0; dt.Sec := 0;
  with Data, Data.Title do
    S := FormStr(Title,45,Left)+#21+FormStr(ID,20,Left)+#21+
    FormStr(Autor,45,Left)+#21+FormStr(Topic,25,Left)+#21+
    FormStr(Company,25,Left)+#21+Long2Date(DateOfBack)+#21+
    Long2Date(AddDates(dt, BorrowPeriod));
  if Data.Back then S := '*' + S else S := ' ' + S;
  SourceI := S;
end; { SourceI }

function SourceIT(Data : TICard; L : Longint) : string;
begin { SourceIT }
  with Data, Data.Title do
    SourceIT := FormStr(Title, 45, Left)+' '#21' '+
    FormStr(Reader.Name,40, Left)+#21+ Long2Date(L);
end; { SourceIT }

    {****************************************************************}

    {$I FILEPROC.INC}

    {****************************************************************}

procedure NewFile;
var
  dgNewFile : TDialog;
  Valid : Boolean;
  J, Code : Word;
  S : string;
  I : Byte;
begin { NewFile }
  S := '';
  with dgNewFile do
    begin
      Init(Primary, 'Нова база данни', 20, 8, 60, 17, 1);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 29, 2, 4, 3, True, True, kbAltD);
        SetItem('  ~О~▓каз  ', nil, nil, 29, 4, 4, 3, True, True, kbAltO);
      SetGroup(_txt, NormStr);
        SetItem('~И~ме на база▓а данни'^L, nil, nil,
          2, 2, 2, 2, True, True, kbNoKey);
        SetItem('За база▓а данни е необ╡одимо да'+ ^C +
                '▒║╣е▒▓в│ва▓ и ▓░и▓е й ╖а▒▓и:' + ^C,
          nil, nil, 2, 6, 1, 1, True, True, kbNoKey);
        SetItem('~<име>.LRI, <име>.LRB и <име>.LRC~'+^C,
          nil, nil, 2, 8, 1, 1, True, True, kbNoKey);
      SetGroup(_str, NormStr);
        SetItem('', @S, nil, 2, 3, 28, 2, True, True, kbAltI);
      repeat
        Valid := True;
        Code := ActiveDialog;
        S := UpStr(S);
        if Length(S) < 1 then Valid := False;
        if not(Ord(S[1]) in [48..57, 65..90]) then Valid := False;
        for I := 2 to Length(S) do
          if Ord(S[I]) in [34, 46..47, 58..62, 91..93, 124, 128..255] then
            Valid := False;
        if (Code = _Cancel) or ((Gr^ = 1) and (It^ = 2)) then Valid := True;
        if not Valid then
          ErrorDialog('Г░е╕ка в име▓о на ┤айла' + ^C);
      until Valid;
      if ((Code = _Cancel) or ((Gr^ = 1) and (It^ = 2))) then Valid := False;
      Done;
        if Valid then
          begin
            LibraryICard := S + ICardExt;
            LibraryBCard := S + BCardExt;
            LibraryCCard := S + CCardExt;
              if (CreateDataBase(LibraryICard) <> 3) then
              if (CreateDataBase(LibraryBCard) <> 3) then
              if (CreateDataBase(LibraryCCard) <> 3) then
                SelectedDataBase := True;
          end;
    end;
end; { NewFile }

procedure SelectFile;
const
  MissBase = 'Да ▒║здам ли лип▒ва╣а▓а база данни?';
var
  dgSelectFile : TDialog;
  Valid : Boolean;
  Code, I : Word;
  FileName : string;
begin { SelectFile }
  Filter := '*.lr*';
  with dgSelectFile do
    begin
      Init(Secondary, 'Избо░ на библио▓ека', 20, 5, 60, 21, 2);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 29, 2, 4, 3, True, True, kbAltD);
        SetItem('  ~О~▓каз  ', nil, nil, 29, 4, 4, 3, True, True, kbAltO);
      SetGroup(_str, NormStr);
        SetItem('~Ф~ил▓║░ ', @Filter, nil, 2, 2, 17, 1, True, True, kbAltF);
      SetGroup(_fil, NormStr);
        SetItem('', @FileName, nil, 2, 5, 15, 2, True, True, kbNoKey);
      repeat
        Valid := True;
        Code := ActiveDialog;
        if (Gr^ = 1) and (It^ = 2) then Code := _Cancel;
        if (FileName = '') and (Code <> _Cancel) then Valid := False;
      until Valid;
      Done;
    end;
    if Valid and (Code <> _Cancel) then
      begin
        SelectedDataBase := True;
        Delete(FileName, Pos('.', FileName), Length(FileName));
        FileName := UpStr(FileName);
        LibraryICard := FileName + ICardExt;
        LibraryBCard := FileName + BCardExt;
        LibraryCCard := FileName + CCardExt;
        Assign(F, LibraryICard);
        Reset(F); Code := IOResult;
        SelectedDataBase := True;
          if Code <> 0 then
            if not (CreateDataBase(FileName + ICardExt) <> 3) then SelectedDataBase := False;
         Assign(F, LibraryBCard);
         Reset(F); Code := IOResult;
          if Code <> 0 then
            if not (CreateDataBase(FileName + BCardExt) <> 3) then
              SelectedDataBase := False;
         Assign(F, LibraryCCard);
         Reset(F); Code := IOResult;
          if Code <> 0 then
            if not (CreateDataBase(FileName + CCardExt) <> 3) then
              SelectedDataBase := False;
      end;
end; { SelectFile }

procedure SaveAsFile;
var
  dgSaveAs : TDialog;
  Valid : Boolean;
  J, Code : Word;
  S : string;
  I : Byte;
begin { SaveAsFile }
  S := '';
  with dgSaveAs do
    begin
      Init(Secondary, 'Запи▒ под ново име', 20, 8, 60, 17, 3);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 29, 2, 4, 3, True, True, kbAltD);
        SetItem('  ~О~▓каз  ', nil, nil, 29, 4, 4, 3, True, True, kbAltO);
      SetGroup(_txt, NormStr);
        SetItem('~И~ме на база▓а данни'^L, nil, nil,
          2, 2, 2, 2, True, True, kbNoKey);
        SetItem('За база▓а данни е необ╡одимо да'+ ^C +
                '▒║╣е▒▓в│ва▓ и ▓░и▓е й ╖а▒▓и:' + ^C,
          nil, nil, 2, 6, 1, 1, True, True, kbNoKey);
        SetItem('~<име>.LRI, <име>.LRB и <име>.LRC~'+^C,
          nil, nil, 2, 8, 1, 1, True, True, kbNoKey);
      SetGroup(_str, NormStr);
        SetItem('', @S, nil, 2, 3, 28, 2, True, True, kbAltI);
      repeat
        Valid := True;
        Code := ActiveDialog;
        S := UpStr(S);
        if Length(S) < 1 then Valid := False;
        if not(Ord(S[1]) in [48..57, 65..90]) then Valid := False;
        for I := 2 to Length(S) do
          if Ord(S[I]) in [34, 46..47, 58..62, 91..93, 124, 128..255] then
            Valid := False;
        if (Code = _Cancel) or ((Gr^ = 1) and (It^ = 2)) then Valid := True;
        if not Valid then
          ErrorDialog('Г░е╕ка в име▓о на ┤айла' + ^C);
      until Valid;
      if ((Code = _Cancel) or ((Gr^ = 1) and (It^ = 2))) then Valid := False;
      Done;
        if Valid then
          begin
            if CopyBaseAs(LibraryCCard, S+CCardExt) then
            if CopyBaseAs(LibraryBCard, S+BCardExt) then
            if CopyBaseAs(LibraryICard, S+ICardExt) then
              SelectedDataBase := True;
            LibraryCCard := S + CCardExt;
            LibraryBCard := S + BCardExt;
            LibraryICard := S + ICardExt;
          end;
    end;
end; { SaveAsFile }

procedure EraseFile;
var
  dgErase : TDialog;
  Code : Word;
begin { EraseFile }
  with dgErase do
    begin
      Init(Secondary, 'Из▓░иване на база данни', 25, 8, 55, 17, 4);
      SetGroup(_rbt, NormStr);
        SetItem('~И~дек▒и', nil, nil, 10, 3, 2, 2, True, True, kbAltI);
        SetItem('~З~аглави┐', nil, nil, 10, 4, 2, 2, True, True, kbAltZ);
        SetItem('~К~а░▓они', nil, nil, 10, 5, 2, 2, True, True, kbAltK);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 4, 7, 2, 2, True, True, kbAltD);
        SetItem('  ~O~▓каз  ', nil, nil, 16, 7, 2, 2, True, True, kbAltO);
        Code := ActiveDialog;
        if (Gr^ = 2) and (It^ = 2) then Code := _Cancel;
        if Code <> _Cancel then
          begin
            if Dialog^[1]^.Switch[1]^ then
              begin
                Assign(F, LibraryICard); Erase(F); Code := IOResult;
              end;
            if Dialog^[1]^.Switch[2]^ then
              begin
                Assign(F, LibraryBCard); Erase(F); Code := IOResult;
              end;
            if Dialog^[1]^.Switch[3]^ then
              begin
                Assign(F, LibraryCCard); Erase(F); Code := IOResult;
              end;
            if Dialog^[1]^.Switch[1]^ or Dialog^[1]^.Switch[2]^ or
              Dialog^[1]^.Switch[3]^ then SelectedDataBase := False;
          end;
        Done;
    end;
end; { EraseFile }

procedure CloseFile;
begin { CloseFile }
  SelectedDataBase := False;
  LibraryICard := ''; LibraryBCard := ''; LibraryCCard := '';
end; { CloseFile }

procedure BaseInfo;
var
  dgInfo : TDialog;
  L : Longint;
  S : string;
begin  { BaseInfo }
  with dgInfo do
    begin
      Init(Secondary, 'Ин┤о░ма╢и┐ за база▓а данни', 15, 6, 65, 21, 5);
      SetGroup(_box, NormStr);
        SetItem(' ~Файлове~ ', nil, nil, 1, 2, 2, 11, True, True, kbNoKey);
        SetItem(' ~Данни~ ', nil, nil, 1, 6, 3, 4, True, True, kbNoKey);
      SetGroup(_txt, NormStr);
        SetItem(LibraryICard + ', ' + LibraryBCard + ', ' + LibraryCCard + ^L,
          nil, nil, 2, 3, 50, 2, True, True, kbNoKey);
        SetItem('Чи▓а▓ели:'^L, nil, nil, 2, 7, 15, 12, True, True, kbNoKey);
        SetItem('Заглави┐:'^L, nil, nil, 2, 8, 15, 12, True, True, kbNoKey);
        SetItem('Взе▓и книги:'^L, nil, nil, 2, 9, 15, 12, True, True, kbNoKey);
      Assign(F, LibraryCCard); Reset(F, 1); L := IOResult;
        L := FileSize(F); Close(F); Str(L div SizeOf(TCCard), S);
        SetItem('~'+S+'~'^R, nil, nil, 2, 7, 3, 12, True, True, kbNoKey);
      Assign(F, LibraryBCard); Reset(F, 1); L := IOResult;
        L := FileSize(F); Close(F); Str(L div SizeOf(TBCard), S);
        SetItem('~'+S+'~'^R, nil, nil, 2, 8, 3, 12, True, True, kbNoKey);
      Assign(F, LibraryICard); Reset(F, 1); L := IOResult;
        L := FileSize(F); Close(F); Str(L div SizeOf(TICard), S);
        SetItem('~'+S+'~'^R, nil, nil, 2, 9, 3, 12, True, True, kbNoKey);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 22, 13, 4, 3, True, True, kbAltD);
      ActiveDialog;
      Done;
    end;
end; { BaseInfo }

procedure About;
var
  dgAbout : TDialog;
  Regs : Registers;
  S1, S2 : string;
begin { About }
  with dgAbout do
    begin
      Init(Secondary, 'Ин┤о░ма╢и┐ за п░ог░ама▓а', 10, 5, 70, 21, 0);
      SetGroup(_txt, NormStr);
        S1 := ProgramName + ^L + 'Ве░▒и┐ 1.0'^L +
        'П░ог░амен код (c) 1997 Мом╖ил Х░и▒▓ов Мин╖ев'^L;
      SetItem(S1, nil, nil, 3, 2, 10, 2, True, True, kbNoKey);
      SetItem(LName+^L, nil, nil, 4, 8, 3, 1, True, True, kbNoKey);
      SetItem(LOrgz+^L, nil, nil, 4, 9, 3, 1, True, True, kbNoKey);
        S1 := 'ДОС ве░▒и┐:'^L+
              'Свободна паме▓:'^L;
      SetItem(S1, nil, nil, 4, 12, 10, 1, True, True, kbNoKey);
        Regs.AH := $30; Intr($21, Regs);
        Str(Regs.AL, S1); Str(Regs.AH, S2);
          S1 := '~' + S1 + '.' + S2 + '~'^R;
        Str(MaxAvail div 1024, S2); S1 := S1 + '~' + S2 + ' K~'^R;
      SetItem(S1, nil, nil, 2, 12, 11, 1, True, True, kbNoKey);
      { Logo }
        SetItem(#26#27#28^R, nil, nil, 49, 10, 3, 1, True, False, kbNoKey);
        SetItem(#29#30#31^R, nil, nil, 49, 11, 3, 1, True, False, kbNoKey);
      SetGroup(_box, NormStr);
        SetItem(' ~Реги▒▓░а╢и┐~ ', nil, nil, 3, 7, 10, 6,
        True, True, kbNoKey);
      SetGroup(_box, NormStr);
        SetItem(' ~Си▒▓емна ин┤о░ма╢и┐~ ', nil, nil, 3, 11, 10, 2,
        True, True, kbNoKey);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 49, 2, 4, 3, True, True, kbAltD);
      ActiveDialog;
      Done;
    end;
end; { About }

    {****************************************************************}

procedure NewReader;
var Data : TCCard;
begin { NewReader }
  FillChar(Data, SizeOf(Data), 0);
  if EditReader(Data, 'С║здаване на нов ка░▓он', Primary, True) then
    SaveCard(LibraryCCard, Data, SizeOf(Data), 0);
end; { NewReader }

procedure NewTitle;
var Data : TBCard;
begin { NewTitle }
  FillChar(Data, SizeOf(Data), 0);
  if EditTitle(Data, 'С║здаване на ново заглавие', Primary, True) then
    SaveCard(LibraryBCard, Data, SizeOf(Data), 0);
end; { NewTitle }

    {****************************************************************}

procedure SearchReader;
var Data : TCCard;
begin { SearchReader }
  FillChar(Data, SizeOf(Data), 0);
  if EditReader(Data, 'Т║░▒ене ка░▓он на ╖и▓а▓ел * Фил▓║░', Secondary, False) then
    SelectReader(Data, 'Спи▒║к на ╖и▓а▓ел▒ки▓е ка░▓они', Primary, nil);
end; { SearchReader }

procedure SearchTitle;
var Data : TBCard;
begin { SearchTitle }
  FillChar(Data, SizeOf(Data), 0);
  if EditTitle(Data, 'Т║░▒ене на заглавие * Фил▓║░', Secondary, False) then
    SelectTitle(Data, 'Спи▒║к на заглави┐▓а в библио▓ека▓а', Primary, nil);
end; { SearchTitle }

procedure Refresh;
var I : Integer;
begin { Refresh }
  I := Question('Да ~из▓░и┐~ ли ин┤о░ма╢и┐▓а'^C+
                'за в║░на▓и▓е заглави┐?'^C);
  if I = 1 then DeleteBackTitles;
end; { Refresh }

    {****************************************************************}

procedure NotReturnedTitles;
const
  LnE = #13#10;
var
  dgRet : TDialog;
  A, P : PSList;
  I, J : Integer;
  N : Longint;
  Code : Word;
  S, U : string;
begin { NotReturnedTitles }
  with dgRet do
    begin
      Init(Primary, 'Нев║░на▓и в ▒░ок заглави┐', 15, 5, 65, 20, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 39, 2, 1, 1, True, True, kbAltD);
        SetItem('  ~П~е╖а▓  ', nil, nil, 39, 4, 1, 1, True, True, kbAltP);
      SetGroup(_lst, NormStr);
        SetItem('', nil, nil, 2, 3, 15, 2, False, True, kbNoKey);
        I := SearchITBase(Dialog^[2]^.StrList[1], False);
      Code := ActiveDialog;
      if Code <> _Cancel then
        if (Gr^ = 1) and (It^ = 2) then
          begin
            NewSList(P, 'NOTR');
            ScanSListNS('НЕВЪРНАТИ В СРОК ЗАГЛАВИЯ:', False, P);
            A := Dialog^[2]^.StrList[1];
            for N := 1 to MaxSList(A) do
              begin
                J := 0; S := ''; U := SElement(N, A);
                for I := 1 to Length(U) do
                  begin
                    if U[I] <> #21 then S := S + U[I]
                      else begin
                        Inc(J);
                        case J of
                          1 : ScanSListNS(LnE + '] ' + S, False, P);
                          2 : ScanSListNS(LnE + prBold + S + prNormal, False, P);
                        end;
                        S := '';
                      end;
                    if I = Length(U) then ScanSListNS(' ' + S + LnE, False, P);
                  end;
              end;
            Print(P);
            DelSList(P);
          end;
      Done;
    end;
end; { NotReturnedTitles }

procedure BusyTitles;
const LnE = #13#10;
var
  dgBusy : TDialog;
  A, P : PSList;
  I, J : Integer;
  N : Longint;
  Code : Word;
  S, U : string;
begin { BusyTutle }
  with dgBusy do
    begin
      Init(Primary, 'Спи▒║к на зае▓и▓е заглави┐', 15, 5, 65, 20, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 39, 2, 1, 1, True, True, kbAltD);
        SetItem('  ~П~е╖а▓  ', nil, nil, 39, 4, 1, 1, True, True, kbAltP);
      SetGroup(_lst, NormStr);
        SetItem('', nil, nil, 2, 3, 15, 2, False, True, kbNoKey);
        I := SearchITBase(Dialog^[2]^.StrList[1], True);
      Code := ActiveDialog;
      if (Code <> _Cancel) and (I<>-1) then
        if (Gr^ = 1) and (It^ = 2) then
          begin
            NewSList(P, 'BUSY');
            ScanSListNS('ЗАЕТИ ЗАГЛАВИЯ:', False, P);
            A := Dialog^[2]^.StrList[1];
            for N := 1 to MaxSList(A) do
              begin
                J := 0; S := ''; U := SElement(N, A);
                for I := 1 to Length(U) do
                  begin
                    if U[I] <> #21 then S := S + U[I]
                      else begin
                        Inc(J);
                        case J of
                          1 : ScanSListNS(LnE + '] ' + S, False, P);
                          2 : ScanSListNS(LnE + prBold + S + prNormal, False, P);
                        end;
                        S := '';
                      end;
                    if I = Length(U) then ScanSListNS(' ' + S + LnE, False, P);
                  end;
              end;
            Print(P);
            DelSList(P);
          end;
      Done;
    end;
end; { BusyTitle }

    {****************************************************************}

function Password;
var
  dgPassword : TDialog;
  S1, S2, S3 : string;
  PassIndx, I : Byte;
  Valid : Boolean;
  Code : Word;
begin { Password }
  begin
    Assign(F, ParamStr(0));
    Reset(F, 1); Code := IOResult;
    if (not B) and (Code <> 0) then
      begin Password := False; Exit; end;
    Seek(F, $1E5E4); Code := IOResult;
    BlockRead(F, SPass, SizeOf(SPass)); Code := IOResult;
    PassIndx := Length(SPass);
    for I := 1 to PassIndx do
      SPass[I] := Chr(Ord(SPass[I]) xor PassIndx);
    if (not B) and (SPass = '') then
      begin Password := True; Exit end;
  end;
  S1 := ''; S2 := ''; S3 := '';
  with dgPassword do
    begin
      if B then
        Init(Primary, 'П░ом┐на на па░ола▓а', 15, 7, 65, 18, 0) else
        Init(Alert, 'П░ове░ка на па░ола▓а', 15, 7, 65, 15, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 39, 2, 4, 3, True, True, kbAltD);
        SetItem('  ~О~▓каз  ', nil, nil, 39, 4, 4, 3, True, True, kbAltO);
      if B then
        begin
          SetGroup(_txt, NormStr);
          SetItem('~С~▓а░а па░ола' + ^L, nil, nil, 2, 2, 2, 2,
            True, (SPass <> ''), kbNoKey);
          SetItem('~Н~ова па░ола' + ^L, nil, nil, 2, 5, 2, 2,
            True, True, kbNoKey);
          SetItem('~П~ов▓о░ение на нова▓а па░ола' + ^L, nil, nil, 2, 8, 2, 2,
            True, True, kbNoKey);
          SetGroup(_str, PassStr);
            SetItem('', @S1, nil, 2, 3, 16, 3, True, (SPass <> ''), kbAltS);
            SetItem('', @S2, nil, 2, 6, 16, 3, True, True, kbAltN);
            SetItem('', @S3, nil, 2, 9, 16, 3, True, True, kbAltP);
        end else
        begin
          SetGroup(_txt, NormStr);
            SetItem('~П~а░ола'^L, nil, nil, 2, 2, 2, 2, True, True, kbNoKey);
          SetGroup(_str, PassStr);
            SetItem('', @S1, nil, 2, 3, 16, 3, True, True, kbAltP);
        end;

    if B then
      begin
        repeat
          Valid := True;
          Code := ActiveDialog;
          if (Gr^ = 1) and (It^ = 2) then Code := _Cancel;
          if (S1 <> SPass) or (S2 <> S3) then Valid := False;
          if not(Valid) and (Code <> _Cancel) then
            ErrorDialog('Г░е╕ка п░и в║веждане на ' + ^C + 'па░ола▓а' + ^C);
            if Code = _Cancel then Valid := True;
        until Valid;
        if Valid and (Code <> _Cancel) then
          begin
            SPass := S2;
            PassIndx := Length(SPass);
            for I := 1 to PassIndx do
              SPass[I] := Chr(Ord(SPass[I]) xor PassIndx);
            Seek(F, $1E5E4); Code := IOResult;
            BlockWrite(F, SPass, SizeOf(SPass)); Code := IOResult;
          end;
      end else
      begin
        Code := ActiveDialog;
        if (Gr^ = 1) and (It^ = 2) then Code := _Cancel;
        Valid := (SPass = S1) and (Code <> _Cancel);
      end;
      Password := Valid;
      SPass := '';
      Done;
    end;
  Close(F);
end; { Password }

    {****************************************************************}

function EditReader;
var
  dgEditCCard : TDialog;
  Code, Z : Word;
  S, S1, S2, S3, S4, S5, S6 : string;
  Valid, C : Boolean;
  dt : DateTime;
  Clip : TCCard;
  I, L, Q : Longint;
begin { EditReader }
  L := Data.Date;
  if L = 0 then
    begin GetDate(dt.Year, dt.Month, dt.Day, Code); PackTime(dt, L); end;
  UnpackTime(L, dt);
  Clip := Data;
  S := Long2Date(L);
  Valid := False;
  with dgEditCCard, Data do
    begin
      { Init }
      if Number > 0 then
        begin
          Str(Number, S1);
          for I := 8 downto 1 do if Number < Power(10, I) then S1 := '0' + S1;
        end else S1 := '';
      if Age > 0 then Str(Age, S2) else S2 := '';
      if Passport > 0 then
        begin
          Str(Passport, S3);
          for I := 6 downto 1 do if Passport < Power(10, I) then S3 := '0' + S3;
        end else S3 := '';
      if Ord(Serial) > 0 then S4 := Serial else S4 := '';
      if (DateOfPass <> ZeroDate) and (DateOfPass <> 0) then
        S5 := Long2Date(DateOfPass) else S5 := '';
      S6 := '';
      Init(TD, Caption, 5, 4, 75, 22, 0);
  SetGroup(_but, NormStr);
    SetItem('  ~Д~об░е  ', nil, nil, 59, 2, 1, 3, True, True, kbAltD);
    SetItem('  ~О~▓каз  ', nil, nil, 59, 4, 1, 3, True, True, kbAltO);
  SetGroup(_str, NumbStr);
    SetItem('~Н~оме░       ', @S1, nil, 3, 2, 44, 3, True, True, kbAltN);
  SetGroup(_str, NormStr);
    SetItem('~И~ме         ', @Name, nil, 3, 4, 13, 1, True, True, kbAltI);
    SetItem('~А~д░е▒       ', @Address, nil, 3, 6, 3, 1, True, True, kbAltA);
    SetItem('~Т~еле┤он     ', @Phone, nil, 3, 7, 43, 1, True, True, kbAltT);
    SetItem('~П~░о┤е▒и┐    ', @Profession, nil, 3, 8, 33, 1, True, True, kbAltP);
    SetItem('~М~е▒▓о░або▓а ', @WorkPlace, nil, 3, 9, 23, 1, True, True, kbAltM);
    SetItem('Д~л~║жно▒▓    ', @Post, nil, 3, 10, 33, 1, True, True, kbAltL);
  SetGroup(_box, NormStr);
    SetItem(' ~Об░азование~ ', nil, nil, 53, 10, 1, 2, True, True, kbNoKey);
    SetItem('', nil, nil, 2, 12, 18, 2, True, True, kbNoKey);
  SetGroup(_str, NumbStr);
    SetItem('В~║~з░а▒▓     ', @S2, nil, 3, 11, 50, 3, True, True, kbAltY);
  SetGroup(_rbt, NormStr);
    SetItem('Па▒по░▓ ', nil, nil, 3, 12, 43, 3, Data.PassBool, True, kbNoKey);
  SetGroup(_str, NumbStr);
    SetItem('Номе░  ', @S3, nil, 4, 13, 50, 1, True, True, kbNoKey);
  SetGroup(_str, NormStr);
    SetItem('Се░и┐ ', @S4, nil, 22, 13, 39, 1, True, True, kbNoKey);
    SetItem('Да▓а   ', @S5, nil, 4, 14, 47, 1, True, True, kbNoKey);
    SetItem('Г░.(▒) ', @PlaceOfPass, nil, 4, 15, 37, 1, True, True, kbNoKey);
  SetGroup(_obt, NormStr);
    SetItem('Бе~з~ об░азов.', nil, nil, 54, 11, 4, 7, 0=Education, True, kbAltZ);
    SetItem('О~▒~новно', nil, nil, 54, 12, 4, 7, 1=Education, True, kbAltS);
    SetItem('С~░~едно', nil, nil, 54, 13, 4, 8, 2=Education, True, kbAltR);
    SetItem('Пол~│~-ви▒╕е', nil, nil, 54, 14, 4, 9, 3=Education, True, kbAltU);
    SetItem('~В~и▒╕е', nil, nil, 54, 15, 4, 10, 4=Education, True, kbAltW);
  if PKind^ = Primary then begin
  SetGroup(_txt, NormStr);
    SetItem('Да▓а на ▒║здаване: ~'+ S + '~'^C, nil, nil, 1, 17, 1, 4, True, True, kbNoKey);
  end else begin
  SetGroup(_str, NormStr);
    SetItem('Да▓а на ▒║здаване: ', @S6, nil, 19, 17, 20, 4, True, True, kbNoKey);
  end;

  repeat
    Valid := True;
    Code := ActiveDialog;
    if (Gr^ = 1) and (It^ = 2) then Code := _Cancel;
    if Dialog^[6]^.Switch[1]^ then
      begin
        if Length(S3) < 7 then Valid := False;
        for I := 1 to Length(S3) do
          if not(Ord(S3[I]) in [48..57]) then Valid := False;
        S4 := UpStr(S4);
        if not(Ord(S4[1]) in [128..159]) then Valid := False;
        if Date2Long(S5) = MaxLongint then Valid := False;
      end;
    if (PKind^ <> Primary) and (Date2Long(S6) = MaxLongint) and
      (Length(S6) > 0) then Valid := False;
    if (not Valid) and (not((Code = _Cancel) or ((Gr^ = 1) and (It^ = 2)))) then
      ErrorDialog('Г░е╕ка в данни▓е за'^C'ка░▓она'^C);
    if Valid then Val(S1, Q, Z);
    C := _New;
    if not _New then if (Q <> Number) then C := True;
    if Valid and (PKind^ = Primary) and (Code <> _Cancel) and C then
    if (Equal(@Q, False)) then
      begin
        ErrorDialog('Има ка░▓он в база▓а данни'^C'▒║▒ ▒║╣и┐ номе░'^C);
        Valid := False;
      end;
  until Valid or (Code = _Cancel);
  if ((Code = _Cancel) or ((Gr^ = 1) and (It^ = 2))) then Valid := False;

    { Transfer Dialog info to Data record }
    if Valid then
      begin
        Val(S1, I, Code); Data.Number := Abs(I);
        Val(S2, I, Code); Data.Age := Abs(I);
          for I := 1 to dgEditCCard.Dialog^[9]^.Numb^ do
            if Dialog^[9]^.Switch[I]^ then Education := Pred(I);
        Val(S3, I, Code); Data.Passport := I;
        Data.PassBool := Dialog^[6]^.Switch[1]^;
        if S4 <> '' then Data.Serial := S4[1];
        Data.DateOfPass := Date2Long(S5);             { Date of the passport }
        if PKind^ = Primary then
          begin                                           { Date of creation }
            GetDate(dt.Year, dt.Month, dt.Day, Code);
            PackTime(dt, Data.Date);
         end else Data.Date := Date2Long(S6);
      end;
        if Code = _Cancel then Data := Clip;
        Done;
        EditReader := Valid;
    end;
end; { EditReader }

function EditTitle;
var
  dgEditBCard : TDialog;
  Valid, C : Boolean;
  Code, D : Word;
  I : Integer;
  R : Real;
  Clip : TBCard;
  S, S1 : string;
begin { EditTitle }
  Clip := Data;
  with dgEditBCard, Data do
    begin
      if Number > 0 then Str(Number, S) else S := '';
      Str(Price:-9:2, S1);
      Init(TD, Caption, 10, 5, 70, 21, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 49, 2, 4, 3, True, True, kbAltD);
        SetItem('  ~О~▓каз  ', nil, nil, 49, 4, 4, 3, True, True, kbAltO);
      SetGroup(_str, NormStr);
        SetItem('УД~К~ ', @ID, nil, 7, 4, 27, 3, True, True, kbAltK);
        SetItem('~З~аглавие ', @Title, nil, 2, 7, 2, 1, True, True, kbAltZ);
        SetItem('~А~в▓о░ ', @Autor, nil, 5, 8, 2, 1, True, True, kbAltA);
        SetItem('~Т~ема ', @Topic, nil, 6, 9, 22, 1, True, True, kbAltT);
        SetItem('~И~зда▓ел▒▓во ', @Company, nil, 4, 11, 17, 1, True, True, kbAltI);
      SetGroup(_str, NumbStr);
        SetItem('~Е~дини╖на ╢ена ', @S1, nil, 2, 12, 29, 1, True, True, kbAltI);
        SetItem('~Е~кземпл┐░и о▓ заглавие▓о ',
          @S, nil, 26, 13, 4, 1, True, True, kbAltE);
      repeat
        Valid := True;
        Code := ActiveDialog;
        if ((Gr^ = 1) and (It^ = 2)) then Code := _Cancel;
        if (Code <> _Cancel) and (PKind^ = Primary) then
          begin
            Val(S, I, D);
            if (D <> 0) or (I < 1) then Valid := False else Number := I;
            Val(S1, R, D);
            if (D <> 0) or (R < 0) then Valid := False else Price := R;
            if (ID = '') or (Title = '') then Valid := False;
            if not Valid then
              ErrorDialog('Невалидна ин┤о░ма╢и┐'^C'за заглавие'^C);

            C := _New;
            if not _New then if (Clip.ID <> ID) then C := True;
            if Valid and (PKind^ = Primary) and (Code <> _Cancel) and C then
            if (Equal(@ID, True)) then
              begin
                ErrorDialog('Има заглавие в база▓а данни'^C'▒║▒ ▒║╣и┐ УДК'^C);
                Valid := False;
              end;
          end;
      until Valid;
      if Code = _Cancel then Data := Clip;
      Done;
      EditTitle := (Code <> _Cancel);
    end;
end; { EditTitle }

function SelectReader;
var
  dgSelectC : TDialog;
  A, BList : PSList;
  _Title : ^TBCard;
  Valid, O : Boolean;
  Code : Word;
  I, N, Q, Z : Longint;
begin { SelectReader }
  with dgSelectC do
    begin
      Init(TD, Title, 3, 4, 78, 23, 0);
    SetGroup(_but, NormStr);
      SetItem('  ~Д~об░е        ', nil, nil, 58,  2, 1, 1, True, True, kbAltD);
      SetItem('  ~М~а░ки░ане    ', nil, nil, 58,  4, 1, 1, True, True, kbAltM);
      SetItem('  Ин~в~е░▓и░ане  ', nil, nil, 58,  6, 1, 1, True, True, kbAltW);
  if PKind^ = Primary then
    begin
      SetItem('  ~И~з▓░иване    ', nil, nil, 58,  9, 1, 1, True, True, kbAltI);
      SetItem('  ~Р~едак▓и░ане ', nil, nil, 58, 11, 1, 1, True, True, kbAltR);
      SetItem('  ~К~а░▓он      ', nil, nil, 58, 13, 1, 1, True, True, kbAltK);
      SetItem('  ~П~е╖а▓        ', nil, nil, 58, 15, 1, 1, True, True, kbAltP);
    end else begin _Title := P; N := Available(_Title^); end;
    SetGroup(_lst, NormStr);
      SetItem('', nil, nil, 2, 3, 20, 4, True, True, kbNoKey);
      BList := Dialog^[2]^.StrList[1]; { Shorter name }
      I := SearchCBase(Data, BList);
    SetGroup(_txt, NormStr);
      SetItem('Спи▒║к на наме░ени▓е ка░▓они'^L,
        nil, nil, 3, 2, 1, 1, True, True, kbNoKey);
      SetItem('Фо░ма▓: ~N'#207#21'име'#21'ад░е▒'#21'▓еле┤он'#21'п░о┤е▒и┐'#21+
              'об░азование'#21'в║з░а▒▓'#21'ме▒▓о░або▓а~'^L,
        nil, nil, 2, 17, 20, 1, True, True, kbNoKey);
      SetItem('~дл║жно▒▓'#21'па▒по░▓'#21'да▓а па▒по░▓'#21+
              'м┐▒▓о на издаване на па▒по░▓а'#21+'да▓а ка░▓он~'^L,
        nil, nil, 2, 18, 20, 1, True, True, kbNoKey);

      repeat
        if (I <> -1) then Code := ActiveDialog;
        Valid := False;
        if (Code = _Cancel) then Valid := True;
        if (Code <> _Cancel) then if (Gr^ = 1) then
          case It^ of
            1 : Valid := True;
            2, 3 : for Z := 1 to MaxSList(BList) do
                     case It^ of
                       2 : SetSBool(Z, BList, True);
                       3 : begin
                             O := SStrBool(Z, BList);
                             SetSBool(Z, BList, not O);
                           end;
                     end;
            4 : I := EraseCCard(BList);
            5 : I := ReadCCard(Data, SElement(Dialog^[2]^.M[1]^ +
                  Dialog^[2]^.P[1]^-1, BList), Edit);
            6 : I := ReadCCard(Data, SElement(Dialog^[2]^.M[1]^ +
                    Dialog^[2]^.P[1]^-1, BList), Search);
            7 : PrintCCard(BList);
          end;
        if It^ in [4..6] then if BList <> nil then
          begin
            DelSList(BList); NewSList(BList, 'CCRD');
            I := SearchCBase(Data, BList);
          end;
          A := BList^.Next; Q := 0;
          while A <> nil do
            begin
              if A^.Bool then Inc(Q);
              A := A^.Next;
            end;
        if (PKind^ = Secondary) and (Gr^ = 1) and (It^ = 1) then
          if Q > N then
            begin
              ErrorDialog('Н┐ма до▒▓а▓║╖но екземпл┐░и'^C+
                          'за в▒и╖ки изб░ани ╖и▓а▓ели!'^C);
              Valid := False;
              Q := 0;
            end;
      until Valid or (I=-1);

      if (PKind^ = Secondary) and (Code <> _Cancel) and (Q > 0) then
        SaveICard(_Title, BList, False);
      Done;
    end;
end; { SelectReader }

procedure Reader;
var
  dgReader : TDialog;
  Code : Word;
  A, B : PSList;
  El : TBCard;
  I : Integer;
  S : string;
begin { Reader }
  FillChar(El, SizeOf(El), 0);
  with dgReader, Data do
    begin
      Init(Secondary, 'Чи▓а▓ел▒ки ка░▓он', 10, 6, 70, 21, 0);
      SetGroup(_but, NormStr);
        SetItem('   ~Д~об░е   ', nil, nil, 48, 2, 3, 1, True, True, kbAltD);
        SetItem('  З~а~емане  ', nil, nil, 48, 4, 3, 1, True, True, kbAltA);
        SetItem('  В~░~║╣ане  ', nil, nil, 48, 6, 3, 1, True, True, kbAltR);
        SetItem('   ~П~е╖а▓   ', nil, nil, 48, 8, 3, 1, True, True, kbAltP);
      SetGroup(_lst, NormStr);
        SetItem('', nil, nil, 2, 3, 15, 8, False, True, kbNoKey);
        SetItem('', nil, nil, 2, 10, 2, 1, False, True, kbNoKey);
        A := Dialog^[2]^.StrList[1];
        B := Dialog^[2]^.StrList[2];
        I := SearchIBase(@Data, nil, B, False);
        Str(Number, S);
          ScanSListNS('номе░: '+ S, False, A);
          ScanSListNS('име:   '+ Name, False, A);
          ScanSListNS('ад░е▒: '+ Address, False, A);
          ScanSListNS('▓ел.:  '+ Phone, False, A);
          ScanSListNS(Profession+' '+Educ[Education], False, A);
          Str(Age, S);
          ScanSListNS('в║з░а▒▓: '+S, False, A);
      if PassBool then
        begin
          Str(Passport, S);
          ScanSListNS('па▒по░▓: '+ S+ ' '+ Serial, False, A);
          if (DateOfPass <> ZeroDate) and (DateOfPass <> 0) then
            S := Long2Date(DateOfPass) else S := '';
          ScanSListNS('         '+ PlaceOfPass+ ' '+ S, False, A);
      end;
        if (Date <> ZeroDate) and (Date <> 0) then
          S := Long2Date(Date) else S := '';
          ScanSListNS('▒║здаден: '+ S, False, A);
      SetGroup(_txt, NormStr);
        SetItem('Данни о▓ ка░▓она:'^L,
          nil, nil, 3, 2, 1, 1, True, True, kbNoKey);
        SetItem('Взе▓и/в║░на▓и заглави┐:'^L,
          nil, nil, 3, 9, 1, 1, True, True, kbNoKey);

      repeat
      Code := ActiveDialog;
      if Code <> _Cancel then
      if Gr^ = 1 then
        begin
          case It^ of
            2 : if EditTitle(El, 'Заемане на заглавие * Фил▓║░', Secondary, False) then
              SelectTitle(El, 'Заемане на заглавие', Secondary, @Data);
            3 : ReturnBook(@Data, nil);
            4 : PrintICard(@Data, B, True);
          end;
            if (Gr^ = 1) and (It^ in [2..3]) then
              begin
                if B <> nil then DelSList(B); NewSList(B, '');
                I := SearchIBase(@Data, nil, B, False);
              end;
          end;
      until (Code = _Cancel) or ((Gr^ = 1) and (It^ = 1)) or (I = -1);
      Done;
    end;
end; { Reader }

function SelectTitle;
var
  dgSelectB : TDialog;
  A, B, BList : PSList;
  _Reader : ^TCCard;
  Valid, O : Boolean;
  El : TICard;
  Code : Word;
  I, Z : Longint;
begin { SelectTitle }
  with dgSelectB do
    begin
      Init(TD, Title, 3, 4, 78, 23, 0);
    SetGroup(_but, NormStr);
      SetItem('  ~Д~об░е        ', nil, nil, 58, 2, 1, 1, True, True, kbAltD);
      SetItem('  ~М~а░ки░ане    ', nil, nil, 58, 4, 1, 1, True, True, kbAltM);
      SetItem('  Ин~в~е░▓и░ане  ', nil, nil, 58, 6, 1, 1, True, True, kbAltW);
  if PKind^ = Primary then
    begin
      SetItem('  ~И~з▓░иване    ', nil, nil, 58,  9, 1, 1, True, True, kbAltI);
      SetItem('  ~Р~едак▓и░ане ', nil, nil, 58, 11, 1, 1, True, True, kbAltR);
      SetItem('  ~З~аглавие    ', nil, nil, 58, 13, 1, 1, True, True, kbAltZ);
      SetItem('  ~П~е╖а▓        ', nil, nil, 58, 15, 1, 1, True, True, kbAltP);
    end else _Reader := P;
    SetGroup(_lst, NormStr);
      SetItem('', nil, nil, 2, 3, 20, 4, True, True, kbNoKey);
      BList := Dialog^[2]^.StrList[1]; { Shorter name }
      I := SearchBBase(Data, BList, (PKind^ = Secondary));
    SetGroup(_txt, NormStr);
      SetItem('Спи▒║к на наме░ени▓е заглави┐'^L,
        nil, nil, 3, 2, 1, 1, True, True, kbNoKey);
      SetItem('Фо░ма▓:'^L+
              '  ~заглавие'#21'УДК'#21'ав▓о░'#21'жан░'#21'едини╖на ╢ена'#21+
              'б░ой екземпл┐░и о▓ заглавие▓о~'^L,
        nil, nil, 2, 17, 20, 1, True, True, kbNoKey);

      repeat
        if (I <> -1) then Code := ActiveDialog;
        if (Code <> _Cancel) then if (Gr^ = 1) then
          case It^ of
            2, 3 : for Z := 1 to MaxSList(BList) do
                     case It^ of
                       2 : SetSBool(Z, BList, True);
                       3 : begin
                             O := SStrBool(Z, BList);
                             SetSBool(Z, BList, not O);
                           end;
                     end;
            4 : I := EraseBCard(BList);
            5 : I := ReadBCard(Data, SElement(Dialog^[2]^.M[1]^ +
                  Dialog^[2]^.P[1]^-1, BList), Edit);
            6 : I := ReadBCard(Data, SElement(Dialog^[2]^.M[1]^ +
                  Dialog^[2]^.P[1]^-1, BList), Search);
            7 : PrintBCard(BList);
          end;
        if It^ in [4..6] then if BList <> nil then
          begin
            DelSList(BList); NewSList(BList, 'BCRD');
            I := SearchBBase(Data, BList, (PKind^ = Secondary));
          end;
      until (Code = _Cancel) or ((Gr^ = 1) and (It^ = 1)) or (I = -1);
      if (PKind^ = Secondary) and (Code <> _Cancel) and (_Reader <> nil) then
        SaveICard(_Reader, BList, True);
      Done;
    end;
end; { SelectTitle }

procedure Title;
var
  dgTitle : TDialog;
  Code : Word;
  A, B : PSList;
  El : TCCard;
  I : Integer;
  S : string;
begin { Title }
  FillChar(El, SizeOf(El), 0);
  with dgTitle, Data do
    begin
      Init(Secondary, 'Заглавие', 10, 6, 70, 21, 0);
      SetGroup(_but, NormStr);
        SetItem('   ~Д~об░е   ', nil, nil, 48, 2, 3, 1, True, True, kbAltD);
        SetItem('  З~а~емане  ', nil, nil, 48, 4, 3, 1, True, True, kbAltA);
        SetItem('  В~░~║╣ане  ', nil, nil, 48, 6, 3, 1, True, True, kbAltR);
        SetItem('   ~П~е╖а▓   ', nil, nil, 48, 8, 3, 1, True, True, kbAltP);
      SetGroup(_lst, NormStr);
        SetItem('', nil, nil, 2, 3, 15, 8, False, True, kbNoKey);
        SetItem('', nil, nil, 2, 10, 2, 1, False, True, kbNoKey);
        A := Dialog^[2]^.StrList[1];
        B := Dialog^[2]^.StrList[2];
        I := SearchIBase(nil, @Data, B, False);
          ScanSListNS('УДК:           '+ ID,      False, A);
          ScanSListNS('заглавие:      '+ Title,   False, A);
          ScanSListNS('ав▓о░:         '+ Autor,   False, A);
          ScanSListNS('жан░:          '+ Topic,   False, A);
          ScanSListNS('изда▓ел▒▓во:   '+ Company, False, A);
        Str(Price:-9:2, S);
          ScanSListNS('едини╖на ╢ена: '+ S, False, A);
        Str(Number, S);
          ScanSListNS('екземпл┐░и:    '+ S, False, A);
      SetGroup(_txt, NormStr);
        SetItem('Данни за заглавие▓о:'^L,
          nil, nil, 3, 2, 1, 1, True, True, kbNoKey);
        SetItem('Взе▓и екземпл┐░и о▓:'^L,
          nil, nil, 3, 9, 1, 1, True, True, kbNoKey);

      repeat
      Code := ActiveDialog;
      if Code <> _Cancel then
      if Gr^ = 1 then
        begin
          case It^ of
            2 : if Available(Data) > 0 then
                begin
                  if EditReader(El, 'Заемане на заглавие * Фил▓║░', Secondary, False) then
                    SelectReader(El, 'Заемане на заглавие', Secondary, @Data);
                end else
                ErrorDialog('Н┐ма до▒▓а▓║╖но екземпл┐░и'^C+
                            'в библио▓ека▓а'^C);
            3 : ReturnBook(nil, @Data);
            4 : PrintICard(@Data, B, False);
          end;
            if (Gr^ = 1) and (It^ in [2..3]) then
              begin
                if B <> nil then DelSList(B); NewSList(B, '');
                I := SearchIBase(nil, @Data, B, False);
              end;
          end;
      until (Code = _Cancel) or ((Gr^ = 1) and (It^ = 1)) or (I = -1);
      Done;
    end;
end; { Reader }

function ReturnBook;
var
  dgReturn : TDialog;
  BList : PSList;
  R : ^TCCard;
  T : ^TBCard;
  Code : Word;
  I : Integer;
begin { ReturnBook }
  with dgReturn do
    begin
      R := P1; T := P2;
      Init(Secondary, 'В░║╣ане на заглавие в библио▓ека▓а', 10, 6, 70, 21, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~Д~об░е  ', nil, nil, 49, 2, 1, 1, True, True, kbAltD);
        SetItem('  ~О~▓каз  ', nil, nil, 49, 4, 1, 1, True, True, kbAltO);
      SetGroup(_lst, NormStr);
        SetItem('', nil, nil, 2, 3, 15, 2, True, True, kbNoKey);
        BList := Dialog^[2]^.StrList[1];
        if P1 <> nil then I := SearchIBase(R, nil, BList, True);
        if P2 <> nil then I := SearchIBase(nil, T, BList, True);
      SetGroup(_txt, NormStr);
        if R <> nil then
        SetItem('Спи▒║к на заглави┐▓а │ ╖и▓а▓ел┐:'^L,
          nil, nil, 3, 2, 1, 1, True, True, kbNoKey);
        if T <> nil then
        SetItem('Спи▒║к на ╖и▓а▓ели▓е взели екземпл┐░и:'^L,
          nil, nil, 3, 2, 1, 1, True, True, kbNoKey);
      Code := ActiveDialog;
      if (Gr^ = 1) and (It^ = 2) then Code := _Cancel;
      if Code <> _Cancel then
        begin
          if R <> nil then WriteICard(R, nil, BList);
          if T <> nil then WriteICard(nil, T, Blist);
        end;
      Done;
    end;
  ReturnBook := Code <> _Cancel;
end; { ReturnBook }

begin { Lib }
  HelpFile := 'LIBRARY.HLP';
end. { Lib }
