unit UserSystem;

interface

uses
    Classes, SysUtils ,CmdMgr , {ElHashList ,} grobal2 , HUtil32;


type
    // TUserInfo Class Declarations --------------------------------------------
    TUserInfo  = class (ICommand)
    private
        FUserName    : String;      // ����� �̸�
        FConnState   : Integer;     // ���ӻ���
        FGateIdx     : Integer;     // ���Ӽ����� ���ӵ� ����Ʈ ��ȣ
        FUserGateIdx : Integer;     // ���Ӽ����� ���ӵ� ����Ʈ ��ȣ
        FUserHandle  : Integer;     // ���� �ڵ�
        FRecog       : Integer;     // Hum �޸��� �ּ�
        FMapInfo     : String;      // ������ ���� �� ����
    public
        constructor Create;  override;
        destructor  Destroy; override;

        procedure   OnUserOpen;
        procedure   OnUserClose;
        // ��ɾ� ��ġ
        procedure   OnCmdChange( var Cmd : TCmdMsg ) ; override;

        // ��ɾ� ���� ����
        procedure   OnCmdISMFriendOpen ( Cmd : TCmdMsg);
        procedure   OnCmdISMFriendClose( Cmd : TCmdMsg);
        procedure   OnCmdISMUserInfo   ( Cmd : TCmdMsg);


       // ���� ����Լ� ���� ������Ƽ
        property  UserName      : String  read FUserName    Write FUserName;
        property  ConnState     : Integer read FConnState   Write FConnState;
        property  GateIdx       : Integer read FGateIdx     Write FGateIdx;
        property  UserGateIdx   : Integer read FUserGateIdx Write FUserGateIdx;
        property  UserHandle    : Integer read FUserHandle  Write FUserHandle;
        property  Recog         : Integer read FRecog       Write FRecog;
        property  MapInfo       : String  read FMapInfo     Write FMapInfo;

    end;

    PTUserInfo = ^TUserInfo;

implementation
    uses
        UserMgr , svMain;

// TUserInfo =================================================================
constructor TUserInfo.Create;
begin
    inherited ;
    //TO DO Initialize
    FUserName    := '';
    FConnState   := CONNSTATE_UNKNOWN;
    FGateIdx     := 0;
    FUserHandle  := 0;
    FRecog       := 0;
    FMapInfo     :='';
end;

destructor  TUserInfo.Destroy;
begin
    // TO DO Free Mem

    inherited;
end;

//------------------------------------------------------------------------------
// �ý����� �����ϰ� �����.
//------------------------------------------------------------------------------
procedure TUserInfo.OnUserOpen;
begin

end;

//------------------------------------------------------------------------------
// �ý�����  �Ұ����ϰ� �����.
//------------------------------------------------------------------------------
procedure TUserInfo.OnUserClose;
begin

end;
//------------------------------------------------------------------------------
// ��ɾ� �̺�Ʈ ó��
//------------------------------------------------------------------------------
procedure TUserInfo.OnCmdChange( var Cmd :TCmdMsg ) ;
begin

    case Cmd.CmdNum of
    ISM_FRIEND_OPEN     : OnCmdISMFriendOpen ( Cmd );
    ISM_FRIEND_CLOSE    : OnCmdISMFriendClose( Cmd );
    ISM_USER_INFO       : OnCmdISMUserInfo   ( Cmd );
    end;

end;

//------------------------------------------------------------------------------
// ģ���ý��� ����
//------------------------------------------------------------------------------
procedure TUserInfo.OnCmdISMFriendOpen ( Cmd : TCmdMsg );
begin

end;

//------------------------------------------------------------------------------
// ģ�� �ý��� ����
//------------------------------------------------------------------------------
procedure TUserInfo.OnCmdISMFriendClose ( Cmd : TCmdMsg );
begin

end;

//------------------------------------------------------------------------------
// ģ�� �ý��۵�� ������ ���������� Ŭ���̾�Ʈ�� �����Ѵ�.
//------------------------------------------------------------------------------
procedure TUserInfo.OnCmdISMUserInfo ( Cmd : TCmdMsg );
var
    UserName    : String;
    ConnState   : String;
    MapInfo     : String;
    Str         : String;

    UserInfo    : TUserInfo;
begin

    // ���¸޼��� �и�
    Str := GetValidStr3 (Cmd.body,UserName  , ['/']);
    Str := GetValidStr3 (Str     ,ConnState , ['/']);
    Str := GetValidStr3 (Str     ,MapInfo   , ['/']);

    // ������ �޼����� �����Ѵ�.
    UserInfo := Cmd.pInfo ;
    Str      := UserName + '/' + MapInfo;

    // �׽�Ʈ������ �ƴϸ� ���� ���� ���¸� 0���� ������. 2003-07-01 : ������ ������ ������ ������.
    if not BoTestServer then begin
       ConnState := '0';
    end;

    // Ŭ���̾�Ʈ�� �޼��� ����
    //
    UserMgrEngine.InterSendMsg( stClient, 0, UserInfo.GateIdx, UserInfo.UserGateIdx, UserInfo.UserHandle,
                    UserInfo.UserName, UserInfo.Recog, SM_USER_INFO, Str_ToInt(ConnState,0), 0, 0, Str );

end;



end.
