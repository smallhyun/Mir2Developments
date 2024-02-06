Unit HGEImage;

Interface

uses
  Windows, SysUtils, StrUtils, Graphics, math, HGE, WilPion;

Type

  THGEEIImages = Class
  Private
    Image: ITexture;
  Public
    Quad: THGEQuad;
    PWidth: Integer;
    PHeight: Integer;
    TexWidth: Integer;
    TexHeight: Integer;
    ClientRect: TRect;
    Constructor Create();
    Destructor Destroy(); Override;
    Procedure LoadFromBits(Bits: Array Of word; width, Height: integer; Transparent: Boolean; TransparentColor: Word; px: Integer = 0; py: integer = 0); Overload;
    Procedure LoadFromBits(Bits: Array Of byte; MainPalette: TRgbQuads; width, Height: integer; Transparent: Boolean; TransparentColor: Word; px: Integer = 0; py: integer = 0); Overload;
    Function GetPixels(x, y: integer): LongWord;
    Procedure ColorToGray(Out Tmp: Itexture);
    Procedure LoadFromITexture(Images: Itexture; width, Height: integer; px: Integer = 0; py: integer = 0);
    Procedure ChangeColor(Out Tmp: Itexture; R, G, B: Byte);
    Procedure LoadFromBitmap(bitmap: Tbitmap; Transparent: Boolean = true);

  End;

Implementation
Var
  HGE               : IHGE = Nil;

Constructor THGEEIImages.Create();
Begin

  HGE := HGECreate(HGE_VERSION);
End;

Destructor THGEEIImages.Destroy();
Begin
  Inherited;
End;

Procedure THGEEIImages.ChangeColor(Out Tmp: Itexture; R, G, B: Byte); //变色
Var
  OldColP           : PLongWord;
  TmpColP           : PLongWord;
  I, J              : Integer;
  R1, G1, B1, A1    : byte;
Begin
  If Image <> Nil Then
  Begin
    tmp := HGE.Texture_Create(self.TexWidth, Self.TexHeight);
    OldColP := Image.Lock(False);
    TmpColP := tmp.Lock(true);
    For I := 0 To PHeight - 1 Do
    Begin
      For J := 0 To PWidth - 1 Do
      Begin
        If OldColP^ = 0 Then
        Begin
          Inc(OldColP);
          Inc(tmpColP);
          Continue;
        End;
        R1 := GetR(OldColP^);
        G1 := GetG(OldColP^);
        B1 := GetB(OldColP^);
        If (R1 < 128) Or (G1 < 128) Or (B1 < 128) Then
        Begin
          TmpColp^ := OldColP^;
          Inc(OldColP);
          Inc(tmpColP);
          Continue;
        End;
        A1 := GetA(OldColP^);
        If (abs(R1 - G1) In [0..15]) And (abs(G1 - B1) In [0..15]) Then
        Begin
          TmpColp^ := ARGB(A1, R, G, B);
          Inc(OldColP);
          Inc(tmpColP);
        End
        Else
        Begin
          TmpColp^ := OldColP^;
          Inc(OldColP);
          Inc(tmpColP);
        End;
      End;
      Inc(OldColP, TexWidth - pWidth);
      Inc(TmpColP, TexWidth - pWidth);
    End;
    Image.Unlock;
    tmp.Unlock;
  End;
End;

Procedure THGEEIImages.LoadFromBitmap(bitmap: Tbitmap; Transparent: Boolean);
Var
  i, y, w, h        : integer;
  OldColP           : PLongWord;
  r, b, g           : byte;
  c                 : Tcolor;
Begin
  w := 1 Shl ceil(log2(bitmap.Width));  //计算2的N次幂大小，做为纹理大小
  h := 1 Shl ceil(log2(bitmap.Height));
  Image := HGE.Texture_Create(w, h);
  TexWidth := w;
  TexHeight := h;
  OldColP := Image.Lock(false);
  For i := 0 To bitmap.height - 1 Do
  Begin
    For y := 0 To bitmap.width - 1 Do
    Begin
      c := bitmap.canvas.Pixels[y, i];
      If Transparent Then
      Begin
        If c = 0 Then
        Begin
          OldColP^ := $00000000;
        End
        Else
        Begin
          r := getrvalue(c);
          g := getgvalue(c);
          b := getbvalue(c);
          OldColP^ := argb($FF, r, g, b);
        End;
      End
      Else
      Begin
        r := getrvalue(c);
        g := getgvalue(c);
        b := getbvalue(c);
        OldColP^ := argb($FF, r, g, b);
      End;
      inc(OldColP);
    End;
    Inc(OldColP, TexWidth - bitmap.Width);
  End;
  Image.Unlock;
  PWidth := bitmap.width;
  PHeight := bitmap.Height;
  Quad.Tex := Image;
  Quad.V[0].TX := 0; Quad.V[0].TY := 0; //left
  Quad.V[1].TX := PWidth / TexWidth; Quad.V[1].TY := 0; //right
  Quad.V[2].TX := PWidth / TexWidth; Quad.V[2].TY := PHeight / TexHeight; //rightbottom
  Quad.V[3].TX := 0; Quad.V[3].TY := pHeight / TexHeight; //leftbottom
  Quad.Blend := BLEND_DEFAULT;
  Quad.V[0].Col := $FFFFFFFF;
  Quad.V[1].Col := $FFFFFFFF;
  Quad.V[2].Col := $FFFFFFFF;
  Quad.V[3].Col := $FFFFFFFF;
  ClientRect.Left := 0;
  ClientRect.Top := 0;
  ClientRect.Right := PWidth;
  ClientRect.Bottom := PHeight;
End;

Procedure THGEEIImages.LoadFromITexture(Images: Itexture; width, Height: integer; px: Integer = 0; py: integer = 0); //传3
Begin
  Image := Images;
  TexWidth := Image.GetWidth();
  TexHeight := Image.GetHeight();
  PWidth := width;
  PHeight := Height;
  Quad.Tex := Image;
  Quad.V[3].TX := 0; Quad.V[3].TY := 0; //left
  Quad.V[2].TX := PWidth / TexWidth; Quad.V[2].TY := 0; //right
  Quad.V[1].TX := PWidth / TexWidth; Quad.V[1].TY := PHeight / TexHeight; //rightbottom
  Quad.V[0].TX := 0; Quad.V[0].TY := pHeight / TexHeight; //leftbottom
  Quad.Blend := BLEND_DEFAULT;
  Quad.V[0].Col := $FFFFFFFF;
  Quad.V[1].Col := $FFFFFFFF;
  Quad.V[2].Col := $FFFFFFFF;
  Quad.V[3].Col := $FFFFFFFF;
  ClientRect.Left := 0;
  ClientRect.Top := 0;
  ClientRect.Right := PWidth;
  ClientRect.Bottom := PHeight;
End;

Procedure THGEEIImages.ColorToGray(Out Tmp: ITexture);
Var
  OldColP           : PLongWord;
  TmpColP           : PLongWord;
  I, J              : Integer;
  g                 : byte;
Begin
  If Image <> Nil Then
  Begin
    tmp := HGE.Texture_Create(self.TexWidth, Self.TexHeight);
    OldColP := Image.Lock(False);
    TmpColP := tmp.Lock(true);
    For I := 0 To PHeight - 1 Do
    Begin
      For J := 0 To PWidth - 1 Do
      Begin
        If OldColP^ = 0 Then
        Begin
          Inc(OldColP);
          Inc(tmpColP);
          Continue;
        End
        Else
        Begin

          g := GetG(OldColp^);
          tmpColP^ := ARGB(255, g, g, g);
        End;
        Inc(OldColP);
        inc(tmpColP);
      End;
      Inc(OldColP, TexWidth - pWidth);
      Inc(TmpColP, TexWidth - pWidth);
    End;
    Image.Unlock;
    tmp.Unlock;
  End;
End;

Function THGEEIImages.GetPixels(x, y: integer): LongWord;
Var
  OldColP           : PLongWord;
Begin
  If Image <> Nil Then
  Begin
    If (x > PWidth) Or (x < 0) Then
    Begin Result := 0; exit; End;
    If (y > PHeight) Or (y < 0) Then
    Begin Result := 0; exit; End;
    OldColP := image.Lock(true);
    inc(OldColp, y * TexWidth + x);
    Result := OldColp^;
    Image.Unlock;
  End
  Else
  Begin
    Result := 0;
  End;
End;

Procedure THGEEIImages.LoadFromBits(Bits: Array Of word; width, Height: integer; Transparent: Boolean; TransparentColor: Word; px: Integer; py: integer);
Var
  i, y, w, h        : integer;
  OldColP           : PLongWord;
  NewCol            : Word;
Begin
  w := 1 Shl ceil(log2(Width));
  h := 1 Shl ceil(log2(Height));
  Image := HGE.Texture_Create(w, h);
  TexWidth := w;
  TexHeight := h;
  OldColP := Image.Lock(false);
  inc(OldColp, Py * TexWidth + Px);
  For i := height - 1 Downto 0 Do
  Begin
    For y := 0 To width - 1 Do
    Begin
      Newcol := bits[i * width + y];
      If Transparent Then
      Begin
        If NewCol = TransparentColor Then
        Begin
          OldColP^ := ARGB(0, 0, 0, 0);
        End
        Else
        Begin
          OldColP^ := ARGB(255, (NewCol And $F800) Shr 8, (NewCol And $7E0) Shr 3, (NewCol And $1F) Shl 3);
        End;
      End
      Else
      Begin
        OldColP^ := ARGB(255, (NewCol And $F800) Shr 8, (NewCol And $7E0) Shr 3, (NewCol And $1F) Shl 3);
      End;
      inc(OldColP);
    End;
    Inc(OldColP, TexWidth - Width);
  End;
  Image.Unlock;
  PWidth := width;
  PHeight := Height;
  Quad.Tex := Image;
  Quad.V[0].TX := 0; Quad.V[0].TY := 0;
  Quad.V[1].TX := PWidth / TexWidth; Quad.V[1].TY := 0;
  Quad.V[2].TX := PWidth / TexWidth; Quad.V[2].TY := PHeight / TexHeight;
  Quad.V[3].TX := 0; Quad.V[3].TY := pHeight / TexHeight;
  Quad.Blend := BLEND_DEFAULT;
  Quad.V[0].Col := $FFFFFFFF;
  Quad.V[1].Col := $FFFFFFFF;
  Quad.V[2].Col := $FFFFFFFF;
  Quad.V[3].Col := $FFFFFFFF;
  ClientRect.Left := 0;
  ClientRect.Top := 0;
  ClientRect.Right := PWidth;
  ClientRect.Bottom := PHeight;
End;

Procedure THGEEIImages.LoadFromBits(Bits: Array Of byte; MainPalette: TRgbQuads; width, Height: integer; Transparent: Boolean; TransparentColor: Word; px: Integer = 0; py: integer = 0);
Var
  i, y, w, h        : integer;
  OldColP           : PLongWord;
  NewCol            : Word;
  r, g, b           : byte;
Begin
  w := 1 Shl ceil(log2(Width));
  h := 1 Shl ceil(log2(Height));
  Image := HGE.Texture_Create(w, h);
  TexWidth := w;
  TexHeight := h;
  OldColP := Image.Lock(false);
  inc(OldColp, Py * TexWidth + Px);
  For i := height - 1 Downto 0 Do
  Begin
    For y := 0 To width - 1 Do
    Begin
      Newcol := bits[i * width + y];
      If Transparent Then
      Begin

        If NewCol = TransparentColor Then
        Begin
          OldColP^ := ARGB(0, 0, 0, 0);
        End
        Else
        Begin
          r := MainPalette[NewCol].rgbred;
          g := MainPalette[NewCol].rgbGreen;
          b := MainPalette[NewCol].rgbBlue;
          OldColP^ := ARGB(255, r, g, b);

        End;
      End
      Else
      Begin
        r := MainPalette[NewCol].rgbred;
        g := MainPalette[NewCol].rgbGreen;
        b := MainPalette[NewCol].rgbBlue;
        OldColP^ := ARGB(255, r, g, b);
      End;
      inc(OldColP);
    End;
    Inc(OldColP, TexWidth - Width);
  End;
  Image.Unlock;
  PWidth := width;
  PHeight := Height;
  Quad.Tex := Image;
  Quad.V[0].TX := 0; Quad.V[0].TY := 0;
  Quad.V[1].TX := PWidth / TexWidth; Quad.V[1].TY := 0;
  Quad.V[2].TX := PWidth / TexWidth; Quad.V[2].TY := PHeight / TexHeight;
  Quad.V[3].TX := 0; Quad.V[3].TY := pHeight / TexHeight;
  Quad.Blend := BLEND_DEFAULT;
  Quad.V[0].Col := $FFFFFFFF;
  Quad.V[1].Col := $FFFFFFFF;
  Quad.V[2].Col := $FFFFFFFF;
  Quad.V[3].Col := $FFFFFFFF;
  ClientRect.Left := 0;
  ClientRect.Top := 0;
  ClientRect.Right := PWidth;
  ClientRect.Bottom := PHeight;
End;

Initialization
  HGE := Nil;

End.
