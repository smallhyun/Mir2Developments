unit Light0e;

interface
uses
  Windows, SysUtils, Classes, Graphics, HGETextures, HGEBase, Winapi.Direct3D9,
  HGECanvas, Grobal2;

{$INCLUDE Light0e.inc}

var
  Light0eSurface: TDXTexture = nil;

procedure CreateLight0eSurface();
procedure DestroyLight0eSurface();

implementation
uses
  CLMain;

function DecodeRLE(const Source, Target: Pointer; Count: Cardinal; bitLength: Byte): Boolean;
var
  I, j: Integer;
  SourcePtr,
  TargetPtr: PByte;
  RunLength: Cardinal;
  Counter: Cardinal;
begin
  Counter := 0;
  TargetPtr := Target;
  SourcePtr := Source;

  while Counter < Count do begin
    RunLength := 1 + (SourcePtr^ and $7F);
    if SourcePtr^ > $7F then begin
      Inc(SourcePtr);
      for I := 0 to RunLength - 1 do begin
        for j := 1 to bitLength - 1 do
        begin
          TargetPtr^ := SourcePtr^;
          Inc(SourcePtr);
          Inc(TargetPtr);
        end;
        TargetPtr^ := SourcePtr^;
        Dec(SourcePtr, bitLength - 1);
        Inc(TargetPtr);
      end;
      Inc(SourcePtr, bitLength);
    end
    else begin
      Inc(SourcePtr);
      Move(SourcePtr^, TargetPtr^, bitLength * RunLength);
      Inc(SourcePtr, bitLength * RunLength);
      Inc(TargetPtr, bitLength * RunLength);
    end;
    Inc(Counter, bitLength * RunLength);
  end;
  Result := Counter = Count;
end;

procedure CreateLight0eSurface();
var
  Access: TDXAccessInfo;
  WriteBuffer, ReadBuffer, DecodeBuffer: PAnsiChar;
  Y: Integer;
begin
  DestroyLight0eSurface();
  Light0eSurface := TDXImageTexture.Create(g_DXCanvas);
  Light0eSurface.Size := Point(LightWidth, LightHeight);
  Light0eSurface.PatternSize := Point(LightWidth, LightHeight);
  Light0eSurface.Format := D3DFMT_A8R8G8B8;
  Light0eSurface.Active := True;
  if Light0eSurface.Active then begin
    if Light0eSurface.Lock(lfWriteOnly, Access) then begin
      GetMem(DecodeBuffer, LightWidth * LightHeight * 4);
      Try
        if DecodeRLE(@LightBuffer, DecodeBuffer, LightWidth * LightHeight * 4, 4) then
        begin
          for Y := 0 to LightHeight - 1 do begin
            ReadBuffer := @DecodeBuffer[Y * LightWidth * 4];
            WriteBuffer := Pointer(Integer(Access.Bits) + (Access.Pitch * Y));
            Move(ReadBuffer^, WriteBuffer^, LightWidth * 4);
          end;
        end;
      Finally
        FreeMem(DecodeBuffer);
        Light0eSurface.Unlock;
      End;
    end; 
  end else begin
    Light0eSurface.Free;
    Light0eSurface := nil;
  end;
end;

procedure DestroyLight0eSurface();
begin
  if Light0eSurface <> nil then Light0eSurface.Free;
  Light0eSurface := nil;
end;

end.
