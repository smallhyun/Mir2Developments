unit   ImgButton;   
    
  interface   
    
  uses   
      Windows,   Messages,   SysUtils,   Classes,   Graphics,   Controls,   Forms,   Dialogs;   
    
  type   
      TImgButton   =   class(TGraphicControl)   
      private   
          FGNormal:           TBitmap;   
          FGMouseDown:     TBitMap;   
          FGMouseUp:         TBitMap;   
          FGDisabled:       TBitMap;   
          tmpBitmap:         TBitMap;   
          FCaption:           AnsiString;   
          FShowCaption:   Boolean;   
          FModalResult:   TModalResult;   
          FFont:TFont;   
          procedure   SetGNormal(Value:   TBitMap);   
          procedure   SetGMouseDown(Value:   TBitMap);   
          procedure   SetGMouseUp(Value:   TBitMap);   
          procedure   SetGDisabled(Value:   TBitMap);   
          procedure   SetCaption(Value:AnsiString);   
          procedure   Resize(Sender:   TObject);   
          procedure   SetShowCaption(Value:Boolean);   
          procedure   DrawCaption;   
          procedure   SetFont(Value:TFont);   
      protected   
          procedure   paint;override;   
          procedure   MouseEnter(var   Msg:   TMessage);   message   CM_MOUSEENTER;   
          procedure   MouseLeave(var   Msg:   TMessage);   message   CM_MOUSELEAVE;   
          procedure   MouseDown(Button:   TMouseButton;   Shift:   TShiftState;   X,   Y:   Integer);   override;   
          procedure   MouseUp(Button:   TMouseButton;   Shift:   TShiftState;   X,   Y:   Integer);   override;   
      public   
          constructor   Create(AOwner:   TComponent);   override;   
          destructor   Destroy;   override;   
      published   
          property   PictureEnter:       TBitMap   read   FGMouseUp   write   SetGMouseUp;   
          property   PictureDown:         TBitMap   read   FGMouseDown   write   SetGMouseDown;   
          property   PictureNormal:               TBitMap   read   FGNormal   write   SetGNormal;   
          property   PictureDisable:           TBitMap   read   FGDisabled   write   SetGDisabled;   
          property   ModalResult:           TModalResult   read   FModalResult   write   FModalResult   default   0;   
          property   Caption:     AnsiString   read   FCaption   write   SetCaption;   
          property   ShowCaption:Boolean   read   FShowCaption   write   SetShowCaption;   
          property   Font:TFont   read   FFont   write   SetFont;   
          //property   Action;   
          //property   Anchors;   
          property   Enabled;   
          property   ParentShowHint;   
          property   PopupMenu;   
          property   ShowHint;   
          property   Visible;   
          property   OnClick;   
          property   OnDblClick;   
          property   OnMouseDown;   
          property   OnMouseMove;   
          property   OnMouseUp;   
      end;   
    
  procedure   Register;   
    
  implementation   
    
  procedure   Register;   
  begin   
      RegisterComponents('Standard',   [TImgButton]);   
  end;   
    
  {   TImgButton   }   
    
  constructor   TImgButton.Create(AOwner:   TComponent);   
  begin   
      inherited   Create(AOwner);   
      Width   :=   100;   
      Height   :=   100;   
      FGNormal         :=TBitMap.Create;   
      FGMouseDown   :=TBitMap.Create;   
      FGMouseUp       :=TBitMap.Create;   
      FGDisabled     :=TBitMap.Create;   
      tmpBitmap       :=TBitMap.Create;   
      //OnResize:=Resize;   
      With   Canvas.Font   do   begin   
          //Charset:=GB2312_CHARSET;   
          Color:=   clWindowText;   
          Height:=-12;   
          Name:='ËÎÌå';   
          Pitch:=fpDefault;   
          Size:=9;     
      end;   
      FFont:=Canvas.Font;   
  end;   
    
  destructor   TImgButton.Destroy;   
  begin   
      FGNormal.Free;   
      FGMouseDown.Free;   
      FGMouseUp.Free;   
      FGDisabled.Free;   
      tmpBitMap:=nil;   
      tmpBitmap.Free;   
      inherited   Destroy;   
  end;   
    
  procedure   TImgButton.paint;   
  const   
      XorColor   =   $00FFD8CE;   
  begin   
      with   Canvas   do   begin   
          if   (csDesigning   in   ComponentState)   then   begin   
              Pen.Style   :=   psDot;   
              Pen.Mode   :=   pmXor;   
              Pen.Color   :=   XorColor;   
              Brush.Style   :=   bsClear;   
              Rectangle(0,   0,   ClientWidth,   ClientHeight);   
          end;   
    
          if   not   Enabled   then   
              if   not   FGDisabled.Empty   then   
                  tmpBitmap:=   FGDisabled   
              else   
                  tmpBitMap:=FGNormal   
          else   
              tmpBitMap:=FGNormal;   
    
          Canvas.StretchDraw(ClientRect,   tmpBitmap);   
          DrawCaption;   
      end;   
  end;   
    
  procedure   TImgButton.SetGDisabled(Value:   TBitMap);   
  begin   
      FGDisabled.Assign(Value);   
      Invalidate;   
  end;   
    
  procedure   TImgButton.SetGMouseDown(Value:   TBitMap);   
  begin   
      FGMouseDown.Assign(Value);   
      Invalidate;   
  end;   
    
  procedure   TImgButton.SetGNormal(Value:   TBitMap);   
  begin   
      FGNormal.Assign(Value);   
      tmpBitmap:=   FGNormal;   
      Width:=FGNormal.Width;   
      Height:=FGNormal.Height;   
      Repaint;   
      Canvas.StretchDraw(ClientRect,   FGNormal);   
      Invalidate;   
  end;   
    
  procedure   TImgButton.SetGMouseUp(Value:   TBitMap);   
  begin   
      FGMouseUp.Assign(Value);   
      Invalidate;   
  end;   
    
  procedure   TImgButton.MouseDown(Button:   TMouseButton;   Shift:   TShiftState;   X,Y:   Integer);   
  begin   
      if   (x>0)   and   (x<Width)   and   (y>0)   and   (y<Height)   then   begin   
          if   button   =   mbLeft   then   begin   
              Repaint;   
              Canvas.StretchDraw(ClientRect,   FGMouseDown);   
              DrawCaption;   
          end;   
      end;   
      inherited;   
  end;   
    
  procedure   TImgButton.MouseEnter(var   Msg:   TMessage);   
  begin   
      if   Enabled   then   begin   
          Repaint;   
          Canvas.StretchDraw(ClientRect,   FGMouseUp);   
          DrawCaption;   
      end;   
  end;   
    
  procedure   TImgButton.MouseLeave(var   Msg:   TMessage);   
  begin   
      if   Enabled   then   begin   
          Repaint;   
          Canvas.StretchDraw(ClientRect,   FGNormal);   
          DrawCaption;   
      end;   
  end;   
    
  procedure   TImgButton.MouseUp(Button:   TMouseButton;   Shift:   TShiftState;   X,   
      Y:   Integer);   
  begin   
      if   (x>0)   and   (x<Width)   and   (y>0)   and   (y<Height)   then   begin   
          if   button   =   mbLeft   then   begin   
              Repaint;   
              Canvas.StretchDraw(ClientRect,   FGMouseUp);   
              DrawCaption;   
          end;   
      end;   
      inherited;   
  end;   
    
    
  procedure   TImgButton.Resize(Sender:   TObject);   
  begin   
      if   not   FGNormal.Empty   then   begin   
          Width:=FGNormal.Width;   
          Height:=FGNormal.Height;   
          DrawCaption;   
      end;   
  end;   
    
  procedure   TImgButton.SetCaption(Value:   AnsiString);   
  begin   
      FCaption:=Value;   
      DrawCaption;   
      Invalidate;   
  end;   
    
  procedure   TImgButton.DrawCaption;   
  var   
      x,y:integer;   
  begin   
      if   FShowCaption   then   begin   
          with   Canvas   do   begin   
              Brush.Style   :=   bsClear;   
              x:=Round((Width-TextWidth(Caption))/2);   
              y:=Round((Height-TextHeight(Caption))/2);   
              TextOut(x,y,Caption);   
          end;   
      end;   
  end;   
    
  procedure   TImgButton.SetShowCaption(Value:   Boolean);   
  begin   
      FShowCaption:=Value;   
      Invalidate;   
  end;   
    
  procedure   TImgButton.SetFont(Value:   TFont);   
  begin   
      FFont:=Value;   
      Canvas.Font:=Value;   
      Invalidate;   
  end;   
    
  end.  