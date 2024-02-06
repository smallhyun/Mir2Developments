unit ClMain;

interface

uses
  Windows, Messages, MMSystem, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, DrawScrn, IntroScn, PlayScn, MapUnit, WIL, Grobal2, Actor, StdCtrls,
  clEvent, ScktComp, ExtCtrls, HUtil32, EdCode, ClFunc, magiceff, SoundUtil,
  IniFiles, MaketSystem, RelationShip, HGEGUI, HGE, HGETextures, HGECanvas,
  Winapi.Direct3D9, Winapi.DirectDraw, HGESounds, D7ScktComp, Registry, HGEFont,
  jpeg, types;

const
  BO_FOR_TEST = FALSE;
  BoServerIniFile = FALSE;   // 使用配置文件为TRUE，
  KoreanVersion = FALSE;
  EnglishVersion = FALSE;
  ChinaVersion = FALSE;
  TaiwanVersion = FALSE;
  BoUseFindHack = FALSE;
  BoNeedPatch = FALSE;
   // 2003/02/11
  BoDebugModeScreen = TRUE;

   // 2003/04/01
  VERSION_YEAR = 2005; //2003;
  VERSION_MON = 5; //8;
  VERSION_DAY = 1; //5;

  LocalLanguage: TImeMode = imOpen;
  SERVERADDR: string = '127.0.0.1';         //服务器IP地址
  TESTSERVERADDR = '61.153.61.246';         // 韩国测试区服务器IP地址
  kornetworldaddress = '61.153.61.246';      //韩服世界服务器IP地址
  NEARESTPALETTEINDEXFILE = 'Data\npal.idx';
  SCREENWIDTH = 800;
  SCREENHEIGHT = 600;
  MAXBAGITEMCL = 52;
  ENEMYCOLOR = 69;
  MAXFONT = 4;
  MAXVIEWOBJECT = 20;
  FontKorArr: array[0..MAXFONT-1] of string = (
                '宋体',
                '楷体',
                '仿宋',
                '黑体'
            );

  FontEngArr: array[0..MAXFONT-1] of string = (
                'Courier New',
                'Arial',
                'MS Sans Serif',
                'Microsoft Sans Serif'
            );
  CurFont: integer = 0;
  CurFontName: string = '宋体';
   //HIT
  HIT_INCLEVEL = 14;
  HIT_INCSPEED = 60;
  HIT_BASE = 1400;
  RUN_STRUCK_DELAY: integer = 0{3 * 1000};

type
  TKornetWorld = record
    CPIPcode: string;
    SVCcode: string;
    LoginID: string;
    CheckSum: string;
  end;

  TOneClickMode = (toNone, toKornetWorld);

  TTimerCommand = (tcSoftClose, tcReSelConnect, tcFastQueryChr, tcQueryItemPrice);

  TChrAction = (caWalk, caRun, caHit, caSpell, caSitdown);

  TConnectionStep = (cnsLogin, cnsSelChr, cnsReSelChr, cnsPlay);

  TDirectDrawCreate = function(lpGUID: PGUID; out lplpDD: IDirectDraw; pUnkOuter: IUnknown): HRESULT; stdcall;

  TMovingItem = record
    Index: integer;
    Item: TClientItem;
  end;

  PTMovingItem = ^TMovingItem;

  TMiniViewObject = record
    Index: integer;
    x, y: integer;
    LastTick: longword;
  end;

  PTMiniViewObject = ^TMiniViewObject;

  TFrmMain = class(TForm)
    CSocket: TClientSocket;
    Timer1: TTimer;
    MouseTimer: TTimer;
    WaitMsgTimer: TTimer;
    SelChrWaitTimer: TTimer;
    CmdTimer: TTimer;
    MinTimer: TTimer;
    CloseTimer: TTimer;
    TimerRun: TTimer;
    g_DXSound: TDXSound;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DXDraw1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DXDraw1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DXDraw1Finalize(Sender: TObject);
    procedure CSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure MsgProg;
    procedure DXDraw1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DXDraw1DblClick(Sender: TObject);
    procedure WaitMsgTimerTimer(Sender: TObject);
    procedure SelChrWaitTimerTimer(Sender: TObject);
    procedure DXDraw1Click(Sender: TObject);
    procedure CmdTimerTimer(Sender: TObject);
    procedure MinTimerTimer(Sender: TObject);
    procedure CheckHackTimerTimer(Sender: TObject);
    procedure SendTimeTimerTimer(Sender: TObject);
    procedure DelitemProg;
    procedure MainCancelItemMoving;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TimerRunTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    SocStr, BufferStr: string;
    WarningLevel: integer;
    TimerCmd: TTimerCommand;
    MakeNewId: string;
    ActionLockTime: longword;
    LastHitTime: longword;
    ActionFailLock: Boolean;
    FailAction, FailDir: integer;
    FailActionTime: longword;
    ActionKey: word;
    mousedowntime: longword;
    WaitingMsg: TDefaultMessage;
    WaitingStr: string;
    boSizeMove: Boolean;
    boInFocus: Boolean;
    m_Point: TPoint;
    FboDisplayChange: Boolean;
    FIDDraw: IDirectDraw;
    FDDrawHandle: THandle;
    FHotKeyId: Integer;
    FCriticalSection: TRTLCriticalSection;
    FboShowLogo: Boolean;
    FdwShowLogoTick: LongWord;
    FnShowLogoIndex: Integer;
    m_FreeTextureTick: LongWord;
    m_FreeTextureIndex: Integer;
    FFrameRate: Integer;
    FInitialized: Boolean;
    FInterval: Cardinal;
    FInterval2: Cardinal;
    FNowFrameRate: Integer;
    FOldTime: DWORD;
    FOldTime2: DWORD;
    procedure CheckMapView;
    function CheckPtInMinMap(X, Y: Integer): Boolean;
    procedure SpeedHackTimerTimer(Sender: TObject);
    procedure FindWHHackTimerTimer(Sender: TObject);
    procedure RunEffectTimerTimer(Sender: TObject);
    procedure ProcessKeyMessages;
    procedure ProcessActionMessages;
    procedure CheckSpeedHack(rtime: Longword);
    procedure CheckSpeedHackChina(stime: longword);
    procedure DecodeMessagePacket(datablock: string);
    procedure ActionFailed;
    function GetMagicByKey(Key: AnsiChar): PTClientMagic;
    procedure UseMagic(tx, ty: integer; pcm: PTClientMagic);
    procedure UseMagicSpell(who, effnum, targetx, targety, magic_id: integer);
    procedure UseMagicFire(who, efftype, effnum, targetx, targety, target: integer);
    procedure UseMagicFireFail(who: integer);
    procedure CloseAllWindows;
    procedure ClearDropItems;
    procedure ResetGameVariables;
    procedure ChangeServerClearGameVariables;
    procedure _DXDrawMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function CheckDoorAction(dx, dy: integer): Boolean;
    procedure ClientGetPasswdSuccess(body: string);
    procedure ClientGetNeedUpdateAccount(body: string);
    procedure ClientGetSelectServer;
    procedure ClientGetReceiveChrs(body: string);
    procedure ClientGetStartPlay(body: string);
    procedure ClientGetReconnect(body: string);
    procedure ClientGetMapDescription(body: string);
    procedure ClientGetAdjustBonus(bonus: integer; body: string);
    procedure ClientGetAddItem(body: string);
    procedure ClientGetUpdateItem(body: string);
    procedure ClientGetDelItem(body: string; flag: integer);
    procedure ClientGetDelItems(body: string);
    procedure ClientGetBagItmes(body: string);
    procedure ClientGetDropItemFail(iname: string; sindex: integer);
    procedure ClientGetShowItem(itemid, x, y, looks: integer; body: string);
    procedure ClientGetHideItem(itemid, x, y: integer);
    procedure ClientGetSenduseItems(body: string);
    procedure ClientGetAddMagic(body: string);
    procedure ClientGetDelMagic(magid: integer);
    procedure ClientGetMyMagics(checksum: integer; body: string);
    procedure ClientGetMagicLvExp(magid, maglv, magtrain: integer);
    procedure ClientGetSound(soundid: integer);
    procedure ClientGetDuraChange(uidx, newdura, newduramax: integer);
    procedure ClientGetMerchantSay(merchant, face: integer; saying: string);
    procedure ClientGetSendGoodsList(merchant, count: integer; body: string);
    procedure ClientGetDecorationList(merchant, count: integer; body: string);
    procedure ClientGetJangwonList(Page, count: integer; body: string);
    procedure ClientGetGABoardList(ListNum, Page, MaxPage: integer; body: string);
    procedure ClientGetGABoardRead(body: string);
    procedure ClientGetSendMakeDrugList(merchant: integer; body: string);
    procedure ClientGetSendMakeItemList(merchant: integer; body: string);
    procedure ClientGetSendUserSell(merchant: integer);
    procedure ClientGetSendUserRepair(merchant: integer);
    procedure ClientGetSendUserStorage(merchant: integer);
    procedure ClientGetSendUserMaketSell(merchant: integer);
    procedure ClientGetSaveItemList(merchant, currentpage, maxpage: integer; bodystr: string);
    procedure ClientGetSendDetailGoodsList(merchant, count, topline: integer; bodystr: string);
    procedure ClientGetSendNotice(body: string);
    procedure ClientGetGroupMembers(bodystr: string);
    procedure ClientGetOpenGuildDlg(bodystr: string);
    procedure ClientGetSendGuildMemberList(body: string);
    procedure ClientGetDealRemoteAddItem(body: string);
    procedure ClientGetDealRemoteDelItem(body: string);
    procedure ClientGetReadMiniMap(mapindex: integer);
    procedure ClientGetChangeGuildName(body: string);
    procedure ClientGetSendUserState(body: string);
    procedure ClientGetUserInfo(msg: TDefaultMessage; body: string);
    procedure ClientGetDelFriend(msg: TDefaultMessage; body: string);
    procedure ClientGetFriendInfo(msg: TDefaultMessage; body: string);
    procedure ClientGetFriendResult(msg: TDefaultMessage; body: string);
    procedure ClientGetTagAlarm(msg: TDefaultMessage; body: string);
    procedure ClientGetTagList(msg: TDefaultMessage; body: string);
    procedure ClientGetTagInfo(msg: TDefaultMessage; body: string);
    procedure ClientGetTagRejectList(msg: TDefaultMessage; body: string);
    procedure ClientGetTagRejectAdd(msg: TDefaultMessage; body: string);
    procedure ClientGetTagRejectDelete(msg: TDefaultMessage; body: string);
    procedure ClientGetTagResult(msg: TDefaultMessage; body: string);
    procedure ClientFriendSort(var datalist: TList; firstname: string);
    procedure ClientGetLMList(msg: TDefaultMessage; body: string);
    procedure ClientGetLMOptionChange(msg: TDefaultMessage);
    procedure ClientGetLMRequest(msg: TDefaultMessage; body: string);
    procedure ClientGetLMResult(msg: TDefaultMessage; body: string);
    procedure ClientGetLMDelete(msg: TDefaultMessage; body: string);
    procedure ClientGetServerUnBind(Body:String);
    procedure ClientGetAttackMode( mode :byte);
    procedure RecalcNotReadCount;
    procedure RecalcOnlinUserCount;
    // 20003-09-05 Encrypt LoginId,PasswordmCharName
    function GetLoginId: string;
    procedure SetLogId(id: string);
    function GetLoginPasswd: string;
    procedure SetLoginPasswd(pw: string);
    function GetCharName: string;
    procedure SetCharName(name: string);
  public
    Certification: integer;
    ActionLock: Boolean;
    SpeedHackTimer: TTimer;
    FindWHHackTimer: TTimer;
    RunEffectTimer: TTimer;
    WhisperName: string;
    m_CheckTick: LongWord; 
    // 20003-09-05 Encrypt LoginId,PasswordmCharName
    EncLoginId, EncLoginPasswd, EncCharName: string;
    EncEncLoginID: string;
    FLoginIDLock: Boolean;
    property LoginId: string read GetLoginId write SetLogId;
    property LoginPasswd: string read GetLoginPasswd write SetLoginPasswd;
    property CharName: string read GetCharName write SetCharName;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure ProcOnIdle;
    procedure AppLogout;
    procedure AppExit;
    procedure PrintScreenNow;
    procedure EatItem(idx: integer);
    procedure SendClientMessage(msg, Recog, param, tag, series: integer);
    procedure SendClientMessage2(msg, Recog, param, tag, series: integer; str: string);
    procedure SendVersionNumber;
    procedure SendLogin(uid, passwd: string);
    procedure SendNewAccount(ue: TUserEntryInfo; ua: TUserEntryAddInfo);
    procedure SendUpdateAccount(ue: TUserEntryInfo; ua: TUserEntryAddInfo);
    procedure SendSelectServer(svname: string);
    procedure SendChgPw(id, passwd, newpasswd: string);
    procedure SendNewChr(uid, uname, shair, sjob, ssex: string);
    procedure SendQueryChr;
    procedure SendDelChr(chrname: string);
    procedure SendSelChr(chrname: string);
    procedure SendRunLogin;
    procedure SendSay(str: string);
    procedure SendActMsg(ident, x, y, dir: integer);
    procedure SendSpellMsg(ident, x, y, dir, target: integer);
    procedure SendQueryUserName(targetid, x, y: integer);
    procedure SendDropItem(name: string; itemserverindex: integer);
    procedure SendDropCountItem(iname: string; mindex, icount: integer);
    procedure SendPickup;
    procedure SendTakeOnItem(where: byte; itmindex: integer; itmname: string);
    procedure SendTakeOffItem(where: byte; itmindex: integer; itmname: string);
    procedure SendEat(idx, itmindex: integer; itmname: string);
    procedure UpgradeItem(ItemIndex, jewelIndex: integer; StrItem, StrJewel: string);
    procedure SendItemSumCount(OrgItemIndex, ExItemIndex: integer; StrOrgItem, StrExItem: string);
    procedure UpgradeItemResult(ItemIndex: integer; wResult: word; str: string);
    procedure SendButchAnimal(x, y, dir, actorid: integer);
    procedure SendMagicKeyChange(magid: integer; keych: AnsiChar);
    procedure SendMerchantDlgSelect(merchant: integer; rstr: string);
    procedure SendQueryPrice(merchant, itemindex: integer; itemname: string);
    procedure SendQueryRepairCost(merchant, itemindex: integer; itemname: string);
    procedure SendSellItem(merchant, itemindex: integer; itemname: string; Count: word);
    procedure SendRepairItem(merchant, itemindex: integer; itemname: string);
    procedure SendStorageItem(merchant, itemindex: integer; itemname: string; Count: word);
    procedure SendMaketSellItem(merchant, itemindex: integer; price: string; Count: word);
    procedure SendGetDetailItem(merchant, menuindex: integer; itemname: string);
    procedure SendGetJangwonList(Page: integer);
    procedure SendGABoardRead(Body: string);
    procedure SendGetMarketPageList(merchant, pagetype: integer; itemname: string);
    procedure SendBuyMarket(merchant, sellindex: integer);
    procedure SendCancelMarket(merchant, sellindex: integer);
    procedure SendGetPayMarket(merchant, sellindex: integer);
    procedure SendMarketClose;
    procedure SendBuyItem(merchant, itemserverindex: integer; itemname: string; Count: word);
    procedure SendBuyDecoItem(merchant, DecoItemNum: integer);
    procedure SendTakeBackStorageItem(merchant, itemserverindex: integer; itemname: string; Count: word);
    procedure SendMakeDrugItem(merchant: integer; itemname: string);
    procedure SendMakeItemSel(merchant: integer; itemname: string);
    procedure SendMakeItem(merchant: integer; data: string);
    procedure SendDropGold(dropgold: integer);
    procedure SendGroupMode(onoff: Boolean);
    procedure SendCreateGroup(withwho: string);
    procedure SendWantMiniMap;
    procedure SendDealTry;
    procedure SendGuildDlg;
    procedure SendCancelDeal;
    procedure SendAddDealItem(ci: TClientItem);
    procedure SendDelDealItem(ci: TClientItem);
    procedure SendChangeDealGold(gold: integer);
    procedure SendDealEnd;
    procedure SendAddGroupMember(withwho: string);
    procedure SendDelGroupMember(withwho: string);
    procedure SendGuildHome;
    procedure SendGuildMemberList;
    procedure SendGuildAddMem(who: string);
    procedure SendGuildDelMem(who: string);
    procedure SendGuildUpdateNotice(notices: string);
    procedure SendGABoardUpdateNotice(notice, CurPage: integer; bodyText: string);
    procedure SendGABoardModify(CurPage: integer; bodyText: string);
    procedure SendGABoardDel(CurPage: integer; bodyText: string);
    procedure SendGABoardNoticeCheck;
    procedure SendGetGABoardList(Page: integer);
    procedure SendGuildUpdateGrade(rankinfo: string);
    procedure SendSpeedHackUser(code: integer);
    procedure SendAdjustBonus(remain: integer; babil: TNakedAbility);
    procedure UseNormalEffect(effnum, effx, effy: integer);
    procedure UseLoopNormalEffect(ActorID: integer; EffectIndex, LoopTime: Word);
    procedure AttackTarget(target: TActor);
    procedure SendAddFriend(data: string; FriendType: integer);
    procedure SendDelFriend(data: string);
    procedure SendMail(data: string);
    procedure SendReadingMail(data: string);
    procedure SendDelMail(data: string);
    procedure SendLockMail(data: string);
    procedure SendUnLockMail(data: string);
    procedure SendMailList;
    procedure SendRejectList;
    procedure SendUpdateFriend(data: string);
    procedure SendAddReject(data: string);
    procedure SendDelREject(data: string);
    procedure SendLMOPtionChange(OptionType: integer; Enable: integer);
    procedure SendLMRequest(ReqType: integer; ReqSeq: integer);
    procedure SendLMSeparate(ReqType: integer; data: string);
    function IsMyMember(name: string): Boolean;
    function TargetInSwordLongAttackRange(ndir: integer): Boolean;
    function TargetInSwordWideAttackRange(ndir: integer): Boolean;
    function TargetInSwordCrossAttackRange(ndir: integer): Boolean;
    procedure OnProgramException(Sender: TObject; E: Exception);
    procedure SendSocket(sendstr: string);
    function ServerAcceptNextAction: Boolean;
    function CanNextAction: Boolean;
    function CanNextHit: Boolean;
    function IsUnLockAction(action, adir: integer): Boolean;
    procedure ActiveCmdTimer(cmd: TTimerCommand);
    function IsGroupMember(uname: string): Boolean;
    procedure AppOnIdle(boInitialize: Boolean = False);
    procedure FullScreen(boFull: Boolean);
    procedure MyDeviceRender(Sender: TObject);
    procedure DisplayChange(boReset: Boolean);
    procedure MyDeviceInitialize(Sender: TObject; var Success: Boolean; var ErrorMsg: string);
    procedure MyDeviceFinalize(Sender: TObject);
    procedure MyDeviceNotifyEvent(Sender: TObject; Msg: Cardinal);
    procedure ProcessFreeTexture;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure TurnDuFu(pcm: PTClientMagic);
    procedure CreateParams(var Params: TCreateParams); override;
  end;

procedure DecodeLicenseStrings(strlist: TStringlist);

function CheckMirProgram: Boolean;

procedure WaitAndPass(msec: longword);

procedure DebugOutStr(msg: string);

procedure ChangeWalkHitValues(level, speed, weightsum, rundelay: integer);

procedure TogglePlaySoundEffect;

function GetFileCheckSum(flname: string): integer;

function GetRGB(c256: byte): integer;

var
  FrmMain: TFrmMain;
  DScreen: TDrawScreen;
  IntroScene: TIntroScene;
  LoginScene: TLoginScene;
  SelectChrScene: TSelectChrScene;
  PlayScene: TPlayScene;
  LoginNoticeScene: TLoginNotice;
  DropedItemList: TList;
  ChangeFaceReadyList: TList;
  TerminateNow: Boolean;
  ViewList: array[1..MAXVIEWOBJECT] of TMiniViewObject;
  ViewListCount: Integer;
  MainParam1, MainParam2, MainParam3, MainParam4, MainParam5, MainParam6: string;
  //DObjList: TList;
  EventMan: TClEventManager;
  ServerCount: integer;
  ServerCaptionArr: array[0..31] of string;
  ServerNameArr: array[0..31] of string;
  KornetWorld: TKornetWorld;
  ServerName: string;
  MapTitle: string;
  GuildName: string;
  GuildRankName: string;
  Map: TMap;
  MySelf: THumActor;
  MyDrawActor: THumActor;
  UseItems: array[0..12] of TClientItem;       //8->12
  ItemArr: array[0..MAXBAGITEMCL - 1] of TClientItem;
  DealItems: array[0..9] of TClientItem;
  MakeItemArr: array[0..5] of TClientItem;
  DealRemoteItems: array[0..19] of TClientItem;
  SaveItemList: TList;
  MenuItemList: TList;
  DealGold, DealRemoteGold: integer;
  BoDealEnd: Boolean;
  DealWho: string;
  MagicList: TList;
  MouseItem, MouseStateItem, MouseUserStateItem: TClientItem;
  FreeActorList: TList;
  BoServerChanging: Boolean;
  BoBagLoaded: Boolean;
  BoOptionLoaded: Boolean;
  BoOneTimePassword: Boolean;
  FirstServerTime: longword;
  FirstClientTime: longword;
  //ServerTimeGap: int64;
  TimeFakeDetectCount: integer;
  MainAniCount: integer;
  ClientVersion: integer;
  FirstServerTimeChina: longword;
  FirstClientTimeChina: longword;
  TimeFakeDetectCountChina: integer;
  checkfaketime: longword;
  checkchecksumtime: longword;
  SHGetTime: longword;
  SHTimerTime: longword;
  SHFakeCount: integer;
  SHHitSpeedCount: integer;
  LatestClientTime2: longword;
  FirstClientTimerTime: longword;
  LatestClientTimerTime: longword;
  FirstClientGetTime: longword;
  LatestClientGetTime: longword;
  TimeFakeDetectSum: integer;
  TimeFakeDetectTimer: integer;
  BonusPoint, SaveBonusPoint: integer;
  BonusTick: TNakedAbility;
  BonusAbil: TNakedAbility;
  NakedAbil: TNakedAbility;
  BonusAbilChg: TNakedAbility;
  SellDlgItem: TClientItem;
  SellDlgItemSellWait: TClientItem;
  DealDlgItem: TClientItem;
  MakingDlgItem: TClientItem;
  BoQueryPrice: Boolean;
  QueryPriceTime: longword;
  SellPriceStr: string;
  BoOneClick: Boolean;
  OneClickMode: TOneClickMode;
  BoFirstTime: Boolean;
  ConnectionStep: TConnectionStep;
  BoWellLogin: Boolean;
  ServerConnected: Boolean;
  ViewFog: Boolean;
  DayBright: integer;
  AreaStateValue: integer;
  MyHungryState: integer;
  BoPlaySoundEffect: Boolean;
  LastAttackTime: longword;
  LastMoveTime: longword;
  ItemMoving: Boolean;
  MovingItem: TMovingItem;
  DelTempItem: TClientItem;
  UpItemItem: TClientItem;
  WaitingUseItem: TMovingItem;
  EatingItem: TClientItem;
  EatTime: longword;
  LatestStruckTime: longword;
  LatestSpellTime: longword;
  LatestFireHitTime: longword;
  LatestRushRushTime: longword;
  LatestHitTime: longword;
  LatestMagicTime: longword;
  DizzyDelayStart: longword;
  DizzyDelayTime: integer;
  DoFadeOut: Boolean;
  DoFadeIn: Boolean;
  FadeIndex: integer;
  DoFastFadeOut: Boolean;
  BoStopAfterAttack: Boolean;
  BoAttackSlow: Boolean;
  BoMoveSlow, BoMoveSlow2: Boolean;
  MoveSlowLevel: integer;
  MoveSlowValue: integer;
  MapMoving: Boolean;
  MapMovingWait: Boolean;
//  CheckBadMapMode: Boolean;
  BoCheckSpeedHackDisplay: Boolean;
  BoWantMiniMap: Boolean;
  BoDrawMiniMap: Boolean;
  ViewMiniMapTran:Boolean=false;
  g_ShowMiniMapXY:Boolean=false;
  g_MinMapWidth:Integer=180;
  TempMapTitle:string;

  ViewMiniMapStyle: integer;
  ViewGeneralMapStyle: integer;
  PrevVMMStyle: integer;
  MiniMapIndex: integer=-1;
  MCX: integer;
  MCY: integer;
  MouseX, MouseY: integer;
  g_MouseX,g_MouseY:Integer;

  TargetX: integer;
  TargetY: integer;
  TargetCret, FocusCret: TActor;
  MagicTarget, AutoTarget: TActor;
  TargetCase: Byte;
  BoAutoDig: Boolean;
  BoSelectMyself: Boolean;
  FocusItem: PTDropItem;
  MagicDelayTime: longword;
  MagicPKDelayTime: longword;
  ChrAction: TChrAction;
  NoDarkness: Boolean;
  RunReadyCount: integer;
  SoftClosed: Boolean;
  SelChrAddr: string;
  SelChrPort: integer;
  ImgMixSurface: TDXTexture;
  ImgLargeMixSurface: TDXTexture;
  MiniMapSurface: TDXTexture;
  CurMerchant: integer;
  MDlgX, MDlgY: integer;
  changegroupmodetime: longword;
  dealactiontime: longword;
  querymsgtime: longword;
  DupSelection: integer;
  MsgYesIagree: string;
  MsgNoImnot: string;
  AllowGroup: Boolean;
  SellStHold: Boolean;
  GroupMembers: TStringList;
  GroupIdList: TList; // MonOpenHp
  FriendMembers: TList;
  BlackMembers: TList;
  MailLists: TList;
  BlockLists: TStringList;
  MailAlarm: Boolean;
  WantMailList: Boolean;
  ConnectFriend: integer;
  ConnectBlack: integer;
  NotReadMailCount: integer;
  fLover: TRelationShipMgr;
  fMaster: TRelationShipMgr;
  fPupil: TRelationShipMgr;
  MySpeedPoint, MyHitPoint, MyAntiPoison, MyPoisonRecover, MyHealthRecover, MySpellRecover, MyAntiMagic: integer;
  AvailIDDay, AvailIDHour: word;
  AvailIPDay, AvailIPHour: word;
  CaptureSerial: integer;
  SendCount, ReceiveCount: integer;
  TestSendCount, TestReceiveCount: integer;
  SpellCount, SpellFailCount, FireCount: integer;
  DebugCount, DebugCount1, DebugCount2: integer;
  LastestClientGetTime: longword;
  ToolMenuHook: HHOOK;
  LastHookKey: integer;
  LastHookKeyTime: longword;
  BoNextTimePowerHit: Boolean;
  BoCanLongHit: Boolean;
  BoCanWideHit: Boolean;
  BoCanCrossHit: Boolean;
  BoCanTwinHit: Boolean;
  BoNextTimeFireHit: Boolean;
  BoCanStoneHit: Boolean;
  WalkCheckSum_fake1: integer;
  WalkCheckSum_fake2: integer;
  WalkCheckSum_fake3: integer;
  WalkCheckSum1: integer;
  HitCheckSum1: integer;
  HitCheckSum_fake1: integer;
  HitCheckSum_fake2: integer;
  HitCheckSum_fake3: integer;
  pWalkCheckSum2: ^integer;
  pHitCheckSum2: ^integer;
  pWalkCheckSum3: ^integer;
  pHitCheckSum3: ^integer;
  DarkLevel: integer;
  DayBright_fake: integer;
  DarkLevel_fake: integer;
  pDayBrightCheck: ^integer;
  pDarkLevelCheck: ^integer;
  pLocalFileCheckSum: ^integer;
  pClientCheckSum1: ^integer;
  pClientCheckSum2: ^integer;
  pClientCheckSum3: ^integer;
  BoSendFileCheckSum: Boolean;
  EffectNum: Byte;
  BoMsgDlgTimeCheck: Boolean;
  MsgDlgMaxStr: Byte;
  SpeedHackUse: Boolean;
  hfindWnd: Integer;
  BoViewEffect: Boolean;
  DropItemView: Boolean;
  gCheckTime: longword;
  mirapphandle: HWnd;
  GameClose: Boolean;
  CouplePower: Boolean;
  TabClickTime: longword;
  gFps: integer;
  FpsLastTime: longword;
  AngelFastDraw: Boolean;
  StBeltAutoFill: Boolean;
  BtInDex: integer;
  BeltType: integer;
  gAutoRun: Boolean;
  g_boShowName: Boolean;
  HGE: IHGE = nil;

  g_dwKeyTimeTick: longword;
  NetPort : Word ;  // 登录网关端口变量
  NetSvrAddr: string[15];   //  IP地址变量
  NowSvrName : string;      //服务器名称变量
//   BackSoundLoopTime: longword;

   //DebugColor1, DebugColor2, DebugColor3, DebugColor4: byte;
   //BoDebugColorChanged: Boolean;

implementation

uses
  FState, MShare, HGEFonts, HGEBase, Bass, DLLFile, Logo,
  Light0a, Light0b, Light0c, Light0d, Light0e, Light0f;

{$R *.DFM}
{$R ColorTable.RES}

function GetRGB(c256: byte): integer;
begin
  Result := RGB(g_ColorTable[c256].rgbRed, g_ColorTable[c256].rgbGreen, g_ColorTable[c256].rgbBlue);
end;

procedure DecodeLicenseStrings(strlist: TStringlist);
var
  i: integer;
  str: string;
begin
  for i := 0 to strlist.Count - 1 do
  begin
    str := strlist[i];
    strlist[i] := DecodeString(str);
  end;
end;

procedure ChangeWalkHitValues(level, speed, weightsum, rundelay: integer);
begin
  WalkCheckSum_fake1 := 10 + Random(1000);
  WalkCheckSum_fake2 := 100 + Random(1000);
  WalkCheckSum_fake3 := 1000 + Random(1000);
  WalkCheckSum1 := Random(100);
  pWalkCheckSum2^ := Random(10000);
  pWalkCheckSum3^ := Random(10000);

   //

  HitCheckSum_fake1 := 10 + Random(1000);
  HitCheckSum_fake2 := 100 + Random(1000);
  HitCheckSum_fake3 := 1000 + Random(1000);

  HitCheckSum1 := level * HIT_INCLEVEL + abs(speed) * HIT_INCSPEED + weightsum + rundelay;

  pHitCheckSum2^ := (HitCheckSum1 * 4) xor $FFFFFFFF;
  pHitCheckSum3^ := (HitCheckSum1 * 20) xor $FFFFFFFF;
end;

function CheckMirProgram: Boolean;
var
  pstr, cstr: array[0..255] of Char;
begin
  Result := FALSE;
  StrPCopy(pstr, 'Legend of Mir 2');
  mirapphandle := FindWindow(nil, pstr);
  if (mirapphandle <> 0) and (mirapphandle <> Application.Handle) then
  begin
{$IFNDEF COMPILE}
    SetActiveWindow(mirapphandle);
    Result := TRUE;
{$ENDIF}
    exit;
  end;
end;

procedure WaitAndPass(msec: longword);
var
  start: longword;
begin
  start := GetTickCount;
  while GetTickCount - start < msec do
  begin
    Application.ProcessMessages;
  end;
end;

procedure DebugOutStr(msg: string);
var
  flname: string;
  fhandle: TextFile;
begin
  exit;
  flname := '.\!debug.txt';
  if FileExists(flname) then
  begin
    AssignFile(fhandle, flname);
    Append(fhandle);
  end
  else
  begin
    AssignFile(fhandle, flname);
    Rewrite(fhandle);
  end;
  WriteLn(fhandle, TimeToStr(Time) + ' ' + msg);
  CloseFile(fhandle);
end;

function KeyboardHookProc(Code: Integer; WParam: Longint; var Msg: TMsg): Longint; stdcall;
begin
  if ((WParam = 9){ or (WParam = 13)}) and (LastHookKey = 18) and (GetTickCount - LastHookKeyTime < 500) then
  begin
    if FrmMain.WindowState <> wsMinimized then
    begin
      FrmMain.WindowState := wsMinimized;
    end
    else
      Result := CallNextHookEx(ToolMenuHook, Code, WParam, Longint(@Msg));
    exit;
  end;
  LastHookKey := WParam;
  LastHookKeyTime := GetTickCount;

  Result := CallNextHookEx(ToolMenuHook, Code, WParam, Longint(@Msg));
end;

procedure TogglePlaySoundEffect;
begin
  BoPlaySoundEffect := not BoPlaySoundEffect;
  if BoPlaySoundEffect then
    DScreen.AddChatBoardString('[音效 开]', clWhite, clBlack)
  else
    DScreen.AddChatBoardString('[音效 关]', clWhite, clBlack);
end;

function GetFileCheckSum(flname: string): integer;
type
  pinteger = ^Integer;
var
  pbuf: PAnsiChar;
  i, n, handle, bsize, cval, csum: integer;
begin
  Result := 0;
  if FileExists(flname) then
  begin
    handle := FileOpen(flname, fmOpenRead or fmShareDenyNone);
    if handle > 0 then
    begin
      bsize := FileSeek(handle, 0, 2);
      GetMem(pbuf, (bsize + 3) div 4 * 4);
      FillChar(pbuf^, (bsize + 3) div 4 * 4, 0);
      FileSeek(handle, 0, 0);
      FileRead(handle, pbuf^, bsize);
      FileClose(handle);

      csum := 0;
      for i := 0 to (bsize + 3) div 4 - 1 do
      begin
        cval := pinteger(pbuf)^;
        pbuf := PAnsiChar(integer(pbuf) + 4);
        csum := csum xor cval;
      end;

      Result := csum;
    end;
  end;
end;




//--------------------------------------------------------------------------------------

// 20003-09-05 Encrypt LoginId,PasswordmCharName
function TFrmMain.GetLoginId: string;
begin
  Result := '';

  if FLoginIDLock = false then
  begin
    Result := DecodeString(EncLoginId);
  end
  else
  begin
    if EncLoginId = DecodeString(EncEncLoginId) then
      Result := DecodeString(EncLoginId);
  end

end;

procedure TFrmMain.SetLogId(id: string);
begin
  if FLoginIDLock = false then
  begin
    EncLoginId := EncodeString(id);
    EncEncLoginId := EncodeString(EncLoginId);
  end;
end;

function TFrmMain.GetLoginPasswd: string;
begin
  Result := DecodeString(EncLoginPasswd);
end;

procedure TFrmMain.SetLoginPasswd(pw: string);
begin
  if FLoginIDLock = false then
  begin
    EncLoginPasswd := EncodeString(pw);
  end;
end;

function TFrmMain.GetCharName: string;
begin
  Result := DecodeString(EncCharName);
end;

procedure TFrmMain.SetCharName(name: string);
begin
  EncCharName := EncodeString(name);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  flname, str: string;
  ini: TIniFile;
  i: integer;
  fr: PTFriend;
  ma: PTMail;
  Res: TResourceStream;
begin
  FInterval2 := 1;
  FInterval := 30;
  FOldTime := TimeGetTime;
  FOldTime2 := TimeGetTime;
  Res := TResourceStream.Create(Hinstance, '256RGB', 'RGB');
  try
    Res.Read(g_ColorTable, SizeOf(g_ColorTable));
  finally
    Res.Free;
  end;

  case g_FScreenMode of
    1:
      begin
        g_FScreenWidth := 1024;
        g_FScreenHeight := 768;
      end;
    2:
      begin
        g_FScreenWidth := SCREENWIDTH;
        g_FScreenHeight := SCREENHEIGHT;
      end;
  else
    begin
      g_FScreenWidth := SCREENWIDTH;
      g_FScreenHeight := SCREENHEIGHT;
    end;
  end;
  GUIFScreenWidth := g_FScreenWidth;
  GUIFScreenHeight := g_FScreenHeight;

  FDDrawHandle := 0;
  FIDDraw := nil;
  Randomize;
  InitializeCriticalSection(FCriticalSection);

  m_FreeTextureTick := GetTickCount;
  m_FreeTextureIndex := 0;

  if g_boFullScreen then
  begin
    BorderStyle := bsNone;
    BorderIcons := [];
    ClientWidth := g_FScreenWidth;
    ClientHeight := g_FScreenHeight;
    WindowState := wsMaximized;

    DisplayChange(False);

    m_Point := ClientOrigin;
  end
  else
  begin
    BorderStyle := bsSingle;
  end;


  ClientWidth := g_FScreenWidth;
  ClientHeight := g_FScreenHeight;

  LoadWMImagesLib(nil);

  g_DWinMan := TDWinManager.Create(Self);
  g_SoundList := TStringList.Create;
  m_Point := ClientOrigin;

  g_DXFont := TDXFont.Create;
//  g_DXSound := TDXSound.Create(Self);
//  g_DXSound.Initialize;      //声卡问题

  if g_DXSound.Initialized then
  begin
    g_Sound := TSoundEngine.Create(g_DXSound.DSound);
    //MP3:=TMPEG.Create(nil);
  end
  else
  begin
    g_Sound := Nil;
    //MP3:=nil;
  end;

  g_boSound := True;
  FboShowLogo := False;
  FnShowLogoIndex := 0;
  FdwShowLogoTick := GetTickCount;
  boSizeMove := False;

  Randomize;

  new(pWalkCheckSum2);
  new(pHitCheckSum2);
  new(pWalkCheckSum3);
  new(pHitCheckSum3);

  new(pDayBrightCheck);
  new(pDarkLevelCheck);
  new(pLocalFileCheckSum);
  new(pClientCheckSum1);
  new(pClientCheckSum2);
  new(pClientCheckSum3);

  if BoServerIniFile then
  begin
  ini := TIniFile.Create('.\mirsetup.ini');
  if ini <> nil then
   begin
    SERVERADDR := ini.ReadString('Setup', 'ServerAddr', SERVERADDR);
      // 2003/08/29 IME 滚弊荐沥
    LocalLanguage := imSAlpha;
    CurFontName := ini.ReadString('Setup', 'FontName', CurFontName);
    MsgYesIagree := ini.ReadString('Setup', 'Message1', '');
    MsgNoImnot := ini.ReadString('Setup', 'Message2', '');
    ServerCount := _MIN(32, ini.ReadInteger('Server', 'ServerCount', 1));
    for i := 0 to ServerCount - 1 do
    begin
      str := 'Server' + IntToStr(i + 1) + 'Caption';
      ServerCaptionArr[i] := ini.ReadString('Server', str, '');
      str := 'Server' + IntToStr(i + 1) + 'Name';
      ServerNameArr[i] := ini.ReadString('Server', str, '');
    end;
    ini.Free;
   end;
   end
  else
  begin
    SERVERADDR := NetSvrAddr; //服务器IP地址    NetSvrAddr
    ServerCount := 1;  //服务器数量  1就表示1个区
    ServerNameArr[0] := NowSvrName;     //  服务器名字
    ServerCaptionArr[0] := ServerNameArr[0];

   { ServerNameArr[1] := '烈焰';    //第二个服务器名字
    ServerCaptionArr[1] := ServerNameArr[1];
    ServerNameArr[2] := '光芒';    //第三个服务器名字
    ServerCaptionArr[2] := ServerNameArr[2];
    ServerNameArr[3] := '淡水';    //第四个服务器名字
    ServerCaptionArr[3] := ServerNameArr[3];
    ServerNameArr[4] := '流云';    //第五个服务器名字
    ServerCaptionArr[4] := ServerNameArr[4];
    ServerNameArr[5] := '疾风';    //第六个服务器名字
    ServerCaptionArr[5] := ServerNameArr[5];
    ServerNameArr[6] := '新浪';    //第七个服务器名字
    ServerCaptionArr[6] := ServerNameArr[6];
    ServerNameArr[7] := '蜀山';    //第八个服务器名字
    ServerCaptionArr[7] := ServerNameArr[7];  }
  end;
  ToolMenuHook := SetWindowsHookEx(WH_KEYBOARD, @KeyboardHookProc, 0, GetCurrentThreadID);

  ClientVersion := VERSION_YEAR * 10000 + VERSION_MON * 100 + VERSION_DAY;

  flname := '.\wav\sound.lst';
  LoadSoundList(flname);
   //if FileExists (flname) then
   //   SoundList.LoadFromFile (flname);
  DScreen := TDrawScreen.Create;
  IntroScene := TIntroScene.Create;
  LoginScene := TLoginScene.Create;
  SelectChrScene := TSelectChrScene.Create;
  PlayScene := TPlayScene.Create;
  LoginNoticeScene := TLoginNotice.Create;

  Map := TMap.Create;
  DropedItemList := TList.Create;
  MagicList := TList.Create;
  FreeActorList := TList.Create;
   //DObjList := TList.Create;
  EventMan := TClEventManager.Create;
  ChangeFaceReadyList := TList.Create;
   // 2003/02/11
  ViewListCount := 0;
  FillChar(ViewList, sizeof(TMiniViewObject) * MAXVIEWOBJECT, #0);

  Myself := nil;
   // 2003/03/15 酒捞袍 牢亥配府 犬厘
  FillChar(UseItems, sizeof(TClientItem) * 13, #0);            //9->13
  FillChar(ItemArr, sizeof(TClientItem) * MAXBAGITEMCL, #0);
  FillChar(DealItems, sizeof(TClientItem) * 10, #0);
  FillChar(DealRemoteItems, sizeof(TClientItem) * 20, #0);
  SaveItemList := TList.Create;
  MenuItemList := TList.Create;
  WaitingUseItem.Item.S.Name := '';  //馒侩芒 辑滚客 烹脚埃俊 烙矫历厘
  EatingItem.S.Name := '';

  TargetX := -1;
  TargetY := -1;
  TargetCret := nil;
  FocusCret := nil;
  FocusItem := nil;
  MagicTarget := nil;
  AutoTarget := nil;
  TargetCase := 1; // AutoTarget

  DebugCount := 0;
  DebugCount1 := 0;
  DebugCount2 := 0;
  TestSendCount := 0;
  TestReceiveCount := 0;
  BoServerChanging := FALSE;
  BoBagLoaded := FALSE;
  BoOptionLoaded := FALSE;
  BoAutoDig := FALSE;

  LatestClientTime2 := 0;
  FirstClientTime := 0;
  FirstServerTime := 0;
  FirstClientTimerTime := 0;
  LatestClientTimerTime := 0;
  FirstClientGetTime := 0;
  LatestClientGetTime := 0;

  TimeFakeDetectCount := 0;
  TimeFakeDetectTimer := 0;
  TimeFakeDetectSum := 0;
  TimeFakeDetectCountChina := 0;

  SHGetTime := 0;
  SHTimerTime := 0;
  SHFakeCount := 0;
  SHHitSpeedCount := 0;

  DayBright := 3; //广
  DayBright_fake := DayBright;
  pDayBrightCheck^ := DayBright;
  ViewFog := TRUE;
  DarkLevel := 0;
  DarkLevel_fake := DarkLevel;
  pDarkLevelCheck^ := DarkLevel;

  AreaStateValue := 0;
  ConnectionStep := cnsLogin;
  BoWellLogin := FALSE;
  ServerConnected := FALSE;
  SocStr := '';
  WarningLevel := 0;  //阂樊菩哦 荐脚 冉荐 (菩哦汗荤 啊瓷己 乐澜)
  ActionFailLock := FALSE;
  MapMoving := FALSE;
  MapMovingWait := FALSE;
//   CheckBadMapMode := FALSE;
  BoCheckSpeedHackDisplay := FALSE;
   //BoViewMiniMap := FALSE;
  BoWantMiniMap := FALSE;
  BoDrawMiniMap := FALSE;
  ViewMiniMapStyle := 0;  //0: 救焊烙, 1: 馆捧疙, 2: 流立
  ViewGeneralMapStyle := 0;
  PrevVMMStyle := 1;
  FailDir := 0;
  FailAction := 0;
  FailActionTime := GetTickCount;
  DupSelection := 0;

  LastAttackTime := GetTickCount;
  LastMoveTime := GetTickCount;
  LatestSpellTime := GetTickCount;
  TabClickTime := GetTickCount;

  BoFirstTime := TRUE;
  ItemMoving := FALSE;
  DoFadeIn := FALSE;
  DoFadeOut := FALSE;
  DoFastFadeOut := FALSE;
  BoAttackSlow := FALSE;
  BoStopAfterAttack := FALSE;

  BoMoveSlow := FALSE;
  BoMoveSlow2 := FALSE;
  BoNextTimePowerHit := FALSE;
  BoCanLongHit := FALSE;
  BoCanWideHit := FALSE;
   // 2003/03/15 脚痹公傍
  BoCanCrossHit := FALSE;
  BoCanTwinHit := FALSE;
  BoNextTimeFireHit := FALSE;

  BoPlaySoundEffect := TRUE;

  NoDarkness := FALSE;
  SoftClosed := FALSE;
  BoQueryPrice := FALSE;
  SellPriceStr := '';

  AllowGroup := FALSE;
  SellStHold := FALSE;
  GroupMembers := TStringList.Create;
  GroupIdList := TList.Create; // MonOpenHp
   // 2003/04/15 模备, 率瘤
  FriendMembers := TList.Create;
  BlackMembers := TList.Create;
  MailLists := TList.Create;
  BlockLists := TStringList.Create;
  MailAlarm := false;
  WantMailList := false;
   

   // 2003/07/08 楷牢荤力
  fLover := TRelationShipMgr.Create;
  fMaster := TRelationShipMgr.Create;
  fPupil := TRelationShipMgr.Create;

  MainWinHandle := handle;
  g_FrmMainWinHandle := handle;

   //盔努腐, 内齿岿靛 殿..
  BoOneClick := FALSE;
  OneClickMode := toNone;

  CSocket.Active := FALSE;
  CSocket.Port := NetPort;   //登录网关通讯端口
  if MainParam1 = '' then
    CSocket.Address := SERVERADDR
  else
  begin
    if (MainParam1 <> '') and (MainParam2 = '') then  //颇扼皋磐 1俺
      CSocket.Address := MainParam1;
    if (MainParam2 <> '') and (MainParam3 = '') then
    begin  //颇扼皋磐 2俺 牢版快
      CSocket.Address := MainParam1;
      CSocket.Port := Str_ToInt(MainParam2, 0);
    end;
    if (MainParam3 <> '') then
    begin  //颇扼皋磐 3俺牢版快, 烹钦 立加
      if CompareText(MainParam1, '/KWG') = 0 then
      begin
            //内齿 岿靛 侩
        CSocket.Address := kornetworldaddress;  //game.megapass.net';
        CSocket.Port := 9000;
        BoOneClick := TRUE;
        OneClickMode := toKornetWorld;
        with KornetWorld do
        begin
          CPIPcode := MainParam2;
          SVCcode := MainParam3;
          LoginID := MainParam4;
          CheckSum := MainParam5; //'dkskxhdkslxlkdkdsaaaasa';
        end;
      end
      else
      begin
            //老馆 盔努腐 烹钦 霸捞飘侩
        CSocket.Address := MainParam2;
        CSocket.Port := Str_ToInt(MainParam3, 0);
        BoOneClick := TRUE;
      end;
    end;
  end;
  if BO_FOR_TEST then
    CSocket.Address := TESTSERVERADDR;

  SpeedHackTimer := TTimer.Create(self);
  SpeedHackTimer.Interval := 250;
  SpeedHackTimer.Enabled := TRUE;
  SpeedHackTimer.OnTimer := SpeedHackTimerTimer;

  FindWHHackTimer := TTimer.Create(self);
  FindWHHackTimer.Interval := 5000;
  FindWHHackTimer.Enabled := TRUE;
  FindWHHackTimer.OnTimer := FindWHHackTimerTimer;

  RunEffectTimer := TTimer.Create(self); // 侩带怜 倡汾狼辨, 侩鞠狼辨
  RunEffectTimer.Interval := 400;
  RunEffectTimer.Enabled := False;
  RunEffectTimer.OnTimer := RunEffectTimerTimer;
  RunEffectTimer.Tag := 555;

   // MainSurface := nil;
  pLocalFileCheckSum^ := GetFileCheckSum(ParamStr(0));
  BoSendFileCheckSum := FALSE;

   //DebugColor1 := 0;
   //DebugColor2 := 0;
   //DebugColor3 := 0;
   //DebugColor4 := 0;
  EffectNum := 0; // FireDragon

  EncLoginId := '';
  EncLoginPasswd := '';
  EncCharName := '';
  FLoginIDLock := false;

  g_Market := TMarketItemManager.Create;

  BoMsgDlgTimeCheck := False;
  MsgDlgMaxStr := 30;
  SpeedHackUse := False;
  BoViewEffect := True;
//   BackSoundLoopTime := GetTickcount;
  gCheckTime := GetTickcount;

  GameClose := False;
  CouplePower := False;
  StBeltAutoFill := False;
  BtInDex := -1;
  BeltType := 1;
  DropItemView := True;
  gAutoRun := False;
  g_boShowName := False;

  gFps := 0;
  FpsLastTime := GetTickcount;
  AngelFastDraw := False;
  //cSocket.Active := TRUE;
  HGE := HGECreate(HGE_VERSION);
  HGE.System_SetState(HGE_SCREENBPP, 16);
  HGE.System_SetState(HGE_WINDOWED, True);
  HGE.System_SetState(HGE_FScreenWidth, g_FScreenWidth);
  HGE.System_SetState(HGE_FScreenHeight, g_FScreenHeight);
  HGE.System_SetState(HGE_HIDEMOUSE, False);
  HGE.System_SetState(HGE_HWNDPARENT, handle);
  HGE.System_SetState(HGE_SHOWSPLASH, False);
  HGE.System_SetState(HGE_DONTSUSPEND, True);
  HGE.System_SetState(HGE_HARDWARE, True);
  HGE.System_SetState(HGE_TEXTUREFILTER, True);
  HGE.System_SetState(HGE_FPS, HGEFPS_VSYNC); //HGE.System_SetState(HGE_FPS, HGEFPS_VSYNC);
  HGE.System_SetState(HGE_INITIALIZE, MyDeviceInitialize);
  HGE.System_SetState(HGE_FINALIZE, MyDeviceFinalize);
  HGE.System_SetState(HGE_NOTIFYEVENT, MyDeviceNotifyEvent);
  DebugOutStr('----------------------- started ------------------------');

  Application.OnException := OnProgramException;
//   Application.OnIdle := AppOnIdle;

  FrmDlg := TFrmDlg.Create(nil);

end;

procedure TFrmMain.OnProgramException(Sender: TObject; E: Exception);
begin
  DebugOutStr(E.Message);
end;

procedure TFrmMain.WMSysCommand(var Message: TWMSysCommand);
begin
{   with Message do begin
      if (CmdType and $FFF0) = SC_KEYMENU then begin
         if (Key = VK_TAB) or (Key = VK_RETURN) then begin
            FrmMain.WindowState := wsMinimized;
         end else
            inherited;
      end else
         inherited;
   end;
}
  inherited;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
 //HGE 新加 开始
  FIDDraw := nil;
  if FDDrawHandle > 0 then
    FreeLibrary(FDDrawHandle);
  if ToolMenuHook <> 0 then
    UnhookWindowsHookEx(ToolMenuHook);
   //SoundCloseProc;
   //DXTimer.Enabled := FALSE;
  Timer1.Enabled := FALSE;
  MinTimer.Enabled := FALSE;

  DScreen.Finalize;
  PlayScene.Finalize;
  LoginNoticeScene.Finalize;

  DScreen.Free;
  IntroScene.Free;
  LoginScene.Free;
  SelectChrScene.Free;
  PlayScene.Free;
  LoginNoticeScene.Free;
  SaveItemList.Free;
  MenuItemList.Free;

  DebugOutStr('----------------------- closed -------------------------');
  Map.Free;
  DropedItemList.Free;
  MagicList.Free;
  FreeActorList.Free;
  ChangeFaceReadyList.Free;
   //if MainSurface <> nil then MainSurface.Free;

  g_DXSound.Free;
  g_DWinMan.Free;
  DeleteCriticalSection(FCriticalSection);
  FrmDlg.Free;

   //DObjList.Free;
  EventMan.Free;

  if RunEffectTimer <> nil then
    RunEffectTimer.Free;
  if FindWHHackTimer <> nil then
    FindWHHackTimer.Free;
  if SpeedHackTimer <> nil then
    SpeedHackTimer.Free;

   //困殴惑痢
  g_Market.Free;

  BASS_StreamFree(MusicHS);
  if MusicStream <> nil then
    MusicStream.Free;
  BASS_Free;

  HGE.System_Shutdown;
  g_DXFont.Free;
  HGE := nil;
end;

function ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
begin
  with Result do
  begin
    rgbRed := Src.rgbRed + ((Dest.rgbRed - Src.rgbRed) * Percent div 256);
    rgbGreen := Src.rgbGreen + ((Dest.rgbGreen - Src.rgbGreen) * Percent div 256);
    rgbBlue := Src.rgbBlue + ((Dest.rgbBlue - Src.rgbBlue) * Percent div 256);
    rgbReserved := 0;
  end;
end;

procedure TFrmMain.DXDraw1Finalize(Sender: TObject);
begin
   //DXTimer.Enabled := FALSE;
end;

type
  TInt64Decompose = packed record
    case Integer of
      1:
        (nInt64: Int64;);
      2:
        (nInteger1: Integer;
        nInteger2: Integer;);
  end;

procedure TfrmMain.FormActivate(Sender: TObject);
var
  ErrorMsg: string;
  MemoryStatus: TMemoryStatus;
  Reg: TRegistry;
  VersionInfo: TosversionInfo;
  DI: TD3DAdapterIdentifier9;
  ini: TIniFile;
  D3D: IDirect3D9;
{$IFNDEF DEBUG}
  nCount: Integer;
{$ENDIF}
begin
  if boFirstTime then begin
    boFirstTime := FALSE;

    if not BASS_Init(-1, 44100, 0, 0, nil) then
      Application.MessageBox(PCHar('游戏音频初始化失败，将无法播放背景音乐'), '提示信息', MB_OK + MB_ICONSTOP);

    if not HGE.System_Initiate then begin
      ErrorMsg := '----------------错误信息--------------------' + #13#10;
      ErrorMsg := ErrorMsg + HGE.System_GetErrorMessage + #13#10;
      ErrorMsg := ErrorMsg + #13#10;
      ErrorMsg := ErrorMsg + '----------------系统信息--------------------' + #13#10;
      VersionInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
      Reg := TRegistry.Create;
      if Windows.GetVersionEx(VersionInfo) then begin
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        case VersionInfo.dwPlatformId of
          VER_PLATFORM_WIN32s: begin
          
          end;
          VER_PLATFORM_WIN32_WINDOWS: begin
            if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False) then begin
              ErrorMsg := ErrorMsg + '操作系统：' + Reg.ReadString('ProductName') + #13#10;
            end;
            Reg.CloseKey;
          end;
          VER_PLATFORM_WIN32_NT: begin
            if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False) then begin
              ErrorMsg := ErrorMsg + '操作系统：' + Reg.ReadString('ProductName') + #13#10;
            end;
            Reg.CloseKey;
          end;
          VER_PLATFORM_WIN32_CE: begin

          end;
        end;
        ErrorMsg := ErrorMsg + '系统版本：' + Format('%d.%d.%d', [VersionInfo.dwMajorVersion, VersionInfo.dwMinorVersion, VersionInfo.dwBuildNumber]) + #13#10;
        ErrorMsg := ErrorMsg + '补丁版本：' + VersionInfo.szCSDVersion + #13#10;
        if Reg.OpenKey('SOFTWARE\Microsoft\DirectX', False) then begin
          ErrorMsg := ErrorMsg + 'DirectX ：' + Reg.ReadString('Version') + #13#10;
        end;
        Reg.CloseKey;
      end;
      Reg.Free;

      D3D := Direct3DCreate9(D3D_SDK_VERSION);
      if D3D <> nil then begin
        Try
          D3D.GetAdapterIdentifier(D3DADAPTER_DEFAULT, D3DENUM_NO_DRIVERVERSION, DI);
        Except
        End;
        ErrorMsg := ErrorMsg + #13#10;
        ErrorMsg := ErrorMsg + '----------------显卡信息--------------------' + #13#10;
        ErrorMsg := ErrorMsg + '显卡名称：' + DI.Description + #13#10;
        ErrorMsg := ErrorMsg + '驱动程序：' + DI.Driver + #13#10;

        ErrorMsg := ErrorMsg + Format('驱动版本：%d.%d.%d.%d', [
              HIWORD(DI.DriverVersion.HighPart),
              LOWORD(DI.DriverVersion.HighPart),
              HIWORD(DI.DriverVersion.LowPart),
              LOWORD(DI.DriverVersion.LowPart)]) + #13#10;

        ErrorMsg := ErrorMsg + '可用显存：' + IntToStr(HGE.AvailableTextureMem div 1024 div 1024) + 'M' + #13#10;
        ErrorMsg := ErrorMsg + '纹理大小：' + IntToStr(HGE.D3DCaps.MaxTextureWidth) + '*' + IntToStr(HGE.D3DCaps.MaxTextureHeight) + #13#10;
      end;
      D3D := nil;
      SafeFillChar(MemoryStatus, SizeOf(MemoryStatus), #0);
      MemoryStatus.dwLength := SizeOf(TMemoryStatus);
      GlobalMemoryStatus(MemoryStatus);
      ErrorMsg := ErrorMsg + #13#10;
      ErrorMsg := ErrorMsg + '----------------内存信息--------------------' + #13#10;
      ErrorMsg := ErrorMsg + '物理内存：' + intToStr(MemoryStatus.dwTotalPhys div 1024 div 1024) + 'M' + #13#10;
      ErrorMsg := ErrorMsg + '可用物理内存：' + intToStr(MemoryStatus.dwAvailPhys div 1024 div 1024) + 'M' + #13#10;
      ErrorMsg := ErrorMsg + '虚拟内存：' + intToStr(MemoryStatus.dwTotalVirtual div 1024 div 1024) + 'M' + #13#10;
      ErrorMsg := ErrorMsg + '可用虚拟内存：' + intToStr(MemoryStatus.dwAvailVirtual div 1024 div 1024) + 'M' + #13#10;
      CopyStrToClipboard(ErrorMsg);
      ErrorMsg := ErrorMsg + #13#10;
      ErrorMsg := ErrorMsg + '请使用 Ctrl + V 粘贴以上信息发送给游戏管理员        ';
      //Visible := False;
      Application.MessageBox(PCHar(ErrorMsg), '游戏初始化失败', MB_OK + MB_ICONSTOP);
      close;
      HGE.System_Shutdown;
      Exit;
    end;
    MinTimer.Enabled := True;
  end;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   //Savebags ('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemArr);
   //DxTimer.Enabled := FALSE;
end;


{------------------------------------------------------------}

procedure TFrmMain.ProcOnIdle;
var
  done: Boolean;
begin
//   AppOnIdle (self, done);
end;

procedure TFrmMain.AppLogout;
begin
  if mrOk = FrmDlg.DMessageDlg('是否确认退出？', [mbOk, mbCancel]) then
  begin
    SendClientMessage(CM_SOFTCLOSE, 0, 0, 0, 0);
    PlayScene.ClearActors;
    CloseAllWindows;
    if not BoOneClick then
    begin
      SoftClosed := TRUE;
      ActiveCmdTimer(tcSoftClose);
    end
    else
    begin
      ActiveCmdTimer(tcReSelConnect);
    end;
    if BoBagLoaded then
      Savebags('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemArr);

    BoBagLoaded := FALSE;
  end;
end;

procedure TFrmMain.AppExit;
begin
  if mrOk = FrmDlg.DMessageDlg('是否确认退出游戏？', [mbOk, mbCancel]) then
  begin
    if BoBagLoaded then
      Savebags('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemArr);
    BoBagLoaded := FALSE;
    FrmMain.Close;
  end;
end;

procedure TfrmMain.PrintScreenNow;
   function IntToStr2(n: integer): string;
   begin
      if n < 10 then Result := '0' + IntToStr(n)
      else Result := IntToStr(n);
   end;
var
  flname: string;
begin
 if (HGE = nil) or (HGE.GetD3DDevice = nil) then exit;
 if not DirectoryExists('Images') then  CreateDir('Images');
  while TRUE do begin
    flname := 'Images\SaveImag' + IntToStr2(g_nCaptureSerial) + '.jpg';
    if not FileExists (flname) then break;
    Inc (g_nCaptureSerial);
  end;
   //HGE.System_SaveToFile(flname, D3DXIFF_BMP);
  if MySelf <> nil then DScreen.AddChatBoardString(Format('[截图保存位置: %s]', [ExtractFileName(flname)]), clGreen, clWhite);
  end;

{------------------------------------------------------------}

procedure TFrmMain.ProcessKeyMessages;
begin
  case ActionKey of
    VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8:
      begin
        UseMagic(MouseX, MouseY, GetMagicByKey(AnsiChar((ActionKey - VK_F1) + byte('1')))); //胶农赴 谅钎
            //DScreen.AddSysMsg ('KEY' + IntToStr(Random(10000)));
        ActionKey := 0;
        TargetX := -1;
        exit;
      end;
      // 2003/08/20 =>付过窜绵虐 眠啊  // AddMagicKey
    VK_F1 - 100, VK_F2 - 100, VK_F3 - 100, VK_F4 - 100, VK_F5 - 100, VK_F6 - 100, VK_F7 - 100, VK_F8 - 100:
      begin
        UseMagic(MouseX, MouseY, GetMagicByKey(AnsiChar((ActionKey - (VK_F1 - 100)) + byte('1') + 20))); //胶农赴 谅钎
        ActionKey := 0;
        TargetX := -1;
        exit;
      end;
      //-----------
  end;
end;

procedure TFrmMain.ProcessActionMessages;
var
  mx, my, dx, dy, crun: integer;
  ndir, adir, mdir: byte;
  bowalk, bostop: Boolean;
  stdcount: integer;
label
  LB_WALK;
begin
  if Myself = nil then
    exit;

   //Move
  if (TargetX >= 0) and CanNextAction and ServerAcceptNextAction then
  begin //ActionLock捞 钱府搁, ActionLock篮 悼累捞 场唱扁 傈俊 钱赴促.
    if (TargetX <> Myself.XX) or (TargetY <> Myself.YY) then
    begin
      mx := Myself.XX;
      my := Myself.YY;
      dx := TargetX;
      dy := TargetY;
      ndir := GetNextDirection(mx, my, dx, dy);
      case ChrAction of
        caWalk:
          begin
LB_WALK:
               //DScreen.AddSysMsg ('caWalk ' + IntToStr(Myself.XX) + ' ' +
               //                               IntToStr(Myself.YY) + ' ' +
               //                               IntToStr(TargetX) + ' ' +
               //                               IntToStr(TargetY));
            crun := Myself.CanWalk;
            if IsUnLockAction(CM_WALK, ndir) and (crun > 0) then
            begin
              GetNextPosXY(ndir, mx, my);
              bowalk := TRUE;
              bostop := FALSE;
              if not PlayScene.CanWalk(mx, my) then
              begin
                bowalk := FALSE;
                adir := 0;
                if not bowalk then
                begin  //涝备 八荤
                  mx := Myself.XX;
                  my := Myself.YY;
                  GetNextPosXY(ndir, mx, my);
                  if CheckDoorAction(mx, my) then
                    bostop := TRUE;
                end;
                if not bostop and not PlayScene.CrashMan(mx, my) then
                begin //荤恩篮 磊悼栏肺 乔窍瘤 臼澜..
                  mx := Myself.XX;
                  my := Myself.YY;
                  adir := PrivDir(ndir);
                  GetNextPosXY(adir, mx, my);
                  if not Map.CanMove(mx, my) then
                  begin
                    mx := Myself.XX;
                    my := Myself.YY;
                    adir := NextDir(ndir);
                    GetNextPosXY(adir, mx, my);
                    if Map.CanMove(mx, my) then
                      bowalk := TRUE;
                  end
                  else
                    bowalk := TRUE;
                end;
                if bowalk then
                begin
                  Myself.UpdateMsg(CM_WALK, mx, my, adir, 0, 0, '', 0);
                  LastMoveTime := GetTickCount;
                end
                else
                begin
                  mdir := GetNextDirection(Myself.XX, Myself.YY, dx, dy);
                  if mdir <> Myself.Dir then
                    Myself.SendMsg(CM_TURN, Myself.XX, Myself.YY, mdir, 0, 0, '', 0);
                  TargetX := -1;
                end;
              end
              else
              begin
                Myself.UpdateMsg(CM_WALK, mx, my, ndir, 0, 0, '', 0);  //亲惑 付瘤阜 疙飞父 扁撅
                LastMoveTime := GetTickCount;
              end;
            end
            else
            begin
              TargetX := -1;
            end;
          end;
        caRun:
          begin
            stdcount := 0; //0为取消助跑  1需要助跑
            if (MySelf.State and $01000000) <> 0 then
              stdcount := 0;
            if RunReadyCount >= stdcount {1} then
            begin
              crun := Myself.CanRun;
              if (GetDistance(mx, my, dx, dy) >= 2) and (crun > 0) then
              begin
                if IsUnLockAction(CM_RUN, ndir) then
                begin
                  GetNextRunXY(ndir, mx, my);
                  if PlayScene.CanRun(Myself.XX, Myself.YY, mx, my) then
                  begin
                    Myself.UpdateMsg(CM_RUN, mx, my, ndir, 0, 0, '', 0);
                    LastMoveTime := GetTickCount;
                  end
                  else
                  begin
                    mx := Myself.XX;
                    my := Myself.YY;
                    goto LB_WALK;
                  end;
                end
                else
                  TargetX := -1;
              end
              else
              begin
                     //if crun = -1 then begin
                        //DScreen.AddSysMsg ('瘤陛篮 钝 荐 绝嚼聪促.');
                        //TargetX := -1;
                     //end;
                goto LB_WALK;     //眉仿捞 绝绰版快.
                     {if crun = -2 then begin
                        DScreen.AddSysMsg ('泪矫饶俊 钝 荐 乐嚼聪促.');
                        TargetX := -1;
                     end; }
              end;
            end
            else
            begin
              Inc(RunReadyCount);
              goto LB_WALK;
            end;
          end;
      end;
    end;
  end;
  TargetX := -1; //茄锅俊 茄沫究..
  if Myself.RealActionMsg.Ident > 0 then
  begin
    FailAction := Myself.RealActionMsg.Ident; //角菩且锭 措厚
    FailDir := Myself.RealActionMsg.Dir;
    FailActionTime := GetTickCount;
    if Myself.RealActionMsg.Ident = CM_SPELL then
    begin
      SendSpellMsg(Myself.RealActionMsg.Ident, Myself.RealActionMsg.X, Myself.RealActionMsg.Y, Myself.RealActionMsg.Dir, Myself.RealActionMsg.State);
    end
    else
      SendActMsg(Myself.RealActionMsg.Ident, Myself.RealActionMsg.X, Myself.RealActionMsg.Y, Myself.RealActionMsg.Dir);
    Myself.RealActionMsg.Ident := 0;

      //皋春甫 罐篮饶 10惯磊惫 捞惑 吧栏搁 磊悼栏肺 荤扼咙
    if MDlgX <> -1 then
      if (abs(MDlgX - Myself.XX) >= 8) or (abs(MDlgY - Myself.YY) >= 8) then
      begin
        FrmDlg.CloseMDlg;
        FrmDlg.SafeCloseDlg;

{            if(FrmDlg.DMakeItemDlg.Visible) then
               FrmDlg.DMakeItemDlgOkClick(FrmDlg.DMakeItemDlgCancel, 0, 0);
            if FrmDlg.DItemMarketDlg.Visible then FrmDlg.CloseItemMarketDlg;
            if(FrmDlg.DJangwonListDlg.Visible) then
               FrmDlg.DJangwonCloseClick(FrmDlg.DJangwonClose, 0, 0);
            if(FrmDlg.DGABoardListDlg.Visible) then
               FrmDlg.DGABoardListCloseClick(FrmDlg.DGABoardListClose, 0, 0);
            if(FrmDlg.DGABoardDlg.Visible) then
               FrmDlg.DGABoardCloseClick(FrmDlg.DGABoardClose, 0, 0);}

        MDlgX := -1;
      end;
  end;
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  msg, wc, dir, mx, my: integer;
  ini: TIniFile;
begin
//  DScreen.AddChatBoardString ('FormKeyDown Key=> '+IntToStr(Key), clGreen, clWhite);
  case Key of
    VK_PAUSE:
      begin
        Key := 0;
        PrintScreenNow;
      end;
    VK_RETURN: begin
        if (ssAlt in Shift) and (Key = VK_RETURN) then begin
          FullScreen(not g_boFullScreen);
          Exit;
        end;
      end;
  end;
//  //增加全屏窗口切换
//  if (ssAlt in Shift) and (Key = VK_RETURN) then begin
//    FullScreen(not g_boFullScreen);
  //end;

  if g_DWinMan.KeyDown(Key, Shift) then
    exit;

  if (Myself = nil) or (DScreen.CurrentScene <> PlayScene) then
    exit;

//   if PlayScene.EdChat.Visible then begin
//      exit;
//   end;

  mx := Myself.XX;
  my := Myself.YY;
  case Key of
    VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8:
      if ssCtrl in Shift then
      begin
        if (GetTickCount - LatestSpellTime > (400 + MagicDelayTime)) then      //技能间隔延迟 默认是500
        begin
          ActionKey := Key - 100;
        end;
        Key := 0;
      end
      else
      begin //-----
        if (GetTickCount - LatestSpellTime > (500 + MagicDelayTime)) then
        begin
          ActionKey := Key;
        end;
        Key := 0;
      end;
    VK_F9:
      begin
        FrmDlg.OpenItemBag;
      end;
    VK_F10:
      begin
        FrmDlg.StatePage := 0;
        FrmDlg.OpenMyStatus;
        Key := 0
      end;
    VK_F11:
      begin
        FrmDlg.StatePage := 3;
        FrmDlg.OpenMyStatus;
      end;

{    VK_RETURN:
        begin
          PlayScene.EdChat.Visible := TRUE;
          PlayScene.EdChat.SetFocus;
          SetImeMode(PlayScene.EdChat.Handle, imOpen);
          if FrmDlg.BoGuildChat then
          begin
            PlayScene.EdChat.Text := '!~';
            PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
            PlayScene.EdChat.SelLength := 0;
          end
          else
          begin
            PlayScene.EdChat.Text := '';
          end;
//               LocalLanguage := imSAlpha;
        end; }

    word('R'):
      begin
        if (ssAlt in Shift) and (GetTickCount > m_CheckTick) then
        begin
          m_CheckTick := GetTickCount + 1000;
          SendClientMessage(CM_QUERYBAGITEMS, 0, 0, 0, 0);
        end;
      end;
    word('H'):
      begin
        if ssCtrl in Shift then
        begin
          SendSay('@AttackMode');
        end;
      end;
    word('A'):
      begin
        if ssCtrl in Shift then
        begin
          SendSay('@Rest');
        end;
      end;
    word('F'):
      begin
        if ssCtrl in Shift then
        begin

        end;
      end;
    word('X'):
      begin
        if Myself = nil then
          exit;
        if ssAlt in Shift then
        begin
          FrmMain.SendClientMessage(CM_CANCLOSE, 0, 0, 0, 0);

{               if (GetTickCount - LatestStruckTime > 10000) and
                  (GetTickCount - LatestMagicTime > 10000) and
                  (GetTickCount - LatestHitTime > 10000) or
                  (Myself.Death) then
               begin
                  AppLogOut;
               end else
                  DScreen.AddChatBoardString ('在战斗的时候你不能退出游戏.', clYellow, clRed);}
        end;
      end;
      word('W'): begin
        if GetTickCount - g_dwKeyTimeTick > 200 then begin
          g_dwKeyTimeTick := GetTickCount;
          if ssAlt in Shift then begin  //添加遍组
            if FocusCret <> nil then
               if GroupMembers.Count = 0 then
                  SendCreateGroup(FocusCret.UserName)
               else SendAddGroupMember(FocusCret.UserName);
          end;
        end;
      end;
      word('E'): begin
        if GetTickCount - g_dwKeyTimeTick > 200 then begin
          g_dwKeyTimeTick := GetTickCount;
          if ssAlt in Shift then begin  //删除队员
            if FocusCret <> nil then
              SendDelGroupMember(FocusCret.UserName)
          end;
        end;
      end;
     word('Q'):
      begin
        if Myself = nil then
          exit;
        if ssAlt in Shift then
        begin
          if (GetTickCount - LatestStruckTime > 10000) and (GetTickCount - LatestMagicTime > 10000) and (GetTickCount - LatestHitTime > 10000) or (Myself.Death) then
          begin
            AppExit;
          end
          else
            DScreen.AddChatBoardString('在战斗的时候你不能退出游戏.', clYellow, clRed);
        end;
      end;
  end;

  case Key of
    VK_UP:
      with DScreen do
      begin
        if ChatBoardTop > 0 then
          Dec(ChatBoardTop);
      end;
    VK_DOWN:
      with DScreen do
      begin
        if ChatBoardTop < ChatStrs.Count - 1 then
          Inc(ChatBoardTop);
      end;
    VK_PRIOR:
      with DScreen do
      begin
        if ChatBoardTop > VIEWCHATLINE then
          ChatBoardTop := ChatBoardTop - VIEWCHATLINE
        else
          ChatBoardTop := 0;
      end;
    VK_NEXT:
      with DScreen do
      begin
        if ChatBoardTop + VIEWCHATLINE < ChatStrs.Count - 1 then
          ChatBoardTop := ChatBoardTop + VIEWCHATLINE
        else
          ChatBoardTop := ChatStrs.Count - 1;
        if ChatBoardTop < 0 then
          ChatBoardTop := 0;
      end;
  end;
end;

procedure TFrmMain.FormKeyPress(Sender: TObject; var Key: Char);
var
  i: integer;
begin
//  DScreen.AddChatBoardString ('FormKeyPress Key=> '+IntToStr(byte(Key)), clGreen, clWhite);
  if FrmDlg.DSelServerDlg.Visible then
  begin
//          MessageDlg ('FormKeyPress Key=> '+IntToStr(byte(Key)), mtWarning, [mbOk], 0);
    case byte(Key) of
      byte('1'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer1, 1, 1);
      byte('2'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer2, 1, 1);
      byte('3'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer3, 1, 1);
      byte('4'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer4, 1, 1);
      byte('5'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer5, 1, 1);
      byte('6'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer6, 1, 1);
      byte('7'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer7, 1, 1);
      byte('8'):
        FrmDlg.DSServer1Click(FrmDlg.DSServer8, 1, 1);
    end;
    Exit;
  end;

  if g_DWinMan.KeyPress(Key) then
    exit;

  if (byte(Key) = 13) and FrmDlg.DSelectChr.Visible and (not FrmDlg.DCreateChr.Visible) then
  begin
    SelectChrScene.SelChrStartClick;
    Exit;
  end;

  if DScreen.CurrentScene = PlayScene then
  begin
    if PlayScene.EdChat.Visible then
    begin
      exit;
    end;
    case byte(Key) of
//      byte('I'), byte('i'):
//        begin
//          FrmDlg.OpenItemBag;
//        end;
//      byte('C'), byte('c'):
//        begin
//          FrmDlg.StatePage := 0;
//          FrmDlg.OpenMyStatus;
//        end;
//      byte('S'), byte('s'):
//        begin
//          FrmDlg.StatePage := 3;
//          FrmDlg.OpenMyStatus;
//        end;
      byte('A'), byte('a'):
        begin
          SendSay('@Rest');
        end;
        //取消显示翅膀效果快捷键
//      byte('K'), byte('k'):
//        begin
//          BoViewEffect := not BoViewEffect;
//          if BoViewEffect then
//            DScreen.AddChatBoardString('<显示翅膀效果>', clGreen, clWhite)
//          else
//            DScreen.AddChatBoardString('<不显示翅膀效果>', clGreen, clWhite)
//        end;
//      byte('O'), byte('o'):
//        FrmDlg.DMyStateClick(FrmDlg.DOption, 0, 0);
//      byte('V'), byte('v'):
//        begin
//          FrmDlg.DBotMiniMapClick(nil, 0, 0);
//        end;
      byte('`'):       //快捷键显示拾取物品
        begin
          SendPickup;
          TabClickTime := GetTickCount;
        end;
        //取消B键大地图功能
//      byte('B'), byte('b'):
//        begin
//          FrmMain.SendWantMiniMap;
//          if ViewGeneralMapStyle < 2 then
//          begin
//            Inc(ViewGeneralMapStyle);
//          end
//          else
//            ViewGeneralMapStyle := 0;
//        end;
            // 取消U键月灵快速绘制
//      byte('U'), byte('u'):
//        begin
//          if AngelFastDraw then
//          begin
//            AngelFastDraw := False;
//            DScreen.AddChatBoardString('<月灵的快速绘制开启>', clGreen, clWhite)
//          end
//          else
//          begin
//            AngelFastDraw := True;
//            DScreen.AddChatBoardString('<月灵的快速绘制关闭>', clGreen, clWhite)
//          end;
//        end;
                   //人物显名开关
          byte('N'), byte('n'):
             begin
                if g_boShowName then begin
                   g_boShowName := False;
                   DScreen.AddChatBoardString ('人物显名关闭', clGreen, clWhite)
                end
                else begin
                   g_boShowName := True;
                   DScreen.AddChatBoardString ('人物显名开启', clGreen, clWhite)
                end;
             end;
      byte('D'), byte('d'): //自动跑路
        begin
          RunReadyCount := 0;
          if gAutoRun then
          begin
            gAutoRun := False;
            DScreen.AddChatBoardString('自动奔跑关闭', clGreen, clWhite)
          end
          else
          begin
            gAutoRun := True;
            DScreen.AddChatBoardString('自动奔跑开启', clGreen, clWhite)
          end;
        end;
//      byte('P'), byte('p'):
//        begin
//          FrmDlg.DBotGroupClick(nil, 0, 0);
//        end;
      byte('T'), byte('t'):
        begin
          FrmDlg.DBotTradeClick(nil, 0, 0);
        end;
      byte('G'), byte('g'):
        begin
          FrmDlg.DBotGuildClick(nil, 0, 0);
        end;
          // 2003/01/13 .. 窜绵虐 眠啊 ======================== 场
          // 2003/04/15 模备, 率瘤
         //  好友快捷键
//      byte('W'), byte('w'):
//        begin
//          FrmDlg.DBotFriendClick(nil, 0, 0);
//        end;
//         //  邮件快捷键
//      byte('M'), byte('m'):
//        begin
//          FrmDlg.DBotMemoClick(nil, 0, 0);
//        end;
//         //  关系快捷键
//      byte('L'), byte('l'):
//        begin
//          FrmDlg.DBotMasterClick(nil, 0, 0);
//        end;

      byte('1')..byte('6'):
        begin
        //  FrmDlg.SwapBujuk(byte(Key) - byte('1'));

          StBeltAutoFill := True;
          EatItem(byte(Key) - byte('1')); //骇飘 酒捞袍阑 荤侩茄促.
        end;
      27: //ESC
        begin
          CloseAllWindows;
        end;
      byte(' '), 13: //盲泼 冠胶
        begin
          PlayScene.EdChat.Visible := TRUE;
          PlayScene.EdChat.SetFocus;
          SetImeMode(PlayScene.EdChat.Handle, imOpen);
          if FrmDlg.BoGuildChat then
          begin
            PlayScene.EdChat.Text := '!~';
            PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
            PlayScene.EdChat.SelLength := 0;
          end
          else
          begin
            PlayScene.EdChat.Text := '';
          end;
//               LocalLanguage := imSAlpha;
        end; 
      byte('@'), byte('!'), byte(','), byte('/'):
        begin
          PlayScene.EdChat.Visible := TRUE;
          PlayScene.EdChat.SetFocus;
          LocalLanguage := imSHanguel;
          SetImeMode(PlayScene.EdChat.Handle, LocalLanguage);
          if Key = '/' then
          begin
            if WhisperName = '' then
              PlayScene.EdChat.Text := Key
            else if Length(WhisperName) > 2 then
              PlayScene.EdChat.Text := '/' + WhisperName + ' '
            else
              PlayScene.EdChat.Text := Key;
            PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
            PlayScene.EdChat.SelLength := 0;
          end
          else if Key = ',' then
          begin
            if Copy(fLover.GetDisplay(0), length(STR_LOVER) + 1, 6) <> '' then
              PlayScene.EdChat.Text := '⒔'
            else
              PlayScene.EdChat.Text := Key;
            PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
            PlayScene.EdChat.SelLength := 0;
          end
          else
          begin
            PlayScene.EdChat.Text := Key;
            PlayScene.EdChat.SelStart := 1;
            PlayScene.EdChat.SelLength := 0;
          end;
          LocalLanguage := imSAlpha;
        end;
    end;
    Key := #0;
  end;
end;

function TFrmMain.GetMagicByKey(Key: AnsiChar): PTClientMagic;
var
  i: integer;
  pm: PTClientMagic;
begin
  Result := nil;
  for i := 0 to MagicList.Count - 1 do
  begin
    pm := PTClientMagic(MagicList[i]);
    if pm.Key = Key then
    begin
      Result := pm;
      break;
    end;
  end;
end;

var
  g_dwOverSpaceWarningTick: LongWord;   //魔法释放超过指定范围提示间隔

procedure TFrmMain.UseMagic(tx, ty: integer; pcm: PTClientMagic);
var
  tdir, targx, targy, targid: integer;
  pmag: PTUseMagicInfo;
  meff: TMagicEff;
  TempTarget: TActor;
  SpellSpend: word;
  boOutRange: Boolean;  //魔法释放范围
begin
  if pcm = nil then
    exit;

//   if (pcm.Def.Spell + pcm.Def.DefSpell <= Myself.Abil.MP) or (pcm.Def.EffectType = 0) then begin
  SpellSpend := Round(pcm.Def.Spell / (pcm.Def.MaxTrainLevel + 1) * (pcm.Level + 1)) + pcm.Def.DefSpell;

  if (SpellSpend <= Myself.Abil.MP) or (pcm.Def.EffectType = 0) then
  begin

    if pcm.Def.EffectType = 0 then
    begin
         //if CanNextAction and ServerAcceptNextAction then begin
      if pcm.Def.MagicId = SWD_FIREHIT then
      begin
        if GetTickCount - LatestFireHitTime < 10 * 1000 then
        begin
          exit;
        end;
      end;

      if pcm.Def.MagicId = SWD_RUSHRUSH then
      begin
        if GetTickCount - LatestRushRushTime < 3 * 1000 then
        begin
          exit;
        end;
      end;

      if pcm.Def.MagicId = SWD_TWINHIT then
      begin
        BoStopAfterAttack := TRUE;
        if BoViewEffect then
        begin
          meff := TCharEffect.Create(210, 6, MySelf);
          meff.NextFrameTime := 120;
          meff.ImgLib := WMagic2;
          PlayScene.EffectList.Add(meff);
        end;
      end;

      if GetTickCount - LatestSpellTime > 500 then
      begin
        LatestSpellTime := GetTickCount;
        MagicDelayTime := 0; //pcm.Def.DelayTime;
        SendSpellMsg(CM_SPELL, Myself.Dir{x}, 0, pcm.Def.MagicId, 0);
      end;
    end
    else
    begin
      tdir := GetFlyDirection(390, 175, tx, ty);

      TurnDuFu(pcm);

      if (pcm.Def.Effect in [2, 6, 7, 8, 11, 12, 14, 15, 16, 17, 18, 20, 21, 22, 26, 27, 28, 29, 31, 35, 36, 40, 41, 44, 46, 47]) then
      begin
        TargetCase := 1;
        MagicTarget := FocusCret;
      end
      else
      begin
        TargetCase := 2;
        if (FocusCret <> nil) and (not FocusCret.Death) then
        begin
          if FocusCret.Race = 0 then
          begin
            TargetCase := 1;
            MagicTarget := FocusCret;
            AutoTarget := FocusCret;  //如果目标为人物也执行技能目标锁定
          end
          else
            AutoTarget := FocusCret;
        end;
        if (AutoTarget <> nil) and AutoTarget.Death then
          AutoTarget := nil;
      end;

      if TargetCase = 2 then
        TempTarget := AutoTarget
      else
        TempTarget := MagicTarget;
      if (TempTarget = nil) or (TempTarget <> FocusCret) then
      begin
        if (FocusCret <> nil) and (not FocusCret.Death) then
          TempTarget := FocusCret;
      end;
      if (not PlayScene.IsValidActor(TempTarget)) and (TempTarget <> nil) and (not TempTarget.Death) then
        TempTarget := nil;

      if TargetCase = 1 then
        MagicTarget := TempTarget
      else if TargetCase = 2 then
        AutoTarget := TempTarget;

      if TempTarget = nil then
      begin
        PlayScene.CXYfromMouseXY(tx, ty, targx, targy);
        targid := 0;
      end
      else
      begin
        targx := TempTarget.XX;
        targy := TempTarget.YY;
        targid := TempTarget.RecogId;
        tdir := GetNextDirection(Myself.XX, Myself.YY, targx, targy);    //魔法攻击目标人物面相目标
      end;

      boOutRange := (abs(MySelf.XX - targx) > 8) or (abs(MySelf.YY - targy) > 8);   // 魔法释放范围

      // 魔法释放范围
      if boOutRange then begin
        if (pcm.Def.Effect in [1, 3, 4, 9, 10, 11, 12, 14, 17, 18, 20, 21, 26, 27, 30, 31, 34, 39, 40, 44, 46, 47]) then   //如果是这些技能释放超过距离就执行失败
        begin
          if GetTickCount - g_dwOverSpaceWarningTick > 1000 then begin
          g_dwOverSpaceWarningTick := GetTickCount;
          DScreen.AddSysMsg('目标太远了，施展魔法失败！！！');
         end;
         TargetX := -1;
         Exit
        end;
      end;

      if CanNextAction and ServerAcceptNextAction then
      begin
        LatestSpellTime := GetTickCount;
        new(pmag);
        FillChar(pmag^, sizeof(TUseMagicInfo), #0);
        pmag.EffectNumber := pcm.Def.Effect;
        pmag.MagicSerial := pcm.Def.MagicId;
        pmag.ServerMagicCode := 0;
        MagicDelayTime := 200 + pcm.Def.DelayTime;

        case pmag.MagicSerial of
          2, 14, 15, 16, 17, 18, 19, 21, 12, 25, 26, 28, 29, 30, 31, 40, 41, 42, 43:
            ;
        else
          LatestMagicTime := GetTickCount;
        end;

        MagicPKDelayTime := 0;
//        if MagicTarget <> nil then      //群体技能攻击人物魔法随机延迟
//          if MagicTarget.Race = 0 then
//            MagicPKDelayTime := 300 + Random(1100); //(600+200 + MagicDelayTime div 5);

        Myself.SendMsg(CM_SPELL, targx, targy, tdir, Integer(pmag), targid, '', 0);
      end; // else
            //Dscreen.AddSysMsg ('过一会你就可以用它了.');
         //Inc (SpellCount);
    end;
  end
  else
    Dscreen.AddSysMsg('没有足够的魔法点数.');
end;

procedure TFrmMain.UseMagicSpell(who, effnum, targetx, targety, magic_id: integer);
var
  actor: TActor;
  adir: integer;
  pmag: PTUseMagicInfo;
begin
  actor := PlayScene.FindActor(who);
  if actor <> nil then
  begin
    adir := GetFlyDirection(actor.XX, actor.YY, targetx, targety);
    new(pmag);
    FillChar(pmag^, sizeof(TUseMagicInfo), #0);
    pmag.EffectNumber := effnum;
    pmag.ServerMagicCode := 0;
    pmag.MagicSerial := magic_id;
    actor.SendMsg(SM_SPELL, 0, 0, adir, Integer(pmag), 0, '', 0);
    Inc(SpellCount);
  end
  else
    Inc(SpellFailCount);
end;

procedure TFrmMain.UseMagicFire(who, efftype, effnum, targetx, targety, target: integer);
var
  actor: TActor;
  adir, sound: integer;
  pmag: PTUseMagicInfo;
begin
  actor := PlayScene.FindActor(who);
  if actor <> nil then
  begin
    actor.SendMsg(SM_MAGICFIRE, target{111magid}, efftype, effnum, targetx, targety, '', sound);
      //if actor = Myself then Dec (SpellCount);
    if FireCount < SpellCount then
      Inc(FireCount);
  end;
end;

procedure TFrmMain.UseMagicFireFail(who: integer);
var
  actor: TActor;
begin
  actor := PlayScene.FindActor(who);
  if actor <> nil then
  begin
    actor.SendMsg(SM_MAGICFIRE_FAIL, 0, 0, 0, 0, 0, '', 0);
  end;
  MagicTarget := nil;
end;

procedure TFrmMain.UseNormalEffect(effnum, effx, effy: integer);
var
  meff, meff2: TMagicEff;
  k: integer;
  bofly: Boolean;
begin
  meff := nil;
  meff2 := nil;
  if not BoViewEffect then
    Exit;
  case effnum of
    NE_HEARTPALP:
      meff := TNormalDrawEffect.Create(effx, effy, WMon14Img, 410, 6, 120, FALSE);
    NE_CLONESHOW:
      meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 670, 10, 150, True);
    NE_THUNDER:
      begin
        PlayScene.NewMagic(nil, MAGIC_DUN_THUNDER, MAGIC_DUN_THUNDER, effx, effy, effx, effy, 0, mtThunder, FALSE, 30, bofly);
        PlaySound(8301);
      end;
    NE_FIRE:
      begin
        PlayScene.NewMagic(nil, MAGIC_DUN_FIRE1, MAGIC_DUN_FIRE1, effx, effy, effx, effy, 0, mtThunder, FALSE, 30, bofly);
        PlayScene.NewMagic(nil, MAGIC_DUN_FIRE2, MAGIC_DUN_FIRE2, effx, effy, effx, effy, 0, mtThunder, FALSE, 30, bofly);
        PlaySound(8302);
      end;
    NE_DRAGONFIRE:
      begin
        PlayScene.NewMagic(nil, MAGIC_DRAGONFIRE, MAGIC_DRAGONFIRE, effx, effy, effx, effy, 0, mtThunder, FALSE, 30, bofly);
        PlaySound(8207);
      end;

    NE_FIREBURN:
      begin
        PlayScene.NewMagic(nil, MAGIC_FIREBURN, MAGIC_FIREBURN, effx, effy, effx, effy, 0, mtThunder, FALSE, 30, bofly);
        PlaySound(8226);
      end;
    NE_FIRECIRCLE:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 910, 23, 100, True);
      end;
    NE_POISONFOG:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 1280, 10, 100, True);
        PlaySound(2446);
      end;
    NE_SN_MOVEHIDE:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 1300, 10, 80, True);
        PlaySound(2447);
      end;
    NE_SN_MOVESHOW:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 1310, 10, 80, True);
        PlaySound(2447);
      end;
    NE_SN_RELIVE:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 1330, 10, 100, True);
        PlaySound(2448);
      end;
    NE_FOX_MOVEHIDE:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMon24Img, 800, 10, 90, True);
        PlaySound(109);
      end;
    NE_FOX_MOVESHOW:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMon24Img, 810, 10, 90, True);
        PlaySound(110);
      end;
    NE_SOULSTONE_HIT:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMon24Img, 1410, 10, 120, True);
        PlaySound(157);
      end;
    NE_KINGSTONE_RECALL_1:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 1370, 10, 110, True);
        PlaySound(2579);
      end;
    NE_KINGSTONE_RECALL_2:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMagic2, 1390, 10, 110, True);
        PlaySound(10062);
      end;
    NE_KINGTURTLE_MOBSHOW:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WMon25Img, 3080, 10, 90, True);
        PlaySound(110);
      end;
    NE_DEFENCEEFFECT:
      begin
        meff := TNormalDrawEffect.Create(effx, effy, WEffectImg, 580, 10, 90, True);
//         PlaySound (110);
      end;
  end;
  if meff <> nil then
  begin
    meff.MagOwner := Myself;
    PlayScene.EffectList.Add(meff);
  end;
  if meff2 <> nil then
  begin
    meff2.MagOwner := Myself;
    PlayScene.EffectList.Add(meff2);
  end;
end;

procedure TFrmMain.UseLoopNormalEffect(ActorID: integer; EffectIndex, LoopTime: Word);
var
  actor: TActor;
  meff: TMagicEff;
begin
  meff := nil;
  if not BoViewEffect then
    Exit;
  actor := PlayScene.FindActor(ActorID);

  case EffectIndex of
    NE_CLONEHIDE: //分身术
      begin
        meff := TCharEffect.Create(690, 10, actor);
        meff.NextFrameTime := 150;
        meff.RepeatUntil := 0;
        PlaySound(48);
      end;
    NE_MONCAPTURE:
      begin
        meff := TCharEffect.Create(1020, 8, actor);
        meff.NextFrameTime := 110;
        meff.RepeatUntil := GetTickCount + LoopTime;
        PlaySound(10475);
      end;
    NE_BLOODSUCK:
      begin
        meff := TCharEffect.Create(1090, 10, actor);
        meff.NextFrameTime := 100;
        meff.RepeatUntil := 0;
        PlaySound(10485);
      end;
    NE_FLOWERSEFFECT:
      begin
        meff := TCharEffect.Create(1160, 20, actor);
        meff.NextFrameTime := 120;
        meff.RepeatUntil := GetTickCount + LoopTime;
        meff.Blend := False
      end;
    NE_LEVELUP:
      begin
        PlaySound(156);
        meff := TCharEffect.Create(1190, 20, actor);
        meff.NextFrameTime := 80;
        meff.RepeatUntil := GetTickCount + LoopTime;
      end;
    NE_RELIVE:
      begin
        Exit;
{         meff := TCharEffect.Create (1220, 20, actor);
         meff.NextFrameTime := 100;
         meff.RepeatUntil := GetTickCount + LoopTime;}
      end;
    NE_BIGFORCE:
      begin
        meff := TCharEffect.Create(160, 15, actor);
        meff.NextFrameTime := 80;
        meff.RepeatUntil := 0;
      end;
    NE_FOX_FIRE:
      begin
        meff := TCharEffect.Create(1350, 10, actor);
        meff.NextFrameTime := 100;
        meff.RepeatUntil := GetTickCount + LoopTime;
      end;
    NE_SIDESTONE_PULL:
      begin
        meff := TCharEffect.Create(1410, 10, actor);
        meff.NextFrameTime := 150;
        meff.RepeatUntil := GetTickCount + LoopTime;
        PlaySound(2547);
      end;
    NE_HAPPYBIRTHDAY:
      begin
        PlaySound(158);
//      DScreen.AddChatBoardString ('NE_HAPPYBIRTHDAY', clYellow, clRed);
        meff := TCharEffect.Create(1430, 30, actor);
        meff.NextFrameTime := 100;
        meff.RepeatUntil := GetTickCount + LoopTime;
      end;
    NE_KOREAFIGHTING:
      begin
        PlaySound(161);
        meff := TCharEffect.Create(1470, 30, actor);
        meff.NextFrameTime := 80;
        meff.RepeatUntil := GetTickCount + LoopTime;
      end;
  end;

  if meff <> nil then
  begin
    meff.ImgLib := WMagic2;
    PlayScene.EffectList.Add(meff);
  end;
end;

procedure TFrmMain.EatItem(idx: integer);
  procedure UnBindItem(sn:string);
  var
  i, code , icnt: integer;
  pcm: pTUnbindInfo;
  begin
    if gettickcount - g_nLastUnbindTime < 1000 then exit;

    icnt := BagItemCount;
    if icnt + 11 > MAXBAGITEMCL then exit;

    // 是否有相同的物品
    for I := 0 to MAXBAGITEMCL - 1 do begin
      if ItemArr[i].S.Name = EatingItem.S.Name then
        exit;
    end;

    // 解包代码
    code := -1;
    for i := 0 to g_UnbindItemList.Count - 1 do begin
      pcm := pTUnbindInfo(g_UnbindItemList[i]);
      if pcm.sItemName = EatingItem.S.Name then begin
        code := pcm.nUnbindCode;
        break;
      end;
    end;

    if code = -1 then exit;

    for I := 0 to MAXBAGITEMCL - 1 do begin
      if (ItemArr[i].S.Shape = code) and (ItemArr[i].S.Name <> '') then begin
        g_nLastUnbindTime := gettickcount;
        SendEat(i, ItemArr[i].MakeIndex, ItemArr[i].S.Name);
        ItemArr[i].S.Name := '';
        break;
      end;
    end;
  end;
begin
  if (MovingItem.Item.S.StdMode = 7) and ItemMoving then
  begin
    EatingItem := MovingItem.Item;
    FrmDlg.CancelItemMoving;
    EatTime := GetTickCount;
    SendEat(idx, EatingItem.MakeIndex, EatingItem.S.Name);
//      DScreen.AddChatBoardString ('SendEat-after', clYellow, clRed);
    ItemUseSound(EatingItem.S.StdMode);
    Exit;
  end;

  if idx in [0..MAXBAGITEMCL - 1] then
  begin
    if (EatingItem.S.Name <> '') and (GetTickCount - EatTime > 5 * 1000) then
    begin
      EatingItem.S.Name := '';
    end;
    if (EatingItem.S.Name = '') and (ItemArr[idx].S.Name <> '') and (ItemArr[idx].S.StdMode in [0..3,70]) then
    begin
      EatingItem := ItemArr[idx];
      ItemArr[idx].S.Name := '';

      if (ItemArr[idx].S.StdMode = 4) and (ItemArr[idx].S.Shape < 100) then
      begin
        if ItemArr[idx].S.Shape < 50 then
        begin
          if mrYes <> FrmDlg.DMessageDlg(ItemArr[idx].S.Name + '你要开始学习吗？', [mbYes, mbNo]) then
          begin
            ItemArr[idx] := EatingItem;
            exit;
          end;
        end
        else
        begin
          if mrYes <> FrmDlg.DMessageDlg(ItemArr[idx].S.Name + '你要使用吗？', [mbYes, mbNo]) then
          begin
            ItemArr[idx] := EatingItem;
            exit;
          end;
        end;
      end;
      EatTime := GetTickCount;
      SendEat(idx, ItemArr[idx].MakeIndex, ItemArr[idx].S.Name);
      ItemUseSound(ItemArr[idx].S.StdMode);
      UnBindItem(EatingItem.s.Name);
    end;
  end
  else
  begin
    if (idx = -1) and ItemMoving then
    begin
      ItemMoving := FALSE;
      EatingItem := MovingItem.Item;
      MovingItem.Item.S.Name := '';

      if (EatingItem.S.StdMode = 4) and (EatingItem.S.Shape < 100) then
      begin
        if EatingItem.S.Shape < 50 then
        begin
          if mrYes <> FrmDlg.DMessageDlg('"' + EatingItem.S.Name + '"是否开始修炼?', [mbYes, mbNo]) then
          begin
            AddItemBag(EatingItem);
            exit;
          end;
        end
        else
        begin
          if mrYes <> FrmDlg.DMessageDlg('"' + EatingItem.S.Name + '"是否开始修炼?', [mbYes, mbNo]) then
          begin
            AddItemBag(EatingItem);
            exit;
          end;
        end;
      end;
      EatTime := GetTickCount;
      SendEat(idx, EatingItem.MakeIndex, EatingItem.S.Name);
      ItemUseSound(EatingItem.S.StdMode);
      UnBindItem(EatingItem.s.Name);   
    end;
  end;
end;

function TFrmMain.TargetInSwordLongAttackRange(ndir: integer): Boolean;
var
  nx, ny: integer;
  actor: TActor;
begin
  Result := FALSE;
  GetFrontPosition(Myself.XX, Myself.YY, ndir, nx, ny);
  GetFrontPosition(nx, ny, ndir, nx, ny);
  if (abs(Myself.XX - nx) = 2) or (abs(Myself.YY - ny) = 2) then
  begin
    actor := PlayScene.FindActorXY(nx, ny);
    if actor <> nil then
      if not actor.Death then
        Result := TRUE;
  end;
end;

function TFrmMain.TargetInSwordWideAttackRange(ndir: integer): Boolean;
var
  nx, ny, rx, ry, mdir: integer;
  actor, ractor: TActor;
begin
  Result := FALSE;
  GetFrontPosition(Myself.XX, Myself.YY, ndir, nx, ny);
  actor := PlayScene.FindActorXY(nx, ny);

  mdir := (ndir + 1) mod 8;
  GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
  ractor := PlayScene.FindActorXY(rx, ry);
  if ractor = nil then
  begin
    mdir := (ndir + 2) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;
  if ractor = nil then
  begin
    mdir := (ndir + 7) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;

  if (actor <> nil) and (ractor <> nil) then
    if not actor.Death and not ractor.Death then
      Result := TRUE;
end;

function TFrmMain.TargetInSwordCrossAttackRange(ndir: integer): Boolean;
var
  nx, ny, rx, ry, mdir: integer;
  actor, ractor: TActor;
begin
  Result := FALSE;
  GetFrontPosition(Myself.XX, Myself.YY, ndir, nx, ny);
  actor := PlayScene.FindActorXY(nx, ny);

  mdir := (ndir + 1) mod 8;
  GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
  ractor := PlayScene.FindActorXY(rx, ry);
  if ractor = nil then
  begin
    mdir := (ndir + 2) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;
  if ractor = nil then
  begin
    mdir := (ndir + 3) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;
  if ractor = nil then
  begin
    mdir := (ndir + 4) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;
  if ractor = nil then
  begin
    mdir := (ndir + 5) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;
  if ractor = nil then
  begin
    mdir := (ndir + 6) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;
  if ractor = nil then
  begin
    mdir := (ndir + 7) mod 8;
    GetFrontPosition(Myself.XX, Myself.YY, mdir, rx, ry);
    ractor := PlayScene.FindActorXY(rx, ry);
  end;

  if (actor <> nil) and (ractor <> nil) then
    if not actor.Death and not ractor.Death then
      Result := TRUE;
end;

{--------------------- Mouse Interface ----------------------}

procedure TFrmMain.DXDraw1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i, mx, my, msx, msy, sel: integer;
  target: TActor;
  itemnames: string;
begin
  if g_DWinMan.MouseMove(Shift, X, Y) then
    exit;
  if (Myself = nil) or (DScreen.CurrentScene <> PlayScene) then
    exit;
  BoSelectMyself := PlayScene.IsSelectMyself(X, Y);

  target := PlayScene.GetAttackFocusCharacter(X, Y, DupSelection, sel, FALSE);
  if DupSelection <> sel then
    DupSelection := 0;
  if target <> nil then
  begin
    if (target.UserName = '') and (GetTickCount - target.SendQueryUserNameTime > 10 * 1000) then
    begin
      target.SendQueryUserNameTime := GetTickCount;
      SendQueryUserName(target.RecogId, target.XX, target.YY);
    end;
    FocusCret := target;
  end
  else
    FocusCret := nil;

  FocusItem := PlayScene.GetDropItems(X, Y, itemnames);
  if FocusItem <> nil then
  begin
    PlayScene.ScreenXYfromMCXY(FocusItem.X, FocusItem.Y, mx, my);
//      DScreen.AddChatBoardString ('Pos=> '+ IntToStr(((Length(FocusItem.Name) div 2)*6)), clYellow, clRed);
    DScreen.ShowHint(mx + 2 - ((Length(FocusItem.Name) div 2) * 6), my - 10, itemnames, //PTDropItem(ilist[i]).Name,
      clWhite, TRUE);
  end
  else
    DScreen.ClearHint(True);

  g_MouseX := X;
  g_MouseY := Y;
  CheckMapView;
  if g_ShowMiniMapXY then Exit;

  PlayScene.CXYfromMouseXY(X, Y, MCX, MCY);
  MouseX := X;
  MouseY := Y;
  MouseItem.S.Name := '';
  MouseStateItem.S.Name := '';
  MouseUserStateItem.S.Name := '';
//   if ((ssLeft in Shift) or (ssRight in Shift)) and (GetTickCount - mousedowntime > 300) then
  if ((ssLeft in Shift) or (ssRight in Shift) or gAutoRun) and (GetTickCount - mousedowntime > 300) then
    _DXDrawMouseDown(self, mbLeft, Shift, X, Y);

end;

procedure TFrmMain.DXDraw1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mousedowntime := GetTickCount;
  RunReadyCount := 0;
  _DXDrawMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFrmMain.AttackTarget(target: TActor);
var
  tdir, dx, dy, hitmsg: integer;
begin
  hitmsg := CM_HIT;
  if UseItems[U_WEAPON].S.StdMode = 6 then
    hitmsg := CM_HEAVYHIT;

  tdir := GetNextDirection(Myself.XX, Myself.YY, target.XX, target.YY);
  if (abs(Myself.XX - target.XX) <= 1) and (abs(Myself.YY - target.YY) <= 1) and (not target.Death) then
  begin
    if CanNextAction and ServerAcceptNextAction and CanNextHit then
    begin

      if BoNextTimeFireHit and (Myself.Abil.MP >= 7) then
      begin
        BoNextTimeFireHit := FALSE;
        hitmsg := CM_FIREHIT;
      end
      else if BoNextTimePowerHit then
      begin
        BoNextTimePowerHit := FALSE;
        hitmsg := CM_POWERHIT;
      end
      else if BoCanTwinHit and (Myself.Abil.MP >= 10) then
      begin
        hitmsg := CM_TWINHIT;
      end
      else if BoCanWideHit and (Myself.Abil.MP >= 3) then
      begin //and (TargetInSwordWideAttackRange (tdir)) then begin
        hitmsg := CM_WIDEHIT;
      end
      else

      if BoCanCrossHit and (Myself.Abil.MP >= 6) then
      begin
        hitmsg := CM_CROSSHIT;
      end
      else if BoCanLongHit and (TargetInSwordLongAttackRange(tdir)) then
      begin
        hitmsg := CM_LONGHIT;
      end;

         //if ((target.Race <> 0) and (target.Race <> RCC_GUARD)) or (ssShift in Shift) then
      Myself.SendMsg(hitmsg, Myself.XX, Myself.YY, tdir, 0, 0, '', 0);
      LatestHitTime := GetTickCount;
    end;
    LastAttackTime := GetTickCount;
  end
  else
  begin
      //if (UseItems[U_WEAPON].S.Shape = 6) and (target <> nil) then begin
      //   Myself.SendMsg (CM_THROW, Myself.XX, Myself.YY, tdir, integer(target), 0, '', 0);
      //   TargetCret := nil;
      //end else begin
    ChrAction := caRun;  // 助跑相关；攻击目标远了就跑过去，caWalk是走过去
    GetBackPosition(target.XX, target.YY, tdir, dx, dy);
    targetx := dx;
    targety := dy;
      //end;
  end;
end;

procedure TFrmMain._DXDrawMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  tdir, nx, ny, hitmsg, sel: integer;
  target: TActor;
  Pt:TPoint;
  ARect:TRect;  
begin
  ActionKey := 0;
  MouseX := X;
  MouseY := Y;
  BoAutoDig := FALSE;

  if (Button = mbRight) and ItemMoving then
  begin
    FrmDlg.CancelItemMoving;
    exit;
  end;
  if g_DWinMan.MouseDown(Button, Shift, X, Y) then
    exit;

  if ViewMiniMapStyle>0 then
     begin
        ARect:=Rect(g_FScreenWidth-g_MinMapWidth,0,g_FScreenWidth,g_MinMapWidth);
        Pt:=Point(X,Y);
        if types.PtInRect(ARect,Pt) then
           begin
              if Button=mbLeft then
                 begin
                    Inc(ViewMiniMapStyle);
                    if ViewMiniMapStyle > 2 then
                       ViewMiniMapStyle := 1;
                 end
                 else
                 ViewMiniMapTran:=not ViewMiniMapTran;
              if ViewMiniMapStyle=2 then
                 g_MinMapWidth:=200
                 else
                 g_MinMapWidth:=120;
              CheckMapView;
              Exit;
           end;
     end;

  if (Myself = nil) or (DScreen.CurrentScene <> PlayScene) then
    exit;



  if ssMiddle in Shift then
  begin
    RunReadyCount := 0;
    if gAutoRun then
    begin
      gAutoRun := False;
      DScreen.AddChatBoardString ('自动奔跑关闭', clGreen, clWhite)
    end
    else
    begin
      gAutoRun := True;
      DScreen.AddChatBoardString ('自动奔跑开启', clGreen, clWhite)
    end;
  end
  else if ssLeft in Shift then
  begin
    if gAutoRun then
    begin
      RunReadyCount := 0;
      gAutoRun := False;
      DScreen.AddChatBoardString ('自动奔跑关闭', clGreen, clWhite)
    end;
  end;

  if (ssRight in Shift) or gAutoRun then
  begin
    if Shift = [ssRight] then
      Inc(DupSelection);
    target := PlayScene.GetAttackFocusCharacter(X, Y, DupSelection, sel, FALSE);
    if DupSelection <> sel then
      DupSelection := 0;
    if target <> nil then
    begin
      if ssCtrl in Shift then
      begin
        if GetTickCount - LastMoveTime > 1000 then
        begin
          if (target.Race = 0) and (not target.Death) then
          begin
            SendClientMessage(CM_QUERYUSERSTATE, target.RecogId, target.XX, target.YY, 0);
            exit;
          end;
        end;
      end;
    end
    else
      DupSelection := 0;

    PlayScene.CXYfromMouseXY(X, Y, MCX, MCY);
    if (abs(Myself.XX - MCX) <= 0) and (abs(Myself.YY - MCY) <= 0) then    //助跑相关，1就是鼠标指向1格外开跑 之前两个0都是1
    begin
      tdir := GetNextDirection(Myself.XX, Myself.YY, MCX, MCY);
      if CanNextAction and ServerAcceptNextAction then
      begin
        Myself.SendMsg(CM_TURN, Myself.XX, Myself.YY, tdir, 0, 0, '', 0);
      end;
    end
    else
    begin
      ChrAction := caRun;
      targetx := MCX;
      targety := MCY;
      exit;
    end;
  end;

  if ssLeft in Shift {Button = mbLeft} then
  begin
    target := PlayScene.GetAttackFocusCharacter(X, Y, DupSelection, sel, TRUE);
    PlayScene.CXYfromMouseXY(X, Y, MCX, MCY);
    TargetCret := nil;

    if (UseItems[U_WEAPON].S.Name <> '') and (target = nil) then
    begin
      if UseItems[U_WEAPON].S.Shape = 19 then
      begin
        tdir := GetNextDirection(Myself.XX, Myself.YY, MCX, MCY);
        GetFrontPosition(Myself.XX, Myself.YY, tdir, nx, ny);
        if not Map.CanMove(nx, ny) or (ssShift in Shift) then
        begin
          if CanNextAction and ServerAcceptNextAction and CanNextHit then
          begin
            Myself.SendMsg(CM_HIT + 1, Myself.XX, Myself.YY, tdir, 0, 0, '', 0);
          end;
          BoAutoDig := TRUE;
          exit;
        end;
      end;
    end;

    if ssAlt in Shift then
    begin
      tdir := GetNextDirection(Myself.XX, Myself.YY, MCX, MCY);
      if CanNextAction and ServerAcceptNextAction then
      begin
        target := PlayScene.ButchAnimal(MCX, MCY);
        if target <> nil then
        begin
          SendButchAnimal(MCX, MCY, tdir, target.RecogId);
          Myself.SendMsg(CM_SITDOWN, Myself.XX, Myself.YY, tdir, 0, 0, '', 0);
          exit;
        end;
        Myself.SendMsg(CM_SITDOWN, Myself.XX, Myself.YY, tdir, 0, 0, '', 0);
      end;
      targetx := -1;
    end
    else
    begin
      if (target <> nil) or (ssShift in Shift) then
      begin
        targetx := -1;
        if target <> nil then
        begin
          if GetTickCount - LastMoveTime > 1500 then
          begin
            if target.Race = RCC_MERCHANT then
            begin
              SendClientMessage(CM_CLICKNPC, target.RecogId, 0, 0, 0);
              exit;
            end;
          end;

          if (not target.Death) then
          begin
            TargetCret := target;
            if ((target.Race <> 0) and (target.Race <> RCC_GUARD) and (target.Race <> RCC_GUARD2) and (target.Race <> RCC_MERCHANT) and (pos('(', target.UserName) = 0) //林牢绝绰 各(乐绰 各篮 碍力傍拜 秦具窃)
              ) or (ssShift in Shift)
              or (target.NameColor = ENEMYCOLOR)
              then
            begin
              MagicTarget := target; // AutoTarget
              AutoTarget := target; // AutoTarget
              AttackTarget(target);
              LatestHitTime := GetTickCount;

              if BoStopAfterAttack then
              begin
                BoStopAfterAttack := FALSE;
                TargetCret := nil;
                AutoTarget := nil;
              end;
              if (target <> nil) and (ssShift in Shift) then
                AutoTarget := nil;
            end;
          end;
        end
        else
        begin
          tdir := GetNextDirection(Myself.XX, Myself.YY, MCX, MCY);
          if CanNextAction and ServerAcceptNextAction and CanNextHit then
          begin
            hitmsg := CM_HIT + Random(3);
            if BoCanLongHit and (TargetInSwordLongAttackRange(tdir)) then
            begin
              hitmsg := CM_LONGHIT;
            end;
            if BoCanWideHit and (Myself.Abil.MP >= 3) and (TargetInSwordWideAttackRange(tdir)) then
            begin
              hitmsg := CM_WIDEHIT;
            end;
            if BoCanCrossHit and (Myself.Abil.MP >= 6) and (TargetInSwordCrossAttackRange(tdir)) then
            begin
              hitmsg := CM_CROSSHIT;
            end;
            Myself.SendMsg(hitmsg, Myself.XX, Myself.YY, tdir, 0, 0, '', 0);
          end;
          LastAttackTime := GetTickCount;
        end;
      end
      else
      begin
        if (MCX = Myself.XX) and (MCY = Myself.YY) then
        begin
          tdir := GetNextDirection(Myself.XX, Myself.YY, MCX, MCY);
          if CanNextAction and ServerAcceptNextAction then
          begin
            SendPickup;
          end;
        end
        else if GetTickCount - LastAttackTime > 1000 then
        begin
          if ssCtrl in Shift then
          begin
            ChrAction := caRun;
          end
          else
          begin
            ChrAction := caWalk;
          end;
          targetx := MCX;
          targety := MCY;
        end;
      end;
    end;
  end;
end;

procedure TFrmMain.DXDraw1DblClick(Sender: TObject);
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  pt := ScreenToClient(pt);
  if g_DWinMan.DblClick(pt.X, pt.Y) then
    exit;
end;

function TFrmmain.CheckDoorAction(dx, dy: integer): Boolean;
var
  nx, ny, ndir, door: integer;
begin
  Result := FALSE;
   //if not Map.CanMove (dx, dy) then begin
      //if (Abs(dx-Myself.XX) <= 2) and (Abs(dy-Myself.YY) <= 2) then begin
  door := Map.GetDoor(dx, dy);
  if door > 0 then
  begin
    if not Map.IsDoorOpen(dx, dy) then
    begin
      SendClientMessage(CM_OPENDOOR, door, dx, dy, 0);
      Result := TRUE;
    end;
  end;
      //end;
   //end;
end;

procedure TFrmMain.DXDraw1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if g_DWinMan.MouseUp(Button, Shift, X, Y) then
    exit;
  if CheckPtInMinMap(X,Y) then
     Exit;
  targetx := -1;
end;

procedure TFrmMain.DXDraw1Click(Sender: TObject);
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  pt := ScreenToClient(pt);
  if g_DWinMan.Click(pt.X, pt.Y) then exit;
end;

procedure TFrmMain.MouseTimerTimer(Sender: TObject);
var
  pt: TPoint;
  keyvalue: TKeyBoardState;
  shift: TShiftState;
begin
  GetCursorPos(pt);
  SetCursorPos(pt.X, pt.Y);

  if TargetCret <> nil then
  begin
    if ActionKey > 0 then
    begin
      ProcessKeyMessages;
    end
    else
    begin
      if not TargetCret.Death and PlayScene.IsValidActor(TargetCret) then
      begin
        FillChar(keyvalue, sizeof(TKeyboardState), #0);
        if GetKeyboardState(keyvalue) then
        begin
          shift := [];
          if ((keyvalue[VK_SHIFT] and $80) <> 0) then
            shift := shift + [ssShift];
          if ((TargetCret.Race <> 0) and (TargetCret.Race <> RCC_GUARD) and (TargetCret.Race <> RCC_GUARD2) and (TargetCret.Race <> RCC_MERCHANT) and (pos('(', TargetCret.UserName) = 0) //林牢乐绰 各(碍力傍拜 秦具窃)
            ) or (TargetCret.NameColor = ENEMYCOLOR)   //利篮 磊悼 傍拜捞 凳
            or ((ssShift in shift) and (not PlayScene.EdChat.Visible)) then
          begin //荤恩阑 角荐肺 傍拜窍绰 巴阑 阜澜
            AttackTarget(TargetCret);
          end; //else begin
                  //TargetCret := nil;
               //end
        end;
      end
      else
        TargetCret := nil;
    end;
  end;
  if BoAutoDig then
  begin //自动挖矿
    if CanNextAction and ServerAcceptNextAction and CanNextHit then
    begin
      Myself.SendMsg(CM_HIT + 1, Myself.XX, Myself.YY, Myself.Dir, 0, 0, '', 0);
    end;
  end;
end;

procedure TFrmMain.WaitMsgTimerTimer(Sender: TObject);
var AMapName,data:string;
begin
  if Myself = nil then
    exit;
  if Myself.ActionFinished then
  begin
    WaitMsgTimer.Enabled := FALSE;
    case WaitingMsg.Ident of
      SM_CHANGEMAP:
        begin
          FrmDlg.SafeCloseDlg;
          MapMovingWait := FALSE;
          MapMoving := FALSE;
               //甘捞 官差搁 惑痢 皋春甫 摧绰促.
          if MDlgX <> -1 then
          begin
            FrmDlg.CloseMDlg;
            MDlgX := -1;
          end;
          ClearDropItems;
          EventMan.ClearEvents;
          PlayScene.CleanObjects;

          WaitingStr := GetValidStr3(WaitingStr, data, [#13]);
          AMapName:=data;
          WaitingStr := GetValidStr3(WaitingStr, data, [#13]);
          MapTitle:=data;
          TempMapTitle:=data;
          if strtointdef(WaitingStr,-1)<=0 then
             begin
              BoDrawMiniMap := False;
              MiniMapIndex:=-1;
             end
             else
             ClientGetReadMiniMap(strtointdef(WaitingStr,-1));

        //  MapTitle := '';
          PlayScene.SendMsg(SM_CHANGEMAP, 0, WaitingMsg.Param{x}, WaitingMsg.tag{y}, LOBYTE(WaitingMsg.Series){darkness}, // 侩带怜
            0, 0, 0, AMapName{mapname});

          EffectNum := HIBYTE(WaitingMsg.Series);
          if EffectNum < 0 then
            EffectNum := 0;
          if (EffectNum = 1) or (EffectNum = 2) then
            RunEffectTimer.Enabled := True
          else
            RunEffectTimer.Enabled := False;

          Myself.CleanCharMapSetting(WaitingMsg.Param, WaitingMsg.Tag);
               //DScreen.AddSysMsg (IntToStr(WaitingMsg.Param) + ' ' +
               //                   IntToStr(WaitingMsg.Tag) + ' : My ' +
               //                   IntToStr(Myself.XX) + ' ' +
               //                   IntToStr(Myself.YY) + ' ' +
               //                   IntToStr(Myself.RX) + ' ' +
               //                   IntToStr(Myself.RY) + ' '
               //                  );
          targetx := -1;
          TargetCret := nil;
          FocusCret := nil;

        end;
    end;
  end;
end;



{----------------------- Socket -----------------------}

procedure TFrmMain.SelChrWaitTimerTimer(Sender: TObject);
begin
  SelChrWaitTimer.Enabled := FALSE;
  SendQueryChr;
end;

procedure TFrmMain.ActiveCmdTimer(cmd: TTimerCommand);
begin
  CmdTimer.Enabled := TRUE;
  TimerCmd := cmd;
end;

procedure TFrmMain.CmdTimerTimer(Sender: TObject);
begin
  CmdTimer.Enabled := FALSE;
  CmdTimer.Interval := 1000;
  case TimerCmd of
    tcSoftClose:
      begin
        CmdTimer.Enabled := FALSE;
        CSocket.Socket.Close;
      end;
    tcReSelConnect:
      begin
            //霸烙 函荐 檬扁拳...
        ResetGameVariables;
            //
        DScreen.ChangeScene(stSelectChr);

        ConnectionStep := cnsReSelChr;
        if not BoOneClick then
        begin
          with CSocket do
          begin
            Active := FALSE;
            Address := SelChrAddr;
            Port := SelChrPort;
            Active := TRUE;
          end;
        end
        else
        begin
          if CSocket.Socket.Connected then
            CSocket.Socket.SendText('$S' + SelChrAddr + '/' + IntToStr(SelChrPort) + '%');
          CmdTimer.Interval := 1;
          ActiveCmdTimer(tcFastQueryChr);
        end;
      end;
    tcFastQueryChr:
      begin
        SendQueryChr;
      end;
  end;
end;

procedure TFrmMain.CloseAllWindows;
begin
  with FrmDlg do
  begin

    CancelItemMoving;
    if DStateWin.Visible then
      DStateWin.Visible := FALSE;
    if DUserState1.Visible then
      DUserState1.Visible := FALSE;
    if DItemBag.Visible then
      DItemBag.Visible := FALSE;
    if DMerchantDlg.Visible then
      CloseMDlg;
    if DSellDlg.Visible then
      CloseDSellDlg;
    if DGuildDlg.Visible then
      DGDCloseClick(nil, 0, 0);
    if DDealDlg.Visible then
      DDealCloseClick(nil, 0, 0);
    if DGroupDlg.Visible then
      DGrpDlgCloseClick(nil, 0, 0);
    if DMailListDlg.Visible then
      ToggleShowMailListDlg;
    if DFriendDlg.Visible then
      ToggleShowFriendsDlg;
    if DBlockListDlg.Visible then
      ToggleShowBlockListDlg;
//      if DMemo.Visible then ToggleShowMemoDlg;
    if DMemo.Visible then
      DMemoCloseClick(DMemoClose, 0, 0);
    if DMakeItemDlg.Visible then
      DMakeItemDlgOkClick(DMakeItemDlgCancel, 0, 0);
    if DItemMarketDlg.Visible then
      CloseItemMarketDlg;
//      if DItemMarketDlg.Visible then DItemMarketDlg.Visible := FALSE;

    if DJangwonListDlg.Visible then
      DJangwonCloseClick(DJangwonClose, 0, 0);
    if DGABoardListDlg.Visible then
      DGABoardListCloseClick(DGABoardListClose, 0, 0);
    if DGABoardDlg.Visible then
      DGABoardCloseClick(DGABoardClose, 0, 0);
    if DGADecorateDlg.Visible then
      DGADecorateCloseClick(DGADecorateClose, 0, 0);
    if DMasterDlg.Visible then
      ToggleShowMasterDlg;
    DMsgDlg.Visible := FALSE;
    DMenuDlg.Visible := FALSE;
    DKeySelDlg.Visible := FALSE;
    DDealRemoteDlg.Visible := FALSE;
    DGuildEditNotice.Visible := FALSE;
    DAdjustAbility.Visible := FALSE;
    DMailDlg.Visible := FALSE;
  end;
  if MDlgX <> -1 then
  begin
    FrmDlg.CloseMDlg;
    MDlgX := -1;
  end;
  ItemMoving := FALSE;  //

  BoMsgDlgTimeCheck := False;
  FrmDlg.MsgDlgClickTime := GetTickCount;
end;

procedure TFrmMain.ClearDropItems;
var
  i: integer;
begin
  for i := 0 to DropedItemList.Count - 1 do
    Dispose(PTDropItem(DropedItemList[i]));
  DropedItemList.Clear;
end;

procedure TFrmMain.ResetGameVariables;
var
  i: integer;
begin
  CloseAllWindows;
  ClearDropItems;
  for i := 0 to MagicList.Count - 1 do
    Dispose(PTClientMagic(MagicList[i]));
  MagicList.Clear;
  ItemMoving := FALSE;
  WaitingUseItem.Item.S.Name := '';
  EatingItem.S.name := '';
  MovingItem.Item.S.Name := '';

  targetx := -1;
  TargetCret := nil;
  FocusCret := nil;
  MagicTarget := nil;
  ActionLock := FALSE;
  GroupMembers.Clear;
  GroupIdList.Clear;
   // 2003/04/15 模备, 率瘤
  for i := 0 to FriendMembers.Count - 1 do
    Dispose(PTFriend(FriendMembers[i]));
  FriendMembers.Clear;

  for i := 0 to BlackMembers.Count - 1 do
    Dispose(PTFriend(BlackMembers[i]));
  BlackMembers.Clear;

  BlockLists.Clear;
  for i := 0 to MailLists.Count - 1 do
    Dispose(PTMail(MailLists[i]));
  MailLists.Clear;
  WantMailList := false;

   //2003/07/08 楷牢荤力
  fLover.Clear;
  fMaster.Clear;
  fPupil.Clear;

  GuildRankName := '';
  GuildName := '';

  MapMoving := FALSE;
  WaitMsgTimer.Enabled := FALSE;
  MapMovingWait := FALSE;
  DScreen.ChatBoardTop := 0;
  BoNextTimePowerHit := FALSE;
  BoCanLongHit := FALSE;
  BoCanWideHit := FALSE;
   // 2003/03/15 脚痹公傍
  BoCanCrosshit := FALSE;
  BoCanTwinhit := FALSE;
  BoNextTimeFireHit := FALSE;

   // 2003/03/15 牢亥配府 犬厘
  FillChar(UseItems, sizeof(TClientItem) * 13, #0);        // 9->13
  FillChar(ItemArr, sizeof(TClientItem) * MAXBAGITEMCL, #0);

  with SelectChrScene do
  begin
    FillChar(ChrArr, sizeof(TSelChar) * 3, #0);
    ChrArr[0].FreezeState := TRUE; //扁夯捞 倔绢 乐绰 惑怕
    ChrArr[1].FreezeState := TRUE;
  end;
  PlayScene.ClearActors;
  ClearDropItems;
  EventMan.ClearEvents;
  PlayScene.CleanObjects;
   //DXDraw1RestoreSurface (self);
  Myself := nil;

   //困殴惑痢 檬扁拳;
  g_Market.Clear;
end;

procedure TFrmMain.ChangeServerClearGameVariables;
var
  i: integer;
begin
  CloseAllWindows;
  ClearDropItems;
  for i := 0 to MagicList.Count - 1 do
    Dispose(PTClientMagic(MagicList[i]));
  MagicList.Clear;
  ItemMoving := FALSE;
  WaitingUseItem.Item.S.Name := '';
  EatingItem.S.name := '';
  targetx := -1;
  TargetCret := nil;
  FocusCret := nil;
  MagicTarget := nil;
  ActionLock := FALSE;
  GroupMembers.Clear;
  GroupIdList.Clear;
   // 2003/04/15 模备, 率瘤
  for i := 0 to FriendMembers.Count - 1 do
    Dispose(PTFriend(FriendMembers[i]));
  FriendMembers.Clear;

  for i := 0 to BlackMembers.Count - 1 do
    Dispose(PTFriend(BlackMembers[i]));
  BlackMembers.Clear;

  BlockLists.Clear;
  for i := 0 to MailLists.Count - 1 do
    Dispose(PTMail(MailLists[i]));
  MailLists.Clear;
  WantMailList := false;

   //2003/07/08 楷牢荤力
  fLover.clear;
  fMaster.Clear;
  fPupil.Clear;

  GuildRankName := '';
  GuildName := '';

  MapMoving := FALSE;
  WaitMsgTimer.Enabled := FALSE;
  MapMovingWait := FALSE;
  BoNextTimePowerHit := FALSE;
  BoCanLongHit := FALSE;
  BoCanWideHit := FALSE;
   // 2003/03/15 脚痹公傍
  BoCanCrosshit := FALSE;
  BoCanTwinhit := FALSE;

  ClearDropItems;
  EventMan.ClearEvents;
  PlayScene.CleanObjects;
end;

procedure TFrmMain.CSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  packet: array[0..255] of Char;
  strbuf: array[0..255] of Char;
  str: string;
begin
  ServerConnected := TRUE;
  if ConnectionStep = cnsLogin then
  begin
    if OneClickMode = toKornetWorld then
    begin  //内齿岿靛甫 版蜡秦辑 霸烙俊 立加
      FillChar(packet, 256, #0);
      str := 'KwGwMGS';
      StrPCopy(strbuf, str);
      Move(strbuf, (@packet[0])^, Length(str));
      str := 'CONNECT';
      StrPCopy(strbuf, str);
      Move(strbuf, (@packet[8])^, Length(str));
      str := KornetWorld.CPIPcode;
      StrPCopy(strbuf, str);
      Move(strbuf, (@packet[16])^, Length(str));
      str := KornetWorld.SVCcode;
      StrPCopy(strbuf, str);
      Move(strbuf, (@packet[32])^, Length(str));
      str := KornetWorld.LoginID;
      StrPCopy(strbuf, str);
      Move(strbuf, (@packet[48])^, Length(str));
      str := KornetWorld.CheckSum;
      StrPCopy(strbuf, str);
      Move(strbuf, (@packet[64])^, Length(str));
      Socket.SendBuf(packet, 256);
    end;
    DScreen.ChangeScene(stLogin);
      //SendVersionNumber;
  end;
  if ConnectionStep = cnsSelChr then
  begin
//    Application.MessageBox( PChar('cnsSelChr'), PChar('Check'), IDOK);
    LoginScene.OpenLoginDoor;
    SelChrWaitTimer.Enabled := TRUE;
  end;
  if ConnectionStep = cnsReSelChr then
  begin
    CmdTimer.Interval := 1;
    ActiveCmdTimer(tcFastQueryChr);
  end;
  if ConnectionStep = cnsPlay then
  begin
    if not BoServerChanging then
    begin
      ClearBag;  //啊规 檬扁拳
      DScreen.ClearChatBoard; //盲泼芒 檬扁拳
      DScreen.ChangeScene(stLoginNotice);
    end
    else
    begin
      ChangeServerClearGameVariables;
    end;
    SendRunLogin;
  end;
  SocStr := '';
  BufferStr := '';
end;

procedure TFrmMain.CSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  ServerConnected := FALSE;
  if (ConnectionStep = cnsLogin) and not BoWellLogin then
  begin
    FrmDlg.DMessageDlg('Connection closed...', [mbOk]);
    Close;
  end;
//   FrmDlg.DLOGO.Visible := False;
  CloseTimer.Enabled := True;
  if SoftClosed then
  begin
    SoftClosed := FALSE;
    ActiveCmdTimer(tcReSelConnect);
  end;
end;

procedure TFrmMain.CSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
  Socket.Close;
end;

procedure TFrmMain.CSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
  n: integer;
  data, data2: string;
begin
  data := Socket.ReceiveText;
   
   //DebugOutStr (data);
   //if pos('GOOD', data) > 0 then DScreen.AddSysMsg (data);

  n := pos('*', data);
  if n > 0 then
  begin
    data2 := Copy(data, 1, n - 1);
    data := data2 + Copy(data, n + 1, Length(data));
      //SendSocket ('*');
    CSocket.Socket.SendText('*');
  end;
  SocStr := SocStr + data;
end;

{-------------------------------------------------------------}

procedure TFrmMain.SendSocket(sendstr: string);
const
  Code: byte = 1;
begin
   //DebugOutStr (sendstr);
  if CSocket.Socket.Connected then
  begin
    CSocket.Socket.SendText('#' + IntToStr(Code) + sendstr + '!');
    Inc(Code);
    if Code >= 10 then
      Code := 1;
  end;
end;

procedure TFrmMain.SendClientMessage(msg, Recog, param, tag, series: integer);
var
  dmsg: TDefaultMessage;
begin
  dmsg := MakeDefaultMsg(msg, Recog, param, tag, series);
  SendSocket(EncodeMessage(dmsg));
end;

procedure TFrmMain.SendClientMessage2(msg, Recog, param, tag, series: integer; str: string);
var
  dmsg: TDefaultMessage;
begin
  dmsg := MakeDefaultMsg(msg, Recog, param, tag, series);
  SendSocket(EncodeMessage(dmsg) + EncodeString(str));
end;

procedure TFrmMain.SendVersionNumber;
var
  msg: TDefaultMessage;
begin
{   msg := MakeDefaultMsg (CM_PROTOCOL, ClientVersion, 0, 0, 0);
   SendSocket (EncodeMessage (msg));}
end;

procedure TFrmMain.SendLogin(uid, passwd: string);
var
  msg: TDefaultMessage;
begin
  LoginId := uid;
  LoginPasswd := passwd;
  msg := MakeDefaultMsg(CM_IDPASSWORD, ClientVersion, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(uid + '/' + passwd));
  BoWellLogin := TRUE;
end;

procedure TFrmMain.SendNewAccount(ue: TUserEntryInfo; ua: TUserEntryAddInfo);
var
  msg: TDefaultMessage;
begin
  MakeNewId := ue.LoginId;
  msg := MakeDefaultMsg(CM_ADDNEWUSER, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeBuffer(@ue, sizeof(TUserEntryInfo)) + EncodeBuffer(@ua, sizeof(TUserEntryAddInfo)));
end;

procedure TFrmMain.SendUpdateAccount(ue: TUserEntryInfo; ua: TUserEntryAddInfo);
var
  msg: TDefaultMessage;
begin
  MakeNewId := ue.LoginId;
  msg := MakeDefaultMsg(CM_UPDATEUSER, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeBuffer(@ue, sizeof(TUserEntryInfo)) + EncodeBuffer(@ua, sizeof(TUserEntryAddInfo)));
end;

procedure TFrmMain.SendSelectServer(svname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_SELECTSERVER, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(svname));
end;

procedure TFrmMain.SendChgPw(id, passwd, newpasswd: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_CHANGEPASSWORD, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(id + #9 + passwd + #9 + newpasswd));
end;

procedure TFrmMain.SendNewChr(uid, uname, shair, sjob, ssex: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_NEWCHR, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(uid + '/' + uname + '/' + shair + '/' + sjob + '/' + ssex));
end;

procedure TFrmMain.SendQueryChr;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_QUERYCHR, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(LoginId + '/' + IntToStr(Certification)));
end;

procedure TFrmMain.SendDelChr(chrname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DELCHR, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(DecodeString(chrname)));
end;

procedure TFrmMain.SendSelChr(chrname: string);
var
  msg: TDefaultMessage;
begin
  CharName := DecodeString(chrname);
  msg := MakeDefaultMsg(CM_SELCHR, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(LoginId + '/' + CharName));
end;

procedure TFrmMain.SendRunLogin;
var
  msg: TDefaultMessage;
  str: string;
begin
  str := '**' + LoginId + '/' + CharName + '/' + IntToStr(Certification) + '/' + IntToStr(ClientVersion) + '/' + IntToStr(Certification xor $F2E44FFF) + '/' + IntToStr(pLocalFileCheckSum^) + '/' + IntToStr(Certification xor $a4a5b277) + '/' + '0';
   //if NewGameStart then begin
   //   str := str + '0';
   //   NewGameStart := FALSE;
   //end else str := str + '1';
  SendSocket(EncodeString(str));
end;

procedure TFrmMain.SendSay(str: string);
var
  msg: TDefaultMessage;
begin
  if str <> '' then
  begin
{      if str = '/check debug screen' then begin
         CheckBadMapMode := not CheckBadMapMode;
         if CheckBadMapMode then DScreen.AddSysMsg ('On')
         else DScreen.AddSysMsg ('Off');
         exit;
      end;}
    if str = '/check speedhack' then
    begin
      BoCheckSpeedHackDisplay := not BoCheckSpeedHackDisplay;
      exit;
    end;
    if str = '@password' then
    begin
      if PlayScene.EdChat.PasswordChar = #0 then
        PlayScene.EdChat.PasswordChar := '*'
      else
        PlayScene.EdChat.PasswordChar := #0;
      exit;
    end;
    msg := MakeDefaultMsg(CM_SAY, 0, 0, 0, 0);
    SendSocket(EncodeMessage(msg) + EncodeString(str));

    if str[1] = '/' then
    begin
      DScreen.AddChatBoardString(str, GetRGB(180), clWhite);
      GetValidStr3(Copy(str, 2, Length(str) - 1), WhisperName, [' ']);
    end
    else if (Copy(str, 1, 2) = '⒔') then
      if Copy(fLover.GetDisplay(0), length(STR_LOVER) + 1, 6) <> '' then
        DScreen.AddChatBoardString(MySelf.UserName + ': ' + Copy(str, 3, Length(str) - 2), GetRGB(253), clWhite);

    if BoOneTimePassword then
    begin
      BoOneTimePassword := FALSE;
      PlayScene.EdChat.PasswordChar := #0;
    end;
  end;
end;

procedure TFrmMain.SendActMsg(ident, x, y, dir: integer);
var
  msg: TDefaultMessage;
begin
//   if ident in [CM_TURN, CM_WALK, CM_RUN, CM_HIT, CM_POWERHIT, CM_LONGHIT, CM_WIDEHIT,
//                CM_HEAVYHIT, CM_BIGHIT, CM_FIREHIT, CM_CROSSHIT, CM_TWINHIT, CM_SITDOWN] then
  if (ident = CM_TURN) or (ident = CM_WALK) or (ident = CM_RUN) or (ident = CM_HIT) or (ident = CM_POWERHIT) or (ident = CM_LONGHIT) or (ident = CM_WIDEHIT) or (ident = CM_HEAVYHIT) or (ident = CM_BIGHIT) or (ident = CM_FIREHIT) or (ident = CM_CROSSHIT) or (ident = CM_TWINHIT) or (ident = CM_SITDOWN) then
    msg := MakeDefaultMsg(ident, MakeLong(x, y), 0, dir, 0, Myself.RecogId)
  else
    msg := MakeDefaultMsg(ident, MakeLong(x, y), 0, dir, 0);

  SendSocket(EncodeMessage(msg));
  ActionLock := TRUE; //辑滚俊辑 #+FAIL! 捞唱 #+GOOD!捞 棵锭鳖瘤 扁促覆
  ActionLockTime := GetTickCount;
  Inc(SendCount);
end;

procedure TFrmMain.SendSpellMsg(ident, x, y, dir, target: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(ident, MakeLong(x, y), Loword(target), dir, Hiword(target));
  SendSocket(EncodeMessage(msg));
  ActionLock := TRUE; //辑滚俊辑 #+FAIL! 捞唱 #+GOOD!捞 棵锭鳖瘤 扁促覆
  ActionLockTime := GetTickCount;
  Inc(SendCount);
end;

procedure TFrmMain.SendQueryUserName(targetid, x, y: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_QUERYUSERNAME, targetid, x, y, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendDropItem(name: string; itemserverindex: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DROPITEM, itemserverindex, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(name));
end;

procedure TFrmMain.SendDropCountItem(iname: string; mindex, icount: integer);
var
  msg: TDefaultMessage;
begin

  msg := MakeDefaultMsg(CM_DROPCOUNTITEM, mindex, icount, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(iname));

end;

procedure TFrmMain.SendPickup;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_PICKUP, 0, Myself.XX, Myself.YY, 0, Myself.RecogId);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendTakeOnItem(where: byte; itmindex: integer; itmname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAKEONITEM, itmindex, where, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itmname));
end;

procedure TFrmMain.SendTakeOffItem(where: byte; itmindex: integer; itmname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAKEOFFITEM, itmindex, where, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itmname));
end;

procedure TFrmMain.SendEat(idx, itmindex: integer; itmname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_EAT, itmindex, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itmname));
//   DScreen.AddChatBoardString ('SendEat  idx=>'+IntToStr(idx), clYellow, clRed);
//   if idx < 6 then StBeltAutoFill := True;
  if idx <> -1 then
    BtInDex := idx;
end;

procedure TFrmMain.UpgradeItem(ItemIndex, jewelIndex: integer; StrItem, StrJewel: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_UPGRADEITEM, ItemIndex, Loword(jewelIndex), Hiword(jewelIndex), 0);
  SendSocket(EncodeMessage(msg) + EncodeString(StrItem + '/' + StrJewel));
end;

// 般摹扁
procedure TFrmMain.SendItemSumCount(OrgItemIndex, ExItemIndex: integer; StrOrgItem, StrExItem: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_ITEMSUMCOUNT, OrgItemIndex, Loword(ExItemIndex), Hiword(ExItemIndex), 0);
  SendSocket(EncodeMessage(msg) + EncodeString(StrOrgItem + '/' + StrExItem));
end;

procedure TFrmMain.UpgradeItemResult(ItemIndex: integer; wResult: word; str: string);
begin
  FrmDlg.UpgradeItemEffect(wResult);
  PlaySound(10310);  // s_deal_additem

end;

procedure TFrmMain.SendButchAnimal(x, y, dir, actorid: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_BUTCH, actorid, x, y, dir);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendMagicKeyChange(magid: integer; keych: AnsiChar);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MAGICKEYCHANGE, magid, byte(keych), 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendMerchantDlgSelect(merchant: integer; rstr: string);
var
  msg: TDefaultMessage;
  param: string;
begin
  if Length(rstr) >= 2 then
  begin  //颇扼皋鸥啊 鞘夸茄 版快啊 乐澜.
    if (rstr[1] = '@') and (rstr[2] = '@') then
    begin
      if rstr = '@@AgitForSale' then
        FrmDlg.DMessageDlg('请输入行会的名字.', [mbOk, mbAbort])
      else if rstr = '@@AgitOneRecall' then
        FrmDlg.DMessageDlg('请输入.', [mbOk, mbAbort])
      else if rstr = '@@buildguildnow' then
      begin
        MsgDlgMaxStr := 20;
        FrmDlg.DMessageDlg('请输入你想建立的行会的名字.', [mbOk, mbAbort]);
        MsgDlgMaxStr := 30;
      end
      else
        FrmDlg.DMessageDlg('请输入.', [mbOk, mbAbort]);
      param := Trim(FrmDlg.DlgEditText);
               if Length(param) > 14 then begin
            FrmDlg.DMessageDlg ('行会名字不能超过七个汉字', [mbOk]);
            exit;
         end;
      rstr := rstr + #13 + param;
    end;
  end;
  msg := MakeDefaultMsg(CM_MERCHANTDLGSELECT, merchant, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(rstr));
end;

procedure TFrmMain.SendQueryPrice(merchant, itemindex: integer; itemname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MERCHANTQUERYSELLPRICE, merchant, Loword(itemindex), Hiword(itemindex), 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendQueryRepairCost(merchant, itemindex: integer; itemname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MERCHANTQUERYREPAIRCOST, merchant, Loword(itemindex), Hiword(itemindex), 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendSellItem(merchant, itemindex: integer; itemname: string; Count: word);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERSELLITEM, merchant, Loword(itemindex), Hiword(itemindex), Count);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendRepairItem(merchant, itemindex: integer; itemname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERREPAIRITEM, merchant, Loword(itemindex), Hiword(itemindex), 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendStorageItem(merchant, itemindex: integer; itemname: string; Count: word);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERSTORAGEITEM, merchant, Loword(itemindex), Hiword(itemindex), Count);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendMaketSellItem(merchant, itemindex: integer; price: string; Count: word);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MARKET_SELL, merchant, Loword(itemindex), Hiword(itemindex), Count);
  SendSocket(EncodeMessage(msg) + EncodeString(price));
end;

procedure TFrmMain.SendGetDetailItem(merchant, menuindex: integer; itemname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERGETDETAILITEM, merchant, menuindex, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendGetJangwonList(Page: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GUILDAGITLIST, Page, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGABoardRead(Body: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GABOARD_READ, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(Body));
end;

procedure TFrmMain.SendGetMarketPageList(merchant, pagetype: integer; itemname: string);
var // Market System..
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MARKET_LIST, merchant, pagetype, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendBuyMarket(merchant, sellindex: integer);
var // Market System..
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MARKET_BUY, merchant, Loword(sellindex), Hiword(sellindex), 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendCancelMarket(merchant, sellindex: integer);
var // Market System..
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MARKET_CANCEL, merchant, Loword(sellindex), Hiword(sellindex), 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGetPayMarket(merchant, sellindex: integer);
var // Market System..
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MARKET_GETPAY, merchant, Loword(sellindex), Hiword(sellindex), 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendMarketClose;
var // Market System..
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_MARKET_CLOSE, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendBuyItem(merchant, itemserverindex: integer; itemname: string; Count: word);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERBUYITEM, merchant, Loword(itemserverindex), Hiword(itemserverindex), Count);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendBuyDecoItem(merchant, DecoItemNum: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DECOITEM_BUY, merchant, Loword(DecoItemNum), Hiword(DecoItemNum), 1);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendTakeBackStorageItem(merchant, itemserverindex: integer; itemname: string; Count: word);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERTAKEBACKSTORAGEITEM, merchant, Loword(itemserverindex), Hiword(itemserverindex), Count);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendMakeDrugItem(merchant: integer; itemname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERMAKEDRUGITEM, merchant, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;

procedure TFrmMain.SendMakeItemSel(merchant: integer; itemname: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERMAKEITEMSEL, merchant, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(itemname));
end;
// 力炼

procedure TFrmMain.SendMakeItem(merchant: integer; data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_USERMAKEITEM, merchant, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendDropGold(dropgold: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DROPGOLD, dropgold, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGroupMode(onoff: Boolean);
var
  msg: TDefaultMessage;
begin
  if onoff then
    msg := MakeDefaultMsg(CM_GROUPMODE, 0, 1, 0, 0)   //on
  else
    msg := MakeDefaultMsg(CM_GROUPMODE, 0, 0, 0, 0);  //off
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendCreateGroup(withwho: string);
var
  msg: TDefaultMessage;
begin
  if withwho <> '' then
  begin
    msg := MakeDefaultMsg(CM_CREATEGROUP, 0, 0, 0, 0);
    SendSocket(EncodeMessage(msg) + EncodeString(withwho));
  //  DScreen.AddChatBoardString(withwho + '是否加入队伍.', TColor($BB840F), clWhite);
  end;
end;

procedure TFrmMain.SendWantMiniMap;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_WANTMINIMAP, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendDealTry;
var
  msg: TDefaultMessage;
  i, fx, fy: integer;
  actor: TActor;
  who: string;
  proper: Boolean;
begin
   (*proper := FALSE;
   GetFrontPosition (Myself.XX, Myself.YY, Myself.Dir, fx, fy);
   with PlayScene do
      for i:=0 to ActorList.Count-1 do begin
         actor := TActor (ActorList[i]);
         if {(actor.Race = 0) and} (actor.XX = fx) and (actor.YY = fy) then begin
            proper := TRUE;
            who := actor.UserName;
            break;
         end;
      end;
   if proper then begin*)
  msg := MakeDefaultMsg(CM_DEALTRY, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(who));
   //end;
end;

procedure TFrmMain.SendGuildDlg;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_OPENGUILDDLG, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendCancelDeal;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DEALCANCEL, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendAddDealItem(ci: TClientItem);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DEALADDITEM, ci.MakeIndex, 0, 0, ci.Dura);
  SendSocket(EncodeMessage(msg) + EncodeString(ci.S.Name));
end;

procedure TFrmMain.SendDelDealItem(ci: TClientItem);
var
  msg: TDefaultMessage;
begin

  msg := MakeDefaultMsg(CM_DEALDELITEM, ci.MakeIndex, 0, 0, ci.Dura);
  SendSocket(EncodeMessage(msg) + EncodeString(ci.S.Name));
end;

procedure TFrmMain.SendChangeDealGold(gold: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DEALCHGGOLD, gold, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendDealEnd;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_DEALEND, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendAddGroupMember(withwho: string);
var
  msg: TDefaultMessage;
begin
  if withwho <> '' then
  begin
    msg := MakeDefaultMsg(CM_ADDGROUPMEMBER, 0, 0, 0, 0);
    SendSocket(EncodeMessage(msg) + EncodeString(withwho));
  //  DScreen.AddChatBoardString(withwho + '是否加入我的队伍.', TColor($BB840F), clWhite);
  end;
end;

procedure TFrmMain.SendDelGroupMember(withwho: string);
var
  msg: TDefaultMessage;
begin
  if withwho <> '' then
  begin
    msg := MakeDefaultMsg(CM_DELGROUPMEMBER, 0, 0, 0, 0);
    SendSocket(EncodeMessage(msg) + EncodeString(withwho));
  end;
end;

procedure TFrmMain.SendGuildHome;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GUILDHOME, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGuildMemberList;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GUILDMEMBERLIST, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGuildAddMem(who: string);
var
  msg: TDefaultMessage;
begin
  if Trim(who) <> '' then
  begin
    msg := MakeDefaultMsg(CM_GUILDADDMEMBER, 0, 0, 0, 0);
    SendSocket(EncodeMessage(msg) + EncodeString(who));
  end;
end;

procedure TFrmMain.SendGuildDelMem(who: string);
var
  msg: TDefaultMessage;
begin
  if Trim(who) <> '' then
  begin
    msg := MakeDefaultMsg(CM_GUILDDELMEMBER, 0, 0, 0, 0);
    SendSocket(EncodeMessage(msg) + EncodeString(who));
  end;
end;

//巩磊凯狼 辨捞啊 呈公辨瘤 臼档废 漏妨辑 柯促.
procedure TFrmMain.SendGuildUpdateNotice(notices: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GUILDUPDATENOTICE, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(notices));
end;

procedure TFrmMain.SendGABoardUpdateNotice(notice, CurPage: integer; bodyText: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GABOARD_ADD, notice, CurPage, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(bodyText));
end;

procedure TFrmMain.SendGABoardModify(CurPage: integer; bodyText: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GABOARD_EDIT, 0, CurPage, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(bodyText));
end;

procedure TFrmMain.SendGetGABoardList(Page: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GABOARD_LIST, Page, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGABoardNoticeCheck;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GABOARD_NOTICE_CHECK, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendGABoardDel(CurPage: integer; bodyText: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GABOARD_DEL, 0, CurPage, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(bodyText));
end;

procedure TFrmMain.SendGuildUpdateGrade(rankinfo: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_GUILDUPDATERANKINFO, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(rankinfo));
end;

procedure TFrmMain.SendSpeedHackUser(code: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_SPEEDHACKUSER, code, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendAdjustBonus(remain: integer; babil: TNakedAbility);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_ADJUST_BONUS, remain, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeBuffer(@babil, sizeof(TNakedAbility)));
end;


{---------------------------------------------------------------}

function TFrmMain.ServerAcceptNextAction: Boolean;
begin
  Result := TRUE;
   //捞傈 青悼捞 辑滚俊辑 牢沥登菌绰瘤
  if ActionLock then
  begin
    if GetTickCount - ActionLockTime > 10 * 1000 then
    begin
      ActionLock := FALSE;
         //Dec (WarningLevel);
    end;
    Result := FALSE;
  end;
end;

function TFrmMain.CanNextAction: Boolean;
begin
  if (Myself.IsIdle) and (Myself.State and $04000000 = 0) and
      // 2003/07/15 脚痹公傍, 惑怕捞惑 眠啊...搬葫
    (Myself.State and $20000000 = 0) and (GetTickCount - DizzyDelayStart > DizzyDelayTime) then
  begin
    Result := TRUE;
  end
  else
    Result := FALSE;
end;

function TFrmMain.CanNextHit: Boolean;  //怖 荤侩窍扁 流傈俊 龋免秦具 窃.
var
  nexthit, levelfast: integer;
begin
  levelfast := _MIN(370, (Myself.Abil.Level * 14));
  levelfast := _MIN(800, levelfast + Myself.HitSpeed * 60);
  if BoAttackSlow then
    nexthit := 1400 - levelfast + 1500 //呈公 腹捞 甸菌芭唱, 渴捞 呈公 公芭框.
  else
    nexthit := 1400 - levelfast;
  if nexthit < 0 then
    nexthit := 0;
  if GetTickCount - LastHitTime > longword(nexthit) then
  begin
    LastHitTime := GetTickCount;
    Result := TRUE;
  end
  else
    Result := FALSE;
end;

procedure TFrmMain.ActionFailed;
begin
  targetx := -1;
  targety := -1;
  ActionFailLock := TRUE; //鞍篮 规氢栏肺 楷加捞悼角菩甫 阜扁困秦辑, FailDir苞 窃膊 荤侩
  Myself.MoveFail;
end;

function TFrmMain.IsUnLockAction(action, adir: integer): Boolean;
begin
  if (ActionFailLock and (action = FailAction) and (adir = FailDir) and (GetTickCount - FailActionTime < 1000)) or (MapMoving) or (BoServerChanging) then
  begin
    Result := FALSE;
  end
  else
  begin
    ActionFailLock := FALSE;
    Result := TRUE;
  end;
end;

function TFrmMain.IsGroupMember(uname: string): Boolean;
var
  i: integer;
begin
  Result := FALSE;
  for i := 0 to GroupMembers.Count - 1 do
    if GroupMembers[i] = uname then
    begin
      Result := TRUE;
      break;
    end;
end;

{-------------------------------------------------------------}

procedure TFrmMain.Timer1Timer(Sender: TObject);
var
  str, data: string;
  len, i, n, mcnt: integer;
const
  busy: Boolean = FALSE;
begin
  if busy then
    exit;
   //if ServerConnected then
   //   DxTimer.Enabled := TRUE
   //else
   //   DxTimer.Enabled := FALSE;

  busy := TRUE;
  try
    BufferStr := BufferStr + SocStr;
    SocStr := '';
    if BufferStr <> '' then
    begin
      mcnt := 0;
      while Length(BufferStr) >= 2 do
      begin
        if MapMovingWait then
          break; // 措扁..
        if Pos('!', BufferStr) <= 0 then
          break;
        BufferStr := ArrestStringEx(BufferStr, '#', '!', data);
        if data <> '' then
        begin
          DecodeMessagePacket(data);
        end
        else if Pos('!', BufferStr) = 0 then
          break;
      end;
    end;
  finally
    busy := FALSE;
  end;

  if WarningLevel > 30 then
  begin
    FrmMain.Close;
  end;

  if BoQueryPrice then
  begin
    if GetTickCount - QueryPriceTime > 500 then
    begin
      BoQueryPrice := FALSE;
      case FrmDlg.SpotDlgMode of
        dmSell:
          SendQueryPrice(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name);
        dmRepair:
          SendQueryRepairCost(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name);
      end;
    end;
  end;

  if BonusPoint > 0 then
  begin
    FrmDlg.DBotPlusAbil.Visible := TRUE;
  end
  else
  begin
    FrmDlg.DBotPlusAbil.Visible := FALSE;
  end;

end;

procedure TFrmMain.TimerRunTimer(Sender: TObject);
const
  boRun: Boolean = False;
begin
  if boRun then
    Exit;
  boRun := True;
  try
    AppOnIdle();
  finally
    boRun := False;
  end;
end;

procedure TFrmMain.MsgProg;
var
  str, data: string;
  len, i, n, mcnt: integer;
const
  busy: Boolean = FALSE;
begin
  if busy then
    exit;
   //if ServerConnected then
   //   DxTimer.Enabled := TRUE
   //else
   //   DxTimer.Enabled := FALSE;

  busy := TRUE;
  try
    BufferStr := BufferStr + SocStr;
    SocStr := '';
    if BufferStr <> '' then
    begin
      mcnt := 0;
      while Length(BufferStr) >= 2 do
      begin
        if MapMovingWait then
          break; // 措扁..
        if Pos('!', BufferStr) <= 0 then
          break;
        BufferStr := ArrestStringEx(BufferStr, '#', '!', data);
        if data <> '' then
        begin
          DecodeMessagePacket(data);
        end
        else if Pos('!', BufferStr) = 0 then
          break;
      end;
    end;
  finally
    busy := FALSE;
  end;

  if WarningLevel > 30 then
  begin
    FrmMain.Close;
  end;

  if BoQueryPrice then
  begin
    if GetTickCount - QueryPriceTime > 500 then
    begin
      BoQueryPrice := FALSE;
      case FrmDlg.SpotDlgMode of
        dmSell:
          SendQueryPrice(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name);
        dmRepair:
          SendQueryRepairCost(CurMerchant, SellDlgItem.MakeIndex, SellDlgItem.S.Name);
      end;
    end;
  end;

  if BonusPoint > 0 then
  begin
    FrmDlg.DBotPlusAbil.Visible := TRUE;
  end
  else
  begin
    FrmDlg.DBotPlusAbil.Visible := FALSE;
  end;

end;

procedure TFrmMain.SpeedHackTimerTimer(Sender: TObject);
var
  gcount, timer: longword;
  ahour, amin, asec, amsec: word;
begin
  DecodeTime(Time, ahour, amin, asec, amsec);
  timer := ahour * 1000 * 60 * 60 + amin * 1000 * 60 + asec * 1000 + amsec;
  gcount := GetTickCount;
  if SHGetTime > 0 then
  begin
    if abs((gcount - SHGetTime) - (timer - SHTimerTime)) > 70 then
    begin
      Inc(SHFakeCount);
    end
    else
      SHFakeCount := 0;
//      if SHFakeCount > 4 then begin
    if SHFakeCount > 1 then
    begin
      if not SpeedHackUse then
      begin
        SendSpeedHackUser(10001);
        SpeedHackUse := True;
      end;
      FrmDlg.DMessageDlg('网络出现不稳定情况导致游戏已被中止 CODE=10001\' + '如有问题请联系游戏管理员 [ddq@163.com]', [mbOk]);
      FrmMain.Close;
    end;
    if BoCheckSpeedHackDisplay then
    begin
      DScreen.AddSysMsg('->' + IntToStr(gcount - SHGetTime) + ' - ' + IntToStr(timer - SHTimerTime) + ' = ' + IntToStr(abs((gcount - SHGetTime) - (timer - SHTimerTime))) + ' (' + IntToStr(SHFakeCount) + ')');
    end;
  end;
  SHGetTime := gcount;
  SHTimerTime := timer;
end;

procedure TFrmMain.FindWHHackTimerTimer(Sender: TObject);
var
  v0, v1, v2, v3: integer;
begin
  if Myself <> nil then
  begin
      // 秦欧 雀乔 八荤
    v0 := Myself.Abil.Level * HIT_INCLEVEL + abs(Myself.HitSpeed) * HIT_INCSPEED + Myself.Abil.Weight + Myself.Abil.MaxWeight + Myself.Abil.WearWeight + Myself.Abil.MaxWearWeight + Myself.Abil.HandWeight + Myself.Abil.MaxHandWeight + RUN_STRUCK_DELAY;

    v1 := HitCheckSum1;
    v2 := (longword(pHitCheckSum2^) xor $FFFFFFFF) div 4;
    v3 := (longword(pHitCheckSum3^) xor $FFFFFFFF) div 20;
      ////
    if (v0 = v1) and (v0 = v2) and (v0 = v3) then
    begin
      ;
    end
    else
    begin
         //皋葛府甫 秦欧沁澜...
      FrmMain.Close;
      exit;
    end;
  end;
end;

procedure TFrmMain.CheckSpeedHack(rtime: Longword);
var
  cltime, svtime: integer;
  str: string;
begin
  if FirstServerTime > 0 then
  begin
    if (GetTickCount - FirstClientTime) > 10 * 60 * 1000 then
    begin  //30盒 付促 檬扁拳
      FirstServerTime := rtime; //檬扁拳
      FirstClientTime := GetTickCount;
         //ServerTimeGap := rtime - int64(GetTickCount);
    end;
    cltime := GetTickCount - FirstClientTime;
    svtime := rtime - FirstServerTime; // + 3000;

    if cltime > (svtime + 5000) then
    begin  //泛阑 皑救窃
      Inc(TimeFakeDetectCount);
      if TimeFakeDetectCount > 5 then
      begin
            //矫埃炼累...
        str := 'Bad';
        if not SpeedHackUse then
        begin
          SendSpeedHackUser(10000);
          SpeedHackUse := True;
        end;
        FrmDlg.DMessageDlg('连接情况很差或系统不稳定 CODE=10000\' + '请联系游戏管理员 [ddq@163.com]', [mbOk]);
        FrmMain.Close;
      end;
    end
    else
    begin
      str := 'Good';
      TimeFakeDetectCount := 0;
    end;
    if BoCheckSpeedHackDisplay then
    begin
      DScreen.AddSysMsg(IntToStr(svtime) + ' - ' + IntToStr(cltime) + ' = ' + IntToStr(svtime - cltime) + ' ' + str);
    end;
  end
  else
  begin
    FirstServerTime := rtime;
    FirstClientTime := GetTickCount;
      //ServerTimeGap := int64(GetTickCount) - longword(msg.Recog);
  end;
end;

procedure TFrmMain.CheckSpeedHackChina(stime: longword);
begin

end;

procedure TFrmMain.DecodeMessagePacket(datablock: string);
var
  head, body, body2, tagstr, data, rdstr, str: string;
  msg: TDefaultMessage;
  smsg: TShortMessage;
  mbw: TMessageBodyW;
  desc: TCharDesc;
  wl: TMessageBodyWL;
  featureEx, wd: word;
  L, i, j, n, BLKSize, param, sound, cltime, svtime, idx: integer;
  tempb, AddCheck: boolean;
  actor: TActor;
  event: TClEvent;
  GroupTimeout:DWORD;
begin
  if datablock[1] = '+' then
  begin  //checkcode
    data := Copy(datablock, 2, Length(datablock) - 1);
    data := GetValidStr3(data, tagstr, ['/']);
    if tagstr = 'PWR' then
      BoNextTimePowerHit := TRUE;  //促澜锅俊 powerhit阑 锭副 荐 乐澜...
    if tagstr = 'LNG' then
      BoCanLongHit := TRUE;
    if tagstr = 'ULNG' then
      BoCanLongHit := FALSE;
    if tagstr = 'WID' then
      BoCanWideHit := TRUE;
    if tagstr = 'UWID' then
      BoCanWideHit := FALSE;
    if tagstr = 'CRS' then
      BoCanCrossHit := TRUE;
    if tagstr = 'UCRS' then
      BoCanCrossHit := FALSE;
      // 2003/07/15 脚痹公傍 眠啊
    if tagstr = 'TWN' then
      BoCanTwinHit := TRUE;
    if tagstr = 'UTWN' then
      BoCanTwinHit := FALSE;
    if tagstr = 'FIR' then
    begin
      BoNextTimeFireHit := TRUE;  //堪拳搬捞 技泼等 惑怕
      LatestFireHitTime := GetTickCount;
         //Myself.SendMsg (SM_READYFIREHIT, Myself.XX, Myself.YY, Myself.Dir, 0, 0, '', 0);
    end;
    if tagstr = 'STN' then
      BoCanStoneHit := TRUE;
    if tagstr = 'USTN' then
      BoCanStoneHit := FALSE;

    if tagstr = 'UFIR' then
      BoNextTimeFireHit := FALSE;
    if tagstr = 'GOOD' then
    begin
      ActionLock := FALSE;
      Inc(ReceiveCount);
    end;
    if tagstr = 'FAIL' then
    begin
      ActionFailed;
      ActionLock := FALSE;
      Inc(ReceiveCount);
    end;
    if data <> '' then
    begin
      data := GetValidStr3(data, tagstr, ['/']);
      CheckSpeedHack(Str_ToInt(tagstr, 0));
      if data <> '' then
      begin
//            DScreen.AddSysMsg('[傍加琴眉农] Count:'+IntToStr(SHHitSpeedCount));
        if Myself.HitSpeed <> Str_ToInt(data, 0) then
        begin
//               DScreen.AddSysMsg('[厚沥惑]');
          Inc(SHHitSpeedCount);
          if SHHitSpeedCount > 3 then
          begin
            DScreen.AddChatBoardString('您目前正在使用黑客工具，请停止使用', clYellow, clRed);
          end;
          Myself.HitSpeed := Str_ToInt(data, 0);

          if SHHitSpeedCount > 6 then
          begin
            if not SpeedHackUse then
            begin
              SendSpeedHackUser(10002);
              SpeedHackUse := True;
            end;
            FrmDlg.DMessageDlg('随时终止此优惠计划. CODE=10002\' + '请联系游戏管理员 [ddq@163.com]', [mbOk]);
            FrmMain.Close;
          end;
        end
        else
        begin
//               DScreen.AddSysMsg('[沥惑]');
          if SHHitSpeedCount > 0 then
            Dec(SHHitSpeedCount);
        end;
      end;
    end;
    exit;
  end;
  if Length(datablock) < DEFBLOCKSIZE then
  begin
    if datablock[1] = '=' then
    begin
      data := Copy(datablock, 2, Length(datablock) - 1);
      if data = 'DIG' then
      begin
        Myself.BoDigFragment := TRUE;
      end;
    end;
    exit;
  end;

  head := Copy(datablock, 1, DEFBLOCKSIZE);
  body := Copy(datablock, DEFBLOCKSIZE + 1, Length(datablock) - DEFBLOCKSIZE);
  msg := DecodeMessage(head);

  if msg.Ident = SM_DAYCHANGING then
  begin
    DayBright_fake := msg.Param;
    DarkLevel_fake := msg.Tag;
  end;

  if Myself = nil then
  begin
    case msg.Ident of
      SM_NEWID_SUCCESS:
        begin
          FrmDlg.DMessageDlg('你的帐号已经建立了.\请妥善保管你的帐户和密码,\' + '并且不要因任何原因把它们告诉任何其他人.\如果忘记了密码,\' + '你可以通过我们的主页重新找回它.\' + '(http://www.1mir2.com)', [mbOk]);

        end;
      SM_NEWID_FAIL:
        begin
          case msg.Recog of
            0:
              begin
                FrmDlg.DMessageDlg('帐号"' + MakeNewId + '"已被其他的玩家使用了,\' + '请创建一个不同的帐号.', [mbOk]);
                LoginScene.NewIdRetry(FALSE);  //促矫 矫档
              end;
            -2:
              FrmDlg.DMessageDlg('这个帐号禁止使用,\请更换其他帐号进行注册.', [mbOk]);
          else
            FrmDlg.DMessageDlg('建立ID失败,\请确认它没有包含空格,\特殊字符或难以辨认的字符.', [mbOk]);
          end;
        end;
      SM_PASSWD_FAIL:
        begin
          case msg.Recog of
            -1:
              FrmDlg.DMessageDlg('密码错误.', [mbOk]);
            -2:
              FrmDlg.DMessageDlg('连续三次密码错误,\你将在一段时间内无法再次连接.', [mbOk]);
            -3:
              FrmDlg.DMessageDlg('这个帐号正在使用,或者是被异常的终止锁定了,\请稍后再试.', [mbOk]);
            -4:
              FrmDlg.DMessageDlg('这个帐户不能正确访问,\请改变帐户或者申请付费注册.', [mbOk]);
            -5:
              FrmDlg.DMessageDlg('这个账户已被禁止登录. \'+intToStr(msg.Param)+'天'+intToStr(msg.Tag)+'小时后可以使用. \网站 http://www.1mir2.com', [mbOk]);
          else
            FrmDlg.DMessageDlg('ID不存在或未知错误.', [mbOk]);
          end;
          LoginScene.PassWdFail;
        end;
      SM_NEEDUPDATE_ACCOUNT: //拌沥 沥焊甫 促矫 涝仿窍扼.
        begin
          ClientGetNeedUpdateAccount(body);
        end;
      SM_UPDATEID_SUCCESS:
        begin
          FrmDlg.DMessageDlg('你的帐户已经更新.', [mbOk]);
          ClientGetSelectServer;
        end;
      SM_UPDATEID_FAIL:
        begin
          FrmDlg.DMessageDlg('更新帐户失败.', [mbOk]);
          ClientGetSelectServer;
        end;
      SM_PASSOK_SELECTSERVER:
        begin
          AvailIDDay := Loword(msg.Recog);
          AvailIDHour := Hiword(msg.Recog);
          AvailIPDay := msg.Param;
          AvailIPHour := msg.Tag;

          if AvailIDDay > 0 then
          begin
            if AvailIDDay = 1 then
              FrmDlg.DMessageDlg('你的付费到今天为止', [mbOk])
            else
              FrmDlg.DMessageDlg('个人帐户期限剩余:' + IntToStr(AvailIDDay - 1) + '天', [mbOk]);
          end
          else if AvailIPDay > 0 then
          begin
            if AvailIPDay = 1 then
              FrmDlg.DMessageDlg('当前在用的IP的剩余时间将在今天结束', [mbOk])
            else // if AvailIPDay <= 3 then
              FrmDlg.DMessageDlg('当前IP的周期 ' + IntToStr(AvailIPDay) + '剩余天数', [mbOk]);
          end
          else if AvailIPHour > 0 then
          begin
                  // if AvailIPHour <= 100 then
            FrmDlg.DMessageDlg('IP的周期' + IntToStr(AvailIPHour) + '剩余小时', [mbOk]);
          end
          else if AvailIDHour > 0 then
          begin
            FrmDlg.DMessageDlg('个人帐户期限剩余:' + IntToStr(AvailIDHour) + '小时', [mbOk]);
          end;

          if not LoginScene.BoUpdateAccountMode then
            ClientGetSelectServer;
        end;
      SM_PASSOK_WRONGSSN:
        begin
          FrmDlg.DMessageDlg('登记的身份证号码错误.', [mbOk]);
        end;
      SM_NOT_IN_SERVICE:
        begin
          FrmDlg.DMessageDlg('当前服务器正在维护中,\请至官方网站了解详情http://www.1mir2.com.', [mbOk]);
        end;
      SM_SEND_PUBLICKEY:
        begin
          SetPublicKey(msg.Param xor msg.Tag);
        end;
      SM_SELECTSERVER_OK:
        begin
          ClientGetPasswdSuccess(body);
        end;

      SM_QUERYCHR:
        begin
          ClientGetReceiveChrs(body);
        end;
      SM_QUERYCHR_FAIL:
        begin
          DoFastFadeOut := FALSE;
          DoFadeIn := FALSE;
          DoFadeOut := FALSE;
          FrmDlg.DMessageDlg('这个帐号不可用,服务器认正失败.', [mbOk]);
          Close;
        end;
      SM_NEWCHR_SUCCESS:
        begin
          SendQueryChr;
        end;
      SM_NEWCHR_FAIL:
        begin
          case msg.Recog of
            2:
              FrmDlg.DMessageDlg('这个名字已经存在.', [mbOk]);
            3:
              FrmDlg.DMessageDlg('你只能为一个帐户设两个角色.\请和游戏管理员联系.', [mbOk]);
            4:
              FrmDlg.DMessageDlg('角色建立失败 Error=4', [mbOk]);
          else
            FrmDlg.DMessageDlg('未知的错误.', [mbOk]);
          end;
        end;
      SM_CHGPASSWD_SUCCESS:
        begin
          FrmDlg.DMessageDlg('密码变更成功.', [mbOk]);
        end;
      SM_CHGPASSWD_FAIL:
        begin
          case msg.Recog of
            -1:
              FrmDlg.DMessageDlg('密码错误,\不能进行密码变更.', [mbOk]);
            -2:
              FrmDlg.DMessageDlg('帐户被锁定,请稍后再试.', [mbOk]);
          else
            FrmDlg.DMessageDlg('密码少于4位,你不能改变它', [mbOk]);
          end;
        end;
      SM_DELCHR_SUCCESS:
        begin
          SendQueryChr;
        end;
      SM_DELCHR_FAIL:
        begin
          FrmDlg.DMessageDlg('删除角色失败.', [mbOk]);
        end;
      SM_STARTPLAY:
        begin
          ClientGetStartPlay(body);
          exit;
        end;
      SM_STARTFAIL:
        begin
          LoginScene.HideLoginBox;
          FrmDlg.DMessageDlg('您选择的服务器用户满员', [mbOk]);
                           //'辑滚狼 抗扁摹 给茄 巩力肺 立加捞 秒家登菌嚼聪促.',
          FrmMain.Close;
          exit;
        end;
      SM_VERSION_FAIL:
        begin
          LoginScene.HideLoginBox;
          FrmDlg.DMessageDlg('版本错误，请下载最新版本 (www.1mir2.com)', [mbOk]);
          FrmMain.Close;
          exit;
        end;
      SM_OUTOFCONNECTION, SM_NEWMAP, SM_LOGON, SM_RECONNECT, SM_SENDNOTICE, SM_DLGMSG:
        ;  //酒贰俊辑 贸府
    else
      exit;
    end;
  end;
  if MapMoving then
  begin
    if msg.Ident = SM_CHANGEMAP then
    begin
      WaitingMsg := msg;
      WaitingStr := DecodeString(body);
      MapMovingWait := TRUE;
      WaitMsgTimer.Enabled := TRUE;
    end;
    exit;
  end;

  if msg.Ident = SM_DAYCHANGING then
  begin
    pDayBrightCheck^ := msg.Param;
    pDarkLevelCheck^ := msg.Tag;
  end;

  case msg.Ident of
    SM_NEWMAP:  // 货肺款 甘俊 甸绢皑
      begin
        MiniMapIndex:=-1;
        FrmDlg.SafeCloseDlg;
        MapTitle := '';
        str := DecodeString(body); //mapname
        PlayScene.SendMsg(SM_NEWMAP, 0, msg.Param{x}, msg.tag{y}, LOBYTE(msg.Series){darkness}, // 侩带怜 FireDragon
          0, 0, 0, str{mapname});
        EffectNum := HIBYTE(msg.Series);
        if EffectNum < 0 then
          EffectNum := 0;
        if (EffectNum = 1) or (EffectNum = 2) then
          RunEffectTimer.Enabled := True
        else
          RunEffectTimer.Enabled := False;
      end;

    SM_LOGON:
      begin
        FirstServerTime := 0;
        FirstClientTime := 0;
        with msg do
        begin
          DecodeBuffer(body, @wl, sizeof(TMessageBodyWL));
          PlayScene.SendMsg(SM_LOGON, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir}, wl.lParam1, //desc.Feature,
            wl.lParam2, //desc.Status,
            0, '');
          DScreen.ChangeScene(stPlayGame);
          SendClientMessage(CM_QUERYBAGITEMS, 0, 0, 0, 0);
          if Lobyte(Loword(wl.lTag1)) = 1 then
            AllowGroup := TRUE
          else
            AllowGroup := FALSE;
          BoServerChanging := FALSE;
               // 2003/04/15 模备, 率瘤
          SendClientMessage(CM_FRIEND_LIST, 0, 0, 0, 0);
        end;
        if AvailIDDay > 0 then
        begin
          DScreen.AddChatBoardString('你被通过充值卡充值连接', clGreen, clWhite)
          //DScreen.AddChatBoardString('当前帐户期限剩余:' + IntToStr(AvailIDDay - 1) + '天', clGreen, clWhite)     //游戏里提示账户时间
        end
        else if AvailIPDay > 0 then
        begin
          DScreen.AddChatBoardString('你被通过固定数量IP连接', clGreen, clWhite)
        end
        else if AvailIPHour > 0 then
        begin
          DScreen.AddChatBoardString('你被通过固定时间IP连接', clGreen, clWhite)
        end
        else if AvailIDHour > 0 then
        begin
          DScreen.AddChatBoardString('你被通过固定时间帐户充值', clGreen, clWhite)
        end;
      end;

    SM_CHECK_CLIENTVALID:
      begin

        DecodeBuffer(body, @smsg, sizeof(TShortMessage));
        pClientCheckSum1^ := msg.Recog;
        pClientCheckSum2^ := MakeLong(msg.Param, msg.Tag);
        pClientCheckSum3^ := MakeLong(smsg.Ident, smsg.Msg);

      end;

    SM_RECONNECT:
      begin
        ClientGetReconnect(body);
      end;

    SM_TIMECHECK_MSG:
      begin
        CheckSpeedHack(msg.Recog);
      end;

    SM_AREASTATE:
      begin
        AreaStateValue := msg.Recog;
      end;

    SM_MAPDESCRIPTION:
      begin
        ClientGetMapDescription(body);
      end;

    SM_ADJUST_BONUS:
      begin
        ClientGetAdjustBonus(msg.Recog, body);
      end;

    SM_MYSTATUS:
      begin
        MyHungryState := msg.Param;  //硅绊前 惑怕
      end;

    SM_TURN:
      begin
        if Length(body) > UpInt(sizeof(TCharDesc) * 4 / 3) then
        begin
          body2 := Copy(body, UpInt(sizeof(TCharDesc) * 4 / 3) + 1, Length(body));
          data := DecodeString(body2); //某腐 捞抚
          str := GetValidStr3(data, data, ['/']);
               //data = 捞抚
               //str = 祸哎
        end
        else
          data := '';
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        PlayScene.SendMsg(SM_TURN, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir + light}, desc.Feature, desc.Status, 0, ''); //捞抚
        if data <> '' then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
          begin
            actor.DescUserName := GetValidStr3(data, actor.UserName, ['\']);
                  //actor.UserName := data;
            actor.NameColor := GetRGB(Str_ToInt(str, 0));
          end;
        end;
      end;

    SM_FOXSTATE:
      begin
        if Length(body) > UpInt(sizeof(TCharDesc) * 4 / 3) then
        begin
          body2 := Copy(body, UpInt(sizeof(TCharDesc) * 4 / 3) + 1, Length(body));
          data := DecodeString(body2); //某腐 捞抚
          str := GetValidStr3(data, data, ['/']);
               //data = 捞抚
               //str = 祸哎
        end
        else
          data := '';
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        PlayScene.SendMsg(SM_TURN, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir + light}, desc.Feature, desc.Status, 0, ''); //捞抚

        if data <> '' then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
          begin
            actor.DescUserName := GetValidStr3(data, actor.UserName, ['\']);
                  //actor.UserName := data;
            actor.NameColor := GetRGB(Str_ToInt(str, 0));
            actor.TempState := Hibyte(msg.Series); //厚岿玫林 泅力 惑怕 罐澜
//      DScreen.AddChatBoardString ('SM_FOXSTATE: TempState=> '+InttoStr(actor.TempState), clYellow, clRed);
          end;
        end;
      end;

    SM_BACKSTEP:
      begin
        if Length(body) > UpInt(sizeof(TCharDesc) * 4 / 3) then
        begin
          body2 := Copy(body, UpInt(sizeof(TCharDesc) * 4 / 3) + 1, Length(body));
          data := DecodeString(body2); //某腐 捞抚
          str := GetValidStr3(data, data, ['/']);
               //data = 捞抚
               //str = 祸哎
        end
        else
          data := '';
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        PlayScene.SendMsg(SM_BACKSTEP, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir + light}, desc.Feature, desc.Status, 0, ''); //捞抚
        if data <> '' then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
          begin
            actor.DescUserName := GetValidStr3(data, actor.UserName, ['\']);
                  //actor.UserName := data;
            actor.NameColor := GetRGB(Str_ToInt(str, 0));
          end;
        end;
      end;

    SM_SPACEMOVE_HIDE, SM_SPACEMOVE_HIDE2:
      begin
        if msg.Recog = Myself.RecogId then
        begin
          FrmDlg.SafeCloseDlg;
        end
        else
          PlayScene.SendMsg(msg.Ident, msg.Recog, msg.Param{x}, msg.tag{y}, 0, 0, 0, 0, '');
      end;

    SM_SPACEMOVE_SHOW, SM_SPACEMOVE_SHOW2:
      begin
        if Length(body) > UpInt(sizeof(TCharDesc) * 4 / 3) then
        begin
          body2 := Copy(body, UpInt(sizeof(TCharDesc) * 4 / 3) + 1, Length(body));
          data := DecodeString(body2); //某腐 捞抚
          str := GetValidStr3(data, data, ['/']);
               //data = 捞抚
               //str = 祸哎
        end
        else
          data := '';
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        if msg.Recog <> Myself.RecogId then
        begin //促弗 某腐磐牢 版快
          PlayScene.NewActor(msg.Recog, msg.Param, msg.tag, msg.Series, desc.feature, desc.Status);
        end;
        PlayScene.SendMsg(msg.Ident, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir + light}, desc.Feature, desc.Status, 0, ''); //捞抚
        if data <> '' then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
          begin
            actor.DescUserName := GetValidStr3(data, actor.UserName, ['\']);
                  //actor.UserName := data;
            actor.NameColor := GetRGB(Str_ToInt(str, 0));
          end;
        end;
      end;
    SM_SPACEMOVE_SHOW_NO:
      begin
        if Length(body) > UpInt(sizeof(TCharDesc) * 4 / 3) then
        begin
          body2 := Copy(body, UpInt(sizeof(TCharDesc) * 4 / 3) + 1, Length(body));
          data := DecodeString(body2); //某腐 捞抚
          str := GetValidStr3(data, data, ['/']);
               //data = 捞抚
               //str = 祸哎
        end
        else
          data := '';
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        if msg.Recog <> Myself.RecogId then
        begin //促弗 某腐磐牢 版快
          PlayScene.NewActor(msg.Recog, msg.Param, msg.tag, msg.Series, desc.feature, desc.Status);
        end;
        PlayScene.SendMsg(msg.Ident, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir + light}, desc.Feature, desc.Status, 0, ''); //捞抚
        if data <> '' then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
          begin
            actor.DescUserName := GetValidStr3(data, actor.UserName, ['\']);
                  //actor.UserName := data;
            actor.NameColor := GetRGB(Str_ToInt(str, 0));
          end;
        end;
      end;

    SM_WALK, SM_RUSH, SM_RUSHKUNG:
      begin
            //DScreen.AddSysMsg ('WALK ' + IntToStr(msg.Param) + ':' + IntToStr(msg.Tag));
        DecodeBuffer(body, @desc, sizeof(TCharDesc));

        if (msg.Recog <> Myself.RecogId) or (msg.Ident = SM_RUSH) or (msg.Ident = SM_RUSHKUNG) then
          PlayScene.SendMsg(msg.Ident, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir+light}, desc.Feature, desc.Status, 0, '');
        if msg.Ident = SM_RUSH then
          LatestRushRushTime := GetTickCount;
      end;

    SM_RUN:
      begin
            //DScreen.AddSysMsg ('RUN ' + IntToStr(msg.Param) + ':' + IntToStr(msg.Tag));
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        if msg.Recog <> Myself.RecogId then
          PlayScene.SendMsg(SM_RUN, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir+light}, desc.Feature, desc.Status, 0, '');
      end;

    SM_CHANGELIGHT:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.ChrLight := msg.Param;
        end;
      end;

    SM_LAMPCHANGEDURA:
      begin
        if UseItems[U_RIGHTHAND].S.Name <> '' then
        begin
          UseItems[U_RIGHTHAND].Dura := msg.Recog;
        end;
      end;

    SM_MOVEFAIL:      //荤侩 救窃...
      begin
        ActionFailed;
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        PlayScene.SendMsg(SM_TURN, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series{dir}, desc.Feature, desc.Status, 0, '');
      end;

    SM_BUTCH:
      begin
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        if msg.Recog <> Myself.RecogId then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
            actor.SendMsg(SM_SITDOWN, msg.Param{x}, msg.tag{y}, msg.Series{dir}, 0, 0, '', 0);
        end;
      end;
    SM_SITDOWN:
      begin
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        if msg.Recog <> Myself.RecogId then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
            actor.SendMsg(SM_SITDOWN, msg.Param{x}, msg.tag{y}, msg.Series{dir}, 0, 0, '', 0);
        end;
      end;

    SM_HIT, SM_HEAVYHIT, SM_POWERHIT, SM_LONGHIT, SM_WIDEHIT,
      // 2003/03/15 脚痹公傍
    SM_CROSSHIT, SM_TWINHIT, SM_STONEHIT, SM_BIGHIT, SM_FIREHIT:
      begin
        if msg.Recog <> Myself.RecogId then
        begin
          actor := PlayScene.FindActor(msg.Recog);
          if actor <> nil then
          begin
            actor.SendMsg(msg.Ident, msg.Param{x}, msg.tag{y}, msg.Series{dir}, 0, 0, '', 0);
            if msg.ident = SM_HEAVYHIT then
            begin
              if body <> '' then
                actor.BoDigFragment := TRUE;
            end;
          end;
        end;
      end;
    SM_FLYAXE:
      begin
        DecodeBuffer(body, @mbw, sizeof(TMessageBodyW));
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.SendMsg(msg.Ident, msg.Param{x}, msg.tag{y}, msg.Series{dir}, 0, 0, '', 0);
          actor.TargetX := mbw.Param1;  //x 带瘤绰 格钎
          actor.TargetY := mbw.Param2;    //y
          actor.TargetRecog := MakeLong(mbw.Tag1, mbw.Tag2);
        end;
      end;

    SM_LIGHTING, SM_DRAGON_FIRE1, SM_DRAGON_FIRE2, SM_DRAGON_FIRE3, SM_LIGHTING_1..SM_LIGHTING_3:
      begin
        DecodeBuffer(body, @wl, sizeof(TMessageBodyWL));
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.SendMsg(msg.Ident, msg.Param{x}, msg.tag{y}, msg.Series{dir}, 0, 0, '', 0);
          actor.TargetX := wl.lParam1;  //x 带瘤绰 格钎
          actor.TargetY := wl.lParam2;    //y
          actor.TargetRecog := wl.lTag1;
          actor.MagicNum := wl.lTag2;   //付过 锅龋
        end;
      end;

      // 2003/02/11 弊缝盔狼 困摹 沥焊
      SM_GROUPPOS:
      begin
        DecodeBuffer(body, @mbw, sizeof(TMessageBodyW));
            // 2003/03/04 弊缝盔 沤扁颇楷 汲沥
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
//               if not actor.BoOpenHealth then
          AddCheck := True;
          if GroupIdList.Count > 0 then
            for i := 0 to GroupIdList.Count - 1 do
            begin
              if integer(GroupIdList[i]) = actor.RecogId then
              begin
                AddCheck := False;
                Break;
              end;
            end;
          if AddCheck then
            GroupIdList.Add(pointer(actor.RecogId)); // MonOpenHp
          //actor.BoOpenHealth := TRUE;    // 组队显示对方血条
        end;
        if (msg.Recog <> MySelf.RecogId)  then      
        begin
          idx := -1;
          for i := 1 to MAXVIEWOBJECT do
          begin
            if (ViewList[i].Index = msg.Recog) then
              idx := i;
          end;
          if (idx = -1) then
          begin
            Inc(ViewListCount);
            if (ViewListCount > MAXVIEWOBJECT) then
              ViewListCount := MAXVIEWOBJECT;
            idx := ViewListCount;
          end;
          ViewList[idx].Index := msg.Recog;
          ViewList[idx].X := msg.Param;  {x}
          ViewList[idx].Y := msg.tag;    {y}
          ViewList[idx].LastTick := GetTickCount;
        end;
      end;

    SM_SPELL: //促弗 捞啊 林巩阑 寇框
      begin
        body:=GetValidStr3(body,body2,['\']);
        if body<>'0' then
           begin
             actor := PlayScene.FindActor(StrToIntDef(body,0));
             if actor<>nil then
                begin
                  msg.Param:=actor.XX;
                  msg.Tag:=actor.YY;
                end;
           end;
        UseMagicSpell(msg.Recog{who}, msg.Series{effectnum}, msg.Param{tx}, msg.Tag{y}, Str_ToInt(body2, 0));
       // UseMagicSpell(msg.Recog{who}, msg.Series{effectnum}, msg.Param{tx}, msg.Tag{y}, Str_ToInt(body, 0));
      end;
    SM_MAGICFIRE:
      begin
        DecodeBuffer(body, @param, sizeof(integer));
        UseMagicFire(msg.Recog{who}, Lobyte(msg.Series){efftype}, Hibyte(msg.Series){effnum}, msg.Param{tx}, msg.Tag{y}, param);
      end;
    SM_MAGICFIRE_FAIL:
      begin
        UseMagicFireFail(msg.Recog{who});
      end;

    SM_NORMALEFFECT:
      begin
            //msg.Recog{who},
        UseNormalEffect(msg.Series{辆幅}, msg.Param{X}, msg.Tag{Y});
      end;
    SM_LOOPNORMALEFFECT:
      begin
        UseLoopNormalEffect(msg.Recog{RecogID}, msg.Series{辆幅}, msg.Param{矫埃});
//      DScreen.AddChatBoardString ('SM_LOOPNORMALEFFECT: 风橇鸥烙=> ' +IntToStr(msg.Param), clYellow, clRed);
      end;

    SM_OUTOFCONNECTION:
      begin
        DoFastFadeOut := FALSE;
        DoFadeIn := FALSE;
        DoFadeOut := FALSE;
        FrmDlg.DMessageDlg('服务器连接被强行中断\连接时间可能超过限制\或者用户请求重新连接', [mbOk]);
        Close;
      end;

    SM_DEATH, SM_NOWDEATH:
      begin
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.SendMsg(msg.Ident, msg.param{x}, msg.Tag{y}, msg.Series{damage}, desc.Feature, desc.Status, '', 0);
          actor.Abil.HP := 0;
        end
        else
        begin
          PlayScene.SendMsg(SM_DEATH, msg.Recog, msg.param{x}, msg.Tag{y}, msg.Series{damage}, desc.Feature, desc.Status, 0, '');
        end;
      end;
    SM_SKELETON:
      begin
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
        PlayScene.SendMsg(SM_SKELETON, msg.Recog, msg.param{HP}, msg.Tag{maxHP}, msg.Series{damage}, desc.Feature, desc.Status, 0, '');
      end;
    SM_ALIVE:
      begin
        DecodeBuffer(body, @desc, sizeof(TCharDesc));
//            UseNormalEffect (NE_RELIVE{辆幅}, MySelf.XX{X}, MySelf.YY{Y});
        PlayScene.SendMsg(SM_ALIVE, msg.Recog, msg.param{HP}, msg.Tag{maxHP}, msg.Series{damage}, desc.Feature, desc.Status, 0, '');
      end;

    SM_ABILITY:
      begin
        Myself.Gold := msg.Recog;
        Myself.Job := msg.Param;
        DecodeBuffer(body, @Myself.Abil, sizeof(TAbility));
        ChangeWalkHitValues(Myself.Abil.Level, Myself.HitSpeed, Myself.Abil.Weight + Myself.Abil.MaxWeight + Myself.Abil.WearWeight + Myself.Abil.MaxWearWeight + Myself.Abil.HandWeight + Myself.Abil.MaxHandWeight, RUN_STRUCK_DELAY);
      end;

    SM_SUBABILITY:
      begin
        MyHitPoint := Lobyte(msg.Param);
        MySpeedPoint := Hibyte(msg.Param);
        MyAntiPoison := Lobyte(msg.Tag);
        MyPoisonRecover := Hibyte(msg.Tag);
        MyHealthRecover := Lobyte(msg.Series);
        MySpellRecover := Hibyte(msg.Series);
        MyAntiMagic := lobyte(loword(msg.Recog));
      end;

    SM_DAYCHANGING:
      begin
        DayBright := msg.Param;
        DarkLevel := msg.Tag;
        if DarkLevel = 0 then
          ViewFog := FALSE
        else
          ViewFog := TRUE;
      end;

    SM_WINEXP:
      begin
        Myself.Abil.Exp := msg.Recog; //坷弗 版氰摹
            //DScreen.AddSysMsg ('已获得' + IntToStr(msg.Param) + ' 点经验值。');
        DScreen.AddChatBoardString(IntToStr(MakeLong(msg.Param, msg.tag)) + ' 经验值增加.', clWhite, clRed);
      end;

    SM_CHANGEFAMEPOINT:
      begin
        Myself.FameName := DecodeString(body);
        Myself.Abil.FameCur := msg.Recog; //函版等 疙己摹
//            DScreen.AddChatBoardString ('SM_CHANGEFAMEPOINT: msg.Recog=> ' + IntToStr(Myself.Abil.FameCur), clWhite, clRed);
//            DScreen.AddChatBoardString ('SM_CHANGEFAMEPOINT: DecodeString (body)=> ' + Myself.FameName, clWhite, clRed);
      end;

    SM_LEVELUP:
      begin
        DScreen.AddSysMsg('升级!');
        DScreen.AddChatBoardString('您的等级已提升！', TColor($A21C06), TColor($F6B9DE));
      end;

    SM_HEALTHSPELLCHANGED:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.Abil.HP := msg.Param;
          actor.Abil.MP := msg.Tag;
          actor.Abil.MaxHP := msg.Series;
               //actor.BoEatEffect := TRUE;
               //actor.EatEffectFrame := 0;
               //actor.EatEffectTime := GetTickCount;
        end;
      end;

    SM_STRUCK:
      begin
            //wl: TMessageBodyWL;
        DecodeBuffer(body, @wl, sizeof(TMessageBodyWL));
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          if actor = Myself then
          begin
            if Myself.NameColor = 249 then //弧盎捞绰 嘎栏搁 立加阑 给 谗绰促.
              LatestStruckTime := GetTickCount;
          end
          else
          begin
            if actor.CanCancelAction then
              actor.CancelAction;
          end;
//          if not (actor is THumActor) then     // 如果不是怪物就不后仰  开启这段人物不后仰
          actor.UpdateMsg(SM_STRUCK, wl.lTag2, 0, msg.Series{damage}, wl.lParam1, wl.lParam2, '', wl.lTag1{锭赴仇酒捞叼});
          actor.Abil.HP := msg.param;
          actor.Abil.MaxHP := msg.Tag;
        end;
      end;

    SM_CHANGEFACE:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          DecodeBuffer(body, @desc, sizeof(TCharDesc));
          actor.WaitForRecogId := MakeLong(msg.Param, msg.Tag);
          actor.WaitForFeature := desc.Feature;
          actor.WaitForStatus := desc.Status;
          AddChangeFace(actor.WaitForRecogId);
        end;
      end;

    SM_OPENHEALTH:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          if actor <> Myself then
          begin
            actor.Abil.HP := msg.Param;
            actor.Abil.MaxHP := msg.Tag;
          end;
          actor.Bo_OpenHealth := TRUE;
          //actor.OpenHealthTime := 999999999;
          //actor.OpenHealthStart := GetTickCount;
        end;
      end;
    SM_CLOSEHEALTH:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.Bo_OpenHealth := FALSE;
        end;
      end;
    SM_INSTANCEHEALGUAGE:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.Abil.HP := msg.param;
          actor.Abil.MaxHP := msg.Tag;
          actor.BoInstanceOpenHealth := TRUE;
          actor.OpenHealthTime := 2 * 1000;
          actor.OpenHealthStart := GetTickCount;
        end;
      end;

    SM_BREAKWEAPON:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          if actor is THumActor then
            THumActor(actor).DoWeaponBreakEffect;
        end;
      end;

    SM_CRY, SM_GROUPMESSAGE, //   弊缝 皋技瘤
    SM_GUILDMESSAGE, SM_WHISPER, SM_SYSMSG_REMARK, SM_SYSMESSAGE: //系统消息
      begin
        str := DecodeString(body);
        DScreen.AddChatBoardString(str, GetRGB(Lobyte(msg.Param)), GetRGB(Hibyte(msg.Param)));
        if msg.Ident = SM_GUILDMESSAGE then
          FrmDlg.AddGuildChat(str)
        else if msg.Ident = SM_SYSMSG_REMARK then
          DScreen.AddSysMsg('clYellow' + str);
      end;

    SM_HEAR:
      begin
        if not g_boOwnerMsg then   //拒绝公聊 
        str := DecodeString(body);
        DScreen.AddChatBoardString(str, GetRGB(Lobyte(msg.Param)), GetRGB(Hibyte(msg.Param)));
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
          actor.Say(str);
      end;

    SM_USERNAME:
      begin
        str := DecodeString(body);
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
               //Username \ 荤合巩颇 / 疙己龋莫
          actor.FameName := GetValidStr3(str, str, ['/']);
          actor.DescUserName := GetValidStr3(str, actor.Username, ['\']);
          actor.NameColor := GetRGB(msg.Param);
        end;
      end;
    SM_CHANGENAMECOLOR:
      begin
        actor := PlayScene.FindActor(msg.Recog);
        if actor <> nil then
        begin
          actor.NameColor := GetRGB(msg.Param);
        end;
      end;

    SM_HIDE, SM_GHOST,  //儡惑..
    SM_DISAPPEAR:
      begin
        if Myself.RecogId <> msg.Recog then
          PlayScene.SendMsg(SM_HIDE, msg.Recog, msg.Param{x}, msg.tag{y}, 0, 0, 0, 0, '');
      end;

    SM_DIGUP:
      begin
        DecodeBuffer(body, @wl, sizeof(TMessageBodyWL));
        actor := PlayScene.FindActor(msg.Recog);
        if actor = nil then
          actor := PlayScene.NewActor(msg.Recog, msg.Param, msg.tag, msg.Series, wl.lParam1, wl.lParam2);
        actor.CurrentEvent := wl.lTag1;
        actor.SendMsg(SM_DIGUP, msg.Param{x}, msg.tag{y}, msg.Series{dir + light}, wl.lParam1, wl.lParam2, '', 0);
      end;
    SM_DIGDOWN:
      begin //券康茄龋 msg.Series(规氢)罐澜
        PlayScene.SendMsg(SM_DIGDOWN, msg.Recog, msg.Param{x}, msg.tag{y}, msg.Series, 0, 0, 0, '');
      end;
    SM_SHOWEVENT:
      begin
        DecodeBuffer(body, @smsg, sizeof(TShortMessage));
        event := TClEvent.Create(msg.Recog, Loword(msg.Tag){x}, msg.Series{y}, msg.Param{e-type});
        event.Dir := 0;
        event.EventParam := smsg.Ident;
        EventMan.AddEvent(event);  //clvent啊 Free瞪 荐 乐澜
      end;
    SM_HIDEEVENT:
      begin
        EventMan.DelEventById(msg.Recog);
      end;

      //Item ??
      SM_ADDITEM:
      begin
        ClientGetAddItem(body);
      end;
    SM_COUNTERITEMCHANGE:
      begin
        if not BoDealEnd then
          dealactiontime := GetTickCount;  // 背券且锭 - 般摹扁 酒捞袍狼 版快 皋技瘤 朝扼咳
        ChangeItemCount(msg.Recog, msg.Param, msg.Tag, DecodeString(body));
      end;
    SM_UPGRADEITEM_RESULT:
      begin
        UpgradeItemResult(msg.Recog, msg.Param, DecodeString(body));
      end;
    SM_BAGITEMS:
      begin
        ClientGetBagItmes(body);
      end;
    SM_UPDATEITEM:
      begin
        ClientGetUpdateItem(body);
      end;
    SM_DELITEM:
      begin
        ClientGetDelItem(body, msg.Tag);
      end;
    SM_DELITEMS:
      begin
        ClientGetDelItems(body);
      end;

    SM_DROPITEM_SUCCESS:
      begin
        DelDropItem(DecodeString(body), msg.Recog);
      end;
    SM_DROPITEM_FAIL:
      begin
        ClientGetDropItemFail(DecodeString(body), msg.Recog);
      end;

    SM_ITEMSHOW:
      begin
        ClientGetShowItem(msg.Recog, msg.param{x}, msg.Tag{y}, msg.Series{looks}, DecodeString(body));
      end;
    SM_ITEMHIDE:
      begin
        ClientGetHideItem(msg.Recog, msg.param, msg.Tag);
      end;

    SM_OPENDOOR_OK: //穿焙啊俊 狼秦 巩捞 凯覆
      begin
        Map.OpenDoor(msg.param, msg.tag);
            //巩咯绰 家府...
      end;

    SM_OPENDOOR_LOCK: //郴啊 凯妨绊 茄 巩捞 泪败乐澜
      begin
        DScreen.AddSysMsg('巩捞 泪败廉 乐嚼聪促.');
      end;
    SM_CLOSEDOOR:
      begin
        Map.CloseDoor(msg.param, msg.tag);
      end;

    SM_CANCLOSE_OK:
      begin
//               DScreen.AddChatBoardString ('Receive=> SM_CANCLOSE_OK:', clYellow, clRed);
        if (GetTickCount - LatestStruckTime > 10000) and (GetTickCount - LatestMagicTime > 10000) and (GetTickCount - LatestHitTime > 10000) or (Myself.Death) then
        begin
          AppLogOut;
        end
        else
          DScreen.AddChatBoardString('在战斗的时候你不能退出游戏.', clYellow, clRed);
      end;

    SM_CANCLOSE_FAIL:
      begin
//               DScreen.AddChatBoardString ('Receive=> SM_CANCLOSE_FAIL:', clYellow, clRed);
        DScreen.AddChatBoardString('在战斗的时候你不能退出游戏.', clYellow, clRed);
      end;

    SM_TAKEON_OK:
      begin
        Myself.Feature := msg.Recog;
        Myself.FeatureChanged;
            // 2003/03/15 酒捞袍 牢亥配府 犬厘
        if WaitingUseItem.Index in [0..12] then      //8->12
          UseItems[WaitingUseItem.Index] := WaitingUseItem.Item;
        WaitingUseItem.Item.S.Name := '';
      end;
    SM_CREATEGROUPREQ:
      begin
        str := DecodeString(body);
//        DScreen.AddChatBoardString ('SM_CREATEGROUPREQ: SendUderID=> '+str, clYellow, clRed);
        if not BoMsgDlgTimeCheck then
        begin
          BoMsgDlgTimeCheck := True;
          FrmDlg.MsgDlgClickTime := GetTickCount + 30000;
          GroupTimeout :=  FrmDlg.MsgDlgClickTime;
          if mrYes = FrmDlg.DMessageDlg(str + '邀请您加入队伍，是否同意？', [mbYes, mbNo]) then
          begin
            FrmMain.SendClientMessage2(CM_CREATEGROUPREQ_OK, 0, 0, 0, 0, str);
//        DScreen.AddChatBoardString ('CM_CREATEGROUPREQ_OK', clYellow, clRed);
          end
          else
          begin
            if GetTickCount > GroupTimeout then
              FrmMain.SendClientMessage2(CM_CREATEGROUPREQ_TIMEOUT, 0, 0, 0, 0, str)
            else
              FrmMain.SendClientMessage2(CM_CREATEGROUPREQ_FAIL, 0, 0, 0, 0, str);
//        DScreen.AddChatBoardString ('CM_CREATEGROUPREQ_FAIL', clYellow, clRed);
          end;
          BoMsgDlgTimeCheck := False;
          FrmDlg.MsgDlgClickTime := GetTickCount;
          GroupTimeout :=  GetTickCount;
        end;
      end;

    SM_ADDGROUPMEMBERREQ:
      begin
        str := DecodeString(body);
//        DScreen.AddChatBoardString ('SM_ADDGROUPMEMBERREQ: SendUderID=> '+str, clYellow, clRed);
        if not BoMsgDlgTimeCheck then
        begin
          BoMsgDlgTimeCheck := True;
          FrmDlg.MsgDlgClickTime := GetTickCount + 30000;
          GroupTimeout :=  FrmDlg.MsgDlgClickTime;
          if mrYes = FrmDlg.DMessageDlg(str + '邀请你加入他的队伍，是否同意？', [mbYes, mbNo]) then
          begin
            FrmMain.SendClientMessage2(CM_ADDGROUPMEMBERREQ_OK, 0, 0, 0, 0, str);
//        DScreen.AddChatBoardString ('CM_ADDGROUPMEMBERREQ_OK', clYellow, clRed);
          end
          else
          begin
            if GetTickCount > GroupTimeout then
              FrmMain.SendClientMessage2(CM_ADDGROUPMEMBERREQ_TIMEOUT, 0, 0, 0, 0, str)
            else
              FrmMain.SendClientMessage2(CM_ADDGROUPMEMBERREQ_FAIL, 0, 0, 0, 0, str);
//        DScreen.AddChatBoardString ('CM_ADDGROUPMEMBERREQ_FAIL', clYellow, clRed);
          end;
          BoMsgDlgTimeCheck := False;
          FrmDlg.MsgDlgClickTime := GetTickCount;
          GroupTimeout :=  GetTickCount;
        end;
      end;

    SM_LM_DELETE_REQ:
      begin
        str := DecodeString(body);
//        DScreen.AddChatBoardString ('SM_LM_DELETE_REQ: SendUderID=> '+str, clYellow, clRed);
        if not BoMsgDlgTimeCheck then
        begin
          BoMsgDlgTimeCheck := True;
          FrmDlg.MsgDlgClickTime := GetTickCount + 30000;
          if mrYes = FrmDlg.DMessageDlg(str + '确定解除恋人关系？\一旦确定须要缴纳150,0000万金币手续费用，继续？', [mbYes, mbNo]) then
          begin
            FrmMain.SendClientMessage2(CM_LM_DELETE_REQ_OK, RsState_Lover, 0, 0, 0, str);
//        DScreen.AddChatBoardString ('CM_LM_DELETE_REQ_OK', clYellow, clRed);
          end
          else
          begin
            FrmMain.SendClientMessage2(CM_LM_DELETE_REQ_FAIL, RsState_Lover, 0, 0, 0, str);
//        DScreen.AddChatBoardString ('CM_LM_DELETE_REQ_FAIL', clYellow, clRed);
          end;
          BoMsgDlgTimeCheck := False;
          FrmDlg.MsgDlgClickTime := GetTickCount;
        end;
      end;

    SM_TAKEON_FAIL:
      begin
        AddItemBag(WaitingUseItem.Item);
        WaitingUseItem.Item.S.Name := '';
      end;
    SM_TAKEOFF_OK:
      begin
        Myself.Feature := msg.Recog;
        Myself.FeatureChanged;
        WaitingUseItem.Item.S.Name := '';
      end;
    SM_TAKEOFF_FAIL:
      begin
        if WaitingUseItem.Index < 0 then
        begin
          n := -(WaitingUseItem.Index + 1);
          UseItems[n] := WaitingUseItem.Item;
        end;
        WaitingUseItem.Item.S.Name := '';
      end;
    SM_EXCHGTAKEON_OK:
      ;
    SM_EXCHGTAKEON_FAIL:
      ;

    SM_SENDUSEITEMS:
      begin
        ClientGetSenduseItems(body);
      end;
    SM_WEIGHTCHANGED:
      begin
        if (msg.Recog + msg.Param + msg.Tag) = (((msg.Series xor $aa21) xor $1F35) xor $3A5F) then
        begin
          Myself.Abil.Weight := msg.Recog;
          Myself.Abil.WearWeight := msg.Param;
          Myself.Abil.HandWeight := msg.Tag;
        end
        else
        begin
          Myself.Abil.Weight := 127;
          Myself.Abil.WearWeight := 127;
          Myself.Abil.HandWeight := 127;
        end;
        ChangeWalkHitValues(Myself.Abil.Level, Myself.HitSpeed, Myself.Abil.Weight + Myself.Abil.MaxWeight + Myself.Abil.WearWeight + Myself.Abil.MaxWearWeight + Myself.Abil.HandWeight + Myself.Abil.MaxHandWeight, RUN_STRUCK_DELAY);
      end;
    SM_GOLDCHANGED:
      begin
        SoundUtil.PlaySound(s_money);
        if msg.Recog > Myself.Gold then
        begin
          DScreen.AddSysMsg(IntToStr(msg.Recog - Myself.Gold) + '金币增加.');
        end;
        Myself.Gold := msg.Recog;
      end;
    SM_POTCASHCHANGED:
      begin
        Myself.PlayCash := msg.Recog;
      end;
    SM_FEATURECHANGED:
      begin
        PlayScene.SendMsg(msg.Ident, msg.Recog, 0, 0, 0, MakeLong(msg.Param, msg.Tag), 0, 0, '');
      end;
    SM_CHARSTATUSCHANGED:
      begin
        PlayScene.SendMsg(msg.Ident, msg.Recog, 0, 0, 0, MakeLong(msg.Param, msg.Tag), msg.Series, 0, '');
      end;
    SM_CLEAROBJECTS:
      begin
            //PlayScene.CleanObjects;
        MapMoving := TRUE; //甘 捞悼吝
      end;

    SM_EAT_OK:
      begin
//      DScreen.AddChatBoardString ('SM_EAT_OK: EatingItem.S.Name=> '+ EatingItem.S.Name, clYellow, clRed);
        if EatingItem.S.StdMode <> 7 then
          EatingItem.S.Name := ''; // 畴馋捞 酒聪搁
        if (EatingItem.S.StdMode = 7) and (EatingItem.Dura = 1) then
        begin
          EatingItem.S.Name := '';
        end;
        if (MovingItem.Item.S.StdMode = 7) and (MovingItem.Item.Dura = 1) then
        begin
          MovingItem.Item.S.Name := '';
          ItemMoving := FALSE;
//               FrmDlg.CancelItemMoving;
        end;
        ArrangeItembag;
//骇飘酒捞袍 家厚矫 磊悼栏肺 盲快扁 2006/03/22-------------------------
        if StBeltAutoFill then
        begin
          if ItemArr[BtInDex].S.Name = '' then
          begin
            i := GetSameItemFromBag(EatingItem);
//      DScreen.AddChatBoardString ('i := GetSameItemFromBag(EatingItem)    i=> '+IntToStr(i), clYellow, clRed);
            if i <> -100 then
            begin
//      DScreen.AddChatBoardString ('ItemArr[i].S.Name=> '+ ItemArr[i].S.Name  +'     '+IntToStr(i), clYellow, clRed);
              if ItemArr[i].S.Name <> '' then
              begin
                ItemArr[BtInDex] := ItemArr[i];
                ItemArr[i].S.Name := '';
              end;
            end;
          end;
          StBeltAutoFill := False;
        end;
//---------------------------------------------------------------------
      end;
    SM_EAT_FAIL:
      begin
//      DScreen.AddChatBoardString ('SM_EAT_FAIL: EatingItem.S.Name=> '+ EatingItem.S.Name, clYellow, clRed);
        StBeltAutoFill := False;
        if EatingItem.S.StdMode <> 7 then
          AddItemBag(EatingItem); // 畴馋捞 酒聪搁
        EatingItem.S.Name := '';
      end;

    SM_ADDMAGIC:
      begin
        if body <> '' then
          ClientGetAddMagic(body);
      end;
    SM_SENDMYMAGIC:
      begin
        if body <> '' then
          ClientGetMyMagics(msg.Recog, body);
      end;
    SM_DELMAGIC:
      begin
        ClientGetDelMagic(msg.Recog);
      end;
    SM_MAGIC_LVEXP:
      begin
        ClientGetMagicLvExp(msg.Recog{magid}, msg.Param{lv}, MakeLong(msg.Tag, msg.Series));
      end;
    SM_SOUND:
      begin
        ClientGetSound(msg.Param);
      end;
    SM_DURACHANGE:
      begin
        ClientGetDuraChange(msg.Param{useitem index}, msg.Recog, MakeLong(msg.Tag, msg.Series));
      end;

    SM_MERCHANTSAY:
      begin
        ClientGetMerchantSay(msg.Recog, msg.Param, DecodeString(body));
      end;
    SM_MERCHANTDLGCLOSE:
      begin
//      DScreen.AddChatBoardString ('SM_MERCHANTDLGCLOSE: msg.Param=> '+IntToStr(msg.Param), clYellow, clRed);
//            FrmDlg.CloseMDlg();
        if msg.Param = 0 then
          FrmDlg.CloseMDlg()
        else
          FrmDlg.CloseMDlg2(); //@@@@
      end;
    SM_SENDGOODSLIST:
      begin
        ClientGetSendGoodsList(msg.Recog, msg.Param, body);
      end;
    SM_DECOITEM_LIST:
      begin
//      DScreen.AddChatBoardString ('SM_DECOITEM_LIST: msg.Recog=> '+IntToStr(msg.Recog), clYellow, clRed);
//      DScreen.AddChatBoardString ('SM_DECOITEM_LIST: msg.Param=> '+IntToStr(msg.Param), clYellow, clRed);
        ClientGetDecorationList(msg.Recog, msg.Param, body);
      end;
    SM_DECOITEM_LISTSHOW: //2004/08/05 厘盔操固扁
      begin
//      DScreen.AddChatBoardString ('SM_DECOITEM_LISTSHOW: msg.Recog=> '+IntToStr(msg.Recog), clYellow, clRed);
//      DScreen.AddChatBoardString ('SM_DECOITEM_LISTSHOW: msg.Param=> '+IntToStr(msg.Param), clYellow, clRed);
        CurMerchant := msg.Recog;
        FrmDlg.ShowGADecorateDlg;
      end;
    SM_SENDUSERMAKEDRUGITEMLIST:
      begin
        ClientGetSendMakeDrugList(msg.Recog, body);
      end;
    SM_SENDUSERMAKEITEMLIST:
      begin
        ClientGetSendMakeItemList(msg.Recog, body);
      end;
    SM_SENDUSERSELL:
      begin
        ClientGetSendUserSell(msg.Recog);
      end;
    SM_SENDUSERREPAIR:
      begin
        ClientGetSendUserRepair(msg.Recog);
      end;
    SM_SENDBUYPRICE:
      begin
        if SellDlgItem.S.Name <> '' then
        begin
          if msg.Recog > 0 then
          begin
            if SellDlgItem.S.OverlapItem > 0 then
              SellPriceStr := IntToStr(msg.Recog * SellDlgItem.Dura) + '金币'
            else
              SellPriceStr := IntToStr(msg.Recog) + '金币';
          end
          else
            SellPriceStr := '????金币';
        end;
      end;
    SM_USERSELLITEM_OK:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        Myself.Gold := msg.Recog;
        SellDlgItemSellWait.S.Name := '';
      end;

    SM_USERSELLITEM_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        AddItemBag(SellDlgItemSellWait);
        SellDlgItemSellWait.S.Name := '';
        FrmDlg.DMessageDlg('你不能卖这个物品', [mbOk]);
      end;

    SM_USERSELLCOUNTITEM_OK:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        Myself.Gold := msg.Recog;
        SellItemProg(msg.Param, msg.Tag);
        SellDlgItemSellWait.S.Name := '';
      end;

    SM_USERSELLCOUNTITEM_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        AddItemBag(SellDlgItemSellWait);
        SellDlgItemSellWait.S.Name := '';
        FrmDlg.DMessageDlg('你不能卖这个物品', [mbOk]);
      end;
    SM_SENDREPAIRCOST:
      begin
        if SellDlgItem.S.Name <> '' then
        begin
          if msg.Recog >= 0 then
            SellPriceStr := IntToStr(msg.Recog) + '金币'
          else
            SellPriceStr := '????金币';
        end;
      end;
    SM_USERREPAIRITEM_OK:
      begin
        if SellDlgItemSellWait.S.Name <> '' then
        begin
          FrmDlg.LastestClickTime := GetTickCount;
          Myself.Gold := msg.Recog;
          SellDlgItemSellWait.Dura := msg.Param;
          SellDlgItemSellWait.DuraMax := msg.Tag;
          AddItemBag(SellDlgItemSellWait);
          SellDlgItemSellWait.S.Name := '';
        end;
      end;
    SM_USERREPAIRITEM_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        AddItemBag(SellDlgItemSellWait);
        SellDlgItemSellWait.S.Name := '';
        FrmDlg.DMessageDlg('你不能修理这个物品', [mbOk]);
      end;
    SM_STORAGE_OK, SM_STORAGE_FULL, SM_STORAGE_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        if msg.Ident <> SM_STORAGE_OK then
        begin
          if msg.Ident = SM_STORAGE_FULL then
            FrmDlg.DMessageDlg('你的个人包袱已经满了，你不能再寄存任何东西了', [mbOk])
          else
            FrmDlg.DMessageDlg('你不能寄存', [mbOk]);
          AddItemBag(SellDlgItemSellWait);
        end;
        SellDlgItemSellWait.S.Name := '';
      end;
    SM_SAVEITEMLIST:
      begin
        ClientGetSaveItemList(msg.Recog, msg.tag, msg.series, body);
      end;
    SM_TAKEBACKSTORAGEITEM_OK, SM_TAKEBACKSTORAGEITEM_FAIL, SM_TAKEBACKSTORAGEITEM_FULLBAG:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        if msg.Ident <> SM_TAKEBACKSTORAGEITEM_OK then
        begin
          if msg.Ident = SM_TAKEBACKSTORAGEITEM_FULLBAG then
            FrmDlg.DMessageDlg('你不能再携带更多东西了', [mbOk])
          else
            FrmDlg.DMessageDlg('你不能取回', [mbOk]);
        end
        else
          FrmDlg.DelStorageItem(msg.Recog, msg.Param); //itemserverindex
      end;

    SM_BUYITEM_SUCCESS:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        Myself.Gold := msg.Recog;
        FrmDlg.SoldOutGoods(MakeLong(msg.Param, msg.Tag)); //迫赴 酒捞袍 皋春俊辑 画
      end;
    SM_BUYITEM_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        case msg.Recog of
          1:
            FrmDlg.DMessageDlg('物品被卖出', [mbOk]);
          2:
            FrmDlg.DMessageDlg('没有更多物品可以携带了', [mbOk]);
          3:
            FrmDlg.DMessageDlg('你没有足够的钱来购买物品', [mbOk]);
        end;
      end;
    SM_MAKEDRUG_SUCCESS:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        Myself.Gold := msg.Recog;
        FrmDlg.DMessageDlg('物品已被正确打造', [mbOk]);
      end;
    SM_MAKEDRUG_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        case msg.Recog of
          1:
            FrmDlg.DMessageDlg('发生了错误', [mbOk]);
          2:
            FrmDlg.DMessageDlg('没有更多的项目可以进行', [mbOk]);
          3:
            FrmDlg.DMessageDlg('钱是不够的', [mbOk]);
          4:
            FrmDlg.DMessageDlg('你缺乏所必需的物品', [mbOk]);
          5:
            FrmDlg.DMessageDlg('失败，使宝石。', [mbOk]);
          6:
            FrmDlg.DMessageDlg('该矿石具有纯度低度', [mbOk]);
        end;
      end;

    SM_SENDDETAILGOODSLIST:
      begin
        ClientGetSendDetailGoodsList(msg.Recog, msg.Param, msg.Tag, body);
      end;

    SM_TEST:
      begin
        Inc(TestReceiveCount);
      end;

    SM_SENDNOTICE:
      begin
        ClientGetSendNotice(body);
      end;

    SM_GROUPMODECHANGED: //辑滚俊辑 唱狼 弊缝 汲沥捞 函版登菌澜.
      begin
        if msg.Param > 0 then
          AllowGroup := TRUE
        else
          AllowGroup := FALSE;
        changegroupmodetime := GetTickCount;
      end;
    SM_CREATEGROUP_OK:
      begin
        changegroupmodetime := GetTickCount;
        AllowGroup := TRUE;
            // 2003/03/04 弊缝阑 肝绰 版快 磊扁 磊脚狼 HP甫 焊咯淋
       // MySelf.BoOpenHealth := TRUE;   //组队显示自己血条
            {GroupMembers.Add (Myself.UserName);
            GroupMembers.Add (DecodeString(body));}
      end;
    SM_CREATEGROUP_FAIL:
      begin
        changegroupmodetime := GetTickCount;
        case msg.Recog of
          -1:
            FrmDlg.DMessageDlg('已经加入编组.', [mbOk]);
          -2:
            FrmDlg.DMessageDlg('这个被加进编组的名字是不正确的', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('你想邀请加入编组的这个用户已经是其他组的成员了', [mbOk]);
          -4:
            FrmDlg.DMessageDlg('对方不允许编组', [mbOk]);
          -5:
            FrmDlg.DMessageDlg('对方正在考虑是否加入队伍', [mbOk]);
        end;
      end;
    SM_GROUPADDMEM_OK:
      begin
        changegroupmodetime := GetTickCount;
            //GroupMembers.Add (DecodeString(body));
      end;
    SM_GROUPADDMEM_FAIL:
      begin
        changegroupmodetime := GetTickCount;
        case msg.Recog of
          -1:
            FrmDlg.DMessageDlg('编组还未成立或者你还不够等级创建', [mbOk]);
          -2:
            FrmDlg.DMessageDlg('这个被加进编组的名字是不正确的', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('已经加入编组', [mbOk]);
          -4:
            FrmDlg.DMessageDlg('对方不允许编组', [mbOk]);
          -5:
            FrmDlg.DMessageDlg('成员上限已经达到', [mbOk]);
        end;
      end;
    SM_GROUPDELMEM_OK:
      begin
        changegroupmodetime := GetTickCount;
            {data := DecodeString (body);
            for i:=0 to GroupMembers.Count-1 do begin
               if GroupMembers[i] = data then begin
                  GroupMembers.Delete (i);
                  break;
               end;
            end; }
      end;
    SM_GROUPDELMEM_FAIL:
      begin
        changegroupmodetime := GetTickCount;
        case msg.Recog of
          -1:
            FrmDlg.DMessageDlg('编组还未成立或者你还不够等级创建', [mbOk]);
          -2:
            FrmDlg.DMessageDlg('这个被加进编组的名字是不正确的', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('你仍旧不在编组中', [mbOk]);
        end;
      end;
    SM_GROUPCANCEL:
      begin
            // 2003/03/04 弊缝捞 秦力登绰 版快 HP免仿窍瘤 臼澜
         // MySelf.BoOpenHealth := FALSE;   //退出队伍取消血条
        GroupMembers.Clear;
        try
//          for i := 0 to GroupIdList.Count - 1 do
//          begin
//            actor := PlayScene.FindActor(integer(GroupIdList[i]));
//            if actor <> nil then
//              actor.BoOpenHealth := False;
//          end;
          GroupIdList.Clear;  // MonOpenHp
        except
        end;
      end;
    SM_GROUPMEMBERS:
      begin
            // 2003/03/04 弊缝捞 秦力登绰 版快 HP免仿窍瘤 臼澜
       // MySelf.BoOpenHealth := TRUE;   //   组队刷新成员，然后显示自己血条
        ClientGetGroupMembers(DecodeString(body));
      end;

    SM_OPENGUILDDLG:
      begin
        querymsgtime := GetTickCount;
        ClientGetOpenGuildDlg(body);
      end;

    SM_SENDGUILDMEMBERLIST:
      begin
        querymsgtime := GetTickCount;
        ClientGetSendGuildMemberList(body);
      end;

    SM_OPENGUILDDLG_FAIL:
      begin
        querymsgtime := GetTickCount;
        FrmDlg.DMessageDlg('你仍旧没有加入行会', [mbOk]);
      end;

    SM_DEALTRY_FAIL:
      begin
        querymsgtime := GetTickCount;
        FrmDlg.DMessageDlg('交易被取消\要正确交易你必须和对方面对面', [mbOk]);
      end;
    SM_DEALMENU:
      begin
        querymsgtime := GetTickCount;
        DealWho := DecodeString(body);
        FrmDlg.OpenDealDlg(1);
      end;
    SM_GUILDAGITDEALMENU:
      begin
        querymsgtime := GetTickCount;
        DealWho := DecodeString(body);
        FrmDlg.OpenDealDlg(2);
      end;
    SM_DEALCANCEL:
      begin
        FrmDlg.CancelItemMoving;
        MoveDealItemToBag;

        if DealGold > 0 then
        begin
          Myself.Gold := Myself.GOld + DealGold;
          DealGold := 0;
        end;
        FrmDlg.CloseDealDlg;

//            if DealDlgItem.S.OverlapItem > 0 then FrmDlg.CancelItemMoving;
        FrmDlg.CancelItemMoving;
        if FrmDlg.DCountDlgCancel.Visible then
        begin
          FrmDlg.DCountDlg.DialogResult := mrCancel;
          FrmDlg.DCountDlg.Visible := FALSE;
        end;
      end;

    SM_DEALADDITEM_OK:
      begin
        dealactiontime := GetTickCount;
        if DealDlgItem.S.Name <> '' then
        begin
          ResultDealItem(DealDlgItem, msg.Recog, msg.Param);  //Deal Dlg俊 眠啊
          DealDlgItem.S.Name := '';
        end;
      end;
    SM_DEALADDITEM_FAIL:
      begin
        dealactiontime := GetTickCount;
        if DealDlgItem.S.Name <> '' then
        begin
          AddItemBag(DealDlgItem);  //啊规俊 眠啊
          DealDlgItem.S.Name := '';
        end;
      end;
    SM_DEALDELITEM_OK:
      begin
        dealactiontime := GetTickCount;
        if DealDlgItem.S.Name <> '' then
        begin
               //AddItemBag (DealDlgItem);  //啊规俊 眠啊
          DealDlgItem.S.Name := '';
        end;
      end;
    SM_DEALDELITEM_FAIL:
      begin
        dealactiontime := GetTickCount;
        if DealDlgItem.S.Name <> '' then
        begin
          DelCountItemBag(DealDlgItem.S.Name, DealDlgItem.MakeIndex, DealDlgItem.Dura);
          AddDealItem(DealDlgItem);
          if (MovingItem.Item.MakeIndex = DealDlgItem.MakeIndex) and (MovingItem.Item.S.Name = DealDlgItem.S.Name) then
          begin
            ItemMoving := FALSE;
            MovingItem.Item.S.Name := '';
          end;
          DealDlgItem.S.Name := '';
        end;
        FrmDlg.CancelItemMoving;
      end;
    SM_DEALREMOTEADDITEM:
      begin
        ClientGetDealRemoteAddItem(body);
        SoundUtil.PlaySound(s_deal_additem);
      end;
    SM_DEALREMOTEDELITEM:
      begin
        ClientGetDealRemoteDelItem(body);
        SoundUtil.PlaySound(s_deal_delitem);
      end;

    SM_DEALCHGGOLD_OK:
      begin
        DealGold := msg.Recog;
        Myself.Gold := MakeLong(msg.param, msg.tag);
        dealactiontime := GetTickCount;
      end;
    SM_DEALCHGGOLD_FAIL:
      begin
        DealGold := msg.Recog;
        Myself.Gold := MakeLong(msg.param, msg.tag);
        dealactiontime := GetTickCount;
      end;
    SM_DEALREMOTECHGGOLD:
      begin
        DealRemoteGold := msg.Recog;
        SoundUtil.PlaySound(s_money);  //惑措规捞 捣阑 函版茄 版快 家府啊 抄促.
      end;
    SM_DEALSUCCESS:
      begin
        FrmDlg.CloseDealDlg;
      end;

    SM_SENDUSERSTORAGEITEM:  //焊包窍绰 芒阑 剁框.
      begin
        ClientGetSendUserStorage(msg.Recog);
      end;
    //改变攻击模式
    SM_ATTACKMODE:
      begin
         ClientGetAttackMode( msg.Param );
      end;
    SM_READMINIMAP_OK:
      begin
        querymsgtime := GetTickCount;
        ClientGetReadMiniMap(msg.Param);
      end;

    SM_READMINIMAP_FAIL:
      begin
        querymsgtime := GetTickCount;
        DScreen.AddChatBoardString('没有可用的地图', clWhite, clRed);
        BoDrawMiniMap := False;
      end;

    SM_CHANGEGUILDNAME:
      begin
        ClientGetChangeGuildName(DecodeString(body));
      end;

    SM_SENDUSERSTATE:
      begin
        ClientGetSendUserState(body);
      end;

    SM_GUILDADDMEMBER_OK:
      begin
        SendGuildMemberList;
      end;
    SM_GUILDADDMEMBER_FAIL:
      begin
        case msg.Recog of
          1:
            FrmDlg.DMessageDlg('你没有权利使用这个命令', [mbOk]);
          2:
            FrmDlg.DMessageDlg('想加入进来的成员应该来面对掌门人', [mbOk]);
          3:
            FrmDlg.DMessageDlg('对方已经加入我们的行会', [mbOk]);
          4:
            FrmDlg.DMessageDlg('对方已经加入其他行会', [mbOk]);
          5:
            FrmDlg.DMessageDlg('对方不允许加入行会', [mbOk]);
        end;
      end;
    SM_GUILDDELMEMBER_OK:
      begin
        SendGuildMemberList;
      end;
    SM_GUILDDELMEMBER_FAIL:
      begin
        case msg.Recog of
          1:
            FrmDlg.DMessageDlg('你没有权利使用这个命令', [mbOk]);
          2:
            FrmDlg.DMessageDlg('此人非本行会成员', [mbOk]);
          3:
            FrmDlg.DMessageDlg('行会掌门人不能开除自己', [mbOk]);
          4:
            FrmDlg.DMessageDlg('不能使用命令', [mbOk]);
        end;
      end;

    SM_GUILDRANKUPDATE_FAIL:
      begin
        case msg.Recog of
          -2:
            FrmDlg.DMessageDlg('掌门人位置不能为空', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('新的行会掌门人已经被传位', [mbOk]);
          -4:
            FrmDlg.DMessageDlg('一个行会最多只能有二个掌门人', [mbOk]);
          -5:
            FrmDlg.DMessageDlg('掌门人位置不能为空', [mbOk]);
          -6:
            FrmDlg.DMessageDlg('不能添加成员/删除成员', [mbOk]);
          -7:
            FrmDlg.DMessageDlg('职位重复或者出错', [mbOk]);
        end;
      end;

    SM_GUILDMAKEALLY_OK, SM_GUILDMAKEALLY_FAIL:
      begin
        case msg.Recog of
          -1:
            FrmDlg.DMessageDlg('你没有权利', [mbOk]);
          -2:
            FrmDlg.DMessageDlg('联盟失败', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('你应该面对你想要结盟的行会掌门人', [mbOk]);
          -4:
            FrmDlg.DMessageDlg('对方行会掌门人不允许结盟', [mbOk]);
        end;
      end;
    SM_GUILDBREAKALLY_OK, SM_GUILDBREAKALLY_FAIL:
      begin
        case msg.Recog of
          -1:
            FrmDlg.DMessageDlg('解除结盟', [mbOk]);
          -2:
            FrmDlg.DMessageDlg('此行会不是您行会的结盟行会', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('没有此行会', [mbOk]);
        end;
      end;

    SM_BUILDGUILD_OK:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        FrmDlg.DMessageDlg('行会建立成功', [mbOk]);
      end;

    SM_BUILDGUILD_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        case msg.Recog of
          -1:
            FrmDlg.DMessageDlg('已经加入行会', [mbOk]);
          -2:
            FrmDlg.DMessageDlg('缺少创建费用', [mbOk]);
          -3:
            FrmDlg.DMessageDlg('你没有准备好需要的全部物品', [mbOk]);
        end;
      end;
    SM_MENU_OK:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
        if body <> '' then
          FrmDlg.DMessageDlg(DecodeString(body), [mbOk]);
      end;
    SM_DLGMSG:
      begin
        if body <> '' then
          FrmDlg.DMessageDlg(DecodeString(body), [mbOk]);
      end;

      // 2003/04/15 模备, 率瘤
      SM_USER_INFO:
      begin
        if body <> '' then
          ClientGetUserInfo(msg, body);
      end;

    SM_FRIEND_INFO:
      begin
        if body <> '' then
          ClientGetFriendInfo(msg, body);
      end;
    SM_FRIEND_DELETE:
      begin
        if body <> '' then
          ClientGetDelFriend(msg, body);
      end;
    SM_FRIEND_RESULT:
      begin
        if body <> '' then
          ClientGetFriendResult(msg, body);
      end;
      // 2003/04/15 模备, 率瘤
    SM_TAG_ALARM: // 脚痹 皋技瘤 档馒
      begin
            // if body <> '' then ClientGetTagAlarm (msg ,body);
        ClientGetTagAlarm(msg, body);
      end;
    SM_TAG_LIST:  // 率瘤 府胶飘
      begin
        if body <> '' then
          ClientGetTagList(msg, body);
      end;
    SM_TAG_INFO:  // 率瘤 沥焊
      begin
        if body <> '' then
          ClientGetTagInfo(msg, body);
      end;
    SM_TAG_REJECT_LIST:   // 芭何磊 府胶飘
      begin
        if body <> '' then
          ClientGetTagRejectList(msg, body);
      end;
    SM_TAG_REJECT_ADD:    // 芭何磊 殿废
      begin
        if body <> '' then
          ClientGetTagRejectAdd(msg, body);
      end;
    SM_TAG_REJECT_DELETE: // 芭何磊 昏力
      begin
        if body <> '' then
          ClientGetTagRejectDelete(msg, body);
      end;
    SM_TAG_RESULT:        // 率瘤 搬苞
      begin
        if body <> '' then
          ClientGetTagResult(msg, body);
      end;
    SM_LM_OPTION:       // 楷牢荤力 可记函版
      begin
        ClientGetLMOptionChange(msg);
      end;
    SM_LM_REQUEST:      // 楷牢荤力 殿废夸备
      begin
        ClientGetLMRequest(msg, body);
      end;
    SM_LM_LIST:       // 楷牢荤力 府胶飘
      begin
        ClientGetLMList(msg, body);
      end;
    SM_LM_RESULT:      // 楷牢荤力 搬苞
      begin
        ClientGetLMREsult(msg, body);
      end;
    SM_LM_DELETE:     // 楷牢 荤力 昏力
      begin
        ClientGetLMDelete(msg, body);
      end;

    SM_MARKET_LIST:  //困殴魄概 府胶飘
      begin
        g_Market.OnMsgWriteData(msg, body);
        FrmDlg.ShowItemMarketDlg; // 困殴魄概 ItemMarket
      end;
    SM_MARKET_RESULT: // 困殴魄概 搬苞
      begin
//            DScreen.AddSysMsg ('SM_MARKET_RESULT R:'+ intToStr(msg.Recog));
//            DScreen.AddSysMsg ('SM_MARKET_RESULT P:'+ intToStr(msg.param));
//            DScreen.AddSysMsg ('SM_MARKET_RESULT T:'+ intToStr(msg.Tag));

        case msg.Param of // Market System..
          UMResult_Success:
            ;    // 0   ;     // 成功
          UMResult_Fail:
            ;    // 1   ;     // 失败
          UMResult_ReadFail:
            ;    // 2   ;     // 读取失败
          UMResult_WriteFail:
            ;    // 3   ;     // 保存失败
          UMResult_ReadyToSell:      // 4   ;     // 销售可能
            begin
              ClientGetSendUserMaketSell(msg.Recog);
            end;
          UMResult_OverSellCount:   // 5   ;     // 销售项囊路量超过
            FrmDlg.DMessageDlg('上架物品数量超限.', [mbOk]);
          UMResult_LessMoney:       // 6   ;     // 金币不足
            begin
              FrmDlg.LastestClickTime := GetTickCount;
              if SellDlgItemSellWait.S.Name <> '' then
              begin
                AddItemBag(SellDlgItemSellWait);
              end;
              SellDlgItemSellWait.S.Name := '';
            end;
          UMResult_LessLevel:
            ;    // 7   ;     // 级别不够
          UMResult_MaxBagItemCount:
            ; // 8   ;     // 包裹已满
          UMResult_NoItem:
            ;    // 9   ;     // 这个项目
          UMResult_DontSell:         // 10  ;     // 销售不可
            begin
              FrmDlg.LastestClickTime := GetTickCount;
              AddItemBag(SellDlgItemSellWait);
              SellDlgItemSellWait.S.Name := '';
              FrmDlg.DMessageDlg('这个物品不能上架。', [mbOk]);
            end;
          UMResult_DontBuy:
            ; // 11  ;     // 购买不可
          UMResult_DontGetMoney:
            ; // 12  ;     // 价格最大值
          UMResult_MarketNotReady:
            ; // 13  ;     // 委托系统本身不可用
          UMResult_LessTrustMoney:   // 14  ;     // 委托金额不足1000 前相比已大
            begin
              FrmDlg.LastestClickTime := GetTickCount;
              if SellDlgItemSellWait.S.Name <> '' then
              begin
                AddItemBag(SellDlgItemSellWait);
              end;
              SellDlgItemSellWait.S.Name := '';
            end;

          UMResult_MaxTrustMoney:
            ; // 15  ;     // 委托金额太大
          UMResult_CancelFail:
            ; // 16  ;     // 委托取消失败
          UMResult_OverMoney:
            ; // 17  ;     // 所有金额超过最大值的语感
          UMResult_SellOK:           // 18  ;     // 销售就好了
            begin
//      DScreen.AddChatBoardString ('UMResult_SellOK:', clYellow, clRed);
              FrmDlg.DSellDlg.Visible := FALSE;
              FrmDlg.LastestClickTime := GetTickCount;
//                     Myself.Gold := msg.Recog;
//                     SellItemProg ( msg.Param, msg.Tag );
              SellDlgItemSellWait.S.Name := '';
              DScreen.AddChatBoardString(SellDlgItemSellWait.S.Name + ' 上架成功', clLime, clBlack);
            end;
          UMResult_BuyOK:
            ; // 19  ;     // 购得非常完美
          UMResult_CancelOK:
            ; // 20  ;     // 取消销售很好
          UMResult_GetPayOK:
            ; // 21  ;     // 销售金额就好了
        else


        end;
      end;

    SM_GUILDAGITLIST:
      begin
        ClientGetJangwonList(msg.Recog, msg.Param, body);
      end;
    SM_GABOARD_LIST: //厘盔 霸矫魄
      begin
        ClientGetGABoardList(msg.Param, msg.Recog, msg.Tag, body);
      end;
    SM_GABOARD_READ: //厘盔 霸矫魄
      begin
        ClientGetGABoardRead(body);
      end;
    SM_GABOARD_NOTICE_OK:
      begin
        FrmDlg.SendGABoardNoticeOk;
      end;
    SM_GABOARD_NOTICE_FAIL:
      begin
        DScreen.AddChatBoardString('只有授权行会管理员才可以编辑', clWhite, clRed);
      end;

    SM_DONATE_OK:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
      end;

    SM_DONATE_FAIL:
      begin
        FrmDlg.LastestClickTime := GetTickCount;
      end;

    SM_NEXTTIME_PASSWORD:
      begin
        if PlayScene.EdChat.PasswordChar = #0 then
          PlayScene.EdChat.PasswordChar := '*';
        BoOneTimePassword := TRUE;
      end;
         
//      SM_CHANGEATTATCKMODE:
//         begin  //改变攻击模式
//            g_sAttackMode := DecodeString (body);
//         end;

    SM_PLAYDICE:
      begin
        body2 := Copy(body, UpInt(sizeof(TMessageBodyWL) * 4 / 3) + 1, Length(body));
        DecodeBuffer(body, @wl, sizeof(TMessageBodyWL));
        str := DecodeString(body2);
        FrmDlg.RunDice := msg.Param;

        FrmDlg.DiceType := 1;
        FrmDlg.DiceArr[0].DiceResult := lobyte(loword(wl.lparam1));
        FrmDlg.DiceArr[1].DiceResult := hibyte(loword(wl.lparam1));
        FrmDlg.DiceArr[2].DiceResult := lobyte(hiword(wl.lparam1));
        FrmDlg.DiceArr[3].DiceResult := hibyte(hiword(wl.lparam1));
        FrmDlg.DiceArr[4].DiceResult := lobyte(loword(wl.lparam2));
        FrmDlg.DiceArr[5].DiceResult := hibyte(loword(wl.lparam2));
        FrmDlg.DiceArr[6].DiceResult := lobyte(hiword(wl.lparam2));
        FrmDlg.DiceArr[7].DiceResult := hibyte(hiword(wl.lparam2));
        FrmDlg.DiceArr[8].DiceResult := lobyte(loword(wl.lTag1));
        FrmDlg.DiceArr[9].DiceResult := hibyte(loword(wl.lTag1));
        FrmDlg.DialogSize := 0;

        FrmDlg.DMessageDlg('', []);

        FrmMain.SendMerchantDlgSelect(msg.Recog, str);
      end;

    SM_PLAYROCK:
      begin
        body2 := Copy(body, UpInt(sizeof(TMessageBodyWL) * 4 / 3) + 1, Length(body));
        DecodeBuffer(body, @wl, sizeof(TMessageBodyWL));
        str := DecodeString(body2);

        FrmDlg.RunDice := msg.Param;
        FrmDlg.DiceType := 2;
        FrmDlg.DiceArr[0].DiceResult := lobyte(loword(wl.lparam1));
//      DScreen.AddChatBoardString ('SM_PLAYDICE: DiceResult=> '+InttoStr(FrmDlg.DiceArr[0].DiceResult), clYellow, clRed);
//            FrmDlg.DiceArr[1].DiceResult := hibyte(loword(wl.lparam1));
        FrmDlg.DialogSize := 0;

        FrmDlg.DMessageDlg('', []);
        FrmMain.SendMerchantDlgSelect(msg.Recog, str);
      end;
    SM_SERVERUNBIND: ClientGetServerUnBind(Body); //解包消息

  else
    begin
      DScreen.AddSysMsg(IntToStr(msg.Ident) + ' : ' + body);
    end;

  end;

  if Pos('#', datablock) > 0 then
    DScreen.AddSysMsg(datablock);
end;

procedure TFrmMain.ClientGetPasswdSuccess(body: string);
var
  str, runaddr, runport, uid, certifystr: string;
begin
  str := DecodeString(body);
  str := GetValidStr3(str, runaddr, ['/']);
  str := GetValidStr3(str, runport, ['/']);
  str := GetValidStr3(str, certifystr, ['/']);
  Certification := Str_ToInt(certifystr, 0);

  if not BoOneClick then
  begin
    CSocket.Active := FALSE;  //肺弊牢俊 楷搬等 家南 摧澜
    FrmDlg.DSelServerDlg.Visible := FALSE;
    WaitAndPass(500); //0.5檬悼救 扁促覆
    ConnectionStep := cnsSelChr;

//    Application.MessageBox( PChar(runaddr+'/'+runport+'/'+certifystr), PChar('Check'), IDOK);
    with CSocket do
    begin
      SelChrAddr := runaddr;
      SelChrPort := Str_ToInt(runport, 0);
      Address := SelChrAddr;
      Port := SelChrPort;
      Active := TRUE;
    end;
//    Application.MessageBox( PChar('Activated'), PChar('Check'), IDOK);
  end
  else
  begin
    FrmDlg.DSelServerDlg.Visible := FALSE;
    SelChrAddr := runaddr;
    SelChrPort := Str_ToInt(runport, 0);

//    Application.MessageBox( PChar(runaddr+'/'+runport+'/'+certifystr), PChar('CheckOneClick'), IDOK);
    if CSocket.Socket.Connected then
      CSocket.Socket.SendText('$S' + runaddr + '/' + runport + '%');
    WaitAndPass(500); //0.5檬悼救 扁促覆
    ConnectionStep := cnsSelChr;
    LoginScene.OpenLoginDoor;
    SelChrWaitTimer.Enabled := TRUE;
//    Application.MessageBox( PChar('Activated'), PChar('CheckOneClick'), IDOK);
  end;
  FLoginIDLock := true;
end;

procedure TFrmMain.ClientGetSelectServer;
var
  sname: string;
begin
  LoginScene.HideLoginBox;
  FrmDlg.ShowSelectServerDlg;
end;

procedure TFrmMain.ClientGetNeedUpdateAccount(body: string);
var
  ue: TUserEntryInfo;
begin
  DecodeBuffer(body, @ue, sizeof(TUserEntryInfo));
  LoginScene.UpdateAccountInfos(ue);
end;

procedure TFrmMain.ClientGetReceiveChrs(body: string);
var
  i, select: integer;
  str, uname, sjob, shair, slevel, ssex: string;
begin
  SelectChrScene.ClearChrs;
  str := DecodeString(body);
  for i := 0 to 2 do
  begin
    str := GetValidStr3(str, uname, ['/']);
    str := GetValidStr3(str, sjob, ['/']);
    str := GetValidStr3(str, shair, ['/']);
    str := GetValidStr3(str, slevel, ['/']);
    str := GetValidStr3(str, ssex, ['/']);
    select := 0;
    if (uname <> '') and (slevel <> '') and (ssex <> '') then
    begin
      if uname[1] = '*' then
      begin
        select := i;
        uname := Copy(uname, 2, Length(uname) - 1);
      end;
      SelectChrScene.AddChr(uname, Str_ToInt(sjob, 0), Str_ToInt(shair, 0), Str_ToInt(slevel, 0), Str_ToInt(ssex, 0));
    end;
    with SelectChrScene do
    begin
      if select = 0 then
      begin
        ChrArr[0].FreezeState := FALSE;
        ChrArr[0].Selected := TRUE;
        ChrArr[1].FreezeState := TRUE;
        ChrArr[1].Selected := FALSE;
      end
      else if select = 1 then
      begin
        ChrArr[0].FreezeState := TRUE;
        ChrArr[0].Selected := FALSE;
        ChrArr[1].FreezeState := FALSE;
        ChrArr[1].Selected := TRUE;
      end
      else if select = 2 then
      begin
        ChrArr[0].FreezeState := TRUE;
        ChrArr[0].Selected := FALSE;
        ChrArr[1].FreezeState := TRUE;
        ChrArr[1].Selected := FALSE;
      end;

    end;
  end;
end;

procedure TFrmMain.ClientGetStartPlay(body: string);
var
  str, addr, sport: string;
begin
  str := DecodeString(body);
  sport := GetValidStr3(str, addr, ['/']);

  if not BoOneClick then
  begin
    CSocket.Active := FALSE;  //肺弊牢俊 楷搬等 家南 摧澜
    WaitAndPass(500); //0.5檬悼救 扁促覆

    ConnectionStep := cnsPlay;
    with CSocket do
    begin
      Address := addr;
      Port := Str_ToInt(sport, 0);
      Active := TRUE;
    end;
  end
  else
  begin
    SocStr := '';
    BufferStr := '';
    if CSocket.Socket.Connected then
      CSocket.Socket.SendText('$R' + addr + '/' + sport + '%');

    ConnectionStep := cnsPlay;
    ClearBag;  //啊规 檬扁拳
    DScreen.ClearChatBoard; //盲泼芒 檬扁拳
    DScreen.ChangeScene(stLoginNotice);

    WaitAndPass(500); //0.5檬悼救 扁促覆
    SendRunLogin;
  end;
end;

procedure TFrmMain.ClientGetReconnect(body: string);
var
  str, addr, sport: string;
begin
  str := DecodeString(body);
  sport := GetValidStr3(str, addr, ['/']);

  if not BoOneClick then
  begin
    if BoBagLoaded then
      Savebags('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemArr);

    BoBagLoaded := FALSE;

    BoServerChanging := TRUE;
    CSocket.Active := FALSE;  //肺弊牢俊 楷搬等 家南 摧澜

    WaitAndPass(500); //0.5檬悼救 扁促覆

    ConnectionStep := cnsPlay;
    with CSocket do
    begin
      Address := addr;
      Port := Str_ToInt(sport, 0);
      Active := TRUE;
    end;

  end
  else
  begin
    if BoBagLoaded then
      Savebags('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemArr);

    BoBagLoaded := FALSE;

    SocStr := '';
    BufferStr := '';
    BoServerChanging := TRUE;

    if CSocket.Socket.Connected then   //立加 辆丰 脚龋 焊辰促.
      CSocket.Socket.SendText('$C' + addr + '/' + sport + '%');

    WaitAndPass(500); //0.5檬悼救 扁促覆
    if CSocket.Socket.Connected then   //犁立..
      CSocket.Socket.SendText('$R' + addr + '/' + sport + '%');

    ConnectionStep := cnsPlay;
    ClearBag;  //啊规 檬扁拳
    DScreen.ClearChatBoard; //盲泼芒 檬扁拳
    DScreen.ChangeScene(stLoginNotice);

    WaitAndPass(300); //0.5檬悼救 扁促覆
    ChangeServerClearGameVariables;

    SendRunLogin;
  end;
end;

procedure TFrmMain.ClientGetMapDescription(body: string);
var
  data: string;
begin
  body := DecodeString(body);
  body := GetValidStr3(body, data, [#13]);
  MapTitle := data; //甘 捞抚....
end;

procedure TFrmMain.ClientGetAdjustBonus(bonus: integer; body: string);
var
  str1, str2, str3: string;
begin
  BonusPoint := bonus;
  body := GetValidStr3(body, str1, ['/']);
  str3 := GetValidStr3(body, str2, ['/']);
  DecodeBuffer(str1, @BonusTick, sizeof(TNakedAbility));
  DecodeBuffer(str2, @BonusAbil, sizeof(TNakedAbility));
  DecodeBuffer(str3, @NakedAbil, sizeof(TNakedAbility));
  FillChar(BonusAbilChg, sizeof(TNakedAbility), #0);
end;

procedure TFrmMain.ClientGetAddItem(body: string);
var
  cu: TClientItem;
begin
  if body <> '' then
  begin
    DecodeBuffer(body, @cu, sizeof(TClientItem));
    AddItemBag(cu);
    DScreen.AddSysMsg(cu.S.Name + ' 被发现.');
  end;
end;

procedure TFrmMain.ClientGetUpdateItem(body: string);
var
  i: integer;
  cu: TClientItem;
begin
  if body <> '' then
  begin
    DecodeBuffer(body, @cu, sizeof(TClientItem));
    UpdateItemBag(cu);
      // 2003/03/15 牢亥配府 犬厘
    for i := 0 to 12 do
    begin    // 8 -> 12
      if (UseItems[i].S.Name = cu.S.Name) and (UseItems[i].MakeIndex = cu.MakeIndex) then
      begin
        UseItems[i] := cu;
      end;
    end;
  end;
end;

procedure TFrmMain.ClientGetDelItem(body: string; flag: integer);
var
  i: integer;
  cu: TClientItem;
begin
  if body <> '' then
  begin
    if flag = 1 then
    begin
      DecodeBuffer(body, @DelTempItem, sizeof(TClientItem));
    end
    else
    begin
      DecodeBuffer(body, @cu, sizeof(TClientItem));
      DelItemBag(cu.S.Name, cu.MakeIndex);
         // 2003/03/15 牢亥配府 犬厘
      for i := 0 to 12 do
      begin   // 8 -> 12
        if (UseItems[i].S.Name = cu.S.Name) and (UseItems[i].MakeIndex = cu.MakeIndex) then
        begin
          UseItems[i].S.Name := '';
        end;
      end;
    end;
  end;
end;

procedure TFrmMain.ClientGetDelItems(body: string);
var
  i, iindex: integer;
  str, iname: string;
  cu: TClientItem;
begin
  body := DecodeString(body);
  while body <> '' do
  begin
    body := GetValidStr3(body, iname, ['/']);
    body := GetValidStr3(body, str, ['/']);
    if (iname <> '') and (str <> '') then
    begin
      iindex := Str_ToInt(str, 0);
      DelItemBag(iname, iindex);
         // 2003/03/15 牢亥配府 犬厘
      for i := 0 to 12 do
      begin   // 8->12
        if (UseItems[i].S.Name = iname) and (UseItems[i].MakeIndex = iindex) then
        begin
          UseItems[i].S.Name := '';
        end;
      end;
    end
    else
      break;
  end;
end;

procedure TFrmMain.ClientGetBagItmes(body: string);
var
  str: string;
  cu: TClientItem;
  ItemSaveArr: array[0..MAXBAGITEMCL - 1] of TClientItem;

  function CompareItemArr: Boolean;
  var
    i, j: integer;
    flag: Boolean;
  begin
    flag := TRUE;
    for i := 0 to MAXBAGITEMCL - 1 do
    begin
      if ItemSaveArr[i].S.Name <> '' then
      begin
        flag := FALSE;
        for j := 0 to MAXBAGITEMCL - 1 do
        begin
          if (ItemArr[j].S.Name = ItemSaveArr[i].S.Name) and (ItemArr[j].MakeIndex = ItemSaveArr[i].MakeIndex) then
          begin
            if (ItemArr[j].Dura = ItemSaveArr[i].Dura) and (ItemArr[j].DuraMax = ItemSaveArr[i].DuraMax) then
            begin
              flag := TRUE;
            end;
            break;
          end;
        end;
        if not flag then
          break;
      end;
    end;
    if flag then
    begin
      for i := 0 to MAXBAGITEMCL - 1 do
      begin
        if ItemArr[i].S.Name <> '' then
        begin
          flag := FALSE;
          for j := 0 to MAXBAGITEMCL - 1 do
          begin
            if (ItemArr[i].S.Name = ItemSaveArr[j].S.Name) and (ItemArr[i].MakeIndex = ItemSaveArr[j].MakeIndex) then
            begin
              if (ItemArr[i].Dura = ItemSaveArr[j].Dura) and (ItemArr[i].DuraMax = ItemSaveArr[j].DuraMax) then
              begin
                flag := TRUE;
              end;
              break;
            end;
          end;
          if not flag then
            break;
        end;
      end;
    end;
    Result := flag;
  end;

begin
   //ClearBag;
  FillChar(ItemArr, sizeof(TClientItem) * MAXBAGITEMCL, #0);
  while TRUE do
  begin
    if body = '' then
      break;
    body := GetValidStr3(body, str, ['/']);
    DecodeBuffer(str, @cu, sizeof(TClientItem));
    AddItemBag(cu);
  end;
  FillChar(ItemSaveArr, sizeof(TClientItem) * MAXBAGITEMCL, #0);
  Loadbags('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemSaveArr);
  if CompareItemArr then
  begin
    Move(ItemSaveArr, ItemArr, sizeof(TClientItem) * MAXBAGITEMCL);
  end;
  ArrangeItembag;
  BoBagLoaded := TRUE;
end;

procedure TFrmMain.ClientGetDropItemFail(iname: string; sindex: integer);
var
  pc: PTClientItem;
begin
  pc := GetDropItem(iname, sindex);
  if pc <> nil then
  begin
    AddItemBag(pc^);
    DelDropItem(iname, sindex);
  end;
end;

procedure TFrmMain.ClientGetShowItem(itemid, x, y, looks: integer; body: string);
var
  i: integer;
  pd: PTDropItem;
  itmname, sDeco: string;
begin
  for i := 0 to DropedItemList.Count - 1 do
  begin
    if PTDropItem(DropedItemList[i]).id = itemid then
      exit;
  end;
  new(pd);
  pd.Id := itemid;
  pd.X := x;
  pd.Y := y;
  pd.Looks := looks;
  sDeco := '0';
  if body <> '' then
  begin
    body := GetValidStr3(body, itmname, ['/']);
    body := GetValidStr3(body, sDeco, ['/']);
  end;
  pd.Name := itmname;
  if Str_ToInt(sDeco, 0) = 0 then
    pd.BoDeco := False
  else
    pd.BoDeco := True;

  pd.FlashTime := GetTickCount - Random(3000);
  pd.BoFlash := FALSE;
  DropedItemList.Add(pd);
end;

procedure TFrmMain.ClientGetHideItem(itemid, x, y: integer);
var
  i: integer;
  pd: PTDropItem;
begin
  for i := 0 to DropedItemList.Count - 1 do
  begin
    if PTDropItem(DropedItemList[i]).id = itemid then
    begin
      Dispose(PTDropItem(DropedItemList[i]));
      DropedItemlist.Delete(i);
      break;
    end;
  end;
end;

procedure TFrmMain.ClientGetSenduseItems(body: string);
var
  index: integer;
  str, data: string;
  cu: TClientItem;
begin
   // 2003/03/15 脚痹公傍
  FillChar(UseItems, sizeof(TClientItem) * 13, #0);      // 9->13
  while TRUE do
  begin
    if body = '' then
      break;
    body := GetValidStr3(body, str, ['/']);
    body := GetValidStr3(body, data, ['/']);
    index := Str_ToInt(str, -1);
      // 2003/03/15 酒捞袍 牢亥配府 犬厘
    if index in [0..12] then
    begin    // 8->12
      DecodeBuffer(data, @cu, sizeof(TClientItem));
      UseItems[index] := cu;
    end;
  end;
end;

procedure TFrmMain.ClientGetAddMagic(body: string);
var
  pcm: PTClientMagic;
begin
  new(pcm);
  DecodeBuffer(body, @(pcm^), sizeof(TClientMagic));
  MagicList.Add(pcm);
end;

procedure TFrmMain.ClientGetDelMagic(magid: integer);
var
  i: integer;
begin
  for i := MagicList.Count - 1 downto 0 do
  begin
    if PTClientMagic(MagicList[i]).Def.MagicId = magid then
    begin
      Dispose(PTClientMagic(MagicList[i]));
      MagicList.Delete(i);
      break;
    end;
  end;
end;

procedure TFrmMain.ClientGetMyMagics(checksum: integer; body: string);
var
  i, mdelay: integer;
  data: string;
  pcm: PTClientMagic;
begin
  for i := 0 to MagicList.Count - 1 do
    Dispose(PTClientMagic(MagicList[i]));
  MagicList.Clear;
  mdelay := 0;
  while TRUE do
  begin
    if body = '' then
      break;
    body := GetValidStr3(body, data, ['/']);
    if data <> '' then
    begin
      new(pcm);
      DecodeBuffer(data, @(pcm^), sizeof(TClientMagic));
      MagicList.Add(pcm);
      mdelay := mdelay + pcm.Def.DelayTime;
    end
    else
      break;
  end;

  if (checksum xor $4BBC2255) xor $773F1A34 <> mdelay then
  begin
    for i := 0 to MagicList.Count - 1 do
      PTClientMagic(MagicList[i]).Def.DelayTime := 1000;
  end;

end;

procedure TFrmMain.ClientGetMagicLvExp(magid, maglv, magtrain: integer);
var
  i: integer;
begin
  for i := MagicList.Count - 1 downto 0 do
  begin
    if PTClientMagic(MagicList[i]).Def.MagicId = magid then
    begin
      PTClientMagic(MagicList[i]).level := maglv;
      PTClientMagic(MagicList[i]).CurTrain := magtrain;
      break;
    end;
  end;
end;

procedure TFrmMain.ClientGetSound(soundid: integer);
begin
  SilenceSound;
  if soundid <> 0 then
  begin
    PlaySound(soundid);
  end
end;

procedure TFrmMain.ClientGetDuraChange(uidx, newdura, newduramax: integer);
begin
   // 2003/03/15 酒捞袍 牢亥配府 犬厘
  if uidx in [0..12] then
  begin     // 8->12
    if UseItems[uidx].S.Name <> '' then
    begin
      UseItems[uidx].Dura := newdura;
      UseItems[uidx].DuraMax := newduramax;
    end;
  end;
end;

procedure TFrmMain.ClientGetMerchantSay(merchant, face: integer; saying: string);
var
  npcname: string;
begin
  MDlgX := Myself.XX;
  MDlgY := Myself.YY;
  if CurMerchant <> merchant then
  begin
    CurMerchant := merchant;
    FrmDlg.ResetMenuDlg;
    FrmDlg.CloseMDlg;
  end;

  saying := GetValidStr3(saying, npcname, ['/']);
  FrmDlg.ShowMDlg(face, npcname, saying);
end;

procedure TFrmMain.ClientGetSendGoodsList(merchant, count: integer; body: string);
var
  i: integer;
  data, gname, gsub, gprice, gstock: string;
  pcg: PTClientGoods;
begin
  FrmDlg.ResetMenuDlg;

  CurMerchant := merchant;
  with FrmDlg do
  begin
      //deocde body received from server
    body := DecodeString(body);
    while body <> '' do
    begin
      body := GetValidStr3(body, gname, ['/']);
      body := GetValidStr3(body, gsub, ['/']);
      body := GetValidStr3(body, gprice, ['/']);
      body := GetValidStr3(body, gstock, ['/']);
      if (gname <> '') and (gprice <> '') and (gstock <> '') then
      begin
        new(pcg);
        pcg.Name := gname;
        pcg.SubMenu := Str_ToInt(gsub, 0);
        pcg.Price := Str_ToInt(gprice, 0);
        pcg.Stock := Str_ToInt(gstock, 0);
        pcg.Grade := -1;
        MenuList.Add(pcg);
      end
      else
        break;
    end;
    FrmDlg.ShowShopMenuDlg;
    FrmDlg.CurDetailItem := '';
  end;
end;

procedure TFrmMain.ClientGetDecorationList(merchant, count: integer; body: string);
var
  i: integer;
  data, sname, simgindex, sprice, scase: string;
  pcd: PTClientGADecoration;
begin

  with FrmDlg do
  begin
    for i := 0 to GADecorationList.Count - 1 do
      Dispose(PTClientGADecoration(GADecorationList[i]));
    GADecorationList.Clear;
  end;

//   CurMerchant := merchant;
   //捞抚/锅龋/啊拜/辆幅
  with FrmDlg do
  begin
      //deocde body received from server
    body := DecodeString(body);
    while body <> '' do
    begin
      body := GetValidStr3(body, sname, ['/']);
      body := GetValidStr3(body, simgindex, ['/']);
      body := GetValidStr3(body, sprice, ['/']);
      body := GetValidStr3(body, scase, ['/']);
//         body := GetValidStr3 (body, sprice, ['/']);
//      DScreen.AddChatBoardString (sname+'/'+stemp1+'/'+simgindex+'/'+stemp2, clYellow, clRed);
//         if (sname <> '') and (sprice <> '') and (simgindex <> '') then begin
      if (sname <> '') and (simgindex <> '') then
      begin
        new(pcd);
        pcd.Num := Str_ToInt(simgindex, 0);
        pcd.Name := sname;
        pcd.Price := Str_ToInt(sprice, 0);
        pcd.ImgIndex := Str_ToInt(simgindex, 0);
        pcd.CaseNum := Str_ToInt(scase, 0);

        GADecorationList.Add(pcd);
      end
      else
        break;
    end;
//      FrmDlg.ShowGADecorateDlg;
  end;
end;

procedure TFrmMain.ClientGetJangwonList(Page, count: integer; body: string);
var //厘盔府胶飘 罐澜
//   i: integer;
  SNum, SGuildname, SCaptainname1, SCaptainname2, SSellprice, SSellstate: string;
  pcj: PTClientJangwon;
begin
  FrmDlg.ResetMenuDlg;

   //deocde body received from server
  body := DecodeString(body);
  while body <> '' do
  begin
    body := GetValidStr3(body, SNum, ['/']);
    body := GetValidStr3(body, SGuildname, ['/']);
    body := GetValidStr3(body, SCaptainname1, ['/']);
    body := GetValidStr3(body, SCaptainname2, ['/']);
    body := GetValidStr3(body, SSellprice, ['/']);
    body := GetValidStr3(body, SSellstate, ['/']);
    if (SCaptainname1 <> '') and (SSellprice <> '') and (SSellstate <> '') then
    begin
      new(pcj);
      pcj.Num := Str_ToInt(SNum, 0);
      pcj.GuildName := SGuildname;
      pcj.CaptaineName1 := SCaptainname1;
      pcj.CaptaineName2 := SCaptainname2;
      pcj.SellPrice := Str_ToInt(SSellprice, 0);
      pcj.SellState := SSellstate;
      FrmDlg.JangwonList.Add(pcj);
//  DScreen.AddChatBoardString (SNum +'/'+ SGuildname +'/'+ SCaptainname +'/'+ SSellprice +'/'+ SSellstate, clYellow, clRed);
    end
    else
      break;
  end;
  if Page = 1 then
    FrmDlg.MenuTop := 0
  else if Page = 2 then
    FrmDlg.MenuTop := 10;
  FrmDlg.ShowJangwonDlg; // 困殴魄概 ItemMarket

end;

procedure TFrmMain.ClientGetGABoardList(ListNum, Page, MaxPage: integer; body: string);
var //厘盔 霸矫魄 府胶飘 罐澜
  i: integer;
  SGuildname, SWriteUser, SIndexType1, SIndexType2, SIndexType3, SIndexType4, STitleMsg, LineData: string;
  pcb: PTClientGABoard;
begin
   //deocde body received from server
  body := DecodeString(body);

  body := GetValidStr3(body, SGuildname, ['/']);
  body := GetValidStr3(body, SWriteUser, ['/']);
  body := GetValidStr3(body, SIndexType1, ['/']);
  body := GetValidStr3(body, SIndexType2, ['/']);
  body := GetValidStr3(body, SIndexType3, ['/']);
  body := GetValidStr3(body, SIndexType4, ['/']);
  body := GetValidStr3(body, STitleMsg, ['/']);

  FrmDlg.GABoard_MaxPage := MaxPage;
  FrmDlg.GABoard_CurPage := Page;

  if ListNum = 1 then
  begin
    FrmDlg.ResetMenuDlg;
    FrmDlg.GABoard_GuildName := SGuildname;
  end;

  if STitleMsg <> '' then
  begin
    new(pcb);
    pcb.WrigteUser := SWriteUser;
    pcb.IndexType1 := StrToInt(SIndexType1);
    pcb.IndexType2 := StrToInt(SIndexType2);
    pcb.IndexType3 := StrToInt(SIndexType3);
    pcb.IndexType4 := StrToInt(SIndexType4);

    STitleMsg := GetValidStr3(SQLSafeToStr(STitleMsg), LineData, [#13]);
    FrmDlg.GABoard_Notice.Add(LineData);
    pcb.TitleMsg := LineData;
    pcb.ReplyCount := 0;
    if pcb.IndexType2 > 0 then
      Inc(pcb.ReplyCount);
    if pcb.IndexType3 > 0 then
      Inc(pcb.ReplyCount);
    if pcb.IndexType4 > 0 then
      Inc(pcb.ReplyCount);

    FrmDlg.GABoardList.Add(pcb);
  end;

//   if FrmDlg.DGABoardListDlg.Visible then FrmDlg.DGABoardListDlg.Visible := False;
  if ListNum = 100 then
    FrmDlg.ShowGABoardListDlg;

end;

procedure TFrmMain.ClientGetGABoardRead(body: string);
var
  SWriteUser, STitleMsg, SIndexType1, SIndexType2, SIndexType3, SIndexType4, LineData: string;
begin

  body := DecodeString(body);

  body := GetValidStr3(body, SIndexType1, ['/']);
  body := GetValidStr3(body, SIndexType2, ['/']);
  body := GetValidStr3(body, SIndexType3, ['/']);
  body := GetValidStr3(body, SIndexType4, ['/']);
  body := GetValidStr3(body, SWriteUser, ['/']);
  body := GetValidStr3(body, STitleMsg, ['/']);

  FrmDlg.GABoard_IndexType1 := StrToInt(SIndexType1);
  FrmDlg.GABoard_IndexType2 := StrToInt(SIndexType2);
  FrmDlg.GABoard_IndexType3 := StrToInt(SIndexType3);
  FrmDlg.GABoard_IndexType4 := StrToInt(SIndexType4);

  FrmDlg.GABoard_UserName := SWriteUser;
  FrmDlg.GABoard_TxtBody := STitleMsg;

//DScreen.AddChatBoardString (SIndexType1 +'/'+ SIndexType2 +'/'+ SIndexType3 +'/'+ SIndexType4 +'/'+
//                            SWriteUser +'/'+ STitleMsg , clYellow, clRed);

  FrmDlg.GABoard_Notice.Clear;
//   STitleMsg := GetValidStr3 (SQLSafeToStr(STitleMsg), LineData, [#13]);
//   FrmDlg.GABoard_Notice.Add (SQLSafeToStr(STitleMsg));

  while TRUE do
  begin
    if STitleMsg = '' then
    begin
//    DScreen.AddChatBoardString ('STitleMsg=> '+STitleMsg, clYellow, clRed);
//    DScreen.AddChatBoardString ('LineData=> '+LineData, clYellow, clRed);
      break;
    end;
    STitleMsg := GetValidStr3(SQLSafeToStr(STitleMsg), LineData, [#13]);
    FrmDlg.GABoard_Notice.Add(LineData);
  end;

  FrmDlg.ShowGABoardReadDlg;

end;

procedure TFrmMain.ClientGetSendMakeDrugList(merchant: integer; body: string);
var
  i: integer;
  data, gname, gsub, gprice, gstock: string;
  pcg: PTClientGoods;
begin
  FrmDlg.ResetMenuDlg;

  CurMerchant := merchant;
  with FrmDlg do
  begin
      //clear shop menu list
      //deocde body received from server
    body := DecodeString(body);
    while body <> '' do
    begin
      body := GetValidStr3(body, gname, ['/']);
      body := GetValidStr3(body, gsub, ['/']);
      body := GetValidStr3(body, gprice, ['/']);
      body := GetValidStr3(body, gstock, ['/']);
      if (gname <> '') and (gprice <> '') and (gstock <> '') then
      begin
        new(pcg);
        pcg.Name := gname;
        pcg.SubMenu := Str_ToInt(gsub, 0);
        pcg.Price := Str_ToInt(gprice, 0);
        pcg.Stock := Str_ToInt(gstock, 0);
        pcg.Grade := -1;
        MenuList.Add(pcg);
      end
      else
        break;
    end;
    FrmDlg.ShowShopMenuDlg;
    FrmDlg.CurDetailItem := '';
    FrmDlg.BoMakeDrugMenu := TRUE;
  end;
end;

procedure TFrmMain.ClientGetSendMakeItemList(merchant: integer; body: string);
var
  i: integer;
  data, gname, gsub, gprice, gstock: string;
  pcg: PTClientGoods;
begin
  FrmDlg.ResetMenuDlg;

  CurMerchant := merchant;
  with FrmDlg do
  begin
      //clear shop menu list
      //deocde body received from server
    body := DecodeString(body);
    while body <> '' do
    begin
      body := GetValidStr3(body, gname, ['/']);
      body := GetValidStr3(body, gsub, ['/']);
      body := GetValidStr3(body, gprice, ['/']);
      body := GetValidStr3(body, gstock, ['/']);
      if (gname <> '') and (gprice <> '') and (gstock <> '') then
      begin
        new(pcg);
        pcg.Name := gname;
        pcg.SubMenu := Str_ToInt(gsub, 0);
        pcg.Price := Str_ToInt(gprice, 0);
        pcg.Stock := Str_ToInt(gstock, 0);
        pcg.Grade := -1;
        MenuList.Add(pcg);
      end
      else
        break;
    end;
    FrmDlg.ShowShopMenuDlg;
    FrmDlg.CurDetailItem := '';
    FrmDlg.BoMakeItemMenu := True;
  end;
end;

procedure TFrmMain.ClientGetSendUserSell(merchant: integer);
begin
  FrmDlg.CloseDSellDlg;
  CurMerchant := merchant;
  FrmDlg.SpotDlgMode := dmSell;
  FrmDlg.ShowShopSellDlg;
end;

procedure TFrmMain.ClientGetSendUserRepair(merchant: integer);
begin
  FrmDlg.CloseDSellDlg;
  CurMerchant := merchant;
  FrmDlg.SpotDlgMode := dmRepair;
  FrmDlg.ShowShopSellDlg;
end;

procedure TFrmMain.ClientGetSendUserStorage(merchant: integer);
begin
  FrmDlg.CloseDSellDlg;
  CurMerchant := merchant;
  FrmDlg.SpotDlgMode := dmStorage;
  FrmDlg.ShowShopSellDlg;
end;

procedure TFrmMain.ClientGetSendUserMaketSell(merchant: integer);
begin
  FrmDlg.CloseDSellDlg;
  CurMerchant := merchant;
  FrmDlg.SpotDlgMode := dmMaketSell;
  FrmDlg.ShowShopSellDlg;
end;

procedure TFrmMain.ClientGetSaveItemList(merchant, Currentpage, maxpage: integer; bodystr: string);
var
  i: integer;
  data: string;
  pc: PTClientItem;
  pcg: PTClientGoods;
begin
  FrmDlg.ResetMenuDlg;

//   DScreen.AddSysMsg (IntToStr(CurrentPage) + ' , ' + IntToStr(maxpage) );

  if Currentpage = 0 then
  begin
    for i := 0 to SaveItemList.Count - 1 do
      Dispose(PTClientItem(SaveItemList[i]));
    SaveItemList.Clear;
  end;

  while TRUE do
  begin
    if bodystr = '' then
      break;
    bodystr := GetValidStr3(bodystr, data, ['/']);
    if data <> '' then
    begin
      new(pc);
      DecodeBuffer(data, @(pc^), sizeof(TClientItem));
      SaveItemList.Add(pc);
    end
    else
      break;
  end;

  CurMerchant := merchant;
  with FrmDlg do
  begin
      //deocde body received from server
    for i := 0 to SaveItemList.Count - 1 do
    begin
      new(pcg);
      pcg.Name := PTClientItem(SaveItemList[i]).S.Name;
      pcg.SubMenu := 0;
      pcg.Price := PTClientItem(SaveItemList[i]).MakeIndex;
      pcg.Stock := Round(PTClientItem(SaveItemList[i]).Dura / 1000);
      pcg.Grade := Round(PTClientItem(SaveItemList[i]).DuraMax / 1000);
      MenuList.Add(pcg);
    end;
    if Currentpage = maxpage then
    begin
      FrmDlg.ShowShopMenuDlg;
      FrmDlg.BoStorageMenu := TRUE;
    end;
  end;
end;

procedure TFrmMain.ClientGetSendDetailGoodsList(merchant, count, topline: integer; bodystr: string);
var
  i: integer;
  body, data, gname, gprice, gstock, ggrade: string;
  pcg: PTClientGoods;
  pc: PTClientItem;
begin
  FrmDlg.ResetMenuDlg;

  CurMerchant := merchant;

  bodystr := DecodeString(bodystr);
  while TRUE do
  begin
    if bodystr = '' then
      break;
    bodystr := GetValidStr3(bodystr, data, ['/']);
    if data <> '' then
    begin
      new(pc);
      DecodeBuffer(data, @(pc^), sizeof(TClientItem));
      MenuItemList.Add(pc);
    end
    else
      break;
  end;

  with FrmDlg do
  begin
      //clear shop menu list
    for i := 0 to MenuItemList.Count - 1 do
    begin
      new(pcg);
      pcg.Name := PTClientItem(MenuItemList[i]).S.Name;
      pcg.SubMenu := 0;
      pcg.Price := PTClientItem(MenuItemList[i]).DuraMax;
      pcg.Stock := PTClientItem(MenuItemList[i]).MakeIndex;
      pcg.Grade := Round(PTClientItem(MenuItemList[i]).Dura / 1000);
      MenuList.Add(pcg);
    end;
    FrmDlg.ShowShopMenuDlg;
    FrmDlg.BoDetailMenu := TRUE;
    FrmDlg.MenuTopLine := topline;
  end;
end;

procedure TFrmMain.ClientGetSendNotice(body: string);
var
  data, msgstr: string;
begin
  DoFastFadeOut := FALSE;
  msgstr := '';
  body := DecodeString(body);
  while TRUE do
  begin
    if body = '' then
      break;
    body := GetValidStr3(body, data, [#27]);
    msgstr := msgstr + data + '\';
  end;
  FrmDlg.DialogSize := 2;
  gAutoRun := False;
  if FrmDlg.DMessageDlg(msgstr, [mbOk]) = mrOk then
  begin
    SendClientMessage(CM_LOGINNOTICEOK, 0, 0, 0, 0);
  end;
end;

procedure TFrmMain.ClientGetGroupMembers(bodystr: string);
var
  memb: string;
  actor: TActor;
  i: integer;
begin
  GroupMembers.Clear;

  try
//    for i := 0 to GroupIdList.Count - 1 do
//    begin
//      actor := PlayScene.FindActor(integer(GroupIdList[i]));
//      if actor <> nil then
//        actor.BoOpenHealth := False;   //解散队伍取消血条
//    end;
    GroupIdList.Clear; // MonOpenHp
  except
  end;

  while TRUE do
  begin
    if bodystr = '' then
      break;
    bodystr := GetValidStr3(bodystr, memb, ['/']);
    if memb <> '' then
      GroupMembers.Add(memb)
    else
      break;
  end;
end;

procedure TFrmMain.ClientGetOpenGuildDlg(bodystr: string);
var
  str, data, linestr, s1: string;
  pstep: integer;
begin
  str := DecodeString(bodystr);
  str := GetValidStr3(str, FrmDlg.Guild, [#13]);
  str := GetValidStr3(str, FrmDlg.GuildFlag, [#13]);
  str := GetValidStr3(str, data, [#13]);
  if data = '1' then
    FrmDlg.GuildCommanderMode := TRUE
  else
    FrmDlg.GuildCommanderMode := FALSE;

  FrmDlg.GuildStrs.Clear;
  FrmDlg.GuildNotice.Clear;
  pstep := 0;
  while TRUE do
  begin
    if str = '' then
      break;
    str := GetValidStr3(str, data, [#13]);
    if data = '<Notice>' then
    begin
      FrmDlg.GuildStrs.AddObject(char(7) + '公告', TObject(clWhite));
      FrmDlg.GuildStrs.Add(' ');
      pstep := 1;
      continue;
    end;
    if data = '<KillGuilds>' then
    begin
      FrmDlg.GuildStrs.Add(' ');
      FrmDlg.GuildStrs.AddObject(char(7) + '敌对行会', TObject(clWhite));
      FrmDlg.GuildStrs.Add(' ');
      pstep := 2;
      linestr := '';
      continue;
    end;
    if data = '<AllyGuilds>' then
    begin
      if linestr <> '' then
        FrmDlg.GuildStrs.Add(linestr);
      linestr := '';
      FrmDlg.GuildStrs.Add(' ');
      FrmDlg.GuildStrs.AddObject(char(7) + '联盟行会', TObject(clWhite));
      FrmDlg.GuildStrs.Add(' ');
      pstep := 3;
      continue;
    end;

    if pstep = 1 then
      FrmDlg.GuildNotice.Add(data);

    if data <> '' then
    begin
      if data[1] = '<' then
      begin
        ArrestStringEx(data, '<', '>', s1);
        if s1 <> '' then
        begin
          FrmDlg.GuildStrs.Add(' ');
          FrmDlg.GuildStrs.AddObject(char(7) + s1, TObject(clWhite));
          FrmDlg.GuildStrs.Add(' ');
          continue;
        end;
      end;
    end;
    if (pstep = 2) or (pstep = 3) then
    begin
      if Length(linestr) > 80 then
      begin
        FrmDlg.GuildStrs.Add(linestr);
        linestr := '';
        linestr := linestr + fmstr(data, 18);
      end
      else
      begin
        linestr := linestr + fmstr(data, 18);
      end;
      continue;
    end;

    FrmDlg.GuildStrs.Add(data);
  end;

  if linestr <> '' then
    FrmDlg.GuildStrs.Add(linestr);

  FrmDlg.ShowGuildDlg;
end;

procedure TFrmMain.ClientGetSendGuildMemberList(body: string);
var
  str, data, rankname, members: string;
  rank: integer;
begin
  str := DecodeString(body);
  FrmDlg.GuildStrs.Clear;
  FrmDlg.GuildMembers.Clear;
  rank := 0;
  while TRUE do
  begin
    if str = '' then
      break;
    str := GetValidStr3(str, data, ['/']);
    if data <> '' then
    begin
      if data[1] = '#' then
      begin
        rank := Str_ToInt(Copy(data, 2, Length(data) - 1), 0);
        continue;
      end;
      if data[1] = '*' then
      begin
        if members <> '' then
          FrmDlg.GuildStrs.Add(members);
        rankname := Copy(data, 2, Length(data) - 1);
        members := '';
        FrmDlg.GuildStrs.Add(' ');
        if FrmDlg.GuildCommanderMode then
          FrmDlg.GuildStrs.AddObject(fmStr('(' + IntToStr(rank) + ')', 3) + '<' + rankname + '>', TObject(clWhite))
        else
          FrmDlg.GuildStrs.AddObject('<' + rankname + '>', TObject(clWhite));
        FrmDlg.GuildMembers.Add('#' + IntToStr(rank) + ' <' + rankname + '>');
        continue;
      end;
      if Length(members) > 80 then
      begin
        FrmDlg.GuildStrs.Add(members);
        members := '';
      end;
      members := members + FmStr(data, 18);
      FrmDlg.GuildMembers.Add(data);
    end;
  end;
  if members <> '' then
    FrmDlg.GuildStrs.Add(members);
end;

procedure TFrmMain.MinTimerTimer(Sender: TObject);
var
  i: integer;
  timertime: longword;
begin
  with PlayScene do
    for i := 0 to ActorList.Count - 1 do
    begin
      if IsGroupMember(TActor(ActorList[i]).UserName) then
      begin
        TActor(ActorList[i]).Grouped := TRUE;
      end
      else
        TActor(ActorList[i]).Grouped := FALSE;
    end;
  for i := FreeActorList.Count - 1 downto 0 do
  begin
    if GetTickCount - TActor(FreeActorList[i]).DeleteTime > 60000 then
    begin
      TActor(FreeActorList[i]).Free;
      FreeActorList.Delete(i);
    end;
  end;
  //自动喊话
  if g_boAutoTalk then
  begin
    if (GetTickCount - g_nAutoTalkTimer) > 60000 then     //自动发言间隔，60000=60秒
    begin
      SendSay(g_sAutoTalkStr);
      g_nAutoTalkTimer := GetTickCount;
    end;
  end;
end;

procedure TFrmMain.CheckHackTimerTimer(Sender: TObject);
const
  busy: boolean = FALSE;
var
  ahour, amin, asec, amsec: word;
  tcount, timertime: longword;
begin
(*   if busy then exit;
   busy := TRUE;
   DecodeTime (Time, ahour, amin, asec, amsec);
   timertime := amin * 1000 * 60 + asec * 1000 + amsec;
   tcount := GetTickCount;

   if BoCheckSpeedHackDisplay then begin
      DScreen.AddSysMsg (IntToStr(tcount - LatestClientTime2) + ' ' +
                         IntToStr(timertime - LatestClientTimerTime) + ' ' +
                         IntToStr(abs(tcount - LatestClientTime2) - abs(timertime - LatestClientTimerTime)));
                         // + ',  ' +
                         //IntToStr(tcount - FirstClientGetTime) + ' ' +
                         //IntToStr(timertime - FirstClientTimerTime) + ' ' +
                         //IntToStr(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)));
   end;

   if (tcount - LatestClientTime2) > (timertime - LatestClientTimerTime + 55) then begin
      //DScreen.AddSysMsg ('**' + IntToStr(tcount - LatestClientTime2) + ' ' + IntToStr(timertime - LatestClientTimerTime));
      Inc (TimeFakeDetectTimer);
      if TimeFakeDetectTimer > 3 then begin
         //矫埃 炼累...
         SendSpeedHackUser;
         FrmDlg.DMessageDlg ('作为黑客程序使用者被记录在案\' +
                             '使用这种程序是违法的\' +
                             '而且请注意，你可能会受到类似帐户查封等惩罚\' +
                             '[询问] mir2master@wemade.com\' +
                             '程序将被终止。', [mbOk]);
         FrmMain.Close;
      end;
   end else
      TimeFakeDetectTimer := 0;


   if FirstClientTimerTime = 0 then begin
      FirstClientTimerTime := timertime;
      FirstClientGetTime := tcount;
   end else begin
      if (abs(timertime - LatestClientTimerTime) > 500) or
         (timertime < LatestClientTimerTime)
      then begin
         FirstClientTimerTime := timertime;
         FirstClientGetTime := tcount;
      end;
      if abs(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)) > 5000 then begin
         Inc (TimeFakeDetectSum);
         if TimeFakeDetectSum > 25 then begin
            //矫埃 炼累...
            SendSpeedHackUser;
            FrmDlg.DMessageDlg ('作为黑客程序使用者被记录在案。\' +
                             '使用这种程序是违法的。\' +
                             '而且请注意，你可能会受到类似帐户查封等惩罚。\' +
                             '[询问] mir2master@wemade.com\' +
                             '程序将被终止。', [mbOk]);
            FrmMain.Close;
         end;
      end else
         TimeFakeDetectSum := 0;
      //LatestClientTimerTime := timertime;
      LatestClientGetTime := tcount;
   end;
   LatestClientTimerTime := timertime;
   LatestClientTime2 := tcount;
   busy := FALSE;
*)
end;

procedure TFrmMain.CheckMapView;
var P:TPoint;
    ARect:TRect;
begin
  g_ShowMiniMapXY:=False;
  if BoDrawMiniMap and (ViewMiniMapStyle>0) then
     begin
        P.X := g_MouseX;
        P.Y := g_MouseY;
        ARect:=Rect(g_FScreenWidth-g_MinMapWidth,0,g_FScreenWidth,g_MinMapWidth);
        g_ShowMiniMapXY:=types.PtInRect(ARect, P);
     end;
end;

function TFrmMain.CheckPtInMinMap(X, Y: Integer): Boolean;
var Pt:TPoint;
    ARect:TRect;
begin
  if ViewMiniMapStyle>0 then
     begin
        Pt:=Point(X,Y);
        ARect:=Rect(g_FScreenWidth-g_MinMapWidth,0,g_FScreenWidth,g_MinMapWidth);
        Result:=types.PtInRect(ARect,Pt);
     end
     else
     Result:=False;
end;

(**
const
   busy: boolean = FALSE;
var
   ahour, amin, asec, amsec: word;
   timertime, tcount: longword;
begin
   if busy then exit;
   busy := TRUE;
   DecodeTime (Time, ahour, amin, asec, amsec);
   timertime := amin * 1000 * 60 + asec * 1000 + amsec;
   tcount := GetTickCount;

   //DScreen.AddSysMsg (IntToStr(tcount - FirstClientGetTime) + ' ' +
   //                   IntToStr(timertime - FirstClientTimerTime) + ' ' +
   //                   IntToStr(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)));

   if FirstClientTimerTime = 0 then begin
      FirstClientTimerTime := timertime;
      FirstClientGetTime := tcount;
   end else begin
      if (abs(timertime - LatestClientTimerTime) > 2000) or
         (timertime < LatestClientGetTime)
      then begin
         FirstClientTimerTime := timertime;
         FirstClientGetTime := tcount;
      end;
      if abs(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)) > 2000 then begin
         Inc (TimeFakeDetectSum);
         if TimeFakeDetectSum > 10 then begin
            //矫埃 炼累...
            SendSpeedHackUser;
            FrmDlg.DMessageDlg ('作为黑客程序使用者被记录在案。\' +
                             '使用这种程序是违法的。\' +
                             '而且请注意，你可能会受到类似帐户查封等惩罚。\' +
                             '[询问] mir2master@wemade.com\' +
                             '程序将被终止。', [mbOk]);
            FrmMain.Close;
         end;
      end else
         TimeFakeDetectSum := 0;
      LatestClientTimerTime := timertime;
      LatestClientGetTime := tcount;
   end;
   busy := FALSE;
end;
//**)

procedure TFrmMain.ClientGetDealRemoteAddItem(body: string);
var
  ci: TClientItem;
begin
  if body <> '' then
  begin
    DecodeBuffer(body, @ci, sizeof(TClientItem));
    AddDealRemoteItem(ci);
  end;
end;

procedure TFrmMain.ClientGetDealRemoteDelItem(body: string);
var
  ci: TClientItem;
begin
  if body <> '' then
  begin
    DecodeBuffer(body, @ci, sizeof(TClientItem));
    DelDealRemoteItem(ci);
  end;
end;

procedure TFrmMain.ClientGetReadMiniMap(mapindex: integer);
begin
  if mapindex >= 1 then
  begin
    BoDrawMiniMap := True;
      if BoWantMiniMap then
      begin
//         if PrevVMMStyle < 1 then
//            PrevVMMStyle := 1;
//         ViewMiniMapStyle := PrevVMMStyle;
      end;
    MiniMapIndex := mapindex - 1;
  end;
end;

procedure TFrmMain.ClientGetChangeGuildName(body: string);
var
  str: string;
begin
  str := GetValidStr3(body, GuildName, ['/']);
  GuildRankName := Trim(str);
end;

procedure TFrmMain.ClientGetSendUserState(body: string);
var
  ustate: TUserStateInfo;
begin
  DecodeBuffer(body, @ustate, sizeof(TUserStateInfo));
  ustate.NameColor := GetRGB(ustate.NameColor);
  FrmDlg.OpenUserState(ustate);
end;

procedure TFrmMain.SendTimeTimerTimer(Sender: TObject);
var
  tcount: longword;
begin
//   tcount := GetTickCount;
//   SendClientMessage (CM_CLIENT_CHECKTIME, tcount, Loword(LatestClientGetTime), Hiword(LatestClientGetTime), 0);
//   LastestClientGetTime := tcount;
end;

function TFrmMain.IsMyMember(name: string): Boolean;
var
  i: integer;
begin
  Result := false;
   // 模备俊辑 八祸
  for i := FriendMembers.Count - 1 downto 0 do
  begin
    if PTFriend(FriendMembers[i]).CharID = name then
    begin
      Result := true;
      Exit;
    end;
  end;

   // Black List俊辑 八祸
  for i := BlackMembers.Count - 1 downto 0 do
  begin
    if PTFriend(BlackMembers[i]).CharID = name then
    begin
      Result := true;
      Exit;
    end;
  end;

end;

// 2003/04/15 模备, 率瘤
procedure TFrmMain.ClientGetDelFriend(msg: TDefaultMessage; body: string);
var
  i: integer;
  str: string;
  keep: boolean;
begin
  str := DecodeString(body);
  keep := TRUE;
   // 模备俊辑 八祸
  for i := FriendMembers.Count - 1 downto 0 do
  begin
    if PTFriend(FriendMembers[i]).CharID = str then
    begin
      Dispose(PTFriend(FriendMembers[i]));
      FriendMembers.Delete(i);
      keep := FALSE;
      break;
    end;
  end;

   // 模备俊辑 八祸
   // Black List俊辑 八祸
  for i := BlackMembers.Count - 1 downto 0 do
  begin
    if PTFriend(BlackMembers[i]).CharID = str then
    begin
      Dispose(PTFriend(BlackMembers[i]));
      BlackMembers.Delete(i);
      keep := FALSE;
      break;
    end;
  end;


   // Block List俊辑 八祸
  if keep then
  begin
    for i := BlockLists.Count - 1 downto 0 do
    begin
      if BlockLists[i] = str then
      begin
        BlockLists.Delete(i);
        keep := FALSE;
        break;
      end;
    end;
  end;

  RecalcOnlinUserCount;

end;

procedure TFrmMain.RecalcOnlinUserCount;
var
  i: integer;
begin
  ConnectFriend := 0;
  for i := 0 to FriendMembers.Count - 1 do
  begin
    if PTFriend(FriendMembers[i]).Status >= 4 then
      inc(ConnectFriend);
  end;

  ConnectBlack := 0;
  for i := 0 to BlackMembers.Count - 1 do
  begin
    if PTFriend(BlackMembers[i]).Status >= 4 then
      inc(ConnectBlack);
  end;

end;

procedure TFrmMain.ClientGetUserInfo(msg: TDefaultMessage; body: string);
var
  i, j: integer;
  str, fname, fmapinfo: string;
  fstatus: integer;
  keep: boolean;
  fr: PTFriend;
begin
//   DScreen.AddSysMsg('SM_USER_INFO(BODY):'+body);
  str := DecodeString(body);
//   DScreen.AddSysMsg('SM_USER_INFO:'+str);

  fstatus := msg.param;
  fmapinfo := GetValidStr3(str, fname, ['/']);

   // 模备俊辑 八荤
  for i := FriendMembers.Count - 1 downto 0 do
  begin
    if PTFriend(FriendMembers[i]).CharID = fname then
    begin
      PTFriend(FriendMembers[i]).Status := fstatus;
      break;
    end;
  end;

   // 厩楷俊辑 八荤
  for i := BlackMembers.Count - 1 downto 0 do
  begin
    if PTFriend(BlackMembers[i]).CharID = fname then
    begin
      PTFriend(BlackMembers[i]).Status := fstatus;
      break;
    end;
  end;

  RecalcOnlinUserCount;
end;

procedure TFrmMain.ClientFriendSort(var datalist: TList; firstname: string);
var
  i, j: integer;
  firstpt, temppt: pointer;
begin
    // 2俺捞惑捞 登具 家飘啊 等促.
  if (datalist = nil) or (datalist.count < 2) then
    Exit;

  firstpt := nil;

    // 贸澜栏肺 持绢具 登绰巴阑 朅促.
  if (firstname <> '') then
  begin
    for i := 0 to datalist.count - 1 do
    begin
      if (PTFriend(datalist[i]).CharID = firstname) then
      begin
        firstpt := datalist[i];
        datalist.Delete(i);
        break;
      end;
    end;
  end;

    // 俺荐啊 2焊促 努版快俊
  if datalist.count >= 2 then
  begin
    for i := 0 to datalist.count - 2 do
    begin
      for j := i + 1 to datalist.count - 1 do
      begin
        if PTFriend(datalist[i]).CharID > PTFriend(datalist[j]).CharID then
        begin
          temppt := datalist[i];
          datalist[i] := datalist[j];
          datalist[j] := temppt;
        end;
      end;
    end;
  end;

    // 贸澜俊促 持绢霖促.
  if firstpt <> nil then
  begin
    datalist.Insert(0, firstpt);
  end;

end;

procedure TFrmMain.ClientGetFriendInfo(msg: TDefaultMessage; body: string);
var
  i, j: integer;
  str, fname, fmemo: string;
  ftype, fstatus: integer;
  keep: boolean;
  fr: PTFriend;
begin
//   DScreen.AddSysMsg('SM_FRIEND_INFO(BODY):'+body);
  str := DecodeString(body);
//   DScreen.AddSysMsg('SM_FRIEND_INFO:'+str);

   //str := GetValidStr3 (str, ftype, [' ']);
   //str := GetValidStr3 (str, fstatus, [' ']);
  ftype := msg.param;
  fstatus := msg.tag;
  fmemo := GetValidStr3(str, fname, ['/']);

  i := ftype;
  case i of
    RT_FRIENDS:
      begin
        keep := TRUE;
            // 模备俊辑 八祸
        for i := FriendMembers.Count - 1 downto 0 do
        begin
          if PTFriend(FriendMembers[i]).CharID = fname then
          begin
            PTFriend(FriendMembers[i]).Status := fstatus;
            PTFriend(FriendMembers[i]).Memo := fmemo;
            keep := FALSE;
            break;
          end;
        end;
        if keep then
        begin
          new(fr);
          fr.CharID := fname;
          fr.Status := fstatus;
          fr.Memo := fmemo;
          FriendMembers.Add(fr);
        end;

        ClientFriendSort(FriendMembers, flover.GetName(RsState_Lover));
      end;
    RT_BLACKLIST:
      begin
        keep := TRUE;
            // 模备俊辑 八祸
        for i := BlackMembers.Count - 1 downto 0 do
        begin
          if PTFriend(BlackMembers[i]).CharID = fname then
          begin
            PTFriend(BlackMembers[i]).Status := fstatus;
            PTFriend(BlackMembers[i]).Memo := fmemo;
            keep := FALSE;
            break;
          end;
        end;
        if keep then
        begin
          new(fr);
          fr.CharID := fname;
          fr.Status := fstatus;
          fr.Memo := fmemo;
          BlackMembers.Add(fr);
        end;

        ClientFriendSort(BlackMembers, '');
      end;
    RT_LOVERS:
      begin
      end;
    RT_MASTER:
      begin
      end;
    RT_DISCIPLE:
      begin
      end;
  end;

  RecalcOnlinUserCount
end;

procedure TFrmMain.ClientGetFriendResult(msg: TDefaultMessage; body: string);
var
  i: integer;
  str, fcmd, ferr, fname: string;
  keep: boolean;
  fr: PTFriend;
begin
  str := DecodeString(body);
  ferr := GetValidStr3(str, fcmd, [' ']);
  i := StrToInt(ferr);
  case i of
    CR_FAIL:
      DScreen.AddChatBoardString('请求的操作失败，原因是未知的错误。', clWhite, clRed);
    CR_DONTFINDUSER:
      DScreen.AddChatBoardString('字符名称不能被发现。', clWhite, clRed);
    CR_DONTADD:
      DScreen.AddChatBoardString('增加失败。', clWhite, clRed);
    CR_DONTDELETE:
      DScreen.AddChatBoardString('删除失败。', clWhite, clRed);
    CR_DONTUPDATE:
      DScreen.AddChatBoardString('修改失败。', clWhite, clRed);
    CR_DONTACCESS:
      DScreen.AddChatBoardString('信息是不可访问。', clWhite, clRed);
    CR_LISTISMAX:
      DScreen.AddChatBoardString('最大允许的人数已经超过。', clWhite, clRed);
    CR_LISTISMIN:
      DScreen.AddChatBoardString('最小允许的人数已经达到。', clWhite, clRed);
  end;
end;

procedure TFrmMain.ClientGetTagAlarm(msg: TDefaultMessage; body: string);
var
  notreadcount: integer;
begin
//     DScreen.AddSysMsg('SM_TAG_ARLARM:');
  notreadcount := msg.Param;
  if (notreadcount > 0) then
  begin
    DScreen.AddChatBoardString('你收到了新邮件！', clWhite, clRed);
    MailAlarm := true;
  end;

end;

procedure TFrmMain.RecalcNotReadCount;
var
  i: integer;
begin
     // 佬瘤 臼篮俺荐甫 盎脚茄促.
  NotReadMailCount := 0;
  for i := 0 to MailLists.Count - 1 do
  begin
    if (pTMail(MailLists[i]).Status = 0) then
      inc(NotReadMailCount);
  end;

end;

procedure TFrmMain.ClientGetTagList(msg: TDefaultMessage; body: string);
var
  i: integer;
  str: string;
  MailStr: string;
  StateStr: string;
  DateStr: string;
  SenderStr: string;
  TotalCount: integer;
  PageCount: integer;
  pMail: pTMail;
begin
  str := DecodeString(body);
//   DScreen.AddSysMsg('SM_TAG_LIST:'+str);

  PageCount := msg.Param;
  TotalCount := msg.Tag;

  pMail := nil;
  for i := 0 to TotalCount - 1 do
  begin
    str := GetValidStr3(str, MailStr, ['/']);
    MailStr := GetValidStr3(MailStr, StateStr, [':']);
    MailStr := GetValidStr3(MailStr, DateStr, [':']);
    MailStr := GetValidStr3(MailStr, SenderStr, [':']);

    new(pMail);

    pMail^.Sender := SenderStr;
    pMail^.Date := DateStr;
    pMail^.Mail := MailStr;
    pMail^.Status := Str_ToInt(StateStr, 0);

    MailLists.Insert(0, pMail);
  end;

  RecalcNotReadCount;
end;

procedure TFrmMain.ClientGetTagInfo(msg: TDefaultMessage; body: string);
var
  str: string;
  i: integer;
  Status: integer;
begin
  str := DecodeString(body);
  Status := msg.Param;

//   DScreen.AddSysMsg('SM_TAG_INFO:'+str + IntToStr(Status));
  for i := 0 to MailLists.Count - 1 do
  begin
    if pTMail(MailLists[i]).Date = str then
    begin
      // 昏力牢版快俊绰 昏力窍磊
      if Status = 3 then
      begin
        dispose(MailLists[i]);
        MailLists.Delete(i);
      end
      else
        pTMail(MailLists[i]).Status := Status;

      break;
    end;
  end;
  RecalcNotReadCount;
end;

procedure TFrmMain.ClientGetTagRejectList(msg: TDefaultMessage; body: string);
var
  i: integer;
  str: string;
  RejectStr: string;
  RejectCount: Integer;
begin

  str := DecodeString(body);
//   DScreen.AddSysMsg('SM_TAG_REJECT_LIST:'+str);

  RejectCount := msg.Param;

  for i := 0 to RejectCount - 1 do
  begin
    str := GetValidStr3(str, RejectStr, ['/']);
    BlockLists.Add(RejectStr);
  end;

end;

procedure TFrmMain.ClientGetTagRejectAdd(msg: TDefaultMessage; body: string);
var
  str: string;
begin
  str := DecodeString(body);
//   DScreen.AddSysMsg('SM_TAG_REJECT_ADD:'+str);

  BlockLists.Add(str);

end;

procedure TFrmMain.ClientGetTagRejectDelete(msg: TDefaultMessage; body: string);
var
  str: string;
  i: integer;
begin
  str := DecodeString(body);
//   DScreen.AddSysMsg('SM_TAG_REJECT_DELETE:'+str);

  for i := 0 to BlockLists.Count - 1 do
  begin
    if (BlockLists[i] = str) then
    begin
      BlockLists.Delete(i);
      break;
    end;
  end
end;

procedure TFrmMain.ClientGetTagResult(msg: TDefaultMessage; body: string);
begin

end;

procedure TFrmMain.ClientGetLMList(msg: TDefaultMessage; body: string);
var
  _state: integer;
  _level: integer;
  _Sex: integer;
  _Date: string;
  _ServerDate: string;
  _Name: string;
  _MapInfo: string;
  count, i: integer;
  str: string;
  infostr: string;
  temp: string;
begin
  str := DecodeString(body);
  count := msg.Param;
//     DScreen.AddSysmsg ('SM_LM_LIST:'+intToStr(count)+','+str);
//  DScreen.AddChatBoardString ('SM_LM_LIST:'+intToStr(count)+','+str, clWhite, clGreen);
  for i := 0 to count - 1 do begin
    str := GetValidStr3(str, infostr, ['/']);
    if infostr <> '' then begin
      infostr := GetValidStr3(infostr, temp, [':']);
      _state := Str_ToInt(temp, 0);
      infostr := GetValidStr3(infostr, _Name, [':']);
      infostr := GetValidStr3(infostr, temp, [':']);
      _level := Str_ToInt(temp, 1);
      infostr := GetValidStr3(infostr, temp, [':']);
      _Sex := Str_ToInt(temp, 0);
      infostr := GetValidStr3(infostr, _Date, [':']);
      infostr := GetValidStr3(infostr, _ServerDate, [':']);
      infostr := GetValidStr3(infostr, _MapInfo, [':']);

      case _state of
        RsState_Lover :
        begin
//          DScreen.AddChatBoardString (_Name+' '+_MapInfo+'', clWhite, clGreen);
          fLover.Add(MySelf.UserName, _Name, _state, _level, _Sex, _Date, _ServerDate, _MapInfo);
          ClientFriendSort(FriendMembers, flover.GetName(RsState_Lover));
        end;
        RsState_Master :
        begin
//          DScreen.AddChatBoardString (_Name+' '+_MapInfo+'', clWhite, clGreen);
          fMaster.Add(MySelf.UserName, _Name, _state, _level, _Sex, _Date, _ServerDate, _MapInfo);
//          ClientFriendSort(FriendMembers, fMaster.GetName(RsState_Master));


        end;
        RsState_Pupil :
        begin
//          DScreen.AddChatBoardString (_Name+' '+_MapInfo+'', clWhite, clGreen);
          fPupil.Add(MySelf.UserName, _Name, _state, _level, _Sex, _Date, _ServerDate, _MapInfo);
//          ClientFriendSort(FriendMembers, fPupil.GetName(RsState_Pupil));

        end;
      end;

//            if _MapInfo <> '' then
//            begin
//                DScreen.AddChatBoardString (_Name+'丛捞 '+_MapInfo+'俊 拌绞聪促.', clWhite, clGreen);
//            end;
    end;
  end;
end;

procedure TFrmMain.ClientGetLMOptionChange(msg: TDefaultMessage);
var
  optiontype, enable: integer;
begin
  optiontype := msg.Param;
  enable := msg.Tag;
  case optiontype of
    1:
      begin
        fLover.SetEnable(rsState_Lover, enable);
        if enable = 1 then
          DScreen.AddChatBoardString('允许情侣关系', clRed, clWhite)
        else
          DScreen.AddChatBoardString('拒绝情侣关系', clRed, clWhite);
      end;
  end;
     // DScreen.AddSysmsg ('SM_LM_OPTION:'+IntToStr( optiontype) + ','+ IntToStr( enable));

end;

procedure TFrmMain.ClientGetLMRequest(msg: TDefaultMessage; body: string);
var
  str: string;
  ReqType: integer;
  ReqSeq: integer;
begin
  str := DecodeString(body);
  ReqType := msg.Param;
  ReqSeq := msg.Tag;

  case ReqType of
    RsState_Lover:
      begin
        case ReqSeq of
          RsReq_WhoWantJoin:
            begin
              if mrYes = FrmDlg.DMessageDlg(str + ' 正在向你发送结婚请求。\请问你愿意和他(她)结为合法夫妻吗？', [mbYes, mbNo]) then
                SendLMRequest(ReqType, RsReq_AloowJoin)
              else
                SendLMRequest(ReqType, RsReq_DenyJoin);

            end;
        end;
      end;
    RsState_Master:
      begin
        case ReqSeq of
          RsReq_WhoWantJoin:
            begin
              if mrYes = FrmDlg.DMessageDlg(str + '请求与你成师徒。\一旦师徒关系建立， 强制脱离\将' + '支付150,0000金币费用，\你确定要建立师徒关系吗？', [mbYes, mbNo]) then
                SendLMRequest(RsState_Pupil, RsReq_AloowJoin)
              else
                SendLMRequest(RsState_Pupil, RsReq_DenyJoin);
            end;
        end;
      end;
    RsState_Pupil:
      begin
        case ReqSeq of
          RsReq_WhoWantJoin:
            begin
              if mrYes = FrmDlg.DMessageDlg(str + '请求与你成师徒。\一旦师徒关系建立， 强制脱离\将' + '支付150,0000金币费用，\你确定要建立师徒关系吗？', [mbYes, mbNo]) then
                SendLMRequest(RsState_Master, RsReq_AloowJoin)
              else
                SendLMRequest(RsState_Master, RsReq_DenyJoin);
            end;
        end;
      end;
  end;

//   DScreen.AddSysmsg ('SM_LM_REQUEST:'+IntToStr( msg.param) + ','+IntToStr( msg.Tag) + ','+ str);
end;

procedure TFrmMain.ClientGetLMResult(msg: TDefaultMessage; body: string);
var
  str: string;
  reqtype: integer;
  errcode: integer;
  sName, sMinLevel, sMaxLevel: string;
begin
  str := DecodeString(body);
  reqtype := msg.Param;
  errcode := msg.Tag;

  case reqtype of
    RsState_Lover:
      begin
        case errcode of
          RsError_SuccessJoin: //= 1;         // 参加成功了 ( 曼啊茄荤恩率)
            begin
//                FrmDlg.DMessageDlg (str+'丛苞 楷牢捞 登菌嚼聪促.', [mbYes]);
              FrmDlg.AddFriend(str, false);
              PlaySound(154);
            end;
          RsError_SuccessJoined: //= 2;         // 参加成功了 ( 曼啊等 荤恩率)
            begin
//                FrmDlg.DMessageDlg (str+'丛捞 背力甫 倾遏窍咯 楷牢捞 登菌嚼聪促.', [mbYes]);
              FrmDlg.AddFriend(str, false);
              PlaySound(154);
            end;
          RsError_DontJoin: //= 3;         // 曼啊且 荐 绝促
//            FrmDlg.JustMessageDlg (str+' 决定是否要结婚吗？', [mbOK]);
            FrmDlg.DMessageDlg(str + '决定是否要结婚吗？', [mbOK]);
          RsError_DontLeave: //= 4;         // 栋朝荐 绝促.
            FrmDlg.DMessageDlg(str + '你破坏不了我们的关系。', [mbOK]);
          RsError_RejectMe: //= 5;         // 芭何惑怕捞促
            FrmDlg.DMessageDlg('您目前没有允许情侣关系。\请点击选择允许情侣关系按钮。', [mbOK]);
          RsError_RejectOther: //= 6;         // 芭何惑怕捞促
            FrmDlg.DMessageDlg(str + '目前未允许情侣关系。', [mbOK]);
          RsError_LessLevelMe: //= 7;         // 唱狼饭骇捞 撤促
            FrmDlg.DMessageDlg('只有22级或更高的等级才可以邀请情侣关系。', [mbOK]);
          RsError_LessLevelOther: //= 8;         // 惑措规狼饭骇捞 撤促
            FrmDlg.DMessageDlg(str + '必须22级或以上才可以接婚。', [mbOK]);
          RsError_EqualSex: //= 9;         // 己喊捞 鞍促
            FrmDlg.DMessageDlg('两个相同性别不允许情侣关系。', [mbOK]);
          RsError_FullUser: //= 10;        // 曼咯牢盔捞 啊垫谩促
            FrmDlg.DMessageDlg(str + '已经结婚，因此无法再次结婚', [mbOK]);
          RsError_CancelJoin: //= 11;        // 曼啊秒家
            DScreen.AddChatBoardString('求婚被拒绝。', clGreen, clWhite);
          RsError_DenyJoin: //= 12;        // 曼啊甫 芭例窃
            FrmDlg.DMessageDlg(str + '拒绝了你的求婚。', [mbOK]);
          RsError_DontDelete: //= 13;        // 呕硼矫懦荐 绝促.
            FrmDlg.DMessageDlg(str + '摧毁不了我们的关系。', [mbOK]);
          RsError_SuccessDelete: //= 14;        // 呕硼矫淖澜
            begin
              PlaySound(155);
              FrmDlg.DMessageDlg(str + '的情侣关系已经解散。', [mbOK]);
            end;
          RsError_NotRelationShip: //= 15;        // 背力惑怕啊 酒聪促.
            FrmDlg.DMessageDlg('你目前已经是已婚人士了.', [mbOK]);
        end;
      end;
    RsState_Master:
      begin
        case errcode of
          RsError_LessLevelMe:begin
            str := GetValidStr3(str, sMinLevel, ['/']);
            str := GetValidStr3(str, sMaxLevel, ['/']);

            FrmDlg.DMessageDlg('只有 '+sMinLevel+' 级到 '+sMaxLevel+' 级才可以拜师.', [mbOK]);
          end;
          RsError_LessLevelOther:begin
            str := GetValidStr3(str, sName, ['/']);
            FrmDlg.DMessageDlg(sName + ' 要作为师傅必须在 '+str+' 级或者 '+str+' 级以上.', [mbOK]);
          end;
          RsError_FullUser:
            FrmDlg.DMessageDlg(str + '收的徒弟数量已经满了，\不能再收徒.', [mbOK]);
          RsError_SuccessDelete:
            begin
              PlaySound(155);
              FrmDlg.DMessageDlg('你已和 ' + str + ' 脱离师徒关系.', [mbOK]);
            end;
          RsError_CancelJoin:
            DScreen.AddChatBoardString('建立师徒关系的邀请已经取消了.', clGreen, clWhite);
          RsError_DenyJoin:
            FrmDlg.DMessageDlg(str + '拒绝了您建立师徒关系的请求.', [mbOK]);
          RsError_RelationShip:
            FrmDlg.DMessageDlg(str + ' 已经是你的师傅，\请不要重复请求拜师.', [mbOK]);
        end;
      end;
    RsState_Pupil:
      begin
        case errcode of
          RsError_LessLevelMe:
            FrmDlg.DMessageDlg('只有 '+str+' 级或 '+str+' 级以上的才可以收徒.', [mbOK]);
          RsError_LessLevelOther:begin
            str := GetValidStr3(str, sName, ['/']);
            str := GetValidStr3(str, sMinLevel, ['/']);
            str := GetValidStr3(str, sMaxLevel, ['/']);
            FrmDlg.DMessageDlg(sName + ' 要作为徒弟必须在 '+sMinLevel+' 级到 '+sMaxLevel+' 级.', [mbOK]);
          end;
          RsError_FullUser:
            FrmDlg.DMessageDlg(str + '已经拜师，\不能重复拜师.', [mbOK]);
          RsError_SuccessDelete:
            begin
              PlaySound(155);
              FrmDlg.DMessageDlg(str + ' 已经和你脱离师徒关系.', [mbOK]);
            end;
          RsError_CancelJoin:
            DScreen.AddChatBoardString('建立师徒关系的邀请已经取消了.', clGreen, clWhite);
          RsError_DenyJoin:
            FrmDlg.DMessageDlg(str + '拒绝了您建立师徒关系的请求.', [mbOK]);
          RsError_RelationShip:
            FrmDlg.DMessageDlg(str + '已经是你的徒弟，\请不要重复请求收徒.', [mbOK]);
        end;
      end;
  end;

     // DScreen.AddSysmsg ('SM_LM_RESULT:'+IntToStr( msg.param) + ','+IntToStr( msg.Tag) + ','+ str);
end;

procedure TFrmMain.ClientGetLMDelete(msg: TDefaultMessage; body: string);
var
  str: string;
  ReqType: integer;
begin
  str := DecodeString(body);
  ReqType := msg.Param;
  case ReqType of
    RsState_Lover: fLover.Delete(str);
    RsState_Master: fMaster.Delete(str);
    RsState_Pupil: fPupil.Delete(str);
  end;;
end;

procedure TFrmMain.SendAddFriend(data: string; FriendType: integer);
var
  msg: TDefaultMessage;
begin
//   DScreen.AddSysMsg('CM_FRIEND_ADD:'+data);
   // TO DO , FRIEND = 1 (wparam ) , BLACKLIST = 8
  msg := MakeDefaultMsg(CM_FRIEND_ADD, 0, FriendType, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendAddReject(data: string);
var
  msg: TDefaultMessage;
begin
//   DScreen.AddSysMsg('CM_TAG_REJECT_ADD:'+data);
  msg := MakeDefaultMsg(CM_TAG_REJECT_ADD, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendDelReject(data: string);
var
  msg: TDefaultMessage;
begin
//   DScreen.AddSysMsg('CM_TAG_REJECT_DELETE:'+data);
  msg := MakeDefaultMsg(CM_TAG_REJECT_DELETE, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendLMOptionChange(OptionType: integer; Enable: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_LM_OPTION, OptionType, Enable, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendLMRequest(ReqType: integer; ReqSeq: integer);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_LM_REQUEST, ReqType, ReqSeq, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendLMSeparate(ReqType: integer; data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_LM_DELETE, ReqType, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendDelFriend(data: string);
var
  msg: TDefaultMessage;
begin
//   DScreen.AddSysMsg('CM_FRIEND_DELETE:'+data);
  msg := MakeDefaultMsg(CM_FRIEND_DELETE, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendMail(data: string);
var
  msg: TDefaultMessage;
begin
  if frmDlg.BoMemoJangwon then
  begin
    msg := MakeDefaultMsg(CM_GUILDAGIT_TAG_ADD, 0, 0, 0, 0);
    frmDlg.BoMemoJangwon := False;
  end
  else
    msg := MakeDefaultMsg(CM_TAG_ADD, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendReadingMail(data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAG_SETINFO, 0, 1, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendDelMail(data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAG_DELETE, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendLockMail(data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAG_SETINFO, 0, 2, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendUnLockMail(data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAG_SETINFO, 0, 3, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.SendMailList;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAG_LIST, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendRejectList;
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_TAG_REJECT_LIST, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg));
end;

procedure TFrmMain.SendUpdateFriend(data: string);
var
  msg: TDefaultMessage;
begin
  msg := MakeDefaultMsg(CM_FRIEND_EDIT, 0, 0, 0, 0);
  SendSocket(EncodeMessage(msg) + EncodeString(data));
end;

procedure TFrmMain.DelitemProg;
begin
  DelItemBag(DelTempItem.S.Name, DelTempItem.MakeIndex);
end;

procedure TFrmMain.RunEffectTimerTimer(Sender: TObject);
var
  tx, ty, n, kx, ky, i: integer;
  bofly: Boolean;
begin

  tx := Myself.XX;
  ty := Myself.YY;

  Randomize;
  RunEffectTimer.Tag := RunEffectTimer.Tag + 1;
  n := random(4);
  kx := random(5) + 1;
  ky := random(4) + 1;
  if RunEffectTimer.Tag > 1000000 then
    RunEffectTimer.Tag := 1000;

  if EffectNum = 1 then
  begin
    case random(5) of
      0:
        RunEffectTimer.Interval := 400;
      1:
        RunEffectTimer.Interval := 600;
      2:
        RunEffectTimer.Interval := 800;
      3:
        RunEffectTimer.Interval := 1000;
      4:
        RunEffectTimer.Interval := 1500;
    end;

    case n of
      0:
        if Map.CanMove(tx + kx, ty - ky) then
          PlayScene.NewMagic(nil, MAGIC_DUN_THUNDER, MAGIC_DUN_THUNDER, tx + kx, ty - ky, tx + kx, ty - ky, 0, mtThunder, FALSE, 30, bofly);
      1:
        if Map.CanMove(tx - kx, ty + ky) then
          PlayScene.NewMagic(nil, MAGIC_DUN_THUNDER, MAGIC_DUN_THUNDER, tx - kx, ty + ky, tx - kx, ty + ky, 0, mtThunder, FALSE, 30, bofly);
      2:
        if Map.CanMove(tx - kx, ty - ky) then
          PlayScene.NewMagic(nil, MAGIC_DUN_THUNDER, MAGIC_DUN_THUNDER, tx - kx, ty - ky, tx - kx, ty - ky, 0, mtThunder, FALSE, 30, bofly);
      3:
        if Map.CanMove(tx + kx, ty + ky) then
          PlayScene.NewMagic(nil, MAGIC_DUN_THUNDER, MAGIC_DUN_THUNDER, tx + kx, ty + ky, tx + kx, ty + ky, 0, mtThunder, FALSE, 30, bofly);
    end;
    PlaySound(8301);

  end
  else if EffectNum = 2 then
  begin
    case random(RunEffectTimer.Tag) mod 5 of
      0:
        RunEffectTimer.Interval := 1000;
      1:
        RunEffectTimer.Interval := 1500;
      2:
        RunEffectTimer.Interval := 2000;
      3:
        RunEffectTimer.Interval := 2500;
      4:
        RunEffectTimer.Interval := 3000;
    end;

    case n of
      0:
        if Map.CanMove(tx + kx, ty - ky) then
        begin
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE1, MAGIC_DUN_FIRE1, tx + kx, ty - ky, tx + kx, ty - ky, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE2, MAGIC_DUN_FIRE2, tx + kx, ty - ky, tx + kx, ty - ky, 0, mtThunder, FALSE, 30, bofly);
        end;
      1:
        if Map.CanMove(tx - kx, ty + ky) then
        begin
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE1, MAGIC_DUN_FIRE1, tx - kx, ty + ky, tx - kx, ty + ky, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE2, MAGIC_DUN_FIRE2, tx - kx, ty + ky, tx - kx, ty + ky, 0, mtThunder, FALSE, 30, bofly);
        end;
      2:
        if Map.CanMove(tx - kx, ty - ky) then
        begin
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE1, MAGIC_DUN_FIRE1, tx - kx, ty - ky, tx - kx, ty - ky, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE2, MAGIC_DUN_FIRE2, tx - kx, ty - ky, tx - kx, ty - ky, 0, mtThunder, FALSE, 30, bofly);
        end;
      3:
        if Map.CanMove(tx + kx, ty + ky) then
        begin
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE1, MAGIC_DUN_FIRE1, tx + kx, ty + ky, tx + kx, ty + ky, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic(nil, MAGIC_DUN_FIRE2, MAGIC_DUN_FIRE2, tx + kx, ty + ky, tx + kx, ty + ky, 0, mtThunder, FALSE, 30, bofly);
        end;
    end;
    PlaySound(8302);
  end;

end;

procedure TFrmMain.MainCancelItemMoving;
begin
  FrmDlg.CancelItemMoving;
end;

procedure TFrmMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ConnectionStep = cnsPlay then begin
    case Key of
      VK_TAB:
      begin
          FrmDlg.DBotMiniMapClick(nil, 0, 0);
        if ViewMiniMapStyle=2 then
           g_MinMapWidth:=200
           else
           g_MinMapWidth:=120;
          CheckMapView;
      end;
    end;
  end;
  if g_DWinMan.KeyUp(Key, Shift) then Exit;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
//  ShowWindow(application.Handle, SW_HIDE);
end;

procedure TfrmMain.AppOnIdle(boInitialize: Boolean = False);
var
  CanDraw: Boolean;
  t, t2: DWORD;
  LagCount: Integer;
  I: Integer;
begin
  CanDraw := HGE.Gfx_CanBegin();
  g_boCanDraw := CanDraw and (not boSizeMove);

  if MusicHS >= BASS_ERROR_ENDED then
  begin
    if boInFocus and g_boCanDraw then
    begin
      if BASS_ChannelIsActive(MusicHS) = BASS_ACTIVE_PAUSED then
      begin
        ChangeBGMState(bgmPlay);
      end;
      g_boCanSound := True;
    end
    else
    begin
      if BASS_ChannelIsActive(MusicHS) = BASS_ACTIVE_PLAYING then
      begin
        ChangeBGMState(bgmPause);
      end;
      g_boCanSound := False;
      SilenceSound;
    end;
  end;

  g_boCanDraw := False;
  t := TimeGetTime;
  t2 := t - FOldTime;
  if t2 >= FInterval then
  begin
    FOldTime := t;

    LagCount := t2 div FInterval2;
    if LagCount < 1 then
      LagCount := 1;

    Inc(FNowFrameRate);

    I := Max(t - FOldTime2, 1);
    if I >= 1000 then
    begin
      FFrameRate := Round(FNowFrameRate * 1000 / I);
      FNowFrameRate := 0;
      FOldTime2 := t;
    end;
    g_boCanDraw := True;
    //DoTimer(LagCount);
  end;

  if not FboShowLogo then
  begin
    if g_boCanDraw then
    begin
      HGE.Gfx_BeginScene;
      HGE.Gfx_Clear($FF222222);
      HGE.RenderBatch;
      MyDeviceRender(nil);
      HGE.Gfx_EndScene;
    end;
  end
  else if not boInitialize then
  begin
    if DScreen.CurrentScene = PlayScene then
    begin
      PlayScene.BeginScene; //DebugOutStr('106');

      if g_boCanDraw then
      begin
        if PlayScene.CanDrawTileMap then
        begin
          HGE.Gfx_BeginScene(PlayScene.MapSurface.Target);
          HGE.Gfx_Clear(0);
          HGE.RenderBatch;
          PlayScene.DrawTileMap(nil);
          HGE.Gfx_EndScene;
        end;
        if PlayScene.m_boPlayChange then
        begin
          HGE.Gfx_BeginScene(PlayScene.ObjSurface.Target);
          HGE.Gfx_Clear(0);
          HGE.RenderBatch;
          PlayScene.PlaySurface(nil);
          HGE.Gfx_EndScene;

        end;
        if ViewFog then begin
          HGE.Gfx_BeginScene(PlayScene.LigSurface.Target);
          HGE.Gfx_Clear(0);
          HGE.RenderBatch;
          PlayScene.LightSurface(nil);
          HGE.Gfx_EndScene;
        end;
        HGE.Gfx_BeginScene(PlayScene.MagSurface.Target);
        HGE.Gfx_Clear(0);
        HGE.RenderBatch;
        PlayScene.MagicSurface(nil);
        HGE.Gfx_EndScene;
      end;
    end;
    if g_boCanDraw then
    begin
      HGE.Gfx_BeginScene;
      HGE.Gfx_Clear(0);
      HGE.RenderBatch;
      MyDeviceRender(nil);
      HGE.Gfx_EndScene;
    end;
  end
  else
  begin
    if g_boCanDraw then
    begin
      HGE.Gfx_BeginScene;
      HGE.Gfx_Clear(0);
      HGE.RenderBatch;
      MyDeviceRender(nil);
      HGE.Gfx_EndScene;
    end;
  end;
end;

procedure TfrmMain.FullScreen(boFull: Boolean);
begin
  if g_boFullScreen <> boFull then begin
    TimerRun.Enabled := False;
    application.ProcessMessages;
    g_boFullScreen := boFull;
    if g_boFullScreen then begin
      DisplayChange(False);
      
      BorderStyle := bsNone;
      BorderIcons := [];

      ClientWidth := HGE.System_GetState(HGE_FScreenWidth);
      ClientHeight := HGE.System_GetState(HGE_FScreenHeight);
      WindowState := wsMaximized;

      m_Point.X := 0;
      m_Point.Y := 0;
    end else begin
      DisplayChange(True);

      BorderStyle := bsSingle;
      FormStyle := fsNormal;
      WindowState := wsNormal;
      ClientWidth := HGE.System_GetState(HGE_FScreenWidth);
      ClientHeight := HGE.System_GetState(HGE_FScreenHeight);
      BorderIcons := [biSystemMenu, biMinimize];
      Left := (Screen.width - ClientWidth) div 2;
      Top := (Screen.Height - ClientHeight) div 2 - 40;
      SetWindowPos(handle, HWND_NOTOPMOST, left, top, width, height, SWP_SHOWWINDOW);
    end;
    TimerRun.Enabled := True;
    Tag := 0;
  end;

end;

procedure TfrmMain.MyDeviceFinalize(Sender: TObject);
begin
  TimerRun.Enabled := False;
  g_DXCanvas := nil;
 // UnLoadWMImagesLib();
  UnLoadColorLevels();
//  DScreen.Finalize;
//  PlayScene.Finalize;
end;

procedure TfrmMain.MyDeviceInitialize(Sender: TObject; var Success: Boolean; var ErrorMsg: string);
var
  nCount: Integer;
begin
  HGETextures.InitializeTexturesInfo();

  //=============设置窗体的字体,大小=============
  frmMain.Font.name := DEFFONTNAME;
  frmMain.Font.Size := DEFFONTSIZE;
  frmMain.Canvas.Font.name := DEFFONTNAME;
  frmMain.Canvas.Font.Size := DEFFONTSIZE;

  g_boInitialize := True;

  MShare.g_DXCanvas := TDXDrawCanvas.Create(g_DXFont);
  HGECanvas.g_DXCanvas := MShare.g_DXCanvas;

  g_Font := Font;

  nCount := g_DXFont.CreateTexture;
  if nCount = -1 then
  begin
    Success := False;
    ErrorMsg := 'Texture Size Error';
    exit;
  end;

  CreateLogoSurface();
  CreateLight0aSurface();
  CreateLight0bSurface();
  CreateLight0cSurface();
  CreateLight0dSurface();
  CreateLight0eSurface();
  CreateLight0fSurface();

  while not FboShowLogo do
  begin
    AppOnIdle();
    Sleep(1);
    Application.ProcessMessages;
    if GetTickCount > FdwShowLogoTick then
    begin
      FdwShowLogoTick := GetTickCount + 30;
      //if FnShowLogoIndex < 400 then

      Inc(FnShowLogoIndex, 5);
      if FnShowLogoIndex = 400 then
      begin
        InitWMImagesLib;
        CSocket.Active := TRUE;
        break;
      end;
    end;
  end;

  AppOnIdle();
  FrmDlg.Initialize;
  LoginScene.Initialize;

  AppOnIdle();
  DScreen.Initialize;

  AppOnIdle();
  Success := PlayScene.Initialize;
  if not Success then
  begin
    ErrorMsg := 'PlayScene Initialize Error';
    exit;
  end;

  AppOnIdle();

  Success := g_DXFont.Initialize(DEFFONTNAME, DEFFONTSIZE);
  if not Success then
  begin
    ErrorMsg := 'Font Initialize Error';
    exit;
  end;

  try
    AppOnIdle();
    ErrorMsg := 'Error Code = 1';
    LoadColorLevels();
    ErrorMsg := 'Error Code = 2';
    FBoShowLogo := True;
    ErrorMsg := 'Error Code = 3';
    g_boInitialize := False;
    ErrorMsg := 'Error Code = 4';
    TimerRun.Enabled := True;
    ErrorMsg := 'Error Code = 7';
    if g_boFullScreen then
    begin
      m_Point.X := 0;
      m_Point.Y := 0;
    end;
    asm
        finit;//D3D初始化引起时间错误, 重新初始化浮点单元解决问题
    end;
  except
    Success := False;
  end;
end;

procedure TfrmMain.MyDeviceRender(Sender: TObject);

  procedure LogoInitialize(MinImage: Integer);
  var
    d: TDXTexture;
  begin
    if g_LogoSurface <> nil then
    begin
      if FnShowLogoIndex < 256 then
      begin
        g_DXCanvas.Draw((g_FScreenWidth - g_LogoSurface.Width) div 2, (g_FScreenHeight - g_LogoSurface.Height) div 2 - 20, g_LogoSurface.ClientRect, g_LogoSurface, True, cColor4($FFFFFF or (FnShowLogoIndex shl 24)));
      end
      else if FnShowLogoIndex < 400 then
      begin
        g_DXCanvas.Draw((g_FScreenWidth - g_LogoSurface.Width) div 2, (g_FScreenHeight - g_LogoSurface.Height) div 2 - 20, g_LogoSurface.ClientRect, g_LogoSurface, True);
      end
      else if FnShowLogoIndex < 626 then
      begin
        d := WProgUse.Images[MinImage];
        if d <> nil then
          g_DXCanvas.Draw(0, 0, d.ClientRect, d, True, cColor4($FFFFFF or ((FnShowLogoIndex - 400) shl 24)));

        g_DXCanvas.Draw((g_FScreenWidth - g_LogoSurface.Width) div 2, (g_FScreenHeight - g_LogoSurface.Height) div 2 - 20, g_LogoSurface.ClientRect, g_LogoSurface, True, cColor4($FFFFFF or ((655 - FnShowLogoIndex) shl 24)));
      end
      else
      begin
        d := WProgUse.Images[MinImage];
        if d <> nil then
          g_DXCanvas.Draw(0, 0, d.ClientRect, d, True);
        FBoShowLogo := True;
        //FnShowLogoIndex := 0;
      end;
    end
    else
      FBoShowLogo := True;
  end;

var
  d: TDXTexture;
  p: TPoint;
begin
  if not FBoShowLogo then
  begin
    LogoInitialize(LOGINBAGIMGINDEX);
  end
  else if not g_boInitialize then
  begin
    ProcessFreeTexture;
    ProcessKeyMessages;
    ProcessActionMessages;

    if DScreen.CurrentScene = PlayScene then
    begin
      g_DXCanvas.Draw(SOFFX, SOFFY, PlayScene.MagSurface.ClientRect, PlayScene.MagSurface, True);
    end;

    DScreen.DrawScreen(g_DXCanvas.DrawTexture);

    if DropItemView then
      if TabClickTime + 3000 > GetTickCount then
      begin
        PlayScene.DropItemsShow(g_DXCanvas.DrawTexture);
      end;

    if g_boCanDraw then
    begin
      PlayScene.RenderMiniMap(g_DXCanvas.DrawTexture);
      g_DWinMan.DirectPaint(g_DXCanvas.DrawTexture);
      DScreen.DrawScreenTop(g_DXCanvas.DrawTexture);
      DScreen.DrawHint(g_DXCanvas.DrawTexture);
      if ItemMoving and g_boCanDraw then
      begin
        if (MovingItem.Item.S.Name <> '金币') then
          d := WBagItem.Images[MovingItem.Item.S.Looks]
        else
          d := WBagItem.Images[115];

        if d <> Nil then
        begin
          GetCursorPos(p);
          p.X := p.X - m_Point.X;
          p.Y := p.Y - m_Point.Y;
          g_DXCanvas.Draw(p.x - (d.ClientRect.Right div 2), p.y - (d.ClientRect.Bottom div 2), d.ClientRect, d, TRUE);
        end;
      end;

      if DoFadeOut then
      begin
        if FadeIndex < 1 then
          FadeIndex := 1;
        if FadeIndex <= 1 then
          DoFadeOut := FALSE
        else
          Dec(FadeIndex, 2);
      end
      else if DoFadeIn then
      begin
        if FadeIndex > 29 then
          FadeIndex := 29;
        if FadeIndex >= 29 then
          DoFadeIn := FALSE
        else
          Inc(FadeIndex, 2);
      end
      else if DoFastFadeOut then
      begin
        if FadeIndex < 1 then
          FadeIndex := 1;
        if FadeIndex > 1 then
          Dec(FadeIndex, 4);
      end;
    end;
  end;
end;

procedure TFrmMain.DisplayChange(boReset: Boolean);
var
  nWidth, nHeight: Integer;
begin
  if boReset then begin
    if FboDisplayChange then begin
      FormStyle := fsNormal;
      FIDDraw := nil;
      if FDDrawHandle > 0 then
        FreeLibrary(FDDrawHandle);
      FDDrawHandle := 0;
      FboDisplayChange := False;
      UnRegisterHotKey(Handle, FHotKeyId);
    end;
  end else begin
    if not FboDisplayChange then begin
      FormStyle := fsStayOnTop;
      if HGE.System_GetState(HGE_FScreenWidth) = g_FScreenWidth then begin
        nWidth := g_FScreenWidth;
        nHeight := g_FScreenHeight;
      end
      else begin
        nWidth := g_FScreenWidth;
        nHeight := g_FScreenHeight;
      end;
      
      FIDDraw := nil;
      if FDDrawHandle > 0 then
        FreeLibrary(FDDrawHandle);
      FDDrawHandle := LoadLibrary('DDraw.dll');

      if DD_OK = TDirectDrawCreate(GetProcAddress(FDDrawHandle, 'DirectDrawCreate'))(nil, FIDDraw, nil) then begin
        if DD_OK = FIDDraw.SetDisplayMode(nWidth, nHeight, 32) then begin          // WIN10 16改32
          FboDisplayChange := True;
          FHotKeyId := GlobalAddAtom('361ClientKey') - $C000;
          RegisterHotKey(Handle, FHotKeyId, MOD_ALT, VK_TAB);
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.MyDeviceNotifyEvent(Sender: TObject; Msg: Cardinal);
begin
  case Msg of
    msgDeviceLost:
      begin
        PlayScene.Lost;
        g_DXFont.Lost;
        DScreen.ClearHint(True);
        //DebugOutStr('DeviceLost');
      end;
    msgDeviceRecovered:
      begin
        PlayScene.Recovered;
        g_DXFont.Recovered;
        Map.OldClientRect := Rect(0, 0, 0, 0);
        DScreen.ClearHint(True);
        //DebugOutStr('DeviceRecovered');
      end;
    msgDeviceRestoreSize:
      begin
        ClientWidth := HGE.System_GetState(HGE_FScreenWidth);
        ClientHeight := HGE.System_GetState(HGE_FScreenHeight);
        if g_boFullScreen then
        begin
          if FIDDraw <> nil then
          begin
            if ClientWidth = g_FScreenWidth then
              FIDDraw.SetDisplayMode(g_FScreenWidth, g_FScreenHeight, 32)
            else
              FIDDraw.SetDisplayMode(g_FScreenWidth, g_FScreenHeight, 32);   //WIN10   16改32
          end;
          m_Point.X := 0;
          m_Point.Y := 0;
        end
        else
        begin
          Left := (Screen.width - ClientWidth) div 2;
          Top := (Screen.Height - ClientHeight) div 2 - 40;
          SetWindowPos(handle, HWND_NOTOPMOST, left, top, width, height, SWP_SHOWWINDOW);
        end;
      end;
  end;
end;

procedure TfrmMain.ProcessFreeTexture;
begin
  if GetTickCount > m_FreeTextureTick then
  begin
    m_FreeTextureTick := GetTickCount + 2000;
    while True do
    begin
      Inc(m_FreeTextureIndex);
      if not (m_FreeTextureIndex in [Low(g_ClientImages)..High(g_ClientImages)]) then
      begin
        m_FreeTextureIndex := Low(g_ClientImages);
      end;
      if (g_ClientImages[m_FreeTextureIndex] <> nil) and (g_ClientImages[m_FreeTextureIndex].SurfaceCount > 0) and (g_ClientImages[m_FreeTextureIndex].boInitialize) then
      begin
        g_ClientImages[m_FreeTextureIndex].FreeTextureByTime;
        Break;
      end;
    end;
  end;
end;

procedure TfrmMain.WMMove(var Message: TWMMove);
begin
  m_Point := ClientOrigin;
  inherited;
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FALSE;
  if (GetTickCount - LatestStruckTime > 10000) and (GetTickCount - LatestMagicTime > 10000) and (GetTickCount - LatestHitTime > 10000) or (Myself.Death) then
  begin
    Application.Terminate;
  end
  else
    DScreen.AddChatBoardString('在战斗的时候你不能退出游戏.', clYellow, clRed);
end;

procedure TFrmMain.TurnDuFu(pcm: PTClientMagic);
var
  s: TClientItem;
  Str,str1: string;
  i,index: Integer;
  RedDu, LimeDu, HuFu: Boolean;
begin
  RedDu := False;
  LimeDu := False;
  HuFu := False;
  //检查包裹里有什么毒
  if WaitingUseItem.Item.S.Name <> '' then Exit;
  for I:=6 to MAXBAGITEMCL - 1 do begin
    if (ItemArr[i].S.StdMode = 25) and (ItemArr[i].S.Name <> '') then begin
      if ItemArr[i].S.Shape = 1 then LimeDu := True
      else if ItemArr[i].S.Shape = 2 then RedDu := True
      else if ItemArr[i].S.Shape = 5 then HuFu := True;
    end;
  end;
  index:=U_ARMRINGL;       //毒放在四格改U_BUJUK
  s := UseItems[Index];
  if not LimeDu and not RedDu and not HuFu then Exit;
  if (pcm.Def.MagicId = 6) or (pcm.Def.MagicId = 38) then begin
    Str := '药';
    if LimeDu and RedDu then begin //如果2种毒都存在
      if g_nDuwhich=0 then begin
        str1:='黄';
        g_nDuwhich:=1;
      end else begin
        str1:='灰';
        g_nDuwhich:=0;
      end
    end else begin
      if LimeDu then begin
        str1:='灰';
        g_nDuwhich:=0;
      end else if RedDu then begin
        str1:='黄';
        g_nDuwhich:=1;
      end;
    end;
    if (s.s.StdMode = 25) and (Pos(Str1, s.s.Name) > 0) then Exit; //如果是相同的毒或符就退出

    WaitingUseItem.Index := index;
    for i := 6 to MAXBAGITEMCL - 1 do begin
      if (ItemArr[i].S.StdMode = 25) and (str1 <> '') and (Pos(Str, ItemArr[i].S.Name) > 0)and (Pos(Str1, ItemArr[i].S.Name) > 0) then begin
        SendTakeOnItem(WaitingUseItem.Index ,ItemArr[i].MakeIndex, ItemArr[i].S.Name);
        WaitingUseItem.Item := ItemArr[i];
        ItemArr[i].S.Name := '';
        ArrangeItembag;
        Exit;
      end;
    end;
  end else if (pcm.Def.MagicId in [13, 14, 15, 16, 17, 18, 19, 30, 36, 41, 46, 49]) then begin
    if (s.s.StdMode = 25) and (s.S.Shape = 5) and (s.S.Name <> '') then Exit;

    WaitingUseItem.Index := index;
    for i := 6 to MAXBAGITEMCL - 1 do begin
      if (ItemArr[i].s.StdMode = 25) and (ItemArr[i].s.Shape = 5) and (ItemArr[i].s.Name <> '') then begin
        SendTakeOnItem(WaitingUseItem.Index, ItemArr[i].MakeIndex, ItemArr[i].s.Name);
        WaitingUseItem.Item := ItemArr[i];
        ItemArr[i].s.Name := '';
        ArrangeItembag;
        Exit;
      end;
    end;
  end;
end;

procedure TFrmMain.ClientGetServerUnBind(Body: string);
var
  i: integer;
  data: string;
  pcm: pTUnbindInfo;
begin
  if g_UnbindItemList.Count > 0 then //20080629
    for i := 0 to g_UnbindItemList.Count - 1 do
      if pTUnbindInfo(g_UnbindItemList[i]) <> nil then
        Dispose(pTUnbindInfo(g_UnbindItemList[i]));
  g_UnbindItemList.Clear;
  while TRUE do begin
    if Body = '' then
      break;
    Body := GetValidStr3(Body, data, ['/']);
    if data <> '' then begin
      new(pcm);
      DecodeBuffer(data, @(pcm^), sizeof(TUnbindInfo));
      g_UnbindItemList.Add(pcm);
    end
    else
      break;
  end;
end;

procedure TFrmMain.ClientGetAttackMode( mode: byte);
begin
   MySelf.AttackMode := mode;
end;


procedure TfrmMain.CreateParams(var Params: TCreateParams);
  //随机取密码
  function RandomGetPass(): string;
  var
    s, s1: string;
    I, i0: Byte;
  begin
    s := '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
    s1 := '';
    Randomize(); //随机种子
    for i := 0 to 8 do begin
      i0 := random(35);
      s1 := s1 + copy(s, i0, 1);
    end;
    Result := s1;
  end;
begin
  inherited CreateParams(Params);
  strpcopy(pchar(@Params.WinClassName), RandomGetPass);
  Params.WndParent := 0; 
  //Params.WinClassName:=mssss;
end;

end.

