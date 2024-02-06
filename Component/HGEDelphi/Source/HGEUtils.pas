unit HGEUtils;

interface

procedure CopyInstanceData(Src, Dst: TObject);

function GetValidStr3(Str: string; var Dest: string; const Divider: array of Char): string;

implementation

procedure CopyInstanceData(Src, Dst: TObject);
begin
  if Assigned(Src) and Assigned(Dst) and (Src.ClassType = Dst.ClassType) then
    Move((PChar(Src) + 4)^, (PChar(Dst) + 4)^, Src.InstanceSize - 4);
end;

function GetValidStr3(Str: string; var Dest: string; const Divider: array of Char): string;
const
  BUF_SIZE = $FFFF;
var
  Buf: array[0..BUF_SIZE] of Char;
  BufCount, Count, SrcLen, i, ArrCount: LongInt;
  Ch: Char;
label
  CATCH_DIV;
begin
  Ch := #0;
  try
    SrcLen := Length(Str);
    BufCount := 0;
    Count := 1;

    if SrcLen >= BUF_SIZE - 1 then begin
      Result := '';
      Dest := '';
      Exit;
    end;

    if Str = '' then begin
      Dest := '';
      Result := Str;
      Exit;
    end;
    ArrCount := SizeOf(Divider) div SizeOf(Char);

    while True do begin
      if Count <= SrcLen then begin
        Ch := Str[Count];
        for i := 0 to ArrCount - 1 do
          if Ch = Divider[i] then
            goto CATCH_DIV;
      end;
      if (Count > SrcLen) then begin
        CATCH_DIV:
        if (BufCount > 0) then begin
          if BufCount < BUF_SIZE - 1 then begin
            Buf[BufCount] := #0;
            Dest := string(Buf);
            Result := Copy(Str, Count + 1, SrcLen - Count);
          end;
          break;
        end
        else begin
          if (Count > SrcLen) then begin
            Dest := '';
            Result := Copy(Str, Count + 2, SrcLen - 1);
            break;
          end;
        end;
      end
      else begin
        if BufCount < BUF_SIZE - 1 then begin
          Buf[BufCount] := Ch;
          Inc(BufCount);
        end;

      end;
      Inc(Count);
    end;
  except
    Dest := '';
    Result := '';
  end;
end;

end.

