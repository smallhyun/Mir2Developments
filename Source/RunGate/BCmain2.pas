unit BCmain2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  syncobjs, StdCtrls, D7ScktComp, HUtil32, ExtCtrls, Winsock,
  IniFiles, Grobal2, EdCode;


const
   VER_STR = 'v050531:';
   FOREIGNVERSION = FALSE; //TRUE;

   MAX_USER = 1000;
   MAX_CLIENTRECEIVELENGTH = 300; // 100 BYTE PER SEC
   MAX_CHECKSENDLENGTH = 512;
   MAX_RADDR = 4;
//   SERVERBASEPORT = 5100;
//   USERBASEPORT = 7100;
   ServerPort : integer = 5100;
   GateBasePort : integer = 7100;

type
  TUserInfo = record
  	 Socket: TCustomWinSocket;
    SocData: string;   //받은 버퍼
    SendData: string;  //보낼것이 남음
    ServerUserIndex: integer;  //서버에서의 UserList에서의 index
    PriviousCheckCode: integer;
    CrackWanrningLevel: integer;
    BoLoginCode: Boolean;
    //SendLength: integer;
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
  end;

  TSendUserData = record
    uindex: integer;   ///user array 에서의 index
    shandle: integer;
    data: string;   //데이타
  end;
  PTSendUserData = ^TSendUserData;

  TReceiveData = record
    p: PAnsiChar;
    len: integer;
  end;
  PTReceiveData = ^TReceiveData;


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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LbPort: TLabel;
    CbDisplay: TCheckBox;
    CbShowSocData: TCheckBox;
    Label7: TLabel;
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
    procedure Label5DblClick(Sender: TObject);
    procedure EdUserCountDblClick(Sender: TObject);
  private
    UserCount: integer;
    lastsendstr: string;
    DisplayMsg: TStringList;
  	 chktime: Longword;
    sendremtime: Longword;
    connected: Boolean;
    LackAddrs: TStringList;
    loopstarttime: longword;
    looptime, receivetime: longword;
    sendtime: longword;
    tryconntime: longword;
    displaytime: longword;

    lt_receivelen: integer;
    lt_receivetime: longword;
    lc_receivelen: integer;
    lc_sendlen: integer;
    lc_sendlenclient: integer;
    lt_sendserver1: integer;
    lt_sendserver2: integer;
    lt_sendserver3: integer;

    //function  DataReceiveOK (shandle, alen: integer): Boolean;
    procedure ClearSendDataInfo;
  public
    procedure SendSocketS (pbin: PAnsiChar; len: integer);
    procedure SendSocketMsgS (ident: integer; uindex: word; socnum: integer; srvindex: word; len: integer; pbin: PAnsiChar);
    procedure ProcReceiveBuffer (pReceive: PAnsiChar; reclen: integer);
    procedure ProcessMakeSocketStr (shandle, uindex: integer; pbody: PAnsiChar; len: integer);
    procedure ProcessUserPacket (psend: PTSendUserData);
    procedure ProcessPacket (psend: PTSendUserData);
    //function  SendServerToClient (UInfo: TUserInfo; str: string): integer;
  end;

  procedure CheckListValid (alist: TStringList);
  function  LoadAbusiveList (flname: string): Boolean;
  function  ChangeAbusiveText (var str: string): Boolean;

var
  FrmMain: TFrmMain;
  //ServerSocData: string;
  ReceiveBuffers: TList;
  pReceiveBuf: PAnsiChar;
  ReceiveBufLen: integer;
  ReceiveSocList: TList;
  SendUserBuffer: TList;

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
  AbusiveList: TStringList;
  SendToServerMaxTime: integer;
  MaxTime1: longword;
  MaxTime2: longword;
  BoShowByByte: Boolean;

  ErrorCount1: integer;
  ErrorCount2: integer;
  ErrorCount3: integer;
  ErrorCount4: integer;
  ErrorCount5: integer;


implementation

uses showip, WarningMsg;

{$R *.DFM}


procedure CheckListValid (alist: TStringList);
var
   i: integer;
begin
   i := 0;
   while TRUE do begin
      if i >= alist.Count-1 then break;
      if Trim(alist[i]) = '' then begin
         alist.Delete (i);
         continue;
      end;
      Inc (i);
   end;
end;

function  LoadAbusiveList (flname: string): Boolean;
begin
   Result := FALSE;
   if FileExists (flname) then begin
      AbusiveList.LoadFromFile (flname);
      CheckListValid (AbusiveList);
      Result := TRUE;
   end;
end;

function  ChangeAbusiveText (var str: string): Boolean;
   function strstr (elementptr, dptr: PAnsiChar; elen, dlen: integer): PAnsiChar;
   var
      i, old: integer;
      eptr: PAnsiChar;
   begin
      Result := nil;
      old := elen;
      while TRUE do begin
         if dlen <= 0 then break;
         if byte(dptr^) = byte(elementptr^) then begin
            eptr := elementptr;
            Result := dptr;
            elen := old;
            while TRUE do begin
               if byte(dptr^) <> byte(eptr^) then begin
                  Result := nil;
                  break;
               end;
               Dec(dlen);
               Dec(elen);
               if (dlen <= 0) or (elen <= 0) then begin
                  if elen > 0 then Result := nil;
                  exit;
               end;
               dptr := PAnsiChar(integer(dptr) + 1);
               eptr := PAnsiChar(integer(eptr) + 1);
            end;
         end else begin
            if {(byte(dptr^) >= $A1) or} (byte(dptr^) >= $B0) then begin   //sonmg(2004/12/13)
               dptr := PAnsiChar(integer(dptr) + 1);
               Dec (dlen);
            end;
         end;
         dptr := PAnsiChar(integer(dptr) + 1);
         Dec (dlen);
      end;
   end;
var
   i, k, slen, dlen, pl, dl: integer;
   dptr, pstr, fptr: PAnsiChar;
   flag: Boolean;
begin
   Result := FALSE;
   dlen := Length(str);
   for i:=0 to AbusiveList.Count-1 do begin
      slen := Length(AbusiveList[i]);
      if slen <= dlen then begin
         pstr := @(AbusiveList[i][1]);
         dptr := @(str[1]);
         pl := Length(AbusiveList[i]);
         dl := Length(str);
         while TRUE do begin
            fptr := strstr (pstr , dptr, pl, dl);
            if fptr <> nil then begin
               FillChar (fptr^, pl, '*');
               Result := TRUE;
            end else
               break;
         end;
      end;
   end;
end;

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
      FrmMain.Caption := VER_STR+ReadString ('server', 'Title', '');
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
   BoShowByByte := TRUE;

   ReceiveBuffers := TList.Create;
   pReceiveBuf := nil;
   ReceiveBufLen := 0;
   DisplayMsg := TStringList.Create;
   LackAddrs := TStringList.Create;
   AbusiveList := TStringList.Create;
   ReceiveSocList := TList.Create;
   SendUserBuffer := TList.Create;

      if not LoadAbusiveList ('!Abuse.txt') then
         ShowMessage ('!Abuse.txt not found.');

   ServerConnection := FALSE;

   ServerBusy := FALSE;
   SendHoldCount := 0;
   ServerSendHolds := 0;
   chktime := GetTickCount;
   //for i:=0 to MAX_USER-1 do begin
   //   SendInfos[i].shandle := -1;
   //   SendInfos[i].Socket := nil;
   //end;

   UserHold := FALSE;
   UserHoldTime := GetTickCount;

   for i:=0 to MAX_USER-1 do begin
   	with UserInfos[i] do begin
         Socket 		:= nil;
         SocData     := '';
         SendData    := '';     
         ServerUserIndex := 0;  //기본...
         PriviousCheckCode  := -1;
         CrackWanrningLevel := 0;
         BoLoginCode := TRUE;
         //SendLength 	:= 0;
         SendLock 	:= FALSE;
         SendLatestTime := GetTickCount;
         SendAvailable := TRUE;
         SendCheck := FALSE;
         CheckSendLength := 0;
    		ReceiveLength := 0;
    		ReceiveTime := GetTickCount;
         shandle  := -1;
      end;
   end;
   SendToServerMaxTime := 100;
   MaxTime1 := 50;
   MaxTime2 := 50;

   with ClientSocket do begin
      Active := FALSE;
   end;
   tryconntime := GetTickCount - 25 * 1000;
   displaytime := GetTickCount;

   Connected := FALSE;

   BtnRunClick (self);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
var
   i: integer;
begin
	DisplayMsg.Free;
   ///SocLock.Free;
   ///UsrLock.Free;
   for i:=0 to ReceiveBuffers.Count-1 do begin
      FreeMem (PTReceiveData (ReceiveBuffers[i]).p);
      Dispose (PTReceiveData (ReceiveBuffers[i]));
   end;
   ReceiveBuffers.Free;

   AbusiveList.Free;
   ReceiveSocList.Free;
   SendUserBuffer.Free;
end;


procedure TFrmMain.ClearSendDataInfo;
var
   i: integer;
begin
   for i:=0 to MAX_USER-1 do begin
      UserInfos[i].shandle := -1;
      UserInfos[i].Socket := nil;
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
      end;
   end;
   ClearSendDataInfo;
   if pReceiveBuf <> nil then
      FreeMem (pReceiveBuf);
   pReceiveBuf := nil;   
   ReceiveBufLen := 0;

   for i:=0 to ReceiveBuffers.Count-1 do begin
      FreeMem (PTReceiveData (ReceiveBuffers[i]).p);
      Dispose (PTReceiveData (ReceiveBuffers[i]));
   end;
   ReceiveBuffers.Clear;

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
   //ClientSocketDisconnect(Sender, Socket);
	ErrorCode := 0;
   Connected := FALSE;
end;

procedure TFrmMain.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
   len: integer;
   ll, start: longword;
   p: PAnsiChar;
   //prec: PTReceiveData;
begin
   try
      start := GetTickCount;

      len := Socket.ReceiveLength;
      GetMem (p, len);
      Socket.ReceiveBuf (p^, len);
      //new (prec);
      //prec.p := p;
      //prec.len := len;
      ProcReceiveBuffer (p, len);
      //ReceiveBuffers.Add (prec);

      lt_receivelen := lt_receivelen + len;

      ll := GetTickCount - start;
      if ll > receivetime then receivetime := ll;
   except
      Memo.Lines.Add ('[Exception] ClientSocketRead');
   end;
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

procedure TFrmMain.SendSocketS (pbin: PAnsiChar; len: integer);  //무조건 보낸다.
begin
   with ClientSocket do begin
      if Socket.Connected then
         Socket.SendBuf (pbin^, len);
   end;
end;

procedure TFrmMain.SendSocketMsgS (ident: integer; uindex: word; socnum: integer; srvindex: word; len: integer; pbin: PAnsiChar);
var
   buflen: integer;
   p: PAnsiChar;
   msg: TMsgHeader;
begin
   msg.Code := longword($aa55aa55);
   msg.SNumber := socnum;
   msg.UserGateIndex := uindex;
   msg.Ident := ident;
   msg.UserListIndex := srvindex;
   msg.Length := len;
   buflen := sizeof(TMsgHeader) + len;
   GetMem (p, buflen);
   Move (msg, p^, sizeof(TMsgHeader));
   if pbin <> nil then
      Move (pbin^, (@p[sizeof(TMsgHeader)])^, len);
   SendSocketS (p, sizeof(TMsgHeader) + len);
   FreeMem (p);
end;


//=====================================================

procedure TFrmMain.ProcReceiveBuffer (pReceive: PAnsiChar; reclen: integer);
var
   pbody, pwork, ptemp: PAnsiChar;
   i, len, n: integer;
   pheader: PTMsgHeader;
begin
   try
      ReAllocMem (pReceiveBuf, ReceiveBufLen + reclen);
      Move (pReceive^, (@pReceiveBuf[ReceiveBufLen])^, reclen);
      FreeMem (pReceive);
      len := ReceiveBufLen + reclen;
      pwork := pReceiveBuf;                     //pwork

      while len >= sizeof(TMsgHeader) do begin
         pheader := PTMsgHeader (pwork);
         if longword(pheader.Code) = $aa55aa55 then begin
            if len < sizeof(TMsgHeader) + abs(pheader.Length) then break;
            pbody := @pwork[sizeof(TMsgHeader)];
            //.....pheader, pbody, pheader.Length...
            case pheader.Ident of
               GM_CHECKSERVER:
                  begin
                     ServerBusy := FALSE;
                     ServerCheckTime := GetTickCount;
                  end;
               GM_SERVERUSERINDEX:
                  begin
                     if (pheader.UserGateIndex < MAX_USER) then
                        if UserInfos[pheader.UserGateIndex].Shandle = pheader.SNumber then begin
                           UserInfos[pheader.UserGateIndex].ServerUserIndex := pheader.UserListIndex;
                        end;
                  end;
               GM_RECEIVE_OK:
                  begin
                     SendSocketMsgS (GM_RECEIVE_OK, 0, 0, 0, 0, nil);
                  end;
               GM_DATA:
                  begin
                     processMakeSocketStr (pheader.SNumber, pheader.UserGateIndex, pbody, pheader.Length);
                  end;
               GM_TEST:
                  begin
                     i := 0;
                  end;
               GM_SENDPUBLICKEY:
                  begin
                     SetPublicKey( pheader.UserListIndex );
                  end;
               else begin
                  Inc (ErrorCount1);
               end;
            end;

            pwork := @pwork[sizeof(TMsgHeader) + abs(pheader.Length)];
            len := len - (sizeof(TMsgHeader) + abs(pheader.Length));
         end else begin
            pwork := @pwork[1];
            Dec (len);
            Inc (ErrorCount2);
         end;
      end;

      if len > 0 then begin  //남았음
         GetMem (ptemp, len);
         Move (pwork^, ptemp^, len);
         FreeMem (pReceiveBuf);
         pReceiveBuf := ptemp;       //psrc 나머지만 있음
         ReceiveBufLen := len;
      end else begin
         FreeMem (pReceiveBuf);
         pReceiveBuf := nil;
         ReceiveBufLen := 0;
      end;
   except
      Memo.Lines.Add ('[Exception] ProcReceiveBuffer');
   end;
end;

procedure TFrmMain.DecodeTimerTimer(Sender: TObject);
const
	busy: Boolean = FALSE;
var
   ll, start: longword;
   i, len: integer;
   p: PAnsiChar;
   prec: PTReceiveData;
   psend: PTSendUserData;
   sdata: TSendUserData;
begin
	if busy then exit;
   try
      {start := GetTickCount;
      while TRUE do begin
         if ReceiveBuffers.Count <= 0 then break;
         prec := PTReceiveData (ReceiveBuffers[0]);
         ReceiveBuffers.Delete(0);
         ProcReceiveBuffer (prec.p, prec.len);
         Dispose (prec);
         if GetTickCount - start > SendToServerMaxTime then break;
      end;  }
      if GetTickCount - lt_receivetime >= 1000 then begin
         lt_receivetime := GetTickCount;
         if not BoShowByByte then begin
            Label5.Caption := IntToStr(lc_receivelen div 1024) + 'KB/' +
                              IntToStr(lt_receivelen div 1024) + 'KB';
            Label7.Caption := IntToStr(lt_sendserver1 div 1024) + 'KB/' +
                              IntToStr(lt_sendserver2 div 1024) + 'KB/' +
                              IntToStr(lt_sendserver3 div 1024) + 'KB - ' +
                              IntToStr(lc_sendlen div 1024) + 'KB/' +
                              IntToStr(lc_sendlenclient div 1024) + 'KB';
         end else begin
            Label5.Caption := IntToStr(lc_receivelen) + 'B/' +
                              IntToStr(lt_receivelen) + 'B';
            Label7.Caption := IntToStr(lt_sendserver1) + 'B/' +
                              IntToStr(lt_sendserver2) + 'B/' +
                              IntToStr(lt_sendserver3) + 'B - ' +
                              IntToStr(lc_sendlen) + 'B/' +
                              IntToStr(lc_sendlenclient) + 'B';
         end;
{
         if ServerSocket.Socket.ActiveConnections >= 3 then begin
            if lc_receivelen = 0 then begin
               FrmWarning.Execute (IntToStr(ServerSocket.Port));
            end else
               FrmWarning.Visible := FALSE;
         end;
}
         lt_receivelen := 0;
         lc_receivelen := 0;
         lc_sendlen := 0;
         lc_sendlenclient := 0;
         lt_sendserver1 := 0;
         lt_sendserver2 := 0;
         lt_sendserver3 := 0;

      end;

      try
         start := GetTickCount;
         //클라이언트에서 받은 데이타를 서버로 보낸다.
         while TRUE do begin
            if ReceiveSocList.Count <= 0 then break;
            psend := ReceiveSocList[0];
            ReceiveSocList.Delete (0);
            ProcessUserPacket (psend);  //서버로 보낸다.
            Dispose (psend);
            if GetTickCount - start > MaxTime1 then break;
         end;
      except
         Memo.Lines.Add ('[Exception] DecodeTimerTImer->ProcessUserPacket');
      end;

      try
         start := GetTickCount;
         //서버에서 받은 데이타를 클라이언트로 전송한다.
         while TRUE do begin
            if SendUserBuffer.Count <= 0 then break;
            psend := PTSendUserData(SendUserBuffer[0]);
            SendUserBuffer.Delete (0);
            ProcessPacket (psend);   //클라이언트로 보낸다
            Dispose (psend);
            if GetTickCount - start > MaxTime2 then break;
         end;
      except
         Memo.Lines.Add ('[Exception] DecodeTimerTImer->ProcessPacket');
      end;

      try
         start := GetTickCount;
         if GetTickCount - sendremtime > 300 then begin
            sendremtime := GetTickCount;

            if ReceiveSocList.Count > 0 then begin
               if MaxTime1 < 300 then
                  Inc (MaxTime1);
            end else begin
               if MaxTime1 > 30 then
                  Dec (MaxTime1);
            end;
            if SendUserBuffer.Count > 0 then begin
               if MaxTime2 < 300 then
                  Inc (MaxTime2);
            end else begin
               if MaxTime2 > 30 then
                  Dec (MaxTime2);
            end;

            //미처 못 보낸것
            for i:=0 to MAX_USER-1 do begin
               if UserInfos[i].Socket <> nil then begin {빈곳}
                  if UserInfos[i].SendData <> '' then begin
                     sdata.uindex := i;
                     sdata.shandle := UserInfos[i].shandle;
                     sdata.Data := '';
                     ProcessPacket (@sdata);
                     if GetTickCount - start > 20 then break;
                  end;
               end;
            end;
         end;
      except
         Memo.Lines.Add ('[Exception] DecodeTimerTImer->ProcessPacket 2');
      end;

      { 2초에 한번 채크 코드를 보낸다 }
      if (GetTickCount - chktime > 2000) then begin
         chktime := GetTickCount;
         if ServerConnection then begin
            SendSocketMsgS (GM_CHECKCLIENT, 0, 0, 0, 0, nil);
            //ClientSocket.Socket.SendText ('%--$');
         end;
         if GetTickCount - ServerCheckTime > 60 * 1000 then begin {server busy}
            ServerBusy := TRUE;
            ClientSocket.Close;
         end;
         if looptime > 50 then Dec (looptime, 20);
         if receivetime > 1 then Dec (receivetime);
         if sendtime > 1 then Dec (sendtime);
      end;
      busy := FALSE;
   except
      Memo.Lines.Add ('[Exception] DecodeTimer');
      busy := FALSE;
   end;

   ll := GetTickCount - loopstarttime;
   loopstarttime := GetTickCount;
   if ll > looptime then looptime := ll;

   if GetTickCount - displaytime > 1000 then begin
      displaytime := GetTickCount;
      Label2.Caption := 'Loop <' + IntToStr (looptime);
      Label3.Caption := 'Rece <' + IntToStr (receivetime);
      Label4.Caption := 'Send <' + IntToStr (sendtime) + ' Lim' + IntToStr(MaxTime1) + '/' + IntToStr(MaxTime2);
   end;

end;

procedure TFrmMain.ProcessMakeSocketStr (shandle, uindex: integer; pbody: PAnsiChar; len: integer);
var
   makestr, sstr: string;
   pdef: PTDefaultMessage;
   psend: PTSendUserData;
begin
   try
      makestr := '';
      if len < 0 then begin  //short message...
         makestr := '#' + string (pbody) + '!';
      end else begin
         if len >= sizeof(TDefaultMessage) then begin
            pdef := PTDefaultMessage (pbody);
            if len > sizeof(TDefaultMessage) then begin
               makestr := '#' + EncodeMessage (pdef^) + string(PAnsiChar(@pbody[sizeof(TDefaultMessage)])) + '!';
            end else begin
               makestr := '#' + EncodeMessage (pdef^) + '!';
            end;
         end;
      end;
      if (uindex >= 0) and (uindex < MAX_USER) and (makestr <> '') then begin
         new (psend);
         psend.uindex := uindex;
         psend.shandle := shandle;
         psend.Data := makestr;
         SendUserBuffer.Add (psend);
      end;
   except
      Memo.Lines.Add ('[Exception] ProcessMakeSocketStr');
   end;
end;

procedure TFrmMain.ProcessUserPacket (psend: PTSendUserData);
var
   n, code, len, errcount: integer;
   workstr, data, head, body, say, whostr: string;
   pbuf: PAnsiChar;
   msg: TDefaultMessage;
begin
   try
      errcount := 0;
      lt_sendserver1 := lt_sendserver1 + Length(psend.data);
      if (psend.uindex >= 0) and (psend.uindex < MAX_USER) then begin
         if (UserInfos[psend.uindex].Shandle = psend.shandle) and (UserInfos[psend.uindex].CrackWanrningLevel < 10) then begin

            //불량 패킷 공격을 막기 위해
            //1K이상 누적 데이터가 쌓여 있는 경우에는
            //더 이상의 데이터는 무시한다.
            if Length(UserInfos[psend.uindex].SocData) > 20000 then begin
               UserInfos[psend.uindex].SocData := '';
               UserInfos[psend.uindex].CrackWanrningLevel := 99;
               psend.Data := '';
            end;

            workstr := UserInfos[psend.uindex].SocData + psend.Data;

            //패킷 단위로 분리한다.
            while CharCount (workstr, '!') >= 1 do begin
               data := '';
               WorkStr := ArrestStringEx (WorkStr, '#', '!', data);
               if Length(data) > 2 then begin
                  code := Str_ToInt (data[1], 99);
                  //if code = 0 then n := 9
                  //else n := code - 1;
                  if code = UserInfos[psend.uindex].PriviousCheckCode then begin
                     Inc (UserInfos[psend.uindex].CrackWanrningLevel);
                     continue; //복사된 패킷은 보내지 않는다.
                  end else
                     UserInfos[psend.uindex].PriviousCheckCode := code;
                  data := Copy (data, 2, Length(data)-1);

                  //패킷 분리
                  len := Length (data);
                  if len >= DEFBLOCKSIZE then begin

                     if UserInfos[psend.uindex].BoLoginCode then begin
                        //시작 메세지
                        lt_sendserver2 := lt_sendserver2 + Length(data);
                        UserInfos[psend.uindex].BoLoginCode := FALSE;
                        data := '#' + IntToStr(code) + data + '!';
                        GetMem (pbuf, Length(AnsiString(data)) + 1);
                        Move (PAnsiChar(AnsiString(data))^, pbuf^, Length(AnsiString(data)) + 1);
                        SendSocketMsgS (GM_DATA,
                                          psend.uindex,
                                          UserInfos[psend.uindex].Socket.SocketHandle,
                                          UserInfos[psend.uindex].ServerUserIndex,
                                          Length(data) + 1,
                                          pbuf);
                        FreeMem (pbuf);
                     end else begin
                        lt_sendserver3 := lt_sendserver3 + Length(data);
                        //일반 메세지
                        if len = DEFBLOCKSIZE then begin
                           head := data;
                           body := '';
                        end else begin
                           head := Copy (data, 1, DEFBLOCKSIZE);
                           body := Copy (data, DEFBLOCKSIZE+1, Length(data)- DEFBLOCKSIZE);
                        end;
                        msg  := DecodeMessage (head);

                        if body <> '' then begin
                           if msg.Ident = CM_SAY then begin  //욕설 필터
                              say := DecodeString (body);
                              if say <> '' then begin
                                 if say[1] = '/' then begin
                                    say := GetValidStr3 (say, whostr, [' ']);
                                    ChangeAbusiveText (say);
                                    say := whostr + ' ' + say;
                                 end else begin
                                    if say[1] <> '@' then
                                       ChangeAbusiveText (say);
                                 end;
                              end;
                              body := EncodeString (say);
                           end;
                           GetMem (pbuf, sizeof(TDefaultMessage) + Length(body) +1);
                           Move (PAnsiChar(@msg)^, pbuf^, sizeof(TDefaultMessage));
                           Move (PAnsiChar(AnsiString(body))^, (@pbuf[sizeof(TDefaultMessage)])^, Length(AnsiString(body))+1);
                           SendSocketMsgS (GM_DATA,
                                             psend.uindex,
                                             UserInfos[psend.uindex].Socket.SocketHandle,
                                             UserInfos[psend.uindex].ServerUserIndex,
                                             sizeof(TDefaultMessage) + Length(body)+1,
                                             pbuf);
                           FreeMem (pbuf);
                        end else begin
                           GetMem (pbuf, sizeof(TDefaultMessage));
                           Move (msg, pbuf^, sizeof(TDefaultMessage));
                           SendSocketMsgS (GM_DATA,
                                             psend.uindex,
                                             UserInfos[psend.uindex].Socket.SocketHandle,
                                             UserInfos[psend.uindex].ServerUserIndex,
                                             sizeof(TDefaultMessage),
                                             pbuf);
                           FreeMem (pbuf);
                        end;
                     end;

                  end;
               end else begin
                  if errcount >= 1 then begin
                     WorkStr := '';
                  end;
                  Inc (errcount);
                  //break;
               end;
            end;

            UserInfos[psend.uindex].SocData := WorkStr;

         end else begin
            UserInfos[psend.uindex].SocData := '';
         end;

      end;
   except
      if (psend.uindex >= 0) and (psend.uindex < MAX_USER) then
         data := '[' + UserInfos[psend.uindex].RemoteAddr + ']' +
                      UserInfos[psend.uindex].SocData;
      Memo.Lines.Add ('[Exception] ProcessUserPacket ' + data);
   end;
end;

procedure TFrmMain.ProcessPacket (psend: PTSendUserData);  //shandle, uindex: integer);
var
   i: integer;
   makestr, sstr: string;
   pdef: PTDefaultMessage;
begin
   if (psend.uindex >= 0) and (psend.uindex < MAX_USER) then begin
      if UserInfos[psend.uindex].Shandle = psend.shandle then begin
         lc_sendlen := lc_sendlen + Length(psend.Data);
         makestr := UserInfos[psend.uindex].SendData + psend.Data;

         while makestr <> '' do begin
            if Length(makestr) > 250 then begin
               sstr := Copy (makestr, 1, 250);
               makestr := Copy (makestr, 250+1, Length(makestr)-250);
            end else begin
               sstr := makestr;
               makestr := '';
            end;

            with UserInfos[psend.uindex] do begin
               if not SendAvailAble then begin
                  if TimeOutTime < GetTickCount then begin
                     SendAvailAble := TRUE;
                     CheckSendLength := 0;
                     UserHold := TRUE;
                     UserHoldTime := GetTickCount;
                  end;
               end;
               if SendAvailAble then begin
                  if CheckSendLength >= 512 then begin
                     if not SendCheck then begin
                        SendCheck := TRUE;
                        sstr := '*' + sstr; //send verify code..
                     end;
                     if CheckSendLength >= 2048 then begin
                        SendAvailAble := FALSE;
                        TimeOutTime := GetTickCount + 3000;
                     end;
                  end;
                  if Socket <> nil then
                     if Socket.Connected then begin
                        lc_sendlenclient := lc_sendlenclient + Length(sstr);
                        Socket.SendText (sstr);
                     end;
                  //SendLength := SendLength + Length(sstr);
                  CheckSendLength := CheckSendLength + Length(sstr);
               end else begin
                  makestr := sstr + makestr;
                  break;
               end;
            end;
         end;

         UserInfos[psend.uindex].SendData := makestr;

      end;
   end;
end;

//======================================================

procedure TFrmMain.ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
	i, uindex: integer;
begin
   uindex := -1;   //sonmg
   if ServerConnection then begin
      try
         for i:=0 to MAX_USER-1 do begin
            if UserInfos[i].Socket = nil then begin {빈곳}
               UserInfos[i].Socket := Socket;
               UserInfos[i].SocData  := '';
               UserInfos[i].SendData := '';
               UserInfos[i].ServerUserIndex := 0;  //기본값
               UserInfos[i].PriviousCheckCode  := -1;
               UserInfos[i].CrackWanrningLevel := 0;
               UserInfos[i].BoLoginCode := TRUE;
               //UserInfos[i].SendLength	:= 0;
               UserInfos[i].SendLock	:= FALSE;
               UserInfos[i].SendLatestTime := GetTickCount;
               UserInfos[i].SendAvailable := TRUE;
               UserInfos[i].SendCheck := FALSE;
               UserInfos[i].CheckSendLength := 0;
    				UserInfos[i].ReceiveLength := 0;
    				UserInfos[i].ReceiveTime := GetTickCount;
               UserInfos[i].shandle := Socket.SocketHandle;
               UserInfos[i].RemoteAddr := Socket.RemoteAddress;
               uindex := i;
               Inc (UserCount);
               break;
            end;
         end;
      finally
      end;
      if uindex < 0 then DisplayMsg.Add('uIndex Error');
      {send connection}
      SendSocketMsgS (GM_OPEN, uindex, Socket.SocketHandle, 0, Length(Socket.RemoteAddress)+1, @Socket.RemoteAddress[1]);
      Socket.Data := pointer(uindex);
      EdUserCount.Text := IntToStr(UserCount);
      DisplayMsg.Add ('Connect ' + Socket.RemoteAddress);
	end else begin
      Socket.Data := pointer(-1);
   	Socket.Close;
      DisplayMsg.Add ('Kick off ' + Socket.RemoteAddress);
   end;
end;

procedure TFrmMain.ServerSocketClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var
	i, uindex: integer;
   remote : string;
begin
   remote := Socket.RemoteAddress;
   uindex := integer(Socket.Data);
   if (uindex >=0) and (uindex < MAX_USER) then begin
      UserInfos[uindex].Socket := nil;
      UserInfos[uindex].shandle := -1;
      Dec (UserCount);
      if ServerConnection then begin
//         SendSocketMsgS (GM_CLOSE, 0, Socket.SocketHandle, 0, 0, nil);
         //끊을때 IP를 보내서 접속할때의 IP와 다른지 비교하도록 한다.(sonmg)
         SendSocketMsgS (GM_CLOSE, uindex, Socket.SocketHandle, 0, Length(Socket.RemoteAddress)+1, @Socket.RemoteAddress[1]);
         EdUserCount.Text := IntToStr(UserCount);
         DisplayMsg.Add ('Disconnect ' + Socket.RemoteAddress);
      end;
   end;
end;

procedure TFrmMain.ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   DisplayMsg.Add ('Error ' + IntToStr(ErrorCode) + ': ' + Socket.RemoteAddress);
   Socket.Close;
	ErrorCode := 0;
end;

procedure TFrmMain.ServerSocketClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
	code, n, len, uindex: integer;
   temp, data, workstr, head, body, say, whostr: string;
   msg: TDefaultMessage;
   ll, start: longword;
   pclsend: PTSendUserData;
begin
   try
      start := GetTickCount;
      data := Socket.ReceiveText;
      uindex := integer(Socket.Data);

      lc_receivelen := lc_receivelen + Length(data);

      if CbShowSocData.Checked then
         Memo.Lines.Add (data);

      if (uindex >= 0) and (uindex < MAX_USER) and (data <> '') and Connected then begin
         if UserInfos[uindex].Socket = Socket then begin
            n := pos ('*', data);  //클라이언트의 채크 코드
            if n > 0 then begin
               UserInfos[uindex].SendAvailable := TRUE;
               UserInfos[uindex].SendCheck := FALSE;
               UserInfos[uindex].CheckSendLength := 0;
               UserInfos[uindex].ReceiveTime := GetTickCount;

               temp := Copy (data, 1, n-1);
               data := temp + Copy (data, n+1, Length(data));
            end;

            if (data <> '') and ServerConnection and (not ServerBusy) then begin {서버와 연결상태 확인}
               new (pclsend);
               pclsend.uindex := uindex;
               pclsend.shandle := Socket.SocketHandle;
               pclsend.Data := data;
               ReceiveSocList.Add (pclsend);
            end;
         end;
      end;

      ll := GetTickCount - start;
      if ll > sendtime then sendtime := ll;
   except
      Memo.Lines.Add ('[Exception] ClientRead');
   end;
end;


//======================================================

procedure TFrmMain.MemoChange(Sender: TObject);
begin
	if Memo.Lines.Count > 500 then begin
   	Memo.Lines.Clear;
   end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var i: integer;
begin
   if CbDisplay.Checked then begin
      for i:=0 to DisplayMsg.Count-1 do
         Memo.Lines.Add (DisplayMsg[i]);
   end;
	DisplayMsg.Clear;
end;


//=================================================


procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
   i: integer;
   MssageReturn: Word;
begin
   if FOREIGNVERSION then begin
      MssageReturn := MessageDlg ('Do you want to close RunGate program?', mtWarning, mbYesNoCancel, 0);
   end else begin
      MssageReturn := MessageDlg ('Do you want to close RunGate program?', mtWarning, mbYesNoCancel, 0);
   end;

	if mrYes = MssageReturn then begin
   	CanClose := TRUE;
      ClientSocket.Close;
      ServerSocket.Close;
      for i:=0 to MAX_USER-1 do begin
         if UserInfos[i].Socket <> nil then begin
            UserInfos[i].Socket.Close;
            UserInfos[i].Socket := nil;
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
         LbPort.Caption := IntToStr(ServerSocket.Port);
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
   if not ClientSocket.Socket.Connected then begin
      with ClientSocket do begin
         Active := FALSE;
         Port := ServerPort + ServerIndex;
         Address := cbAddrs.Items[ServerIndex];
         if Address <> '' then
            Active := TRUE;
      end;
      LbPort.Caption := IntToStr(ServerSocket.Port);
   end;
   looptime := 0;
   receivetime := 0;
   sendtime := 0;
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

procedure TFrmMain.Label5DblClick(Sender: TObject);
begin
   BoShowByByte := not BoShowByByte;
end;

procedure TFrmMain.EdUserCountDblClick(Sender: TObject);
begin
   if FrmMain.ClientHeight = Panel1.Height then begin
      FrmMain.ClientHeight := Panel1.Height * 2;
   end else begin
      FrmMain.ClientHeight := Panel1.Height;
   end;
end;

end.
