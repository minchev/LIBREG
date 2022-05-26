{**********************************}
{*                                *}
{*    Lists unit (c) 1997         *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

{$I-}

unit Lists;
interface
uses Dos;
const
  FDDIcon = #252#253#32;
  HDDIcon = #254#255#32;
  FilIcon = #222#223#32;

  PageSplit = 500; { ~128KB for page of not sorted SList }

type
  PSList = ^TSList;
  TSList = record
    Data : string;
    Bool : Boolean;
    Count : Longint;
    Next : PSList;
  end; { TSList }

  PFList = ^TFList;
  TFList = record
    Data : SearchRec;
    Next : PFList;
  end; { TFList }

  TTemp = string[4];

  { * - Page method /not sorted only/ }

  procedure NewSList(var Root : PSList; TmpName : TTemp);
  procedure ScanSList(Data : string; Bool : Boolean; var Root : PSList);
  procedure ScanSListNS(Data : string; Bool : Boolean; var Root : PSList); {*}
  procedure DelSList(var Root : PSList);                                   {*}
  procedure DelSElem(var Root : PSList; Data : string);
  procedure SetSBool(N : Longint; var Root : PSList; Bool : Boolean);      {*}
  procedure WList(N : Longint; var Root : PSList);                         {*}
  procedure RList(N : Longint; var Root : PSList);                         {*}
  function MaxSList(Root : PSList) : Longint;
  function SElement(N : Longint; var Root : PSList) : string;              {*}
  function SStrBool(N : Longint; var Root : PSList) : Boolean;             {*}

  procedure NewFList(var Root : PFList);
  procedure ScanFList(Data : SearchRec; var Root : PFList);
  procedure ReadFiles(Root : PFList);
  procedure FDirInfo(N : Integer; lsPoint : PFList; var DI : SearchRec);
  procedure DelFList(var Root : PFList);
  function MaxFList(Root : PFList) : Word;
  function FElement(N : Word; lsPoint : PFList) : string;

const
  Filter : string = '*.*';
  LFilter : string = #0;

implementation
uses Strings, Transfer;

function MaxFList;
var C : Integer;
    lsFiles : PFList;
begin { MaxFList }
 C := 0; lsFiles := Root;
  while lsFiles^.Next <> nil do
    begin
      Inc(C);
      lsFiles := lsFiles^.Next;
    end;
  MaxFList := C;
end; { MaxFList }

procedure NewFList;
begin { NewFList }
  New(Root); Root^.Next := nil;
end; { NewFList }

procedure ScanFList;
var PScan1, PScan2, PScan : PFList;
begin { ScanFList }
  PScan2 := Root;
  PScan1 := Root^.Next;
  while (PScan1 <> nil) and (PScan1^.Data.Name < Data.Name) do
    begin
      PScan2 := PScan1;
      PScan1 := PScan1^.Next;
    end;
  New(PScan);
  PScan^.Next := PScan1;
  PScan2^.Next := PScan;
  PScan^.Data := Data;
end; { ScanFList }

procedure ReadFiles;
var DirInfo : SearchRec;
    lsFiles : PFList;
    Regs : Registers;
    FDD, HDD : Byte;
    S : string;
    I : Byte;
begin { ReadFiles }
  lsFiles := Root;
  FindFirst('*.*', Directory, DirInfo);
  while DosError = 0 do
  begin
    if (DirInfo.Name[1] <> '.') and (DirInfo.Attr and Directory <> 0) then
      ScanFList(DirInfo, lsFiles);
    FindNext(DirInfo);
  end;
  GetDir(0, S);
  if Length(S) > 3 then
    begin
      DirInfo.Name := '..';
      DirInfo.Attr := Directory;
      ScanFList(DirInfo, lsFiles);
    end;
  while lsFiles^.Next <> nil do
    lsFiles := lsFiles^.Next;
  FindFirst(Filter, AnyFile, DirInfo);
  while DosError = 0 do
  begin
    if (DirInfo.Attr and Directory = 0) and (DirInfo.Attr and VolumeID = 0)
      then ScanFList(DirInfo, lsFiles);
    FindNext(DirInfo);
  end;

  for I := 0 to 3 do
    begin
      Regs.AH := $08;
      Regs.DL := I;
      Intr($13, Regs);
      if (Regs.DH * Regs.CH * Regs.CL) > 0 then
        begin
          DirInfo.Name := FDDIcon + Chr(65 + I) + ':';
          DirInfo.Attr := VolumeID;
          ScanFList(DirInfo, lsFiles);
        end;
    end;

  for I := 3 to 26 do
    begin
      Regs.AH := $36;
      Regs.DL := I;
        Intr($21,Regs);
      if Regs.AX <> $FFFF then
        begin
          DirInfo.Name := HDDIcon + Chr(64 + I) + ':';
          ScanFList(DirInfo,lsFiles);
        end;
    end;
end; { ReadFiles }

function FElement;
var
  lsP : PFList;
  Counter : Integer;
  S : string;
begin { FElement }
  Counter := 0; lsP := lsPoint; S := '';
  while (lsP <> nil) do
    begin
      if Counter = N then
        begin
          S := lsP^.Data.Name;
          if lsP^.Data.Attr and Directory <> 0 then S := S + '\'
            else if lsP^.Data.Attr and VolumeID = 0 then S := LoStr(S);
          Break;
        end;
        Inc(Counter);
      lsP := lsP^.Next;
    end;
  FElement := S;
end; { FElement }

procedure FDirInfo;
var lsP : PFList;
    Counter : Integer;
begin { FDirInfo }
  Counter := 0; lsP := lsPoint;
  while (lsP <> nil) do
    begin
      if Counter = N then
        begin
          DI := lsP^.Data;
          Exit;
        end;
      Inc(Counter);
      lsP := lsP^.Next;
    end;
end; { FDirInfo }

procedure DelFList;
var PDel, PNext : PFList;
begin { DelFList }
  PDel := Root^.Next;
  while PDel <> nil do
    begin
      PNext := PDel^.Next;
      Dispose(PDel); PDel := PNext;
    end;
  Dispose(Root); Root := nil;
  LFilter := #0;
end; { DelFList }

procedure NewSList;
begin { NewSList }
  New(Root); Root^.Next := nil;
  Root^.Count := 0; Root^.Data := TmpName;
end; { NewSList }

procedure ScanSList;
var PScan1, PScan2, PScan : PSList;
begin { ScanSList }
  PScan2 := Root;
  PScan1 := Root^.Next;
  while (PScan1 <> nil) and (PScan1^.Data < Data) do
    begin
      PScan2 := PScan1;
      PScan1 := PScan1^.Next;
    end;
  New(PScan);
  PScan^.Next := PScan1;
  PScan2^.Next := PScan;
  PScan^.Count := 0;
  PScan^.Data := Data;
  PScan^.Bool := Bool;
end; { ScanSList }

procedure ScanSListNS;
var
  A, P1, P2 : PSList;
  N : Longint;
begin { ScanSListNS }
  if ((Root^.Count div PageSplit) <> (Succ(Root^.Count) div PageSplit)) then
    WList(Root^.Count, Root);
  P2 := Root; P1 := Root^.Next;
  while P1 <> nil do
    begin
      P2 := P1;
      P1 := P1^.Next;
    end;
  if MaxAvail >= SizeOf(TSList) then New(A);
  A^.Data := Data;
  A^.Next := nil;
  A^.Bool := Bool;
  A^.Count := Succ(Root^.Count);
  P2^.Next := A;
  Inc(Root^.Count);
end; { ScanSListNS }

procedure DelSList;
var
  PDel, PNext : PSList;
  DirInfo : SearchRec;
  F : file;
begin { DelSList }
  PDel := Root^.Next;
  while PDel <> nil do
    begin
      PNext := PDel^.Next;
      Dispose(PDel); PDel := PNext;
    end;
  Dispose(Root); Root := nil;
  FindFirst('*.TMP', Archive, DirInfo);
  while DosError = 0 do
  begin
    Assign(F, DirInfo.Name); Erase(F);
    FindNext(DirInfo);
  end;
end; { DelSList }

procedure DelSElem;
var PDel, PLast: PSList;
begin { DelSElem }
  PLast := Root;
  PDel := Root^.Next;
  while (PDel <> nil) and (PDel^.Data <> Data) do
    begin
      PLast := PDel;
      PDel := PDel^.Next;
    end;
  if PDel = nil then Exit;
    Dispose(PDel);
  PLast^.Next := PDel^.Next;
end; { DelSElem }

procedure WList;
var
  F : file of TSList;
  A, PDel : PSList;
  S : string;
begin { WList }
  Str(Succ(N div PageSplit), S);
  if Succ(N div PageSplit) < 10 then S := '0' + S;
  Assign(F, Root^.Data + S + '.TMP');
  Rewrite(F);
  A := Root^.Next; PDel := A;
  while A <> nil do
    begin
      Write(F, A^); PDel := A^.Next;
      Dispose(A); A := PDel;
    end;
  Close(F);
end; { WList }

procedure RList;
var
  F : file of TSList;
  A, P : PSList;
  B : TSList;
  S : string;
begin { RList }
  Str(Succ(N div PageSplit), S);
  if Succ(N div PageSplit) < 10 then S := '0' + S;
  Assign(F, Root^.Data + S + '.TMP');
  Reset(F);
    A := Root;
    while not Eof(F) do
      begin
        Read(F, B);
        New(A); A^ := B; A := A^.Next;
      end;
  Close(F);
end; { RList }

function MaxSList;
begin { MaxSList }
  MaxSList := Root^.Count;
end; { MaxSList }

function SElement;
var
  A : PSList;
  C : Longint;
  S : string;
begin { SElement }
  A := Root^.Next;
  if (Root^.Count div PageSplit) <> (N div PageSplit) then
    begin
      WList(A^.Count, Root);
      RList(N, Root);
    end;
  C := (PageSplit * (N div PageSplit)); S := '';
  if N div PageSplit = 0 then C := 1;
  while A <> nil do
    begin
      if C = N then
        begin
          S := A^.Data; Break;
        end;
        Inc(C);
      A := A^.Next;
    end;
  SElement := S;
end; { SElement }

function SStrBool;
var
  A : PSList;
  C : Longint;
  B : Boolean;
begin { SStrBool }
  A := Root^.Next;
  if (Root^.Count div PageSplit) <> (N div PageSplit) then
    begin
      WList(A^.Count, Root);
      RList(N, Root);
    end;
  C := (PageSplit * (N div PageSplit)); B := False;
  if N div PageSplit = 0 then C := 1;
  while A <> nil do
    begin
      if C = N then
        begin
          B := A^.Bool; Break;
        end;
        Inc(C);
      A := A^.Next;
    end;
  SStrBool := B;
end; { SStrBool }

procedure SetSBool;
var
  A : PSList;
  C : Longint;
begin { SetSBool }
  A := Root^.Next;
  if (Root^.Count div PageSplit) <> (N div PageSplit) then
    begin
      WList(A^.Count, Root);
      RList(N, Root);
    end;
  C := (PageSplit * (N div PageSplit));
  if N div PageSplit = 0 then C := 1;
  while A <> nil do
    begin
      if C = N then
        begin
          A^.Bool := Bool; Break;
        end;
        Inc(C);
      A := A^.Next;
    end;
end; { SetSBool }

end. { Lists }
