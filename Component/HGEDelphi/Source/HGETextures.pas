unit HGETextures;

interface

uses
  System.SysUtils, System.Classes, System.Math,
  Winapi.Windows, Winapi.Direct3D9,
  Vcl.Graphics, Vcl.Imaging.pngimage,
  HGE, HGEBase;

type
  TDXTextureBehavior = (tbManaged, tbUnmanaged, tbDynamic, tbRTarget, tbSystem);

  TDXLockFlags = (lfNormal, lfReadOnly, lfWriteOnly);

  TDXTextureState = (tsNotReady, tsReady, tsLost, tsFailure);

  TDrawMode = (dmNone{无透明}, dmDefault{默认}, dmAnti{混合}, dmColorAdd{颜色加?});


  TDXAccessInfo = record
    Bits: Pointer;
    Pitch: Integer;
    Format: TColorFormat;
  end;

  TDXTexture = class
  private
    FHeight: Integer;
    FWidth: Integer;
    FTexWidth: Integer;
    FTexHeight: Integer;
    FTexture: ITexture;
    FSize: TPoint;
    FPatternSize: TPoint;
    FFormat: TD3DFormat;
    FBehavior: TDXTextureBehavior;
    FActive: Boolean;
    FDrawCanvas: TObject;
    function GetActive: Boolean;
    function GetPool(): TD3DPool;
    function GetPixel(X, Y: Integer): Cardinal;
    procedure SetActive(const Value: Boolean);
    procedure SetSize(const Value: TPoint);
    procedure SetBehavior(const Value: TDXTextureBehavior);
    procedure SetFormat(const Value: TD3DFormat);
    procedure SetPixel(X, Y: Integer; const Value: Cardinal);
    procedure SetPatternSize(const Value: TPoint);
    procedure LoadBitmapToTexture(Stream: TStream); overload;
    procedure LoadBitmapToTexture(Bitmap: TBitmap); overload;
    procedure LoadBitmapToTexture(FileName: string; var SW, SH: Integer); overload;
    procedure LoadBitmapToTexture(Bitmap: TBitmap; var SW, SH: Integer); overload;
    procedure Load24or32BitmapToTexture(FileName: string; Mode: integer; var SW, SH: Integer);
  protected
    FState: TDXTextureState;
    function MakeReady(): Boolean; dynamic;
    procedure MakeNotReady(); dynamic;
    procedure ChangeState(NewState: TDXTextureState);
  public
    constructor Create(DrawCanvas: TObject = nil); dynamic;
    destructor Destroy; override;
    property Canvas: TObject read FDrawCanvas write FDrawCanvas;
    property Active: Boolean read GetActive write SetActive;
    property Size: TPoint read FSize write SetSize;
    property PatternSize: TPoint read FPatternSize write SetPatternSize;
    property Image: ITexture read FTexture write FTexture;
    property Format: TD3DFormat read FFormat write SetFormat;
    property Behavior: TDXTextureBehavior read FBehavior write SetBehavior;
    property Pixels[X, Y: Integer]: Cardinal read GetPixel write SetPixel;
    function Lock(Flags: TDXLockFlags; out Access: TDXAccessInfo): Boolean;
    function LockRect(const LockArea: TRect; Flags: TDXLockFlags; out Access: TDXAccessInfo): Boolean;
    function Unlock(): Boolean;
    function Clear(): Boolean;
    function ClientRect: TRect; dynamic;
    function Width: Integer; dynamic;
    function Height: Integer; dynamic;
    procedure Lost(); dynamic;
    procedure Recovered(); dynamic;
    procedure Line(nX, nY, nLength: Integer; FColor: Cardinal);
    procedure LineTo(nX, nY, nWidth: Integer; FColor: Cardinal);
    procedure FillRect(const Rect: TRect; Color: Cardinal);
    procedure FrameRect(const Rect: TRect; DevColor: Cardinal);
    procedure RFillRect(FColor: Cardinal);
    procedure LoadBitmapToDTexture(Bitmap: TBitmap);
    procedure LoadFromFile(FileName: string); overload;
    procedure LoadFromFile(FileName: string; var SW, SH: Integer; mode: Integer = 0); overload;
    procedure LoadFromFile(Bitmap: TBitmap; var SW, SH: Integer; mode: Integer = 0); overload;
    procedure LoadFromBitmap(bitmap: Tbitmap; Transparent: Boolean = true);
    procedure CopyTexture(SourceTexture: TDXTexture); overload;
    procedure CopyTexture(X, Y: Integer; SourceTexture: TDXTexture); overload;
    procedure Draw(X, Y: Integer; Source: TDXTexture; Transparent: Boolean); overload;
    procedure Draw(X, Y: Integer; Source: TDXTexture; Transparent, MirrorX, MirrorY: Boolean); overload;
    procedure Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Transparent: Boolean); overload;
    procedure Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Transparent, MirrorX, MirrorY: Boolean); overload;
    procedure Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Color, DrawFx: Cardinal); overload;
    procedure Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; DrawFx: Cardinal); overload;
    procedure Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Transparent: Boolean; DrawFx: Cardinal); overload;

    procedure Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; DrawMode: TDrawMode); overload;

    procedure StretchDraw(SrcRect, DesRect: TRect; Source: TDXTexture; Transparent: Boolean); overload;
    procedure StretchDraw(SrcRect, DesRect: TRect; Source: TDXTexture; DrawFx: Cardinal); overload;
    procedure StretchDraw(SrcRect, DesRect: TRect; Source: TDXTexture; dwColor: Cardinal; DrawFx: Cardinal); overload;
    procedure DrawRect(X, Y, Width, Height: Single; Color: Cardinal; Filled: Boolean; BlendMode: Integer = BLEND_DEFAULT);

    //Edit使用
    procedure TextOutEdit(X, Y: Integer; Text: string; FColor: Cardinal);
    procedure TextOutTexture(X, Y: Integer; Text: string; FColor: Cardinal); overload;
    procedure TextOutTexture(X, Y: Integer; Text: WideString; FColor: Cardinal; BColor: Cardinal; boClearMark: Boolean = False); overload;
  end;

  TDXImageTexture = class(TDXTexture)
  public
    constructor Create(DrawCanvas: TObject = nil); override;
    function ClientRect: TRect; override;
    function Width: Integer; override;
    function Height: Integer; override;
  end;

  TDXRenderTargetTexture = class(TDXTexture)
  private
    FTarget: ITarget;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
  protected
    function MakeReady(): Boolean; override;
    procedure MakeNotReady(); override;
  public
    constructor Create(DrawCanvas: TObject = nil); override;
    destructor Destroy; override;
    procedure Lost(); override;
    procedure Recovered(); override;
    property Target: ITarget read FTarget write FTarget;
    property Active: Boolean read GetActive write SetActive;
  end;

procedure InitializeTexturesInfo();


procedure WidthBytes(AWidth, ABitCount: Integer; var APicth: Integer); inline;



implementation

uses
  HGECanvas, HGEFonts, Wil;

var
  FHGE: IHGE = nil;
  FQuad: THGEQuad;

procedure WidthBytes(AWidth, ABitCount: Integer; var APicth: Integer);
begin
  APicth := (((AWidth * ABitCount) + 31) and not 31) div 8;
end;


procedure InitializeTexturesInfo();
begin
  FHGE := HGECreate(HGE_VERSION);
end;

{ TDXTexture }
function TDXTexture.GetActive: Boolean;
begin
  Result := (FTexture <> nil) and (FState = tsReady) and (FTexture.Handle <> nil);
end;

function TDXTexture.GetPool: TD3DPool;
begin
  Result := D3DPOOL_DEFAULT;
  case FBehavior of
    tbManaged:
      Result := D3DPOOL_MANAGED;
    tbUnmanaged:
      ;
    tbDynamic:
      ;
    tbRTarget:
      ;
    tbSystem:
      Result := D3DPOOL_SYSTEMMEM;
  end;
end;

function TDXTexture.GetPixel(X, Y: Integer): Cardinal;
var
  Access: TDXAccessInfo;
  PPixel: Pointer;
begin
  Result := 0;
  if (X < 0) or (Y < 0) or (X > Size.X) or (Y > Size.Y) then
    exit;

//   (1) Lock the desired texture.
  if (not Lock(lfReadOnly, Access)) then
  begin
    Result := 0;
    Exit;
  end;
  try
    PPixel := Pointer(Integer(Access.Bits) + (Access.Pitch * Y) + (X * Format2Bytes[Access.Format]));
    Result := DisplaceRB(PixelXto32(PPixel, Access.Format));
  finally
    Unlock();
  end;
end;

procedure TDXTexture.SetActive(const Value: Boolean);
begin
  if Value then
    ChangeState(tsReady)
  else
    ChangeState(tsNotReady);
  FActive := FState = tsReady;
end;

procedure TDXTexture.SetSize(const Value: TPoint);
begin
  FSize := Value;
end;

procedure TDXTexture.SetBehavior(const Value: TDXTextureBehavior);
begin
  FBehavior := Value;
end;

procedure TDXTexture.SetFormat(const Value: TD3DFormat);
begin
  FFormat := Value;
end;

procedure TDXTexture.SetPixel(X, Y: Integer; const Value: Cardinal);
var
  Access: TDXAccessInfo;
  PPixel: Pointer;
begin
//   (1) Lock the desired texture.
  if (X < 0) or (Y < 0) or (X > Size.X) or (Y > Size.Y) then
    exit;
  if (not Lock(lfWriteOnly, Access)) then
    Exit;

  try
//   (2) Get pointer to the requested pixel.
    PPixel := Pointer(Integer(Access.Bits) + (Access.Pitch * Y) + (X * Format2Bytes[Access.Format]));

//   (3) Apply format conversion.
    Pixel32toX(DisplaceRB(Value), PPixel, Access.Format);
  finally
//   (4) Unlock the texture.
    Unlock();
  end;
end;

procedure TDXTexture.SetPatternSize(const Value: TPoint);
begin
  FPatternSize := Value;
end;

procedure TDXTexture.LoadBitmapToTexture(Stream: TStream);
var
  Bitmap: TBitmap;
  Access: TDXAccessInfo;
  Y: Integer;
  WriteBuffer, ReadBuffer: PChar;
begin
  Bitmap := TBitmap.Create;
  try
    Stream.Position := 0;
    Bitmap.LoadFromStream(Stream);
    FTexture := FHGE.Texture_Create(Bitmap.Width, Bitmap.Height, GetPool, FFormat);
    if (FTexture <> nil) and (FTexture.Handle <> nil) then
    begin
      if Lock(lfWriteOnly, Access) then
      begin
        for Y := 0 to Bitmap.Height - 1 do
        begin
          ReadBuffer := Bitmap.ScanLine[Y];
          WriteBuffer := Pointer(Integer(Access.Bits) + (Access.Pitch * Y));
          Move(ReadBuffer^, WriteBuffer^, Bitmap.Width * 2);
        end;
        UnLock;
      end;
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure TDXTexture.LoadBitmapToTexture(Bitmap: TBitmap);
var
  Access: TDXAccessInfo;
  Y: Integer;
  WriteBuffer, ReadBuffer: PChar;
begin
  try
    FTexture := FHGE.Texture_Create(Bitmap.Width, Bitmap.Height, GetPool, FFormat);
    if (FTexture <> nil) and (FTexture.Handle <> nil) then
    begin
      if Lock(lfWriteOnly, Access) then
      begin
        for Y := 0 to Bitmap.Height - 1 do
        begin
          ReadBuffer := Bitmap.ScanLine[Y];
          WriteBuffer := Pointer(Integer(Access.Bits) + (Access.Pitch * Y));
          LineR5G6B5_A1R5G5B5(ReadBuffer, WriteBuffer, Bitmap.Width);
        end;
        UnLock;
      end;
    end;
  finally
    Bitmap.Free;
  end;
end;
{$WARNINGS OFF}
procedure TDXTexture.LoadBitmapToTexture(FileName: string; var SW, SH: Integer);
var
  Bitmap: TBitmap;
  Access: TDXAccessInfo;
  Y: Integer;
  WriteBuffer, ReadBuffer: PAnsiChar;
  bt: Integer;
begin
  try
    Bitmap := TBitmap.Create;
    Bitmap.LoadFromFile(FileName);
    case Bitmap.PixelFormat of
      pf8bit:
        bt := 0;
      pf16bit:
        bt := 1;
    end;
    FTexture := FHGE.Texture_Create(Bitmap.Width, Bitmap.Height, GetPool, FFormat);
    if (FTexture <> nil) and (FTexture.Handle <> nil) then
    begin
      if Lock(lfWriteOnly, Access) then
      begin
        for Y := 0 to Bitmap.Height - 1 do
        begin
          ReadBuffer := Bitmap.ScanLine[Y];
          WriteBuffer := Pointer(Integer(Access.Bits) + (Access.Pitch * Y));
          if bt = 0 then
            LineX8_A1R5G5B5(ReadBuffer, WriteBuffer, Bitmap.Width)
          else
            LineR5G6B5_A1R5G5B5(ReadBuffer, WriteBuffer, Bitmap.Width);
        end;
        UnLock;
      end;
      SW := Bitmap.Width;
      SH := Bitmap.Height;
    end;
  finally
   Bitmap.Free;
  end;

end;
{$WARNINGS ON}

procedure TDXTexture.LoadBitmapToTexture(Bitmap: TBitmap; var SW, SH: Integer);
var
  Access: TDXAccessInfo;
  Y: Integer;
  WriteBuffer, ReadBuffer: PChar;
begin
  try
    FTexture := FHGE.Texture_Create(Bitmap.Width, Bitmap.Height, GetPool, FFormat);
    if (FTexture <> nil) and (FTexture.Handle <> nil) then
    begin
      if Lock(lfWriteOnly, Access) then
      begin
        for Y := 0 to Bitmap.Height - 1 do
        begin
          ReadBuffer := Bitmap.ScanLine[Y];
          WriteBuffer := Pointer(Integer(Access.Bits) + (Access.Pitch * Y));
          LineR5G6B5_A1R5G5B5(ReadBuffer, WriteBuffer, Bitmap.Width);
        end;
        UnLock;
      end;
      SW := Bitmap.Width;
      SH := Bitmap.Height;
    end;

  finally
    Bitmap.Free;
  end;
end;

procedure TDXTexture.Load24or32BitmapToTexture(FileName: string; Mode: integer; var SW, SH: Integer);
var
  Bitmap: TBitmap;
  X, Y: Integer;
  PDes: PLongword;
  PSrc: pointer;
begin
  try
    Bitmap := TBitmap.Create;
    Bitmap.LoadFromFile(FileName);
    FTexture := FHGE.Texture_Create(Bitmap.Width, Bitmap.Height, GetPool, FFormat);
    if (FTexture <> nil) and (FTexture.Handle <> nil) then
    begin
      PDes := FHGE.Texture_Lock(FTexture, True, 0, 0, Bitmap.Width, Bitmap.Height);
      for Y := 0 to Bitmap.Height - 1 do
      begin
        PSrc := Bitmap.ScanLine[Y];
        X := 0;
        while TRUE do
        begin
          if X >= Bitmap.Width then
            break;
          PDes^ := PixelXto32(PSrc, COLOR_A8R8G8B8, Mode);
          Inc(PLongword(PDes));
          Inc(Longword(PSrc), 3);
          Inc(X);
        end;
      end;
      FHGE.Texture_Unlock(FTexture);
      SW := Bitmap.Width;
      SH := Bitmap.Height;
    end;

  finally

  end;
    Bitmap.Free;
end;

function TDXTexture.MakeReady: Boolean;
var
  Pool: TD3DPool;
begin
  Result := False;

  Pool := D3DPOOL_DEFAULT;
  case FBehavior of
    tbManaged:
      Pool := D3DPOOL_MANAGED;
    tbSystem:
      Pool := D3DPOOL_SYSTEMMEM;
  end;

  FTexture := FHGE.Texture_Create(FSize.X, FSize.Y, Pool, FFormat);
  if (FTexture <> nil) and (FTexture.Handle <> nil) then
  begin
    FSize.X := FTexture.GetWidth();
    FSize.Y := FTexture.GetHeight();
    Result := True;
  end
  else
    FTexture := nil;
end;

procedure TDXTexture.MakeNotReady;
begin
  if FTexture <> nil then
    FTexture.Handle := nil;
  FTexture := nil;
end;

procedure TDXTexture.ChangeState(NewState: TDXTextureState);
begin
  if (FState = tsNotReady) and (NewState = tsReady) then
  begin
    if MakeReady() then
      FState := tsReady;
  end
  else if (NewState = tsNotReady) then
  begin
    if (FState = tsReady) then
      MakeNotReady();
    FState := tsNotReady;
  end
  else if (FState = tsReady) and (NewState = tsLost) and (FBehavior <> tbManaged) then
  begin
    MakeNotReady();
    FState := tsLost;
  end
  else if (FState = tsLost) and (NewState = tsReady) then
  begin
    if (MakeReady()) then
      FState := tsReady
    else
      FState := tsFailure;
  end
  else if (FState = tsFailure) and (NewState = tsReady) then
  begin
    if (MakeReady()) then
      FState := tsReady;
  end;
end;

constructor TDXTexture.Create(DrawCanvas: TObject);
begin
  inherited Create;
  FTexture := nil;
  FState := tsNotReady;
  FFormat := D3DFMT_A8R8G8B8;
  FBehavior := tbManaged;
  FActive := False;
  FDrawCanvas := DrawCanvas;
end;

destructor TDXTexture.Destroy;
begin
  if FTexture <> nil then
    FTexture.Handle := nil;
  FTexture := nil;
  inherited;
end;

function TDXTexture.Lock(Flags: TDXLockFlags; out Access: TDXAccessInfo): Boolean;
var
  LockedRect: TD3DLocked_Rect;
  Usage: Cardinal;
begin
  // (1) Verify conditions.
  Result := False;

  if (FTexture = nil) or (FTexture.Handle = nil) then
    Exit;

  // (2) Determine USAGE.
  Usage := 0;
  if (Flags = lfReadOnly) then
    Usage := D3DLOCK_READONLY;

  // (3) Lock the entire texture.
  Result := Succeeded(FTexture.Handle.LockRect(0, LockedRect, nil, Usage));

  // (4) Return access information.
  if (Result) then
  begin
    Access.Bits := LockedRect.pBits;
    Access.Pitch := LockedRect.Pitch;
    Access.Format := D3DToFormat(FFormat);
  end;
end;

function TDXTexture.LockRect(const LockArea: TRect; Flags: TDXLockFlags; out Access: TDXAccessInfo): Boolean;
var
  LockedRect: TD3DLocked_Rect;
  Usage: Cardinal;
begin
  // (1) Verify conditions.
  Result := False;
  if (FTexture = nil) or (FTexture.Handle = nil) then
    Exit;

  // (2) Determine USAGE.
  Usage := 0;
  if (Flags = lfReadOnly) then
    Usage := D3DLOCK_READONLY;

  // (3) Lock the entire texture.
  Result := Succeeded(FTexture.Handle.LockRect(0, LockedRect, @LockArea, Usage));

  // (4) Return access information.
  if (Result) then
  begin
    Access.Bits := LockedRect.pBits;
    Access.Pitch := LockedRect.Pitch;
    Access.Format := D3DToFormat(FFormat);
  end;
end;

function TDXTexture.Unlock: Boolean;
begin
  Result := (FTexture <> nil) and (FTexture.Handle <> nil) and (Succeeded(FTexture.Handle.UnlockRect(0)));
end;

function TDXTexture.Clear(): Boolean;
var
  Access: TDXAccessInfo;
begin
  Result := False;
  if not Active then
    exit;
  if Lock(lfWriteOnly, Access) then
  begin
    try
      FillChar(Access.Bits^, Access.Pitch * Size.Y, #0);
      Result := True;
    finally
      Unlock();
    end;
  end;
end;

function TDXTexture.ClientRect: TRect;
begin
  Result.Left := 0;
  Result.Top := 0;
  Result.Right := FSize.X;
  Result.Bottom := FSize.Y;
end;

function TDXTexture.Width: Integer;
begin
  Result := FSize.X;
end;

function TDXTexture.Height: Integer;
begin
  Result := FSize.Y;
end;

procedure TDXTexture.Lost;
begin
  ChangeState(tsLost);
end;

procedure TDXTexture.Recovered;
begin
  ChangeState(tsReady);
end;

procedure TDXTexture.Line(nX, nY, nLength: Integer; FColor: Cardinal);
var
  Access: TDXAccessInfo;
  wColor: Word;
  RGBQuad: TRGBQuad;
  WriteBuffer: Pointer;
begin
  if nY < 0 then
    exit;
  if nY > FSize.Y then
    exit;
  if nX > FSize.X then
    exit;
  if nX < 0 then
  begin
    nLength := nLength - nX;
    nX := 0;
  end;
  if (nX + nLength) > FSize.X then
    nLength := FSize.X - nX;
  if nLength <= 0 then
    exit;
  FColor := DisplaceRB(FColor or $FF000000);
  RGBQuad := PRGBQuad(@FColor)^;
  wColor := ($F0 shl 8) + ((WORD(RGBQuad.rgbRed) and $F0) shl 4) + (WORD(RGBQuad.rgbGreen) and $F0) + (WORD(RGBQuad.rgbBlue) shr 4);
  if Lock(lfWriteOnly, Access) then
  begin
    try
      WriteBuffer := Pointer(Integer(Access.Bits) + Access.Pitch * nY + nX * 2);
      asm
        push    edi
        push    edx
        push    eax
        mov     edi, WriteBuffer
        mov     ecx, nLength
        mov     dx, wColor

@pixloop:
        mov     ax, [edi].word
        mov     [edi], dx
        add     edi, 2
        dec     ecx
        jnz     @pixloop
        pop     eax
        pop     edx
        pop     edi
      end;
    finally
      UnLock;
    end;
  end;
end;

procedure TDXTexture.LineTo(nX, nY, nWidth: Integer; FColor: Cardinal);
var
  Access: TDXAccessInfo;
  I: Integer;
  WriteBuffer: PWord;
  wColor: Word;
  RGBQuad: TRGBQuad;
begin
  if nX < 0 then
  begin
    nWidth := nWidth + nX;
    nX := 0;
  end;
  if nY < 0 then
    Exit;
  if nX >= FSize.X then
    Exit;
  if nY >= FSize.Y then
    exit;
  if (nX + nWidth) > FSize.X then
    nWidth := FSize.X - nX;
  if nWidth <= 0 then
    Exit;
  RGBQuad := PRGBQuad(@FColor)^;
  wColor := ($F0 shl 8) + ((WORD(RGBQuad.rgbRed) and $F0) shl 4) + (WORD(RGBQuad.rgbGreen) and $F0) + (WORD(RGBQuad.rgbBlue) shr 4);
  if Lock(lfWriteOnly, Access) then
  begin
    try
      WriteBuffer := PWord(Integer(Access.Bits) + (Access.Pitch * nY) + (nX * 2));
      for I := nX to nWidth + nX do
      begin
        WriteBuffer^ := wColor;
        Inc(WriteBuffer);
      end;
    finally
      UnLock;
    end;
  end;
end;

procedure TDXTexture.FillRect(const Rect: TRect; Color: Cardinal);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).Rectangle(Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top, DisplaceRB(Color), True);
end;

procedure TDXTexture.FrameRect(const Rect: TRect; DevColor: Cardinal);
var
  colorARGB: Cardinal;
begin
  colorARGB := SetA(DevColor, 255);
  FHGE.Gfx_RenderLine(Rect.Left, Rect.Top, Rect.Right, Rect.Top, colorARGB);
  FHGE.Gfx_RenderLine(Rect.Left, Rect.Top, Rect.Left, Rect.Bottom, colorARGB);
  FHGE.Gfx_RenderLine(Rect.Left, Rect.Bottom, Rect.Right, Rect.Bottom, colorARGB);
  FHGE.Gfx_RenderLine(Rect.Right, Rect.Top, Rect.Right, Rect.Bottom, colorARGB);
end;

procedure TDXTexture.RFillRect(FColor: Cardinal);  //32位色用
var
  Access: TDXAccessInfo;
  nX, nY: Integer;
  WriteBuffer: PLongword;
  wColor: Longword;
begin
  if FSize.X <= 0 then
    Exit;
  if FSize.Y <= 0 then
    exit;
  wColor := FColor or $FF000000;
  if Lock(lfWriteOnly, Access) then
  begin
    try
      for nY := 0 to FSize.Y do
      begin
        WriteBuffer := PLongword(Integer(Access.Bits) + (Access.Pitch * nY));
        for nX := 0 to FSize.X do
        begin
          WriteBuffer^ := wColor;
          Inc(PLongword(WriteBuffer));
        end;
      end;
    finally
      UnLock;
    end;
  end;
end;

procedure TDXTexture.LoadBitmapToDTexture(Bitmap: TBitmap);
begin
  LoadBitmapToTexture(Bitmap);
end;

procedure TDXTexture.LoadFromFile(FileName: string);
var
  MemoryStream: TMemoryStream;
begin
  if FTexture <> nil then
  begin
    FTexture.Handle := nil;
    FTexture := nil;
  end;
  if FileExists(FileName) then
  begin
    MemoryStream := TMemoryStream.Create;
    try
      MemoryStream.LoadFromFile(FileName);
      if MemoryStream.Size > 2 then
      begin
        if (PChar(MemoryStream.Memory)[0] + PChar(MemoryStream.Memory)[1]) = 'BM' then
        begin
          LoadBitmapToTexture(MemoryStream);
        end;
        if FTexture <> nil then
        begin
          FSize.X := FTexture.GetWidth;
          FSize.Y := FTexture.GetHeight;
          FPatternSize := FSize;
        end;
      end;
    finally
      MemoryStream.Free;
    end;
  end;
end;

procedure TDXTexture.LoadFromFile(FileName: string; var SW, SH: Integer; mode: Integer);
begin
  if FTexture <> nil then
  begin
    FTexture.Handle := nil;
    FTexture := nil;
  end;
  if FileExists(FileName) then
  begin
    SW := 0;
    SH := 0;
    try
      if mode = 0 then
      begin
        LoadBitmapToTexture(FileName, SW, SH);
      end
      else
      begin
        Load24or32BitmapToTexture(FileName, mode, SW, SH);
      end;
      if FTexture <> nil then
      begin
        FSize.X := FTexture.GetWidth;
        FSize.Y := FTexture.GetHeight;
        FPatternSize := FSize;
      end;

    finally

    end;
  end;
end;

procedure TDXTexture.LoadFromFile(Bitmap: TBitmap; var SW, SH: Integer; mode: Integer);
begin
  if FTexture <> nil then
  begin
    FTexture.Handle := nil;
    FTexture := nil;
  end;
  SW := 0;
  SH := 0;
  try
    LoadBitmapToTexture(Bitmap, SW, SH);
    if FTexture <> nil then
    begin
      FSize.X := FTexture.GetWidth;
      FSize.Y := FTexture.GetHeight;
      FPatternSize := FSize;
    end;

  finally

  end;
end;

procedure TDXTexture.LoadFromBitmap(bitmap: Tbitmap; Transparent: Boolean);
var
  nloop, jloop: integer;
  OldColP: PLongWord;
  r, b, g: byte;
  c: Tcolor;
begin
  FTexWidth := 1 shl ceil(log2(bitmap.Width));
  FTexHeight := 1 shl ceil(log2(bitmap.Height));
  FTexture := FHGE.Texture_Create(FTexWidth, FTexHeight);
  OldColP := FTexture.Lock(false);
  for nloop := 0 to bitmap.height - 1 do
  begin
    for jloop := 0 to bitmap.width - 1 do
    begin
      c := bitmap.canvas.Pixels[jloop, nloop];
      if Transparent then
      begin
        if c = 0 then
        begin
          OldColP^ := $00000000;
        end
        else
        begin
          r := getrvalue(c);
          g := getgvalue(c);
          b := getbvalue(c);
          OldColP^ := argb($FF, r, g, b);
        end;
      end
      else
      begin
        r := getrvalue(c);
        g := getgvalue(c);
        b := getbvalue(c);
        OldColP^ := argb($FF, r, g, b);
      end;
      inc(OldColP);
    end;
    Inc(OldColP, FTexWidth - bitmap.Width);
  end;
  FTexture.Unlock;
  FWidth := bitmap.width;
  FHeight := bitmap.Height;
  FQuad.Tex := FTexture;
  FQuad.V[0].TX := 0;
  FQuad.V[0].TY := 0;
  FQuad.V[1].TX := FWidth / FTexWidth;
  FQuad.V[1].TY := 0;
  FQuad.V[2].TX := FWidth / FTexWidth;
  FQuad.V[2].TY := FHeight / FTexHeight;
  FQuad.V[3].TX := 0;
  FQuad.V[3].TY := FHeight / FTexHeight;
  FQuad.Blend := BLEND_DEFAULT;
  FQuad.V[0].Col := $FFFFFFFF;
  FQuad.V[1].Col := $FFFFFFFF;
  FQuad.V[2].Col := $FFFFFFFF;
  FQuad.V[3].Col := $FFFFFFFF;
end;

procedure TDXTexture.CopyTexture(SourceTexture: TDXTexture);
var
  SourceAccess: TDXAccessInfo;
  Access: TDXAccessInfo;
begin
  if SourceTexture = nil then
    exit;
  if Active then
    ChangeState(tsNotReady);
  FSize := SourceTexture.Size;
  FPatternSize := SourceTexture.PatternSize;
  FFormat := SourceTexture.Format;
  ChangeState(tsReady);
  if SourceTexture.Lock(lfReadOnly, SourceAccess) then
  begin
    try
      if Lock(lfWriteOnly, Access) then
      begin
        try
          Move(SourceAccess.Bits^, Access.Bits^, Access.Pitch * FSize.Y);
        finally
          UnLock;
        end;
      end;
    finally
      SourceTexture.Unlock;
    end;
  end;
end;

procedure TDXTexture.CopyTexture(X, Y: Integer; SourceTexture: TDXTexture);
var
  SourceAccess: TDXAccessInfo;
  Access: TDXAccessInfo;
  srcleft, srcwidth, srctop, srcbottom, I: Integer;
  ReadBuffer, WriteBuffer: Pointer;
begin
  if SourceTexture = nil then
    exit;
  if X >= FSize.X then
    exit;
  if Y >= FSize.Y then
    exit;
  if X < 0 then
  begin
    srcleft := -X;
    srcwidth := SourceTexture.Width + X;
    X := 0;
  end
  else
  begin
    srcleft := 0;
    srcwidth := SourceTexture.Width;
  end;
  if Y < 0 then
  begin
    srctop := -Y;
    srcbottom := srctop + SourceTexture.Height + Y;
    Y := 0;
  end
  else
  begin
    srctop := 0;
    srcbottom := srctop + SourceTexture.Height;
  end;

  if (srcleft + srcwidth) > SourceTexture.Width then
    srcwidth := SourceTexture.Width - srcleft;
  if srcbottom > SourceTexture.Height then
    srcbottom := SourceTexture.Height;
  if (X + srcwidth) > FSize.X then
    srcwidth := FSize.X - X;

  if (Y + srcbottom - srctop) > FSize.Y then
    srcbottom := FSize.Y - Y + srctop;

  if (srcwidth <= 0) or (srcbottom <= 0) or (srcleft >= SourceTexture.Width) or (srctop >= SourceTexture.Height) then
    exit;

  if SourceTexture.Lock(lfReadOnly, SourceAccess) then
  begin
    try
      if Lock(lfWriteOnly, Access) then
      begin
        try
          for I := srctop to srcbottom - 1 do
          begin
            ReadBuffer := Pointer(Integer(SourceAccess.Bits) + SourceAccess.Pitch * I + (srcleft * 2));
            WriteBuffer := Pointer(Integer(Access.Bits) + Access.Pitch * (Y + I - srctop) + (X * 2));
            Move(ReadBuffer^, WriteBuffer^, srcwidth * 2);
          end;
        finally
          UnLock;
        end;
      end;
    finally
      SourceTexture.Unlock;
    end;
  end;
end;

procedure TDXTexture.Draw(X, Y: Integer; Source: TDXTexture; Transparent: Boolean);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).Draw(Source, X, Y, bTransparent[Transparent]);
end;

procedure TDXTexture.Draw(X, Y: Integer; Source: TDXTexture; Transparent, MirrorX, MirrorY: Boolean);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).Draw(Source, X, Y, bTransparent[Transparent], $FFFFFFFF, MirrorX, MirrorY);
end;

procedure TDXTexture.Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Transparent: Boolean);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawRect(Source, X, Y, SrcRect, bTransparent[Transparent]);
end;

procedure TDXTexture.Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Transparent, MirrorX, MirrorY: Boolean);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawRect(Source, X, Y, SrcRect, bTransparent[Transparent], $FFFFFFFF, MirrorX, MirrorY);
end;

procedure TDXTexture.Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Color, DrawFx: Cardinal);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawRect(Source, X, Y, SrcRect, DrawFx, Color);
end;

procedure TDXTexture.Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; DrawFx: Cardinal);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawRect(Source, X, Y, SrcRect, DrawFx);
end;

procedure TDXTexture.Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; Transparent: Boolean; DrawFx: Cardinal);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawRect(Source, X, Y, SrcRect, DrawFx, $7DFFFFFF);
end;

procedure TDXTexture.StretchDraw(SrcRect, DesRect: TRect; Source: TDXTexture; Transparent: Boolean);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawStretch(Source, SrcRect.Left, SrcRect.Top, SrcRect.Right, SrcRect.Bottom, DesRect, bTransparent[Transparent]);
end;

procedure TDXTexture.StretchDraw(SrcRect, DesRect: TRect; Source: TDXTexture; DrawFx: Cardinal);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawStretch(Source, SrcRect.Left, SrcRect.Top, SrcRect.Right, SrcRect.Bottom, DesRect, DrawFx);
end;

procedure TDXTexture.StretchDraw(SrcRect, DesRect: TRect; Source: TDXTexture; dwColor: Cardinal; DrawFx: Cardinal);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).DrawStretch(Source, SrcRect.Left, SrcRect.Top, SrcRect.Right, SrcRect.Bottom, DesRect, DrawFx, dwColor);
end;

procedure TDXTexture.DrawRect(X, Y, Width, Height: Single; Color: Cardinal; Filled: Boolean; BlendMode: Integer);
begin
  if FDrawCanvas <> nil then
    TDXCanvas(FDrawCanvas).Rectangle(X, Y, Width, Height, Color, Filled, BlendMode);
end;

procedure TDXTexture.TextOutEdit(X, Y: Integer; Text: string; FColor: Cardinal);
begin
  if FDrawCanvas <> nil then
    TextOutTexture(X, Y, Text, FColor);
end;

procedure TDXTexture.TextOutTexture(X, Y: Integer; Text: WideString; FColor, BColor: Cardinal; boClearMark: Boolean);
var
  Access, SourceAccess: TDXAccessInfo;
  sWord: Word;
  AsciiRect: TRect;
  I, j, nX, nY, kerning, nFontWidth, nFontHeight: Integer;
  ReadBuffer, WriteBuffer: Pointer;
  wColor, wBColor: Word;
  RGBQuad: TRGBQuad;
  FontData: pTFontData;
  Texture: TDXTexture;
begin
  if Text = '' then exit;
  if (BColor = 0) and (not boClearMark) then begin
    TextOutTexture(X, Y, Text, FColor);
    Exit;
  end;
  Dec(X);
  Dec(Y);
  FColor := DisplaceRB(FColor or $FF000000);
  RGBQuad := PRGBQuad(@FColor)^;
  wColor := ($F0 shl 8) + ((WORD(RGBQuad.rgbRed) and $F0) shl 4) + (WORD(RGBQuad.rgbGreen) and $F0) + (WORD(RGBQuad.rgbBlue) shr 4);

  if boClearMark then begin  //清理描边
    wBColor := 0;
  end
  else begin
    BColor := DisplaceRB(BColor or $FF000000);
    RGBQuad := PRGBQuad(@BColor)^;
    wBColor := ($F0 shl 8) + ((WORD(RGBQuad.rgbRed) and $F0) shl 4) + (WORD(RGBQuad.rgbGreen) and $F0) + (WORD(RGBQuad.rgbBlue) shr 4);
  end;
  if (FDrawCanvas <> nil) and (TDXDrawCanvas(FDrawCanvas).Font <> nil) then begin
    FontData := TDXDrawCanvas(FDrawCanvas).Font.FontData;
    kerning := TDXDrawCanvas(FDrawCanvas).Font.kerning;
    if Lock(lfWriteOnly, Access) then begin
      try
        for I := 1 to Length(Text) do begin
          if X >= Width then break;
          Move(Text[i], sWord, SizeOf(Char));
          AsciiRect := TDXDrawCanvas(FDrawCanvas).Font.AsciiRect[sWord];
          if (AsciiRect.Right > 4) then begin
            nY := Y;
            nFontWidth := AsciiRect.Right - AsciiRect.Left;
            if nFontWidth < 4 then Continue;
            if X < 0 then begin
              if (-X) >= (nFontWidth + kerning) then begin
                Inc(X, nFontWidth + kerning);
                Continue;
              end;
              AsciiRect.Left := AsciiRect.Left - X;
              nFontWidth := AsciiRect.Right - AsciiRect.Left;
              if nFontWidth <= 0 then begin
                X := kerning;
                Continue;
              end;
              X := 0;
            end;
            if (X + nFontWidth) >= Width then begin
              nFontWidth := Width - X;
              if nFontWidth <= 0 then Exit;
            end;

            if nY < 0 then begin
              AsciiRect.Top := AsciiRect.Top - nY;
              nY := 0;
            end;
            nFontHeight := AsciiRect.Bottom - AsciiRect.Top;
            if nFontHeight <= 0 then begin
              Inc(X, nFontWidth + kerning);
              Continue;
            end;

            for j := AsciiRect.Top to AsciiRect.Bottom - 1 do begin
              if nY >= Height then break;
              ReadBuffer := @(FontData^[j][AsciiRect.Left]);
              WriteBuffer := Pointer(Integer(Access.Bits) + Access.Pitch * nY + X * 2);
              asm
                push esi
                push edi
                push ebx
                push edx

                mov esi, ReadBuffer
                mov edi, WriteBuffer
                mov ecx, nFontWidth
                mov dx,  wColor
                mov bx,  wBColor
              @pixloop:
                mov ax, [esi].word
                add esi, 2

                cmp ax, 0
                JE  @@Next

                cmp ax, $F000
                JE  @@AddBColor

                and ax, dx
                mov [edi], dx
                JMP @@Next
              @@AddBColor:
                mov [edi], bx

              @@Next:
                add edi, 2

                dec ecx
                jnz @pixloop

                pop edx
                pop ebx
                pop edi
                pop esi
              end;
              Inc(nY);
            end;
            Inc(X, nFontWidth + kerning);
          end;
        end;
      finally
        UnLock;
      end;
    end;
  end;
end;

procedure TDXTexture.TextOutTexture(X, Y: Integer; Text: string; FColor: Cardinal);
var
  Access, SourceAccess: TDXAccessInfo;
  sWord: Word;
  AsciiRect: TRect;
  i, j, nX, nY, kerning, nFontWidth, nFontHeight: Integer;
  ReadBuffer, WriteBuffer: Pointer;
  wColor: Word;
  RGBQuad: TRGBQuad;
  FontData: pTFontData;
begin
  if Text = '' then exit;
  Dec(X);
  Dec(Y);
  FColor := DisplaceRB(FColor or $FF000000);
  RGBQuad := PRGBQuad(@FColor)^;
  wColor := ($F0 shl 8) + ((WORD(RGBQuad.rgbRed) and $F0) shl 4) + (WORD(RGBQuad.rgbGreen) and $F0) + (WORD(RGBQuad.rgbBlue) shr 4);
  if (FDrawCanvas <> nil) and (TDXDrawCanvas(FDrawCanvas).Font <> nil) then begin
    FontData := TDXDrawCanvas(FDrawCanvas).Font.FontData;
    kerning := TDXDrawCanvas(FDrawCanvas).Font.kerning;
    if Lock(lfWriteOnly, Access) then begin
      try
        for I := 1 to Length(Text) do begin
          if X >= Width then break;
          Move(Text[i], sWord, SizeOf(Char));
          AsciiRect := TDXDrawCanvas(FDrawCanvas).Font.AsciiRect[sWord];

          //标记 是否文字已经创建

          if (AsciiRect.Right > 4) then begin
            nY := Y;
            nFontWidth := AsciiRect.Right - AsciiRect.Left;
            if nFontWidth < 4 then Continue;
            if X < 0 then begin
              if (-X) >= (nFontWidth + kerning) then begin
                Inc(X, nFontWidth + kerning);
                Continue;
              end;
              AsciiRect.Left := AsciiRect.Left - X;
              nFontWidth := AsciiRect.Right - AsciiRect.Left;
              if nFontWidth <= 0 then begin
                X := kerning;
                Continue;
              end;
              X := 0;
            end;
            if (X + nFontWidth) >= Width then begin
              nFontWidth := Width - X;
              if nFontWidth <= 0 then Exit;
            end;

            if nY < 0 then begin
              AsciiRect.Top := AsciiRect.Top - nY;
              nY := 0;
            end;
            nFontHeight := AsciiRect.Bottom - AsciiRect.Top;
            if nFontHeight <= 0 then begin
              Inc(X, nFontWidth + kerning);
              Continue;
            end;

            for j := AsciiRect.Top to AsciiRect.Bottom - 1 do begin
              if nY >= Height then break;
              ReadBuffer := @(FontData^[j][AsciiRect.Left]);
              WriteBuffer := Pointer(Integer(Access.Bits) + Access.Pitch * nY + X * 2);
              asm
                push esi
                push edi
                push ebx
                push edx

                mov esi, ReadBuffer
                mov edi, WriteBuffer
                mov ecx, nFontWidth
                mov dx,  wColor
              @pixloop:
                mov ax, [esi].word
                add esi, 2

                cmp ax, 0
                JE  @@Next

                and ax, dx
                mov [edi], ax
              @@Next:
                add edi, 2

                dec ecx
                jnz @pixloop

                pop edx
                pop ebx
                pop edi
                pop esi
              end;
              Inc(nY);
            end;
            Inc(X, nFontWidth + kerning);
          end;
        end;
      finally
        UnLock;
      end;
    end;
  end;
end;

procedure TDXTexture.Draw(X, Y: Integer; SrcRect: TRect; Source: TDXTexture; DrawMode: TDrawMode);
begin
  case DrawMode of
    dmNone:
      Draw(x, y, SrcRect, Source, False);
    dmDefault:
      Draw(x, y, SrcRect, Source, True);
    dmAnti:
      Draw(x, y, SrcRect, Source, fxAnti);
    dmColorAdd:   {颜色加?}
      Draw(x, y, SrcRect, Source, Blend_SrcColor);
  else
    Draw(x, y, SrcRect, Source, True);
  end;
end;

{ TDXImageTexture }
constructor TDXImageTexture.Create(DrawCanvas: TObject);
begin
  inherited Create(DrawCanvas);
  FFormat := D3DFMT_A1R5G5B5;
  FBehavior := tbManaged;
end;

function TDXImageTexture.ClientRect: TRect;
begin
  Result.Left := 0;
  Result.Top := 0;
  Result.Right := FPatternSize.X;
  Result.Bottom := FPatternSize.Y;
end;

function TDXImageTexture.Width: Integer;
begin
  Result := FPatternSize.X;
end;

function TDXImageTexture.Height: Integer;
begin
  Result := FPatternSize.Y;
end;

{ TDXRenderTargetTexture }
constructor TDXRenderTargetTexture.Create(DrawCanvas: TObject);
begin
  inherited;
  FTarget := nil;
end;

destructor TDXRenderTargetTexture.Destroy;
begin
  FTarget := nil;
  FTexture := nil;
  inherited;
end;

procedure TDXRenderTargetTexture.Lost;
begin
  FTexture := nil;
end;

procedure TDXRenderTargetTexture.Recovered;
begin
  if FTarget <> nil then
    FTexture := FTarget.GetTexture;
end;

function TDXRenderTargetTexture.GetActive: Boolean;
begin
  Result := (FTarget <> nil) and (FTexture <> nil);
end;

procedure TDXRenderTargetTexture.SetActive(const Value: Boolean);
begin
  if Value then
    MakeReady
  else
    MakeNotReady;
end;

function TDXRenderTargetTexture.MakeReady: Boolean;
begin
  Result := False;
  if FTarget = nil then
  begin
    FTarget := FHGE.Target_Create(FSize.X, FSize.Y, False);
    if FTarget <> nil then
    begin
      FTexture := FTarget.GetTexture;
      if FTexture <> nil then
      begin
        FPatternSize.X := FSize.X;
        FPatternSize.Y := FSize.Y;
        FSize.X := FTexture.GetWidth();
        FSize.Y := FTexture.GetHeight();
      end;
    end;
    Result := (FTarget <> nil) and (FTexture <> nil);
  end;
end;

procedure TDXRenderTargetTexture.MakeNotReady;
begin
  FTarget := nil;
end;

initialization
  FHGE := nil;

finalization
  FHGE := nil;

end.

