unit SqlEngn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, ObjBase, Grobal2,
  M2Share, DBSQL ;

const
   // GAME --> DB
   LOADTYPE_REQGETLIST      = 100;  // ������ ����Ʈ�� ��û�Ѵ�.
   LOADTYPE_REQBUYITEM      = 101;  // ������ ��⸦ ��û�Ѵ�.
   LOADTYPE_REQSELLITEM     = 102;  // ������ ���
   LOADTYPE_REQGETPAYITEM   = 103;  // ��ȸ��
   LOADTYPE_REQCANCELITEM   = 104;  // ���� ����� ������ ���
   LOADTYPE_REQREADYTOSELL  = 105;  // ��Ź�������� �˾ƺ��°�
   LOADTYPE_REQCHECKTODB    = 106;  // ������ ���� ���� ��������.

   // DB --> GAME
   LOADTYPE_GETLIST         = 200;  // ������ ����Ʈ ����
   LOADTYPE_BUYITEM         = 201;  // �������� ���.
   LOADTYPE_SELLITEM        = 202;  // �������� ���
   LOADTYPE_GETPAYITEM      = 203;  // ��ȸ��
   LOADTYPE_CANCELITEM      = 204;  // ���� ����� ������ ���
   LOADTYPE_READYTOSELL     = 205;  // ��Ź�������� �˾ƺ���.

   //--------����Խ���(sonmg)--------
   KIND_NOTICE  = 0;
   KIND_GENERAL = 1;
   KIND_ERROR   = 255;

   // GAME --> DB
   GABOARD_REQGETLIST      = 500;   // ����Խ��� ����Ʈ ��û.
   GABOARD_REQADDARTICLE   = 501;   // ����Խ��� �۾��� ��û.
   GABOARD_REQDELARTICLE   = 502;   // ����Խ��� �ۻ��� ��û.
   GABOARD_REQEDITARTICLE  = 503;   // ����Խ��� �ۼ��� ��û.

   // DB --> GAME
   GABOARD_GETLIST         = 600;   // ����Խ��� ����Ʈ ����.
   GABOARD_ADDARTICLE      = 601;
   GABOARD_DELARTICLE      = 602;
   GABOARD_EDITARTICLE     = 603;

type
    // ������ ���̽����� �����ܿ쿡 �ʿ��� ������ ����
    TSqlLoadRecord = record
        loadType    : integer;
        UserName    : string[20];
        pRcd        : pointer;  //
    end;
    PTSqlLoadRecord = ^TSqlLoadRecord;

    // �����ͺ��̽� ���࿡ ���õ� ������
    TSQLEngine = class(TThread)
    private
        SqlToDBList: TList;
        DbToGameList: TList;

//        SQLock      : TCriticalSection;
        FActive     : Boolean;
        procedure AddToDBList(   pInfo : pTSqlLoadRecord );
        procedure AddToGameList( pInfo : pTSqlLoadRecord );

        // �����ʿ��� �����͸� ������ ���� �κ�
        function GetGameExecuteData : pTSqlLoadRecord;

    protected
        procedure Execute; override;

    public
        constructor Create;
        destructor Destroy; override;

        procedure ExecuteSaveCommand;
        function ExecuteLoadCommand : integer;

        //UserMarket (��Ź����)=================================================
        // ������ ����Ʈ �б� ��û
        function RequestLoadPageUserMarket(
                  ReqInfo_ : TMarKetReqInfo
                  ):Boolean;
        //�����۵��
        function RequestSellItemUserMarket(
                  UserName: string;
                  pselladd: PTMarketLoad
                  ):Boolean;

        //������ ��Ź �������� �˻�
        function RequestReadyToSellUserMarket(
                  UserName    : String;
                  MarketName  : String;
                  sellwho     : String
                  ):Boolean;

        // ������ ��� ��û
        function RequestBuyItemUserMarket(
                  UserName    : string;
                  MarketName  : string;
                  BuyWho      : string;
                  SellIndex   : integer
                  ):Boolean;

        //��ϵ� ������ ���
        function RequestCancelSellUserMarket(
                  UserName    : String;
                  MarketName  : String;
                  sellwho     : String;
                  sellindex   : integer
                  ):Boolean;

        //������ ����
        function RequestGetpayUserMarket(
                  UserName    : string;
                  MarketName  : string;
                  sellwho     : string;
                  sellindex   : integer
                  ):Boolean;

        // �������� �������� ���ɿ�������
        procedure CheckToDB(
                  UserName    : string;
                  Marketname  : string;
                  SellWho     : string;
                  MakeIndex_  : integer;
                  SellIndex   : integer;
                  CheckType   : integer
                  );

        //��Ź���� ���� �ݱ�
        procedure Open ( WantOpen : Boolean );

        procedure ExecuteRun ;

        {-----����Խ���-----}
        function RequestLoadGuildAgitBoard( UserName, gname : string ):Boolean;
        function RequestGuildAgitBoardAddArticle( gname : string; OrgNum, SrcNum1, SrcNum2, SrcNum3, nKind, AgitNum : integer; uname, data : string ):Boolean;
        function RequestGuildAgitBoardDelArticle( gname : string; OrgNum, SrcNum1, SrcNum2, SrcNum3 : integer; uname : string ):Boolean;
        function RequestGuildAgitBoardDelAll( gname : string; agitnum : integer; uname : string ):Boolean;
        function RequestGuildAgitBoardEditArticle( gname : string; OrgNum, SrcNum1, SrcNum2, SrcNum3 : integer; uname, data : string ):Boolean;

    end;
var
   SqlEngine   : TSQLEngine;
   g_UMDEBUG : integer;
implementation
uses
   svMain;

constructor TSQLEngine.Create;
begin
   inherited Create (TRUE);
//   FreeOnTerminate := TRUE;

   SqlToDBList := TList.Create;
   DbToGameList := TList.Create;

//   SQLock := TCriticalSection.Create;
   FActive := true;
   g_UMDEBUG := 0;
end;


destructor TSQLEngine.Destroy;
begin
   //�޸� �����ʿ�
   SqlToDBList.Free;

   //�޸� ���� �ʿ�
   DbToGameList.Free;

//   SQLock.Free;
   inherited Destroy;
end;

procedure TSQLEngine.Open ( WantOpen : Boolean );
begin
   try
      SQLock.Enter;
      FActive := WantOpen;
   finally
      SQLock.Leave;
   end;
end;

procedure TSQLEngine.ExecuteSaveCommand;
begin

end;

function TSQLEngine.ExecuteLoadCommand : integer;
var
   pload       : PTSqlLoadRecord;
   bExit       : boolean;
   pSearchInfo : PTSearchSellItem;
   pLoadInfo   : PTMarketLoad;
   rInfoList   : TList;
   SqlResult   : integer;
   i           : integer;
   pSearchGaBoardList : PTSearchGaBoardList;
   pArticleLoad : PTGaBoardArticleLoad;
   loadtime     : LongWord;
   loadtype     : integer;
begin
   Result := 0;
   bExit := false;
   pLoad := nil;
   while (not bExit) do
   begin
      Result := 1;   //bug result

      try
         if not g_DBSQL.Connected then begin
            g_DBSQL.ReConnect;
            Continue;
         end;
      except
         MainOutMessage('[Exception]ExecuteLoadCommand - g_DBSQL.Connected');
      end;

      Result := 2;   //bug result

      // ��ɾ� ����Ʈ ���... ������ ���� ...
      try
         SQLock.Enter;
         if SQLToDBList <> nil then begin
            if SQLToDBList.count > 0 then begin
               if SQLToDBList.Items[0] = nil then begin
                  {debug code}MainOutMessage('SQLToDBList.Items[0] = nil' + ' [' + IntToStr(g_UMDEBUG) + ']');
               end;
               pLoad := SQLToDBList.Items[0];
               SQLToDBList.Delete(0);
               if g_UMDEBUG = 1000 then begin
                  {debug code}MainOutMessage('SQLToDBList.Delete(0) count:' + IntToStr(SQLToDBList.count) + ' [' + IntToStr(g_UMDEBUG) + ']');
                  g_UMDEBUG := 6;
                  bExit := false;
               end else begin
                  g_UMDEBUG := 2;
                  bExit := false;
               end;
            end else begin
//               {debug code}MainOutMessage('not SQLToDBList.count > 0');
               g_UMDEBUG := 3;
               pLoad := nil;
               bExit := true;
            end;
         end else begin
            if g_UMDEBUG = 1000 then {debug code}MainOutMessage('not SQLToDBList <> nil' + ' [' + IntToStr(g_UMDEBUG) + ']');
            g_UMDEBUG := 4;
            pLoad := nil;
            bExit := true;
         end;
      finally
         SQLock.Leave;
      end;

      Result := 3;   //bug result

      if pLoad <> nil then begin
         loadtime := GetTickCount;
         loadtype := pLoad.loadType;

         if (g_UMDEBUG > 0) and (g_UMDEBUG <> 2) then {debug code}MainOutMessage('[TestCode]ExecuteLoadCommand LoadType : ' + IntToStr(loadtype) + ' [' + IntToStr(g_UMDEBUG) + ']');
         g_UMDEBUG := 5;

         Result := 30000 + loadtype;  //extended bug result

         // �ε� Ÿ�Կ� ���� ������
         case pLoad.loadType of
            LOADTYPE_REQGETLIST:
            begin
               g_UMDEBUG := 11;
               Result := 4;   //bug result

               // ������ ���� ������..
               pSearchInfo := PTSearchSellItem( pLoad.pRcd );
               g_UMDEBUG := 12;

               if pSearchInfo <> nil then begin
                  // ����Ʋ �ϳ� ���������.
                  rInfoList   := TList.Create;

                  g_UMDEBUG := 21;

                  if g_DBSql = nil then MainOutMessage('[Exception] g_DBSql = nil');

                  // ���� �о����. ���� SQL  ���� �о���ºκ�(�� �κп��� �������� �� ����)
                  SqlResult := g_DBSql.LoadPageUserMarket(
                               pSearchInfo.MarketName,
                               pSearchInfo.Who,
                               pSearchInfo.ItemName,
                               pSearchInfo.ItemType,
                               pSearchInfo.ItemSet,
                               rInfoList
                               );

                  if rInfoList = nil then MainOutMessage('[Exception] rInfoList = nil');
                  g_UMDEBUG := 22;

                  // ����Ʈ �������� �Ѱ��ְ�
                  pSearchInfo.IsOK  := SqlResult;
                  pSearchInfo.pList := rInfoList;

                  g_UMDEBUG := 23;

                  // ����Ʈ�� �ش��ϴ� ����Ʈ�� �����ְ�
                  rInfoList := nil;

                  g_UMDEBUG := 24;

                  // ��¦ Ÿ�Ը� �ٲٰ�..
                  pLoad.loadType := LOADTYPE_GETLIST;

                  g_UMDEBUG := 13;

                  // �����ʿ��� ����Ҽ� �ְ� ������Ŀ�
                  AddToGameList( pLoad );
                  // �������� �����ش�.
                  pSearchInfo := nil;
                  pLoad := nil;

                  g_UMDEBUG := 14;
               end else begin
                  if g_UMDEBUG > 0 then {debug code}MainOutMessage('[TestCode]ExecuteLoadCommand : pSearchInfo = nil' + IntToStr(loadtype) + ' [' + IntToStr(g_UMDEBUG) + ']');
                  g_UMDEBUG := 15;
               end;

            end;
            LOADTYPE_REQBUYITEM:
            begin
               Result := 5;   //bug result

               g_UMDEBUG := 25;

               pLoadInfo := PTMarketLoad( pLoad.pRcd );
               if pLoadInfo <> nil then begin
                  SqlResult := g_DBSql.BuyOneUserMarket(pLoadInfo );
                  PLoadInfo.IsOK := SqlResult;
                  pLoad.loadType := LOADTYPE_BUYITEM;
                  AddToGameList( pLoad );
                  pLoadInfo := nil;
                  pLoad     := nil;
               end;

            end;
            LOADTYPE_REQSELLITEM:
            begin
               Result := 6;   //bug result

               g_UMDEBUG := 16;

               pLoadInfo := PTMarketLoad( pLoad.pRcd );
               if pLoadInfo <> nil then begin
                  g_UMDEBUG := 17;

                  SqlResult := g_DBSql.AddSellUserMarket( pLoadInfo );
                  PLoadInfo.IsOK := SqlResult;
                  pLoad.loadType := LOADTYPE_SELLITEM;
                  AddToGameList( pLoad );
                  pLoadInfo := nil;
                  pLoad     := nil;

                  g_UMDEBUG := 18;
               end else begin
                  g_UMDEBUG := 19;
               end;

            end;
            LOADTYPE_REQREADYTOSELL:
            begin
               Result := 7;   //bug result

               g_UMDEBUG := 26;

               pLoadInfo := PTMarketLoad( pLoad.pRcd );

               g_UMDEBUG := 30;

               if pLoadInfo <> nil then begin
                  SqlResult := g_DBSql.ReadyToSell( pLoadInfo );
                  PLoadInfo.IsOK := SqlResult;
                  pLoad.loadType := LOADTYPE_READYTOSELL;
                  AddToGameList( pLoad );
                  pLoadInfo := nil;
                  pLoad     := nil;
               end;

               g_UMDEBUG := 31;

            end;
            LOADTYPE_REQCANCELITEM:
            begin
               Result := 8;   //bug result

               g_UMDEBUG := 27;

               pLoadInfo := PTMarketLoad( pLoad.pRcd );
               if pLoadInfo <> nil then begin
                  SqlResult := g_DBSql.CancelUserMarket(pLoadInfo );
                  PLoadInfo.IsOK := SqlResult;
                  pLoad.loadType := LOADTYPE_CANCELITEM;
                  AddToGameList( pLoad );
                  pLoadInfo := nil;
                  pLoad     := nil;
               end;

            end;
            LOADTYPE_REQGETPAYITEM:
            begin
               Result := 9;   //bug result

               g_UMDEBUG := 28;

               pLoadInfo := PTMarketLoad( pLoad.pRcd );
               if pLoadInfo <> nil then begin
                  SqlResult := g_DBSql.GetPayUserMarket(pLoadInfo );
                  PLoadInfo.IsOK := SqlResult;
                  pLoad.loadType := LOADTYPE_GETPAYITEM;
                  AddToGameList( pLoad );
                  pLoadInfo := nil;
                  pLoad     := nil;
               end;
            end;

            LOADTYPE_REQCHECKTODB:
            begin
               Result := 10;   //bug result

               g_UMDEBUG := 29;

               pSearchInfo := PTSearchSellItem( pLoad.pRcd );
               if pSearchInfo <> nil then begin
                   case pSearchInfo.CheckType of
                   MARKET_CHECKTYPE_SELLOK://��Ź ����
                       begin
                       g_DBSql.ChkAddSellUserMarket( pSearchInfo , true);
                       end;
                   MARKET_CHECKTYPE_SELLFAIL://��Ź ����
                       begin
                       g_DBSql.ChkAddSellUserMarket( pSearchInfo , false);
                       end;
                   MARKET_CHECKTYPE_BUYOK://���� ����
                       begin
                       g_DBSql.ChkBuyOneUserMarket( pSearchInfo , true);
                       end;
                   MARKET_CHECKTYPE_BUYFAIL://���� ����
                       begin
                       g_DBSql.ChkBuyOneUserMarket( pSearchInfo , false);
                       end;
                   MARKET_CHECKTYPE_CANCELOK://��� ����
                       begin
                       g_DBSql.ChkCancelUserMarket( pSearchInfo , true);
                       end;
                   MARKET_CHECKTYPE_CANCELFAIL://��� ����
                       begin
                       g_DBSql.ChkCancelUserMarket( pSearchInfo , false);
                       end;
                   MARKET_CHECKTYPE_GETPAYOK://�� ȸ�� ����
                       begin
                       g_DBSql.ChkGetPayUserMarket( pSearchInfo , true);
                       end;
                   MARKET_CHECKTYPE_GETPAYFAIL://�� ȸ�� ����
                       begin
                       g_DBSql.ChkGetPayUserMarket( pSearchInfo , false);
                       end;
                   end;

                   FreeMem ( pSearchInfo );
                   pSearchInfo := nil;
               end;


            end;
            //------------------------------------------
            // ����Խ��� ���...
            GABOARD_REQGETLIST:
            begin
               Result := 11;   //bug result

               // ������ ���� ������..
               pSearchGaBoardList := PTSearchGaBoardList( pLoad.pRcd );

               if pSearchGaBoardList <> nil then
               begin
                 // ����ƮƲ �ϳ� ���������.
                 rInfoList   := TList.Create;
                 // ���� �о����. ���� SQL���� �о���ºκ�
                 SqlResult := g_DBSql.LoadPageGaBoardList(
                               pSearchGaBoardList.GuildName,
                               pSearchGaBoardList.Kind,
                               rInfoList
                               );

                 // ����Ʈ �������� �Ѱ��ְ�
                 pSearchGaBoardList.ArticleList := rInfoList;
                 // ����Ʈ�� �ش��ϴ� �����ʹ� �����ְ�
                 rInfoList := nil;
                 // ��¦ Ÿ�Ը� �ٲٰ�..
                 pLoad.loadType := GABOARD_GETLIST;
                 // �����ʿ��� ����Ҽ� �ְ� ������Ŀ�
                 AddToGameList( pLoad );
                 // ���� ���� �����ش�.
                 pSearchGaBoardList := nil;
                 pLoad := nil;
               end;
            end;
            GABOARD_REQADDARTICLE:
            begin
               Result := 12;   //bug result

               // ������ ���� ������..
               pArticleLoad := PTGaBoardArticleLoad( pLoad.pRcd );

               // �����̸� ����.
               pArticleLoad.UserName := pLoad.UserName;

               if pArticleLoad <> nil then
               begin
                 // ���� �о����. ���� SQL���� �о���ºκ�
                 SqlResult := g_DBSql.AddGaBoardArticle( pArticleLoad );

                 // ��¦ Ÿ�Ը� �ٲٰ�..
                 pLoad.loadType := GABOARD_ADDARTICLE;
                 // �����ʿ��� ����Ҽ� �ְ� ������Ŀ�
                 AddToGameList( pLoad );
                 // ���� ���� �����ش�.
                 pArticleLoad := nil;
                 pLoad := nil;
               end;
            end;
            GABOARD_REQDELARTICLE:
            begin
               Result := 13;   //bug result

               // ������ ���� ������..
               pArticleLoad := PTGaBoardArticleLoad( pLoad.pRcd );

               // �����̸� ����.
               pArticleLoad.UserName := pLoad.UserName;

               if pArticleLoad <> nil then
               begin
                 // ���� �о����. ���� SQL���� �о���ºκ�
                 SqlResult := g_DBSql.DelGaBoardArticle( pArticleLoad );

                 // ��¦ Ÿ�Ը� �ٲٰ�..
                 pLoad.loadType := GABOARD_DELARTICLE;
                 // �����ʿ��� ����Ҽ� �ְ� ������Ŀ�
                 AddToGameList( pLoad );
                 // ���� ���� �����ش�.
                 pArticleLoad := nil;
                 pLoad := nil;
               end;
            end;
            GABOARD_REQEDITARTICLE:
            begin
               Result := 14;   //bug result

               // ������ ���� ������..
               pArticleLoad := PTGaBoardArticleLoad( pLoad.pRcd );

               // �����̸� ����.
               pArticleLoad.UserName := pLoad.UserName;

               if pArticleLoad <> nil then
               begin
                 // ���� �о����. ���� SQL���� �о���ºκ�
                 SqlResult := g_DBSql.EditGaBoardArticle( pArticleLoad );

                 // ��¦ Ÿ�Ը� �ٲٰ�..
                 pLoad.loadType := GABOARD_EDITARTICLE;
                 // �����ʿ��� ����Ҽ� �ְ� ������Ŀ�
                 AddToGameList( pLoad );
                 // ���� ���� �����ش�.
                 pArticleLoad := nil;
                 pLoad := nil;
               end;
            end;
            else
            begin
               Result := 170000 + loadtype;  //extended bug result
               if g_UMDEBUG > 0 then {debug code}MainOutMessage('[TestCode]ExecuteLoadCommand : case else LoadType' + IntToStr(loadtype) + ' [' + IntToStr(g_UMDEBUG) + ']');
               g_UMDEBUG := 20;
            end;
            //------------------------------------------

         end;//case

         Result := 15;   //bug result

         if pLoad <> nil then
         begin
            Result := 16;   //bug result

            dispose( pLoad );
            pLoad := nil;
         end;

         // TEST_TIME
         if g_TestTime = 12 then
            MainOutMessage('SQLEng Load :'+IntToStr( GetTickCount-Loadtime)+','+IntToStr(Loadtype));

      end; // pload <> nil

   end;  // while...
end;

procedure TSQLEngine.Execute;
var
   buginfo : integer;
begin
   buginfo := 0;

//   Suspend;
   while TRUE do
   begin
      // ������ ó����ƾ

      try
         // �����ͺ��̽��� �����ϴ� ����� ���� �����Ѵ�.
         ExecuteSaveCommand;
      except
         MainOutMessage('EXCEPTION SQLEngine.ExecuteSaveCommand');
      end;


      // �����ͺ��̽����� �д� ��ɾ� ����
      try
         buginfo := ExecuteLoadCommand;
      except
         MainOutMessage('EXCEPTION SQLEngine.ExecuteLoadCommand' + IntToStr(buginfo) + ' [' + IntToStr(g_UMDEBUG) + ']');
         if buginfo = 3 then g_UMDEBUG := 1000;
      end;

      sleep (1);  //���Ϲ����� 1->50���� ����(sonmg 2004/06/15)->��� ����(2004/07/08)
      if Terminated then exit;

    end;

end;

// GAME SERVER ==> DB ������ ���� ==============================================
// ������ûĿ��Ʈ ���
procedure TSQLEngine.AddToDBList( pInfo : pTSqlLoadRecord );
begin
   if pInfo = nil then exit;

   try
      SQLock.Enter;
      SqlToDBList.Add (pInfo);
   finally
      SQLock.Leave;
   end;

end;

// ������ ����Ʈ �б⸦ ��û�Ѵ�.
function TSQLEngine.RequestLoadPageUserMarket (
   ReqInfo_ : TMarKetReqInfo
   ):Boolean;
var
   pload: PTSqlLoadRecord;
   flag : Boolean;
begin
   Result := false;

   try
      SQLock.Enter;
      flag := FActive;
   finally
      SQLock.Leave;
   end;

   if not flag then Exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := LOADTYPE_REQGETLIST;
   pload.UserName := ReqInfo_.UserName;
   GetMem (pload.pRcd, sizeof(TSearchSellItem));
   // �д� ���� ����
   PTSearchSellItem(pload.pRcd).MarketName := ReqInfo_.marketname;
   PTSearchSellItem(pload.pRcd).Who        := ReqInfo_.searchwho;
   PTSearchSellItem(pload.pRcd).ItemName   := ReqInfo_.searchitem;
   PTSearchSellItem(pload.pRcd).ItemType   := ReqInfo_.itemtype;
   PTSearchSellItem(pload.pRcd).ItemSet    := ReqInfo_.itemSet;
   PTSearchSellItem(pload.pRcd).UserMode   := ReqInfo_.UserMode;

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   if g_UMDEBUG = 1000 then {debug code}MainOutMessage('RequestLoadPageUserMarket-AddToDBList' +  ' [' + IntToStr(g_UMDEBUG) + ']');
   g_UMDEBUG := 1;

   Result := true;

end;

//���� �Ǹſø� �������� ��ҽ�Ų��.
function TSQLEngine.RequestReadyToSellUserMarket (
   UserName    : String;
   MarketName  : String;
   sellwho     : String
):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := false;
   if not FActive then Exit;

   new (pload);
   pload.loadType := LOADTYPE_REQREADYTOSELL;  //

   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TMarketLoad));  //��� ����.

   PTMarketLoad(pload.pRcd).MarketName := marketname;
   PTMarketLoad(pload.pRcd).SellWho    := sellwho;

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := true;
end;

//������ ��⸦ ��û�Ѵ�.
function TSQLEngine.RequestBuyItemUserMarket (
   UserName    : string;
   MarketName  : string;
   BuyWho      : string;
   SellIndex   : integer
):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := false;
   if not FActive then Exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := LOADTYPE_REQBUYITEM;
   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TMarketLoad));
   // ������ϴ� ������ �������
   PTMarketLoad(pload.pRcd).MarketName     := marketname;
   PTMarketLoad(pload.pRcd).SellWho        := Buywho;
   PTMarketLoad(pload.pRcd).Index          := sellindex;

   {debug code}if pload = nil then exit;
   // ���
   AddToDBList( pload );

   Result := true;
end;

// �������� ��Ȯ�� �޾Ҵ��� ����
procedure TSQLEngine.CheckToDB (
   UserName    : string;
   Marketname  : string;
   SellWho     : string;
   MakeIndex_  : integer;
   SellIndex   : integer;
   CheckType   : integer
   );
var
   pload: PTSqlLoadRecord;
begin
   if not FActive then begin
      MainOutMessage('[TestCode2] TSqlEngine.CheckToDB FActive is FALSE');
   end;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := LOADTYPE_REQCHECKTODB;
   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TSearchSellItem));
   // ���޹��� ������ �������� �Է�
   PTSearchSellItem(pload.pRcd).CheckType  := CheckType;
   PTSearchSellItem(pload.pRcd).MarketName := marketname;
   PTSearchSellItem(pload.pRcd).Who        := SellWho;
   PTSearchSellItem(pload.pRcd).makeindex  := MakeIndex_;
   PTSearchSellItem(pload.pRcd).SellIndex  := sellindex;

   {debug code}if pload = nil then exit;
   // ���
   AddToDBList( pload );

end;

// ������ ���
function TSQLEngine.RequestSellItemUserMarket (
   UserName: string;
   pselladd: PTMarketLoad
):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := false;
   if not FActive then Exit;

   new (pload);
   pload.loadType := LOADTYPE_REQSELLITEM;  //

   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TMarketLoad));
   Move (pselladd^, pload.pRcd^, sizeof(TMarketLoad));

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := true;
end;

//������ ����
function TSQLEngine.RequestGetPayUserMarket(
   UserName    : string;
   MarketName  : string;
   sellwho     : string;
   sellindex   : integer
):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := false;
   if not FActive then Exit;

   new (pload);
   pload.loadType := LOADTYPE_REQGETPAYITEM;  //

   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TMarketLoad));  //��� ����.

   PTMarketLoad(pload.pRcd).MarketName := marketname;
   PTMarketLoad(pload.pRcd).SellWho    := sellwho;
   PTMarketLoad(pload.pRcd).Index      := sellindex;

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := true;
end;

//���� �Ǹſø� �������� ��ҽ�Ų��.
function TSQLEngine.RequestCancelSellUserMarket (
   UserName    : String;
   MarketName  : String;
   sellwho     : String;
   sellindex   : integer
):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := false;
   if not FActive then Exit;

   new (pload);
   pload.loadType := LOADTYPE_REQCANCELITEM;  //

   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TMarketLoad));  //��� ����.

   PTMarketLoad(pload.pRcd).MarketName := marketname;
   PTMarketLoad(pload.pRcd).SellWho    := sellwho;
   PTMarketLoad(pload.pRcd).Index      := sellindex;

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := true;
end;

// DB --> GAME SERVER  ������ ���� =============================================
procedure TSQLEngine.AddToGameList( pInfo : pTSqlLoadRecord );
begin
   if pInfo = nil then exit;

   try
      SQLock.Enter;
      DbToGameList.Add (pInfo);
   finally
      SQLock.Leave;
   end;

end;

// ���� �Ʒ����ʹ� �����ʿ��� ����ϴ� �κ��̹Ƿ� �����尡 �и��ȴ� ����!=======
// �����ʿ��� �����͸� �о ó���ؾߵǴ� �κ�...
function TSQLEngine.GetGameExecuteData : pTSqlLoadRecord;
begin
   Result := nil;

   // ��ɾ� ����Ʈ ���... ������ ���� ...
   try
      SQLock.Enter;
      if DbToGameList <> nil then begin
         if DbTOGameList.count > 0 then begin
            Result := DbTOGameList.Items[0];
            DbTOGameList.Delete(0);
         end;
      end;
   finally
      SQLock.Leave;
   end;

end;

//�����ʿ��� �����ϴ� ��ƾ
procedure TSQLEngine.ExecuteRun;
var
   pLoad       : PTSqlLoadRecord;
   pSearchInfo : PTSearchSellItem;
   pLoadInfo   : PTMarketLoad;
   hum         : TUserHuman;
   i           : integer;
   pBoardListInfo : PTSearchGaBoardList;
   pArticleInfo : PTGaBoardArticleLoad;
begin

   try
      // �ѹ��� �ϳ��� �����ϵ�������.. 1msec Ÿ�̸ӿ� ������ ����ϰ� �ȴ�.
      pLoad := GetGameExecuteData;

      if pLoad <> nil then begin
         case pLoad.loadType of
         LOADTYPE_GETLIST :
            begin
               pSearchInfo := pLoad.pRcd;

               if pSearchInfo <> nil then begin
                  hum := UserEngine.GetUserHuman ( pLoad.UserName);

                  // ������ ������
                  if hum <> nil then begin
                     hum.GetMarketData( pSearchInfo );
                     hum.SendUserMarketList( 0 );
                  end else begin
                     // ������ ����.. ����Ʈ �������..
                     MainOutMessage('INFO SQLENGINE DO NOT FIND USER FOR MARKETLIST!');
                  end;

                  // �޸� ����..
                  if pSearchInfo.pList <> nil then begin
                     for i := pSearchInfo.pList.count -1 downto 0 do begin
                        if pSearchInfo.pList.items[0] <> nil then
                           dispose ( pSearchInfo.pList.items[0] );

                        pSearchInfo.pList.delete(0);
                     end;
                     pSearchInfo.pList.Free;
                     pSearchInfo.pList := nil;
                  end;
               end;
            end;
         LOADTYPE_SELLITEM :
            begin
               pLoadInfo := pLoad.pRcd;

               if pLoadInfo <> nil then begin
                  hum := UserEngine.GetUserHuman ( pLoad.UserName );

                  if hum <> nil then begin
                      hum.SellUserMarket( pLoadInfo );
                  end else begin
                      // ������ ����.. ����Ʈ �������..
                      MainOutMessage('INFO SQLENGINE DO NOT FIND USER FOR SELLITEM!');
                      // �����ͺ��̽� �� ���� �������
                  end;
               end;
            end;
         LOADTYPE_READYTOSELL :
            begin
               pLoadInfo := pLoad.pRcd;

               if pLoadInfo <> nil then begin
                  hum := UserEngine.GetUserHuman ( pLoad.UserName);

                  if hum <> nil then begin
                     hum.ReadyToSellUserMarket( pLoadInfo );
                  end else begin
                     // ������ ����.. ����Ʈ �������..
                     MainOutMessage('INFO SQLENGINE DO NOT FIND USER FOR SELLITEM!');
                     // �����ͺ��̽� �� ���� �������
                  end;
               end;
            end;
         LOADTYPE_BUYITEM:
            begin
               pLoadInfo := pLoad.pRcd;

               if pLoadInfo <> nil then begin
                  hum := UserEngine.GetUserHuman ( pLoad.UserName);

                  if hum <> nil then begin
                     hum.BuyUserMarket(pLoadInfo);
                  end else begin
                     // ������ ����.. ����Ʈ �������..
                     MainOutMessage('INFO SQLENGINE DO NOT FIND USER FOR SELLITEM!');
                     // �����ͺ��̽� �� ���� �������
                  end;
               end;
            end;
         LOADTYPE_CANCELITEM:
            begin
               pLoadInfo := pLoad.pRcd;

               if pLoadInfo <> nil then begin
                  hum := UserEngine.GetUserHuman ( pLoad.UserName);

                  if hum <> nil then begin
                     hum.CancelUserMarket(pLoadInfo);
                  end else begin
                     // ������ ����.. ����Ʈ �������..
                     MainOutMessage('INFO SQLENGINE DO NOT FIND USER FOR CANCEL!');
                     // �����ͺ��̽� �� ���� �������
                  end;
               end;
            end;
         LOADTYPE_GETPAYITEM:
            begin
               pLoadInfo := pLoad.pRcd;

               if pLoadInfo <> nil then begin
                  hum := UserEngine.GetUserHuman ( pLoad.UserName);

                  if hum <> nil then begin
                     hum.GetPayUserMarket(pLoadInfo);
                  end else begin
                     // ������ ����.. ����Ʈ �������..
                     MainOutMessage('INFO SQLENGINE DO NOT FIND USER FOR GETPAY!');
                     // �����ͺ��̽� �� ���� �������
                  end;
               end;
            end;

         //------------------------------------------
         // ����Խ��� ���...
         GABOARD_GETLIST:
            begin
               pBoardListInfo := pLoad.pRcd;

               if pBoardListInfo <> nil then begin
                  if pBoardListInfo.GuildName <> '' then begin
                     // ����Խ��� ����Ʈ�� ����.
                     GuildAgitBoardMan.AddGaBoardList( pBoardListInfo );

                     // �������� Refresh��Ŵ.
                     hum := UserEngine.GetUserHuman ( pBoardListInfo.UserName );

                     if hum <> nil then begin
                        hum.CmdReloadGaBoardList( pBoardListInfo.GuildName, 1);
                     end;
                  end;

                  // �޸� ����..
                  if pBoardListInfo.ArticleList <> nil then begin
                     for i := pBoardListInfo.ArticleList.count -1 downto 0 do begin
                        if pBoardListInfo.ArticleList.items[0] <> nil then
                           dispose ( pBoardListInfo.ArticleList.items[0] );

                        pBoardListInfo.ArticleList.delete(0);
                     end;
                     pBoardListInfo.ArticleList.Free;
                     pBoardListInfo.ArticleList := nil;
                  end;
               end;
            end;
         GABOARD_ADDARTICLE :
            begin
               pArticleInfo := pLoad.pRcd;

               if pArticleInfo <> nil then begin
                  // �켱 DB���� �ε��Ѵ�...
//                  GuildAgitBoardMan.LoadAllGaBoardList( pArticleInfo.UserName );
               end;
            end;
         GABOARD_DELARTICLE :
            begin
               pArticleInfo := pLoad.pRcd;

               if pArticleInfo <> nil then begin
                  // �켱 DB���� �ε��Ѵ�...
//                  GuildAgitBoardMan.LoadAllGaBoardList( pArticleInfo.UserName );
               end;
            end;
         GABOARD_EDITARTICLE :
            begin
               pArticleInfo := pLoad.pRcd;

               if pArticleInfo <> nil then begin
                  // �켱 DB���� �ε��Ѵ�...
//                  GuildAgitBoardMan.LoadAllGaBoardList( pArticleInfo.UserName );
               end;
            end;
        //------------------------------------------

        end;

        //�޸� ����.. pRcd
        if pLoad.pRcd <> nil then begin
           FreeMem( pLoad.pRcd );
        end;
        //�޸� ����
        dispose( pLoad );
        pLoad := nil;
     end;

   except
       MainOutMessage('SQLEngnExcept ExecuteRun!');
   end;

end;

{-----------------------------����Խ���-------------------------}
function TSQLEngine.RequestLoadGuildAgitBoard( UserName, gname : string ):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := FALSE;
   if not FActive then Exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := GABOARD_REQGETLIST;
   pload.UserName := UserName;
   GetMem (pload.pRcd, sizeof(TSearchGaBoardList));

   // �д� ���� ����
   PTSearchGaBoardList(pload.pRcd).AgitNum   := 0;
   PTSearchGaBoardList(pload.pRcd).GuildName := gname;  //����̸����� ã��.
   PTSearchGaBoardList(pload.pRcd).OrgNum    := -1;
   PTSearchGaBoardList(pload.pRcd).SrcNum1   := -1;
   PTSearchGaBoardList(pload.pRcd).SrcNum2   := -1;
   PTSearchGaBoardList(pload.pRcd).SrcNum3   := -1;
   PTSearchGaBoardList(pload.pRcd).Kind      := KIND_GENERAL;
   PTSearchGaBoardList(pload.pRcd).UserName  := UserName;

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := TRUE;
end;

function TSQLEngine.RequestGuildAgitBoardAddArticle( gname : string; OrgNum, SrcNum1, SrcNum2, SrcNum3, nKind, AgitNum : integer; uname, data : string ):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := FALSE;
   if not FActive then Exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := GABOARD_REQADDARTICLE;
   pload.UserName := uname;
   GetMem (pload.pRcd, sizeof(TGaBoardArticleLoad));

   // �д� ���� ����
   PTGaBoardArticleLoad(pload.pRcd).AgitNum   := AgitNum;
   PTGaBoardArticleLoad(pload.pRcd).GuildName := gname;
   PTGaBoardArticleLoad(pload.pRcd).OrgNum    := OrgNum;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum1   := SrcNum1;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum2   := SrcNum2;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum3   := SrcNum3;
   PTGaBoardArticleLoad(pload.pRcd).Kind      := nKind;
   PTGaBoardArticleLoad(pload.pRcd).UserName  := uname;
   FillChar(PTGaBoardArticleLoad(pload.pRcd).Content, sizeof(PTGaBoardArticleLoad(pload.pRcd).Content), #0);
   StrPLCopy (PTGaBoardArticleLoad(pload.pRcd).Content, data, sizeof(PTGaBoardArticleLoad(pload.pRcd).Content)-1);

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := TRUE;
end;

function TSQLEngine.RequestGuildAgitBoardDelArticle( gname : string; OrgNum, SrcNum1, SrcNum2, SrcNum3 : integer; uname : string ):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := FALSE;
   if not FActive then Exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := GABOARD_REQDELARTICLE;
   pload.UserName := uname;
   GetMem (pload.pRcd, sizeof(TGaBoardArticleLoad));

   // �д� ���� ����
   PTGaBoardArticleLoad(pload.pRcd).AgitNum   := 0;
   PTGaBoardArticleLoad(pload.pRcd).GuildName := gname;
   PTGaBoardArticleLoad(pload.pRcd).OrgNum    := OrgNum;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum1   := SrcNum1;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum2   := SrcNum2;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum3   := SrcNum3;
   PTGaBoardArticleLoad(pload.pRcd).Kind      := KIND_ERROR;
   PTGaBoardArticleLoad(pload.pRcd).UserName  := uname;
   FillChar(PTGaBoardArticleLoad(pload.pRcd).Content, sizeof(PTGaBoardArticleLoad(pload.pRcd).Content), #0);

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := TRUE;
end;

function TSQLEngine.RequestGuildAgitBoardDelAll( gname : string; agitnum : integer; uname : string ):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := FALSE;
   if not FActive then Exit;

   if agitnum = 0 then exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := GABOARD_REQDELARTICLE;
   pload.UserName := uname;
   GetMem (pload.pRcd, sizeof(TGaBoardArticleLoad));

   // �д� ���� ����
   PTGaBoardArticleLoad(pload.pRcd).AgitNum   := agitnum;
   PTGaBoardArticleLoad(pload.pRcd).GuildName := gname;
   PTGaBoardArticleLoad(pload.pRcd).OrgNum    := 0;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum1   := 0;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum2   := 0;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum3   := 0;
   PTGaBoardArticleLoad(pload.pRcd).Kind      := KIND_ERROR;
   PTGaBoardArticleLoad(pload.pRcd).UserName  := uname;
   FillChar(PTGaBoardArticleLoad(pload.pRcd).Content, sizeof(PTGaBoardArticleLoad(pload.pRcd).Content), #0);

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := TRUE;
end;

function TSQLEngine.RequestGuildAgitBoardEditArticle( gname : string; OrgNum, SrcNum1, SrcNum2, SrcNum3 : integer; uname, data : string ):Boolean;
var
   pload: PTSqlLoadRecord;
begin
   Result := FALSE;
   if not FActive then Exit;

   // �б� ���ڵ� ����
   new (pload);
   pload.loadType := GABOARD_REQEDITARTICLE;
   pload.UserName := uname;
   GetMem (pload.pRcd, sizeof(TGaBoardArticleLoad));

   // �д� ���� ����
   PTGaBoardArticleLoad(pload.pRcd).AgitNum   := 0;
   PTGaBoardArticleLoad(pload.pRcd).GuildName := gname;
   PTGaBoardArticleLoad(pload.pRcd).OrgNum    := OrgNum;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum1   := SrcNum1;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum2   := SrcNum2;
   PTGaBoardArticleLoad(pload.pRcd).SrcNum3   := SrcNum3;
   PTGaBoardArticleLoad(pload.pRcd).Kind      := KIND_ERROR;
   PTGaBoardArticleLoad(pload.pRcd).UserName  := uname;
   FillChar(PTGaBoardArticleLoad(pload.pRcd).Content, sizeof(PTGaBoardArticleLoad(pload.pRcd).Content), #0);
   StrPLCopy (PTGaBoardArticleLoad(pload.pRcd).Content, data, sizeof(PTGaBoardArticleLoad(pload.pRcd).Content)-1);

   {debug code}if pload = nil then exit;
   AddToDBList( pload );

   Result := TRUE;
end;


end.
