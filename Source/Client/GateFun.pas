unit GateFun;

interface

uses
  Classes, SysUtils, WinProcs, Graphics, Math, IdHashMessageDigest, ShellAPI,
  ShlObj, ActiveX, Registry, ComObj, Tlhelp32;

function Q_Isipaddrstr(ip: string): Boolean;
procedure Q_Delete(var S: string; Index, Count: Integer);
function Q_PosStr(const FindString, SourceString: string; StartPos: Integer = 1): Integer;
function Q_SplitString(const source, ch: string): TStringList;
function Q_Isportstr(pstr: string; var port: Integer): Boolean;
function EnStringtoHex(str: string): string;
function DeHextoString(str: string): string;
function GetFileMd5(InFileName: string): string;
function DelDirectory(const Source: string): Boolean;
function Q_IntToStr(n: Integer): string;
function CreateDesktopShortcut(cFileName: string; cParameters: string; clinkname: string): string;
function ArrestStringEx(source, SearchAfter, ArrestBefore: string; var ArrestStr: string): string;

implementation



resourcestring

  RC_ExplorerKey = 'Software\MicroSoft\Windows\CurrentVersion\Explorer';

function GetFileMd5(InFileName: string): string;
var
  mymd5: TIdHashMessageDigest5;
  fileStream: TMemoryStream;
begin
  Result := '';
  fileStream := TMemoryStream.Create;
  try
    fileStream.LoadFromFile(InFileName);
    mymd5 := TIdHashMessageDigest5.Create;
    try
      Result := UpperCase(mymd5.HashBytesAsHex(mymd5.HashStream(fileStream)));
    except
      Result := '';
    end;
    mymd5.Free;
  except
    Result := '';
  end;
  FreeAndNil(fileStream);
end;

function DelDirectory(const Source: string): Boolean;
var
  fo: TSHFILEOPSTRUCT;
begin

  FillChar(fo, SizeOf(fo), 0);
  with fo do begin
    Wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar(Source + #0);
    pTo := #0#0;
    fFlags := FOF_NOCONFIRMATION + FOF_SILENT;
  end;
  Result := (SHFileOperation(fo) = 0);

end;

function StringToHex(S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    Result := Result + IntToHex(Ord(S[i]), 2);
end;

function HexToString(S: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 1 to Length(S) do begin
    if ((i mod 2) = 1) then
      Result := Result + Chr(StrToInt('0x' + Copy(S, i, 2)));
  end;
end;

 function edcode_dirstr(s: string): string;
var
  i, slen: Integer;
begin
  slen := Length(s);
  if slen > 0 then
    for i := 1 to Length(s) do
      s[i] := Char(Ord(s[i]) xor $aa xor slen xor i);
  Result := s;
end;

function EnStringtoHex(str: string): string;
begin
  try
    Result := StringToHex(edcode_dirstr(str));
  except
    Result := '';
  end;
end;

function DeHextoString(str: string): string;
begin
  try
    Result := edcode_dirstr(HexToString(str));
  except
    Result := '';
  end;
end;



procedure Q_Delete(var S: string; Index, Count: Integer);
asm
        PUSH    EBX
        PUSH    ESI
        XOR     EBX,EBX
        CMP     ECX,EBX
        JLE     @@qt
        MOV     EBX,[EAX]
        TEST    EBX,EBX
        JE      @@qt
        MOV     ESI,[EBX-4]
        DEC     EDX
        JS      @@qt
        SUB     ESI,EDX
        JNG     @@qt
        SUB     ESI,ECX
        JLE     @@zq
        PUSH    ECX
        MOV     EBX,EDX
        CALL    UniqueString
        POP     ECX
        PUSH    EAX
        MOV     EDX,ESI
        ADD     EAX,EBX
        SHR     ESI,2
        JE      @@nx
@@lp:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        MOV     BL,[EAX+ECX+1]
        MOV     [EAX+1],BL
        MOV     BL,[EAX+ECX+2]
        MOV     [EAX+2],BL
        MOV     BL,[EAX+ECX+3]
        MOV     [EAX+3],BL
        ADD     EAX,4
        DEC     ESI
        JNE     @@lp
@@nx:   AND     EDX,3
        JMP     DWORD PTR @@tV[EDX*4]
@@zq:   CALL    System.@LStrClr
@@qt:   POP     ESI
        POP     EBX
        RET
@@tV:   DD      @@t0,@@t1,@@t2,@@t3
@@t1:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        INC     EAX
        JMP     @@t0
@@t2:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        MOV     BL,[EAX+ECX+1]
        MOV     [EAX+1],BL
        ADD     EAX,2
        JMP     @@t0
@@t3:   MOV     BL,[EAX+ECX]
        MOV     [EAX],BL
        MOV     BL,[EAX+ECX+1]
        MOV     [EAX+1],BL
        MOV     BL,[EAX+ECX+2]
        MOV     [EAX+2],BL
        ADD     EAX,3
@@t0:   POP     EDX
        MOV     BYTE PTR [EAX],0
        SUB     EAX,EDX
        MOV     [EDX-4],EAX
        POP     ESI
        POP     EBX
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

function Q_IntToStr(n: Integer): string;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,EDX
        XOR     EDX,EDX
        CMP     ESI,1000
        JNL     @@x1
        CMP     ESI,$FFFFFF9C
        JNG     @@x1
        MOV     ECX,3
        JMP     @@do
@@x1:   CMP     ESI,10000000
        JNL     @@x2
        CMP     ESI,$FFF0BDC0
        JNG     @@x2
        MOV     ECX,7
        JMP     @@do
@@x2:   MOV     ECX,$0B
@@do:   CALL    System.@LStrFromPCharLen
        MOV     EAX,ESI
        MOV     ESI,[EDI]
        MOV     EDI,ESI
        TEST    EAX,EAX
        JE      @@eq
        JNS     @@ns
        CMP     EAX,$80000000
        JE      @@mm
        MOV     BYTE PTR [ESI],$2D
        INC     ESI
        NEG     EAX
@@ns:   MOV     ECX,$0A
@@lp1:  XOR     EDX,EDX
        DIV     ECX
        ADD     DL,$30
        MOV     BYTE PTR [ESI],DL
        INC     ESI
        TEST    EAX,EAX
        JNE     @@lp1
        MOV     BYTE PTR [ESI],0
        LEA     ECX,[ESI-1]
        SUB     ESI,EDI
        MOV     DWORD PTR [EDI-4],ESI
        CMP     BYTE PTR [EDI],$2D
        JE      @@ws
@@lp2:  CMP     EDI,ECX
        JAE     @@qt
        MOV     AH,BYTE PTR [EDI]
        MOV     AL,BYTE PTR [ECX]
        MOV     BYTE PTR [ECX],AH
        MOV     BYTE PTR [EDI],AL
        DEC     ECX
@@ws:   INC     EDI
        JMP     @@lp2
@@qt:   POP     EDI
        POP     ESI
        RET
@@eq:   MOV     WORD PTR [ESI],$0030
        MOV     DWORD PTR [ESI-4],1
        POP     EDI
        POP     ESI
        RET
@@mm:   MOV     DWORD PTR [ESI],$3431322D
        MOV     DWORD PTR [ESI+4],$33383437
        MOV     DWORD PTR [ESI+8],$00383436
        MOV     DWORD PTR [ESI-4],11
        POP     EDI
        POP     ESI
end;



function Q_SplitString(const source, ch: string): TStringList;
var
  Temp: string;
  i: Integer;
begin
  Result := TStringList.Create;
  Temp := source;
  i := Q_PosStr(ch, source);
  if i < 1 then Exit;
  while i <> 0 do begin
    Result.Add(Copy(Temp, 0, i - 1));
    Q_Delete(Temp, 1, i);
    i := Q_PosStr(ch, Temp);
  end;
  Result.Add(Temp);
end;

function Q_Isipaddrstr(ip: string): Boolean;
var
  Str: TStringList;
  i, tmp: Integer;
begin
  Result := False;
  if ip <> '' then begin
    Str := Q_SplitString(ip, '.');
    try
      if Str.Count = 4 then begin
        for i := 0 to 3 do begin
          if not TryStrToInt(Str[i], tmp) then Exit;
          if (tmp < 0) or (tmp > 255) then Exit;
        end;
        Result := True;
      end;
    finally
      Str.Clear;
      FreeAndNil(Str);
      
    end;
  end;
end;

function Q_Isportstr(pstr: string; var port: Integer): Boolean;
begin
  Result := TryStrToInt(pstr, port) and (port >= 0) and (port <= 65535);
end;

function CreateDesktopShortcut(cFileName: string; cParameters: string; clinkname: string): string;
var
  MyObject: IUnknown;
  MySLink: IShellLink;
  MyPFile: IPersistFile;
  Directory: string;
  WFileName: WideString;
  MyReg: TRegIniFile;
begin
  MyObject := CreateComObject(CLSID_ShellLink);
  MySLink := MyObject as IShellLink;
  MyPFile := MyObject as IPersistFile;
  with MySLink do begin
    SetArguments(PChar(cParameters));
    SetPath(PChar(cFileName));
    SetWorkingDirectory(PChar(ExtractFilePath(cFileName)));
  end;
  MyReg := TRegIniFile.Create(RC_ExplorerKey);
  Directory := MyReg.ReadString('Shell Folders', 'Desktop', '');
  WFileName := Directory + '\' + clinkname + '.lnk';
  MyPFile.Save(PWChar(WFileName), FALSE);
  Result := WFileName;
  MyReg.Free;
end;

function ArrestStringEx(source, SearchAfter, ArrestBefore: string; var ArrestStr: string): string;
var
  srclen: Integer;
  GoodData: Boolean;
  i, n: Integer;
begin
  ArrestStr := '';
  if source = '' then
  begin
    Result := '';
    exit;
  end;

  try
    srclen := Length(source);
    GoodData := False;
    if srclen >= 2 then
      if source[1] = SearchAfter then
      begin
        source := Copy(source, 2, srclen - 1);
        srclen := Length(source);
        GoodData := True;
      end
      else begin
        n := Q_PosStr(SearchAfter, source);
        if n > 0 then
        begin
          source := Copy(source, n + 1, srclen - (n));
          srclen := Length(source);
          GoodData := True;
        end;
      end;
    if GoodData then begin
      n := Q_PosStr(ArrestBefore, source);
      if n > 0 then
      begin
        ArrestStr := Copy(source, 1, n - 1);
        Result := Copy(source, n + 1, srclen - n);
      end
      else begin
        Result := SearchAfter + source;
      end;
    end
    else begin
      for i := 1 to srclen do begin
        if source[i] = SearchAfter then begin
          Result := Copy(source, i, srclen - i + 1);
          break;
        end;
      end;
    end;
  except
    ArrestStr := '';
    Result := '';
  end;
end;


end.

