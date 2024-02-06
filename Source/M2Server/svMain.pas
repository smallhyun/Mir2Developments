unit svMain;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  D7ScktComp, RunSock, syncobjs, StdCtrls, ExtCtrls, FrnEngn, UsrEngn,
  Envir, IniFiles, itmunit, Magic, NoticeM, Guild, MudUtil, Event,
  Grobal2, FSrvValue, InterServerMsg, InterMsgClient, HUtil32, Buttons,
  M2Share, Castle, MfdbDef, ObjNpc , UserMgrEngn , DragonSystem,
  SQLEngn, DBSQL, EDcode, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPClient, Menus;

const
   ENGLISHVERSION = FALSE;    //ÀÌÅÂ¸®(À¯·´)
   PHILIPPINEVERSION = FALSE; //ÇÊ¸®ÇÉ
   CHINAVERSION = FALSE;
   TAIWANVERSION = FALSE;
   KOREANVERSION = TRUE;      //ÇÑ±¹

   SENDBLOCK: integer = 1024; //2048;  //°ÔÀÌÆ®¿Í Åë½ÅÇÏ±â ¶§¹®¿¡ ºí·°ÀÌ Å©´Ù.
   SENDCHECKBLOCK: integer = 4096; //2048;      //Ä³Å© ½ÅÈ£¸¦ º¸³½´Ù.
   SENDAVAILABLEBLOCK: integer = 7999; //4096;  //Ä³Å© ½ÅÈ£°¡ ¾ø¾îµµ ÀÌÁ¤µµ´Â º¸³½´Ù.
   GATELOAD: integer = 10; //10KB
   LINENOTICEFILE = 'Notice\LineNotice.txt';
   LINEHELPFILE = 'LineHelp.txt';
   BUILDGUILDFEE: integer = 1000000;

type
  TFrmMain = class(TForm)
    GateSocket: TServerSocket;
    Memo1: TMemo;
    Timer1: TTimer;
    RunTimer: TTimer;
    DBSocket: TClientSocket;
    ConnectTimer: TTimer;
    StartTimer: TTimer;
    Panel1: TPanel;
    SaveVariableTimer: TTimer;
    LbRunTime: TLabel;
    TCloseTimer: TTimer;
    LbUserCount: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    Label4: TLabel;
    LbTimeCount: TLabel;
    Label5: TLabel;
    LogUDP: TIdUDPClient;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    NPC1: TMenuItem;
    NPC2: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    procedure GateSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure GateSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure GateSocketClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure GateSocketClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure RunTimerTimer(Sender: TObject);
    procedure ConnectTimerTimer(Sender: TObject);
    procedure DBSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure DBSocketDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure DBSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure DBSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure StartTimerTimer(Sender: TObject);
    procedure SaveVariableTimerTimer(Sender: TObject);
    procedure TCloseTimerTimer(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure MakeStoneMines;
    procedure StartServer;
    procedure OnProgramException (Sender: TObject; E: Exception);
    function LoadClientFileCheckSum: Boolean;
  public
    procedure SaveItemNumber;
    procedure RefreshForm;
  end;


procedure MainOutMessage (str: string);
procedure AddUserLog (str: string);  //ÇÃ·¡ÀÌ¾îÀÇ Çàµ¿À» ±â·Ï
procedure AddUserConAlarmLog (str: string);
procedure AddConLog (str: string);  //Á¢¼Ó ±â·ÏÀ» ·Î±×·Î ³²±è
procedure AddChatLog (str: string);  //Ã¤ÆÃ ±â·ÏÀ» ·Î±×·Î ³²±è
function  GetCertifyNumber: integer;
function  GetItemServerIndex: integer;
function  DBConnected: Boolean;
procedure LoadMultiServerTables;
function  GetMultiServerAddrPort (servernum: byte; var addr: string; var port: integer): Boolean;
function  GetUnbindItemName (shape: integer): string;
function  LoadLineNotice (flname: string): Boolean;
function  LoadLineHelp (flname: string): Boolean;
function  GetStartPointMapName (index: integer): string;
function  DecodeStringPassword( var src: string; key: integer ): string;
procedure LoadSetupIniInfo;

var
  FrmMain: TFrmMain;
  RunSocket: TRunSocket;
  FrontEngine: TFrontEngine;
  UserEngine: TUserEngine;
  UserMgrEngine : TUserMgrEngine;
  GrobalEnvir: TEnvirList;
  ItemMan: TItemUnit;
  MagicMan: TMagicManager;
  NoticeMan: TNoticeManager;
  GuildMan: TGuildManager;
  GuildAgitMan: TGuildAgitManager;  //¹®ÆÄÀå¿ø(sonmg)
  GuildAgitBoardMan: TGuildAgitBoardManager;  //Àå¿ø°Ô½ÃÆÇ(sonmg)
  GuildAgitStartNumber: integer;   //¹®ÆÄÀå¿ø ½ÃÀÛ¹øÈ£(MapInfo¿¡¼­ ÀÐ¾î¿È).
  GuildAgitMaxNumber: integer;   //¹®ÆÄÀå¿ø ÃÖ´ë°³¼ö(MapInfo¿¡¼­ ÀÐ¾î¿È).
  EventMan: TEventManager;
  UserCastle: TUserCastle;
  boUserCastleInitialized : Boolean;
  gFireDragon: TDragonSystem;

  DecoItemList: TStringList;  //Àå¿ø²Ù¹Ì±â
  MakeItemList: TStringList;  // list of TStringList;
  MakeItemIndexList: TStringList;  // Á¦Á¶ ¾ÆÀÌÅÛ ±¸ºÐ Index ¸®½ºÆ®.
  StartPoints: TStringList;
  SafePoints: TStringList;
  MultiServerList: TList;
  ShutUpList: TQuickList; //Ã¤ÆÃ±ÝÁö ¸®½ºÆ®
  MiniMapList: TStringList;
  UnbindItemList: TStringList;
  LineNoticeList: TStringList;
  LineHelpList: TStringList;
  QuestDiaryList: TList;  //list of TList of TList(PTQDDinfo)
                                      //TQDDinfo // [n] index or unit index
                                                 // TStringList
  StartupQuestNpc: TMerchant;
  DefaultNpc: TMerchant;

  EventItemList: TStringList;   //À¯´ÏÅ© ¾ÆÀÌÅÛ ÀÌº¥Æ®¸¦ À§ÇÑ ¸®½ºÆ®
  EventItemGifeBaseNumber: integer;
  GrobalQuestParams: array[0..9] of integer;
  GrobalStringParams: array[0..99] of string;

  ErrorLogFile: string;
  MirDayTime: integer;  //¹Ì¸£ÀÇ ½Ã°£... Çö½Ç ½Ã°£ÀÇ 2¹è ºü¸§
  ServerIndex: integer;
  ServerName: string;
  ServerNumber: integer;

  BoVentureServer: Boolean;
  BoTestServer: Boolean;
  BoClientTest: Boolean;
  TestLevel: integer;
  TestGold: integer;
  TestServerMaxUser: integer;
  BoServiceMode: Boolean;
  BoNonPKServer: Boolean;
  BoViewHackCode: Boolean;
  BoViewAdmissionfail: Boolean;
  BoGetGetNeedNotice: Boolean;
  GetGetNoticeTime: longword;

  UserFullCount: integer;
  ZenFastStep: integer;
  BoSysHasMission: Boolean;    //ÀÌº¥Æ®¿ë, ¹Ì¼ÇÀÌ ÀÖ´ÂÁö
  SysMission_Map: string;
  SysMission_X: integer;
  SysMission_Y: integer;
  TotalUserCount: integer;  //Àü¼­¹ö¸¦ ÅëÅÐÀº »ç¿ëÀÚ¼ö

  csMsgLock: TCriticalSection;
  csTimerLock: TCriticalSection;
  csObjMsgLock: TCriticalSection;
  csSendMsgLock: TCriticalSection;
  csShare: TCriticalSection;  //µ¿±âÈ­ ½Ã°£ÀÌ ¤FÀº °øÀ¯º¯¼ö¿¡ »ç¿ëÇØ¾ß ÇÔ.
  csDelShare: TCriticalSection;  //µ¿±âÈ­ ½Ã°£ÀÌ ¤FÀº °øÀ¯º¯¼ö¿¡ »ç¿ëÇØ¾ß ÇÔ.
  csSocLock: TCriticalSection;
  usLock: TCriticalSection;   //user engine thread
  usIMLock: TCriticalSection;   //user engine thread
  ruLock: TCriticalSection;   // run sock
  ruSendLock: TCriticalSection;   // run sock
  ruCloseLock: TCriticalSection;   // run sock
  socstrLock: TCriticalSection;
  fuLock: TCriticalSection;   //front engine thread
  fuOpenLock: TCriticalSection;   //front engine thread
  fuCloseLock: TCriticalSection;   //front engine thread
  humanLock: TCriticalSection;   // human sendbufer
  umLock: TCriticalSection;   //User Manager engine thread
  SQLock: TCriticalSection;   // SQL Engine Thread

  MainMsg: TStringList;
  UserLogs: TStringList;  //ÇÃ·¡ÀÌ¾îÀÇ Çàµ¿ ·Î±×
  UserConAlarmLogs: TStringList;  //Æ¯Á¤ Çàµ¿ À¯ÀúÀÇ Á¢¼Ó/Çàµ¿ ·Î±×
  UserConLogs: TStringList;  //Á¢¼Ó ·Î±×
  UserChatLog: TStringList;  //Ã¤ÆÃ ·Î±×
  DiscountForNightTime: Boolean;
  HalfFeeStart: integer;  //ÇÒÀÎ½Ã°£ ½ÃÀÛ
  HalfFeeEnd: integer;   //ÇÒÀÎ½Ã°£ ³¡

  ServerReady: Boolean;       //¼­¹ö°¡ »ç¿ëÀÚ¸¦ ¹ÞÀ» ÁØºñ°¡ µÇ¾ú´Â°¡?
  ServerClosing: Boolean;
  FCertify, FItemNumber: integer;
  RDBSocData: string;
  ReadyDBReceive: Boolean;
  RunFailCount: integer;
  MirUserLoadCount: integer;
  MirUserSaveCount: integer;
  CurrentDBloadingTime: longword;
  BoEnableAbusiveFilter: Boolean;
  LottoSuccess, LottoFail: integer;
  Lotto1, Lotto2, Lotto3, Lotto4, Lotto5, Lotto6: integer;

  MsgServerAddress: string;
  MsgServerPort: integer;
  LogServerAddress: string;
  LogServerPort: integer;
  ShareBaseDir: string;
  ShareVentureDir: string;
  ShareFileNameNum: integer;
  ConLogBaseDir: string;  //Á¢¼Ó ½Ã°£ ·Î±×
  ChatLogBaseDir: string;  //Á¢¼Ó ½Ã°£ ·Î±×

  DefHomeMap: string;  //°¢ ¼­¹ö¸¶´Ù ²À ÀÖ¾î¾ß ÇÏ´Â ¸Ê
  DefHomeX: integer;
  DefHomeY: integer;
  GuildDir: string;
  GuildFile: string;
  GuildBaseDir: string;
  GuildAgitFile: string;
  CastleDir: string;
  EnvirDir: string;
  MapDir: string;

  CurrentMonthlyCard: integer;    //¿ùÁ¤¾× »ç¿ëÀÚ ¼ö
  TotalTimeCardUsage: integer;  //½Ã°£Á¦ Ä«µå »ç¿ëÀÚÀÇ »ç¿ë ÃÑ ½Ã°£ //½Ã°£
  LastMonthTotalTimeCardUsage: integer;   //½Ã°£
  GrossTimeCardUsage: integer;    //½Ã°£
  GrossResetCount: integer;

  serverruntime: longword;
  runstart: longword;
  rcount: integer;
  minruncount: integer;
  curruncount: integer;
  maxsoctime: integer;
  cursoctime: integer;
  maxusrtime: integer;
  curusrcount: integer;
  curhumtime: integer;
  maxhumtime: integer;
  curmontime: integer;
  maxmontime: integer;
  humrotatetime: longword;
  curhumrotatetime: integer;
  maxhumrotatetime: integer;
  humrotatecount: integer;
  LatestGenStr: string[30];
  LatestMonStr: string[30];

  HumLimitTime: longword;
  MonLimitTime: longword;
  ZenLimitTime: longword;
  NpcLimitTime: longword;
  SocLimitTime: longword;
  DecLimitTime: longword;

  //ÀÌ¸§µé
  __ClothsForMan: string;
  __ClothsForWoman: string;
  __WoodenSword: string;
  __Candle: string;
  __BasicDrug: string;

  __GoldStone: string;
  __SilverStone: string;
  __SteelStone: string;
  __CopperStone: string;
  __BlackStone: string;
  __Gem1Stone: string;
  __Gem2Stone: string;
  __Gem3Stone: string;
  __Gem4Stone: string;

  __ZumaMonster1: string;
  __ZumaMonster2: string;
  __ZumaMonster3: string;
  __ZumaMonster4: string;

  __Bee             : string;
  __Spider          : string;
  __WhiteSkeleton   : string;
  __ShinSu          : string;
  __ShinSu1         : string;
  __AngelMob        : string;
  __CloneMob        : string;
  __WomaHorn        : string;
  __ZumaPiece       : string;

  __GoldenImugi     : string;
  __WhiteSnake      : string;


  ClientFileName1: string;
  ClientFileName2: string;
  ClientFileName3: string;
  ClientCheckSumValue1: integer;
  ClientCheckSumValue2: integer;
  ClientCheckSumValue3: integer;

  UserSendAllMsgType: integer;
  UserSendAllMsgGold: integer;
  UserSendAllMsgPotCash: integer;
  ExtraMsgInfo: string;

  ExtraExp: array [0..7] of word;
  ExtraLowLevel: array [0..7] of integer;
  ExtraHighLevel: array [0..7] of integer;

  ApprenticeMinLevel: word;
  ApprenticeMaxLevel: word;
  MasterOKLevel: word;
  MasterCreditPointCount: byte;
  ApprenticeLevel: array [0..99] of byte;
  ApprenticeCreditPoint: array [0..99] of integer;
  MasterCreditPoint: array [0..99] of integer;
  //µð¹ö±ë Á¤º¸
  gErrorCount :integer;
  g_TestTime : integer;

  //½ºÇÙÃ¼Å©
  g_SpeedHackCheck : integer;
  g_SpeedHackCheckChar : string;

  //¿ÜÄ¡±â ¹üÀ§
  g_CryWide : integer;
  //ÇöÀç »ý¼ºÁßÀÎ Merchant Index
  CurrentMerchantIndex : integer;
  ServerTickDifference: longword;

  //¾ÆÀÌÅÛ ÀÎµ¦½º ÁöÁ¤
  INDEX_CHOCOLATE: integer;  //ÃÊÄÝ·¿
  INDEX_CANDY: integer;      //»çÅÁ
  INDEX_LOLLIPOP: integer;   //¸·´ë»çÅÁ
  INDEX_MIRBOOTS: integer;   //Ãµ·æ½ÅÇàº¸

implementation

{$R *.DFM}

uses
   LocalDB, IdSrvClient;


function IntTo_Str (val: integer): string;
begin
   if val < 10 then Result := '0' + IntToStr(val)
   else Result := IntToStr(val);
end;

function  CheckFileCheckSum (flname: string): integer;
type
   pNativeInt = ^NativeInt;
var
   pbuf: PAnsiChar;
   i, n, handle, bsize, cval, csum: NativeInt;
begin
   Result := 0;
   if FileExists (flname) then begin
      handle := FileOpen (flname, fmOpenRead or fmShareDenyNone);
      if handle > 0 then begin
         bsize := FileSeek (handle, 0, 2);
         GetMem (pbuf, (bsize+3) div 4 * 4);
         FillChar (pbuf^, (bsize+3) div 4 * 4, 0);
         FileSeek (handle, 0, 0);
         FileRead (handle, pbuf^, bsize);
         FileClose (handle);

         csum := 0;
         for i:=0 to (bsize+3) div 4 - 1 do begin
            cval := pinteger (pbuf)^;
            pbuf := PAnsiChar (NativeInt(pbuf) + 4);
            csum := csum xor cval;
         end;

         Result := csum;
      end;
   end;
end;


procedure TFrmMain.RefreshForm;
begin
   Application.ProcessMessages;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
   fname, str: string;
   ini: TIniFile;
   ayear, amon, aday, ahour, amin, asec, amsec ,runPort: word;
   fhandle: TextFile;
begin
   gErrorCount := 0;
   Randomize;
   ServerIndex := 0;

   RunSocket := TRunSocket.Create;
   MainMsg := TStringList.Create;
   UserLogs := TStringList.Create;
   UserConAlarmLogs := TStringList.Create;
   UserConLogs := TStringList.Create;
   UserChatLog := TStringList.Create;
   GrobalEnvir := TEnvirList.Create;
   ItemMan := TItemUnit.Create;
   MagicMan := TMagicManager.Create;
   NoticeMan := TNoticeManager.Create;
   GuildMan := TGuildManager.Create;
   GuildAgitMan := TGuildAgitManager.Create; //¹®ÆÄÀå¿ø(sonmg)
   GuildAgitBoardMan := TGuildAgitBoardManager.Create;  //Àå¿ø°Ô½ÃÆÇ(sonmg)
   EventMan := TEventManager.Create;
   UserCastle := TUserCastle.Create;
   boUserCastleInitialized := FALSE;
   //¿ë´øÀü ½Ã½ºÅÛ
   gFireDragon := TDragonSystem.Create;

   FrontEngine  := TFrontEngine.Create;
   UserEngine   := TUserEngine.Create;
   // Ä£±¸ ÂÊÁö ½Ã½ºÅÛ
   UserMgrEngine:= TUserMgrEngine.Create;

   // DBSQL
   g_DBSQL   := TDBSQL.Create;
   SQLEngine := TSQLEngine.Create;


   DecoItemList := TStringList.Create;
   MakeItemList := TStringList.Create;
   MakeItemIndexList := TStringList.Create;
   StartPoints := TStringList.Create;
   SafePoints := TStringList.Create;
   MultiServerList := TList.Create;
   ShutUpList := TQuickList.Create;
   MiniMapList := TStringList.Create;
   UnbindItemList := TStringList.Create;
   LineNoticeList := TStringList.Create;
   LineHelpList := TStringList.Create;
   QuestDiaryList := TList.Create;
   StartupQuestNpc := nil;
   DefaultNpc := nil;
   
   EventItemList := TStringList.Create;
   EventItemGifeBaseNumber := 0;

   csMsgLock    := TCriticalSection.Create;
   csTimerLock  := TCriticalSection.Create;
   csObjMsgLock := TCriticalSection.Create;
   csSendMsgLock:= TCriticalSection.Create;
   csShare      := TCriticalSection.Create;
   csDelShare   := TCriticalSection.Create;
   csSocLock    := TCriticalSection.Create;
   usLock       := TCriticalSection.Create;
   usIMLock     := TCriticalSection.Create;
   ruLock       := TCriticalSection.Create;
   ruSendLock   := TCriticalSection.Create;
   ruCloseLock  := TCriticalSection.Create;
   socstrLock   := TCriticalSection.Create;
   fuLock       := TCriticalSection.Create;
   fuOpenLock   := TCriticalSection.Create;
   fuCloseLock  := TCriticalSection.Create;
   HumanLock    := TCriticalSection.Create; // À§¿¡°ÍµéÀº ¿Ö ÇÁ¸® ¾ÈÇÒ±î...
   umLock       := TCriticalSection.Create;
   SQLock       := TCriticalSection.Create;

   RDBSocData := '';
   ReadyDBReceive := FALSE;
   RunFailCount := 0;
   MirUserLoadCount := 0;
   MirUserSaveCount := 0;
   BoGetGetNeedNotice := FALSE;

   FCertify := 0;
   FItemNumber := 0;
   ServerReady := FALSE;
   ServerClosing := FALSE;
   BoEnableAbusiveFilter := TRUE;
   LottoSuccess := 0;
   LottoFail := 0;
   Lotto1 := 0;
   Lotto2 := 0;
   Lotto3 := 0;
   Lotto4 := 0;
   Lotto5 := 0;
   Lotto6 := 0;

   CurrentMerchantIndex := 0;
   ServerTickDifference := 0;

   FillChar (GrobalQuestParams, sizeof(GrobalQuestParams), #0);
   FillChar (GrobalStringParams, sizeof(GrobalStringParams), #0);

   DecodeDate (Date, ayear, amon, aday);
   DecodeTime (Time, ahour, amin, asec, amsec);
   ErrorLogFile := '.\Log\' +
                   IntToStr(ayear) + '-' + IntToStr(amon) + '-' + IntTo_Str(aday) +
                   '.' +
                   IntTo_Str(ahour) +
                   '-' +
                   IntTo_Str(amin) +
                   '.log';
   AssignFile (fhandle, ErrorLogFile);
   Rewrite (fhandle);
   CloseFile (fhandle);

   minruncount := 99999;
   maxsoctime := 0;
   maxusrtime := 0;
   maxhumtime := 0;
   maxmontime := 0;
   curhumrotatetime := 0;
   maxhumrotatetime := 0;
   humrotatecount := 0;


   HumLimitTime := 30;
   MonLimitTime := 30;
   ZenLimitTime := 5;
   NpcLimitTime := 5;
   SocLimitTime := 10;
   DecLimitTime := 20;

   Memo1.Lines.Add ('×¼±¸¼ÓÔØÅäÖÃÐÅÏ¢..');
   fname := '.\!setup.txt';
   if FileExists (fname) then begin
      ini := TIniFile.Create (fname);
      if ini <> nil then begin
         ServerIndex := ini.ReadInteger ('Server', 'ServerIndex', 0);
         ServerName := ini.ReadString ('Server', 'ServerName', '');
         ServerNumber := ini.ReadInteger ('Server', 'ServerNumber', 0);
         str := ini.ReadString ('Server', 'VentureServer', 'FALSE');
         BoVentureServer := (CompareText(str, 'TRUE') = 0);

         str := ini.ReadString ('Server', 'TestServer', 'FALSE');
         BoTestServer := (CompareText(str, 'TRUE') = 0);
         //Å¬¶óÀÌ¾ðÆ® Å×½ºÆ®¿ë
         str := ini.ReadString ('Server', 'ClientTest', 'FALSE');
         BoClientTest := (CompareText(str, 'TRUE') = 0);

         TestLevel := ini.ReadInteger ('Server', 'TestLevel', 1);
         TestGold := ini.ReadInteger ('Server', 'TestGold', 0);
         TestServerMaxUser := ini.ReadInteger ('Server', 'TestServerUserLimit', 500);

         str := ini.ReadString ('Server', 'ServiceMode', 'FALSE');
         BoServiceMode := (CompareText(str, 'TRUE') = 0);

         str := ini.ReadString ('Server', 'NonPKServer', 'FALSE');
         BoNonPKServer := (CompareText(str, 'TRUE') = 0);

         str := ini.ReadString ('Server', 'ViewHackMessage', 'TRUE');
         BoViewHackCode := (CompareText(str, 'TRUE') = 0);

         str := ini.ReadString ('Server', 'ViewAdmissionFailure', 'FALSE');
         BoViewAdmissionfail := (CompareText(str, 'TRUE') = 0);

         DefHomeMap := ini.ReadString ('Server', 'HomeMap', '0');
         DefHomeX := ini.ReadInteger ('Server', 'HomeX', 289);
         DefHomeY := ini.ReadInteger ('Server', 'HomeY', 618);
         runPort :=  ini.ReadInteger ('Server', 'RunPort', 5000);
         with GateSocket do begin
           Port := runPort;
           Open;
         end;
         with DBSocket do begin
            Address := ini.ReadString ('Server', 'DBAddr', '210.121.143.205');
            Port := ini.ReadInteger ('Server', 'DBPort', 6000);
            Active := TRUE;
         end;
         FItemNumber := ini.ReadInteger ('Setup', 'ItemNumber', 0);

         HumLimitTime := ini.ReadInteger ('Server', 'HumLimit', HumLimitTime);
         MonLimitTime := ini.ReadInteger ('Server', 'MonLimit', MonLimitTime);
         ZenLimitTime := ini.ReadInteger ('Server', 'ZenLimit', ZenLimitTime);
         NpcLimitTime := ini.ReadInteger ('Server', 'NpcLimit', NpcLimitTime);
         SocLimitTime := ini.ReadInteger ('Server', 'SocLimit', SocLimitTime);
         DecLimitTime := ini.ReadInteger ('Server', 'DecLimit', DecLimitTime);

         SENDBLOCK := ini.ReadInteger ('Server', 'SendBlock', SENDBLOCK);
         SENDCHECKBLOCK := ini.ReadInteger ('Server', 'CheckBlock', SENDCHECKBLOCK);
         SENDAVAILABLEBLOCK := ini.ReadInteger ('Server', 'AvailableBlock', SENDAVAILABLEBLOCK);
         GATELOAD := ini.ReadInteger ('Server', 'GateLoad', GATELOAD);

         UserFullCount := ini.ReadInteger ('Server', 'UserFull', 500);
         ZenFastStep := ini.ReadInteger ('Server', 'ZenFastStep', 300);

         MsgServerAddress := ini.ReadString ('Server', 'MsgSrvAddr', '210.121.143.205');
         MsgServerPort := ini.ReadInteger ('Server', 'MsgSrvPort', 4900);

         LogServerAddress := ini.ReadString ('Server', 'LogServerAddr', '192.168.0.152');
         LogServerPort := ini.ReadInteger ('Server', 'LogServerPort', 10000);

         DiscountForNightTime := ini.ReadBool ('Server', 'DiscountForNightTime', FALSE);
         HalfFeeStart := ini.ReadInteger ('Server', 'HalfFeeStart', 2);  //2½Ã
         HalfFeeEnd := ini.ReadInteger ('Server', 'HalfFeeEnd', 10);  //10½Ã

         ShareBaseDir := ini.ReadString ('Share', 'BaseDir', 'D:\');
         ShareFileNameNum := 1;
         GuildDir := ini.ReadString ('Share', 'GuildDir', 'D:\');
         GuildFile := ini.ReadString ('Share', 'GuildFile', 'D:\');
         // Àå¿ø ¸ñ·Ï ÆÄÀÏ.
         GuildBaseDir := ExtractFileDir(GuildFile) + '\';  //Æú´õ´Â GuildFile°ú °°ÀÌ »ç¿ë(sonmg)
         GuildAgitFile := GuildBaseDir + 'GuildAgitList.txt';   //ÆÄÀÏÀÌ¸§ ÇÏµåÄÚµù(sonmg)

         ShareVentureDir := ini.ReadString ('Share', 'VentureDir', 'D:\');
         ConLogBaseDir := ini.ReadString ('Share', 'ConLogDir', 'D:\');
         ChatLogBaseDir := ini.ReadString ('Share', 'ChatLogDir', 'D:\');
         CastleDir := ini.ReadString ('Share', 'CastleDir', 'D:\');
         EnvirDir := ini.ReadString ('Share', 'EnvirDir', '.\Envir\');
         MapDir := ini.ReadString ('Share', 'MapDir', '.\Map\');

         ClientFileName1 := ini.ReadString ('Setup', 'ClientFile1', '');
         ClientFileName2 := ini.ReadString ('Setup', 'ClientFile2', '');
         ClientFileName3 := ini.ReadString ('Setup', 'ClientFile3', '');

         __ClothsForMan := ini.ReadString ('Names', 'ClothsMan', '');
         __ClothsForWoman := ini.ReadString ('Names', 'ClothsWoman', '');
         __WoodenSword := ini.ReadString ('Names', 'WoodenSword', '');
         __Candle := ini.ReadString ('Names', 'Candle', '');
         __BasicDrug := ini.ReadString ('Names', 'BasicDrug', '');

         __GoldStone := ini.ReadString ('Names', 'GoldStone', '');
         __SilverStone := ini.ReadString ('Names', 'SilverStone', '');
         __SteelStone := ini.ReadString ('Names', 'SteelStone', '');
         __CopperStone := ini.ReadString ('Names', 'CopperStone', '');
         __BlackStone := ini.ReadString ('Names', 'BlackStone', '');
         __Gem1Stone := ini.ReadString ('Names', 'Gem1Stone', '');
         __Gem2Stone := ini.ReadString ('Names', 'Gem2Stone', '');
         __Gem3Stone := ini.ReadString ('Names', 'Gem3Stone', '');
         __Gem4Stone := ini.ReadString ('Names', 'Gem4Stone', '');

         __ZumaMonster1 := ini.ReadString ('Names', 'Zuma1', '');
         __ZumaMonster2 := ini.ReadString ('Names', 'Zuma2', '');
         __ZumaMonster3 := ini.ReadString ('Names', 'Zuma3', '');
         __ZumaMonster4 := ini.ReadString ('Names', 'Zuma4', '');

         __Bee      := ini.ReadString ('Names', 'Bee', '');
         __Spider   := ini.ReadString ('Names', 'Spider', '');
         __WhiteSkeleton := ini.ReadString ('Names', 'Skeleton', '');
         __ShinSu   := ini.ReadString ('Names', 'Dragon', '');
         __ShinSu1  := ini.ReadString ('Names', 'Dragon1', '');
         __AngelMob := ini.ReadString ('Names', 'Angel', '');
         __CloneMob := ini.ReadString ('Names', 'Clone', '');

         __WomaHorn := ini.ReadString ('Names', 'WomaHorn', '');
         BUILDGUILDFEE := ini.ReadInteger ('Names', 'BuildGuildFee', BUILDGUILDFEE);
         __ZumaPiece := ini.ReadString ('Names', 'ZumaPiece', '');

         __GoldenImugi := ini.ReadString ('Names', 'GoldenImugi', '');
         __WhiteSnake  := ini.ReadString ('Names', 'WhiteSnake', '');

         ini.Free;
      end;
      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØÅäÖÃÎÄ¼þ!setup.txt..');
   end else
      ShowMessage ('ÖØ´ó´íÎó£¡È±ÉÙµµ°¸!setup.txt...');

   if (__ClothsForMan = '') or
      (__ClothsForWoman = '') or
      (__WoodenSword = '') or
      (__Candle = '') or
      (__BasicDrug = '') or
      (__GoldStone = '') or
      (__SilverStone = '') or
      (__SteelStone = '') or
      (__CopperStone = '') or
      (__BlackStone = '') or
      (__Gem1Stone = '') or
      (__Gem2Stone = '') or
      (__Gem3Stone = '') or
      (__Gem4Stone = '') or
      (__ZumaMonster1 = '') or
      (__ZumaMonster2 = '') or
      (__ZumaMonster3 = '') or
      (__ZumaMonster4 = '') or
      (__Bee = '') or
      (__Spider = '') or
      (__WhiteSkeleton = '') or
      (__ShinSu = '') or
      (__ShinSu1 = '') or
      (__AngelMob = '') or
      (__CloneMob = '') or
      (__WomaHorn = '') or
      (__ZumaPiece = '') or
      (__GoldenImugi = '') or
      (__WhiteSnake = '') then
      ShowMessage ('Check your !setup.txt file. [Names] -> ClothsForMan ...');

   //¹öÀüº° ¾ÆÀÌÅÛ ÀÎµ¦½º ÁöÁ¤
   if KOREANVERSION then begin
      INDEX_CHOCOLATE := 661; //ÃÊÄÝ·¿
      INDEX_CANDY     := 666; //»çÅÁ
      INDEX_LOLLIPOP  := 667; //¸·´ë»çÅÁ
      INDEX_MIRBOOTS  := 642; //Ãµ·æ½ÅÇàº¸
   end else if ENGLISHVERSION then begin
      INDEX_CHOCOLATE := 1; //ÃÊÄÝ·¿
      INDEX_CANDY     := 594; //»çÅÁ
      INDEX_LOLLIPOP  := 595; //¸·´ë»çÅÁ
      INDEX_MIRBOOTS  := 477; //Ãµ·æ½ÅÇàº¸
   end else if PHILIPPINEVERSION then begin
      INDEX_CHOCOLATE := 611; //ÃÊÄÝ·¿
      INDEX_CANDY     := 556; //»çÅÁ
      INDEX_LOLLIPOP  := 557; //¸·´ë»çÅÁ
      INDEX_MIRBOOTS  := 1; //Ãµ·æ½ÅÇàº¸
   end;

{$IFDEF MIR2EI}
   Caption := '[ei] ' + ServerName + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time);
   Panel1.Color := clLime;
{$ELSE}
   // 2003/04/01 ¹öÁ¯ ¹øÈ£ Ç¥±â
   Caption := ServerName + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time) + ' V' + IntToStr(VERSION_NUMBER);
{$ENDIF}
   LoadSetupIniInfo;

   LoadMultiServerTables;

   LogUDP.Host := LogServerAddress;
   LogUDP.Port := LogServerPort;

   ConnectTimer.Enabled := TRUE;
   Application.OnException := OnProgramException;

   CurrentDBloadingTime := GetTickCount;
   serverruntime := GetTickCount;

   StartTimer.Enabled := TRUE;
   Timer1.Enabled := TRUE;

   g_TestTime := 0;
   g_CryWide := 150;  //»Æ×Ö·¶Î§ 150

   //½ºÇÙÃ¼Å©
   g_SpeedHackCheck := 300;
   g_SpeedHackCheckChar := '';
end;

procedure TFrmMain.OnProgramException (Sender: TObject; E: Exception);
begin
   if gErrorCount > 20000 then
   begin
     gErrorCount := 0;
//   if Sender <> nil then
//       MainOutMessage (Sender.ClassName +':'+E.Message + formatdatetime('hh:nn:ss',now))
//   else
       MainOutMessage (E.Message + formatdatetime('hh:nn:ss',now));
   end;
   gErrorCount := gErrorCount + 1;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   SaveItemNumber;
   //¼­¹ö ¿À·ù³µÀ»¶§ »çºÏ¼º ÆÄÀÏÀÌ ÃÊ±âÈ­µÇ´Â °ÍÀ» ¸·±âÀ§ÇÑ ÄÚµå(sonmg 2004/08/13)
   if boUserCastleInitialized then
      UserCastle.SaveAll;

   FrontEngine.Terminate;
   FrontEngine.Free;

   UserEngine.Free;
   //Ä£±¸ ÂÊÁö ½Ã½ºÅÛ
   UserMgrEngine.Terminate;
   UserMgrEngine.Free;

   //DBSQL
   SQLEngine.Terminate;
   g_DBSQL.Free;
   SQLEngine.Free;

   RunSocket.Free;
   MainMsg.Free;
   UserLogs.Free;
   UserConAlarmLogs.Free;
   UserConLogs.Free;
   UserChatLog.Free;
   GrobalEnvir.Free;
   ItemMan.Free;
   MagicMan.Free;
   NoticeMan.Free;
   GuildMan.Free;
   GuildAgitMan.Free;   //¹®ÆÄÀå¿ø(sonmg)
   GuildAgitBoardMan.Free; //Àå¿ø°Ô½ÃÆÇ(sonmg)
   EventMan.Free;
   UserCastle.Free;
   gFireDragon.Free;

   DecoItemList.Free;
   MakeItemList.Free;
   MakeItemIndexList.Free;
   StartPoints.Free;
   SafePoints.Free;
   MultiServerList.Free;
   EventItemList.Free;

   csMsgLock.Free;
   csTimerLock.Free;
   csObjMsgLock.Free;
   csSendMsgLock.Free;
   csShare.Free;
   csDelShare.Free;
   csSocLock.Free;
end;

procedure TFrmMain.SaveItemNumber;
var
   fname: string;
   ini: TIniFile;
begin
   fname := '.\!setup.txt';
   ini := TIniFile.Create (fname);
   if ini <> nil then begin
      ini.WriteInteger ('Setup', 'ItemNumber', FItemNumber);
      ini.Free;
   end;
end;

function GetCertifyNumber: integer;
begin
   Inc (FCertify);
   if FCertify > $7FFE then FCertify := 1;
   Result := FCertify;
end;

function GetItemServerIndex: integer;
begin
   Inc (FItemNumber);
   if FItemNumber > $7FFFFFFE then FItemNumber := 1;
   Result := FItemNumber;
end;

procedure LoadMultiServerTables;
var
   i, k: integer;
   str, snum, saddr, sport: string;
   strlist, slist: TStringList;
begin
   for i:=0 to MultiServerList.Count-1 do
      TStringList(MultiServerList[i]).Free;
   MultiServerList.Clear;

   if FileExists ('!servertable.txt') then begin
      strlist := TStringList.Create;
      strlist.LoadFromFile ('!servertable.txt');
      for i:=0 to strlist.Count-1 do begin
         str := Trim(strlist[i]);
         if str <> '' then begin
            if str[1] = ';' then continue;
            str := GetValidStr3 (str, snum, [' ', #9]);
            if str <> '' then begin
               slist := TStringList.Create;
               for k:=0 to 30 do begin
                  if str = '' then break;
                  str := GetValidStr3 (str, saddr, [' ', #9]);
                  str := GetValidStr3 (str, sport, [' ', #9]);
                  if (saddr <> '') and (sport <> '') then begin
                     slist.AddObject (saddr, TObject(Str_ToInt(sport, 0)));
                  end;
               end;
               MultiServerList.Add (slist);
            end;
         end;
      end;
   end else
      ShowMessage ('File not found... <!servertable.txt>');
end;

function  GetMultiServerAddrPort (servernum: byte; var addr: string; var port: integer): Boolean;
var
   n: integer;
   slist: TStringList;
begin
   Result := FALSE;
   if servernum < MultiServerList.Count then begin
      slist := TStringList(MultiServerList[servernum]);
      n := Random (slist.Count);
      addr := slist[n];
      port := Integer(slist.Objects[n]);
      Result := TRUE;
   end else
      MainOutMessage ('GetMultiServerAddrPort Fail..:'+ IntToStr(servernum));
end;

function  GetUnbindItemName (shape: integer): string;
var
   i: integer;
begin
   Result := '';
   for i:=0 to UnbindItemList.Count-1 do begin
      if Integer(UnbindItemList.Objects[i]) = shape then begin
         Result := UnbindItemList[i];
         break;
      end;
   end;
end;

function  LoadLineNotice (flname: string): Boolean;
begin
   Result := FALSE;
   if FileExists (flname) then begin
      LineNoticeList.LoadFromFile (flname);
      CheckListValid (LineNoticeList);
      Result := TRUE;
   end;
end;

function  LoadLineHelp (flname: string): Boolean;
begin
   Result := FALSE;
   if FileExists (flname) then begin
      LineHelpList.LoadFromFile (flname);
      CheckListValid (LineHelpList);
      Result := TRUE;
   end;
end;

//ÇØ´ç indexÀÇ StartPoint ¸Ê ÀÌ¸§À» ¾ò¾î¿À´Â ÇÔ¼ö(sonmg 2005/12/28)
function  GetStartPointMapName (index: integer): string;
var
   str, mapstr, rangestr: string;
begin
   str := '';
   Result := '';
   if index < 0 then exit;
   if StartPoints.Count <= 0 then exit;

   if (index < StartPoints.Count) then begin
      str := StartPoints[index];
      str := GetValidStr3(str, mapstr, ['/']);
      Result := mapstr;
   end;
end;

//¹®ÀÚ¿­À» ÀÎÄÚµù ¶Ç´Â µðÄÚµùÇÏ´Â ÇÔ¼ö
//¹®ÀÚ¿­ ¾Õ¿¡ 'ENCODE_'°¡ ºÙ¾îÀÖÀ¸¸é ÀÎÄÚµù, ¾Æ´Ï¸é µðÄÚµù ÀÛ¾÷À» ¼öÇà
//@Param var src : ÀÎÄÚµù ¶Ç´Â µðÄÚµùµÉ ¿øº» ¹®ÀÚ¿­, ¸®ÅÏµÉ ¶§¿¡´Â
//@Param key : ÀÎÄÚµù ¹× µðÄÚµù¿¡ »ç¿ëµÉ Key
//@Result : ÀÎÄÚµùµÈ ¹®ÀÚ¿­À» ¹ÝÈ¯ÇÔ. µðÄÚµùÀÎ °æ¿ì´Â ''¸¦ ¹ÝÈ¯ÇÔ.
function  DecodeStringPassword( var src: string; key: integer ): string;
var
   i, temp: integer;
   tempstr, EncodedPwd: string;
   EncodeString: string;
begin
   Result := '';
   EncodeString := 'M2';

   tempstr := Copy( UPPERCASE(src), 1, _MIN(Length(EncodeString), Length(src)) );
   if tempstr = EncodeString then begin
      src := Copy( src, Length(EncodeString) +1, Length(src) );
      EncodedPwd := src;
      //Encode Password
      for i:=1 to Length(src) do begin
         temp := Integer(src[i]) xor ( key + i );
         if not ((temp >= 33) and (temp <= 126)) then begin
            temp := Integer(src[i]);
         end;
         EncodedPwd[i] := Char(temp);
      end;
      Result := EncodedPwd;
   end else begin
      //Decode Password
      for i:=1 to Length(src) do begin
         temp := Integer(src[i]) xor ( key + i );
         if not ((temp >= 33) and (temp <= 126)) then begin
            temp := Integer(src[i]);
         end;
         src[i] := Char(temp);
      end;
   end;
end;

procedure LoadSetupIniInfo;
var
  i: Integer;
  ini: TIniFile;
  fname: string;
begin
  fname := '.\Setup\Global.ini';
  if FileExists(fname) then begin
    ini := TIniFile.Create(fname);
    if ini <> nil then begin
      UserSendAllMsgType := ini.ReadInteger('Server', 'UserSendAllMsgType', 0);
      UserSendAllMsgGold := ini.ReadInteger('Server', 'UserSendAllMsgGold', 10000);
      UserSendAllMsgPotCash := ini.ReadInteger('Server', 'UserSendAllMsgPotCash', 10);

      for i := Low(ExtraHighLevel) to High(ExtraHighLevel) do begin
        ExtraExp[i] := ini.ReadInteger('Exp', 'ExtraExp' + IntToStr(i + 1), 0);
        ExtraLowLevel[i] := ini.ReadInteger('Exp', 'ExtraLowLevel' + IntToStr(i + 1), 0);
        ExtraHighLevel[i] := ini.ReadInteger('Exp', 'ExtraHighLevel' + IntToStr(i + 1), 0);
      end;
      ExtraMsgInfo := ini.ReadString('Exp', 'ExtraMsgInfo', '');

      ApprenticeMinLevel := ini.ReadInteger('Master', 'ApprenticeMinLevel', 7);
      ApprenticeMaxLevel := ini.ReadInteger('Master', 'ApprenticeMaxLevel', 18);
      MasterOKLevel := ini.ReadInteger('Master', 'MasterOKLevel', 35);
      MasterCreditPointCount := ini.ReadInteger('Master', 'MasterCreditPointCount', 0);

      if MasterCreditPointCount > 0 then begin
        for i := 0 to MasterCreditPointCount - 1 do begin
          ApprenticeLevel[i] := ini.ReadInteger('Master', 'ApprenticeLevel' + IntToStr(i + 1), 0);
          ApprenticeCreditPoint[i] := ini.ReadInteger('Master', 'ApprenticeCreditPoint' + IntToStr(i + 1), 0);
          MasterCreditPoint[i] := ini.ReadInteger('Master', 'MasterCreditPoint' + IntToStr(i + 1), 0);
        end;
      end;
    end;
    ini.Free;
  end else
    ShowMessage('File not found... <' + fname + '>');
end;

//---------------------------------------------------------------//

procedure MainOutMessage (str: string);
begin
   try
      csMsgLock.Enter;
      MainMsg.Add (str);
   finally
      csMsgLock.Leave;
   end;
end;

procedure AddUserLog (str: string);
begin
   try
      csMsgLock.Enter;
      UserLogs.Add (str);
   finally
      csMsgLock.Leave;
   end;
end;

procedure AddUserConAlarmLog (str: string);
begin
   try
      csMsgLock.Enter;
      UserConAlarmLogs.Add (str);
   finally
      csMsgLock.Leave;
   end;
end;

procedure AddConLog (str: string);
begin
   try
      csMsgLock.Enter;
      UserConLogs.Add (str);
   finally
      csMsgLock.Leave;
   end;
end;

procedure AddChatLog (str: string);
begin
   try
      csMsgLock.Enter;
      UserChatLog.Add (str);
   finally
      csMsgLock.Leave;
   end;
end;

procedure WriteConLogs (slist: TStringList);
var
   ayear, amon, aday, ahour, amin, asec, amsec: word;
   dirname, flname: string;
   dir256: array[0..255] of char;
   f: TextFile;
   i: integer;
begin
   if slist.Count = 0 then exit;

   DecodeDate (Date, ayear, amon, aday);
   DecodeTime (Time, ahour, amin, asec, amsec);
   dirname := ConLogBaseDir + IntToStr(ayear) + '-' + IntTo_Str(amon) + '-' + IntTo_Str(aday);
   if not FileExists (dirname) then begin
      StrPCopy (dir256, dirname);
      CreateDirectory (@dir256, nil);
   end;
   flname := dirname + '\C-' + IntToStr(ServerIndex) + '-' + IntTo_Str(ahour) + 'H' + IntTo_Str(amin div 10 * 10) + 'M.txt';

   AssignFile (f, flname);
   if not FileExists (flname) then
      Rewrite (f)
   else Append (f);

   for i:=0 to slist.Count-1 do begin
      WriteLn (f, '1'#9 + slist[i] + ''#9 + '0');
   end;

   CloseFile (f);
end;

procedure WriteChatLogs (slist: TStringList);
var
   ayear, amon, aday, ahour, amin, asec, amsec: word;
   dirname, flname: string;
   dir256: array[0..255] of char;
   f: TextFile;
   i: integer;
begin
   if slist.Count = 0 then exit;

   DecodeDate (Date, ayear, amon, aday);
   DecodeTime (Time, ahour, amin, asec, amsec);
   dirname := ChatLogBaseDir + IntToStr(ayear) + '-' + IntTo_Str(amon) + '-' + IntTo_Str(aday);
   if not FileExists (dirname) then begin
      StrPCopy (dir256, dirname);
      CreateDirectory (@dir256, nil);
   end;
   flname := dirname + '\C-' + {IntToStr(ServerIndex) + '-' +} IntTo_Str(ahour) + 'H' + {IntTo_Str(amin div 10 * 10) +} 'M.txt';

   AssignFile (f, flname);
   if not FileExists (flname) then
      Rewrite (f)
   else Append (f);

   for i:=0 to slist.Count-1 do begin
      WriteLn (f, IntToStr(ServerIndex) + ''#9 + slist[i] + ''#9 + '0');
   end;

   CloseFile (f);
end;

function TFrmMain.LoadClientFileCheckSum: Boolean;
begin
   Memo1.Lines.Add ('¼ÓÔØ¿Í»§¶Ë°æ±¾ÐÅÏ¢..');
   if ClientFileName1 <> '' then
      ClientCheckSumValue1 := CheckFileCheckSum (ClientFileName1);
   if ClientFileName2 <> '' then
      ClientCheckSumValue2 := CheckFileCheckSum (ClientFileName2);
   if ClientFileName3 <> '' then
      ClientCheckSumValue3 := CheckFileCheckSum (ClientFileName3);
   if (clientchecksumvalue1 = 0) and (clientchecksumvalue2 = 0) and (clientchecksumvalue3 = 0) then begin
      Memo1.Lines.Add ('Loading client version information failed. check !setup.txt -> [setup] -> clientfile1,..');
      Result := FALSE;
   end else begin
      Memo1.Lines.Add ('¿Í»§¶Ë°æ±¾ÐÅÏ¢¼ÓÔØ³É¹¦.' + ClientFileName1 + '(' + IntToStr(ClientCheckSumValue1) + ') ' + ClientFileName2 + '(' + IntToStr(ClientCheckSumValue2) + ') ' + ClientFileName3 + '(' + IntToStr(ClientCheckSumValue3) + ')');
      Result := TRUE;
   end;
end;

// ----------------------------------------------------------------


procedure TFrmMain.StartTimerTimer(Sender: TObject);
var
   i,error, checkvalue: integer;
   IsSuccess : Boolean;
   handle, FileDate : integer;
   DateTime : TDateTime;
begin
   StartTimer.Enabled := FALSE;

   try
      //µ¥ÀÌÅÍ °Ë»ç
{$ifdef MIR2EI}
      checkvalue := SIZEOFEIFDB;
{$else}
      checkvalue := SIZEOFFDB;
{$endif}

      if sizeof(FDBRecord) <> checkvalue then begin
         ShowMessage('SizeOf(THuman) ' + IntToStr(sizeof(FDBRecord)) + ' <> SIZEOFTHUMAN ' + IntToStr(SIZEOFFDB));
         Close;
         exit;
      end;

      if not LoadClientFileCheckSum then begin
         close;
         exit;
      end;

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØÎïÆ·Êý¾Ý¿â StdItem.DB...');

      //±âº» µ¥ÀÌÅ¸¸¦ ·Îµù ÇÑ´Ù.
      error := FrmDB.LoadStdItems;
      if error < 0 then begin
         ShowMessage ('StdItems.DB' + '£º¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('ÎïÆ·Êý¾Ý¿â¼ÓÔØ³É¹¦.');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØÐ¡µØÍ¼ÐÅÏ¢ MiniMap.txt...');
      error := FrmDB.LoadMiniMapInfos;
      if error < 0 then begin
         ShowMessage ('MiniMap.txt' + '£º¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('Ð¡µØÍ¼ÐÅÏ¢¼ÓÔØ³É¹¦.');

      // ¿ë´øÁ¯ ½Ã½ºÅÛ ·Îµù
//      Memo1.Lines.Add('Loading DragonSystem...');
//      Memo1.Lines.Add( gFireDragon.Initialize( EnvirDir + DRAGONITEMFILE , IsSuccess ) );
//      if ( not IsSuccess ) then
//      Memo1.Lines.Add( DRAGONITEMFILE +'1111111111111111111');


      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØµØÍ¼ÎÄ¼þ MapInfo.txt...');
      error := FrmDB.LoadMapFiles;
      if error < 0 then begin
         ShowMessage ('MapInfo.txt¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('µØÍ¼ÎÄ¼þ¼ÓÔØ³É¹¦.');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØ¹ÖÎïÊý¾Ý¿â Monster.DB...');
      error := FrmDB.LoadMonsters;
      if error <= 0 then begin
         ShowMessage ('Monster.DB' + '£º¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('¹ÖÎïÊý¾Ý¿â¼ÓÔØ³É¹¦.');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØ¼¼ÄÜÊý¾Ý¿â Magic.DB...');
      error := FrmDB.LoadMagic;
      if error <= 0 then begin
         ShowMessage ('Magic.DB' + '£º¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('¼¼ÄÜÊý¾Ý¿â¼ÓÔØ³É¹¦.');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØ¹ÖÎïË¢ÐÂÐÅÏ¢ MonGen.txt...');
      error := FrmDB.LoadZenLists;
      if error <= 0 then begin
         ShowMessage ('MonGen.txt' + '£º¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('¹ÖÎïË¢ÐÂÐÅÏ¢¼ÓÔØ³É¹¦.');

      // 2003/06/20 ÀÌº¥Æ®¸÷ Á¨ ¸Þ¼¼Áö µî·Ï
      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØ¹ÖÎïËµ»°ÎÄ¼þ GenMsg.txt...');
      error := FrmDB.LoadGenMsgLists;
      if error <= 0 then begin
         ShowMessage ('GenMsg.txt' + '¶ÁÈ¡Ê§°Ücode=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('¹ÖÎïËµ»°ÎÄ¼þ¼ÓÔØ³É¹¦.');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØÀ¦°óÎïÆ·ÐÅÏ¢ UnbindList.txt...');
      error := FrmDB.LoadUnbindItemLists;
      if error < 0 then begin
         ShowMessage ('UnbindList.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('À¦°óÎïÆ·ÐÅÏ¢¼ÓÔØ³É¹¦..');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØµØÍ¼ÈÎÎñÐÅÏ¢ MapQuest.txt...');
      error := FrmDB.LoadMapQuestInfos;
      if error < 0 then begin
         ShowMessage ('MapQuest.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('µØÍ¼ÈÎÎñÐÅÏ¢¼ÓÔØ³É¹¦.');

//      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØµÇÂ¼½Å±¾ StartupQuest.txt...');
//      error := FrmDB.LoadStartupQuest;
//      if error < 0 then begin
//         ShowMessage ('StartupQuest.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
//         close;
//         exit;
//      end else
//         Memo1.Lines.Add ('µÇÂ¼½Å±¾¼ÓÔØ³É¹¦..');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØÄ¬ÈÏNPC½Å±¾ QManage.txt...');
      error := FrmDB.LoadDefaultNpc;
      if error < 0 then begin
         ShowMessage ('QManage.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('Ä¬ÈÏNPC½Å±¾¼ÓÔØ³É¹¦..');

      Memo1.Lines.Add ('ÕýÔÚ¼ÓÔØÈÎÎñÈÕ¼ÇÐÅÏ¢ QuestDiary\*.txt...');
      error := FrmDB.LoadQuestDiary;
      if error < 0 then begin
         ShowMessage ('QuestDiary\*.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('ÈÎÎñÈÕ¼ÇÐÅÏ¢¼ÓÔØ³É¹¦..');

      if LoadAbusiveList ('!Abuse.txt') then
         Memo1.Lines.Add  ('!Abuse.txt' + ' ¼ÓÔØ³É¹¦..');

      if LoadLineNotice (LINENOTICEFILE) then
         Memo1.Lines.Add  (LINENOTICEFILE + ' ¹«¸æÎÄ¼þ¼ÓÔØ³É¹¦..')
      else
         Memo1.Lines.Add  (LINENOTICEFILE + ' ¹«¸æÎÄ¼þ¼ÓÔØÊ§°Ü!!');

//      if LoadLineHelp (LINEHELPFILE) then
//         Memo1.Lines.Add  (LINEHELPFILE + ' loaded..')
//      else
//         Memo1.Lines.Add  (LINEHELPFILE + ' loading failure !!!!!!!!!');

      if FrmDB.LoadAdminFiles > 0 then
         Memo1.Lines.Add  ('¹ÜÀíÔ±ÁÐ±í¼ÓÔØ³É¹¦..')
      else
         Memo1.Lines.Add  ('¹ÜÀíÔ±ÁÐ±í¼ÓÔØÊ§°Ü!!');

      // LoadPublicKey
//      if LoadPublicKey( EnvirDir + 'enckey.txt' ) then
//         Memo1.Lines.Add  ('PublicKey loaded..');

      // 2003/08/28
      FrmDB.LoadChatLogFiles;
      Memo1.Lines.Add  ('ÁÄÌìÈÕÖ¾ÁÐ±í¼ÓÔØ³É¹¦..');

      GuildMan.LoadGuildList;
      Memo1.Lines.Add  ('ÐÐ»áÁÐ±í¼ÓÔØ³É¹¦..');

      GuildAgitMan.LoadGuildAgitList;
      Memo1.Lines.Add  ('ÐÐ»á×¯Ô°ÁÐ±í¼ÓÔØ³É¹¦..');

      //Àå¿ø°Ô½ÃÆÇ
      GuildAgitBoardMan.LoadAllGaBoardList('');
      Memo1.Lines.Add  ('ÐÐ»á×¯Ô°¹«¸æÁÐ±í¼ÓÔØ³É¹¦..');

      UserCastle.Initialize;  //¹®ÆÄÁ¤º¸°¡ ÀÌ¹Ì ÀÐ¾îÁø ÈÄ¿¡ ºÒ·ÁÁ®¾ßÇÔ
      boUserCastleInitialized := TRUE;
      Memo1.Lines.Add  ('³Ç±¤³õÊ¼»¯..');

      if ServerIndex = 0 then begin //0¹ø ¼­¹ö°¡ ¸¶½ºÅÍ°¡ µÈ´Ù.
         FrmSrvMsg.Initialize;
      end else begin
         FrmMsgClient.Initialize;
      end;

      // DBSQL ¿¬°á ------------------------------------------------------------
      if g_DBSQL.Connect( ServerName , '.\!DBSQL.TXT' ) then
      Memo1.Lines.Add ('DBSQL Á¬½Ó³É¹¦..')
      else
      Memo1.Lines.Add ('DBSQL Á¬½ÓÊ§°Ü!! ' );
      //------------------------------------------------------------------------
      //¹öÀü Ç¥½Ã..
      DateTime := 0;
      if FileExists ('M2Server.exe') then begin
         handle := FileOpen ('M2Server.exe', fmOpenRead or fmShareDenyNone);
         if handle > 0 then begin
            FileDate := FileGetDate( handle );
            DateTime := FileDateToDateTime(FileDate);
            MainOutMessage('ÎÄ¼þ×îÐÂ°æ±¾ : ' + DateTimeToStr(DateTime));
            FileClose (handle);
         end;
      end;
      //------------------------------------------------------------------------

      StartServer;

      ServerReady := TRUE;

      Sleep(1);
      ConnectTimer.Enabled := TRUE;

      runstart := GetTickCount;
      rcount := 0;
      humrotatetime := GetTickCount;
      RunTimer.Enabled := TRUE;


   except
      MainOutMessage ('starttimer exception...');
   end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var
   i, runsec: integer;
   fhandle: TextFile;
   fail: Boolean;
   r: Real;
   ayear, amon, aday: word;
   ahour, amin, asec, amsec: word;
   checkstr, str, sendb: string;
   pgate: PTRunGateInfo;
   MyStream: TMemoryStream;
   down : integer;
begin
   down := 1;
   try
      csTimerLock.Enter;
      if Memo1.Lines.Count > 500 then Memo1.Lines.Clear;
      fail := TRUE;
      if MainMsg.Count > 0 then begin
         try
            if not FileExists (ErrorLogFile) then begin
               AssignFile (fhandle, ErrorLogFile);
               Rewrite (fhandle);
               fail := FALSE;
            end else begin
               AssignFile (fhandle, ErrorLogFile);
               Append (fhandle);
               fail := FALSE;
            end;
         except
            Memo1.Lines.Add ('Error on writing ErrorLog.');
         end;
      end;
      for i:=0 to MainMsg.Count-1 do begin
         Memo1.Lines.Add (MainMsg[i]);
         if not fail then WriteLn (fhandle, MainMsg[i]);
      end;
      MainMsg.Clear;
      if not fail then CloseFile (fhandle);

      //ÇÃ·¡ÀÌ¾îÀÇ Á¢¼Ó ·Î±×¸¦ UDP¼ÒÄÏÀ» ÅëÇØ¼­ ·Î±×¼öÁý¼­¹ö¿¡ Àü´Þ
      for I := 0 to UserLogs.Count-1 do begin
         try
            str := '1'#9 +
                   IntToStr(ServerNumber) + #9 +
                   IntToStr(ServerIndex) + #9 +
                   UserLogs[I];
            LogUDP.Send(str);
         except
            Continue;
         end;
      end;
      UserLogs.Clear;

      //ÇÃ·¡ÀÌ¾îÀÇ Á¢¼Ó ·Î±×¸¦ ÀúÀåÇÑ´Ù.
      if UserConLogs.Count > 0 then begin
         try
           WriteConLogs (UserConLogs);
         except
           MainOutMessage ('ÕÒ²»µ½ConLogÎÄ¼þ¼Ð£¬µÇÂ¼ÈÕÖ¾´¢´æÊ§°Ü..');
//           MainOutMessage ('ERROR_CONLOG_FAIL');
         end;
         UserConLogs.Clear;
      end;

      //ÇÃ·¡ÀÌ¾îÀÇ Ã¤ÆÃ ·Î±×¸¦ ÀúÀåÇÑ´Ù.
      if UserChatLog.Count > 0 then begin
         try
           WriteChatLogs (UserChatLog);
         except
           MainOutMessage ('ERROR_CHATLOG_FAIL');
         end;
         UserChatLog.Clear;
      end;

   finally
      csTimerLock.Leave;
   end;

   try
   down := 2;

   if ServerIndex = 0 then checkstr := '[M]'
   else if FrmMsgClient.MsgClient.Socket.Connected then checkstr := '[S]'
   else checkstr := '[ ]';

   checkStr := checkStr+IntToStr(gErrorCount);
{$IFDEF DEBUG} //sonmg
   checkstr := checkstr + ' DEBUG';
{$ENDIF}

   down := 3;

   runsec := (GetTickCount - serverruntime) div 1000;
   ahour := runsec div 3600;
   amin := (runsec mod 3600) div 60;
   asec := runsec mod 60;
   LbRunTime.Caption := '[' + IntToStr(ahour) + ':' + IntToStr(amin) + ':' + IntToStr(asec)
                        + ']' + checkstr;
   down := 4;
   // 2003/03/18 Å×½ºÆ® ¼­¹ö ÀÎ¿ø Á¦ÇÑ
   LbUserCount.Caption :=
                           '(' + //IntToStr(UserEngine.MonRunCount) + '/' +
                           IntToStr(UserEngine.MonCount) + ')   ' +
                           IntToStr(UserEngine.GetRealUserCount) +
                           '/' + IntToStr(UserEngine.GetUserCount) +
                           '/' + IntToStr(UserEngine.FreeUserCount);
   Label1.Caption := 'Run' + IntToStr(curruncount) + '/' + IntToStr(minruncount) + ' ' +
                     'Soc' + IntToStr(cursoctime) + '/' + IntToStr(maxsoctime) + ' ' +
                     'Usr' + IntToStr(curusrcount) + '/' + IntToStr(maxusrtime) + '.';
   Label2.Caption := 'Hum' + IntToStr(curhumtime) + '/' + IntToStr(maxhumtime) + ' ' +
                     'Mon' + IntToStr(curmontime) + '/' + IntToStr(maxmontime) + ' ' +
                     'UsrRot' + IntToStr(curhumrotatetime) + '/' + IntToStr(maxhumrotatetime) +
                                '(' + IntToStr(humrotatecount) + ')';

   Label5.Caption := LatestGenStr + ' - ' + LatestMonStr + '    ';

   down := 5;
   r := GetTickCount / (1000 * 60 * 60 * 24);
   if r >= 36 then LbTimeCount.Font.Color := clRed;
   LbTimeCount.Caption := FloatToString (r) + 'Day';

   down := 6;
   str := '';
   with RunSocket do begin  //¸ÖÆ¼ ½º·¡Æ®·Î º¯°æÇßÀ» °æ¿ì µ¿±âÈ­ ÁÖÀÇ
      for i:=0 to MAXGATE-1 do begin
         pgate := PTRunGateInfo (@GateArr[i]);
         if pgate <> nil then begin
            if pgate.Socket <> nil then begin
               if pgate.sendbytes < 1024 then sendb := IntToStr(pgate.sendbytes) + 'b '
               else sendb := IntToStr(pgate.sendbytes div 1024) + 'kb ';
               str := str +
                      '[G' + IntToStr(i+1) + ': ' +
                      IntToStr(pgate.curbuffercount) + '/' + IntToStr(pgate.remainbuffercount) + ' ' +
                      sendb +
                      IntToStr(pgate.sendsoccount) +
                      '] ';
            end;
         end;
      end;
   end;
   Label3.Caption := str;

   down := 7;
   Inc (minruncount);
   Dec (maxsoctime);
   Dec (maxusrtime);
   Dec (maxhumtime);
   Dec (maxmontime);
   Dec (maxhumrotatetime);

   except
      MainOutMessage('Exception Timer1Timer :'+IntTostr(down));
   end;
end;

procedure TFrmMain.SaveVariableTimerTimer(Sender: TObject);
begin
   SaveItemNumber;
end;

procedure TFrmMain.MakeStoneMines;
var
   i, k, x, y: integer;
   ev: TStoneMineEvent;
   env: TEnvirnoment;
begin
   for i:=0 to GrobalEnvir.Count-1 do begin
      env := TEnvirnoment(GrobalEnvir[i]);
      if (env.MineMap > 0) then begin
         for x:=0 to env.MapWidth-1 do
            for y:=0 to env.MapHeight-1 do begin
               if env.minemap = 1 then
                  ev := TStoneMineEvent.Create (env, x, y, ET_MINE)   //»ý¼ºÀ¸·Î ³¡
               else if env.minemap = 2 then
                  ev := TStoneMineEvent.Create (env, x, y, ET_MINE2)  //»ý¼ºÀ¸·Î ³¡
               else
                  ev := TStoneMineEvent.Create (env, x, y, ET_MINE3);  //»ý¼ºÀ¸·Î ³¡
               //EventMan.AddEvent (ev); Ãß°¡ÇÒ ÇÊ¿ä´Â ¾ø´Ù.
               // ¸¶ÀÎÀÌ ¾È ³Ö¾îÁ³´Ù¸é ¾ø¿¡¹ö¸®Áö..
               if ( ev <> nil ) and ev.IsAddToMap = false then
               begin
                    ev.Free;
                    ev := nil;
                    // MainOutMessage('STONMIME FREE');
               end;

            end;
      end;
   end;
end;

procedure TFrmMain.StartServer;
var
   error: integer;
   TotalDecoMonCount: integer;
begin
   try

      FrmIDSoc.Initialize;
      Memo1.Lines.Add ('IDSoc ³õÊ¼»¯..');

      GrobalEnvir.InitEnvirnoments;
      Memo1.Lines.Add ('GrobalEnvir ¼ÓÔØ³É¹¦..');

      MakeStoneMines; //±¤¼®À» Ã¤¿î´Ù.
      Memo1.Lines.Add ('MakeStoneMines ¼ÓÔØ³É¹¦..');

      error := FrmDB.LoadMerchants;
      if error < 0 then begin
         ShowMessage ('merchant.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('ÉÌÈËÎÄ¼þ¼ÓÔØ³É¹¦...');

      //---------------------------------------------
      //Àå¿ø²Ù¹Ì±â ¾ÆÀÌÅÛ ¸®½ºÆ® ·Îµå(sonmg)
      //LoadAgitDecoMonº¸´Ù ¸ÕÀú ½ÇÇàµÇ¾î¾ß ÇÔ.
//      error := FrmDB.LoadDecoItemList;
//      if error < 0 then begin
//         ShowMessage ('DecoItem.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
//         close;
//         exit;
//      end else
//         Memo1.Lines.Add ('DecoItemList loaded..');

      //0¹ø ¼­¹ö¿¡¼­¸¸ ÀÐ¾îµéÀÓ.
      if ServerIndex = 0 then begin
         //Àå¿ø²Ù¹Ì±â ¿ÀºêÁ§Æ® ·Îµå(sonmg)
         //LoadDecoItemListº¸´Ù ³ªÁß¿¡ ½ÇÇàµÇ¾î¾ß ÇÔ.
         error := GuildAgitMan.LoadAgitDecoMon;
         if error < 0 then begin
            ShowMessage (GuildBaseDir + AGITDECOMONFILE + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
            close;
            exit;
         end else begin
            //Àå¿ø¿¡ ²Ù¹Ì±â ¿ÀºêÁ§Æ®¸¦ »ý¼º½ÃÅ²´Ù.
            TotalDecoMonCount := GuildAgitMan.MakeAgitDecoMon;
            //Àå¿øº° ²Ù¹Ì±â ¿ÀºêÁ§Æ® °³¼ö¸¦ Á¾ÇÕÇÑ´Ù.
            GuildAgitMan.ArrangeEachAgitDecoMonCount;
            Memo1.Lines.Add ('×¯Ô°×°ÊÎÎï ' + IntToStr(TotalDecoMonCount) + ' ¼ÓÔØ...');
         end;
      end;
      //---------------------------------------------

      if not BoVentureServer then begin  //¸ðÇè¼­¹ö¿¡¼­´Â °æºñº´ÀÌ ¾ø´Ù.
         error := FrmDB.LoadGuards;
         if error < 0 then begin
            ShowMessage ('Guardlist.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
            close;
            exit;
         end;
      end;

      error := FrmDB.LoadNpcs;
      if error < 0 then begin
         ShowMessage ('Npc.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('½»Ò×NPCÁÐ±í¼ÓÔØ³É¹¦..');

      error := FrmDB.LoadMakeItemList;
      if error < 0 then begin
         ShowMessage ('MakeItem.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('Á¶ÖÆÎïÆ·ÐÅÏ¢¼ÓÔØ³É¹¦..');

      error := FrmDB.LoadDropItemShowList;
      if error < 0 then begin
         ShowMessage ('DropItemShowList.txt' + '£º¶ÁÈ¡Ê§°Ücode= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('¹ÖÎïµôÂäÌáÊ¾ÎÄ¼þ¼ÓÔØ³É¹¦..');

      error := FrmDB.LoadStartPoints;
      if error < 0 then begin
         ShowMessage ('StartPoint.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('¸´»îµãÅäÖÃ¼ÓÔØ³É¹¦..');

      error := FrmDB.LoadSafePoints;
      if error < 0 then begin
         ShowMessage ('SafePoint.txt' + '¶ÁÈ¡Ê§°Ü code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('»Ø³ÇµãÅäÖÃ¼ÓÔØ³É¹¦..');

      FrontEngine.Resume;
      Memo1.Lines.Add ('F-Engine ×¼±¸¾ÍÐ÷..');

      UserEngine.Initialize;
      Memo1.Lines.Add ('U-Engine ³õÊ¼»¯..');

      UserMgrEngine.Resume;
      Memo1.Lines.Add ('UserMgr-Engine ×¼±¸¾ÍÐ÷..');

      SQlEngine.Resume;
      Memo1.Lines.Add ('SQL-Engine ×¼±¸¾ÍÐ÷..');

   except
      MainOutMessage ('startserver exception..');
   end;
end;

procedure TFrmMain.ConnectTimerTimer(Sender: TObject);
begin
   if not DBSocket.Active then begin
      DBSocket.Active := TRUE;
   end;
end;


{--------------- GateÀÇ µ¥ÀÌÅ¸¸¦ Ã³¸®ÇÔ --------------}

procedure TFrmMain.RunTimerTimer(Sender: TObject);
begin
   if ServerReady then begin
      RunSocket.Run;

      FrmIDSoc.DecodeSocStr;

      UserEngine.ExecuteRun;

      //À§Å¹»óÁ¡
      SqlEngine.ExecuteRun;

      EventMan.Run;

      if ServerIndex = 0 then begin //0¹ø ¼­¹ö°¡ ¸¶½ºÅÍ°¡ µÈ´Ù.
         FrmSrvMsg.Run;
      end else begin
         FrmMsgClient.Run;
      end;
   end;

   Inc (rcount);
   if GetTickCount - runstart > 250 then begin
      runstart := GetTickCount;
      curruncount := rcount;
      if minruncount > curruncount then minruncount := curruncount;
      rcount := 0;
   end;
end;

{------------- Gate Socket °ü·Ã ÇÔ¼ö ----------------}

procedure TFrmMain.GateSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RunSocket.Connect (Socket);
end;

procedure TFrmMain.GateSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RunSocket.Disconnect (Socket);
end;

procedure TFrmMain.GateSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   RunSocket.SocketError (Socket, ErrorCode);
end;

procedure TFrmMain.GateSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   RunSocket.SocketRead (Socket);
end;

{------------- DB Socket °ü·Ã ÇÔ¼ö ----------------}

function  DBConnected: Boolean;
begin
   if FrmMain.DBSocket.Active then
      Result := FrmMain.DBSocket.Socket.Connected
   else Result := FALSE;      
end;

procedure TFrmMain.DBSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ;
end;

procedure TFrmMain.DBSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ;
end;

procedure TFrmMain.DBSocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   ErrorCode := 0;
   Socket.Close;
end;

procedure TFrmMain.DBSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
   data: string;
begin
   try
      csSocLock.Enter;
      data := Socket.ReceiveText;
      RDBSocData := RDBSocData + data;
      if not ReadyDBReceive then
         RDBSocData := '';

   finally
      csSocLock.Leave;
   end;

   // DB ¿¡¼­ÀÐÀº µ¥ÀÌÅÍ¸¦ ³Ö´Â´Ù. PDS...
   UserMgrEngine.OnDBRead( data );


//   if ReadyDBReceive then MainOutMessage ('DB-> ' + IntToStr(Length(data)) + ' OK')
//   else MainOutMessage ('DB-> ' + IntToStr(Length(data)) + ' Miss');
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if not ServerClosing then begin
      CanClose := FALSE;
      if MessageDlg ('ÒªÀë¿ªËÅ·þÆ÷Âð£¿', mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then begin
         ServerClosing := TRUE;
         TCloseTimer.Enabled := TRUE;
         RunSocket.CloseAllGate;
      end;
   end;      
end;

procedure TFrmMain.TCloseTimerTimer(Sender: TObject);
begin
   if (UserEngine.GetRealUserCount = 0) and (FrontEngine.IsFinished) then begin
      Close;
   end;
end;

procedure TFrmMain.Panel1DblClick(Sender: TObject);
var
   ini: TIniFile;
   fname, bostr: string;
begin
   if FrmServerValue.Execute then begin
      fname := '.\!setup.txt';
      ini := TIniFile.Create (fname);
      if ini <> nil then begin
         ini.WriteInteger ('Server', 'HumLimit', HumLimitTime);
         ini.WriteInteger ('Server', 'MonLimit', MonLimitTime);
         ini.WriteInteger ('Server', 'ZenLimit', ZenLimitTime);
         ini.WriteInteger ('Server', 'SocLimit', SocLimitTime);
         ini.WriteInteger ('Server', 'DecLimit', DecLimitTime);
         ini.WriteInteger ('Server', 'NpcLimit', NpcLimitTime);

         ini.WriteInteger ('Server', 'SendBlock', SENDBLOCK);
         ini.WriteInteger ('Server', 'CheckBlock', SENDCHECKBLOCK);
         ini.WriteInteger ('Server', 'GateLoad', GATELOAD);

         if BoViewHackCode then bostr := 'TRUE'
         else bostr := 'FALSE';
         ini.WriteString ('Server', 'ViewHackMessage', bostr);

         if BoViewAdmissionFail then bostr := 'TRUE'
         else bostr := 'FALSE';
         ini.WriteString ('Server', 'ViewAdmissionFailure', bostr);

      end;
   end;
end;

procedure TFrmMain.SpeedButton1Click(Sender: TObject);
var
   ini: TIniFile;
   fname: string;
begin
   FrmIDSoc.Timer1Timer(self);

   with FrmMsgClient do begin
      if ServerIndex <> 0 then
         if not MsgClient.Socket.Connected then begin
            MsgClient.Active := TRUE;
         end;
   end;

   fname := '.\!setup.txt';
   if FileExists (fname) then begin
      ini := TIniFile.Create (fname);
      if ini <> nil then begin
         LogServerAddress := ini.ReadString ('Server', 'LogServerAddr', '192.168.0.152');
         LogServerPort := ini.ReadInteger ('Server', 'LogServerPort', 10000);

         ClientFileName1 := ini.ReadString ('Setup', 'ClientFile1', '');
         ClientFileName2 := ini.ReadString ('Setup', 'ClientFile2', '');
         ClientFileName3 := ini.ReadString ('Setup', 'ClientFile3', '');
      end;
      ini.Free;
   end;
   LogUDP.Host := LogServerAddress;
   LogUDP.Port := LogServerPort;

   LoadMultiServerTables;

   FrmIDSoc.LoadShareIPList;

   LoadClientFileCheckSum;
end;

end.

