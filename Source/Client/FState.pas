unit FState;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, Grobal2, clFunc, hUtil32, MapUnit, SoundUtil, comobj, HGEGUI,
  HGETextures, RelationShip, MaketSystem;

const
  BOTTOMBOARD = 1;
  BOTTOMBOARD1024 = 2;
  VIEWCHATLINE = 9;
  MAXSTATEPAGE = 4;
  LISTLINEHEIGHT = 13;
  LISTLINEHEIGHT2 = 14;
  MAKETLINEHEIGHT = 19;
  REPLYIMGPOS = 20;
  MAXMENU = 10;
  DECOMAXMENU = 12;
  RING_OF_UNKNOWN = 130;
  BRACELET_OF_UNKNOWN = 131;
  HELMET_OF_UNKNOWN = 132;
  UPITEMSUCCESSOFFSET = 633;

  MAX_FRIEND_COUNT = 20;
  VIEW_FRIEND = 1;
  VIEW_MAILSEND = 2;
  VIEW_MAILREAD = 3;
  VIEW_MEMO = 4;
  AdjustAbilHints: array[0..8] of string = ('������ ', 'ħ��(ħ��ʦ)', '����(��ʿ)', '���� ', 'ħ������', '����ֵ ', 'ħ��ֵ', '׼ȷ ', '���� ');

type
  TSpotDlgMode = (dmSell, dmRepair, dmStorage, dmMaketSell);

  TClickPoint = record
    rc: TRect;
    RStr: string;
  end;

  PTClickPoint = ^TClickPoint;

  TDiceInfo = record
    DiceResult: integer;
    DiceCurrent: integer;
    DiceLeft, DiceTop: integer;
    DiceCount: integer;
    DiceLimit: integer;
    DiceTime: longword;
  end;

  TFrmDlg = class(TForm)
    DBackground: TDWindow;
    DAdjustAbility: TDWindow;
    DPlusDC: TDButton;
    DPlusMC: TDButton;
    DPlusSC: TDButton;
    DPlusAC: TDButton;
    DPlusMAC: TDButton;
    DPlusHP: TDButton;
    DPlusMP: TDButton;
    DPlusHit: TDButton;
    DPlusSpeed: TDButton;
    DMinusDC: TDButton;
    DMinusMC: TDButton;
    DMinusSC: TDButton;
    DMinusAC: TDButton;
    DMinusMAC: TDButton;
    DMinusMP: TDButton;
    DMinusHP: TDButton;
    DMinusHit: TDButton;
    DMinusSpeed: TDButton;
    DAdjustAbilClose: TDButton;
    DAdjustAbilOk: TDButton;
    DBlockListDlg: TDWindow;
    DBlockListClose: TDButton;
    DBLPgUp: TDButton;
    DBLPgDn: TDButton;
    DBLDel: TDButton;
    DBLAdd: TDButton;
    DBottom: TDWindow;
    DMyState: TDButton;
    DMyBag: TDButton;
    DMyMagic: TDButton;
    DOption: TDButton;
    DBotMemo: TDButton;
    DBelt1: TDButton;
    DBelt2: TDButton;
    DBelt3: TDButton;
    DBelt4: TDButton;
    DBelt5: TDButton;
    DBelt6: TDButton;
    DBotMiniMap: TDButton;
    DBotTrade: TDButton;
    DBotGuild: TDButton;
    DBotGroup: TDButton;
    DBotPlusAbil: TDButton;
    DBotFriend: TDButton;
    DBotMaster: TDButton;
    DBotLogout: TDButton;
    DBotExit: TDButton;
    DChgPw: TDWindow;
    DChgpwOk: TDButton;
    DChgpwCancel: TDButton;
    DCountDlg: TDWindow;
    DCountDlgClose: TDButton;
    DCountDlgMax: TDButton;
    DCountDlgOk: TDButton;
    DCountDlgCancel: TDButton;
    DDealDlg: TDWindow;
    DDGrid: TDGrid;
    DDealOk: TDButton;
    DDealClose: TDButton;
    DDGold: TDButton;
    DDealJangwon: TDWindow;
    DDealRemoteDlg: TDWindow;
    DDRGrid: TDGrid;
    DDRGold: TDButton;
    DFriendDlg: TDWindow;
    DFrdClose: TDButton;
    DFrdPgUp: TDButton;
    DFrdPgDn: TDButton;
    DFrdFriend: TDButton;
    DFrdBlackList: TDButton;
    DFrdAdd: TDButton;
    DFrdDel: TDButton;
    DFrdMemo: TDButton;
    DFrdMail: TDButton;
    DFrdWhisper: TDButton;
    DGABoardDlg: TDWindow;
    DGABoardClose: TDButton;
    DGABoardCancel: TDButton;
    DGABoardOk2: TDButton;
    DGABoardReply: TDButton;
    DGABoardDel: TDButton;
    DGABoardMemo: TDButton;
    DGABoardListDlg: TDWindow;
    DGABoardListClose: TDButton;
    DGABoardListNext: TDButton;
    DGABoardListRefresh: TDButton;
    DGABoardListPrev: TDButton;
    DGABoardOk: TDButton;
    DGABoardWrite: TDButton;
    DGABoardNotice: TDButton;
    DGADecorateDlg: TDWindow;
    DGADecorateListNext: TDButton;
    DGADecorateListPrev: TDButton;
    DGADecorateBuy: TDButton;
    DGADecorateCancel: TDButton;
    DGADecorateClose: TDButton;
    DGroupDlg: TDWindow;
    DGrpAllowGroup: TDButton;
    DGrpDlgClose: TDButton;
    DGrpCreate: TDButton;
    DGrpAddMem: TDButton;
    DGrpDelMem: TDButton;
    DGuildDlg: TDWindow;
    DGDHome: TDButton;
    DGDList: TDButton;
    DGDChat: TDButton;
    DGDAddMem: TDButton;
    DGDDelMem: TDButton;
    DGDEditNotice: TDButton;
    DGDEditGrade: TDButton;
    DGDAlly: TDButton;
    DGDBreakAlly: TDButton;
    DGDWar: TDButton;
    DGDCancelWar: TDButton;
    DGDUp: TDButton;
    DGDDown: TDButton;
    DGDClose: TDButton;
    DGuildEditNotice: TDWindow;
    DGEClose: TDButton;
    DGEOk: TDButton;
    DItemBag: TDWindow;
    DGold: TDButton;
    DRepairItem: TDButton;
    DCloseBag: TDButton;
    DItemGrid: TDGrid;
    DItemMarketDlg: TDWindow;
    DItemBuy: TDButton;
    DItemCancel: TDButton;
    DItemFind: TDButton;
    DItemMarketClose: TDButton;
    DItemSellCancel: TDButton;
    DItemListPrev: TDButton;
    DItemListRefresh: TDButton;
    DItemListNext: TDButton;
    DMGold: TDButton;
    DMarketMemo: TDButton;
    DJangwonListDlg: TDWindow;
    DJangwonClose: TDButton;
    DJangListNext: TDButton;
    DJangMemo: TDButton;
    DJangListPrev: TDButton;
    DKeySelDlg: TDWindow;
    DKsIcon: TDButton;
    DKsF1: TDButton;
    DKsF2: TDButton;
    DKsF3: TDButton;
    DKsF4: TDButton;
    DKsNone: TDButton;
    DKsOk: TDButton;
    DKsF5: TDButton;
    DKsF6: TDButton;
    DKsF7: TDButton;
    DKsF8: TDButton;
    DKsConF1: TDButton;
    DKsConF5: TDButton;
    DKsConF2: TDButton;
    DKsConF6: TDButton;
    DKsConF3: TDButton;
    DKsConF7: TDButton;
    DKsConF4: TDButton;
    DKsConF8: TDButton;
    DLogIn: TDWindow;
    DLoginNew: TDButton;
    DLoginOk: TDButton;
    DLoginClose: TDButton;
    DLoginChgPw: TDButton;
    DMailDlg: TDWindow;
    DMailOK: TDButton;
    DMailClose: TDButton;
    DMailListDlg: TDWindow;
    DMailListClose: TDButton;
    DMailListPgUp: TDButton;
    DMailListPgDn: TDButton;
    DMLBlock: TDButton;
    DMLLock: TDButton;
    DMLDel: TDButton;
    DMLRead: TDButton;
    DMLReply: TDButton;
    DMakeItemDlg: TDWindow;
    DMakeItemDlgOk: TDButton;
    DMakeItemDlgCancel: TDButton;
    DMakeItemDlgClose: TDButton;
    DMakeitemGrid: TDGrid;
    DMasterDlg: TDWindow;
    DLover1: TDButton;
    DLover2: TDButton;
    DLover3: TDButton;
    DMasterClose: TDButton;
    DMaster3: TDButton;
    DMaster2: TDButton;
    DMaster1: TDButton;
    DMemo: TDWindow;
    DMemoClose: TDButton;
    DMemoB1: TDButton;
    DMemoB2: TDButton;
    DMenuDlg: TDWindow;
    DMenuPrev: TDButton;
    DMenuNext: TDButton;
    DMenuBuy: TDButton;
    DMenuClose: TDButton;
    DMerchantDlg: TDWindow;
    DMerchantDlgClose: TDButton;
    DMsgDlg: TDWindow;
    DMsgDlgOk: TDButton;
    DMsgDlgYes: TDButton;
    DMsgDlgCancel: TDButton;
    DMsgDlgNo: TDButton;
    DNewAccount: TDWindow;
    DNewAccountOk: TDButton;
    DNewAccountClose: TDButton;
    DNewAccountCancel: TDButton;
    DSelectChr: TDWindow;
    DscStart: TDButton;
    DscNewChr: TDButton;
    DscEraseChr: TDButton;
    DscCredits: TDButton;
    DscExit: TDButton;
    DscSelect1: TDButton;
    DscSelect2: TDButton;
    DSellDlg: TDWindow;
    DSellDlgOk: TDButton;
    DSellDlgClose: TDButton;
    DSellDlgSpot: TDButton;
    DSellDlgStHold: TDButton;
    DSellDlgBtnHold: TDButton;
    DSelServerDlg: TDWindow;
    DSSrvClose: TDButton;
    DSServer1: TDButton;
    DSServer2: TDButton;
    DSServer3: TDButton;
    DSServer4: TDButton;
    DSServer5: TDButton;
    DSServer6: TDButton;
    DEngServer1: TDButton;
    DSServer8: TDButton;
    DSServer7: TDButton;
    DStateWin: TDWindow;
    DPrevState: TDButton;
    DCloseState: TDButton;
    DNextState: TDButton;
    DSWNecklace: TDButton;
    DSWLight: TDButton;
    DSWArmRingR: TDButton;
    DSWArmRingL: TDButton;
    DSWRingR: TDButton;
    DSWRingL: TDButton;
    DSWWeapon: TDButton;
    DSWDress: TDButton;
    DSWHelmet: TDButton;
    DStMag1: TDButton;
    DStMag2: TDButton;
    DStMag3: TDButton;
    DStMag4: TDButton;
    DStMag5: TDButton;
    DStPageUp: TDButton;
    DStPageDown: TDButton;
    DSWBujuk: TDButton;
    DSWBelt: TDButton;
    DSWBoots: TDButton;
    DSWCharm: TDButton;
    DHeartImg: TDButton;
    DUserState1: TDWindow;
    DCloseUS1: TDButton;
    DWeaponUS1: TDButton;
    DHelmetUS1: TDButton;
    DNecklaceUS1: TDButton;
    DDressUS1: TDButton;
    DLightUS1: TDButton;
    DArmringRUS1: TDButton;
    DRingRUS1: TDButton;
    DArmringLUS1: TDButton;
    DRingLUS1: TDButton;
    DBujukUS1: TDButton;
    DBeltUS1: TDButton;
    DBootsUS1: TDButton;
    DCharmUS1: TDButton;
    DHeartImgUS: TDButton;
    DCreateChr: TDWindow;
    DccWarrior: TDButton;
    DccWizzard: TDButton;
    DccMonk: TDButton;
    DccReserved: TDButton;
    DccMale: TDButton;
    DccFemale: TDButton;
    DccLeftHair: TDButton;
    DccRightHair: TDButton;
    DccOk: TDButton;
    DccClose: TDButton;
    DMsgSimpleDlg: TDWindow;
    DMsgSimpleDlgOk: TDButton;
    DMsgSimpleDlgCancel: TDButton;
    AutoCRY: TDButton;
    Refuseguild: TDButton;
    RefuseWHISPER: TDButton;
    RefuseCRY: TDButton;
    RefusePublicChat: TDButton;
    procedure DBottomInRealArea(Sender: TObject; X, Y: Integer; var IsRealArea: Boolean);
    procedure DBottomDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMyStateDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DOptionClick(Sender: TObject);
    procedure DItemBagDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DRepairItemDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DRepairItemInRealArea(Sender: TObject; X, Y: Integer; var IsRealArea: Boolean);
    procedure DStateWinDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure FormCreate(Sender: TObject);
    procedure DPrevStateDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DLoginNewDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DscSelect1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DccCloseDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DItemGridGridSelect(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DItemGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
    procedure DItemGridDblClick(Sender: TObject);
    procedure DMsgDlgOkDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMsgDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMsgDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DCloseBagDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBackgroundBackgroundClick(Sender: TObject);
    procedure DItemGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DBelt1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure FormDestroy(Sender: TObject);
    procedure DBelt1DblClick(Sender: TObject);
    procedure SwapBujuk(idx: integer);
    procedure DLoginCloseClick(Sender: TObject; X, Y: Integer);
    procedure DLoginOkClick(Sender: TObject; X, Y: Integer);
    procedure DLoginNewClick(Sender: TObject; X, Y: Integer);
    procedure DLoginChgPwClick(Sender: TObject; X, Y: Integer);
    procedure DNewAccountOkClick(Sender: TObject; X, Y: Integer);
    procedure DNewAccountCloseClick(Sender: TObject; X, Y: Integer);
    procedure DccCloseClick(Sender: TObject; X, Y: Integer);
    procedure DChgpwOkClick(Sender: TObject; X, Y: Integer);
    procedure DscSelect1Click(Sender: TObject; X, Y: Integer);
    procedure DCloseStateClick(Sender: TObject; X, Y: Integer);
    procedure DPrevStateClick(Sender: TObject; X, Y: Integer);
    procedure DNextStateClick(Sender: TObject; X, Y: Integer);
    procedure DSWWeaponClick(Sender: TObject; X, Y: Integer);
    procedure DMsgDlgOkClick(Sender: TObject; X, Y: Integer);
    procedure DCloseBagClick(Sender: TObject; X, Y: Integer);
    procedure DBelt1Click(Sender: TObject; X, Y: Integer);
    procedure DMyStateClick(Sender: TObject; X, Y: Integer);
    procedure DStateWinClick(Sender: TObject; X, Y: Integer);
    procedure DSWWeaponMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBelt1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMerchantDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMerchantDlgCloseClick(Sender: TObject; X, Y: Integer);
    procedure DMerchantDlgClick(Sender: TObject; X, Y: Integer);
    procedure DMerchantDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DMerchantDlgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DMenuCloseClick(Sender: TObject; X, Y: Integer);
    procedure DMenuDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMenuDlgClick(Sender: TObject; X, Y: Integer);
    procedure DSellDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DSellDlgCloseClick(Sender: TObject; X, Y: Integer);
    procedure DSellDlgSpotClick(Sender: TObject; X, Y: Integer);
    procedure DSellDlgSpotDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DSellDlgSpotMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DSellDlgOkClick(Sender: TObject; X, Y: Integer);
    procedure DMenuBuyClick(Sender: TObject; X, Y: Integer);
    procedure DMenuPrevClick(Sender: TObject; X, Y: Integer);
    procedure DMenuNextClick(Sender: TObject; X, Y: Integer);
    procedure DGoldClick(Sender: TObject; X, Y: Integer);
    procedure DSWLightDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DLoginNewClickSound(Sender: TObject; Clicksound: TClickSound);
    procedure DStMag1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DStMag1Click(Sender: TObject; X, Y: Integer);
    procedure DKsIconDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DKsF1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DKsOkClick(Sender: TObject; X, Y: Integer);
    procedure DKsF1Click(Sender: TObject; X, Y: Integer);
    procedure DKeySelDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotGroupDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGrpAllowGroupDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGrpDlgCloseClick(Sender: TObject; X, Y: Integer);
    procedure DBotGroupClick(Sender: TObject; X, Y: Integer);
    procedure DGrpAllowGroupClick(Sender: TObject; X, Y: Integer);
    procedure DGrpCreateClick(Sender: TObject; X, Y: Integer);
    procedure DGroupDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGrpAddMemClick(Sender: TObject; X, Y: Integer);
    procedure DGrpDelMemClick(Sender: TObject; X, Y: Integer);
    procedure DBotLogoutClick(Sender: TObject; X, Y: Integer);
    procedure DBotExitClick(Sender: TObject; X, Y: Integer);
    procedure DStPageUpClick(Sender: TObject; X, Y: Integer);
    procedure DBottomMouse(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DDealOkClick(Sender: TObject; X, Y: Integer);
    procedure DDealCloseClick(Sender: TObject; X, Y: Integer);
    procedure DBotTradeClick(Sender: TObject; X, Y: Integer);
    procedure DDealRemoteDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DDealDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DDGridGridSelect(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DDGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
    procedure DDGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DDRGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
    procedure DDRGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DDGoldClick(Sender: TObject; X, Y: Integer);
    procedure DSServer1Click(Sender: TObject; X, Y: Integer);
    procedure DSSrvCloseClick(Sender: TObject; X, Y: Integer);
    procedure DBotMiniMapClick(Sender: TObject; X, Y: Integer);
    procedure DMenuDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DUserState1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DUserState1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DWeaponUS1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DCloseUS1Click(Sender: TObject; X, Y: Integer);
    procedure DNecklaceUS1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotGuildClick(Sender: TObject; X, Y: Integer);
    procedure DGuildDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGDUpClick(Sender: TObject; X, Y: Integer);
    procedure DGDDownClick(Sender: TObject; X, Y: Integer);
    procedure DGDCloseClick(Sender: TObject; X, Y: Integer);
    procedure DGDHomeClick(Sender: TObject; X, Y: Integer);
    procedure DGDListClick(Sender: TObject; X, Y: Integer);
    procedure DGDAddMemClick(Sender: TObject; X, Y: Integer);
    procedure DGDDelMemClick(Sender: TObject; X, Y: Integer);
    procedure DGDEditNoticeClick(Sender: TObject; X, Y: Integer);
    procedure DGDEditGradeClick(Sender: TObject; X, Y: Integer);
    procedure DGECloseClick(Sender: TObject; X, Y: Integer);
    procedure DGEOkClick(Sender: TObject; X, Y: Integer);
    procedure DGuildEditNoticeDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGDChatClick(Sender: TObject; X, Y: Integer);
    procedure DGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DNewAccountDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DAdjustAbilCloseClick(Sender: TObject; X, Y: Integer);
    procedure DAdjustAbilityDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotPlusAbilClick(Sender: TObject; X, Y: Integer);
    procedure DPlusDCClick(Sender: TObject; X, Y: Integer);
    procedure DMinusDCClick(Sender: TObject; X, Y: Integer);
    procedure DAdjustAbilOkClick(Sender: TObject; X, Y: Integer);
    procedure DBotPlusAbilDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DAdjustAbilityMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DUserState1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DEngServer1Click(Sender: TObject; X, Y: Integer);
    procedure DGDAllyClick(Sender: TObject; X, Y: Integer);
    procedure DGDBreakAllyClick(Sender: TObject; X, Y: Integer);
    procedure DSelServerDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DSServer1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotFriendClick(Sender: TObject; X, Y: Integer);
    procedure DBotFriendDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotFriendMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFriendDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DFrdPgUpClick(Sender: TObject; X, Y: Integer);
    procedure DFrdPgUpDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DFrdFriendClick(Sender: TObject; X, Y: Integer);
    procedure DFrdBlackListClick(Sender: TObject; X, Y: Integer);
    procedure DFrdAddMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFrdDelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFrdMemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFrdMailMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFrdWhisperMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFrdCloseClick(Sender: TObject; X, Y: Integer);
    procedure DFrdFriendDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DFrdBlackListDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMailListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMailListCloseClick(Sender: TObject; X, Y: Integer);
    procedure DMailListPgUpClick(Sender: TObject; X, Y: Integer);
    procedure DMLReplyMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMLReadMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMLDelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMLLockMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMLBlockMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMailListDlgClick(Sender: TObject; X, Y: Integer);
    procedure DFriendDlgClick(Sender: TObject; X, Y: Integer);
    procedure DBlockListCloseClick(Sender: TObject; X, Y: Integer);
    procedure DBLPgUpClick(Sender: TObject; X, Y: Integer);
    procedure DBlockListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBlockListDlgClick(Sender: TObject; X, Y: Integer);
    procedure DBLAddMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBLDelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMLBlockClick(Sender: TObject; X, Y: Integer);
    procedure DBotMemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBotMemoClick(Sender: TObject; X, Y: Integer);
    procedure DFrdAddClick(Sender: TObject; X, Y: Integer);
    procedure DMLReadClick(Sender: TObject; X, Y: Integer);
    procedure DFrdMailClick(Sender: TObject; X, Y: Integer);
    procedure DMemoDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DFrdMemoClick(Sender: TObject; X, Y: Integer);
    procedure DMemoCloseClick(Sender: TObject; X, Y: Integer);
    procedure DFrdDelClick(Sender: TObject; X, Y: Integer);
    procedure DFrdWhisperClick(Sender: TObject; X, Y: Integer);
    procedure DMemoB1DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMemoB2DirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMemoB1Click(Sender: TObject; X, Y: Integer);
    procedure DBLAddClick(Sender: TObject; X, Y: Integer);
    procedure DBLDelClick(Sender: TObject; X, Y: Integer);
    procedure DMLReplyClick(Sender: TObject; X, Y: Integer);
    procedure DMLDelClick(Sender: TObject; X, Y: Integer);
    procedure DMLLockClick(Sender: TObject; X, Y: Integer);
    procedure DFriendDlgDblClick(Sender: TObject);
    procedure DMailListDlgDblClick(Sender: TObject);
    procedure DBotMemoDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DFriendDlgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DMailListDlgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DFrdPgUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFrdPgDnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMailListPgUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMailListPgDnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBLPgUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBLPgDnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DFriendDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMailListDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMailDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBlockListDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMakeItemDlgOkDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DCountDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DCountDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DCountDlgOkDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DCountDlgOkClick(Sender: TObject; X, Y: Integer);
    procedure DCountDlgCloseClick(Sender: TObject; X, Y: Integer);
    procedure DMakeItemDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMakeitemGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
    procedure DMakeitemGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DMakeitemGridGridSelect(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
    procedure DMakeItemDlgOkClick(Sender: TObject; X, Y: Integer);
    procedure DItemMarketDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DItemMarketDlgClick(Sender: TObject; X, Y: Integer);
    procedure DItemMarketDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DItemListPrevClick(Sender: TObject; X, Y: Integer);
    procedure DItemListNextClick(Sender: TObject; X, Y: Integer);
    procedure DItemBuyClick(Sender: TObject; X, Y: Integer);
    procedure DItemMarketCloseClick(Sender: TObject; X, Y: Integer);
    procedure DMGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DItemMarketDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DItemListRefreshClick(Sender: TObject; X, Y: Integer);
    procedure DItemSellCancelClick(Sender: TObject; X, Y: Integer);
    procedure DItemFindClick(Sender: TObject; X, Y: Integer);
    procedure DItemSellCancelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DItemCancelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DItemBagClick(Sender: TObject; X, Y: Integer);
    procedure DMemoClick(Sender: TObject; X, Y: Integer);
    procedure DMailDlgClick(Sender: TObject; X, Y: Integer);
    procedure DItemMarketDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DJangwonListDlgClick(Sender: TObject; X, Y: Integer);
    procedure DJangwonListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DJangwonCloseClick(Sender: TObject; X, Y: Integer);
    procedure DJangListPrevClick(Sender: TObject; X, Y: Integer);
    procedure DJangListNextClick(Sender: TObject; X, Y: Integer);
    procedure DJangMemoClick(Sender: TObject; X, Y: Integer);
    procedure DDealJangwonDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGABoardListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGABoardListCloseClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardOkClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardListDlgDblClick(Sender: TObject);
    procedure DGABoardListDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DGABoardDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGABoardCloseClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardOk2Click(Sender: TObject; X, Y: Integer);
    procedure DGABoardWriteClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardNoticeClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardReplyClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DGABoardListNextClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardListPrevClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardListRefreshClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardMemoClick(Sender: TObject; X, Y: Integer);
    procedure DGABoardDelClick(Sender: TObject; X, Y: Integer);
    procedure DGADecorateDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DGADecorateCloseClick(Sender: TObject; X, Y: Integer);
    procedure DGADecorateBuyClick(Sender: TObject; X, Y: Integer);
    procedure DGADecorateCancelClick(Sender: TObject; X, Y: Integer);
    procedure DGADecorateDlgClick(Sender: TObject; X, Y: Integer);
    procedure DGADecorateDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DGADecorateListNextClick(Sender: TObject; X, Y: Integer);
    procedure DGADecorateListPrevClick(Sender: TObject; X, Y: Integer);
    procedure DMasterDlgClick(Sender: TObject; X, Y: Integer);
    procedure DMasterDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMasterDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DLover1Click(Sender: TObject; X, Y: Integer);
    procedure DLover1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DLover2Click(Sender: TObject; X, Y: Integer);
    procedure DLover2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DLover3Click(Sender: TObject; X, Y: Integer);
    procedure DLover3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DMasterCloseClick(Sender: TObject; X, Y: Integer);
    procedure DHeartImgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DHeartImgUSDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotMasterClick(Sender: TObject; X, Y: Integer);
    procedure DMarketMemoClick(Sender: TObject; X, Y: Integer);
    procedure DMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DSkillBarOnDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DChFriendDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DChGroupClick(Sender: TObject; X, Y: Integer);
    procedure DChFriendClick(Sender: TObject; X, Y: Integer);
    procedure DChMemoClick(Sender: TObject; X, Y: Integer);
    procedure DSellDlgBtnHoldClick(Sender: TObject; X, Y: Integer);
    procedure DSellDlgStHoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DSelectChrClick(Sender: TObject; X, Y: Integer);
    procedure DSellDlgBtnHoldMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DGrpAllowGroupMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DGroupDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DBotMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DRepairItemClick(Sender: TObject; X, Y: Integer);
    procedure DMyStateMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DMaster3Click(Sender: TObject; X, Y: Integer);
    procedure DMaster3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DMaster1Click(Sender: TObject; X, Y: Integer);
    procedure DMaster1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DMsgSimpleDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DMsgSimpleDlgKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DMsgSimpleDlgOkClick(Sender: TObject; X, Y: Integer);
    procedure RefusePublicChatClick(Sender: TObject; X, Y: Integer);
    procedure RefusePublicChatMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RefusePublicChatDirectPaint(Sender: TObject;
      dsurface: TDXTexture);
    procedure RefuseCRYClick(Sender: TObject; X, Y: Integer);
    procedure RefuseWHISPERClick(Sender: TObject; X, Y: Integer);
    procedure RefuseguildClick(Sender: TObject; X, Y: Integer);
    procedure AutoCRYClick(Sender: TObject; X, Y: Integer);
    procedure DDRGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DDGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
    procedure DBotGroupMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    DlgTemp: TList;
    magcur, magtop: integer;
    EdDlgEdit: TEdit;
    EdCountEdit: TEdit;
    ItemSearchEdit: TEdit;
    Memo: TMemo;
    // 2003/04/15 ģ��, ����
    edCharID: TEdit;
    memoMail: TMemo;
    ViewDlgEdit: Boolean;
    msglx, msgly: integer;
    MagKeyIcon, MagKeyCurKey: integer;
    MagKeyMagName: string;
    BackupMemoMail: string;
    StrMemoMail: string;
    MagicPage: integer;
    // 2003/04/15 ģ��, ����
    MemoCharID: string;
    MemoCharID2: string;
    MemoDate: string;
    FriendPage: integer;
    BlackListPage: integer;
    MailPage: integer;
    BlockPage: integer;
    CurrentMail: integer;
    CurrentFriend: integer;
    CurrentBlack: integer;
    CurrentBlock: integer;
    ViewFriends: boolean;
    ViewWindowNo: integer;
    ViewWindowData: integer;
    FriendDlgDblClicked: Boolean;
    MailListDlgDblClicked: Boolean;
    BlinkTime: longword;
    BlinkCount: integer;  //0..9���̸� �ݺ�

    procedure RestoreHideControls;
    procedure PageChanged;
    procedure DealItemReturnBag(mitem: TClientItem);
    procedure DealZeroGold;
  public
    MenuTop: integer;
    StatePage: integer;
    MsgText: string;
    DialogSize: integer;
    RunDice: integer;
    DiceType: Byte;
    BoDrawDice: Boolean;
    DiceArr: array[0..9] of TDiceInfo;
    MerchantName: string;
    MerchantFace: integer;
    MDlgStr: string;
    MDlgPoints: TList;
    RequireAddPoints: Boolean;
    SelectMenuStr: string;
    LastestClickTime: longword;
    MsgDlgClickTime: longword;
    SpotDlgMode: TSpotDlgMode;
    MenuList: TList; //list of PTClientGoods
    JangwonList: TList; //��� ����Ʈ PTClientJangwon
    GABoardList: TList; //��� �Խ��� ����Ʈ
    GADecorationList: TList; //��� �ٹ̱� ����Ʈ
    MenuIndex: integer;
    CurDetailItem: string;
    MenuTopLine: integer;
    BoDetailMenu: Boolean;
    BoStorageMenu: Boolean;
    BoNoDisplayMaxDura: Boolean;
    BoMakeDrugMenu: Boolean;
    BoFirstShowOnServerSel: Boolean;
    // ������ ���׷��̵�
    BoUpItemEffect: Boolean;
    CurUpItemEffect: integer;
    UpItemOffset: integer;
    UpItemMaxFrame: integer;
    upeffecttime: longword;

    // ��ġ��
    Total: integer;
    NameMakeItem: string[14];

    // ����
    BoMakeItemMenu: Boolean;
    // ��Ź�Ǹ�
    MItemSellState: Byte;
    BoInRect: Boolean;
    // ��� ����
    BoMemoJangwon: Boolean;
    NAHelps: TStringList;
    NewAccountTitle: string;
    DlgEditText: string;
    UserState1: TUserStateInfo;
    Guild: string;
    GuildFlag: string;
    GuildCommanderMode: Boolean;
    GuildStrs: TStringList;
    GuildStrs2: TStringList;
    GuildNotice: TStringList;
    GuildMembers: TStringList;
    GuildTopLine: integer;
    GuildEditHint: string;
    GuildChats: TStringList;
    BoGuildChat: Boolean;
    GABoard_GuildName: string;
    GABoard_UserName: string[14];
    GABoard_TxtBody: string;
//    GABoard_Edit     : string;
    GABoard_Notice: TStringList;
    GABoard_MaxPage: integer;
    GABoard_CurPage: integer;
    GABoard_BoNotice: integer;
    GABoard_BoWrite: Byte;
    GABoard_BoReply: Byte;
    GABoard_IndexType1: integer;
    GABoard_IndexType2: integer;
    GABoard_IndexType3: integer;
    GABoard_IndexType4: integer;
    GABoard_X, GABoard_Y: integer;

    m_dwBlinkTime: LongWord;
    m_boViewBlink: Boolean;

    procedure Initialize;
    procedure OpenMyStatus;
    procedure OpenUserState(ustate: TUserStateInfo);
    procedure OpenItemBag;
    procedure ViewBottomBox(visible: Boolean);
    procedure CancelItemMoving;
    procedure DropMovingItem;
    procedure OpenAdjustAbility;
    procedure HideAllControls;
    procedure ShowSelectServerDlg;
    function DMessageDlg(msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
    function DSimpleMessageDlg (msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
    function OnlyMessageDlg(msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
    function DCountMsgDlg(msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
    function MakeItemDlgShow(msgstr: string): TModalResult;
    procedure ShowMDlg(face: integer; mname, msgstr: string);
    procedure ShowGuildDlg;
    procedure ShowGuildEditNotice;
    procedure ShowGuildEditGrade;
    procedure ResetMenuDlg;
    procedure ShowShopMenuDlg;
    procedure ShowItemMarketDlg;
    procedure ShowJangwonDlg;
    procedure ShowGADecorateDlg;
    procedure ShowGABoardListDlg;
    procedure ShowGABoardReadDlg;
    procedure SendGABoardOkProg;
    procedure SendGABoardNoticeOk;
    procedure ShowShopSellDlg;
    procedure CloseDSellDlg;
    procedure CloseMDlg;
    procedure CloseMDlg2;
    procedure CloseItemMarketDlg;
    procedure SafeCloseDlg;
    procedure ToggleShowGroupDlg;
    // 2003/04/15 ģ��, ����
    procedure ToggleShowFriendsDlg;
    procedure ToggleShowMailListDlg;
    procedure ToggleShowBlockListDlg;
    procedure ToggleShowMemoDlg;
    procedure ToggleShowMasterDlg;
    procedure ShowEditMail;
    procedure AddFriend(FriendName: string; ShowMessage: Boolean);
    procedure OpenDealDlg(DealCase: Byte);
    procedure CloseDealDlg;
    procedure SetChatFocus;
    function DecoItemDesc(Dura: word; var str: string): string;
    procedure SoldOutGoods(itemserverindex: integer);
    procedure DelStorageItem(itemserverindex: integer; remain: word);
    procedure GetMouseItemInfo(var iname, line1, line2, line3, line4: string; var useable: boolean; bowear: Boolean);
    procedure SetMagicKeyDlg(icon: integer; magname: string; var curkey: word);
    procedure AddGuildChat(str: string);
    function ConvertEscChar(str: string): string;
    procedure UpgradeItemEffect(wResult: word);
    procedure DGABoardReplyVisibleOk(Index, ReplyCount: Integer; dsurface: TDXTexture);
  end;

var
  FrmDlg: TFrmDlg;

implementation

uses
  ClMain, MShare, Actor;

{$R *.DFM}

{
   ##  MovingItem.Index
      1~n : ����â�� ������ ����
      -1~-8 : ����â������ ������ ����
      -97 : ��ȯâ�� ��
      -98 : ��
      -99 : �ȱ� â������ ������ ����
      -20~29: ��ȯâ������ ������ ����
}

procedure TFrmDlg.FormCreate(Sender: TObject);
begin
  StatePage := 0;
  DlgTemp := TList.Create;
  DialogSize := 1; //�⺻ ũ��
  RunDice := 0;
  DiceType := 1;
  BoDrawDice := FALSE;
  magcur := 0;
  magtop := 0;
  MDlgPoints := TList.Create;
  SelectMenuStr := '';
  MenuList := TList.Create;
  JangwonList := TList.Create;
  GABoardList := TList.Create;
  GADecorationList := TList.Create;
  MenuIndex := -1;
  MenuTopLine := 0;
  BoDetailMenu := FALSE;
  BoStorageMenu := FALSE;
  BoNoDisplayMaxDura := FALSE;
  BoMakeDrugMenu := FALSE;
  BoMakeItemMenu := FALSE;
  BoMemoJangwon := False;
  NameMakeItem := '';
  MagicPage := 0;
   // 2003/04/15 ģ��, ����
  FriendPage := 0;
  BlackListPage := 0;
  MailPage := 0;
  BlockPage := 0;
  CurrentMail := -1;
  CurrentFriend := -1;
  CurrentBlack := -1;
  CurrentBlock := -1;
  ViewFriends := TRUE;
  ViewWindowNo := 0;
  ViewWindowData := 0;

  NAHelps := TStringList.Create;
  BlinkTime := GetTickCount;
  BlinkCount := 0;

  SellDlgItem.S.Name := '';
  Guild := '';
  GuildFlag := '';
  GuildCommanderMode := FALSE;
  GuildStrs := TStringList.Create;
  GuildStrs2 := TStringList.Create; //�����
  GuildNotice := TStringList.Create;
  GABoard_Notice := TStringList.Create;
  GuildMembers := TStringList.Create;
  GuildChats := TStringList.Create;

  EdDlgEdit := TEdit.Create(FrmMain.Owner);
  with EdDlgEdit do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    MaxLength := 30;
    Height := 16;
    Ctl3d := FALSE;
    BorderStyle := bsSingle;  {OnKeyPress := EdDlgEditKeyPress;}
    Visible := FALSE;
  end;

  EdCountEdit := TEdit.Create(FrmMain.Owner);
  with EdCountEdit do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    MaxLength := 20;
    Height := 16;
    Ctl3d := FALSE;
    BorderStyle := bsSingle;
    Visible := False;
  end;

  ItemSearchEdit := TEdit.Create(FrmMain.Owner);
  with ItemSearchEdit do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    MaxLength := 20;
    Height := 16;
    Ctl3d := FALSE;
    BorderStyle := bsSingle;
    Visible := False;
  end;

  Memo := TMemo.Create(FrmMain.Owner);
  with Memo do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    Ctl3d := FALSE;
    BorderStyle := bsSingle;  {OnKeyPress := EdDlgEditKeyPress;}
    Visible := FALSE;
  end;

   // 2003/04/15 ģ��, ����
  edCharID := TEdit.Create(FrmMain.Owner);
  with edCharID do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    MaxLength := 14;
    Height := 16;
    Ctl3d := FALSE;
    BorderStyle := bsSingle;  {OnKeyPress := EdDlgEditKeyPress;}
    Visible := FALSE;
  end;

  memoMail := TMemo.Create(FrmMain.Owner);
  with memoMail do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    MaxLength := 80;
    Ctl3d := FALSE;
    BorderStyle := bsSingle;  {OnKeyPress := EdDlgEditKeyPress;}
    Visible := FALSE;
  end;

  m_dwBlinkTime := GetTickCount;
  m_boViewBlink := False;
end;

procedure TFrmDlg.FormDestroy(Sender: TObject);
begin
  DlgTemp.Free;
  MDlgPoints.Free;  //������..
  MenuList.Free;
  JangwonList.Free;
  GABoardList.Free;
  GADecorationList.Free;
  NAHelps.Free;
  GuildStrs.Free;
  GuildStrs2.Free;
  GuildNotice.Free;
  GABoard_Notice.Free;
  GuildMembers.Free;
  GuildChats.Free;
end;

procedure TFrmDlg.HideAllControls;
var
  i: integer;
  c: TControl;
begin
  DlgTemp.Clear;
  with FrmMain do
    for i := 0 to ControlCount - 1 do
    begin
      c := Controls[i];
      if c is TEdit then
        if (c.Visible) and (c <> EdDlgEdit) then
        begin
          DlgTemp.Add(c);
          c.Visible := FALSE;
        end;
    end;
end;

procedure TFrmDlg.RestoreHideControls;
var
  i: integer;
  c: TControl;
begin
  for i := 0 to DlgTemp.Count - 1 do
  begin
    TControl(DlgTemp[i]).Visible := TRUE;
  end;
end;

procedure TFrmDlg.Initialize;  //������ ��������Ҷ����� ȣ���
var
  i, dsrvtop, dsrvheight: integer;
  lx, ly: integer;
  d: TDXTexture;
begin
  g_DWinMan.ClearAll;

  DBackground.Left := 0;
  DBackground.Top := 0;
  DBackground.Width := g_FScreenWidth;
  DBackground.Height := g_FScreenHeight;
  DBackground.Background := TRUE;
  g_DWinMan.AddDControl(DBackground, TRUE);

   {-----------------------------------------------------------}

   //��Ϣ�Ի���
  d := WProgUse.Images[360];
  if d <> nil then
  begin
    DMsgDlg.SetImgIndex(WProgUse, 360);
    DMsgDlg.Left := (g_FScreenWidth - d.Width) div 2;
    DMsgDlg.Top := (g_FScreenHeight - d.Height) div 2;
  end;
  DMsgDlgOk.SetImgIndex(WProgUse, 361);
  DMsgDlgYes.SetImgIndex(WProgUse, 363);
  DMsgDlgCancel.SetImgIndex(WProgUse, 365);
  DMsgDlgNo.SetImgIndex(WProgUse, 367);
  DMsgDlgOk.Top := 126;
  DMsgDlgYes.Top := 126;
  DMsgDlgCancel.Top := 126;
  DMsgDlgNo.Top := 126;

   {-----------------------------------------------------------}

   // ��½�˺Ŵ���
  d := WProgUse.Images[660]; //����
  if d <> nil then
  begin
    DCountDlg.SetImgIndex(WProgUse, 660);
    DCountDlg.Left := (g_FScreenWidth - d.Width) div 2;
    DCountDlg.Top := (g_FScreenHeight - d.Height) div 2;
  end;
  DCountDlgMax.SetImgIndex(WProgUse, 662);
  DCountDlgOk.SetImgIndex(WProgUse, 663);
  DCountDlgCancel.SetImgIndex(WProgUse, 664);
  DCountDlgClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}
  //������ѡ�񴰿�
  d := WProgUse.Images[661];
  if d <> nil then
  begin
    DMakeItemDlg.SetImgIndex(WProgUse, 661);
    DMakeItemDlg.Left := (g_FScreenWidth - d.Width) div 2;
    DMakeItemDlg.Top := (g_FScreenHeight - d.Height) div 2;
  end;

  DMakeitemGrid.Left := 16;
  DMakeitemGrid.Top := 13;
  DMakeitemGrid.Width := 240; //286;
  DMakeitemGrid.Height := 40; //80;

  lx := 163; //234;
  ly := 109; //141;

  DMakeItemDlgCancel.SetImgIndex(WProgUse, 674);  //664
  DMakeItemDlgCancel.Left := lx;
  DMakeItemDlgCancel.Top := ly;
  DMakeItemDlgCancel.Visible := True;
  lx := lx - 70;

  DMakeItemDlgOk.SetImgIndex(WProgUse, 691);  //663
  DMakeItemDlgOk.Left := lx;
  DMakeItemDlgOk.Top := ly;
  DMakeItemDlgOk.Visible := True;

  DMakeItemDlgClose.SetImgIndex(WProgUse, 64);
  DMakeItemDlgClose.Left := 246; //319;
  DMakeItemDlgClose.Top := 0;
  DMakeItemDlgClose.Visible := True;

  DMakeItemDlg.Floating := True;

   {-----------------------------------------------------------}
   //��½�Ի���
  d := WProgUse.Images[60];
  if d <> nil then
  begin
    DLogIn.SetImgIndex(WProgUse, 60);
    DLogIn.Left := (g_FScreenWidth - d.Width) div 2;
    DLogIn.Top := (g_FScreenHeight - d.Height) div 2;
  end;
  DLoginNew.SetImgIndex(WProgUse, 61);
  DLoginNew.Left := 25;
  DLoginNew.Top := 207;
  DLoginOk.SetImgIndex(WProgUse, 62);
  DLoginOk.Left := 169;
  DLoginOk.Top := 164;
  DLoginChgPw.SetImgIndex(WProgUse, 53);
  DLoginChgPw.Left := 130;
  DLoginChgPw.Top := 207;
  DLoginClose.SetImgIndex(WProgUse, 64);
  DLoginClose.Left := 252;
  DLoginClose.Top := 28;

   {-----------------------------------------------------------}


  DEngServer1.Visible := FALSE;

  DSServer1.Visible := FALSE;
  DSServer2.Visible := FALSE;
  DSServer3.Visible := FALSE;
  DSServer4.Visible := FALSE;
  DSServer5.Visible := FALSE;
  DSServer6.Visible := FALSE;
  DSServer7.Visible := FALSE;
  DSServer8.Visible := FALSE;

  if ServerCount >= 1 then
    DSServer1.Visible := TRUE;
  if ServerCount >= 2 then
    DSServer2.Visible := TRUE;
  if ServerCount >= 3 then
    DSServer3.Visible := TRUE;
  if ServerCount >= 4 then
    DSServer4.Visible := TRUE;
  if ServerCount >= 5 then
    DSServer5.Visible := TRUE;
  if ServerCount >= 6 then
    DSServer6.Visible := TRUE;
  if ServerCount >= 7 then
    DSServer7.Visible := TRUE;
  if ServerCount >= 8 then
    DSServer8.Visible := TRUE;

  if ServerCount <= 8 then
  begin
    dsrvheight := 42; //42;
    dsrvtop := 235 - (dsrvheight * ServerCount) div 2;

    d := WProgUse.Images[256];  //2];
    if d <> nil then
    begin
      DSelServerDlg.SetImgIndex(WProgUse, 256);
      DSelServerDlg.Left := (g_FScreenWidth - d.Width) div 2;
      DSelServerDlg.Top := (g_FScreenHeight - d.Height) div 2;
    end;
    DSSrvClose.SetImgIndex(WProgUse, 64);
    DSSrvClose.Left := 244;
    DSSrvClose.Top := 30;

    DSServer1.SetImgIndex(WProgUse2, 2); //82);
    DSServer1.Left := 63;
    DSServer1.Top := dsrvtop + 0 * dsrvheight; //102;

    DSServer2.SetImgIndex(WProgUse2, 2); //82);
    DSServer2.Left := 63;
    DSServer2.Top := dsrvtop + 1 * dsrvheight; //102;

    DSServer3.SetImgIndex(WProgUse2, 2); //82);
    DSServer3.Left := 63;
    DSServer3.Top := dsrvtop + 2 * dsrvheight; //102;

    DSServer4.SetImgIndex(WProgUse2, 2); //82);
    DSServer4.Left := 63;
    DSServer4.Top := dsrvtop + 3 * dsrvheight; //102;

    DSServer5.SetImgIndex(WProgUse2, 2); //82);
    DSServer5.Left := 63;
    DSServer5.Top := dsrvtop + 4 * dsrvheight; //102;

    DSServer6.SetImgIndex(WProgUse2, 2); //82);
    DSServer6.Left := 63;
    DSServer6.Top := dsrvtop + 5 * dsrvheight; //102;

    DSServer7.SetImgIndex(WProgUse2, 2); //82);
    DSServer7.Left := 63;
    DSServer7.Top := dsrvtop + 6 * dsrvheight; //102;

    DSServer8.SetImgIndex(WProgUse2, 2); //82);
    DSServer8.Left := 63;
    DSServer8.Top := dsrvtop + 7 * dsrvheight; //102;
  end;

  if (ServerCount > 8) and (ServerCount <= 16) then
  begin
    dsrvheight := 42;
    dsrvtop := 235 - (dsrvheight * 16{ServerCount}  div 2) div 2;

    d := WProgUse2.Images[4];
    if d <> nil then
    begin
      DSelServerDlg.SetImgIndex(WProgUse2, 4);
      DSelServerDlg.Left := (g_FScreenWidth - d.Width) div 2;
      DSelServerDlg.Top := (g_FScreenHeight - d.Height) div 2;
    end;
    DSSrvClose.SetImgIndex(WProgUse, 64);
    DSSrvClose.Left := 348;
    DSSrvClose.Top := 31;

    DSServer1.SetImgIndex(WProgUse2, 2); //82);
    DSServer1.Left := 25;
    DSServer1.Top := dsrvtop + 0 * dsrvheight; //102;

    DSServer2.SetImgIndex(WProgUse2, 2); //82);
    DSServer2.Left := 25;
    DSServer2.Top := dsrvtop + 1 * dsrvheight; //102;

    DSServer3.SetImgIndex(WProgUse2, 2); //82);
    DSServer3.Left := 25;
    DSServer3.Top := dsrvtop + 2 * dsrvheight; //102;

    DSServer4.SetImgIndex(WProgUse2, 2); //82);
    DSServer4.Left := 25;
    DSServer4.Top := dsrvtop + 3 * dsrvheight; //102;

    DSServer5.SetImgIndex(WProgUse2, 2); //82);
    DSServer5.Left := 25;
    DSServer5.Top := dsrvtop + 4 * dsrvheight; //102;

    DSServer6.SetImgIndex(WProgUse2, 2); //82);
    DSServer6.Left := 25;
    DSServer6.Top := dsrvtop + 5 * dsrvheight; //102;

    DSServer7.SetImgIndex(WProgUse2, 2); //82);
    DSServer7.Left := 25;
    DSServer7.Top := dsrvtop + 6 * dsrvheight; //102;

    DSServer8.SetImgIndex(WProgUse2, 2); //82);
    DSServer8.Left := 25;
    DSServer8.Top := dsrvtop + 7 * dsrvheight; //102;

  end;

  if (ServerCount > 16) then
  begin // and (ServerCount <= 24) then begin
    dsrvheight := 42;
    dsrvtop := 235 - (dsrvheight * 8) div 2;

    d := WProgUse2.Images[5];
    if d <> nil then
    begin
      DSelServerDlg.SetImgIndex(WProgUse2, 5);
      DSelServerDlg.Left := (g_FScreenWidth - d.Width) div 2;
      DSelServerDlg.Top := (g_FScreenHeight - d.Height) div 2;
    end;
    DSSrvClose.SetImgIndex(WProgUse, 64);
    DSSrvClose.Left := 527;
    DSSrvClose.Top := 35;

    DSServer1.SetImgIndex(WProgUse2, 2); //82);
    DSServer1.Left := 25;
    DSServer1.Top := dsrvtop + 0 * dsrvheight; //102;

    DSServer2.SetImgIndex(WProgUse2, 2); //82);
    DSServer2.Left := 25;
    DSServer2.Top := dsrvtop + 1 * dsrvheight; //102;

    DSServer3.SetImgIndex(WProgUse2, 2); //82);
    DSServer3.Left := 25;
    DSServer3.Top := dsrvtop + 2 * dsrvheight; //102;

    DSServer4.SetImgIndex(WProgUse2, 2); //82);
    DSServer4.Left := 25;
    DSServer4.Top := dsrvtop + 3 * dsrvheight; //102;

    DSServer5.SetImgIndex(WProgUse2, 2); //82);
    DSServer5.Left := 25;
    DSServer5.Top := dsrvtop + 4 * dsrvheight; //102;

    DSServer6.SetImgIndex(WProgUse2, 2); //82);
    DSServer6.Left := 25;
    DSServer6.Top := dsrvtop + 5 * dsrvheight; //102;

    DSServer7.SetImgIndex(WProgUse2, 2); //82);
    DSServer7.Left := 25;
    DSServer7.Top := dsrvtop + 6 * dsrvheight; //102;

    DSServer8.SetImgIndex(WProgUse2, 2); //82);
    DSServer8.Left := 25;
    DSServer8.Top := dsrvtop + 7 * dsrvheight; //102;

  end;



   {-----------------------------------------------------------}

   //�½��˺Ŵ���
  d := WProgUse.Images[63];
  if d <> nil then
  begin
    DNewAccount.SetImgIndex(WProgUse, 63);
    DNewAccount.Left := (g_FScreenWidth - d.Width) div 2;
    DNewAccount.Top := (g_FScreenHeight - d.Height) div 2;
  end;
  DNewAccountOk.SetImgIndex(WProgUse, 62);
  DNewAccountOk.Left := 160;
  DNewAccountOk.Top := 417;
  DNewAccountCancel.SetImgIndex(WProgUse, 52);
  DNewAccountCancel.Left := 448;
  DNewAccountCancel.Top := 419;
  DNewAccountClose.SetImgIndex(WProgUse, 64);
  DNewAccountClose.Left := 587;
  DNewAccountClose.Top := 33;
   {-----------------------------------------------------------}
   //LOGO����
//   DLOGO.Left := 0;
//   DLOGO.Top := 0;
//   DLOGO.Width := 800;
//   DLOGO.Height := 600;
   {-----------------------------------------------------------}

   //�޸����봰��
  d := WProgUse.Images[50];
  if d <> nil then
  begin
    DChgPw.SetImgIndex(WProgUse, 50);
    DChgPw.Left := (g_FScreenWidth - d.Width) div 2;
    DChgPw.Top := (g_FScreenHeight - d.Height) div 2;
  end;
  DChgpwOk.SetImgIndex(WProgUse, 62);
  DChgPwOk.Left := 181;
  DChgPwOk.Top := 253;
  DChgpwCancel.SetImgIndex(WProgUse, 52);
  DChgPwCancel.Left := 276;
  DChgPwCancel.Top := 252;

   {-----------------------------------------------------------}

   //ѡ���ɫ����
  DSelectChr.Left := 0;
  DSelectChr.Top := 0;
  DSelectChr.Width := g_FScreenWidth;
  DSelectChr.Height := g_FScreenHeight;
  DscSelect1.SetImgIndex(WProgUse, 66);
  DscSelect2.SetImgIndex(WProgUse, 67);
  DscStart.SetImgIndex(WProgUse, 68);
  DscNewChr.SetImgIndex(WProgUse, 69);
  DscEraseChr.SetImgIndex(WProgUse, 70);
  DscCredits.SetImgIndex(WProgUse, 71);
  DscExit.SetImgIndex(WProgUse, 72);

  DscSelect1.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 133;
  DscSelect1.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 453;
  DscSelect2.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 685;
  DscSelect2.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 454;
  DscStart.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 385;
  DscStart.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 456;
  DscNewChr.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 348;
  DscNewChr.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 486;
  DscEraseChr.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 347;
  DscEraseChr.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 506;
  DscCredits.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 362;
  DscCredits.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 527;
  DscExit.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 379;
  DscExit.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 547;

   {-----------------------------------------------------------}

   //������ɫ����

   //������ɫ����
  d := WProgUse.Images[73];
  if d <> nil then
  begin
    DCreateChr.SetImgIndex(WProgUse, 73);
    DCreateChr.Left := (g_FScreenWidth - d.Width) div 2;
    DCreateChr.Top := (g_FScreenHeight - d.Height) div 2;
  end;
  DccWarrior.SetImgIndex(WProgUse, 74);
  DccWizzard.SetImgIndex(WProgUse, 75);
  DccMonk.SetImgIndex(WProgUse, 76);
   //DccReserved.SetImgIndex (WProgUse.Images[76], TRUE);
  DccMale.SetImgIndex(WProgUse, 77);
  DccFemale.SetImgIndex(WProgUse, 78);
  DccLeftHair.SetImgIndex(WProgUse, 79);
  DccRightHair.SetImgIndex(WProgUse, 80);
  DccOk.SetImgIndex(WProgUse, 62);
  DccClose.SetImgIndex(WProgUse, 64);
  DccWarrior.Left := 48;
  DccWarrior.Top := 157;
  DccWizzard.Left := 93;
  DccWizzard.Top := 157;
  DccMonk.Left := 138;
  DccMonk.Top := 157;
      //DccReserved.Left := 183;
      //DccReserved.Top := 157;
  DccMale.Left := 93;
  DccMale.Top := 231;
  DccFemale.Left := 138;
  DccFemale.Top := 231;
  DccLeftHair.Left := 76;
  DccLeftHair.Top := 308;
  DccRightHair.Left := 170;
  DccRightHair.Top := 308;
  DccClose.Left := 248;
  DccClose.Top := 31;
  DccOk.Left := 102;
  DccOk.Top := 359;


   {-----------------------------------------------------------}
   //����״̬����
  d := WProgUse.Images[370];  //����
  if d <> nil then
  begin
    DStateWin.SetImgIndex(WProgUse, 370);
    DStateWin.Left := g_FScreenWidth - d.Width;
    DStateWin.Top := 0;
  end;
  DSWNecklace.Left := 38 + 130;
  DSWNecklace.Top := 52 + 35;
  DSWNecklace.Width := 34;
  DSWNecklace.Height := 31;
  DSWHelmet.Left := 38 + 77;
  DSWHelmet.Top := 52 + 41;
  DSWHelmet.Width := 18;
  DSWHelmet.Height := 18;
  DSWLight.Left := 38 + 130;
  DSWLight.Top := 52 + 73;
  DSWLight.Width := 34;
  DSWLight.Height := 31;
  DSWArmRingR.Left := 38 + 4;
  DSWArmRingR.Top := 52 + 124;
  DSWArmRingR.Width := 34;
  DSWArmRingR.Height := 31;
  DSWArmRingL.Left := 38 + 130;
  DSWArmRingL.Top := 52 + 124;
  DSWArmRingL.Width := 34;
  DSWArmRingL.Height := 31;
  DSWRingR.Left := 38 + 4;
  DSWRingR.Top := 52 + 163;
  DSWRingR.Width := 34;
  DSWRingR.Height := 31;
  DSWRingL.Left := 38 + 130;
  DSWRingL.Top := 52 + 163;
  DSWRingL.Width := 34;
  DSWRingL.Height := 31;
  DSWWeapon.Left := 38 + 9;
  DSWWeapon.Top := 52 + 28;
  DSWWeapon.Width := 47;
  DSWWeapon.Height := 87;
  DSWDress.Left := 38 + 58;
  DSWDress.Top := 52 + 70;
  DSWDress.Width := 53;
  DSWDress.Height := 112;
      // 2003/03/15 ������ �κ��丮 Ȯ��
  DSWBujuk.Left := 38 + 4;
  DSWBujuk.Top := 52 + 202;
  DSWBujuk.Width := 34;
  DSWBujuk.Height := 31;
  DSWBelt.Left := 38 + 46;
  DSWBelt.Top := 52 + 202;
  DSWBelt.Width := 34;
  DSWBelt.Height := 31;
  DSWBoots.Left := 38 + 88;
  DSWBoots.Top := 52 + 202;
  DSWBoots.Width := 34;
  DSWBoots.Height := 31;
  DSWCharm.Left := 38 + 130;
  DSWCharm.Top := 52 + 202;
  DSWCharm.Width := 34;
  DSWCharm.Height := 31;

  DStMag1.Left := 38 + 8;
  DStMag1.Top := 52 + 7;
  DStMag1.Width := 31;
  DStMag1.Height := 33;
  DStMag2.Left := 38 + 8;
  DStMag2.Top := 52 + 44;
  DStMag2.Width := 31;
  DStMag2.Height := 33;
  DStMag3.Left := 38 + 8;
  DStMag3.Top := 52 + 82;
  DStMag3.Width := 31;
  DStMag3.Height := 33;
  DStMag4.Left := 38 + 8;
  DStMag4.Top := 52 + 119;
  DStMag4.Width := 31;
  DStMag4.Height := 33;
  DStMag5.Left := 38 + 8;
  DStMag5.Top := 52 + 156;
  DStMag5.Width := 31;
  DStMag5.Height := 33;

  DStPageUp.SetImgIndex(WProgUse, 398);
  DStPageDown.SetImgIndex(WProgUse, 396);
  DStPageUp.Left := 213;
  DStPageUp.Top := 113;
  DStPageDown.Left := 213;
  DStPageDown.Top := 143;

  DCloseState.SetImgIndex(WProgUse, 371);
  DCloseState.Left := 8;
  DCloseState.Top := 39;
  DPrevState.SetImgIndex(WProgUse, 373);
  DNextState.SetImgIndex(WProgUse, 372);
  DPrevState.Left := 7;
  DPrevState.Top := 128;
  DNextState.Left := 7;
  DNextState.Top := 187;
  DHeartImg.SetImgIndex(WProgUse, 604);

   {-----------------------------------------------------------}

   //����״̬����(�鿴������Ϣ)
  d := WProgUse.Images[370];  //����
  if d <> nil then
  begin
    DUserState1.SetImgIndex(WProgUse, 370);
    DUserState1.Left := g_FScreenWidth - d.Width - d.Width;
    DUserState1.Top := 0;
  end;
  DNecklaceUS1.Left := 38 + 130;
  DNecklaceUS1.Top := 52 + 35;
  DNecklaceUS1.Width := 34;
  DNecklaceUS1.Height := 31;
  DHelmetUS1.Left := 38 + 77;
  DHelmetUS1.Top := 52 + 41;
  DHelmetUS1.Width := 18;
  DHelmetUS1.Height := 18;
  DLightUS1.Left := 38 + 130;
  DLightUS1.Top := 52 + 73;
  DLightUS1.Width := 34;
  DLightUS1.Height := 31;
  DArmRingRUS1.Left := 38 + 4;
  DArmRingRUS1.Top := 52 + 124;
  DArmRingRUS1.Width := 34;
  DArmRingRUS1.Height := 31;
  DArmRingLUS1.Left := 38 + 130;
  DArmRingLUS1.Top := 52 + 124;
  DArmRingLUS1.Width := 34;
  DArmRingLUS1.Height := 31;
  DRingRUS1.Left := 38 + 4;
  DRingRUS1.Top := 52 + 163;
  DRingRUS1.Width := 34;
  DRingRUS1.Height := 31;
  DRingLUS1.Left := 38 + 130;
  DRingLUS1.Top := 52 + 163;
  DRingLUS1.Width := 34;
  DRingLUS1.Height := 31;
  DWeaponUS1.Left := 38 + 9;
  DWeaponUS1.Top := 52 + 28;
  DWeaponUS1.Width := 47;
  DWeaponUS1.Height := 87;
  DDressUS1.Left := 38 + 58;
  DDressUS1.Top := 52 + 70;
  DDressUS1.Width := 53;
  DDressUS1.Height := 112;

      // 2003/03/15 ������ �κ��丮 Ȯ��
  DBujukUS1.Left := 38 + 4;
  DBujukUS1.Top := 52 + 202;
  DBujukUS1.Width := 34;
  DBujukUS1.Height := 31;
  DBeltUS1.Left := 38 + 46;
  DBeltUS1.Top := 52 + 202;
  DBeltUS1.Width := 34;
  DBeltUS1.Height := 31;
  DBootsUS1.Left := 38 + 88;
  DBootsUS1.Top := 52 + 202;
  DBootsUS1.Width := 34;
  DBootsUS1.Height := 31;
  DCharmUS1.Left := 38 + 130;
  DCharmUS1.Top := 52 + 202;
  DCharmUS1.Width := 34;
  DCharmUS1.Height := 31;

  DCloseUS1.SetImgIndex(WProgUse, 371);
  DCloseUS1.Left := 8;
  DCloseUS1.Top := 39;
  DHeartImgUS.SetImgIndex(WProgUse, 604);

  {-------------------------------------------------------------}

   //��Ʒ������
  DItemBag.SetImgIndex(WProgUse, 3);
  DItemBag.Left := 0;
  DItemBag.Top := 0;
  DItemGrid.Left := 20;
  DItemGrid.Top := 13;
  DItemGrid.Width := 286;
  DItemGrid.Height := 162;

  BoUpItemEffect := FALSE;
   {-----------------------------------------------------------}

   //�������
  if g_FScreenMode = 1 then d := WProgUse.Images[BOTTOMBOARD1024]
  else d := WProgUse.Images[BOTTOMBOARD];
  if d <> nil then
  begin
    DBottom.Left := 0;
    DBottom.Top := g_FScreenHeight - d.Height;
    DBottom.Width := d.Width;
    DBottom.Height := d.Height;
  end;

   {-----------------------------------------------------------}

   //�ײ�״̬����4����ݰ�ť
  DMyState.SetImgIndex(WProgUse, 8);
  DMyState.Left := g_FScreenWidth-157;
  DMyState.Top := 61;
  DMyBag.SetImgIndex(WProgUse, 9);
  DMyBag.Left := g_FScreenWidth-118;
  DMyBag.Top := 41;
  DMyMagic.SetImgIndex(WProgUse, 10);
  DMyMagic.Left := g_FScreenWidth-78;
  DMyMagic.Top := 21;
  DOption.SetImgIndex(WProgUse, 11);
  DOption.Left := g_FScreenWidth-36;
  DOption.Top := 11;

   {-----------------------------------------------------------}

   //�ײ�״̬����С��ͼ�����ס��лᡢ�鰴ť
  DBotMiniMap.SetImgIndex(WProgUse, 130);
  DBotMiniMap.Left := 219;
  DBotMiniMap.Top := 104;
  DBotTrade.SetImgIndex(WProgUse, 132);
  DBotTrade.Left := 219 + 30; //560 - 30;
  DBotTrade.Top := 104;
  DBotGuild.SetImgIndex(WProgUse, 134);
  DBotGuild.Left := 219 + 30 * 2;
  DBotGuild.Top := 104;
  DBotGroup.SetImgIndex(WProgUse, 128);
  DBotGroup.Left := 219 + 30 * 3;
  DBotGroup.Top := 104;
  DBotPlusAbil.SetImgIndex(WProgUse, 140); //�ӵ�
  DBotPlusAbil.Left := 219 + 30 * 4;
  DBotPlusAbil.Top := 104;
   // 2003/04/15 ����, ����
  DBotFriend.SetImgIndex(WProgUse, 530); //����
  DBotFriend.Left := 219 + 30 * 4;
  DBotFriend.Top := 104;
  DBotMaster.SetImgIndex(WProgUse, 528); //����
  DBotMaster.Left := 219 + 30 * 5;
  DBotMaster.Top := 104;

  DBotMemo.SetImgIndex(WProgUse, 532); //�ʼ�
  DBotMemo.Left := g_FScreenWidth-47;
  DBotMemo.Top := 204;
  DBotExit.SetImgIndex(WProgUse, 138);
  DBotExit.Left := g_FScreenWidth-240;
  DBotExit.Top := 104;
  DBotLogout.SetImgIndex(WProgUse, 136);
  DBotLogout.Left := g_FScreenWidth-270;
  DBotLogout.Top := 104;
   {-----------------------------------------------------------}
   //������Ϣ�����
   RefusePublicChat.SetImgIndex(WProgUse,280); //�ܾ����й�����Ϣ
   RefusePublicChat.Left:=176;
   RefusePublicChat.Top:=120;

   RefuseCRY.SetImgIndex(WProgUse,282);    //�ܾ����к�����Ϣ
   RefuseCRY.Left:=176;
   RefuseCRY.Top:=140;

   RefuseWHISPER.SetImgIndex(WProgUse,284);   //�ܾ�����˽����Ϣ
   RefuseWHISPER.Left:=176;
   RefuseWHISPER.Top:=160;

   Refuseguild.SetImgIndex(WProgUse,286);  //�ܾ��л�������Ϣ
   Refuseguild.Left:=176;
   Refuseguild.Top:=180;

   AutoCRY.SetImgIndex(WProgUse,288);   //�Զ���������
   AutoCRY.Left:=176;
   AutoCRY.Top:=200;
   //��ҩ�����
  DBelt1.Left := (g_FScreenWidth div 2)-115;
  DBelt1.Width := 32;
  DBelt1.Top := 59;
  DBelt1.Height := 29;
  DBelt2.Left := (g_FScreenWidth div 2)-72;
  DBelt2.Width := 32;
  DBelt2.Top := 59;
  DBelt2.Height := 29;
  DBelt3.Left := (g_FScreenWidth div 2)-29;
  DBelt3.Width := 32;
  DBelt3.Top := 59;
  DBelt3.Height := 29;
  DBelt4.Left := (g_FScreenWidth div 2)+15;
  DBelt4.Width := 32;
  DBelt4.Top := 59;
  DBelt4.Height := 29;
  DBelt5.Left := (g_FScreenWidth div 2)+59;
  DBelt5.Width := 32;
  DBelt5.Top := 59;
  DBelt5.Height := 29;
  DBelt6.Left := (g_FScreenWidth div 2)+103;
  DBelt6.Width := 32;
  DBelt6.Top := 59;
  DBelt6.Height := 29;
   {-----------------------------------------------------------}

   //�ƽ�������Ʒ���رհ�����ť
  DGold.SetImgIndex(WProgUse, 29);
  DGold.Left := 10;
  DGold.Top := 190;
  DRepairItem.SetImgIndex(WProgUse, 26);
  DRepairItem.Left := 254;
  DRepairItem.Top := 183;
  DRepairItem.Width := 48;
  DRepairItem.Height := 22;
  DClosebag.SetImgIndex(WProgUse, 371);
  DCloseBag.Left := 309;
  DCloseBag.Top := 203;
  DCloseBag.Width := 14;
  DCloseBag.Height := 20;

   {-----------------------------------------------------------}

   //���˶Ի���
  d := WProgUse.Images[384];
  if d <> nil then
  begin
    DMerchantDlg.Left := 0;
    DMerchantDlg.Top := 0;
    DMerchantDlg.SetImgIndex(WProgUse, 384);
  end;
  DMerchantDlgClose.Left := 399;
  DMerchantDlgClose.Top := 1;
  DMerchantDlgClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}

   //�˵��Ի���
  d := WProgUse.Images[385];
  if d <> nil then
  begin
    DMenuDlg.Left := 138;
    DMenuDlg.Top := 163;
    DMenuDlg.SetImgIndex(WProgUse, 385);
  end;
  DMenuPrev.Left := 43;
  DMenuPrev.Top := 175;
  DMenuPrev.SetImgIndex(WProgUse, 388);
  DMenuNext.Left := 90;
  DMenuNext.Top := 175;
  DMenuNext.SetImgIndex(WProgUse, 387);
  DMenuBuy.Left := 215;
  DMenuBuy.Top := 171;
  DMenuBuy.SetImgIndex(WProgUse, 386);
  DMenuClose.Left := 291;
  DMenuClose.Top := 0;
  DMenuClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}

   //����ϵͳ  //2004/01/15 ItemMarket..
  d := WProgUse.Images[670];
  if d <> nil then
  begin
    DItemMarketDlg.Left := 0;
    DItemMarketDlg.Top := 90;
    DItemMarketDlg.SetImgIndex(WProgUse, 670);
  end;

  DItemListPrev.Left := 216;
  DItemListPrev.Top := 355;
  DItemListPrev.SetImgIndex(WProgUse, 388);
  DItemListNext.Left := 303;
  DItemListNext.Top := 355;
  DItemListNext.SetImgIndex(WProgUse, 387);
  DItemListRefresh.Left := 259;
  DItemListRefresh.Top := 356;
  DItemListRefresh.SetImgIndex(WProgUse, 671);

  DItemBuy.Left := 330;
  DItemBuy.Top := 326; //418;
  DItemBuy.SetImgIndex(WProgUse, 672);
  DItemSellCancel.Left := 330;
  DItemSellCancel.Top := 326; //418;
  DItemSellCancel.SetImgIndex(WProgUse, 544);
  DItemCancel.Left := 396;
  DItemCancel.Top := 325; //418;
  DItemCancel.SetImgIndex(WProgUse, 674);
  DItemFind.Left := 145;
  DItemFind.Top := 327; //417;
  DItemFind.SetImgIndex(WProgUse, 676);
  DMarketMemo.Left := 305; //258;
  DMarketMemo.Top := 326;
  DMarketMemo.SetImgIndex(WProgUse, 681);

  DMGold.Visible := False;
//   DMGold.SetImgIndex (WProgUse, 29); //��ũ�� 3�� ����
//   DMGold.Left := 465;
//   DMGold.Top  := 226;

  DItemMarketClose.Left := 447;
  DItemMarketClose.Top := 7;
  DItemMarketClose.SetImgIndex(WProgUse, 64);
   {-----------------------------------------------------------}

   //װ��Ʒ�� //2004/06/18
  d := WProgUse.Images[702];
  if d <> nil then
  begin
    DGADecorateDlg.Left := 0;
    DGADecorateDlg.Top := 55; //90;
    DGADecorateDlg.SetImgIndex(WProgUse, 702);
  end;

  DGADecorateListPrev.Left := 150;
  DGADecorateListPrev.Top := 361;
  DGADecorateListPrev.SetImgIndex(WProgUse, 388);
  DGADecorateListNext.Left := 237;
  DGADecorateListNext.Top := 361;
  DGADecorateListNext.SetImgIndex(WProgUse, 387);

  DGADecorateBuy.Left := 211;
  DGADecorateBuy.Top := 304;
  DGADecorateBuy.SetImgIndex(WProgUse, 672);
  DGADecorateCancel.Left := 211;
  DGADecorateCancel.Top := 328;
  DGADecorateCancel.SetImgIndex(WProgUse, 674);
  DGADecorateClose.Left := 581; //410;
  DGADecorateClose.Top := 6;
  DGADecorateClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}

  d := WProgUse.Images[680];
  if d <> nil then
  begin
    DJangwonListDlg.Left := 0;
    DJangwonListDlg.Top := 175;
    DJangwonListDlg.SetImgIndex(WProgUse, 680);
  end;

  DJangListPrev.Left := 208; //152;
  DJangListPrev.Top := 199;
  DJangListPrev.SetImgIndex(WProgUse, 388);
  DJangListNext.Left := 298; //242;
  DJangListNext.Top := 199;
  DJangListNext.SetImgIndex(WProgUse, 387);
  DJangMemo.Left := 254; //197;
  DJangMemo.Top := 193;
  DJangMemo.SetImgIndex(WProgUse, 681);

  DMGold.Visible := False;
//   DMGold.SetImgIndex (WProgUse, 29); //��ũ�� 3�� ����
//   DMGold.Left := 465;
//   DMGold.Top  := 226;

  DJangwonClose.Left := 522; //410;
  DJangwonClose.Top := 0;
  DJangwonClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}
   //ׯ԰������
  d := WProgUse.Images[688];
  if d <> nil then
  begin
    DGABoardListDlg.Left := 0;
    DGABoardListDlg.Top := 175;
    DGABoardListDlg.SetImgIndex(WProgUse, 688);
  end;

  DGABoardOk.Left := 344;
  DGABoardOk.Top := 262;
  DGABoardOk.SetImgIndex(WProgUse, 691);
  DGABoardWrite.Left := 275;
  DGABoardWrite.Top := 262;
  DGABoardWrite.SetImgIndex(WProgUse, 693);
  DGABoardNotice.Left := 206;
  DGABoardNotice.Top := 262;
  DGABoardNotice.SetImgIndex(WProgUse, 695);

  DGABoardListPrev.Left := 61;
  DGABoardListPrev.Top := 280;
  DGABoardListPrev.SetImgIndex(WProgUse, 388);
  DGABoardListNext.Left := 148;
  DGABoardListNext.Top := 280;
  DGABoardListNext.SetImgIndex(WProgUse, 387);
  DGABoardListRefresh.Left := 104;
  DGABoardListRefresh.Top := 281;
  DGABoardListRefresh.SetImgIndex(WProgUse, 671);

  DGABoardListClose.Left := 401;
  DGABoardListClose.Top := 6;
  DGABoardListClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}
   //ׯ԰��������Ϣ�޸�
  d := WProgUse.Images[689];
  if d <> nil then
  begin
    DGABoardDlg.Left := 0;
    DGABoardDlg.Top := 175;
    DGABoardDlg.SetImgIndex(WProgUse, 689);
  end;

  DGABoardDel.Left := 19;
  DGABoardDel.Top := 186;
  DGABoardDel.SetImgIndex(WProgUse, 697);
  DGABoardMemo.Left := 85;
  DGABoardMemo.Top := 186;
  DGABoardMemo.SetImgIndex(WProgUse, 681);

  DGABoardReply.Left := 109;
  DGABoardReply.Top := 186;
  DGABoardReply.SetImgIndex(WProgUse, 699);
  DGABoardOk2.Left := 175;
  DGABoardOk2.Top := 186;
  DGABoardOk2.SetImgIndex(WProgUse, 691);
  DGABoardCancel.Left := 241;
  DGABoardCancel.Top := 186;
  DGABoardCancel.SetImgIndex(WProgUse, 674);

  DGABoardClose.Left := 291;
  DGABoardClose.Top := 8;
  DGABoardClose.SetImgIndex(WProgUse, 64);

   {-----------------------------------------------------------}

   //���۶Ի���
  d := WProgUse.Images[392];
  if d <> nil then
  begin
    DSellDlg.Left := 328;
    DSellDlg.Top := 163;
    DSellDlg.SetImgIndex(WProgUse, 392);
  end;
  DSellDlgOk.Left := 85;
  DSellDlgOk.Top := 150;
  DSellDlgOk.SetImgIndex(WProgUse, 393);
  DSellDlgClose.Left := 115;
  DSellDlgClose.Top := 0;
  DSellDlgClose.SetImgIndex(WProgUse, 64);
  DSellDlgSpot.Left := 27;
  DSellDlgSpot.Top := 67;
  DSellDlgSpot.Width := 61;
  DSellDlgSpot.Height := 52;

   {-----------------------------------------------------------}

   //����ħ����ݶԻ���
  d := WProgUse.Images[620];
  if d <> nil then
  begin
    DKeySelDlg.Left := (g_FScreenWidth - d.Width) div 2;
    DKeySelDlg.Top := (g_FScreenHeight - d.Height) div 2;
    DKeySelDlg.SetImgIndex(WProgUse, 620);
  end;
  DKsIcon.Left := 51;  //DMagIcon...
  DKsIcon.Top := 31;
  DKsF1.SetImgIndex(WProgUse, 232);
  DKsF1.Left := 25; //34; //-9
  DKsF1.Top := 78; //83; //-4
  DKsF2.SetImgIndex(WProgUse, 234);
  DKsF2.Left := 57; //66;
  DKsF2.Top := 78; //83;
  DKsF3.SetImgIndex(WProgUse, 236);
  DKsF3.Left := 89; //98;
  DKsF3.Top := 78; //83;
  DKsF4.SetImgIndex(WProgUse, 238);
  DKsF4.Left := 121; ////130;
  DKsF4.Top := 78;
  DKsF5.SetImgIndex(WProgUse, 240);
  DKsF5.Left := 160; //171; //-11
  DKsF5.Top := 78;
  DKsF6.SetImgIndex(WProgUse, 242);
  DKsF6.Left := 192; //203;
  DKsF6.Top := 78;
  DKsF7.SetImgIndex(WProgUse, 244);
  DKsF7.Left := 224; //235;
  DKsF7.Top := 78;
  DKsF8.SetImgIndex(WProgUse, 246);
  DKsF8.Left := 256; //267;
  DKsF8.Top := 78;
  DKsConF1.SetImgIndex(WProgUse, 626);
  DKsConF1.Left := 25;
  DKsConF1.Top := 120;
  DKsConF2.SetImgIndex(WProgUse, 628);
  DKsConF2.Left := 57;
  DKsConF2.Top := 120;
  DKsConF3.SetImgIndex(WProgUse, 630);
  DKsConF3.Left := 89;
  DKsConF3.Top := 120;
  DKsConF4.SetImgIndex(WProgUse, 632);
  DKsConF4.Left := 121;
  DKsConF4.Top := 120;
  DKsConF5.SetImgIndex(WProgUse, 634);
  DKsConF5.Left := 160;
  DKsConF5.Top := 120;
  DKsConF6.SetImgIndex(WProgUse, 636);
  DKsConF6.Left := 192;
  DKsConF6.Top := 120;
  DKsConF7.SetImgIndex(WProgUse, 638);
  DKsConF7.Left := 224;
  DKsConF7.Top := 120;
  DKsConF8.SetImgIndex(WProgUse, 640);
  DKsConF8.Left := 256;
  DKsConF8.Top := 120;
  DKsNone.SetImgIndex(WProgUse, 624);
  DKsNone.Left := 296; //299;//-2
  DKsNone.Top := 78; //83;//-4
  DKsOk.SetImgIndex(WProgUse, 621);
  DKsOk.Left := 296; //222;
  DKsOk.Top := 120; //131;

   {-----------------------------------------------------------}
   //��Ի���
  d := WProgUse.Images[120];
  if d <> nil then
  begin
    DGroupDlg.Left := (g_FScreenWidth - d.Width) div 2;
    DGroupDlg.Top := (g_FScreenHeight - d.Height) div 2;
    DGroupDlg.SetImgIndex(WProgUse, 120);
  end;
  DGrpDlgClose.SetImgIndex(WProgUse, 64);
  DGrpDlgClose.Left := 260;
  DGrpDlgClose.Top := 0;
  DGrpAllowGroup.SetImgIndex(WProgUse, 122);
  DGrpAllowGroup.Left := 20;
  DGrpAllowGroup.Top := 18;
  DGrpCreate.SetImgIndex(WProgUse, 123);
  DGrpCreate.Left := 21 + 1;
  DGrpCreate.Top := 202 + 1;
  DGrpAddMem.SetImgIndex(WProgUse, 124);
  DGrpAddMem.Left := 96 + 1;
  DGrpAddMem.Top := 202 + 1;
  DGrpDelMem.SetImgIndex(WProgUse, 125);
  DGrpDelMem.Left := 171 + 1;
  DGrpDelMem.Top := 202 + 1;

   {-----------------------------------------------------------}
  //���׶Ի���
  d := WProgUse.Images[389];  //������
  if d <> nil then
  begin
    DDealDlg.Left := g_FScreenWidth - d.Width;
    DDealDlg.Top := 0;
    DDealDlg.SetImgIndex(WProgUse, 389);
  end;
  DDGrid.Left := 21;
  DDGrid.Top := 56;
  DDGrid.Width := 36 * 5;
  DDGrid.Height := 33 * 2;
  DDealOk.SetImgIndex(WProgUse, 391);
  DDealOk.Left := 155;
  DDealOk.Top := 193 - 65;
  DDealClose.SetImgIndex(WProgUse, 64);
  DDealClose.Left := 220;
  DDealClose.Top := 42;
  DDGold.SetImgIndex(WProgUse, 28);
  DDGold.Left := 11;
  DDGold.Top := 202 - 65;

  d := WProgUse.Images[390];  //�����
  if d <> nil then
  begin
    DDealRemoteDlg.Left := DDealDlg.Left - d.Width;
    DDealRemoteDlg.Top := 0;
    DDealRemoteDlg.SetImgIndex(WProgUse, 390);
  end;
  DDRGrid.Left := 21;
  DDRGrid.Top := 56;
  DDRGrid.Width := 36 * 5;
  DDRGrid.Height := 33 * 2;
  DDRGold.SetImgIndex(WProgUse, 28);
  DDRGold.Left := 11;
  DDRGold.Top := 202 - 65;

   // ��� �ŷ� �˸���
  d := WProgUse.Images[683];
  if d <> nil then
  begin
    DDealJangwon.Left := 388;
    DDealJangwon.Top := 138;
    DDealJangwon.SetImgIndex(WProgUse, 683);
  end;

   {-----------------------------------------------------------}
   //�л����˵�
  d := WProgUse.Images[180];
  if d <> nil then
  begin
    DGuildDlg.Left := 0;
    DGuildDlg.Top := 0;
    DGuildDlg.SetImgIndex(WProgUse, 180);
  end;
  DGDClose.Left := 584;
  DGDClose.Top := 6;
  DGDClose.SetImgIndex(WProgUse, 64);
  DGDHome.Left := 13;
  DGDHome.Top := 411;
  DGDHome.SetImgIndex(WProgUse, 198);
  DGDList.Left := 13;
  DGDList.Top := 429;
  DGDList.SetImgIndex(WProgUse, 200);
  DGDChat.Left := 94;
  DGDChat.Top := 429;
  DGDChat.SetImgIndex(WProgUse, 190);
  DGDAddMem.Left := 243;
  DGDAddMem.Top := 411;
  DGDAddMem.SetImgIndex(WProgUse, 182);
  DGDDelMem.Left := 243;
  DGDDelMem.Top := 429;
  DGDDelMem.SetImgIndex(WProgUse, 192);
  DGDEditNotice.Left := 325;
  DGDEditNotice.Top := 411;
  DGDEditNotice.SetImgIndex(WProgUse, 196);
  DGDEditGrade.Left := 325;
  DGDEditGrade.Top := 429;
  DGDEditGrade.SetImgIndex(WProgUse, 194);
  DGDAlly.Left := 407;
  DGDAlly.Top := 411;
  DGDAlly.SetImgIndex(WProgUse, 184);
  DGDBreakAlly.Left := 407;
  DGDBreakAlly.Top := 429;
  DGDBreakAlly.SetImgIndex(WProgUse, 186);
  DGDWar.Left := 529;
  DGDWar.Top := 411;
  DGDWar.SetImgIndex(WProgUse, 202);
  DGDCancelWar.Left := 529;
  DGDCancelWar.Top := 429;
  DGDCancelWar.SetImgIndex(WProgUse, 188);

  DGDUp.Left := 595;
  DGDUp.Top := 239;
  DGDUp.SetImgIndex(WProgUse, 373);
  DGDDown.Left := 595;
  DGDDown.Top := 291;
  DGDDown.SetImgIndex(WProgUse, 372);

   //�л�ͨ��༭��
  DGuildEditNotice.SetImgIndex(WProgUse, 204);
  DGEOk.SetImgIndex(WProgUse, 361);
  DGEOk.Left := 514;
  DGEOk.Top := 287;
  DGEClose.SetImgIndex(WProgUse, 64);
  DGEClose.Left := 584;
  DGEClose.Top := 6;

   {-----------------------------------------------------------}
   //���Ե����Ի���
  DAdjustAbility.SetImgIndex(WProgUse, 226);
  DAdjustAbilClose.SetImgIndex(WProgUse, 64);
  DAdjustAbilClose.Left := 316;
  DAdjustAbilClose.Top := 1;
  DAdjustAbilOk.SetImgIndex(WProgUse, 62);
  DAdjustAbilOk.Left := 220;
  DAdjustAbilOk.Top := 298;

  DPlusDC.SetImgIndex(WProgUse, 227);
  DPlusDC.Left := 217;
  DPlusDC.Top := 101;
  DPlusMC.SetImgIndex(WProgUse, 227);
  DPlusMC.Left := 217;
  DPlusMC.Top := 121;
  DPlusSC.SetImgIndex(WProgUse, 227);
  DPlusSC.Left := 217;
  DPlusSC.Top := 140;
  DPlusAC.SetImgIndex(WProgUse, 227);
  DPlusAC.Left := 217;
  DPlusAC.Top := 160;
  DPlusMAC.SetImgIndex(WProgUse, 227);
  DPlusMAC.Left := 217;
  DPlusMAC.Top := 181;
  DPlusHP.SetImgIndex(WProgUse, 227);
  DPlusHP.Left := 217;
  DPlusHP.Top := 201;
  DPlusMP.SetImgIndex(WProgUse, 227);
  DPlusMP.Left := 217;
  DPlusMP.Top := 220;
  DPlusHit.SetImgIndex(WProgUse, 227);
  DPlusHit.Left := 217;
  DPlusHit.Top := 240;
  DPlusSpeed.SetImgIndex(WProgUse, 227);
  DPlusSpeed.Left := 217;
  DPlusSpeed.Top := 261;

  DMinusDC.SetImgIndex(WProgUse, 228);
  DMinusDC.Left := 227;
  DMinusDC.Top := 101;
  DMinusMC.SetImgIndex(WProgUse, 228);
  DMinusMC.Left := 227;
  DMinusMC.Top := 121;
  DMinusSC.SetImgIndex(WProgUse, 228);
  DMinusSC.Left := 227;
  DMinusSC.Top := 140;
  DMinusAC.SetImgIndex(WProgUse, 228);
  DMinusAC.Left := 227;
  DMinusAC.Top := 160;
  DMinusMAC.SetImgIndex(WProgUse, 228);
  DMinusMAC.Left := 227;
  DMinusMAC.Top := 181;
  DMinusHP.SetImgIndex(WProgUse, 228);
  DMinusHP.Left := 227;
  DMinusHP.Top := 201;
  DMinusMP.SetImgIndex(WProgUse, 228);
  DMinusMP.Left := 227;
  DMinusMP.Top := 220;
  DMinusHit.SetImgIndex(WProgUse, 228);
  DMinusHit.Left := 227;
  DMinusHit.Top := 240;
  DMinusSpeed.SetImgIndex(WProgUse, 228);
  DMinusSpeed.Left := 227;
  DMinusSpeed.Top := 261;

   {-----------------------------------------------------------}
   // 2003/04/15 ģ��, ����
   //����
  d := WProgUse.Images[536];
  if d <> nil then
  begin
    DFriendDlg.SetImgIndex(WProgUse, 536);
    DFriendDlg.Left := 0; //(SCREENWIDTH - d.Width) div 2;
    DFriendDlg.Top := 0; //(SCREENHEIGHT - d.Height) div 2;
  end;
  DFrdClose.SetImgIndex(WProgUse, 371);
  DFrdClose.Left := 247;
  DFrdClose.Top := 5;
  DFrdPgUp.SetImgIndex(WProgUse, 373);
  DFrdPgUp.Left := 259;
  DFrdPgUp.Top := 102;
  DFrdPgDn.SetImgIndex(WProgUse, 372);
  DFrdPgDn.Left := 259;
  DFrdPgDn.Top := 154;
  DFrdFriend.SetImgIndex(WProgUse, 540);
  DFrdFriend.Left := 15;
  DFrdFriend.Top := 35;
  DFrdBlackList.SetImgIndex(WProgUse, 573);
  DFrdBlackList.Left := 130;
  DFrdBlackList.Top := 35;
  DFrdAdd.SetImgIndex(WProgUse, 554);
  DFrdAdd.Left := 90;
  DFrdAdd.Top := 233;
  DFrdDel.SetImgIndex(WProgUse, 556);
  DFrdDel.Left := 124;
  DFrdDel.Top := 233;
  DFrdMemo.SetImgIndex(WProgUse, 558);
  DFrdMemo.Left := 158;
  DFrdMemo.Top := 233;
  DFrdMail.SetImgIndex(WProgUse, 560);
  DFrdMail.Left := 192;
  DFrdMail.Top := 233;
  DFrdWhisper.SetImgIndex(WProgUse, 562);
  DFrdWhisper.Left := 226;
  DFrdWhisper.Top := 233;
   {-----------------------------------------------------------}
   //�ʼ� Mail
  d := WProgUse.Images[536];
  if d <> nil then
  begin
    DMailListDlg.SetImgIndex(WProgUse, 536);
    DMailListDlg.Left := 512; //(SCREENWIDTH - d.Width) div 2;
    DMailListDlg.Top := 0; //(SCREENHEIGHT - d.Height) div 2;
  end;
  DMailListClose.SetImgIndex(WProgUse, 371);
  DMailListClose.Left := 247;
  DMailListClose.Top := 5;
  DMailListPgUp.SetImgIndex(WProgUse, 373);
  DMailListPgUp.Left := 259;
  DMailListPgUp.Top := 102;
  DMailListPgDn.SetImgIndex(WProgUse, 372);
  DMailListPgDn.Left := 259;
  DMailListPgDn.Top := 154;
  DMLReply.SetImgIndex(WProgUse, 564);
  DMLReply.Left := 90;
  DMLReply.Top := 233;
  DMLRead.SetImgIndex(WProgUse, 566);
  DMLRead.Left := 124;
  DMLRead.Top := 233;
  DMLDel.SetImgIndex(WProgUse, 556);
  DMLDel.Left := 158;
  DMLDel.Top := 233;
  DMLLock.SetImgIndex(WProgUse, 568);
  DMLLock.Left := 192;
  DMLLock.Top := 233;
  DMLBlock.SetImgIndex(WProgUse, 570);
  DMLBlock.Left := 226;
  DMLBlock.Top := 233;
   {-----------------------------------------------------------}
   //Mail
  d := WProgUse.Images[536];
  if d <> nil then
  begin
    DBlockListDlg.SetImgIndex(WProgUse, 536);
    DBlockListDlg.Left := 512; //(SCREENWIDTH - d.Width) div 2;
    DBlockListDlg.Top := 265; //(SCREENHEIGHT - d.Height) div 2;
  end;
  DBlockListClose.SetImgIndex(WProgUse, 371);
  DBlockListClose.Left := 247;
  DBlockListClose.Top := 5;
  DBLPgUp.SetImgIndex(WProgUse, 373);
  DBLPgUp.Left := 259;
  DBLPgUp.Top := 102;
  DBLPgDn.SetImgIndex(WProgUse, 372);
  DBLPgDn.Left := 259;
  DBLPgDn.Top := 154;
  DBLAdd.SetImgIndex(WProgUse, 554);
  DBLAdd.Left := 192;
  DBLAdd.Top := 233;
  DBLDel.SetImgIndex(WProgUse, 556);
  DBLDel.Left := 226;
  DBLDel.Top := 233;
   {-----------------------------------------------------------}
   //�����ʼ���
  d := WProgUse.Images[537];
  if d <> nil then
  begin
    DMemo.SetImgIndex(WProgUse, 537);
    DMemo.Left := 290; //(SCREENWIDTH - d.Width) div 2;
    DMemo.Top := 0; //(SCREENHEIGHT - d.Height) div 2;
  end;
  DMemoClose.SetImgIndex(WProgUse, 371);
  DMemoClose.Left := 205;
  DMemoClose.Top := 1;
  DMemoB1.SetImgIndex(WProgUse, 544);
  DMemoB1.Left := 58;
  DMemoB1.Top := 114;
  DMemoB2.SetImgIndex(WProgUse, 538);
  DMemoB2.Left := 126;
  DMemoB2.Top := 114;

   {-----------------------------------------------------------}
   //�ʼ���
  d := WProgUse.Images[583];
  if d <> nil then
  begin
    DMasterDlg.SetImgIndex(WProgUse, 583);
    DMasterDlg.Left := 0; //(SCREENWIDTH - d.Width) div 2;
    DMasterDlg.Top := 0; //(SCREENHEIGHT - d.Height) div 2;
  end;
  DMasterClose.SetImgIndex(WProgUse, 371);
  DMasterClose.Left := 280;
  DMasterClose.Top := 5;
  DLover1.SetImgIndex(WProgUse, 600);
  DLover1.Left := 32;
  DLover1.Top := 136;
  DLover2.SetImgIndex(WProgUse, 598);
  DLover2.Left := 66;
  DLover2.Top := 136;
  DLover3.SetImgIndex(WProgUse, 594);
  DLover3.Left := 100;
  DLover3.Top := 136;
  DMaster1.SetImgIndex(WProgUse, 590);
  DMaster1.Left := 168;
  DMaster1.Top := 360;
  DMaster2.SetImgIndex(WProgUse, 596);
  DMaster2.Left := 202;
  DMaster2.Top := 360;
  DMaster3.SetImgIndex(WProgUse, 592);
  DMaster3.Left := 236;
  DMaster3.Top := 360;
end;


//��/�ر��ҵ����ԶԻ���
procedure TFrmDlg.OpenMyStatus;
var
  str: string;
begin
  str := Copy(fLover.GetDisplay(0), length(STR_LOVER) + 1, 6);
  if str = '' then
    DHeartImg.Visible := False
  else
    DHeartImg.Visible := True;

  DStateWin.Visible := not DStateWin.Visible;
  PageChanged;
end;
//��ʾ�����Ϣ�Ի���

procedure TFrmDlg.OpenUserState(ustate: TUserStateInfo);
begin
  UserState1 := ustate;
  if UserState1.bExistLover then
    DHeartImgUS.Visible := True
  else
    DHeartImgUS.Visible := False;
  DUserState1.Visible := TRUE;
end;

//��ʾ/�ر���Ʒ�Ի���
procedure TFrmDlg.OpenItemBag;
begin
  DItemBag.Visible := not DItemBag.Visible;
  if DItemBag.Visible then
    ArrangeItemBag;
end;

//�ײ�״̬��
procedure TFrmDlg.ViewBottomBox(visible: Boolean);
begin
  DBottom.Visible := visible;
end;


// ȡ����Ʒ�ƶ� ������Ʒ
procedure TFrmDlg.CancelItemMoving;
var
  idx, n: integer;
begin
  if ItemMoving then
  begin
    ItemMoving := FALSE;
    idx := MovingItem.Index;
    if idx < 0 then
    begin
      if idx = -99 then
      begin
        AddItemBag(MovingItem.Item);
        Exit;
      end;
      if (idx <= -20) and (idx > -30) then
      begin
        AddDealItem(MovingItem.Item);
      end
      else
      begin
        n := -(idx + 1);
            // 2003/03/15 ������ �κ��丮 Ȯ��
        if n in [0..12] then
        begin    //8->12
          UseItems[n] := MovingItem.Item;
        end;
      end;
    end
    else if idx in [0..MAXBAGITEM - 1] then
    begin
      if (ItemArr[idx].S.Name = '') then
      begin
//               (MovingItem.Item.S.StdMode <= 3) then begin // 2004/02/23 ����, ����, ��ũ�� �ƴѰ��� ����â��..
        ItemArr[idx] := MovingItem.Item;
      end
      else
      begin
        AddItemBag(MovingItem.Item);
      end;
    end;
    MovingItem.Item.S.Name := '';
  end;
  ArrangeItemBag;
end;

//���ƶ�����Ʒ����(��ѯ��)
procedure TFrmDlg.DropMovingItem;
begin
  if ItemMoving then
  begin
    ItemMoving := FALSE;
    if MovingItem.Item.S.Name <> '' then
    begin
      FrmMain.SendDropItem(MovingItem.Item.S.Name, MovingItem.Item.MakeIndex);
      AddDropItem(MovingItem.Item);
      MovingItem.Item.S.Name := '';
    end;
  end;
end;
(*
//���ƶ�����Ʒ����
procedure TFrmDlg.DropMovingItem;
var
   idx, DlopCount : integer;
   valstr : String;
   MsgResult : integer;
begin

   if ItemMoving then begin
      ItemMoving := FALSE;
      if MovingItem.Item.S.Name <> '' then begin
         if MovingItem.Item.S.OverlapItem > 0 then begin
            if DMakeItemDlg.Visible then begin
               DMessageDlg ('��ȷ��Ҫ���������Ʒ.', [mbOk]);
               ItemMoving := True;
               CancelItemMoving;
               Exit;
            end;

            DlopCount := 0;
            Total := MovingItem.Item.Dura;
            if Total = 1 then begin
               DlgEditText := '1';
               MsgResult := mrOk;
            end
            else MsgResult := DCountMsgDlg ('��ǰ���� ' + IntToStr(MovingItem.Item.Dura) +
                     ' ��.\���붪������?', [mbOk, mbCancel, mbAbort]);
            ItemMoving := TRUE;
            if (MsgResult = mrCancel) then begin
               CancelItemMoving;
               Exit;
            end
            else if MsgResult = mrOk then begin

               GetValidStrVal (DlgEditText, valstr, [' ']);
               DlopCount := Str_ToInt (valstr, 0);

               if DlopCount <= 0 then DlopCount := 0;
               if DlopCount > MovingItem.Item.Dura then DlopCount := MovingItem.Item.Dura;
               if DlopCount = MovingItem.Item.Dura then begin
                  FrmMain.SendDropItem (MovingItem.Item.S.Name, MovingItem.Item.MakeIndex);
                  AddDropItem (MovingItem.Item);
                  MovingItem.Item.S.Name := '';
                  MovingItem.Item.Dura := 0;
               end
               else if (DlopCount > 0) then begin
                  FrmMain.SendDropCountItem( MovingItem.Item.S.Name, MovingItem.Item.MakeIndex, DlopCount );
               end;
               CancelItemMoving;
               Exit;
            end;
         end
         else begin

           if MovingItem.Item.S.StdMode <> 9 then begin
              if (MovingItem.Item.S.UniqueItem and $04) <> 0 then begin
                 if mrOk = DMessageDlg ('�� �������� ������ ������� �������Դϴ�.\������ �������� �����Ͻðڽ��ϱ�?', [mbOk, mbCancel]) then
                    FrmMain.SendDropItem (MovingItem.Item.S.Name, MovingItem.Item.MakeIndex)//2004/01/15 ItemSafeGuard..
                 else begin
                    ItemMoving := TRUE;
                    CancelItemMoving;
                    Exit;
                 end;
              end
              else if mrOk = DMessageDlg ('��ȷ��Ҫ���������Ʒ��', [mbOk, mbCancel]) then
                 FrmMain.SendDropItem (MovingItem.Item.S.Name, MovingItem.Item.MakeIndex)//2004/01/15 ItemSafeGuard..
              else begin
                 ItemMoving := TRUE;
                 CancelItemMoving;
                 Exit;
              end;
           end
           else
              FrmMain.SendDropItem (MovingItem.Item.S.Name, MovingItem.Item.MakeIndex)//2004/01/15 ItemSafeGuard..
         end;

         AddDropItem (MovingItem.Item);
         MovingItem.Item.S.Name := '';
      end;
   end;

    {
   if ItemMoving then begin
      ItemMoving := FALSE;
      if MovingItem.Item.S.Name <> '' then begin
         FrmMain.SendDropItem (MovingItem.Item.S.Name, MovingItem.Item.MakeIndex);
         AddDropItem (MovingItem.Item);
         MovingItem.Item.S.Name := '';
      end;
   end;
    }
end;
*)

procedure TFrmDlg.OpenAdjustAbility;
begin
  DAdjustAbility.Left := 0;
  DAdjustAbility.Top := 0;
  SaveBonusPoint := BonusPoint;
  FillChar(BonusAbilChg, sizeof(TNakedAbility), #0);
  DAdjustAbility.Visible := TRUE;
end;

procedure TFrmDlg.DBackgroundBackgroundClick(Sender: TObject);
var
  dropgold: integer;
  valstr: string;
begin
  if ItemMoving then
  begin
    DBackground.WantReturn := TRUE;
    if MovingItem.Item.S.Name = '���' then
    begin
      ItemMoving := FALSE;
      MovingItem.Item.S.Name := '';
         //�󸶸� ���� ���� �����.
      DialogSize := 1;
      DMessageDlg('������¶��ٽ��?', [mbOk, mbAbort]);

      GetValidStrVal(DlgEditText, valstr, [' ']);
      dropgold := Str_ToInt(valstr, 0);
         //
      FrmMain.SendDropGold(dropgold);
    end;
    if MovingItem.Index >= 0 then //������ ���濡�� �����͸�..
      DropMovingItem;
  end;
end;

procedure TFrmDlg.DBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ItemMoving then
  begin
    DBackground.WantReturn := TRUE;
  end;
end;

procedure TFrmDlg.DBottomMouse(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  function ExtractUserName(line: string): string;
  var
    uname: string;
  begin
    GetValidStr3(line, line, ['(', '!', '*', '/', ')']);
    GetValidStr3(line, uname, [' ', '=', ':']);
    if uname <> '' then
      if (uname[1] = '/') or (uname[1] = '(') or (uname[1] = ' ') or (uname[1] = '[') then
        uname := '';
    Result := uname;
  end;

var
  n: integer;
  str: string;
  nWidth:Integer;
begin
  if g_FScreenWidth = 1024 then nWidth := 598
  else nWidth := 374;
  
  if (X >= 208) and (X <= (208 + nWidth)) and (Y >= g_FScreenHeight - 130) and (Y <= g_FScreenHeight - 130 + 12 * 9) then begin
    n := DScreen.ChatBoardTop + (Y - (g_FScreenHeight - 130)) div 12;
    if (n < DScreen.ChatStrs.Count) then begin
      if not PlayScene.EdChat.Visible then begin
        PlayScene.EdChat.Visible := TRUE;
        PlayScene.EdChat.SetFocus;
      end;
      PlayScene.EdChat.Text := '/' + ExtractUserName(DScreen.ChatStrs[n]) + ' ';
      PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
      PlayScene.EdChat.SelLength := 0;
    end
    else
      PlayScene.EdChat.Text := '';
  end;

  if DItemMarketDlg.Visible then begin
    if (X >= 206) and (X <= 208 + 380) and (Y >= g_FScreenHeight - 51) then
      SetChatFocus;
  end

end;

{------------------------------------------------------------------------}

////��ʾͨ�öԻ���
function TFrmDlg.DMessageDlg(msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;

  procedure DoRunDice;
  var
    dr: TDXTexture;
    i: integer;
    flag: Boolean;
  begin

    if (DiceType = 2) then
    begin
      if DiceArr[0].DiceCount < 20 then
      begin
        if GetTickCount - DiceArr[0].DiceTime > 250 then
        begin
//               if DiceArr[0].DiceCount mod 2 = 1 then DiceArr[0].DiceCurrent := 1 + Random(3)
          DiceArr[0].DiceCurrent := DiceArr[0].DiceCount mod 3;
          DiceArr[0].DiceTime := GetTickCount;
          Inc(DiceArr[0].DiceCount);
        end;
      end
      else
      begin
        DiceArr[0].DiceCurrent := DiceArr[0].DiceResult - 1;
        if GetTickCount - DiceArr[0].DiceTime > 3000 then
          DMsgDlg.Visible := FALSE;
      end;
    end
    else if RunDice = 1 then
    begin
      if DiceArr[0].DiceCount < 20 then
      begin
        if GetTickCount - DiceArr[0].DiceTime > 100 then
        begin
          if DiceArr[0].DiceCount mod 5 = 4 then
            DiceArr[0].DiceCurrent := 1 + Random(6)
          else
            DiceArr[0].DiceCurrent := 8 + DiceArr[0].DiceCount mod 5;
          DiceArr[0].DiceTime := GetTickCount;
          Inc(DiceArr[0].DiceCount);
        end;
      end
      else
      begin
        DiceArr[0].DiceCurrent := DiceArr[0].DiceResult;
        if GetTickCount - DiceArr[0].DiceTime > 3000 then
          DMsgDlg.Visible := FALSE;
      end;
    end
    else
    begin
      flag := TRUE;
      for i := 0 to RunDice - 1 do
      begin
        if DiceArr[i].DiceCount < DiceArr[i].DiceLimit then
        begin
          if GetTickCount - DiceArr[i].DiceTime > 100 then
          begin
            if DiceArr[i].DiceCount mod 5 = 4 then
              DiceArr[i].DiceCurrent := 1 + Random(6)
            else
              DiceArr[i].DiceCurrent := 8 + DiceArr[i].DiceCount mod 5;
            DiceArr[i].DiceTime := GetTickCount;
            Inc(DiceArr[i].DiceCount);
          end;
          flag := FALSE;
        end
        else
        begin
          DiceArr[i].DiceCurrent := DiceArr[i].DiceResult;
          if GetTickCount - DiceArr[i].DiceTime < 4000 then
            flag := FALSE;
        end;
      end;
      if flag then
        DMsgDlg.Visible := FALSE;
    end;
  end;

const
  XBase = 324;
var
  lx, ly, i, k: integer;
  d: TDXTexture;
begin
  lx := XBase;
  ly := 126;
  case DialogSize of
    0:  //С�Ի���
      begin
        d := WProgUse.Images[381];
        if d <> nil then
        begin
          DMsgDlg.SetImgIndex(WProgUse, 381);
          DMsgDlg.Left := (g_FScreenWidth - d.Width) div 2;
          DMsgDlg.Top := (g_FScreenHeight - d.Height) div 2;
          msglx := 39;
          msgly := 38;
          lx := 90; //d.Width div 2 - 38; //XBase;
          ly := 36; //56;
        end;
      end;
    1:  //��Ի��򣨺ᣩ
      begin
        d := WProgUse.Images[360];
        if d <> nil then
        begin
          DMsgDlg.SetImgIndex(WProgUse, 360);
          DMsgDlg.Left := (g_FScreenWidth - d.Width) div 2;
          DMsgDlg.Top := (g_FScreenHeight - d.Height) div 2;
          msglx := 39;
          msgly := 38;
          lx := XBase;
          ly := 126;
        end;
      end;
    2:  //��Ի�������
      begin
        d := WProgUse.Images[380];
        if d <> nil then
        begin
          DMsgDlg.SetImgIndex(WProgUse, 380);
          DMsgDlg.Left := (g_FScreenWidth - d.Width) div 2;
          DMsgDlg.Top := (g_FScreenHeight - d.Height) div 2;
          msglx := 23;
          msgly := 20;
          lx := 90;
          ly := 305;
        end;
      end;
  end;
  MsgText := msgstr;
  ViewDlgEdit := FALSE;
  DMsgDlg.Floating := TRUE;   //�༭�򲻿ɼ�..
  DMsgDlgOk.Visible := FALSE;  //��������ƶ�
  DMsgDlgYes.Visible := FALSE;
  DMsgDlgCancel.Visible := FALSE;
  DMsgDlgNo.Visible := FALSE;
  DMsgDlg.Left := (g_FScreenWidth - DMsgDlg.Width) div 2;
  DMsgDlg.Top := (g_FScreenHeight - DMsgDlg.Height) div 2;

  for i := 0 to RunDice - 1 do
  begin
    DiceArr[i].DiceCount := 0;
    DiceArr[i].DiceLimit := 10 + Random(RunDice + 2) * 5;
    DiceArr[i].DiceCurrent := 1;
    DiceArr[i].DiceTime := GetTickCount;
  end;

  if mbCancel in DlgButtons then
  begin
    DMsgDlgCancel.Left := lx;
    DMsgDlgCancel.Top := ly;
    DMsgDlgCancel.Visible := TRUE;
    lx := lx - 110;
  end;
  if mbNo in DlgButtons then
  begin
    DMsgDlgNo.Left := lx;
    DMsgDlgNo.Top := ly;
    DMsgDlgNo.Visible := TRUE;
    lx := lx - 110;
  end;
  if mbYes in DlgButtons then
  begin
    DMsgDlgYes.Left := lx;
    DMsgDlgYes.Top := ly;
    DMsgDlgYes.Visible := TRUE;
    lx := lx - 110;
  end;
  if (mbOk in DlgButtons) or (lx = XBase) then
  begin
    DMsgDlgOk.Left := lx;
    DMsgDlgOk.Top := ly;
    DMsgDlgOk.Visible := TRUE;
    lx := lx - 110;
    SetDCapture(nil);   //���׽�ҵ�����ȷ��
  end;
  HideAllControls;
  DMsgDlg.ShowModal;

  if mbAbort in DlgButtons then
  begin
    ViewDlgEdit := TRUE; //��ʾ�༭��.
    DMsgDlg.Floating := FALSE;
    with EdDlgEdit do
    begin
      Text := '';
      Width := DMsgDlg.Width - 70;
      Left := (g_FScreenWidth - EdDlgEdit.Width) div 2;
      Top := (g_FScreenHeight - EdDlgEdit.Height) div 2 - 10;
      EdDlgEdit.MaxLength := MsgDlgMaxStr;
    end;
  end;
  Result := mrOk;
  k := 0;
  while TRUE do
  begin
    if not DMsgDlg.Visible then
      break;
      //FrmMain.DXTimerTimer (self, 0);
    frmMain.AppOnIdle();
    Application.ProcessMessages;
    Inc(k);
    if k = 5 then
    begin
      FrmMain.MsgProg;
      k := 0;
    end;

    if BoMsgDlgTimeCheck then
    begin
      if MsgDlgClickTime < GetTickCount then
      begin
        DMsgDlg.DialogResult := mrNo;
        BoMsgDlgTimeCheck := False;
        MsgDlgClickTime := GetTickCount;
        DMsgDlg.Visible := False;
        break;
      end;
    end;
    if RunDice > 0 then
    begin
      BoDrawDice := TRUE;
      for i := 0 to RunDice - 1 do
      begin
        DiceArr[i].DiceLeft := DMsgDlg.Width div 2 + 6 - (33 * RunDice) div 2 + 33 * i; // - 15;  //37
        DiceArr[i].DiceTop := DMsgDlg.Height div 2 - 14;  //25
      end;
      DoRunDice;
    end;
    if Application.Terminated then
      exit;
  end;

  EdDlgEdit.Visible := FALSE;
  RestoreHideControls;
  DlgEditText := EdDlgEdit.Text;
  if PlayScene.EdChat.Visible then
    PlayScene.EdChat.SetFocus;
  ViewDlgEdit := FALSE;
  Result := DMsgDlg.DialogResult;
  DialogSize := 1; //�⺻����
  RunDice := 0;
  BoDrawDice := FALSE;
end;

function TFrmDlg.DSimpleMessageDlg (msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
const
  XBase = 384;
var
  I: Integer;
  lx, ly: integer;
  d: TDXTexture;
begin
  begin
    d := WProgUse.Images[710];
    if d <> nil then begin
      DMsgSimpleDlg.SetImgIndex(WProgUse, 710);
      DMsgSimpleDlg.Left := (g_FScreenWidth - d.Width) div 2;
      DMsgSimpleDlg.Top := (g_FScreenHeight - d.Height) div 2;
      msglx := 39;
      msgly := 38;
      lx := 220;
      ly := 96;
    end;
  end;
  MsgText := msgstr;
  ViewDlgEdit := FALSE;
  DMsgSimpleDlg.Floating := TRUE;
  DMsgSimpleDlgOk.Visible := False;
  DMsgSimpleDlgCancel.Visible := False;
  DMsgSimpleDlg.Left := (g_FScreenWidth - DMsgSimpleDlg.Width) div 2;
  DMsgSimpleDlg.Top := (g_FScreenHeight - DMsgSimpleDlg.Height) div 2;

  if MovingItem.Item.S.Name <> '' then
    FrmDlg.DMsgSimpleDlg.Top := 410;

  if (MySelf <> nil) and MySelf.Death then begin
    FrmDlg.DMsgSimpleDlg.Left := 0;
    FrmDlg.DMsgSimpleDlg.Top := 0;
  end;

  if mbCancel in DlgButtons then begin
    DMsgSimpleDlgCancel.Left := lx;
    DMsgSimpleDlgCancel.Top := ly;
    DMsgSimpleDlgCancel.Visible := True;
    lx := lx - 100;
  end;
  if (mbOK in DlgButtons) or (lx = XBase) then begin
    DMsgSimpleDlgOk.Left := lx;
    DMsgSimpleDlgOk.Top := ly;
    DMsgSimpleDlgOk.Visible := True;
    lx := lx - 100;
  end;
  HideAllControls;
  DMsgSimpleDlg.ShowModal;
  if mbAbort in DlgButtons then begin
    ViewDlgEdit := True;
    DMsgSimpleDlg.Floating := False;
    with EdDlgEdit do begin
      Text := '';
      Width := DMsgDlg.Width - 70;
      Left := (g_FScreenWidth - EdDlgEdit.Width) div 2;
      Top := (g_FScreenHeight - EdDlgEdit.Height) div 2 - 10;
    end;
  end;
  Result := mrOk;

  while True do begin
    if not DMsgSimpleDlg.Visible then
      Break;

    FrmMain.AppOnIdle();
    Application.ProcessMessages;
    if Application.Terminated then
      Exit;
    Sleep(1);
  end;

  EdDlgEdit.Visible := False;
  RestoreHideControls;
  DlgEditText := EdDlgEdit.Text;
  if PlayScene.EdChat.Visible then
    PlayScene.EdChat.SetFocus;
  ViewDlgEdit := False;
  Result := DMsgSimpleDlg.DialogResult;
end;

function TFrmDlg.OnlyMessageDlg(msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
const
  XBase = 329;
var
  lx, ly, i: integer;
  d: TDXTexture;
begin
  lx := XBase;
  ly := 126;
  case DialogSize of
    1:  //�а� ū��
      begin
        d := WProgUse.Images[360];
        if d <> nil then
        begin
          DMsgDlg.SetImgIndex(WProgUse, 360);
          DMsgDlg.Left := (g_FScreenWidth - d.Width) div 2;
          DMsgDlg.Top := (g_FScreenHeight - d.Height) div 2;
          msglx := 39;
          msgly := 38;
          lx := XBase;
          ly := 143;
        end;
      end;
  end;
  MsgText := msgstr;
  ViewDlgEdit := FALSE;
  DMsgDlg.Floating := TRUE;   //�޼��� �ڽ��� ���ٴ�..
  DMsgDlgOk.Visible := FALSE;
  DMsgDlgYes.Visible := FALSE;
  DMsgDlgCancel.Visible := FALSE;
  DMsgDlgNo.Visible := FALSE;
  DMsgDlg.Left := (g_FScreenWidth - DMsgDlg.Width) div 2;
  DMsgDlg.Top := (g_FScreenHeight - DMsgDlg.Height) div 2;

  if (mbOk in DlgButtons) or (lx = XBase) then
  begin
    DMsgDlgOk.Left := lx;
    DMsgDlgOk.Top := ly;
    DMsgDlgOk.Visible := TRUE;
    lx := lx - 110;
  end;
  HideAllControls;
  Result := mrOk;
  DMsgDlg.ShowModal;
  while TRUE do
  begin
    if not DMsgDlg.Visible then
      break;
      //FrmMain.DXTimerTimer (self, 0);
//      frmMain.AppOnIdle();
    Application.ProcessMessages;

{      if BoMsgDlgTimeCheck then begin
         if MsgDlgClickTime < GetTickCount then begin
            DMsgDlg.DialogResult := mrNo;
            BoMsgDlgTimeCheck := False;
            MsgDlgClickTime := GetTickCount;
            DMsgDlg.Visible := False;
            break;
         end;
      end;}
    if Application.Terminated then
      exit;
  end;

  EdDlgEdit.Visible := FALSE;
  RestoreHideControls;
  DlgEditText := EdDlgEdit.Text;
  if PlayScene.EdChat.Visible then
    PlayScene.EdChat.SetFocus;
  ViewDlgEdit := FALSE;
  Result := DMsgDlg.DialogResult;
  DialogSize := 1; //�⺻����
  RunDice := 0;
  BoDrawDice := FALSE;
end;

procedure TFrmDlg.DMsgDlgOkClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DMsgDlgOk then
    DMsgDlg.DialogResult := mrOk;
  if Sender = DMsgDlgYes then
    DMsgDlg.DialogResult := mrYes;
  if Sender = DMsgDlgCancel then
    DMsgDlg.DialogResult := mrCancel;
  if Sender = DMsgDlgNo then
    DMsgDlg.DialogResult := mrNo;

  if GameClose then
  begin
//      FrmMain.CloseNPMon;
    FrmMain.Close;
  end;

  BoMsgDlgTimeCheck := False;
  MsgDlgClickTime := GetTickCount;
  DMsgDlg.Visible := FALSE;
end;

procedure TFrmDlg.DMsgDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
  begin
      //2003/02/11 OK/Cancel������ ���͸� OK��...
    if DMsgDlgOk.Visible and not (DMsgDlgYes.Visible {or DMsgDlgCancel.Visible}  or DMsgDlgNo.Visible) then
    begin
      DMsgDlg.DialogResult := mrOk;
      DMsgDlg.Visible := FALSE;
    end;
    if DMsgDlgYes.Visible and not (DMsgDlgOk.Visible or DMsgDlgCancel.Visible) then
    begin
      DMsgDlg.DialogResult := mrYes;
      DMsgDlg.Visible := FALSE;
    end;
  end;
  if Key = 27 then
  begin
    if DMsgDlgNo.Visible then
    begin
      DMsgDlg.DialogResult := mrNo;
      DMsgDlg.Visible := FALSE;
    end;
    if DMsgDlgCancel.Visible then
    begin
      DMsgDlg.DialogResult := mrCancel;
      DMsgDlg.Visible := FALSE;
    end;
  end;
end;

procedure TFrmDlg.DMsgDlgOkDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if not Downed then
      d := WLib.Images[FaceIndex]
    else
      d := WLib.Images[FaceIndex + 1];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DMsgSimpleDlgDirectPaint(Sender: TObject;
  dsurface: TDXTexture);
var
  I: Integer;
  d: TDXTexture;
  ly: integer;
  str, data: string;
  nX,nY:Integer;
begin
   with Sender as TDWindow do begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
         dsurface.Draw (SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

      ly := msgly;
      str := MsgText;
      while TRUE do begin
         if str = '' then break;
         str := GetValidStr3 (str, data, ['\']);
         if data <> '' then
            g_DXCanvas.TextOut(SurfaceX(Left+msglx), SurfaceY(Top+ly), data, clWhite);
         ly := ly + 14;
         end
      end;

  if ViewDlgEdit then begin
    if not EdDlgEdit.Visible then begin
      EdDlgEdit.Visible := TRUE;
      EdDlgEdit.SetFocus;
    end;
  end;
end;

procedure TFrmDlg.DMsgSimpleDlgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then begin
      if DMsgSimpleDlgOk.Visible then begin
         DMsgSimpleDlg.DialogResult := mrOk;
         DMsgSimpleDlg.Visible := FALSE;
      end;
   end;
   if Key = 27 then begin
      if DMsgSimpleDlgCancel.Visible then begin
         DMsgSimpleDlg.DialogResult := mrCancel;
         DMsgSimpleDlg.Visible := FALSE;
      end;
   end;
end;

procedure TFrmDlg.DMsgSimpleDlgOkClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DMsgSimpleDlgOk then DMsgSimpleDlg.DialogResult := mrOk;
  if Sender = DMsgSimpleDlgCancel then DMsgSimpleDlg.DialogResult := mrCancel;
  DMsgSimpleDlg.Visible := FALSE;
end;

procedure TFrmDlg.DMsgDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d, dr: TDXTexture;
  ly, px, py, i: integer;
  str, data: string;
begin
  with Sender as TDWindow do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    if BoDrawDice then
    begin
      if DiceType = 1 then
      begin
        for i := 0 to RunDice - 1 do
        begin
          dr := WBagItem.GetCachedImage(376 + DiceArr[i].DiceCurrent - 1, px, py);
          if dr <> nil then
          begin
            dsurface.Draw(SurfaceX(Left) + DiceArr[i].DiceLeft + px - 14, SurfaceY(Top) + DiceArr[i].DiceTop + py + 38, dr.ClientRect, dr, TRUE);
          end;
        end;
      end
      else if DiceType = 2 then
      begin
        dr := WBagItem.GetCachedImage(887 + DiceArr[0].DiceCurrent, px, py);
        if dr <> nil then
        begin
          dsurface.Draw(SurfaceX(Left) + DiceArr[0].DiceLeft + px - 14, SurfaceY(Top) + DiceArr[0].DiceTop + py + 38, dr.ClientRect, dr, TRUE);
        end;
      end;
    end;
//      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
    ly := msgly;
    str := MsgText;
    while TRUE do
    begin
      if str = '' then
        break;
      str := GetValidStr3(str, data, ['\']);
      if data <> '' then
        g_DXCanvas.TextOut(SurfaceX(Left + msglx), SurfaceY(Top + ly), data, clWhite);
      ly := ly + 14;
    end;
//      g_DXCanvas.//Release;
  end;
  if ViewDlgEdit then
  begin
    if not EdDlgEdit.Visible then
    begin
      EdDlgEdit.Visible := TRUE;
      EdDlgEdit.SetFocus;
    end;
  end;
end;

{------------------------------------------------------------------------}

//�α��� â

procedure TFrmDlg.DLoginNewDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if TDButton(Sender).Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;
//ע���ʺ�

procedure TFrmDlg.DLoginNewClick(Sender: TObject; X, Y: Integer);
var
  IE: variant;
begin
 LoginScene.NewClick;     // ��¼����ע��
//   2003/03/18 ��������ҳע�ᣬ������ҳע�ᣬ����������
//  if mrOk = FrmDlg.DMessageDlg('ע�����û�������ת��ٷ���վ��http://www.1mir2.com\ \�����ȷ������ť����ע�����û���', [mbOk, mbCancel]) then
//  begin
//    IE := CreateOleObject('Internetexplorer.Application');
//    IE.Visible := true;
//    IE.Navigate('http://www.1mir2.com');
//    FrmMain.CloseNPMon;
//    FrmMain.Close;
//  end;
end;

procedure TFrmDlg.DLoginOkClick(Sender: TObject; X, Y: Integer);
begin
  LoginScene.OkClick;
end;

procedure TFrmDlg.DLoginCloseClick(Sender: TObject; X, Y: Integer);
begin
//   FrmMain.CloseNPMon;
  FrmMain.Close;
end;
//�޸�����

procedure TFrmDlg.DLoginChgPwClick(Sender: TObject; X, Y: Integer);
var
  IE: variant;
begin
   LoginScene.ChgPwClick;    // ��¼�����޸����룬
//   2003/03/18 �������޸�������ת��ҳ��
//  if mrOk = FrmDlg.DMessageDlg('�����������ת��ٷ���վ��http://www.1mir2.com\ \�����ȷ������ť���������������ҳ�档', [mbOk, mbCancel]) then
//  begin
//    IE := CreateOleObject('Internetexplorer.Application');
//    IE.Visible := true;
//    IE.Navigate('http://1mir2.com');
//    FrmMain.CloseNPMon;
//    FrmMain.Close;
//  end;
end;

procedure TFrmDlg.DLoginNewClickSound(Sender: TObject; Clicksound: TClickSound);
begin
  case Clicksound of
    csNorm:
      PlaySound(s_norm_button_click);
    csStone:
      PlaySound(s_rock_button_click);
    csGlass:
      PlaySound(s_glass_button_click);
  end;
end;

{------------------------------------------------------------------------}
//��ʾѡ��������Ի���

procedure TFrmDlg.ShowSelectServerDlg;
begin
  DSelServerDlg.Visible := TRUE;
  BoFirstShowOnServerSel := TRUE;
end;

procedure TFrmDlg.DSelServerDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DSelServerDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
  if BoFirstShowOnServerSel then
  begin
    BoFirstShowOnServerSel := FALSE;

    if ServerCount >= 1 then
      DSServer1.Caption := ServerCaptionArr[0];
    if ServerCount >= 2 then
      DSServer2.Caption := ServerCaptionArr[1];
    if ServerCount >= 3 then
      DSServer3.Caption := ServerCaptionArr[2];
    if ServerCount >= 4 then
      DSServer4.Caption := ServerCaptionArr[3];
    if ServerCount >= 5 then
      DSServer5.Caption := ServerCaptionArr[4];
    if ServerCount >= 6 then
      DSServer6.Caption := ServerCaptionArr[5];
    if ServerCount >= 7 then
      DSServer7.Caption := ServerCaptionArr[6];
    if ServerCount >= 8 then
      DSServer8.Caption := ServerCaptionArr[7];
  end;

end;

procedure TFrmDlg.DSServer1Click(Sender: TObject; X, Y: Integer);
var
  svname: string;
begin
  svname := '';
  if TDButton(Sender).Tag = 0 then
    svname := ServerNameArr[0];
  if TDButton(Sender).Tag = 1 then
    svname := ServerNameArr[1];
  if TDButton(Sender).Tag = 2 then
    svname := ServerNameArr[2];
  if TDButton(Sender).Tag = 3 then
    svname := ServerNameArr[3];
  if TDButton(Sender).Tag = 4 then
    svname := ServerNameArr[4];
  if TDButton(Sender).Tag = 5 then
    svname := ServerNameArr[5];
  if TDButton(Sender).Tag = 6 then
    svname := ServerNameArr[6];
  if TDButton(Sender).Tag = 7 then
    svname := ServerNameArr[7];
  if TDButton(Sender).Tag = 8 then
    svname := ServerNameArr[8];

  if svname <> '' then
  begin
    if BO_FOR_TEST then
    begin
      svname := 'DragonServer';
    end;
    FrmMain.SendSelectServer(svname);
    DSelServerDlg.Visible := FALSE;
    ServerName := svname;
  end;
end;

procedure TFrmDlg.DEngServer1Click(Sender: TObject; X, Y: Integer);
var
  svname: string;
begin
  svname := 'DragonServer';

  if svname <> '' then
  begin
    if BO_FOR_TEST then
    begin
      svname := 'DragonServer';
    end;
    FrmMain.SendSelectServer(svname);
    DSelServerDlg.Visible := FALSE;
    ServerName := svname;
  end;
end;

procedure TFrmDlg.DSSrvCloseClick(Sender: TObject; X, Y: Integer);
begin
  DSelServerDlg.Visible := FALSE;
//   FrmMain.CloseNPMon;
  FrmMain.Close;
end;


{------------------------------------------------------------------------}
//�� ���� ����� â

//���ʺ�
procedure TFrmDlg.DNewAccountOkClick(Sender: TObject; X, Y: Integer);
begin
  LoginScene.NewAccountOk;
end;

procedure TFrmDlg.DNewAccountCloseClick(Sender: TObject; X, Y: Integer);
begin
  LoginScene.NewAccountClose;
end;

procedure TFrmDlg.DNewAccountDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  i: integer;
begin
  with g_DXCanvas do
  begin
    with DNewAccount do
    begin
      d := DMenuDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

//      //SetBkMode (Handle, TRANSPARENT);
//      Font.Color := clSilver;
    for i := 0 to NAHelps.Count - 1 do
    begin
      TextOut((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 79 + 386 + 10,
              (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 64 + 119 + 5 + i * 14, NAHelps[i], clSilver);
    end;
    TextOut((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 79 + 283, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 64 + 57, NewAccountTitle, clWhite);
//      //Release;
  end;
end;



{------------------------------------------------------------------------}
////Chg pw �ڽ�

procedure TFrmDlg.DChgpwOkClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DChgpwOk then
    LoginScene.ChgpwOk;
  if Sender = DChgpwCancel then
    LoginScene.ChgpwCancel;
end;




{------------------------------------------------------------------------}
//ĳ���� ����

procedure TFrmDlg.DscSelect1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(Left, Top, d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DscSelect1Click(Sender: TObject; X, Y: Integer);
begin
  if Sender = DscSelect1 then
    SelectChrScene.SelChrSelect1Click;
  if Sender = DscSelect2 then
    SelectChrScene.SelChrSelect2Click;
  if Sender = DscStart then
    SelectChrScene.SelChrStartClick;
  if Sender = DscNewChr then
    SelectChrScene.SelChrNewChrClick;
  if Sender = DscEraseChr then
    SelectChrScene.SelChrEraseChrClick;
  if Sender = DscCredits then
    SelectChrScene.SelChrCreditsClick;
  if Sender = DscExit then
    SelectChrScene.SelChrExitClick;
end;


{------------------------------------------------------------------------}
//�½�����ְҵѡ��

procedure TFrmDlg.DccCloseDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end
    else
    begin
      d := nil;
      if Sender = DccWarrior then
      begin
        with SelectChrScene do
          if ChrArr[NewIndex].UserChr.Job = 0 then
            d := WLib.Images[55];
      end;
      if Sender = DccWizzard then
      begin
        with SelectChrScene do
          if ChrArr[NewIndex].UserChr.Job = 1 then
            d := WLib.Images[56];
      end;
      if Sender = DccMonk then
      begin
        with SelectChrScene do
          if ChrArr[NewIndex].UserChr.Job = 2 then
            d := WLib.Images[57];
      end;
      if Sender = DccMale then
      begin
        with SelectChrScene do
          if ChrArr[NewIndex].UserChr.Sex = 0 then
            d := WLib.Images[58];
      end;
      if Sender = DccFemale then
      begin
        with SelectChrScene do
          if ChrArr[NewIndex].UserChr.Sex = 1 then
            d := WLib.Images[59];
      end;
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DccCloseClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DccClose then
    SelectChrScene.SelChrNewClose;
  if Sender = DccWarrior then
    SelectChrScene.SelChrNewJob(0);
  if Sender = DccWizzard then
    SelectChrScene.SelChrNewJob(1);
  if Sender = DccMonk then
    SelectChrScene.SelChrNewJob(2);
  if Sender = DccReserved then
    SelectChrScene.SelChrNewJob(3);
  if Sender = DccMale then
    SelectChrScene.SelChrNewSex(0);
  if Sender = DccFemale then
    SelectChrScene.SelChrNewSex(1);
//   if Sender = DccLeftHair then SelectChrScene.SelChrNewPrevHair;
//   if Sender = DccRightHair then SelectChrScene.SelChrNewNextHair;
  if Sender = DccOk then
    SelectChrScene.SelChrNewOk;
end;

{------------------------------------------------------------------------}

//������Ϣ���滭...

{------------------------------------------------------------------------}

procedure TFrmDlg.DStateWinDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  i, l, m, pgidx, magline, bbx, bby, mmx, idx, ax, ay, trainlv, tx: integer;
  pm: PTClientMagic;
  d: TDXTexture;
  hcolor, old, keyimg: integer;
  iname, d1, d2, d3, d4: string;
  useable: Boolean;
  str: string;
  FColor: TColor;
begin
  if Myself = nil then
    exit;
  with DStateWin do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    case StatePage of
      0:
        begin //�Լ�װ��
          pgidx := 376; //��4��
          if Myself <> nil then
            if Myself.Sex = 1 then
              pgidx := 377; //Ů4��
          bbx := Left + 38;
          bby := Top + 52;
          d := WProgUse.Images[pgidx];
          if d <> nil then
            dsurface.Draw(SurfaceX(bbx), SurfaceY(bby), d.ClientRect, d, FALSE);
          bbx := bbx - 7;
          bby := bby + 44;
          if UseItems[U_DRESS].S.Name <> '' then
          begin
            idx := UseItems[U_DRESS].S.Looks; //�·� if Myself.Sex = 1 then idx := 80; //Ů�·�
            if idx >= 0 then
            begin
              d := WStateItem.GetCachedImage(idx, ax, ay);
              if d <> nil then
                dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
            end;
          end;

          idx := 440 + Myself.Hair div 2; //����
          if Myself.Sex = 1 then
            idx := 480 + Myself.Hair div 2;
          if idx > 0 then
          begin
            d := WProgUse.GetCachedImage(idx, ax, ay);
            if d <> nil then
              dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
          end;

          if UseItems[U_WEAPON].S.Name <> '' then
          begin
            idx := UseItems[U_WEAPON].S.Looks;
            if idx >= 0 then
            begin
              d := WStateItem.GetCachedImage(idx, ax, ay);
              if d <> nil then
                dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
            end;
            if idx = 923 then
            begin
              d := WStateItem.GetCachedImage(idx - 1, ax, ay);
              if d <> nil then
                DrawBlend(dsurface, SurfaceX(bbx + ax), SurfaceY(bby + ay), d, 1);
            end;
          end;
          if UseItems[U_HELMET].S.Name <> '' then
          begin
            idx := UseItems[U_HELMET].S.Looks;
            if idx >= 0 then
            begin
              d := WStateItem.GetCachedImage(idx, ax, ay);
              if d <> nil then
                dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
            end;
          end;
        end;
      1:
        begin //״ֵ̬
          l := Left + 112; //66;
          m := Top + 99;
          with g_DXCanvas do
          begin  
               //SetBkMode (Handle, TRANSPARENT);
//               Font.Color := clWhite;
            TextOut(SurfaceX(l + 0), SurfaceY(m + 0), IntToStr(Lobyte(Myself.Abil.AC)) + '-' + IntToStr(Hibyte(Myself.Abil.AC)), clWhite);
            TextOut(SurfaceX(l + 0), SurfaceY(m + 20), IntToStr(Lobyte(Myself.Abil.MAC)) + '-' + IntToStr(Hibyte(Myself.Abil.MAC)), clWhite);
            TextOut(SurfaceX(l + 0), SurfaceY(m + 40), IntToStr(Lobyte(Myself.Abil.DC)) + '-' + IntToStr(Hibyte(Myself.Abil.DC)), clWhite);
            TextOut(SurfaceX(l + 0), SurfaceY(m + 60), IntToStr(Lobyte(Myself.Abil.MC)) + '-' + IntToStr(Hibyte(Myself.Abil.MC)), clWhite);
            TextOut(SurfaceX(l + 0), SurfaceY(m + 80), IntToStr(Lobyte(Myself.Abil.SC)) + '-' + IntToStr(Hibyte(Myself.Abil.SC)), clWhite);
            TextOut(SurfaceX(l + 0), SurfaceY(m + 100), IntToStr(Myself.Abil.HP) + '/' + IntToStr(Myself.Abil.MaxHP), clWhite);
            TextOut(SurfaceX(l + 0), SurfaceY(m + 120), IntToStr(Myself.Abil.MP) + '/' + IntToStr(Myself.Abil.MaxMP), clWhite);
                   //Release;
          end;
        end;
      2:
        begin //����������ֵ
          bbx := Left + 38;
          bby := Top + 52;
          d := WProgUse.Images[382];
          if d <> nil then
            dsurface.Draw(SurfaceX(bbx), SurfaceY(bby), d.ClientRect, d, FALSE);

          bbx := bbx + 20;
          bby := bby + 10;
          with g_DXCanvas do
          begin  
               //SetBkMode (Handle, TRANSPARENT);
            mmx := bbx + 85;
               //TextOut (bbx, bby, '����ֵ');
               //TextOut (mmx, bby, Format('%2.2f',[Myself.Abil.Exp/Myself.Abil.MaxExp*100]) + '%');

            TextOut(bbx, bby, '��ǰ����', clSilver);
            TextOut(mmx, bby, IntToStr(Myself.Abil.Exp), clSilver);

            TextOut(bbx, bby + 14 * 1, '��������', clSilver);
            TextOut(mmx, bby + 14 * 1, IntToStr(Myself.Abil.MaxExp), clSilver);

            TextOut(bbx, bby + 14 * 2, '��������', clSilver);
            if Myself.Abil.Weight > Myself.Abil.MaxWeight then
              FColor := clRed
            else
              FColor := clSilver;
            TextOut(mmx, bby + 14 * 2, IntToStr(Myself.Abil.Weight) + '/' + IntToStr(Myself.Abil.MaxWeight), FColor);

            TextOut(bbx, bby + 14 * 3, '��������', clSilver);
            if Myself.Abil.WearWeight > Myself.Abil.MaxWearWeight then
              FColor := clRed
            else
              FColor := clSilver;
            TextOut(mmx, bby + 14 * 3, IntToStr(Myself.Abil.WearWeight) + '/' + IntToStr(Myself.Abil.MaxWearWeight), FColor);

            TextOut(bbx, bby + 14 * 4, '����', clSilver);
            if Myself.Abil.HandWeight > Myself.Abil.MaxHandWeight then
              FColor := clRed
            else
              FColor := clSilver;
            TextOut(mmx, bby + 14 * 4, IntToStr(Myself.Abil.HandWeight) + '/' + IntToStr(Myself.Abil.MaxHandWeight), FColor);

            TextOut(bbx, bby + 14 * 5, '��ȷ��', clSilver);
            TextOut(mmx, bby + 14 * 5, IntToStr(MyHitPoint), clSilver);

            TextOut(bbx, bby + 14 * 6, '���ݶ�', clSilver);
            TextOut(mmx, bby + 14 * 6, IntToStr(MySpeedPoint), clSilver);

            TextOut(bbx, bby + 14 * 7, 'ħ������', clSilver);
            TextOut(mmx, bby + 14 * 7, '+' + IntToStr(MyAntiMagic * 10) + '%', clSilver);

            TextOut(bbx, bby + 14 * 8, '�ж�����', clSilver);
            TextOut(mmx, bby + 14 * 8, '+' + IntToStr(MyAntiPoison * 10) + '%', clSilver);

            TextOut(bbx, bby + 14 * 9, '�ж��ָ�', clSilver);
            TextOut(mmx, bby + 14 * 9, '+' + IntToStr(MyPoisonRecover * 10) + '%', clSilver);

            TextOut(bbx, bby + 14 * 10, '�����ָ�', clSilver);
            TextOut(mmx, bby + 14 * 10, '+' + IntToStr(MyHealthRecover * 10) + '%', clSilver);

            TextOut(bbx, bby + 14 * 11, 'ħ���ָ�', clSilver);
            TextOut(mmx, bby + 14 * 11, '+' + IntToStr(MySpellRecover * 10) + '%', clSilver);

            TextOut(bbx, bby + 14 * 12, 'Ԫ������', clSilver);
            TextOut(mmx, bby + 14 * 12, '' + IntToStr(Myself.PlayCash), clSilver);

          end;   //Release;

        end;
      3:
        begin //ħ������
          bbx := Left + 38;
          bby := Top + 52;
          d := WProgUse.Images[383];
          if d <> nil then
            dsurface.Draw(SurfaceX(bbx), SurfaceY(bby), d.ClientRect, d, FALSE);

            //lv, exp
          magtop := MagicPage * 5;
          magline := _MIN(MagicPage * 5 + 5, MagicList.Count);
          for i := magtop to magline - 1 do
          begin
            pm := PTClientMagic(MagicList[i]);
            m := i - magtop;
            keyimg := 0;
            case byte(pm.Key) of
              byte('1'):
                keyimg := 248;
              byte('2'):
                keyimg := 249;
              byte('3'):
                keyimg := 250;
              byte('4'):
                keyimg := 251;
              byte('5'):
                keyimg := 252;
              byte('6'):
                keyimg := 253;
              byte('7'):
                keyimg := 254;
              byte('8'):
                keyimg := 255;
                  // 2003/08/20 =>ħ��������Ű �߰�  // AddMagicKey
              byte('1') + 20:
                keyimg := 642;
              byte('2') + 20:
                keyimg := 643;
              byte('3') + 20:
                keyimg := 644;
              byte('4') + 20:
                keyimg := 645;
              byte('5') + 20:
                keyimg := 646;
              byte('6') + 20:
                keyimg := 647;
              byte('7') + 20:
                keyimg := 648;
              byte('8') + 20:
                keyimg := 649;
                  //-----------
            end;
            if keyimg > 0 then
            begin
              d := WProgUse.Images[keyimg];
              if d <> nil then
                dsurface.Draw(bbx + 145, bby + 8 + m * 37, d.ClientRect, d, TRUE);
            end;
            d := WProgUse.Images[112]; //lv
            if d <> nil then
              dsurface.Draw(bbx + 48, bby + 8 + 15 + m * 37, d.ClientRect, d, TRUE);
            d := WProgUse.Images[111]; //exp
            if d <> nil then
              dsurface.Draw(bbx + 48 + 26, bby + 8 + 15 + m * 37, d.ClientRect, d, TRUE);
          end;

          with g_DXCanvas do
          begin  
               //SetBkMode (Handle, TRANSPARENT);
//               Font.Color := clSilver;
            for i := magtop to magline - 1 do
            begin
              pm := PTClientMagic(MagicList[i]);
              m := i - magtop;
              if not (pm.Level in [0..3]) then
                pm.Level := 0; //ħ�����3��
              TextOut(bbx + 48, bby + 8 + m * 37, pm.Def.MagicName, clSilver);
              if pm.Level in [0..3] then
                trainlv := pm.Level
              else
                trainlv := 0;
              TextOut(bbx + 48 + 16, bby + 8 + 15 + m * 37, IntToStr(pm.Level), clSilver);
              if pm.Def.MaxTrain[trainlv] > 0 then
              begin
                if trainlv < 3 then
                  TextOut(bbx + 48 + 46, bby + 8 + 15 + m * 37, IntToStr(pm.CurTrain) + '/' + IntToStr(pm.Def.MaxTrain[trainlv]), clSilver)
                else
                  TextOut(bbx + 48 + 46, bby + 8 + 15 + m * 37, '-', clSilver);
              end;
            end;
               //Release;
          end;
        end;
    end;
      //������Ϊ��ʾ��������������Ʒ��Ϣ����ʾλ��Ϊ�����·�
    if MouseStateItem.S.Name <> '' then
    begin
      MouseItem := MouseStateItem;
      GetMouseItemInfo(iname, d1, d2, d3, d4, useable, TRUE);
      if iname <> '' then
      begin
        if MouseItem.Dura = 0 then
          hcolor := clRed
//            else if MouseItem.UpgradeOpt > 0 then hcolor := clAqua  //$0C36E9 //@@@@@
//        else if MouseItem.UpgradeOpt > 0 then     // ��Ʒ��ɫ  �Լ�����
//          hcolor := TColor($cccc33)          // ��Ʒ��ɫ  �Լ�����
        else
          hcolor := clWhite;

            // 2003/03/15 ������Ϊ��ʾ��������������Ʒ��Ϣ����ʾλ��Ϊ�����·�
        with g_DXCanvas do
        begin
          TextOut(SurfaceX(Left + 37), SurfaceY(Top + 272), iname, clYellow);
          TextOut(SurfaceX(Left + 37 + TextWidth(iname)), SurfaceY(Top + 272), d1, hcolor);
          TextOut(SurfaceX(Left + 37), SurfaceY(Top + 272 + TextHeight('A') + 2), d2, hcolor);
          TextOut(SurfaceX(Left + 37), SurfaceY(Top + 272 + (TextHeight('A') + 2) * 2), d3 + d4, hcolor);
        end;

            // 2003/03/15 ��ʾ��Ʒ��Ϣ���Ϸ�(Ư����ʾ)
            // Str := iname + d1 + '\' + d2 + '\' + d3 + d4;
            // DScreen.ShowHint(MouseX, MouseY, Str, hcolor, FALSE);

      end;
      MouseItem.S.Name := '';
    end;

      //������ơ��л����ơ�������
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := Myself.NameColor;
//
         tx := 122 - TextWidth(FrmMain.CharName) div 2;
////         TextOut (SurfaceX(Left + tx), SurfaceX(Top + 12), Myself.UserName);
         DHeartImg.Left := tx-14;
         DHeartImg.Top := 24;
//
//         TextOut (SurfaceX(Left + 122 - TextWidth(FrmMain.CharName) div 2),
//                  SurfaceY(Top + 23), Myself.UserName);

      TextOut(SurfaceX(Left + 122 - TextWidth(FrmMain.CharName) div 2), SurfaceY(Top + 23), Myself.UserName, Myself.NameColor);

      if StatePage = 0 then
      begin
        TextOut(SurfaceX(Left + 45), SurfaceY(Top + 55), GuildName + ' ' + GuildRankName, clSilver);
      end;
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DSWLightDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  idx: integer;
  d: TDXTexture;
begin
  if StatePage = 0 then
  begin
    if Sender = DSWNecklace then
    begin
      if UseItems[U_NECKLACE].S.Name <> '' then
      begin
        idx := UseItems[U_NECKLACE].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWNecklace.SurfaceX(DSWNecklace.Left + (DSWNecklace.Width - d.Width) div 2), DSWNecklace.SurfaceY(DSWNecklace.Top + (DSWNecklace.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWLight then
    begin
      if UseItems[U_RIGHTHAND].S.Name <> '' then
      begin
        idx := UseItems[U_RIGHTHAND].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWLight.SurfaceX(DSWLight.Left + (DSWLight.Width - d.Width) div 2), DSWLight.SurfaceY(DSWLight.Top + (DSWLight.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWArmRingR then
    begin
      if UseItems[U_ARMRINGR].S.Name <> '' then
      begin
        idx := UseItems[U_ARMRINGR].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWArmRingR.SurfaceX(DSWArmRingR.Left + (DSWArmRingR.Width - d.Width) div 2), DSWArmRingR.SurfaceY(DSWArmRingR.Top + (DSWArmRingR.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWArmRingL then
    begin
      if UseItems[U_ARMRINGL].S.Name <> '' then
      begin
        idx := UseItems[U_ARMRINGL].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWArmRingL.SurfaceX(DSWArmRingL.Left + (DSWArmRingL.Width - d.Width) div 2), DSWArmRingL.SurfaceY(DSWArmRingL.Top + (DSWArmRingL.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWRingR then
    begin
      if UseItems[U_RINGR].S.Name <> '' then
      begin
        idx := UseItems[U_RINGR].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWRingR.SurfaceX(DSWRingR.Left + (DSWRingR.Width - d.Width) div 2), DSWRingR.SurfaceY(DSWRingR.Top + (DSWRingR.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWRingL then
    begin
      if UseItems[U_RINGL].S.Name <> '' then
      begin
        idx := UseItems[U_RINGL].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWRingL.SurfaceX(DSWRingL.Left + (DSWRingL.Width - d.Width) div 2), DSWRingL.SurfaceY(DSWRingL.Top + (DSWRingL.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
      // 2003/03/15 ������ �κ��丮 Ȯ��
    if Sender = DSWBujuk then
    begin
      if UseItems[U_BUJUK].S.Name <> '' then
      begin
        idx := UseItems[U_BUJUK].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWBujuk.SurfaceX(DSWBujuk.Left + (DSWBujuk.Width - d.Width) div 2) + 1, DSWBujuk.SurfaceY(DSWBujuk.Top + (DSWBujuk.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWBelt then
    begin
      if UseItems[U_BELT].S.Name <> '' then
      begin
        idx := UseItems[U_BELT].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWBelt.SurfaceX(DSWBelt.Left + (DSWBelt.Width - d.Width) div 2) + 1, DSWBelt.SurfaceY(DSWBelt.Top + (DSWBelt.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWBoots then
    begin
      if UseItems[U_BOOTS].S.Name <> '' then
      begin
        idx := UseItems[U_BOOTS].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWBoots.SurfaceX(DSWBoots.Left + (DSWBoots.Width - d.Width) div 2 + 1), DSWBoots.SurfaceY(DSWBoots.Top + (DSWBoots.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;
    if Sender = DSWCharm then
    begin
      if UseItems[U_CHARM].S.Name <> '' then
      begin
        idx := UseItems[U_CHARM].S.Looks;
        if idx >= 0 then
        begin
          d := WStateItem.Images[idx];
          if d <> nil then
            dsurface.Draw(DSWCharm.SurfaceX(DSWCharm.Left + (DSWCharm.Width - d.Width) div 2 + 1), DSWCharm.SurfaceY(DSWCharm.Top + (DSWCharm.Height - d.Height) div 2), d.ClientRect, d, TRUE);
        end;
      end;
    end;

  end;
end;

procedure TFrmDlg.DStateWinClick(Sender: TObject; X, Y: Integer);
begin
  if StatePage = 3 then
  begin
    X := DStateWin.LocalX(X) - DStateWin.Left;
    Y := DStateWin.LocalY(Y) - DStateWin.Top;
    if (X >= 33) and (X <= 33 + 166) and (Y >= 55) and (Y <= 55 + 37 * 5) then
    begin
      magcur := (Y - 55) div 37;
      if (magcur + magtop) >= MagicList.Count then
        magcur := (MagicList.Count - 1) - magtop;
    end;
  end;
end;

procedure TFrmDlg.DCloseStateClick(Sender: TObject; X, Y: Integer);
begin
  DStateWin.Visible := FALSE;
end;

procedure TFrmDlg.DPrevStateDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if TDButton(Sender).Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.PageChanged;
begin
  case StatePage of
    2:
      begin //���� ����â
        DStMag1.Visible := FALSE;
        DStMag2.Visible := FALSE;
        DStMag3.Visible := FALSE;
        DStMag4.Visible := FALSE;
        DStMag5.Visible := FALSE;
        DStPageUp.Visible := FALSE;
        DStPageDown.Visible := FALSE;
      end;
    3:
      begin //���� ����â
        DStMag1.Visible := TRUE;
        DStMag2.Visible := TRUE;
        DStMag3.Visible := TRUE;
        DStMag4.Visible := TRUE;
        DStMag5.Visible := TRUE;
        DStPageUp.Visible := TRUE;
        DStPageDown.Visible := TRUE;
        MagicPage := 0;
      end;
  else
    begin
      DStMag1.Visible := FALSE;
      DStMag2.Visible := FALSE;
      DStMag3.Visible := FALSE;
      DStMag4.Visible := FALSE;
      DStMag5.Visible := FALSE;
      DStPageUp.Visible := FALSE;
      DStPageDown.Visible := FALSE;
    end;
  end;
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.DPrevStateClick(Sender: TObject; X, Y: Integer);
begin
  Dec(StatePage);
  if StatePage < 0 then
    StatePage := MAXSTATEPAGE - 1;
  PageChanged;
end;

procedure TFrmDlg.DNextStateClick(Sender: TObject; X, Y: Integer);
begin
  Inc(StatePage);
  if StatePage > MAXSTATEPAGE - 1 then
    StatePage := 0;
  PageChanged;
end;

procedure TFrmDlg.DSWWeaponClick(Sender: TObject; X, Y: Integer);
var
  where, n, sel: integer;
  flag, movcancel: Boolean;
begin
  if Myself = nil then
    exit;
  if StatePage <> 0 then
    exit;
  if ItemMoving then
  begin
    flag := FALSE;
    movcancel := FALSE;
    if (MovingItem.Index = -97) or (MovingItem.Index = -98) then
      exit;
    if (MovingItem.Item.S.Name = '') or (WaitingUseItem.Item.S.Name <> '') then
      exit;
    where := GetTakeOnPosition(MovingItem.Item.S.StdMode);
    if MovingItem.Index >= 0 then
    begin
      case where of
        U_DRESS:
          begin
            if Sender = DSWDress then
            begin
              if Myself.Sex = 0 then //����
                if MovingItem.Item.S.StdMode <> 10 then //���ڿ�
                  exit;
              if Myself.Sex = 1 then //����
                if MovingItem.Item.S.StdMode <> 11 then //���ڿ�
                  exit;
              flag := TRUE;
            end;
          end;
        U_WEAPON:
          begin
            if Sender = DSWWEAPON then
            begin
              flag := TRUE;
            end;
          end;
        U_NECKLACE:
          begin
            if Sender = DSWNecklace then
              flag := TRUE;
          end;
        U_RIGHTHAND:
          begin
            if Sender = DSWLight then
              flag := TRUE;
          end;
        U_HELMET:
          begin
            if Sender = DSWHelmet then
              flag := TRUE;
          end;
        U_RINGR, U_RINGL:
          begin
            if DSWRingL=Sender then
               where := U_RINGL
               else
               where := U_RINGR;
             flag := TRUE;
          end;
        U_ARMRINGR,U_ARMRINGL:              //�ֶ�����
          begin  //����
            if DSWArmRingL=Sender then
               where := U_ARMRINGL
               else
               where := U_ARMRINGR;
             flag := TRUE;
          end;
            // 2003/03/15 COPARK ������ �κ��丮 Ȯ��
        U_BUJUK:
          begin       //����, ������
            if Sender = DSWBujuk then
            begin
              where := U_BUJUK;
              flag := TRUE;
            end;
            if Sender = DSWArmRingL then
            begin
              where := U_ARMRINGL;
              flag := TRUE;
            end;
          end;
        U_BELT:
          begin  //��Ʈ
            if Sender = DSWBelt then
            begin
              where := U_BELT;
              flag := TRUE;
            end;
          end;
        U_BOOTS:
          begin  //�Ź�
            if Sender = DSWBoots then
            begin
              where := U_BOOTS;
              flag := TRUE;
            end;
          end;
        U_CHARM:
          begin  //��ȣ��
            if Sender = DSWCharm then
            begin
              where := U_CHARM;
              flag := TRUE;
            end;
          end;

      end;
    end
    else
    begin
      n := -(MovingItem.Index + 1);
         // 2003/03/15 COPARK ������ �κ��丮 Ȯ��
      if n in [0..12] then
      begin            // 8->12
        ItemClickSound(MovingItem.Item.S);
        UseItems[n] := MovingItem.Item;
        MovingItem.Item.S.Name := '';
        ItemMoving := FALSE;
      end;
    end;
    if flag then
    begin
      ItemClickSound(MovingItem.Item.S);
      WaitingUseItem := MovingItem;
      WaitingUseItem.Index := where;

      FrmMain.SendTakeOnItem(where, MovingItem.Item.MakeIndex, MovingItem.Item.S.Name);
      MovingItem.Item.S.Name := '';
      ItemMoving := FALSE;
    end;
  end
  else
  begin
    flag := FALSE;
    if (MovingItem.Item.S.Name <> '') or (WaitingUseItem.Item.S.Name <> '') then
      exit;
    sel := -1;
    if Sender = DSWDress then
      sel := U_DRESS;
    if Sender = DSWWeapon then
      sel := U_WEAPON;
    if Sender = DSWHelmet then
      sel := U_HELMET;
    if Sender = DSWNecklace then
      sel := U_NECKLACE;
    if Sender = DSWLight then
      sel := U_RIGHTHAND;
    if Sender = DSWRingL then
      sel := U_RINGL;
    if Sender = DSWRingR then
      sel := U_RINGR;
    if Sender = DSWArmRingL then
      sel := U_ARMRINGL;
    if Sender = DSWArmRingR then
      sel := U_ARMRINGR;
      // 2003/03/15 ������ �κ��丮 Ȯ��
    if Sender = DSWBujuk then
      sel := U_BUJUK;
    if Sender = DSWBelt then
      sel := U_BELT;
    if Sender = DSWBoots then
      sel := U_BOOTS;
    if Sender = DSWCharm then
      sel := U_CHARM;

    if sel >= 0 then
    begin
      if UseItems[sel].S.Name <> '' then
      begin
        ItemClickSound(UseItems[sel].S);
        MovingItem.Index := -(sel + 1);
        MovingItem.Item := UseItems[sel];
        UseItems[sel].S.Name := '';
        ItemMoving := TRUE;
      end;
    end;
  end;
end;

procedure TFrmDlg.DSWWeaponMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  sel: integer;
  iname, d1, d2, d3: string;
  useable: Boolean;
  hcolor: TColor;
  lx, ly: integer;
begin

  if StatePage = 1 then
  begin
    lx := X; // - DStateWin.Left;
    ly := Y; // - DStateWin.Top;
//      DScreen.AddChatBoardString ('lx=> '+IntToStr(lx) +'  ly=> '+IntToStr(ly), clYellow, clRed);
    if (lx > 57) and (lx < 180) and (ly > 88) and (ly < 105) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 90, '', clYellow, FALSE)    //�������м�������������������Ķ�Ӧ���ԣ����ָ��ȥ��ʾ������ Ĭ��Ϊ�������
    else if (lx > 57) and (lx < 180) and (ly > 110) and (ly < 127) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 112, '', clYellow, FALSE)     //Ĭ��Ϊħ������
    else if (lx > 57) and (lx < 180) and (ly > 132) and (ly < 149) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 134, '', clYellow, FALSE)    //Ĭ��Ϊ������
    else if (lx > 57) and (lx < 180) and (ly > 154) and (ly < 171) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 156, '', clYellow, FALSE)    //Ĭ��Ϊħ����
    else if (lx > 57) and (lx < 180) and (ly > 176) and (ly < 193) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 178, '', clYellow, FALSE)     //Ĭ��Ϊ����
    else if (lx > 57) and (lx < 180) and (ly > 198) and (ly < 215) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 200, '', clYellow, FALSE)   //��Ϊ����ֵ
    else if (lx > 57) and (lx < 180) and (ly > 220) and (ly < 237) then
      DScreen.ShowHint(DStateWin.Left + 158, DStateWin.Top + 222, '', clYellow, FALSE)    //Ĭ��Ϊħ��ֵ

    else
      DScreen.ClearHint(True);
  end;

  if StatePage <> 0 then
    exit;
   //DScreen.ClearHint(True);
  sel := -1;
  if Sender = DSWDress then
    sel := U_DRESS;
  if Sender = DSWWeapon then
    sel := U_WEAPON;
  if Sender = DSWHelmet then
    sel := U_HELMET;
  if Sender = DSWNecklace then
    sel := U_NECKLACE;
  if Sender = DSWLight then
    sel := U_RIGHTHAND;
  if Sender = DSWRingL then
    sel := U_RINGL;
  if Sender = DSWRingR then
    sel := U_RINGR;
  if Sender = DSWArmRingL then
    sel := U_ARMRINGL;
  if Sender = DSWArmRingR then
    sel := U_ARMRINGR;
   // 2003/03/15 ������ �κ��丮 Ȯ��
  if Sender = DSWBujuk then
    sel := U_BUJUK;
  if Sender = DSWBelt then
    sel := U_BELT;
  if Sender = DSWBoots then
    sel := U_BOOTS;
  if Sender = DSWCharm then
    sel := U_CHARM;

  if sel >= 0 then
  begin
    MouseStateItem := UseItems[sel];
      // 2003/03/15 ������ �κ��丮 Ȯ��
    MouseX := DStateWin.Left + X;
    MouseY := DStateWin.Top + Y;
      {MouseItem := UseItems[sel];
      GetMouseItemInfo (iname, d1, d2, d3, useable);
      if iname <> '' then begin
         if UseItems[sel].Dura = 0 then hcolor := clRed
         else hcolor := clSilver;
         with Sender as TDButton do
            DScreen.ShowHint (SurfaceX(Left - 30),
                              SurfaceY(Top + 50),
                              iname + d1 + '\' + d2 + '\' + d3 + d4, hcolor, FALSE);
      end;
      MouseItem.S.Name := '';}
  end;
end;


//����â : ���� ������

procedure TFrmDlg.DStMag1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  idx, icon: integer;
  d: TDXTexture;
  pm: PTClientMagic;
begin
  with Sender as TDButton do
  begin
    idx := _Max(Tag + MagicPage * 5, 0);
    if idx < MagicList.Count then
    begin
      pm := PTClientMagic(MagicList[idx]);
      icon := pm.Def.Effect * 2;
      if icon >= 0 then
      begin //�������� ���°�..
        if not Downed then
        begin
          d := WMagicon.Images[icon];
          if d <> nil then
            dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
        end
        else
        begin
          d := WMagicon.Images[icon + 1];
          if d <> nil then
            dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
        end;
      end;
    end;
  end;
end;

procedure TFrmDlg.DStMag1Click(Sender: TObject; X, Y: Integer);
var
  i, idx: integer;
  selkey: word;
  keych: AnsiChar;
  pm: PTClientMagic;
begin
  if StatePage = 3 then
  begin
    idx := TDButton(Sender).Tag + magtop;
    if (idx >= 0) and (idx < MagicList.Count) then
    begin

      pm := PTClientMagic(MagicList[idx]);
      selkey := word(pm.Key);
      SetMagicKeyDlg(pm.Def.Effect * 2, pm.Def.MagicName, selkey);
      keych := AnsiChar(selkey);

      for i := 0 to MagicList.Count - 1 do
      begin
        pm := PTClientMagic(MagicList[i]);
        if pm.Key = keych then
        begin
          pm.Key := #0;
          FrmMain.SendMagicKeyChange(pm.Def.MagicId, #0);
        end;
      end;
      pm := PTClientMagic(MagicList[idx]);
         //if pm.Def.EffectType <> 0 then begin //�˹��� Ű������ ����.
      pm.Key := keych;
      FrmMain.SendMagicKeyChange(pm.Def.MagicId, keych);
         //end;
    end;
  end;
end;

procedure TFrmDlg.DStPageUpClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DStPageUp then
  begin
    if MagicPage > 0 then
      Dec(MagicPage);
  end
  else
  begin
    if MagicPage < (MagicList.Count + 4) div 5 - 1 then
      Inc(MagicPage);
  end;
end;





{------------------------------------------------------------------------}

//�ײ�״̬

{------------------------------------------------------------------------}

procedure TFrmDlg.DBottomDirectPaint(Sender: TObject; dsurface: TDXTexture);
  function GetJobAttackMode (mode: integer): string;
  begin
    Result := '';
    case mode of
      0: Result := '[ȫ�幥��]';
      1: Result := '[��ƽ����]';
      2: Result := '[���鹥��]';
      3: Result := '[�лṥ��]';
      4: Result := '[�ƶ񹥻�]';
    end;
  end;
var
  d: TDXTexture;
  rc: TRect;
  btop, sx, sy, i, fcolor, bcolor: integer;
  r: Real;
  s: string;
  sHpStr, sMpStr: string;
begin
  if g_FScreenMode = 1 then d := WProgUse.Images[BOTTOMBOARD1024]
  else d := WProgUse.Images[BOTTOMBOARD];

  if d <> nil then
    dsurface.Draw(DBottom.Left, DBottom.Top, d.ClientRect, d, TRUE);
  btop := 0;
  if d <> nil then
  begin
    with d.ClientRect do
      rc := Rect(Left, Top, Right, Top + 120);
    btop := g_FScreenHeight - d.height;
      //�ϰ벿͸��
    dsurface.Draw(0, btop, rc, d, TRUE);
      //�°벿��͸��
    with d.ClientRect do
      rc := Rect(Left, Top + 120, Right, Bottom);
    dsurface.Draw(0, btop + 120, rc, d, FALSE);
  end;
   //����(����,����,����,����)
  d := nil;
  case DayBright of
    0:
      d := WProgUse.Images[15];  //����
    1:
      d := WProgUse.Images[12];  //����
    2:
      d := WProgUse.Images[13];  //����
    3:
      d := WProgUse.Images[14];  //����
  end;
  if d <> nil then
    dsurface.Draw(g_FScreenWidth-52, 79 + DBottom.Top, d.ClientRect, d, TRUE);

  if Myself <> nil then
  begin
      //��ʾHP��MP ͼ��
    if (Myself.Abil.MaxHP > 0) and (Myself.Abil.MaxMP > 0) then
    begin
      if (Myself.Job = 0) and (Myself.Abil.Level < 28) then
      begin //��ʿlv26
        d := WProgUse.Images[5];
        if d <> nil then
        begin
          rc := d.ClientRect;
          rc.Right := d.ClientRect.Right - 2;
          dsurface.Draw(38, btop + 90, rc, d, TRUE);
        end;
        d := WProgUse.Images[6];
        if d <> nil then
        begin
          rc := d.ClientRect;
          rc.Right := d.ClientRect.Right - 2;
          rc.Top := Round(rc.Bottom / Myself.Abil.MaxHP * (Myself.Abil.MaxHP - Myself.Abil.HP));
          dsurface.Draw(38, btop + 90 + rc.Top, rc, d, TRUE);
        end;
      end
      else
      begin
        d := WProgUse.Images[4];
        if d <> nil then
        begin
               //HP ͼ��
          rc := d.ClientRect;
          rc.Right := d.ClientRect.Right div 2 - 1;
          rc.Top := Round(rc.Bottom / Myself.Abil.MaxHP * (Myself.Abil.MaxHP - Myself.Abil.HP));
          rc.Top := _MAX(rc.Top, 0);
          dsurface.Draw(40, btop + 91 + rc.Top, rc, d, TRUE);
               //MP ͼ��
          rc := d.ClientRect;
          rc.Left := d.ClientRect.Right div 2 + 1;
          rc.Right := d.ClientRect.Right - 1;
          rc.Top := Round(rc.Bottom / Myself.Abil.MaxMP * (Myself.Abil.MaxMP - Myself.Abil.MP));
          rc.Top := _MAX(rc.Top, 0);
          dsurface.Draw(40 + rc.Left, btop + 91 + rc.Top, rc, d, TRUE);
        end;
      end;
      with g_DXCanvas do begin //���½�Ѫ����ħ��ֵ��ʾ
        sHpStr := format('%d/%d',[MySelf.Abil.HP,MySelf.Abil.MaxHP]);
        sMpStr := format('%d/%d',[MySelf.Abil.MP,MySelf.Abil.MaxMP]);
        TextOut (55 - (TextWidth(sHpStr) div 2), g_FScreenHeight-37, sHpStr, clWhite);
        TextOut (116 - (TextWidth(sMpStr) div 2), g_FScreenHeight-37, sMpStr, clWhite);
      end;
    end;

      //�ȼ�
    with g_DXCanvas do
    begin
      PomiTextOut(dsurface, g_FScreenWidth-140, g_FScreenHeight-104, IntToStr(Myself.Abil.Level));
      TextOut (g_FScreenWidth-159, g_FScreenHeight-138, GetJobAttackMode(MySelf.AttackMode), clWhite);    //���½ǹ���ģʽ��ʾ
    end;

//        {-----------------����Ļ���½���ʾʱ��--------------------------------------}
        Set8087CW(Longword($133F));   //ȫ��ģʽʱ�䲻��
        g_DXCanvas.TextOut (g_FScreenWidth-128, g_FScreenHeight-21, FormatDateTime('hh:mm:ss',Now), clWhite {clBlack} );

      //������, ����������
    if (Myself.Abil.MaxExp > 0) and (Myself.Abil.MaxWeight > 0) then
    begin
      d := WProgUse.Images[7];
      if d <> nil then
      begin
          //������
        rc := d.ClientRect;
        if MySelf.Abil.Exp > 0 then
          r := MySelf.Abil.MaxExp / MySelf.Abil.Exp
        else
          r := 0;
        if r > 0 then
          rc.Right := Round(rc.Right / r)
        else
          rc.Right := 0;
        rc.Right := _MIN(rc.Right, d.Width);
        dsurface.Draw(g_FScreenWidth - 134, g_FScreenHeight - 73, rc, d, FALSE);
        //����������


          rc := d.ClientRect;
          if MySelf.Abil.Weight > 0 then r := MySelf.Abil.MaxWeight / MySelf.Abil.Weight
          else r := 0;

          if r > 0 then rc.Right := Round(rc.Right / r)
          else rc.Right := 0;

          rc.Right := _MIN(rc.Right, d.Width);

          dsurface.Draw(g_FScreenWidth div 2 + (g_FScreenWidth div 2 - (400 - 266)), g_FScreenHeight - 40, rc, d, False);

      {  rc := d.ClientRect;
        if MySelf.Abil.WearWeight > 0 then begin
          rc.Right := _MIN(Round(rc.Right / (0 / MySelf.Abil.WearWeight)), rc.Right);
          rc.Right := _MIN(rc.Right, d.Width);
          dsurface.Draw(g_FScreenWidth - 134, g_FScreenHeight - 40, rc, d, FALSE);
        end;  }
      end;
    end;
      //�����̶�
      { 2003/04/15 ������ ��ü
      if MyHungryState in [1..4] then begin
         d := WProgUse.Images[16 + MyHungryState-1];
         if d <> nil then begin
            dsurface.Draw (754, 553, d.ClientRect, d, TRUE);
         end;
      end;
      }

  end;
 //-----------------------------------------------------------------------
   //��ʾ���������
  sx := 208;
  sy := g_FScreenHeight - 130;
  with DScreen do
  begin
      //SetBkMode (g_DXCanvas.Handle, OPAQUE);
    for i := ChatBoardTop to ChatBoardTop + VIEWCHATLINE - 1 do
    begin
      if i > ChatStrs.Count - 1 then
        break;
      fcolor := integer(ChatStrs.Objects[i]);
      bcolor := integer(ChatBks[i]);
//         g_DXCanvas.Font.Color := fcolor;
//         g_DXCanvas.Brush.Color := bcolor;
//         g_DXCanvas.TextOut (sx, sy+(i-ChatBoardTop)*12, ChatStrs.Strings[i]);
      g_DXCanvas.TextOut(sx, sy + (i - ChatBoardTop) * 12, ChatStrs.Strings[i], bcolor, fcolor);
    end;
  end;
//   g_DXCanvas.//Release;

end;




{--------------------------------------------------------------}
//�жϵײ�����ϵ�һ���Ƿ�͸��

procedure TFrmDlg.DBottomInRealArea(Sender: TObject; X, Y: Integer; var IsRealArea: Boolean);
var
  d: TDXTexture;
begin
  if g_FScreenMode = 1 then d := WProgUse.Images[BOTTOMBOARD1024]
  else d := WProgUse.Images[BOTTOMBOARD];
  
  if d <> nil then
  begin
    if d.Pixels[X, Y] > 0 then
      IsRealArea := TRUE
    else
      IsRealArea := FALSE;
  end;
end;

procedure TFrmDlg.DMyStateDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDButton;
  dd: TDXTexture;
begin
  if Sender is TDButton then
  begin
    d := TDButton(Sender);
    if d.Downed then
    begin
      dd := d.WLib.Images[d.FaceIndex];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end;

  end;
end;

procedure TFrmDlg.DMyStateMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  sMsg:String;
begin
  if Sender = DBotMiniMap then
    sMsg := '��ͼ(Tab)';
  if Sender = DBotTrade then
    sMsg := '����(T)';
  if Sender = DBotGuild then
    sMsg := '�л�(G)';
  if Sender = DBotGroup then
    sMsg := '�������/�Ҽ�����';
  if Sender = DBotPlusAbil then
    sMsg := '����';
  if Sender = DBotFriend then
    sMsg := '����(W)';
  if Sender = DBotMaster then
    sMsg := '��ϵ(L)';
  if Sender = DBotLogout then
    sMsg := 'С��(Alt+X)';
  if Sender = DBotExit then
    sMsg := '�˳�(Alt+Q)';
  if Sender = DBotMemo then
    sMsg := '�ʼ�(M)';
  if Sender = DMyState then
    sMsg := '״̬��Ϣ(F10)';
  if Sender = DMyBag then
    sMsg := '������Ʒ(F9)';
  if Sender = DMyMagic then
    sMsg := '������Ϣ(F11)';
  if Sender = DOption then
    sMsg := '��Ч����';

  with Sender as TDButton do
    DScreen.ShowHint(SurfaceX(Left - 8), SurfaceY(Top - 20), sMsg, clWhite, FALSE); // clYellow ��ť������ɫ
end;

procedure TFrmDlg.DBotMemoDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDButton;
  dd: TDXTexture;
begin
  DMyStateDirectPaint(Sender, dsurface);

  if Sender is TDButton then
  begin
    d := TDButton(Sender);
     // ������ ǥ�� ??
    if not TDButton(Sender).Downed and MailAlarm then
    begin
      if (GetTickCount mod 1000) > 500 then
        dd := d.WLib.Images[d.FaceIndex]
      else
        dd := d.WLib.Images[d.FaceIndex + 1];

      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);

    end;
  end;
end;


//�׷�, ��ȯ, �� ��ư
procedure TFrmDlg.DBotGroupDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDButton;
  dd: TDXTexture;
begin
  if Sender is TDButton then
  begin
    d := TDButton(Sender);
    if not d.Downed then
    begin
      dd := d.WLib.Images[d.FaceIndex];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end
    else
    begin
      dd := d.WLib.Images[d.FaceIndex + 1];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DBotGroupMouseDown(Sender: TObject; Button: TMouseButton;    //����Ҽ�������ӿ���
  Shift: TShiftState; X, Y: Integer);
begin          
   if ssRight in Shift then

     begin
        if GetTickCount > changegroupmodetime then
          begin
          AllowGroup := not AllowGroup;
          changegroupmodetime := GetTickCount + 2000;
          FrmMain.SendGroupMode(AllowGroup);
          end;

       if AllowGroup then
       begin
         DScreen.AddChatBoardString('[�������]', clgreen, clwhite);
       end
       else
       begin
         DScreen.AddChatBoardString('[�ܾ����]', clgreen, clblack);
       end;
     end
     else
     ToggleShowGroupDlg;
end;

procedure TFrmDlg.DBotPlusAbilDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDButton;
  dd: TDXTexture;
begin
  if Sender is TDButton then
  begin
    d := TDButton(Sender);
    if not d.Downed then
    begin
      if (BlinkCount mod 2 = 0) and (not DAdjustAbility.Visible) then
        dd := d.WLib.Images[d.FaceIndex]
      else
        dd := d.WLib.Images[d.FaceIndex + 2];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end
    else
    begin
      dd := d.WLib.Images[d.FaceIndex + 1];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end;

    if GetTickCount - BlinkTime >= 500 then
    begin
      BlinkTime := GetTickCount;
      Inc(BlinkCount);
      if BlinkCount >= 10 then
        BlinkCount := 0;
    end;
  end;
end;

procedure TFrmDlg.DMyStateClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DMyState then
  begin
    StatePage := 0;
    OpenMyStatus;
  end;
  if Sender = DMyBag then
    OpenItemBag;
  if Sender = DMyMagic then
  begin
    StatePage := 3;
    OpenMyStatus;
  end;
  if Sender = DOption then
  begin
    TogglePlaySoundEffect;
  end;
end;

procedure TFrmDlg.DOptionClick(Sender: TObject);
begin
end;





{------------------------------------------------------------------------}

// 1-6 �����

{------------------------------------------------------------------------}
procedure TFrmDlg.DBelt1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  idx: integer;
  d: TDXTexture;
begin
  if Myself = nil then
    Exit;
  with Sender as TDButton do
  begin
    idx := Tag;
    if idx in [0..5] then
    begin
      if ItemArr[idx].s.Name <> '' then
      begin
        d := WBagItem.Images[ItemArr[idx].s.Looks];
        if d <> nil then
          dsurface.Draw(SurfaceX(Left + (Width - d.Width) div 2), SurfaceY(Top + (Height - d.Height) div 2), d.ClientRect, d, TRUE);

         // ������ ��ġ��   //new add
        if ItemArr[idx].s.OverlapItem > 0 then
        begin
               //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//               g_DXCanvas.Font.Color := clYellow;

          g_DXCanvas.TextOut(SurfaceX(Left + (Width - d.Width) div 2), SurfaceY(Top + (Height - d.Height) div 2), IntToStr(ItemArr[idx].Dura), clYellow);
//               g_DXCanvas.//Release;
        end;

      end;
    end;
    PomiTextOut(dsurface, SurfaceX(Left + 13), SurfaceY(Top + 19), IntToStr(idx + 1));
  end;
end;

procedure TFrmDlg.DBelt1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
begin
  idx := TDButton(Sender).Tag;
  if idx in [0..5] then
  begin
    if ItemArr[idx].s.Name <> '' then
    begin
      MouseItem := ItemArr[idx];
    end;
  end;
end;

procedure TFrmDlg.DBelt1Click(Sender: TObject; X, Y: Integer);
var
  idx: integer;
  temp: TClientItem;
begin
  idx := TDButton(Sender).Tag;
  if idx in [0..5] then
  begin
    if not ItemMoving then
    begin
      if ItemArr[idx].s.Name <> '' then
      begin
        ItemClickSound(ItemArr[idx].s);
        ItemMoving := TRUE;
        MovingItem.Index := idx;
        MovingItem.Item := ItemArr[idx];
        ItemArr[idx].s.Name := '';
      end;
    end
    else
    begin
      if (MovingItem.Index = -97) or (MovingItem.Index = -98) then
        exit;
//         if MovingItem.Item.S.StdMode <= 3 then begin //����,����,��ũ��
      if (MovingItem.Item.S.StdMode <= 3){ or (MovingItem.Item.S.StdMode = 25)} then
      begin //����,����,��ũ��, ������, ����
            //ItemClickSound (MovingItem.Item.S.StdMode);
        if ItemArr[idx].s.Name <> '' then
        begin
          temp := ItemArr[idx];
          ItemArr[idx] := MovingItem.Item;
          MovingItem.Index := idx;
          MovingItem.Item := temp
        end
        else
        begin
          ItemArr[idx] := MovingItem.Item;
          MovingItem.Item.S.name := '';
          ItemMoving := FALSE;
        end;
      end;
    end;
  end;
end;

{procedure TFrmDlg.DBelt1Click(Sender: TObject; X, Y: Integer);
var
   idx: integer;
   temp: TClientItem;
begin
   idx := TDButton(Sender).Tag;
   if idx in [0..5] then begin
      if not ItemMoving then begin
         if ItemArr[idx].S.Name <> '' then begin
            ItemClickSound (ItemArr[idx].S);
            ItemMoving := TRUE;
            MovingItem.Index := idx;
            MovingItem.Item := ItemArr[idx];
            ItemArr[idx].S.Name := '';
         end;
      end else begin
         if (MovingItem.Index = -97) or (MovingItem.Index = -98) then exit;
         if MovingItem.Item.S.StdMode <= 3 then begin //����,����,��ũ��
            //ItemClickSound (MovingItem.Item.S.StdMode);
            if ItemArr[idx].S.Name <> '' then begin
               temp := ItemArr[idx];
               ItemArr[idx] := MovingItem.Item;
               MovingItem.Index := idx;
               MovingItem.Item := temp
            end else begin
               ItemArr[idx] := MovingItem.Item;
               MovingItem.Item.S.name := '';
               ItemMoving := FALSE;
            end;
         end;
      end;
   end;
end;}

procedure TFrmDlg.DBelt1DblClick(Sender: TObject);
var
  idx, where: integer;
  TempSender: TObject;
begin
  idx := TDButton(Sender).Tag;
  if idx in [0..5] then
  begin
    if ItemArr[idx].s.Name <> '' then
    begin
      if (ItemArr[idx].s.StdMode <= 4) or (ItemArr[idx].s.StdMode = 31) then
      begin //����� �� �ִ� ������
        StBeltAutoFill := True;
        FrmMain.EatItem(idx);
      end;
    end
    else
    begin
//         if ItemMoving and (MovingItem.Index = idx) and
//           (MovingItem.Item.S.StdMode <= 4) or (MovingItem.Item.S.StdMode = 31)
      if ItemMoving and (MovingItem.Index = idx) and (MovingItem.Item.S.StdMode <= 4) or (MovingItem.Item.S.StdMode in [31,70]){ or (MovingItem.Item.S.StdMode = 25) }then
      begin
      {  if MovingItem.Item.S.StdMode = 25 then
        begin
//      DScreen.AddChatBoardString ('MovingItem.Item.S.Shape=> '+IntToStr(MovingItem.Item.S.Shape), clYellow, clRed);
          where := GetTakeOnPosition(MovingItem.Item.S.StdMode);
          if MovingItem.Index >= 0 then
          begin
            case where of
              U_ARMRINGR, U_BUJUK:
                begin
                //  TempSender := DSWBujuk;
                  TempSender := DSWArmRingL;
                end;
            end;
          end;
          DSWWeaponClick(TempSender, 1, 1);
          Exit;
        end;   }
        StBeltAutoFill := True;
        FrmMain.EatItem(-1);
        BtInDex := idx;
      end;
    end;
  end;
end;

{----------------------------------------------------------}

//��Ʒ��Ϣ

{----------------------------------------------------------}

procedure TFrmDlg.GetMouseItemInfo(var iname, line1, line2, line3, line4: string; var useable: boolean; bowear: Boolean);

  function GetDuraStr(dura, maxdura: integer): string;
  begin
    if not BoNoDisplayMaxDura then
      Result := IntToStr(Round(dura / 1000)) + '/' + IntToStr(Round(maxdura / 1000))
    else
      Result := IntToStr(Round(dura / 1000));
  end;

  function GetDura100Str(dura, maxdura: integer): string;
  begin
    if not BoNoDisplayMaxDura then
      Result := IntToStr(Round(dura / 100)) + '/' + IntToStr(Round(maxdura / 100))
    else
      Result := IntToStr(Round(dura / 100));
  end;

begin
  if Myself = nil then
    exit;
  iname := '';
  line1 := '';
  line2 := '';
  line3 := '';
  useable := TRUE;

  if MouseItem.S.Name <> '' then
  begin
    iname := MouseItem.S.Name + ' ';
    case MouseItem.S.StdMode of
      0:
        begin //ҩƷ
          if MouseItem.S.Shape = 1 then
          begin //����
            if (MouseItem.S.DC > 0) and (MouseItem.S.MC > 0) then
            begin
              line1 := line1 + 'HP' + IntToStr(MouseItem.S.DC) + '%�ָ� ';
              line1 := line1 + 'MP' + IntToStr(MouseItem.S.MC) + '%�ָ� ';
            end
            else if (MouseItem.S.DC > 0) then
              line1 := line1 + 'HP' + IntToStr(MouseItem.S.DC) + '%�ָ� '
            else if (MouseItem.S.MC > 0) then
              line1 := line1 + 'MP' + IntToStr(MouseItem.S.MC) + '%�ָ� ';
          end;

          if MouseItem.S.AC > 0 then
            line1 := '+' + IntToStr(MouseItem.S.AC) + 'HP ';
          if MouseItem.S.MAC > 0 then
            line1 := line1 + '+' + IntToStr(MouseItem.S.MAC) + 'MP ';

          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
        end;
      1..3:
        begin
          if (MouseItem.S.StdMode = 3) and (MouseItem.S.Shape = 12) and (MouseItem.S.Name = '����') then
          begin
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
            line3 := MySelf.UserName + '������տ���';
          end
          else if MouseItem.S.OverlapItem = 1 then
            line1 := line1 + '����' + IntToStr(MouseItem.Dura div 10) + ' ����' + IntToStr(MouseItem.Dura)
          else if MouseItem.S.OverlapItem = 2 then
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight * MouseItem.Dura) + ' ����' + IntToStr(MouseItem.Dura)
          else
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
        end;
      4:
        begin
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
          useable := FALSE;
          case MouseItem.S.Shape of
            0:
              begin
                line2 := '��ʿ�ؼ�';
                line4 := '��Ҫ�ȼ�' + IntToStr(MouseItem.S.DuraMax);
                if (Myself.Job = 0) and (Myself.Abil.Level >= MouseItem.S.DuraMax) then
                  useable := TRUE;
              end;
            1:
              begin
                line2 := '��ʦ�ؼ�';
                line4 := '��Ҫ�ȼ�' + IntToStr(MouseItem.S.DuraMax);
                if (Myself.Job = 1) and (Myself.Abil.Level >= MouseItem.S.DuraMax) then
                  useable := TRUE;
              end;
            2:
              begin
                line2 := '��ʿ�ؼ�';
                line4 := '��Ҫ�ȼ�' + IntToStr(MouseItem.S.DuraMax);
                if (Myself.Job = 2) and (Myself.Abil.Level >= MouseItem.S.DuraMax) then
                  useable := TRUE;
              end;
          end;
        end;
      5..6: //����
        begin
          useable := FALSE;
          if MouseItem.S.ItemDesc and $01 <> 0 then  //�����������
            iname := '(*)' + iname;

          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' �־�' + GetDuraStr(MouseItem.Dura, MouseItem.DuraMax);
          if MouseItem.S.DC > 0 then
            line2 := '����' + IntToStr(Lobyte(MouseItem.S.DC)) + '-' + IntToStr(Hibyte(MouseItem.S.DC)) + ' ';
          if MouseItem.S.MC > 0 then
            line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MC)) + '-' + IntToStr(Hibyte(MouseItem.S.MC)) + ' ';
          if MouseItem.S.SC > 0 then
            line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.SC)) + '-' + IntToStr(Hibyte(MouseItem.S.SC)) + ' ';
          if MouseItem.S.SpecialPwr in [1..10] then  //������ ����
            line2 := line2 + 'ǿ��+' + IntToStr(MouseItem.S.SpecialPwr) + ' ';
          if (MouseItem.S.SpecialPwr <= -1) and (MouseItem.S.SpecialPwr >= -50) then
            line2 := line2 + '��ʥ+' + IntToStr(-MouseItem.S.SpecialPwr) + ' ';
          if (MouseItem.S.SpecialPwr <= -51) and (MouseItem.S.SpecialPwr >= -100) then
            line2 := line2 + '��ʥ-' + IntToStr((-MouseItem.S.SpecialPwr) - 50) + ' ';
          if Hibyte(MouseItem.S.AC) > 0 then
            line3 := line3 + '׼ȷ+' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
          if MouseItem.S.Slowdown > 0 then
            line3 := line3 + '�ٶ�+' + IntToStr(MouseItem.S.Slowdown) + ' '; //==Upgradeitem==
          if MouseItem.S.Tox > 0 then
            line3 := line3 + '�ж�+' + IntToStr(MouseItem.S.Tox) + ' '; //==Upgradeitem==
          if Hibyte(MouseItem.S.MAC) > 0 then
          begin
            if Hibyte(MouseItem.S.MAC) > 10 then
              line3 := line3 + '�����ٶ�+' + IntToStr(Hibyte(MouseItem.S.MAC) - 10) + ' '
            else
              line3 := line3 + '�����ٶ�-' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
          end;
          if (MouseItem.S.AC and $80) <> 0 then
          begin
            line3 := line3 + '���� ';
          end;
          if Lobyte(MouseItem.S.AC and $7F) > 0 then
            line3 := line3 + '����+' + IntToStr(Lobyte(MouseItem.S.AC and $7F)) + ' ';
          if Lobyte(MouseItem.S.MAC) > 0 then
            line3 := line3 + '����+' + IntToStr(Lobyte(MouseItem.S.MAC)) + ' ';
          case MouseItem.S.Need of
            0:
              begin
                if Myself.Abil.Level >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := line4 + '��Ҫ�ȼ�' + IntToStr(MouseItem.S.NeedLevel);
              end;
            1:
              begin
                if hibyte(Myself.Abil.DC) >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := line4 + '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
              end;
            2:
              begin
                if hibyte(Myself.Abil.MC) >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := line4 + '��Ҫħ����' + IntToStr(MouseItem.S.NeedLevel);
              end;
            3:
              begin
                if hibyte(Myself.Abil.SC) >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := line4 + '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
              end;
          end;
        end;
      7:
        begin //������
          if MouseItem.S.OverlapItem = 1 then
            line1 := line1 + '����' + IntToStr(MouseItem.Dura div 10) + ' ����' + IntToStr(MouseItem.Dura)
          else if MouseItem.S.OverlapItem = 2 then
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight * MouseItem.Dura) + ' ����' + IntToStr(MouseItem.Dura)
          else
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
          line2 := '��Ctrl��ѡ����Ʒ���а�';
        end;
      8:
        begin
          case MouseItem.S.Shape of
            0:
              begin //����
                line1 := line1 + '�л�����No.' + IntToStr(MouseItem.Dura) + ' ����' + IntToStr(MouseItem.S.Weight);
                line2 := '��Ч��Ϊ24Сʱ';
              end;
            1:
              begin //�������ƶ�����
                line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
                line2 := '�ð����� �ʿ��Ͽ� �ڽ��� �̲��� ����';
                line3 := '�������ϴ�.'
              end;
            2:       //��Ʒ�лƽ𼦵�
              line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
          end;
        end;
      9:
        begin //������
//               line1 := DecoItemDesc( MouseItem.Dura);
//               line1 := line1 + ' ����' +  IntToStr(MouseItem.S.Weight)
//                                        + ' �־�'+ IntToStr(Round(MouseItem.DuraMax/1000));
          line1 := '����' + IntToStr(MouseItem.S.Weight) + ' �־�' + IntToStr(Round(MouseItem.DuraMax / 1000));
//                                + ' �־�'+ IntToStr(Trunc(MouseItem.DuraMax/1000));
          line2 := DecoItemDesc(MouseItem.Dura, line3);
        end;
      10, 11:  //���·�, Ů�·�
        begin
          useable := FALSE;
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' �־�' + GetDuraStr(MouseItem.Dura, MouseItem.DuraMax);
               //line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) +
               //      ' �־�'+ IntToStr(Round(MouseItem.Dura/1000)) + '/' + IntToStr(Round(MouseItem.DuraMax/1000));
          if MouseItem.S.AC > 0 then
            line2 := '����' + IntToStr(Lobyte(MouseItem.S.AC)) + '-' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
          if MouseItem.S.MAC > 0 then
            line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MAC)) + '-' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
          if MouseItem.S.DC > 0 then
            line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.DC)) + '-' + IntToStr(Hibyte(MouseItem.S.DC)) + ' ';
          if MouseItem.S.MC > 0 then
            line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MC)) + '-' + IntToStr(Hibyte(MouseItem.S.MC)) + ' ';
          if MouseItem.S.Agility > 0 then
            line2 := line2 + '����+' + IntToStr(MouseItem.S.Agility) + ' '; // ==Upgradeitem==
          if MouseItem.S.SC > 0 then
            line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.SC)) + '-' + IntToStr(Hibyte(MouseItem.S.SC)) + ' ';

          if MouseItem.S.HpAdd > 0 then
            line3 := line3 + 'HP+' + IntToStr(MouseItem.S.HpAdd) + ' ';
          if MouseItem.S.MpAdd > 0 then
            line3 := line3 + 'MP+' + IntToStr(MouseItem.S.MpAdd) + ' ';
          if MouseItem.S.EffType1 = 3 then
            line3 := line3 + '����+' + IntToStr(MouseItem.S.EffValue1) + ' ';
          if MouseItem.S.MgAvoid > 0 then
            line3 := line3 + 'ħ������+' + IntToStr(MouseItem.S.MgAvoid) + ' '; //==Upgradeitem==
          if MouseItem.S.ToxAvoid > 0 then
            line3 := line3 + '�ж�����+' + IntToStr(MouseItem.S.ToxAvoid) + ' '; //==Upgradeitem==

          case MouseItem.S.EffType1 of
            5:
              begin
                line3 := line3 + '�����ָ�+' + IntToStr(MouseItem.S.EffRate1 * 10) + '% ';
                line3 := line3 + 'ħ���ָ�+' + IntToStr(MouseItem.S.EffValue1 * 10) + '% ';
              end;
          end;
          case MouseItem.S.EffType2 of
            5:
              begin
                line3 := line3 + '�����ָ�+' + IntToStr(MouseItem.S.EffRate2 * 10) + '% ';
                line3 := line3 + 'ħ���ָ�+' + IntToStr(MouseItem.S.EffValue2 * 10) + '% ';
              end;
          end;

          case MouseItem.S.Need of
            0:
              begin
                if Myself.Abil.Level >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := '��Ҫ�ȼ�' + IntToStr(MouseItem.S.NeedLevel);
              end;
            1:
              begin
                if hibyte(Myself.Abil.DC) >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
              end;
            2:
              begin
                if hibyte(Myself.Abil.MC) >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := '��Ҫħ����' + IntToStr(MouseItem.S.NeedLevel);
              end;
            3:
              begin
                if hibyte(Myself.Abil.SC) >= MouseItem.S.NeedLevel then
                  useable := TRUE;
                line4 := '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
              end;
          end;
        end;
      15,     //ͷ��
      19, 20, 21,  //����
      22, 23,  //��ָ
         // 2003/03/15 ������ �κ��丮 Ȯ��
      52, 53, 54, //���� Ь ��ʯ
      24, 26:  //����
        begin
          useable := FALSE;
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' ';
          if (MouseItem.S.StdMode <> 53) then
            line1 := line1 + '�־�' + GetDuraStr(MouseItem.Dura, MouseItem.DuraMax) + ' ';
               // 2003/08/25 ���� ������, �ż��Ӽ� ǳ�� ���� �߰�.  // AddHolyMent
          if MouseItem.S.StdMode = 15 then
          begin
            if (MouseItem.S.Accurate > 0) then
              line2 := line2 + '׼ȷ+' + IntToStr(MouseItem.S.Accurate) + ' '; // ==Upgradeitem==
            if MouseItem.S.MgAvoid > 0 then
              line3 := line3 + 'ħ������+' + IntToStr(MouseItem.S.MgAvoid) + ' '; //==Upgradeitem==
            if MouseItem.S.ToxAvoid > 0 then
              line3 := line3 + '�ж�����+' + IntToStr(MouseItem.S.ToxAvoid) + ' '; //==Upgradeitem==
          end;
          if MouseItem.S.StdMode = 26 then
          begin
            if (MouseItem.S.Accurate > 0) then
              line2 := line2 + '׼ȷ+' + IntToStr(MouseItem.S.Accurate) + ' '; // ==Upgradeitem==
            if MouseItem.S.Agility > 0 then
              line2 := line2 + '����+' + IntToStr(MouseItem.S.Agility) + ' '; // ==Upgradeitem==
          end;
          if (MouseItem.S.StdMode = 52) or (MouseItem.S.StdMode = 54) then
          begin
//                  if MouseItem.S.AC > 0 then
//                     line2 := '����' + IntToStr(Lobyte(MouseItem.S.AC)) + '-' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';// ==Upgradeitem==
//                  if MouseItem.S.MAC > 0 then
//                     line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MAC)) + '-' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';// ==Upgradeitem==
            if MouseItem.S.Agility > 0 then
              line2 := line2 + '����+' + IntToStr(MouseItem.S.Agility) + ' '; // ==Upgradeitem==
            if (MouseItem.S.Accurate > 0) then   //2004/01/08
              line2 := line2 + '׼ȷ+' + IntToStr(MouseItem.S.Accurate) + ' '; // ==Upgradeitem==

            if MouseItem.S.StdMode = 54 then
            begin
              if MouseItem.S.ToxAvoid > 0 then
                line3 := line3 + '�ж�����+' + IntToStr(MouseItem.S.ToxAvoid) + ' '; //==Upgradeitem==
            end;
          end;
          if (MouseItem.S.SpecialPwr <= -1) and (MouseItem.S.SpecialPwr >= -50) then
            line2 := line2 + '��ʥ+' + IntToStr(-MouseItem.S.SpecialPwr) + ' ';
          if (MouseItem.S.SpecialPwr <= -51) and (MouseItem.S.SpecialPwr >= -100) then
            line2 := line2 + '��ʥ-' + IntToStr((-MouseItem.S.SpecialPwr) - 50) + ' ';
               //-----------------

          if ((MouseItem.S.Shape = RING_OF_UNKNOWN) or (MouseItem.S.Shape = BRACELET_OF_UNKNOWN) or (MouseItem.S.Shape = HELMET_OF_UNKNOWN)) and (not bowear) then
          begin
            line2 := '????????';
          end
          else
          begin
            case MouseItem.S.StdMode of
              19: //����
                begin
                  if MouseItem.S.AtkSpd > 0 then
                    line2 := line2 + '�����ٶ�+' + IntToStr(MouseItem.S.AtkSpd) + ' ';
                  if (MouseItem.S.Accurate > 0) then
                    line2 := line2 + '׼ȷ+' + IntToStr(MouseItem.S.Accurate) + ' '; // ==Upgradeitem==
                  if MouseItem.S.Slowdown > 0 then
                    line2 := line2 + '�ٶ�+' + IntToStr(MouseItem.S.Slowdown) + ' '; //==Upgradeitem==
                  if MouseItem.S.Tox > 0 then
                    line2 := line2 + '�ж�+' + IntToStr(MouseItem.S.Tox) + ' '; //==Upgradeitem==
//                           if MouseItem.S.MgAvoid > 0 then
//                              line3 := line3 + '����+' + IntToStr(MouseItem.S.MgAvoid)+ ' '; //==Upgradeitem==
                  if MouseItem.S.AC > 0 then
                  begin
                   // line3 := line3 + 'ħ������+' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
                   line2 := line2 + 'ħ�����+' + IntToStr(Hibyte(MouseItem.S.AC)) + '0% ';
                  end;
                  if Lobyte(MouseItem.S.MAC) > 0 then
                    line2 := line2 + '����+' + IntToStr(Lobyte(MouseItem.S.MAC)) + ' ';
                  if Hibyte(MouseItem.S.MAC) > 0 then
                    line2 := line2 + '����+' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
                              //���� ǥ�þȵ� + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
                end;
              20:
                begin
                  if MouseItem.S.AC > 0 then
                    line2 := line2 + '׼ȷ+' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
                  if MouseItem.S.MAC > 0 then
                    line2 := line2 + '����+' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
                  if MouseItem.S.AtkSpd > 0 then
                    line2 := line2 + '�����ٶ�+' + IntToStr(MouseItem.S.AtkSpd) + ' ';
                  if MouseItem.S.Slowdown > 0 then
                    line2 := line2 + '�ٶ�+' + IntToStr(MouseItem.S.Slowdown) + ' '; //==Upgradeitem==
                  if MouseItem.S.Tox > 0 then
                    line2 := line2 + '�ж�+' + IntToStr(MouseItem.S.Tox) + ' '; //==Upgradeitem==
                  if MouseItem.S.MgAvoid > 0 then
                    line3 := line3 + 'ħ������+' + IntToStr(MouseItem.S.MgAvoid) + ' '; //==Upgradeitem==
                end;
              21:  //����
                begin
                  if Hibyte(MouseItem.S.AC) > 0 then
                    line2 := line2 + '�����ָ�+' + IntToStr(Hibyte(MouseItem.S.AC)) + '0% ';
                  if Hibyte(MouseItem.S.MAC) > 0 then
                    line2 := line2 + 'ħ���ָ�+' + IntToStr(Hibyte(MouseItem.S.MAC)) + '0% ';
                  if MouseItem.S.Accurate > 0 then
                    line2 := line2 + '׼ȷ+' + IntToStr(MouseItem.S.Accurate) + ' '; //==Upgradeitem==
                  if MouseItem.S.Slowdown > 0 then
                    line2 := line2 + '�ٶ�+' + IntToStr(MouseItem.S.Slowdown) + ' '; //==Upgradeitem==
                  if MouseItem.S.Tox > 0 then
                    line2 := line2 + '�ж�+' + IntToStr(MouseItem.S.Tox) + ' '; //==Upgradeitem==
//                           if MouseItem.S.AtkSpd > 0 then
//                              line3 := line3 + '�����ٶ�+' + IntToStr(MouseItem.S.AtkSpd ) + ' ';
                  if Lobyte(MouseItem.S.AC) + MouseItem.S.AtkSpd > 0 then
                    line3 := line3 + '�����ٶ�+' + IntToStr(Lobyte(MouseItem.S.AC) + MouseItem.S.AtkSpd) + ' ';
                  if Lobyte(MouseItem.S.MAC) > 0 then
                    line3 := line3 + '�����ٶ�-' + IntToStr(Lobyte(MouseItem.S.MAC)) + ' ';
                  if MouseItem.S.MgAvoid > 0 then
                    line3 := line3 + 'ħ������+' + IntToStr(MouseItem.S.MgAvoid) + ' '; //==Upgradeitem==
                end;
              22:
                begin
                  if MouseItem.S.AC > 0 then
                    line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.AC)) + '-' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
                  if MouseItem.S.MAC > 0 then
                    line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MAC)) + '-' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
                  if MouseItem.S.AtkSpd > 0 then
                    line2 := line2 + '�����ٶ�+' + IntToStr(MouseItem.S.AtkSpd) + ' ';
                  if MouseItem.S.Slowdown > 0 then
                    line2 := line2 + '�ٶ�+' + IntToStr(MouseItem.S.Slowdown) + ' '; //==Upgradeitem==
                  if MouseItem.S.Tox > 0 then
                    line2 := line2 + '�ж�+' + IntToStr(MouseItem.S.Tox) + ' '; //==Upgradeitem==
                end;
              23:  //��ָ
                begin
                  if MouseItem.S.Slowdown > 0 then
                    line2 := line2 + '�ٶ�+' + IntToStr(MouseItem.S.Slowdown) + ' '; //==Upgradeitem==
                  if MouseItem.S.Tox > 0 then
                    line2 := line2 + '�ж�+' + IntToStr(MouseItem.S.Tox) + ' '; //==Upgradeitem==
                  if Hibyte(MouseItem.S.AC) > 0 then
                    line2 := line2 + '�ж�����+' + IntToStr(Hibyte(MouseItem.S.AC)) + '0% ';
                  if Hibyte(MouseItem.S.MAC) > 0 then
                    line2 := line2 + '�ж��ָ�+' + IntToStr(Hibyte(MouseItem.S.MAC)) + '0% ';
//                           if MouseItem.S.AtkSpd > 0 then
//                              line3 := line3 + '�����ٶ�+' + IntToStr(MouseItem.S.AtkSpd ) + ' ';
                  if Lobyte(MouseItem.S.AC) + MouseItem.S.AtkSpd > 0 then
                    line3 := line3 + '�����ٶ�+' + IntToStr(Lobyte(MouseItem.S.AC) + MouseItem.S.AtkSpd) + ' ';
                  if Lobyte(MouseItem.S.MAC) > 0 then
                    line3 := line3 + '�����ٶ�-' + IntToStr(Lobyte(MouseItem.S.MAC)) + ' ';
                end;
              24: //����
                begin
                  if MouseItem.S.AC > 0 then
                    line2 := line2 + '׼ȷ+' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
                  if MouseItem.S.MAC > 0 then
                    line2 := line2 + '����+' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
{                           if (MouseItem.S.Accurate > 0) then
                              line2 := line2 + '׼ȷ+'+ IntToStr(MouseItem.S.Accurate)+ ' '; // ==Upgradeitem==
                           if MouseItem.S.Agility > 0 then
                              line2 := line2 + '����+' + IntToStr(MouseItem.S.Agility) + ' '; // ==Upgradeitem==}
                end;
            else
              begin
                if MouseItem.S.AC > 0 then
                  line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.AC)) + '-' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
                if MouseItem.S.MAC > 0 then
                  line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MAC)) + '-' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
              end;
            end;
            if MouseItem.S.DC > 0 then
              line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.DC)) + '-' + IntToStr(Hibyte(MouseItem.S.DC)) + ' ';
            if MouseItem.S.MC > 0 then
              line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MC)) + '-' + IntToStr(Hibyte(MouseItem.S.MC)) + ' ';
            if MouseItem.S.SC > 0 then
              line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.SC)) + '-' + IntToStr(Hibyte(MouseItem.S.SC)) + ' ';
                  // 2003/03/15 ������ �κ��丮 Ȯ��
            if MouseItem.S.HpAdd > 0 then
              line2 := line2 + 'HP+' + IntToStr(MouseItem.S.HpAdd) + ' ';
            if MouseItem.S.MpAdd > 0 then
            begin
              if MouseItem.S.StdMode = 26 then
                line3 := line3 + 'MP+' + IntToStr(MouseItem.S.MpAdd) + ' '
              else
                line2 := line2 + 'MP+' + IntToStr(MouseItem.S.MpAdd) + ' ';
            end;
            if MouseItem.S.ExpAdd > 0 then
              line2 := line2 + '���鱶��+' + IntToStr(MouseItem.S.ExpAdd) + ' ';
            case MouseItem.S.EffType1 of
              1:
                begin
                  line2 := line2 + '����+' + IntToStr(MouseItem.S.EffValue1) + ' ';
                end;
              2:
                begin
                  line2 := line2 + '������+' + IntToStr(MouseItem.S.EffValue1) + ' ';
                end;
              4:
                begin
                  line2 := line2 + '��������+' + IntToStr(MouseItem.S.EffValue1) + ' ';
                end;
//                     5: begin
//                           line2 := line2 + '�����ָ�+' + IntToStr(MouseItem.S.EffRate1) + '% ';
//                           line2 := line2 + 'ħ���ָ�+' + IntToStr(MouseItem.S.EffValue1) + '% ';
//                        end;

            end;
            case MouseItem.S.EffType2 of
              1:
                begin
                  line2 := line2 + '����+' + IntToStr(MouseItem.S.EffValue2) + ' ';
                end;
              2:
                begin
                  line2 := line2 + '������+' + IntToStr(MouseItem.S.EffValue2) + ' ';
                end;
              4:
                begin
                  line2 := line2 + '��������+' + IntToStr(MouseItem.S.EffValue2) + ' ';
                end;
//                     5: begin
//                           line2 := line2 + '�����ָ�+' + IntToStr(MouseItem.S.EffRate2) + '% ';
//                           line2 := line2 + 'ħ���ָ�+' + IntToStr(MouseItem.S.EffValue2) + '% ';
//                        end;
            end;

            case MouseItem.S.Need of
              0:
                begin
                  if Myself.Abil.Level >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫ�ȼ�' + IntToStr(MouseItem.S.NeedLevel);
                end;
              1:
                begin
                  if hibyte(Myself.Abil.DC) >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
                end;
              2:
                begin
                  if hibyte(Myself.Abil.MC) >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫħ����' + IntToStr(MouseItem.S.NeedLevel);
                end;
              3:
                begin
                  if hibyte(Myself.Abil.SC) >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
                end;
            end;
          end;
        end;
      25: //���������ҩ
        begin
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
          line2 := 'ʹ��' + GetDura100Str(MouseItem.Dura, MouseItem.DuraMax);
        end;
      30: //��,Ƚ��
        begin
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' �־�' + GetDuraStr(MouseItem.Dura, MouseItem.DuraMax);
//               if MouseItem.S.Shape = 2 then begin
          if MouseItem.S.AC > 0 then
            line2 := '����' + IntToStr(Lobyte(MouseItem.S.AC)) + '-' + IntToStr(Hibyte(MouseItem.S.AC)) + ' ';
          if MouseItem.S.MAC > 0 then
            line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MAC)) + '-' + IntToStr(Hibyte(MouseItem.S.MAC)) + ' ';
          if MouseItem.S.DC > 0 then
            line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.DC)) + '-' + IntToStr(Hibyte(MouseItem.S.DC)) + ' ';
          if MouseItem.S.MC > 0 then
            line2 := line2 + 'ħ��' + IntToStr(Lobyte(MouseItem.S.MC)) + '-' + IntToStr(Hibyte(MouseItem.S.MC)) + ' ';
          if MouseItem.S.SC > 0 then
            line2 := line2 + '����' + IntToStr(Lobyte(MouseItem.S.SC)) + '-' + IntToStr(Hibyte(MouseItem.S.SC)) + ' ';
//               end;
              case MouseItem.S.Need of
              0:
                begin
                  if Myself.Abil.Level >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫ�ȼ�' + IntToStr(MouseItem.S.NeedLevel);
                end;
              1:
                begin
                  if hibyte(Myself.Abil.DC) >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
                end;
              2:
                begin
                  if hibyte(Myself.Abil.MC) >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫħ����' + IntToStr(MouseItem.S.NeedLevel);
                end;
              3:
                begin
                  if hibyte(Myself.Abil.SC) >= MouseItem.S.NeedLevel then
                    useable := TRUE;
                  line4 := line4 + '��Ҫ������' + IntToStr(MouseItem.S.NeedLevel);
                end;
            end;
        end;
      40: //��
        begin
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' Ʒ��' + GetDuraStr(MouseItem.Dura, MouseItem.DuraMax);
        end;
      42: //ҩ��
        begin
          if MouseItem.S.OverlapItem = 1 then
            line1 := line1 + '����' + IntToStr(MouseItem.Dura div 10) + ' ����' + IntToStr(MouseItem.Dura) + ' �ɷ�'
          else if MouseItem.S.OverlapItem = 2 then
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight * MouseItem.Dura) + ' ����' + IntToStr(MouseItem.Dura) + ' �ɷ�'
          else
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' �ɷ�';
        end;
      43: //��ʯ
        begin
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight) + ' ����' + IntToStr(Round(MouseItem.Dura / 1000));
        end;
      44: //�ֿ�
        begin
          if MouseItem.S.Shape = 1 then
          begin
            if MouseItem.S.OverlapItem = 1 then
              line1 := line1 + '����' + IntToStr(MouseItem.Dura div 10) + ' ����' + IntToStr(MouseItem.Dura)
            else if MouseItem.S.OverlapItem = 2 then
              line1 := line1 + '����' + IntToStr(MouseItem.S.Weight * MouseItem.Dura) + ' ����' + IntToStr(MouseItem.Dura)// + ' �ֿ�'
            else
              line1 := line1 + '����' + IntToStr(MouseItem.S.Weight); // + ' �ֿ�';
          end
          else
          begin
            line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
          end;
        end;

      60, 61:
        begin
          if MouseItem.S.Shape in [20, 21] then
          begin
            if MouseItem.S.Shape = 20 then
            begin
              line2 := '��Ctrl����ѡ��������߽���ά��';
              line3 := '����Χ: �·���ͷ����Ƥ����Ь'
            end
            else if MouseItem.S.Shape = 21 then
            begin
              line2 := '����Ctrl��ѡ����߽���ά��';
              line3 := '����Χ: ��������ָ������';
            end;
          end
          else
            line2 := '����Ctrl��ѡ����Ʒ��ü�ǿ';

          case MouseItem.S.Shape of
            1:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ���ӹ�����';
                line3 := 'ǿ����Χ: ��������������ָ������'
              end;
            2:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ����ħ����';
                line3 := 'ǿ����Χ: ��������������ָ������'
              end;
            3:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ���Ӿ�����';
                line3 := 'ǿ����Χ: ��������������ָ������'
              end;
            4:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ���ӷ���';
                line3 := 'ǿ����Χ: ��ָ���������·���ͷ����������Ь��'
              end;
            5:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ����ħ��';
                line3 := 'ǿ����Χ: ��ָ���������·���ͷ����������Ь��';
              end;
            6:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' �������־�';
                line3 := 'ǿ����Χ: ����װ��';
              end;
            7:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ����׼ȷ';
                line3 := 'ǿ����Χ: ����������ͷ��������';
              end;
            8:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ��������';
                line3 := 'ǿ����Χ: ������װ��������Ь��';
              end;
            9:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ���ӹ����ٶ�';
                line3 := 'ǿ����Χ: ��������������ָ';
              end;
            10:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' �ٶ�+';
                line3 := 'ǿ����Χ: ��������������ָ';
              end;
            11:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' �ж�+';
                line3 := 'ǿ����Χ: ��������������ָ';
              end;
            12:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' ����ħ������';
                line3 := 'ǿ����Χ: �������·���ͷ��';
              end;
            13:
              begin
                line1 := '����' + IntToStr(MouseItem.S.Weight) + ' �����ж�����';
                line3 := 'ǿ����Χ: �·���ͷ��������';
              end;
          end;
        end;
      70:
        begin
          line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
          case MouseItem.S.Shape of
            67, 68, 69, 70, 71, 72, 73:begin
              line2 := 'ʹ�û��' + IntToStr(MouseItem.DuraMax) + 'Ԫ��';
            end;
          end;
          case MouseItem.S.Shape of
            77:begin
              line2 := 'ȫ��װ����������';
            end;
          end;
        end;
    else
      begin
        line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
      end;
    end;
    if MouseItem.S.Shape = 99 then
    begin
      if MouseItem.S.StdMode in [21, 22, 26, 53] then
      begin
        line1 := line1 + '����' + IntToStr(MouseItem.S.Weight);
        line2 := '�� ' + IntToStr(MouseItem.S.Undead);
      end;
    end;
  end;
end;

//�滭���ﱳ��
procedure TFrmDlg.DItemBagDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  iname, d0, d1, d2, d3: string;
  n: integer;
  useable: Boolean;
  d: TDXTexture;
  FColor: TColor;
begin
  if Myself = nil then
    exit;
  with DItemBag do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    GetMouseItemInfo(iname, d0, d1, d2, d3, useable, FALSE);
//      GetMouseItemInfo (d0, d1, d2, d3, useable, FALSE);
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clWhite;
//         TextOut (SurfaceX(Left+64), SurfaceY(Top+185), GetGoldStr(Myself.Gold));
      TextOut(SurfaceX(Left + 64), SurfaceY(Top + 185), GetGoldStr(Myself.Gold), clWhite);

      if iname <> '' then
      begin
//            Font.Color := clYellow;
//            TextOut (SurfaceX(Left+70), SurfaceY(Top+215), iname);
        TextOut(SurfaceX(Left + 70), SurfaceY(Top + 215), iname, clYellow);
        n := TextWidth(iname);

//            if MouseItem.UpgradeOpt > 0 then Font.Color := clAqua
//        if MouseItem.UpgradeOpt > 0 then     //��Ʒ��ɫ   �Լ�����
//          FColor := TColor($cccc33) //��Ʒ��ɫ   �Լ�����
//        else                        //��Ʒ��ɫ   �Լ�����
          FColor := clWhite;
//            TextOut (SurfaceX(Left+70) + n, SurfaceY(Top+215), d0);
//            TextOut (SurfaceX(Left+70), SurfaceY(Top+215+14), d1);
//            TextOut (SurfaceX(Left+70), SurfaceY(Top+215+14*2), d2);

        TextOut(SurfaceX(Left + 70) + n, SurfaceY(Top + 215), d0, FColor);
        TextOut(SurfaceX(Left + 70), SurfaceY(Top + 215 + 14), d1, FColor);
        TextOut(SurfaceX(Left + 70), SurfaceY(Top + 215 + 14 * 2), d2, FColor);
        if not useable then
          FColor := clRed;
        n := TextWidth(d2);
//            TextOut (SurfaceX(Left+70) + n, SurfaceY(Top+215+14*2), d3);
        TextOut(SurfaceX(Left + 70) + n, SurfaceY(Top + 215 + 14 * 2), d3, FColor);
      end;
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DRepairItemInRealArea(Sender: TObject; X, Y: Integer; var IsRealArea: Boolean);
begin
{   if (X >= 0) and (Y >= 0) and (X <= DRepairItem.Width) and
      (Y <= DRepairItem.Height) then
         IsRealArea := TRUE
   else IsRealArea := FALSE;}
end;

procedure TFrmDlg.DRepairItemDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DRepairItem do
  begin
    d := WLib.Images[FaceIndex];
    if DRepairItem.Downed and (d <> nil) then
      dsurface.Draw(SurfaceX(254), SurfaceY(183), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DCloseBagDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DCloseBag do
  begin
    if DCloseBag.Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DCloseBagClick(Sender: TObject; X, Y: Integer);
begin
  DItemBag.Visible := FALSE;
end;

procedure TFrmDlg.DItemGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  idx: integer;
  temp: TClientItem;
  iname, d1, d2, d3: string;
  useable: Boolean;
  hcolor: TColor;
begin

//   if ssRight in Shift then begin
//      if ItemMoving then
//         DItemGridGridSelect (self, ACol, ARow, Shift);
//   end else begin
  idx := ACol + ARow * DItemGrid.ColCount + 6{��Ʈ����};

  if idx in [6..MAXBAGITEM - 1] then
  begin
    MouseItem := ItemArr[idx];
         {GetMouseItemInfo (iname, d1, d2, d3, d4, useable);
         if iname <> '' then begin
            if useable then hcolor := clWhite
            else hcolor := clRed;
            with DItemGrid do
               DScreen.ShowHint (SurfaceX(Left + ACol*ColWidth),
                                 SurfaceY(Top + (ARow+1)*RowHeight),
                                 iname + d1 + '\' + d2 + d3, hcolor, FALSE);
         end;
         MouseItem.S.Name := '';}
  end;
//   end;
end;

procedure TFrmDlg.DItemGridGridSelect(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  idx, mi, n: integer;
  temp: TClientItem;
  bCheck: Boolean;
begin
  bCheck := False;
  idx := ACol + ARow * DItemGrid.ColCount + 6{��Ʈ����};

  if (not ItemMoving) and (ItemArr[idx].s.Name <> '') then
  begin
    if ssRight in Shift then
    begin
      if (EatTime + 300 < GetTickCount) and (ItemArr[idx].s.StdMode < 4) then
      begin
        if (ItemArr[idx].s.StdMode = 3) and (ItemArr[idx].s.Shape in [1, 2, 3, 4, 5, 6, 9, 10, 11]) then

        else
        begin
          FrmMain.EatItem(idx);
          Exit;
        end
      end;
    end;
  end;

  if idx in [6..MAXBAGITEM - 1] then
  begin
    if not ItemMoving then
    begin
      if ItemArr[idx].s.Name <> '' then
      begin
        ItemMoving := TRUE;
        MovingItem.Index := idx;
        MovingItem.Item := ItemArr[idx];
        ItemArr[idx].s.Name := '';
        ItemClickSound(ItemArr[idx].s);
      end;
    end
    else
    begin
         //��Ʒ�����ƶ�
         //ItemClickSound (MovingItem.Item.S.StdMode);
      mi := MovingItem.Index;
      if (DMakeItemDlg.Visible) or (DDealDlg.Visible) then
      begin  // 2004/02/23 ��Ʒ�����������������е���Ʒ�ƶ����κ��޸�
        if (mi >= 0) and (mi < 6) then
        begin
          CancelItemMoving;
          if DMakeItemDlg.Visible then
            DMessageDlg('�������������,\չƷ�����Դ�һ��ת�Ƶ�����ǰ������.', [mbOk])
          else if DDealDlg.Visible then
            DMessageDlg('�ڽ�����Ŀ,\չƷ�����Դ�һ��ת�Ƶ�����ǰ������.', [mbOk]);
          Exit;
        end;
      end;
      if (mi = -97) or (mi = -98) then
        exit; //��...
         // 2003/03/15 ������ �κ��丮 Ȯ��
      if (mi < 0) and (mi >= -13) then
      begin  //-99: Sell������....-9->-13
            //״̬������
        WaitingUseItem := MovingItem;
        FrmMain.SendTakeOffItem(-(MovingItem.Index + 1), MovingItem.Item.MakeIndex, MovingItem.Item.S.Name);
        MovingItem.Item.S.name := '';
        ItemMoving := FALSE;
      end
      else
      begin
        if (mi <= -20) and (mi > -30) then
        begin //����������
          DealItemReturnBag(MovingItem.Item); //send only
               //2004/01/06 ��Ʒ�������� ������ --------
          if MovingItem.Item.S.OverlapItem > 0 then
          begin
            MovingItem.Item.S.name := '';
            ItemMoving := FALSE;
            Exit;
          end; //--------------------------------------------
        end;
        if ItemArr[idx].s.Name <> '' then
        begin

          if ssCtrl in Shift then
          begin //####
            if (MovingItem.Item.S.StdMode in [60, 61]) and (not ((MovingItem.Item.S.StdMode = 61) and (MovingItem.Item.S.Shape in [20, 21]))) then
            begin
              if mrOk = DMessageDlg(ItemArr[idx].s.Name + ' ʹ�� ' + MovingItem.Item.S.Name + ' ��������?', [mbOk, mbCancel]) then
                bCheck := True
              else
              begin
                CancelItemMoving;
                Exit;
              end;
            end
            else
              bCheck := True;
          end;

          if bCheck then
          begin
//               if ssCtrl in Shift then begin
            UpItemItem := ItemArr[idx];
            FrmMain.UpGradeItem(ItemArr[idx].MakeIndex, MovingItem.Item.MakeIndex, ItemArr[idx].s.Name, MovingItem.Item.S.Name);
            if AddItemBag(MovingItem.Item) then
            begin
              MovingItem.Item.S.name := '';
              ItemMoving := FALSE;
            end;
          end
          else
          begin
            if (ItemArr[idx].s.OverlapItem > 0) and (ItemArr[idx].s.Name = MovingItem.Item.S.Name) and (not DMakeItemDlg.Visible) then
            begin

              FrmMain.SendItemSumCount(ItemArr[idx].MakeIndex, MovingItem.Item.MakeIndex, ItemArr[idx].s.Name, MovingItem.Item.S.Name);

                     //2004/01/06 ������ ���� ���� ������ �ٲ� -----------
              if (mi > 0) and (mi < 100) then
                CancelItemMoving
              else
              begin
                MovingItem.Item.S.Name := '';
                ItemMoving := FALSE;
              end; //-----------------------------------------------
            end
            else
            begin
              temp := ItemArr[idx];
              ItemArr[idx] := MovingItem.Item;
              MovingItem.Index := idx;
              MovingItem.Item := temp
            end;
          end;
        end
        else
        begin
          ItemArr[idx] := MovingItem.Item;
          MovingItem.Item.S.name := '';
          ItemMoving := FALSE;
        end;
      end;
    end;
  end;
  ArrangeItemBag;
end;
//װ������Ч��

procedure TFrmDlg.DItemGridDblClick(Sender: TObject);
var
  idx, i, where: integer;
  keyvalue: TKeyBoardState;
  cu: TClientItem;
  TempSender: TObject;
begin
  idx := DItemGrid.Col + DItemGrid.Row * DItemGrid.ColCount + 6;
  if idx in [6..MAXBAGITEM - 1] then
  begin
    if ItemArr[idx].s.Name <> '' then
    begin
         {FillChar(keyvalue, sizeof(TKeyboardState), #0);
         GetKeyboardState (keyvalue);
         if keyvalue[VK_CONTROL] = $80 then begin
            //�Ƶ����������, ���ҵ����ʵ�λ��
            cu := ItemArr[idx];
            ItemArr[idx].S.Name := '';
            AddItemBag (cu);
         end else
            if (ItemArr[idx].S.StdMode <= 4) or (ItemArr[idx].S.StdMode = 31) then begin //��ʹ�õĵ���
               FrmMain.EatItem (idx);
            end; }
    end
    else
    begin
      if ItemMoving and (MovingItem.Item.S.Name <> '') then
      begin
        FillChar(keyvalue, sizeof(TKeyboardState), #0);
        GetKeyboardState(keyvalue);
        if keyvalue[VK_CONTROL] = $80 then
        begin
               //��Ʈâ���� �ű�
          cu := MovingItem.Item;
          MovingItem.Item.S.Name := '';
          ItemMoving := FALSE;
          AddItemBag(cu);
        end
        else if (MovingItem.Index = idx) and (MovingItem.Item.S.StdMode <= 4) or (ItemArr[idx].s.StdMode in [7, 8, 31,70]) then
        begin
          FrmMain.EatItem(-1);
        end
                   //˫����Ʒ 2006/03/22----------------------------------------
        else
        begin
          where := GetTakeOnPosition(MovingItem.Item.S.StdMode);

          if MovingItem.Index >= 0 then
          begin
            case where of
              U_DRESS:
                TempSender := DSWDress;
              U_WEAPON:
                TempSender := DSWWEAPON;
              U_NECKLACE:
                TempSender := DSWNecklace;
              U_RIGHTHAND:
                TempSender := DSWLight;
              U_HELMET:
                TempSender := DSWHelmet;
              U_RINGL:
                begin
                  if (UseItems[U_RINGR].s.Name<>'')  and         //˫�������ָ
                     (UseItems[U_RINGL].s.Name<>'') then
                     begin
                       if g_boRightItemRingEmpty then
                          TempSender := DSWRingR
                          else
                          TempSender := DSWRingL;
                       g_boRightItemRingEmpty:=not g_boRightItemRingEmpty;
                     end
                     else
                     begin
                          if UseItems[U_RINGR].s.Name = '' then
                            TempSender := DSWRingR
                          else
                            TempSender := DSWRingL;
                     end;
                end;
              U_ARMRINGR:
                begin
                  if (UseItems[U_ARMRINGR].s.Name<>'')  and         //˫���������
                     (UseItems[U_ARMRINGL].s.Name<>'') then
                     begin
                       if g_boRightItemArmRingEmpty then
                          TempSender := DSWArmRingR
                          else
                          TempSender := DSWArmRingL;
                       g_boRightItemArmRingEmpty:=not g_boRightItemArmRingEmpty;
                     end
                     else
                     begin
                          if UseItems[U_ARMRINGR].s.Name = '' then
                            TempSender := DSWArmRingR
                          else
                            TempSender := DSWArmRingL;
                     end;
                end;
              U_BUJUK:
                begin
                    TempSender := DSWArmRingL   //˫��������������
                  //˫���������ĸ���������
//                  case MovingItem.Item.S.Shape of
//                      1,2,5 : TempSender := DSWBujuk;
//                  else
//                     TempSender := DSWArmRingL;
//                  end;
                end;
              U_BELT:
                TempSender := DSWBelt;
              U_BOOTS:
                TempSender := DSWBoots;
              U_CHARM:
                TempSender := DSWCharm;
            end;
          end;
          DSWWeaponClick(TempSender, 1, 1);
        end;
      end;
    end;
  end;
end;

procedure TFrmDlg.UpgradeItemEffect(wResult: word);
begin
  UpItemOffset := UPITEMSUCCESSOFFSET;
  UpItemMaxFrame := 8;

  BoUpItemEffect := TRUE;
  CurUpItemEffect := 0;
end;

procedure TFrmDlg.DItemGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
var
  d: TDXTexture;
  idx, ax, ay: integer;
begin
  idx := ACol + ARow * DItemGrid.ColCount + 6;
  if idx in [6..MAXBAGITEM - 1] then
  begin
    if ItemArr[idx].s.Name <> '' then
    begin
      d := WBagItem.Images[ItemArr[idx].s.Looks];
      if (ItemArr[idx].s.OverlapItem < 1) or ((ItemArr[idx].s.OverlapItem > 0) and (ItemArr[idx].dura > 0)) then
      begin
        if d <> nil then
          with DItemGrid do
            dsurface.Draw(SurfaceX(Rect.Left + (ColWidth - d.Width) div 2 - 1), SurfaceY(Rect.Top + (RowHeight - d.Height) div 2 + 1), d.ClientRect, d, TRUE);

            // ������ ��ġ��
        if ItemArr[idx].s.OverlapItem > 0 then
        begin
               //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//               g_DXCanvas.Font.Color := clYellow;

          g_DXCanvas.TextOut(DItemGrid.SurfaceX(Rect.Left + 20), DItemGrid.SurfaceY(Rect.Top + 20), IntToStr(ItemArr[idx].dura), clYellow);
//               g_DXCanvas.//Release;
        end;
      end;

    end;
  end;

  if BoUpItemEffect then
  begin  // ������ ���׷��̵� ȿ��
    if GetTickCount - upeffecttime > 120 then
    begin
      upeffecttime := GetTickCount;
      Inc(CurUpItemEffect);
      if CurUpItemEffect >= UpItemMaxFrame then
      begin
        FrmMain.DelitemProg;
        BoUpItemEffect := FALSE;
        UpItemItem.S.Name := '';
      end;
    end;
  end;

  if BoUpItemEffect then
  begin

    d := WMagic2.GetCachedImage(UpItemOffset + CurUpItemEffect, ax, ay);

    if d <> nil then
      if idx in [6..MAXBAGITEM - 1] then
        if (UpItemItem.MakeIndex = ItemArr[idx].MakeIndex) and (Trim(UpItemItem.S.Name) = Trim(ItemArr[idx].s.Name)) then
          DrawBlend(dsurface, DItemGrid.SurfaceX(Rect.Left) - 9 + ax, DItemGrid.SurfaceY(Rect.Top) + 41 + ay, d, 1);
  end;
end;

procedure TFrmDlg.DGoldClick(Sender: TObject; X, Y: Integer);
begin
  if Myself = nil then
    exit;
  if not ItemMoving then
  begin
    if Myself.Gold > 0 then
    begin
      PlaySound(s_money);
      ItemMoving := TRUE;
      MovingItem.Index := -98; //��
      MovingItem.Item.S.Name := '���';
    end;
  end
  else
  begin
    if (MovingItem.Index = -97) or (MovingItem.Index = -98) then
    begin //����..
      ItemMoving := FALSE;
      MovingItem.Item.S.Name := '';
      if MovingItem.Index = -97 then
      begin //������������
        DealZeroGold;
      end;
    end;
  end;
  ;
end;






{------------------------------------------------------------------------}

//���˶Ի�����

{------------------------------------------------------------------------}

procedure TFrmDlg.ShowMDlg(face: integer; mname, msgstr: string);
var
  i: integer;
begin
  DMerchantDlg.Left := 0;  //Ĭ��λ��
  DMerchantDlg.Top := 0;
  MerchantFace := face;
  MerchantName := mname;
  MDlgStr := msgstr;
  DMerchantDlg.Visible := TRUE;
  DItemBag.Left := 440;  //����ƫ��
  DItemBag.Top := 0;
  for i := 0 to MDlgPoints.Count - 1 do
    Dispose(PTClickPoint(MDlgPoints[i]));
  MDlgPoints.Clear;
  RequireAddPoints := TRUE;
  LastestClickTime := GetTickCount;
end;

procedure TFrmDlg.RefuseCRYClick(Sender: TObject; X, Y: Integer);
begin
   if g_RefuseCRY then begin
    g_RefuseCRY := false;
    FrmMain.SendSay('@�ܾ�����');
  end
  else begin
    g_RefuseCRY := true;
    FrmMain.SendSay('@�ܾ�����');
  end;
end;

procedure TFrmDlg.RefuseguildClick(Sender: TObject; X, Y: Integer);
begin
  if g_Refuseguild then begin
    g_Refuseguild := false;
    FrmMain.SendSay('@�ܾ��л�����');
  end
  else begin
    g_Refuseguild := true;
    FrmMain.SendSay('@�ܾ��л�����');
  end;
end;

procedure TFrmDlg.RefusePublicChatClick(Sender: TObject; X, Y: Integer);
begin
  if g_boOwnerMsg then begin
    g_boOwnerMsg := false;
    DScreen.AddChatBoardString('������չ�����Ϣ', GetRGB(219), clWhite);
  end
  else begin
    g_boOwnerMsg := true;
    DScreen.AddChatBoardString('�ܾ����չ�����Ϣ', GetRGB(219), clWhite);
  end;
end;

procedure TFrmDlg.RefusePublicChatDirectPaint(Sender: TObject;
  dsurface: TDXTexture);
var
  d: TDXTexture;
  boClick: Boolean;
begin
  boClick := False;
  if Sender = RefuseCRY then begin
    boClick := not g_RefuseCRY;
  end else
  if Sender = RefuseWHISPER then begin
    boClick := not g_RefuseWHISPER;
  end else
  if Sender = Refuseguild then begin
    boClick := not g_Refuseguild;
  end else
  if Sender = AutoCRY then begin
    boClick := not g_boAutoTalk;
  end else
  if Sender = RefusePublicChat then begin
    boClick := g_boOwnerMsg;
  end;
  with Sender as TDButton do begin
    if WLib <> nil then begin
      d := WLib.Images[FaceIndex + Integer(boClick)];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, True);
    end;
  end;
end;

procedure TFrmDlg.RefusePublicChatMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  nLocalY:Integer;
  nHintX,nHintY:Integer;
  Butt:TDButton;
  sMsg:String;
  Int: Integer;
begin
  if MySelf = nil then Exit;
  Butt:=TDButton(Sender);
  if Sender = RefusePublicChat then sMsg:= '�ܾ����й�����Ϣ';
  if Sender = RefuseCRY then sMsg:= '�ܾ����к�����Ϣ';
  if Sender = RefuseWHISPER then sMsg:= '�ܾ�����˽����Ϣ';
  if Sender = Refuseguild then sMsg:= '�ܾ��л�������Ϣ';
  if Sender = AutoCRY then sMsg:= '�Զ���������';

  if pos('\',sMsg) > 0 then
    nLocalY := 12
  else nLocalY := 0;

  with Butt as TDButton do
    DScreen.ShowHint(Butt.SurfaceX(Butt.Left), Butt.SurfaceY(Butt.Top - 20 -nLocalY ), sMsg, clWhite, FALSE); //clWhite
end;

procedure TFrmDlg.RefuseWHISPERClick(Sender: TObject; X, Y: Integer);
begin
  if g_RefuseWHISPER then begin
    g_RefuseWHISPER := false;
    FrmMain.SendSay('@�ܾ�˽��');
  end
  else begin
    g_RefuseWHISPER := true;
    FrmMain.SendSay('@�ܾ�˽��');
  end;
end;

procedure TFrmDlg.ResetMenuDlg;
var
  i: integer;
begin
  CloseDSellDlg;
  for i := 0 to MenuItemList.Count - 1 do  //�˵�Ҳ������ϸ��
    Dispose(PTClientItem(MenuItemList[i]));
  MenuItemList.Clear;

  for i := 0 to MenuList.Count - 1 do
    Dispose(PTClientGoods(MenuList[i]));
  MenuList.Clear;

  for i := 0 to JangwonList.Count - 1 do
    Dispose(PTClientJangwon(JangwonList[i]));
  JangwonList.Clear;

  for i := 0 to GABoardList.Count - 1 do
    Dispose(PTClientGABoard(GABoardList[i]));
  GABoardList.Clear;

   //CurDetailItem := '';
  MenuIndex := -1;
  MenuTopLine := 0;
  BoDetailMenu := FALSE;
  BoStorageMenu := FALSE;
  BoMakeDrugMenu := FALSE;
  BoMakeItemMenu := FALSE;
  NameMakeItem := '';

  DSellDlg.Visible := FALSE;
  DMenuDlg.Visible := FALSE;
end;

procedure TFrmDlg.ShowShopMenuDlg;
begin
  MenuIndex := -1;

  DMerchantDlg.Left := 0;  //Ĭ��λ��
  DMerchantDlg.Top := 0;
  DMerchantDlg.Visible := TRUE;

  DSellDlg.Visible := FALSE;

  DMenuDlg.Left := 0;
  DMenuDlg.Top := 176;
  DMenuDlg.Visible := TRUE;
  MenuTop := 0;

  DItemBag.Left := 440;
  DItemBag.Top := 0;
  DItemBag.Visible := TRUE;

  LastestClickTime := GetTickCount;
end;

procedure TFrmDlg.ShowItemMarketDlg; //2004/01/15 ItemMarket..
var
  i: integer;
begin

  DSellDlg.Visible := FALSE;
  BoInRect := False;

  if not DItemBag.Visible then
  begin
    DItemBag.Left := 440;
    DItemBag.Top := 0;
    DItemBag.Visible := TRUE;
  end;
  if not DItemMarketDlg.Visible then
  begin
    DItemMarketDlg.Left := 0; //10;
    DItemMarketDlg.Top := 90; //20;
    DItemMarketDlg.Visible := TRUE;
  end;

  if g_Market.GetFirst = 1 then
  begin
    MenuTop := 0;
    MenuIndex := -1;
  end;

//   HideAllControls;
//   DItemMarketDlg.ShowModal;
  DItemMarketDlg.Show;

  with ItemSearchEdit do
  begin
    Text := '';
    Width := 132;
    Left := DItemMarketDlg.Left + 13;
    Top := DItemMarketDlg.Top + 328;
  end;

  if g_Market.GetUserMode = 1 then
  begin
    DItemBuy.Visible := True;
    DItemSellCancel.Visible := False;
    DItemFind.Visible := True;
    DItemMarketDlg.KeyFocus := True;
    ItemSearchEdit.Visible := TRUE;
    ItemSearchEdit.SetFocus;
    DlgEditText := ItemSearchEdit.Text;
  end
  else if g_Market.GetUserMode = 2 then
  begin
    DItemBuy.Visible := False;
    DItemSellCancel.Visible := True;
    DItemFind.Visible := False;
    ItemSearchEdit.Visible := False;
  end;
  DItemCancel.Visible := True;

  SetImeMode(PlayScene.EdChat.Handle, imSHanguel); //@@@@
//   RestoreHideControls;
  if PlayScene.EdChat.Visible then
    PlayScene.EdChat.SetFocus;

  LastestClickTime := GetTickCount;

end;

procedure TFrmDlg.ShowJangwonDlg; //2004/01/15 ItemMarket..
var
  i: integer;
begin

  BoMemoJangwon := False;
  DSellDlg.Visible := FALSE;

  if not DJangwonListDlg.Visible then
  begin
    DJangwonListDlg.Left := 0; //10;
    DJangwonListDlg.Top := 175; //20;
    DJangwonListDlg.Visible := TRUE;
  end;

  MenuIndex := -1;
  DJangwonListDlg.Show;
  LastestClickTime := GetTickCount;

end;

procedure TFrmDlg.ShowGADecorateDlg; //2004/06/18 ׯ԰װ��
var
  i: integer;
begin

  if not DItemBag.Visible then
  begin
    DItemBag.Left := 440;
    DItemBag.Top := 0;
//      DItemBag.Visible := TRUE;
  end;
  if not DGADecorateDlg.Visible then
  begin
    DGADecorateDlg.Left := 0; //10;
    DGADecorateDlg.Top := 55; //90;//20;
    DGADecorateDlg.Visible := TRUE;
  end;

  MenuTop := 0;
  MenuIndex := 0;

  DGADecorateDlg.Show;
  LastestClickTime := GetTickCount;

end;

procedure TFrmDlg.ShowGABoardListDlg;
var
  i: integer;
begin

//   BoMemoJangwon := False;
  DSellDlg.Visible := FALSE;
  GABoard_BoWrite := 0;
  GABoard_BoNotice := 1;

  if not DGABoardListDlg.Visible then
  begin
    DGABoardListDlg.Left := 0; //10;
    DGABoardListDlg.Top := 175; //20;
    DGABoardListDlg.Visible := TRUE;
  end;

  MenuIndex := -1;
  DGABoardListDlg.Show;
  LastestClickTime := GetTickCount;

end;

procedure TFrmDlg.ShowGABoardReadDlg;
var
  d: TDXTexture;
  i: integer;
  data: string;
begin
  with DGABoardDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
    begin
      Left := 240;
      Top := 175;
    end;

    DGABoardDlg.ShowModal;
    if (GABoard_BoReply = 1) or (GABoard_BoWrite = 1) then
    begin
      DGABoardReply.Visible := False;
      DGABoardDel.Visible := False;
      DGABoardMemo.Visible := False;
    end
    else
    begin
      DGABoardReply.Visible := True;
      DGABoardDel.Visible := True;
      DGABoardMemo.Visible := True;
    end;
    DGABoardOk2.Visible := True;

    if Memo.ReadOnly then
    begin
      DGABoardDel.Visible := False;
    end;

    Memo.Left := SurfaceX(Left + 11);
    Memo.Top := SurfaceY(Top + 37);
    Memo.Width := d.Width - 22;
    Memo.Height := 142;
    Memo.Lines.Assign(GABoard_Notice);
    Memo.Visible := TRUE;
  end;

end;

procedure TFrmDlg.CloseItemMarketDlg;
begin
  DItemMarketCloseClick(DItemMarketClose, 0, 0);
end;

procedure TFrmDlg.ShowShopSellDlg;
begin
  SellStHold := False;
  DSellDlg.Left := 260;
  DSellDlg.Top := 176;
  DSellDlg.Visible := TRUE;

  DMenuDlg.Visible := FALSE;

  DItemBag.Left := 440;
  DItemBag.Top := 0;
  DItemBag.Visible := TRUE;

  LastestClickTime := GetTickCount;
  SellPriceStr := '';
end;

procedure TFrmDlg.CloseMDlg;
var
  i: integer;
begin
  MDlgStr := '';
  DMerchantDlg.Visible := FALSE;
  for i := 0 to MDlgPoints.Count - 1 do
    Dispose(PTClickPoint(MDlgPoints[i]));
  MDlgPoints.Clear;
   //�����رղ˵�
  DItemBag.Left := 0;  //@@@@
  DItemBag.Top := 0;
  DMenuDlg.Visible := FALSE;
  CloseDSellDlg;
end;

procedure TFrmDlg.CloseMDlg2;
var
  i: integer;
begin
  MDlgStr := '';
  DMerchantDlg.Visible := FALSE;
  for i := 0 to MDlgPoints.Count - 1 do
    Dispose(PTClickPoint(MDlgPoints[i]));
  MDlgPoints.Clear;

  DMenuDlg.Visible := FALSE;
  CloseDSellDlg;
end;

procedure TFrmDlg.CloseDSellDlg;
begin
  DSellDlg.Visible := FALSE;
  if SellDlgItem.S.Name <> '' then
    AddItemBag(SellDlgItem);
  SellDlgItem.S.Name := '';
end;

//NPC�ű�����{����}��ʾλ��

procedure TFrmDlg.DMerchantDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  str, data, fdata, cmdstr, cmdmsg, cmdparam: string;
  lx, ly, sx: integer;
  drawcenter: Boolean;
  pcp: PTClickPoint;
begin
  with Sender as TDWindow do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT); //����͸��
    lx := 30;
    ly := 20;
    str := MDlgStr;
    drawcenter := FALSE;
    while TRUE do
    begin
      if str = '' then
        break;
      str := GetValidStr3(str, data, [char($a)]);
      if data <> '' then
      begin
        sx := 0;
        fdata := '';
        while (pos('<', data) > 0) and (pos('>', data) > 0) and (data <> '') do
        begin
          if data[1] <> '<' then
          begin
            data := '<' + GetValidStr3(data, fdata, ['<']);
          end;
          data := ArrestStringEx(data, '<', '>', cmdstr);

               //fdata + cmdstr + data
          if cmdstr <> '' then
          begin
            if Uppercase(cmdstr) = 'C' then
            begin
              drawcenter := TRUE;
              continue;
            end;
            if UpperCase(cmdstr) = '/C' then
            begin
              drawcenter := FALSE;
              continue;
            end;
            cmdparam := GetValidStr3(cmdstr, cmdstr, ['/']); //cmdparam : �������
          end
          else
          begin
            DMenuDlg.Visible := FALSE;
            DSellDlg.Visible := FALSE;
          end;

          if fdata <> '' then
          begin
            g_DXCanvas.TextOut(SurfaceX(Left + lx + sx), SurfaceY(Top + ly), fdata, clWhite {clBlack} );
            sx := sx + g_DXCanvas.TextWidth(fdata);
          end;
          if cmdstr <> '' then
          begin
            if RequireAddPoints then
            begin //�ѹ���...
              new(pcp);
              pcp.rc := Rect(lx + sx, ly, lx + sx + g_DXCanvas.TextWidth(cmdstr), ly + 14);
              pcp.RStr := cmdparam;
              MDlgPoints.Add(pcp);
            end;
            if SelectMenuStr = cmdparam then
            begin
              g_DXCanvas.TextOut(SurfaceX(Left + lx + sx), SurfaceY(Top + ly), cmdstr, clRed);
              g_DXCanvas.MoveTo(SurfaceX(Left + lx + sx), SurfaceY(Top + ly) + g_DXCanvas.TextHeight(cmdstr) + 2);
              g_DXCanvas.LineTo(SurfaceX(Left + lx + sx) + g_DXCanvas.TextWidth(cmdstr) - 1, SurfaceY(Top + ly) + g_DXCanvas.TextHeight(cmdstr) + 2, clRed);
            end
            else
            begin
              g_DXCanvas.TextOut(SurfaceX(Left + lx + sx), SurfaceY(Top + ly), cmdstr, clYellow);
              g_DXCanvas.MoveTo(SurfaceX(Left + lx + sx), SurfaceY(Top + ly) + g_DXCanvas.TextHeight(cmdstr) + 2);
              g_DXCanvas.LineTo(SurfaceX(Left + lx + sx) + g_DXCanvas.TextWidth(cmdstr) - 1, SurfaceY(Top + ly) + g_DXCanvas.TextHeight(cmdstr) + 2, clYellow);
            end;

            sx := sx + g_DXCanvas.TextWidth(cmdstr);
//                  g_DXCanvas.Font.Style := g_DXCanvas.Font.Style - [fsUnderline];
          end;
        end;
        if data <> '' then
          g_DXCanvas.TextOut(SurfaceX(Left + lx + sx), SurfaceY(Top + ly), data, clWhite {clBlack});
      end;
      ly := ly + 16;
    end;
//      g_DXCanvas.//Release;
    RequireAddPoints := FALSE;
  end;

end;

procedure TFrmDlg.DMerchantDlgCloseClick(Sender: TObject; X, Y: Integer);
begin
  CloseMDlg;
end;

procedure TFrmDlg.DMenuDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);

  function sx(x: integer): integer;
  begin
    Result := DMenuDlg.SurfaceX(DMenuDlg.Left + x);
  end;

  function sy(y: integer): integer;
  begin
    Result := DMenuDlg.SurfaceY(DMenuDlg.Top + y);
  end;

var
  i, lh, k, m, menuline: integer;
  d: TDXTexture;
  pg: PTClientGoods;
  str: string;
  FColor: TColor;
begin
  with g_DXCanvas do
  begin
    with DMenuDlg do
    begin
      d := DMenuDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      //SetBkMode (Handle, TRANSPARENT);
      //title
    FColor := clWhite;
    if not BoStorageMenu then
    begin
      TextOut(sx(19), sy(11), '��Ʒ�б�', FColor);
      TextOut(sx(156), sy(11), '�۸�', FColor);
      if not BoMakeItemMenu then
        TextOut(sx(245), sy(11), '�־�', FColor);
      lh := LISTLINEHEIGHT;
      menuline := _MIN(MAXMENU, MenuList.Count - MenuTop);
         //��Ʒ�嵥
      for i := MenuTop to MenuTop + menuline - 1 do
      begin
        m := i - MenuTop;
        if i = MenuIndex then
        begin
          FColor := clRed;
          TextOut(sx(12), sy(32 + m * lh), char(7), FColor);
        end
        else
          FColor := clWhite;
        pg := PTClientGoods(MenuList[i]);
        TextOut(sx(19), sy(32 + m * lh), pg.Name, FColor);
        if (pg.SubMenu >= 1) and (pg.SubMenu <> 2) then
          TextOut(sx(137), sy(32 + m * lh), #31, FColor);
        TextOut(sx(156), sy(32 + m * lh), IntToStr(pg.Price) + '���', FColor);
        str := '';
        if pg.Grade = -1 then
          str := '-'
        else
          TextOut(sx(245), sy(32 + m * lh), IntToStr(pg.Grade), FColor);
            {else for k:=0 to pg.Grade-1 do
               str := str + '*';
            if Length(str) >= 4 then begin
               Font.Color := clYellow;
               TextOut (SX(245), SY(32 + m*lh), str);
            end else
               TextOut (SX(245), SY(32 + m*lh), str);}
      end;
    end
    else
    begin
      TextOut(sx(19), sy(11), '�й���Ʒ�б�(' + IntToStr(MenuList.Count) + '/44��)', FColor);
      TextOut(sx(156), sy(11), '�־�', FColor);
      TextOut(sx(245), sy(11), '', FColor);
      lh := LISTLINEHEIGHT;
      menuline := _MIN(MAXMENU, MenuList.Count - MenuTop);
         //��Ʒ�嵥
      for i := MenuTop to MenuTop + menuline - 1 do
      begin
        m := i - MenuTop;
        if i = MenuIndex then
        begin
          FColor := clRed;
          TextOut(sx(12), sy(32 + m * lh), char(7), FColor);
        end
        else
          FColor := clWhite;
        pg := PTClientGoods(MenuList[i]);
        TextOut(sx(19), sy(32 + m * lh), pg.Name, FColor);
        if (pg.SubMenu >= 1) and (pg.SubMenu <> 2) then
          TextOut(sx(137), sy(32 + m * lh), #31, FColor);
        TextOut(sx(156), sy(32 + m * lh), IntToStr(pg.Stock) + '/' + IntToStr(pg.Grade), FColor);
      end;
    end;
      //TextOut (0, 0, IntToStr(MenuTopLine));

      //Release;
  end;
end;

{
procedure TFrmDlg.DMenuDlgDirectPaint(Sender: TObject;
  dsurface: TDXTexture);
  function SX(x: integer): integer;
  begin
      Result := DMenuDlg.SurfaceX (DMenuDlg.Left + x);
  end;
  function SY(y: integer): integer;
  begin
      Result := DMenuDlg.SurfaceY (DMenuDlg.Top + y);
  end;
var
   i, lh, k, m, menuline: integer;
   d: TDXTexture;
   pg: PTClientGoods;
   str: string;
begin
   with  g_DXCanvas do begin  
      with DMenuDlg do begin
         d := DMenuDlg.WLib.Images[FaceIndex];
         if d <> nil then
            dsurface.Draw (SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
      end;

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      //SetBkMode (Handle, TRANSPARENT);
      //title
      Font.Color := clWhite;
      if not BoStorageMenu then begin
         TextOut (SX(19),  SY(11), '��Ʒ�б�');
         TextOut (SX(156), SY(11), '�۸�');
         if not BoMakeItemMenu then
            TextOut (SX(245), SY(11), '�־�');
         lh := LISTLINEHEIGHT;
         menuline := _MIN(MAXMENU, MenuList.Count-MenuTop);
         //��ǰ ����Ʈ
         for i:=MenuTop to MenuTop+menuline-1 do begin
            m := i-MenuTop;
            if i = MenuIndex then begin
               Font.Color := clRed;
               TextOut (SX(12),  SY(32 + m*lh), char(7));
            end else Font.Color := clWhite;
            pg := PTClientGoods (MenuList[i]);
            TextOut (SX(19),  SY(32 + m*lh), pg.Name);
            if (pg.SubMenu >= 1) and (pg.SubMenu <> 2) then
               TextOut (SX(137), SY(32 + m*lh), #31);
            TextOut (SX(156), SY(32 + m*lh), IntToStr(pg.Price) + '���');
            str := '';
            if pg.Grade = -1 then str := '-'
            else TextOut (SX(245), SY(32 + m*lh), IntToStr(pg.Grade));
         end;
      end else begin
         TextOut (SX(19),  SY(11), '�й���Ʒ�б�');
         TextOut (SX(156), SY(11), '�־�');
         TextOut (SX(245), SY(11), '');
         lh := LISTLINEHEIGHT;
         menuline := _MIN(MAXMENU, MenuList.Count-MenuTop);
         //��Ʒ�嵥
         for i:=MenuTop to MenuTop+menuline-1 do begin
            m := i-MenuTop;
            if i = MenuIndex then begin
               Font.Color := clRed;
               TextOut (SX(12),  SY(32 + m*lh), char(7));
            end else Font.Color := clWhite;
            pg := PTClientGoods (MenuList[i]);
            TextOut (SX(19),  SY(32 + m*lh), pg.Name);
            if (pg.SubMenu >= 1) and (pg.SubMenu <> 2) then
               TextOut (SX(137), SY(32 + m*lh), #31);
            TextOut (SX(156), SY(32 + m*lh), IntToStr(pg.Stock) + '/' + IntToStr(pg.Grade));
         end;
      end;
      //TextOut (0, 0, IntToStr(MenuTopLine));

      //Release;
   end;
end;}

procedure TFrmDlg.DMenuDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly, idx: integer;
  iname, d1, d2, d3, d4: string;
  useable: Boolean;
begin
  DScreen.ClearHint(True);
  lx := DMenuDlg.LocalX(X) - DMenuDlg.Left;
  ly := DMenuDlg.LocalY(Y) - DMenuDlg.Top;
  if (lx >= 14) and (lx <= 279) and (ly >= 32) then
  begin
    idx := (ly - 32) div LISTLINEHEIGHT + MenuTop;
    if idx < MenuList.Count then
    begin
      PlaySound(s_glass_button_click);
      MenuIndex := idx;
      if DMakeItemDlg.Visible then
        DMakeItemDlgOkClick(DMakeItemDlgCancel, 0, 0);
    end;
  end;

  if BoStorageMenu then
  begin
    if (MenuIndex >= 0) and (MenuIndex < SaveItemList.Count) then
    begin
      MouseItem := PTClientItem(SaveItemList[MenuIndex])^;
      GetMouseItemInfo(iname, d1, d2, d3, d4, useable, FALSE);
      if iname <> '' then
      begin
        lx := 240;
        ly := 32 + (MenuIndex - MenuTop) * LISTLINEHEIGHT;
        with Sender as TDButton do
          DScreen.ShowHint(DMenuDlg.SurfaceX(Left + lx), DMenuDlg.SurfaceY(Top + ly), iname + d1 + '\' + d2 + '\' + d3 + d4, clYellow, FALSE);
      end;
      MouseItem.S.Name := '';
    end;
  end
  else
  begin
    if (MenuIndex >= 0) and (MenuIndex < MenuItemList.Count) and ((PTClientGoods(MenuList[MenuIndex]).SubMenu = 0) or (PTClientGoods(MenuList[MenuIndex]).SubMenu = 2)) then
    begin
      MouseItem := PTClientItem(MenuItemList[MenuIndex])^;
      BoNoDisplayMaxDura := TRUE;
      GetMouseItemInfo(iname, d1, d2, d3, d4, useable, FALSE);
      BoNoDisplayMaxDura := FALSE;
      if iname <> '' then
      begin
        lx := 240;
        ly := 32 + (MenuIndex - MenuTop) * LISTLINEHEIGHT;
        with Sender as TDButton do
          DScreen.ShowHint(DMenuDlg.SurfaceX(Left + lx), DMenuDlg.SurfaceY(Top + ly), iname + d1 + '\' + d2 + '\' + d3 + d4, clYellow, FALSE);
      end;
      MouseItem.S.Name := '';
    end;
  end;
end;

procedure TFrmDlg.DMenuDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  with DMenuDlg do
    if (X < SurfaceX(Left + 10)) or (X > SurfaceX(Left + Width - 20)) or (Y < SurfaceY(Top + 30)) or (Y > SurfaceY(Top + Height - 50)) then
    begin
      DScreen.ClearHint(True);
    end;
end;

procedure TFrmDlg.DMenuBuyClick(Sender: TObject; X, Y: Integer);
var
  pg: PTClientGoods;
  MsgResult, Count: integer;
  valstr: string;
begin
  Count := 0;
  if GetTickCount < LastestClickTime then
    exit; //�������������
  if (MenuIndex >= 0) and (MenuIndex < MenuList.Count) then
  begin
    pg := PTClientGoods(MenuList[MenuIndex]);
    LastestClickTime := GetTickCount + 5000;
    if (pg.SubMenu > 0) and (pg.SubMenu <> 2) then
    begin
      FrmMain.SendGetDetailItem(CurMerchant, 0, pg.Name);
      MenuTopLine := 0;
      CurDetailItem := pg.Name;
    end
    else
    begin
      if BoStorageMenu then
      begin
        try
          MouseItem := PTClientItem(SaveItemList[MenuIndex])^;
        except
        end;
        if MouseItem.S.OverlapItem > 0 then
        begin
          Total := MouseItem.Dura;
          if Total = 1 then
          begin
            DlgEditText := '1';
            MsgResult := mrOk;
          end
          else
            MsgResult := DCountMsgDlg('��ǰ���� ' + IntToStr(MouseItem.Dura) + ' ��.\���������빺�����Ʒ����?', [mbAbort]);
          GetValidStrVal(DlgEditText, valstr, [' ']);
          Count := Str_ToInt(valstr, 0);

          if Count > MouseItem.Dura then
            Count := MouseItem.Dura;
          if (MsgResult = mrCancel) or (Count <= 0) then
          begin// or (Count < 1) or(Count > MAX_OVERLAPITEM ) then begin
            Count := 0;
            Exit;
          end;
          FrmMain.SendTakeBackStorageItem(CurMerchant, pg.Price{MakeIndex}, pg.Name, word(Count));
        end
        else
          FrmMain.SendTakeBackStorageItem(CurMerchant, pg.Price{MakeIndex}, pg.Name, word(Count));
        exit;
      end;
      if BoMakeItemMenu then
      begin
        NameMakeItem := pg.Name;
        FrmMain.SendMakeItemSel(CurMerchant, pg.Name);
        MakeItemDlgShow('');
        exit;
      end;
      if BoMakeDrugMenu then
      begin
        FrmMain.SendMakeDrugItem(CurMerchant, pg.Name);
        exit;
      end;

      if pg.SubMenu = 2 then
      begin // pg.SubMenu = 2 �̸� ��ġ�� ������..
        Total := 100;
        MsgResult := DCountMsgDlg('���������?', [mbOk, mbCancel, mbAbort]);
        GetValidStrVal(DlgEditText, valstr, [' ']);
        Count := Str_ToInt(valstr, 0);
        if (MsgResult = mrCancel) or (Count <= 0) or (Count > MAX_OVERLAPITEM) then
        begin
          Exit;
        end;
      end;
      FrmMain.SendBuyItem(CurMerchant, pg.Stock, pg.Name, word(Count));
    end;
  end;
end;

procedure TFrmDlg.DMenuPrevClick(Sender: TObject; X, Y: Integer);
begin
  if not BoDetailMenu then
  begin
    if MenuTop > 0 then
      Dec(MenuTop, MAXMENU - 1);
    if MenuTop < 0 then
      MenuTop := 0;
  end
  else
  begin
    if MenuTopLine > 0 then
    begin
      MenuTopLine := _MAX(0, MenuTopLine - 10);
      FrmMain.SendGetDetailItem(CurMerchant, MenuTopLine, CurDetailItem);
    end;
  end;
end;

procedure TFrmDlg.DMenuNextClick(Sender: TObject; X, Y: Integer);
begin
  if not BoDetailMenu then
  begin
    if MenuTop + MAXMENU < MenuList.Count then
      Inc(MenuTop, MAXMENU - 1);
  end
  else
  begin
    MenuTopLine := MenuTopLine + 10;
    FrmMain.SendGetDetailItem(CurMerchant, MenuTopLine, CurDetailItem);
  end;
end;

procedure TFrmDlg.SoldOutGoods(itemserverindex: integer);
var
  i: integer;
  pg: PTClientGoods;
begin
  for i := 0 to MenuList.Count - 1 do
  begin
    pg := PTClientGoods(MenuList[i]);
    if (pg.Grade >= 0) and (pg.Stock = itemserverindex) then
    begin
      Dispose(pg);
      MenuList.Delete(i);
      if i < MenuItemList.Count then
        MenuItemList.Delete(i);
      if MenuIndex > MenuList.Count - 1 then
        MenuIndex := MenuList.Count - 1;
      break;
    end;
  end;
end;

procedure TFrmDlg.DelStorageItem(itemserverindex: integer; remain: word);
var
  i: integer;
  pg: PTClientGoods;
begin
  for i := 0 to MenuList.Count - 1 do
  begin
    pg := PTClientGoods(MenuList[i]);
    if (pg.Price = itemserverindex) then
    begin //��������ΰ�� Price = ItemServerIndex��.
      if (remain > 0) and (PTClientItem(SaveItemList[i])^.s.OverlapItem > 0) then
      begin
        PTClientItem(SaveItemList[i])^.dura := remain;
        Exit;
      end;
      Dispose(pg);
      MenuList.Delete(i);
      if i < SaveItemList.Count then
        SaveItemList.Delete(i);
      if MenuIndex > MenuList.Count - 1 then
        MenuIndex := MenuList.Count - 1;
      break;
    end;
  end;
end;

procedure TFrmDlg.DMenuCloseClick(Sender: TObject; X, Y: Integer);
begin
  DMenuDlg.Visible := FALSE;
end;

procedure TFrmDlg.DMerchantDlgClick(Sender: TObject; X, Y: Integer);
var
  i, L, T: integer;
  p: PTClickPoint;
begin
  if GetTickCount < LastestClickTime then
    exit; //Ŭ���� ���� ���ϰ� ����
  L := DMerchantDlg.Left;
  T := DMerchantDlg.Top;
  with DMerchantDlg do
    for i := 0 to MDlgPoints.Count - 1 do
    begin
      p := PTClickPoint(MDlgPoints[i]);
      if (X >= SurfaceX(L + p.rc.Left)) and (X <= SurfaceX(L + p.rc.Right)) and (Y >= SurfaceY(T + p.rc.Top)) and (Y <= SurfaceY(T + p.rc.Bottom)) then
      begin
        PlaySound(s_glass_button_click);
        if DMakeItemDlg.Visible then
          DMakeItemDlgOkClick(DMakeItemDlgCancel, 0, 0);
        if DSellDlg.Visible then
          CloseDSellDlg;
        SafeCloseDlg;
{            if DItemMarketDlg.Visible then CloseItemMarketDlg;
            if DJangwonListDlg.Visible then DJangwonCloseClick(DJangwonClose, 0, 0);
            if DGABoardListDlg.Visible then DGABoardListCloseClick(FrmDlg.DGABoardListClose, 0, 0);
            if DGABoardDlg.Visible then DGABoardCloseClick(FrmDlg.DGABoardClose, 0, 0);
            if DGADecorateDlg.Visible then DGADecorateCloseClick(FrmDlg.DGADecorateClose, 0, 0);}

        FrmMain.SendMerchantDlgSelect(CurMerchant, p.RStr);
        LastestClickTime := GetTickCount + 5000; //5���Ŀ� ��� ����
        break;
      end;
    end;
end;

procedure TFrmDlg.DMerchantDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, L, T: integer;
  p: PTClickPoint;
begin
  if GetTickCount < LastestClickTime then
    exit; //Ŭ���� ���� ���ϰ� ����
  SelectMenuStr := '';
  L := DMerchantDlg.Left;
  T := DMerchantDlg.Top;
  with DMerchantDlg do
    for i := 0 to MDlgPoints.Count - 1 do
    begin
      p := PTClickPoint(MDlgPoints[i]);
      if (X >= SurfaceX(L + p.rc.Left)) and (X <= SurfaceX(L + p.rc.Right)) and (Y >= SurfaceY(T + p.rc.Top)) and (Y <= SurfaceY(T + p.rc.Bottom)) then
      begin
        SelectMenuStr := p.RStr;
        break;
      end;
    end;
end;

procedure TFrmDlg.DMerchantDlgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SelectMenuStr := '';
end;

procedure TFrmDlg.DSellDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  actionname: string;
begin
  with DSellDlg do
  begin
    d := DMenuDlg.WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clWhite;
      actionname := '';
      case SpotDlgMode of
        dmSell:
          actionname := '��: ';
        dmRepair:
          actionname := '����: ';
        dmStorage:
          actionname := ' �й���Ʒ';
        dmMaketSell:
          actionname := ' ��������';
      end;
      TextOut(SurfaceX(Left + 8), SurfaceY(Top + 6), actionname + SellPriceStr, clWhite);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DSellDlgCloseClick(Sender: TObject; X, Y: Integer);
begin
  CloseDSellDlg;
end;

procedure TFrmDlg.DSellDlgSpotClick(Sender: TObject; X, Y: Integer);
var
  temp: TClientItem;
  MsgResult, Count: integer;
  valstr: string;
begin
  SellPriceStr := '';
  if not ItemMoving then
  begin
    if SellDlgItem.S.Name <> '' then
    begin
      ItemClickSound(SellDlgItem.S);
      ItemMoving := TRUE;
      MovingItem.Index := -99; //sell â���� ����..
      MovingItem.Item := SellDlgItem;
      SellDlgItem.S.Name := '';
    end;
  end
  else
  begin
    if (MovingItem.Index = -97) or (MovingItem.Index = -98) then
      exit;
    if (MovingItem.Index >= 0) or (MovingItem.Index = -99) then
    begin
      ItemClickSound(MovingItem.Item.S);
      if SellDlgItem.S.Name <> '' then
      begin //�ڸ��� ������
        temp := SellDlgItem;
        SellDlgItem := MovingItem.Item;
        MovingItem.Index := -99; //sell â���� ����..
        MovingItem.Item := temp;
      end
      else if MovingItem.Item.S.OverlapItem = 0 then
      begin
        SellDlgItem := MovingItem.Item;
        MovingItem.Item.S.name := '';
        ItemMoving := FALSE;
      end
      else if MovingItem.Item.S.OverlapItem > 0 then
      begin
        SellDlgItem := MovingItem.Item;
        ItemMoving := FALSE;
        Total := MovingItem.Item.Dura;
        if Total = 1 then
        begin
          DlgEditText := '1';
          MsgResult := mrOk;
        end
        else
          MsgResult := DCountMsgDlg('��ǰ���� ' + IntToStr(MovingItem.Item.Dura) + ' ��.\������������۵���Ʒ����?', [mbOk, mbCancel, mbAbort]);
        ItemMoving := TRUE;
        GetValidStrVal(DlgEditText, valstr, [' ']);
        Count := Str_ToInt(valstr, 0);
        if Count <= 0 then
        begin
          Count := 0;
          AddItemBag(SellDlgItem);
          SellDlgItem.S.Name := '';
          SellDlgItem.Dura := 0;
          MovingItem.Item.S.name := '';
          CancelItemMoving;
          Exit;
        end;
        if Count >= SellDlgItem.Dura then
        begin
          Count := SellDlgItem.Dura;
          MovingItem.Item.Dura := 0;
        end;
        if MsgResult = mrOk then
        begin
          SellDlgItem.Dura := word(Count);
          if MovingItem.Item.Dura > 0 then
          begin
            MovingItem.Item.Dura := MovingItem.Item.Dura - word(Count);
          end;
          if MovingItem.Item.Dura <= 0 then
          begin
            MovingItem.Item.Dura := 0;
            MovingItem.Item.S.name := '';
            ItemMoving := FALSE;
          end;
//               MovingItem.Index := 0;
          CancelItemMoving;
        end;
        if MsgResult = mrCancel then
        begin
          AddItemBag(SellDlgItem);
          SellDlgItem.S.Name := '';
          SellDlgItem.Dura := 0;
          MovingItem.Item.S.name := '';
//               MovingItem.Index := 0;
          CancelItemMoving;
          Exit;
        end;
      end;

      BoQueryPrice := TRUE;
      QueryPriceTime := GetTickCount;
         //Ȧ���ưó�� 2006/04/04
      if SellStHold and (SellDlgItem.S.Name <> '') then
        DSellDlgOkClick(DSellDlgOk, 1, 1);
    end;
  end;

end;

procedure TFrmDlg.DSellDlgSpotDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  if SellDlgItem.S.Name <> '' then
  begin
    d := WBagItem.Images[SellDlgItem.S.Looks];
    if d <> nil then
    begin
      with DSellDlgSpot do
        dsurface.Draw(SurfaceX(Left + (Width - d.Width) div 2), SurfaceY(Top + (Height - d.Height) div 2), d.ClientRect, d, TRUE);

      if SellDlgItem.S.OverlapItem > 0 then
      begin
               //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//               g_DXCanvas.Font.Color := clYellow;
        with DSellDlgSpot do
          g_DXCanvas.TextOut(SurfaceX(Left + (Width - d.Width) div 2) + 21, SurfaceY(Top + (Height - d.Height) div 2) + 15, IntToStr(SellDlgItem.Dura), clYellow);
//               g_DXCanvas.//Release;
      end;
    end;
  end;
end;

procedure TFrmDlg.DSellDlgSpotMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  MouseItem := SellDlgItem;
end;

procedure TFrmDlg.DSellDlgOkClick(Sender: TObject; X, Y: Integer);
var
  dropgold: integer;
  valstr: string;
  MsgResult: integer;
begin
  if (SellDlgItem.S.Name = '') and (SellDlgItemSellWait.S.Name = '') then
    exit;
  if GetTickCount < LastestClickTime then
    exit; //�������������
  case SpotDlgMode of
    dmSell:
      FrmMain.SendSellItem(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name, SellDlgItem.Dura);
    dmRepair:
      FrmMain.SendRepairItem(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name);
    dmStorage:
      FrmMain.SendStorageItem(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name, SellDlgItem.Dura);
    dmMaketSell:
      begin
        DMessageDlg('������������ۼ۸�', [mbOk, mbAbort]);
        GetValidStrVal(DlgEditText, valstr, [' ']);

        try
          dropgold := Str_ToInt(valstr, 0);
        except
          DMessageDlg('�������', [mbOk]);
          Exit;
        end;
        if (dropgold > 0) and (dropgold <= MAX_MARKETPRICE) then
        begin
          MsgResult := DMessageDlg(SellDlgItem.S.Name + ' �ļ۸�Ϊ ' + GetGoldStr(dropgold) + '��ң�', [mbOk, mbCancel]);
          if MsgResult = mrOk then
            FrmMain.SendMaketSellItem(CurMerchant, SellDlgItem.MakeIndex, valstr, SellDlgItem.Dura)
          else if MsgResult = mrCancel then
            Exit;
        end
        else
        begin
          DMessageDlg('�����������ϼ���Ʒ�ļ۸�\������ۼ۸�����Ϊ ' + GetGoldStr(MAX_MARKETPRICE) + ' ��ҡ�', [mbOk]);
          Exit;
        end;
      end;
  end;

  SellDlgItemSellWait := SellDlgItem;
  SellDlgItem.S.Name := '';
  LastestClickTime := GetTickCount + 5000;
  SellPriceStr := '';
end;





{------------------------------------------------------------------------}

//ħ�������ô��� (�Ի�)

{------------------------------------------------------------------------}

procedure TFrmDlg.SetMagicKeyDlg(icon: integer; magname: string; var curkey: word);
begin
  MagKeyIcon := icon;
  MagKeyMagName := magname;
  MagKeyCurKey := curkey;

  DKeySelDlg.Left := (g_FScreenWidth - DKeySelDlg.Width) div 2;
  DKeySelDlg.Top := (g_FScreenHeight - DKeySelDlg.Height) div 2;
  HideAllControls;
  DKeySelDlg.ShowModal;

  while TRUE do
  begin
    if not DKeySelDlg.Visible then
      break;
      //FrmMain.DXTimerTimer (self, 0);
    frmMain.AppOnIdle();
    Application.ProcessMessages;
    if Application.Terminated then
      exit;
  end;

  RestoreHideControls;
  curkey := MagKeyCurKey;
end;

procedure TFrmDlg.DKeySelDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DKeySelDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
      //���� �̸�
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clSilver;
      TextOut(SurfaceX(Left + 95), SurfaceY(Top + 38), MagKeyMagName + '��ݼ��̱�����Ϊ.', clSilver);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DKsIconDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DksIcon do
  begin
    d := WMagicon.Images[MagKeyIcon];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DKsF1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  b: TDButton;
  d: TDXTexture;
begin
  b := nil;
  case MagKeyCurKey of
    word('1'):
      b := DKsF1;
    word('2'):
      b := DKsF2;
    word('3'):
      b := DKsF3;
    word('4'):
      b := DKsF4;
    word('5'):
      b := DKsF5;
    word('6'):
      b := DKsF6;
    word('7'):
      b := DKsF7;
    word('8'):
      b := DKsF8;
      // 2003/08/20 =>��������Ű �߰�  // AddMagicKey
    word('1') + 20:
      b := DKsConF1;
    word('2') + 20:
      b := DKsConF2;
    word('3') + 20:
      b := DKsConF3;
    word('4') + 20:
      b := DKsConF4;
    word('5') + 20:
      b := DKsConF5;
    word('6') + 20:
      b := DKsConF6;
    word('7') + 20:
      b := DKsConF7;
    word('8') + 20:
      b := DKsConF8;
      //-------
  else
    b := DKsNone;
  end;
  if b = Sender then
  begin
    with b do
    begin
      d := WLib.Images[FaceIndex + 1];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
  with Sender as TDButton do
  begin
    if Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DKsOkClick(Sender: TObject; X, Y: Integer);
begin
  DKeySelDlg.Visible := FALSE;
end;

procedure TFrmDlg.DKsF1Click(Sender: TObject; X, Y: Integer);
begin
  if Sender = DKsF1 then
    MagKeyCurKey := integer('1');
  if Sender = DKsF2 then
    MagKeyCurKey := integer('2');
  if Sender = DKsF3 then
    MagKeyCurKey := integer('3');
  if Sender = DKsF4 then
    MagKeyCurKey := integer('4');
  if Sender = DKsF5 then
    MagKeyCurKey := integer('5');
  if Sender = DKsF6 then
    MagKeyCurKey := integer('6');
  if Sender = DKsF7 then
    MagKeyCurKey := integer('7');
  if Sender = DKsF8 then
    MagKeyCurKey := integer('8');
   // 2003/08/20 =>��������Ű �߰�  // AddMagicKey
  if Sender = DKsConF1 then
    MagKeyCurKey := integer('1') + 20;
  if Sender = DKsConF2 then
    MagKeyCurKey := integer('2') + 20;
  if Sender = DKsConF3 then
    MagKeyCurKey := integer('3') + 20;
  if Sender = DKsConF4 then
    MagKeyCurKey := integer('4') + 20;
  if Sender = DKsConF5 then
    MagKeyCurKey := integer('5') + 20;
  if Sender = DKsConF6 then
    MagKeyCurKey := integer('6') + 20;
  if Sender = DKsConF7 then
    MagKeyCurKey := integer('7') + 20;
  if Sender = DKsConF8 then
    MagKeyCurKey := integer('8') + 20;
   //------
  if Sender = DKsNone then
    MagKeyCurKey := 0;
end;



{------------------------------------------------------------------------}

//��������΢�Ͱ�ť

{------------------------------------------------------------------------}

//С��ͼ
procedure TFrmDlg.DBotMiniMapClick(Sender: TObject; X, Y: Integer);
begin
  BoWantMiniMap := TRUE;
  if ViewMiniMapStyle=0 then
     ViewMiniMapStyle:=1
     else
     begin
       if ViewMiniMapStyle=2 then
          begin
            ViewMiniMapStyle:=0;
            BoWantMiniMap := FALSE;
            PrevVMMStyle:=0;
          end
          else
          begin
           inc(ViewMiniMapStyle);
          end;
     end;
  if MiniMapIndex=-1 then
     begin
       querymsgtime := GetTickCount + 3000;
       FrmMain.SendWantMiniMap;
     end;
end;

procedure TFrmDlg.DBotTradeClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount > querymsgtime then
  begin
    querymsgtime := GetTickCount + 3000;
    FrmMain.SendDealTry;
  end;
end;

procedure TFrmDlg.DBotGuildClick(Sender: TObject; X, Y: Integer);
begin
  if DGuildDlg.Visible then
  begin
    DGuildDlg.Visible := FALSE;
  end
  else if GetTickCount > querymsgtime then
  begin
    querymsgtime := GetTickCount + 3000;
    FrmMain.SendGuildDlg;
  end;
end;

procedure TFrmDlg.DBotGroupClick(Sender: TObject; X, Y: Integer);
begin
//  ToggleShowGroupDlg;
end;


{------------------------------------------------------------------------}

//�׷� ���̾�α�

{------------------------------------------------------------------------}

procedure TFrmDlg.ToggleShowGroupDlg;
begin
  DGroupDlg.Visible := not DGroupDlg.Visible;
end;

procedure TFrmDlg.DGroupDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  lx, ly, n: integer;
begin
  with DGroupDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    if GroupMembers.Count > 0 then
    begin
      with g_DXCanvas do
      begin  
            //SetBkMode (Handle, TRANSPARENT);
//            Font.Color := clSilver;
        lx := SurfaceX(28) + Left;
        ly := SurfaceY(80) + Top;
        TextOut(lx, ly, GroupMembers[0], clSilver);
        for n := 1 to GroupMembers.Count - 1 do
        begin
          lx := SurfaceX(28) + Left + ((n - 1) mod 2) * 100;
          ly := SurfaceY(80 + 16) + Top + ((n - 1) div 2) * 16;
          TextOut(lx, ly, GroupMembers[n], clSilver);
        end;
            //Release;
      end;
    end;
  end;
end;

procedure TFrmDlg.DGrpDlgCloseClick(Sender: TObject; X, Y: Integer);
begin
  DGroupDlg.Visible := FALSE;
end;

procedure TFrmDlg.DGrpAllowGroupDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if AllowGroup then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DGrpAllowGroupClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount > changegroupmodetime then
  begin
    AllowGroup := not AllowGroup;
    changegroupmodetime := GetTickCount + 2000; //timeout 5�� //DelayTime 5�� 2������ //2004/11/18
    FrmMain.SendGroupMode(AllowGroup);
  end;
end;

procedure TFrmDlg.DGrpCreateClick(Sender: TObject; X, Y: Integer);
var
  who: string;
begin
  if (GetTickCount > changegroupmodetime) and (GroupMembers.Count = 0) then
  begin
    DialogSize := 1;
    DMessageDlg('����������������˵�����.', [mbOk, mbAbort]);
    who := Trim(DlgEditText);
    if who <> '' then
    begin
      changegroupmodetime := GetTickCount + 2000; //timeout 5�� //DelayTime 5�ʿ��� 2�ʷ����� //2004/11/18
      FrmMain.SendCreateGroup(Trim(DlgEditText));
    end;
  end;
end;

procedure TFrmDlg.DGrpAddMemClick(Sender: TObject; X, Y: Integer);
var
  who: string;
begin
  if (GetTickCount > changegroupmodetime) and (GroupMembers.Count > 0) then
  begin
    DialogSize := 1;
    DMessageDlg('����������������˵�����.', [mbOk, mbAbort]);
    who := Trim(DlgEditText);
    if who <> '' then
    begin
      changegroupmodetime := GetTickCount + 2000; //timeout 5�� //DelayTime 5�ʿ��� 2�ʷ����� //2004/11/18
      FrmMain.SendAddGroupMember(Trim(DlgEditText));
    end;
  end;
end;

procedure TFrmDlg.DGrpDelMemClick(Sender: TObject; X, Y: Integer);
var
  who: string;
begin
  if (GetTickCount > changegroupmodetime) and (GroupMembers.Count > 0) then
  begin
    DialogSize := 1;
    DMessageDlg('��������ӱ�����ɾ�����˵�����.', [mbOk, mbAbort]);
    who := Trim(DlgEditText);
    if who <> '' then
    begin
      changegroupmodetime := GetTickCount + 2000; //timeout 5�� //DelayTime 5�ʿ��� 2�ʷ����� //2004/11/18
      FrmMain.SendDelGroupMember(Trim(DlgEditText));
    end;
  end;
end;

procedure TFrmDlg.DBotLogoutClick(Sender: TObject; X, Y: Integer);
begin
   // 2003/08/29 IME ��������
  LocalLanguage := imSAlpha;

  FrmMain.SendClientMessage(CM_CANCLOSE, 0, 0, 0, 0);
{
   if (GetTickCount - LatestStruckTime > 10000) and
      (GetTickCount - LatestMagicTime > 10000) and
      (GetTickCount - LatestHitTime > 10000) or
      (Myself.Death) then begin
      FrmMain.AppLogOut;
   end else
      DScreen.AddChatBoardString ('��ս����ʱ���㲻���˳���Ϸ.', clYellow, clRed);
}
end;

procedure TFrmDlg.DBotExitClick(Sender: TObject; X, Y: Integer);
begin
  if (GetTickCount - LatestStruckTime > 10000) and (GetTickCount - LatestMagicTime > 10000) and (GetTickCount - LatestHitTime > 10000) or (Myself.Death) then
  begin
    FrmMain.AppExit;
  end
  else
    DScreen.AddChatBoardString('��ս����ʱ���㲻���˳���Ϸ.', clYellow, clRed);
end;

procedure TFrmDlg.DBotPlusAbilClick(Sender: TObject; X, Y: Integer);
begin
  FrmDlg.OpenAdjustAbility;
end;


{------------------------------------------------------------------------}

//��ȯ ���̾�α�

{------------------------------------------------------------------------}

procedure TFrmDlg.OpenDealDlg(DealCase: Byte);
var
  d: TDXTexture;
begin
  if DealCase = 1 then
  begin
    DDealDlg.Floating := True;
    DDealRemoteDlg.Floating := True;
    DDealRemoteDlg.Left := g_FScreenWidth - 236 - 100;
    DDealRemoteDlg.Top := 0;
    DDealDlg.Left := g_FScreenWidth - 236 - 100;
    DDealDlg.Top := DDealRemoteDlg.Height;
    DDealJangwon.Visible := False;
  end
  else if DealCase = 2 then
  begin
    DDealJangwon.Floating := False;
    DDealJangwon.Visible := True;
    DDealDlg.Floating := False;
    DDealRemoteDlg.Floating := False;
    DDealRemoteDlg.Left := 548;
    DDealRemoteDlg.Top := 202;
    DDealDlg.Left := 312;
    DDealDlg.Top := 202;
  end;
  DItemBag.Left := 0; //475;
  DItemBag.Top := 0;
  DItemBag.Visible := TRUE;
  DDealDlg.Visible := TRUE;
  DDealRemoteDlg.Visible := TRUE;

  FillCHar(DealItems, sizeof(TClientItem) * 10, #0);
  FillCHar(DealRemoteItems, sizeof(TClientItem) * 20, #0);
  DealGold := 0;
  DealRemoteGold := 0;
  BoDealEnd := FALSE;

   //��Ʒ���еĲ���Ӱ����
  ArrangeItembag;
end;

procedure TFrmDlg.CloseDealDlg;
begin
  DDealDlg.Visible := FALSE;
  DDealRemoteDlg.Visible := FALSE;
  if DDealJangwon.Visible then
    DDealJangwon.Visible := False;

   //��Ʒ���еĲ���Ӱ����
  ArrangeItembag;
end;

procedure TFrmDlg.DDealOkClick(Sender: TObject; X, Y: Integer);
var
  mi: integer;
begin
  if GetTickCount > dealactiontime then
  begin
      //CloseDealDlg;
    FrmMain.SendDealEnd;
    dealactiontime := GetTickCount + 4000;
    BoDealEnd := TRUE;
      //���״�������������ڽ��״������Ĳ���Ӱ��(����)
    if ItemMoving then
    begin
      mi := MovingItem.Index;
      if (mi <= -20) and (mi > -30) then
      begin //������ȥ��
        AddDealItem(MovingItem.Item);  // ����=>��ɬ
        ItemMoving := FALSE;
        MovingItem.Item.S.name := '';
        MovingItem.Item.Dura := 0; // 10/29
      end;
    end;
  end;
end;

procedure TFrmDlg.DDealCloseClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount > dealactiontime then
  begin
    CloseDealDlg;
    FrmMain.SendCancelDeal;
  end;
end;

procedure TFrmDlg.DDealRemoteDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DDealRemoteDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clWhite;
      TextOut(SurfaceX(Left + 64), SurfaceY(Top + 196 - 65), GetGoldStr(DealRemoteGold), clWhite);
//         TextOut (SurfaceX(Left+(110-(TextWidth(FrmMain.CharName)div 2))), SurfaceY(Top+3)+5, DealWho);
      TextOut(SurfaceX(Left + 59 + (106 - TextWidth(DealWho)) div 2), SurfaceY(Top + 3) + 3, DealWho, clWhite);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DDealDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DDealDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    with g_DXCanvas do
    begin
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clWhite;
      TextOut(SurfaceX(Left + 64), SurfaceY(Top + +196 - 65), GetGoldStr(DealGold), clWhite);
//         TextOut (SurfaceX(Left+(110-(TextWidth(FrmMain.CharName)div 2))), SurfaceY(Top+3)+5, FrmMain.CharName);
      TextOut(SurfaceX(Left + 59 + (106 - TextWidth(FrmMain.CharName)) div 2), SurfaceY(Top + 3) + 3, FrmMain.CharName, clWhite);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DealItemReturnBag(mitem: TClientItem);
begin
  if not BoDealEnd then
  begin
    DealDlgItem := mitem;
    FrmMain.SendDelDealItem(DealDlgItem);
    dealactiontime := GetTickCount + 4000;
  end;
end;

procedure TFrmDlg.DDGridGridSelect(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  temp: TClientItem;
  mi, idx: integer;
  MsgResult, Count: integer;
  valstr: string;
begin
  if not BoDealEnd and (GetTickCount > dealactiontime) then
  begin
      //2004/01/15 ItemSafeGuard..
    if not ItemMoving then
    begin
//         idx := ACol + ARow * DDGrid.ColCount;
//         if idx in [0..9] then begin
//            if DealItems[idx].S.Name <> '' then begin
//               ItemMoving := TRUE;
//               MovingItem.Index := -idx - 20;
//               MovingItem.Item := DealItems[idx];
//               DealItems[idx].S.Name := '';
//               ItemClickSound (MovingItem.Item.S);
//            end;
//         end;
    end
    else
    begin
      mi := MovingItem.Index;
      if (mi >= 0) or (mi <= -20) and (mi > -30) then
      begin //����,���� �°͸�
        ItemClickSound(MovingItem.Item.S);
        ItemMoving := FALSE;
        if mi >= 0 then
        begin
          if MovingItem.Item.S.OverlapItem > 0 then
          begin

            Total := MovingItem.Item.Dura;
            if Total = 1 then
            begin
              DlgEditText := '1';
              MsgResult := mrOk;
            end
            else
              MsgResult := DCountMsgDlg('��ǰ���� ' + IntToStr(MovingItem.Item.Dura) + ' ��.\�㽫���׶��ټ�?', [mbOk, mbCancel, mbAbort]);
            GetValidStrVal(DlgEditText, valstr, [' ']);
            Count := Str_ToInt(valstr, 0);
            if Count <= 0 then
              Count := 0;
            if Count > MovingItem.Item.Dura then
            begin
              Count := MovingItem.Item.Dura;
            end;
            ItemMoving := TRUE;
            if MsgResult = mrOk then
            begin //and (Count > 0) and (Count < MAX_OVERLAPITEM+1 ) then begin
              DealDlgItem := MovingItem.Item; //�������ȴ�����ڼ䱣��
              DealDlgItem.Dura := word(Count);
              MovingItem.Item.Dura := MovingItem.Item.Dura - Count;
              if MovingItem.Item.Dura = 0 then
              begin
                MovingItem.Item.S.name := '';
                ItemMoving := FALSE;
              end;
              CancelItemMoving;
              FrmMain.SendAddDealItem(DealDlgItem);
              dealactiontime := GetTickCount + 4000;
            end
            else if MsgResult = mrCancel then
            begin
              CancelItemMoving;
              dealactiontime := GetTickCount;
            end;
          end
          else
          begin
            DealDlgItem := MovingItem.Item;
            FrmMain.SendAddDealItem(DealDlgItem);
            dealactiontime := GetTickCount + 4000;
          end;
        end
        else
          AddDealItem(MovingItem.Item);
        MovingItem.Item.S.name := '';
      end;
      if mi = -98 then
        DDGoldClick(self, 0, 0);
    end;
    ArrangeItemBag;
  end;
end;

procedure TFrmDlg.DCountDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
  begin
    if DCountDlgOk.Visible then
    begin
      DCountDlg.DialogResult := mrOk;
      DCountDlg.Visible := FALSE;
    end;
  end;
  if Key = 27 then
  begin
    if DCountDlgCancel.Visible then
    begin
      DCountDlg.DialogResult := mrCancel;
      DCountDlg.Visible := FALSE;
    end;
  end;
end;

procedure TFrmDlg.DDGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
var
  idx: integer;
  d: TDXTexture;
begin
  idx := ACol + ARow * DDGrid.ColCount;
  if idx in [0..9] then
  begin
    if DealItems[idx].s.Name <> '' then
    begin
      d := WBagItem.Images[DealItems[idx].s.Looks];
      if d <> nil then
        with DDGrid do
          dsurface.Draw(SurfaceX(Rect.Left + (ColWidth - d.Width) div 2 - 1), SurfaceY(Rect.Top + (RowHeight - d.Height) div 2 + 1), d.ClientRect, d, TRUE);
         // ������ ��ġ��
      if DealItems[idx].s.OverlapItem > 0 then
      begin
            //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//            g_DXCanvas.Font.Color := clYellow;

        g_DXCanvas.TextOut(DDGrid.SurfaceX(Rect.Left + 20), DDGrid.SurfaceY(Rect.Top + 20), IntToStr(DealItems[idx].dura), clYellow);
//            g_DXCanvas.//Release;
      end;
    end;
  end;
end;

procedure TFrmDlg.DDGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  idx: integer;
begin
  idx := ACol + ARow * DDGrid.ColCount;
  if idx in [0..9] then
  begin
    MouseItem := DealItems[idx];
  end;
end;

procedure TFrmDlg.DDRGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
var
  idx: integer;
  i, k: integer;
  d: TDXTexture;
begin

   //�ߺ��� �������� ������ ���ش�.
  for i := 0 to 19 do
  begin
    if DealRemoteItems[i].s.Name <> '' then
    begin
      for k := i + 1 to 19 do
      begin
        if DealRemoteItems[i].s.OverlapItem > 0 then
        begin
          if (DealRemoteItems[i].s.Name = DealRemoteItems[k].s.Name) then
          begin //(ItemArr[i].MakeIndex <> ItemArr[k].MakeIndex) and
            DealRemoteItems[i].dura := DealRemoteItems[i].dura + DealRemoteItems[k].dura;
            FillChar(DealRemoteItems[k], sizeof(TClientItem), #0);
          end;
        end
        else if (DealRemoteItems[i].s.Name = DealRemoteItems[k].s.Name) and (DealRemoteItems[i].MakeIndex = DealRemoteItems[k].MakeIndex) then
        begin
          FillChar(DealRemoteItems[k], sizeof(TClientItem), #0);
        end;
      end;
    end;
  end;

  idx := ACol + ARow * DDRGrid.ColCount;
  if idx in [0..19] then
  begin
    if DealRemoteItems[idx].s.Name <> '' then
    begin
      d := WBagItem.Images[DealRemoteItems[idx].s.Looks];
      if d <> nil then
        with DDRGrid do
          dsurface.Draw(SurfaceX(Rect.Left + (ColWidth - d.Width) div 2 - 1), SurfaceY(Rect.Top + (RowHeight - d.Height) div 2 + 1), d.ClientRect, d, TRUE);
         // ������ ��ġ��
      if DealRemoteItems[idx].s.OverlapItem > 0 then
      begin
            //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//            g_DXCanvas.Font.Color := clYellow;

        g_DXCanvas.TextOut(DDRGrid.SurfaceX(Rect.Left + 20), DDRGrid.SurfaceY(Rect.Top + 20), IntToStr(DealRemoteItems[idx].dura), clYellow);
//            g_DXCanvas.//Release;
      end;

    end;
  end;
end;

procedure TFrmDlg.DDRGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  if Myself = nil then
    exit;
  with DDRGold do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DDRGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  idx: integer;
begin
  idx := ACol + ARow * DDRGrid.ColCount;
  if idx in [0..19] then
  begin
    MouseItem := DealRemoteItems[idx];
  end;
end;

procedure TFrmDlg.DealZeroGold;
begin
  if not BoDealEnd and (DealGold > 0) then
  begin
    dealactiontime := GetTickCount + 4000;
    FrmMain.SendChangeDealGold(0);
  end;
end;

procedure TFrmDlg.DDGoldClick(Sender: TObject; X, Y: Integer);
var
  dgold: integer;
  valstr: string;
begin
  if Myself = nil then
    exit;
  if not BoDealEnd and (GetTickCount > dealactiontime) then
  begin
    if not ItemMoving then
    begin
      if DealGold > 0 then
      begin
        PlaySound(s_money);
        ItemMoving := TRUE;
        MovingItem.Index := -97; //��ȯ â������ ��
        MovingItem.Item.S.Name := '���';
      end;
    end
    else
    begin
      if (MovingItem.Index = -97) or (MovingItem.Index = -98) then
      begin //����..
        if (MovingItem.Index = -98) then
        begin //����â���� �� ��
          if MovingItem.Item.S.Name = '���' then
          begin
                  //�󸶸� ���� ���� �����.
            DialogSize := 1;
            ItemMoving := FALSE;
            MovingItem.Item.S.Name := '';
            DMessageDlg('����֧�����ٽ�ң�', [mbOk, mbAbort]);
            GetValidStrVal(DlgEditText, valstr, [' ']);
            dgold := Str_ToInt(valstr, 0);
            if (dgold <= (DealGold + Myself.Gold)) and (dgold > 0) then
            begin
              FrmMain.SendChangeDealGold(dgold);
              dealactiontime := GetTickCount + 4000;
            end
            else
              dgold := 0;
          end;
        end;
        ItemMoving := FALSE;
        MovingItem.Item.S.Name := '';
      end;
    end;
  end;
end;



procedure TFrmDlg.DDGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  if Myself = nil then
    exit;
  with DDGold do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

{--------------------------------------------------------------}

procedure TFrmDlg.DUserState1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  i, l, m, pgidx, bbx, bby, idx, ax, ay, sex, hair, tx: integer;
  d: TDXTexture;
  hcolor, keyimg: integer;
  iname, d1, d2, d3, d4, str: string;
  useable: Boolean;
  FColor: tColor;
begin
  with DUserState1 do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

      //�۲���˵�װ��(��װ״̬)
    sex := DRESSfeature(UserState1.Feature) mod 2;
    hair := HAIRfeature(UserState1.Feature);
    if sex = 1 then
      pgidx := 377   //Ů
    else
      pgidx := 376;     //��
    bbx := Left + 38;
    bby := Top + 52;
    d := WProgUse.Images[pgidx];
    if d <> nil then
      dsurface.Draw(SurfaceX(bbx), SurfaceY(bby), d.ClientRect, d, FALSE);
    bbx := bbx - 7;
    bby := bby + 44;

    if UserState1.UseItems[U_DRESS].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_DRESS].s.Looks; //�·� if Sex = 1 then idx := 80; //Ů�·�
      if idx >= 0 then
      begin
        d := WStateItem.GetCachedImage(idx, ax, ay);
        if d <> nil then
          dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
      end;
    end;

      //�·�, ����, ����
    idx := 440 + hair div 2; //����
    if sex = 1 then
      idx := 480 + hair div 2;

    if idx > 0 then
    begin
      d := WProgUse.GetCachedImage(idx, ax, ay);
      if d <> nil then
        dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
    end;

    if UserState1.UseItems[U_WEAPON].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_WEAPON].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.GetCachedImage(idx, ax, ay);
        if d <> nil then
          dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
      end;
      if idx = 923 then
      begin
        d := WStateItem.GetCachedImage(idx - 1, ax, ay);
        if d <> nil then
          DrawBlend(dsurface, SurfaceX(bbx + ax), SurfaceY(bby + ay), d, 1);
      end;
    end;
    if UserState1.UseItems[U_HELMET].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_HELMET].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.GetCachedImage(idx, ax, ay);
        if d <> nil then
          dsurface.Draw(SurfaceX(bbx + ax), SurfaceY(bby + ay), d.ClientRect, d, TRUE);
      end;
    end;

      //ԭΪ�򿪣���ʾ����������Ϣ���װ����Ϣ����ʾ�������·�
    if MouseUserStateItem.S.Name <> '' then
    begin
      MouseItem := MouseUserStateItem;
      GetMouseItemInfo(iname, d1, d2, d3, d4, useable, FALSE);
      if iname <> '' then
      begin
        if MouseItem.Dura = 0 then
          hcolor := clRed
//            else if MouseItem.UpgradeOpt > 0 then hcolor := clAqua //@@@@@
//        else if MouseItem.UpgradeOpt > 0 then     / ��Ʒ��ɫ  ��������
//          hcolor := TColor($cccc33)              // ��Ʒ��ɫ  ��������
        else
          hcolor := clWhite;

        with g_DXCanvas do
        begin  
               //SetBkMode (Handle, TRANSPARENT);
          FColor := clYellow;
          TextOut(SurfaceX(Left + 37), SurfaceY(Top + 272), iname, FColor);
          FColor := hcolor;
          TextOut(SurfaceX(Left + 37 + TextWidth(iname)), SurfaceY(Top + 272), d1, FColor); //+35
          TextOut(SurfaceX(Left + 37), SurfaceY(Top + 272 + TextHeight('A') + 2), d2, FColor);
          TextOut(SurfaceX(Left + 37), SurfaceY(Top + 272 + (TextHeight('A') + 2) * 2), d3 + d4, FColor);
               //Release;
        end;

            // 2003/03/15 ��ʾ������
            //Str := iname + d1 + '\' + d2 + '\' + d3 + d4;
            //DScreen.ShowHint(MouseX, MouseY, Str, hcolor, FALSE);
      end;
      MouseItem.S.Name := '';
    end
    else if not UserState1.bExistLover then
      DScreen.ClearHint(True); //@@@@@

      //���ֺ��л�
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
      FColor := UserState1.NameColor;
      TextOut(SurfaceX(Left + 122 - TextWidth(UserState1.UserName) div 2), SurfaceY(Top + 23), UserState1.UserName, FColor);
      FColor := clSilver;
      TextOut(SurfaceX(Left + 45), SurfaceY(Top + 58), UserState1.GuildName + ' ' + UserState1.GuildRankName, FColor);
      tx := 122 - TextWidth(UserState1.UserName) div 2;
         //Release;
    end;

  end;
  DHeartImgUS.Left := tx - 14;
  DHeartImgUS.Top := 24; //@@@@@

end;

procedure TFrmDlg.DUserState1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  X := DUserState1.LocalX(X) - DUserState1.Left;
  Y := DUserState1.LocalY(Y) - DUserState1.Top;
  if (X > 42) and (X < 201) and (Y > 54) and (Y < 71) then
  begin
      //DScreen.AddSysMsg (IntToStr(X) + ' ' + IntToStr(Y) + ' ' + UserState1.GuildName);
    if UserState1.GuildName <> '' then
    begin
      PlayScene.EdChat.Visible := TRUE;
      PlayScene.EdChat.SetFocus;
      SetImeMode(PlayScene.EdChat.Handle, LocalLanguage);
      PlayScene.EdChat.Text := UserState1.GuildName;
      PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
      PlayScene.EdChat.SelLength := 0;
    end;
  end
  else if (X > 80) and (X < 160) and (Y > 18) and (Y < 38) then
  begin
    if UserState1.UserName <> '' then
    begin
      PlayScene.EdChat.Visible := TRUE;
      PlayScene.EdChat.SetFocus;
      SetImeMode(PlayScene.EdChat.Handle, LocalLanguage);
      PlayScene.EdChat.Text := '/' + UserState1.UserName + ' ';
      PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
      PlayScene.EdChat.SelLength := 0;
    end;
  end;

end;

procedure TFrmDlg.DUserState1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  MouseUserStateItem.S.Name := '';
  if UserState1.bExistLover then
  begin
    X := DUserState1.LocalX(X) - DUserState1.Left;
    Y := DUserState1.LocalY(Y) - DUserState1.Top;
    if (X > 80) and (X < 160) and (Y > 18) and (Y < 38) then
      DScreen.ShowHint(DUserState1.Left + DHeartImgUS.Left + 10, DUserState1.Top + DHeartImgUS.Top + 14, UserState1.LoverName + '�İ���', clWhite, FALSE)
    else if Y < 200 then
      DScreen.ClearHint(True);
  end;

end;

procedure TFrmDlg.DWeaponUS1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  sel: integer;
begin
  sel := -1;
  if Sender = DDressUS1 then
    sel := U_DRESS;
  if Sender = DWeaponUS1 then
    sel := U_WEAPON;
  if Sender = DHelmetUS1 then
    sel := U_HELMET;
  if Sender = DNecklaceUS1 then
    sel := U_NECKLACE;
  if Sender = DLightUS1 then
    sel := U_RIGHTHAND;
  if Sender = DRingLUS1 then
    sel := U_RINGL;
  if Sender = DRingRUS1 then
    sel := U_RINGR;
  if Sender = DArmRingLUS1 then
    sel := U_ARMRINGL;
  if Sender = DArmRingRUS1 then
    sel := U_ARMRINGR;
   // 2003/03/15 ������ �κ��丮 Ȯ��
  if Sender = DBujukUS1 then
    sel := U_BUJUK;
  if Sender = DBeltUS1 then
    sel := U_BELT;
  if Sender = DBootsUS1 then
    sel := U_BOOTS;
  if Sender = DCharmUS1 then
    sel := U_CHARM;

  if sel >= 0 then
  begin
    MouseUserStateItem := UserState1.UseItems[sel];
      // 2003/03/15 ������ �κ��丮 Ȯ��
    MouseX := DUserState1.Left + X;
    MouseY := DUserState1.Top + Y;
  end;

end;

procedure TFrmDlg.DCloseUS1Click(Sender: TObject; X, Y: Integer);
begin
  DUserState1.Visible := FALSE;
end;

procedure TFrmDlg.DNecklaceUS1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  idx: integer;
  d: TDXTexture;
begin
  if Sender = DNecklaceUS1 then
  begin
    if UserState1.UseItems[U_NECKLACE].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_NECKLACE].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DNecklaceUS1.SurfaceX(DNecklaceUS1.Left + (DNecklaceUS1.Width - d.Width) div 2), DNecklaceUS1.SurfaceY(DNecklaceUS1.Top + (DNecklaceUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DLightUS1 then
  begin
    if UserState1.UseItems[U_RIGHTHAND].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_RIGHTHAND].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DLightUS1.SurfaceX(DLightUS1.Left + (DLightUS1.Width - d.Width) div 2), DLightUS1.SurfaceY(DLightUS1.Top + (DLightUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DArmRingRUS1 then
  begin
    if UserState1.UseItems[U_ARMRINGR].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_ARMRINGR].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DArmRingRUS1.SurfaceX(DArmRingRUS1.Left + (DArmRingRUS1.Width - d.Width) div 2), DArmRingRUS1.SurfaceY(DArmRingRUS1.Top + (DArmRingRUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DArmRingLUS1 then
  begin
    if UserState1.UseItems[U_ARMRINGL].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_ARMRINGL].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DArmRingLUS1.SurfaceX(DArmRingLUS1.Left + (DArmRingLUS1.Width - d.Width) div 2), DArmRingLUS1.SurfaceY(DArmRingLUS1.Top + (DArmRingLUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DRingRUS1 then
  begin
    if UserState1.UseItems[U_RINGR].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_RINGR].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DRingRUS1.SurfaceX(DRingRUS1.Left + (DRingRUS1.Width - d.Width) div 2), DRingRUS1.SurfaceY(DRingRUS1.Top + (DRingRUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DRingLUS1 then
  begin
    if UserState1.UseItems[U_RINGL].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_RINGL].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DRingLUS1.SurfaceX(DRingLUS1.Left + (DRingLUS1.Width - d.Width) div 2), DRingLUS1.SurfaceY(DRingLUS1.Top + (DRingLUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
   // 2003/03/15 ������ �κ��丮 Ȯ��
  if Sender = DBujukUS1 then
  begin
    if UserState1.UseItems[U_BUJUK].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_BUJUK].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DBujukUS1.SurfaceX(DBujukUS1.Left + (DBujukUS1.Width - d.Width) div 2), DBujukUS1.SurfaceY(DBujukUS1.Top + (DBujukUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DBeltUS1 then
  begin
    if UserState1.UseItems[U_BELT].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_BELT].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DBeltUS1.SurfaceX(DBeltUS1.Left + (DBeltUS1.Width - d.Width) div 2), DBeltUS1.SurfaceY(DBeltUS1.Top + (DBeltUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DBootsUS1 then
  begin
    if UserState1.UseItems[U_BOOTS].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_BOOTS].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DBootsUS1.SurfaceX(DBootsUS1.Left + (DBootsUS1.Width - d.Width) div 2), DBootsUS1.SurfaceY(DBootsUS1.Top + (DBootsUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;
  if Sender = DCharmUS1 then
  begin
    if UserState1.UseItems[U_CHARM].s.Name <> '' then
    begin
      idx := UserState1.UseItems[U_CHARM].s.Looks;
      if idx >= 0 then
      begin
        d := WStateItem.Images[idx];
        if d <> nil then
          dsurface.Draw(DCharmUS1.SurfaceX(DCharmUS1.Left + (DCharmUS1.Width - d.Width) div 2), DCharmUS1.SurfaceY(DCharmUS1.Top + (DCharmUS1.Height - d.Height) div 2), d.ClientRect, d, TRUE);
      end;
    end;
  end;

end;

procedure TFrmDlg.ShowGuildDlg;
begin
  DGuildDlg.Visible := TRUE;  //not DGuildDlg.Visible;
  DGuildDlg.Top := -3;
  DGuildDlg.Left := 0;
  if DGuildDlg.Visible then
  begin
    if GuildCommanderMode then
    begin
      DGDAddMem.Visible := TRUE;
      DGDDelMem.Visible := TRUE;
      DGDEditNotice.Visible := TRUE;
      DGDEditGrade.Visible := TRUE;
      DGDAlly.Visible := TRUE;
      DGDBreakAlly.Visible := TRUE;
      DGDWar.Visible := TRUE;
      DGDCancelWar.Visible := TRUE;
    end
    else
    begin
      DGDAddMem.Visible := FALSE;
      DGDDelMem.Visible := FALSE;
      DGDEditNotice.Visible := FALSE;
      DGDEditGrade.Visible := FALSE;
      DGDAlly.Visible := FALSE;
      DGDBreakAlly.Visible := FALSE;
      DGDWar.Visible := FALSE;
      DGDCancelWar.Visible := FALSE;
    end;

  end;
  GuildTopLine := 0;
end;

procedure TFrmDlg.ShowGuildEditNotice;
var
  d: TDXTexture;
  i: integer;
  data: string;
begin
  with DGuildEditNotice do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
    begin
      Left := (g_FScreenWidth - d.Width) div 2;
      Top := (g_FScreenHeight - d.Height) div 2;
    end;
    HideAllControls;
    DGuildEditNotice.ShowModal;

    Memo.Left := SurfaceX(Left + 16);
    Memo.Top := SurfaceY(Top + 36);
    Memo.Width := 571;
    Memo.Height := 246;
    Memo.Lines.Assign(GuildNotice);
    Memo.ReadOnly := False;
    Memo.Visible := TRUE;

    while TRUE do
    begin
      if not DGuildEditNotice.Visible then
        break;
      frmMain.AppOnIdle();
      Application.ProcessMessages;
      if Application.Terminated then
        exit;
    end;

    DGuildEditNotice.Visible := FALSE;
    RestoreHideControls;

    if DMsgDlg.DialogResult = mrOk then
    begin
         //���... ���İ��������� ������Ʈ �Ѵ�.
      data := '';
      for i := 0 to Memo.Lines.Count - 1 do
      begin
        if Memo.Lines[i] = '' then
          data := data + Memo.Lines[i] + ' '#13
        else
          data := data + Memo.Lines[i] + #13;
      end;
      if Length(data) > 4000 then
      begin
        data := Copy(data, 1, 4000);
        DMessageDlg('�������ݳ������ƴ�С���������ݽ����ض̣�', [mbOk]);
      end;
      FrmMain.SendGuildUpdateNotice(data);
    end;
  end;
end;

procedure TFrmDlg.ShowGuildEditGrade;
var
  d: TDXTexture;
  data: string;
  i: integer;
begin
  if GuildMembers.Count <= 0 then
  begin
    DMessageDlg('���ȵ�� [�б�] �༭�����Ա��Ϣ��', [mbOk]);
    exit;
  end;

  with DGuildEditNotice do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
    begin
      Left := (g_FScreenWidth - d.Width) div 2;
      Top := (g_FScreenHeight - d.Height) div 2;
    end;
    HideAllControls;
    DGuildEditNotice.ShowModal;
    DGuildEditNotice.KeyFocus := True;
    Memo.Left := SurfaceX(Left + 16);
    Memo.Top := SurfaceY(Top + 36);
    Memo.Width := 571;
    Memo.Height := 246;
    Memo.Lines.Assign(GuildMembers);
    Memo.Visible := TRUE;
    Memo.SetFocus;

    while TRUE do
    begin
      if not DGuildEditNotice.Visible then
        break;
      frmMain.AppOnIdle();
      Application.ProcessMessages;
      if Application.Terminated then
        exit;
    end;

    DGuildEditNotice.Visible := FALSE;
    RestoreHideControls;

    if DMsgDlg.DialogResult = mrOk then
    begin
         //GuildMembers.Assign (Memo.Lines);
         //���... ���ɸ���
      data := '';
      for i := 0 to Memo.Lines.Count - 1 do
      begin
        data := data + Memo.Lines[i] + #13;  //�ڷ������ϴ���
      end;
      if Length(data) > 5000 then
      begin
        data := Copy(data, 1, 5000);
        DMessageDlg('���ݳ������ƴ�С�����ݽ����ض̣�', [mbOk]);
      end;
      FrmMain.SendGuildUpdateGrade(data);
    end;
  end;
end;

procedure TFrmDlg.DGuildDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  i, n, bx, by: integer;
  FColor: tColor;
begin
  with DGuildDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    with g_DXCanvas do
    begin
         //SetBkMode (Handle, TRANSPARENT);
      FColor := clWhite;
      TextOut(Left + 320, Top + 13, Guild, FColor);

      bx := Left + 24;
      by := Top + 41;
      for i := GuildTopLine to GuildStrs.Count - 1 do
      begin
        n := i - GuildTopLine;
        if n * 14 > 356 then
          break;
        if Integer(GuildStrs.Objects[i]) <> 0 then
          FColor := TColor(GuildStrs.Objects[i])
        else
        begin
          if BoGuildChat then
            FColor := GetRGB(2)
          else
            FColor := clSilver;
        end;
        TextOut(bx, by + n * 14, GuildStrs[i], FColor);
      end;

         //Release;
    end;

  end;
end;

procedure TFrmDlg.DGDUpClick(Sender: TObject; X, Y: Integer);
begin
  if GuildTopLine > 0 then
    Dec(GuildTopLine, 3);
  if GuildTopLine < 0 then
    GuildTopLine := 0;
end;

procedure TFrmDlg.DGDDownClick(Sender: TObject; X, Y: Integer);
begin
  if GuildTopLine + 12 < GuildStrs.Count then
    Inc(GuildTopLine, 3);
end;

procedure TFrmDlg.DGDCloseClick(Sender: TObject; X, Y: Integer);
begin
  DGuildDlg.Visible := FALSE;
  BoGuildChat := FALSE;
end;

procedure TFrmDlg.DGDHomeClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount > querymsgtime then
  begin
    querymsgtime := GetTickCount + 3000;
    FrmMain.SendGuildHome;
    BoGuildChat := FALSE;
  end;
end;

procedure TFrmDlg.DGDListClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount > querymsgtime then
  begin
    querymsgtime := GetTickCount + 3000;
    FrmMain.SendGuildMemberList;
    BoGuildChat := FALSE;
  end;
end;

procedure TFrmDlg.DGDAddMemClick(Sender: TObject; X, Y: Integer);
begin
  DMessageDlg(Guild + '���������Ϊ�л��Ա�Ľ�ɫ��.', [mbOk, mbAbort]);
  if DlgEditText <> '' then
    FrmMain.SendGuildAddMem(DlgEditText);
end;

procedure TFrmDlg.DGDDelMemClick(Sender: TObject; X, Y: Integer);
begin
  DMessageDlg(Guild + '����������л���ɾ���Ľ�ɫ��.', [mbOk, mbAbort]);
  if DlgEditText <> '' then
    FrmMain.SendGuildDelMem(DlgEditText);
end;

procedure TFrmDlg.DGDEditNoticeClick(Sender: TObject; X, Y: Integer);
begin
  GuildEditHint := '[�޸��лṫ������.]';
  ShowGuildEditNotice;
  PlayScene.EdChat.SetFocus;    //�л�༭�򽹵�����
end;

procedure TFrmDlg.DGDEditGradeClick(Sender: TObject; X, Y: Integer);
begin
  GuildEditHint := '[�޸��л��Ա�ĵȼ���ְλ�� # ���� : ���������л��Ա/ɾ���л��Ա.]';
  ShowGuildEditGrade;
end;

procedure TFrmDlg.DGDAllyClick(Sender: TObject; X, Y: Integer);
begin
  if mrOk = DMessageDlg('�ͶԷ��л����Ӧ���� [�������]״̬��.\' + '������Ӧ����ԶԷ��л�����.\' + '���������', [mbOk, mbCancel]) then
    FrmMain.SendSay('@����');
end;

procedure TFrmDlg.DGDBreakAllyClick(Sender: TObject; X, Y: Integer);
begin
  DMessageDlg('���������ȡ�����˵��л�����֡�', [mbOk, mbAbort]);
  if DlgEditText <> '' then
    FrmMain.SendSay('@ȡ������ ' + DlgEditText);
end;

procedure TFrmDlg.DGuildEditNoticeDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DGuildEditNotice do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    with g_DXCanvas do
    begin
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clSilver;

      TextOut(Left + 18, Top + 291, GuildEditHint, clSilver);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DGECloseClick(Sender: TObject; X, Y: Integer);
begin
  DGuildEditNotice.Visible := FALSE;
  Memo.Visible := FALSE;
  DMsgDlg.DialogResult := mrCancel;
end;

procedure TFrmDlg.DGEOkClick(Sender: TObject; X, Y: Integer);
begin
  DGECloseClick(self, 0, 0);
  DMsgDlg.DialogResult := mrOk;
end;

procedure TFrmDlg.AddGuildChat(str: string);
var
  i: integer;
begin
  GuildChats.Add(str);
  if GuildChats.Count > 500 then
  begin
    for i := 0 to 100 do
      GuildChats.Delete(0);
  end;
  if BoGuildChat then
    GuildStrs.Assign(GuildChats);
end;

procedure TFrmDlg.AutoCRYClick(Sender: TObject; X, Y: Integer);
begin
  g_boAutoTalk := not g_boAutoTalk;
  if g_boAutoTalk then begin
     g_sAutoTalkStr := PlayScene.EdChat.Text;
     DScreen.AddChatBoardString('�������Զ��������ܣ�������е������Ѽ�¼Ϊ��������', GetRGB(219), clWhite)
  end else begin
     g_sAutoTalkStr := '';
     DScreen.AddChatBoardString('�Զ����������ѹر�', GetRGB(219), clWhite)
  end;
end;

procedure TFrmDlg.DGDChatClick(Sender: TObject; X, Y: Integer);
begin
  BoGuildChat := not BoGuildChat;
  if BoGuildChat then
  begin
    GuildStrs2.Assign(GuildStrs);
    GuildStrs.Assign(GuildChats);
  end
  else
    GuildStrs.Assign(GuildStrs2);
end;

procedure TFrmDlg.DGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  if Myself = nil then
    exit;
  with dgold do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;


{--------------------------------------------------------------}
//�ɷ�ġ ���� â

procedure TFrmDlg.DAdjustAbilCloseClick(Sender: TObject; X, Y: Integer);
begin
  DAdjustAbility.Visible := FALSE;
  BonusPoint := SaveBonusPoint;
end;

procedure TFrmDlg.DAdjustAbilityDirectPaint(Sender: TObject; dsurface: TDXTexture);

  procedure AdjustAb(abil: byte; val: word; var lov, hiv: byte);
  var
    lo, hi: byte;
    i: integer;
  begin
    lo := Lobyte(abil);
    hi := Hibyte(abil);
    lov := 0;
    hiv := 0;
    for i := 1 to val do
    begin
      if lo + 1 < hi then
      begin
        Inc(lo);
        Inc(lov);
      end
      else
      begin
        Inc(hi);
        Inc(hiv);
      end;
    end;
  end;

var
  d: TDXTexture;
  l, m, adc, amc, asc, aac, amac: integer;
  ldc, lmc, lsc, lac, lmac, hdc, hmc, hsc, hac, hmac: byte;
  FColor: TColor;
begin
  if Myself = nil then
    exit;
  with g_DXCanvas do
  begin
    with DAdjustAbility do
    begin
      d := DMenuDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

      //SetBkMode (Handle, TRANSPARENT);
//      Font.Color := clSilver;

    l := DAdjustAbility.SurfaceX(DAdjustAbility.Left) + 36;
    m := DAdjustAbility.SurfaceY(DAdjustAbility.Top) + 22;

    TextOut(l, m, '��ϲ: ���Ѿ�������һ���ȼ���!.', clSilver);
    TextOut(l, m + 14, 'ѡ��������ߵ�������', clSilver);
    TextOut(l, m + 14 * 2, '������ѡ����ֻ������һ�Ρ�', clSilver);
    TextOut(l, m + 14 * 3, '����ܺ�С�ĵ�ѡ��.', clSilver);

      //Ŀǰ������ֵ
    l := DAdjustAbility.SurfaceX(DAdjustAbility.Left) + 100; //66;
    m := DAdjustAbility.SurfaceY(DAdjustAbility.Top) + 101;

    adc := (BonusAbil.DC + BonusAbilChg.DC) div BonusTick.DC;
    amc := (BonusAbil.MC + BonusAbilChg.MC) div BonusTick.MC;
    asc := (BonusAbil.SC + BonusAbilChg.SC) div BonusTick.SC;
    aac := (BonusAbil.AC + BonusAbilChg.AC) div BonusTick.AC;
    amac := (BonusAbil.MAC + BonusAbilChg.MAC) div BonusTick.MAC;

    AdjustAb(NakedAbil.DC, adc, ldc, hdc);
    AdjustAb(NakedAbil.MC, amc, lmc, hmc);
    AdjustAb(NakedAbil.SC, asc, lsc, hsc);
      //AdjustAb (NakedAbil.AC, aac, lac, hac);
      //AdjustAb (NakedAbil.MAC, amac, lmac, hmac);
    lac := 0;
    hac := aac;
    lmac := 0;
    hmac := amac;

    TextOut(l + 0, m + 0, IntToStr(Lobyte(Myself.Abil.DC) + ldc) + '-' + IntToStr(Hibyte(Myself.Abil.DC) + hdc), clWhite);
    TextOut(l + 0, m + 20, IntToStr(Lobyte(Myself.Abil.MC) + lmc) + '-' + IntToStr(Hibyte(Myself.Abil.MC) + hmc), clWhite);
    TextOut(l + 0, m + 40, IntToStr(Lobyte(Myself.Abil.SC) + lsc) + '-' + IntToStr(Hibyte(Myself.Abil.SC) + hsc), clWhite);
    TextOut(l + 0, m + 60, IntToStr(Lobyte(Myself.Abil.AC) + lac) + '-' + IntToStr(Hibyte(Myself.Abil.AC) + hac), clWhite);
    TextOut(l + 0, m + 80, IntToStr(Lobyte(Myself.Abil.MAC) + lmac) + '-' + IntToStr(Hibyte(Myself.Abil.MAC) + hmac), clWhite);
    TextOut(l + 0, m + 100, IntToStr(Myself.Abil.MaxHP + (BonusAbil.HP + BonusAbilChg.HP) div BonusTick.HP), clWhite);
    TextOut(l + 0, m + 120, IntToStr(Myself.Abil.MaxMP + (BonusAbil.MP + BonusAbilChg.MP) div BonusTick.MP), clWhite);
    TextOut(l + 0, m + 140, IntToStr(MyHitPoint + (BonusAbil.Hit + BonusAbilChg.Hit) div BonusTick.Hit), clWhite);
    TextOut(l + 0, m + 160, IntToStr(MySpeedPoint + (BonusAbil.Speed + BonusAbilChg.Speed) div BonusTick.Speed), clWhite);

    TextOut(l + 0, m + 180, IntToStr(BonusPoint), clYellow);

    l := DAdjustAbility.SurfaceX(DAdjustAbility.Left) + 155; //66;
    m := DAdjustAbility.SurfaceY(DAdjustAbility.Top) + 101;

    if BonusAbilChg.DC > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 0, IntToStr(BonusAbilChg.DC + BonusAbil.DC) + '/' + IntToStr(BonusTick.DC), FColor);

    if BonusAbilChg.MC > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 20, IntToStr(BonusAbilChg.MC + BonusAbil.MC) + '/' + IntToStr(BonusTick.MC), FColor);

    if BonusAbilChg.SC > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 40, IntToStr(BonusAbilChg.SC + BonusAbil.SC) + '/' + IntToStr(BonusTick.SC), FColor);

    if BonusAbilChg.AC > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 60, IntToStr(BonusAbilChg.AC + BonusAbil.AC) + '/' + IntToStr(BonusTick.AC), FColor);

    if BonusAbilChg.MAC > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 80, IntToStr(BonusAbilChg.MAC + BonusAbil.MAC) + '/' + IntToStr(BonusTick.MAC), FColor);

    if BonusAbilChg.HP > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 100, IntToStr(BonusAbilChg.HP + BonusAbil.HP) + '/' + IntToStr(BonusTick.HP), FColor);

    if BonusAbilChg.MP > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 120, IntToStr(BonusAbilChg.MP + BonusAbil.MP) + '/' + IntToStr(BonusTick.MP), FColor);

    if BonusAbilChg.Hit > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 140, IntToStr(BonusAbilChg.Hit + BonusAbil.Hit) + '/' + IntToStr(BonusTick.Hit), FColor);

    if BonusAbilChg.Speed > 0 then
      FColor := clWhite
    else
      FColor := clSilver;
    TextOut(l + 0, m + 160, IntToStr(BonusAbilChg.Speed + BonusAbil.Speed) + '/' + IntToStr(BonusTick.Speed), FColor);

      //Release;
  end;

end;

procedure TFrmDlg.DPlusDCClick(Sender: TObject; X, Y: Integer);
var
  incp: integer;
begin
  if BonusPoint > 0 then
  begin
    if IsKeyPressed(VK_CONTROL) and (BonusPoint > 10) then
      incp := 10
    else
      incp := 1;
    Dec(BonusPoint, incp);
    if Sender = DPlusDC then
      Inc(BonusAbilChg.DC, incp);
    if Sender = DPlusMC then
      Inc(BonusAbilChg.MC, incp);
    if Sender = DPlusSC then
      Inc(BonusAbilChg.SC, incp);
    if Sender = DPlusAC then
      Inc(BonusAbilChg.AC, incp);
    if Sender = DPlusMAC then
      Inc(BonusAbilChg.MAC, incp);
    if Sender = DPlusHP then
      Inc(BonusAbilChg.HP, incp);
    if Sender = DPlusMP then
      Inc(BonusAbilChg.MP, incp);
    if Sender = DPlusHit then
      Inc(BonusAbilChg.Hit, incp);
    if Sender = DPlusSpeed then
      Inc(BonusAbilChg.Speed, incp);
  end;
end;

procedure TFrmDlg.DMinusDCClick(Sender: TObject; X, Y: Integer);
var
  decp: integer;
begin
  if IsKeyPressed(VK_CONTROL) and (BonusPoint - 10 > 0) then
    decp := 10
  else
    decp := 1;
  if Sender = DMinusDC then
    if BonusAbilChg.DC >= decp then
    begin
      Dec(BonusAbilChg.DC, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusMC then
    if BonusAbilChg.MC >= decp then
    begin
      Dec(BonusAbilChg.MC, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusSC then
    if BonusAbilChg.SC >= decp then
    begin
      Dec(BonusAbilChg.SC, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusAC then
    if BonusAbilChg.AC >= decp then
    begin
      Dec(BonusAbilChg.AC, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusMAC then
    if BonusAbilChg.MAC >= decp then
    begin
      Dec(BonusAbilChg.MAC, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusHP then
    if BonusAbilChg.HP >= decp then
    begin
      Dec(BonusAbilChg.HP, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusMP then
    if BonusAbilChg.MP >= decp then
    begin
      Dec(BonusAbilChg.MP, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusHit then
    if BonusAbilChg.Hit >= decp then
    begin
      Dec(BonusAbilChg.Hit, decp);
      Inc(BonusPoint, decp);
    end;
  if Sender = DMinusSpeed then
    if BonusAbilChg.Speed >= decp then
    begin
      Dec(BonusAbilChg.Speed, decp);
      Inc(BonusPoint, decp);
    end;
end;

procedure TFrmDlg.DAdjustAbilOkClick(Sender: TObject; X, Y: Integer);
begin
  FrmMain.SendAdjustBonus(BonusPoint, BonusAbilChg);
  DAdjustAbility.Visible := FALSE;
end;

procedure TFrmDlg.DAdjustAbilityMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i, lx, ly: integer;
  flag: Boolean;
begin
  with DAdjustAbility do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    flag := FALSE;
    if (lx >= 50) and (lx < 150) then
      for i := 0 to 8 do
      begin  //DC,MC,SC..�� ��Ʈ�� ������ �Ѵ�.
        if (ly >= 98 + i * 20) and (ly < 98 + (i + 1) * 20) then
        begin
          DScreen.ShowHint(SurfaceX(Left) + lx + 10, SurfaceY(Top) + ly + 5, AdjustAbilHints[i], clWhite, FALSE);
          flag := TRUE;
          break;
        end;
      end;
    if not flag then
      DScreen.ClearHint(True);
  end;
end;

procedure TFrmDlg.DSServer1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  oldsize, down: integer;
begin
  with Sender as TDButton do
  begin
    if not Downed then
    begin
      d := WLib.Images[FaceIndex];
      down := 0;
    end
    else
    begin
      d := WLib.Images[FaceIndex + 1];
      down := 1;
    end;
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);


      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//      oldsize := g_DXCanvas.Font.Size;
//      g_DXCanvas.Font.Size := 12;
//      g_DXCanvas.Font.Style := [fsBold];
//   g_DXCanvas.TextOut(x - g_DXCanvas.TextWidth(nstr) div 2, y + row * 12, fcolor, nstr);
    g_DXCanvas.TextOut(SurfaceX(Left) + (TDButton(Sender).Width - g_DXCanvas.TextWidth(TDButton(Sender).Caption)) div 2 + down,
                         SurfaceY(Top) + (TDButton(Sender).Height - g_DXCanvas.TextHeight(TDButton(Sender).Caption)) div 2 + down,
                         TDButton(Sender).Caption,
                         GetRGB(150));

//      g_DXCanvas.Font.Size := oldsize;
//      g_DXCanvas.Font.Style := [];
//      g_DXCanvas.//Release;

  end;

end;

// 2003/04/15 ģ��, ���� =============== ���� ������
procedure TFrmDlg.DBotFriendClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowFriendsDlg;
end;

procedure TFrmDlg.DBotFriendDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDButton;
  dd: TDXTexture;
begin
  if Sender is TDButton then
  begin
    d := TDButton(Sender);
    if not d.Downed then
    begin
      dd := d.WLib.Images[d.FaceIndex];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end
    else
    begin
      dd := d.WLib.Images[d.FaceIndex + 1];
      if dd <> nil then
        dsurface.Draw(d.SurfaceX(d.Left), d.SurfaceY(d.Top), dd.ClientRect, dd, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DBotFriendMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DBotFriend do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DBottom.SurfaceX(DBottom.Left) + lx + 13;
    sy := SurfaceY(Top) + DBottom.SurfaceX(DBottom.Top) + ly - 2;
    DScreen.ShowHint(sx, sy, '����(W)', clYellow, FALSE);
  end;
end;

procedure TFrmDlg.ToggleShowFriendsDlg;
begin
  DFriendDlg.Visible := not DFriendDlg.Visible;
end;

procedure TFrmDlg.ToggleShowMailListDlg;
begin
  DMailListDlg.Visible := not DMailListDlg.Visible;
  MailAlarm := false;
end;

procedure TFrmDlg.ToggleShowBlockListDlg;
begin
  DBlockListDlg.Visible := not DBlockListDlg.Visible;
end;

procedure TFrmDlg.ToggleShowMemoDlg;
begin
  DMemo.Visible := not DMemo.Visible;
  MemoMail.Visible := DMemo.Visible;
end;

procedure TFrmDlg.DFriendDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDXTexture;
  lx, ly, n, t, l, ax, ay: integer;
  CurrentPage, maxPage, UpPage, DownPage: integer;
  FColor: TColor;
  str: string;
begin
  if ViewFriends then
  begin
    CurrentPage := FriendPage + 1;
    maxPage := FriendMembers.Count div 10 + 1;
  end
  else
  begin
    CurrentPage := BlackListPage + 1;
    maxPage := BlackMembers.Count div 10 + 1;
  end;

  if CurrentPage > 1 then
    UpPage := CurrentPage - 1
  else
    UpPage := CurrentPage;
  if CurrentPage < maxPage then
    DownPage := CurrentPage + 1
  else
    DownPage := CurrentPage;

  DFrdpgUp.hint := IntToStr(UpPage) + '/' + IntToStr(maxPage);
  DFrdpgDn.hint := IntToStr(DownPage) + '/' + IntToStr(maxPage);

  b := WProgUse.GetCachedImage(534, ax, ay);
  with DFriendDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    if ViewFriends then
    begin
      if FriendMembers.Count > 0 then
      begin
//            //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
        t := FriendPage * 20;
        l := _MIN(FriendPage * 20 + 20, FriendMembers.Count);
        for n := t to l - 1 do
        begin
          if PTFriend(FriendMembers[n]).Status >= 4 then
            FColor := clWhite
          else
            FColor := clSilver;

          lx := SurfaceX(30) + Left + ((n - t) mod 2) * 120;
          ly := SurfaceY(70) + Top + ((n - t) div 2) * 15;

//          if fLover.Find(PTFriend(FriendMembers[n]).CharID) then
//            str := '��' + PTFriend(FriendMembers[n]).CharID     //�������Ǻ����б�����������ǰ�ķ���
//          else
            str := PTFriend(FriendMembers[n]).CharID;

          if n = CurrentFriend then
          begin
            FColor := clBlack;
            g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(str), g_DXCanvas.TextHeight(str), $FFC0C0C0);
//                  g_DXCanvas.Brush.Color := clSilver;
//                  g_DXCanvas.Brush.Style := bsSolid;
          end
          else
          begin
            g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(str), g_DXCanvas.TextHeight(str), $FF000000);
//                  g_DXCanvas.Brush.Color := clBlack;
//                  g_DXCanvas.Brush.Style := bsClear;
          end;

          g_DXCanvas.TextOut(lx, ly, str, FColor);
               //   g_DXCanvas.TextOut (lx, ly,FColor, str);

//             DScreen.AddSysMsg (IntToStr(lx+ax-5) + ' ' + IntToStr(ly+ay+5));
//             dsurface.Draw (SurfaceX(lx+ax-5), SurfaceY(ly+ay+5), b.ClientRect, b, TRUE);

//               g_DXCanvas.Font.Color := clWhite;
          FColor := clWhite;
//               g_DXCanvas.Brush.Style := bsClear;
          lx := SurfaceX(25) + Left;
          ly := SurfaceY(240) + Top;
          g_DXCanvas.TextOut(lx, ly, IntToStr(ConnectFriend) + '/' + IntToStr(FriendMembers.Count), FColor);

        end;
//            g_DXCanvas.//Release;
      end;
    end
    else
    begin
      if BlackMembers.Count > 0 then
      begin
        with g_DXCanvas do
        begin  
               //SetBkMode (Handle, TRANSPARENT);
          FColor := clSilver;
          t := BlackListPage * 20;
          l := _MIN(BlackListPage * 20 + 20, BlackMembers.Count);
          for n := t to l - 1 do
          begin

            if PTFriend(BlackMembers[n]).Status >= 4 then
              FColor := clWhite
            else
              FColor := clSilver;

            lx := SurfaceX(30) + Left + ((n - t) mod 2) * 120;
            ly := SurfaceY(70) + Top + ((n - t) div 2) * 15;

            str := PTFriend(BlackMembers[n]).CharID;
            if n = CurrentBlack then
            begin
              FColor := clBlack;
              g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(str), g_DXCanvas.TextHeight(str), $FFC0C0C0);
//                    g_DXCanvas.Font.Color  := clBlack;
//                    g_DXCanvas.Brush.Color := clSilver;
//                    g_DXCanvas.Brush.Style := bsSolid;
            end
            else
            begin
              g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(str), g_DXCanvas.TextHeight(str), $FF000000);
//                    g_DXCanvas.Brush.Color := clBlack;
//                    g_DXCanvas.Brush.Style := bsClear;
            end;

            TextOut(lx, ly, str, FColor);
            dsurface.Draw(lx + ax - 5, ly + ay + 5, b.ClientRect, b, TRUE);
          end;

          FColor := clWhite;
//               g_DXCanvas.Brush.Style := bsClear;
          lx := SurfaceX(25) + Left;
          ly := SurfaceY(240) + Top;
          g_DXCanvas.TextOut(lx, ly, IntToStr(ConnectBlack) + '/' + IntToStr(BlackMembers.Count), FColor);

               //Release;
        end;
      end;
    end;
      //�̸�
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
      FColor := MySelf.NameColor;
      TextOut(SurfaceX(Left + 134 - TextWidth(MySelf.UserName) div 2), SurfaceY(Top + 13), MySelf.UserName, FColor);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DFrdPgUpClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DFrdPgUp then
  begin
    if ViewFriends then
    begin
      if FriendPage > 0 then
        Dec(FriendPage);
    end
    else
    begin
      if BlackListPage > 0 then
        Dec(BlackListPage);
    end;
  end
  else
  begin
    if ViewFriends then
    begin
      if FriendPage < (FriendMembers.Count + 19) div 20 - 1 then
        Inc(FriendPage);
    end
    else
    begin
      if BlackListPage < (BlackMembers.Count + 19) div 20 - 1 then
        Inc(BlackListPage);
    end;
  end;
end;

procedure TFrmDlg.DFrdPgUpDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if TDButton(Sender).Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DFrdFriendClick(Sender: TObject; X, Y: Integer);
begin
  ViewFriends := TRUE;
  DFriendDlg.hint := '';
end;

procedure TFrmDlg.DFrdBlackListClick(Sender: TObject; X, Y: Integer);
begin
  ViewFriends := FALSE;
  DFriendDlg.hint := '';
end;

procedure TFrmDlg.DFrdAddMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdAdd do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '����', clWhite, FALSE);     //clYellow
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DFrdDelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdDel do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, 'ɾ��', clWhite, FALSE);     //clYellow
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DFrdMemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdMemo do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '����¼', clWhite, FALSE);     //clYellow
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DFrdMailMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdMail do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '�ʼ�', clWhite, FALSE);     //clYellow
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DFrdWhisperMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdWhisper do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '˽��', clWhite, FALSE);     //clYellow
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DFrdCloseClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowFriendsDlg;
end;

procedure TFrmDlg.DFrdFriendDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if ViewFriends then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end
    else
    begin
      d := WLib.Images[FaceIndex + 1];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DFrdBlackListDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if ViewFriends then
    begin
      d := WLib.Images[FaceIndex + 1];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end
    else
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DMailListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDXTexture;
  lx, ly, n, t, l, ax, ay: integer;
  Rect: TRect;
  CurrentPage, maxPage, UpPage, DownPage: integer;
  LockStr: string;
  FColor: TColor;
begin
  CurrentPage := MailPage + 1;
  maxPage := MailLists.Count div 10 + 1;
  if CurrentPage > 1 then
    UpPage := CurrentPage - 1
  else
    UpPage := CurrentPage;
  if CurrentPage < maxPage then
    DownPage := CurrentPage + 1
  else
    DownPage := CurrentPage;

  DMailListPgUp.hint := IntToStr(UpPage) + '/' + IntToStr(maxPage);
  DMailListpgDn.hint := IntToStr(DownPage) + '/' + IntToStr(maxPage);

  b := WProgUse.GetCachedImage(543, ax, ay);
  with DMailListDlg do
  begin
    d := WLib.Images[FaceIndex];

    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    dsurface.Draw(SurfaceX(Left + 15), SurfaceY(Top + 35), b.ClientRect, b, TRUE);

    if MailLists.Count > 0 then
    begin
      t := MailPage * 11;
      l := _MIN(MailPage * 11 + 11, MailLists.Count);

      for n := t to l - 1 do
      begin

        lx := SurfaceX(30) + Left;
        ly := SurfaceY(60) + Top + (n - t) * 15;
        if n = CurrentMail then
        begin
          g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(PTMail(MailLists[n]).Sender), g_DXCanvas.TextHeight(PTMail(MailLists[n]).Sender), $FF808080);
//               g_DXCanvas.Brush.Color := clDkGray ;
//               g_DXCanvas.Brush.Style := bsSolid;
        end
        else
        begin
          g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(PTMail(MailLists[n]).Sender), g_DXCanvas.TextHeight(PTMail(MailLists[n]).Sender), $FF000000);
//               g_DXCanvas.Brush.Color := clBlack;
//               g_DXCanvas.Brush.Style := bsClear;
        end;

        LockStr := '';

        case PTMail(MailLists[n]).Status of
          0:
            FColor := clWhite;
          1:
            FColor := clSilver;
          2:
            begin
              FColor := clWhite;
              LockStr := '[*]';
            end;
          3:
            FColor := clBlue;
        end;

        Rect.Left := lx - 10;
        Rect.Top := ly;
        Rect.Right := lx + 215;
        Rect.Bottom := ly + 15;
//            g_DXCanvas.FillRect(Rect.Left,Rect.Top,Rect.Right,Rect.Bottom,$FFC0C0C0);
        g_DXCanvas.TextOut(lx, ly + 2, PTMail(MailLists[n]).Sender, FColor);

        lx := SurfaceX(145) + Left;
        ly := SurfaceY(60) + Top + (n - t) * 15;

        Rect.Left := lx;
        Rect.Top := ly;
        Rect.Right := lx + 100;
        Rect.Bottom := ly + 15;
        g_DXCanvas.TextRect(Rect, LockStr + StrToVisibleOnly(SqlSafeToStr(PTMail(MailLists[n]).Mail)), FColor);

        FColor := clWhite;
//            g_DXCanvas.Brush.Style := bsClear;
        lx := SurfaceX(25) + Left;
        ly := SurfaceY(240) + Top;
        g_DXCanvas.TextOut(lx, ly, IntToStr(NotReadMailCount) + '/' + IntToStr(MailLists.Count), FColor);

      end;
//         g_DXCanvas.//Release;
    end;

      //�̸�
    with g_DXCanvas do
    begin
         //SetBkMode (Handle, TRANSPARENT);
      FColor := MySelf.NameColor;
      TextOut(SurfaceX(Left + 134 - TextWidth(MySelf.UserName) div 2), SurfaceY(Top + 13), MySelf.UserName, FColor);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DMailListCloseClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowMailListDlg;
end;

procedure TFrmDlg.DMailListPgUpClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DMailListPgUp then
  begin
    if MailPage > 0 then
      Dec(MailPage);
  end
  else
  begin
    if MailPage < (MailLists.Count + 10) div 11 - 1 then
      Inc(MailPage);
  end;
end;

procedure TFrmDlg.DMLReplyMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DMLReply do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '�ظ�', clWhite, FALSE);    //clYellow
  end;
end;

procedure TFrmDlg.DMLReadMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DMLRead do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '�Ķ�', clWhite, FALSE);   //clYellow
  end;
end;

procedure TFrmDlg.DMLDelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DMLDel do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, 'ɾ��', clWhite, FALSE);     //clYellow
  end;
end;

procedure TFrmDlg.DMLLockMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DMLLock do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '����', clWhite, FALSE);    //clYellow
  end;
end;

procedure TFrmDlg.DMLBlockMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DMLBlock do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '�����б�', clWhite, FALSE);     //clYellow
  end;
end;

procedure TFrmDlg.DMailListDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly: integer;
  pos: integer;
begin
  ItemSearchEdit.Visible := False;
  lx := X - DMailListDlg.Left;
  ly := Y - DMailListDlg.Top;
  if (lx > 20) and (lx < 250) and (ly > 60) and (ly < 225) then
  begin
    pos := (ly - 60) div 15 + MailPage * 11;
    if MailLists.Count > pos then
      CurrentMail := pos;
  end;
end;

procedure TFrmDlg.DMailListDlgDblClick(Sender: TObject);
begin
  MailListDlgDblClicked := true;
end;

procedure TFrmDlg.DMailListDlgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not MailListDlgDblClicked then
    Exit;

  MailListDlgDblClicked := false;
  DMLReadClick(nil, 0, 0);
end;

procedure TFrmDlg.DFriendDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly, pos, sx, sy: integer;
begin
  ItemSearchEdit.Visible := False;

  lx := X - DFriendDlg.Left;
  ly := Y - DFriendDlg.Top;
  (Sender as TDWindow).hint := '';
  if (lx > 30) and (lx < 240) and (ly > 70) and (ly < 225) then
  begin

    pos := (lx div 140) + ((ly - 70) div 15) * 2 + FriendPage * 20;
    if ViewFriends then
    begin
      if FriendMembers.Count > pos then
      begin
        CurrentFriend := pos;

        if CurrentFriend >= 0 then
        begin
          (Sender as TDWindow).hint := StrToHint(SqlSafeToStr(PTFriend(FriendMembers[CurrentFriend]).Memo));
        end;
      end;
    end
    else
    begin
      if BlackMembers.Count > pos then
      begin
        CurrentBlack := pos;
        if CurrentBlack >= 0 then
        begin
          (Sender as TDWindow).hint := StrToHint(SqlSafeToStr(PTFriend(BlackMembers[CurrentBlack]).Memo));
        end;
      end;
    end;

  end


//    DScreen.AddSysMsg (IntToStr(lx) + ' ' + IntToStr(ly) + ' ' + IntToStr(pos));
end;

procedure TFrmDlg.DFriendDlgDblClick(Sender: TObject);
begin
  FriendDlgDblClicked := true;
end;

procedure TFrmDlg.DFriendDlgMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not FriendDlgDblClicked then
    Exit;

  FriendDlgDblClicked := false;

  if ViewFriends then
  begin
    if CurrentFriend >= 0 then
    begin
      if (PTFriend(FriendMembers[CurrentFriend]).Status >= 4) then
        DFrdWhisperClick(nil, 0, 0)
      else
        DFrdMailClick(nil, 0, 0);
    end;
  end
  else
  begin
    if CurrentBlack >= 0 then
    begin
      if (PTFriend(BlackMembers[CurrentBlack]).Status >= 4) then
        DFrdWhisperClick(nil, 0, 0)
      else
        DFrdMailClick(nil, 0, 0);
    end;
  end;

end;

procedure TFrmDlg.DBlockListCloseClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowBlockListDlg;
end;

procedure TFrmDlg.DBLPgUpClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DBLPgUp then
  begin
    if BlockPage > 0 then
      Dec(BlockPage);
  end
  else
  begin
    if BlockPage < (BlockLists.Count + 10) div 11 - 1 then
      Inc(BlockPage);
  end;
end;

procedure TFrmDlg.DBlockListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDXTexture;
  lx, ly, n, t, l, ax, ay: integer;
  Rect: TRect;
  CurrentPage, maxPage, UpPage, DownPage: integer;
  FColor: tColor;
begin
  CurrentPage := BlockPage + 1;
  maxPage := BlockLists.Count div 10 + 1;
  if CurrentPage > 1 then
    UpPage := CurrentPage - 1
  else
    UpPage := CurrentPage;
  if CurrentPage < maxPage then
    DownPage := CurrentPage + 1
  else
    DownPage := CurrentPage;

  DBLpgUp.hint := IntToStr(UpPage) + '/' + IntToStr(maxPage);
  DBLpgDn.hint := IntToStr(DownPage) + '/' + IntToStr(maxPage);

  b := WProgUse.GetCachedImage(542, ax, ay);
  with DBlockListDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    dsurface.Draw(SurfaceX(Left + 15), SurfaceY(Top + 35), b.ClientRect, b, TRUE);
    if BlockLists.Count > 0 then
    begin
//         //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      t := BlockPage * 11;
      l := _MIN(BlockPage * 11 + 11, BlockLists.Count);
      for n := t to l - 1 do
      begin

        lx := SurfaceX(30) + Left + ((n - t) mod 2) * 120;
        ly := SurfaceY(70) + Top + ((n - t) div 2) * 15;
        if n = CurrentBlock then
        begin
          FColor := clBlack;
          g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(BlockLists[n]), g_DXCanvas.TextHeight(BlockLists[n]), $FF808080);
//               g_DXCanvas.Font.Color  := clBlack;
//               g_DXCanvas.Brush.Color := clGray;
//               g_DXCanvas.Brush.Style := bsSolid;
        end
        else
        begin
          FColor := clSilver;
          g_DXCanvas.FillRect(lx, ly, g_DXCanvas.TextWidth(BlockLists[n]), g_DXCanvas.TextHeight(BlockLists[n]), $FF000000);
//               g_DXCanvas.Font.Color  := clSilver;
//               g_DXCanvas.Brush.Color := clBlack;
//               g_DXCanvas.Brush.Style := bsClear;
        end;

        g_DXCanvas.TextOut(lx, ly, BlockLists[n], FColor);

//            lx := SurfaceX(30) + Left;
//            ly := SurfaceY(60) + Top  + (n-t) * 15;
//            Rect.Left  := lx - 10;    Rect.Top    := ly;
//            Rect.Right := lx + 215;   Rect.Bottom := ly + 14;
//            g_DXCanvas.FillRect(Rect);
//            g_DXCanvas.TextOut (lx, ly, BlockLists[n]);

      end;
//         g_DXCanvas.//Release;
    end;
      //������
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
      FColor := MySelf.NameColor;
      TextOut(SurfaceX(Left + 134 - TextWidth(MySelf.UserName) div 2), SurfaceY(Top + 13), MySelf.UserName, FColor);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DBlockListDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly: integer;
  pos: integer;
begin
  ItemSearchEdit.Visible := False;

  lx := X - DBlockListDlg.Left;
  ly := Y - DBlockListDlg.Top;
  if (lx > 20) and (lx < 250) and (ly > 60) and (ly < 225) then
  begin
    pos := (lx div 140) + ((ly - 70) div 15) * 2 + FriendPage * 20;
//       pos := (ly - 60) div 15 + BlockPage * 11;
    if BlockLists.Count > pos then
      CurrentBlock := pos;
  end;
end;

procedure TFrmDlg.DBLAddMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DBLAdd do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DBlockListDlg.SurfaceX(DBlockListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DBlockListDlg.SurfaceX(DBlockListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '���������б�', clWhite, FALSE);    //clYellow
  end;
end;

procedure TFrmDlg.DBLDelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DBLDel do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DBlockListDlg.SurfaceX(DBlockListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DBlockListDlg.SurfaceX(DBlockListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, 'ɾ��', clWhite, FALSE);  //clYellow
  end;
end;

procedure TFrmDlg.DMLBlockClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowBlockListDlg;
end;

procedure TFrmDlg.DBotMemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DBotMemo do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DBottom.SurfaceX(DBottom.Left) + lx + 8;
    sy := SurfaceY(Top) + DBottom.SurfaceX(DBottom.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '�ʼ���(M)', clWhite, FALSE);   //clYellow
  end;

end;

procedure TFrmDlg.DBotMemoClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowMailListDlg;

  if WantMailList = false then
  begin
    FrmMain.SendMailList;
    FrmMain.SendRejectLIst;
    WantMailList := true;
  end;

  MailAlarm := false;

end;

procedure TFrmDlg.AddFriend(FriendName: string; ShowMessage: Boolean);
var
  frdtype: integer;
begin
  if FriendName <> '' then
  begin
      // �ڽ��� ����� �� ����
    if FriendName = MySelf.UserName then
    begin
      if ShowMessage then
        DMessageDlg('�㲻������Լ�', [mbOk]);
      Exit;
    end;

    if FrmMain.IsMyMember(FriendName) then
    begin
      if ShowMessage then
        DMessageDlg(FriendName + '�Ѿ���ӵ��б�', [mbOk]);
      Exit;
    end;

    if ViewFriends then
      frdtype := 1
    else
      frdtype := 8;
    FrmMain.SendAddFriend(FriendName, frdtype);
  end;

end;

procedure TFrmDlg.DFrdAddClick(Sender: TObject; X, Y: Integer);
begin
   { 2003/04/15
   if (not DMemo.Visible) then begin
      ViewWindowNo := 1;
      DMemoB1.SetImgIndex(WProgUse, 544);
      ShowEditMail;
   end;
   }
  // ����� ģ�� �Ǵ� �ǿ��� ������ �����Ѵ�.
  if ViewFriends then
  begin
    if Friendmembers.Count >= MAX_FRIEND_COUNT then
    begin
      DMessageDlg('û�и����λ�ÿ�������ĺ���', [mbOk]);
      Exit;
    end;

  end
  else
  begin
    if Blackmembers.Count >= MAX_FRIEND_COUNT then
    begin
      DMessageDlg('û�и����λ�ÿ���������ĵ���', [mbOk]);
      Exit;
    end;

  end;

  DScreen.ClearHint(True);
  DMessageDlg('�������������ӵ��б������:', [mbOk, mbAbort]);
  AddFriend(DlgEditText, true);

end;

procedure TFrmDlg.DFrdDelClick(Sender: TObject; X, Y: Integer);
var
  delchar: string;
begin
  if ViewFriends then
  begin
    if CurrentFriend >= 0 then
      delchar := PTFriend(FriendMembers[CurrentFriend]).CharID
    else
      Exit;
  end
  else
  begin
    if CurrentBlack >= 0 then
      delchar := PTFriend(BlackMembers[CurrentBlack]).CharID
    else
      Exit;
  end;

  if delchar <> '' then
  begin
    if mrOk = FrmDlg.DMessageDlg(delchar + ' �����������б�ɾ����', [mbOk, mbCancel]) then
    begin
      FrmMain.sendDelFriend(delchar);
    end;
  end;

end;

procedure TFrmDlg.DFrdMailClick(Sender: TObject; X, Y: Integer);
begin

//   if (not DMemo.Visible)then
  begin
    if ViewFriends then
    begin
      if (CurrentFriend < 0) then
        Exit;
      ViewWindowData := CurrentFriend;
      MemoCharID := PTFriend(FriendMembers[ViewWindowData]).CharID;
    end
    else
    begin
      if (CurrentBlack < 0) then
        Exit;
      ViewWindowData := CurrentBlack;
      MemoCharID := PTFriend(BlackMembers[ViewWindowData]).CharID;
    end;

    ViewWindowNo := VIEW_MAILSEND;
    DMemoB1.SetImgIndex(WProgUse, 546);
    DMemoB2.SetImgIndex(WProgUse, 538);
    DMemoB1.Visible := true;
    memoMail.Clear;

    ShowEditMail;
  end;
end;

procedure TFrmDlg.DMLReadClick(Sender: TObject; X, Y: Integer);
var
  str: string;
begin
//   if (not DMemo.Visible) and (CurrentMail >= 0) then begin
  if (CurrentMail >= 0) then
  begin

    ViewWindowNo := VIEW_MAILREAD;
    ViewWindowData := CurrentMail;
    DMemoB1.Visible := false; //.SetImgIndex(WProgUse, 544);
    DMemoB2.SetImgIndex(WProgUse, 544);
    MemoMail.Text := SQlSafeToStr(pTMail(MailLists[CurrentMail]).Mail);
    MemoMail.ReadOnly := true;
    MemoCharID := PTMail(MailLists[ViewWindowData]).Sender;
    str := PTMail(MailLists[ViewWindowData]).Date;
    MemoDate := '20' + str[1] + str[2] + '/' + str[3] + str[4] + '/' + str[5] + str[6] + ' ' + str[7] + str[8] + ':' + str[9] + str[10];
      // �о����� ����
    if (pTMail(MailLists[CurrentMail]).Status = 0) then
      FrmMain.SendReadingMail(pTMail(MailLists[CurrentMail]).Date);

    ShowEditMail;

  end;
end;

procedure TFrmDlg.DFrdMemoClick(Sender: TObject; X, Y: Integer);
begin
//   if (not DMemo.Visible) then
  begin
    if ViewFriends then
    begin
      if (CurrentFriend >= 0) then
      begin
        ViewWindowData := CurrentFriend;
        MemoCharID := PTFriend(FriendMembers[ViewWindowData]).CharID;
        ViewWindowNo := VIEW_MEMO;
        memoMail.Text := SqlSafeToStr(PTFriend(FriendMembers[CurrentFriend]).Memo);
        DMemoB1.SetImgIndex(WProgUse, 544);
        DMemoB2.SetImgIndex(WProgUse, 538);
        DMemoB1.Visible := true;

        ShowEditMail;
      end;
    end
    else
    begin
      if (CurrentBlack >= 0) then
      begin
        ViewWindowData := CurrentBlack;
        MemoCharID := PTFriend(BlackMembers[ViewWindowData]).CharID;
        ViewWindowNo := VIEW_MEMO;
        memoMail.Text := SqlSafeToStr(PTFriend(BlackMembers[CurrentBlack]).Memo);
        DMemoB1.SetImgIndex(WProgUse, 544);
        DMemoB2.SetImgIndex(WProgUse, 538);
        DMemoB1.Visible := true;

        ShowEditMail;
      end;

    end;

  end;
end;

procedure TFrmDlg.DFrdWhisperClick(Sender: TObject; X, Y: Integer);
var
  wisname: string;
  actionchar: char;
begin

  if ViewFriends then
  begin
    if CurrentFriend >= 0 then
      wisname := PTFriend(FriendMembers[CurrentFriend]).CharID
    else
      Exit;
  end
  else
  begin
    if CurrentBlack >= 0 then
      wisname := PTFriend(BlackMembers[CurrentBlack]).CharID
    else
      Exit;
  end;

  PlayScene.EdChat.Visible := FALSE;
  FrmMain.WhisperName := wisname;
//  if FrmMain.WhisperName = Copy(fLover.GetDisplay(0), length(STR_LOVER) + 1, 20) then
//    actionchar := ','
//  else
    actionchar := '/';
  FrmMain.FormKeyPress(Sender, actionchar);
end;

procedure TFrmDlg.DMemoDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDXTexture;
  lx, ly, n, t, l, ax, ay: integer;
  Rect: TRect;
begin
//     if not (Sender As TDWindow).CanFocus then MemoMail.Visible := false
//     else MemoMail.Visible := true;

  case ViewWindowNo of
    VIEW_MAILREAD:
      begin
        memoMail.Left := DMemo.Left + 28;
        memoMail.Top := DMemo.Top + 36 + 14;
        memoMail.Width := 148;
        memoMail.Height := 72 - 14;
      end;
  else
    begin
      memoMail.Left := DMemo.Left + 28;
      memoMail.Top := DMemo.Top + 36;
      memoMail.Width := 148;
      memoMail.Height := 72;
    end;
  end;

  with DMemo do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

      //����...ֽ����ͼ, ���͵����, ����ע�������
    case ViewWindowNo of
      VIEW_FRIEND:  // ����: ���������, ע��: ���������
        begin
          b := WProgUse.GetCachedImage(549 + 1, ax, ay);
        end;
      VIEW_MAILSEND:  // ��λ: �ռ��˷���������������������: ��
        begin
          b := WProgUse.GetCachedImage(549 + 2, ax, ay);

          with g_DXCanvas do
          begin  
             //SetBkMode (Handle, TRANSPARENT);
//             Font.Color := clSilver;
//             MemoCharID := PTFriend(FriendMembers[ViewWindowData]).CharID;
            TextOut(SurfaceX(Left + 140 - TextWidth(MemoCharID) div 2), SurfaceY(Top + 13), MemoCharID, clSilver);
             //Release;
          end;
        end;
      VIEW_MAILREAD:  // ��λ: ��������ʾ���� �����������:�����
        begin
          b := WProgUse.GetCachedImage(549 + 3, ax, ay);

          with g_DXCanvas do
          begin  
//             //SetBkMode (Handle, TRANSPARENT);
//             Brush.Style := bsSolid;
//             Brush.Color := clGray;
//             Font.Color  := clWhite;

//            FillRect(SurfaceX(Left + 28),
//                      SurfaceY(Top + 36),TextWidth(MemoDate) ,TextHeight(MemoDate), $FF808080);

            TextOut(SurfaceX(Left + 28), SurfaceY(Top + 36), MemoDate, clWhite);

//             Brush.Style := bsClear;
//             Font.Color := clSilver;
            MemoCharID := PTMail(MailLists[ViewWindowData]).Sender;


//            FillRect(SurfaceX(Left + 140 - TextWidth(MemoCharID) div 2),
//                    SurfaceY(Top + 13),TextWidth(MemoCharID) ,TextHeight(MemoCharID), $FFC0C0C0);

            TextOut(SurfaceX(Left + 140 - TextWidth(MemoCharID) div 2), SurfaceY(Top + 13), MemoCharID, clSilver);
             //Release;
          end;

        end;
      VIEW_MEMO:  //����: ���ѵ���Ϣ�ϣ�������: ע������
        begin
          b := WProgUse.GetCachedImage(549 + 1, ax, ay);

          with g_DXCanvas do
          begin  
             //SetBkMode (Handle, TRANSPARENT);
//             Font.Color := clSilver;
//             MemoCharID := PTFriend(FriendMembers[ViewWindowData]).CharID;
            TextOut(SurfaceX(Left + 140 - TextWidth(MemoCharID) div 2), SurfaceY(Top + 13), MemoCharID, clSilver);
             //Release;
          end;
        end;
    end;

    dsurface.Draw(SurfaceX(Left + 9), SurfaceY(Top + 7), b.ClientRect, b, TRUE);

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//      g_DXCanvas.Font.Color  := clSilver;
//      if n = CurrentBlock then
//         g_DXCanvas.Brush.Color := clGray
//      else
//         g_DXCanvas.Brush.Color := clBlack;

//      g_DXCanvas.//Release;
  end;
end;

procedure TFrmDlg.ShowEditMail;
var
  d: TDXTexture;
  i: integer;
  data: string;
begin
  with DMemo do
  begin

    d := WLib.Images[FaceIndex];
    if d <> nil then
    begin
//         Left := (SCREENWIDTH - d.Width) div 2;
//         Top := (SCREENHEIGHT - d.Height) div 2;
    end;
    HideAllControls;

      //ע�ⴰ�ڴ�С����
{
      case ViewWindowNo of
      VIEW_MAILREAD:
            begin
            memoMail.Left  := SurfaceX(Left+21);
            memoMail.Top   := SurfaceY(Top+36+14);
            memoMail.Width := 146;
            memoMail.Height:= 72 - 14;
            end;
      else
            begin
            memoMail.Left := SurfaceX(Left+21);
            memoMail.Top  := SurfaceY(Top+36);
            memoMail.Width := 146;
            memoMail.Height := 72;
            end;
      end;
}
      // ��¼������¸������е�������
    if ViewWindowNo = VIEW_MEMO then
    begin
      BackupMemoMail := memoMail.Text;
    end;
    memomail.MaxLength := 80;
    if not memoMail.visible then
      memoMail.Visible := TRUE;

    SetImeMode(MemoMail.Handle, LocalLanguage);

    DMemo.Show;

    while TRUE do
    begin
      if not DMemo.Visible then
        break;
      frmMain.AppOnIdle();
      Application.ProcessMessages;
      if Application.Terminated then
        exit;
    end;

    DMemo.Visible := FALSE;
    RestoreHideControls;

    if DMsgDlg.DialogResult = mrOk then
    begin
         //���... ������ʾ����.
      data := '';
      for i := 0 to Memo.Lines.Count - 1 do
      begin
        if Memo.Lines[i] = '' then
          data := data + Memo.Lines[i] + ' '#13
        else
          data := data + Memo.Lines[i] + #13;
      end;
      data := ConvertEscChar(data);
      if Length(data) > 70 then
      begin
        data := Copy(data, 1, 70);
        DMessageDlg('ժҪ��Ϣ������������������\���Գ������֣�������ʾ������', [mbOk]);
      end;
         //case ViewWindowNo of
         //1: FrmMain.SendAddFriend (data);
         //2: FrmMain.SendMail (data);
         //3: begin end;
         //4: FrmMain.SendUpdateFriend (data);
         //end;
    end;
  end;
end;

function TFrmDlg.ConvertEscChar(str: string): string;
begin
   // Convert...
  Result := str;
end;

procedure TFrmDlg.DMemoCloseClick(Sender: TObject; X, Y: Integer);
begin
  DMemo.Visible := FALSE;
  case ViewWindowNo of
    VIEW_FRIEND:
      begin
        edCharID.Visible := FALSE;
        memoMail.Visible := FALSE;
        memoMail.ReadOnly := FALSE;
      end;
    VIEW_MAILSEND:
      begin
        edCharID.Visible := FALSE;
        memoMail.Visible := FALSE;
        memoMail.ReadOnly := FALSE;
      end;
    VIEW_MAILREAD:
      begin
        memoMail.Visible := FALSE;
        memoMail.ReadOnly := FALSE;
      end;
    VIEW_MEMO:
      begin
        memoMail.Visible := FALSE;
        memoMail.ReadOnly := FALSE;
      end;
  end;
  DMsgDlg.DialogResult := mrCancel;

  SetImeMode(PlayScene.EdChat.Handle, LocalLanguage);
end;

procedure TFrmDlg.DMemoB1DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin

    if TDButton(Sender).Downed then
      d := WLib.Images[FaceIndex + 1]
    else
      d := WLib.Images[FaceIndex];

    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

  end;

end;

procedure TFrmDlg.DMemoB2DirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin

    if TDButton(Sender).Downed then
      d := WLib.Images[FaceIndex + 1]
    else
      d := WLib.Images[FaceIndex];

    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

  end;

end;

procedure TFrmDlg.DMemoB1Click(Sender: TObject; X, Y: Integer);
begin

  // ������ ��Ȳ�ϋ� OK ���� ����
  case ViewWindowNo of
    VIEW_FRIEND:
      begin

      end;
    VIEW_MAILSEND:
      begin
        if MemoMail.Text <> '' then
        begin
          if frmDlg.BoMemoJangwon then
            FrmMain.SendMail(MemoCharID + '/' + MemoCharID2 + '/' + StrToSqlSafe(MemoMail.Text))
          else
            FrmMain.SendMail(MemoCharID + '/' + StrToSqlSafe(MemoMail.Text));
        end
        else
          frmDlg.BoMemoJangwon := False;

      end;
    VIEW_MAILREAD:
      begin

      end;
    VIEW_MEMO:
      begin
        if BackupMemoMail <> MemoMail.Text then
          FrmMain.SendUpdateFriend(MemoCharID + '/' + StrToSqlSafe(MemoMail.Text));
      end;
  end;

  edCharID.Visible := FALSE;
  MemoMail.Visible := FALSE;
  DMemo.Visible := FALSE;
  MemoMail.ReadOnly := FALSE;

  DMsgDlg.DialogResult := mrOK;

  SetImeMode(PlayScene.EdChat.Handle, LocalLanguage);

end;

procedure TFrmDlg.DBLAddClick(Sender: TObject; X, Y: Integer);
begin
  DMessageDlg('�������������ӵ������б����������:', [mbOk, mbAbort]);
  if DlgEditText <> '' then
  begin
    FrmMain.SendAddReject(DlgEditText);
  end;

end;

procedure TFrmDlg.DBLDelClick(Sender: TObject; X, Y: Integer);
begin
  if CurrentBlock < 0 then Exit;
  if mrOk = FrmDlg.DMessageDlg('����Ӹ��б���ɾ����', [mbOk, mbCancel]) then
  begin
    FrmMain.SendDelReject(BlockLists[CurrentBlock]);
  end;
end;

procedure TFrmDlg.DMLReplyClick(Sender: TObject; X, Y: Integer);
begin
  if CurrentMail >= 0 then
  begin
    ViewWindowNo := VIEW_MAILSEND;
    ViewWindowData := CurrentMail;
    DMemoB1.SetImgIndex(WProgUse, 548);
    DMemoB2.SetImgIndex(WProgUse, 538);
    DMemoB1.Visible := true;
    MemoMail.Clear;
    MemoMail.ReadOnly := false;
    MemoCharID := PTMail(MailLists[CurrentMail]).Sender;
    ShowEditMail;
  end;

end;

procedure TFrmDlg.DMLDelClick(Sender: TObject; X, Y: Integer);
begin
  if CurrentMail < 0 then Exit;
  if pTMail(MailLists[CurrentMail]).Status = 2 then
  begin
    FrmDlg.DMessageDlg('�㲻��ɾ���ܱ������ʼ������Ƚ��������', [mbOk]);
    exit;
  end;

  if pTMail(MailLists[CurrentMail]).Status = 3 then
  begin
    FrmDlg.DMessageDlg('�ʼ��Ѿ���ɾ����', [mbOk]);
    exit;
  end;

  if mrOk = FrmDlg.DMessageDlg('����ɾ��ѡ����ʼ���', [mbOk, mbCancel]) then
  begin
    FrmMain.SendDelMail(pTMail(MailLists[CurrentMail]).Date);
  end;

end;

procedure TFrmDlg.DMLLockClick(Sender: TObject; X, Y: Integer);
var
  IsLock: Boolean;
  mstate: Byte;
begin
  if CurrentMail < 0 then Exit;

  mstate := pTMail(MailLists[CurrentMail]).Status;

      // ������ ���̸� ��ۼ� ����
  if (mstate = 3) then
    exit;

  if (mstate = 2) then
    IsLock := TRUE
  else
    IsLock := FALSE;

  if IsLock then
    FrmMain.SendUnLockMail(pTMail(MailLists[CurrentMail]).Date)
  else
    FrmMain.SendLockMail(pTMail(MailLists[CurrentMail]).Date)
end;

procedure TFrmDlg.DFrdPgUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with (Sender as TDbutton) do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, (Sender as TDbutton).Hint, clYellow, FALSE);
  end;

end;

procedure TFrmDlg.DFrdPgDnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with (Sender as TDbutton) do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DFriendDlg.SurfaceX(DFriendDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DFriendDlg.SurfaceX(DFriendDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, (Sender as TDbutton).Hint, clYellow, FALSE);
  end;

end;

procedure TFrmDlg.DMailListPgUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with (Sender as TDbutton) do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, (Sender as TDbutton).Hint, clYellow, FALSE);
  end;

end;

procedure TFrmDlg.DMailListPgDnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with (Sender as TDbutton) do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMailListDlg.SurfaceX(DMailListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMailListDlg.SurfaceX(DMailListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, (Sender as TDbutton).Hint, clYellow, FALSE);
  end;

end;

procedure TFrmDlg.DBLPgUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with (Sender as TDbutton) do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DBlockListDlg.SurfaceX(DBlockListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DBlockListDlg.SurfaceX(DBlockListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, (Sender as TDbutton).Hint, clYellow, FALSE);
  end;

end;

procedure TFrmDlg.DBLPgDnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with (Sender as TDbutton) do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DBlockListDlg.SurfaceX(DBlockListDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DBlockListDlg.SurfaceX(DBlockListDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, (Sender as TDbutton).Hint, clYellow, FALSE);
  end;

end;

procedure TFrmDlg.DFriendDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  if (Sender as TDWindow).hint = '' then
    DScreen.ClearHint(True)
  else
  begin
    with (Sender as TDWindow) do
    begin
      if ViewFriends then
      begin
        lx := 30 + (CurrentFriend mod 2) * 120;
        ly := 82 + ((CurrentFriend mod 20) div 2) * 15;
      end
      else
      begin
        lx := 30 + (CurrentBlack mod 2) * 120;
        ly := 82 + ((CurrentBlack mod 20) div 2) * 15;
      end;

      sx := SurfaceX(Left) + lx;
      sy := SurfaceY(Top) + ly;
      DScreen.ShowHint(sx, sy, (Sender as TDWindow).Hint, clWhite, FALSE);
    end;
  end;
end;

procedure TFrmDlg.DMailListDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.DMailDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.DBlockListDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.DMemoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.DMakeItemDlgOkDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if Downed then
    begin
      d := WLib.Images[FaceIndex];
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DCountDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d, dr: TDXTexture;
  ly, px, py, i: integer;
  str, data: string;
begin
  with Sender as TDWindow do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
    ly := msgly;
    str := MsgText;
    while TRUE do
    begin
      if str = '' then
        break;
      str := GetValidStr3(str, data, ['\']);
      if data <> '' then
        g_DXCanvas.TextOut(SurfaceX(Left + msglx), SurfaceY(Top + ly), data, clWhite{clBlack} );
      ly := ly + 14;
    end;
//      g_DXCanvas.//Release;
  end;
  if not EdCountEdit.Visible then
  begin
    EdCountEdit.Visible := TRUE;
    EdCountEdit.SetFocus;
  end;
end;

function TFrmDlg.DCountMsgDlg(msgstr: string; DlgButtons: TMsgDlgButtons): TModalResult;
var
  lx, ly, i: integer;
  d: TDXTexture;
begin

  msglx := 31;
  msgly := 34;
  lx := 205;
  ly := 136;

  d := WProgUse.Images[660];
  if d <> nil then
  begin
    DCountDlg.SetImgIndex(WProgUse, 660);
    DCountDlg.Left := (g_FScreenWidth - d.Width) div 2;
    DCountDlg.Top := (g_FScreenHeight - d.Height) div 2;
    DCountDlg.Visible := True;
  end;

  MsgText := msgstr;
  DCountDlg.Floating := False;   //��Ϣ������..
  DCountDlg.Left := (g_FScreenWidth - DCountDlg.Width) div 2;
  DCountDlg.Top := (g_FScreenHeight - DCountDlg.Height) div 2;
  DCountDlg.Visible := True;

  DCountDlgCancel.Left := lx;
  DCountDlgCancel.Top := ly;
  DCountDlgCancel.Visible := TRUE;
  lx := lx - 69;

  DCountDlgOk.Left := lx;
  DCountDlgOk.Top := ly;
  DCountDlgOk.Visible := TRUE;
  lx := lx - 69;

  DCountDlgMax.Left := lx;
  DCountDlgMax.Top := ly;
  DCountDlgMax.Visible := TRUE;

  DCountDlgClose.Left := 287;
  DCountDlgClose.Top := 0;
  DCountDlgClose.Visible := True;

  HideAllControls;
  DCountDlg.ShowModal;

  with EdCountEdit do
  begin
    Text := '';
    Width := DCountDlg.Width - 80;
    Left := (g_FScreenWidth - EdCountEdit.Width) div 2 - 8;
    Top := (g_FScreenHeight - EdCountEdit.Height) div 2 + 13;
  end;

  Result := mrOk;

  while TRUE do
  begin
    if not DCountDlg.Visible then
      break;
    frmMain.AppOnIdle();
    Application.ProcessMessages;
    if Application.Terminated then
      exit;
  end;

  EdCountEdit.Visible := TRUE;
  RestoreHideControls;
  DlgEditText := EdCountEdit.Text;
  if PlayScene.EdChat.Visible then
    PlayScene.EdChat.SetFocus;

  EdCountEdit.Visible := FALSE;
  Result := DCountDlg.DialogResult;
end;

procedure TFrmDlg.DCountDlgOkDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if Downed then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DCountDlgOkClick(Sender: TObject; X, Y: Integer);
begin
  if Sender = DCountDlgMax then
  begin
    EdCountEdit.Text := IntToStr(Total);
    DlgEditText := EdCountEdit.Text;
    DCountDlg.DialogResult := mrAll;
  end;
  if Sender = DCountDlgOk then
    DCountDlg.DialogResult := mrOk;
  if Sender = DCountDlgCancel then
    DCountDlg.DialogResult := mrCancel;
  if Sender <> DCountDlgMax then
  begin
    EdCountEdit.Visible := False;
    DCountDlg.Visible := False;
  end;

end;

procedure TFrmDlg.DCountDlgCloseClick(Sender: TObject; X, Y: Integer);
begin
  DCountDlg.DialogResult := mrCancel;
  DCountDlg.Visible := False;
  DCountDlgClose.Downed := False;
end;

procedure TFrmDlg.DMakeItemDlgOkClick(Sender: TObject; X, Y: Integer);
var
  data: string;
begin

  if Sender = DMakeItemDlgOk then
  begin
    DMakeItemDlg.DialogResult := mrOk;
    data := NameMakeItem;
    data := data + '/' + MakeStrMakeItem();
    FrmMain.SendMakeItem(CurMerchant, data);
  end;
  if (Sender = DMakeItemDlgCancel) or (Sender = DMakeItemDlgClose) then
  begin
    DMakeItemDlg.DialogResult := mrCancel;
  end;
  MoveMakeItemToBag;

  DMakeItemDlg.Visible := False;
  DMakeItemDlgClose.Downed := False;

end;

procedure TFrmDlg.DMakeItemDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  if Myself = nil then
    exit;
  with DMakeItemDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

//      GetMouseItemInfo (d0, d1, d2, d3, useable, FALSE);
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clWhite;
      TextOut(SurfaceX(Left + 19), SurfaceY(Top + 60), '�������ȷ������Ҫ����Ʒ', clWhite);
         //Release;
    end;
  end;
end;

function TFrmDlg.MakeItemDlgShow(msgstr: string): TModalResult;
var
  i: integer;
begin

  DMakeItemDlg.Left := 212; //140;//291;
  DMakeItemDlg.Top := 176; //176;

  DMakeItemDlg.Visible := True;

   //������ ���濡 �ܻ��� �ִ��� �˻�
  ArrangeItembag;

end;

procedure TFrmDlg.DMakeitemGridGridPaint(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture);
var
  idx: integer;
  d: TDXTexture;
begin
  idx := ACol + ARow * DMakeitemGrid.ColCount;
  if idx in [0..5] then
  begin
    if MakeItemArr[idx].s.Name <> '' then
    begin
      d := WBagItem.Images[MakeItemArr[idx].s.Looks];
      if d <> nil then
        with DMakeitemGrid do
          dsurface.Draw(SurfaceX(Rect.Left + (ColWidth - d.Width) div 2 - 1), SurfaceY(Rect.Top + (RowHeight - d.Height) div 2 + 1), d.ClientRect, d, TRUE);
            // ������ ��ġ��
      if MakeItemArr[idx].s.OverlapItem > 0 then
      begin
               //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
//               g_DXCanvas.Font.Color := clYellow;

        g_DXCanvas.TextOut(DMakeitemGrid.SurfaceX(Rect.Left + 20), DMakeitemGrid.SurfaceY(Rect.Top + 20), IntToStr(MakeItemArr[idx].dura), clYellow);
//               g_DXCanvas.//Release;
      end;
    end;
  end;

end;

procedure TFrmDlg.DMakeitemGridGridSelect(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  temp: TClientItem;
  mi, idx: integer;
  MsgResult, Count, OrgCount: integer;
  valstr: string;
begin
  MsgResult := mrCancel;
  if not ItemMoving then
  begin
    idx := ACol + ARow * DMakeitemGrid.ColCount;
    if idx in [0..5] then
    begin
      if MakeItemArr[idx].s.Name <> '' then
      begin
        ItemMoving := TRUE;
        MovingItem.Item := MakeItemArr[idx];
        MakeItemArr[idx].s.Name := '';
        ItemClickSound(MovingItem.Item.S);
      end;
    end;
  end
  else
  begin
    mi := MovingItem.Index;
    if mi >= 6 then
    begin //����,���� �°͸�

      if SearchOverlapItem(MovingItem.Item) then
      begin
        CancelItemMoving;
        DMessageDlg('ͬ���������Ʒֻ�ܴ����ظ�һ��.', [mbOk]);
        Exit;
      end;

      ItemClickSound(MovingItem.Item.S);
      OrgCount := MovingItem.Item.Dura;
      MakingDlgItem := MovingItem.Item; //������ ����� ��ٸ��µ��� ����
      if MakingDlgItem.S.OverlapItem > 0 then
      begin
        Total := MovingItem.Item.Dura;
        ItemMoving := FALSE;
        if Total = 1 then
        begin
          DlgEditText := '1';
          MsgResult := mrOk;
        end
        else
          MsgResult := DCountMsgDlg('��ǰ���� ' + IntToStr(MovingItem.Item.Dura) + ' ��.\����Ҫ�һ�����?', [mbOk, mbCancel, mbAbort]);

        ItemMoving := TRUE;
        GetValidStrVal(DlgEditText, valstr, [' ']);
        Count := Str_ToInt(valstr, 0);
        if Count <= 0 then
        begin
          Count := 0;
          MakingDlgItem.S.Name := '';
        end;
        if Count > MovingItem.Item.Dura then
        begin
          Count := MovingItem.Item.Dura;
//                  MovingItem.Item.Dura := 0;
        end;
        if MsgResult = mrOk then
        begin //and (Count > 0) and (Count < MAX_OVERLAPITEM+1 ) then begin
          MakingDlgItem.Dura := word(Count);
          MovingItem.Item.Dura := MovingItem.Item.Dura - Count;
          if MovingItem.Item.Dura = 0 then
          begin
            MovingItem.Item.S.name := '';
            ItemMoving := FALSE;
          end;
        end
        else if MsgResult = mrCancel then
        begin
          CancelItemMoving;
          Exit;
        end;
      end;
      if (not AddMakeItem(MakingDlgItem)) and (MakingDlgItem.S.OverlapItem > 0) then
      begin
        MovingItem.Item.Dura := OrgCount;
      end;
      if ItemMoving then
        CancelItemMoving;
    end;
  end;
  ArrangeItemBag;

end;

procedure TFrmDlg.DMakeitemGridGridMouseMove(Sender: TObject; X, Y: integer; ACol, ARow: Integer; Shift: TShiftState);
var
  idx: integer;
begin
  idx := ACol + ARow * DMakeitemGrid.ColCount;
  if idx in [0..5] then
  begin
    MouseItem := MakeItemArr[idx];
  end;
end;

procedure TFrmDlg.DItemMarketDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);

  function sx(x: integer): integer;
  begin
    Result := DItemMarketDlg.SurfaceX(DItemMarketDlg.Left + x);
  end;

  function sy(y: integer): integer;
  begin
    Result := DItemMarketDlg.SurfaceY(DItemMarketDlg.Top + y);
  end;

var
  i, lh, k, m, n, menuline: integer;
  d, TempSurface: TDXTexture;
  pg: PTMarketITem;
  year, mon, day, hour, min, datestr: string;
  targdate: TDateTime;
  iname, d0, d1, d2, d3, pagestr: string;
  useable: Boolean;
  MouseItemTemp: TClientItem;
  FColor: TColor;
begin
  i := 0;
  pg := nil;

  with g_DXCanvas do
  begin
    with DItemMarketDlg do
    begin
      d := DItemMarketDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      //SetBkMode (Handle, TRANSPARENT);
//      Font.Color := clWhite;

    lh := MAKETLINEHEIGHT;
    menuline := _MIN(MAXMENU, g_Market.Count - MenuTop);

    if g_Market.GetUserMode = 1 then
    begin
      TextOut(sx(186), sy(16), '������Ʒ��', clWhite);
      DMarketMemo.Visible := True;
    end
    else if g_Market.GetUserMode = 2 then
    begin
      TextOut(sx(186), sy(16), '�ҵ���Ʒ��', clWhite);
      DMarketMemo.Visible := False;
    end;

    TextOut(sx(373), sy(16), format('%4d', [(MenuTop + 10) div 10]), clWhite);
    if g_Market.RecvMaxPage < 1 then
      TextOut(sx(403), sy(16), '/ ' + '1', clWhite)
    else
      TextOut(sx(403), sy(16), '/ ' + IntToStr(g_Market.RecvMaxPage), clWhite);
//      TextOut (SX(504), SY(16), GetGoldStr(Myself.Gold));

    TextOut(sx(41), sy(46), '��Ʒ', clWhite);
    TextOut(sx(200), sy(46), '�۸�', clWhite);
    if g_Market.GetUserMode = 2 then
      TextOut(sx(360), sy(46), '״̬', clWhite)
    else
      TextOut(sx(360), sy(46), '����', clWhite);

    for i := MenuTop to MenuTop + menuline - 1 do
    begin
      m := i - MenuTop;
      pg := g_Market.GetItem(i);

      if i = MenuIndex then
      begin
        FColor := clRed;
        TextOut(sx(34), sy(70 + m * lh), char(7), FColor);
        MemoCharID := pg.SellWho;
      end
      else if pg.SellState = 2 then
        FColor := clYellow
      else if pg.UpgCount > 0 then
        FColor := clAqua
      else
        FColor := clWhite;

      if pg <> nil then
      begin
        TextOut(sx(41), sy(70 + MAKETLINEHEIGHT * m), pg.Item.S.Name, FColor);
        TextOut(sx(170), sy(70 + MAKETLINEHEIGHT * m), format('%15s', [GetGoldStr(pg.SellPrice)]), FColor);
        if g_Market.GetUserMode = 2 then
        begin
          if pg.SellState = 1 then
            TextOut(sx(360), sy(70 + MAKETLINEHEIGHT * m), '��������', FColor)
          else if pg.SellState = 2 then
            TextOut(sx(360), sy(70 + MAKETLINEHEIGHT * m), '�������', FColor);
        end
        else
          TextOut(sx(360), sy(70 + MAKETLINEHEIGHT * m),  pg.SellWho, FColor);
      end;
    end;
//      Font.Color := clWhite;
    if (MenuIndex >= 0) and (MenuIndex < g_Market.Count) then
    begin
      pg := g_Market.GetItem(MenuIndex);
      year := Copy(pg.Selldate, 1, 2);
      mon := Copy(pg.Selldate, 3, 2);
      day := Copy(pg.Selldate, 5, 2);
      hour := Copy(pg.Selldate, 7, 2);
      min := Copy(pg.Selldate, 9, 2);
      datestr := '20' + year + '-' + mon + '-' + day + ' ' + hour + ':' + min;
      TextOut(sx(21), sy(275), '�ϼ�����: ' + datestr, clWhite);
      targdate := EncodeDate(StrToInt(year) + 2000, StrToInt(mon), StrToInt(day)) + EncodeTime(StrToInt(hour), StrToInt(min), 0, 0);
      targdate := targdate + 100;
      TextOut(sx(21), sy(292), '��������: ' + FormatDateTime('YYYY-MM-DD', targdate), clWhite);
    end;

    if (MenuIndex >= 0) and (MenuIndex < g_Market.Count) then
    begin
      MouseItemTemp := MouseItem;
      MouseItem := pg.item;
      with DItemMarketDlg do
      begin
        GetMouseItemInfo(iname, d0, d1, d2, d3, useable, FALSE);
        MouseItem := MouseItemTemp;
            //SetBkMode (Handle, TRANSPARENT);

        if iname <> '' then
        begin
          TextOut(sx(228), sy(268), iname, clYellow);
          n := TextWidth(iname);
          FColor := clWhite;
          TextOut(sx(228) + n, sy(268), d0, FColor);
          TextOut(sx(228), sy(268 + 14), d1, FColor);
          TextOut(sx(228), sy(268 + 14 * 2), d2, FColor);
          if not useable then
            FColor := clRed;
          n := TextWidth(d2);
          TextOut(sx(228) + n, sy(268 + 14 * 2), d3, FColor);
        end;
      end;
    end;

      //Release;
  end;

  if (MenuIndex >= 0) and (MenuIndex < g_Market.Count) then
  begin
    pg := g_Market.GetItem(MenuIndex);
    TempSurface := WBagItem.Images[pg.Item.S.Looks];
    if TempSurface <> nil then
      dsurface.Draw(sx(172) + (36 - TempSurface.Width) div 2, sy(274) + (32 - TempSurface.Height) div 2, TempSurface.ClientRect, TempSurface, TRUE);
//         dsurface.Draw (SX(173), SY(275), TempSurface.ClientRect, TempSurface, TRUE);
  end;

  if (ItemSearchEdit.Left <> sx(13)) or (ItemSearchEdit.Top <> sy(328)) then
  begin
    ItemSearchEdit.Left := sx(13);
    ItemSearchEdit.Top := sy(328);
  end;

//   DScreen.ClearHint(True);
//   MouseStateItem.S.Name := '';

end;

procedure TFrmDlg.DItemMarketDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly, idx: integer;
  pg: PTMarketITem;
begin

  pg := nil;
  lx := DItemMarketDlg.LocalX(X) - DItemMarketDlg.Left;
  ly := DItemMarketDlg.LocalY(Y) - DItemMarketDlg.Top;
  if (lx >= 10) and (lx <= 459) and (ly >= 65) and (ly <= 256) then
  begin
    idx := (ly - 70) div MAKETLINEHEIGHT + MenuTop;
    if idx < g_Market.Count then
    begin
      PlaySound(s_glass_button_click);
      MenuIndex := idx;
    end;
  end;

  if (MenuIndex >= 0) and (MenuIndex < g_Market.Count) then
  begin
    pg := g_Market.GetItem(MenuIndex);
    if pg.SellState = 1 then
      MItemSellState := 1 // ������
    else if pg.SellState = 2 then
      MItemSellState := 2; // �������
  end;

end;

procedure TFrmDlg.DItemMarketDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if BoInRect then
  begin
     // DItemMarketDlg.SpotX := X;
     // DItemMarketDlg.SpotY := Y;
  end;
//   DScreen.ClearHint(True);
end;

procedure TFrmDlg.DItemListPrevClick(Sender: TObject; X, Y: Integer);
begin

  MenuIndex := -1;
  if MenuTop > 0 then
  begin
    Dec(MenuTop, MAXMENU);
    if MenuTop < 0 then
      MenuTop := 0;
  end;
  MenuIndex := MenuTop;
  DItemMarketDlgClick(DItemMarketDlg, 0, 0);
end;

procedure TFrmDlg.DItemListNextClick(Sender: TObject; X, Y: Integer);
var
  MaxNum: integer;
begin

  MenuIndex := -1;
  MaxNum := (g_Market.RecvMaxPage) * 10;
  if (MaxNum >= g_Market.Count) and (MaxNum >= (MenuTop + 19)) then
  begin
    Inc(MenuTop, MAXMENU);
    if g_Market.Count <= MenuTop then
      FrmMain.SendGetMarketPageList(CurMerchant, 1, '')
  end;
  MenuIndex := MenuTop;
  DItemMarketDlgClick(DItemMarketDlg, 0, 0);
end;

procedure TFrmDlg.DItemBuyClick(Sender: TObject; X, Y: Integer);
var
  pg: PTMarketITem;
  MsgResult: integer;
begin
  if GetTickCount < LastestClickTime then
    exit; //�������������
  DScreen.ClearHint(True);
  if (MenuIndex >= 0) and (MenuIndex < g_Market.Count) then
  begin
    ItemSearchEdit.Visible := False;
    pg := g_Market.GetItem(MenuIndex);
    if Myself.Gold < pg.SellPrice then
    begin
      MsgResult := DMessageDlg('Ǯ����.', [mbOk, mbCancel]);
      Exit;
    end;
    MsgResult := DMessageDlg(pg.Item.S.Name + ' ������Ʒ ' + IntToStr(pg.SellPrice) + '��ң�', [mbOk, mbCancel]);

    if MsgResult = mrOk then
    begin
      FrmMain.SendBuyMarket(CurMerchant, pg.Index);
      DItemBag.Show; //����ˢ��
    end
    else if MsgResult = mrCancel then
    begin
    end;
  end;
end;

procedure TFrmDlg.DItemMarketCloseClick(Sender: TObject; X, Y: Integer);
begin
   // ί���б��ڹر�ϵͳ��λ���ر��˷�������
  g_Market.Clear;
  FrmMain.SendMarketClose;

  ItemSearchEdit.Visible := FALSE;
  DItemMarketDlg.Visible := FALSE;
  DItemMarketClose.Downed := False;

//   PlayScene.EdChat.SetFocus;
  LocalLanguage := imChinese;  //imSAlpha
  SetImeMode(PlayScene.EdChat.Handle, LocalLanguage);
  LastestClickTime := GetTickCount;

  MemoCharID := '';

end;

procedure TFrmDlg.DMGoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  if Myself = nil then
    exit;
  if DMGold.Visible then
  begin
    with DMGold do
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DItemMarketDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then
    if DItemMarketDlg.Visible then
      CloseItemMarketDlg;

  if Key = 13 then
    DItemFindClick(DItemFind, 0, 0);

  DScreen.ClearHint(True);
  case Key of
    VK_UP:
      begin
        if (MenuTop <= (MenuIndex - 1)) and (MenuIndex <> -1) then
        begin
          Dec(MenuIndex, 1);
          DItemMarketDlgClick(DItemMarketDlg, 0, 0);
        end;
      end;
    VK_DOWN:
      begin
        if (MenuTop + MAXMENU > (MenuIndex + 1)) and (MenuIndex <> -1) and ((MenuIndex + 1) < g_Market.Count) then
        begin
          Inc(MenuIndex, 1);
          DItemMarketDlgClick(DItemMarketDlg, 0, 0);
        end;
      end;
    VK_LEFT:
      begin
        DItemListPrevClick(DItemListPrev, 0, 0);
      end;
    VK_RIGHT:
      begin
        DItemListNextClick(DItemListNext, 0, 0);
      end;
  else

  end;

end;

procedure TFrmDlg.DItemListRefreshClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount < LastestClickTime then
  begin
    DScreen.AddChatBoardString('�����Ӻ�ſ��԰��������ť', clYellow, clRed);
    exit; //�������������
  end;
  DScreen.ClearHint(True);
  MenuIndex := -1;
  MenuTop := 0;
  MenuTopLine := 0;
  FrmMain.SendGetMarketPageList(CurMerchant, 0, '');
  LastestClickTime := GetTickCount + 5000;

end;

procedure TFrmDlg.DItemSellCancelClick(Sender: TObject; X, Y: Integer);
var
  pg: PTMarketITem;
  MsgResult: integer;
begin
  if GetTickCount < LastestClickTime then
    exit; //�������������
  DScreen.ClearHint(True);
  if (MenuIndex >= 0) and (MenuIndex < g_Market.Count) then
  begin
    ItemSearchEdit.Visible := False;
    pg := g_Market.GetItem(MenuIndex);
    if pg.SellState = 1 then
    begin
      MsgResult := DMessageDlg('����ȡ���ϼ��ṩ�� ' + pg.Item.S.Name + ' ��', [mbOk, mbCancel]);
      if MsgResult = mrOk then
      begin
        FrmMain.SendCancelMarket(CurMerchant, pg.Index);
        DItemBag.Show;
      end;
    end
    else if pg.SellState = 2 then
    begin
      MsgResult := DMessageDlg('�𾴵�����:\    ��л��ʹ������ϵͳ����������ȡ���������������� \���ǽ���ȡ1%��Ӷ��Ӷ���Զ������۽���п۳�.', [mbOk, mbCancel]);
      if MsgResult = mrOk then
        FrmMain.SendGetPayMarket(CurMerchant, pg.Index);
    end;
    MItemSellState := 0;
  end;
end;

procedure TFrmDlg.DItemFindClick(Sender: TObject; X, Y: Integer);
var
  findstr: string;
begin

  if GetTickCount < LastestClickTime then
    exit; //Ŭ���� ���� ���ϰ� ����

//   DMessageDlg ('Ҫ��������Ʒ����.', [mbOk, mbAbort]);
//   GetValidStrVal (DlgEditText, findstr, [' ']);
//   findstr := trim(findstr);
  findstr := trim(ItemSearchEdit.Text);
  findstr := Copy(findstr, 1, 14);
  ItemSearchEdit.Visible := False;
  if findstr <> '' then
    FrmMain.SendGetMarketPageList(CurMerchant, 2, findstr);
  LastestClickTime := GetTickCount + 5000;
//   DScreen.AddChatBoardString ('SendGetMarketPageList (CurMerchant, 2, ' +findstr + ')',  clYellow, clRed);

end;

procedure TFrmDlg.DItemSellCancelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
{   if g_Market.GetUserMode = 1 then begin
   end else if g_Market.GetUserMode = 2 then begin
      if MItemSellState = 1 then
         DScreen.ShowHint (DItemMarketDlg.Left+ DItemMarketDlg.SurfaceX(330-40), DItemMarketDlg.Top+DItemMarketDlg.SurfaceY(322+25),//(269+40),
                           '��Ź�� �������� ��� �մϴ�.', clYellow, FALSE)
      else if MItemSellState = 2 then
         DScreen.ShowHint (DItemMarketDlg.Left+DItemMarketDlg.SurfaceX(330-40), DItemMarketDlg.Top+DItemMarketDlg.SurfaceY(322+25),//(269+40),
                           '��Ź���� ȸ�� �մϴ�.', clYellow, FALSE);
   end;}
end;

procedure TFrmDlg.DItemCancelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
//   DScreen.ShowHint (DItemMarketDlg.SurfaceX(586-30), DItemMarketDlg.SurfaceY(269+45),//(269+40),
//                     '��Ź�Ǹ�â�� �ݽ��ϴ�.', clYellow, FALSE)
end;

procedure TFrmDlg.DItemBagClick(Sender: TObject; X, Y: Integer);
begin
  ItemSearchEdit.Visible := False;
end;

procedure TFrmDlg.DMemoClick(Sender: TObject; X, Y: Integer);
begin
  ItemSearchEdit.Visible := False;
end;

procedure TFrmDlg.DMailDlgClick(Sender: TObject; X, Y: Integer);
begin
  ItemSearchEdit.Visible := False;
end;

procedure TFrmDlg.DItemMarketDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  with DItemMarketDlg do
//      if (X < SurfaceX(Left+9)) or (X > SurfaceX(Left+Width-3)) or (Y < SurfaceY(Top+155)) or (Y > SurfaceY(Top+Height-125)) then begin
    if (X < SurfaceX(Left + 9)) or (X > SurfaceX(Left + Width - 3)) or (Y < SurfaceY(Top + 65)) or (Y > SurfaceY(Top + Height - 131)) then
    begin
      BoInRect := False;
    end
    else
    begin
      BoInRect := True;
    end;
//   DScreen.ClearHint(True);
//   MouseStateItem.S.Name := '';
  if g_Market.GetUserMode = 1 then
  begin
    with DItemMarketDlg do
      if (X > SurfaceX(Left + 34)) and (X < SurfaceX(Left + 16 + ItemSearchEdit.Width)) and (Y > SurfaceY(Top + 323)) and (Y < SurfaceY(Top + 347)) then
      begin
        DItemMarketDlg.KeyFocus := True;
        ItemSearchEdit.Visible := TRUE;
        ItemSearchEdit.SetFocus;
      end
      else
        ItemSearchEdit.Visible := False;
  end;

end;

procedure TFrmDlg.SetChatFocus;
begin
  ItemSearchEdit.Visible := False;
  PlayScene.EdChat.Visible := TRUE;
  PlayScene.EdChat.SetFocus;
end;

procedure TFrmDlg.DJangwonListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);

  function sx(x: integer): integer;
  begin
    Result := DJangwonListDlg.SurfaceX(DJangwonListDlg.Left + x);
  end;

  function sy(y: integer): integer;
  begin
    Result := DJangwonListDlg.SurfaceY(DJangwonListDlg.Top + y);
  end;

var
  i, menuline: integer;
  d: TDXTexture;
  pj: PTClientJangwon;
  FColor: TColor;
begin
  i := 0;
  pj := nil;

  with g_DXCanvas do
  begin
    with DJangwonListDlg do
    begin
      d := DJangwonListDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      //SetBkMode (Handle, TRANSPARENT);
    FColor := clWhite;
    menuline := _MIN(MAXMENU, JangwonList.Count);

    TextOut(sx(15), sy(32), '���', FColor);
    TextOut(sx(68), sy(32), '�л������', FColor);
    TextOut(sx(223), sy(32), '�л����Ա', FColor); //(SX(191)
    TextOut(sx(383), sy(32), '���ۼ۸�', FColor); //SX(271)
    TextOut(sx(463), sy(32), '״̬', FColor);      //SX(355)

//      for i:=MenuTop to MenuTop+menuline-1 do begin
    for i := 0 to menuline - 1 do
    begin
//         m := i-MenuTop;
      pj := PTClientJangwon(JangwonList[i]);

      if i = MenuIndex then
        FColor := clRed
      else
        FColor := clWhite;

      if pj <> nil then
      begin
        TextOut(sx(19), sy(51 + LISTLINEHEIGHT2 * i), format('%2s', [IntToStr(pj.Num)]), FColor);
        TextOut(sx(58), sy(51 + LISTLINEHEIGHT2 * i), pj.GuildName, FColor);
        TextOut(sx(160), sy(51 + LISTLINEHEIGHT2 * i), pj.CaptaineName1, FColor);
        TextOut(sx(260), sy(51 + LISTLINEHEIGHT2 * i), ', ' + pj.CaptaineName2, FColor);
        TextOut(sx(355), sy(51 + LISTLINEHEIGHT2 * i), format('%14s', [GetGoldStr(pj.SellPrice)]), FColor); //SX(249)
        TextOut(sx(461), sy(51 + LISTLINEHEIGHT2 * i), pj.SellState, FColor); //SX(348)
      end;
    end;


      //Release;
  end;
end;

procedure TFrmDlg.DJangwonListDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly, idx: integer;
  pj: PTClientJangwon;
begin

  pj := nil;
  lx := DJangwonListDlg.LocalX(X) - DJangwonListDlg.Left;
  ly := DJangwonListDlg.LocalY(Y) - DJangwonListDlg.Top;
  if (lx >= 9) and (lx <= 511) and (ly >= 48) and (ly <= 190) then
  begin
//      idx := (ly-51) div LISTLINEHEIGHT2 + MenuTop;
    idx := (ly - 51) div LISTLINEHEIGHT2;
    if idx < JangwonList.Count then
    begin
      PlaySound(s_glass_button_click);
      MenuIndex := idx;
    end;
  end;

  if (MenuIndex >= 0) and (MenuIndex < JangwonList.Count) then
  begin
    pj := PTClientJangwon(JangwonList[MenuIndex]);
  end;

end;

procedure TFrmDlg.DJangListPrevClick(Sender: TObject; X, Y: Integer);
begin
  MenuIndex := -1;
  if MenuTop = 10 then
    FrmMain.SendGetJangwonList(1);
end;

procedure TFrmDlg.DJangListNextClick(Sender: TObject; X, Y: Integer);
begin
  MenuIndex := -1;
  if MenuTop = 0 then
    FrmMain.SendGetJangwonList(2);
end;

procedure TFrmDlg.DJangwonCloseClick(Sender: TObject; X, Y: Integer);
begin
  DJangwonListDlg.Visible := False;
  BoMemoJangwon := False;
end;

procedure TFrmDlg.DJangMemoClick(Sender: TObject; X, Y: Integer);
var
  pj: PTClientJangwon;
begin
  if MenuIndex < 0 then
    Exit;
  pj := nil;

  ViewWindowNo := VIEW_MAILSEND;
  ViewWindowData := CurrentMail;
  DMemoB1.SetImgIndex(WProgUse, 546);
  DMemoB2.SetImgIndex(WProgUse, 538);
  DMemoB1.Visible := true;
  MemoMail.Clear;
//   MemoMail.ReadOnly := false;

  pj := PTClientJangwon(JangwonList[MenuIndex]);
  MemoCharID := pj.CaptaineName1;
  MemoCharID2 := pj.CaptaineName2;

  DMemo.Left := 410;
  DMemo.Top := 198;
  Memo.Clear;
  BoMemoJangwon := True;
  ShowEditMail;

end;

procedure TFrmDlg.DDealJangwonDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DDealJangwon do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         Font.Color := clWhite;
//         Font.Size := 12;
//         Font.Style := [fsBold];
      TextOut(SurfaceX(Left + 50), SurfaceY(Top + 9), '�л���������', clWhite);
//         Font.Size := 9;
//         Font.Style := [];
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DGABoardListDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);

  function sx(x: integer): integer;
  begin
    Result := DGABoardListDlg.SurfaceX(DGABoardListDlg.Left + x);
  end;

  function sy(y: integer): integer;
  begin
    Result := DGABoardListDlg.SurfaceY(DGABoardListDlg.Top + y);
  end;

var
  i, menuline: integer;
  d, TempSurface: TDXTexture;
  pb: PTClientGABoard;
  TempTitleMsg: string[36];
  FColor: TColor;
begin
  i := 0;
  pb := nil;

  with g_DXCanvas do
  begin
    with DGABoardListDlg do
    begin
      d := DGABoardListDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      //SetBkMode (Handle, TRANSPARENT);
    FColor := clWhite;
    menuline := _MIN(MAXMENU, GABoardList.Count);

    i := (142 - TextWidth(GABoard_GuildName)) div 2;
    TextOut(sx(118 + i), sy(15), GABoard_GuildName, FColor);
    TextOut(sx(45), sy(46), '����', FColor);
    TextOut(sx(234), sy(46), '��ּ', FColor);

    TextOut(sx(343), sy(15), format('%2d', [GABoard_CurPage]), FColor);
    if GABoard_MaxPage < 1 then
      TextOut(sx(360), sy(15), '/ ' + '1', FColor)
    else
      TextOut(sx(360), sy(15), '/ ' + IntToStr(GABoard_MaxPage), FColor);

    for i := 0 to menuline - 1 do
    begin
      pb := PTClientGABoard(GABoardList[i]);

      if i in [0, 1, 2] then
        FColor := clYellow
      else
        FColor := clWhite;

      if i in [0, 1, 2] then
        pb.ReplyCount := 0;
      if pb <> nil then
      begin
        if pb.ReplyCount > 0 then
        begin
          TextOut(sx(20), sy(68 + MAKETLINEHEIGHT * i), pb.WrigteUser, FColor);
          if pb.ReplyCount > 2 then
          begin
            TempTitleMsg := pb.TitleMsg;
            TextOut(sx(124 + (pb.ReplyCount * REPLYIMGPOS)), sy(68 + MAKETLINEHEIGHT * i), TempTitleMsg, FColor)
          end
          else
            TextOut(sx(124 + (pb.ReplyCount * REPLYIMGPOS)), sy(68 + MAKETLINEHEIGHT * i), pb.TitleMsg, FColor);
        end
        else
        begin
          TextOut(sx(20), sy(68 + MAKETLINEHEIGHT * i), pb.WrigteUser, FColor);
          TextOut(sx(124), sy(68 + MAKETLINEHEIGHT * i), pb.TitleMsg, FColor);
        end;
      end;

    end;

      //Release;
  end;

  for i := 0 to menuline - 1 do
  begin
    pb := PTClientGABoard(GABoardList[i]);

    if i in [0, 1, 2] then
      pb.ReplyCount := 0;
    if pb <> nil then
    begin
      if pb.ReplyCount > 0 then
        DGABoardReplyVisibleOk(i, pb.ReplyCount, dsurface);
    end;
  end;

end;

procedure TFrmDlg.DGABoardListCloseClick(Sender: TObject; X, Y: Integer);
begin
  GABoardList.Clear;
  DGABoardListDlg.Visible := False;
end;

procedure TFrmDlg.DGABoardOkClick(Sender: TObject; X, Y: Integer);
begin
  DGABoardListDlg.Visible := False;
end;

procedure TFrmDlg.DGABoardReplyVisibleOk(Index, ReplyCount: Integer; dsurface: TDXTexture);

  function sx(x: integer): integer;
  begin
    Result := DGABoardListDlg.SurfaceX(DGABoardListDlg.Left + x);
  end;

  function sy(y: integer): integer;
  begin
    Result := DGABoardListDlg.SurfaceY(DGABoardListDlg.Top + y);
  end;

var
  d: TDXTexture;
begin
  d := WProgUse.Images[690];
  if d <> nil then
    dsurface.Draw(sx(109 + (ReplyCount * REPLYIMGPOS)), sy(65 + MAKETLINEHEIGHT * Index), d.ClientRect, d, TRUE);
end;

procedure TFrmDlg.DGABoardListDlgDblClick(Sender: TObject);
var
  lx, ly, idx: integer;
  pb: PTClientGABoard;
  SendStr: string;
begin

  GABoard_BoWrite := 0;
  GABoard_BoReply := 0;
  pb := nil;
  lx := DGABoardListDlg.LocalX(GABoard_X) - DGABoardListDlg.Left;
  ly := DGABoardListDlg.LocalY(GABoard_Y) - DGABoardListDlg.Top;
  if (lx >= 13) and (lx <= 411) and (ly >= 65) and (ly <= 253) then
  begin
    idx := (ly - (64)) div MAKETLINEHEIGHT;
    if idx < GABoardList.Count then
    begin
      PlaySound(s_glass_button_click);
      MenuIndex := idx;
    end;

    if (MenuIndex >= 0) and (MenuIndex < GABoardList.Count) then
    begin
      pb := PTClientGABoard(GABoardList[MenuIndex]);
      SendStr := IntToStr(pb.IndexType1) + '/' + IntToStr(pb.IndexType2) + '/' + IntToStr(pb.IndexType3) + '/' + IntToStr(pb.IndexType4);
      if (Trim(pb.WrigteUser) = Trim(Myself.UserName)) then
        Memo.ReadOnly := False
      else
        Memo.ReadOnly := True;
      FrmMain.SendGABoardRead(SendStr);
    end;
  end;

end;

procedure TFrmDlg.DGABoardListDlgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  GABoard_X := X;
  GABoard_Y := Y;
end;

procedure TFrmDlg.DGABoardDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DGABoardDlg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    with g_DXCanvas do
    begin  
         //SetBkMode (Handle, TRANSPARENT);
//         FColor := clWhite;//clSilver;

      TextOut(Left + 16, Top + 13, GABoard_UserName, clWhite);
//         TextOut (Left+18, Top+291, GABoard_Edit);
         //Release;
    end;
  end;
end;

procedure TFrmDlg.DGABoardCloseClick(Sender: TObject; X, Y: Integer);
begin
  GABoard_Notice.Clear;
  DGABoardDlg.Visible := FALSE;
  Memo.ReadOnly := False;
  Memo.Visible := FALSE;
//   DMsgDlg.DialogResult := mrCancel;
end;

procedure TFrmDlg.DGABoardOk2Click(Sender: TObject; X, Y: Integer);
var
  data: string;
  i: Integer;
begin
  for i := 0 to Memo.Lines.Count - 1 do
  begin
    if Memo.Lines[i] = '' then
      data := data + Memo.Lines[i] + ' '#13
    else
      data := data + Memo.Lines[i] + #13;
  end;
  if Length(StrToSqlSafe(data)) >= 500 then
  begin
    Memo.Visible := False;
    DMessageDlg('��ĸ���������������ƣ������±༭һ�顣', [mbOk]);
    DGABoardDlg.ShowModal;
    Memo.Visible := True;
    Exit;
  end;

  DGABoardCloseClick(self, 0, 0);
//   DScreen.AddChatBoardString ('====SendGABoardOkProg====;', clYellow, clRed);
//   DMsgDlg.DialogResult := mrOk;
  SendGABoardOkProg;
end;

procedure TFrmDlg.DGABoardWriteClick(Sender: TObject; X, Y: Integer);
begin
  GABoard_BoWrite := 1;
  GABoard_BoNotice := 1;
  GABoard_BoReply := 0;
  Memo.ReadOnly := False;
  GABoard_UserName := Myself.UserName;
  GABoard_Notice.Clear;
  if DGABoardDlg.Visible then
    DGABoardCloseClick(DGABoardClose, 0, 0);
  ShowGABoardReadDlg;
end;

procedure TFrmDlg.DGABoardNoticeClick(Sender: TObject; X, Y: Integer);
begin
  if GetTickCount < LastestClickTime then
    Exit;
  FrmMain.SendGABoardNoticeCheck;
  LastestClickTime := GetTickCount + 3000;
end;

procedure TFrmDlg.DGABoardReplyClick(Sender: TObject; X, Y: Integer);
begin
  if MenuIndex in [0, 1, 2] then
  begin
    GABoard_BoReply := 0;
    DScreen.AddChatBoardString('�㲻�ܷ����ظ�֪ͨ', clYellow, clRed);
    Exit;
  end
  else
    GABoard_BoReply := 1;

  if DGABoardDlg.Visible then
    DGABoardCloseClick(DGABoardClose, 0, 0);
  ShowGABoardReadDlg;
end;

procedure TFrmDlg.DGABoardDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then
  begin
    if DGABoardDlg.Visible then
      DGABoardCloseClick(DGABoardClose, 0, 0);
  end;
end;

procedure TFrmDlg.DGABoardListPrevClick(Sender: TObject; X, Y: Integer);
begin
  if 1 < GABoard_CurPage then
    FrmMain.SendGetGABoardList(GABoard_CurPage - 1);
end;

procedure TFrmDlg.DGABoardListNextClick(Sender: TObject; X, Y: Integer);
begin
  if GABoard_MaxPage > GABoard_CurPage then
    FrmMain.SendGetGABoardList(GABoard_CurPage + 1);
end;

procedure TFrmDlg.DGABoardListRefreshClick(Sender: TObject; X, Y: Integer);
begin
  FrmMain.SendGetGABoardList(1);
end;

procedure TFrmDlg.DGABoardMemoClick(Sender: TObject; X, Y: Integer);
begin

  if (MenuIndex < 0) or (MenuIndex > 10) or (GABoard_UserName = '') or (GABoard_UserName = MySelf.UserName) then
    Exit;
  if DGABoardDlg.Visible then
    DGABoardCloseClick(DGABoardClose, 0, 0);
  ViewWindowNo := VIEW_MAILSEND;
  ViewWindowData := CurrentMail;
  DMemoB1.SetImgIndex(WProgUse, 546);
  DMemoB2.SetImgIndex(WProgUse, 538);
  DMemoB1.Visible := true;
  MemoMail.Clear;

  MemoCharID := GABoard_UserName;

  DMemo.Left := 410;
  DMemo.Top := 198;
  BoMemoJangwon := False;
  Memo.Clear;
  ShowEditMail;

end;

procedure TFrmDlg.DGABoardDelClick(Sender: TObject; X, Y: Integer);
var
  SendStr: string;
  MsgResult: integer;
begin

  if (Trim(GABoard_UserName) = Trim(Myself.UserName)) and (GABoard_BoWrite = 0) and (GABoard_BoReply = 0) then
  begin
    Memo.Visible := False;
    MsgResult := DMessageDlg('��ȷ��Ҫɾ��������', [mbOk, mbCancel]);
    DGABoardDlg.ShowModal;
    Memo.Visible := True;
    if MsgResult = mrCancel then
      Exit
    else if MsgResult = mrOk then
    begin
      if DGABoardDlg.Visible then
        DGABoardCloseClick(DGABoardClose, 0, 0);
      SendStr := IntToStr(GABoard_IndexType1) + '/' + IntToStr(GABoard_IndexType2) + '/' + IntToStr(GABoard_IndexType3) + '/' + IntToStr(GABoard_IndexType4);
   //      DScreen.AddChatBoardString ('SendGABoardDel=> ' + SendStr, clYellow, clRed);
      FrmMain.SendGABoardDel(GABoard_CurPage, SendStr);
    end;
  end;
//   else if DGABoardDel.Visible then DGABoardDel.Visible   := False;
end;

procedure TFrmDlg.SendGABoardOkProg;
var
  data: string;
  i: Integer;
begin
  if (Trim(GABoard_UserName) <> Trim(Myself.UserName)) and (GABoard_BoWrite = 0) and (GABoard_BoReply = 0) then
  begin
    DGABoardOk2.Visible := False;
//      DScreen.AddChatBoardString ('��״̬!!!!', clYellow, clRed);
  end
  else
  begin //if DMsgDlg.DialogResult = mrOk then begin

    data := '';
    for i := 0 to Memo.Lines.Count - 1 do
    begin
      if Memo.Lines[i] = '' then
        data := data + Memo.Lines[i] + ' '#13
      else
        data := data + Memo.Lines[i] + #13;
    end;
    if Length(StrToSqlSafe(data)) > 500 then
    begin
//            data := Copy (data, 1, 500);
      DMessageDlg('��ĸ����������������', [mbOk]);
//            DScreen.AddChatBoardString ('��ĸ����������������', clWhite, clRed);
      Exit;
    end;

    if (Trim(GABoard_UserName) = Trim(Myself.UserName)) and (GABoard_BoWrite = 0) and (GABoard_BoReply = 0) then
    begin
      data := IntToStr(GABoard_IndexType1) + '/' + IntToStr(GABoard_IndexType2) + '/' + IntToStr(GABoard_IndexType3) + '/' + IntToStr(GABoard_IndexType4) + '/' + StrToSqlSafe(data);
      FrmMain.SendGABoardModify(GABoard_CurPage, data);
//   DScreen.AddChatBoardString ('�޸ķ���!!', clYellow, clRed);
      Memo.Clear;
      Exit;
    end
    else if GABoard_BoReply = 1 then
    begin
      data := IntToStr(GABoard_IndexType1) + '/' + IntToStr(GABoard_IndexType2) + '/' + IntToStr(GABoard_IndexType3) + '/' + IntToStr(GABoard_IndexType4) + '/' + StrToSqlSafe(data);
//      DScreen.AddChatBoardString ('���·���!!', clYellow, clRed);
    end
    else
    begin
//      DScreen.AddChatBoardString ('д������!!', clYellow, clRed);
      data := '0/0/0/0/' + StrToSqlSafe(data);
    end;

//     DScreen.AddChatBoardString (data, clYellow, clRed);
    FrmMain.SendGABoardUpdateNotice(GABoard_BoNotice, GABoard_CurPage, data);
    Memo.Clear;
    DMsgDlg.DialogResult := mrCancel;
  end;

end;

procedure TFrmDlg.SendGABoardNoticeOk;
begin
  GABoard_BoWrite := 1;
  GABoard_BoNotice := 0;
  GABoard_BoReply := 0;
  Memo.ReadOnly := False;
  GABoard_UserName := Myself.UserName;
  GABoard_Notice.Clear;
  if DGABoardDlg.Visible then
    DGABoardCloseClick(DGABoardClose, 0, 0);
  ShowGABoardReadDlg;
end;

procedure TFrmDlg.DGADecorateDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);

  function sx(x: integer): integer;
  begin
    Result := DGADecorateDlg.SurfaceX(DGADecorateDlg.Left + x);
  end;

  function sy(y: integer): integer;
  begin
    Result := DGADecorateDlg.SurfaceY(DGADecorateDlg.Top + y);
  end;

var
  i, m, menuline, ImgX, ImgY: integer;
  d, TempSurface: TDXTexture;
  pd: PTClientGADecoration;
  FColor: TColor;
begin
  i := 0;
  pd := nil;

  with g_DXCanvas do
  begin
    with DGADecorateDlg do
    begin
      d := DGADecorateDlg.WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;

      //SetBkMode (g_DXCanvas.Handle, TRANSPARENT);
      //SetBkMode (Handle, TRANSPARENT);
    FColor := clWhite;
    menuline := _MIN(DECOMAXMENU, GADecorationList.Count - MenuTop);
//      DScreen.AddChatBoardString ('GADecorationList.Count=> ' +IntToStr(GADecorationList.Count), clYellow, clRed);

    TextOut(sx(93), sy(15), 'װ��Ʒ�б�', FColor);
    TextOut(sx(513), sy(16), format('%3d', [(MenuTop + 12) div 12]), FColor);
    if GADecorationList.Count < 13 then
      TextOut(sx(538), sy(16), '/ ' + '1', FColor)
    else
      TextOut(sx(538), sy(16), '/ ' + IntToStr((GADecorationList.Count div 12) + 1), FColor);

//      TextOut (SX(15),  SY(32), '���');
    TextOut(sx(61), sy(47), '����', FColor);
    TextOut(sx(183), sy(47), '�۸�', FColor); //SX(271)

    for i := MenuTop to MenuTop + menuline - 1 do
    begin
//      for i:=0 to menuline-1 do begin
      m := i - MenuTop;
      pd := PTClientGADecoration(GADecorationList[i]);

      if i = MenuIndex then
        FColor := clRed
      else
        FColor := clWhite;

      if pd <> nil then
      begin
//            TextOut (SX(19),  SY(70 + MAKETLINEHEIGHT * i), format('%2s',[IntToStr(pd.Num)]));
        TextOut(sx(26), sy(70 + MAKETLINEHEIGHT * m), pd.Name, FColor);
        TextOut(sx(158), sy(70 + MAKETLINEHEIGHT * m), format('%14s', [GetGoldStr(pd.Price)]), FColor); //SX(249)
      end;
    end;

    FColor := clWhite;
    if (MenuIndex >= 0) and (MenuIndex < GADecorationList.Count) then
    begin
      pd := PTClientGADecoration(GADecorationList[MenuIndex]);
      if pd.CaseNum = 1 then
        TextOut(sx(17), sy(306), '��������', FColor)
      else if pd.CaseNum = 2 then
        TextOut(sx(17), sy(306), '���Էŵ�����', FColor)
      else if pd.CaseNum = 3 then
        TextOut(sx(17), sy(306), '���������ڡ���', FColor);
    end;
      //Release;
  end;

  if (MenuIndex >= 0) and (MenuIndex < GADecorationList.Count) then
  begin
    pd := PTClientGADecoration(GADecorationList[MenuIndex]);

    if pd.Num = 140 then
      pd.ImgIndex := 300
    else if pd.Num = 141 then
      pd.ImgIndex := 301
    else if pd.Num = 156 then
      pd.ImgIndex := 302
    else if pd.Num = 157 then
      pd.ImgIndex := 303
    else if pd.Num = 163 then
      pd.ImgIndex := 304
    else if pd.Num = 165 then
      pd.ImgIndex := 305
    else if pd.Num = 185 then
      pd.ImgIndex := 306;

    TempSurface := WDecoImg.Images[pd.ImgIndex];
    if TempSurface <> nil then
      ImgX := 285 + ((312 - TempSurface.Width) div 2);
    ImgY := 72 + ((285 - TempSurface.Height) div 2);

    dsurface.Draw(sx(ImgX), sy(ImgY), TempSurface.ClientRect, TempSurface, TRUE);
  end;

end;

procedure TFrmDlg.DGADecorateCloseClick(Sender: TObject; X, Y: Integer);
begin
  DGADecorateDlg.Visible := False;
end;

procedure TFrmDlg.DGADecorateCancelClick(Sender: TObject; X, Y: Integer);
begin
  DGADecorateDlg.Visible := False;
end;

procedure TFrmDlg.DGADecorateBuyClick(Sender: TObject; X, Y: Integer);
var
  pd: PTClientGADecoration;
begin
  if (MenuIndex >= 0) and (MenuIndex < GADecorationList.Count) then
  begin
    pd := PTClientGADecoration(GADecorationList[MenuIndex]);
    FrmMain.SendBuyDecoItem(CurMerchant, pd.Num);
    if not DItemBag.Visible then
    begin
      DItemBag.Left := 440;
      DItemBag.Top := 0;
      DItemBag.Visible := TRUE;
    end;
  end;
end;

procedure TFrmDlg.DGADecorateDlgClick(Sender: TObject; X, Y: Integer);
var
  lx, ly, idx: integer;
  pd: PTClientGADecoration;
begin

  pd := nil;
  lx := DGADecorateDlg.LocalX(X) - DGADecorateDlg.Left;
  ly := DGADecorateDlg.LocalY(Y) - DGADecorateDlg.Top;
  if (lx >= 11) and (lx <= 275) and (ly >= 64) and (ly <= 294) then
  begin
    idx := (ly - 70) div MAKETLINEHEIGHT + MenuTop;
    if idx < GADecorationList.Count then
    begin
      PlaySound(s_glass_button_click);
      MenuIndex := idx;
    end;
  end;

  if (MenuIndex >= 0) and (MenuIndex < GADecorationList.Count) then
  begin
    pd := PTClientGADecoration(GADecorationList[MenuIndex]);
  end;
end;

procedure TFrmDlg.DGADecorateDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then
    if DGADecorateDlg.Visible then
      DGADecorateDlg.Visible := False;

//   DScreen.ClearHint(True);
  case Key of
    VK_UP:
      begin
        if (MenuTop <= (MenuIndex - 1)) and (MenuIndex <> -1) then
        begin
          Dec(MenuIndex, 1);
          DGADecorateDlgClick(DGADecorateDlg, 0, 0);
        end;
      end;
    VK_DOWN:
      begin
        if (MenuTop + DECOMAXMENU > (MenuIndex + 1)) and (MenuIndex <> -1) and ((MenuIndex + 1) < GADecorationList.Count) then
        begin
          Inc(MenuIndex, 1);
          DGADecorateDlgClick(DGADecorateDlg, 0, 0);
        end;
      end;
    VK_LEFT:
      begin
        DGADecorateListPrevClick(DGADecorateListPrev, 0, 0);
      end;
    VK_RIGHT:
      begin
        DGADecorateListNextClick(DGADecorateListNext, 0, 0);
      end;
  else

  end;

end;

procedure TFrmDlg.DGADecorateListNextClick(Sender: TObject; X, Y: Integer);
var
  MaxNum: Integer;
begin
  MenuIndex := -1;
  MaxNum := ((GADecorationList.Count div 12) + 1) * 12;
  if (MaxNum >= GADecorationList.Count) and (MaxNum >= (MenuTop + 23)) then
  begin
    Inc(MenuTop, DECOMAXMENU);
  end;
  MenuIndex := MenuTop;
  DGADecorateDlgClick(DGADecorateDlg, 0, 0);

end;

procedure TFrmDlg.DGADecorateListPrevClick(Sender: TObject; X, Y: Integer);
begin
  MenuIndex := -1;
  if MenuTop > 0 then
  begin
    Dec(MenuTop, DECOMAXMENU);
    if MenuTop < 0 then
      MenuTop := 0;
  end;
  MenuIndex := MenuTop;
  DGADecorateDlgClick(DGADecorateDlg, 0, 0);
end;

procedure TFrmDlg.SafeCloseDlg;
begin
  if DMakeItemDlg.Visible then
    DMakeItemDlgOkClick(DMakeItemDlgCancel, 0, 0);
  if DItemMarketDlg.Visible then
    CloseItemMarketDlg;
  if DJangwonListDlg.Visible then
    DJangwonCloseClick(DJangwonClose, 0, 0);
  if DGABoardListDlg.Visible then
    DGABoardListCloseClick(FrmDlg.DGABoardListClose, 0, 0);
  if DGABoardDlg.Visible then
    DGABoardCloseClick(FrmDlg.DGABoardClose, 0, 0);
  if DGADecorateDlg.Visible then
    DGADecorateCloseClick(DGADecorateClose, 0, 0);
end;

function TFrmDlg.DecoItemDesc(Dura: word; var str: string): string;
var
  pd: PTClientGADecoration;
begin
  if (Dura >= 0) and (Dura < GADecorationList.Count) then
  begin
    pd := PTClientGADecoration(GADecorationList[Dura]);
    if pd.CaseNum = 1 then
      str := '��������'
    else if pd.CaseNum = 2 then
      str := '���Էŵ�����'
    else if pd.CaseNum = 3 then
      str := '���������ڡ���';
    Result := 'ͼ��: ' + pd.Name;
  end;
end;

procedure TFrmDlg.DMasterDlgClick(Sender: TObject; X, Y: Integer);
begin
  ItemSearchEdit.Visible := False;
end;

procedure TFrmDlg.DMasterDlgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDXTexture;
  lx, ly, n, t, l, ax, ay: integer;
  Rect: TRect;
  CurrentPage, maxPage, UpPage, DownPage: integer;
begin

  with (Sender as TDWindow) do
  begin
    if fLover.GetEnable(RsState_Lover) = 1 then
      DLover1.SetImgIndex(WProgUse, 602)
    else
      DLover1.SetImgIndex(WProgUse, 600);

    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);

    b := WProgUse.GetCachedImage(582, ax, ay);
    dsurface.Draw(SurfaceX(Left + 5), SurfaceY(Top + 5), b.ClientRect, b, TRUE);
    b := WProgUse.GetCachedImage(580, ax, ay);
    dsurface.Draw(SurfaceX(Left + 168), SurfaceY(Top + 136), b.ClientRect, b, TRUE);
    b := WProgUse.GetCachedImage(581, ax, ay);
    dsurface.Draw(SurfaceX(Left + 32), SurfaceY(Top + 360), b.ClientRect, b, TRUE);


//      g_DXCanvas.Font.Color  := clSilver;
//      g_DXCanvas.Brush.Color := clBlack;
//      g_DXCanvas.Brush.Style := bsClear;


    lx := SurfaceX(30) + Left;
    ly := SurfaceY(32) + Top + (1 * 15);

    g_DXCanvas.TextOut(lx, ly, fLover.GetDisplay(0), clSilver);       //ʦͽ���������

    ly := SurfaceY(32) + Top + (3 * 15);
    g_DXCanvas.TextOut(lx, ly, fLover.GetDisplay(1), clSilver);

    ly := SurfaceY(32) + Top + (5 * 15);
    g_DXCanvas.TextOut(lx, ly, fLover.GetDisplay(2), clSilver);

    if fMaster.GetMasterCount > 0 then begin

      lx := SurfaceX(30) + Left;
      ly := SurfaceY(182) + Top + (1 * 22);

//      g_DXCanvas.TextOut(lx, ly, 'fMaster.GetMasterCount='+IntToStr(fMaster.GetMasterCount), clSilver);

      g_DXCanvas.TextOut(lx, ly, fMaster.GetDisplay(0), clSilver);

      ly := SurfaceY(182) + Top + (2 * 22);
      g_DXCanvas.TextOut(lx, ly, fMaster.GetDisplay(1), clSilver);

    end;

    if fPupil.GetPupilCount > 0 then begin

      lx := SurfaceX(30) + Left;
      ly := SurfaceY(182) + Top + (1 * 22);

//      g_DXCanvas.TextOut(lx, ly, clSilver, 'fPupil.GetPupilCount='+IntToStr(fPupil.GetPupilCount));

      g_DXCanvas.TextOut(lx, ly, fPupil.GetDisplay(0), clSilver);

      ly := SurfaceY(182) + Top + (2 * 22);
      g_DXCanvas.TextOut(lx, ly, fPupil.GetDisplay(1), clSilver);

      ly := SurfaceY(182) + Top + (3 * 22);
      g_DXCanvas.TextOut(lx, ly, fPupil.GetDisplay(2), clSilver);

      ly := SurfaceY(182) + Top + (4 * 22);
      g_DXCanvas.TextOut(lx, ly, fPupil.GetDisplay(3), clSilver);

      ly := SurfaceY(182) + Top + (5 * 22);
      g_DXCanvas.TextOut(lx, ly, fPupil.GetDisplay(4), clSilver);
    end;
//      g_DXCanvas.//Release;

  end;

end;

procedure TFrmDlg.DMasterDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.DLover1Click(Sender: TObject; X, Y: Integer);
var
  sendenable: integer;
begin
  if fLover.GetEnable(RsState_Lover) = 1 then
    sendenable := 0
  else
    sendenable := 1;

  FrmMain.SendLMOptionChange(1, sendenable);

end;

procedure TFrmDlg.DLover1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdAdd do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMasterDlg.SurfaceX(DMasterDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMasterDlg.SurfaceX(DMasterDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, 'ѡ�������', clWhite, FALSE);
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DLover2Click(Sender: TObject; X, Y: Integer);
begin
  FrmMain.SendLMRequest(RsState_Lover, RsReq_WantToJoinOther);
end;

procedure TFrmDlg.DLover2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdAdd do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMasterDlg.SurfaceX(DMasterDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMasterDlg.SurfaceX(DMasterDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '���', clWhite, FALSE);
    DFriendDlg.hint := '';
  end;

end;

procedure TFrmDlg.DLover3Click(Sender: TObject; X, Y: Integer);
var
  Name: string;
begin
  Name := fLover.GetName(RsState_Lover);
//     DScreen.AddSysMsg ( 'LOVER3_CLCIK:'+Name );
  if mrCancel = DMessageDlg('��飿\��Ҫ֧��150,0000���������\�Ƿ������ϵ��������', [mbYes, mbCancel]) then
    Exit;
  if Name <> '' then
    FrmMain.SendLMSeparate(RsState_Lover, Name);

end;

procedure TFrmDlg.DLover3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DFrdAdd do
  begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMasterDlg.SurfaceX(DMasterDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMasterDlg.SurfaceX(DMasterDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '���', clWhite, FALSE);
    DFriendDlg.hint := '';
  end;

end;

procedure TFrmDlg.ToggleShowMasterDlg;
begin
  DMasterDlg.Visible := not DMasterDlg.Visible;
  if DMasterDlg.Visible then begin
    flover.MakeDisplay(10);
    fMaster.MakeDisplay(30);
    fPupil.MakeDisplay(40);
  end;
end;

procedure TFrmDlg.DMaster1Click(Sender: TObject; X, Y: Integer);
begin
  if MySelf.Abil.Level < 35 then FrmMain.SendLMRequest(RsState_Master, RsReq_WantToJoinOther)
  else FrmMain.SendLMRequest(RsState_Pupil, RsReq_WantToJoinOther);
end;

procedure TFrmDlg.DMaster1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
  str: string;
begin
  if MySelf.Abil.Level < 35 then str := '��ʦ'
  else str := '��ͽ';
  with DMaster1 do begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMasterDlg.SurfaceX(DMasterDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMasterDlg.SurfaceX(DMasterDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, str, clWhite, FALSE);
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DMaster3Click(Sender: TObject; X, Y: Integer);
var
  Name: string;
  PupilInfo: TRelationShipInfo;
begin
  if fMaster.GetMasterCount > 0 then begin
    Name := fMaster.GetName(RsState_Master);
    if mrCancel = DMessageDlg('��������ʦͽ��ϵ��\����������ʦͽ��\��Ҫ֧��150,0000�����Ϊ����ѡ�', [mbYes, mbCancel]) then
      Exit;
    if Name <> '' then
      FrmMain.SendLMSeparate(RsState_Master, Name);
  end;

  if fPupil.GetPupilCount > 0 then begin
    if mrOk = DMessageDlg('��������Ҫ���ʦ��ͽ�ܵ�����', [mbOk, mbCancel, mbAbort]) then
    begin
      Name := Trim (DlgEditText);
      if fPupil.GetInfo(Name, PupilInfo) then begin
        if mrOk = DMessageDlg('��ȷ��Ҫ��'+Name+'���ͽ�����ʦ����\��Ҫ֧��150,0000�����Ϊ����ѡ�', [mbOk, mbCancel]) then begin
          FrmMain.SendLMSeparate(RsState_Pupil, Name);
        end;
      end else begin
        DMessageDlg(Name+'�������ͽ�ܣ���������ȷ��ͽ�����֡�', [mbOk]);
      end;
    end;
  end;
end;

procedure TFrmDlg.DMaster3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
begin
  with DMaster3 do begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + DMasterDlg.SurfaceX(DMasterDlg.Left) + lx + 8;
    sy := SurfaceY(Top) + DMasterDlg.SurfaceX(DMasterDlg.Top) + ly + 6;
    DScreen.ShowHint(sx, sy, '����ʦͽ��ϵ', clWhite, FALSE);
    DFriendDlg.hint := '';
  end;
end;

procedure TFrmDlg.DMasterCloseClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowMasterDlg;
end;

procedure TFrmDlg.DHeartImgDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DHeartImg do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DHeartImgUSDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with DHeartImgUS do
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DBotMasterClick(Sender: TObject; X, Y: Integer);
begin
  ToggleShowMasterDlg;
end;

procedure TFrmDlg.DMarketMemoClick(Sender: TObject; X, Y: Integer);
begin
  if trim(MemoCharID) <> '' then
  begin
    ViewWindowNo := VIEW_MAILSEND;
    DMemoB1.SetImgIndex(WProgUse, 546);
    DMemoB2.SetImgIndex(WProgUse, 538);
    DMemoB1.Visible := true;
    memoMail.Clear;
    ShowEditMail;
  end
  else
    DMessageDlg('û��Ŀ�걻ѡ��.', [mbOk]);
end;

procedure TFrmDlg.DMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then
    if DMemo.Visible then
      DMemoCloseClick(DMemoClose, 0, 0);
end;

procedure TFrmDlg.DSkillBarOnDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDButton;
begin
  b := nil;
  b := TDButton(Sender);
  if b.Tag = 1 then
  begin
    with b do
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DChFriendDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
  b: TDButton;
begin
  b := nil;
  b := TDButton(Sender);
  with TDButton(Sender) do
  begin
    d := WLib.Images[FaceIndex];
    if (b.Downed) and (d <> nil) then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
  end;
end;

procedure TFrmDlg.DChGroupClick(Sender: TObject; X, Y: Integer);
begin
  if (GetTickCount > changegroupmodetime) and (GroupMembers.Count > 0) then
  begin
    if UserState1.UserName <> '' then
    begin
      changegroupmodetime := GetTickCount + 2000; //timeout 5�� //DelayTime 5�ʿ��� 2�ʷ����� //2004/11/18
      FrmMain.SendAddGroupMember(Trim(UserState1.UserName));
    end;
  end
  else if (GetTickCount > changegroupmodetime) and (GroupMembers.Count = 0) then
  begin
    if UserState1.UserName <> '' then
    begin
      changegroupmodetime := GetTickCount + 2000;
      FrmMain.SendCreateGroup(Trim(UserState1.UserName));
    end;
  end;
end;

procedure TFrmDlg.DChFriendClick(Sender: TObject; X, Y: Integer);
begin
  FrmMain.SendAddFriend(UserState1.UserName, 1);
  ToggleShowFriendsDlg;
end;

procedure TFrmDlg.DChMemoClick(Sender: TObject; X, Y: Integer);
begin
  ViewWindowNo := VIEW_MAILSEND;
  ViewWindowData := CurrentMail;
  DMemoB1.SetImgIndex(WProgUse, 548);
  DMemoB2.SetImgIndex(WProgUse, 538);
  DMemoB1.Visible := true;
  MemoMail.Clear;
  MemoMail.ReadOnly := false;
  MemoCharID := UserState1.UserName;
  ShowEditMail;
end;

{
procedure TFrmDlg.DCreateChrDirectPaint(Sender: TObject;
  dsurface: TDXTexture);
var
   rc: TRect;
   n, bx, by, ax, ay, img: integer;
   d, c, dd: TDXTexture;
begin
   rc.Left   := 105;
   rc.Top    := 45;
   rc.Right  := 683;
   rc.Bottom := 471;
   FrmMain.DxDraw1.Surface.FillRect(rc,0);

   with DCreateChr do begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
         dsurface.Draw (SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
   end;

   SelectChrScene.DrawNewChr(FrmMain.DxDraw1.Surface);

end;
}
procedure TFrmDlg.DSellDlgBtnHoldClick(Sender: TObject; X, Y: Integer);
begin
  if SellStHold then
    SellStHold := False
  else
    SellStHold := True;
end;

procedure TFrmDlg.DSellDlgStHoldDirectPaint(Sender: TObject; dsurface: TDXTexture);
var
  d: TDXTexture;
begin
  with Sender as TDButton do
  begin
    if SellStHold then
    begin
      d := WLib.Images[FaceIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, TRUE);
    end;
  end;
end;

procedure TFrmDlg.DSelectChrClick(Sender: TObject; X, Y: Integer);
var
  nX, nY: Integer;
begin
//   if (50  < X) and (22 < Y) and (X < 265 ) and (Y < 382) then SelectChrScene.SelChrSelect1Click;
//   if (290 < X) and (22 < Y) and (X < 505 ) and (Y < 382) then SelectChrScene.SelChrSelect2Click;
//   if (530 < X) and (22 < Y) and (X < 745 ) and (Y < 382) then SelectChrScene.SelChrSelect3Click;
  nX := (g_FScreenWidth - DEFSCREENWIDTH) div 2;
  nY := (g_FScreenHeight - DEFSCREENHEIGHT) div 2;

  if (nX+50 < X) and (nY+22 < Y) and (X < 265+nX) and (Y < 382+nY) then
    SelectChrScene.SelChrSelect1Click;
  if (nX+490 < X) and (nY+22 < Y) and (X < 605+nX) and (Y < 382+nY) then
    SelectChrScene.SelChrSelect2Click;
end;

procedure TFrmDlg.DSellDlgBtnHoldMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not SellStHold then
    with DSellDlgBtnHold do
      DScreen.ShowHint(SurfaceX(Left) + 46, SurfaceY(Top) + 1, 'HOLD����', clYellow, FALSE);
end;

procedure TFrmDlg.DGrpAllowGroupMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  with DGrpAllowGroup do
  begin
    if AllowGroup then
      DScreen.ShowHint(SurfaceX(Left) - 2, SurfaceY(Top) - 18, '', clYellow, FALSE)   //�������м��ǵ����ŵ���ӿ���������ʾ�����֣�Ĭ���ǿ�
    else
      DScreen.ShowHint(SurfaceX(Left) - 2, SurfaceY(Top) - 18, '', clYellow, FALSE);   //�������м��ǵ����ŵ���ӿ���������ʾ�����֣�Ĭ���ǹ�
  end;
end;

procedure TFrmDlg.DGroupDlgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  DScreen.ClearHint(True);
end;

procedure TFrmDlg.SwapBujuk(idx: integer);
var
  where: integer;
  TempSender: TObject;
  i: Integer;
begin
  if ItemArr[idx].s.StdMode <> 25 then
    Exit;

  WaitingUseItem.Item := ItemArr[idx];
  WaitingUseItem.Index := U_ARMRINGL;
  FrmMain.SendTakeOnItem(U_ARMRINGL, ItemArr[idx].MakeIndex, ItemArr[idx].s.Name);
  ItemArr[idx].s.Name := '';
end;

procedure TFrmDlg.DBotMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lx, ly: integer;
  sx, sy: integer;
  flag: boolean;
  s: string;
begin
  if MySelf = nil then
    Exit;
  flag := FALSE;
  with DBottom do begin
    lx := LocalX(X - Left);
    ly := LocalY(Y - Top);
    sx := SurfaceX(Left) + lx;
    sy := SurfaceY(Top) + ly;
    if (lx > (g_FScreenWidth-134)) and (lx < (g_FScreenWidth-94)) and (ly > 145) and (ly < 145 + 10) then begin
      flag := TRUE;
      sx := g_FScreenWidth-134;
      sy := g_FScreenHeight-104;
      DScreen.ShowHint(sx, sy+13, '', clWhite, FALSE);  //��ǰ�ȼ�    
    end;
    if (lx > (g_FScreenWidth-134)) and (lx < (g_FScreenWidth-64)) and (ly > 175) and (ly < 180 + 10) then begin
      flag := TRUE;
      sx := g_FScreenWidth-134;
      sy := g_FScreenHeight-74;
      s := Format('%2.2f', [Myself.Abil.Exp / Myself.Abil.MaxExp * 100]);
      DScreen.ShowHint(sx, sy+13, '��ǰ����'+s+'%', clWhite, FALSE);
    end;
    if (lx > (g_FScreenWidth-134)) and (lx < (g_FScreenWidth-64)) and (ly > 208) and (ly < 210 + 10) then begin
      flag := TRUE;
      sx := g_FScreenWidth-134;
      sy := g_FScreenHeight-40;
      s := IntToStr(Myself.Abil.Weight) + '/' + IntToStr(Myself.Abil.MaxWeight);
      DScreen.ShowHint(sx, sy+13, '��������'+s, clWhite, FALSE);
    end;
    if not flag then begin
      DScreen.ClearHint(True);
    end;
  end;
end;


procedure TFrmDlg.DRepairItemClick(Sender: TObject; X, Y: Integer);
begin
  FrmMain.SendClientMessage(CM_QUERYBAGITEMS, 0, 0, 0, 0);
end;

end.

