unit Func;

interface

uses
  SysUtils, Classes, SyncObjs, IniFiles, D7ScktComp, WinSock;

const
  GATEMAXSESSION    = 10000;

type
  TBlockIPMethod = (mDisconnect, mBlock, mBlockList);

  TSessionInfo = record
    Socket: TCustomWinSocket;
    nSocketHandle: Integer;             //Socket句柄
    sRemoteAddress: string;             //IP
    sRenStr: string;
    dwReceiveTick: LongWord;            //在线Tick
  end;
  pTSessionInfo = ^TSessionInfo;

  TSendUserData = record
    nSocketIdx: Integer;
    nSocketHandle: Integer;
    sMsg: string;
  end;
  pTSendUserData = ^TSendUserData;

  TSockaddr = record
    nIPaddr: Integer;
    nCount: Integer;
    dwTick: LongWord;
  end;
  pTSockaddr = ^TSockaddr;

procedure AddMainLogMsg(Msg: string; nLevel: Integer);
function IsStringNumber(str: string): Boolean;
function GetToken(S: string; splitchar: string; var P: Integer): string;
function IsIPaddr(IP: string): Boolean;
function MakeRenStr(S: Integer): string;
function CheckStr(const str: string): Boolean;
function CheckBlank(const str: string): Boolean;
(*function Q_PosStr(const FindString, SourceString: string; StartPos: Integer = 1): Integer;*)
function Str_ToInt(str: string; Def: LongInt): LongInt;
procedure LoadBlockIPFile();
procedure LoadBlockIDFile();
procedure SaveBlockIPList();

var
  Conf              : TIniFile;
  CS_MainLog        : TCriticalSection;
  MainLogMsgList    : TStringList;
  ClientSockeMsgList: TStringList;      //loginserver发过来的信息
  SendMsgList       : TList;            //客户端发来的信息
  CurrIPaddrList    : TList;            //临时IP记录
  BlockIPList       : TList;            //临时过滤
  TempBlockIPList   : TList;            //永久过滤
  BlockIDList       : TStringList;
  nShowLogLevel     : Integer = 3;      //日志等级
  sEnckeyFileName   : string = '.\EncKey.txt';
  sConfigFileName   : string = '.\Config.ini';
  GateClass         : string = 'LoginGate';
  GateName          : string = 'LoginGate';
  TitleName         : string = '龙的传说';
  ServerAddr        : string = '127.0.0.1';
  ServerPort        : Integer = 5567;
  GateAddr          : string = '0.0.0.0';
  BindAddr          : string = '0.0.0.0';
  GatePort          : Integer = 7676;
  SessionArray      : array[0..GATEMAXSESSION - 1] of TSessionInfo; //连接数组
  SessionCount      : Integer;          // 连接会话数
  boDecodeLock      : Boolean = False;
  boStarted         : Boolean = False;
  boClose           : Boolean = False;
  boServiceStart    : Boolean = False;
  boGateReady       : Boolean = False;  //网关是否就绪
  boCheckServerFail : Boolean = False;  //网关 <->游戏服务器之间检测是否失败（超时）
  dwCheckServerTimeOutTime: LongWord = 10 * 1000; //网关 <->游戏服务器之间检测超时时间长度 (可配置，待配置)

  nImposeTime       : Integer;

  boSendHoldTimeOut : Boolean;
  dwSendHoldTick    : LongWord;
  dwCheckRecviceTick: LongWord;
  dwCheckServerTick : LongWord;
  dwCheckServerTimeMin: LongWord;
  dwCheckServerTimeMax: LongWord;
  dwProcessReviceMsgTimeLimit: LongWord;
  dwProcessSendMsgTimeLimit: LongWord;
  dwSessionTimeOutTime: LongWord = 5 * 60 * 1000; //客户端超时
  nMaxConnOfIPaddr  : Integer = 20;     //每IP连接量
  dwConnSpaceOfIPaddr: LongWord = 500;  //连接间隔时间
  BlockMethod       : TBlockIPMethod = mDisconnect; //攻击处理方式

  boEnableIDSrv     : Boolean = False;  //启用账号系统
  boEnRegUser       : Boolean = True;   //允许注册账号
  boEnModPass       : Boolean = True;   //允许修改密码
  boSQLReady        : Boolean = False;
  ACCOUNTServer     : string = '127.0.0.1';
  ACCOUNTDB         : string = 'Account';
  ACCOUNTID         : string = 'sa';
  ACCOUNTPWS        : string = 'sa';
  boNoThisSQL       : Boolean = False;  //SQL不在本机

implementation

procedure AddMainLogMsg(Msg: string; nLevel: Integer);
var
  tMsg              : string;
begin
  try
    CS_MainLog.Enter;
    if nLevel <= nShowLogLevel then
    begin
      tMsg := '[' + FormatDateTime('mm-dd hh:mm', Now) + '] ' + Msg; //lyygate
      MainLogMsgList.Add(tMsg);
    end;
  finally
    CS_MainLog.Leave;
  end;
end;

function IsStringNumber(str: string): Boolean;
var
  i                 : Integer;
begin
  Result := True;
  for i := 1 to Length(str) do
    if (byte(str[i]) < byte('0')) or (byte(str[i]) > byte('9')) then
    begin
      Result := False;
      break;
    end;
end;

function GetToken(S: string; splitchar: string; var P: Integer): string;
var
  i                 : Integer;
begin
  if P > Length(S) then
  begin
    Result := '';
    exit;
  end;
  i := P;
  while (Length(S) >= P) and (S[P] <> splitchar) do
  begin
    Inc(P);
  end;
  Result := Copy(S, i, P - i);
  Inc(P);
end;

function IsIPaddr(IP: string): Boolean;
var
  i                 : Integer;
  s1, s2, s3, s4    : string;
begin
  i := 1;
  s1 := GetToken(IP, '.', i);
  s2 := GetToken(IP, '.', i);
  s3 := GetToken(IP, '.', i);
  s4 := GetToken(IP, '.', i);
  Result := IsStringNumber(s1) and IsStringNumber(s2) and IsStringNumber(s3) and IsStringNumber(s4);
end;

function Str_ToInt(str: string; Def: LongInt): LongInt;
begin
  Result := Def;
  if str <> '' then
  begin
    if ((Word(str[1]) >= Word('0')) and (Word(str[1]) <= Word('9'))) or
      (str[1] = '+') or (str[1] = '-') then
    try
      Result := StrToInt64(str);
    except
    end;
  end;
end;

function MakeRenStr(S: Integer): string;
var
  str               : string;
begin
  Randomize;
  //str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  str := '1234567890abcdefghijklmnopqrstuvwxyz';
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = S)
end;

function CheckStr(const str: string): Boolean;
var
  i                 : Integer;
begin
  for i := 1 to Length(str) do
  begin
    if CharInSet(str[i], ['"', ',', '`', '=', '<', '>', '\', '(', ')',Chr(34), Chr(39)]) then
    begin
      Result := True;
      exit;
    end;
  end;
  Result := False;
end;

function CheckBlank(const str: string): Boolean;
var
  i                 : Integer;
begin
  for i := 1 to Length(str) do
  begin
    if str[i] <= ' ' then
    begin
      Result := True;
      exit;
    end;
  end;
  Result := False;
end;

(*function Q_PosStr(const FindString, SourceString: string; StartPos: Integer): Integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        PUSH    EDX
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        SUB     EDX,ECX
        JNG     @@qt0
        XCHG    EAX,EDX
        ADD     EDI,ECX
        MOV     ECX,EAX
        JMP     @@nx
@@fr:   INC     EDI
        DEC     ECX
        JE      @@qt0
@@nx:   MOV     EBX,EDX
        MOV     AL,BYTE PTR [ESI]
@@lp1:  CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JE      @@qt0
        CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JE      @@qt0
        CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JE      @@qt0
        CMP     AL,BYTE PTR [EDI]
        JE      @@uu
        INC     EDI
        DEC     ECX
        JNE     @@lp1
@@qt0:  XOR     EAX,EAX
@@qt:   POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
        RET
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JE      @@fd
        MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JE      @@fd
        MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JE      @@fd
        MOV     AL,BYTE PTR [ESI+EBX]
        CMP     AL,BYTE PTR [EDI+EBX]
        JNE     @@fr
        DEC     EBX
        JNE     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        SUB     EAX,[ESP]
        POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
end;
*)
procedure LoadBlockIPFile();
var
  i                 : Integer;
  sFileName         : string;
  LoadList          : TStringList;
  sIPaddr           : string;
  nIPaddr           : Integer;
  IPaddr            : pTSockaddr;
begin
  sFileName := '.\BlockIPList.txt';
  if FileExists(sFileName) then
  begin
    AddMainLogMsg('正在加载永久过滤列表...', 3);
    LoadList := TStringList.Create;
    LoadList.LoadFromFile(sFileName);
    for i := 0 to LoadList.Count - 1 do
    begin
      sIPaddr := Trim(LoadList.Strings[0]);
      if sIPaddr = '' then Continue;
      nIPaddr := inet_addr(PAnsiChar(AnsiString(sIPaddr)));
      if nIPaddr = INADDR_NONE then Continue;
      New(IPaddr);
      FillChar(IPaddr^, SizeOf(TSockaddr), 0);
      IPaddr.nIPaddr := nIPaddr;
      BlockIPList.Add(IPaddr);
    end;
    FreeAndNil(LoadList);
  end;
end;

procedure LoadBlockIDFile();
var
  i                 : Integer;
  sFileName         : string;
  LoadList          : TStringList;
  sID               : string;
begin
  sFileName := '.\BlockIDList.txt';
  if FileExists(sFileName) then
  begin
    AddMainLogMsg('正在加载禁止注册ID列表...', 3);
    LoadList := TStringList.Create;
    LoadList.LoadFromFile(sFileName);
    for i := 0 to LoadList.Count - 1 do
    begin
      sID := Trim(LoadList.Strings[i]);
      if sID = '' then Continue;
      BlockIDList.Add(sID);
    end;
    FreeAndNil(LoadList);
  end;
end;

procedure SaveBlockIPList();
var
  i                 : Integer;
  SaveList          : TStringList;
begin
  SaveList := TStringList.Create;
  for i := 0 to BlockIPList.Count - 1 do
  begin
    SaveList.Add(String(inet_ntoa(TInAddr(pTSockaddr(BlockIPList.Items[i]).nIPaddr))));
  end;
  SaveList.SaveToFile('.\BlockIPList.txt');
  FreeAndNil(SaveList);
end;

procedure FreeIpList();
var
  i                 : Integer;
  IPaddr            : pTSockaddr;
begin
  for i := 0 to CurrIPaddrList.Count - 1 do
  begin
    IPaddr := CurrIPaddrList.Items[i];
    Dispose(IPaddr);
  end;
  for i := 0 to BlockIPList.Count - 1 do
  begin
    IPaddr := BlockIPList.Items[i];
    Dispose(IPaddr);
  end;
  for i := 0 to TempBlockIPList.Count - 1 do
  begin
    IPaddr := TempBlockIPList.Items[i];
    Dispose(IPaddr);
  end;
end;

initialization
  begin
    Conf := TIniFile.Create(sConfigFileName);
    nShowLogLevel := Conf.ReadInteger(GateClass, 'ShowLogLevel', nShowLogLevel);
    CS_MainLog := TCriticalSection.Create;
    MainLogMsgList := TStringList.Create;
    BlockIDList := TStringList.Create;
    ClientSockeMsgList := TStringList.Create;
    SendMsgList := TList.Create;
    CurrIPaddrList := TList.Create;
    BlockIPList := TList.Create;
    TempBlockIPList := TList.Create;
  end;

finalization
  begin
    FreeIpList();
    FreeAndNil(MainLogMsgList);
    FreeAndNil(BlockIDList);
    FreeAndNil(CS_MainLog);
    FreeAndNil(Conf);
    FreeAndNil(ClientSockeMsgList);
    FreeAndNil(SendMsgList);
    FreeAndNil(CurrIPaddrList);
    FreeAndNil(BlockIPList);
    FreeAndNil(TempBlockIPList);
  end;

end.

