unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls,
  ExtCtrls, ComCtrls, Func, EDcode, D7ScktComp, Menus, ComObj, Variants, WinSock,
  Grobal2, Hutil32;

type
  TFormMain = class(TForm)
    ClientSocket: TClientSocket;
    ServerSocket: TServerSocket;
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    MemoLog: TMemo;
    N1: TMenuItem;
    O1: TMenuItem;
    N_Start: TMenuItem;
    N_Stop: TMenuItem;
    StartTimer: TTimer;
    DecodeTimer: TTimer;
    SendTimer: TTimer;
    Timer: TTimer;
    N_ReConnect: TMenuItem;
    N_ReLoadConfig: TMenuItem;
    N_CleaeLog: TMenuItem;
    N_Exit: TMenuItem;
    N_General: TMenuItem;
    N_RegSet: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocketClientConnect(Sender: TObject; Socket:
      TCustomWinSocket);
    procedure ServerSocketClientDisconnect(Sender: TObject; Socket:
      TCustomWinSocket);
    procedure ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure StartTimerTimer(Sender: TObject);
    procedure DecodeTimerTimer(Sender: TObject);
    procedure SendTimerTimer(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure N_StartClick(Sender: TObject);
    procedure N_StopClick(Sender: TObject);
    procedure N_ReConnectClick(Sender: TObject);
    procedure N_ReLoadConfigClick(Sender: TObject);
    procedure N_CleaeLogClick(Sender: TObject);
    procedure N_ExitClick(Sender: TObject);
    procedure MemoLogChange(Sender: TObject);
    procedure N_GeneralClick(Sender: TObject);
    procedure N_RegSetClick(Sender: TObject);
  private
    dwShowMainLogTick: LongWord;
    boShowLocked: Boolean;
    TempLogList: TStringList;
    dwCheckClientTick: LongWord;
    boServerReady: Boolean;
    dwReConnectServerTime: LongWord;
    Rs: OleVariant;
    Conn: OleVariant;
    procedure LoadConfig();
    procedure StartService();
    procedure StopService();
    procedure RestSessionArray();
    procedure ShowMainLogMsg();
    procedure ProcessUserPacket(UserData: pTSendUserData);
    procedure LoginGetNewUser(puser: TSessionInfo; body: string);
    procedure LoginChangePasswd(puser: TSessionInfo; body: string);
    procedure SendSocket(Socket: TCustomWinSocket; uhandle, data: string);
    procedure ConnSQL();
    procedure CheckConn();
    procedure CloseSQL();
    function IsConnLimited(sIPaddr: string): Boolean;
    function IsBlockIP(sIPaddr: string): Boolean;
    function IsBlockID(sID: string): Boolean;
  public
    procedure CloseConnect(sIPaddr: string);
  end;

var
  FormMain: TFormMain;

implementation

uses
  GeneralConfig, IDSrvConfig;

{$R *.dfm}

function TFormMain.IsBlockIP(sIPaddr: string): Boolean;
var
  i: Integer;
  IPaddr: pTSockaddr;
  nIPaddr: Integer;
begin
  Result := False;
  nIPaddr := inet_addr(PAnsiChar(AnsiString(sIPaddr)));
  for i := 0 to TempBlockIPList.Count - 1 do begin
    IPaddr := TempBlockIPList.Items[i];
    if IPaddr.nIPaddr = nIPaddr then begin
      Result := True;
      exit;
    end;
  end;
  for i := 0 to BlockIPList.Count - 1 do begin
    IPaddr := BlockIPList.Items[i];
    if IPaddr.nIPaddr = nIPaddr then begin
      Result := True;
      exit;
    end;
  end;
end;

function TFormMain.IsBlockID(sID: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to BlockIDList.Count - 1 do begin
    if CompareText(BlockIDList[i], sID) = 0 then begin
      Result := True;
      exit;
    end;
  end;
end;

procedure TFormMain.CloseConnect(sIPaddr: string);
var
  i: Integer;
  boCheck: Boolean;
begin
  if ServerSocket.Active then
    while (True) do begin
      boCheck := False;
      for i := 0 to ServerSocket.Socket.ActiveConnections - 1 do begin
        if sIPaddr = ServerSocket.Socket.Connections[i].RemoteAddress then begin
          ServerSocket.Socket.Connections[i].Close;
          boCheck := True;
          break;
        end;
      end;
      if not boCheck then
        break;
    end;
end;

function TFormMain.IsConnLimited(sIPaddr: string): Boolean;
var
  i: Integer;
  IPaddr: pTSockaddr;
  nIPaddr: Integer;
begin
  Result := False;
  nIPaddr := inet_addr(PAnsiChar(AnsiString(sIPaddr)));
  for i := 0 to CurrIPaddrList.Count - 1 do begin
    if pTSockaddr(CurrIPaddrList[i]).nIPaddr = nIPaddr then begin
      Inc(pTSockaddr(CurrIPaddrList[i]).nCount);
      if (dwConnSpaceOfIPaddr > 0) and ((GetTickCount -
        pTSockaddr(CurrIPaddrList[i]).dwTick) < dwConnSpaceOfIPaddr) then begin
        Result := True;
        exit;
      end;
      pTSockaddr(CurrIPaddrList[i]).dwTick := GetTickCount;

      if (nMaxConnOfIPaddr > 0) and (pTSockaddr(CurrIPaddrList[i]).nCount >
        nMaxConnOfIPaddr) then begin
        Result := True;
      end;
      exit;
    end;
  end;
  New(IPaddr);
  //FillChar(IPaddr^, SizeOf(TSockaddr), 0);
  IPaddr.nIPaddr := nIPaddr;
  IPaddr.nCount := 1;
  IPaddr.dwTick := GetTickCount;
  CurrIPaddrList.Add(IPaddr);
end;

procedure TFormMain.ConnSQL();
begin
  if BoEnableIDSrv then begin
    Conn := CreateOleObject('ADODB.Connection');
    try
      AddMainLogMsg('正在连接SQL帐号数据库...', 1);
      //连接数据库
      Conn.ConnectionString := 'Provider=SQLOLEDB.1;Password=' + ACCOUNTPWS +
        ';Persist Security Info=True;User ID=' + ACCOUNTID + ';Initial Catalog='
          +
        ACCOUNTDB + ';Data Source=' + ACCOUNTServer + ';';
      Conn.Open();
      //连接成功返回true
      Rs := CreateOleObject('adodb.recordset');
      BoSQLReady := True;
      AddMainLogMsg('连接SQL帐号数据库成功...', 1);
    except
      on E: Exception do begin
        //连接失败返回False
        Rs := UNASSIGNED;
        Conn := UNASSIGNED;
        BoSQLReady := False;
        AddMainLogMsg('SQL帐号数据库连接失败' + #13#10 + E.Message, 1);
      end;

    end;
  end
  else begin
    AddMainLogMsg('帐号服务系统设置为禁止使用...', 1);
    BoSQLReady := False;
  end;
end;

procedure TFormMain.CheckConn();
begin
  try
    Rs.Open('Select FLD_LOGINID From [TBL_ACCOUNT] Where FLD_LOGINID=''''', Conn, 1,
      1);
    Rs.Close;
  except
    try
      Conn := UNASSIGNED;
      Conn := CreateOleObject('ADODB.Connection');
      Conn.ConnectionString := 'Provider=SQLOLEDB.1;Password=' + ACCOUNTPWS +
        ';Persist Security Info=True;User ID=' + ACCOUNTID + ';Initial Catalog='
          +
        ACCOUNTDB + ';Data Source=' + ACCOUNTServer + ';';
      Conn.Open();
      AddMainLogMsg('重新连接' + ACCOUNTDB + '数据库...', 1);
    except
      on E: Exception do begin
        AddMainLogMsg('重新连接' + ACCOUNTDB + '数据库失败' + #13#10 +
          E.Message, 4);
      end;
    end;
  end;
end;

procedure TFormMain.CloseSQL();
begin
  try
    if BoSQLReady then
      Conn.Close;
  finally
    if BoSQLReady then
      AddMainLogMsg('帐号数据库已经关闭...', 1);
    BoSQLReady := False;
    Rs := UNASSIGNED;
    Conn := UNASSIGNED;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  TempLogList := TStringList.Create;
  Self.Top := Conf.ReadInteger(GateClass, 'Top', 270);
  Self.Left := Conf.ReadInteger(GateClass, 'Left', 290);
  nImposeTime := 0;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  TempLogList.Free;
  Conf.WriteInteger(GateClass, 'Top', Self.Top);
  Conf.WriteInteger(GateClass, 'Left', Self.Left);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if boClose then
    exit;
  if Application.MessageBox('是否确认退出LoginGate网关？', '确认信息', MB_YESNO
    + MB_ICONQUESTION) = IDYES then begin
    if boServiceStart then begin
      StartTimer.Enabled := True;
      CanClose := False;
    end;
  end
  else
    CanClose := False;
end;

procedure TFormMain.LoadConfig;
begin
  AddMainLogMsg('正在加载配置信息...', 3);
  if Conf <> nil then begin
    TitleName := Conf.ReadString(GateClass, 'Title', TitleName);
    ServerAddr := Conf.ReadString(GateClass, 'ServerAddr', ServerAddr);
    ServerPort := Conf.ReadInteger(GateClass, 'ServerPort', ServerPort);
    GateAddr := Conf.ReadString(GateClass, 'GateAddr', GateAddr);
    BindAddr := Conf.ReadString(GateClass, 'BindAddr', BindAddr);
    GatePort := Conf.ReadInteger(GateClass, 'GatePort', GatePort);
    nShowLogLevel := Conf.ReadInteger(GateClass, 'ShowLogLevel', nShowLogLevel);

    dwSessionTimeOutTime := Conf.ReadInteger(GateClass, 'SessionTimeOutTime', dwSessionTimeOutTime);
    nMaxConnOfIPaddr := Conf.ReadInteger(GateClass, 'MaxConnOfIPaddr', nMaxConnOfIPaddr);
    dwConnSpaceOfIPaddr := Conf.ReadInteger(GateClass, 'ConnSpaceOfIPaddr', dwConnSpaceOfIPaddr);
    BlockMethod := TBlockIPMethod(Conf.ReadInteger(GateClass, 'BlockMethod', Integer(BlockMethod)));

    dwCheckServerTimeOutTime := Conf.ReadInteger(GateClass, 'ServerCheckTimeOut', dwCheckServerTimeOutTime);

    BoEnableIDSrv := Conf.ReadBool(GateClass, 'EnableIDSrv', BoEnableIDSrv);
    boEnRegUser := Conf.ReadBool(GateClass, 'EnRegUser', boEnRegUser);
    boEnModPass := Conf.ReadBool(GateClass, 'EnModPass', boEnModPass);
    ACCOUNTServer := Conf.ReadString(GateClass, 'ACCOUNTServer', ACCOUNTServer);
    ACCOUNTDB := Conf.ReadString(GateClass, 'ACCOUNTDB', ACCOUNTDB);
    ACCOUNTID := Conf.ReadString(GateClass, 'ACCOUNTID', ACCOUNTID);
    ACCOUNTPWS := Conf.ReadString(GateClass, 'ACCOUNTPWS', ACCOUNTPWS);
    boNoThisSQL := Conf.ReadBool(GateClass, 'NoThisSQL', boNoThisSQL);

    sEnckeyFileName := Conf.ReadString(GateClass, 'EnckeyFileName', sEnckeyFileName);
  end;
  AddMainLogMsg('配置信息加载完成...', 3);
  AddMainLogMsg('服务器地址：' + ServerAddr + ':' + IntToStr(ServerPort), 0);
  AddMainLogMsg('网关端口：' + IntToStr(GatePort), 0);
  LoadBlockIPFile();
  LoadBlockIDFile();
  CloseSQL();
  ConnSQL();
end;

procedure TFormMain.RestSessionArray;
var
  i: Integer;
  tSession: pTSessionInfo;
begin
  for i := 0 to GATEMAXSESSION - 1 do begin
    tSession := @SessionArray[i];
    tSession.Socket := nil;
    tSession.nSocketHandle := -1;
    tSession.sRemoteAddress := '';
    tSession.sRenStr := '';
  end;
end;

procedure TFormMain.StartService;
begin
  try
    AddMainLogMsg('服务器正在初始化...', 0);
    AddMainLogMsg('正在启动服务...', 2);
    boServiceStart := True;
    boGateReady := False;
    BoSQLReady := False;
    boCheckServerFail := False;
    N_Start.Enabled := False;
    N_Stop.Enabled := True;
    SessionCount := 0;
    LoadConfig();
    Caption := GateName + ' - ' + TitleName;
    Application.Title := GateName + ' ' + IntToStr(GatePort);
    RestSessionArray();
    dwProcessReviceMsgTimeLimit := 50;
    dwProcessSendMsgTimeLimit := 50;
    boServerReady := False;
    dwReConnectServerTime := GetTickCount - 25000;
    ServerSocket.Active := False;
    ServerSocket.Address := GateAddr;
    ServerSocket.Port := GatePort;
    ServerSocket.Active := True;
    ClientSocket.Active := False;
    ClientSocket.Address := ServerAddr;
    ClientSocket.Port := ServerPort;
    ClientSocket.Active := True;
    SendTimer.Enabled := True;
    AddMainLogMsg('服务已启动成功...', 2);
    if LoadPublicKey(sEnckeyFileName) then
      AddMainLogMsg('秘钥文件加载成功...', 2);
  except
    on E: Exception do begin
      N_Start.Enabled := True;
      N_Stop.Enabled := False;
      AddMainLogMsg(E.Message, 0);
    end;
  end;
end;

procedure TFormMain.StopService;
var
  nSockIdx: Integer;
begin
  AddMainLogMsg('正在停止服务...', 2);
  boServiceStart := False;
  boGateReady := False;
  N_Start.Enabled := True;
  N_Stop.Enabled := False;
  for nSockIdx := 0 to GATEMAXSESSION - 1 do begin
    if SessionArray[nSockIdx].Socket <> nil then
      SessionArray[nSockIdx].Socket.Close;
  end;
  ServerSocket.Close;
  ClientSocket.Close;
  CloseSQL();
  SaveBlockIPList();
  AddMainLogMsg('服务停止成功...', 2);
end;

procedure TFormMain.ShowMainLogMsg;
var
  i: Integer;
begin
  if (GetTickCount - dwShowMainLogTick) < 200 then
    exit;
  dwShowMainLogTick := GetTickCount();
  try
    boShowLocked := True;
    try
      CS_MainLog.Enter;
      for i := 0 to MainLogMsgList.Count - 1 do begin
        TempLogList.Add(MainLogMsgList.Strings[i]);
      end;
      MainLogMsgList.Clear;
    finally
      CS_MainLog.Leave;
    end;
    for i := 0 to TempLogList.Count - 1 do begin
      MemoLog.Lines.Add(TempLogList.Strings[i]);
    end;
    TempLogList.Clear;
  finally
    boShowLocked := False;
  end;
end;

procedure TFormMain.ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  boGateReady := True;
  dwCheckServerTick := GetTickCount();
  dwCheckRecviceTick := GetTickCount();
  RestSessionArray();
  boServerReady := True;
  dwCheckServerTimeMax := 0;
end;

procedure TFormMain.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
  i: Integer;
  UserSession: pTSessionInfo;
begin
  for i := 0 to GATEMAXSESSION - 1 do begin
    UserSession := @SessionArray[i];
    if UserSession.Socket <> nil then begin
      UserSession.Socket.Close;
      UserSession.Socket := nil;
      UserSession.nSocketHandle := -1;
      UserSession.sRemoteAddress := '';
      UserSession.sRenStr := '';
    end;
  end;
  RestSessionArray();
  boGateReady := False;
  boServerReady := False;
  ClientSockeMsgList.Clear;
end;

procedure TFormMain.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
  sRecvMsg: string;
begin
  sRecvMsg := Socket.ReceiveText;
  ClientSockeMsgList.Add(sRecvMsg);
end;

procedure TFormMain.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
  Socket.Close;
  boServerReady := False;
end;

procedure TFormMain.ServerSocketClientConnect(Sender: TObject; Socket:
  TCustomWinSocket);
var
  nSockIdx: Integer;
  sRemoteAddress: string;
  UserSession: pTSessionInfo;
  IPaddr: pTSockaddr;
begin
  Socket.nIndex := -1;
  sRemoteAddress := Socket.RemoteAddress;

  if IsBlockIP(sRemoteAddress) then begin
    AddMainLogMsg('过滤连接: ' + sRemoteAddress, 4);
    Socket.Close;
    exit;
  end;

  if IsConnLimited(sRemoteAddress) then begin
    case BlockMethod of
      mDisconnect: begin
          Socket.Close;
        end;
      mBlock: begin
          New(IPaddr);
          IPaddr.nIPaddr := inet_addr(PAnsiChar(AnsiString(sRemoteAddress)));
          TempBlockIPList.Add(IPaddr);
          CloseConnect(sRemoteAddress);
        end;
      mBlockList: begin
          New(IPaddr);
          IPaddr.nIPaddr := inet_addr(PAnsiChar(AnsiString(sRemoteAddress)));
          BlockIPList.Add(IPaddr);
          CloseConnect(sRemoteAddress);
        end;
    end;
    AddMainLogMsg('端口攻击: ' + sRemoteAddress, 4);
    exit;
  end;

  if boGateReady then begin
    for nSockIdx := 0 to GATEMAXSESSION - 1 do begin
      UserSession := @SessionArray[nSockIdx];
      if UserSession.Socket = nil then begin
        UserSession.Socket := Socket;
        UserSession.nSocketHandle := Socket.SocketHandle;
        UserSession.sRemoteAddress := Socket.RemoteAddress;
        UserSession.sRenStr := '';
        UserSession.dwReceiveTick := GetTickCount();
        Socket.nIndex := nSockIdx;
        Inc(SessionCount);
        break;
      end;
    end;
    if Socket.nIndex >= 0 then begin
      ClientSocket.Socket.SendText('%O' + IntToStr(Socket.SocketHandle) + '/' + Socket.RemoteAddress + '$');
      Socket.nIndex := nSockIdx;
      AddMainLogMsg('开始连接: ' + sRemoteAddress, 5);
    end
    else begin
      Socket.nIndex := -1;
      Socket.Close;
      AddMainLogMsg('禁止连接: ' + sRemoteAddress, 1);
    end;
  end
  else begin
    Socket.nIndex := -1;
    Socket.Close;
    AddMainLogMsg('禁止连接: ' + sRemoteAddress, 1);
  end;
end;

procedure TFormMain.ServerSocketClientDisconnect(Sender: TObject; Socket:
  TCustomWinSocket);
var
  i: Integer;
  nSockIndex: Integer;
  sRemoteAddr: string;
  UserSession: pTSessionInfo;
  nIPaddr: Integer;
begin
  sRemoteAddr := Socket.RemoteAddress;
  nIPaddr := inet_addr(PAnsiChar(AnsiString(sRemoteAddr)));
  nSockIndex := Socket.nIndex;

  for i := 0 to CurrIPaddrList.Count - 1 do begin
    if pTSockaddr(CurrIPaddrList[i]).nIPaddr = nIPaddr then begin
      Dec(pTSockaddr(CurrIPaddrList[i]).nCount);
      if pTSockaddr(CurrIPaddrList[i]).nCount <= 0 then begin
        Dispose(pTSockaddr(CurrIPaddrList[i]));
        CurrIPaddrList.Delete(i);
      end;
      break;
    end;
  end;

  if (nSockIndex >= 0) and (nSockIndex < GATEMAXSESSION) then begin
    UserSession := @SessionArray[nSockIndex];
    UserSession.Socket := nil;
    UserSession.nSocketHandle := -1;
    UserSession.sRemoteAddress := '';
    UserSession.sRenStr := '';
    Socket.nIndex := -1;
    Dec(SessionCount);
    if boGateReady then begin
      ClientSocket.Socket.SendText('%X' + IntToStr(Socket.SocketHandle) + '$');
      AddMainLogMsg('退出连接: ' + sRemoteAddr, 5);
    end;
  end;
end;

procedure TFormMain.ServerSocketClientError(Sender: TObject; Socket:
  TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
  Socket.Close;
end;

procedure TFormMain.ServerSocketClientRead(Sender: TObject; Socket:
  TCustomWinSocket);
var
  sReviceMsg: string;
  sRemoteAddress: string;
  nSocketIndex: Integer;
  UserData: pTSendUserData;
  UserSession: pTSessionInfo;
begin
  sRemoteAddress := Socket.RemoteAddress;
  nSocketIndex := Socket.nIndex;
  sReviceMsg := Socket.ReceiveText;
  if (nSocketIndex >= 0) and (nSocketIndex < GATEMAXSESSION) and (sReviceMsg <>
    '') and boServerReady then begin
    UserSession := @SessionArray[nSocketIndex];
    if UserSession.Socket = Socket then begin
      if (sReviceMsg <> '') and boGateReady and not boCheckServerFail then begin
        New(UserData);
        UserData.nSocketIdx := nSocketIndex;
        UserData.nSocketHandle := Socket.SocketHandle;
        UserData.sMsg := sReviceMsg;
        SendMsgList.Add(UserData);
      end;
    end;
  end;
end;

procedure TFormMain.StartTimerTimer(Sender: TObject);
begin
  if boStarted then begin
    StartTimer.Enabled := False;
    StopService();
    boClose := True;
    Close;
  end
  else begin
    boStarted := True;
    StartTimer.Enabled := False;
    StartService();
  end;
end;

procedure TFormMain.LoginGetNewUser(puser: TSessionInfo; body: string);
var
  ue: TUserEntryInfo;
  ua: TUserEntryAddInfo;
  size1, success: integer;
  uestr, uastr: string;
  msg: TDefaultMessage;
  sUserID: string[15];
  sUserPass: string[15];
  sBirthday: string[11];
  sSSNo: string[20];
  sQuiz: string[20];
  sAnswer: string[20];
  sQuiz2: string[20];
  sAnswer2: string[20];
  sUserEmail: string[20];
  sMobilePhone: string[11];
  sPhone: string[12];
  sUserName: string[21];
begin
  success := -1;
  FillChar(ue, sizeof(TUserEntryInfo), #0);
  FillChar(ua, sizeof(TUserEntryAddInfo), #0);
  size1 := UpInt(sizeof(TUserEntryInfo) * 4 / 3);
  uestr := Copy(body, 1, size1);
  uastr := Copy(body, size1 + 1, Length(body));

  if (uestr <> '') and (uastr <> '') then begin
    DecodeBuffer(uestr, @ue, sizeof(TUserEntryInfo));
    DecodeBuffer(uastr, @ua, sizeof(TUserEntryAddInfo));

    {   AddMainLogMsg ('TUserEntryInfo.LoginId=' + ue.LoginId, 1);
       AddMainLogMsg ('TUserEntryInfo.Password=' + ue.Password, 1);
       AddMainLogMsg ('TUserEntryInfo.UserName=' + ue.UserName, 1);
       AddMainLogMsg ('TUserEntryInfo.SSNo=' + ue.SSNo, 1);
       AddMainLogMsg ('TUserEntryInfo.Phone=' + ue.Phone, 1);
       AddMainLogMsg ('TUserEntryInfo.Quiz=' + ue.Quiz, 1);
       AddMainLogMsg ('TUserEntryInfo.Answer=' + ue.Answer, 1);
       AddMainLogMsg ('TUserEntryInfo.EMail=' + ue.EMail, 1);
       AddMainLogMsg ('TUserEntryAddInfo.Quiz2=' + ua.Quiz2, 1);
       AddMainLogMsg ('TUserEntryAddInfo.Answer2=' + ua.Answer2, 1);
       AddMainLogMsg ('TUserEntryAddInfo.Birthday=' + ua.Birthday, 1);
       AddMainLogMsg ('TUserEntryAddInfo.MobilePhone=' + ua.MobilePhone, 1);
       AddMainLogMsg ('TUserEntryAddInfo.Memo1=' + ua.Memo1, 1);
       AddMainLogMsg ('TUserEntryAddInfo.Memo2=' + ua.Memo2, 1);   }
    sUserID := ue.LoginId;
    sUserPass := ue.Password;
    sBirthday := ua.Birthday;
    sSSNo := ue.SSNo;
    sQuiz := ue.Quiz;
    sAnswer := ue.Answer;
    sQuiz2 := ua.Quiz2;
    sAnswer2 := ua.Answer2;
    sUserEmail := ue.EMail;
    sMobilePhone := ua.MobilePhone;
    sPhone := ue.Phone;
    sUserName := ue.UserName;
    if (not BoEnableIDSrv) or (not boEnRegUser) then
    {//注册功能被管理员禁止} begin
      success := -3;
    end;
    if CheckStr(sUserID) or CheckStr(sUserPass) or CheckStr(sQuiz) or
      CheckStr(sAnswer) or CheckStr(sQuiz2) or CheckStr(sAnswer2) or
      CheckStr(sUserEmail) or CheckStr(sSSNo) then begin
      success := -4; //包含非法字符
    end;
    if CheckBlank(sUserID) or CheckBlank(sUserPass) or CheckBlank(sQuiz) or
      CheckBlank(sAnswer) or CheckBlank(sQuiz2) or CheckBlank(sAnswer2) or
      CheckBlank(sUserEmail) or CheckStr(sSSNo) then begin
      success := -5; //包含空格
    end;
    if IsBlockID(sUserID) then
      success := -2;

    if success = -1 then begin
      if boNoThisSQL then
        CheckConn();
      try
        Rs.Open('Select FLD_LOGINID,FLD_PASSWORD From [TBL_ACCOUNT] Where FLD_LOGINID=''' + sUserID + '''', Conn, 1, 3);
        if not Rs.Eof then begin
          Rs.Close;
          success := 0; //帐号已经存在
        end
        else begin
          Rs.Addnew;
          Rs.Fields['FLD_LOGINID'].value := sUserID;
          Rs.Fields['FLD_PASSWORD'].value := sUserPass;
          Rs.Update;
          Rs.Close;
          Rs.Open('select * from TBL_ACCOUNTADD', Conn, 1, 3);     //下面屏蔽到Rs.Close就不保存ACCOUNTADD表
          Rs.Addnew;
          Rs.Fields['FLD_LOGINID'].value := sUserID;
          Rs.Fields['FLD_BIRTHDAY'].value := sBirthday;
          Rs.Fields['FLD_SSNO'].value := sSSNo;
          Rs.Fields['FLD_PHONE'].value := sPhone;
          Rs.Fields['FLD_MOBILEPHONE'].value := sMobilePhone;
          Rs.Fields['FLD_EMAIL'].value := sUserEmail;
          Rs.Fields['FLD_QUIZ1'].value := sQuiz;
          Rs.Fields['FLD_ANSWER1'].value := sAnswer;
          Rs.Fields['FLD_QUIZ2'].value := sQuiz2;
          Rs.Fields['FLD_ANSWER2'].value := sAnswer2;
          Rs.Fields['FLD_USERNAME'].value := sUserName;
          Rs.Update;
          Rs.Close;
          success := 1;
          AddMainLogMsg(sUserID + '注册成功!', 4);
          Inc(nImposeTime);
        end;
      except
        on E: Exception do begin
          AddMainLogMsg(sUserID + '注册帐号异常:' + E.Message, 4);
        end;
      end;
    end;
  end;

  if success = 1 then begin
    msg := MakeDefaultMsg(SM_NEWID_SUCCESS, 0, 0, 0, 0);
  end
  else begin
    msg := MakeDefaultMsg(SM_NEWID_FAIL, success, 0, 0, 0);
  end;
  SendSocket(puser.Socket, IntToStr(puser.nSocketHandle), EncodeMessage(msg))
end;

procedure TFormMain.LoginChangePasswd(puser: TSessionInfo; body: string);
var
  str, uid, passwd, newpass: string;
  success: integer;
  ue: TUserEntryInfo;
  ua: TUserEntryAddInfo;
  msg: TDefaultMessage;
begin
  str := DecodeString(body);
  str := GetValidStr3(str, uid, [#9]);
  newpass := GetValidStr3(str, passwd, [#9]);
  success := 1;

  if (not BoEnableIDSrv) or (not boEnModPass) then
  {//修改密码功能被管理员禁止} begin
    success := -3;
  end;
  //  if not BoSQLReady then                //数据库连接不成功
  //  begin
  //    success := 1;
  //  end;
  if CheckStr(passwd) or CheckStr(newpass) then begin
    success := -4; //包含非法字符
  end;
  if CheckBlank(passwd) or CheckBlank(newpass) then begin
    success := -4; //包含空格
  end;

  if success = 1 then begin
    if boNoThisSQL then
      CheckConn();
    try
      Rs.Open('Select FLD_LOGINID,FLD_PASSWORD From [TBL_ACCOUNT] Where FLD_LOGINID=''' + uid + '''', Conn, 1, 3);
      if Rs.Eof then begin
        Rs.Close;
        success := -1; //用户不存在，老密码错误
      end;
      if Trim(passwd) <> Trim(Rs.Fields['FLD_PASSWORD'].value) then begin
        Rs.Close;
        success := -1; //老密码错误
      end
      else begin
        Rs.Fields['FLD_PASSWORD'].value := newpass;
        Rs.Update;
        Rs.Close;
        AddMainLogMsg(uid + '修改密码成功!', 4);
        Inc(nImposeTime);
      end;
    except
      on E: Exception do begin
        AddMainLogMsg(uid + '修改密码异常:' + E.Message, 4);
        success := -1; //出现异常
      end;
    end;
  end;
  if success = 1 then begin
    msg := MakeDefaultMsg(SM_CHGPASSWD_SUCCESS, 0, 0, 0, 0);
    FillChar(ue, sizeof(TUserEntryInfo), #0);
    FillChar(ua, sizeof(TUserEntryAddInfo), #0);
    ue.LoginId := uid;
    ue.Password := passwd;
    ue.UserName := '-> "' + newpass + '"';
    ue.SSNo := puser.sRemoteAddress;
  end
  else
    msg := MakeDefaultMsg(SM_CHGPASSWD_FAIL, success, 0, 0, 0);
  SendSocket(puser.Socket, IntToStr(puser.nSocketHandle), EncodeMessage(msg));
end;

procedure TFormMain.SendSocket(Socket: TCustomWinSocket; uhandle, data: string);
begin
  Socket.SendText(AnsiString('%' + uhandle + '/#' + data + '!$'));
end;

procedure TFormMain.ProcessUserPacket(UserData: pTSendUserData);
var
  Msg: TDefaultMessage;
  sData: string;
  nSocketHandle: Integer;
  sHead, sBody: string;
begin
  try
    if (UserData.nSocketIdx >= 0) and (UserData.nSocketIdx < GATEMAXSESSION) then
      begin
      if (UserData.nSocketHandle =
        SessionArray[UserData.nSocketIdx].nSocketHandle) then begin
        nSocketHandle := UserData.nSocketHandle;
        sData := UserData.sMsg;

        sHead := Copy(sData, 3, DEFBLOCKSIZE);
        sBody := Copy(sData, DEFBLOCKSIZE + 3, Length(sData) - DEFBLOCKSIZE -
          3);
        Msg := DecodeMessage(sHead);
        if (Msg.Ident = CM_ADDNEWUSER) or (Msg.Ident = CM_CHANGEPASSWORD) then
          begin
          case Msg.Ident of
            CM_ADDNEWUSER: begin
                if GetTickCount - SessionArray[UserData.nSocketIdx].dwReceiveTick
                  > 5 * 1000 then begin
                  SessionArray[UserData.nSocketIdx].dwReceiveTick :=
                    GetTickCount;
                  LoginGetNewUser(SessionArray[UserData.nSocketIdx], sBody);
                end
                else
                  AddMainLogMsg('[Hacker Attack] ADDNEWACCOUNT ' +
                    SessionArray[UserData.nSocketIdx].sRemoteAddress, 1);
              end;
            CM_CHANGEPASSWORD: begin
                if GetTickCount - SessionArray[UserData.nSocketIdx].dwReceiveTick
                  > 5 * 1000 then begin
                  SessionArray[UserData.nSocketIdx].dwReceiveTick :=
                    GetTickCount;
                  LoginChangePasswd(SessionArray[UserData.nSocketIdx], sBody);
                end
                else
                  AddMainLogMsg('[Hacker Attack] CHANGEPASSWORD ' +
                    SessionArray[UserData.nSocketIdx].sRemoteAddress, 1);
              end;
          end;
        end
        else begin
          SessionArray[UserData.nSocketIdx].dwReceiveTick := GetTickCount();
          ClientSocket.Socket.SendText(AnsiString('%A' + IntToStr(nSocketHandle) + '/' + sData + '$'));
        end;
      end;
    end;
  except
    if (UserData.nSocketIdx >= 0) and (UserData.nSocketIdx < GATEMAXSESSION) then
      begin
      sData := '[' + SessionArray[UserData.nSocketIdx].sRemoteAddress + ']';
    end;
    AddMainLogMsg('[Exception] ProcessUserPacket' + sData, 1);
  end;
end;

procedure TFormMain.DecodeTimerTimer(Sender: TObject);
var
  Pack: string;
  SP: Integer;
  SID: string;
  SIDLen: Integer;
  SendPack: string;
  SendPackLen: Integer;
  UserSession: pTSessionInfo;
  UserData: pTSendUserData;
  i: Integer;
  nSocketHandle: Integer;
begin
  ShowMainLogMsg();
  try
    try
      if boDecodeLock or (not boGateReady) then
        exit;
      boDecodeLock := True;
      while (True) do begin
        if ClientSockeMsgList.Count <= 0 then
          break;
        Pack := ClientSockeMsgList.Strings[0];
        ClientSockeMsgList.Delete(0);
        if Pack[2] = '+' then begin
          boCheckServerFail := False;
          dwCheckServerTick := GetTickCount();
          Continue;
        end;
        //SP := Q_PosStr('/', Pack);
        SP := Pos('/', Pack); // Q_PosStr
        SIDLen := SP - 2;
        SetLength(SID, SIDLen);
        for i := 1 to SIDLen do
          SID[i] := Pack[i + 1];
        SendPackLen := Length(Pack) - SP - 1;
        SetLength(SendPack, SendPackLen);
        for i := 1 to SendPackLen do
          SendPack[i] := Pack[i + SP];
        nSocketHandle := StrToInt(SID);
        for i := 0 to GATEMAXSESSION - 1 do begin
          UserSession := @SessionArray[i];
          if UserSession.nSocketHandle = nSocketHandle then begin
            if UserSession.Socket <> nil then
              UserSession.Socket.SendText(AnsiString(SendPack));
            break;
          end;
        end;
        //AddMainLogMsg(IntToStr(nSocketHandle) + '   s:' + SendPack, 0);
      end;

      while (True) do begin
        if SendMsgList.Count <= 0 then
          break;
        UserData := SendMsgList.Items[0];
        SendMsgList.Delete(0);
        ProcessUserPacket(UserData); //解码信息
        Dispose(UserData);
      end;
    finally
      boDecodeLock := False;
    end;
    /////每二秒向登录服务器发送一个检查信号/////
    if (GetTickCount - dwCheckClientTick) > 2000 then begin
      dwCheckClientTick := GetTickCount();
      if boGateReady then begin
        if ClientSocket.Socket.Connected then
          ClientSocket.Socket.SendText('%--$');
      end;
      if (GetTickCount - dwCheckServerTick) > dwCheckServerTimeOutTime then begin
        boCheckServerFail := True;
        ClientSocket.Close;
      end;
    end;
  except
    on E: Exception do begin
      AddMainLogMsg('[Exception] DecodeTimer', 1);
    end;
  end;
end;

procedure TFormMain.SendTimerTimer(Sender: TObject);
var
  i: Integer;
  UserSession: pTSessionInfo;
begin
  if (GetTickCount - dwSendHoldTick) > 3000 then begin
    boSendHoldTimeOut := False;
  end;
  if boGateReady and not boCheckServerFail then begin
    for i := 0 to GATEMAXSESSION - 1 do begin
      UserSession := @SessionArray[i];
      if UserSession.Socket <> nil then begin
        if (GetTickCount - UserSession.dwReceiveTick) > dwSessionTimeOutTime then
          begin
          AddMainLogMsg('会话超时：' + UserSession.sRemoteAddress, 4);
          UserSession.Socket.Close;
          UserSession.Socket := nil;
          UserSession.nSocketHandle := -1;
          UserSession.sRemoteAddress := '';
        end;
      end;
    end;
  end;
  if not boGateReady then begin
    StatusBar.Panels[1].Text := '正在连接';
    StatusBar.Panels[3].Text := '????';
    if ((GetTickCount - dwReConnectServerTime) > 1000 {30 * 1000}) and
      boServiceStart then begin
      dwReConnectServerTime := GetTickCount();
      ClientSocket.Active := False;
      ClientSocket.Address := ServerAddr;
      ClientSocket.Port := ServerPort;
      ClientSocket.Active := True;
    end;
  end
  else begin
    if boCheckServerFail then begin
      StatusBar.Panels[1].Text := '连接失败';
    end
    else begin
      StatusBar.Panels[1].Text := '已激活';
    end;
    dwCheckServerTimeMin := GetTickCount - dwCheckServerTick;
    if dwCheckServerTimeMax < dwCheckServerTimeMin then
      dwCheckServerTimeMax := dwCheckServerTimeMin;
    StatusBar.Panels[3].Text := IntToStr(dwCheckServerTimeMin) + '/' +
      IntToStr(dwCheckServerTimeMax);
  end;
end;

procedure TFormMain.TimerTimer(Sender: TObject);
begin
  if ServerSocket.Active then begin
    StatusBar.Panels[0].Text := IntToStr(ServerSocket.Port);
    if boSendHoldTimeOut then begin
      StatusBar.Panels[2].Text := IntToStr(SessionCount) + '/#' +
        IntToStr(ServerSocket.Socket.ActiveConnections);
    end
    else begin
      StatusBar.Panels[2].Text := IntToStr(SessionCount) + '/' +
        IntToStr(ServerSocket.Socket.ActiveConnections);
    end;
  end
  else begin
    StatusBar.Panels[0].Text := '????';
    StatusBar.Panels[2].Text := '????';
  end;
{  if nImposeTime > 10 then begin
    StopService();
    Timer.Enabled := False;
  end;}
end;

procedure TFormMain.N_StartClick(Sender: TObject);
begin
  StartService();
end;

procedure TFormMain.N_StopClick(Sender: TObject);
begin
  if Application.MessageBox('是否确认停止服务？', '确认信息', MB_YESNO +
    MB_ICONQUESTION) = IDYES then
    StopService();
end;

procedure TFormMain.N_ReConnectClick(Sender: TObject);
begin
  dwReConnectServerTime := 0;
end;

procedure TFormMain.N_ReLoadConfigClick(Sender: TObject);
begin
  if Application.MessageBox('是否确认重新加载配置信息？', '确认信息', MB_OKCANCEL
    + MB_ICONQUESTION) <> IDOK then
    exit;
  LoadConfig();
end;

procedure TFormMain.N_CleaeLogClick(Sender: TObject);
begin
  if Application.MessageBox('是否确认清除显示的日志信息？', '确认信息',
    MB_OKCANCEL + MB_ICONQUESTION) <> IDOK then
    exit;
  MemoLog.Clear;
end;

procedure TFormMain.N_ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MemoLogChange(Sender: TObject);
begin
  if MemoLog.Lines.Count > 500 then
    MemoLog.Clear;
end;

procedure TFormMain.N_GeneralClick(Sender: TObject);
begin
  frmGeneralConfig.Top := Self.Top + 20;
  frmGeneralConfig.Left := Self.Left;
  with frmGeneralConfig do begin
    EditGateIPaddr.Text := GateAddr;
    EditGatePort.Text := IntToStr(GatePort);
    EditServerIPaddr.Text := ServerAddr;
    EditServerPort.Text := IntToStr(ServerPort);
    EditTitle.Text := TitleName;
    TrackBarLogLevel.Position := nShowLogLevel;
    EditSessionTimeOutTime.Text := IntToStr(dwSessionTimeOutTime div 1000);
    EditMaxConnect.value := nMaxConnOfIPaddr;
    EditConnSpaceOfIPaddr.Text := IntToStr(dwConnSpaceOfIPaddr);
    EditEncKeyFile.Text := sEnckeyFileName;
    case BlockMethod of
      mDisconnect:
        RadioDisConnect.Checked := True;
      mBlock:
        RadioAddTempList.Checked := True;
      mBlockList:
        RadioAddBlockList.Checked := True;
    end;
  end;
  frmGeneralConfig.ShowModal;
end;

procedure TFormMain.N_RegSetClick(Sender: TObject);
begin
  frmIDSrvConfig.Top := Self.Top + 20;
  frmIDSrvConfig.Left := Self.Left;
  with frmIDSrvConfig do begin
    CBNoThisSQL.Checked := boNoThisSQL;
    C_EnableIDSrv.Checked := BoEnableIDSrv;
    C_EnRegUser.Checked := boEnRegUser;
    C_EnModPass.Checked := boEnModPass;
    E_ACCOUNTServer.Text := ACCOUNTServer;
    E_ACCOUNTDB.Text := ACCOUNTDB;
    E_ACCOUNTID.Text := ACCOUNTID;
    E_ACCOUNTPWS.Text := ACCOUNTPWS;
  end;
  frmIDSrvConfig.ShowModal;
end;

end.

