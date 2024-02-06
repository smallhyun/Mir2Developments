unit wmM2Def;

interface
uses
  System.Classes, System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  HGETextures, WIL;

type
  TWMImageHeader = packed record
    Title: string[40];
    bitCount: array[0..2] of byte;
    ImageCount: integer;
    ColorCount: integer;
    PaletteSize: integer;
    IndexOffset: integer;
  end;

  TWMIndexHeader = packed record
    Title: string[40];
    bitCount: array[0..2] of byte;
    IndexCount: integer;
    VerFlag: integer;
  end;
  PTWMIndexHeader = ^TWMIndexHeader;

  TWMImageInfo = packed record
    DXInfo: TDXTextureInfo;
    nSize: Integer;
  end;
  PTWMImageInfo = ^TWMImageInfo;


  TWMM2DefImages = class(TWMBaseImages)
  private
    FHeader: TWMImageHeader;
    FIdxHeader: TWMIndexHeader;
    FIdxFile: string;
    FNewFmt: Boolean;
    Fbo16bit: Boolean;
    procedure LoadIndex(idxfile: string);
    function CopyImageDataToTexture(Buffer: PAnsiChar; Texture: TDXImageTexture; Width, Height: Word): Boolean;
  protected
    procedure LoadDxImage(index: Integer; position: integer; pDXTexture: pTDXTextureSurface); override;
  public
    constructor Create(); override;
    function Initialize(): Boolean; override;
    procedure Finalize; override;
    property bo16bit: Boolean read Fbo16bit;
  end;

  TWMM2DefBit16Images = class(TWMM2DefImages)
  public
    constructor Create(); override;
  end;

implementation

{ TWMM2DefImages }

function TWMM2DefImages.CopyImageDataToTexture(Buffer: PAnsiChar; Texture: TDXImageTexture; Width, Height: Word): Boolean;
var
  Y: Integer;
  Access: TDXAccessInfo;
  WriteBuffer, ReadBuffer: PAnsiChar;
begin
  Result := False;
  if Texture.Lock(lfWriteOnly, Access) then begin
    try
      if Fbo16bit then begin
        FillChar(Access.Bits^, Access.Pitch * Texture.Size.Y, #0);
        for Y := 0 to Height - 1 do begin
          WriteBuffer := Pointer(Integer(Access.Bits) + (Access.Pitch * Y));
          ReadBuffer := @Buffer[(Height - 1 - Y) * Width];
          LineR5G6B5_A1R5G5B5(ReadBuffer, WriteBuffer, Texture.Width);
        end;
      end else begin
        FillChar(Access.Bits^, Access.Pitch * Texture.Size.Y, #0);
        WriteBuffer := Pointer(Integer(Access.Bits));
        ReadBuffer := @Buffer[(Height - 1) * Width];
        for Y := 0 to Height - 1 do begin
          LineX8_A1R5G5B5(ReadBuffer, WriteBuffer, Texture.Width);
          Inc(WriteBuffer, Access.Pitch);
          Dec(ReadBuffer, Width);
        end;
      end;
      Result := True;
    finally
      Texture.Unlock;
    end;
  end;
end;

constructor TWMM2DefImages.Create;
begin
  inherited;
  FReadOnly := True;
  Fbo16bit := False;
end;

procedure TWMM2DefImages.Finalize;
begin
  inherited;
end;

function TWMM2DefImages.Initialize: Boolean;
begin
  Result := inherited Initialize;
  if Result then begin
    FFileStream.Read(FHeader, SizeOf(TWMImageHeader));
    //if FHeader.ColorCount = $100000 then
    Fbo16bit := FHeader.ColorCount = $10000;
    if FHeader.IndexOffset <> 0 then begin //原老新格式
      FNewFmt := True;
      //FFormatName := 'MIR2 标准数据格式(新)';
      //btVersion := 1;
    end
    else begin //原老格式
      //btVersion := 0;
      //FFormatName := 'MIR2 标准数据格式(旧)';
      FNewFmt := False;
      FFileStream.Seek(-4, soFromCurrent);
    end;
    FImageCount := FHeader.ImageCount;
    FIdxFile := ExtractFilePath(FFileName) + ExtractFileNameOnly(FFileName) + '.WIX';
    LoadIndex(FIdxFile);
    InitializeTexture;
  end;
end;

procedure TWMM2DefImages.LoadDxImage(index: Integer; position: integer; pDXTexture: pTDXTextureSurface);
var
  imginfo: TWMImageInfo;
  Buffer: PAnsiChar;
  ReadSize, nLen: Integer;
begin
  pDXTexture.boNotRead := True;
  if FFileStream.Seek(position, 0) = position then begin;
    if not FNewFmt then
      FFileStream.Read(imginfo, SizeOf(imginfo) - SizeOf(Integer))
    else
      FFileStream.Read(imginfo, SizeOf(imginfo));
    if (imginfo.DXInfo.nWidth > MAXIMAGESIZE) or (imgInfo.DXInfo.nHeight > MAXIMAGESIZE) then
      Exit;
    if (imginfo.DXInfo.nWidth < MINIMAGESIZE) or (imgInfo.DXInfo.nHeight < MINIMAGESIZE) then
      Exit;
    if Fbo16bit then begin
      nLen := WidthBytes(16, imginfo.DXInfo.nWidth);
      ReadSize := nLen * imgInfo.DXInfo.nHeight;
    end else begin
      nLen := WidthBytes(8, imginfo.DXInfo.nWidth);
      ReadSize := nLen * imgInfo.DXInfo.nHeight;
    end;
    GetMem(Buffer, ReadSize);
    try
      if FFileStream.Read(Buffer^, ReadSize) = ReadSize then begin
        pDXTexture.Surface := MakeDXImageTexture(imginfo.DXInfo.nWidth, imginfo.DXInfo.nHeight, WILFMT_A1R5G5B5);

        if pDXTexture.Surface <> nil then begin
          if not CopyImageDataToTexture(Buffer, pDXTexture.Surface, nLen, imginfo.DXInfo.nHeight) then
          begin
            pDXTexture.Surface.Free;
            pDXTexture.Surface := nil;
          end
          else begin
            pDXTexture.boNotRead := False;
            pDXTexture.nPx := imginfo.DXInfo.px;
            pDXTexture.nPy := imginfo.DXInfo.py;
          end;
        end;
      end;
    finally
      FreeMem(Buffer);
    end;
  end;
end;

procedure TWMM2DefImages.LoadIndex(idxfile: string);
var
  fhandle, i, value: integer;
  pvalue: PInteger;
  CharBuffer: array[0..4] of Char;
begin
  FIndexList.Clear;
  FImageCount := 0;
  if FileExists(idxfile) then begin
    fhandle := FileOpen(idxfile, fmOpenRead or fmShareDenyNone);
    if fhandle > 0 then begin
      FileRead(fhandle, CharBuffer[0], 5);
      if not (CompareText(CharBuffer, 'MirOf') = 0) then
        FileSeek(fHandle, 0, 0);

      if not FNewFmt then
        FileRead(fhandle, FIdxHeader, sizeof(TWMIndexHeader) - 4)
      else
        FileRead(fhandle, FIdxHeader, sizeof(TWMIndexHeader));

      if FIdxHeader.IndexCount > MAXIMAGECOUNT then exit;

      GetMem(pvalue, 4 * FIdxHeader.IndexCount);
      if FileRead(fhandle, pvalue^, 4 * FIdxHeader.IndexCount) = (4 * FIdxHeader.IndexCount) then begin
        for i := 0 to FIdxHeader.IndexCount - 1 do begin
          value := PInteger(integer(pvalue) + 4 * i)^;
          FIndexList.Add(pointer(value));
        end;
      end;
      FreeMem(pvalue);
      FileClose(fhandle);
    end;
    FImageCount := FIndexList.Count;
  end;
end;



{ TWMM2DefBit16Images }

constructor TWMM2DefBit16Images.Create;
begin
  inherited;
  Fbo16bit := True;
end;

end.


