unit MyAes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, StdCtrls,
  ElAES, Math, ComCtrls;

var
  KEY: TAESKey128;

function StringToHex(S: string): string; forward;

function HexToString(S: string): string; forward;

function EnAesStr(const str, secretkey: string; var aesstr: string): Boolean;   //文字加密

function DeAesStr(const str, secretkey: string; var aesstr: string): Boolean;   //文字解密

function EnAesFiletoMemStrmeam(const secretkey: string; var SaveMem: TMemoryStream): Boolean;

function DeAesFiletoMemStrmeam(const openpath, secretkey: string; var DeMem: TMemoryStream): Boolean;      //文件解密

implementation
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

function EnAesStr(const str, secretkey: string; var aesstr: string): Boolean;   //文字加密
var
  Source: TStringStream;
  Dest: TStringStream;
  Size: integer;
begin

  // Encryption
  Source := TStringStream.Create(str);
  Dest := TStringStream.Create('');
  try
    Size := Source.Size;
    Dest.WriteBuffer(Size, SizeOf(Size));
    FillChar(Key, SizeOf(Key), 0);
    Move(PChar(secretkey)^, Key, Min(SizeOf(Key), Length(secretkey)));
    EncryptAESStreamECB(Source, 0, Key, Dest);
    aesstr := StringToHex(Dest.DataString);
    Result := True;
  except
    Result := False;
  end;
  Source.Free;
  Dest.Free;
end;

function DeAesStr(const str, secretkey: string; var aesstr: string): Boolean;   //文字解密
var
  Source: TStringStream;
  Dest: TStringStream;
  Size: integer;
begin
  Source := TStringStream.Create(HexToString(str));
  Dest := TStringStream.Create('');
  try
    Size := Source.Size;
    Source.ReadBuffer(Size, SizeOf(Size));
    FillChar(Key, SizeOf(Key), 0);
    Move(PChar(secretkey)^, Key, Min(SizeOf(Key), Length(secretkey)));
    DecryptAESStreamECB(Source, Source.Size - Source.Position, Key, Dest);
    aesstr := PChar(Dest.DataString);
    Result := True;
  except
    Result := False;
  end;
  Source.Free;
  Dest.Free;
end;

function EnAesFiletoMemStrmeam(const secretkey: string; var SaveMem: TMemoryStream): Boolean;
var
  Source: TMemoryStream;
  Size: Integer;
begin
  Source := TMemoryStream.Create;
  try
    Source.Position := 0;
    Source.SetSize(SaveMem.Size);
    CopyMemory(Source.Memory, SaveMem.Memory, SaveMem.Size);
    Size := Source.Size;
    SaveMem.Position := 0;
    SaveMem.WriteBuffer(Size, SizeOf(Size));
    FillChar(Key, SizeOf(Key), 0);
    Move(PChar(secretkey)^, Key, Min(SizeOf(Key), Length(secretkey)));
    EncryptAESStreamECB(Source, 0, Key, SaveMem);
    Result := True;
  except
    Result := False;
  end;
  Source.Free;
end;

function DeAesFiletoMemStrmeam(const openpath, secretkey: string; var DeMem: TMemoryStream): Boolean;
var
  Source: TMemoryStream;
  Size: Integer;
begin
  Source := TMemoryStream.Create;
  try
    Source.LoadFromFile(openpath);
    Source.ReadBuffer(Size, SizeOf(Size));
    FillChar(Key, SizeOf(Key), 0);
    Move(PChar(secretkey)^, Key, Min(SizeOf(Key), Length(secretkey)));
    DecryptAESStreamECB(Source, Source.Size - Source.Position, Key, DeMem);
    DeMem.Size := Size;
    Result := True;
  except
    Result := False;
  end;
  Source.Free;
end;

end.

