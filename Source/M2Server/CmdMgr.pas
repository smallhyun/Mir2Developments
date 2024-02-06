unit CmdMgr ;


interface

uses
    Classes,Grobal2 , sysUtils , windows , syncobjs , EDcode , HUtil32;


type
    TSendTarget = (stClient , stInterServer , stOtherServer , stDbServer , stFunc);

    // ��ɾ� ���ڵ� ...........................................................
    TCmdMsg  = Record
        CmdNum      : integer;
        TagetSvrIdx : integer;
        GateIdx     : integer;
        UserGateIdx : integer;
        Userhandle  : integer;
        SendTarget  : TSendTarget;
        Msg         : TDefaultMessage;
        UserName    : String;
        body        : String;
        pInfo       : pointer;
    end;
    PTCmdMsg = ^TCmdMsg;

    // ��ɾ� interface ........................................................
    ICommand = class ( TObject)
    public
        constructor Create; virtual;
        destructor  Destroy; override;
        // ��ɾ� ��������� �߻��ϴ��̺�Ʈ
        procedure   OnCmdChange( var Msg : TCmdMsg ) ; virtual;
        // �׽�Ʈ�� ���� �޼����� �ܺη� ���̰� ��
        procedure   ErrMsg( Msg : String );

    end;

    // ��ɾ� �޴��� ...........................................................
    TCmdMgr  = class ( ICommand )
    private
        FItems              : TList;             // ��ɾ� ����Ʈ

        FDBBuffer           : String;            // DB ���� �� ������
        FDBBufferBack       : String;            // DB ���� �� ������ �����
        FDBList             : TStringList;       // DB ���� �� ��ɾ �����س���
        FInterCS            : TCriticalSection;
        FExternCS           : TCriticalSection;

        // ���� ��ɾ� ���� ����
        procedure  RemoveAll;

        procedure   SendToClient2     ( Msg : TCmdMsg );    // �׽�Ʈ ��ƾ
        procedure   SendToClient      ( Msg : TCmdMsg );    // Ŭ���̾�Ʈ�� ����
        procedure   SendToInterServer ( Msg : TCmdMsg );    // ���� ������ ����
        procedure   SendToOtherServer ( Msg : TCmdMsg );    // �ܺ� ������ ����
        procedure   SendToDbServer    ( Msg : TCmdMsg );    // DB ������ ����

        // ���۸� ������.
        procedure   DivideBuffer;
        // DB���� ���۵� ��ɾ �м��Ѵ�.
        procedure   PatchDBBuffer;


    public
        constructor Create; override;
        destructor  Destroy; override;

        // ��ɾ� ��������� �߻��ϴ��̺�Ʈ
//        procedure   OnCmdChange( var Msg : TCmdMsg ) ; virtual;
        // ���μ����ý������� �޼��� ����
        procedure   SendMsg( Msg : TCmdMsg ); virtual;

        // DB���Ͽ��� ��ɾ ���������� ���۳־��ִ� �̺�Ʈ
        procedure   OnDBRead( ReadBuffer :String );

        // ���� ��ɾ ť���� ����
        procedure   SendMsgQueue (
                        SendTarget  : TSendTarget;
                        TargetSvrIdx: Integer;
                        GateIdx     : Integer;
                        UserGateIdx : Integer;
                        UserHandle  : Integer;
                        UserName    : String;
                        msg         : TDefaultMessage;
                        body        : String
                        );
        // ���� ��ɾ ť���� ����
        procedure   SendMsgQueue1(
                        SendTarget  : TSendTarget;
                        TargetSvrIdx: Integer;
                        GateIdx     : Integer;
                        UserGateIdx : Integer;
                        UserHandle  : Integer;
                        UserName    : String;
                        Recog       : Integer;
                        Ident       : word;
                        Param       : word;
                        Tag         : word;
                        Series      : word;
                        Body        : String
                        );

        // ��ɾ� ť�� �ִ� ������ ������
        procedure   RunMsg;
    end;
    PTCmdMgr = ^TCmdMgr;
var
    g_DbUse : Boolean;

implementation
uses
    svMain , RunDB;


//------------------------------------------------------------------------------
// ������ ����
//------------------------------------------------------------------------------
constructor ICommand.Create;
begin
    inherited;
end;

//------------------------------------------------------------------------------
// �Ҹ��� ����
//------------------------------------------------------------------------------
destructor ICommand.Destroy;
begin
    inherited;

end;

//------------------------------------------------------------------------------
// �޼��� ���۽ÿ� ���ο��� �Ҹ��� ���� ó���Լ� : �����Լ��� ����
//------------------------------------------------------------------------------
procedure ICommand.OnCmdChange( var Msg : TCmdMsg ) ;
begin
    // ��ӹ��� ������ ��ɾ� ó���� ������ ��� �Ѵ�....

end;

//------------------------------------------------------------------------------
// �ҽ� ������ ���� �޼��� ����
//------------------------------------------------------------------------------
procedure ICommand.ErrMsg( Msg : String );
begin
    // �޸𿡴� �ϵ� ǥ���Ѵ�. ���� ȭ���̵ ������ �� �ְ� �Ѵ�.
    MainOutMessage ( Msg );

end;

//------------------------------------------------------------------------------
// ������ ����
//------------------------------------------------------------------------------
constructor TCmdMgr.Create;
begin
    inherited ;
    FItems := TList.Create;
    FDBList:= TStringList.Create;

    FInterCS  := TCriticalSection.Create;
    FExternCS := TCriticalSection.Create;
end;

//------------------------------------------------------------------------------
// �Ҹ��� ����
//------------------------------------------------------------------------------
destructor TCmdMgr.Destroy;
begin
    inherited;

    RemoveAll;
    FItems.Free;

    FDBList.Clear;
    FDBList.Free;
    FInterCS.Free;
    FExternCS.Free;
end;

//------------------------------------------------------------------------------
//  ���� ����Ʈ�� ����� ��ɾ���� ���� �����Ѵ�.
//------------------------------------------------------------------------------
procedure TCmdMgr.RemoveAll;
var
    i       : integer;
    pItem   : PTCmdMsg;
begin


    for i := 0 to FItems.Count -1 do
    begin
        pItem := FItems[i];
        if ( pItem <> nil ) then
            Dispose ( pItem );
    end;

    FItems.Clear;


end;

//------------------------------------------------------------------------------
// ��� ó���Ǵ� �޼��� ����
//------------------------------------------------------------------------------
procedure TCmdMgr.SendMsg( Msg : TCmdMsg );
begin
     case Msg.SendTarget of
      stClient        : SendToClient      ( Msg );
      stInterServer   : SendToInterServer ( Msg );
      stOtherServer   : SendToOtherServer ( Msg );
      stDbServer      : SendToDbServer    ( Msg );
     end;
end;

//------------------------------------------------------------------------------
//  Ŭ���̾�Ʈ�� �޼��� ������ �׽�Ʈ �ϱ����� �ڵ� ȭ�鿡 ������
//------------------------------------------------------------------------------
procedure TCmdMgr.SendToClient2( Msg : TCmdMsg );
var
    str     : string;
begin
    str :=
    '['+IntToStr( Msg.Msg.Ident ) + ']'+
    '['+IntToStr( Msg.Msg.Param ) + ']'+
    '['+IntToStr( Msg.Msg.Tag   ) + ']'+
    '['+IntToStr( Msg.Msg.Series) + ']<'+
    Msg.body + '>';

    Msg.Msg.Ident   := SM_SYSMESSAGE ;
    Msg.Msg.Param   := MakeWord(219, 255);
    Msg.Msg.Tag     := 0;
    Msg.Msg.Series  := 1;
    Msg.body        := EncodeString ( str );

    SendToClient( Msg);
end;


//------------------------------------------------------------------------------
//  Ŭ���̾�Ʈ�� �޼��� ����
//------------------------------------------------------------------------------
procedure TCmdMgr.SendToClient( Msg : TCmdMsg );
var
   packetlen: integer;
   header: TMsgHeader;
   pbuf: PAnsiChar;
   EncodeBody   : String;
begin

    pbuf := nil;


    // Exit Codes...
    if Msg.Userhandle = 0 then Exit;


    // Make Header...
    header.Code         := integer($aa55aa55);
    header.SNumber      := Msg.Userhandle;
    header.UserGateIndex:= Msg.UserGateIdx;
    header.Ident        := GM_DATA;

    // �߰� ��ɾ ������
    if Msg.body <> '' then
    begin
         EncodeBody     := EncodeString(Msg.Body);
         header.Length  := sizeof(TDefaultMessage) + Length(EncodeBody) + 1;
         packetlen      := sizeof(TMsgHeader) + header.Length;
         GetMem (pbuf, packetlen + 4);
         Move (packetlen, pbuf^, 4);
         Move (header, (@pbuf[4])^, sizeof(TMsgHeader));
         Move (Msg.Msg, (@pbuf[4+sizeof(TMsgHeader)])^, sizeof(TDefaultMessage));
         Move ((@EncodeBody[1])^, (@pbuf[4+sizeof(TMsgHeader)+sizeof(TDefaultMessage)])^, Length(EncodeBody)+1);
    end
    else // �߰� ��ɾ ������
    begin
         header.Length  := sizeof(TDefaultMessage);
         packetlen      := sizeof(TMsgHeader) + header.Length;
         GetMem (pbuf, packetlen + 4);
         Move (packetlen, pbuf^, 4);
         Move (header, (@pbuf[4])^, sizeof(TMsgHeader));
         Move (Msg.Msg, (@pbuf[4+sizeof(TMsgHeader)])^, sizeof(TDefaultMessage));
    end;

    fInterCS.Enter;
    try
    // Gate Index = ����Ʈ ���ӹ�ȣ
       RunSocket.SendCmdSocket (Msg.GateIdx, pbuf);

    finally
        fInterCS.Leave;
        // MainOutMessage ('CmdMgr Exception SendSocket..');
    end;



end;

//------------------------------------------------------------------------------
// ���������� ó����
//------------------------------------------------------------------------------
procedure TCmdMgr.SendToInterServer( Msg : TCmdMsg );
begin
   OnCmdChange(Msg);
end;

//------------------------------------------------------------------------------
// �ٸ� ������ �޼��� ����
//------------------------------------------------------------------------------
procedure TCmdMgr.SendToOtherServer( Msg : TCmdMsg );
var
    str : string;
begin

    str := Msg.UserName +'/' + Msg.body;
    // TO DO : Need Send Message To Other Server
    // �ܺ������ε� ������
    FInterCS.Enter;
    try
        UserEngine.SendInterMsg (Msg.CmdNum, ServerIndex, str);
    finally
    FInterCS.Leave;
    end;

    // ���������η� �ѹ� ������ //Msg.TagetSvrIdx
    SendMsgQueue( stInterServer , ServerIndex , 0,0,0, Msg.UserName , Msg.msg , Msg.body );

end;

//------------------------------------------------------------------------------
// DB ������ �޼��� ����
//------------------------------------------------------------------------------
procedure TCmdMgr.SendToDBServer( Msg : TCmdMsg );
var
    str : string;
begin

    str := EncodeMessage (Msg.Msg)+Msg.UserName +'/' + Msg.body;


    FInterCS.Enter;
    try
        FrontEngine.AddDBData (str);
    finally
        FInterCS.Leave;
    end;


    // TO DO : Need Send Message To DB Server
//    while g_DbUse do Sleep(1);
//    SendRDBSocket (0, str);


end;

//------------------------------------------------------------------------------
// ť�� ����Ǵ� �޼��� ����
//------------------------------------------------------------------------------
procedure TCmdMgr.SendMsgQueue(
        SendTarget  : TSendTarget;
        TargetSvrIdx: Integer;
        GateIdx     : Integer;
        UserGateIdx : Integer;
        UserHandle  : Integer;
        UserName    : String;
        msg         : TDefaultMessage;
        body        : String
);
var
    pItem : PTCmdMsg;
begin


    new ( pItem );

    pItem^.CmdNum       := msg.Ident;

    pItem^.SendTarget   := SendTarget;
    pItem^.TagetSvrIdx  := TargetSvrIdx;
    pItem^.GateIdx      := GateIdx;
    pItem^.UserGateIdx  := UserGateIdx;
    pItem^.Userhandle   := UserHandle;
    pItem^.UserName     := UserName;
    pItem^.msg          := msg;
    pItem^.body         := Body;
    pItem^.pInfo        := nil;

    FItems.Add( pItem );


end;

procedure TCmdMgr.SendMsgQueue1(
        SendTarget  : TSendTarget;
        TargetSvrIdx: Integer;
        GateIdx     : Integer;
        UserGateIdx : Integer;
        UserHandle  : Integer;
        UserName    : String;
        Recog       : Integer;
        Ident       : word;
        Param       : word;
        Tag         : word;
        Series      : word;
        Body        : String );
var
    pItem : PTCmdMsg;
begin

    new ( pItem );
    //
    pItem^.msg.Recog := Recog;
    pItem^.msg.Ident := Ident;
    pItem^.msg.Param := Param;
    pItem^.msg.Tag   := Tag;
    pItem^.msg.Series:= Series;

    //
    pItem^.SendTarget   := SendTarget;
    pItem^.CmdNum       := Ident;
    pItem^.TagetSvrIdx  := TargetSvrIdx;
    pItem^.GateIdx      := GateIdx;
    pItem^.UserGateIdx  := UserGateIdx;
    pItem^.UserHandle   := UserHandle;
    pItem^.UserName     := UserName;
    pItem^.body         := Body;
    pItem^.pInfo        := nil;

    FItems.Add( pItem );


end;



//------------------------------------------------------------------------------
// ť�� ����� �޼����� ó����
//------------------------------------------------------------------------------
procedure TCmdMgr.RunMsg;
var
    i       : integer;
    Count   : integer;
    pInfo   : PTCmdMsg;
    TempCmdNum : integer;
begin
    TempCmdNum := 0;
    // DB���� �о���ΰ��� ��ɾ�� ��ȯ�Ѵ�.
    try
    PatchDBBuffer;
    except
      on E: Exception do ErrMsg( '[Exception] PatchFBBuffer : '+E.Message);
    end;

    Count := FItems.Count ;
    // ����Ʈ�� �տ��� ���� ó���Ѵ�.
    // ���൵�� �ٽ� ����Ʈ�� ���ϼ� ������ �̰��� ������ ó���� �ϵ����Ѵ�.
    For i := 0 To Count -1 do
    begin

        FInterCS.Enter;
        try
            pInfo := nil;
            pInfo := FItems[0];
            FItems.Delete(0);
        finally
            FInterCS.Leave;
        end;

        if ( pInfo <> nil ) then
        begin
            try
            TempCmdNum := pInfo^.CmdNum;
            SendMsg( pInfo^ );

            except
            on E: Exception do ErrMsg( 'FT_EXCEPTION:['+IntToStr(TempCmdNum)+']:'+E.Message);
            end;
            dispose( pInfo );
        end;
    end;

//    FCriticalSection.Leave;

end;

//------------------------------------------------------------------------------
// DB ���Ͽ��� ��ɾ �����ϸ� �̰��� �̺�Ʈ�� �ҷ���
//------------------------------------------------------------------------------
procedure TCmdMgr.OnDBRead( ReadBuffer :String );
begin
    try
    FExternCS.Enter;
        FDBBuffer := FDBBuffer + ReadBuffer;
    finally
    FExternCS.Leave;
    end;

end;

procedure TCmdMgr.DivideBuffer;
var
    EndPosition : integer;
    DataLength  : Integer;
    TempData    : String;
begin
    try
    FExternCS.Enter;
        FDBBufferBack := FDBBufferBack+ FDBBuffer;
        FDBBuffer := '';
    finally
    FExternCS.Leave;
    end;
    // DB ���� �� �����͸� ��������(!) �������� �ڸ���.
    // ���ϵ����ʹ� �߰��� ����� �����Ƿ� ���۸� �������� �ʴ´�.
    while true do
    begin

        EndPosition := Pos ('!', FDBBufferBack );
        if EndPosition > 0 then
        begin
            TempData := FDBBufferBack;
            DataLength  := length(TempData);

            Delete(FDBBufferBack,1,EndPosition );
            Delete(TempData,EndPosition + 1 , DataLength);

//            FExternCS.Enter;
//            try
            FDBList.Add( TempData );
//            finally
//                FExternCS.Leave;
//            end;

        end
        else Break;

    end;

end;
//------------------------------------------------------------------------------
// DB ��ɾ �м��Ѵ�.
//------------------------------------------------------------------------------
procedure TCmdMgr.PatchDBBuffer;
var
    Str         : String;
    Data        : String;
    ListCount   : Integer;
    len         : Integer;
    certify     : String;
    head        : String;
    Body        : String;
    msg         : TDefaultMessage;
    rmsg        : String;
    i           : Integer;
    username    : string;
    sendcmdnum  : string;
    EndStr      : string;
begin
    //���۸� ����������
    DivideBuffer;

    ListCount := FDBList.Count ;
    // ���۰� ����.
    if ListCount = 0 then Exit;

    for i := 0 to ListCount -1 do
    begin
        // ��ó���� ���� ��
//        FInterCS.Enter;

//        try
            Str := FDBList[0];
            FDBList.Delete(0);
//        finally
//            FInterCS.Leave;
//        end;

        // ���۰� �����ϸ�
        if str <> '' then
        begin
            data := '';
            // �յ� �⺻ ��ɾ �и��ϰ�
            str := ArrestStringEx (str, '#', '!', data);

            if data <> '' then
            begin
                data := GetValidStr3 (data, certify, ['/']);
                len := Length (data);

                // certify �� 0�ΰ��� ģ�� ���� �ý��� �ƴϸ� ���� �ý���
                if ( Str_ToInt(certify,0) = 0) then
                begin
                  // �⺻ ��������� �ȵȴ�. ��� ��ɾ �߰� ������ ����
                  if len <> DEFBLOCKSIZE then
                  begin
                     head := Copy (data, 1, DEFBLOCKSIZE);
                     body := Copy (data, DEFBLOCKSIZE+2, Length(data)-DEFBLOCKSIZE - 7);

                     msg  := DecodeMessage ( head );
                     rmsg := DecodeString  ( body ) ;

                     rmsg := GetValidStr3 ( rmsg   , username   , ['/']);
                     rmsg := GetValidStr3 ( rmsg   , sendcmdnum , ['/']);

                     // �����̸��� ��� ������.
                     if username <> '' then
                        SendMsgQueue ( stInterServer , 0 , 0 , 0, 0,username , msg , rmsg );
                  end;
                end; //if Str_ToInt(...
            end; // if Data <> '' ...
        end; // if str <> '' ...
    end; // For i := ...
end;

//------------------------------------------------------------------------------
// �޼��� ���۽ÿ� ���ο��� �Ҹ��� ���� ó���Լ� : �����Լ��� ����
//------------------------------------------------------------------------------
{
procedure TCmdMgr.OnCmdChange( var Msg : TCmdMsg ) ;
begin
    // ��ӹ��� ������ ��ɾ� ó���� ������ ��� �Ѵ�....

end;
}


end.
