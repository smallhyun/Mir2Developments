unit DrawScrn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IntroScn, Actor, HUtil32, HGETextures;

const
  MAXSYSLINE = 8;
  BOTTOMBOARD = 1;
  VIEWCHATLINE = 9;
  AREASTATEICONBASE = 150;
  HEALTHBAR_BLACK = 0;
  HEALTHBAR_RED = 1;
  HEALTHBAR_BLUE = 10;

type
  TDrawScreen = class
  private
    frametime, framecount, drawframecount: longword;
    SysMsg: TStringList;
  public
    CurrentScene: TScene;
    ChatStrs: TStringList;
    ChatBks: TList;
    ChatBoardTop: integer;
    HintList: TStringList;
    HintX, HintY, HintWidth, HintHeight: integer;
    HintUp: Boolean;
    HintColor: TColor;
    constructor Create;
    destructor Destroy; override;
    procedure KeyPress(var Key: Char);
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Initialize;
    procedure Finalize;
    procedure ChangeScene(scenetype: TSceneType);
    procedure DrawScreen(MSurface: TDXTexture);
    procedure DrawScreenTop(MSurface: TDXTexture);
    procedure AddSysMsg(msg: string);
    procedure AddChatBoardString(str: string; fcolor, bcolor: integer);
    procedure ClearChatBoard;
    procedure ShowHint(x, y: integer; str: string; color: TColor; drawup: Boolean);
    procedure ClearHint(boClear: Boolean);
    procedure DrawHint(MSurface: TDXTexture);
  end;

implementation

uses
  ClMain, MShare;

constructor TDrawScreen.Create;
var
  i: integer;
begin
  CurrentScene := nil;
  frametime := GetTickCount;
  framecount := 0;
  SysMsg := TStringList.Create;
  ChatStrs := TStringList.Create;
  ChatBks := TList.Create;
  ChatBoardTop := 0;

  HintList := TStringList.Create;

end;

destructor TDrawScreen.Destroy;
begin
  SysMsg.Free;
  ChatStrs.Free;
  ChatBks.Free;
  HintList.Free;
  inherited Destroy;
end;

procedure TDrawScreen.Initialize;
begin
end;

procedure TDrawScreen.Finalize;
begin
end;

procedure TDrawScreen.KeyPress(var Key: Char);
begin
  if CurrentScene <> nil then
    CurrentScene.KeyPress(Key);
end;

procedure TDrawScreen.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if CurrentScene <> nil then
    CurrentScene.KeyDown(Key, Shift);
end;

procedure TDrawScreen.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if CurrentScene <> nil then
    CurrentScene.MouseMove(Shift, X, Y);
end;

procedure TDrawScreen.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if CurrentScene <> nil then
    CurrentScene.MouseDown(Button, Shift, X, Y);
end;

procedure TDrawScreen.ChangeScene(scenetype: TSceneType);
begin
  if CurrentScene <> nil then
    CurrentScene.CloseScene;
  case scenetype of
    stIntro:
      CurrentScene := IntroScene;
    stLogin:
      CurrentScene := LoginScene;
    stSelectCountry:
      ;
    stSelectChr:
      CurrentScene := SelectChrScene;
    stNewChr:
      ;
    stLoading:
      ;
    stLoginNotice:
      CurrentScene := LoginNoticeScene;
    stPlayGame:
      CurrentScene := PlayScene;
  end;
  if CurrentScene <> nil then
    CurrentScene.OpenScene;
end;
//���ϵͳ��Ϣ

procedure TDrawScreen.AddSysMsg(msg: string);
begin
  if SysMsg.Count >= 10 then
    SysMsg.Delete(0);
  SysMsg.AddObject(msg, TObject(GetTickCount));
end;
//�����Ϣ�����

procedure TDrawScreen.AddChatBoardString(str: string; fcolor, bcolor: integer);
var
  i, len, aline, BOXWIDTH: integer;
  dline, temp: string;
begin
  if g_FScreenWidth = 1024 then BOXWIDTH := 374 + 224
  else BOXWIDTH := 374;
  len := Length(str);
  temp := '';
  i := 1;
  while TRUE do
  begin
    if i > len then
      break;
    if byte(str[i]) >= 128 then
    begin
      temp := temp + str[i];
      Inc(i);
      if i <= len then
        temp := temp + str[i]
      else
        break;
    end
    else
      temp := temp + str[i];

    aline := FrmMain.Canvas.TextWidth(temp);
    if aline > BOXWIDTH then
    begin
      ChatStrs.AddObject(temp, TObject(fcolor));
      ChatBks.Add(Pointer(bcolor));
      str := Copy(str, i + 1, len - i);
      temp := '';
      break;
    end;
    Inc(i);
  end;

  if temp <> '' then
  begin
    ChatStrs.AddObject(temp, TObject(fcolor));
    ChatBks.Add(Pointer(bcolor));
    str := '';
  end;
  if ChatStrs.Count > 200 then
  begin
    ChatStrs.Delete(0);
    ChatBks.Delete(0);
    if ChatStrs.Count - ChatBoardTop < VIEWCHATLINE then
      Dec(ChatBoardTop);
  end
  else if (ChatStrs.Count - ChatBoardTop) > VIEWCHATLINE then
  begin
    Inc(ChatBoardTop);
  end;

  if str <> '' then
    AddChatBoardString(' ' + str, fcolor, bcolor);

end;
//������ĳ����Ʒ����ʾ����Ϣ

procedure TDrawScreen.ShowHint(x, y: integer; str: string; color: TColor; drawup: Boolean);
var
  data: string;
  w, h: integer;
begin
  ClearHint(True);
  HintX := x;
  HintY := y;
  HintWidth := 0;
  HintHeight := 0;
  HintUp := drawup;
  HintColor := color;
  while TRUE do
  begin
    if str = '' then
      break;
    str := GetValidStr3(str, data, ['\']);
    w := FrmMain.Canvas.TextWidth(data) + 4{�հ�}  * 2;
    if w > HintWidth then
      HintWidth := w;
    if data <> '' then
      HintList.Add(data)
  end;

  HintHeight := (FrmMain.Canvas.TextHeight('A') + 1) * HintList.Count + 3{�հ�}  * 2;
  if HintUp then
    HintY := HintY - HintHeight;
end;
//���������ĳ����Ʒ����ʾ����Ϣ

procedure TDrawScreen.ClearHint(boClear: Boolean);
begin
  if boClear then
  begin
    HintList.Clear;
  end;
end;

procedure TDrawScreen.ClearChatBoard;
begin
  SysMsg.Clear;
  ChatStrs.Clear;
  ChatBks.Clear;
  ChatBoardTop := 0;
end;

procedure TDrawScreen.DrawScreen(MSurface: TDXTexture);

  procedure NameTextOut(surface: TDXTexture; x, y, fcolor, bcolor: integer; namestr: string);
  var
    i, row: integer;
    nstr: string;
  begin
    row := 0;
    for i := 0 to 10 do
    begin
      if namestr = '' then
        break;
      namestr := GetValidStr3(namestr, nstr, ['\']);
//         BoldTextOut (surface,
//                      x - surface.Canvas.TextWidth(nstr) div 2,
//                      y + row * 12,
//                      fcolor, bcolor, nstr);

      g_DXCanvas.TextOut(x - g_DXCanvas.TextWidth(nstr) div 2, y + row * 12, nstr, fcolor);
      Inc(row);
    end;
  end;

var
  i, k, line, sx, sy, fcolor, bcolor: integer;
  actor: TActor;
  str, uname: string;
  dsurface: TDXTexture;
  d: TDXTexture;
  rc: TRect;
  infoMsg: string;
begin
  // MSurface.Fill(0);
  if CurrentScene <> nil then
    CurrentScene.PlayScene(MSurface);

  if GetTickCount - frametime > 1000 then
  begin
    frametime := GetTickCount;
    drawframecount := framecount;
    framecount := 0;
  end;
  Inc(framecount);


   //SetBkMode (MSurface.Canvas.Handle, TRANSPARENT);
   //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, 'c1 ' + IntToStr(DebugColor1));
   //BoldTextOut (MSurface, 0, 20, clWhite, clBlack, 'c2 ' + IntToStr(DebugColor2));
   //BoldTextOut (MSurface, 0, 40, clWhite, clBlack, 'c3 ' + IntToStr(DebugColor3));
   //BoldTextOut (MSurface, 0, 60, clWhite, clBlack, 'c4 ' + IntToStr(DebugColor4));
   //MSurface.Canvas.Release;


  if Myself = nil then
    exit;

  if CurrentScene = PlayScene then
  begin
    with MSurface do
    begin
         //ͷ����ʾѪ�����
      with PlayScene do
      begin
        for k := 0 to ActorList.Count - 1 do
        begin
          actor := ActorList[k];
//               //������Ѫ  ȫ������������Ѫ���� (Actor.Bo_OpenHealth) and
               if (Actor.Bo_OpenHealth) and (Actor.Abil.MaxHP > 1) and not Actor.Death then begin
                 infoMsg := IntToStr(Actor.Abil.HP) + '/' + IntToStr(Actor.Abil.MaxHP);

                  g_DXCanvas.TextOut (Actor.SayX - {15}g_DXCanvas.TextWidth(infoMsg) div 2, Actor.SayY - 23, infoMsg, clWhite);
               end;

          Actor.BoOpenHealth := True; //��ʾѪ�� True,
          if (actor.BoOpenHealth or actor.BoInstanceOpenHealth) and not actor.Death then
          begin
            if actor.BoInstanceOpenHealth then
              if GetTickCount - actor.OpenHealthStart > actor.OpenHealthTime then
                actor.BoInstanceOpenHealth := FALSE;
            d := WProgUse2.Images[HEALTHBAR_BLACK];
            if d <> nil then
              MSurface.Draw(actor.SayX - d.Width div 2, actor.SayY - 10, d.ClientRect, d, TRUE);
            if actor.Race = 0 then
             d := WProgUse2.Images[HEALTHBAR_BLUE] //�������
            else
            d := WProgUse2.Images[HEALTHBAR_RED];

            if actor.Race in [12,24,50] then //�󵶣�������NPC
             d := WProgUse2.Images[10]      //NPCͷ��Ѫ��ͼƬ
            else
            d := WProgUse2.Images[HEALTHBAR_RED];

            if d <> nil then
            begin
              rc := d.ClientRect;
              if actor.Abil.MaxHP > 0 then
                rc.Right := _MIN(Round((rc.Right - rc.Left) / actor.Abil.MaxHP * actor.Abil.HP), d.Width);
              MSurface.Draw(actor.SayX - d.Width div 2, actor.SayY - 10, rc, d, TRUE);
            end;


          end;
        end;
      end;

        if g_boShowName then begin
          with PlayScene do begin
            for k := 0 to ActorList.Count - 1 do begin
              Actor := ActorList[k];
              if (Actor <> nil)  and (not Actor.Death) and
                (Actor.SayX <> 0) and (Actor.SayY <> 0) and ((actor.Race = 0) or (actor.Race = 1) or (actor.Race = 50)) then begin
                  if (Actor <> FocusCret) then begin

                    if (actor = MySelf) and boSelectMyself then Continue;
                      uname := Actor.UserName;
                      NameTextOut(MSurface,
                        Actor.SayX, // - Canvas.TextWidth(uname) div 2,
                        Actor.SayY + 30,
                        Actor.NameColor, ClBlack,
                        uname);
                  end;
                end;
            end;
          end;
        end;

         //����ǰѡ�����Ʒ/���������
      if (FocusCret <> nil) and PlayScene.IsValidActor(FocusCret) then
      begin

        if FocusCret.Race = 95 then
        begin
          if FocusCret.Death then
            FocusCret.UserName := '�ƹ���'
          else
            FocusCret.UserName := '���⳪��';
        end
        else if FocusCret.Race = 96 then
          FocusCret.UserName := '';

        uname := FocusCret.DescUserName + '\' + FocusCret.UserName;
        if (FocusCret.Race = 50) and (FocusCret.Appearance = 57) then
          uname := '';

        NameTextOut(MSurface, FocusCret.SayX, // - Canvas.TextWidth(uname) div 2,
          FocusCret.SayY + 30, FocusCret.NameColor, clBlack, uname);
      end;
      if BoSelectMyself then
      begin
        uname := Myself.DescUserName + '\' + Myself.UserName;
        NameTextOut(MSurface, Myself.SayX, // - Canvas.TextWidth(uname) div 2,
          Myself.SayY + 30, Myself.NameColor, clBlack, uname);
      end;

//         Canvas.Font.Color := clWhite;

         //��ʾ��ɫ˵������
      with PlayScene do
      begin
        for k := 0 to ActorList.Count - 1 do
        begin
          actor := ActorList[k];
          if actor.Saying[0] <> '' then
          begin
            if GetTickCount - actor.SayTime < 4 * 1000 then
            begin
              for i := 0 to actor.SayLineCount - 1 do
                if actor.Death then
                           //�������˵������ɫ��ͷ���ϵ�������ɫ��
                  g_DXCanvas.TextOut(actor.SayX - (actor.SayWidths[i] div 2), actor.SayY - (actor.SayLineCount * 16) + i * 14, actor.Saying[i], clGray)
                else
                           //��������������˵������ɫ��ͷ���ϵ�������ɫ
                  g_DXCanvas.TextOut(actor.SayX - (actor.SayWidths[i] div 2), actor.SayY - (actor.SayLineCount * 16) + i * 14, actor.Saying[i], clWhite);
            end
            else
              actor.Saying[0] := ''; //˵�Ļ���ʾ4��
          end;
        end;
      end;

         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, IntToStr(SendCount) + ' : ' + IntToStr(ReceiveCount));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, 'HITSPEED=' + IntToStr(Myself.HitSpeed));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, 'DupSel=' + IntToStr(DupSelection));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, IntToStr(LastHookKey));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack,
         //             IntToStr(
         //                int64(GetTickCount - LatestSpellTime) - int64(700 + MagicDelayTime)
         //                ));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, IntToStr(PlayScene.EffectList.Count));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack,
         //                  IntToStr(Myself.XX) + ',' + IntToStr(Myself.YY) + '  ' +
         //                  IntToStr(Myself.ShiftX) + ',' + IntToStr(Myself.ShiftY));

         //System Message
         //��������(��ʱ)
      if (AreaStateValue and $04) <> 0 then
      begin
        g_DXCanvas.TextOut(0, 0, '��������', clWhite);
      end;

//         Canvas.Release;

         //��ʾ��ͼ״̬
      k := 0;
      for i := 0 to 15 do
      begin
        if AreaStateValue and ($01 shr i) <> 0 then
        begin
          d := WProgUse.Images[AREASTATEICONBASE + i];  //FIGHT��ʾս��ͼƬ
          if d <> nil then
          begin
            k := k + d.Width;
            MSurface.Draw(g_FScreenWidth - k, 0, d.ClientRect, d, TRUE);
          end;
        end;
      end;
      // SAFE��ʾ��ȫͼƬ
        if AreaStateValue = 2 then
        begin
         d := WProgUse.Images[AREASTATEICONBASE + 1];
          if d <> nil then
          begin
            k := k + d.Width;
            MSurface.Draw(g_FScreenWidth - k, 0, d.ClientRect, d, TRUE);
          end;
        end;
    end;
  end;
end;
//��ʾ���Ͻ���Ϣ����

procedure TDrawScreen.DrawScreenTop(MSurface: TDXTexture);
var
  i, sx, sy: integer;
  TempMsg: string;
begin
  if Myself = nil then
    exit;

  if CurrentScene = PlayScene then
  begin
    with MSurface do
    begin
       //  SetBkMode (Canvas.Handle, TRANSPARENT);
      if SysMsg.Count > 0 then
      begin
        sx := 30;
        sy := 40;
        for i := 0 to SysMsg.Count - 1 do
        begin
          if Copy(SysMsg[i], 1, 8) = 'clYellow' then
          begin
            TempMsg := Copy(SysMsg[i], 9, Length(SysMsg[i]) - 8);
                //  BoldTextOut (MSurface, sx, sy, clYellow, clBlack, TempMsg);
            g_DXCanvas.TextOut(sx, sy, TempMsg, clYellow);
          end
          else
                //  BoldTextOut (MSurface, sx, sy, clGreen, clBlack, SysMsg[i]);
            g_DXCanvas.TextOut(sx, sy, SysMsg[i], clGreen);
          inc(sy, 16);
        end;
        if GetTickCount - longword(SysMsg.Objects[0]) >= 3000 then
          SysMsg.Delete(0);
      end;
        // Canvas.Release;
    end;
  end;

end;
//��ʾ��ʾ��Ϣ

procedure TDrawScreen.DrawHint(MSurface: TDXTexture);
var
  d: TDXTexture;
  i, hx, hy, old: integer;
  str: string;
  HITNTTRect: TRect;
begin
  if HintList.Count > 0 then
  begin
    d := WProgUse.Images[394];
    if d <> nil then
    begin
      if HintWidth > d.Width then
        HintWidth := d.Width;
      if HintHeight > d.Height then
        HintHeight := d.Height;
      if HintX + HintWidth > g_FScreenWidth then
        hx := g_FScreenWidth - HintWidth
      else
        hx := HintX;
      if HintY < 0 then
        hy := 0
      else
        hy := HintY;
      if hx < 0 then
        hx := 0;

      HITNTTRect.Left := 0;
      HITNTTRect.Top := 0;
      HITNTTRect.Right := HintWidth;
      HITNTTRect.Bottom := HintHeight;


      //   DrawBlendEx (MSurface, hx, hy, d, 0, 0, HintWidth, HintHeight, 0);
      DrawBlendR(MSurface, hx, hy, HITNTTRect, d, 0);
    end;
  end;
  with g_DXCanvas do
  begin
//      SetBkMode (Canvas.Handle, TRANSPARENT);
    if HintList.Count > 0 then
    begin
      for i := 0 to HintList.Count - 1 do
      begin
        LineTo(hx+4, hy+3+(TextHeight('A')+1)*i, HintColor);     //���ָ����水ť��ʾ����ģ����ʾ
       // g_DXCanvas.TextOut(hx + 4, hy + 3 + (TextHeight('A') + 1) * i, HintColor, HintList[i]);
      end;
    end;

    if Myself <> nil then
    begin
{         if CheckBadMapMode then begin
              str := IntToStr(drawframecount) +  ' '
              + '  Mouse ' + IntToStr(MouseX) + ':' + IntToStr(MouseY) + '(' + IntToStr(MCX) + ':' + IntToStr(MCY) + ')'
              + '  HP' + IntToStr(Myself.Abil.HP) + '/' + IntToStr(Myself.Abil.MaxHP)
              + '  D0 ' + IntToStr(DebugCount)
              + ' D1 ' + IntToStr(DebugCount1) + ' D2 '
              + IntToStr(DebugCount2);
         end;}
        // BoldTextOut (MSurface, 10, 0, clWhite, clBlack, str);
      TextOut(10, 0, str, clWhite);
         //old := Canvas.Font.Size;
         //Canvas.Font.Size := 8;
         //BoldTextOut (MSurface, 8, SCREENHEIGHT-42, clWhite, clBlack, ServerName);
      if EffectNum = 3 then
          //  BoldTextOut (MSurface, 14, SCREENHEIGHT-16, clWhite, clBlack, MapTitle )
        TextOut(8, g_FScreenHeight - 16, MapTitle, clWhite)
      else
        TextOut(8, g_FScreenHeight - 16, MapTitle + ' ' + IntToStr(Myself.XX) + ':' + IntToStr(Myself.YY), clWhite);    //���½ǵ�ͼ����λ��
//            BoldTextOut (MSurface, 14, SCREENHEIGHT-16, clWhite, clBlack, MapTitle + ' ' + IntToStr(Myself.XX) + ':' + IntToStr(Myself.YY));
         //Canvas.Font.Size := old;
    end;
      //BoldTextOut (MSurface, 10, 20, clWhite, clBlack, IntToStr(DebugCount) + ' / ' + IntToStr(DebugCount1));

//      Canvas.Release;
  end;

end;

end.

