{*****************************************************************************
字体单元
*****************************************************************************}


unit HGEFont;

interface
uses
  System.Classes, System.SysUtils, System.Math, System.UITypes, System.Generics.Collections,
  Winapi.Windows, Winapi.Direct3D9,
  Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls,
  HGE, HGEBase, HGETextures, HGESprite;

type
  TBugTextOut = procedure(Msg: string);

  pTFontText = ^TFontText;
  TFontText = packed record
    Font: TDXTexture;
    Text: string[1];
    Time: LongWord;
    Name: TFontName;
    Size: Integer;
    Style: TFontStyles;
    FColor: TColor;
    Bcolor: TColor;
  end;

  //Edit控件使用
  TFontEngine = class(TObject)
  private
    FFontTextList: TThreadList;
    FOwnerForm: TForm;
    FreeOutTimeTick: LongWord;
    FTimer: TTimer;
    procedure FreeOutTime;
    procedure TimerEvent(Sender: TObject);
  public
    constructor Create(Source: TForm);
    destructor Destroy; override;
    procedure Clear;
    function GetHeight(): Integer;
    function TextHeight(const Text: string): Integer;
    function TextWidth(const Text: string): Integer;
    function GetTextDIB(Text: string; FColor: TColor; BColor: TColor): TDXTexture;

    property OwnerForm: TForm read FOwnerForm;
    property FontTextList: TThreadList read FFontTextList write FFontTextList;
  end;

var
  BugTextOut: TBugTextOut = nil;

implementation

procedure TextOutFile(Msg: string);
begin
  if @BugTextOut <> nil then
    BugTextOut(Msg);
end;

{ TFontTextEngine }

constructor TFontEngine.Create(Source: TForm);
begin
  FOwnerForm := Source;
  FFontTextList := TThreadList.Create;
  FreeOutTimeTick := GetTickCount;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1000;
  FTimer.OnTimer := TimerEvent;
end;

destructor TFontEngine.Destroy;
begin
  Clear;
  FTimer.Free;
  FFontTextList.Free;
  FOwnerForm := nil;
  inherited;
end;

procedure TFontEngine.Clear;
var
  i: Integer;
  FontText: pTFontText;
begin
  with FFontTextList.LockList do
  begin
    try
      for i := 0 to Count - 1 do begin
        FontText := Items[i];
        FontText.Font.Free;
        Dispose(FontText); //手动释放内存
      end;
      Clear;
    finally
      FFontTextList.UnlockList;
    end;
  end;
end;

procedure TFontEngine.FreeOutTime;
var
  i: Integer;
  FontText: pTFontText;
begin
  if (GetTickCount - FreeOutTimeTick > 1000 * 10) then begin
    FreeOutTimeTick := GetTickCount;

    with FFontTextList.LockList do
    begin
      try
        for i := Count - 1 downto 0 do begin
          FontText := Items[i];
          if (GetTickCount - FontText.Time > 1000 * 60 * 2) then begin
            Delete(i);

            try
              FontText.Font.Free;
            except
              TextOutFile('FreeOutTimeTick1');
            end;

            try
              Dispose(FontText);
            except
              TextOutFile('FreeOutTimeTick2');
            end;
          end;
        end;
      finally
        FontTextList.UnlockList;
      end;
    end;
  end;
end;

function TFontEngine.TextWidth(const Text: string): Integer;
var
  HHDC: hdc;
  tempDC: hdc;
  Point: Size;
begin
 // 创建兼容DC并选入字体          TextWidth(Text), DIB.TextHeight
  tempDC := GetDC(FOwnerForm.Handle);
  HHDC := CreateCompatibleDC(tempDC);
  Winapi.Windows.SelectObject(HHDC, FOwnerForm.Canvas.Font.Handle);
  Winapi.Windows.GetTextExtentPoint32(HHDC, PChar(Text), Length(Text), Point);
  Result := Point.cx;
  DeleteDC(HHDC);
  ReleaseDC(0, tempDC);
end;

procedure TFontEngine.TimerEvent(Sender: TObject);
begin
  try
    //使用内部定时器释放
    FreeOutTime;
  except
    TextOutFile('FreeOutTime');
  end;
end;

function TFontEngine.TextHeight(const Text: string): Integer;
var
  HHDC: hdc;
  tempDC: hdc;
  Point: Size;
begin
 // 创建兼容DC并选入字体          TextWidth(Text), DIB.TextHeight
  tempDC := GetDC(FOwnerForm.Handle);
  HHDC := CreateCompatibleDC(tempDC);
  Winapi.Windows.SelectObject(HHDC, FOwnerForm.Canvas.Font.Handle);
  Winapi.Windows.GetTextExtentPoint32(HHDC, PChar(Text), Length(Text), Point);
  Result := Point.cy;
  DeleteDC(HHDC);
  ReleaseDC(0, tempDC);
end;

function TFontEngine.GetHeight: Integer;
begin
  Result := TextHeight('0');
end;

function TFontEngine.GetTextDIB(Text: string; FColor: TColor; BColor: TColor): TDXTexture;
var
  i: Integer;
  FontText: pTFontText;
begin
  Result := nil;
  if FColor = clBlack then FColor := $00050505;

  with FFontTextList.LockList do
  begin
    try
      for i := 0 to Count - 1 do begin
        FontText := Items[i];
        if (CompareStr(FontText.Text, Text) = 0) and
          (CompareText(FOwnerForm.Canvas.Font.Name, FontText.Name) = 0) and
          (FOwnerForm.Canvas.Font.Size = FontText.Size) and
          (FOwnerForm.Canvas.Font.Style = FontText.Style) and
          (FColor = FontText.FColor) and
          (BColor = FontText.BColor) then begin
          FontText.Time := GetTickCount;
          Result := FontText.Font;
          Exit;
        end;
      end;
    finally
      FFontTextList.UnlockList;
    end;
  end;
end;

end.
