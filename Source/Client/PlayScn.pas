unit PlayScn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IntroScn, Grobal2, HUtil32, Actor, HerbActor, AxeMon, SoundUtil, ClEvent, Wil,
  StdCtrls, clFunc, magiceff, extctrls, HGETextures;

const
  LONGHEIGHT_IMAGE = 35;
  FLASHBASE = 410;
  AAX = 16;
  SOFFX = 0;
  SOFFY = 0;
  LMX = 30;
  LMY = 26;
  MAXLIGHT = 5;
  LightFiles : array[0..MAXLIGHT] of string = (
     'Data\lig0a.dat',
     'Data\lig0b.dat',
     'Data\lig0c.dat',
     'Data\lig0d.dat',
     'Data\lig0e.dat',
     'Data\lig0f.dat'
  );
  LightSizes : array[0..MAXLIGHT] of integer = (
     34496,
     161280,
     327360,
     405920,
     542976,
     713632
  );
  LightMask0 : array[0..2, 0..2] of shortint = (
     (0,1,0),
     (1,3,1),
     (0,1,0)
  );
  LightMask1 : array[0..4, 0..4] of shortint = (
     (0,1,1,1,0),
     (1,1,3,1,1),
     (1,3,4,3,1),
     (1,1,3,1,1),
     (0,1,2,1,0)
  );
  LightMask2 : array[0..8, 0..8] of shortint = (
     (0,0,0,1,1,1,0,0,0),
     (0,0,1,2,3,2,1,0,0),
     (0,1,2,3,4,3,2,1,0),
     (1,2,3,4,4,4,3,2,1),
     (1,3,4,4,4,4,4,3,1),
     (1,2,3,4,4,4,3,2,1),
     (0,1,2,3,4,3,2,1,0),
     (0,0,1,2,3,2,1,0,0),
     (0,0,0,1,1,1,0,0,0)
  );
  LightMask3 : array[0..10, 0..10] of shortint = (
     (0,0,0,0,1,1,1,0,0,0,0),
     (0,0,0,1,2,2,2,1,0,0,0),
     (0,0,1,2,3,3,3,2,1,0,0),
     (0,1,2,3,4,4,4,3,2,1,0),
     (1,2,3,4,4,4,4,4,3,2,1),
     (2,3,4,4,4,4,4,4,4,3,2),
     (1,2,3,4,4,4,4,4,3,2,1),
     (0,1,2,3,4,4,4,3,2,1,0),
     (0,0,1,2,3,3,3,2,1,0,0),
     (0,0,0,1,2,2,2,1,0,0,0),
     (0,0,0,0,1,1,1,0,0,0,0)
  );
  LightMask4 : array[0..14, 0..14] of shortint = (
     (0,0,0,0,0,0,1,1,1,0,0,0,0,0,0),
     (0,0,0,0,0,1,1,1,1,1,0,0,0,0,0),
     (0,0,0,0,1,1,2,2,2,1,1,0,0,0,0),
     (0,0,0,1,1,2,3,3,3,2,1,1,0,0,0),
     (0,0,1,1,2,3,4,4,4,3,2,1,1,0,0),
     (0,1,1,2,3,4,4,4,4,4,3,2,1,1,0),
     (1,1,2,3,4,4,4,4,4,4,4,3,2,1,1),
     (1,2,3,4,4,4,4,4,4,4,4,4,3,2,1),
     (1,1,2,3,4,4,4,4,4,4,4,3,2,1,1),
     (0,1,1,2,3,4,4,4,4,4,3,2,1,1,0),
     (0,0,1,1,2,3,4,4,4,3,2,1,1,0,0),
     (0,0,0,1,1,2,3,3,3,2,1,1,0,0,0),
     (0,0,0,0,1,1,2,2,2,1,1,0,0,0,0),
     (0,0,0,0,0,1,1,1,1,1,0,0,0,0,0),
     (0,0,0,0,0,0,1,1,1,0,0,0,0,0,0)
  );
  LightMask5 : array[0..16, 0..16] of shortint = (
     (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0),
     (0,0,0,0,0,0,1,2,2,2,1,0,0,0,0,0,0),
     (0,0,0,0,0,1,2,4,4,4,2,1,0,0,0,0,0),
     (0,0,0,0,1,2,4,4,4,4,4,2,1,0,0,0,0),
     (0,0,0,1,2,4,4,4,4,4,4,4,2,1,0,0,0),
     (0,0,1,2,4,4,4,4,4,4,4,4,4,2,1,0,0),
     (0,1,2,4,4,4,4,4,4,4,4,4,4,4,2,1,0),
     (1,2,4,4,4,4,4,4,4,4,4,4,4,4,4,2,1),
     (1,2,4,4,4,4,4,4,4,4,4,4,4,4,4,2,1),
     (1,2,4,4,4,4,4,4,4,4,4,4,4,4,4,2,1),
     (0,1,2,4,4,4,4,4,4,4,4,4,4,4,2,1,0),
     (0,0,1,2,4,4,4,4,4,4,4,4,4,2,1,0,0),
     (0,0,0,1,2,4,4,4,4,4,4,4,2,1,0,0,0),
     (0,0,0,0,1,2,4,4,4,4,4,2,1,0,0,0,0),
     (0,0,0,0,0,1,2,4,4,4,2,1,0,0,0,0,0),
     (0,0,0,0,0,0,1,2,2,2,1,0,0,0,0,0,0),
     (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0)
  );

type
  PShoftInt = ^ShortInt;

  TLightEffect = record
    Width: integer;
    Height: integer;
    PFog: Pbyte;
  end;

  TLightMapInfo = record
    ShiftX: integer;
    ShiftY: integer;
    light: integer;
    bright: integer;
  end;

  TPlayScene = class(TScene)
    MapSurface: TDXRenderTargetTexture;
    ObjSurface: TDXRenderTargetTexture;
    MagSurface: TDXRenderTargetTexture;
    LigSurface: TDXRenderTargetTexture;
    m_boPlayChange: Boolean;
  private
    m_dwPlayChangeTick: LongWord;
//    FogScreen: array[0..g_FScreenHeight, 0..g_FScreenWidth] of byte;
//    PFogScreen: PByte;
//    FogWidth, FogHeight: integer;
    Lights: array[0..MAXLIGHT] of TLightEffect;
    MoveTime: longword;
    MoveStepCount: integer;
    AniTime: longword;
    DefXX, DefYY: integer;
    MainSoundTimer: TTimer;
    MsgList: TList;
    LightMap: array[0..LMX, 0..LMY] of TLightMapInfo;
    procedure LoadFog;
    procedure ClearLightMap;
    procedure AddLight(x, y, shiftx, shifty, light: integer; nocheck: Boolean);
    procedure UpdateBright(x, y, light: integer);
    function CheckOverLight(x, y, light: integer): Boolean;
    procedure EdChatKeyPress(Sender: TObject; var Key: Char);
    procedure EdChatKeyDown (Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SoundOnTimer(Sender: TObject);
  public
    EdChat: TEdit;
    ActorList, TempList: TList;
    GroundEffectList: TList;
    EffectList: TList;
    FlyList: TList;
    BlinkTime: Longword;
    ViewBlink: Boolean;
    constructor Create;
    destructor Destroy; override;
    function Initialize: Boolean;
    procedure Finalize; override;
    procedure OpenScene; override;
    procedure CloseScene; override;
    procedure OpeningScene; override;
    procedure Recovered;
    procedure DrawTileMap(Sender: TObject);
    procedure DrawMiniMap(surface: TDXTexture; transparent: Boolean);
    procedure RenderMiniMap(surface: TDXTexture);
    procedure DrawGeneralMap(surface: TDXTexture; transparent: Boolean);
    procedure HideMiniMap(surface: TDXTexture; transparent: Boolean);
    procedure PlayScene(MSurface: TDXTexture); override;
    procedure BeginScene;
    procedure PlaySurface(Sender: TObject);
    procedure MagicSurface(Sender: TObject);
    procedure LightSurface(Sender: TObject);
    procedure Lost;
    function CanDrawTileMap(): Boolean;
    function ButchAnimal(x, y: integer): TActor;
    function FindActor(id: integer): TActor;
    function FindActorXY(x, y: integer): TActor;
    function IsValidActor(actor: TActor): Boolean;
    function NewActor(chrid: integer; cx, cy, cdir: word; cfeature, cstate: integer): TActor;
    procedure ActorDied(actor: TObject);
    procedure SetActorDrawLevel(actor: TObject; level: integer);
    procedure ClearActors;
    function DeleteActor(id: integer): TActor;
    procedure DelActor(actor: TObject);
    procedure SendMsg(ident, chrid, x, y, cdir, feature, state, param: integer; str: string);
    procedure NewMagic(aowner: TActor; magid, magnumb, cx, cy, tx, ty, targetcode: integer; mtype: TMagicType; Recusion: Boolean; anitime: integer; var bofly: Boolean);
    procedure DelMagic(magid: integer);
    function NewFlyObject(aowner: TActor; cx, cy, tx, ty, targetcode: integer; mtype: TMagicType): TMagicEff;
      //function  NewStaticMagic (aowner: TActor; tx, ty, targetcode, effnum: integer);

    procedure ScreenXYfromMCXY(cx, cy: integer; var sx, sy: integer);
    procedure CXYfromMouseXY(mx, my: integer; var ccx, ccy: integer);
    procedure CXYfromMouseXYMid(mx, my: integer; var ccx, ccy: integer);
    function GetCharacter(x, y, wantsel: integer; var nowsel: integer; liveonly: Boolean): TActor;
    function GetAttackFocusCharacter(x, y, wantsel: integer; var nowsel: integer; liveonly: Boolean): TActor;
    function IsSelectMyself(x, y: integer): Boolean;
    function GetDropItems(x, y: integer; var inames: string): PTDropItem;
    procedure DropItemsShow(dsurface: TDXTexture);
    function CanRun(sx, sy, ex, ey: integer): Boolean;
    function CanWalk(mx, my: integer): Boolean;
    function CrashMan(mx, my: integer): Boolean;
    function CanFly(mx, my: integer): Boolean;
    procedure RefreshScene;
    procedure CleanObjects;
  end;

implementation

uses
  ClMain, FState, Relationship, MShare, HGE, Imm,
  Light0a, Light0b, Light0c, Light0d, Light0e, Light0f;

constructor TPlayScene.Create;
begin
  MapSurface := nil;
  ObjSurface := nil;
  MagSurface := nil;
  LigSurface := nil;
  MsgList := TList.Create;
  ActorList := TList.Create;
  TempList := TList.Create;
  GroundEffectList := TList.Create;
  EffectList := TList.Create;
  FlyList := TList.Create;
  BlinkTime := GetTickCount;
  ViewBlink := FALSE;

  EdChat := TEdit.Create(FrmMain.Owner);
  with EdChat do
  begin
    Parent := FrmMain;
    BorderStyle := bsNone;
    OnKeyPress := EdChatKeyPress;
  //  OnKeyDown := EdChatKeyDown;
    Visible := FALSE;
    MaxLength := 70;
    Ctl3D := FALSE;
    Left := 208;
    Top := g_FScreenHeight - 19;
    Height := 12;
    if g_FScreenWidth = 1024 then Width := 387 + 224
    else Width := 387;
    Color := clSilver;
  end;
  MoveTime := GetTickCount;
  AniTime := GetTickCount;
  MainAniCount := 0;
  MoveStepCount := 0;
  MainSoundTimer := TTimer.Create(FrmMain.Owner);
  with MainSoundTimer do
  begin
    OnTimer := SoundOnTimer;
    Interval := 1;
    Enabled := FALSE;
  end;
end;

destructor TPlayScene.Destroy;
begin
  MsgList.Free;
  ActorList.Free;
  TempList.Free;
  GroundEffectList.Free;
  EffectList.Free;
  FlyList.Free;
  inherited Destroy;
end;

procedure TPlayScene.SoundOnTimer(Sender: TObject);
begin
  PlaySound(s_main_theme);
  MainSoundTimer.Interval := 46 * 1000;
end;

procedure TPlayScene.EdChatKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    FrmMain.SendSay(EdChat.Text);
    EdChat.Text := '';
    EdChat.Visible := FALSE;
    Key := #0;
    g_HIMC := ImmGetContext(EdChat.Handle);
    ImmAssociateContext(FrmMain.Handle,0);
//    SetImeMode(EdChat.Handle, imSAlpha);
  end;
  if Key = #27 then
  begin
    EdChat.Text := '';
    EdChat.Visible := FALSE;
    Key := #0;
    g_HIMC := ImmGetContext(EdChat.Handle);
    ImmAssociateContext(FrmMain.Handle,0);
//    SetImeMode(EdChat.Handle, imSAlpha);
  end;
end;

procedure TPlayScene.EdChatKeyDown (Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = 13 then begin
      FrmMain.SendSay (EdChat.Text);
      EdChat.Text := '';
      g_HIMC := ImmGetContext(EdChat.Handle);
      ImmAssociateContext(FrmMain.Handle,0);    // �������뷨,�����������ݼ�������
      EdChat.Visible := FALSE;
   end;
   if Key = 27 then begin
      FrmMain.SendSay (EdChat.Text);
      EdChat.Text := '';
      g_HIMC := ImmGetContext(EdChat.Handle);
      ImmAssociateContext(FrmMain.Handle,0);    // �������뷨,�����������ݼ�������
      EdChat.Visible := FALSE;
   end;
end;

function TPlayScene.Initialize: Boolean;
var
  i: integer;
begin
  Result := False;
  //����
  MapSurface := TDXRenderTargetTexture.Create(g_DXCanvas);
  MapSurface.Size := Point(g_FScreenWidth + UNITX * 10, g_FScreenHeight + UNITY * 10);
  MapSurface.Active := True;
  if not MapSurface.Active then
    exit;

  ObjSurface := TDXRenderTargetTexture.Create(g_DXCanvas);
  ObjSurface.Size := Point(g_FScreenWidth, g_FScreenHeight);
  ObjSurface.Active := True;
  if not ObjSurface.Active then
    exit;

  MagSurface := TDXRenderTargetTexture.Create(g_DXCanvas);
  MagSurface.Size := Point(g_FScreenWidth, g_FScreenHeight);
  MagSurface.Active := True;
  if not MagSurface.Active then
    exit;

  LigSurface := TDXRenderTargetTexture.Create(g_DXCanvas);
  LigSurface.Size := Point(g_FScreenWidth, g_FScreenHeight);
  LigSurface.Active := True;
  if not LigSurface.Active then
    exit;



  Result := True;
end;
//
//procedure TPlayScene.Initialize;
//var
//   i: integer;
//begin
//   MapSurface := TDXTexture.Create (FrmMain.DXDraw1.DDraw);
//   MapSurface.SystemMemory := TRUE;
//   MapSurface.SetSize (MAPSURFACEWIDTH+UNITX*4+30, MAPSURFACEHEIGHT+UNITY*4);
//   ObjSurface := TDXTexture.Create (FrmMain.DXDraw1.DDraw);
//   ObjSurface.SystemMemory := TRUE;
//   ObjSurface.SetSize (MAPSURFACEWIDTH-SOFFX*2, MAPSURFACEHEIGHT);
//
//   FogWidth := MAPSURFACEWIDTH - SOFFX * 2;
//   FogHeight := MAPSURFACEHEIGHT;
//   PFogScreen := @FogScreen;
//   //PFogScreen := AllocMem (FogWidth * FogHeight);
//   ZeroMemory (PFogScreen, MAPSURFACEHEIGHT * MAPSURFACEWIDTH);
//
//   ViewFog := FALSE;
//   for i:=0 to MAXLIGHT do
//      Lights[i].PFog := nil;
//   LoadFog;
//
//end;

procedure TPlayScene.Finalize;
begin
  if MapSurface <> nil then
    MapSurface.Free;
  if ObjSurface <> nil then
    ObjSurface.Free;
  if MagSurface <> nil then
    MagSurface.Free;
  if LigSurface <> nil then
    LigSurface.Free;
  MapSurface := nil;
  ObjSurface := nil;
  MagSurface := nil;
  LigSurface := nil;
end;

procedure TPlayScene.OpenScene;
begin
//   WProgUse.ClearCache;  //�α��� �̹��� ĳ�ø� �����.
//   FrmDlg.ViewBottomBox (TRUE);
//   //EdChat.Visible := TRUE;
//   //EdChat.SetFocus;
//   SetImeMode (FrmMain.Handle, LocalLanguage);
//   //MainSoundTimer.Interval := 1000;
//   //MainSoundTimer.Enabled := TRUE;
  ClMain.HGE.Gfx_Restore(g_FScreenWidth, g_FScreenHeight, 16);
  FrmDlg.ViewBottomBox(TRUE);
  SetImeMode(FrmMain.Handle, LocalLanguage);
end;

procedure TPlayScene.CloseScene;
begin
   //MainSoundTimer.Enabled := FALSE;
  SilenceSound;

  EdChat.Visible := FALSE;
  FrmDlg.ViewBottomBox(FALSE);
end;

procedure TPlayScene.OpeningScene;
begin
end;

procedure TPlayScene.Recovered;
begin
  if MapSurface <> nil then
    MapSurface.Recovered;
  if ObjSurface <> nil then
    ObjSurface.Recovered;
  if MagSurface <> nil then
    MagSurface.Recovered;
  if LigSurface <> nil then
    LigSurface.Recovered;
end;

procedure TPlayScene.RefreshScene;
var
  i: integer;
begin
  Map.OldClientRect.Left := -1;
  for i := 0 to ActorList.Count - 1 do
    TActor(ActorList[i]).LoadSurface;
end;

procedure TPlayScene.RenderMiniMap(surface: TDXTexture);
begin
  if (MiniMapIndex=-1) or (Myself=nil) then Exit;
  if BoDrawMiniMap then
  begin
    if ViewMiniMapStyle > 0 then
    begin
      if ViewMiniMapStyle = 1 then
      begin
        DrawMiniMap(surface, ViewMiniMapTran);
//        FrmDlg.DGeneralMap.Visible := FALSE;
      end
      else if ViewMiniMapStyle = 2 then
      begin
        DrawMiniMap(surface, ViewMiniMapTran);
//        FrmDlg.DGeneralMap.Visible := FALSE;
      end
      else if ViewMiniMapStyle = 3 then
      begin
        DrawMiniMap(surface, ViewMiniMapTran);
//        FrmDlg.DGeneralMap.Visible := True;
      end;
    end;

    if ViewGeneralMapStyle > 0 then
    begin
      if ViewGeneralMapStyle = 1 then
      begin
        if MiniMapIndex in [100, 101, 102, 104, 105, 120, 160, 190] then
          DrawGeneralMap(surface, TRUE)
        else
        begin
          ViewGeneralMapStyle := 0;
          DScreen.AddChatBoardString('��ǰ��ͼû�����ô��ͼ', clGreen, clWhite);
//         else if MiniMapIndex in [134,101,102,104,105,160,190] then DrawGeneralMap2 (MSurface, FALSE)
        end;
      end
      else
      begin
        if MiniMapIndex in [100, 101, 102, 104, 105, 120, 160, 190] then
          DrawGeneralMap(surface, FALSE)
        else
        begin
          ViewGeneralMapStyle := 0;
          DScreen.AddChatBoardString('Only field map will be displayed.', clGreen, clWhite);
//            DScreen.AddChatBoardString ('�ֶ�ӳ��Ϳ���.', clGreen, clWhite);
        end;
      end;
    end;
  end;
end;

procedure TPlayScene.CleanObjects;
var
  i: integer;
begin
  for i := ActorList.Count - 1 downto 0 do
  begin
    if TActor(ActorList[i]) <> Myself then
    begin
      TActor(ActorList[i]).Free;
      ActorList.Delete(i);
    end;
  end;
  MsgList.Clear;
  TargetCret := nil;
  FocusCret := nil;
  MagicTarget := nil;
  for i := 0 to GroundEffectList.Count - 1 do
    TMagicEff(GroundEffectList[i]).Free;
  GroundEffectList.Clear;
  for i := 0 to EffectList.Count - 1 do
    TMagicEff(EffectList[i]).Free;
  EffectList.Clear;
end;

{---------------------- Draw Map -----------------------}

procedure TPlayScene.DrawTileMap(Sender: TObject);
var
   i,j, m,n, imgnum, imgnum2:integer;
   DSurface: TDXTexture;
begin
   with Map do
      if (ClientRect.Left = OldClientRect.Left) and (ClientRect.Top = OldClientRect.Top) then exit;
   Map.OldClientRect := Map.ClientRect;

   with Map.ClientRect do begin
      if g_FScreenHeight = 768 then m := -UNITY*1
      else m := -UNITY*4;
      for j:=(Top - Map.BlockTop-1) to (Bottom - Map.BlockTop+1) do begin
         if g_FScreenWidth = 1024 then n := AAX + 28 -UNITX * 2
         else n := AAX + 14 -UNITX * 4;
         for i:=(Left - Map.BlockLeft-2) to (Right - Map.BlockLeft+1) do begin
            if (i >= 0) and (i < LOGICALMAPUNIT*3) and (j >= 0) and (j < LOGICALMAPUNIT*3) then begin
               imgnum := (Map.MArr[i, j].BkImg and $7FFF);
               if imgnum > 0 then begin
                  if (i mod 2 = 0) and (j mod 2 = 0) then begin
                     imgnum := imgnum - 1;
                     DSurface := WTiles.Images[imgnum];
                     if Dsurface <> nil then
                        MapSurface.Draw (n, m, DSurface.ClientRect, DSurface, FALSE);
                  end;
               end;
            end;
            Inc (n, UNITX);
         end;
         Inc (m, UNITY);
      end;
   end;

   with Map.ClientRect do begin
      if g_FScreenHeight = 768 then m := -UNITY*1
      else m := -UNITY*4;
      for j:=(Top - Map.BlockTop-1) to (Bottom - Map.BlockTop+1) do begin
         if g_FScreenWidth = 1024 then n := AAX + 28 -UNITX * 2
         else n := AAX + 14 -UNITX*4;
         for i:=(Left - Map.BlockLeft-2) to (Right - Map.BlockLeft+1) do begin
            if (i >= 0) and (i < LOGICALMAPUNIT*3) and (j >= 0) and (j < LOGICALMAPUNIT*3) then begin

               imgnum := Map.MArr[i, j].MidImg;
               if imgnum > 0 then begin
                  imgnum := imgnum - 1;
                  DSurface := WSmTiles.Images[imgnum];
                  if Dsurface <> nil then
                     MapSurface.Draw (n, m, DSurface.ClientRect, DSurface, TRUE);
               end;
            end;
            Inc (n, UNITX);
         end;
         Inc (m, UNITY);
      end;
   end;

end;


{----------------------- ����, ����Ʈ ó�� -----------------------}

procedure TPlayScene.LoadFog;  //����Ʈ ����Ÿ �б�
var
  i, fhandle, w, h, prevsize: integer;
  cheat: Boolean;
begin
  prevsize := 0; //���� üũ
  cheat := FALSE;
  for i := 0 to MAXLIGHT do
  begin
    if FileExists(LightFiles[i]) then
    begin
      fhandle := FileOpen(LightFiles[i], fmOpenRead or fmShareDenyNone);
      FileRead(fhandle, w, sizeof(integer));
      FileRead(fhandle, h, sizeof(integer));
      Lights[i].Width := w;
      Lights[i].Height := h;
      Lights[i].PFog := AllocMem(w * h + 8);
      if prevsize < w * h then
      begin
        FileRead(fhandle, Lights[i].PFog^, w * h);
      end
      else
        cheat := TRUE;
      prevsize := w * h;
      if LightSizes[i] <> prevsize then
        cheat := TRUE;
      FileClose(fhandle);
    end;
  end;
  if cheat then
    for i := 0 to MAXLIGHT do
    begin
      if Lights[i].PFog <> nil then
        FillChar(Lights[i].PFog^, Lights[i].Width * Lights[i].Height + 8, #0);
    end;
end;

procedure TPlayScene.ClearLightMap;
var
  i, j: integer;
begin
  FillChar(LightMap, (LMX + 1) * (LMY + 1) * sizeof(TLightMapInfo), 0);
  for i := 0 to LMX do
    for j := 0 to LMY do
      LightMap[i, j].Light := -1;
end;

procedure TPlayScene.UpdateBright(x, y, light: integer);
var
  i, j, r, lx, ly: integer;
  pmask: ^ShortInt;
begin
  r := -1;
  case light of
    0:
      begin
        r := 2;
        pmask := @LightMask0;
      end;
    1:
      begin
        r := 4;
        pmask := @LightMask1;
      end;
    2:
      begin
        r := 8;
        pmask := @LightMask2;
      end;
    3:
      begin
        r := 10;
        pmask := @LightMask3;
      end;
    4:
      begin
        r := 14;
        pmask := @LightMask4;
      end;
    5:
      begin
        r := 16;
        pmask := @LightMask5;
      end;
  end;
  for i := 0 to r do
    for j := 0 to r do
    begin
      lx := x - (r div 2) + i;
      ly := y - (r div 2) + j;
      if (lx in [0..LMX]) and (ly in [0..LMY]) then
        LightMap[lx, ly].bright := LightMap[lx, ly].bright + PShoftInt(integer(pmask) + (i * (r + 1) + j) * sizeof(shortint))^;
    end;
end;

function TPlayScene.CheckOverLight(x, y, light: integer): Boolean;
var
  i, j, r, mlight, lx, ly, count, check: integer;
  pmask: ^ShortInt;
begin
  r := -1;
  case light of
    0:
      begin
        r := 2;
        pmask := @LightMask0;
        check := 0;
      end;
    1:
      begin
        r := 4;
        pmask := @LightMask1;
        check := 4;
      end;
    2:
      begin
        r := 8;
        pmask := @LightMask2;
        check := 8;
      end;
    3:
      begin
        r := 10;
        pmask := @LightMask3;
        check := 18;
      end;
    4:
      begin
        r := 14;
        pmask := @LightMask4;
        check := 30;
      end;
    5:
      begin
        r := 16;
        pmask := @LightMask5;
        check := 40;
      end;
  end;
  count := 0;
  for i := 0 to r do
    for j := 0 to r do
    begin
      lx := x - (r div 2) + i;
      ly := y - (r div 2) + j;
      if (lx in [0..LMX]) and (ly in [0..LMY]) then
      begin
        mlight := PShoftInt(integer(pmask) + (i * (r + 1) + j) * sizeof(shortint))^;
        if LightMap[lx, ly].bright < mlight then
        begin
          inc(count, mlight - LightMap[lx, ly].bright);
          if count >= check then
          begin
            Result := FALSE;
            exit;
          end;
        end;
      end;
    end;
  Result := TRUE;
end;

procedure TPlayScene.AddLight(x, y, shiftx, shifty, light: integer; nocheck: Boolean);
var
  lx, ly: integer;
begin
  lx := x - Myself.Rx + LMX div 2;
  ly := y - Myself.Ry + LMY div 2;
  if (lx >= 1) and (lx < LMX) and (ly >= 1) and (ly < LMY) then
  begin
    if LightMap[lx, ly].light < light then
    begin
      if not CheckOverLight(lx, ly, light) or nocheck then
      begin // > LightMap[lx, ly].light then begin
        UpdateBright(lx, ly, light);
        LightMap[lx, ly].light := light;
        LightMap[lx, ly].shiftx := shiftx;
        LightMap[lx, ly].shifty := shifty;
      end;
    end;
  end;
end;

procedure TPlayScene.DrawMiniMap (surface: TDXTexture; transparent: Boolean);
var
   d: TDXTexture;
   v: Boolean;
   i, k, cl, ix, mx, my, NearLoverCount,ADrawX,ADrawY: integer;
   rc: TRect;
   actor: TActor;
   range: Integer;
   Rx,Ry:Integer;
   S:String;
   ATem:Single;
begin
   // 2003/02/11 ���ڰŸ��� �ʰ� ��...
    if GetTickCount > BlinkTime + 300 then begin
    BlinkTime := GetTickCount;
    ViewBlink := not ViewBlink;
  end;
//  ViewBlink := FLASE;  //ȫ����ͼ���Լ��İ׵㲻��˸



  d := WMMap.Images[MiniMapIndex];
  if d <> nil then begin
    mx := (Myself.XX * 48) div 32;
    my := (Myself.YY * 32) div 32;
    if ViewMiniMapStyle = 2 then begin
      range := 200;
      g_MinMapWidth:=range;
      rc.Left := _MAX(0, mx - range div 2);
      rc.Top := _MAX(0, my - range div 2);
      rc.Right := _MIN(d.ClientRect.Right, rc.Left + range);
      rc.Bottom := _MIN(d.ClientRect.Bottom, rc.Top + range);
      if transparent then
         surface.StretchDraw(Rect((g_FScreenWidth - range), 0, g_FScreenWidth, range), d.ClientRect,d,true)
         else
         surface.StretchDraw(Rect((g_FScreenWidth - range), 0, g_FScreenWidth, range), d.ClientRect,d, False);

      ix := 0;
    end else begin
      range := 120;
      g_MinMapWidth:=range;
      rc.Left := _MAX(0, mx-60);
      rc.Top := _MAX(0, my-60);
      rc.Right := _MIN(d.ClientRect.Right, rc.Left + range);
      rc.Bottom := _MIN(d.ClientRect.Bottom, rc.Top + range);
//      if rc.Right-rc.Left<range then                                                  //С��ͼ��Ե�п�
//         g_DXCanvas.Rectangle((g_FScreenWidth - range),0,range,range,$ff000000,true);  //С��ͼ��Ե�п�
      if transparent then
        DrawBlendR(surface, (g_FScreenWidth - range), 0, rc, d, 0)
        else
        surface.Draw((g_FScreenWidth - range), 0, rc, d, True);

      ix := (g_FScreenWidth - range) - rc.Left;
    end;

    NearLoverCount := 0;

    if ActorList.Count > 0 then begin
      for i := 0 to ActorList.Count - 1 do begin

        if ViewMiniMapStyle = 2 then begin
          mx := ix + (TActor(ActorList[i]).XX * 48) div 32;
          my := (TActor(ActorList[i]).YY * 32) div 32;
          mx := UpInt((mx / d.Width) * range + g_FScreenWidth - range);
          my := UpInt((my / d.Height) * range);
        end
        else begin
          mx := ix + (TActor(ActorList[i]).XX * 48) div 32;
          my := (TActor(ActorList[i]).YY * 32) div 32 - rc.Top;
        end;

        cl := 0;
        if ViewMiniMapStyle = 2 then begin
          case TActor(ActorList[i]).Race of
            RC_USERHUMAN: if ( TActor(ActorList[i]) = Myself ) then begin
              if ViewBlink then cl := $FFFFFFFF
              else cl := 0;
            end
            else if (nil <> fLover) and  (Length( Trim(TActor(ActorList[i]).UserName)) > 0) and
              ( TActor(ActorList[i]).UserName = Copy(fLover.GetDisplay(0), length(STR_LOVER)+1, 20) ) and
              (Not TActor(ActorList[i]).BoOpenHealth) then begin
              cl := 0;
              if (mx > (g_FScreenWidth-range)) and (my < (range-1)) then Inc(NearLoverCount);
            end else cl := 0;

            RCC_GUARD, RCC_GUARD2, RCC_MERCHANT: cl := 0;
            54, 55: cl := 0;
            98, 99: cl := 0;
          else if ((TActor(ActorList[i]).Visible) and (not TActor(ActorList[i]).Death) and (pos('(', TActor(ActorList[i]).UserName) = 0)) then
              cl := 0;
          end;
        end else begin
          case TActor(ActorList[i]).Race of
            RC_USERHUMAN: if ( TActor(ActorList[i]) = Myself ) then
            begin
              if ViewBlink then cl := $FFFFFFFF
              else cl := 0;
            end
            else if (nil <> fLover) and  (Length( Trim(TActor(ActorList[i]).UserName)) > 0) and
              ( TActor(ActorList[i]).UserName = Copy(fLover.GetDisplay(0), length(STR_LOVER)+1, 20) ) and
              (Not TActor(ActorList[i]).BoOpenHealth) then begin
              cl := $FFFF00FF;
              if (mx > (g_FScreenWidth-range)) and (my < (range-1)) then Inc(NearLoverCount);
            end else cl := $FF00FFFF;

            RCC_GUARD: cl := $FF00FF00;
            RCC_GUARD2: cl := $FF00FF00;    //С��ͼ�ϴ���ɫ
            RCC_MERCHANT: cl :=  $FF00FF00;//С��ͼ��NPC��ɫ
//            23, 54, 55:begin
//               if ((TActor(ActorList[i]).Visible) and (not TActor(ActorList[i]).Death)) then cl := $FF0000FF;      //С��ͼ�ϵ�ʿ������ɫ
//             end;
            98, 99: cl := 0;
          else if ((TActor(ActorList[i]).Visible) and (not TActor(ActorList[i]).Death){ and (pos('(', TActor(ActorList[i]).UserName) = 0)}) then
              cl := $FF0000FF;
          end;
        end;

        if (mx > (g_FScreenWidth-range)) and (my < (range-1)) then begin
          if cl <> 0 then begin
            g_DXCanvas.FillRect(mx - 2, my - 2, 3, 3, cl);
          end;
        end;
      end;
    end;

    if NearLoverCount > 0 then
      CouplePower := True
    else
      CouplePower := False;

    if ViewListCount > 0 then begin
      for i := 1 to ViewListCount do begin
        if ((abs(ViewList[i].x - Myself.XX) < 40) and (abs(ViewList[i].y - Myself.YY) < 40)) then begin
          if ViewMiniMapStyle = 3 then begin
            mx := (ViewList[i].x * 48) div 32;
            my := (ViewList[i].y * 32) div 32;
            mx := UpInt(( mx / d.Width ) * range + g_FScreenWidth - range);
            my := UpInt(( my / d.Height ) * range );
          end else begin
            mx := ix + (ViewList[i].x * 48) div 32;
            my := (ViewList[i].y * 32) div 32 - rc.Top;
          end;

        {  if (mx > (g_FScreenWidth-range)) and (my < (range-1)) then begin
            cl := $FFFF0000;
            if ViewMiniMapStyle <> 3 then g_DXCanvas.FillRect(mx - 2, my - 2, 3, 3, cl);
          end; //С��ͼ�ϵ��������  }
        end;

        if (((GetTickCount - ViewList[i].LastTick) > 5000) and (ViewList[i].Index > 0)) then begin
          actor := FindActor(ViewList[i].Index);
          if actor <> nil then begin
            actor.BoOpenHealth := FALSE;
            if GroupIdList.Count > 0 then
              for k := 0 to GroupIdList.Count - 1 do begin  // MonOpenHp
                if integer(GroupIdList[k]) = actor.RecogId then begin
                  GroupIdList.Delete(k);
                  Break;
                end;
              end;
          end;

          if (ViewListCount > 0) then begin
            ViewList[i].Index := ViewList[ViewListCount].Index;
            ViewList[i].x := ViewList[ViewListCount].x;
            ViewList[i].y := ViewList[ViewListCount].y;
            ViewList[i].LastTick := ViewList[ViewListCount].LastTick;
            ViewList[ViewListCount].Index := 0;
            ViewList[ViewListCount].x := 0;
            ViewList[ViewListCount].y := 0;
            ViewList[ViewListCount].LastTick := 0;
          end;
          Dec(ViewListCount);
        end;
      end;
    end;
  end;
  if g_ShowMiniMapXY and (d<>nil) then
     begin
       if range=200 then
          begin
             rx:=g_MouseX-(g_FScreenWidth-range);
             ATem:=rx*(d.Width/range);
             rx :=Round(rx*(d.Width/range)*map.MapWidth/d.Width);
             ry := Round(g_MouseY*(d.Height/range)*map.MapHeight/d.Height);
          end
          else
          begin
            rx :=Round(MySelf.xx + (g_MouseX - (g_FScreenWidth - (rc.Right - rc.Left)) - ((rc.Right - rc.Left) div 2)) * 2 / 3);
            ry :=Round(MySelf.yy + (g_MouseY - (rc.Bottom - rc.Top) div 2));
          end;
      if (rx >= 0) and (ry >= 0) then
      begin
        S := Format('%s:%s', [IntToStr(Round(rx)), IntToStr(Round(ry))]);
        if range=200 then
           g_DXCanvas.TextOut(g_FScreenWidth - g_DXCanvas.TextWidth(S)-2, range - 14, S, clWhite)
           else
           g_DXCanvas.TextOut(g_FScreenWidth - g_DXCanvas.TextWidth(S)-2, rc.Bottom - rc.Top - 14, S, clWhite);
     end;
     end;
end;

procedure TPlayScene.DrawGeneralMap(surface: TDXTexture; transparent: Boolean);
var
  d: TDXTexture;
  v: Boolean;
  i, k, cl, mx, my, WPos, HPos: integer;
//   i, k, cl, ix, mx, my, WPos, HPos: integer;
  rc: TRect;
  actor: TActor;
begin

  if MiniMapIndex = 100 then
    d := WMMap.Images[134]
  else if MiniMapIndex = 101 then
    d := WMMap.Images[135]
  else if MiniMapIndex = 102 then
    d := WMMap.Images[136]
  else if MiniMapIndex = 104 then
    d := WMMap.Images[137]
  else if MiniMapIndex = 105 then
    d := WMMap.Images[138]
  else if MiniMapIndex = 120 then
    d := WMMap.Images[144]
  else if MiniMapIndex = 160 then
    d := WMMap.Images[145]
  else if MiniMapIndex = 190 then
    d := WMMap.Images[146]
  else
    d := WMMap.Images[MiniMapIndex];

  if d <> nil then
  begin
    mx := (Myself.XX * 48) div 64;
    my := (Myself.YY * 32) div 64;
//      rc.Left := _MAX(0, mx-60);
//      rc.Top := _MAX(0, my-60);
//      rc.Right := _MIN(d.ClientRect.Right, rc.Left + 120);
//      rc.Bottom := _MIN(d.ClientRect.Bottom, rc.Top + 120);

//      rc.Left := _MAX(0, mx-400);
//      rc.Top  := _MAX(0, my-222);
//      rc.Right  := _MIN(d.ClientRect.Right, rc.Left + MAPSURFACEWIDTH);
//      rc.Bottom := _MIN(d.ClientRect.Bottom, rc.Top + MAPSURFACEHEIGHT);

    rc.Left := 0;
    rc.Top := 0;
    rc.Right := d.Width;
    rc.Bottom := d.Height;

    WPos := (g_FScreenWidth - d.Width) div 2;
    HPos := (g_FScreenHeight - 18 - d.Height) div 2;
//      if WPos < 0 then WPos := 0;
//      if HPos < 0 then HPos := 0;
    if transparent then
      DrawBlend(surface, WPos, HPos, d, 0)
//         DrawBlendEx (surface, 0, 0, d, rc.Left, rc.Top, SCREENWIDTH, MAPSURFACEHEIGHT, 0)
    else
      surface.Draw(WPos, HPos, rc, d, True);
//         surface.Draw ((SCREENWIDTH-120), 0, rc, d, FALSE);

//    if ViewBlink then begin
//         ix := (WPos) - rc.Left;
//         ix := WPos;
         // 2003/02/11 �̴ϸʻ� �ٸ� ������Ʈ�� ���
    if ActorList.Count > 0 then
    begin
      for i := 0 to ActorList.Count - 1 do
      begin
//                mx := ix + (TActor(ActorList[i]).XX*48) div 32;
        mx := ((TActor(ActorList[i]).XX * 48) div 64) + WPos;
        my := ((TActor(ActorList[i]).YY * 32) div 64) + HPos;
//                my := (TActor(ActorList[i]).YY*32) div 32 - rc.Top;
        cl := 0;
        case TActor(ActorList[i]).Race of
          RC_USERHUMAN:
            if (TActor(ActorList[i]) = Myself) then
              cl := 255
            else if (nil <> fLover) and (Length(Trim(TActor(ActorList[i]).UserName)) > 0) and (TActor(ActorList[i]).UserName = Copy(fLover.GetDisplay(0), length(STR_LOVER) + 1, 20)) and (not TActor(ActorList[i]).BoOpenHealth) then
            begin
//      DScreen.AddChatBoardString ('TActor(ActorList[i]).UserName=> '+TActor(ActorList[i]).UserName, clYellow, clRed);
//      DScreen.AddChatBoardString ('fLover.GetDisplay(0)=> '+fLover.GetDisplay(0), clYellow, clRed);
              cl := 253
            end
//                                 else           cl := 0;  // ��� ������� ����...�׷���� ViewList���� ���
            else
              cl := 146;  // �ٸ� �÷��̾� �ϴû����� ǥ�� 2006/02/17

          RCC_GUARD, RCC_GUARD2, RCC_MERCHANT:
            cl := 251;
          54, 55:
            cl := 0;  // �ż� ������� ����...ViewList���� ���...250
          98, 99:
            cl := 0;
        else
          if ((TActor(ActorList[i]).Visible) and (not TActor(ActorList[i]).Death) and (pos('(', TActor(ActorList[i]).UserName) = 0)) then
            cl := 249;
        end;

//                if (mx > 680) and (my < 119) then begin //@@@@old
        if cl > 0 then
        begin
          surface.Pixels[mx - 1, my - 1] := cl;
          surface.Pixels[mx, my - 1] := cl;
          surface.Pixels[mx + 1, my - 1] := cl;
          surface.Pixels[mx - 1, my] := cl;
          surface.Pixels[mx, my] := cl;
          surface.Pixels[mx + 1, my] := cl;
          surface.Pixels[mx - 1, my + 1] := cl;
          surface.Pixels[mx, my + 1] := cl;
          surface.Pixels[mx + 1, my + 1] := cl;
        end;
//                end;
      end;
    end;
    if ViewListCount > 0 then
    begin
      for i := 1 to ViewListCount do
      begin
        if ((abs(ViewList[i].x - Myself.XX) < 40) and (abs(ViewList[i].y - Myself.YY) < 40)) then
        begin
//                   mx := ix + (ViewList[i].x*48) div 32;
          mx := ((ViewList[i].x * 48) div 64) + WPos;
          my := ((ViewList[i].y * 32) div 64) + HPos;
//                   my := (ViewList[i].y*32) div 32 - rc.Top;
//                   if (mx > 680) and (my < 119) then begin //@@@@old
          cl := 252;
          surface.Pixels[mx - 1, my - 1] := cl;
          surface.Pixels[mx, my - 1] := cl;
          surface.Pixels[mx + 1, my - 1] := cl;
          surface.Pixels[mx - 1, my] := cl;
          surface.Pixels[mx, my] := cl;
          surface.Pixels[mx + 1, my] := cl;
          surface.Pixels[mx - 1, my + 1] := cl;
          surface.Pixels[mx, my + 1] := cl;
          surface.Pixels[mx + 1, my + 1] := cl;
//                   end;
        end;
                // ���������� ������...
        if (((GetTickCount - ViewList[i].LastTick) > 5000) and (ViewList[i].Index > 0)) then
        begin
                   // 2003/03/04 �׷�� Ž���Ŀ� ����
          actor := FindActor(ViewList[i].Index);
          if actor <> nil then
          begin
            actor.BoOpenHealth := FALSE;
            if GroupIdList.Count > 0 then
              for k := 0 to GroupIdList.Count - 1 do
              begin  // MonOpenHp
                if integer(GroupIdList[k]) = actor.RecogId then
                begin
                  GroupIdList.Delete(k);
                  Break;
                end;
              end;
          end;
                   // ���� ������ �ִٸ� �̵�
          if (ViewListCount > 0) then
          begin
            ViewList[i].Index := ViewList[ViewListCount].Index;
            ViewList[i].x := ViewList[ViewListCount].x;
            ViewList[i].y := ViewList[ViewListCount].y;
            ViewList[i].LastTick := ViewList[ViewListCount].LastTick;
            ViewList[ViewListCount].Index := 0;
            ViewList[ViewListCount].x := 0;
            ViewList[ViewListCount].y := 0;
            ViewList[ViewListCount].LastTick := 0;
          end;
          Dec(ViewListCount);
        end;
      end;
    end;
//    end;
  end;
end;

procedure TPlayScene.HideMiniMap(surface: TDXTexture; transparent: Boolean);
var
  d: TDXTexture;
  v: Boolean;
  i, k, cl, ix, mx, my, NearLoverCount: integer;
  rc: TRect;
  actor: TActor;
begin

  d := WMMap.Images[MiniMapIndex];
  if d <> nil then
  begin
    mx := (Myself.XX * 48) div 32;
    my := (Myself.YY * 32) div 32;
    rc.Left := _MAX(0, mx - 60);
    rc.Top := _MAX(0, my - 60);
    rc.Right := _MIN(d.ClientRect.Right, rc.Left + 120);
    rc.Bottom := _MIN(d.ClientRect.Bottom, rc.Top + 120);

//    if ViewBlink then begin
    ix := (g_FScreenWidth - 120) - rc.Left;

    NearLoverCount := 0;
         // 2003/02/11 �̴ϸʻ� �ٸ� ������Ʈ�� ���
    if ActorList.Count > 0 then
    begin
      for i := 0 to ActorList.Count - 1 do
      begin
        mx := ix + (TActor(ActorList[i]).XX * 48) div 32;
        my := (TActor(ActorList[i]).YY * 32) div 32 - rc.Top;
        cl := 0;
        case TActor(ActorList[i]).Race of
          RC_USERHUMAN:
            if (TActor(ActorList[i]) = Myself) then
              cl := 255
            else if (nil <> fLover) and (Length(Trim(TActor(ActorList[i]).UserName)) > 0) and (TActor(ActorList[i]).UserName = Copy(fLover.GetDisplay(0), length(STR_LOVER) + 1, 20)) and (not TActor(ActorList[i]).BoOpenHealth) then
            begin
              cl := 253;
              if (mx > 680) and (my < 119) then
                Inc(NearLoverCount);
            end
            else
              cl := 0;  // ��� ������� ����...�׷���� ViewList���� ���

          RCC_GUARD, RCC_GUARD2, RCC_MERCHANT:
            cl := 251;
          54, 55:
            cl := 0;  // �ż� ������� ����...ViewList���� ���...250
          98, 99:
            cl := 0;
        else
          if ((TActor(ActorList[i]).Visible) and (not TActor(ActorList[i]).Death) and (pos('(', TActor(ActorList[i]).UserName) = 0)) then
            cl := 249;
        end;

      end;
    end;

    if NearLoverCount > 0 then
      CouplePower := True
    else
      CouplePower := False;

    if ViewListCount > 0 then
    begin
      for i := 1 to ViewListCount do
      begin
        if ((abs(ViewList[i].x - Myself.XX) < 40) and (abs(ViewList[i].y - Myself.YY) < 40)) then
        begin
          mx := ix + (ViewList[i].x * 48) div 32;
          my := (ViewList[i].y * 32) div 32 - rc.Top;
        end;
                // ���������� ������...
        if (((GetTickCount - ViewList[i].LastTick) > 5000) and (ViewList[i].Index > 0)) then
        begin
                   // 2003/03/04 �׷�� Ž���Ŀ� ����
          actor := FindActor(ViewList[i].Index);
          if actor <> nil then
          begin
            actor.BoOpenHealth := FALSE;
            if GroupIdList.Count > 0 then
              for k := 0 to GroupIdList.Count - 1 do
              begin  // MonOpenHp
                if integer(GroupIdList[k]) = actor.RecogId then
                begin
                  GroupIdList.Delete(k);
                  Break;
                end;
              end;
          end;
                   // ���� ������ �ִٸ� �̵�
          if (ViewListCount > 0) then
          begin
            ViewList[i].Index := ViewList[ViewListCount].Index;
            ViewList[i].x := ViewList[ViewListCount].x;
            ViewList[i].y := ViewList[ViewListCount].y;
            ViewList[i].LastTick := ViewList[ViewListCount].LastTick;
            ViewList[ViewListCount].Index := 0;
            ViewList[ViewListCount].x := 0;
            ViewList[ViewListCount].y := 0;
            ViewList[ViewListCount].LastTick := 0;
          end;
          Dec(ViewListCount);
        end;
      end;
    end;
//    end;
  end;
end;

{-----------------------------------------------------------------------}
procedure TPlayScene.BeginScene;

  function CheckOverlappedObject(myrc, obrc: TRect): Boolean;
  begin
    if (obrc.Right > myrc.Left) and (obrc.Left < myrc.Right) and (obrc.Bottom > myrc.Top) and (obrc.Top < myrc.Bottom) then
      Result := TRUE
    else
      Result := FALSE;
  end;

var
  i, j, k, n, m, mmm, ix, iy, line, defx, defy, wunit, fridx, ani, anitick, ax, ay, idx, drawingbottomline: integer;
  DSurface, d: TDXTexture;
  blend, movetick: Boolean;
   //myrc, obrc: TRect;
  pd: PTDropItem;
  evn: TClEvent;
  actor: TActor;
  meff: TMagicEff;
  msgstr: string;
  px, py, ImgPosX, ImgPosY: integer;
  nFColor, nBColor: Integer;
  boChange: Boolean;
begin
  if (Myself = nil) then
  begin
    msgstr := '�����˳���Ϸ�����Ժ�...';
//    with g_DXCanvas do
//    begin
      g_DXCanvas.TextOut((g_FScreenWidth - g_DXCanvas.TextWidth(msgstr)) div 2, 200, msgstr, clWhite);
//    end;
    exit;
  end;

//   DoFastFadeOut := FALSE;
  m_boPlayChange := False;

   //ĳ���Ϳ��鿡�� �޼����� ����    07/03
  movetick := FALSE;
  if GetTickCount - MoveTime >= 100 then
  begin
    MoveTime := GetTickCount;   //�ƶ���ʼʱ��
    movetick := TRUE;          //�����ƶ�
    Inc(MoveStepCount);
    if MoveStepCount > 1 then
      MoveStepCount := 0;
  end;
  if GetTickCount - AniTime >= 50 then
  begin
    AniTime := GetTickCount;
    Inc(MainAniCount);
    if MainAniCount > 1000000 then
      MainAniCount := 0;
  end;

  try
    i := 0;                          //�����ɫһЩ��ض���
    while TRUE do
    begin              //Frame ó���� ���⼭ ����.
      if i >= ActorList.Count then
        break;
      actor := ActorList[i];
      if movetick then
        actor.LockEndFrame := FALSE; //�����ƶ�
      if not actor.LockEndFrame then
      begin //û����������
        actor.ProcMsg;   //�����ɫ����Ϣ
        if movetick then
          if actor.Move(MoveStepCount, boChange) then
          begin  //��ɫ�ƶ�
            m_boPlayChange := m_boPlayChange or boChange;
            Inc(i);
            continue;
          end;
        actor.Run;    //ĳ���͵��� �����̰� ��.
        if actor <> Myself then
          actor.ProcHurryMsg;
      end;
      if actor = Myself then
        actor.ProcHurryMsg;
      //������ ���
      if actor.WaitForRecogId <> 0 then
      begin
        if actor.IsIdle then
        begin
          DelChangeFace(actor.WaitForRecogId);
          NewActor(actor.WaitForRecogId, actor.XX, actor.YY, actor.Dir, actor.WaitForFeature, actor.WaitForStatus);
          actor.WaitForRecogId := 0;
          actor.BoDelActor := TRUE;
        end;
      end;
      if actor.BoDelActor then
      begin
         //actor.Free;
        FreeActorList.Add(actor);
        ActorList.Delete(i);
        if TargetCret = actor then
          TargetCret := nil;
        if FocusCret = actor then
          FocusCret := nil;
        if MagicTarget = actor then
          MagicTarget := nil;
      end
      else
        Inc(i);
    end;
  except
    DebugOutStr('101');
  end;
  m_boPlayChange := m_boPlayChange or (GetTickCount > m_dwPlayChangeTick);

  try
    i := 0;
    while TRUE do
    begin
      if i >= GroundEffectList.Count then
        break;
      meff := GroundEffectList[i];
      if meff.Active then
      begin
        if not meff.Run then
        begin //����ȿ��
          meff.Free;
          GroundEffectList.Delete(i);
          continue;
        end;
      end;
      Inc(i);
    end;
    i := 0;
    while TRUE do
    begin
      if i >= EffectList.Count then
        break;
      meff := EffectList[i];
      if meff.Active then
      begin
        if not meff.Run then
        begin //����ȿ��
          meff.Free;
          EffectList.Delete(i);
          continue;
        end;
      end;
      Inc(i);
    end;
    i := 0;
    while TRUE do
    begin
      if i >= FlyList.Count then
        break;
      meff := FlyList[i];
      if meff.Active then
      begin
        if not meff.Run then
        begin //����,ȭ��� ���ư��°�
          meff.Free;
          FlyList.Delete(i);
          continue;
        end;
      end;
      Inc(i);
    end;

    EventMan.Execute;
  except
    DebugOutStr('102');
  end;

  try
   //����� ������ üũ
    for k := 0 to DropedItemList.Count - 1 do
    begin
      pd := PTDropItem(DropedItemList[k]);
      if pd <> nil then
      begin
        if (Abs(pd.x - Myself.XX) > 20) and (Abs(pd.y - Myself.YY) > 20) then
        begin
          Dispose(PTDropItem(DropedItemList[k]));
          DropedItemList.Delete(k);
          break;  //�ѹ��� �Ѱ���..
        end;
      end;
    end;
   //����� ���̳��Ϳ�����Ʈ �˻�
    for k := 0 to EventMan.EventList.Count - 1 do
    begin
      evn := TClEvent(EventMan.EventList[k]);
      if (Abs(evn.X - Myself.XX) > 20) and (Abs(evn.Y - Myself.YY) > 20) then
      begin
        evn.Free;
        EventMan.EventList.Delete(k);
        break;  //�ѹ��� �Ѱ���
      end;
    end;
  except
    DebugOutStr('103');
  end;
  with Map.ClientRect do
  begin
    Left := MySelf.Rx - 13;
    Top := MySelf.Ry - 15;
    Right := MySelf.Rx + 13;
    Bottom := MySelf.Ry + 13;
  end;

//   with Map.ClientRect do begin
//      Left   := MySelf.Rx - 9;
////      Top    := MySelf.Ry - 9;//$$$$
//      Top    := MySelf.Ry - 10;
//      Right  := MySelf.Rx + 9;                         // ������ ¥���� �׸�
//      Bottom := MySelf.Ry + 8;
//   end;
  Map.UpdateMapPos(Myself.Rx, Myself.Ry);
end;

//����Ϸ��ʽ����
procedure TPlayScene.PlayScene(MSurface: TDXTexture);
begin
  if (MySelf = nil) then exit;
  if MySelf.Death then begin//������������ʾ�ڰ׻���
     DrawEffect(ObjSurface, 0, 0, ObjSurface, ceGrayScale, False);
  end;
end;

procedure TPlayScene.LightSurface(Sender: TObject);
var
  d, dsurface: TDXTexture;
  k, i, j, n, m, idx, sx, sy, defy, defx, lx, ly, Level, Level2, lcount, light, lxx, lyy: Integer;
  Actor: TActor;
begin
  if (MySelf = nil) then exit;
  if DarkLevel = 1 then Level := 10
  else Level := 50;

  if g_FScreenWidth = 1024 then
    defx := -UNITX * 4 - MySelf.ShiftX + AAX + 28
  else
    defx := -UNITX * 6 - MySelf.ShiftX + AAX + 14;

  if g_FScreenHeight = 768 then
    defy := -UNITY * 5 - MySelf.ShiftY
  else
    defy := -UNITY * 8 - MySelf.ShiftY;

  if ViewFog and (not MySelf.Death) then begin
    LigSurface.DrawRect(0, 0, g_FScreenWidth, g_FScreenHeight, ARGB(255, Level, Level, Level), True);
    lcount := 0;
    for i := 1 to LMX - 1 do begin
      for j := 1 to LMY - 1 do begin
        light := LightMap[i, j].light;
        if light >= 0 then begin
          lx := (i + Myself.Rx - LMX div 2);
          ly := (j + Myself.Ry - LMY div 2);
          lxx := (lx - Map.ClientRect.Left) * UNITX + defx + LightMap[i, j].shiftx;
          lyy := (ly - Map.ClientRect.Top) * UNITY + defy + LightMap[i, j].shifty;

          case light of
            0: d := Light0aSurface;
            1: d := Light0bSurface;
            2: d := Light0cSurface;
            3: d := Light0dSurface;
            4: d := Light0eSurface;
            5: d := Light0fSurface;
          else
            d := Light0aSurface;
          end;
          if d <> nil then
            LigSurface.Draw(lxx - (d.Width-UNITX) div 2, lyy - (d.Height-UNITY) div 2, d.ClientRect, d, Blend_SrcColorAdd);

          inc(lcount);
        end;
      end;
    end;
  end;
end;

procedure TPlayScene.PlaySurface(Sender: TObject);

  function CheckOverlappedObject(myrc, obrc: TRect): Boolean;
  begin
    if (obrc.Right > myrc.Left) and (obrc.Left < myrc.Right) and (obrc.Bottom > myrc.Top) and (obrc.Top < myrc.Bottom) then
      Result := TRUE
    else
      Result := FALSE;
  end;

var
  i, j, k, n, m, mmm, ix, iy, line, defx, defy, wunit, fridx, ani, anitick, ax, ay, idx, drawingbottomline: integer;
  DSurface, d: TDXTexture;
  blend, movetick: Boolean;
   //myrc, obrc: TRect;
  pd: PTDropItem;
  evn: TClEvent;
  actor: TActor;
  meff: TMagicEff;
  msgstr: string;
  px, py, ImgPosX, ImgPosY: integer;
  nFColor, nBColor: Integer;
 // msgstr: string;
begin

  if myself = nil then begin
    msgstr := '�����˳���Ϸ�����Ժ�...';
//    with g_DXCanvas do
//    begin
      g_DXCanvas.TextOut((g_FScreenWidth - g_DXCanvas.TextWidth(msgstr)) div 2, 200, msgstr, clWhite);
    viewfog:= false;
    exit;
  end;

  try

   ///////////////////////
   //ViewFog := FALSE;
   ///////////////////////

     if NoDarkness or (Myself.Death) then begin
        ViewFog := FALSE;
     end;

     if ViewFog then begin //����
//        ZeroMemory (PFogScreen, MAPSURFACEHEIGHT * MAPSURFACEWIDTH);
        ClearLightMap;
     end;

    drawingbottomline := g_FScreenHeight;
//   ObjSurface.Fill(0);
//   DrawTileMap;
    ObjSurface.Draw(0, 0, Rect(UNITX * 4 + Myself.ShiftX, UNITY * 5 + Myself.ShiftY, UNITX * 4 + Myself.ShiftX + g_FScreenWidth, UNITY * 5 + Myself.ShiftY + g_FScreenHeight), MapSurface, FALSE);

  except
    DebugOutStr('104');
  end;

  if g_FScreenWidth = 1024 then
    defx := -UNITX * 4 - MySelf.ShiftX + AAX + 28
  else
    defx := -UNITX * 6 - MySelf.ShiftX + AAX + 14;

  if g_FScreenHeight = 768 then
    defy := -UNITY * 4 - MySelf.ShiftY
  else
    defy := -UNITY * 7 - MySelf.ShiftY;

  DefXX := defx;
  DefYY := defy;

  try
    m := defy - UNITY;
    for j := (Map.ClientRect.Top - Map.BlockTop) to (Map.ClientRect.Bottom - Map.BlockTop + LONGHEIGHT_IMAGE) do
    begin
      if j < 0 then
      begin
        Inc(m, UNITY);
        continue;
      end;
      n := defx - UNITX * 2;
      //*** 48*32 Ÿ���� ������Ʈ �׸���
      for i := (Map.ClientRect.Left - Map.BlockLeft - 2) to (Map.ClientRect.Right - Map.BlockLeft + 2) do
      begin
        if (i >= 0) and (i < LOGICALMAPUNIT * 3) and (j >= 0) and (j < LOGICALMAPUNIT * 3) then
        begin
          fridx := (Map.MArr[i, j].FrImg) and $7FFF;
          if fridx > 0 then
          begin
            ani := Map.MArr[i, j].AniFrame;
            wunit := Map.MArr[i, j].Area;
            if (ani and $80) > 0 then
            begin
              blend := TRUE;
              ani := ani and $7F;
            end;
            if ani > 0 then
            begin
              anitick := Map.MArr[i, j].anitick;
              fridx := fridx + (MainAniCount mod (ani + (ani * anitick))) div (1 + anitick);
            end;
            if (Map.MArr[i, j].DoorOffset and $80) > 0 then
            begin //����
              if (Map.MArr[i, j].DoorIndex and $7F) > 0 then  //������ ǥ�õ� �͸�
                fridx := fridx + (Map.MArr[i, j].DoorOffset and $7F); //���� ��
            end;
            fridx := fridx - 1;
               // ��ü �׸�
            DSurface := GetObjs(wunit, fridx);
            if DSurface <> nil then
            begin
              if (DSurface.Width = 48) and (DSurface.Height = 32) then
              begin
                mmm := m + UNITY - DSurface.Height;
                if (n + DSurface.Width > 0) and (n <= g_FScreenWidth) and (mmm + DSurface.Height > 0) and (mmm < drawingbottomline) then
                begin
                  ObjSurface.Draw(n, mmm, DSurface.ClientRect, DSurface, TRUE)
                end
                else
                begin
                  if mmm < drawingbottomline then
                  begin //���ʿ��ϰ� �׸��� ���� ����
                    ObjSurface.Draw(n, mmm, DSurface.ClientRect, DSurface, TRUE)
                  end;
                end;
              end;
            end;
          end;
        end;
        Inc(n, UNITX);
      end;
      Inc(m, UNITY);
    end;

   //���ٴڿ� �׷����� ����
    for k := 0 to GroundEffectList.Count - 1 do
    begin
      meff := TMagicEff(GroundEffectList[k]);
      //if j = (meff.Ry - Map.BlockTop) then begin
      meff.DrawEff(ObjSurface);
      if ViewFog then begin
         AddLight (meff.Rx, meff.Ry, 0, 0, meff.light, FALSE);
      end;
    end;

  except
    DebugOutStr('105');
  end;

  try
    m := defy - UNITY;
    for j := (Map.ClientRect.Top - Map.BlockTop) to (Map.ClientRect.Bottom - Map.BlockTop + LONGHEIGHT_IMAGE) do
    begin
      if j < 0 then
      begin
        Inc(m, UNITY);
        continue;
      end;
      n := defx - UNITX * 2;
      //*** ��������Ʈ �׸���
      for i := (Map.ClientRect.Left - Map.BlockLeft - 2) to (Map.ClientRect.Right - Map.BlockLeft + 2) do
      begin
        if (i >= 0) and (i < LOGICALMAPUNIT * 3) and (j >= 0) and (j < LOGICALMAPUNIT * 3) then
        begin
          fridx := (Map.MArr[i, j].FrImg) and $7FFF;
          if fridx > 0 then
          begin
            blend := FALSE;
            wunit := Map.MArr[i, j].Area;
               //���ϸ��̼�
            ani := Map.MArr[i, j].AniFrame;
            if (ani and $80) > 0 then
            begin
              blend := TRUE;
              ani := ani and $7F;
            end;
            if ani > 0 then
            begin
              anitick := Map.MArr[i, j].anitick;
              fridx := fridx + (MainAniCount mod (ani + (ani * anitick))) div (1 + anitick);
            end;
            if (Map.MArr[i, j].DoorOffset and $80) > 0 then
            begin //����
              if (Map.MArr[i, j].DoorIndex and $7F) > 0 then  //������ ǥ�õ� �͸�
                fridx := fridx + (Map.MArr[i, j].DoorOffset and $7F); //���� ��
            end;
            fridx := fridx - 1;
               // ��ü �׸�
            if not blend then
            begin
              DSurface := GetObjs(wunit, fridx);
              if DSurface <> nil then
              begin
                if (DSurface.Width <> 48) or (DSurface.Height <> 32) then
                begin
                  mmm := m + UNITY - DSurface.Height;
                  if (n + DSurface.Width > 0) and (n <= g_FScreenWidth) and (mmm + DSurface.Height > 0) and (mmm < drawingbottomline) then
                  begin
                    ObjSurface.Draw(n, mmm, DSurface.ClientRect, DSurface, TRUE)
                  end
                  else
                  begin
                    if mmm < drawingbottomline then
                    begin //���ʿ��ϰ� �׸��� ���� ����
                      ObjSurface.Draw(n, mmm, DSurface.ClientRect, DSurface, TRUE)
                    end;
                  end;
                end;
              end;
            end
            else
            begin
              DSurface := GetObjsEx(wunit, fridx, ax, ay);
              if DSurface <> nil then
              begin
                mmm := m + ay - 68; //UNITY - DSurface.Height;
                if (n > 0) and (mmm + DSurface.Height > 0) and (n + DSurface.Width < g_FScreenWidth) and (mmm < drawingbottomline) then
                begin
                  DrawBlend(ObjSurface, n + ax - 2, mmm, DSurface, 1);
                end
                else
                begin
                  if mmm < drawingbottomline then
                  begin //���ʿ��ϰ� �׸��� ���� ����
                    DrawBlend(ObjSurface, n + ax - 2, mmm, DSurface, 1);
                  end;
                end;
              end;
            end;
          end;

        end;
        Inc(n, UNITX);
      end;

      if (j <= (Map.ClientRect.Bottom - Map.BlockTop)) and (not BoServerChanging) then
      begin

         //*** �ٴڿ� ����� ���� ����
        for k := 0 to EventMan.EventList.Count - 1 do
        begin
          evn := TClEvent(EventMan.EventList[k]);
          if j = (evn.Y - Map.BlockTop) then
          begin
            evn.DrawEvent(ObjSurface, (evn.X - Map.ClientRect.Left) * UNITX + defx, m);
          end;
        end;

         //*** �ٴڿ� ������ ������ �׸���
        for k := 0 to DropedItemList.Count - 1 do
        begin
          pd := PTDropItem(DropedItemList[k]);
          if pd <> nil then
          begin

            if j = (pd.y - Map.BlockTop) then
            begin
              if pd.BoDeco then
                d := WDecoImg.Images[pd.Looks]
              else
                d := WDnItem.Images[pd.Looks];

              if d <> nil then
              begin
                ix := (pd.x - Map.ClientRect.Left) * UNITX + defx + SOFFX; // + actor.ShiftX;
                iy := m; // + actor.ShiftY;
                if pd.BoDeco then
                begin
                  WDecoImg.GetCachedImage(pd.Looks, px, py);
                  ImgPosX := ix + px;
                  ImgPosY := iy + py;
                end
                else
                begin
                  ImgPosX := ix + HALFX - (d.Width div 2);
                  ImgPosY := iy + HALFY - (d.Height div 2);
                end;
                if pd = FocusItem then
                begin
                  ObjSurface.Draw(ImgPosX, ImgPosY, d.ClientRect, d, TRUE);
                  DrawEffect(ObjSurface, ImgPosX, ImgPosY, d, ceBright, False);
                end
                else
                begin
                  ObjSurface.Draw(ImgPosX, ImgPosY, d.ClientRect, d, TRUE);
                end;
              end;
            end;
          end;
        end;
         //*** ĳ���� �׸���
        for k := 0 to ActorList.Count - 1 do
        begin
          actor := ActorList[k];
          if actor.Race = 81 then
          begin  // ����(õ��)
            if actor.State and $00800000 = 0 then
            begin//������ �ƴϸ�
              actor.DrawChr(ObjSurface, (actor.Rx - Map.ClientRect.Left) * UNITX + defx, (actor.Ry - Map.ClientRect.Top - 1) * UNITY + defy, TRUE, FALSE);
            end;
          end;

          if (j = actor.Ry - Map.BlockTop - actor.DownDrawLevel) then
          begin
            actor.SayX := (actor.Rx - Map.ClientRect.Left) * UNITX + defx + actor.ShiftX + 24;
            if actor.Death then
              actor.SayY := m + UNITY + actor.ShiftY + 16 - 60 + (actor.DownDrawLevel * UNITY)
            else
              actor.SayY := m + UNITY + actor.ShiftY + 16 - 95 + (actor.DownDrawLevel * UNITY);
            actor.DrawChr(ObjSurface, (actor.Rx - Map.ClientRect.Left) * UNITX + defx, m + (actor.DownDrawLevel * UNITY), FALSE, TRUE);
          end;
        end;
        for k := 0 to FlyList.Count - 1 do
        begin
          meff := TMagicEff(FlyList[k]);
          if j = (meff.Ry - Map.BlockTop) then
            meff.DrawEff(ObjSurface);
        end;

      end;
      Inc(m, UNITY);
    end;
  except
    DebugOutStr('106');
  end;

  try
   if ViewFog then begin
      m := defy - UNITY*4;
      for j:=(Map.ClientRect.Top - Map.BlockTop - 4) to (Map.ClientRect.Bottom - Map.BlockTop + LONGHEIGHT_IMAGE) do begin
         if j < 0 then begin Inc (m, UNITY); continue; end;
         n := defx-UNITX*5;
         //��� ���� �׸���
         for i:=(Map.ClientRect.Left - Map.BlockLeft-5) to (Map.ClientRect.Right - Map.BlockLeft+5) do begin
            if (i >= 0) and (i < LOGICALMAPUNIT*3) and (j >= 0) and (j < LOGICALMAPUNIT*3) then begin
               idx := Map.MArr[i, j].Light;
               if idx > 0 then begin
                  AddLight (i+Map.BlockLeft, j+Map.BlockTop, 0, 0, idx, FALSE);
               end;
            end;
            Inc (n, UNITX);
         end;
         Inc (m, UNITY);
      end;

      //ĳ���� ���� �׸���
      if ActorList.Count > 0 then begin
         for k:=0 to ActorList.Count-1 do begin
            actor := ActorList[k];
            if (actor = Myself) or (actor.Light > 0) then
               AddLight (actor.Rx, actor.Ry, actor.ShiftX, actor.ShiftY, actor.Light, actor=Myself);
         end;
      end else begin
         if Myself <> nil then
            AddLight (Myself.Rx, Myself.Ry, Myself.ShiftX, Myself.ShiftY, Myself.Light, TRUE);
      end;
   end;
  except
    DebugOutStr('107');
  end;

  if not BoServerChanging then
  begin
    try
      if (MagicTarget <> nil) then
      begin
//         if IsValidActor (MagicTarget) and (MagicTarget <> Myself) then
        if IsValidActor(MagicTarget) and (MagicTarget <> Myself) and (actor.Race <> 81) then
          if MagicTarget.State and $00800000 = 0 then //������ �ƴϸ�
            MagicTarget.DrawChr(ObjSurface, (MagicTarget.Rx - Map.ClientRect.Left) * UNITX + defx, (MagicTarget.Ry - Map.ClientRect.Top - 1) * UNITY + defy, TRUE, FALSE);
      end;

      //**** ���ΰ� ĳ���� �׸���
//      if not CheckBadMapMode then
//         if ( Myself.State and $00800000 = 0 ) then //������ �ƴϸ� 1������϶����� Ǯ����
//         begin
      Myself.DrawChr(ObjSurface, (Myself.Rx - Map.ClientRect.Left) * UNITX + defx, (Myself.Ry - Map.ClientRect.Top - 1) * UNITY + defy, TRUE, FALSE);
//         end;
         
      //**** ���콺�� ���ٴ�� �ִ� ĳ����
      if (FocusCret <> nil) then
      begin
//         if IsValidActor (FocusCret) and (FocusCret <> Myself) then
        if IsValidActor(FocusCret) and (FocusCret <> Myself) and (actor.Race <> 81) then
          if FocusCret.State and $00800000 = 0 then //������ �ƴϸ�
            FocusCret.DrawChr(ObjSurface, (FocusCret.Rx - Map.ClientRect.Left) * UNITX + defx, (FocusCret.Ry - Map.ClientRect.Top - 1) * UNITY + defy, TRUE, FALSE);
      end;
    except
      DebugOutStr('108');
    end;
  end;

  try
   //**** ���� ȿ��
    for k := 0 to ActorList.Count - 1 do
    begin
      actor := ActorList[k];
      actor.DrawEff(ObjSurface, (actor.Rx - Map.ClientRect.Left) * UNITX + defx, (actor.Ry - Map.ClientRect.Top - 1) * UNITY + defy);
    end;
    for k := 0 to EffectList.Count - 1 do
    begin
      meff := TMagicEff(EffectList[k]);
      //if j = (meff.Ry - Map.BlockTop) then begin
      meff.DrawEff(ObjSurface);
      if ViewFog then begin
         AddLight (meff.Rx, meff.Ry, 0, 0, meff.Light, FALSE);
      end;
    end;
   if ViewFog then begin //��ʾ�ڰ��й�
      for k:=0 to EventMan.EventList.Count-1 do begin
         evn := TClEvent (EventMan.EventList[k]);
         if evn.light > 0 then
            AddLight (evn.X, evn.Y, 0, 0, evn.light, FALSE);
      end;
   end;
  except
    DebugOutStr('109');
  end;

   //������Ʒ����
  try
    for k := 0 to DropedItemList.Count - 1 do
    begin
      pd := PTDropItem(DropedItemList[k]);

      if (pd <> nil) and (not pd.BoDeco) then
      begin
        if GetTickCount - pd.FlashTime > 5 * 1000 then
        begin //��˸
          pd.FlashTime := GetTickCount;
          pd.BoFlash := TRUE;
          pd.FlashStepTime := GetTickCount;
          pd.FlashStep := 0;
        end;
        ix := (pd.x - Map.ClientRect.Left) * UNITX + defx + SOFFX;
        iy := (pd.y - Map.ClientRect.Top - 1) * UNITY + defy + SOFFY;

        if pd.BoFlash then
        begin
          if GetTickCount - pd.FlashStepTime >= 20 then
          begin
            pd.FlashStepTime := GetTickCount;
            Inc(pd.FlashStep);
          end;

          if (pd.FlashStep >= 0) and (pd.FlashStep < 10) then
          begin
            DSurface := WProgUse.GetCachedImage(FLASHBASE + pd.FlashStep, ax, ay);
            if DSurface <> nil then
              DrawBlend(ObjSurface, ix + ax, iy + ay, DSurface, 1);
          end
          else
            pd.BoFlash := FALSE;
        end;
      end;
    end;
  except
    DebugOutStr('110');
  end;

  if ViewFog and (not MySelf.Death) then
    g_DXCanvas.DrawPart(LigSurface,0,0,0,0,g_FScreenWidth, g_FScreenHeight, $FFFFFFFF, blend_Multiply);


  try
    if ViewFog then
    begin
     //   DrawFog (ObjSurface, PFogScreen, FogWidth);
      ObjSurface.Draw(SOFFX, SOFFY, ObjSurface.ClientRect, ObjSurface, FALSE);
    end
    else
    begin
//        if Myself.Death then
//           DrawEffect (0, 0, ObjSurface.Width, ObjSurface.Height, ObjSurface, ceGrayScale);
      ObjSurface.Draw(SOFFX, SOFFY, ObjSurface.ClientRect, ObjSurface, FALSE);
    end;
  except
    DebugOutStr('111');
  end;
  exit;
  if BoDrawMiniMap then
  begin
    if ViewMiniMapStyle > 0 then
    begin
      if ViewMiniMapStyle = 1 then
      begin
        DrawMiniMap(ObjSurface, TRUE);
//        FrmDlg.DGeneralMap.Visible := FALSE;
      end
      else if ViewMiniMapStyle = 2 then
      begin
        DrawMiniMap(ObjSurface, FALSE);
//        FrmDlg.DGeneralMap.Visible := FALSE;
      end
      else if ViewMiniMapStyle = 3 then
      begin
        DrawMiniMap(ObjSurface, TRUE);
//        FrmDlg.DGeneralMap.Visible := True;
      end;
    end;

    if ViewGeneralMapStyle > 0 then
    begin
      if ViewGeneralMapStyle = 1 then
      begin
        if MiniMapIndex in [100, 101, 102, 104, 105, 120, 160, 190] then
          DrawGeneralMap(ObjSurface, TRUE)
        else
        begin
          ViewGeneralMapStyle := 0;
          DScreen.AddChatBoardString('��ǰ��ͼû�����ô��ͼ', clGreen, clWhite);
//         else if MiniMapIndex in [134,101,102,104,105,160,190] then DrawGeneralMap2 (MSurface, FALSE)
        end;
      end
      else
      begin
        if MiniMapIndex in [100, 101, 102, 104, 105, 120, 160, 190] then
          DrawGeneralMap(ObjSurface, FALSE)
        else
        begin
          ViewGeneralMapStyle := 0;
          DScreen.AddChatBoardString('Only field map will be displayed.', clGreen, clWhite);
//            DScreen.AddChatBoardString ('�ֶ�ӳ��Ϳ���.', clGreen, clWhite);
        end;
      end;
    end;
  end;
end;

procedure TPlayScene.MagicSurface(Sender: TObject);
var
  k: integer;
  meff: TMagicEff;
begin
  MagSurface.Draw(SOFFX, SOFFY, ObjSurface.ClientRect, ObjSurface, FALSE);
  for k := 0 to EffectList.count - 1 do
  begin
    meff := TMagicEff(EffectList[k]);
    meff.DrawEff(ObjSurface);
  end;
end;

procedure TPlayScene.Lost;
begin
  if MapSurface <> nil then
    MapSurface.Lost;
  if ObjSurface <> nil then
    ObjSurface.Lost;
  if MagSurface <> nil then
    MagSurface.Lost;
end;

function TPlayScene.CanDrawTileMap: Boolean;
begin
  Result := False;
  with Map do
    if (ClientRect.Left = OldClientRect.Left) and (ClientRect.Top = OldClientRect.Top) then
      Exit;
  if not g_boDrawTileMap then
    Exit;
  Result := True;
end;
{-------------------------------------------------------}

//cx, cy, tx, ty : ���� ��ǥ

procedure TPlayScene.NewMagic(aowner: TActor; magid, magnumb, cx, cy, tx, ty, targetcode: integer; mtype: TMagicType; Recusion: Boolean; anitime: integer; var bofly: Boolean);
var
  i, scx, scy, sctx, scty, effnum: integer;
  meff: TMagicEff;
  target: TActor;
  wimg: TWMImages;
begin
  if (mtype = mtThunder) and ((magnumb = 8) or (magnumb = 9)) then

  else if not BoViewEffect then
  begin
    meff := nil;
    Exit;
  end;
  bofly := FALSE;
  if not (magid in [SM_DRAGON_LIGHTING, 70..74, 111, MAGIC_JW_EFFECT1, MAGIC_SOULBALL_ATT3_1..MAGIC_SOULBALL_ATT3_5, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_2]) then //�߻� ������ �ߺ���. // FireDragon
    for i := 0 to EffectList.Count - 1 do
      if TMagicEff(EffectList[i]).ServerMagicId = magid then
        exit; //�̹� ����..
  ScreenXYfromMCXY(cx, cy, scx, scy);
  ScreenXYfromMCXY(tx, ty, sctx, scty);
  if magnumb > 0 then
    GetEffectBase(magnumb - 1, 0, wimg, effnum)
  else
    effnum := -magnumb;
  target := FindActor(targetcode);

  meff := nil;
  case mtype of
    mtReady, mtFly, mtFlyAxe:
      begin
        meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
        meff.TargetActor := target;
        meff.ImgLib := wimg;
        bofly := TRUE;
      end;
    mtFlyBug:
      begin
        meff := TFlyingBug.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
        meff.TargetActor := target;
            //if effnum = 38 then
            //   meff.ImgLib := WMagic2;
        bofly := TRUE;
      end;

    mtExplosion:
      case magnumb of
        18:
          begin //��ȥ��
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 1570;
            meff.TargetActor := target;
            meff.NextFrameTime := 80;
          end;
        21:
          begin //������
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 1660;
            meff.TargetActor := nil; //target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 20;
            meff.Light := 3;
          end;
        26:
          begin //Ž���Ŀ�
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 3990;
            meff.TargetActor := target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 10;
            meff.Light := 2;
          end;
        27:
          begin //��ȸ����
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 1800;
            meff.TargetActor := nil; //target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 10;
            meff.Light := 3;
          end;
        30:
          begin //������ȸ
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 3930;
            meff.TargetActor := target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 16;
            meff.Light := 3;
          end;
        31:
          begin //����ǳ
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 3850;
            meff.TargetActor := nil; //target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 20;
            meff.Light := 3;
          end;
        40:
          begin //��ȭ��
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 620;
            meff.TargetActor := target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 10;
            meff.Light := 3;
            meff.ImgLib := wimg;
          end;
        47:
          begin //���°�
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 1010;
            meff.TargetActor := target;
            meff.NextFrameTime := 120;
            meff.ExplosionFrame := 10;
            meff.Light := 2;
            meff.ImgLib := wimg;
          end;
        48:
          begin //������
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 1060;
            meff.TargetActor := target;
            meff.NextFrameTime := 80;
            meff.ExplosionFrame := 20;
            meff.Light := 2;
            meff.ImgLib := wimg;
          end;
        90:
          begin // �뼮�� ���� FireDragon
            wimg := WDragonImg;
            meff.ImgLib := wimg;
            effnum := 350;
            meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
            meff.MagExplosionBase := 350;
            meff.ExplosionFrame := 30;
            meff.TargetActor := nil; //target;
            meff.NextFrameTime := 100;
            meff.Light := 3;
          end;

      else
        begin  //�Ȼָ�..
          meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
          meff.TargetActor := target;
          meff.NextFrameTime := 80;
        end;
      end;
    mtFireWind:
      meff := nil;  //��Ч��
    mtFireGun: //��������
      meff := TFireGunEffect.Create(930, scx, scy, sctx, scty);
    mtThunder:
      begin
        if magnumb = SM_DRAGON_LIGHTING then
        begin
          meff := TThuderEffectEx.Create(230, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 5;
//               meff.MagExplosionBase := 250;
          meff.ImgLib := WDragonImg;
          meff.NextFrameTime := 80;
        end
        else if magnumb = MAGIC_DUN_THUNDER then
        begin
          meff := TThuderEffectEx.Create(400, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 5;
          meff.ImgLib := WDragonImg;
          meff.NextFrameTime := 100;
        end
        else if magnumb = MAGIC_DUN_FIRE1 then
        begin
          meff := TThuderEffectEx.Create(440, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WDragonImg;
          meff.NextFrameTime := 90;
        end
        else if magnumb = MAGIC_DUN_FIRE2 then
        begin
          meff := TThuderEffectEx.Create(470, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 10;
          meff.ImgLib := WDragonImg;
          meff.NextFrameTime := 90;
        end
        else if magnumb = MAGIC_DRAGONFIRE then
        begin
          meff := TThuderEffectEx.Create(200, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WDragonImg;
          meff.NextFrameTime := 120;
        end
        else if magnumb = MAGIC_FIREBURN then
        begin
          meff := TThuderEffectEx.Create(350, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 35;
          meff.ImgLib := WDragonImg;
          meff.NextFrameTime := 100;
        end
        else if magnumb = MAGIC_SERPENT_1 then
        begin
          meff := TThuderEffectEx.Create(1250, sctx, scty, nil, magnumb); //target);
          meff.ExplosionFrame := 15;
          meff.ImgLib := WMagic2;
          meff.NextFrameTime := 90;
        end
        else if magnumb = MAGIC_JW_EFFECT1 then
        begin
          meff := TThuderEffectEx.Create(1160, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 18;
          meff.ImgLib := WMagic2;
          meff.NextFrameTime := 120;
        end
        else if magnumb = MAGIC_FOX_THUNDER then
        begin
          meff := TThuderEffectEx.Create(780, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 9;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
        end
        else if magnumb = MAGIC_FOX_FIRE1 then
        begin
          meff := TThuderEffectEx.Create(790, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 10;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
        end
        else if magnumb = MAGIC_SOULBALL_ATT2 then
        begin
          meff := TThuderEffectEx.Create(2120, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
        end
        else if magnumb = MAGIC_SOULBALL_ATT3_1 then
        begin
          meff := TThuderEffectEx.Create(2160, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else if magnumb = MAGIC_SOULBALL_ATT3_2 then
        begin
          meff := TThuderEffectEx.Create(2180, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else if magnumb = MAGIC_SOULBALL_ATT3_3 then
        begin
          meff := TThuderEffectEx.Create(2200, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else if magnumb = MAGIC_SOULBALL_ATT3_4 then
        begin
          meff := TThuderEffectEx.Create(2220, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else if magnumb = MAGIC_SOULBALL_ATT3_5 then
        begin
          meff := TThuderEffectEx.Create(2240, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 20;
          meff.ImgLib := WMon24Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else if magnumb = MAGIC_KINGTURTLE_ATT2_1 then
        begin
          meff := TThuderEffectEx.Create(3010, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 12;
          meff.ImgLib := WMon25Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else if magnumb = MAGIC_KINGTURTLE_ATT2_2 then
        begin
          meff := TThuderEffectEx.Create(3030, sctx, scty, nil, magnumb);
          meff.ExplosionFrame := 12;
          meff.ImgLib := WMon25Img;
          meff.NextFrameTime := 100;
          meff.Light := 1;
        end
        else
        begin
          meff := TThuderEffect.Create(10, sctx, scty, nil); //target);
          meff.ExplosionFrame := 6;
          meff.ImgLib := WMagic2;
        end
      end;
      // 2003/03/15 �űԹ��� �߰�
    mtFireThunder:
      begin
        meff := TThuderEffect.Create(140, sctx, scty, nil); //target);
        meff.ExplosionFrame := 10;
        meff.ImgLib := WMagic2;
      end;

    mtLightingThunder:
      meff := TLightingThunder.Create(970, scx, scy, sctx, scty, target);
    mtExploBujauk:
      begin
        case magnumb of
          10:
            begin  //�����
              meff := TExploBujaukEffect.Create(1160, magnumb, scx, scy, sctx, scty, target);
              meff.MagExplosionBase := 1360;
            end;
          17:
            begin  //������
              meff := TExploBujaukEffect.Create(1160, magnumb, scx, scy, sctx, scty, target);
              meff.MagExplosionBase := 1540;
            end;
          49:
            begin  //��ȥ��
              meff := TExploBujaukEffect.Create(1160, magnumb, scx, scy, sctx, scty, target);
              meff.MagExplosionBase := 1110;
              meff.ExplosionFrame := 10;
//                  meff.ImgLib := WMagic2;
            end;
          MAGIC_FOX_FIRE2:
            begin  //����������:�����
              meff := TExploBujaukEffect.Create(1160, magnumb, scx, scy, sctx, scty, target);
              meff.MagExplosionBase := 1320;
              meff.ExplosionFrame := 10;
            end;
          MAGIC_FOX_CURSE:
            begin  //����������:���ּ�
              meff := TExploBujaukEffect.Create(1160, magnumb, scx, scy, sctx, scty, target);
              meff.MagExplosionBase := 1330;
              meff.ExplosionFrame := 20;
            end;
        end;
        bofly := TRUE;
      end;
      // 2003/03/04
    mtGroundEffect:
      begin
        meff := TMagicEff.Create(magid, effnum, scx, scy, sctx, scty, mtype, Recusion, anitime);
        if meff <> nil then
        begin
          case magnumb of
            32:
              begin  //������1
                meff.ImgLib := WMon21Img;
                meff.MagExplosionBase := 3580;
                meff.TargetActor := target;
                meff.Light := 3;
                meff.ExplosionFrame := 20;
              end;
            37:
              begin
                meff.ImgLib := WMon22Img;
                meff.MagExplosionBase := 3520;
                meff.TargetActor := target;
                meff.Light := 5;
                meff.ExplosionFrame := 20;
              end;
            MAGIC_SOULBALL_ATT1:
              begin
                meff.ImgLib := WMon24Img;
                meff.MagExplosionBase := 2140;
                meff.TargetActor := target;
                meff.Light := 5;
                meff.ExplosionFrame := 20;
              end;
            MAGIC_SIDESTONE_ATT1:
              begin
                meff.ImgLib := WMon24Img;
                meff.MagExplosionBase := 1440;
                meff.TargetActor := target;
                meff.Light := 4;
                meff.ExplosionFrame := 10;
                meff.NextFrameTime := 150;
              end;
            MAGIC_KINGTURTLE_ATT1:
              begin
                meff.ImgLib := WMon25Img;
                meff.MagExplosionBase := 2990;
                meff.TargetActor := target;
                meff.Light := 5;
                meff.ExplosionFrame := 10;
              end;
            MAGIC_KINGTURTLE_ATT3:
              begin
                meff.ImgLib := WMon25Img;
                meff.MagExplosionBase := 3060;
                meff.TargetActor := target;
                meff.Light := 5;
                meff.ExplosionFrame := 10;
              end;
          end;
        end;
//          bofly := TRUE;
      end;
    mtBujaukGroundEffect:
      begin
        meff := TBujaukGroundEffect.Create(1160, magnumb, scx, scy, sctx, scty);
        case magnumb of
          11:
            meff.ExplosionFrame := 16; //�����
          12:
            meff.ExplosionFrame := 16; //��ʥս����
          46:
            meff.ExplosionFrame := 24; //������
        end;
        bofly := TRUE;
      end;
    mtKyulKai:
      begin
        meff := nil; //TKyulKai.Create (1380, scx, scy, sctx, scty);
      end;
  end;
  if meff = nil then
    exit;

  meff.TargetRx := tx;
  meff.TargetRy := ty;
  if meff.TargetActor <> nil then
  begin
    meff.TargetRx := TActor(meff.TargetActor).XX;
    meff.TargetRy := TActor(meff.TargetActor).YY;
  end;
  meff.MagOwner := aowner;
  EffectList.Add(meff);
end;

procedure TPlayScene.DelMagic(magid: integer);
var
  i: integer;
begin
  for i := 0 to EffectList.Count - 1 do
  begin
    if TMagicEff(EffectList[i]).ServerMagicId = magid then
    begin
      TMagicEff(EffectList[i]).Free;
      EffectList.Delete(i);
      break;
    end;
  end;
end;

//cx, cy, tx, ty : ӳ�������
function TPlayScene.NewFlyObject(aowner: TActor; cx, cy, tx, ty, targetcode: integer; mtype: TMagicType): TMagicEff;
var
  i, scx, scy, sctx, scty: integer;
  meff: TMagicEff;
begin
  ScreenXYfromMCXY(cx, cy, scx, scy);
  ScreenXYfromMCXY(tx, ty, sctx, scty);
  case mtype of
    mtFlyArrow:
      meff := TFlyingArrow.Create(1, 1, scx, scy, sctx, scty, mtype, TRUE, 0);
    mtFlyBug:
      meff := TFlyingBug.Create(1, 1, scx, scy, sctx, scty, mtype, TRUE, 0);
    mtFireBall:
      meff := TFlyingFireBall.Create(1, 1, scx, scy, sctx, scty, mtype, TRUE, 0);
  else
    meff := TFlyingAxe.Create(1, 1, scx, scy, sctx, scty, mtype, TRUE, 0);
  end;
  meff.TargetRx := tx;
  meff.TargetRy := ty;
  meff.TargetActor := FindActor(targetcode);
  meff.MagOwner := aowner;
  FlyList.Add(meff);
  Result := meff;
end;

//������ ������ ����ó�� ��� ������ ����
//effnum: �� ��ȣ���� Base�� �� �ٸ���.
{function  NewStaticMagic (aowner: TActor; tx, ty, targetcode, effnum: integer);
var
   i, scx, scy, sctx, scty, effbase: integer;
   meff: TMagicEff;
begin
   ScreenXYfromMCXY (cx, cy, scx, scy);
   ScreenXYfromMCXY (tx, ty, sctx, scty);
   case effnum of
      1: effbase := 340;   //������ ����Ʈ���� ���� ��ġ
      else exit;
   end;

   meff := TLightingEffect.Create (effbase, 1, 1, scx, scy, sctx, scty, mtype, TRUE, 0);
   meff.TargetRx := tx;
   meff.TargetRy := ty;
   meff.TargetActor := FindActor (targetcode);
   meff.MagOwner := aowner;
   FlyList.Add (meff);
   Result := meff;
end;  }

{-------------------------------------------------------}

//����ӳ�䵽ϸ������
{procedure TPlayScene.ScreenXYfromMCXY (cx, cy: integer; var sx, sy: integer);
begin
   if Myself = nil then exit;
   sx := -UNITX*2 - Myself.ShiftX + AAX + 14 + (cx - Map.ClientRect.Left) * UNITX + UNITX div 2;
   sy := -UNITY*3 - Myself.ShiftY + (cy - Map.ClientRect.Top) * UNITY + UNITY div 2;
end; }

procedure TPlayScene.ScreenXYfromMCXY(cx, cy: integer; var sx, sy: integer);
begin
  if Myself = nil then
    exit;
   if g_FScreenWidth = 1024 then sx := (cx-Myself.Rx)*UNITX + 476 + UNITX div 2 - Myself.ShiftX
   else sx := (cx-Myself.Rx)*UNITX + 364 + UNITX div 2 - Myself.ShiftX;

   if g_FScreenHeight = 768 then sy := (cy-Myself.Ry)*UNITY + 320 + UNITY div 2 - Myself.ShiftY
   else sy := (cy-Myself.Ry)*UNITY + 224 + UNITY div 2 - Myself.ShiftY;
end;

//��Ļ���� mx, myת����ccx, ccy��ͼ����
procedure TPlayScene.CXYfromMouseXY(mx, my: integer; var ccx, ccy: integer);
begin
  if Myself = nil then
    exit;
  if g_FScreenWidth = 1024 then ccx := Round((mx - 476 + MySelf.ShiftX - UNITX div 2) / UNITX) + MySelf.Rx
  else ccx := Round((mx - 364 + MySelf.ShiftX - UNITX div 2) / UNITX) + MySelf.Rx;

  if g_FScreenHeight = 768 then ccy := Round((my - 320 + MySelf.ShiftY - UNITY div 2) / UNITY) + MySelf.Ry
  else ccy := Round((my - 224 + MySelf.ShiftY - UNITY div 2) / UNITY) + MySelf.Ry;

end;

procedure TPlayScene.CXYfromMouseXYMid(mx, my: integer; var ccx, ccy: integer); // ħ����׼ȷ..
begin
  if Myself = nil then
    exit;
  ccx := UpInt((mx - 364 + Myself.ShiftX - UNITX) / UNITX) + Myself.Rx;
//   ccy := UpInt((my - (192 -20)+ Myself.ShiftY - UNITY) / UNITY) + Myself.Ry;
  ccy := UpInt((my - (192 - 20) + Myself.ShiftY - UNITY) / UNITY) + Myself.Ry - 1;
end;

//��Ļ����Ľ�ɫ, ������Ϊ��λѡ��..
function TPlayScene.GetCharacter(x, y, wantsel: integer; var nowsel: integer; liveonly: Boolean): TActor;
var
  k, i, ccx, ccy, dx, dy: integer;
  a: TActor;
begin
  Result := nil;
  nowsel := -1;
  CXYfromMouseXY(x, y, ccx, ccy);
  for k := ccy + 8 downto ccy - 1 do
  begin
    for i := ActorList.Count - 1 downto 0 do
      if TActor(ActorList[i]) <> Myself then
      begin
        a := TActor(ActorList[i]);
        if (not liveonly or not a.Death) and (a.BoHoldPlace) and (a.Visible) then
        begin
          if a.YY = k then
          begin
                  //����ķ�Χѡ��
            dx := (a.Rx - Map.ClientRect.Left) * UNITX + DefXX + a.px + a.ShiftX;
            dy := (a.Ry - Map.ClientRect.Top - 1) * UNITY + DefYY + a.py + a.ShiftY;
            if a.CheckSelect(x - dx, y - dy) then
            begin
              Result := a;
              Inc(nowsel);
              if nowsel >= wantsel then
                exit;
            end;
          end;
        end;
      end;
  end;
end;

//ȡ�������ָ����Ľ�ɫ....
function TPlayScene.GetAttackFocusCharacter(x, y, wantsel: integer; var nowsel: integer; liveonly: Boolean): TActor;
var
  k, i, ccx, ccy, dx, dy, centx, centy: integer;
  a: TActor;
begin
  Result := GetCharacter(x, y, wantsel, nowsel, liveonly);
  if Result = nil then
  begin
    nowsel := -1;
    CXYfromMouseXY(x, y, ccx, ccy);
    for k := ccy + 8 downto ccy - 1 do
    begin
      for i := ActorList.Count - 1 downto 0 do
        if TActor(ActorList[i]) <> Myself then
        begin
          a := TActor(ActorList[i]);
          if (not liveonly or not a.Death) and (a.BoHoldPlace) and (a.Visible) then
          begin
            if a.YY = k then
            begin
                     //
              dx := (a.Rx - Map.ClientRect.Left) * UNITX + DefXX + a.px + a.ShiftX;
              dy := (a.Ry - Map.ClientRect.Top - 1) * UNITY + DefYY + a.py + a.ShiftY;
              if a.CharWidth > 40 then
                centx := (a.CharWidth - 40) div 2
              else
                centx := 0;
              if a.CharHeight > 70 then
                centy := (a.CharHeight - 70) div 2
              else
                centy := 0;
              if (x - dx >= centx) and (x - dx <= a.CharWidth - centx) and (y - dy >= centy) and (y - dy <= a.CharHeight - centy) then
              begin
                Result := a;
                Inc(nowsel);
                if nowsel >= wantsel then
                  exit;
              end;
            end;
          end;
        end;
    end;
  end;
end;

function TPlayScene.IsSelectMyself(x, y: integer): Boolean;
var
  k, i, ccx, ccy, dx, dy: integer;
begin
  Result := FALSE;
  CXYfromMouseXY(x, y, ccx, ccy);
  for k := ccy + 2 downto ccy - 1 do
  begin
    if Myself.YY = k then
    begin
         //����ķ�Χѡ��
      dx := (Myself.Rx - Map.ClientRect.Left) * UNITX + DefXX + Myself.px + Myself.ShiftX;
      dy := (Myself.Ry - Map.ClientRect.Top - 1) * UNITY + DefYY + Myself.py + Myself.ShiftY;
      if Myself.CheckSelect(x - dx, y - dy) then
      begin
        Result := TRUE;
        exit;
      end;
    end;
  end;
end;

function TPlayScene.GetDropItems(x, y: integer; var inames: string): PTDropItem; //��Ļ�������
var
  k, i, ccx, ccy, ssx, ssy, dx, dy: integer;
  d: PTDropItem;
  s: TDXTexture;
  c: byte;
begin
  Result := nil;
  CXYfromMouseXY(x, y, ccx, ccy);
  ScreenXYfromMCXY(ccx, ccy, ssx, ssy);
  dx := x - ssx;
  dy := y - ssy;
  inames := '';
  for i := 0 to DropedItemList.Count - 1 do
  begin
    d := PTDropItem(DropedItemList[i]);
    if (d.X = ccx) and (d.Y = ccy) then
    begin
      if d.BoDeco then
        s := WDecoImg.Images[d.Looks]
      else
        s := WDnItem.Images[d.Looks];
      if s = nil then
        continue;
      dx := (x - ssx) + (s.Width div 2) - 3;
      dy := (y - ssy) + (s.Height div 2);
      c := s.Pixels[dx, dy];
      if (c <> 0) or d.BoDeco then
      begin  //ׯ԰װ�� Deco��Ŀ������
        if Result = nil then
          Result := d;
        inames := inames + d.Name + '\';
            //break;
      end;
    end;
  end;
end;

procedure TPlayScene.DropItemsShow(dsurface: TDXTexture);
var
  i, k, mx, my, HintX, HintY, HintWidth, HintHeight: integer;
  d: PTDropItem;
  dds: TDXTexture;
  HITNTTRect: TRect;
  // // �������������ȡ��TAB��ʾ��Ʒ�ı�����ɫ������������λָ�Ĭ��TAB��ʾ
begin
//   FrmMain.Canvas.Font.Size := 8;
//   FrmMain.DxDraw1.Surface.Canvas.Font.Size := 8;
//  dds := WProgUse.Images[394];
//  for i := 0 to DropedItemList.Count - 1 do
//  begin
//    d := PTDropItem(DropedItemList[i]);
//    if d <> nil then
//    begin
//      ScreenXYfromMCXY(d.X, d.Y, mx, my);
////         if my > 460 then Continue;
//      if dds <> nil then
//      begin
//        HintWidth := FrmMain.Canvas.TextWidth(d.Name) + 4 * 2;
//        if HintWidth > dds.Width then
//          HintWidth := dds.Width;
//        HintHeight := (FrmMain.Canvas.TextHeight('A') + 1) + 3 * 2;
//
//        HITNTTRect.Left := 0;
//        HITNTTRect.Top := 0;
//        HITNTTRect.Right := HintWidth;
//        HITNTTRect.Bottom := HintHeight;
//        DrawBlendR(dsurface, mx + 2 - ((Length(d.Name) div 2) * 6), my - 26 - 3, HITNTTRect, dds, 0);
//
//           // DrawBlendEx (FrmMain.DxDraw1.Surface, mx+2-((Length(d.Name) div 2)*6), my-26-3, dds, 0, 0, HintWidth, HintHeight, 0);
//      end;
//    end;
//  end;               // �������������ȡ��TAB��ʾ��Ʒ�ı�����ɫ������������λָ�Ĭ��TAB��ʾ

//   SetBkMode (FrmMain.DxDraw1.Surface.Canvas.Handle, TRANSPARENT);
//   FrmMain.DxDraw1.Surface.Canvas.Font.Color := clWhite;

  for k := 0 to DropedItemList.Count - 1 do
  begin
    d := PTDropItem(DropedItemList[k]);
    if d <> nil then
    begin
      ScreenXYfromMCXY(d.X, d.Y, mx, my);
//         if my > 460 then Continue;
      g_DXCanvas.TextOut(mx + 2 - ((Length(d.Name) div 2) * 6) + 4, my - 26, d.Name, clWhite);
    end;
  end;
//   FrmMain.Canvas.Font.Size := 9;
//   FrmMain.DxDraw1.Surface.Canvas.Font.Size := 9;
//   FrmMain.DxDraw1.Surface.Canvas.Release;
end;

function TPlayScene.CanRun(sx, sy, ex, ey: integer): Boolean;
var
  ndir, rx, ry: integer;
begin
  ndir := GetNextDirection(sx, sy, ex, ey);
  rx := sx;
  ry := sy;
  GetNextPosXY(ndir, rx, ry);
  if CanWalk(rx, ry) and CanWalk(ex, ey) then
    Result := TRUE
  else
    Result := FALSE;
end;

function TPlayScene.CanWalk(mx, my: integer): Boolean;
begin
  Result := FALSE;
  if Map.CanMove(mx, my) then
    Result := not CrashMan(mx, my);
end;

function TPlayScene.CrashMan(mx, my: integer): Boolean;
var
  i: integer;
  a: TActor;
begin
  Result := FALSE;
  for i := 0 to ActorList.Count - 1 do
  begin
    a := TActor(ActorList[i]);
    if (a.Visible) and (a.BoHoldPlace) and (not a.Death) and (a.XX = mx) and (a.YY = my) then
    begin
      Result := TRUE;
      break;
    end;
  end;
end;

function TPlayScene.CanFly(mx, my: integer): Boolean;
begin
  Result := Map.CanFly(mx, my);
end;


{------------------------ Actor ------------------------}

function TPlayScene.FindActor(id: integer): TActor;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to ActorList.Count - 1 do
  begin
    if TActor(ActorList[i]).RecogId = id then
    begin
      Result := TActor(ActorList[i]);
      break;
    end;
  end;
end;

function TPlayScene.FindActorXY(x, y: integer): TActor;  //�� ��ǥ�� actor ����
var
  i: integer;
begin
  Result := nil;
  for i := 0 to ActorList.Count - 1 do
  begin
    if (TActor(ActorList[i]).XX = x) and (TActor(ActorList[i]).YY = y) then
    begin
      Result := TActor(ActorList[i]);
      if not Result.Death and Result.Visible and Result.BoHoldPlace then
        break;
    end;
  end;
end;

function TPlayScene.IsValidActor(actor: TActor): Boolean;
var
  i: integer;
begin
  Result := FALSE;
  for i := 0 to ActorList.Count - 1 do
  begin
    if TActor(ActorList[i]) = actor then
    begin
      Result := TRUE;
      break;
    end;
  end;
end;

function TPlayScene.NewActor(chrid: integer; cx: word; //x
  cy: word; //y
  cdir: word; cfeature: integer; //race, hair, dress, weapon
  cstate: integer): TActor;
var
  i: integer;
  actor: TActor;
  pm: PTMonsterAction;
begin
  for i := 0 to ActorList.Count - 1 do
    if TActor(ActorList[i]).RecogId = chrid then
    begin
      Result := TActor(ActorList[i]);
      exit; //�̹� ����
    end;
  if IsChangingFace(chrid) then
    begin
    Result:=nil;    //��������ſ��ȥ����δ����ֵ
    exit;  //������...
    end;
  case RACEfeature(cfeature) of
    0:
      actor := THumActor.Create;
    9:
      actor := TSoccerBall.Create;  //�౸��

    13:
      actor := TKillingHerb.Create;
    14:
      actor := TSkeletonOma.Create;
    15:
      actor := TDualAxeOma.Create;

    16:
      actor := TGasKuDeGi.Create;  //������� ������

    17:
      actor := TCatMon.Create;   //����, ����(����,â�����,ö�����)
    18:
      actor := THuSuABi.Create;
    19:
      actor := TCatMon.Create;   //����(����,â�����,ö������)

    20:
      actor := TFireCowFaceMon.Create;
    21:
      actor := TCowFaceKing.Create;
    22:
      actor := TDualAxeOma.Create;  //ħ��� ��ũ
    23:
      actor := TWhiteSkeleton.Create;  //��ȯ���

    24:
      actor := TSuperiorGuard.Create;  //���ִ� ���

    30:
      actor := TCatMon.Create; //������
    31:
      actor := TCatMon.Create; //������
    32:
      actor := TScorpionMon.Create; //������ 2����

    33:
      actor := TCentipedeKingMon.Create;  //���׿�, �˷��
    34, 97:
      actor := TBigHeartMon.Create;  //������, ����, �㳪��, ������
    35:
      actor := TSpiderHouseMon.Create;  //���ȰŹ�
    36:
      actor := TExplosionSpider.Create;  //����
    37:
      actor := TFlyingSpider.Create;  //�񵶰Ź�

    40:
      actor := TZombiLighting.Create;  //���� 1 (���� ���� ����)
    41:
      actor := TZombiDigOut.Create;  //���İ� ������ ����
    42:
      actor := TZombiZilkin.Create;

    43:
      actor := TBeeQueen.Create;

    45:
      actor := TArcherMon.Create;
    47:
      actor := TSculptureMon.Create;  //�����屺, ���Ҵ���
    48:
      actor := TSculptureMon.Create;  //
    49:
      actor := TSculptureKingMon.Create;  //�ָ���

    50:
      actor := TNpcActor.Create;

    52, 53:
      actor := TGasKuDeGi.Create;  //������� ���⳪��, ��
    54:
      actor := TSmallElfMonster.Create;
    55:
      actor := TWarriorElfMonster.Create;

    60:
      actor := TElectronicScolpionMon.Create;   //������
    61:
      actor := TBossPigMon.Create;              //�յ�
    62:
      actor := TKingOfSculpureKingMon.Create;   //�ָ�����(���߿�)
      // 2003/02/11 �ű� �� �߰� .. �ذ񺻿�, �νı�
    63:
      actor := TSkeletonKingMon.Create;
    64:
      actor := TGasKuDeGi.Create;
    65:
      actor := TSamuraiMon.Create;
    66:
      actor := TSkeletonSoldierMon.Create;
    67:
      actor := TSkeletonSoldierMon.Create;
    68:
      actor := TSkeletonSoldierMon.Create;
    69:
      actor := TSkeletonArcherMon.Create;
    70:
      actor := TBanyaGuardMon.Create;           //�ݾ߿��
    71:
      actor := TBanyaGuardMon.Create;           //�ݾ��»�
    72:
      actor := TBanyaGuardMon.Create;           //���õ��
      // 2003/07/15 ���ź�õ �� �߰�
    73:
      actor := TPBOMA1Mon.Create;               //���Ϳ���
    74:
      actor := TCatMon.Create;                  //�����˺�/����/������/ģ����
    75:
      actor := TStoneMonster.Create;            //���輮1
    76:
      actor := TSuperiorGuard.Create;           //���ź�õ���
    77:
      actor := TStoneMonster.Create;            //���輮2
    78:
      actor := TBanyaGuardMon.Create;           //��Ȳ����
    79:
      actor := TPBOMA6Mon.Create;               //�������ú�
    80, 96:
      actor := TMineMon.Create;             //�������

    81:
      actor := TAngel.Create;                   //����(õ��)
    83:
      actor := TFireDragon.Create;              //��õ����
    84, 85, 86, 87, 88, 89:
      actor := TDragonStatue.Create; //�뼮��
    90:
      actor := TDragonBody.Create;              //��õ���� �����
    91:
      actor := TBanyaGuardMon.Create;           //���δ���
    92:
      actor := TJumaThunderMon.Create;          //�ָ��ݷ���  TSculptureMon ��ӹ���
    93:
      actor := TBanyaGuardMon.Create;           //ȯ����ȣ
    94:
      actor := TBanyaGuardMon.Create;           //�Ź�(�ż�������)
    95:
      actor := TGasKuDeGi.Create;               //�̺�Ʈ���� 96:�ɴ� 97:������

    98:
      actor := TWallStructure.Create;
    99:
      actor := TCastleDoor.Create;              //����...

    100:
      actor := TBanyaGuardMon.Create;          //Ȳ���̹���
    101:
      actor := TCatMon.Create;                 //���(û����)
    102:
      actor := TSkeletonArcherMon.Create;      //�ü�ȣ����  #####
    103:
      actor := TBanyaGuardMon.Create;          //����������
    104:
      actor := TBanyaGuardMon.Create;          //����������
    105:
      actor := TBanyaGuardMon.Create;          //����������
    106:
      actor := TCentipedeKingMon.Create;       //ȣȥ��
    107:
      actor := TBanyaGuardMon.Create;          //ȣȥ�⼮
    108:
      actor := TBanyaGuardMon.Create;          //ȣ�⿬(��)
    109:
      actor := TBanyaGuardMon.Create;          //ȣ�⿬(��)
    110:
      actor := TFireDragon.Create;             //���õ��
    111, 112:
      actor := TDualAxeOma.Create;         //�����ũ
    113, 114:
      actor := TCatMon.Create;             //ġ��
      // 115 ȣ�ڱ���
    116:
      actor := TCatMon.Create;                 //�����ͼ�
    117:
      actor := TBanyaGuardMon.Create;          //��ö�ͼ�
    118:
      actor := TFireDragon.Create;             //��������
    119:
      actor := TKillingHerb.Create;            //��

  else
    actor := TActor.Create;
  end;

  with actor do
  begin
    RecogId := chrid;
    XX := cx;
    YY := cy;
    rx := XX;
    ry := YY;
    Dir := cdir;
    Feature := cfeature;
    Race := RACEfeature(cfeature);         //changefeature�� ��������
    hair := HAIRfeature(cfeature);         //����ȴ�.
    dress := DRESSfeature(cfeature);
    weapon := WEAPONfeature(cfeature);
    Appearance := APPRfeature(cfeature);

    pm := RaceByPm(Race, Appearance);
    if pm <> nil then
      WalkFrameDelay := pm.ActWalk.ftime;

    if Race = 0 then
    begin
      Sex := dress mod 2;   //0:���� 1:����
    end
    else
      Sex := 0;
    state := cstate;
    Saying[0] := '';
  end;
  ActorList.Add(actor);
  Result := actor;
end;

procedure TPlayScene.ActorDied(actor: TObject);
var
  i: integer;
  flag: Boolean;
begin
  for i := 0 to ActorList.Count - 1 do
    if ActorList[i] = actor then
    begin
      ActorList.Delete(i);
      break;
    end;
  flag := FALSE;
  for i := 0 to ActorList.Count - 1 do
    if not TActor(ActorList[i]).Death then
    begin
      ActorList.Insert(i, actor);
      flag := TRUE;
      break;
    end;
  if not flag then
    ActorList.Add(actor);
end;

procedure TPlayScene.SetActorDrawLevel(actor: TObject; level: integer);
var
  i: integer;
begin
  if level = 0 then
  begin  //�� ó���� �׸����� ��
    for i := 0 to ActorList.Count - 1 do
      if ActorList[i] = actor then
      begin
        ActorList.Delete(i);
        ActorList.Insert(0, actor);
        break;
      end;
  end;
end;

procedure TPlayScene.ClearActors;  //�α׾ƿ��� ���
var
  i: integer;
begin
  for i := 0 to ActorList.Count - 1 do
    TActor(ActorList[i]).Free;
  ActorList.Clear;
  Myself := nil;
  TargetCret := nil;
  FocusCret := nil;
  MagicTarget := nil;

   //������ �ʱ�ȭ �ؾ���.
  for i := 0 to EffectList.Count - 1 do
    TMagicEff(EffectList[i]).Free;
  EffectList.Clear;
end;

function TPlayScene.DeleteActor(id: integer): TActor;
var
  i: integer;
begin
  Result := nil;
  i := 0;
  while TRUE do
  begin
    if i >= ActorList.Count then
      break;
    if TActor(ActorList[i]).RecogId = id then
    begin
      if TargetCret = TActor(ActorList[i]) then
        TargetCret := nil;
      if FocusCret = TActor(ActorList[i]) then
        FocusCret := nil;
      if MagicTarget = TActor(ActorList[i]) then
        MagicTarget := nil;
      TActor(ActorList[i]).DeleteTime := GetTickCount;
      FreeActorList.Add(ActorList[i]);
         //TActor(ActorList[i]).Free;
      ActorList.Delete(i);
    end
    else
      Inc(i);
  end;
end;

procedure TPlayScene.DelActor(actor: TObject);
var
  i: integer;
begin
  for i := 0 to ActorList.Count - 1 do
    if ActorList[i] = actor then
    begin
      TActor(ActorList[i]).DeleteTime := GetTickCount;
      FreeActorList.Add(ActorList[i]);
      ActorList.Delete(i);
      break;
    end;
end;

function TPlayScene.ButchAnimal(x, y: integer): TActor;
var
  i: integer;
  a: TActor;
begin
  Result := nil;
  for i := 0 to ActorList.Count - 1 do
  begin
    a := TActor(ActorList[i]);
    if a.Death and (a.Race <> 0) then
    begin //���� ��ü
      if (abs(a.XX - x) <= 1) and (abs(a.YY - y) <= 1) then
      begin
        Result := a;
        break;
      end;
    end;
  end;
end;


{------------------------- Msg -------------------------}


//�޼����� ���۸��ϴ� ������ ?
//ĳ������ �޼��� ���ۿ� �޼����� ���� �ִ� ���¿���
//���� �޼����� ó���Ǹ� �ȵǱ� ������.
procedure TPlayScene.SendMsg(ident, chrid, x, y, cdir, feature, state, param: integer; str: string);
var
  actor: TActor;
  meff: TMagicEff;
begin
  case ident of
    SM_TEST:
      begin
        actor := NewActor(111, 254{x}, 214{y}, 0, 0, 0);
        Myself := THumActor(actor);
        Map.LoadMap('0', Myself.XX, Myself.YY);
      end;
    SM_CHANGEMAP, SM_NEWMAP:
      begin
        Map.LoadMap(str, x, y);
        DarkLevel := cdir;
           // DayBright_fake := msg.Param;

        DarkLevel_fake := cdir;
        pDarkLevelCheck^ := cdir;

        if DarkLevel = 0 then
          ViewFog := FALSE
        else
          ViewFog := TRUE;
        if (ident = SM_NEWMAP) and (Myself <> nil) then
        begin  //�����̵� �Ҷ� �ε巴�� ���̵��� �ϰ� �������
          Myself.XX := x;
          Myself.YY := y;
          Myself.RX := x;
          Myself.RY := y;
          DelActor(Myself);
        end;

        if BoWantMiniMap then
        begin
          if MiniMapIndex<= 0 then
             FrmMain.SendWantMiniMap;
        end;
//        if ViewGeneralMapStyle > 0 then
//          FrmMain.SendWantMiniMap;

      end;
    SM_LOGON:
      begin
        actor := FindActor(chrid);
        if actor = nil then
        begin
          actor := NewActor(chrid, x, y, Lobyte(cdir), feature, state);
          actor.ChrLight := Hibyte(cdir);
          cdir := Lobyte(cdir);
          actor.SendMsg(SM_TURN, x, y, cdir, feature, state, '', 0);
        end;
        if Myself <> nil then
        begin
          Myself := nil;
        end;
        Myself := THumActor(actor);
      end;
    SM_HIDE:
      begin
        actor := FindActor(chrid);
        if actor <> nil then
        begin
          if actor.BoDelActionAfterFinished then
          begin //������ ������� �ִϸ��̼��� ������ �ڵ����� �����.
            exit;
          end;
          if actor.WaitForRecogId <> 0 then
          begin  //������.. ������ ������ �ڵ����� �����
            exit;
          end;
        end;
        DeleteActor(chrid);
      end;
  else
    begin
      actor := FindActor(chrid);
      if (ident = SM_TURN) or (ident = SM_RUN) or (ident = SM_WALK) or (ident = SM_BACKSTEP) or (ident = SM_DEATH) or (ident = SM_SKELETON) or (ident = SM_DIGUP) or (ident = SM_ALIVE) then
      begin
        if actor = nil then
          actor := NewActor(chrid, x, y, Lobyte(cdir), feature, state);
        if actor <> nil then
        begin
          actor.ChrLight := Hibyte(cdir);
          cdir := Lobyte(cdir);
          if ident = SM_SKELETON then
          begin
            actor.Death := TRUE;
            actor.Skeleton := TRUE;
          end
          else if ident = SM_ALIVE then
          begin  //2005/05/11 ��Ȱ //####
            actor.Feature := feature;
            actor.FeatureChanged;
                     if DarkLevel = 0 then ViewFog := FALSE
                     else ViewFog := TRUE;
            actor.Death := False;
            actor.Skeleton := False;
          end;

        end;
      end;
      if actor = nil then
        exit;
      case ident of
        SM_FEATURECHANGED:
          begin
            actor.Feature := feature;
            actor.FeatureChanged;
          end;
        SM_CHARSTATUSCHANGED:
          begin
            actor.State := feature;
            actor.HitSpeed := state;
            if actor = Myself then
            begin
              ChangeWalkHitValues(Myself.Abil.Level, Myself.HitSpeed, Myself.Abil.Weight + Myself.Abil.MaxWeight + Myself.Abil.WearWeight + Myself.Abil.MaxWearWeight + Myself.Abil.HandWeight + Myself.Abil.MaxHandWeight, RUN_STRUCK_DELAY);
//                        if Myself.State and $10000000 <> 0 then begin        //POISON_STUN
//                           DizzyDelayStart := GetTickCount;
//                           DizzyDelayTime  := 1500; //������
//                        end;
            end;
                     // 2003/07/15 ���Ͽ� ���� �����̻� ����Ʈ �߰�
            if feature and $10000000 <> 0 then
            begin        //POISON_STUN
              meff := TCharEffect.Create(380, 6, actor);
              meff.NextFrameTime := 100;
              meff.ImgLib := WMagic2;
              meff.RepeatUntil := GetTickCount + 2000;
              EffectList.Add(meff);
            end;
          end;
      else
        begin
          if ident = SM_TURN then
          begin
            if str <> '' then
              actor.UserName := str;
          end;
          if ident = SM_WALK then
          begin
            if param > 0 then
              actor.WalkFrameDelay := param;
          end;
          actor.SendMsg(ident, x, y, cdir, feature, state, '', 0);
        end;
      end;
    end;
  end;

end;

end.

