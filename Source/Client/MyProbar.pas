unit MyProbar;

interface

uses
  Windows, Messages, SysUtils, Graphics, ExtCtrls ,Classes;

type
  Imagebar = class
    _img: TImage;
    SourceBmp, NextBmp: TBitmap;
    _height: Integer;
    _width: Integer;
  protected
  public
    constructor Create(pimg: TImage);
    destructor destroy; override;
    procedure Change(pmax, pmin: Int64);
  end;

implementation

constructor Imagebar.Create(pimg: TImage);
begin
  inherited Create;
  _img := pimg;
  _height := _img.Picture.Bitmap.Height;
  _width := _img.Picture.Bitmap.Width;
  SourceBmp := TBitmap.Create;
  SourceBmp.Height := _height;
  SourceBmp.Width := _width;
  BitBlt(SourceBmp.Canvas.Handle, 0, 0, _width, _height, _img.Canvas.Handle, 0, 0, SRCCOPY);
  NextBmp := TBitmap.Create;
end;

destructor Imagebar.destroy;
begin
  inherited;
  FreeAndNil(SourceBmp);
  FreeAndNil(NextBmp);
end;

procedure Imagebar.Change(pmax, pmin: Int64);

  function GetPosition(iMax, iMin: Int64): Int64;
  begin
    if iMax > iMin then
      Result := trunc((iMin / iMax) * 100)
    else
      Result := 100;
  end;

var
  Postion: Int64;
  Nextwidth: Integer;
begin
  Postion := GetPosition(pmax, pmin);
  Nextwidth := trunc((Postion / 100) * _width);
  if Nextwidth > 10 then begin
    NextBmp.Height := _height;
    NextBmp.Width := Nextwidth;
    BitBlt(NextBmp.Canvas.Handle, 0, 0, Nextwidth - 5, _height, SourceBmp.Canvas.Handle, 0, 0, SRCCOPY);
    BitBlt(NextBmp.Canvas.Handle, Nextwidth - 5, 0, 5, _height, SourceBmp.Canvas.Handle, _width - 5, 0, SRCCOPY);
    with _img do begin
      Width := Nextwidth;
      Height := _height;
      Picture.Bitmap := NextBmp;
      Repaint;
    end;
  end;

end;



end.
