unit IdSrvClient;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  D7ScktComp, ExtCtrls, IniFiles, MudUtil, HUtil32, Grobal2, EDCode;

type
  TAdmission = record
    usrid: string[14];
    uaddr: string[15];
    Certification: integer;
    PayMode: integer;  //0:ü����, 1:����, 2:������
    AvailableMode: integer;  //1:�������� 2:�������� 3:�׹����� 4:�׹����� 5:�������� 6:�̸�2���������
                             //7:�̸�3���� 8:������������ 9:����̸�2���� 10:����̸�3����(2004/06/10���� �߰�)
    ClientVersion: integer;
  end;
  PTAdmission = ^TAdmission;

  TFrmIDSoc = class(TForm)
    IDSocket: TClientSocket;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure IDSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure IDSocketDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure IDSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure IDSocketRead(Sender: TObject; Socket: TCustomWinSocket);
  private
    AdmissionList: TList;
    ShareIPList: TStringList;
    LoginServerCheckTime: longword;
    procedure AddAdmission (uid, uaddr: string; certify, paymode, available, clversion: integer);
    procedure DelAdmission (certify: integer);
    procedure GetPasswdSuccess (body: string);
    procedure GetCancelAdmission (body: string);
    procedure GetTotalUserCount (body: string);
    procedure GetAccountExpired (body: string);
    procedure GetRecvPublicKey (body: string);
    procedure GetUsageInformation (body: string);
    procedure GetPremiumCheckResponse (body: string);
    procedure GetEventCheckResponse (body: string);
//    procedure GetRecvUserPotCash (body: string);
  public
    ServerAddress: string;
    ServerPort: integer;
    IDSocStr: string;
    procedure Initialize;
    procedure DecodeSocStr;
    procedure LoadShareIPList;
    function  GetAdmission (uid, ipaddr: string; cert: integer; var availmode, clversion: integer): integer;  //���� �����忡���� ����ؾ� ��.
    procedure SendUserClose (uid: string; cert: integer);
    procedure SendCheckTimeAccount (uid: string; cert: integer);
    procedure SendRequestPublicKey ();
    procedure SendGameTimeOfTimeCardUser (uid: string; gametime_min: integer);
    procedure SendUserShiftToVentureServer (svname, uid: string; cert: integer);
    procedure SendUserCount (ucount: integer);
    procedure SendPremiumCheck (uname, uid: string; cert: integer);
    procedure SendEventCheck (uname, uid: string; cert: integer);
    //2017-07-23 PC����
//    procedure SendPotCashList (uname, uid: string; cert: integer);
//    procedure SendPotCashAdd (uname, uid: string; cert: integer);
//    procedure SendPotCashDel (uname, uid: string; cert: integer);
  end;

var
  FrmIDSoc: TFrmIDSoc;

implementation

uses
   svMain;

{$R *.DFM}

procedure TFrmIDSoc.FormCreate(Sender: TObject);
var
   ini: TIniFile;
   fname: string;
   i: integer;
begin
   IDSocket.Address := '';
   fname := '.\!setup.txt';
   if FileExists (fname) then begin
      ini := TIniFile.Create (fname);
      if ini <> nil then begin
         ServerAddress := ini.ReadString ('Server', 'IDSAddr', '210.121.143.204');
         ServerPort := ini.ReadInteger ('Server', 'IDSPort', 5600);
      end;
      ini.Free;
   end else
      ShowMessage (fname + ' not found');
   AdmissionList := TList.Create;

   ShareIPList := TStringList.Create;
   LoadShareIPList;

   LoginServerCheckTime := GetTickCount;
end;

procedure TFrmIDSoc.FormDestroy(Sender: TObject);
begin
   AdmissionList.Free;
end;

procedure TFrmIDSoc.LoadShareIPList;
var
   i: integer;
   fname: string;
begin {
   ShareIPList.Clear;
   fname := '.\!shareiplist.txt';
   if FileExists (fname) then begin
      ShareIPList.LoadFromFile (fname);
      CheckListValidTrim (ShareIPList);
   end else
      ShowMessage (fname + ' not found');  }
end;

procedure TFrmIDSoc.Timer1Timer(Sender: TObject);
begin
   if IDSocket.Address <> '' then
      if not IDSocket.Active then
         IDSocket.Active := TRUE;
end;

procedure TFrmIDSoc.IDSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   //�α��μ����� ����Ǹ� Publickey�� ��û�Ѵ�.
   SendRequestPublicKey();
end;

procedure TFrmIDSoc.IDSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   ;
end;

procedure TFrmIDSoc.IDSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   Socket.Close;
end;

procedure TFrmIDSoc.IDSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   try
      csShare.Enter;
      IdSocStr := IdSocStr + Socket.ReceiveText;
   finally
      csShare.Leave;
   end;            
end;

procedure TFrmIDSoc.Initialize;
begin
   with IDSocket do begin
      Active := FALSE;
      Address := ServerAddress;
      Port := ServerPort;
      Active := TRUE;
   end;
end;

procedure TFrmIDSoc.SendUserClose (uid: string; cert: integer);
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_USERCLOSED) + '/' + uid + '/' + IntToStr(cert) + ')');
end;

procedure TFrmIDSoc.SendCheckTimeAccount (uid: string; cert: integer);
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_CHECKTIMEACCOUNT) + '/' + uid + '/' + IntToStr(cert) + ')');
end;

procedure TFrmIDSoc.SendRequestPublicKey ();
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_REQUEST_PUBLICKEY) + ')');
end;

procedure TFrmIDSoc.SendGameTimeOfTimeCardUser (uid: string; gametime_min: integer);
begin
// 2003.01.22 ���� ���񽺿� ������ ��ƾ�̹Ƿ� ����ũ ó��
{
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_GAMETIMEOFTIMECARDUSER) +
                                      '/' + uid +
                                      '/' + IntToStr(gametime_min) +
                                      ')');
}
end;

procedure TFrmIDSoc.SendUserShiftToVentureServer (svname, uid: string; cert: integer);
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_SHIFTVENTURESERVER) + '/' + svname + '/' + uid + '/' + IntToStr(cert) + ')');
end;

procedure TFrmIDSoc.SendUserCount (ucount: integer);
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_USERCOUNT) + '/' + ServerName + '/' + IntToStr(ServerIndex) + '/' + IntToStr(ucount) + ')');
end;

procedure TFrmIDSoc.SendPremiumCheck (uname, uid: string; cert: integer);
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_PREMIUMCHECK) + '/' + uid + '/' + IntToStr(cert) + '/' + ServerName + '/' + uname + ')');
end;

procedure TFrmIDSoc.SendEventCheck (uname, uid: string; cert: integer);
begin
   if IDSocket.Socket.Connected then
      IDSocket.Socket.SendText ('(' + IntToStr(ISM_EVENTCHECK) + '/' + uid + '/' + IntToStr(cert) + '/' + ServerName + '/' + uname + ')');
end;

//procedure TFrmIDSoc.SendPotCashList (uname, uid: string; cert: integer);
//begin
//   if IDSocket.Socket.Connected then
//      IDSocket.Socket.SendText ('(' + IntToStr(ISM_POTCASHLIST) + '/' + uid + '/' + IntToStr(cert) + ')');
//end;
//
//procedure TFrmIDSoc.SendPotCashAdd (uname, uid: string; cert: integer);
//begin
//   if IDSocket.Socket.Connected then
//      IDSocket.Socket.SendText ('(' + IntToStr(ISM_POTCASHADD) + '/' + uid + '/' + IntToStr(cert) + ')');
//end;
//
//procedure TFrmIDSoc.SendPotCashDel (uname, uid: string; cert: integer);
//begin
//   if IDSocket.Socket.Connected then
//      IDSocket.Socket.SendText ('(' + IntToStr(ISM_POTCASHDEL) + '/' + uid + '/' + IntToStr(cert) + ')');
//end;

procedure TFrmIDSoc.DecodeSocStr;
var
   BufStr, str, head, body: string;
   ident: integer;
begin
   try
      csShare.Enter;
      if Pos(')', IdSocStr) <= 0 then exit;
      BufStr := IDSocStr;
      IDSocStr := '';
   finally
      csShare.Leave;
   end;

   try
      while Pos (')', BufStr) > 0 do begin
         BufStr := ArrestStringEx (BufStr, '(', ')', str);
         if str <> '' then begin
            body := GetValidStr3 (str, head, ['/']);
            ident := Str_ToInt (head, 0);
            case ident of
               ISM_PASSWDSUCCESS:
                  begin
                     GetPasswdSuccess (body);
                  end;
               ISM_CANCELADMISSION:
                  begin
                     GetCancelAdmission (body);
                  end;
               ISM_SHIFTVENTURESERVER:
                  if BoVentureServer then begin  //���輭���� �̵��ؿ�
                     ;
                  end;
               ISM_TOTALUSERCOUNT:
                  begin
                     GetTotalUserCount (body);
                  end;
               ISM_ACCOUNTEXPIRED:
                  begin
                     GetAccountExpired (body);
                  end;
               ISM_SEND_PUBLICKEY:
                  begin
                     GetRecvPublicKey (body);
                  end;
//             ISM_USAGEINFORMATION:
//                begin
//                   GetUsageInformation (body);
//                   LoginServerCheckTime := GetTickCount;
//                end;
               ISM_PREMIUMCHECK:
                  begin
                     GetPremiumCheckResponse(body);
                  end;
               ISM_EVENTCHECK:
                  begin
                     GetEventCheckResponse(body);
                  end;
//               ISM_POTCASHLIST:
//                  begin
//                     GetRecvUserPotCash(body);
//                  end;
            end;
         end else
            break;
      end;
      try
         csShare.Enter;
         IdSocStr := BufStr + IdSocStr;
      finally
         csShare.Leave;
      end;

      // Update Log...Copark
      // �������縦 �ϴ� ����
//    if GetTickCount - LoginServerCheckTime > 500000 then begin  //�α��� ������ ���� GetUsageInformation �� �� ������
      //�α��� ������ ��������.
//    IDSocket.Active := FALSE;  //�������� �پ��� �ϰԵ�
//    end;

   except
      MainOutMessage ('[Exception] FrmIdSoc.DecodeSocStr');
   end;
end;

procedure TFrmIDSoc.GetPasswdSuccess (body: string);
var
   uid, certstr, paystr, uaddr, availablestr, cversion: string;
   avail: integer;
begin
   try
      body := GetValidStr3 (body, uid, [char($a)]);
      body := GetValidStr3 (body, certstr, [char($a)]);
      body := GetValidStr3 (body, paystr, [char($a)]);
      body := GetValidStr3 (body, availablestr, [char($a)]);
      body := GetValidStr3 (body, uaddr, [char($a)]);
      body := GetValidStr3 (body, cversion, [char($a)]);
      avail := Str_ToInt(availablestr, 0);
//    FrmMain.Memo1.Lines.Add ('Cert:'+uid+'/'+certstr+'/'+paystr+'/'+availablestr+'/'+uaddr+'/'+cversion+'/');
      AddAdmission (uid, uaddr, Str_ToInt(certstr, 0), Str_ToInt(paystr, 0), avail, Str_ToInt(cversion, 0));
      //if avail = 0 then
      //   MainOutMessage (body);
   except
      MainOutMessage ('[Exception] FrmIdSoc.GetPasswdSuccess');
   end;
end;

procedure TFrmIDSoc.GetCancelAdmission (body: string);
var
   uid, certstr: string;
   cert: integer;
begin
   try
      certstr := GetValidStr3 (body, uid, ['/']);
      cert := Str_ToInt (certstr, 0);
      ////UserEngine.AccountExpired (uid);
      DelAdmission (cert);
   except
      MainOutMessage ('[Exception] FrmIdSoc.GetCancelAdmission');
   end;
end;

//available
// 1 ��������
// 2 ��������
// 3 �׹�����
// 4 �׹�����
// 5 ��¥
procedure TFrmIDSoc.AddAdmission (uid, uaddr: string; certify, paymode, available, clversion: integer);
var
   pa: PTAdmission;
begin
   new (pa);
   pa.usrid         := uid;
   pa.uaddr         := uaddr;
   pa.Certification := certify;
   pa.PayMode       := paymode;
   pa.AvailableMode := available;
   pa.ClientVersion := clversion;
   try
      csShare.Enter;
      AdmissionList.Add (pa);
   finally
      csShare.Leave;
   end;
end;

procedure TFrmIDSoc.DelAdmission (certify: integer);
var
   i: integer;
   kickid: string;
begin
   kickid := '';
   try
      csShare.Enter;
      for i:=0 to AdmissionList.Count-1 do begin
         if PTAdmission(AdmissionList[i]).Certification = certify then begin
            kickid := PTAdmission(AdmissionList[i]).UsrId;
            //���� ����
            Dispose (PTAdmission(AdmissionList[i]));
            AdmissionList.Delete (i);
            break;
         end;
      end;
   finally
      csShare.Leave;
   end;
   if kickid <> '' then
   begin
      //������ ������ ID ű..
      csDelShare.Enter;
      try
      RunSocket.CloseUserid (kickid, certify);
      finally
      csDelShare.Leave;
      end;
   end;
end;

//0: ���� ����
//1: ü����
//2: ���� �����
function  TFrmIDSoc.GetAdmission (uid, ipaddr: string; cert: integer; var availmode, clversion: integer): integer;
   function IsShareIP (ip: string): Boolean;
   var
      i: integer;
   begin
      Result := FALSE;
      for i:=0 to ShareIPList.Count-1 do
         if ShareIPList[i] = ip then begin
            Result := TRUE;
            break;
         end;
   end;
var
   i: integer;
begin
   Result := 0;
   availmode := 0;
   try
      try
         csShare.Enter;
         for i:=0 to AdmissionList.Count-1 do begin
            if PTAdmission(AdmissionList[i]).Certification = cert then begin
               //if (PTAdmission(AdmissionList[i]).usrid = uid) and
               //   (
               //     (PTAdmission(AdmissionList[i]).uaddr = ipaddr)
               //       or IsShareIP (PTAdmission(AdmissionList[i]).uaddr)
               //   ) then
               //begin
                  case PTAdmission(AdmissionList[i]).PayMode of
                     2: Result := 3;   //��������
                     1: Result := 2;   //���Ļ����
                     0: Result := 1;   //ü����
                  end;
                  availmode := PTAdmission(AdmissionList[i]).AvailableMode;
                  clversion := PTAdmission(AdmissionList[i]).ClientVersion;
               //end else begin
               //   if BoViewAdmissionFail then
               //      MainOutMessage ('[Adm-Failure] ' + ipaddr + '/' + uid);
               //end;
               break;
            end;
         end;
      finally
         csShare.Leave;
      end;
   except
      MainOutMessage ('[RunSock->FrmIdSoc] GetAdmission exception');
   end;
end;

procedure TFrmIDSoc.GetTotalUserCount (body: string);
begin
   TotalUserCount := Str_ToInt (body, 0);
end;

procedure TFrmIDSoc.GetAccountExpired (body: string);
var
   uid, certstr: string;
   cert: integer;
begin
   try
      certstr := GetValidStr3 (body, uid, ['/']);
      cert := Str_ToInt (certstr, 0);
      if not BoTestServer and not BoServiceMode then begin
//         UserEngine.AccountExpired (uid);
         if UserEngine.TimeAccountExpired( uid )then //�ð��� ���ؼ� �߹�ǰ� ����
         begin
//             DelAdmission (cert);
         end;

      end;
   except
      MainOutMessage ('[Exception] FrmIdSoc.GetCancelAdmission');
   end;
end;

procedure TFrmIDSoc.GetRecvPublicKey (body: string);
var
   pubkeystr: string;
   pubkey: integer;
begin
   try
      GetValidStr3 (body, pubkeystr, ['/']);
      pubkey := Str_ToInt (pubkeystr, 0);
      SetPublicKey( WORD(pubkey) );
      //�α��μ����κ��� publicŰ�� �޾��� �� �ٽ� ��� ������Ʈ�� �����ش�.
      RunSocket.SendPublicKeyToAllGate( GetPublicKey );
      MainOutMessage ('��ȡ���չ����ܳ� : ' + IntToStr(GetPublicKey));
   except
      MainOutMessage ('[Exception] FrmIdSoc.GetRecvPublicKey');
   end;
end;

procedure TFrmIDSoc.GetUsageInformation (body: string);
var
   scurmon, stotalmon, slastmon, sgross, sgrosscount: string;
begin
   body := GetValidStr3 (body, scurmon, ['/']);
   body := GetValidStr3 (body, stotalmon, ['/']);
   body := GetValidStr3 (body, slastmon, ['/']);
   body := GetValidStr3 (body, sgross, ['/']);
   body := GetValidStr3 (body, sgrosscount, ['/']);

   CurrentMonthlyCard := Str_ToInt (scurmon, 0);
   TotalTimeCardUsage := Str_ToInt (stotalmon, 0);
   LastMonthTotalTimeCardUsage := Str_ToInt (slastmon, 0);
   GrossTimeCardUsage := Str_ToInt (sgross, 0);
   GrossResetCount := Str_ToInt (sgrosscount, 0);

end;

procedure TFrmIDSoc.GetPremiumCheckResponse (body: string);
var
   sResult, sUserId, sUserName, sBirthDay: string;
   iGrade: integer;
begin
   iGrade := 0;
   body := GetValidStr3 (body, sResult, ['/']);
   body := GetValidStr3 (body, sUserId, ['/']);
   body := GetValidStr3 (body, sUserName, ['/']);
   body := GetValidStr3 (body, sBirthDay, ['/']);

   if sResult = 'Y' then begin
      iGrade := 2;
   end else if sResult = 'N' then begin
      iGrade := 1;
   end;

   UserEngine.ApplyPremiumUser( iGrade, sUserId, sUserName, sBirthDay );

   MainOutMessage ('[PremiumCheckResponse] ' + sResult + ', ' + sUserId + ', ' + sUserName + ', ' + sBirthDay);
end;

procedure TFrmIDSoc.GetEventCheckResponse (body: string);
var
   sResult, sUserId, sUserName: string;
begin
   body := GetValidStr3 (body, sResult, ['/']);
   body := GetValidStr3 (body, sUserId, ['/']);
   body := GetValidStr3 (body, sUserName, ['/']);

   if (sResult = 'Y') or (sResult = 'y') then begin
      UserEngine.ApplyEventUser( sUserId, sUserName );

      MainOutMessage ('[EventCheckResponse] ' + sResult + ', ' + sUserId + ', ' + sUserName);
   end;
end;

//procedure TFrmIDSoc.GetRecvUserPotCash (body: string);
//var
//   sUserId, sPotCash: string;
//begin
//   try
//      body := GetValidStr3 (body, sUserId, [char($a)]);
//      body := GetValidStr3 (body, sPotCash, [char($a)]);
//   //   FrmMain.Memo1.Lines.Add ('GetRecvUserPotCash:'+sUserId+'/'+sPotCash+'/');
//      UserEngine.ApplyUserPotCash( sUserId, Str_ToInt(sPotCash, 0) );
//   except
//      MainOutMessage ('[Exception] FrmIdSoc.GetRecvUserPotCash');
//   end;
//end;


end.
