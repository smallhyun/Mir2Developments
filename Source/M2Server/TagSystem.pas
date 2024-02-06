unit TagSystem;

interface

uses
    Classes, CmdMgr , grobal2 , {ElHashList ,} UserSystem , sysutils , HUtil32,
    ObjBase;

const

    MAX_TAG_COUNT       = 30;       // �ִ� ���� ����
    MAX_TAG_PAGE_COUNT  = 10;       // �������� ���� ����
    MAX_REJECTER_COUNT  = 20;       // �ִ� �ź��� ��

type
    // TTagInfo Class Decralations ---------------------------------------------
    TTagInfo  = class ( ICommand )
    private
        FSender     : String;       // ������
        FSendDate   : String;       // ���۳�¥
        FMsg        : String;       // ���� ����
        FState      : Integer;      // ( ��������(0) , ����(1) , �����Ұ�(2) , ������(3) );
        FDBSaved    : Boolean;      // ( DB ����� , DB ����ȵ� );
        FClient     : Boolean;      // Ŭ���̾�Ʈ�� ���۵Ǿ����� �Ǵ�
    public
        constructor Create;  override;
        destructor  Destroy; override;

        // Ŭ���̾�Ʈ�� ������ ���� ��������� ����
        function  GetMsgList : String;
//        procedure OnCmdChange( var Msg : TCmdMsg ) ; override;

        // ���� ��� ������ ���� ������Ƽ
        property  Sender      : String  read FSender    Write FSender;
        property  SendDate    : String  read FSendDate  Write FSendDate;
        property  Msg         : String  read FMsg       Write FMsg;
        property  State       : Integer read FState     Write FState;
        property  DBSaved     : Boolean read FDBSaved   Write FDBSaved;
        property  Client      : Boolean read FClient    Write FClient;

    end;
    PTTagInfo = ^TTagInfo;

    // TTagMgr Class Decralations ----------------------------------------------
    TTagMgr = class ( ICommand )
    private
        FItems          : TList; //TElHashList;  // ������ ������ ���� �ؽ�����Ʈ
        FRejecter       : TStringList; //TElHashList;  // �ź��� ����Ʈ

        FNotReadCount   : integer;      // ���� ���� ���� ����

        FIsTagListSendAble : Boolean;   // ���� ����Ʈ �غ� �Ǿ����� �˻�
        FWantTagListFlag   : Boolean;      // Ŭ���̾�Ʈ�� ����Ʈ�� ����
        FWantTagListPage   : integer;      // Ŭ���̾�Ʈ�� ���ϴ� ����Ʈ ������
        FClientGetList     : Boolean;      // Ŭ���̾�Ʈ�� ���� ����Ʈ�� ������ �ִ�

        FIsRejectListSendAble : Boolean;// �ź��� ����Ʈ �غ� �Ǿ����� �˻�
        FWantRejectListFlag   : Boolean;// Ŭ���̾�Ʈ�� �ź��� ����Ʈ�� ����

    public
        constructor Create;  override;
        destructor  Destroy; override;

        procedure   OnUserOpen;
        procedure   OnUserClose;

        //�ű� �ױ׹�ȣ ����
        function GenerateSendDate : String;
        // ���� ���� ���
        function GetTagCount    : Integer;
        // ������ �߰��� �� �ִ��� ����
        function IsTagAddAble   : Boolean;
        // �˻�
        function Find (SendDate : String) : TTagInfo;
        // �߰�
        function Add(
            UserInfo    : TUserInfo;
            Sender      : String;
            SendDate    : String;
            State       : Integer;
            Msg         : String
            ): Boolean;
        // ���� : ���¸� TAGSTATE_DELETED �� �ٲ�
        function  Delete(
            UserInfo    : TUserInfo;
            SendDate    : String;
            var rState  : Integer
            ): Boolean;
        // ���� ����
        function SetInfo(
            UserInfo    : TUserInfo;
            SendDate    : String;
            var State   : Integer
            ): Boolean;
        // ������ ��¥�� ���� ����
        procedure RemoveInfo( Date:String );
        // ��ü ����
        procedure RemoveAll;


        // �ź��� ����
        function GetRejecterCount    : Integer;
        // �ź��ڸ� ����� �� �ֳ� ����
        function IsRejecterAddAble( Name :String ) : Boolean;
        // �ź��� �߰�
        function  AddRejecter   ( Rejecter : String ): Boolean;
        // �ź��� ����
        function  DeleteRejecter( Rejecter : String ): Boolean;
        // �ź��� ã��
        function  FindRejecter  ( Rejecter : String ; pName :String): Boolean;
        // �ź��� ã��
        function  IsRejecter    ( Rejecter : String ): Boolean;
        // �ź��� ��ü ����
        procedure RemoveAllRejecter;

        // �޼��� ����Ʈ ������
        procedure OnMsgList      ( UserInfo : TUserInfo ; PageNum : Integer );
        procedure OnMsgRejectList( UserInfo : TUserInfo );


        // ��ɾ� ���۹޾����� �߻��ϴ� �̺�Ʈ
        procedure OnCmdChange( var Msg : TCmdMsg ) ; override;

        // Ŭ���̾�Ʈ���� ���� ��ɾ�� ........................................
        procedure OnCmdCMAdd            ( Cmd : TCmdMsg );
        procedure OnCmdCMAddDouble      ( Cmd : TCmdMsg );  //sonmg
        procedure OnCmdCMDelete         ( Cmd : TCmdMsg );
        procedure OnCmdCMList           ( Cmd : TCmdMsg );
        procedure OnCmdCMSetInfo        ( Cmd : TCmdMsg );
        procedure OnCmdCMRejectAdd      ( Cmd : TCmdMsg );
        procedure OnCmdCMRejectDelete   ( Cmd : TCmdMsg );
        procedure OnCmdCMRejectList     ( Cmd : TCmdMsg );
        procedure OnCmdCMNotReadCount   ( Cmd : TCmdMsg );

        // Ŭ���̾�Ʈ�� ������ ��ɾ�� ........................................
        // ����Ʈ ����
        procedure OnCmdSMList(
            UserInfo    : TUserInfo;
            PageNum     : Integer;
            ListCount   : Integer;
            TagList     : String
            );
        // ���� ���� ����
        procedure OnCmdSMInfo(
            UserInfo    : TUserInfo;
            SendDate    : String;
            State       : integer
            );
        // �����߰� ����
        procedure OnCmdSMAdd(
            UserInfo    : TUserInfo;
            Sender      : String;
            SendDate    : String;
            State       : integer;
            SendMsg     : String
            );
        // ���� ���� ����
        procedure OnCmdSMDelete(
            UserInfo    : TUserInfo;
            SendDate    : String;
            State       : Integer
            );
        // �ź��� �߰� ����
        procedure OnCmdSMRejectAdd(
            UserInfo    : TUserInfo;
            Rejecter    : String
            );
        // �ź��� ���� ����
        procedure OnCmdSMRejectDelete(
            UserInfo    : TUserInfo;
            Rejecter    : String
            );
        // �ź��� ����Ʈ ����
        procedure OnCmdSMRejectList(
            UserInfo    : TUserInfo;
            ListCount   : integer;
            RejectList  : String
            );
        // ���� ���� ���� ���� ����
        procedure OnCmdSMNotReadCount(
            UserInfo    : TUserInfo;
            NotReadCount: integer
            );
        // Ŭ���Ʈ ��ɾ ���� �����
        procedure OnCmdSMResult(
            UserInfo    : TUserInfo;
            CmdNum      : Word;
            ResultValue : Word
            );

        // �������� ���۹޴� ��ɾ�� ..........................................
        // ������ ���� ���۹���
        procedure OnCmdISMSend  ( Cmd : TCmdMsg );
        // ������ ��ɿ� ���� ���������
        procedure OnCmdISMResult( Cmd : TCmdMsg );

        // �������� �����ϴ� ��ɾ�� ..........................................
        // �������� �ʱ� ����
        procedure OnCmdOSMSend(
            UserName    : String;
            SvrIndex    : integer;
            Sender      : String;
            SendDate    : String;
            State       : integer;
            SendMsg     : String
            );
        // ������ ��ɿ� ���� ��� ����
        procedure OnCmdOSMResult(
            UserName    : String;
            SvrIndex    : integer;
            CmdNum      : Word;
            ResultValue : Word
            );

        //DB �� ������ ��ɾ�� ................................................
        // DB �� ���� �߰�
        procedure OnCmdDBAdd(
            UserInfo    : TUserInfo;
            Reciever    : String;
            SendDate    : String;
            State       : integer;
            SendMsg     : String
            );
       // DB �� ���� ���� ����
        procedure OnCmdDBInfo(
            UserInfo    : TUserInfo;
            SendDate    : String;
            State       : integer
            );
        // DB��  ���� ����
        procedure OnCmdDBDelete         ( UserInfo : TUserInfo; SendDate : String );
        // DB�� ���� ���� ���� ����
        procedure OnCmdDBDeleteAll      ( UserInfo : TUserInfo );
        // DB�� ���� ����Ʈ ��û
        procedure OnCmdDBList           ( UserInfo : TUserInfo );
        // DB�� �ź��� �߰�
        procedure OnCmdDBRejectAdd      ( UserInfo : TUserInfo ; Rejecter :String);
        // DB�� �ź��� ����
        procedure OnCmdDBRejectDelete   ( UserInfo : TUserInfo ; Rejecter :String);
        // DB�� �ź��� ����Ʈ ��û
        procedure OnCmdDBRejectList     ( UserInfo : TUserInfo );
        // �������� �������� ��û
        procedure OnCmdDBNotReadCount   ( UserInfo : TUserInfo );

        // DB �κ��� ���� ��ɾ�� .............................................
        // ���� ����Ʈ ����
        procedure OnCmdDBRList          ( Cmd : TCmdMsg );
        // �ź��� ����Ʈ ����
        procedure OnCmdDBRRejectList    ( Cmd : TCmdMsg );
        // �������� ���� ���� ����
        procedure OnCmdDBRNotReadCount  ( Cmd : TCmdMsg );
        // ����� ����
        procedure OnCmdDBRResult        ( Cmd : TCmdMsg );


    end;
    PTagMgr = ^TTagMgr;

implementation
    uses
        svMain , UserMgr;
// TTagInfo ====================================================================
constructor TTagInfo.Create;
begin
    inherited ;
    //TO DO Initialize
    FSender     := '';
    FSendDate   := '';
    FMsg        := '';
    FState      := 0;
    FDBSaved    := false;
    FClient     := false;

end;

destructor  TTagInfo.Destroy;
begin
    // TO DO Free Mem

    inherited;
end;

//------------------------------------------------------------------------------
// ������ Ŭ���̾�Ʈ�� �����Ҷ� �ʿ��� ���ڿ� ����
//------------------------------------------------------------------------------
function TTagInfo.GetMsgList : String;
begin
    //����:��¥:�������ɸ���:"����"
    Result := IntToStr(FState)+':'+FSendDate +':'+FSender+':'+FMsg;
end;

//------------------------------------------------------------------------------
// ��ɾ� ��ġ
//------------------------------------------------------------------------------
{
procedure TTagInfo.OnCmdChange( var Msg : TCmdMsg ) ;
begin
    // TODO : �ʿ�ÿ� ��ɾ ��ġ��
end;
}

// TTagMgr Class Decralations ==================================================
constructor TTagMgr.Create;
begin
    inherited ;
    //TO DO Initialize
    FItems                  := TList.Create; //TElHashList.Create;
    FRejecter               := TStringList.Create; //TElHashList.Create;

    FIstagListSendAble         := false;
    FWantTagListFlag           := false;
    FWantTagListPage           := -1;

    FClientGetList          := false;

    FIsRejectListSendAble   := false;  // �ź��� ����Ʈ �غ� �Ǿ����� �˻�
    FWantRejectListFlag     := false;  // Ŭ���̾�Ʈ�� �ź��� ����Ʈ�� ����

    FNotReadCount           := 0;

end;

destructor  TTagMgr.Destroy;
begin
    // TO DO Free Mem

    RemoveAll;
    FItems.Free;

    FRejecter.clear;
    FRejecter.Free;


    inherited;
end;

//------------------------------------------------------------------------------
// �ý����� �����ϰ� �Ѵ�.
//------------------------------------------------------------------------------
procedure TTagMgr.OnUserOpen;
begin

end;

//------------------------------------------------------------------------------
// �ý����� �Ұ����ϰ� �Ѵ�.
//------------------------------------------------------------------------------
procedure TTagMgr.OnUserClose;
begin

end;

//------------------------------------------------------------------------------
// ���� ���� ���
//------------------------------------------------------------------------------
function TTagMgr.GetTagCount : Integer;
begin
    Result := FItems.Count;
end;

//------------------------------------------------------------------------------
// ���� �߰� �����Ѱ� ����
//------------------------------------------------------------------------------
function TTagMgr.IsTagAddAble : Boolean;
begin
   Result := false;

   if GetTagCount < MAX_TAG_COUNT then begin
      Result := true;
   end;
end;

//------------------------------------------------------------------------------
// ���� ���� ��¥ ����
//------------------------------------------------------------------------------
function TTagMgr.GenerateSendDate : String;
begin
    Result := FormatDateTime('yymmddhhnnss',Now );
end;

function TTagMgr.Find (SendDate : String) : TTagInfo;
var
   Item   : TTagInfo;
   i      : integer;
begin
   Result := nil;
   for i := 0 to FItems.Count - 1 do begin
       Item := TTagInfo(FItems.Items[i]);
       if Item.FSendDate = SendDate then begin
          Result := Item;
          exit;
       end;
   end;
end;

//------------------------------------------------------------------------------
// ���� �߰�
//------------------------------------------------------------------------------
function TTagMgr.Add(
   UserInfo    : TUserInfo;
   Sender      : String;
   SendDate    : String;
   State       : Integer;
   Msg         : String
): Boolean;
var
   Info        : TTagInfo;
begin
   Result := false;

   // ������ �߰��������� �������Ŀ�
   if IsTagAddAble then begin
      // ������ �ϳ� �����
      Info := TTagInfo.Create;

      // ��ü�� �� �Ҵ�Ǿ�����
      if ( Info <> nil ) then begin

         // ���� ������ �ְ�
         Info.Sender     := Sender;
         Info.SendDate   := SendDate;
         Info.FState     := State;
         Info.Msg        := Msg;

         // �߰�
         FItems.Add( Info );   //FItems.Add ( SendDate , Info );

         // �������� �޼��� ���� �ľ�
         if Info.State = TAGSTATE_NOTREAD then begin
             Inc( FNotReadCount );
         end;

         Result := true;
      end; // if ( Info <> nil )...

   end; // if IsTagAddable...
end;

//------------------------------------------------------------------------------
// ���� ����
//------------------------------------------------------------------------------
function TTagMgr.Delete(
   UserInfo    : TUserInfo;
   SendDate    : String;
   var rState  : Integer
): Boolean;
var
   i       : Integer;
   Info    : TTagInfo;
begin
   Result := false;

   // ���������� ���
   Info := Find(SendDate);            //FItems.Item[SendDate];

   // ������ ������
   if ( Info <> nil ) then begin
      // ���� ���� ���¸� ���� ����
      if ( Info.State = TAGSTATE_DONTDELETE ) then begin
         rState := TAGSTATE_DONTDELETE;
         Exit;
      end else begin  // ���� �����ϸ� ������������ �Ӽ� ����
         Info.State := TAGSTATE_DELETED;
         rState := Info.State;
         Result := true;
         Exit;
      end;
   end;// if ( Info <> nil ) ...

end;

//------------------------------------------------------------------------------
// ���� ����
// ����䱸 ���� : 0 ( �������� ) , 1( ���� ) , 2 ( �������� ) , 3 ( �������� ����)
//------------------------------------------------------------------------------
function TTagMgr.SetInfo(
    UserInfo    : TUserInfo;
    SendDate    : String;
    var state   : Integer
): Boolean;
var
    i   : integer;
    Info: TTagInfo;
begin
    Result := false;

    Info := Find( SendDate ); //FItems.Item[SendDate];

    if Info <> nil then
    begin
        // ������ ������쿡�� ������ ������ �ϳ� ������
        if (Info.FState = TAGSTATE_NOTREAD ) and
               (State <> TAGSTATE_NOTREAD )
        then
        begin
            if ( FNotReadCount > 0 ) then
            begin
                Dec( FNotReadCount );
            end;
        end;

        // �������� ������ ��쿡�� �������� �����Ѵ�.
        if State = TAGSTATE_WANTDELETABLE then
        begin
            State := TAGSTATE_READ;
        end;

        // ������Ʈ ����
        Info.FState := State;

        Result := true;
    end;

end;

//------------------------------------------------------------------------------
// ������ ��¥�� ���� ����
//------------------------------------------------------------------------------
procedure TTagMgr.RemoveInfo( Date:String );
var
    Info    : TTagInfo;
    i       : integer;
begin
    Info := Find( Date ); //FItems.Item[Date];

    if ( Info <> nil ) then
    begin
        i := FItems.IndexOf( Info );
        if i >= 0 then begin
           FItems.Delete(i); //FItems.Delete( Date );
           Info.Free;
           exit;
        end;
    end;

end;
//------------------------------------------------------------------------------
//  ���� ���� �޸� ���� ����
//------------------------------------------------------------------------------
procedure TTagMgr.RemoveAll;
var
    i       : integer;
    Info    : TTagInfo;
begin
    for i := 0 to FItems.Count -1 do
    begin
        Info := FItems.Items[i];
        if ( Info <> nil ) then
        begin
            Info.Free;
        end
    end;

    FItems.Clear;
end;

//------------------------------------------------------------------------------
// �ź��� ���� ���
//------------------------------------------------------------------------------
function TTagMgr.GetRejecterCount : Integer;
begin
    Result := FRejecter.Count;
end;

//------------------------------------------------------------------------------
// �ź��� �߰� �����Ѱ�.
//------------------------------------------------------------------------------
function TTagMgr.IsRejecterAddAble( Name : String ) : Boolean;
var
   Str    : String;
begin
    if ( Name <> '' )  and                      // �̸��� �ְ�
       ( false = FindRejecter( Name , Str) ) and     // �̹� ������� �ʰ�
       ( GetRejecterCount < MAX_REJECTER_COUNT )// �ִ� ������ �����ʾƾ���
    then
        Result := true
    else
        Result := false;
end;

//------------------------------------------------------------------------------
// �ź��� �߰�
//------------------------------------------------------------------------------
function  TTagMgr.AddRejecter( Rejecter : String ): Boolean;
var
    pStr    :PString;
begin
    Result := false;

    if IsRejecterAddAble( Rejecter ) then
    begin
//      new (pStr);
//      pStr^ := Rejecter;
        FRejecter.Add ( Rejecter );        //FRejecter.Add ( Rejecter , pStr );
        Result := true;
    end;
end;

//------------------------------------------------------------------------------
// �ź��� ����
//------------------------------------------------------------------------------
function  TTagMgr.DeleteRejecter(Rejecter : String ): Boolean;
var
    Str  : String;
    i    : integer;
begin
    Result := false;

    if FindRejecter( Rejecter , Str) then
    begin
        i := FRejecter.IndexOf ( Rejecter );
        if i >= 0 then begin
           FRejecter.Delete(i); //FRejecter.Delete ( Rejecter );
//         Dispose( pStr);
           Result := true;
        end;
    end;
end;

//------------------------------------------------------------------------------
// �ź��� ã��
//------------------------------------------------------------------------------
function  TTagMgr.FindRejecter( Rejecter : String ; pName :String) : Boolean;
var
    pStr    : PString;
    i       : Integer;
begin
    pStr   := nil;
    pName  := '';
    Result := false;
    // pStr := FRejecter.Item[Rejecter];
    for i := 0 to FRejecter.Count - 1 do begin
//     pStr := PString(FRejecter.Items[i]);
       if FRejecter.Strings[i] = Rejecter then begin
          pName  := FRejecter.Strings[i];
          Result := true;
          exit;
       end;
    end;
end;

//------------------------------------------------------------------------------
// �ź��� ã��
//------------------------------------------------------------------------------
function  TTagMgr.IsRejecter( Rejecter : String ) : Boolean;
var
    pStr    : PString;
    i       : Integer;
begin
    Result := false;

//  pStr := FRejecter.Item[Rejecter];
    for i := 0 to FRejecter.Count - 1 do begin
//     pStr := PString(FRejecter.Items[i]);
       if FRejecter.Strings[i] = Rejecter then begin
          Result := true;
          exit;
       end;
    end;
end;

//------------------------------------------------------------------------------
// ��� �ź��� �޸𸮸� �����Ѵ�.
//------------------------------------------------------------------------------
procedure  TTagMgr.RemoveAllRejecter;
var
    pStr    : PString;
    i       : Integer;
begin
   {
    for i := 0 to FRejecter.Count - 1 do
    begin
        pStr := FRejecter.Items[i];        //FRejecter.GetByIndex(i);
        if ( pStr <> nil ) then
        begin
            Dispose( pStr );
            pStr := nil;
        end;
    end;
    }
    FRejecter.Clear;
end;

//------------------------------------------------------------------------------
// ��ɾ� ���۹޾��� ��� �߻��ϴ� �̺�Ʈ �����ε��
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdChange( var Msg : TCmdMsg ) ;
begin
    case Msg.CmdNum of
    CM_TAG_ADD          :OnCmdCMAdd         ( Msg );
    CM_TAG_ADD_DOUBLE   :OnCmdCMAddDouble   ( Msg );  //sonmg
    CM_TAG_DELETE       :OnCmdCMDelete      ( Msg );
    CM_TAG_SETINFO      :OnCmdCMSetInfo     ( Msg );
    CM_TAG_LIST         :OnCmdCMList        ( Msg );
    CM_TAG_NOTREADCOUNT :OnCmdCMNotReadCount( Msg );
    CM_TAG_REJECT_LIST  :OnCmdCMRejectList  ( Msg );
    CM_TAG_REJECT_ADD   :OnCmdCMRejectAdd   ( Msg );
    CM_TAG_REJECT_DELETE:OnCmdCMRejectDelete( Msg );

    ISM_TAG_Send        :OnCmdISMSend       ( Msg );
    ISM_TAG_RESULT      :OnCmdISMResult     ( Msg );
    DBR_TAG_LIST        :OnCmdDBRList       ( Msg );
    DBR_TAG_REJECT_LIST :OnCmdDBRRejectList ( Msg );
    DBR_TAG_NOTREADCOUNT:OnCmdDBRNotReadCount( Msg );
    DBR_TAG_RESULT      :OnCmdDBRResult     ( Msg );
    end;
end;

//------------------------------------------------------------------------------
// Ŭ���Ʈ�� ���� ����Ʈ�� �����Ѵ�.
//------------------------------------------------------------------------------
procedure TTagMgr.OnMsgList( UserInfo : TUserInfo ; PageNum : Integer );
var
   i           : Integer;
   startnum    : Integer;
   endnum      : Integer;
   listcount   : Integer;
   Cnt         : Integer;
   TempStr     : String;
   taginfo     : TTagInfo;

begin
   listcount := GetTagCount - 1;

   // ������ ��ȣ�� 0 �̸� ��ü�����Ѵ�.
   if ( PageNum = 0 )then begin
      startnum    := 0;
      endnum      := listcount;
   end else begin
      startnum    := (PageNum-1)  * MAX_TAG_PAGE_COUNT;
      endnum      := startnum + MAX_TAG_PAGE_COUNT;
   end;

   TempStr     := '';

   // ���� ���۹�ȣ�� ����Ʈ ũ�� ������ ������
   if startnum <= listcount then begin
      // ���� ����ȣ�� ����Ʈ ũ�⺸�� ũ�� ����ȣ�� �����Ѵ�.
      if endnum > listCount then
         endnum := listcount;

      // ���۹�ȣ - ����ȣ������ �������� ����Ʈ ����
      Cnt := 0;
//      for i := startnum to endnum do begin
      for i := endnum downto startnum do begin   //�Ųٷ�
         taginfo := FItems.Items[i];   //FItems.GetByIndex(i);
         TempStr := TempStr + taginfo.GetMsgList + '/';
         Inc(Cnt);
      end;

      // Ŭ���̾�Ʈ�� ����
      OnCmdSMList( UserInfo , PageNum , Cnt ,TempStr );

      // Ŭ���Ʈ�� ����Ʈ�� ������ �ִ�
      FClientGetList := true;

   end;

end;

//------------------------------------------------------------------------------
// Ŭ���̾�Ʈ�� �ź��� ����Ʈ�� �����Ѵ�.
//------------------------------------------------------------------------------
procedure TTagMgr.OnMsgRejectList( UserInfo : TUserInfo );
var
    i       : integer;
    Cnt     : Integer;
    TempStr : string;
    pName   : pString;
begin
    // �����Ҳ� ������ ���
    if FRejecter.Count = 0 then Exit;

    TempStr := '';
    Cnt     := 0;

    for i := 0 to FRejecter.Count - 1 do
    begin
//        pName := FRejecter.Items[i];   //FRejecter.GetByIndex(i);
//        if ( pName <> nil ) then
//        begin
//            TempStr := TempStr + pName^ +'/';
       TempStr := TempStr + FRejecter.Strings[i] +'/';
       Inc( Cnt );
//        end;

    end;

    OnCmdSMRejectList( UserInfo, Cnt ,TempStr );

end;

////////////////////////////////////////////////////////////////////////////////
// Ŭ���̾�Ʈ���� ���� ��ɾ��
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// CM_TAG_ADD : ���� �߰�
// ������ / ��������
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMAdd( Cmd : TCmdMsg );
var
    reciever    : String;
    tagmsg      : String;
    senddate     : String;
    recieverinfo: TUserInfo;
begin
    // ����� �м�
    tagmsg := GetValidStr3 (Cmd.body,reciever, ['/']);

    senddate := GenerateSendDate;

    // ������ ������ �����ڿ��� �˷��ش�.
    if UserMgrEngine.InterGetUserInfo( reciever , recieverinfo ) then
    begin
        // ���ܺ� ������ ����
        OnCmdOSMSend(   reciever,
                        recieverinfo.ConnState - CONNSTATE_CONNECT_0,
                        Cmd.UserName,
                        senddate,
                        0,
                        tagmsg
                    );
    end;

    // DB �� ��������
    OnCmdDBAdd( Cmd.pInfo ,reciever,senddate , 0 , tagmsg );
end;

procedure TTagMgr.OnCmdCMAddDouble( Cmd : TCmdMsg );
var
    receiver    : String;
    receiver2   : String;
    tagmsg      : String;
    senddate     : String;
    receiverinfo: TUserInfo;
    receiverinfo2: TUserInfo;
    hum : TUserHuman;
begin
    // ��ɾ� �м�
    tagmsg := GetValidStr3 (Cmd.body, receiver, ['/']);
    tagmsg := GetValidStr3 (tagmsg, receiver2, ['/']);

    // ������ �ð� ���.
    senddate := GenerateSendDate;

    /////////////////////////////////
    // ù��° �����ڿ��� ����.
    // ������ ����� �޴� ����� ������ ������ ����.(sonmg : 2004/05/03)
    if receiver <> Cmd.UserName then begin
       // ������ ������ �����ڿ��� �˷��ش�.
       if UserMgrEngine.InterGetUserInfo( receiver , receiverinfo ) then
       begin
           // ���ܺ� ������ ����
           OnCmdOSMSend(   receiver,
                           receiverinfo.ConnState - CONNSTATE_CONNECT_0,
                           Cmd.UserName,
                           senddate,
                           0,
                           tagmsg
                       );
       end;

       // ���� ���� �޽��� ���
       // �̰� �̷��� ���� �����ε�.. ���߿� ��ġ�� ������ �Ժη� ���� ����
{      TagLock.Enter;
       try

       hum := UserEngine.GetUserHuman( Cmd.UserName );
       if hum <> nil then begin
           hum.SysMsg(receiver + '�Կ��� ������ �����߽��ϴ�.', 0);
       end;

       finally
          TagLock.Leave;
       end;
}
       // DB �� ��������
       OnCmdDBAdd( Cmd.pInfo, receiver, senddate , 0 , tagmsg );
    end;

    /////////////////////////////////
    // �ι�° �����ڿ��� ����.
    if receiver2 <> Cmd.UserName then begin
       if receiver2 = '---' then exit;

       // ������ ������ �����ڿ��� �˷��ش�.
       if UserMgrEngine.InterGetUserInfo( receiver2 , receiverinfo2 ) then
       begin
           // ���ܺ� ������ ����
           OnCmdOSMSend(   receiver2,
                           receiverinfo2.ConnState - CONNSTATE_CONNECT_0,
                           Cmd.UserName,
                           senddate,
                           0,
                           tagmsg
                       );
       end;

       // ���� ���� �޽��� ���
       // �̰� �̷��� ���� �����ε�.. ���߿� ��ġ�� ������ �Ժη� ���� ����
{      TagLock.Enter;
       try

       hum := UserEngine.GetUserHuman( Cmd.UserName );
       if hum <> nil then begin
           hum.SysMsg(receiver2 + '�Կ��� ������ �����߽��ϴ�.', 0);
       end;

       finally
           TagLock.Leave;
       end;
}
       // DB �� ��������
       OnCmdDBAdd( Cmd.pInfo, receiver2, senddate , 0 , tagmsg );
    end;
end;

//------------------------------------------------------------------------------
// CM_TAG_DELETE    : ���� ����
// Param    : ������¥
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMDelete( Cmd : TCmdMsg );
var
    senddate    : string;
    deletemode  : integer;
    rState      : Integer;
    userinfo    : TUserInfo;
begin
    // ����� �м�
    senddate    := Cmd.body;
    deletemode  := Cmd.Msg.Param;
    userinfo    := Cmd.pInfo;

    case deletemode of
    0 : begin   // 1 �� ����
            if Delete( Cmd.pInfo , senddate ,rState ) then
            begin

                // DB�� ��ɾ� ������
                OnCmdDBDelete( userinfo, senddate );

                // Ŭ���̾�Ʈ�� ��ɾ� ������
                OnCmdSMDelete(
                    userinfo,
                    senddate,
                    rState
                );

                // ������ �޸𸮿��� ���� 
                RemoveInfo( senddate );

            end;
        end;
    1 : begin   // ������ ���� ����

        end;
    end;

end;

//------------------------------------------------------------------------------
// CM_TAG_LIST    : ���� ����Ʈ �䱸
// Param    : ������ ��ȣ
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMList( Cmd : TCmdMsg );
var
   pagenum : integer;
begin
   pagenum := Cmd.Msg.Param;

   // ���۰����ϸ�
   if FIsTagListSendAble then begin
      OnMsgList( Cmd.pInfo , pagenum );
   end else begin
      // ������ �Ұ����ϴ�. DB�κ��� ���� ����Ʈ�� �������� ����
      FWantTagListFlag   := true;
      FWantTagListPage   := pagenum;

      // Ŭ���Ѽ��� �о���� �����Ѵ�.
      OnCmdDBList( Cmd.pInfo );
   end;

end;

//------------------------------------------------------------------------------
// CM_TAG_EDIT    : �������� ���� �� ���� ���� ����
// Param    : ������¥ ,  ���� ���� ���� ��ȣ
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMSetInfo( Cmd : TCmdMsg );
var
    tagstate    : integer;
    senddate    : string;
    userinfo    : TUserInfo;
begin
    senddate    := Cmd.body;
    tagstate    := Cmd.Msg.Param;

    userinfo := Cmd.pInfo;

    if SetInfo( userinfo , senddate , tagstate ) then
    begin
        // Ŭ���̾�Ʈ�� ����
        OnCmdSMInfo(userinfo, senddate, tagstate);
        // DB �� ����
        OnCmdDBInfo( userinfo,senddate , tagstate );
    end
    else
    begin
        // ���� ����
        OnCmdSMResult(userinfo , CM_TAG_SETINFO , CR_DONTUPDATE );
    end;
end;

//------------------------------------------------------------------------------
// CM_TAG_REjECT_ADD   : �ź��� �߰�
// Param    : �ź����̸�
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMRejectAdd( Cmd : TCmdMsg );
var
    rejecter    : String;
    userinfo    : TUserInfo;
    rejectinfo  : TUserInfo;
begin
    rejecter    := Cmd.body;
    userinfo    := Cmd.pInfo;

    // �¶��ο� �ִ»���� �ź��ڷ� �߰��� �� �ִ�.
    if not UserMgrEngine.InterGetUserInfo( rejecter , rejectinfo ) then
    begin
        OnCmdSMResult( userinfo , CM_TAG_REJECT_ADD , CR_DONTADD );
        Exit;
    end;

    // �ź��� �߰�
    if AddRejecter( rejecter ) then
    begin
        OnCmdDBRejectAdd( userinfo , Rejecter );
        OnCmdSMRejectAdd( userinfo, rejecter );
    end
    else
    begin
        OnCmdSMResult(userinfo,CM_TAG_REJECT_ADD , CR_DONTADD);
    end;

end;

//------------------------------------------------------------------------------
// CM_TAG_REJECT_DELETE    : �ź��� ����
// Param    : ������ �ź��� �̸�
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMRejectDelete( Cmd : TCmdMsg );
var
    rejecter    : String;
    userinfo    : TUserInfo;
begin
    rejecter    := Cmd.body;
    userinfo    := Cmd.pInfo;
    if DeleteRejecter( rejecter ) then
    begin
        OnCmdDBRejectDelete( userinfo , Rejecter );
        OnCmdSMRejectDelete( userinfo, rejecter );
    end
    else
    begin
        OnCmdSMResult(userinfo ,CM_TAG_REJECT_DELETE , CR_DONTDELETE);
    end;

end;

//------------------------------------------------------------------------------
// CM_TAG_REJECT_LIST    : �ź��� ����Ʈ �䱸
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMRejectList( Cmd : TCmdMsg );
var
    userinfo : TUserInfo;
begin
    userinfo    := Cmd.pInfo;
    if FIsRejectListSendAble then
        OnMsgRejectList( userinfo )
    else
    begin
        FWantRejectListFlag := TRUE;
        // OnCmdSMResult(userinfo,CM_TAG_REJECT_LIST , CR_DBWAIT);
    end;

end;

//------------------------------------------------------------------------------
// CM_TAG_NOTREADCOUNT    : �������� ���� ���� �䱸
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdCMNotReadCount( Cmd : TCmdMsg );
var
    userinfo : TUserInfo;
begin
    userinfo    := Cmd.pInfo;
    if FIsTagListSendAble then
        OnCmdSMNotReadCount( userinfo, FNotReadCount )
    else
        OnCmdSMResult(userinfo ,CM_TAG_NOTREADCOUNT , CR_DBWAIT);
end;

//==============================================================================
// Ŭ���̾�Ʈ�� ������ ��ɾ��
//==============================================================================
//------------------------------------------------------------------------------
// SM_TAG_LIST    : ���� ����Ʈ ����
// Param    : ���� ���� , ���� �������� ����Ʈ
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMList(
    UserInfo    : TUserInfo;
    PageNum     : Integer;
    ListCount   : Integer;
    TagList     : String
);
var
    str : String;
begin
    str := TagList;

    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx ,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName,UserInfo.Recog ,
                                SM_TAG_LIST , PageNum,ListCount,0, str);

end;

//------------------------------------------------------------------------------
// SM_TAG_INFO    : ���� ���� ���� ����
// Param    : ������¥ , ��������
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMInfo(
    UserInfo    : TUserInfo;
    SendDate    : String;
    State       : integer
);
var
    str : String;
begin
    str := SendDate;

    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx  ,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName ,UserInfo.Recog,
                                SM_TAG_INFO , State,0,0, str);

end;

//------------------------------------------------------------------------------
// SM_TAG_ADD    : ���� �߰� ����
// Param    : ���� : ��¥ : ������ : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMAdd(
    UserInfo    : TUserInfo;
    Sender      : String;
    SendDate    : String;
    State       : integer;
    SendMsg     : String
);
var
    str : String;
begin
    //����: ��¥:������:"����"
    str := IntToStr(State)+':'+SendDate+':'+Sender+':'+SendMsg;
    // pagenum = 0 , sendnum = 1;
    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName ,UserInfo.Recog,
                                SM_TAG_LIST ,0,1,0, str);

end;

//------------------------------------------------------------------------------
// ������ ������ �޸𸮿��� ���������θ� ǥ�õǰ� DB���� ������ ������Ŵ
// ���� ���߿� ������ �� �����ϸ� ������Ե�
// +----------------------------------------------------------------------------
// SM_TAG_DELETE    : ���� ���� ���� ����
// Param    : ������¥ , �������� ( ������ ���� ���� )
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMDelete(
    UserInfo    : TUserInfo;
    SendDate    : String;
    State       : Integer
);
var
    str : String;
begin
    //����: ��¥:������:"����"
    str := SendDate;
    // pagenum = 0 , sendnum = 1;
    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx  ,UserInfo.UserGateIdx, UserInfo.UserHandle,
                                UserInfo.UserName , UserInfo.Recog ,
                                SM_TAG_INFO ,State,0,0, str);

end;

//------------------------------------------------------------------------------
// SM_TAG_REJECT_LIST   : �ź��� ����Ʈ ����
// Param    : �ź��� ���� , �ź��� ����Ʈ
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMRejectList(
    UserInfo    : TUserInfo;
    ListCount   : integer;
    RejectList  : String
);
var
    str : String;
begin
    str := RejectList;

    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx  ,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName ,UserInfo.Recog,
                                SM_TAG_REJECT_LIST ,ListCount,0,0, str);

end;

//------------------------------------------------------------------------------
// SM_TAG_REJECT_ADD   : �ź��� �߰� ����
// Param    : �ź��ڸ�
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMRejectAdd(
    UserInfo    : TUserInfo;
    Rejecter    : String
);
var
    str : String;
begin
    str := Rejecter;
    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName , UserInfo.Recog ,
                                SM_TAG_REJECT_ADD ,0,0,0, str);

end;

//------------------------------------------------------------------------------
// SM_TAG_REJECT_DELETE   : �ź��� ���� ����
// Param    : �ź��ڸ�
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMRejectDelete(
    UserInfo    : TUserInfo;
    Rejecter    : String
);
var
    str : String;
begin
    str := Rejecter;

    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx  ,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName ,UserInfo.Recog,
                                SM_TAG_REJECT_DELETE ,0,0,0, str);

end;

//------------------------------------------------------------------------------
// SM_TAG_NOTREADCOUNT   : �������� ���� ���� ����
// Param    : �������� ���� ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMNotReadCount(
    UserInfo    : TUserInfo;
    NotReadCount: integer
);
begin

    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName , UserInfo.Recog,
                                SM_TAG_ALARM ,NotReadCount,0,0,'');

end;

//------------------------------------------------------------------------------
// SM_TAG_RESULT   : Ŭ���̾�Ʈ ��ɾ ���� �����
// Param    : ���۵� ��ɾ� , �����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdSMResult(
    UserInfo    : TUserInfo;
    CmdNum      : Word;
    ResultValue : Word
    );
begin

    UserMgrEngine.InterSendMsg (   stClient ,0,
                                UserInfo.GateIdx  ,UserInfo.UserGateIdx,UserInfo.UserHandle,
                                UserInfo.UserName ,UserInfo.Recog,
                                SM_TAG_RESULT ,CmdNum,Resultvalue,0,'');

end;

////////////////////////////////////////////////////////////////////////////////
// �������� ���۹޴� ��ɾ��
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// ISM_TAG_SEND   : �������� ���� ���۹���
// Param    : �������� , ��¥ , ������ , ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdISMSend( Cmd : TCmdMsg );
var
    sender      : String;
    senddate    : String;
    statestr    : String;
    state       : integer;
    sendmsg     : String;
    tempstr     : String;
    userinfo    : TUserInfo;
begin
    // ����:��¥:�������ɸ���:"����"
    TempStr := GetValidStr3 (Cmd.body   ,statestr   , [':']);
    TempStr := GetValidStr3 (TempStr    ,SendDate   , [':']);
    SendMsg := GetValidStr3 (TempStr    ,Sender     , [':']);

    userinfo := Cmd.pInfo;
    state    := Str_ToInt( statestr , 0 );

    // �ź��ڰ� �ƴϸ�
    if not IsRejecter( sender ) then
    begin
        // ������ �߰��Ѵ�.
        if Add( userinfo , sender , senddate ,state, sendmsg ) then
        begin
            // ũ���̾�Ʈ�� ����Ʈ�� ���۹޾Ҵٸ� �������� ����
            if FClientGetList then
            begin
                OnCmdSMAdd( userinfo, sender , senddate , state , sendmsg );
            end;
            // �������� �˸� ����
            OnCmdSMNotReadCount( userinfo , FNotReadCount );
        end;

    end;

end;

//------------------------------------------------------------------------------
// ISM_TAG_RESULT   : �������� ��� ���� ����
// Param    : ���۸�ɾ� , �����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdISMResult( Cmd : TCmdMsg );
begin

end;

////////////////////////////////////////////////////////////////////////////////
// �������� �����ϴ� ��ɾ��
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// ISM_TAG_SEND   : �������� ���� ������
// Param    : �������� , ��¥ , ������ , ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdOSMSend(
    UserName    : String;
    SvrIndex    : integer;
    Sender      : String;
    SendDate    : String;
    State       : integer;
    SendMsg     : String
);
var
    str : string;
begin
    // ����:��¥:�������ɸ���:"����"
    str := IntToStr(State) +':'+SendDate+':'+Sender+':'+SendMsg;

    UserMgrEngine.InterSendMsg (   stOtherServer ,0,0,0,0,
                                UserName ,0, ISM_TAG_SEND , SvrIndex,0,0, str);

end;

//------------------------------------------------------------------------------
// ISM_TAG_RESULT   : �������� ��� ������
// Param    : ���۸�ɾ� , �����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdOSMResult(
    UserName    : String;
    SvrIndex    : integer;
    CmdNum      : Word;
    ResultValue : Word
);
var
    str : string;
begin
    str := IntToStr(CmdNum) +':' +IntToStr(ResultValue);

    UserMgrEngine.InterSendMsg (   stOtherServer ,0,0,0,0,
                                UserName ,0, ISM_TAG_RESULT , SvrIndex,0,0, str);

end;
////////////////////////////////////////////////////////////////////////////////
// DB �κ��� ���� ��ɾ��
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// DBR_TAG_LIST   : DB�κ��� ���� ����Ʈ ����
// Param    : ���� , ����Ʈ
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRList( Cmd : TCmdMsg );
var
   tagcountstr : string;
   sender      : String;
   senddate    : String;
   statestr    : String;
   sendmsg     : String;
   tempstr     : String;
   tagstr      : String;
   tagcount    : integer;
   i           : Integer;
   userinfo    : TUserInfo;
begin
   tempstr     := GetValidStr3 (Cmd.body, tagcountstr, ['/']);
   tagcount    := Str_ToInt( tagcountstr , 0 );

   userinfo    := Cmd.pInfo;
   // �������ִ� ��� ����ƮƲ �����.
   RemoveAll;

   for i := 0 to tagcount -1 do begin
      // ������ ���õȳ��� �����´�.
      tempstr := GetValidStr3 (tempstr    ,tagstr, ['/']);

      // ���� ���ڸ� �и��Ѵ�.
      tagstr  := GetValidStr3 (tagstr     ,statestr, [':']);
      tagstr  := GetValidStr3 (tagstr     ,senddate, [':']);
      sendmsg := GetValidStr3 (tagstr     ,sender  , [':']);

      // ���� �߰�
      if not Add( userinfo , sender , senddate , Str_ToInt( statestr,0 ), sendmsg ) then begin
         // �߰��ȵǴ� ������ ǥ������
//         MainOutMessage('Tag didn''t Added...');
      end;
   end;


    // ����Ʈ �غ� �Ǿ���
    FIsTagListSendAble := true ;

    // �������� �˸� ���� 2003-08-21 : ���ο��� �˷��ش�.. ������
    // OnCmdSMNotReadCount( userinfo , FNotReadCount );

    // Ŭ���̾�Ʈ�� ����Ʈ�� ���� ����
    if FWantTagListFlag then begin
        // Ŭ���̾�Ʈ���� ����Ʋ ������
        OnMsgList( userinfo , FWantTagListPage );
        // Ŭ���̾�Ʈ���� �������� ����
        FWantTagListFlag   := false;
    end;


end;

//------------------------------------------------------------------------------
// DBR_TAG_REJECT_LIST   : DB�κ��� �ź��� ����Ʈ ����
// Param    : ���� , ����Ʈ
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRRejectList( Cmd : TCmdMsg );
var
    tempstr         : String;
    rejecter        : String;
    rejectcountstr  : String;
    rejectcount     : Integer;
    i               : Integer;
    userinfo        : TUserInfo;
begin
    tempstr         := GetValidStr3 (Cmd.body   ,rejectcountstr, ['/']);
    rejectcount     := Str_ToInt( rejectcountstr ,0 );

    userinfo        := Cmd.pInfo;

    for i := 0 to rejectcount -1 do
    begin
        // ������ ���õȳ��� �����´�.
        tempstr := GetValidStr3 (tempstr    ,rejecter, ['/']);

        if not AddRejecter( rejecter ) then
        begin
            // �߰��ȵǴ� ������ ǥ������
        end;
    end;

    // �ź��� ����Ʈ �غ� �Ǿ�����
    FIsRejectListSendAble := true;

    // Ŭ���̾�Ʈ�� �ź��� ����Ʈ�� ����
    if FWantRejectListFlag then
    begin
        OnMsgRejectList( userinfo );
        FWantRejectListFlag := false;
    end;


end;

//------------------------------------------------------------------------------
// DBR_TAG_NOTREADCOUNT   : DB�κ��� �������� ���� ���� ����
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRNotReadCount( Cmd : TCmdMsg );
var
    notreadcountstr : string;
    userinfo        : TUserInfo;
begin
    notreadcountstr := Cmd.body;
    userinfo        := Cmd.pInfo;

    OnCmdSMNotReadCount( userinfo, Str_ToInt(notreadcountstr,0 ));
end;

//------------------------------------------------------------------------------
// DBR_TAG_RESULT   : DB�κ��� ����� ����
// Param    : ������ ��ɾ� �����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRResult( Cmd : TCmdMsg );
var
    CmdNum  : string;
    ErrCode : string;

begin
    // TO TEST:
    ErrMsg( 'CmdDBRResult[Tag] :'+Cmd.Body );

    CmdNum := GetValidStr3 (Cmd.body,ErrCode, ['/']);

    Case Str_ToInt( CmdNum , 0) of
    DB_TAG_ADD          :;
    DB_TAG_DELETE       :;
    DB_TAG_DELETEALL    :;
    DB_TAG_LIST         :;
    DB_TAG_SETINFO      :;
    DB_TAG_REJECT_ADD   :;
    DB_TAG_REJECT_DELETE:;
    DB_TAG_REJECT_LIST  :;
    DB_TAG_NOTREADCOUNT :;
    end;


end;
////////////////////////////////////////////////////////////////////////////////
//DB �� ������ ��ɾ��
////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------
// DB_TAG_ADD   : DB�� ���� �߰� ����
// Param    : ���� , ��¥ , ������ , ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBAdd(
    UserInfo    : TUserInfo;
    Reciever    : String;
    SendDate    : String;
    State       : integer;
    SendMsg     : String
);
var
    str :string;
begin

    str := IntToStr(State) +':'+SendDate+':'+Reciever+':'+SendMsg+'/';

    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_ADD ,
                                0,0,0,str );

end;

//------------------------------------------------------------------------------
// DB_TAG_INFO   : DB�� ���� ���� ���� ����
// Param    : ��¥ , ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBInfo(
    UserInfo    : TUserInfo;
    SendDate    : String;
    State       : integer
);
var
    str :string;
begin

    str := IntToStr(State) +':'+SendDate+'/';

    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_SETINFO ,
                                0,0,0,str );

end;

//------------------------------------------------------------------------------
// DB_TAG_DELETE   : DB�� ���� ���� ����
// Param    : ��¥
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBDelete( UserInfo : TUserInfo; SendDate : String );
var
    str :string;
begin
    str := SendDate +'/';
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_DELETE ,
                                0,0,0,str );

end;

//------------------------------------------------------------------------------
// DB_TAG_DELETEALL   : DB�� ���� ���λ��� ���� ( ���������Ͱ� ���������Ȱ��� ����)
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBDeleteAll( UserInfo : TUserInfo );
begin
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_DELETEALL ,
                                0,0,0,'' );
end;

//------------------------------------------------------------------------------
// DB_TAG_LIST   : DB�� ��������Ʈ ��û
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBList( UserInfo : TUserInfo );
begin
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_LIST ,
                                0,0,0,'' );
end;

//------------------------------------------------------------------------------
// DB_TAG_REJECT_ADD   : DB�� �ź��� ����Ʈ �߰�
// Param    : �ź��ڸ�
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRejectAdd( UserInfo : TUserInfo ; Rejecter :String);
var
    str : string;
begin
    str := Rejecter+'/';
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_REJECT_ADD ,
                                0,0,0,str );
end;

//------------------------------------------------------------------------------
// DB_TAG_REJECT_DELETE   : DB�� �ź��� ����Ʈ ����
// Param    : �ź��ڸ�
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRejectDelete( UserInfo : TUserInfo ; Rejecter :String);
var
    str : string;
begin
    str := Rejecter+'/';
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_REJECT_DELETE ,
                                0,0,0,str );

end;

//------------------------------------------------------------------------------
// DB_TAG_REJECT_LIST   : DB�� �ź��� ����Ʈ ���� ��û
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBRejectList( UserInfo : TUserInfo );
begin
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_REJECT_LIST ,
                                0,0,0,'' );

end;

//------------------------------------------------------------------------------
// DB_TAG_NOTREDCOUNT   : DB�� �������� �޼��� ���� ��û
// Param    : ����
//------------------------------------------------------------------------------
procedure TTagMgr.OnCmdDBNotReadCount( UserInfo : TUserInfo );
begin
    UserMgrEngine.InterSendMsg (   stDBServer ,ServerIndex,0,0,0,
                                UserInfo.UserName ,0, DB_TAG_NOTREADCOUNT ,
                                0,0,0,'' );
end;




end.
