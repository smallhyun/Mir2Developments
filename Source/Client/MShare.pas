unit MShare;

interface

uses
  Windows, SysUtils, Classes, Graphics, WIL, HGETextures, HGECanvas, HGEFonts,
  HGE, HGEGUI, HGEBase, HGESounds, Clipbrd, DIB, Imm;

const
  LOGINBAGIMGINDEX = 22;
  DEFSCREENWIDTH = 800;
  DEFSCREENHEIGHT = 600;
  MAXX = 52;
  MAXY = 40;

const
  WHumImg_IMAGEFILE = 'Data\Hum.wil';
  WHumWing_IMAGEFILE = 'Data\HumEffect.wil';
  WHairImg_IMAGEFILE = 'Data\Hair.wil';
  WWeapon_IMAGEFILE = 'Data\Weapon.wil';
  WMagic_IMAGEFILE = 'Data\Magic.wil';
  WMagic2_IMAGEFILE = 'Data\Magic2.wil';
  WMagIcon_IMAGEFILE = 'Data\MagIcon.wil';
  WNpcImg_IMAGEFILE = 'Data\Npc.wil';
  WNpc2Img_IMAGEFILE = 'Data\Npc2.wil';
  WEffectImg_IMAGEFILE = 'Data\Effect.wil';
  WProgUse_IMAGEFILE = 'Data\Prguse.wil';
  WProgUse2_IMAGEFILE = 'Data\Prguse2.wil';
  WChrSel_IMAGEFILE = 'Data\ChrSel.wil';
  WMMap_IMAGEFILE = 'Data\mmap.wil';
  WBagItem_IMAGEFILE = 'Data\Items.wil';
  WStateItem_IMAGEFILE = 'Data\StateItem.wil';
  WDnItem_IMAGEFILE = 'Data\DnItems.wil';
  WTiles_IMAGEFILE = 'Data\Tiles.wil';
  WSmTiles_IMAGEFILE = 'Data\SmTiles.wil';
  WDeco_IMAGEFILE = 'Data\Deco.wil';
  WObjects_IMAGEFILE = 'Data\Objects.wil';
  WObjects2_IMAGEFILE = 'Data\Objects2.wil';
  WObjects3_IMAGEFILE = 'Data\Objects3.wil';
  WObjects4_IMAGEFILE = 'Data\Objects4.wil';
  WObjects5_IMAGEFILE = 'Data\Objects5.wil';
  WObjects6_IMAGEFILE = 'Data\Objects6.wil';
  WObjects7_IMAGEFILE = 'Data\Objects7.wil';
  WObjects8_IMAGEFILE = 'Data\Objects8.wil';
  WObjects9_IMAGEFILE = 'Data\Objects9.wil';
  WObjects10_IMAGEFILE = 'Data\Objects10.wil';
  WObjects11_IMAGEFILE = 'Data\Objects11.wil';
  WObjects12_IMAGEFILE = 'Data\Objects12.wil';
  WObjects13_IMAGEFILE = 'Data\Objects13.wil';
  WMon1_IMAGEFILE = 'Data\Mon1.wil';
  WMon2_IMAGEFILE = 'Data\Mon2.wil';
  WMon3_IMAGEFILE = 'Data\Mon3.wil';
  WMon4_IMAGEFILE = 'Data\Mon4.wil';
  WMon5_IMAGEFILE = 'Data\Mon5.wil';
  WMon6_IMAGEFILE = 'Data\Mon6.wil';
  WMon7_IMAGEFILE = 'Data\Mon7.wil';
  WMon8_IMAGEFILE = 'Data\Mon8.wil';
  WMon9_IMAGEFILE = 'Data\Mon9.wil';
  WMon10_IMAGEFILE = 'Data\Mon10.wil';
  WMon11_IMAGEFILE = 'Data\Mon11.wil';
  WMon12_IMAGEFILE = 'Data\Mon12.wil';
  WMon13_IMAGEFILE = 'Data\Mon13.wil';
  WMon14_IMAGEFILE = 'Data\Mon14.wil';
  WMon15_IMAGEFILE = 'Data\Mon15.wil';
  WMon16_IMAGEFILE = 'Data\Mon16.wil';
  WMon17_IMAGEFILE = 'Data\Mon17.wil';
  WMon18_IMAGEFILE = 'Data\Mon18.wil';
  WMon19_IMAGEFILE = 'Data\Mon19.wil';
  WMon20_IMAGEFILE = 'Data\Mon20.wil';
  WMon21_IMAGEFILE = 'Data\Mon21.wil';
  WMon22_IMAGEFILE = 'Data\Mon22.wil';
  WMon23_IMAGEFILE = 'Data\Mon23.wil';
  WMon24_IMAGEFILE = 'Data\Mon24.wil';
  WMon25_IMAGEFILE = 'Data\Mon25.wil';
  WDragonImg_IMAGEFILE = 'Data\Dragon.wil';
  WMain99_IMAGEFILE = 'Resource\Prguse_.pak';
  WMusic_IMAGEFILE = 'Resource\Prguse_.pak';
  Images_Tiles = 0;
  Images_Objects1 = Images_Tiles + 1;
  Images_Objects2 = Images_Objects1 + 1;
  Images_Objects3 = Images_Objects2 + 1;
  Images_Objects4 = Images_Objects3 + 1;
  Images_Objects5 = Images_Objects4 + 1;
  Images_Objects6 = Images_Objects5 + 1;
  Images_Objects7 = Images_Objects6 + 1;
  Images_Objects8 = Images_Objects7 + 1;
  Images_Objects9 = Images_Objects8 + 1;
  Images_Objects10 = Images_Objects9 + 1;
  Images_Objects11 = Images_Objects10 + 1;
  Images_Objects12 = Images_Objects11 + 1;
  Images_Objects13 = Images_Objects12 + 1;
  Images_SmTiles = Images_Objects13 + 1;
  Images_HumImg = Images_SmTiles + 1;
  Images_HairImg = Images_HumImg + 1;
  Images_WHumWing = Images_HairImg + 1;
  Images_WDeco = Images_WHumWing + 1;
  Images_Weapon = Images_WDeco + 1;
  Images_Magic = Images_Weapon + 1;
  Images_Magic2 = Images_Magic + 1;
  Images_MagIcon = Images_Magic2 + 1;
  Images_MonImg = Images_MagIcon + 1;
  Images_Mon2Img = Images_MonImg + 1;
  Images_Mon3Img = Images_Mon2Img + 1;
  Images_Mon4Img = Images_Mon3Img + 1;
  Images_Mon5Img = Images_Mon4Img + 1;
  Images_Mon6Img = Images_Mon5Img + 1;
  Images_Mon7Img = Images_Mon6Img + 1;
  Images_Mon8Img = Images_Mon7Img + 1;
  Images_Mon9Img = Images_Mon8Img + 1;
  Images_Mon10Img = Images_Mon9Img + 1;
  Images_Mon11Img = Images_Mon10Img + 1;
  Images_Mon12Img = Images_Mon11Img + 1;
  Images_Mon13Img = Images_Mon12Img + 1;
  Images_Mon14Img = Images_Mon13Img + 1;
  Images_Mon15Img = Images_Mon14Img + 1;
  Images_Mon16Img = Images_Mon15Img + 1;
  Images_Mon17Img = Images_Mon16Img + 1;
  Images_Mon18Img = Images_Mon17Img + 1;
  Images_Mon19Img = Images_Mon18Img + 1;
  Images_Mon20Img = Images_Mon19Img + 1;
  Images_Mon21Img = Images_Mon20Img + 1;
  Images_Mon22Img = Images_Mon21Img + 1;
  Images_Mon23Img = Images_Mon22Img + 1;
  Images_Mon24Img = Images_Mon23Img + 1;
  Images_Mon25Img = Images_Mon24Img + 1;
  Images_WDragonImg = Images_Mon25Img + 1;
  Images_NpcImg = Images_WDragonImg + 1;
  Images_EffectImg = Images_NpcImg + 1;
  Images_ProgUse = Images_EffectImg + 1;
  Images_ProgUse2 = Images_ProgUse + 1;
  Images_ChrSel = Images_ProgUse2 + 1;
  Images_MMap = Images_ChrSel + 1;
  Images_BagItem = Images_MMap + 1;
  Images_StateItem = Images_BagItem + 1;
  Images_DnItem = Images_StateItem + 1;
  Images_WMain99 = Images_DnItem + 1;
  Images_WMusic = Images_WMain99 + 1;
  Images_Npc2Img = Images_WMusic + 1;

var
  g_boRightItemRingEmpty        :Boolean=False; //�����ָΪ��
  g_boRightItemArmRingEmpty     :Boolean=False; //�������Ϊ��

  g_ClientImages: array[Images_Tiles..Images_Npc2Img] of TWMImages;
  WTiles: TWMImages;
  WObjects1: TWMImages;
  WObjects2: TWMImages;
  WObjects3: TWMImages;
  WObjects4: TWMImages;
  WObjects5: TWMImages;
  WObjects6: TWMImages;
  WObjects7: TWMImages;
  WObjects8: TWMImages;
  WObjects9: TWMImages;
  WObjects10: TWMImages;
  WObjects11: TWMImages;
  WObjects12: TWMImages;
  WObjects13: TWMImages;
  WSmTiles: TWMImages;
  WHumImg: TWMImages;
  WHumWing: TWMImages;
  WHairImg: TWMImages;
  WWeapon: TWMImages;
  WMagic: TWMImages;
  WMagic2: TWMImages;
  WMagIcon: TWMImages;
  WMonImg: TWMImages;
  WMon2Img: TWMImages;
  WMon3Img: TWMImages;
  WMon4Img: TWMImages;
  WMon5Img: TWMImages;
  WMon6Img: TWMImages;
  WMon7Img: TWMImages;
  WMon8Img: TWMImages;
  WMon9Img: TWMImages;
  WMon10Img: TWMImages;
  WMon11Img: TWMImages;
  WMon12Img: TWMImages;
  WMon13Img: TWMImages;
  WMon14Img: TWMImages;
  WMon15Img: TWMImages;
  WMon16Img: TWMImages;
  WMon17Img: TWMImages;
  WMon18Img: TWMImages;
  WMon19Img: TWMImages;
  WMon20Img: TWMImages;
  WMon21Img: TWMImages;
  WMon22Img: TWMImages;
  WMon23Img: TWMImages;
  WMon24Img: TWMImages;
  WMon25Img: TWMImages;
  WDragonImg: TWMImages;
  WDecoImg: TWMImages;
  WNpcImg: TWMImages;
  WNpc2Img: TWMImages;
  WEffectImg: TWMImages;
  WProgUse: TWMImages;
  WProgUse2: TWMImages;
  WChrSel: TWMImages;
  WMMap: TWMImages;
  WBagItem: TWMImages;
  WStateItem: TWMImages;
  WDnItem: TWMImages;
  WMain99: TWMImages;
  WMusic: TWMImages;
  CLIENTUPDATETIME: string = '2016.02.09';
  g_sCurFontName: string = '����';
  g_boFullScreen: Boolean = False;
  g_DXCanvas: TDXDrawCanvas;
  g_boInitialize: Boolean;
  g_DXFont: TDXFont;
  g_Font: TFont;
  g_boDrawTileMap: Boolean = True;
  g_boCanDraw: Boolean = True;
  g_boCanSound: Boolean = True;
  g_DWinMan: TDWinManager;
  g_Sound: TSoundEngine;
  g_SoundList: TStringList;
//  g_DXSound: TDXSound;
  g_boSound: Boolean;
  g_boBGSound: Boolean = True;
  g_btMP3Volume: Byte = 70;
  g_btSoundVolume: Byte = 70;
  g_FScreenMode: Byte = 1;      //�ֱ��ʣ�1��1024*768��0��800*600
  g_FScreenWidth: Integer = DEFSCREENWIDTH;
  g_FScreenHeight: Integer = DEFSCREENHEIGHT;
  g_FrmMainWinHandle: THandle;
  g_ColorTable: TRGBQuads;
  g_HIMC: HIMC; //���뷨�رյ��ñ���

  g_boOwnerMsg: Boolean;            //�Ƿ�ܾ�����
  g_RefuseCRY: Boolean = True;      //�ܾ�����
  g_Refuseguild: Boolean = True;    //�ܾ��л�������Ϣ
  g_RefuseWHISPER: Boolean = True;  //�ܾ�˽����Ϣ
  g_boAutoTalk: Boolean = False;    //�Զ�����
  g_sAutoTalkStr: string;           //��������
  g_nAutoTalkTimer: LongWord = 8;   //�Զ����� 
  //�Զ���ҩ��ʶ
  g_nDuWhich: byte = 0;
  g_UnbindItemList: TList = nil;     // ����б�
  g_nLastUnbindTime : LongWord = 0;  // ʱ��
  g_nCaptureSerial: Integer; //ץͼ�ļ������

  g_nMiniMapMaxX: Integer = -1;
  g_nMiniMapMaxY: Integer = -1;
  g_nMiniMapMoseX: Integer = -1;
  g_nMiniMapMoseY: Integer = -1;
  g_nMiniMapMaxMosX: Integer;
  g_nMiniMapMaxMosY: Integer;
  
procedure CopyStrToClipboard(sStr: string);

procedure LoadWMImagesLib(AOwner: TComponent);

procedure InitWMImagesLib;

procedure UnLoadWMImagesLib();

procedure LoadColorLevels();

procedure UnLoadColorLevels();

procedure PomiTextOut(dsurface: TDXTexture; x, y: integer; str: string);

function GetObjs(wunit, idx: integer): TDXTexture;

function GetObjsEx(wunit, idx: integer; var px, py: integer): TDXTexture;

function GetTempSurface(ColorFormat: TWILColorFormat): TDXImageTexture;

procedure DrawBlend(dsuf: TDXTexture; x, y: integer; ssuf: TDXTexture; blendmode: integer);

procedure DrawBlendR(dsuf: TDXTexture; x, y: integer; Rect: TRect; ssuf: TDXTexture; blendmode: integer);

procedure DrawEffect(dsuf: TDXTexture; x, y: integer; ssuf: TDXTexture; eff: TColorEffect; boBlend: Boolean; blendmode: integer = 0);

function BagItemCount: Integer;

implementation

uses
  ClMain;

var
  GrayScaleByR5G6B5: array[Word] of Word;
  GrayScaleByA1R5G5B5: array[Word] of Word;
  GrayScaleByA4R4G4B4: array[Word] of Word;
  GSA1R5G5B5ToA4R4G4B4: array[Word] of Word;
  ImgMixSurfaceR5G6B5: TDXImageTexture;
  ImgMixSurfaceA1R5G5B5: TDXImageTexture;
  ImgMixSurfaceA4R4G4B4: TDXImageTexture;
  ImgMaxSurfaceR5G6B5: TDXImageTexture;
  ImgMaxSurfaceA1R5G5B5: TDXImageTexture;
  ImgMaxSurfaceA4R4G4B4: TDXImageTexture;
  boA1R5G5B5, boR5G6B5, boA4R4G4B4: Boolean;

procedure CopyStrToClipboard(sStr: string);
var
  Clipboard: TClipboard;
begin
  Clipboard := TClipboard.Create;
  try
    Clipboard.AsText := sStr;
  finally
    Clipboard.Free;
  end;
end;

procedure RefClientImages();
var
  i: Integer;
begin
  for i := Low(g_ClientImages) to High(g_ClientImages) do
  begin
    g_ClientImages[i] := nil;
    case i of
      Images_Tiles:
        g_ClientImages[i] := WTiles;
      Images_Objects1:
        g_ClientImages[i] := WObjects1;
      Images_Objects2:
        g_ClientImages[i] := WObjects2;
      Images_Objects3:
        g_ClientImages[i] := WObjects3;
      Images_Objects4:
        g_ClientImages[i] := WObjects4;
      Images_Objects5:
        g_ClientImages[i] := WObjects5;
      Images_Objects6:
        g_ClientImages[i] := WObjects6;
      Images_Objects7:
        g_ClientImages[i] := WObjects7;
      Images_Objects8:
        g_ClientImages[i] := WObjects8;
      Images_Objects9:
        g_ClientImages[i] := WObjects9;
      Images_Objects10:
        g_ClientImages[i] := WObjects10;
      Images_Objects11:
        g_ClientImages[i] := WObjects11;
      Images_Objects12:
        g_ClientImages[i] := WObjects12;
      Images_Objects13:
        g_ClientImages[i] := WObjects13;
      Images_SmTiles:
        g_ClientImages[i] := WSmTiles;
      Images_WHumWing:
        g_ClientImages[i] := WHumWing;
      Images_WDeco:
        g_ClientImages[i] := WDecoImg;
      Images_HumImg:
        g_ClientImages[i] := WHumImg;
      Images_HairImg:
        g_ClientImages[i] := WHairImg;
      Images_Weapon:
        g_ClientImages[i] := WWeapon;
      Images_Magic:
        g_ClientImages[i] := WMagic;
      Images_Magic2:
        g_ClientImages[i] := WMagic2;
      Images_MagIcon:
        g_ClientImages[i] := WMagIcon;
      Images_MonImg:
        g_ClientImages[i] := WMonImg;
      Images_Mon2Img:
        g_ClientImages[i] := WMon2Img;
      Images_Mon3Img:
        g_ClientImages[i] := WMon3Img;
      Images_Mon4Img:
        g_ClientImages[i] := WMon4Img;
      Images_Mon5Img:
        g_ClientImages[i] := WMon5Img;
      Images_Mon6Img:
        g_ClientImages[i] := WMon6Img;
      Images_Mon7Img:
        g_ClientImages[i] := WMon7Img;
      Images_Mon8Img:
        g_ClientImages[i] := WMon8Img;
      Images_Mon9Img:
        g_ClientImages[i] := WMon9Img;
      Images_Mon10Img:
        g_ClientImages[i] := WMon10Img;
      Images_Mon11Img:
        g_ClientImages[i] := WMon11Img;
      Images_Mon12Img:
        g_ClientImages[i] := WMon12Img;
      Images_Mon13Img:
        g_ClientImages[i] := WMon13Img;
      Images_Mon14Img:
        g_ClientImages[i] := WMon14Img;
      Images_Mon15Img:
        g_ClientImages[i] := WMon15Img;
      Images_Mon16Img:
        g_ClientImages[i] := WMon16Img;
      Images_Mon17Img:
        g_ClientImages[i] := WMon17Img;
      Images_Mon18Img:
        g_ClientImages[i] := WMon18Img;
      Images_Mon19Img:
        g_ClientImages[i] := WMon19Img;
      Images_Mon20Img:
        g_ClientImages[i] := WMon20Img;
      Images_Mon21Img:
        g_ClientImages[i] := WMon21Img;
      Images_Mon22Img:
        g_ClientImages[i] := WMon22Img;
      Images_Mon23Img:
        g_ClientImages[i] := WMon23Img;
      Images_Mon24Img:
        g_ClientImages[i] := WMon24Img;
      Images_Mon25Img:
        g_ClientImages[i] := WMon25Img;
      Images_WDragonImg:
        g_ClientImages[i] := WDragonImg;
      Images_NpcImg:
        g_ClientImages[i] := WNpcImg;
      Images_EffectImg:
        g_ClientImages[i] := WEffectImg;
      Images_ProgUse:
        g_ClientImages[i] := WProgUse;
      Images_ProgUse2:
        g_ClientImages[i] := WProgUse2;
      Images_ChrSel:
        g_ClientImages[i] := WChrSel;
      Images_MMap:
        g_ClientImages[i] := WMMap;
      Images_BagItem:
        g_ClientImages[i] := WBagItem;
      Images_StateItem:
        g_ClientImages[i] := WStateItem;
      Images_DnItem:
        g_ClientImages[i] := WDnItem;
      Images_WMain99:
        g_ClientImages[i] := WMain99;
      Images_WMusic:
        g_ClientImages[i] := WMusic;
      Images_Npc2Img:
        g_ClientImages[i] := WNpc2Img;
    end;
  end;
end;

procedure LoadWMImagesLib(AOwner: TComponent);
begin
  WTiles := CreateWMImages(t_wmM2Def);
  WObjects1 := CreateWMImages(t_wmM2Def);
  WObjects2 := CreateWMImages(t_wmM2Def);
  WObjects3 := CreateWMImages(t_wmM2Def);
  WObjects4 := CreateWMImages(t_wmM2Def);
  WObjects5 := CreateWMImages(t_wmM2Def);
  WObjects6 := CreateWMImages(t_wmM2Def);
  WObjects7 := CreateWMImages(t_wmM2Def);
  WObjects8 := CreateWMImages(t_wmM2Def);
  WObjects9 := CreateWMImages(t_wmM2Def);
  WObjects10 := CreateWMImages(t_wmM2Def);
  WObjects11 := CreateWMImages(t_wmM2Def);
  WObjects12 := CreateWMImages(t_wmM2Def);
  WObjects13 := CreateWMImages(t_wmM2Def);
  WHumWing := CreateWMImages(t_wmM2Def);
  WDecoimg := CreateWMImages(t_wmM2Def);
  WDragonImg := CreateWMImages(t_wmM2Def);
  WSmTiles := CreateWMImages(t_wmM2Def);
  WHumImg := CreateWMImages(t_wmM2Def);
  WHairImg := CreateWMImages(t_wmM2Def);
  WWeapon := CreateWMImages(t_wmM2Def);
  WMagic := CreateWMImages(t_wmM2Def);
  WMagic2 := CreateWMImages(t_wmM2Def);
  WMagIcon := CreateWMImages(t_wmM2Def);
  WMonImg := CreateWMImages(t_wmM2Def);
  WMon2Img := CreateWMImages(t_wmM2Def);
  WMon3Img := CreateWMImages(t_wmM2Def);
  WMon4Img := CreateWMImages(t_wmM2Def);
  WMon5Img := CreateWMImages(t_wmM2Def);
  WMon6Img := CreateWMImages(t_wmM2Def);
  WMon7Img := CreateWMImages(t_wmM2Def);
  WMon8Img := CreateWMImages(t_wmM2Def);
  WMon9Img := CreateWMImages(t_wmM2Def);
  WMon10Img := CreateWMImages(t_wmM2Def);
  WMon11Img := CreateWMImages(t_wmM2Def);
  WMon12Img := CreateWMImages(t_wmM2Def);
  WMon13Img := CreateWMImages(t_wmM2Def);
  WMon14Img := CreateWMImages(t_wmM2Def);
  WMon15Img := CreateWMImages(t_wmM2Def);
  WMon16Img := CreateWMImages(t_wmM2Def);
  WMon17Img := CreateWMImages(t_wmM2Def);
  WMon18Img := CreateWMImages(t_wmM2Def);
  WMon19Img := CreateWMImages(t_wmM2Def);
  WMon20Img := CreateWMImages(t_wmM2Def);
  WMon21Img := CreateWMImages(t_wmM2Def);
  WMon22Img := CreateWMImages(t_wmM2Def);
  WMon23Img := CreateWMImages(t_wmM2Def);
  WMon24Img := CreateWMImages(t_wmM2Def);
  WMon25Img := CreateWMImages(t_wmM2Def);
  WNpcImg := CreateWMImages(t_wmM2Def);
  WNpc2Img := CreateWMImages(t_wmM2Def);
  WEffectImg := CreateWMImages(t_wmM2Def);
  WProgUse := CreateWMImages(t_wmM2Def);
  WProgUse2 := CreateWMImages(t_wmM2Def);
  WChrSel := CreateWMImages(t_wmM2Def);
  WMMap := CreateWMImages(t_wmM2Def);
  WBagItem := CreateWMImages(t_wmM2Def);
  WStateItem := CreateWMImages(t_wmM2Def);
  WDnItem := CreateWMImages(t_wmM2Def);

//  WMain99 := CreateWMImages(t_wmMyImage);
//  WMusic := CreateWMImages(t_wmMyImage);
  RefClientImages();

end;

procedure InitWMImagesLib;

  procedure InitializeImage(var AWMImages: TWMImages);
  var
    sFileName: string;
    vLibType: TLibType;
  begin
    if (not AWMImages.Initialize()) and (AWMImages.FileName <> '') and (AWMImages.WILType in [t_wmM2Def, t_wmM2wis]) then
    begin
      sFileName := ChangeFileExt(AWMImages.FileName, '.wzl');

      vLibType := AWMImages.LibType;

      AWMImages.Finalize;
      AWMImages.Free;
      AWMImages := CreateWMImages(t_wmM2Zip);
      AWMImages.FileName := sFileName;
      AWMImages.LibType := vLibType;

      AWMImages.Initialize();
    end;
  end;

begin
  WTiles.FileName := WTiles_IMAGEFILE;
  WTiles.LibType := ltUseCache;
  InitializeImage(WTiles);

  WObjects1.FileName := WObjects_IMAGEFILE;
  WObjects1.LibType := ltUseCache;
  InitializeImage(WObjects1);

  WObjects2.FileName := WObjects2_IMAGEFILE;
  WObjects2.LibType := ltUseCache;
  InitializeImage(WObjects2);

  WObjects3.FileName := WObjects3_IMAGEFILE;
  WObjects3.LibType := ltUseCache;
  InitializeImage(WObjects3);

  WObjects4.FileName := WObjects4_IMAGEFILE;
  WObjects4.LibType := ltUseCache;
  InitializeImage(WObjects4);

  WObjects5.FileName := WObjects5_IMAGEFILE;
  WObjects5.LibType := ltUseCache;
  InitializeImage(WObjects5);

  WObjects6.FileName := WObjects6_IMAGEFILE;
  WObjects6.LibType := ltUseCache;
  InitializeImage(WObjects6);

  WObjects7.FileName := WObjects7_IMAGEFILE;
  WObjects7.LibType := ltUseCache;
  InitializeImage(WObjects7);

  WObjects8.FileName := WObjects8_IMAGEFILE;
  WObjects8.LibType := ltUseCache;
  InitializeImage(WObjects8);

  WObjects9.FileName := WObjects9_IMAGEFILE;
  WObjects9.LibType := ltUseCache;
  InitializeImage(WObjects9);

  WObjects10.FileName := WObjects10_IMAGEFILE;
  WObjects10.LibType := ltUseCache;
  InitializeImage(WObjects10);

  WObjects11.FileName := WObjects11_IMAGEFILE;
  WObjects11.LibType := ltUseCache;
  InitializeImage(WObjects11);

  WObjects12.FileName := WObjects12_IMAGEFILE;
  WObjects12.LibType := ltUseCache;
  InitializeImage(WObjects12);

  WObjects13.FileName := WObjects13_IMAGEFILE;
  WObjects13.LibType := ltUseCache;
  InitializeImage(WObjects13);

  WSmTiles.FileName := WSmTiles_IMAGEFILE;
  WSmTiles.LibType := ltUseCache;
  InitializeImage(WSmTiles);

  WHumImg.FileName := WHumImg_IMAGEFILE;
  WHumImg.LibType := ltUseCache;
  InitializeImage(WHumImg);

  WHairImg.FileName := WHairImg_IMAGEFILE;
  WHairImg.LibType := ltUseCache;
  InitializeImage(WHairImg);

  WWeapon.FileName := WWeapon_IMAGEFILE;
  WWeapon.LibType := ltUseCache;
  InitializeImage(WWeapon);

  WMagic.FileName := WMagic_IMAGEFILE;
  WMagic.LibType := ltUseCache;
  InitializeImage(WMagic);

  WMagic2.FileName := WMagic2_IMAGEFILE;
  WMagic2.LibType := ltUseCache;
  InitializeImage(WMagic2);

  WMagIcon.FileName := WMagIcon_IMAGEFILE;
  WMagIcon.LibType := ltUseCache;
  InitializeImage(WMagIcon);

  WMonImg.FileName := WMon1_IMAGEFILE;
  WMonImg.LibType := ltUseCache;
  InitializeImage(WMonImg);

  WMon2Img.FileName := WMon2_IMAGEFILE;
  WMon2Img.LibType := ltUseCache;
  InitializeImage(WMon2Img);

  WMon3Img.FileName := WMon3_IMAGEFILE;
  WMon3Img.LibType := ltUseCache;
  InitializeImage(WMon3Img);

  WMon4Img.FileName := WMon4_IMAGEFILE;
  WMon4Img.LibType := ltUseCache;
  InitializeImage(WMon4Img);

  WMon5Img.FileName := WMon5_IMAGEFILE;
  WMon5Img.LibType := ltUseCache;
  InitializeImage(WMon5Img);

  WMon6Img.FileName := WMon6_IMAGEFILE;
  WMon6Img.LibType := ltUseCache;
  InitializeImage(WMon6Img);

  WMon7Img.FileName := WMon7_IMAGEFILE;
  WMon7Img.LibType := ltUseCache;
  InitializeImage(WMon7Img);

  WMon8Img.FileName := WMon8_IMAGEFILE;
  WMon8Img.LibType := ltUseCache;
  InitializeImage(WMon8Img);

  WMon9Img.FileName := WMon9_IMAGEFILE;
  WMon9Img.LibType := ltUseCache;
  InitializeImage(WMon9Img);

  WMon10Img.FileName := WMon10_IMAGEFILE;
  WMon10Img.LibType := ltUseCache;
  InitializeImage(WMon10Img);

  WMon11Img.FileName := WMon11_IMAGEFILE;
  WMon11Img.LibType := ltUseCache;
  InitializeImage(WMon11Img);

  WMon12Img.FileName := WMon12_IMAGEFILE;
  WMon12Img.LibType := ltUseCache;
  InitializeImage(WMon12Img);

  WMon13Img.FileName := WMon13_IMAGEFILE;
  WMon13Img.LibType := ltUseCache;
  InitializeImage(WMon13Img);

  WMon14Img.FileName := WMon14_IMAGEFILE;
  WMon14Img.LibType := ltUseCache;
  InitializeImage(WMon14Img);

  WMon15Img.FileName := WMon15_IMAGEFILE;
  WMon15Img.LibType := ltUseCache;
  InitializeImage(WMon15Img);

  WMon16Img.FileName := WMon16_IMAGEFILE;
  WMon16Img.LibType := ltUseCache;
  InitializeImage(WMon16Img);

  WMon17Img.FileName := WMon17_IMAGEFILE;
  WMon17Img.LibType := ltUseCache;
  InitializeImage(WMon17Img);

  WMon18Img.FileName := WMon18_IMAGEFILE;
  WMon18Img.LibType := ltUseCache;
  InitializeImage(WMon18Img);

  WMon19Img.FileName := WMon19_IMAGEFILE;
  WMon19Img.LibType := ltUseCache;
  InitializeImage(WMon19Img);

  WMon20Img.FileName := WMon20_IMAGEFILE;
  WMon20Img.LibType := ltUseCache;
  InitializeImage(WMon20Img);

  WMon21Img.FileName := WMon21_IMAGEFILE;
  WMon21Img.LibType := ltUseCache;
  InitializeImage(WMon21Img);

  WMon22Img.FileName := WMon22_IMAGEFILE;
  WMon22Img.LibType := ltUseCache;
  InitializeImage(WMon22Img);

  WMon23Img.FileName := WMon23_IMAGEFILE;
  WMon23Img.LibType := ltUseCache;
  InitializeImage(WMon23Img);

  WMon24Img.FileName := WMon24_IMAGEFILE;
  WMon24Img.LibType := ltUseCache;
  InitializeImage(WMon24Img);

  WMon25Img.FileName := WMon25_IMAGEFILE;
  WMon25Img.LibType := ltUseCache;
  InitializeImage(WMon25Img);      

  WNpcImg.FileName := WNpcImg_IMAGEFILE;
  WNpcImg.LibType := ltUseCache;
  InitializeImage(WNpcImg);

  WNpc2Img.FileName := WNpc2Img_IMAGEFILE;
  WNpc2Img.LibType := ltUseCache;
  InitializeImage(WNpc2Img);

  WEffectImg.FileName := WEffectImg_IMAGEFILE;
  WEffectImg.LibType := ltUseCache;
  InitializeImage(WEffectImg);

  WProgUse.FileName := WProgUse_IMAGEFILE;
  WProgUse.LibType := ltUseCache;
  InitializeImage(WProgUse);

{  WMain99.FileName := WMain99_IMAGEFILE;
  WMain99.LibType := ltUseCache;
  InitializeImage(WMain99);    }

  WProgUse2.FileName := WProgUse2_IMAGEFILE;
  WProgUse2.LibType := ltUseCache;
  InitializeImage(WProgUse2);

  WChrSel.FileName := WChrSel_IMAGEFILE;
  WChrSel.LibType := ltUseCache;
  InitializeImage(WChrSel);

  WMMap.FileName := WMMap_IMAGEFILE;
  WMMap.LibType := ltUseCache;
  InitializeImage(WMMap);

  WBagItem.FileName := WBagItem_IMAGEFILE;
  WBagItem.LibType := ltUseCache;
  InitializeImage(WBagItem);

  WStateItem.FileName := WStateItem_IMAGEFILE;
  WStateItem.LibType := ltUseCache;
  InitializeImage(WStateItem);

  WDnItem.FileName := WDnItem_IMAGEFILE;
  WDnItem.LibType := ltUseCache;
  InitializeImage(WDnItem);

  WHumWing.FileName := WHumWing_IMAGEFILE;
  WHumWing.LibType := ltUseCache;
  InitializeImage(WHumWing);

  WDecoimg.FileName := WDeco_IMAGEFILE;
  WDecoimg.LibType := ltUseCache;
  InitializeImage(WDecoimg);

  WDragonImg.FileName := WDragonImg_IMAGEFILE;
  WDragonImg.LibType := ltUseCache;
  InitializeImage(WDragonImg);

  RefClientImages();
end;

procedure UnLoadWMImagesLib();
begin
  WTiles.Finalize;
  WTiles.Free;
  WObjects1.Finalize;
  WObjects1.Free;
  WObjects2.Finalize;
  WObjects2.Free;
  WObjects3.Finalize;
  WObjects3.Free;
  WObjects4.Finalize;
  WObjects4.Free;
  WObjects5.Finalize;
  WObjects5.Free;
  WObjects6.Finalize;
  WObjects6.Free;
  WObjects7.Finalize;
  WObjects7.Free;
  WObjects8.Finalize;
  WObjects8.Free;
  WObjects9.Finalize;
  WObjects9.Free;
  WObjects10.Finalize;
  WObjects10.Free;
  WObjects11.Finalize;
  WObjects11.Free;
  WObjects12.Finalize;
  WObjects12.Free;
  WObjects13.Finalize;
  WObjects13.Free;
  WSmTiles.Finalize;
  WSmTiles.Free;
  WHumImg.Finalize;
  WHumImg.Free;
  WHairImg.Finalize;
  WHairImg.Free;
  WWeapon.Finalize;
  WWeapon.Free;
  WMagic.Finalize;
  WMagic.Free;
  WMagic2.Finalize;
  WMagic2.Free;
  WMagIcon.Finalize;
  WMagIcon.Free;
  WMonImg.Finalize;
  WMonImg.Free;
  WMon2Img.Finalize;
  WMon2Img.Free;
  WMon3Img.Finalize;
  WMon3Img.Free;
  WMon4Img.Finalize;
  WMon4Img.Free;
  WMon5Img.Finalize;
  WMon5Img.Free;
  WMon6Img.Finalize;
  WMon6Img.Free;
  WMon7Img.Finalize;
  WMon7Img.Free;
  WMon8Img.Finalize;
  WMon8Img.Free;
  WMon9Img.Finalize;
  WMon9Img.Free;
  WMon10Img.Finalize;
  WMon10Img.Free;
  WMon11Img.Finalize;
  WMon11Img.Free;
  WMon12Img.Finalize;
  WMon12Img.Free;
  WMon13Img.Finalize;
  WMon13Img.Free;
  WMon14Img.Finalize;
  WMon14Img.Free;
  WMon15Img.Finalize;
  WMon15Img.Free;
  WMon16Img.Finalize;
  WMon16Img.Free;
  WMon17Img.Finalize;
  WMon17Img.Free;
  WMon18Img.Finalize;
  WMon18Img.Free;
  WMon19Img.Finalize;
  WMon19Img.Free;
  WMon20Img.Finalize;
  WMon20Img.Free;
  WMon21Img.Finalize;
  WMon21Img.Free;
  WMon22Img.Finalize;
  WMon22Img.Free;
  WMon23Img.Finalize;
  WMon23Img.Free;
  WMon24Img.Finalize;
  WMon24Img.Free;
  WMon25Img.Finalize;
  WMon25Img.Free;
  WNpcImg.Finalize;
  WNpcImg.Free;
  WNpc2Img.Finalize;
  WNpc2Img.Free;
  WEffectImg.Finalize;
  WEffectImg.Free;
  WProgUse.Finalize;
  WProgUse.Free;
  WProgUse2.Finalize;
  WProgUse2.Free;
  WChrSel.Finalize;
  WChrSel.Free;
  WMMap.Finalize;
  WMMap.Free;
  WBagItem.Finalize;
  WBagItem.Free;
  WStateItem.Finalize;
  WStateItem.Free;
  WDnItem.Finalize;
  WDnItem.Free;
  WHumWing.Finalize;
  WHumWing.Free;
  WDecoimg.Finalize;
  WDecoimg.Free;
  WDragonImg.Finalize;
  WDragonImg.Free;
end;

procedure LoadColorLevels();
var
  i: integer;
  nA, nR, nG, nB, nX: Byte;
begin
  ImgMixSurfaceR5G6B5 := MakeDXImageTexture(g_FScreenWidth, g_FScreenHeight, WILFMT_R5G6B5);
  ImgMixSurfaceA1R5G5B5 := MakeDXImageTexture(g_FScreenWidth, g_FScreenHeight, WILFMT_A1R5G5B5);
  ImgMixSurfaceA4R4G4B4 := MakeDXImageTexture(g_FScreenWidth, g_FScreenHeight, WILFMT_A4R4G4B4);
  ImgMaxSurfaceR5G6B5 := MakeDXImageTexture(g_FScreenWidth, g_FScreenHeight, WILFMT_R5G6B5);
  ImgMaxSurfaceA1R5G5B5 := MakeDXImageTexture(g_FScreenWidth, g_FScreenHeight, WILFMT_A1R5G5B5);
  ImgMaxSurfaceA4R4G4B4 := MakeDXImageTexture(g_FScreenWidth, g_FScreenHeight, WILFMT_A4R4G4B4);
  ImgMixSurfaceR5G6B5.Canvas := g_DXCanvas;
  ImgMixSurfaceA1R5G5B5.Canvas := g_DXCanvas;
  ImgMixSurfaceA4R4G4B4.Canvas := g_DXCanvas;
  ImgMaxSurfaceR5G6B5.Canvas := g_DXCanvas;
  ImgMaxSurfaceA1R5G5B5.Canvas := g_DXCanvas;
  ImgMaxSurfaceA4R4G4B4.Canvas := g_DXCanvas;
  GrayScaleByR5G6B5[0] := 0;
  GrayScaleByA1R5G5B5[0] := 0;
  GrayScaleByA4R4G4B4[0] := 0;
  for i := Low(Word) to High(Word) do
  begin

    nB := BYTE((Word(i) and $1F) shl 3);
    nG := BYTE((Word(i) and $7E0) shr 3);
    nR := BYTE((Word(i) and $F800) shr 8);
    nX := (nR + nG + nB) div 3;
    GrayScaleByR5G6B5[i] := ((Word(nX) and $F8) shl 8) + (Word(nX) and $FC shl 3) + (Word(nX) shr 3);

    nB := BYTE((Word(i) and $1F) shl 3);
    nG := BYTE((Word(i) and $3E0) shr 2);
    nR := BYTE((Word(i) and $7C00) shr 7);
    nA := BYTE((Word(i) and $8000) shr 15);
    nX := (nR + nG + nB) div 3;
    GrayScaleByA1R5G5B5[i] := Word(nA) shl 15 + ((Word(nX) and $F8) shl 7) + (Word(nX) and $F8 shl 2) + (Word(nX) shr 3);

    nB := BYTE((Word(i) and $F) shl 4);
    nG := BYTE(Word(i) and $F0);
    nR := BYTE((Word(i) and $F00) shr 4);
    nA := BYTE((Word(i) and $F000) shr 8);
    nX := (nR + nG + nB) div 3;
    GrayScaleByA4R4G4B4[i] := Word(nA) and $F0 shl 8 + ((Word(nX) and $F0) shl 4) + (Word(nX) and $F0) + (Word(nX) shr 4);

    nB := BYTE((Word(i) and $1F) shl 3);
    nG := BYTE((Word(i) and $3E0) shr 2);
    nR := BYTE((Word(i) and $7C00) shr 7);
    nA := BYTE((Word(i) and $8000) shr 15);
    nX := (nR + nG + nB) div 3;
    if nA = 0 then
      GSA1R5G5B5ToA4R4G4B4[i] := ((Word(nX) and $F0) shl 4) + (Word(nX) and $F0) + (Word(nX) shr 4)
    else
      GSA1R5G5B5ToA4R4G4B4[i] := $F000 + ((Word(nX) and $F0) shl 4) + (Word(nX) and $F0) + (Word(nX) shr 4);
  end;
end;

procedure UnLoadColorLevels();
begin
  if ImgMixSurfaceR5G6B5 <> nil then
    ImgMixSurfaceR5G6B5.Free;
  if ImgMixSurfaceA1R5G5B5 <> nil then
    ImgMixSurfaceA1R5G5B5.Free;
  if ImgMixSurfaceA4R4G4B4 <> nil then
    ImgMixSurfaceA4R4G4B4.Free;
  ImgMixSurfaceR5G6B5 := nil;
  ImgMixSurfaceA1R5G5B5 := nil;
  ImgMixSurfaceA4R4G4B4 := nil;
  if ImgMaxSurfaceR5G6B5 <> nil then
    ImgMaxSurfaceR5G6B5.Free;
  if ImgMaxSurfaceA1R5G5B5 <> nil then
    ImgMaxSurfaceA1R5G5B5.Free;
  if ImgMaxSurfaceA4R4G4B4 <> nil then
    ImgMaxSurfaceA4R4G4B4.Free;
  ImgMaxSurfaceR5G6B5 := nil;
  ImgMaxSurfaceA1R5G5B5 := nil;
  ImgMaxSurfaceA4R4G4B4 := nil;

end;

procedure PomiTextOut(dsurface: TDXTexture; x, y: integer; str: string);
var
  i, n: integer;
  d: TDXTexture;
begin
  for i := 1 to Length(str) do
  begin
    n := byte(str[i]) - byte('0');
    if n in [0..9] then
    begin
      d := WProgUse.Images[30 + n];
      if d <> nil then
        dsurface.Draw(x + i * 8, y, d.ClientRect, d, TRUE);
    end
    else
    begin
      if str[i] = '-' then
      begin
        d := WProgUse.Images[40];
        if d <> nil then
          dsurface.Draw(x + i * 8, y, d.ClientRect, d, TRUE);
      end;
    end;
  end;
end;

function GetObjs(wunit, idx: integer): TDXTexture;
begin
  case wunit of
    0:
      Result := WObjects1.Images[idx];
    1:
      Result := WObjects2.Images[idx];
    2:
      Result := WObjects3.Images[idx];
    3:
      Result := WObjects4.Images[idx];
    4:
      Result := WObjects5.Images[idx];
    5:
      Result := WObjects6.Images[idx];
    6:
      Result := WObjects7.Images[idx];
  else
    Result := WObjects1.Images[idx];
  end;
end;

function GetObjsEx(wunit, idx: integer; var px, py: integer): TDXTexture;
begin
  case wunit of
    0:
      Result := WObjects1.GetCachedImage(idx, px, py);
    1:
      Result := WObjects2.GetCachedImage(idx, px, py);
    2:
      Result := WObjects3.GetCachedImage(idx, px, py);
    3:
      Result := WObjects4.GetCachedImage(idx, px, py);
    4:
      Result := WObjects5.GetCachedImage(idx, px, py);
    5:
      Result := WObjects6.GetCachedImage(idx, px, py);
    6:
      Result := WObjects7.GetCachedImage(idx, px, py);
  else
    Result := WObjects1.GetCachedImage(idx, px, py);
  end;
end;

function GetTempSurface(ColorFormat: TWILColorFormat): TDXImageTexture;
begin
  Result := nil;
  case ColorFormat of
    WILFMT_A1R5G5B5:
      begin
        if boA1R5G5B5 then
          Result := ImgMaxSurfaceA1R5G5B5
        else
          Result := ImgMixSurfaceA1R5G5B5;
        boA1R5G5B5 := not boA1R5G5B5;
      end;
    WILFMT_A4R4G4B4:
      begin
        if boA4R4G4B4 then
          Result := ImgMaxSurfaceA4R4G4B4
        else
          Result := ImgMixSurfaceA4R4G4B4;
        boA4R4G4B4 := not boA4R4G4B4;
      end;
    WILFMT_R5G6B5:
      begin
        if boR5G6B5 then
          Result := ImgMaxSurfaceR5G6B5
        else
          Result := ImgMixSurfaceR5G6B5;
        boR5G6B5 := not boR5G6B5;
      end;
  end;
  if Result <> nil then
    Result.PatternSize := Point(g_FScreenWidth, g_FScreenHeight);
end;

procedure DrawBlend(dsuf: TDXTexture; x, y: integer; ssuf: TDXTexture; blendmode: integer);
begin
  if blendmode = 0 then
    dsuf.Draw(x, y, ssuf.ClientRect, ssuf, $80FFFFFF, fxBlend)
  else
    dsuf.Draw(x, y, ssuf.ClientRect, ssuf, fxAnti);
end;

procedure DrawBlendR(dsuf: TDXTexture; x, y: integer; Rect: TRect; ssuf: TDXTexture; blendmode: integer);
begin
  if blendmode = 0 then
    dsuf.Draw(x, y, Rect, ssuf, $80FFFFFF, fxBlend)
  else if blendmode = 100 then
    dsuf.Draw(x, y, Rect, ssuf, $80FFFFFF, fxBlend)
  else
    dsuf.Draw(x, y, Rect, ssuf, fxAnti);
end;

procedure DrawEffect(dsuf: TDXTexture; x, y: integer; ssuf: TDXTexture; eff: TColorEffect; boBlend: Boolean; blendmode: integer);
var
  I: Integer;
  nColor: Integer;
  DrawFx: Cardinal;
  peff: PByte;
  nWidth, nHeight: Integer;
  nCount: Integer;
begin
  if (dsuf = nil) or (ssuf = nil) then
    Exit;

  if blendmode = 0 then
    DrawFx := fxBlend
  else
    DrawFx := fxAnti;

  if eff = ceNone then
  begin
    dsuf.Draw(x, y, ssuf.ClientRect, ssuf, DrawFx);
    exit;
  end;

  if boBlend then
    nColor := Integer($80000000)
  else
    nColor := Integer($FF000000);

  case eff of
    ceGrayScale:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, clWhite or nColor, fxGrayScale);
    ceBright:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, $B4B4B4 or nColor, fxBright);
    ceRed:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, clRed or nColor, DrawFx);
    ceGreen:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, clGreen or nColor, DrawFx);
    ceBlue:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, clBlue or nColor, DrawFx);
    ceYellow:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, clYellow or nColor, DrawFx);
    ceFuchsia:
      dsuf.Draw(x, y, ssuf.ClientRect, ssuf, clFuchsia or nColor, DrawFx);
  end;
end;

function BagItemCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(ItemArr) to High(ItemArr) do begin
    if ItemArr[I].s.Name <> '' then Inc(Result);
  end;
end;

initialization
begin
  FillChar(g_ClientImages, SizeOf(g_ClientImages), #0);
  g_UnbindItemList := tlist.Create;
end;

finalization
begin
  Freeandnil(g_UnbindItemList);
end;

end.

