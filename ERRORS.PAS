{**********************************}
{*                                *}
{*    Errors unit (c) 1997        *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Errors;
interface

  procedure ErrorDialog(ErrMsg : string); far;
  function RetryDialog(ErrMsg : string) : Word; far;
  function Question(ErrMsg : string) : Word; far;

implementation
uses Drivers, Dialogs;

procedure ErrorDialog;
var
  dgError : TDialog;
begin { ErrorDialog }
  with dgError do
    begin
      Init(Alert, ' ������/�������������� ', 25, 9, 55, 16, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~�~����  ', nil, nil, 11, 5, 1, 3, True, True, kbAltD);
      SetGroup(_txt, NormStr);
        SetItem(ErrMsg, nil, nil, 1, 2, 1, 1, True, True, kbNoKey);
      ActiveDialog;
      Done;
    end;
end; { ErrorDialog }

function RetryDialog;
var
  dgError : TDialog;
begin { RetryDialog }
  with dgError do
    begin
      Init(Alert, ' ������ ', 25, 9, 55, 16, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~�~������  ', nil, nil, 3, 5, 1, 3, True, True, kbAltP);
        SetItem('  ~�~����  ', nil, nil, 18, 5, 1, 3, True, True, kbAltO);
      SetGroup(_txt, NormStr);
        SetItem(ErrMsg, nil, nil, 1, 2, 1, 1, True, True, kbNoKey);
      RetryDialog := ActiveDialog;
      Done;
    end;
end; { RetryDialog }

function Question;
var
  dgError : TDialog;
begin { Question }
  with dgError do
    begin
      Init(Secondary, ' ��������� ', 20, 8, 61, 16, 0);
      SetGroup(_but, NormStr);
        SetItem('  ~�~�  ', nil, nil, 8, 6, 1, 3, True, True, kbAltD);
        SetItem('  ~�~�  ', nil, nil, 16, 6, 1, 3, True, True, kbAltN);
        SetItem('  ~�~����  ', nil, nil, 24, 6, 1, 3, True, True, kbAltO);
      SetGroup(_txt, NormStr);
        SetItem(ErrMsg, nil, nil, 1, 2, 1, 1, True, True, kbNoKey);
      Question := ActiveDialog;
      Done;
    end;
end; { Question }

end. { Errors }