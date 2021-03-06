{**********************************}
{*                                *}
{*    Library register (c) 1997   *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}

program LibReg;
uses Crt, Menus, Views, Colors, Errors, Drivers, Windows, Lib;
var Main,                                                 { main menu }
    sbFile, sbEdit, sbSearch, sbCheck, sbOptions : TMenu; { pop-up menus }
    vwStruct : TView;
    wnSystem : TWindow;
    E1, E2, I : Byte;

procedure Quit; far;
begin { Quit }
  Main.Destruct;
  sbFile.Destruct;
  sbEdit.Destruct;
  sbSearch.Destruct;
  sbCheck.Destruct;
  sbOptions.Destruct;
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
  vwStruct.InitDesktop('����������� ��������');
  vwStruct.InitStatusLine;
  InitClock; InitMouse;
  Prog := Quit;

  Main.Define(Horiz, 2, 2);
    Main.SetItem(' ~�~��� ',' ����������� ��������',kbAltF);
    Main.SetItem(' ~�~������� ', ' ���� �������� � ��������', kbAltR);
    Main.SetItem(' ������~�~�� ',
      ' ������� � ��������� �� ������� �� �������� � ��������', kbAltT);
    Main.SetItem(' ~�~������� ',
      ' �������� �� ���������� ������� �� ������� �� ��������', kbAltP);
    Main.SetItem(' ~�~���� ', ' ������� �� ������� �� ����������', kbAltO);
  Main.InitMenu;

  sbFile.Define(Vert, 2, 3);
    sbFile.SetItem(' ~�~��� ���� �����',
      ' ��������� �� ���� ���� �����', kbNoKey);
    sbFile.SetItem(' ~�~���� �� ���� �����... ',
      ' ��������� �� ���� �����', kbNoKey);
    sbFile.SetItem(' ~�~���� ����... ',
      ' ����� �� �������� ���� ����� � ����� ���', kbNoKey);
    sbFile.SetItem(' ��������~�~',
      ' ��������� �� ������������ � ������ �����', kbNoKey);
    sbFile.SetItem(' ��������~�~��� ',
      ' ������������ �������� � �������� ���� �����', kbNoKey);
    sbFile.SetItem(SEPARATOR,'',kbNoKey);
    sbFile.SetItem(' ��~�~�������',' ���������� �� ������ �����',kbNoKey);
    sbFile.SetItem(SEPARATOR,'',kbNoKey);
    sbFile.SetItem(' �~�~����� ����������... ',
      ' ������� ���������� �� ����������',kbNoKey);
    sbFile.SetItem(' ��~�~��',' ����� �� ����������',kbNoKey);
  sbFile.InitMenu;

  sbEdit.Define(Vert, 10, 3);
    sbEdit.SetItem(' ��� ~�~������...',
      ' �������� �� ��� ������� � ������ �����', kbNoKey);
    sbEdit.SetItem(' ���� ~�~�������... ',
      ' �������� �� ���� �������� � ������ �����', kbNoKey);
  sbEdit.InitMenu;

  sbSearch.Define(Vert, 22, 3);
    sbSearch.SetItem(' ~�~�������',
      ' ������� � ��������� �� ������� �� ��������', kbNoKey);
    sbSearch.SetItem(' ~�~�������',
      ' ������� � ��������� �� ������� �� ��������', kbNoKey);
    sbSearch.SetItem(SEPARATOR, '', kbNoKey);
    sbSearch.SetItem(' ~O~����������    ',
      ' ����������� �� ������ �����', kbNoKey);
  sbSearch.InitMenu;

  sbCheck.Define(Vert, 35, 3);
    sbCheck.SetItem(' ~�~�������� ��������...',
      ' ������ �� ���������� � ���������� ������� � ����������� ��������',
      kbNoKey);
    sbCheck.SetItem(' �~�~���� ������� �������� ',
      ' ������ �� ���������� ����� �� �������� � ����� �� ��������� ��',
      kbNoKey);
  sbCheck.InitMenu;

  sbOptions.Define(Vert, 47, 3);
    sbOptions.SetItem(' ~�~�����...    ', ' ������� �� ��������', kbNoKey);
  sbOptions.InitMenu;
end; { Define }

begin { LibReg }
  Define;
  if not ReadLicence then
    begin
      ErrorDialog('���������� �� �'^C'������������!'^C);
      Quit;
    end;
  if not Password(False) then Quit;
  repeat
    E1 := Main.ActiveMenu(Fictive); E2 := E1;
    while (E2 = mvLeft) or (E2 = mvRight) or (E2 = mvDown) do
      begin

    { SelectedDataBase options }

    for I := 1 to sbEdit.Numb^ do if sbEdit.Item[I]^ <> SEPARATOR then
      sbEdit.SetStatus(I, SelectedDataBase);
    for I := 1 to sbSearch.Numb^ do if sbSearch.Item[I]^ <> SEPARATOR then
      sbSearch.SetStatus(I, SelectedDataBase);
    for I := 1 to sbCheck.Numb^ do if sbCheck.Item[I]^ <> SEPARATOR then
      sbCheck.SetStatus(I, SelectedDataBase);
    for I := 3 to 7 do if sbFile.Item[I]^ <> SEPARATOR then
      sbFile.SetStatus(I, SelectedDataBase);

        case Main.M^ of
          1 : begin
                E2 := sbFile.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbFile.M^ of
                    1 : NewFile;
                    2 : SelectFile;
                    3 : SaveAsFile;
                    4 : EraseFile;
                    5 : CloseFile;
                    7 : BaseInfo;
                    9 : About;
                   10 : Quit;
                  end;
              end;
          2 : begin
                E2 := sbEdit.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbEdit.M^ of
                    1 : NewReader;
                    2 : NewTitle;
                  end; { case }
              end;
          3 : begin
                E2 := sbSearch.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbSearch.M^ of
                    1 : SearchReader;
                    2 : SearchTitle;
                    4 : Refresh;
                  end; { case }
              end;
          4 : begin
                E2 := sbCheck.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbCheck.M^ of
                    1 : NotReturnedTitles;
                    2 : BusyTitles;
                  end; { case }
              end;
          5 : begin
                E2 := sbOptions.ActiveMenu(Main);
                if E2 = mvDown then
                  case sbOptions.M^ of
                    1 : Password(True);
                  end; { case }
              end;
        end; { case }
      end;
  until E1 = mvUp;
  Quit;
end. { LibReg }