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
   ENGLISHVERSION = FALSE;    //���¸�(����)
   PHILIPPINEVERSION = FALSE; //�ʸ���
   CHINAVERSION = FALSE;
   TAIWANVERSION = FALSE;
   KOREANVERSION = TRUE;      //�ѱ�

   SENDBLOCK: integer = 1024; //2048;  //����Ʈ�� ����ϱ� ������ ���� ũ��.
   SENDCHECKBLOCK: integer = 4096; //2048;      //ĳũ ��ȣ�� ������.
   SENDAVAILABLEBLOCK: integer = 7999; //4096;  //ĳũ ��ȣ�� ��� �������� ������.
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
procedure AddUserLog (str: string);  //�÷��̾��� �ൿ�� ���
procedure AddUserConAlarmLog (str: string);
procedure AddConLog (str: string);  //���� ����� �α׷� ����
procedure AddChatLog (str: string);  //ä�� ����� �α׷� ����
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
  GuildAgitMan: TGuildAgitManager;  //�������(sonmg)
  GuildAgitBoardMan: TGuildAgitBoardManager;  //����Խ���(sonmg)
  GuildAgitStartNumber: integer;   //������� ���۹�ȣ(MapInfo���� �о��).
  GuildAgitMaxNumber: integer;   //������� �ִ밳��(MapInfo���� �о��).
  EventMan: TEventManager;
  UserCastle: TUserCastle;
  boUserCastleInitialized : Boolean;
  gFireDragon: TDragonSystem;

  DecoItemList: TStringList;  //����ٹ̱�
  MakeItemList: TStringList;  // list of TStringList;
  MakeItemIndexList: TStringList;  // ���� ������ ���� Index ����Ʈ.
  StartPoints: TStringList;
  SafePoints: TStringList;
  MultiServerList: TList;
  ShutUpList: TQuickList; //ä�ñ��� ����Ʈ
  MiniMapList: TStringList;
  UnbindItemList: TStringList;
  LineNoticeList: TStringList;
  LineHelpList: TStringList;
  QuestDiaryList: TList;  //list of TList of TList(PTQDDinfo)
                                      //TQDDinfo // [n] index or unit index
                                                 // TStringList
  StartupQuestNpc: TMerchant;
  DefaultNpc: TMerchant;

  EventItemList: TStringList;   //����ũ ������ �̺�Ʈ�� ���� ����Ʈ
  EventItemGifeBaseNumber: integer;
  GrobalQuestParams: array[0..9] of integer;
  GrobalStringParams: array[0..99] of string;

  ErrorLogFile: string;
  MirDayTime: integer;  //�̸��� �ð�... ���� �ð��� 2�� ����
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
  BoSysHasMission: Boolean;    //�̺�Ʈ��, �̼��� �ִ���
  SysMission_Map: string;
  SysMission_X: integer;
  SysMission_Y: integer;
  TotalUserCount: integer;  //�������� ������ ����ڼ�

  csMsgLock: TCriticalSection;
  csTimerLock: TCriticalSection;
  csObjMsgLock: TCriticalSection;
  csSendMsgLock: TCriticalSection;
  csShare: TCriticalSection;  //����ȭ �ð��� �F�� ���������� ����ؾ� ��.
  csDelShare: TCriticalSection;  //����ȭ �ð��� �F�� ���������� ����ؾ� ��.
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
  UserLogs: TStringList;  //�÷��̾��� �ൿ �α�
  UserConAlarmLogs: TStringList;  //Ư�� �ൿ ������ ����/�ൿ �α�
  UserConLogs: TStringList;  //���� �α�
  UserChatLog: TStringList;  //ä�� �α�
  DiscountForNightTime: Boolean;
  HalfFeeStart: integer;  //���νð� ����
  HalfFeeEnd: integer;   //���νð� ��

  ServerReady: Boolean;       //������ ����ڸ� ���� �غ� �Ǿ��°�?
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
  ConLogBaseDir: string;  //���� �ð� �α�
  ChatLogBaseDir: string;  //���� �ð� �α�

  DefHomeMap: string;  //�� �������� �� �־�� �ϴ� ��
  DefHomeX: integer;
  DefHomeY: integer;
  GuildDir: string;
  GuildFile: string;
  GuildBaseDir: string;
  GuildAgitFile: string;
  CastleDir: string;
  EnvirDir: string;
  MapDir: string;

  CurrentMonthlyCard: integer;    //������ ����� ��
  TotalTimeCardUsage: integer;  //�ð��� ī�� ������� ��� �� �ð� //�ð�
  LastMonthTotalTimeCardUsage: integer;   //�ð�
  GrossTimeCardUsage: integer;    //�ð�
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

  //�̸���
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
  //����� ����
  gErrorCount :integer;
  g_TestTime : integer;

  //����üũ
  g_SpeedHackCheck : integer;
  g_SpeedHackCheckChar : string;

  //��ġ�� ����
  g_CryWide : integer;
  //���� �������� Merchant Index
  CurrentMerchantIndex : integer;
  ServerTickDifference: longword;

  //������ �ε��� ����
  INDEX_CHOCOLATE: integer;  //���ݷ�
  INDEX_CANDY: integer;      //����
  INDEX_LOLLIPOP: integer;   //�������
  INDEX_MIRBOOTS: integer;   //õ����ຸ

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
   GuildAgitMan := TGuildAgitManager.Create; //�������(sonmg)
   GuildAgitBoardMan := TGuildAgitBoardManager.Create;  //����Խ���(sonmg)
   EventMan := TEventManager.Create;
   UserCastle := TUserCastle.Create;
   boUserCastleInitialized := FALSE;
   //����� �ý���
   gFireDragon := TDragonSystem.Create;

   FrontEngine  := TFrontEngine.Create;
   UserEngine   := TUserEngine.Create;
   // ģ�� ���� �ý���
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
   HumanLock    := TCriticalSection.Create; // �����͵��� �� ���� ���ұ�...
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

   Memo1.Lines.Add ('׼������������Ϣ..');
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
         //Ŭ���̾�Ʈ �׽�Ʈ��
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
         HalfFeeStart := ini.ReadInteger ('Server', 'HalfFeeStart', 2);  //2��
         HalfFeeEnd := ini.ReadInteger ('Server', 'HalfFeeEnd', 10);  //10��

         ShareBaseDir := ini.ReadString ('Share', 'BaseDir', 'D:\');
         ShareFileNameNum := 1;
         GuildDir := ini.ReadString ('Share', 'GuildDir', 'D:\');
         GuildFile := ini.ReadString ('Share', 'GuildFile', 'D:\');
         // ��� ��� ����.
         GuildBaseDir := ExtractFileDir(GuildFile) + '\';  //������ GuildFile�� ���� ���(sonmg)
         GuildAgitFile := GuildBaseDir + 'GuildAgitList.txt';   //�����̸� �ϵ��ڵ�(sonmg)

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
      Memo1.Lines.Add ('���ڼ��������ļ�!setup.txt..');
   end else
      ShowMessage ('�ش����ȱ�ٵ���!setup.txt...');

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

   //������ ������ �ε��� ����
   if KOREANVERSION then begin
      INDEX_CHOCOLATE := 661; //���ݷ�
      INDEX_CANDY     := 666; //����
      INDEX_LOLLIPOP  := 667; //�������
      INDEX_MIRBOOTS  := 642; //õ����ຸ
   end else if ENGLISHVERSION then begin
      INDEX_CHOCOLATE := 1; //���ݷ�
      INDEX_CANDY     := 594; //����
      INDEX_LOLLIPOP  := 595; //�������
      INDEX_MIRBOOTS  := 477; //õ����ຸ
   end else if PHILIPPINEVERSION then begin
      INDEX_CHOCOLATE := 611; //���ݷ�
      INDEX_CANDY     := 556; //����
      INDEX_LOLLIPOP  := 557; //�������
      INDEX_MIRBOOTS  := 1; //õ����ຸ
   end;

{$IFDEF MIR2EI}
   Caption := '[ei] ' + ServerName + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time);
   Panel1.Color := clLime;
{$ELSE}
   // 2003/04/01 ���� ��ȣ ǥ��
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
   g_CryWide := 150;  //���ַ�Χ 150

   //����üũ
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
   //���� ���������� ��ϼ� ������ �ʱ�ȭ�Ǵ� ���� �������� �ڵ�(sonmg 2004/08/13)
   if boUserCastleInitialized then
      UserCastle.SaveAll;

   FrontEngine.Terminate;
   FrontEngine.Free;

   UserEngine.Free;
   //ģ�� ���� �ý���
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
   GuildAgitMan.Free;   //�������(sonmg)
   GuildAgitBoardMan.Free; //����Խ���(sonmg)
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

//�ش� index�� StartPoint �� �̸��� ������ �Լ�(sonmg 2005/12/28)
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

//���ڿ��� ���ڵ� �Ǵ� ���ڵ��ϴ� �Լ�
//���ڿ� �տ� 'ENCODE_'�� �پ������� ���ڵ�, �ƴϸ� ���ڵ� �۾��� ����
//@Param var src : ���ڵ� �Ǵ� ���ڵ��� ���� ���ڿ�, ���ϵ� ������
//@Param key : ���ڵ� �� ���ڵ��� ���� Key
//@Result : ���ڵ��� ���ڿ��� ��ȯ��. ���ڵ��� ���� ''�� ��ȯ��.
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
   Memo1.Lines.Add ('���ؿͻ��˰汾��Ϣ..');
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
      Memo1.Lines.Add ('�ͻ��˰汾��Ϣ���سɹ�.' + ClientFileName1 + '(' + IntToStr(ClientCheckSumValue1) + ') ' + ClientFileName2 + '(' + IntToStr(ClientCheckSumValue2) + ') ' + ClientFileName3 + '(' + IntToStr(ClientCheckSumValue3) + ')');
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
      //������ �˻�
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

      Memo1.Lines.Add ('���ڼ�����Ʒ���ݿ� StdItem.DB...');

      //�⺻ ����Ÿ�� �ε� �Ѵ�.
      error := FrmDB.LoadStdItems;
      if error < 0 then begin
         ShowMessage ('StdItems.DB' + '����ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('��Ʒ���ݿ���سɹ�.');

      Memo1.Lines.Add ('���ڼ���С��ͼ��Ϣ MiniMap.txt...');
      error := FrmDB.LoadMiniMapInfos;
      if error < 0 then begin
         ShowMessage ('MiniMap.txt' + '����ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('С��ͼ��Ϣ���سɹ�.');

      // ����� �ý��� �ε�
//      Memo1.Lines.Add('Loading DragonSystem...');
//      Memo1.Lines.Add( gFireDragon.Initialize( EnvirDir + DRAGONITEMFILE , IsSuccess ) );
//      if ( not IsSuccess ) then
//      Memo1.Lines.Add( DRAGONITEMFILE +'1111111111111111111');


      Memo1.Lines.Add ('���ڼ��ص�ͼ�ļ� MapInfo.txt...');
      error := FrmDB.LoadMapFiles;
      if error < 0 then begin
         ShowMessage ('MapInfo.txt��ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('��ͼ�ļ����سɹ�.');

      Memo1.Lines.Add ('���ڼ��ع������ݿ� Monster.DB...');
      error := FrmDB.LoadMonsters;
      if error <= 0 then begin
         ShowMessage ('Monster.DB' + '����ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('�������ݿ���سɹ�.');

      Memo1.Lines.Add ('���ڼ��ؼ������ݿ� Magic.DB...');
      error := FrmDB.LoadMagic;
      if error <= 0 then begin
         ShowMessage ('Magic.DB' + '����ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('�������ݿ���سɹ�.');

      Memo1.Lines.Add ('���ڼ��ع���ˢ����Ϣ MonGen.txt...');
      error := FrmDB.LoadZenLists;
      if error <= 0 then begin
         ShowMessage ('MonGen.txt' + '����ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('����ˢ����Ϣ���سɹ�.');

      // 2003/06/20 �̺�Ʈ�� �� �޼��� ���
      Memo1.Lines.Add ('���ڼ��ع���˵���ļ� GenMsg.txt...');
      error := FrmDB.LoadGenMsgLists;
      if error <= 0 then begin
         ShowMessage ('GenMsg.txt' + '��ȡʧ��code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add  ('����˵���ļ����سɹ�.');

      Memo1.Lines.Add ('���ڼ���������Ʒ��Ϣ UnbindList.txt...');
      error := FrmDB.LoadUnbindItemLists;
      if error < 0 then begin
         ShowMessage ('UnbindList.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('������Ʒ��Ϣ���سɹ�..');

      Memo1.Lines.Add ('���ڼ��ص�ͼ������Ϣ MapQuest.txt...');
      error := FrmDB.LoadMapQuestInfos;
      if error < 0 then begin
         ShowMessage ('MapQuest.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('��ͼ������Ϣ���سɹ�.');

//      Memo1.Lines.Add ('���ڼ��ص�¼�ű� StartupQuest.txt...');
//      error := FrmDB.LoadStartupQuest;
//      if error < 0 then begin
//         ShowMessage ('StartupQuest.txt' + '��ȡʧ�� code=' + IntToStr(error));
//         close;
//         exit;
//      end else
//         Memo1.Lines.Add ('��¼�ű����سɹ�..');

      Memo1.Lines.Add ('���ڼ���Ĭ��NPC�ű� QManage.txt...');
      error := FrmDB.LoadDefaultNpc;
      if error < 0 then begin
         ShowMessage ('QManage.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('Ĭ��NPC�ű����سɹ�..');

      Memo1.Lines.Add ('���ڼ��������ռ���Ϣ QuestDiary\*.txt...');
      error := FrmDB.LoadQuestDiary;
      if error < 0 then begin
         ShowMessage ('QuestDiary\*.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('�����ռ���Ϣ���سɹ�..');

      if LoadAbusiveList ('!Abuse.txt') then
         Memo1.Lines.Add  ('!Abuse.txt' + ' ���سɹ�..');

      if LoadLineNotice (LINENOTICEFILE) then
         Memo1.Lines.Add  (LINENOTICEFILE + ' �����ļ����سɹ�..')
      else
         Memo1.Lines.Add  (LINENOTICEFILE + ' �����ļ�����ʧ��!!');

//      if LoadLineHelp (LINEHELPFILE) then
//         Memo1.Lines.Add  (LINEHELPFILE + ' loaded..')
//      else
//         Memo1.Lines.Add  (LINEHELPFILE + ' loading failure !!!!!!!!!');

      if FrmDB.LoadAdminFiles > 0 then
         Memo1.Lines.Add  ('����Ա�б���سɹ�..')
      else
         Memo1.Lines.Add  ('����Ա�б����ʧ��!!');

      // LoadPublicKey
//      if LoadPublicKey( EnvirDir + 'enckey.txt' ) then
//         Memo1.Lines.Add  ('PublicKey loaded..');

      // 2003/08/28
      FrmDB.LoadChatLogFiles;
      Memo1.Lines.Add  ('������־�б���سɹ�..');

      GuildMan.LoadGuildList;
      Memo1.Lines.Add  ('�л��б���سɹ�..');

      GuildAgitMan.LoadGuildAgitList;
      Memo1.Lines.Add  ('�л�ׯ԰�б���سɹ�..');

      //����Խ���
      GuildAgitBoardMan.LoadAllGaBoardList('');
      Memo1.Lines.Add  ('�л�ׯ԰�����б���سɹ�..');

      UserCastle.Initialize;  //���������� �̹� �о��� �Ŀ� �ҷ�������
      boUserCastleInitialized := TRUE;
      Memo1.Lines.Add  ('�Ǳ���ʼ��..');

      if ServerIndex = 0 then begin //0�� ������ �����Ͱ� �ȴ�.
         FrmSrvMsg.Initialize;
      end else begin
         FrmMsgClient.Initialize;
      end;

      // DBSQL ���� ------------------------------------------------------------
      if g_DBSQL.Connect( ServerName , '.\!DBSQL.TXT' ) then
      Memo1.Lines.Add ('DBSQL ���ӳɹ�..')
      else
      Memo1.Lines.Add ('DBSQL ����ʧ��!! ' );
      //------------------------------------------------------------------------
      //���� ǥ��..
      DateTime := 0;
      if FileExists ('M2Server.exe') then begin
         handle := FileOpen ('M2Server.exe', fmOpenRead or fmShareDenyNone);
         if handle > 0 then begin
            FileDate := FileGetDate( handle );
            DateTime := FileDateToDateTime(FileDate);
            MainOutMessage('�ļ����°汾 : ' + DateTimeToStr(DateTime));
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

      //�÷��̾��� ���� �α׸� UDP������ ���ؼ� �α׼��������� ����
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

      //�÷��̾��� ���� �α׸� �����Ѵ�.
      if UserConLogs.Count > 0 then begin
         try
           WriteConLogs (UserConLogs);
         except
           MainOutMessage ('�Ҳ���ConLog�ļ��У���¼��־����ʧ��..');
//           MainOutMessage ('ERROR_CONLOG_FAIL');
         end;
         UserConLogs.Clear;
      end;

      //�÷��̾��� ä�� �α׸� �����Ѵ�.
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
   // 2003/03/18 �׽�Ʈ ���� �ο� ����
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
   with RunSocket do begin  //��Ƽ ����Ʈ�� �������� ��� ����ȭ ����
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
                  ev := TStoneMineEvent.Create (env, x, y, ET_MINE)   //�������� ��
               else if env.minemap = 2 then
                  ev := TStoneMineEvent.Create (env, x, y, ET_MINE2)  //�������� ��
               else
                  ev := TStoneMineEvent.Create (env, x, y, ET_MINE3);  //�������� ��
               //EventMan.AddEvent (ev); �߰��� �ʿ�� ����.
               // ������ �� �־����ٸ� ����������..
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
      Memo1.Lines.Add ('IDSoc ��ʼ��..');

      GrobalEnvir.InitEnvirnoments;
      Memo1.Lines.Add ('GrobalEnvir ���سɹ�..');

      MakeStoneMines; //������ ä���.
      Memo1.Lines.Add ('MakeStoneMines ���سɹ�..');

      error := FrmDB.LoadMerchants;
      if error < 0 then begin
         ShowMessage ('merchant.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('�����ļ����سɹ�...');

      //---------------------------------------------
      //����ٹ̱� ������ ����Ʈ �ε�(sonmg)
      //LoadAgitDecoMon���� ���� ����Ǿ�� ��.
//      error := FrmDB.LoadDecoItemList;
//      if error < 0 then begin
//         ShowMessage ('DecoItem.txt' + '��ȡʧ�� code=' + IntToStr(error));
//         close;
//         exit;
//      end else
//         Memo1.Lines.Add ('DecoItemList loaded..');

      //0�� ���������� �о����.
      if ServerIndex = 0 then begin
         //����ٹ̱� ������Ʈ �ε�(sonmg)
         //LoadDecoItemList���� ���߿� ����Ǿ�� ��.
         error := GuildAgitMan.LoadAgitDecoMon;
         if error < 0 then begin
            ShowMessage (GuildBaseDir + AGITDECOMONFILE + '��ȡʧ�� code=' + IntToStr(error));
            close;
            exit;
         end else begin
            //����� �ٹ̱� ������Ʈ�� ������Ų��.
            TotalDecoMonCount := GuildAgitMan.MakeAgitDecoMon;
            //����� �ٹ̱� ������Ʈ ������ �����Ѵ�.
            GuildAgitMan.ArrangeEachAgitDecoMonCount;
            Memo1.Lines.Add ('ׯ԰װ���� ' + IntToStr(TotalDecoMonCount) + ' ����...');
         end;
      end;
      //---------------------------------------------

      if not BoVentureServer then begin  //���輭�������� ����� ����.
         error := FrmDB.LoadGuards;
         if error < 0 then begin
            ShowMessage ('Guardlist.txt' + '��ȡʧ�� code=' + IntToStr(error));
            close;
            exit;
         end;
      end;

      error := FrmDB.LoadNpcs;
      if error < 0 then begin
         ShowMessage ('Npc.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('����NPC�б���سɹ�..');

      error := FrmDB.LoadMakeItemList;
      if error < 0 then begin
         ShowMessage ('MakeItem.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('������Ʒ��Ϣ���سɹ�..');

      error := FrmDB.LoadDropItemShowList;
      if error < 0 then begin
         ShowMessage ('DropItemShowList.txt' + '����ȡʧ��code= ' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('���������ʾ�ļ����سɹ�..');

      error := FrmDB.LoadStartPoints;
      if error < 0 then begin
         ShowMessage ('StartPoint.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('��������ü��سɹ�..');

      error := FrmDB.LoadSafePoints;
      if error < 0 then begin
         ShowMessage ('SafePoint.txt' + '��ȡʧ�� code=' + IntToStr(error));
         close;
         exit;
      end else
         Memo1.Lines.Add ('�سǵ����ü��سɹ�..');

      FrontEngine.Resume;
      Memo1.Lines.Add ('F-Engine ׼������..');

      UserEngine.Initialize;
      Memo1.Lines.Add ('U-Engine ��ʼ��..');

      UserMgrEngine.Resume;
      Memo1.Lines.Add ('UserMgr-Engine ׼������..');

      SQlEngine.Resume;
      Memo1.Lines.Add ('SQL-Engine ׼������..');

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


{--------------- Gate�� ����Ÿ�� ó���� --------------}

procedure TFrmMain.RunTimerTimer(Sender: TObject);
begin
   if ServerReady then begin
      RunSocket.Run;

      FrmIDSoc.DecodeSocStr;

      UserEngine.ExecuteRun;

      //��Ź����
      SqlEngine.ExecuteRun;

      EventMan.Run;

      if ServerIndex = 0 then begin //0�� ������ �����Ͱ� �ȴ�.
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

{------------- Gate Socket ���� �Լ� ----------------}

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

{------------- DB Socket ���� �Լ� ----------------}

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

   // DB �������� �����͸� �ִ´�. PDS...
   UserMgrEngine.OnDBRead( data );


//   if ReadyDBReceive then MainOutMessage ('DB-> ' + IntToStr(Length(data)) + ' OK')
//   else MainOutMessage ('DB-> ' + IntToStr(Length(data)) + ' Miss');
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if not ServerClosing then begin
      CanClose := FALSE;
      if MessageDlg ('Ҫ�뿪�ŷ�����', mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then begin
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

