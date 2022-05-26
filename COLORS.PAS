{**********************************}
{*                                *}
{*    Color unit (c) 1995         *}
{*    Momchil Hristov Minchev     *}
{*                                *}
{**********************************}

unit Colors;
interface
uses Crt;
const _Color_string : string =
  #255#136#15#143#9#129#15#0#7#132#15#4#7#128#15#0#7#128#15#132#15#15#0#12#0+
  #15#0#135#7#143#9#15#0#142#9#14#0#131#9#129#15#0#7#15#0#128#11#15#0#140+
  #11#12#0#135#11#129#15#0#7#15#0#15#4#0#7#14#4#15#7#143#12#129#15#0#7#15#0+
  #15#2#15#0#14#2#0#2#1#2#129#15#0#7#15#0;

var
  colDesktop, colProgram,

  colButtonActive, colButtonInactive,
  colButtonHotkeyActive, colButtonHotkeyInactive,

  colScrollBarArrowAndSlide, colScrollBar,

  colMenuNormal, colMenuNormalHotkey, colMenuSelected,
  colMenuSelectedHotkey, colMenuDisabledItem, colMenuCloseBox,

  colDialogNormal, colDialogInverse, colDialogBright,
  colDialogBrightInverse, colDialogDisabled, colDialogActive,
  colDialogInactive, colDialogCloseBox,

  colSDialogNormal, colSDialogInverse, colSDialogBright,
  colSDialogBrightInverse, colSDialogDisabled, colSDialogActive,
  colSDialogInactive, colSDialogCloseBox,

  colADialogNormal, colADialogInverse, colADialogBright,
  colADialogBrightInverse, colADialogDisabled, colADialogActive,
  colADialogInactive, colADialogCloseBox,

  colHDialogNormal, colHDialogInverse, colHDialogBright,
  colHDialogBrightInverse, colHDialogDisabled, colHDialogActive,
  colHDialogInactive, colHDialogCloseBox : Byte;

  procedure IC(var Col : Byte);
  procedure Color(Attr : Byte);

implementation
var _Number_of_colors : Byte;

procedure Color;
begin { Color }
  TextColor(Ord(_Color_string[2*Attr]));
  TextBackground(Ord(_Color_string[Succ(2*Attr)]));
end; { Color }

procedure IC;
begin { IC }
  Inc(_Number_of_colors);
  Col := _Number_of_colors;
end; { IC }

begin { Colors }
  _Number_of_colors := 0;
  IC(colDesktop); IC(colProgram);

  IC(colButtonActive); IC(colButtonInactive);
  IC(colButtonHotkeyActive); IC(colButtonHotkeyInactive);

  IC(colScrollBarArrowAndSlide); IC(colScrollBar);

  IC(colMenuNormal); IC(colMenuNormalHotkey); IC(colMenuSelected);
  IC(colMenuSelectedHotkey); IC(colMenuCloseBox); IC(colMenuDisabledItem);

  IC(colDialogNormal); IC(colDialogInverse); IC(colDialogBright);
  IC(colDialogBrightInverse); IC(colDialogDisabled); IC(colDialogActive);
  IC(colDialogInactive); IC(colDialogCloseBox);

  IC(colSDialogNormal); IC(colSDialogInverse); IC(colSDialogBright);
  IC(colSDialogBrightInverse); IC(colSDialogDisabled); IC(colSDialogActive);
  IC(colSDialogInactive); IC(colSDialogCloseBox);

  IC(colADialogNormal); IC(colADialogInverse); IC(colADialogBright);
  IC(colADialogBrightInverse); IC(colADialogDisabled); IC(colADialogActive);
  IC(colADialogInactive); IC(colADialogCloseBox);

  IC(colHDialogNormal); IC(colHDialogInverse); IC(colHDialogBright);
  IC(colHDialogBrightInverse); IC(colHDialogDisabled); IC(colHDialogActive);
  IC(colHDialogInactive); IC(colHDialogCloseBox);
end. { Colors }
