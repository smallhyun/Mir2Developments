unit BCmain2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  syncobjs, StdCtrls, D7ScktComp, HUtil32, ExtCtrls, Winsock,
  IniFiles;


const
   MAX_USER = 1000;
   MAX_CLIENTRECEIVELENGTH = 300; // 100 BYTE PER SEC
   MAX_CHECKSENDLENGTH = 512;
   MAX_RADDR = 4;
//   SERVERBASEPORT = 5100;
//   USERBASEPORT = 7100;
   ServerPort : integer = 5100;
   GateBasePort : integer = 7100;

type
  {TSendDataInfo = record
    shandle:  integer;
    RemoteAddr: string;
  	 Socket: TCustomWinSocket;
    sendlist: TStringList;
  end;}

  TUserInfo = record
  	 Socket: TCustomWinSocket;
    Addr: string;
    SendLength: integer;
    SendLock: Boolean;
    SendLatestTime: longword;
    CheckSendLength: integer;
    SendAvailable: Boolean;
    SendCheck: Boolean;
    TimeOutTime: longword;
    ReceiveLength: integer;
    ReceiveTime: longword;
    shandle:  integer;
    RemoteAddr: string;
    sendlist: TStringList;
  end;

  TFrmMain = class(TForm)
    ServerSocket: TServerSocket;
    Memo: TMemo;
    SendTimer: TTimer;
    ClientSocket: TClientSocket;
    Panel1: TPanel;
    Label1: TLabel;
    LbConStatue: TLabel;
    EdUserCount: TEdit;
    Timer1: TTimer;
    BtnRun: TButton;
    DecodeTimer: TTimer;
    LbHold: TLabel;
    LbLack: TLabel;
    Label2: TLabel;
    CbAddrs: TComboBox;
    CbShowMessages: TCheckBox;
    procedure ServerSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocketClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ServerSocketClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure MemoChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ClientSocketConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure SendTimerTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
    procedure DecodeTimerTimer(Sender: TObject);
    procedure MemoDblClick(Sender: TObject);
    procedure CbAddrsChange(Sender: TObject);
  private
    UserCount: integer;
    lastsendstr: string;
    DisplayMsg: TStringList;
  	 chktime: Longword;
    connected: Boolean;
    LackAddrs: TStringList;
    loopstarttime: longword;
    looptime: longword;
    tryconntime: longword;
    procedure SetSendAvailable (shandle: integer);
    function  DataReceiveOK (shandle, alen: integer): Boolean;
    procedure ClearSendDataInfo;
    procedure KickUser (usrhandle: integer);
  public
    function  SendServerToClient (UInfo: TUserInfo; str: string): integer;
  end;

var
  FrmMain: TFrmMain;
  //ServerSocData: string;
  ServerSocList: TStringList;
  //SocLock: TCriticalSection;
  //UsrLock: TCriticalSection;
  //CSSockLock: TRTLCriticalSection;
  //CSUserLock: TRTLCriticalSection;
  ServerAddrList: TStringList;
  ServerIndex: integer;

  ServerConnection: Boolean;
  ServerCheckTime: longword;
  ServerBusy: Boolean;
  SendHoldCount: integer;
  ServerSendHolds: integer;
  ActiveConnectionCount: integer;
  UserInfos: array[0..MAX_USER-1] of TUserInfo;
  UserHold: Boolean;
  UserHoldTime: longword;


implementation

uses showip;

{$R *.DFM}


procedure TFrmMain.FormCreate(Sender: TObject);
var
	i, onaddr: integer;
   ini: TIniFile;
   saddr, s1, s2, s3, s4, s5: string;
   n, localport: integer;
   remoteport, sidx: integer;
begin
   loopstarttime := GetTickCount;
   ServerAddrList := TStringList.Create;

   ini := TIniFile.Create ('.\mirgate.ini');
   with ini do begin
      Panel1.Color := GetDefColorByName (ReadString ('server', 'Color', 'LTGRAY'));
      FrmMain.Caption :='v031223:'+ReadString ('server', 'Title', '');
      ServerPort := ReadInteger ('server', 'ServerPort', ServerPort);
      GateBasePort := ReadInteger ('server', 'GatePort', GateBasePort);
      sidx := Abs (ReadInteger ('server', 'index', 0));
      s1 := ReadString ('server', 'Server1', '');
      s2 := ReadString ('server', 'Server2', '');
      s3 := ReadString ('server', 'Server3', '');
      s4 := ReadString ('server', 'Server4', '');
      s5 := ReadString ('server', 'Server5', '');
   end;
   n := 0;
   if s1 <> '' then begin CbAddrs.Items.Add (s1 + ' (' + IntToStr(n) + ')'); Inc(n); end;
   if s2 <> '' then begin CbAddrs.Items.Add (s2 + ' (' + IntToStr(n) + ')'); Inc(n); end;
   if s3 <> '' then begin CbAddrs.Items.Add (s3 + ' (' + IntToStr(n) + ')'); Inc(n); end;
   if s4 <> '' then begin CbAddrs.Items.Add (s4 + ' (' + IntToStr(n) + ')'); Inc(n); end;
   if s5 <> '' then begin CbAddrs.Items.Add (s5 + ' (' + IntToStr(n) + ')'); Inc(n); end;
   if sidx < CbAddrs.Items.Count then begin
      CbAddrs.ItemIndex := sidx;
      ServerIndex := sidx;
   end;

//   onaddr := 1;
//   SetSockOpt (ServerSocket.Socket.SocketHandle, SOL_SOCKET, SO_REUSEADDR, @onaddr, sizeof(integer));
//   ServerSocket.Active := TRUE;
   UserCount := 0;

   ServerSocList := TStringList.Create;
   DisplayMsg := TStringList.Create;
   LackAddrs := TStringList.Create;

   ServerBusy := FALSE;
   SendHoldCount := 0;
   ServerSendHolds := 0;
   chktime := GetTickCount;
   //for i:=0 to MAX_USER-1 do begin
   //   SendInfos[i].shandle := -1;
   //   SendInfos[i].Socket := nil;
   //   SendInfos[i].sendlist := TStringList.Create;
   //end;

   UserHold := FALSE;
   UserHoldTime := GetTickCount;

   for i:=0 to MAX_USER-1 do begin
   	with UserInfos[i] do begin
         Socket 		:= nil;
         Addr 			:= '';
         SendLength 	:= 0;
         SendLock 	:= FALSE;
         SendLatestTime := GetTickCount;
         SendAvailable := TRUE;
         SendCheck := FALSE;
         CheckSendLength := 0;
    		ReceiveLength := 0;
    		ReceiveTime := GetTickCount;
         shandle  := -1;
         sendlist := TStringList.Create;
      end;
   end;

   with ClientSocket do begin
      Active := FALSE;
   end;
   tryconntime := GetTickCount - 25 * 1000;

   Connected := FALSE;

   with ServerSocket do begin
      Active := FALSE;
      Port := GateBasePort + ServerIndex; {사용자의 접속을 받는 port}
      Active := TRUE;
   end;
   ServerConnection := FALSE;
   SendTimer.Enabled := TRUE;
   
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
var
   i: integer;
begin
	DisplayMsg.Free;
   ///SocLock.Free;
   ///UsrLock.Free;
   ServerSocList.Free;
   for i:=0 to MAX_USER-1 do
      UserInfos[i].sendlist.Free;
end;


procedure TFrmMain.ClearSendDataInfo;
var
   i: integer;
begin
   for i:=0 to MAX_USER-1 do begin
      UserInfos[i].shandle := -1;
      UserInfos[i].Socket := nil;
      UserInfos[i].sendlist.Clear;
   end;
end;

procedure TFrmMain.ClientSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
	i: integer;
begin
	ServerConnection := TRUE;
   UserCount := 0;
   ServerCheckTime  := GetTickCount;
   try
      for i:=0 to MAX_USER-1 do begin
         UserInfos[i].Socket := nil;
         UserInfos[i].SHandle := -1;
         UserInfos[i].Addr   := '';
    	end;
   finally
   end;
   ClearSendDataInfo;
   Connected := TRUE;
end;

procedure TFrmMain.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
	i: integer;
begin
   for i:=0 to MAX_USER-1 do begin
      if UserInfos[i].Socket <> nil then begin
         UserInfos[i].Socket.Close;
         UserInfos[i].Socket := nil;
         UserInfos[i].SHandle := -1;
         UserInfos[i].Addr := '';
      end;
   end;
   ClearSendDataInfo;
   ServerSocList.Clear;
	ServerConnection := FALSE;
   UserCount := 0;
   EdUserCount.Text := IntToStr(UserCount);
   Connected := FALSE;
end;

procedure TFrmMain.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ClientSocket.Close;
   ClientSocketDisconnect(Sender, Socket);
	ErrorCode := 0;
   Connected := FALSE;
end;

procedure TFrmMain.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
	str: string;
begin
   str := Socket.ReceiveText;
	try
   	//EnterCriticalSection (CSSockLock);
      //ServerSocData := ServerSocData + str;
      ServerSocList.Add (str);
 	finally
   	//LeaveCriticalSection (CSSockLock);
	end;
/////   Memo.Lines.Add (str);
end;

function CharCount (str: string; chr: Char): integer;
var
   i: integer;
begin
   Result := 0;
   for i:=1 to Length(str) do
      if str[i] = chr then
         Inc (Result);
end;

//=====================================================

procedure TFrmMain.DecodeTimerTimer(Sender: TObject);
const
	busy: Boolean = FALSE;
var
	socstr, data, temp, shandle: string;
   i, j, k, ident, sh: integer;
   ll: longword;
begin
	if busy then exit;
   try
      busy := TRUE;
      socstr := '';
      while TRUE do begin
         if ServerSocList.Count > 0 then begin
            socstr := socstr + ServerSocList[0];
            ServerSocList.Delete (0);
         end;
         while TRUE do begin
            if CharCount (socstr, '$') >= 1 then begin
               socstr := ArrestStringEx (socstr, '%', '$', data);
               if data <> '' then begin
                  if data[1] = '+' then begin {check code}
                     if data[2] = '-' then begin {kick user}
                        KickUser (Str_ToInt (Copy (data, 3, Length(data)-2), 0));
                     end else begin
                        ServerCheckTime := GetTickCount;
                        ServerBusy := FALSE;
                     end;
                  end else begin
                     data := GetValidStr3 (data, shandle, ['/']);
                     sh := Str_ToInt (shandle, -1);
                     if sh > -1 then begin
                        for i:=0 to MAX_USER-1 do begin
                           if UserInfos[i].shandle = sh then begin
                              UserInfos[i].sendlist.Add (data);
                              break;
                           end;
                        end;
                     end;
                  end;
               end else
                  break;
            end else
               break;
         end;
         if ServerSocList.Count = 0 then begin
            if socstr <> '' then
               ServerSocList.Add (socstr);
            break;
         end;
      end;

      SendHoldCount := 0;
      ServerSendHolds := 0;
      LackAddrs.Clear;
      for i:=0 to MAX_USER-1 do begin
         if UserInfos[i].shandle > -1 then begin
            while TRUE do begin
               if UserInfos[i].SendList.Count <= 0 then break;
               ident := SendServerToClient (UserInfos[i], UserInfos[i].SendList[0]);
               if ident >= 0 then begin
                  if ident = 1 then begin
                     {send ok}
                     UserInfos[i].SendList.Delete (0);
                  end else begin
                     {send wait}
                     if UserInfos[i].SendList.Count > 100 then begin
                        for j:=0 to 50 do
                           UserInfos[i].SendList.Delete (0);
                     end;
                     ServerSendHolds := ServerSendHolds + UserInfos[i].SendList.Count;
                     LackAddrs.Add (UserInfos[i].RemoteAddr + ' : ' + IntToStr(UserInfos[i].SendList.Count));
                     Inc (SendHoldCount);
                     break;
                  end;
               end else begin
                  {invalid socket}
                  UserInfos[i].shandle := -1;
                  UserInfos[i].Socket := nil;
                  UserInfos[i].sendlist.Clear;
                  break;
               end;
            end;
         end;
      end;

      { 2초에 한번 채크 코드를 보낸다 }
      if (GetTickCount - chktime > 2000) then begin
         chktime := GetTickCount;
         if ServerConnection then begin
            ClientSocket.Socket.SendText ('%--$');
         end;
         if GetTickCount - ServerCheckTime > 10000 then begin {server busy}
            ServerBusy := TRUE;
            ClientSocket.Close;
         end;
      end;
      busy := FALSE;
   except
      busy := FALSE;
      //ShowMessage ('Exception... DecodeTimer');
   end;
   ll := GetTickCount - loopstarttime;
   loopstarttime := GetTickCount;
   if ll > looptime then looptime := ll;
   Label2.Caption := IntToStr (looptime);
   if looptime > 50 then Dec (looptime, 50);
end;



//======================================================


{1 : success,  0: wait send,  -1: invalid socket}
function TFrmMain.SendServerToClient (UInfo: TUserInfo; str: string): integer;
var
	i, j: integer;
   sendok: Boolean;
begin
	Result := -1; {invalid socket}
   if UInfo.Socket <> nil then begin
      if not UInfo.SendLock then begin
         with UInfo do begin
            if not SendAvailAble then begin
               if TimeOutTime < GetTickCount then begin
                  SendAvailAble := TRUE;
                  CheckSendLength := 0;
                  UserHold := TRUE;
                  UserHoldTime := GetTickCount;
               end;
            end;
            if SendAvailAble then begin
               if CheckSendLength >= 250 then begin
                  if not SendCheck then begin
                     SendCheck := TRUE;
                     str := '*' + str; //send verify code..
                  end;
                  if CheckSendLength >= MAX_CHECKSENDLENGTH then begin
                     SendAvailAble :=FALSE;
                     TimeOutTime := GetTickCount + 5000;
                  end;
               end;
               Socket.SendText (str);
               SendLength := SendLength + Length(str);
               CheckSendLength := CheckSendLength + Length(str);
               Result := 1; {send success}
            end else
               Result := 0;
         end;
      end else
         Result := 0;
   end;
end;

procedure TFrmMain.SetSendAvailable (shandle: integer);
var
	i: integer;
begin
   try
   	//EnterCriticalSection (CSUserLock);
      for i:=0 to MAX_USER-1 do begin
      	if UserInfos[i].Socket <> nil then begin
            if UserInfos[i].Socket.SocketHandle = shandle then begin
               UserInfos[i].SendAvailable := TRUE;
               UserInfos[i].SendCheck := FALSE;
               UserInfos[i].CheckSendLength := 0;
               break;
            end;
       	end;
    	end;
   finally
   	//LeaveCriticalSection (CSUserLock);
   end;
end;

function TFrmMain.DataReceiveOK (shandle, alen: integer): Boolean;
var
	i: integer;
begin
	Result := FALSE;
   try
   	//EnterCriticalSection (CSUserLock);
      for i:=0 to MAX_USER-1 do begin
      	if UserInfos[i].Socket <> nil then begin
            if UserInfos[i].Socket.SocketHandle = shandle then begin
               with UserInfos[i] do begin
               	if GetTickCount - ReceiveTime < 1000 then begin
                     ReceiveLength := ReceiveLength + alen;
                  	if ReceiveLength <= MAX_CLIENTRECEIVELENGTH then
                     	Result := TRUE;
                	end else begin
                  	ReceiveLength := alen;
                     ReceiveTime   := GetTickCount;
                     Result := TRUE;
                  end;
             	end;
               break;
            end;
       	end;
    	end;
   finally
   	//LeaveCriticalSection (CSUserLock);
   end;
end;

procedure TFrmMain.ServerSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
	i: integer;
begin
   if ServerConnection then begin
      try
         for i:=0 to MAX_USER-1 do begin
            if UserInfos[i].Socket = nil then begin {빈곳}
               UserInfos[i].Socket := Socket;
               UserInfos[i].Addr   := Socket.RemoteAddress;
               UserInfos[i].SendLength	:= 0;
               UserInfos[i].SendLock	:= FALSE;
               UserInfos[i].SendLatestTime := GetTickCount;
               UserInfos[i].SendAvailable := TRUE;
               UserInfos[i].SendCheck := FALSE;
               UserInfos[i].CheckSendLength := 0;
    				UserInfos[i].ReceiveLength := 0;
    				UserInfos[i].ReceiveTime := GetTickCount;
               UserInfos[i].shandle := Socket.SocketHandle;
               UserInfos[i].RemoteAddr := Socket.RemoteAddress;
               UserInfos[i].sendlist.Clear;
               Inc (UserCount);
               break;
            end;
         end;
      finally
      end;
      {send connection}
      ClientSocket.Socket.SendText ('%O' + IntToStr(Socket.SocketHandle) + '/' + Socket.RemoteAddress + '$');
      EdUserCount.Text := IntToStr(UserCount);
      DisplayMsg.Add ('Connect ' + Socket.RemoteAddress);
	end else begin
   	Socket.Close;
      DisplayMsg.Add ('Kick off ' + Socket.RemoteAddress);
   end;
end;

procedure TFrmMain.ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
	i: integer;
   remote : string;
   flag: Boolean;
begin
	flag := FALSE;
   remote := Socket.RemoteAddress;
   try
      for i:=0 to MAX_USER-1 do begin
      	if UserInfos[i].Socket <> nil then begin
            if UserInfos[i].Socket = Socket then begin
               UserInfos[i].Socket := nil;
               UserInfos[i].Addr   := '';
               UserInfos[i].shandle := -1;
               UserInfos[i].sendlist.Clear;
               flag := TRUE;
               Dec (UserCount);
               break;
            end;
       	end;
    	end;
   finally
   end;
   {send disconnect..}
   if flag and ServerConnection then begin
      ClientSocket.Socket.SendText ('%X' + IntToStr(Socket.SocketHandle) + '$');
      EdUserCount.Text := IntToStr(UserCount);
      DisplayMsg.Add ('Disconnect ' + Socket.RemoteAddress);
	end;
   ///shutdown (Socket.SocketHandle, 0);  //WINSOCK closesocket.......
end;

procedure TFrmMain.ServerSocketClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   DisplayMsg.Add ('Error ' + IntToStr(ErrorCode) + ': ' + Socket.RemoteAddress);
   //ServerSocketClientDisconnect (Sender, Socket);
   Socket.Close;
	ErrorCode := 0;
end;

procedure TFrmMain.ServerSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
	n: integer;
   temp, data: string;
begin
	data := Socket.ReceiveText;
   if (data <> '') and Connected then begin
      n := pos ('*', data);
      if n > 0 then begin
         SetSendAvailable (Socket.SocketHandle);
         temp := Copy (data, 1, n-1);
         data := temp + Copy (data, n+1, Length(data));
      end;
      if data <> '' then begin
         if ServerConnection and (not ServerBusy) then {서버와 연결상태 확인}
         	if DataReceiveOK (Socket.SocketHandle, Length(data)) then begin {초당 수신량 조절}
            	ClientSocket.Socket.SendText ('%A' + IntToStr(Socket.SocketHandle) + '/' + data + '$');
           	end;
      end;
	end;
end;

procedure TFrmMain.KickUser (usrhandle: integer);
var
   i: integer;
begin
   if usrhandle <> 0 then begin
      try
         for i:=0 to MAX_USER-1 do begin
            if UserInfos[i].Socket <> nil then begin
               if UserInfos[i].Socket.SocketHandle = usrhandle then begin
                  UserInfos[i].Socket.Close;
                  break;
               end;
            end;
         end;
      finally
      end;
   end;
end;



//======================================================


procedure TFrmMain.MemoChange(Sender: TObject);
begin
	if Memo.Lines.Count > 200 then begin
   	Memo.Lines.Clear;
   end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var i: integer;
begin
   if CbShowMessages.Checked then begin
      for i:=0 to DisplayMsg.Count-1 do
         Memo.Lines.Add (DisplayMsg[i]);
   end;
	DisplayMsg.Clear;
end;


//=================================================


procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
   i: integer;
begin
	if mrYes = MessageDlg ('Would you want colse Sel.Chr. gate program ?', mtWarning, mbYesNoCancel, 0) then begin
   	CanClose := TRUE;
      ClientSocket.Close;
      ServerSocket.Close;
      for i:=0 to MAX_USER-1 do begin
         if UserInfos[i].Socket <> nil then begin
            UserInfos[i].Socket.Close;
            UserInfos[i].Socket := nil;
            UserInfos[i].Addr := '';
         end;
      end;
      ClientSocket.Active := FALSE;
      ServerSocket.Active := FALSE;
	end else
   	CanClose := FALSE;
end;

procedure TFrmMain.SendTimerTimer(Sender: TObject);
var
	i: integer;
begin
   if ServerSocket.Socket <> nil then
	   ActiveConnectionCount := ServerSocket.Socket.ActiveConnections;
	if UserHold then begin
   	LbHold.Caption := IntToStr(ActiveConnectionCount) + '#';
   	if GetTickCount - UserHoldTime > 3000 then begin
      	UserHold := FALSE;
      end;
   end else
   	LbHold.Caption := IntToStr(ActiveConnectionCount);

   {일정시간 동안 신호가 없는 소켓 접속 종료}
   if ServerConnection and (not ServerBusy) then begin
   	for i:=0 to MAX_USER-1 do begin
      	if UserInfos[i].Socket <> nil then begin
            if GetTickCount - UserInfos[i].ReceiveTime > 60 * 60 * 1000 then begin
               UserInfos[i].Socket.Close;
               UserInfos[i].Socket := nil;
               UserInfos[i].SHandle := -1;
               UserInfos[i].Sendlist.Clear;
               UserInfos[i].Addr   := '';
            end;
        	end;
    	end;
	end;

	if not ServerConnection then begin
   	LbConStatue.Caption := '---]   [---';
      if GetTickCount - tryconntime > 30 * 1000 then begin
         tryconntime := GetTickCount;
         with ClientSocket do begin
            Active := FALSE;
            Port := ServerPort + ServerIndex;
            Address := cbAddrs.Items[ServerIndex];
            if Address <> '' then
               Active := TRUE;
         end;
      end;
   end else begin
      if ServerBusy then
   		LbConStatue.Caption := '---]$$[---'
   	else begin
      	LbConStatue.Caption := '-----][-----';
         LbLack.Caption := IntToStr(ServerSendHolds) + '/' + IntToStr(SendHoldCount);
   	end;
   end
end;


procedure TFrmMain.BtnRunClick(Sender: TObject);
begin
	if not ServerConnection then begin
      SendTimer.Enabled := TRUE;
      with ServerSocket do begin
         Active := FALSE;
         Port := GateBasePort + ServerIndex; {사용자의 접속을 받는 port}
         Active := TRUE;
      end;
	end;
end;

procedure TFrmMain.MemoDblClick(Sender: TObject);
var
   i: integer;
begin
   with FrmShowIp do begin
      Memo.Lines.Clear;
      for i:=0 to LackAddrs.Count-1 do
         Memo.Lines.Add (LackAddrs[i]);
      Show;
   end;
end;

procedure TFrmMain.CbAddrsChange(Sender: TObject);
begin
   ServerIndex := CbAddrs.ItemIndex;
end;

end.
