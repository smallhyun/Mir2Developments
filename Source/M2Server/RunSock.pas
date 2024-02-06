unit RunSock;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, ObjBase, FrnEngn, Edcode,
  Grobal2;

const
  SERVERBASEPORT = 5000;
  MAXGATE = 20;
  GATEADDRFILE = '.\!runaddr.txt';
  //ADDRTABLEFILE = '.\!addrtable.txt';
  MAX_PUBADDR = 30;

type
   TRAddr = record
      RemoteAddr: string[20];
      PublicAddr: string[20];
   end;

   TRunGateInfo = record
      Connected: Boolean;
      Socket: TCustomWinSocket;
      PublicAddress: string[20];
      Status: integer;    {0: disconnected,  1: good,  2: heavy traffic}
      //SocData: string;
      ReceiveBuffer: PAnsiChar;
      ReceiveLen: integer;
      SendBuffers: TList;  //���� ���̳ʸ� ����Ÿ ����Ʈ
      UserList: TList; //����ȭ �ؾ���.  �ñ�� ������ Delete������ �ʴ´�.
      NeedCheck: Boolean;
      GateSyncMode: integer;
      WaitTime: longword;
      //SendCheckTimeCount: integer;
      SendDataCount: integer;    //�ʴ� �������� ����Ÿ�� �Ѽ�
      SendDataTime: longword;    //��

      //������ ���ؼ� �ʿ��� ������
      curbuffercount: integer;      //���� �������� ���� ��
      remainbuffercount: integer;   //���� ���� ���� ��
      sendchecktime: longword;
      worksendbytes: integer;
      sendbytes: integer;           //�ʴ� ���� ����Ʈ
      worksendsoccount: integer;
      sendsoccount: integer;        //�ʴ� ���� ���� ��
   end;
   PTRunGateInfo = ^TRunGateInfo;

   TUserInfo = record
      UserId: string[20];
      UserName: string[14];
      UserAddress: string[20];
      //UserCurAddr: string[20];
      UserHandle: integer;
      UserGateIndex: integer;
      Certification: integer;
      ClientVersion: integer;
      UEngine: TObject;
      FEngine: TObject;
      UCret: TObject;
      OpenTime: longword;
      Enabled: Boolean;
   end;
   PTUserInfo = ^TUserInfo;

   TRunCmdInfo = record
        idx     : integer;
        pbuff   : PAnsiChar;
   end;
   PTRunCmdInfo = ^TRunCmdInfo;

   TRunSocket = class
   private
      //CurGateIndex: integer;
      //CurGate: PTRunGateInfo;
      RunAddressList: TStringList;
      MaxPubAddr: integer;
      PubAddrTable: array[0..MAX_PUBADDR-1] of TRAddr;
      //RunGateIndex: integer;
      DecGateIndex: integer;
      gateloadtesttime: longword;
      FCmdList  : TList;
      FCmdCS    : TCriticalsection;
      procedure LoadRunAddress;
      function  GetPublicAddr (raddr: string): string;
      function  OpenNewUser (shandle, uindex: integer; addr: string; ulist: TList): integer;
      procedure DoClientCertification (gindex: integer; puser: PTUserInfo; shandle: integer; data: string);
      procedure ExecGateMsg (gindex: integer; CGate: PTRunGateInfo; pheader: PTMsgHeader; pdata: PAnsiChar; len: integer);
      procedure ExecGateBuffers (gindex: integer; CGate: PTRunGateInfo; pBuffer: PAnsiChar; buflen: integer);
      function  SendGateBuffers (gindex: integer; CGate: PTRunGateInfo; slist: TList): Boolean;
   public
      GateArr: array[0..MAXGATE-1] of TRunGateInfo;
      constructor Create;
      destructor Destroy; override;
      function  IsValidGateAddr (addr: string): Boolean;
      procedure Connect (Socket: TCustomWinSocket);
      procedure Disconnect (Socket: TCustomWinSocket);
      procedure SocketError (Socket: TCustomWinSocket; var ErrorCode: integer);
      procedure SocketRead (Socket: TCustomWinSocket);
      procedure CloseGate (Socket: TCustomWinSocket);
      procedure CloseAllGate;
      procedure SendGateCheck (socket: TCustomWinSocket; msg: integer);
      procedure SendServerUserIndex (socket: TCustomWinSocket; shandle, gindex, index: integer);
      procedure SendPublicKey (socket: TCustomWinSocket; pubkey: integer);
      procedure SendPublicKeyToAllGate (pubkey: integer);
      procedure UserLoadingOk (gateindex, shandle: integer; cret: TObject);
      procedure CloseUser (gateindex, uhandle: integer); //����ȭ �������
      procedure SendForcedClose (gindex, uhandle: integer);
      procedure SendGateLoadTest (gindex: integer);
      procedure CloseUserId (uid: string; cert: integer);
      procedure SendUserSocket (gindex: integer; pbuf: PAnsiChar);
      procedure SendCmdSocket  ( gindex: integer; pbuf: PAnsiChar); // �ٸ������忡�� �־��ִ°�
      procedure PatchSendData; // ������ ��ġ

      procedure Run;
   end;


implementation

uses
   svMain, IdSrvClient;


constructor TRunSocket.Create;
var
   i: integer;
begin
   RunAddressList := TStringList.Create;
   for i:=0 to MAXGATE-1 do begin
      GateArr[i].Connected := FALSE;
      GateArr[i].Socket := nil;
      GateArr[i].NeedCheck := FALSE;
      GateArr[i].curbuffercount := 0;
      GateArr[i].remainbuffercount := 0;
      GateArr[i].sendchecktime := GetTickCount;
      GateArr[i].sendbytes := 0;
      GateArr[i].sendsoccount := 0;
   end;
   LoadRunAddress;
   //RunGateIndex := 0;
   DecGateIndex := 0;

   FCmdList := TList.Create;
   FCmdCS   := TCriticalSection.Create;
end;

destructor TRunSocket.Destroy;
var
    i : integer;
    pInfo : PTRunCmdInfo;
begin
   ruLock.Free;
   socstrLock.Free;
   RunAddressList.Free;

   if FCmdList <> nil then
   begin
        for i := 0 to FCmdList.Count -1 do
        begin
            pInfo := FCmdList[0];
            if pInfo <> nil then
            begin
                if pInfo.pBuff <> nil then
                begin
                    freeMem( pInfo.pBuff );
                end;
                dispose( pInfo );
            end;
            FCmdList.Delete(0);
        end;
        FCmdList.Free;
   end;

   FCmdCS.Free;

   inherited Destroy;
end;

procedure TRunSocket.LoadRunAddress;
begin
   RunAddressList.LoadFromFile (GATEADDRFILE);
   CheckListValid (RunAddressList);
end;

function  TRunSocket.IsValidGateAddr (addr: string): Boolean;
var
   i: integer;
begin
   try
      Result := FALSE;
      ruLock.Enter;
      for i:=0 to RunAddressList.Count-1 do
         if RunAddressList[i] = addr then begin
            Result := TRUE;
            break;
         end;
   finally
      ruLock.Leave;
   end;
end;

function TRunSocket.GetPublicAddr (raddr: string): string;
var
   i: integer;
begin
   Result := raddr;
   for i:=0 to MaxPubAddr-1 do begin
      if PubAddrTable[i].RemoteAddr = raddr then begin
         Result := PubAddrTable[i].PublicAddr;
         break;
      end;
   end;
end;

procedure TRunSocket.Connect (Socket: TCustomWinSocket);
var
   i: integer;
   remote: string;
begin
   if ServerReady then begin
      remote := Socket.RemoteAddress;
      //if IsValidGateAddr (remote) then begin
         for i:=0 to MAXGATE-1 do begin
            if not GateArr[i].Connected then begin
               GateArr[i].Connected := TRUE;
               GateArr[i].Socket := Socket;
               GateArr[i].PublicAddress := GetPublicAddr (remote);
               GateArr[i].Status := 1;  {0: disconnected,  1: good,  2: heavy traffic}
               //GateArr[i].SocData := ''; {synchronized}
               GateArr[i].UserList := TList.Create;
               GateArr[i].ReceiveBuffer := nil;
               GateArr[i].ReceiveLen := 0;
               GateArr[i].SendBuffers := TList.Create;
               GateArr[i].NeedCheck := FALSE;
               GateArr[i].GateSyncMode := 0;  //Sync GOOD
               GateArr[i].SendDataCount := 0;
               GateArr[i].SendDataTime := GetTickCount;
               MainOutMessage ('���� ' + IntToStr(i) + ' �Ѵ�..');
               //������Ʈ�� PublicKey�� �����Ѵ�.
               SendPublicKey( Socket, GetPublicKey );
               break;
            end;
         end;
      //end else begin
      //   MainOutMessage ('Kick ' + Socket.RemoteAddress);
      //   Socket.Close;
      //end;
   end else begin
      MainOutMessage ('Not ready ' + Socket.RemoteAddress);
      Socket.Close;
   end;
end;

procedure TRunSocket.Disconnect (Socket: TCustomWinSocket);
begin
   CloseGate (Socket);
end;

procedure TRunSocket.SocketError (Socket: TCustomWinSocket; var ErrorCode: integer);
begin
   if Socket.Connected then Socket.Close;
   ErrorCode := 0;
end;

procedure TRunSocket.SocketRead (Socket: TCustomWinSocket);
var
   i, len: integer;
   p: PAnsiChar;
begin
   for i:=0 to MAXGATE-1 do
      if GateArr[i].Socket = Socket then begin
         try
            len := Socket.ReceiveLength;
            GetMem (p, len);
            Socket.ReceiveBuf (p^, len);
            ExecGateBuffers (i, PTRunGateInfo (@GateArr[i]), p, len);
            FreeMem (p);
         except
            MainOutMessage ('Exception] SocketRead');
         end;

         break;
      end;
end;

procedure TRunSocket.CloseAllGate;
var
	i: integer;
begin
   for i:=0 to MAXGATE-1 do
      if GateArr[i].Socket <> nil then
         CloseGate (GateArr[i].Socket);
end;

procedure TRunSocket.CloseGate (Socket: TCustomWinSocket);
var
	i, j: integer;
   ulist: TList;
   uinf: PTUserInfo;
begin
   try
      ruLock.Enter;
      for i:=0 to MAXGATE-1 do begin
         if GateArr[i].Socket = Socket then begin
            ulist := GateArr[i].UserList;
            for j:=0 to ulist.Count-1 do begin
               uinf := PTUserInfo (ulist[j]);
               if uinf = nil then continue;
               if uinf.UCret <> nil then begin
                  TUserHuman (uinf.UCret).EmergencyClose := TRUE;
                  //�̰��
                  //EmergencyClose �� ó���Ҷ� Gate�� �̹� ���� ������
                  //���� �ؾ� ��.
                  if not TUserHuman (uinf.UCret).SoftClosed then begin //ĳ���� �������� �������� �ƴϸ�
                     //�ٸ� ������ �˸���.
                     FrmIDSoc.SendUserClose (uinf.UserId, uinf.Certification);
                  end;
               end;
               Dispose (uinf);  //���� ����...
               ulist[j] := nil;
            end;
            ////ulist.Free;
            //GateArr[i].UserList := nil;

            {for j:=0 to GateArr[i].BufferList.Count-1 do
               FreeMem (GateArr[i].BufferList[j]);
            GateArr[i].BufferList.Free;
            GateArr[i].BufferList := nil;}

            if GateArr[i].ReceiveBuffer <> nil then
               FreeMem (GateArr[i].ReceiveBuffer);
            GateArr[i].ReceiveBuffer := nil;
            GateArr[i].ReceiveLen := 0;

            for j:=0 to GateArr[i].SendBuffers.Count-1 do
               FreeMem (GateArr[i].SendBuffers[j]);
            GateArr[i].SendBuffers.Free;
            GateArr[i].SendBuffers := nil;

            GateArr[i].Connected := FALSE;
            GateArr[i].Socket := nil;
            MainOutMessage ('���� ' + IntToStr(i) + ' �ѹر�..');
            break;
         end;
      end;
   finally
      ruLock.Leave;
   end;
end;

//ruLock �ȿ��� ȣ��Ǿ����
//UserList�� index�� ������
function  TRunSocket.OpenNewUser (shandle, uindex: integer; addr: string; ulist: TList): integer;
var
   i: integer;
   uinfo: PTUserInfo;
begin
   new (uinfo);
   uinfo.UserId := '';
   uinfo.UserName := '';
   uinfo.UserAddress := addr;
   uinfo.UserHandle := shandle;
   uinfo.UserGateIndex := uindex;
   uinfo.Certification := 0;
   uinfo.UEngine := nil;
   uinfo.FEngine := nil;
   uinfo.UCret := nil;
   uinfo.OpenTime := GetTickCount;
   uinfo.Enabled := FALSE;
   for i:=0 to ulist.Count-1 do begin
      if ulist[i] = nil then begin
         ulist[i] := uinfo;    //�߰��� �������� ����
         Result := i;
         exit;
      end;
   end;
   ulist.Add (uinfo);
   Result := ulist.Count-1;
end;

procedure TRunSocket.CloseUser (gateindex, uhandle: integer);
var
   i: integer;
   puser: PTUserInfo;
begin
   if not (gateindex in [0..MAXGATE-1]) then exit;
   if GateArr[gateindex].UserList = nil then exit;
   try
      ruLock.Enter;
      try
         for i:=0 to GateArr[gateindex].UserList.Count-1 do begin
            if GateArr[gateindex].UserList[i] = nil then continue;
            if PTUserInfo(GateArr[gateindex].UserList[i]).Userhandle = uhandle then begin
               puser := PTUserInfo (GateArr[gateindex].UserList[i]);
               //Close ���� �ٽ� �����ؾ� ��.
               try
                  if puser.FEngine <> nil then
                     TFrontEngine (puser.FEngine).UserSocketHasClosed (gateindex, puser.UserHandle);
               except
                  MainOutMessage ('[RunSock] TRunSocket.CloseUser exception 1');
               end;
               try
                  if puser.UCret <> nil then begin
                     //TUserHuman (puser.UCret).EmergencyClose := TRUE;
                     TUserHuman (puser.UCret).UserSocketClosed := TRUE;
                  end;
               except
                  MainOutMessage ('[RunSock] TRunSocket.CloseUser exception 2');
               end;
               try
                  if puser.UCret <> nil then begin
                     if TCreature(puser.UCret).BoGhost then begin  //��������ᰡ �ƴ�, ������ ���������ΰ��
                        if not TUserHuman (puser.UCret).SoftClosed then begin //ĳ���� �������� �������� �ƴϸ�
                           //�ٸ� ������ �˸���.
                           FrmIDSoc.SendUserClose (puser.UserId, puser.Certification);
                        end;
                     end;
                  end;
               except
                  MainOutMessage ('[RunSock] TRunSocket.CloseUser exception 3');
               end;
               try
                  //����.. �������� �ʴ´�.
                  //GateArr[gateindex].UserList.Delete (i);
                  Dispose (puser);
                  GateArr[gateindex].UserList[i] := nil;
               except
                  MainOutMessage ('[RunSock] TRunSocket.CloseUser exception 4');
               end;
               break;
            end;
         end;
      except
         MainOutMessage ('[RunSock] TRunSocket.CloseUser exception');
      end;
   finally
      ruLock.Leave;
   end;
//�Ʒ� �ʿ� ���� ��ƾ,  ������ puser.FEngine->UserSocketClosed�� �ذ�Ǿ���.
//   if closeid <> '' then begin  //*11-11 �������ǰ� UCret�� ������ �ȵǾ���.
///////////      FrontEngine.AddCloseIdList (closeid, 0);
//   end;
end;

procedure TRunSocket.SendGateLoadTest (gindex: integer);
var
   def: TDefaultMessage;
   packetlen: integer;
   header: TMsgHeader;
   pbuf: PAnsiChar;
begin
   header.Code := integer($aa55aa55);
   header.SNumber := 0;
   header.Ident := GM_TEST;
   pBuf := nil;

   header.Length := 80; //512;
   packetlen := sizeof(TMsgHeader) + header.Length;
   GetMem (pbuf, packetlen + 4);
   Move (packetlen, pbuf^, 4);
   Move (header, (@pbuf[4])^, sizeof(TMsgHeader));
   Move (Def, (@pbuf[4+sizeof(TMsgHeader)])^, sizeof(TDefaultMessage));

   SendUserSocket (gindex, pbuf);
end;

procedure TRunSocket.SendForcedClose (gindex, uhandle: integer);
var
   def: TDefaultMessage;
   packetlen: integer;
   header: TMsgHeader;
   pbuf: PAnsiChar;
begin
   Def := MakeDefaultMsg (SM_OUTOFCONNECTION, 0, 0, 0, 0);
   pBuf := nil;

   header.Code := integer($aa55aa55);
   header.SNumber := uhandle;
   header.Ident := GM_DATA;

   header.Length := sizeof(TDefaultMessage);
   packetlen := sizeof(TMsgHeader) + header.Length;
   GetMem (pbuf, packetlen + 4);
   Move (packetlen, pbuf^, 4);
   Move (header, (@pbuf[4])^, sizeof(TMsgHeader));
   Move (Def, (@pbuf[4+sizeof(TMsgHeader)])^, sizeof(TDefaultMessage));

   SendUserSocket (gindex, pbuf);
end;

procedure TRunSocket.SendGateCheck (socket: TCustomWinSocket; msg: integer);
var
   header: TMsgHeader;
begin
   if socket.Connected then begin
      header.Code := integer($aa55aa55);
      header.SNumber := 0;
      header.Ident := msg;  //GM_CHECKSERVER;
      header.Length := 0;
      //GetMem (pbuf, sizeof(TMsgHeader) + 4);
      //len := sizeof(TMsgHeader);
      //Move (len, pbuf^, 4);
      //Move (header, (@pbuf[4])^, len);
      //SendUserSocket (GateIndex, pbuf);
      if socket <> nil then
         socket.SendBuf (header, sizeof(TMsgHeader));
   end;
end;

procedure TRunSocket.SendServerUserIndex (socket: TCustomWinSocket; shandle, gindex, index: integer);
var
   header: TMsgHeader;
begin
   if socket.Connected then begin
      header.Code := integer($aa55aa55);
      header.SNumber := shandle;
      header.UserGateIndex := gindex;
      header.Ident := GM_SERVERUSERINDEX;
      header.UserListIndex := index;
      header.Length := 0;
      if socket <> nil then
         socket.SendBuf (header, sizeof(TMsgHeader));
   end;
end;

procedure TRunSocket.SendPublicKey (socket: TCustomWinSocket; pubkey: integer);
var
   header: TMsgHeader;
begin
   if socket.Connected then begin
      header.Code := integer($aa55aa55);
      header.SNumber := 0;
      header.Ident := GM_SENDPUBLICKEY;
      header.UserListIndex := WORD(pubkey);
      header.Length := 0;
      if socket <> nil then
         socket.SendBuf (header, sizeof(TMsgHeader));
   end;
end;

procedure TRunSocket.SendPublicKeyToAllGate (pubkey: integer);
var
   i: integer;
begin
   for i:=0 to MAXGATE-1 do begin
      if GateArr[i].Connected then begin
         if GateArr[i].Socket <> nil then begin
            SendPublicKey( GateArr[i].Socket, pubkey );
         end;
      end;
   end;
end;

//�ٸ� �������� ������ �Ǿ��� ���, Ȥ�� �ٸ� ������ �̻��� ����..
procedure TRunSocket.CloseUserId (uid: string; cert: integer);
var
   gi, k: integer;
   pu: PTUserInfo;
begin
   for gi:=0 to MAXGATE-1 do begin
      if (GateArr[gi].Connected) and (GateArr[gi].Socket <> nil) and (GateArr[gi].UserList <> nil) then begin
         try
            ruCloseLock.Enter;
            for k:=0 to GateArr[gi].UserList.Count-1 do begin
               pu := PTUserInfo (GateArr[gi].UserList[k]);
               if pu = nil then continue;
               if (pu.UserId = uid) or (pu.Certification = cert) then begin
                  if pu.FEngine <> nil then
                     TFrontEngine (pu.FEngine).UserSocketHasClosed (gi, pu.UserHandle);
                  if pu.UCret <> nil then begin
                     TUserHuman (pu.UCret).EmergencyClose := TRUE;
                     TUserHuman (pu.UCret).UserSocketClosed := TRUE;
                     //���� ���� �޼����� Ŭ���̾�Ʈ�� ������.
                     SendForcedClose (gi, pu.UserHandle);
                  end;
                  //GateArr[gi].UserList.Delete (k); �������� ����
                  Dispose (pu);
                  GateArr[gi].UserList[k] := nil;
                  break;
               end;
            end;
         finally
            ruCloseLock.Leave;
         end;
      end;
   end;
end;

//pbuf : [length(4)] + [data]
procedure TRunSocket.SendUserSocket (gindex: integer; pbuf: PAnsiChar);
var
   n, i, len, newlen: integer;
   flag: Boolean;
   psend, pnew: PAnsiChar;
begin
   flag := FALSE;
   if ( pBuf = nil ) then Exit;
   
   try
      ruSendLock.Enter;
      if gindex in [0..MAXGATE-1] then begin
         if (GateArr[gindex].SendBuffers <> nil) then begin
            if (GateArr[gindex].Connected) and (GateArr[gindex].Socket <> nil) then begin
               {Move (pbuf^, len, 4);
               if len > SENDBLOCK then begin
                  for i:=0 to 1000 do begin
                     newlen := _MIN(len, SENDBLOCK);
                     GetMem (pnew, newlen + 4);
                     Move (newlen, pnew^, 4);
                     Move ((@pbuf[4 + i * SENDBLOCK])^, (@pnew[4])^, newlen);
                     len := len - newlen;
                     GateArr[gindex].SendBuffers.Add (pnew);
                     if len <= 0 then break;
                  end;
                  FreeMem (pbuf);
               end else}
               GateArr[gindex].SendBuffers.Add (pbuf);
               flag := TRUE;
               //Socket.SendText (socstr);
            end;
         end;
      end;
   finally
      ruSendLock.Leave;
   end;

   if not flag then
   begin
        try
        FreeMem (pbuf);
        finally
        pbuf := nil;
        end;
   end;
end;

procedure TRunSocket.UserLoadingOk (gateindex, shandle: integer; cret: TObject);
var
   i: integer;
   puser: PTUserInfo;
begin
   if gateindex in [0..MAXGATE-1] then begin
      if GateArr[gateindex].UserList = nil then exit;
      try
         ruLock.Enter;
         for i:=0 to GateArr[gateindex].UserList.Count-1 do begin
            puser := GateArr[gateindex].UserList[i];
            if puser = nil then continue;
            if puser.Userhandle = shandle then begin
               puser.FEngine := nil;
               puser.UEngine := UserEngine;
               puser.UCret := cret;
               break;
            end;
         end;
      finally
         ruLock.Leave;
      end;
   end;
end;

//ruLock �ȿ��� ȣ��Ǵ� �Լ� ��.
procedure TRunSocket.DoClientCertification (gindex: integer; puser: PTUserInfo; shandle: integer; data: string);
   function GetCertification (body: string; var uid, chrname: string; var certify, clversion, clientchecksum: integer; var startnew: Boolean): Boolean;
   var
      str, scert, sver, start, sxorcert, checksum, sxor2: string;
      checkcert, xor1, xor2: longword;
   begin
      {          uid  chr  cer  ver  startnew}
      {body => **SSSS/SSSS/SSSS/SSSS/1}
      Result := FALSE;
      try
         str := DecodeString (body);
         MainOutMessage ('[RunSock] TRunSocket.DoClientCertification.GetCertification ' + str);
         if Length(str) > 2 then begin
            if (str[1] = '*') and (str[2] = '*') then begin
               str := Copy (str, 3, Length(str)-2);
               str := GetValidStr3 (str, uid, ['/']);
               str := GetValidStr3 (str, chrname, ['/']);
               str := GetValidStr3 (str, scert, ['/']);
               str := GetValidStr3 (str, sver, ['/']);
               str := GetValidStr3 (str, sxorcert, ['/']);
               str := GetValidStr3 (str, checksum, ['/']);
               str := GetValidStr3 (str, sxor2, ['/']);

               start := str;
               certify := Str_ToInt (scert, 0);
               checkcert := longword(certify);
               xor1 := Str_ToInt64 (sxorcert, 0);
               xor2 := Str_ToInt64 (sxor2, 0);

               if start = '0' then startnew := TRUE
               else startnew := FALSE;
               if (uid <> '') and (chrname <> '') and (checkcert >= 2) and
                  (checkcert = (xor1 xor $F2E44FFF)) and
                  (checkcert = (xor2 xor $a4a5b277)) then
               begin
                  clversion := Str_ToInt (sver, 0);
                  clientchecksum := Str_ToInt (checksum, 0);
                  Result := TRUE;
               end;
            end;
         end;
      except
         MainOutMessage ('[RunSock] TRunSocket.DoClientCertification.GetCertification exception ');
      end;
   end;
var
   uid, chrname: string;
   certify, clversion, loginclientversion, clcheck, bugstep, certmode, availmode: integer;
   startnew: Boolean;
begin
   { usrid/chrname/certify code }
   bugstep := 0;
   try
      if puser.UserId = '' then begin
         if CharCount (data, '!') >= 1 then begin
            ArrestStringEx (data, '#', '!', data);
            data := Copy (data, 2, Length(data)-1); //1��°�� üũ �ڵ���
            bugstep := 1;
            if GetCertification (data, uid, chrname, certify, clversion, clcheck, startnew) then begin
               certmode := FrmIDSoc.GetAdmission (uid, puser.UserAddress, certify, availmode, loginclientversion);
//             MainOutMessage ('certmode:<' + IntToStr(certmode) + '>');
               if certmode > 0 then begin //��ȿ�� �������� �˻�
                  puser.Enabled       := TRUE;
                  puser.UserId        := Trim(uid);
                  puser.UserName      := Trim(chrname);
                  puser.Certification := certify;
                  puser.ClientVersion := clversion;
                  try
                     FrontEngine.LoadPlayer (uid,
                                             chrname,
                                             puser.UserAddress,
                                             startnew,
                                             certify,
                                             certmode,  //PayMode
                                             availmode,
                                             clversion,
                                             loginclientversion,
                                             clcheck,
                                             shandle,
                                             puser.UserGateIndex,
                                             gindex); //CurGateIndex);
                  except
                     MainOutMessage ('[RunSock] LoadPlay... TRunSocket.DoClientCertification exception');
                  end;
               end else begin
                  //���� ����
                  bugstep := 2;
                  puser.UserId := '* disable *';
                  puser.Enabled := FALSE;
                  CloseUser (gindex, shandle); //CurGateIndex, shandle);
                  bugstep := 3;
//                MainOutMessage ('Fail admission: "' + data + '"');
                  MainOutMessage ('Fail admission:1<' + puser.UserAddress + '><'+IntToStr(availmode)+'>');
                  if startnew then
                     MainOutMessage ('Fail admission:2<'+IntToStr(certmode)+'><'+uid+'><'+chrname+'><'+IntToStr(certify)+'><'+IntToStr(clversion)+'><'+IntToStr(clcheck)+'><T>')
                  else
                     MainOutMessage ('Fail admission:2<'+IntToStr(certmode)+'><'+uid+'><'+chrname+'><'+IntToStr(certify)+'><'+IntToStr(clversion)+'><'+IntToStr(clcheck)+'><F>');

               end;
            end else begin
               bugstep := 4;
               puser.UserId := '* disable *';
               puser.Enabled := FALSE;
               CloseUser (gindex, shandle); //CurGateIndex, shandle);
               bugstep := 5;
               MainOutMessage ('invalid admission: "' + data + '"');
            end;
         end;
      end;
   except
      MainOutMessage ('[RunSock] TRunSocket.DoClientCertification exception ' + IntToStr(bugstep));
   end;
end;


procedure TRunSocket.ExecGateMsg (gindex: integer; CGate: PTRunGateInfo; pheader: PTMsgHeader; pdata: PAnsiChar; len: integer);
var
   i, uidx, debug: integer;
   puser: PTUserInfo;
begin
   debug := 0;
   try
      case pheader.Ident of
         GM_OPEN:
            begin
               debug := 1;
               uidx := OpenNewUser (pheader.SNumber, pheader.UserGateIndex, string(pdata), CGate.UserList);
               SendServerUserIndex (CGate.Socket, pheader.SNumber, pheader.UserGateIndex, uidx + 1);  //1�� �⺻��
            end;
         GM_CLOSE:
            begin
               debug := 2;
               puser := nil;
               //-------------------
               for i:=0 to CGate.UserList.Count-1 do begin
                  puser := PTUserInfo (CGate.UserList[i]);
                  if puser <> nil then begin
                     if puser.UserHandle = pheader.SNumber then begin
                        //�������� IP Address ��(sonmg)
                        if CompareText(puser.UserAddress, string(pdata)) <> 0 then begin
                           if CompareText(string(pdata), '0.0.0.0') <> 0 then
                              MainOutMessage('[IP Address Not Match] ' + puser.UserId + ' ' + puser.UserName + ' ' + puser.UserAddress + '->' + string(pdata));
                        end;
                     end;
                  end;
               end;
               //-------------------
               CloseUser (gindex, pheader.SNumber);
            end;
         GM_CHECKCLIENT:
            begin
               debug := 3;
               CGate.NeedCheck := TRUE;
            end;
         GM_RECEIVE_OK:
            begin
               debug := 4;
               CGate.GateSyncMode := 0;   //Sync GOOD
               CGate.SendDataCount := 0; //CGate.SendDataCount - CGate.SendCheckTimeCount;
            end;
         GM_DATA:
            begin
               debug := 5;
               puser := nil;
               if pheader.UserListIndex >= 1 then begin
                  uidx := pheader.UserListIndex - 1;
                  if (uidx < CGate.UserList.Count) then begin  //����Ʈ�� �߰��� ���� ���� ����..
                     puser := PTUserInfo (CGate.UserList[uidx]);
                     if puser <> nil then
                        if (puser.UserHandle <> pheader.SNumber) then   //�� Ȯ��
                           puser := nil;
                  end;
               end;
               if puser = nil then begin
                  for i:=0 to CGate.UserList.Count-1 do begin
                     if CGate.UserList[i] = nil then continue;
                     if PTUserInfo(CGate.UserList[i]).UserHandle = pheader.SNumber then begin
                        puser := PTUserInfo (CGate.UserList[i]);
                        break;
                     end;
                  end;
               end;

               debug := 6;
               if puser <> nil then begin
                  if (puser.UCret <> nil) and (puser.UEngine <> nil) then begin
                     if puser.Enabled then begin
                        if len >= sizeof(TDefaultMessage) then begin
                           if len = sizeof(TDefaultMessage) then
                              UserEngine.ProcessUserMessage (TUserHuman(puser.UCret), PTDefaultMessage(pdata), nil)
                           else UserEngine.ProcessUserMessage (TUserHuman(puser.UCret), PTDefaultMessage(pdata), @pdata[sizeof(TDefaultMessage)]);
                        end;
                     end;
                  end else begin
                     DoClientCertification (gindex, puser, pheader.SNumber, string(pdata));
                  end;
               end;
            end;
      end;
   except
      MainOutMessage ('[Exception] ExecGateMsg.. ' + IntToStr(debug));
   end;
end;

procedure TRunSocket.ExecGateBuffers (gindex: integer; CGate: PTRunGateInfo; pBuffer: PAnsiChar; buflen: integer);
var
   len: integer;
   pwork, pbody, ptemp: PAnsiChar;
   pheader: PTMsgHeader;
begin
   pwork := nil;
   len   := 0;

   try
      if pBuffer <> nil then begin
         ReAllocMem (CGate.ReceiveBuffer, CGate.ReceiveLen + buflen);
         Move (pBuffer^, (@CGate.ReceiveBuffer[CGate.ReceiveLen])^, buflen);
      end;
   except
      MainOutMessage ('Exception] ExecGateBuffers->pBuffer');
   end;

   try
      len := CGate.ReceiveLen + buflen;
      pwork := CGate.ReceiveBuffer;                     //pwork

      while len >= sizeof(TMsgHeader) do begin
         pheader := PTMsgHeader (pwork);
         if longword(pheader.Code) = $aa55aa55 then begin
            if len < sizeof(TMsgHeader) + pheader.Length then break;
            pbody := @pwork[sizeof(TMsgHeader)];
            //.....pheader, pbody, pheader.Length...
            ExecGateMsg (gindex, CGate, pheader, pbody, pheader.Length);
            //
            pwork := @pwork[sizeof(TMsgHeader) + pheader.Length];
            len := len - (sizeof(TMsgHeader) + pheader.Length);
         end else begin
            pwork := @pwork[1];
            Dec (len);
         end;
      end;
   except
      MainOutMessage ('Exception] ExecGateBuffers->@pwork,ExecGateMsg');
   end;

   try
      if len > 0 then begin  //������
         GetMem (ptemp, len);
         Move (pwork^, ptemp^, len);
         FreeMem (CGate.ReceiveBuffer);
         CGate.ReceiveBuffer := ptemp;       //psrc �������� ����
         CGate.ReceiveLen := len;
      end else begin
         FreeMem (CGate.ReceiveBuffer);
         CGate.ReceiveBuffer := nil;
         CGate.ReceiveLen := 0;
      end;
   except
      MainOutMessage ('Exception] ExecGateBuffers->FreeMem');
   end;

end;

function  TRunSocket.SendGateBuffers (gindex: integer; CGate: PTRunGateInfo; slist: TList): Boolean;
var
   curn, n, i, len, newlen, totlen, sendlen: integer;
   psend, pnew, pwork: PAnsiChar;
   start: longword;
   down : integer;
begin
   Result := TRUE;

   if slist.Count = 0 then exit;

   Down   := 0;

   start := GetTickCount;

   if CGate.GateSyncMode > 0 then begin  //
      if GetTickCount - CGate.WaitTime > 2000 then begin  //Ÿ�� �ƿ�
         CGate.GateSyncMode := 0;
         CGate.SendDataCount := 0;
      end;
      //if CurGate.GateSyncMode >= 2 then begin
      //   CurGate.GateSyncMode := 2; //breakpoint ����
      exit;
      //end;
   end;

   //��Ŷ ����ȭ
   try
      curn := 0;
      psend := slist[curn]; //�׻� slist.Count > 0 ��.

      while TRUE do begin
         Down   := 1;

         if curn + 1 >= slist.Count then break;

         pwork := slist[curn + 1]; //�ٷ��� ���� SENDBLOCK ���� ������ ���Ѵ�.

         Move (psend^, len, 4);
         Move (pwork^, newlen, 4);

         if (len + newlen < SENDBLOCK) then begin
            Down   := 2;
            slist.Delete (curn + 1);
            //���� ���� ��Ƽ� �Ѳ����� ������.
            //ReallocMem (psend, 4 + len + newlen);
            GetMem (pnew, 4 + len + newlen);
            totlen := len + newlen;
            Move (totlen, pnew^, 4);
            Move ((@psend[4])^, (@pnew[4])^, len);
            Move ((@pwork[4])^, (@pnew[4+len])^, newlen);
            FreeMem (psend);
            FreeMem (pwork);
            psend := pnew;
            slist[curn] := psend;
         end else begin
            Inc (curn);
            psend := pwork;
         end;
      end;
   except
      MainOutMessage ('Exception SendGateBuffers(1)..'+IntToStr(Down));
   end;

   //������
   Down   := 10;
   try
      while slist.Count > 0 do begin
         Down   := 11;
         psend := slist[0];

         if psend = nil then begin
            slist.Delete (0);
            continue;
         end;

         Down   := 12;
         Move (psend^, sendlen, 4);
         if (CGate.GateSyncMode = 0) and
            (sendlen + CGate.SendDataCount >= SENDCHECKBLOCK) then
         begin
            Down   := 13;
            if (CGate.SendDataCount = 0) and (sendlen >= SENDCHECKBLOCK) then begin
               //�ʹ� ū ����Ÿ�� �� ������.
               Down   := 14;
               slist.Delete (0);
               Down   := 142;

               try
               FreeMem (psend);
               except
               psend := nil;
               end;
               psend := nil;
            end else begin
               //äũ ��ȣ�� ������.
               //CGate.SendCheckTimeCount := CGate.SendDataCount;
               Down   := 15;
               SendGateCheck (CGate.Socket, GM_RECEIVE_OK);
               CGate.GateSyncMode := 1;    //SENDAVAILABLEBLOCK���� ���� �� ����
               CGate.WaitTime := GetTickCount;
            end;
            break;
         end;
         //if (CurGate.GateSyncMode = 1) and (sendlen + CurGate.SendDataCount >= SENDAVAILABLEBLOCK) then begin
         //   CurGate.GateSyncMode := 2;
         //   break;
         //end;

         if psend = nil then continue;

         Down   := 16;
         slist.Delete (0);
         pwork := @psend[4];

         while sendlen > 0 do begin
            Down   := 17;
            if sendlen >= SENDBLOCK then begin
               Down   := 18;
               if CGate.Socket <> nil then begin
                  Down   := 19;
                  if CGate.Socket.Connected then
                     CGate.Socket.SendBuf (pwork^, SENDBLOCK);
                  CGate.worksendsoccount := CGate.worksendsoccount + 1;
                  CGate.worksendbytes := CGate.worksendbytes + SENDBLOCK;
               end;
               CGate.SendDataCount := CGate.SendDataCount + SENDBLOCK;
               pwork := @pwork[SENDBLOCK];
               sendlen := sendlen - SENDBLOCK;
            end else begin
               Down   := 20;
               if CGate.Socket <> nil then begin
                  Down   := 21;
                  if CGate.Socket.Connected then
                     CGate.Socket.SendBuf (pwork^, sendlen);
                  CGate.worksendsoccount := CGate.worksendsoccount + 1;
                  CGate.worksendbytes := CGate.worksendbytes + sendlen;
                  CGate.SendDataCount := CGate.SendDataCount + sendlen;
               end;
               sendlen := 0;
               break;
            end;
         end;
         Down   := 22;
         FreeMem (psend);

         if GetTickCount - start > SocLimitTime then begin
            Down   := 23;
            Result := FALSE;
            break;
         end;
      end;
   except
      MainOutMessage ('Exception SendGateBuffers(2)..'+IntToStr(Down));
   end;
end;

procedure TRunSocket.SendCmdSocket( gindex: integer; pbuf: PAnsiChar);
var
    PInfo : PTRunCmdInfo;
begin
    FCmdCS.Enter;
    try
      new ( PInfo );
      PInfo.idx   := gindex;
      PInfo.pbuff := pBuf;
      FCmdList.add( PInfo );
    finally
        FCmdCS.Leave;
    end;
end;

procedure TRunSocket.PatchSendData;
var
    pInfo : PTRunCmdInfo;
    count : integer;
begin
        count := FCmdList.Count;
        pInfo := nil;
        while ( count  > 0 ) do
        begin

            FCmdCS.Enter;
            try
                pInfo := FCmdList[0];
                FCmdList.Delete(0);
            finally
               FCmdCS.Leave;
            end;

            count := Count-1;

            if ( pInfo <> nil ) then
            begin
                try
                  SendUserSocket( pInfo.idx , pInfo.pBuff );
                  dispose ( pInfo );
                except
                   MainOutMessage('[EXCEPT] PAtchSendDate');
                end;
                pInfo := nil;
            end;
        end;
end;

procedure TRunSocket.Run;
var
   i, k, len: integer;
   start: longword;
   pgate: PTRunGateInfo;
   p: PAnsiChar;
   full: Boolean;
begin
   start := GetTickCount;
   full := FALSE;
   if ServerReady then begin
      try
         // Cmd ���� �µ����� ��ġ
         PatchSendData;

         //Gate Load Test
         if GATELOAD > 0 then begin
            if GetTickCount - gateloadtesttime >= 100 then begin
               gateloadtesttime := GetTickCount;
               for i:=0 to MAXGATE-1 do begin  //������ ó��
                  pgate := PTRunGateInfo (@GateArr[i]);
                  if (pgate.SendBuffers <> nil) then begin
                     for k:=0 to GATELOAD-1 do
                        SendGateLoadTest (i);
                  end;
               end;
            end;
         end;

         for i:=0 to MAXGATE-1 do begin  //������ ó��
            pgate := PTRunGateInfo (@GateArr[i]);
            if (pgate.SendBuffers <> nil) then begin
               //CurGateIndex := i;
               //CurGate := pgate;
               pgate.curbuffercount := pgate.SendBuffers.Count; //���� ���� ������ ��
               if not SendGateBuffers (i, pgate, pgate.SendBuffers) then begin
                  //���������� ����, �ð��ʰ�
                  pgate.remainbuffercount := pgate.SendBuffers.Count;  //������ ���� ������ ��
                  //RunGateIndex := CurGateIndex + 1;
                  //full := TRUE;
                  break;
               end else begin
                  pgate.remainbuffercount := pgate.SendBuffers.Count;  //������ ���� ������ ��
               end;
            end;
         end;
         //if not full then RunGateIndex := 0;

         for i:=0 to MAXGATE-1 do begin
            if GateArr[i].Socket <> nil then begin
               pgate := PTRunGateInfo (@GateArr[i]);
               if GetTickCount - pgate.sendchecktime >= 1000 then begin
                  pgate.sendchecktime := GetTickCount;
                  pgate.sendbytes := pgate.worksendbytes;
                  pgate.sendsoccount := pgate.worksendsoccount;
                  pgate.worksendbytes := 0;
                  pgate.worksendsoccount := 0;
               end;
               if GateArr[i].NeedCheck then begin
                  GateArr[i].NeedCheck := FALSE;
                  SendGateCheck (GateArr[i].Socket, GM_CHECKSERVER);
               end;
            end;
         end;
      except
         MainOutMessage ('[RunSock] TRunSocket.Run exception');
      end;
   end;

   cursoctime := GetTickCount - start;
   if cursoctime > maxsoctime then
      maxsoctime := cursoctime; 

end;


end.
