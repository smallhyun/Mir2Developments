////////////////////////////////////////////////////////////////////////////////
// SQL �� �����͸� �д´�.
// �̰��� �Լ����� ���� ������ȯ���� ����� ���� ���۵Ǿ�����
// SQlEngine ������ �ҷ������Ѵ�.
// MakeData:2004-01-29
////////////////////////////////////////////////////////////////////////////////
unit DBSQL;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, ADODB, Grobal2, mudutil;

const
   GABOARD_NOTICE_LINE = 3;
   KIND_NOTICE  = 0;

type
    // SQL �����ͺ��̽�
    TDBSql  = class ( TObject )
    private
        FADOConnection  : TADOConnection;
        FADOQuery       : TADOQuery;
        FAutoConnectable: Boolean;

        FConnFile       : TStringList;
        FConnInfo       : string;
        FFileName       : string;
        FServerName     : string;
        FLastConnTime   : TDateTime;
        FLastConnMsec   : DWord;

        procedure LoadItemFromDB( pItem : pTMarketLoad ; SqlDB : TADOQuery );
        procedure LoadBoardListFromDB( pList : PTGaBoardArticleLoad ; SqlDB : TADOQuery );
    public
        constructor Create;
        destructor Destroy; override;

        function    Connect( ServerName : string ; FileName : String ):Boolean;
        function    ReConnect:Boolean;
        procedure   DisConnect;

        property    AutoConnectable : Boolean read FAutoConnectable write FAutoConnectable;
        function    Connected:Boolean;


        //������ ���� ����

        //�Ǹ� �ø� �������� �� ������ ����(�����δ� �� ����)
        function  LoadPageUserMarket(
                  marketname  : string;
                  sellwho     : string;
                  itemname    : string;
                  itemtype    : integer;
                  itemset     : integer;
                  sellitemlist: TList
                  ): integer;
        //�Ǹſ� �߰�
        function  AddSellUserMarket     (     psellitem : PTMarketLoad): integer;
        //��Ź�������� �˾ƺ���.
        function  ReadyToSell          ( var Readyitem : PTMarketLoad): integer;
        //������ ���.
        function  BuyOneUserMarket      ( var buyitem   : PTMarketLoad): integer;
        //�ڽ��� �ø� ������ �����(�ٽ� ã��)
        function  CancelUserMarket      ( var Cancelitem: PTMarketLoad): integer;
        //�Ǹŵ� ��ǰ�� ������ ȸ����
        function  GetPayUserMarket      ( var GetPayitem: PTMarketLoad): integer;

        // �߰� ��� üũ
        function  ChkAddSellUserMarket   ( pSearchInfo : PTSearchSellItem ; IsSucess : Boolean): integer;
        // ��� ��� üũ
        function  ChkBuyOneUserMarket    ( pSearchInfo : PTSearchSellItem ; IsSucess : Boolean): integer;
        // �M�� ��� üũ
        function  ChkCancelUserMarket    ( pSearchInfo : PTSearchSellItem ; IsSucess : Boolean): integer;
        // ȸ�� ��� üũ
        function  ChkGetPayUserMarket    ( pSearchInfo : PTSearchSellItem ; IsSucess : Boolean): integer;

        // ����Խ���
        function LoadPageGaBoardList ( gname : string; nKind: integer; BoardList: TList ): integer;
        function AddGaBoardArticle (pArticleLoad: PTGaBoardArticleLoad): integer;
        function DelGaBoardArticle (pArticleLoad: PTGaBoardArticleLoad): integer;
        function EditGaBoardArticle (pArticleLoad: PTGaBoardArticleLoad): integer;

    end;
var
    g_DBSQL : TDBSQL;
implementation
    uses
        svMain;

// ������
constructor TDBSql.Create;
begin
   FADOConnection  := TADOConnection.Create( nil );
   FADOQuery       := TADOQuery.Create( nil );

   FConnFile       := TStringList.Create;
   FConnInfo       := '';
   FLastConnTime   := 0;
   FLastConnMSec   := 0;

   FAutoConnectable:= false;
end;

// �Ҹ���
destructor TDBSql.Destroy;
begin
   Disconnect;

   FADOConnection.Free;
   FADOQuery.Free;

   FConnFile.Free;
end;

// ������ ���̽� Ŀ�ؼ�
function TDBSql.Connect( ServerName : string ; FileName : String ):Boolean;
begin
    Result := false;

    FFileName   := FileName;
    FServerName := ServerName;

    // Load ODBC Connection Infomations...
    FConnFile.LoadFromFile( FileName );

    //-------------------------------------------
    // �����̸����� ���� ���´�.
    FConnInfo := FConnFile.Values[ ServerName ];
    //-------------------------------------------

    // Ŀ�ؼ� ����
    if FConnInfo <> '' then
    begin
        // Try Connect...
        FADOConnection.ConnectionString := FConnInfo;
        FADOConnection.LoginPrompt := false;
        FADOConnection.Connected := true;
        Result :=  FADOConnection.Connected;

        if Result = true then
        begin
            // ADO_Query setting...
            FADOQuery.Active := false;
            FADOQuery.Connection := FADOConnection;

            FLastConnTime := Now;

            MainOutMessage('DBSQL ���ӳɹ�.. ');

        end;
    end
    else
    begin
        MainOutMessage(ServerName+' : DBSQL CONNECTION INFO IS NULL!');
    end;

    // �õ��� Ÿ�̸Ӱ� ����
    FlastConnMSec := GetTickCount;

end;

// �ٽ� ������ �õ��Ѵ�.. ���쿡 ���� ������ ������ ��츦 ���
function TDBSql.ReConnect : Boolean;
begin
   Result := false;

   DisConnect ;

//   MainOutMessage('[TestCode]Try to reconnect with DBSQL');

   Result := Connect ( FServerName , FFileName );

   MainOutMessage('DBSQL Reconnected...');
end;

// ���ӵǾ� �ִ��� �˾ƺ���.
function TDBSql.Connected:Boolean;
begin
   Result := FADOConnection.Connected;
end;

// DB ���� ����
procedure TDBSql.DisConnect;
begin

   FAdoQuery.Active := false;
   FADOConnection.Connected := false;

end;

//==============================================================================
// ��Ź�Ǹ� �ý��ۿ� ������ ����� �Լ�
//==============================================================================
procedure TDBSql.LoadItemFromDB( pItem : pTMarketLoad ; SqlDB : TADOQuery );
var
   k           : integer;
   prefix      : string;
begin
   if SqlDB = nil then MainOutMessage('[Exception] SqlDB = nil');

   with SqlDB do
   begin
      pItem.Index             := FieldByName('FLD_SELLINDEX').AsInteger;
      pItem.SellState         := FieldByName('FLD_SELLOK').AsInteger;
      pItem.SellWho           := Trim (FieldByName('FLD_SELLWHO'  ).AsString);
      pItem.ItemName          := Trim (FieldByName('FLD_ITEMNAME' ).AsString);
      pItem.SellPrice         := FieldByName('FLD_SELLPRICE').AsInteger;
      pItem.SellDate          := FormatDateTime('YYMMDDHHNNSS',FieldByName('FLD_SELLDATE' ).AsDateTime);

      //TUserItem
      pItem.UserItem.MakeIndex := FieldByName('FLD_MAKEINDEX').AsInteger;
      pItem.UserItem.Index     := FieldByName('FLD_INDEX').AsInteger;
      pItem.UserItem.Dura      := FieldByName('FLD_DURA').AsInteger;
      pItem.UserItem.DuraMax   := FieldByName('FLD_DURAMAX').AsInteger;
      for k:=0 to 13 do
         pItem.UserItem.Desc[k] := FieldByName('FLD_DESC' + IntToStr(k)).AsInteger;
      pItem.UserItem.ColorR    := FieldByName('FLD_COLORR').AsInteger;
      pItem.UserItem.ColorG    := FieldByName('FLD_COLORG').AsInteger;
      pItem.UserItem.ColorB    := FieldByName('FLD_COLORB').AsInteger;
      prefix := Trim (FieldByName('FLD_PREFIX').AsString);
      StrPCopy (pItem.UserItem.Prefix, prefix);
   end;

end;

//�Ǹ� �ø� �������� �� ������ ����(�����δ� �� ����)
function TDBSql.LoadPageUserMarket (
   marketname  : string;
   sellwho     : string;
   itemname    : string;
   itemtype    : integer;
   itemset     : integer;
   sellitemlist: TList
): integer;
var
   SearchStr   : string;
   pSellItem   : PTMarketLoad;
   i           : integer;
begin
   Result := UMResult_Fail;
   with FADOQuery do
   begin
      if ( itemname <> '' ) then SearchStr := 'EXEC UM_LOAD_ITEMNAME ''' +marketname+''','''+itemname+''''
      else if ( sellwho  <> '') then SearchStr := 'EXEC UM_LOAD_USERNAME ''' +marketname+''','''+sellwho+''''
      else if ( itemset  <> 0 ) then SearchStr := 'EXEC UM_LOAD_ITEMSET ''' +marketname+''','+intToStr(itemset)
      else if ( itemtype >= 0 ) then SearchStr := 'EXEC UM_LOAD_ITEMTYPE '''+marketname+''','+intToStr(itemtype);

      try
         if Active then
            Close;

         SQL.Clear;
         SQL.ADD ( SearchStr );

         if not Active then
            Open;
      except
         MainOutMessage ('Exception) TFrmSql.LoadPageUserMarket -> Open (' + IntToStr(SQL.Count) + ')');
         for i:=0 to SQL.Count-1 do
            MainOutMessage (' :' + SQL[i]);
         Result := UMResult_ReadFail;
         //������(sonmg 2006/02/28)
         ReConnect;
         exit;
      end;

      try
         First;
         for i:=0 to RecordCount-1 do begin
            new (pSellItem);
            LoadItemFromDB( pSellItem , FADOQuery );
            sellitemlist.Add (pSellItem);
            if not EOF then
               Next;
         end;

         if Active then
            Close;
         Result := UMResult_Success;
      except
         MainOutMessage ('Exception) TFrmSql.LoadPageUserMarket -> LoadItemFromDB (' + IntToStr(RecordCount) + ')');
         Result := UMResult_ReadFail;
         if Active then
            Close;
      end;

   end;
end;

//�Ǹſ� �߰�
function TDBSql.AddSellUserMarket (psellitem: PTMarketLoad): integer;
var
   i: integer;
begin
   // ����ѵڿ� �÷��׸� ����ϻ��·� �Ѵ�.
   Result := UMResult_Fail;

   with FADOQuery do begin

      SQL.Clear;
      SQL.Add (   'INSERT INTO TBL_ITEMMARKET (' +
                    'FLD_MARKETNAME,'+
                    'FLD_SELLOK,'+
                    'FLD_ITEMTYPE,'+
                    'FLD_ITEMSET,'+
                    'FLD_ITEMNAME,'+
                    'FLD_SELLWHO,'+
                    'FLD_SELLPRICE,'+
                    'FLD_SELLDATE,'+
//                    'FLD_BUYER,'+
//                    'FLD_BUYDATE,'+
                    'FLD_MAKEINDEX,'+
                    'FLD_INDEX,'+
                    'FLD_DURA,'+
                    'FLD_DURAMAX,'+
                    'FLD_DESC0,'+
                    'FLD_DESC1,'+
                    'FLD_DESC2,'+
                    'FLD_DESC3,'+
                    'FLD_DESC4,'+
                    'FLD_DESC5,'+
                    'FLD_DESC6,'+
                    'FLD_DESC7,'+
                    'FLD_DESC8,'+
                    'FLD_DESC9,'+
                    'FLD_DESC10,'+
                    'FLD_DESC11,'+
                    'FLD_DESC12,'+
                    'FLD_DESC13,'+
                    'FLD_COLORR,'+
                    'FLD_COLORG,'+
                    'FLD_COLORB,'+
                    'FLD_PREFIX'+
                    ')'
                  );
      SQL.Add (   ' Values('''+
                    psellitem.MarketName                    + ''','+
                    IntToStr(MARKET_DBSELLTYPE_READYSELL)   +',' + // ����ϻ��°��Ǿߵ� ����
                    IntToStr(psellitem.MarketType)          + ','+
                    IntToStr(psellitem.SetType)             + ','''+
                    psellitem.ItemName                      + ''',''' +
                    psellitem.SellWho                       + ''',' +
                    IntToStr(psellitem.SellPrice)           + ',' +
                    'GETDATE(),'                            +
                    IntToStr(psellitem.UserItem.MakeIndex)  + ',' +
                    IntToStr(psellitem.UserItem.Index)      + ',' +
                    IntToStr(psellitem.UserItem.Dura)       + ',' +
                    IntToStr(psellitem.UserItem.DuraMax)    + ',' +
                    IntToStr(psellitem.UserItem.Desc[0])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[1])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[2])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[3])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[4])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[5])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[6])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[7])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[8])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[9])    + ',' +
                    IntToStr(psellitem.UserItem.Desc[10])   + ',' +
                    IntToStr(psellitem.UserItem.Desc[11])   + ',' +
                    IntToStr(psellitem.UserItem.Desc[12])   + ',' +
                    IntToStr(psellitem.UserItem.Desc[13])   + ',' +
                    IntToStr(psellitem.UserItem.ColorR)     + ',' +
                    IntToStr(psellitem.UserItem.ColorG)     + ',' +
                    IntToStr(psellitem.UserItem.ColorB)     + ',''' +
                    string(psellitem.UserItem.Prefix)       + '''' +
                    ')'
                  );
      try
         ExecSQL;
         Result := UMResult_Success;
      except
         MainOutMessage ('Exception) TFrmSql.AddSellUserMarket -> ExecSQL');
         for i:=0 to SQL.Count-1 do
            MainOutMessage (' :' + SQL[i]);
      end;

   end;
end;

//�Ǹ� �������� �˾ƺ���.
function TDBSql.ReadyToSell( var Readyitem: PTMarketLoad ): integer;
var
   SearchStr : string;
   i         : integer;
begin
   // ������ �о���̰�
   // ������ ���Ǹ� ���·� �����Ѵ�.
   Result := UMResult_Fail;
   with FADOQuery do begin
      // SearchQuery...
      SearchStr := 'EXEC UM_READYTOSELL_NEW '''+ReadyItem.MarketName+''','''+ReadyItem.SellWho+'''' ;

      try
         if Active then
            Close;

         SQL.Clear;
         SQL.ADD ( SearchStr );

         if not Active then
            Open;
      except
         MainOutMessage ('Exception) TFrmSql.ReadyToSell -> Open');
         for i:=0 to SQL.Count-1 do
            MainOutMessage (' :' + SQL[i]);
         Result := UMResult_ReadFail;
         //������(sonmg 2006/02/28)
         ReConnect;
         exit;
      end;

      try
         //--------UM_READYTOSELL_NEW----------
         if RecordCount >= 0 then begin
            ReadyItem.SellCount := RecordCount;
            Result := UMResult_Success;
         end else begin
            ReadyItem.SellCount := 0;
            Result := UMResult_Fail;
         end;
         //--------UM_READYTOSELL_NEW----------

{
         if RecordCount = 1 then begin
            ReadyItem.SellCount := FieldByName('FLD_COUNT').AsInteger;
            Result := UMResult_Success;
         end else begin
            Result := UMResult_Fail;
         end;
}

         if Active then
            Close;
      except
         MainOutMessage ('Exception) TFrmSql.ReadyToSell -> RecordCount');
         ReadyItem.SellCount := 0;  //UM_READYTOSELL_NEW
         Result := UMResult_Fail;
         if Active then
            Close;
      end;

   end;

end;

//������ ���.
function TDBSql.BuyOneUserMarket( var Buyitem: PTMarketLoad ): integer;
var
   SearchStr : string;
   CheckType : integer;
   ChangeTYpe : integer;
   ItemIndex : integer;
   i : integer;
begin
   // ������ �о���̰�
   // ������ ���Ǹ� ���·� �����Ѵ�.
   Result := UMResult_Fail;
   with FADOQuery do
   begin
      CheckType   := MARKET_DBSELLTYPE_SELL;
      ChangeType  := MARKET_DBSELLTYPE_READYBUY;
      ItemIndex   := BuyItem.Index;
      // SearchQuery...
      SearchStr := 'EXEC UM_LOAD_INDEX '+IntToStr(ItemIndex)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

      SQL.Clear;
      SQL.ADD ( SearchStr );

      try
         if not Active then
            Open;
      except
         MainOutMessage ('Exception) TFrmSql.BuyOnUserMarket -> Open');
         for i:=0 to SQL.Count-1 do
            MainOutMessage (' :' + SQL[i]);
         Result := UMResult_ReadFail;
         //������(sonmg 2006/02/28)
         ReConnect;
         exit;
      end;

      if RecordCount  = 1 then begin
         LoadItemFromDB( @BuyItem.UserItem , FADOQuery );
         Result := UMResult_Success;
      end else begin
         Result := UMResult_Fail;
      end;

      if Active then
         Close;

   end;

end;

//�ڽ��� �ø� ������ �����(�ٽ� ã��)
function TDBSql.CancelUserMarket( var Cancelitem: PTMarketLoad ): integer;
var
    SearchStr  : string;
    CheckType  : integer;
    ChangeTYpe : integer;
    ItemIndex  : integer;
    i          : integer;
begin
    // ������ �о���̰�
    // ������ ����� ���·� �����Ѵ�.
    Result := UMResult_Fail;
    with FADOQuery do
    begin
        CheckType   := MARKET_DBSELLTYPE_SELL;
        ChangeType  := MARKET_DBSELLTYPE_READYCANCEL;
        ItemIndex   := Cancelitem.Index;
        // SearchQuery...
        SearchStr := 'EXEC UM_LOAD_INDEX '+IntToStr(ItemIndex)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
           if not Active then
              Open;
        except
            MainOutMessage ('Exception) TFrmSql.BuyOnUserMarket -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            //������(sonmg 2006/02/28)
            ReConnect;
            exit;
        end;

        if RecordCount  = 1 then
        begin
            LoadItemFromDB( @CancelItem.UserItem , FADOQuery );
            Result := UMResult_Success;
        end
        else
        begin
            Result := UMResult_Fail;
        end;

        if Active then
           Close;

    end;


end;

//�ݾ��� ȸ��
function TDBSql.GetPayUserMarket ( var GetPayitem: PTMarketLoad ): integer;
var
    SearchStr   : string;
    CheckType   : integer;
    ChangeTYpe  : integer;
    ItemIndex   : integer;
    i           : integer;
begin
    // ������ �о���̰�
    // ������ ��ȸ�� ���·� �����Ѵ�.

    Result := UMResult_Fail;
    with FADOQuery do
    begin
        CheckType   := MARKET_DBSELLTYPE_BUY;
        ChangeType  := MARKET_DBSELLTYPE_READYGETPAY;
        ItemIndex   := GetPayItem.Index;
        // SearchQuery...
        SearchStr := 'EXEC UM_LOAD_INDEX '+IntToStr(ItemIndex)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
           if not Active then
              Open;
        except
            MainOutMessage ('Exception) TFrmSql.BuyOnUserMarket -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            //������(sonmg 2006/02/28)
            ReConnect;
            exit;
        end;

        if RecordCount  = 1 then
        begin
            LoadItemFromDB( @GetPayItem.UserItem , FADOQuery );
            Result := UMResult_Success;
        end
        else
        begin
            Result := UMResult_Fail;
        end;

        if Active then
           Close;

    end;
end;

// �߰� ��� üũ
function TDBSql.ChkAddSellUserMarket( pSearchInfo :PTSearchSellItem ; IsSucess : Boolean): integer;
var
    SearchStr   : string;
    CheckType   : integer;
    ChangeTYpe  : integer;
    MakeIndex   : integer;
    sellwho     : string;
    marketname  : string;
    i           : integer;
begin
    // ���������� �ǸŵȰ��̶�� ����� �÷��׸� ���� �Ǹ� �÷��׷� ����
    // ���������̶�� ��񿡼� ����

    Result := UMResult_Fail;
    with FADOQuery do
    begin
        CheckType   := MARKET_DBSELLTYPE_READYSELL;
        if IsSucess then
            ChangeType  := MARKET_DBSELLTYPE_SELL
        else
            ChangeType  := MARKET_DBSELLTYPE_DELETE;

        MakeIndex   := pSearchInfo.MakeIndex;
        sellwho     := pSearchInfo.Who;
        marketname  := pSearchInfo.MarketName;
        // SearchQuery...
        SearchStr := 'EXEC UM_CHECK_MAKEINDEX '''+MarketName+''','''+SellWho+''','+IntToStr(MakeIndex)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
            ExecSql;
        except
            MainOutMessage ('Exception) TFrmSql.ChkAddSellUserMarket -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            exit;
        end;

        // Check RESULT...
{        if RecordCount = 0 then
            Result := UMResult_Success
        else
            Result := UMResult_Fail;
}
        Result := UMResult_Success;
        if Active then
           Close;

    end;

end;
// ��� ��� üũ
function TDBSql.ChkBuyOneUserMarket( pSearchInfo :PTSearchSellItem ; IsSucess : Boolean): integer;
var
    SearchStr   : string;
    CheckType   : integer;
    ChangeTYpe  : integer;
    Index       : integer;
    sellwho     : string;
    marketname  : string;
    i           : integer;
begin
    // ���������� �����ٸ� ��񿡼� ����
    //  ���������̶�� ����÷��׸� ���� �Ǹ� �÷��׷� ����

    Result := UMResult_Fail;
    with FADOQuery do
    begin
        CheckType   := MARKET_DBSELLTYPE_READYBUY;
        if IsSucess then
            ChangeType  := MARKET_DBSELLTYPE_BUY
        else
            ChangeType  := MARKET_DBSELLTYPE_SELL;

        Index       := pSearchInfo.SellIndex;
        sellwho     := pSearchInfo.Who;
        marketname  := pSearchInfo.MarketName;
        // SearchQuery...
        SearchStr := 'EXEC UM_CHECK_INDEX_BUY '''+MarketName+''','''+SellWho+''','+IntToStr(Index)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
            ExecSql;
        except
            MainOutMessage ('Exception) TFrmSql.BuyOnUserMarket -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            exit;
        end;

        // Check RESULT...
        Result := UMResult_Success;
        if Active then
           Close;

    end;

end;
// �M�� ��� üũ
function TDBSql.ChkCancelUserMarket( pSearchInfo :PTSearchSellItem ; IsSucess : Boolean): integer;
var
    SearchStr   : string;
    CheckType   : integer;
    ChangeTYpe  : integer;
    Index       : integer;
    sellwho     : string;
    marketname  : string;
    i           : integer;
begin
    // ���������� ��� �Ǿ��ٸ� ��񿡼� ����
    // ���������̶�� ��� �÷��׸� ���� �Ǹ� �÷��׷� ����

    Result := UMResult_Fail;
    with FADOQuery do
    begin
        CheckType   := MARKET_DBSELLTYPE_READYCANCEL;
        if IsSucess then
            ChangeType  := MARKET_DBSELLTYPE_DELETE
        else
            ChangeType  := MARKET_DBSELLTYPE_SELL;

        Index       := pSearchInfo.SellIndex;
        sellwho     := pSearchInfo.Who;
        marketname  := pSearchInfo.MarketName;

        // SearchQuery...
        SearchStr := 'EXEC UM_CHECK_INDEX '''+MarketName+''','''+SellWho+''','+IntToStr(Index)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
            ExecSql;
        except
            MainOutMessage ('Exception) TFrmSql.BuyOnUserMarket -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            exit;
        end;

        // Check RESULT...
        Result := UMResult_Success;
        if Active then
           Close;

    end;


end;
// ȸ�� ��� üũ
function TDBSql.ChkGetPayUserMarket( pSearchInfo :PTSearchSellItem ; IsSucess : Boolean): integer;
var
    SearchStr   : string;
    CheckType   : integer;
    ChangeTYpe  : integer;
    Index       : integer;
    sellwho     : string;
    marketname  : string;
    i           : integer;
begin
    // �������� ȸ���� ��쿡�� ��񿡼� ����
    // ������ ���� ��쿡�� ����÷��׸� �ǸŵǾ������� ����

    Result := UMResult_Fail;
    with FADOQuery do
    begin
        CheckType   := MARKET_DBSELLTYPE_READYGETPAY;
        if IsSucess then
            ChangeType  := MARKET_DBSELLTYPE_DELETE
        else
            ChangeType  := MARKET_DBSELLTYPE_BUY;

        Index       := pSearchInfo.SellIndex;
        sellwho     := pSearchInfo.Who;
        marketname  := pSearchInfo.MarketName;
        // SearchQuery...
        SearchStr := 'EXEC UM_CHECK_INDEX '''+MarketName+''','''+SellWho+''','+IntToStr(Index)+','+IntToStr( CheckType ) +','+IntToStr(ChangeType ) ;

        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
            ExecSql;
        except
            MainOutMessage ('Exception) TFrmSql.BuyOnUserMarket -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            exit;
        end;

        // Check RESULT...
        Result := UMResult_Success;
        if Active then
           Close;

    end;


end;

//==============================================================================
// ��� �Խ��ǿ� ������ ����� �Լ�
//==============================================================================
procedure TDBSql.LoadBoardListFromDB( pList : PTGaBoardArticleLoad ; SqlDB : TADOQuery );
var
    content : array [0..500] of char;
begin

    with SqlDB do
    begin
      pList.AgitNum           := FieldByName('FLD_AGITNUM').AsInteger;
      pList.GuildName         := Trim (FieldByName('FLD_GUILDNAME').AsString);
      pList.OrgNum            := FieldByName('FLD_ORGNUM').AsInteger;
      pList.SrcNum1           := FieldByName('FLD_SRCNUM1').AsInteger;
      pList.SrcNum2           := FieldByName('FLD_SRCNUM2').AsInteger;
      pList.SrcNum3           := FieldByName('FLD_SRCNUM3').AsInteger;
      pList.UserName          := Trim (FieldByName('FLD_USERNAME'  ).AsString);
      FillChar(pList.Content, sizeof(pList.Content), #0);
      StrPLCopy (pList.Content, Trim (FieldByName('FLD_CONTENT' ).AsString), sizeof(pList.Content)-1);
    end;

end;

{----------------------����Խ���------------------------}

function TDBSql.LoadPageGaBoardList ( gname : string; nKind: integer; BoardList: TList ): integer;
var
    SearchStr  : string;
    pArticle   : PTGaBoardArticleLoad;
    i          : integer;
begin
    Result := UMResult_Fail;
    with FADOQuery do
    begin
        if gname = '' then exit;

        //-------------------------------
        //�������� �ε�...
        SearchStr := 'EXEC GABOARD_LOAD ''' + gname + ''',' + IntToStr(KIND_NOTICE);
        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
           if not Active then
              Open;
        except
            MainOutMessage ('Exception) TDBSql.LoadPageGaBoardList -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            //������(sonmg 2006/02/28)
            ReConnect;
            exit;
        end;

        First;
        // �������� ���μ�...
        if RecordCount <= GABOARD_NOTICE_LINE then begin
           for i:=0 to RecordCount-1 do begin
               new (pArticle);
               LoadBoardListFromDB( pArticle , FADOQuery );
               BoardList.Add (pArticle);
               if not EOF then
                  Next;
           end;
           // ��� �ִ� �������� ä���.
           for i:=RecordCount to GABOARD_NOTICE_LINE-1 do begin
               new (pArticle);
               pArticle.AgitNum := 0;
               pArticle.OrgNum := 0;
               pArticle.SrcNum1 := 0;
               pArticle.SrcNum2 := 0;
               pArticle.SrcNum3 := 0;
               pArticle.Kind := KIND_NOTICE;
               pArticle.UserName := '�л�����';
               pArticle.Content := '�л����ŵ�λ�ò���Ϊ��';
               BoardList.Add (pArticle);
           end;
        end else begin // ���������� 3�� ������ ���������� 3����...
           for i:=0 to GABOARD_NOTICE_LINE-1 do begin
               new (pArticle);
               LoadBoardListFromDB( pArticle , FADOQuery );
               BoardList.Add (pArticle);
               if not EOF then
                  Next;
           end;
        end;

        if Active then
           Close;

        //-------------------------------
        //�Ϲ� �Խù� �ε�...
        SearchStr := 'EXEC GABOARD_LOAD ''' + gname + ''',' + IntToStr(nKind);
        SQL.Clear;
        SQL.ADD ( SearchStr );

        try
           if not Active then
              Open;
        except
            MainOutMessage ('Exception) TDBSql.LoadPageGaBoardList -> Open');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
            Result := UMResult_ReadFail;
            //������(sonmg 2006/02/28)
            ReConnect;
            exit;
        end;

        First;
        for i:=0 to RecordCount-1 do begin
            new (pArticle);
            LoadBoardListFromDB( pArticle , FADOQuery );
            BoardList.Add (pArticle);
            if not EOF then
               Next;
        end;

        if Active then
           Close;

        Result := UMResult_Success;
    end;
end;

function TDBSql.AddGaBoardArticle (pArticleLoad: PTGaBoardArticleLoad): integer;
var
    i: integer;
begin
    Result := UMResult_Fail;

    with FADOQuery do begin
//INSERT INTO TBL_GABOARD Values(2, '�ֱ⹮��', 21, 0, 0, 0, 1, '�ֱ�', '�ȳ��ϼ���!!!' )
        SQL.Clear;
        SQL.Add (   'INSERT INTO TBL_GABOARD Values('+
                    IntToStr(pArticleLoad.AgitNum)          + ','''+
                    pArticleLoad.GuildName                  + ''','+
                    IntToStr(pArticleLoad.OrgNum)           + ','+
                    IntToStr(pArticleLoad.SrcNum1)          + ','+
                    IntToStr(pArticleLoad.SrcNum2)          + ','+
                    IntToStr(pArticleLoad.SrcNum3)          + ','+
                    IntToStr(pArticleLoad.Kind)             + ','''+
                    pArticleLoad.UserName                   + ''',''' +
                    string(pArticleLoad.Content)            + '''' +
                    ')'
                );
        try
            ExecSQL;
            Result := UMResult_Success;
        except
            MainOutMessage ('Exception) TDBSql.AddGaBoardArticle -> ExecSQL');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
        end;

    end;

end;

function TDBSql.DelGaBoardArticle (pArticleLoad: PTGaBoardArticleLoad): integer;
var
   SearchStr  : string;
   i: integer;
begin
   Result := UMResult_Fail;

   if pArticleLoad = nil then exit;
   if pArticleLoad.GuildName = '' then exit;
   if pArticleLoad.UserName = '' then exit;

   if pArticleLoad.AgitNum = 0 then begin
      with FADOQuery do begin
         SearchStr := 'EXEC GABOARD_DEL ''' + pArticleLoad.GuildName + ''',' +
                        IntToStr(pArticleLoad.OrgNum) + ',' +
                        IntToStr(pArticleLoad.SrcNum1) + ',' +
                        IntToStr(pArticleLoad.SrcNum2) + ',' +
                        IntToStr(pArticleLoad.SrcNum3);
         SQL.Clear;
         SQL.ADD ( SearchStr );

         try
            ExecSQL;
            Result := UMResult_Success;
         except
            MainOutMessage ('Exception) TDBSql.DelGaBoardArticle -> ExecSQL');
            for i:=0 to SQL.Count-1 do
               MainOutMessage (' :' + SQL[i]);
         end;

      end;
   end else begin
      with FADOQuery do begin
         //���� ��� �Խ��� �Խù� ��� ����
         SearchStr := 'EXEC GABOARD_DELALL ' + IntToStr(pArticleLoad.AgitNum);
         SQL.Clear;
         SQL.ADD ( SearchStr );

         try
            ExecSQL;
            Result := UMResult_Success;
         except
            MainOutMessage ('Exception) TDBSql.DelGaBoardArticle(ALL) -> ExecSQL');
            for i:=0 to SQL.Count-1 do
               MainOutMessage (' :' + SQL[i]);
         end;

      end;
   end;

end;

function TDBSql.EditGaBoardArticle (pArticleLoad: PTGaBoardArticleLoad): integer;
var
    i: integer;
begin
    Result := UMResult_Fail;

    with FADOQuery do begin
//UPDATE TBL_GABOARD SET FLD_CONTENT = '��������' WHERE FLD_GUILDNAME = '���ĸ�' AND
// FLD_ORGNUM = 1 AND FLD_SRCNUM1 = 0 AND FLD_SRCNUM2 = 0 AND FLD_SRCNUM3 = 0
        SQL.Clear;
        SQL.Add (   'UPDATE TBL_GABOARD SET FLD_CONTENT = ''' +
                    string(pArticleLoad.Content) + ''' WHERE ' +
                    'FLD_GUILDNAME = ''' + pArticleLoad.GuildName + ''' AND ' +
                    'FLD_ORGNUM = ' + IntToStr(pArticleLoad.OrgNum) + ' AND ' +
                    'FLD_SRCNUM1 = ' + IntToStr(pArticleLoad.SrcNum1) + ' AND ' +
                    'FLD_SRCNUM2 = ' + IntToStr(pArticleLoad.SrcNum2) + ' AND ' +
                    'FLD_SRCNUM3 = ' + IntToStr(pArticleLoad.SrcNum3)
                  );

        try
            ExecSQL;
            Result := UMResult_Success;
        except
            MainOutMessage ('Exception) TDBSql.EditGaBoardArticle -> ExecSQL');
            for i:=0 to SQL.Count-1 do
                MainOutMessage (' :' + SQL[i]);
        end;

    end;

end;


end.
