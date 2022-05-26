{**********************************}
{*                                *}
{*    Strings unit                *}
{*    1992 (c) Computer           *}
{*    1994 (c) Momchil Hristov    *}
{*                                *}
{**********************************}

unit Strings;
interface
type
  Format = (Left,Right,Center);

  { Cyrillic support }
  function  UpStr(St : string) : string;
  function  LoStr(St : string) : string;

  { 1992 (c) Computer }
  function  CharCnt(Ch : Char; St : string) : Byte;
  function  CharStr(Ch : Char; Count : Byte) : string;
  function  FormStr(St: string; Len : Byte; F : Format) : string;
  { (c) }

implementation

function UpStr(St : string) : string;
var I : Byte;
begin { UpStr }
  for I := 1 to Length(St) do
    begin
      if ((St[I] >= 'a') and (St[I] <= 'z')) or
         ((St[I] >= ' ') and (St[I] <= '¿')) then
        St[I] := Chr(Ord(St[I]) - 32);
    end;
  UpStr := St;
End { UpStr };

function LoStr(St : string) : string;
var I : Byte;
begin { LoStr }
  for I := 1 to Length(St) do
    begin
      if ((St[I] >= 'A') and (St[I] <= 'Z')) or
         ((St[I] >= '€') and (St[I] <= 'Ÿ')) then
        St[I] := Chr(Ord(St[I]) + 32);
    end;
  LoStr := St;
end { LoStr };

Function CharCnt(Ch : Char; St : String) : Byte; assembler;
Asm { CharCnt }
    les       di,[bp+6]
    mov       cl,byte ptr es:di
    xor       ch,ch
    jcxz      @@2
    mov       al,[bp+10]
    inc       di
    cld
@@1:
    repne     scasb
    jne       @@2
    inc       bl
    jmp       @@1
@@2:
    mov       al,bl
End { CharCnt };

Function CharStr(Ch : Char; Count : Byte) : String; assembler;
Asm { CharStr }
    les       di,[bp+10]
    mov       al,[bp+6]
    cld
    stosb
    mov       cl,al
    xor       ch,ch
    mov       al,[bp+8]
    rep       stosb
End { CharStr };

Function FormStr(St : String; Len : Byte; F : Format) : String; assembler;
Asm { FormStr }
    push      ds
    lds       si,[bp+10]
    les       di,[bp+14]
    mov       bl,[bp+6]
    mov       cl,[bp+8]
    xor       ch,ch
    cld
    lodsb
    cmp       bl,Left
    jne       @@2
    cmp       cl,al
    ja        @@1
    mov       al,cl
    stosb
    rep       movsb
    jmp       @@7
@@1:
    mov       bl,cl
    sub       bl,al
    xchg      al,cl
    stosb
    rep       movsb
    mov       al,32
    mov       cl,bl
    rep       stosb
    jmp       @@7
@@2:
    cmp       bl,Right
    jne       @@4
    cmp       cl,al
    ja        @@3
    sub       al,cl
    xor       ah,ah
    add       si,ax
    mov       al,cl
    stosb
    rep       movsb
    jmp       @@7
@@3:
    mov       bl,cl
    sub       bl,al
    xchg      al,cl
    stosb
    mov       al,32
    xchg      bl,cl
    rep       stosb
    mov       cl,bl
    rep       movsb
    jmp       @@7
@@4:
    cmp       bl,Center
    jne       @@7
    cmp       cl,al
    ja        @@5
    sub       al,cl
    shr       al,1
    xor       ah,ah
    add       si,ax
    mov       al,cl
    stosb
    rep       movsb
    jmp       @@7
@@5:
    mov       bl,cl
    sub       bl,al
    shr       bl,1
    mov       bh,bl
    jnc       @@6
    inc       bh
@@6:
    xchg      al,cl
    stosb
    mov       al,32
    xchg      bl,cl
    rep       stosb
    mov       cl,bl
    rep       movsb
    mov       cl,bh
    rep       stosb
@@7:
    pop       ds
End { FormStr };

end { Strings }.
