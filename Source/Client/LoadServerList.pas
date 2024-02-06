unit LoadServerList;


interface

uses
  Windows, SysUtils, Classes, IdHTTP;

type
  TServerList = record
    SName: string[100];
    Note : string[20];
    Addr: string[15];
    Port: Word;
  end;

  PTServerList = ^TServerList;

  _ServerList = array of TServerList;

function Q_PosStr(const FindString, SourceString: string; StartPos: Integer = 1): Integer;
function LoadUrlList(url, Burl: string): _ServerList;
function EncodeServerFile(var Sou: TMemoryStream): Boolean;
function DecodeServerFile(var Sou: TMemoryStream): Boolean;
function GetDivStrEx(var source: AnsiString; Tag : AnsiChar): AnsiString;
function DecodeMakeStr(S: string): string;
implementation

function DecodeMakeStr(S: string): string;
var
  Len, i: Integer;
begin
  Result := '';
  if S <> '' then begin
    for i := 1 to Length(S) do begin
      if ((i mod 2) = 1) then
        Result := Result + Chr(StrToInt('0x' + Copy(S, i, 2)));
    end;
    Len := Length(Result);
    if Len > 0 then
      for i := 1 to Len do
        Result[i] := Char(Ord(Result[i]) xor $aa xor Len xor i);
  end;
end;


function Q_PosStr(const FindString, SourceString: string; StartPos: Integer): Integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        PUSH    EDX
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        SUB     EDX,ECX
        JNG     @@qt0
        XCHG    EAX,EDX
        ADD     EDI,ECX
        MOV     ECX,EAX
        JMP     @@nx
@@fr:   INC     EDI
        DEC     ECX
        JE      @@qt0
@@nx:   MOV     EBX,EDX
        MOV     AL,BYTE PTR [ESI]
@@lp1:  CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JE      @@qt0
        CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JE      @@qt0
        CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JE      @@qt0
        CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JNE     @@lp1
@@qt0:  XOR     EAX,EAX
@@qt:   POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
        RET
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JE      @@fd
        MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JE      @@fd
        MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JE      @@fd
        MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JNE     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        SUB     EAX,[ESP]
        POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
end;

function IsPortStr(s : string):Boolean;
var
  i : Integer;
begin
  i := -1;
  Result := TryStrToInt(s , i) and (i >=0) and (i <= 65535);
end;


function GetDivStrEx(var source: AnsiString; Tag : AnsiChar): AnsiString;
var
  n : Integer;
begin
  Result := '';
  if source <> '' then begin
    while (source[1] = Tag) or (source[length(source)] = Tag) do begin
      if source[1] = Tag then source := Copy(source , 2 ,Length(source) -1);
      if source = '' then Break;
      if source[length(source)] = Tag then source := Copy(source , 1 , Length(source) -1);
      if source = '' then Break;
    end;
    if source <> '' then begin
      n := Pos(Tag , source);
      if n > 0 then begin
        Result := Copy(source , 1 , n-1);
        source := Copy(source , n + 1 , Length(source) - n);
      end
      else begin
        Result := source;
        source := '';
      end;

    end;

  end;
end;


function LoadUrlList(url, Burl: string): _ServerList;
var
  Mem: TMemoryStream;
  _IdHTTP: TIdHTTP;
  i , z: Integer;
  tmp: TStringList;
  temp, _Name, _Note , _Addr, _Port, Check: AnsiString;
  flag: Boolean;
begin
  Mem := TMemoryStream.Create;
  SetLength(Result, 0);
  try
    for z := 0 to 1 do begin
      _IdHTTP := TIdHTTP.Create(nil);
      Mem.Clear;
      try
        _IdHTTP.Get(url, Mem);
        url := Burl;
        flag := True;
      except
        url := Burl;
        flag := False;
      end;
      FreeAndNil(_IdHTTP);

      if not flag then begin
        url := Burl;
        Continue;
      end;


      tmp := TStringList.Create;
      try
        flag := DecodeServerFile(Mem);
        tmp.LoadFromStream(Mem);
        if tmp.Count > 0 then begin
          if not flag then begin
            Check := tmp[0];
            Check := GetDivStrEx(Check, ' ');
            if not SameText(Check, '[ServerList]') then
            begin
              url := Burl;
              Continue;
            end;
          end;
          for i := tmp.Count - 1 downto 0 do begin
            temp := tmp[i];
            _Name := '';
            _Note := '';
            _Addr := '';
            _Port := '';
            _Name := GetDivStrEx(temp, '|');
            _Note := GetDivStrEx(temp, '|');
            _Addr := GetDivStrEx(temp, '|');
            _Port := GetDivStrEx(temp, '|');
            if (_Name = '') or (_Note = '') or (_Addr = '') or (Length(_Addr) > 15) or (not IsPortStr(_Port)) then
              tmp.Delete(i);
          end;
        end
        else
        begin
          url := Burl;
          Continue;
        end;
        if tmp.Count > 0 then begin
          SetLength(Result, tmp.Count);
          for i := 0 to tmp.Count - 1 do begin
            temp := tmp[i];
            _Name := GetDivStrEx(temp, '|');
            _Note := GetDivStrEx(temp, '|');
            _Addr := GetDivStrEx(temp, '|');
            _Port := GetDivStrEx(temp, '|');
            Result[i].SName := _Name;
            Result[i].Note := _Note;
            Result[i].Addr := _Addr;
            Result[i].Port := StrToInt(_Port);
          end;
          Exit;
        end;

      finally
        FreeAndNil(tmp);
      end;
    end;
  finally
    FreeAndNil(Mem);
  end;
end;



function EncodeServerFile(var Sou: TMemoryStream): Boolean;
var
  iSize ,i: Cardinal;
begin
  try
    Result := False;
    if Sou = nil then Exit;
    iSize := Sou.Size;
    if iSize <= 0 then Exit;
    for i := 0 to (iSize - 1) do begin
      PDWORD(DWORD(Sou.Memory) + i)^ := PDWORD(DWORD(Sou.Memory) + i)^ xor $aa xor i;
    end;
    Sou.Position := i;
    Sou.Write(iSize, SizeOf(Cardinal));
    Result := True;
  except
    Result := False;
  end;
end;

function DecodeServerFile(var Sou: TMemoryStream): Boolean;
var
  iSize, i, Len: Cardinal;
begin
  try
    Result := False;
    if Sou = nil then Exit;
    Sou.Position := 0;
    iSize := Sou.Size;
    if iSize <= 0 then Exit;
    iSize := iSize - SizeOf(Cardinal);
    Move(PDWORD(DWORD(Sou.Memory) + iSize)^  , Len  ,SizeOf(Cardinal));
    if Len <> iSize  then Exit;
    for i := 0 to Len - 1 do begin
      PDWORD(DWORD(Sou.Memory) + i)^ := PDWORD(DWORD(Sou.Memory) + i)^  xor i xor $aa;
    end;
    Sou.Size := Len;
    Result := True;
  except
    Result := False;
  end;
end;


end.

