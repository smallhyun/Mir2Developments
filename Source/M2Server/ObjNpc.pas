unit ObjNpc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, Grobal2, Envir, EdCode, ObjBase,
  M2Share, Guild, StrUtils;


const
   GUILDWARFEE = 60000;
   // 2003/07/15 ��ϼ� ���� ����
   CASTLEMAINDOORREPAREGOLD = 1500000; //2000000;
   CASTLECOREWALLREPAREGOLD = 400000;  //500000;
   CASTLEARCHEREMPLOYFEE = 250000;     //300000;
   CASTLEGUARDEMPLOYFEE = 250000;      //300000;
   UPGRADEWEAPONFEE = 10000;

   MAXREQUIRE = 10;

   //���� ���
//   GUILDAGITREGFEE = 10000000;
//   GUILDAGITEXTENDFEE = 1000000;

type
   //���� ���� ����
   TUpgradeInfo = record
      UserName: string[14];
      uitem: TUserItem;
      updc: byte;
      upsc: byte;
      upmc: byte;
      durapoint: byte;
      readydate: TDateTime;
      readycount: longword;
   end;
   PTUpgradeInfo = ^TUpgradeInfo;

   //����Ʈ ����
   TQuestRequire = record
      RandomCount: integer;
      CheckIndex: word;
      CheckValue: byte;  //0, 1
   end;

   TQuestActionInfo = record
      ActIdent: integer;
      ActParam: string;
      ActParamVal: integer;
      ActTag: string;
      ActTagVal: integer;
      ActExtra: string;
      ActExtraVal: integer;
   end;
   PTQuestActionInfo = ^TQuestActionInfo;

   TQuestConditionInfo = record
      IfIdent: integer;
      IfParam: string;
      IfParamVal: integer;
      IfTag: string;
      IfTagVal: integer;
   end;
   PTQuestConditionInfo = ^TQuestConditionInfo;

   TSayingProcedure = record
      ConditionList: TList;
      ActionList: TList; //StringList;
      Saying: string;
      ElseActionList: TList; //StringList;
      ElseSaying: string;
      AvailableCommands: TStringList;
   end;
   PTSayingProcedure = ^TSayingProcedure;

   TSayingRecord = record
      Title: string;
      Procs: TList; //list of PTSayingProcedure
   end;
   PTSayingRecord = ^TSayingRecord;

   TQuestRecord = record
      BoRequire: Boolean;  //�䱸������ �ִ��� ����, ������ �⺻ ��ȭ
      LocalNumber: integer;
      QuestRequireArr: array[0..MAXREQUIRE-1] of TQuestRequire;
      SayingList: TList;  //list of PTSayingRecord
   end;
   PTQuestRecord = ^TQuestRecord;


   TNormNpc = class (TAnimal)
      NpcFace: byte;  //���� ��.. ä��â�� ������ ��..
      //SayString: string; //������ ���ϴ� ���...
      //SayStrings: TStringList; //list of TStringList;
      Sayings: TList;  //list of PTQuestRecord
      DefineDirectory: string;  //�⺻�� ''
      BoInvisible: Boolean;
      BoUseMapFileName: Boolean;  //�����̸��� '-D001'ó�� ���̸��� ���� �ٴ��� ����
      //6-11
      NpcBaseDir: string;

      CanSell       : Boolean;
      CanBuy        : Boolean;
      CanStorage    : Boolean;
      CanGetBack    : Boolean;
      CanRepair     : Boolean;
      CanMakeDrug   : Boolean;
      CanUpgrade    : Boolean;
      CanMakeItem   : Boolean;
      CanItemMarket : Boolean;

      CanSpecialRepair  : Boolean;
      CanTotalRepair    : Boolean;

      // ���� ���
      CanAgitUsage  : Boolean;
      CanAgitManage  : Boolean;
      CanBuyDecoItem : Boolean;

      // ��Ÿ
      CanDoingEtc : Boolean;

      BoSoundPlaying : Boolean;
      SoundStartTime : LongWord;

      MemorialCount : LongInt;

   private
   protected
   public
      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
      procedure ActivateNpcUtilitys (saystr: string);  //������ �� �� �ִ� ��� ����,  �Ǹ�, ����, �ñ�� ��...
      procedure UserCall (caller: TCreature); dynamic;
      procedure UserSelect (whocret: TCreature; selstr: string); dynamic;
      //procedure ArrangeSayStrings;
      procedure NpcSay (target: TCreature; str: string);
      function  ChangeNpcSayTag (src, orgstr, chstr: string): string;
      procedure NpcSayTitle (who: TCreature; title: string);
      procedure CheckNpcSayCommand (hum: TUserHuman; var source: string; tag: string); dynamic;
      procedure ClearNpcInfos;
      procedure LoadNpcInfos;
      procedure LoadMemorialCount;
      procedure WriteMemorialCount;
   end;

   TMerchant = class (TNormNpc)  //�ǸŸ� �ϴ� ����
      MarketName: string;
      MarketType: byte;
      //RepairItem: byte;  //0:����,  1:��
      //StorageItem: byte;
      PriceRate: integer;  //����, 100:����, 100���� ũ�� ��δ�.
      NoSeal: Boolean;
      BoCastleManage: Boolean;  //������ �����ϴ� ���� (��ϼ��� �Ѱ� ���� ��쿡 �ش��)
      BoHiddenNpc: Boolean;
      fSaveToFileCount: integer;
      CreateIndex: integer;   //������ �� ���������� �ο��Ǵ� Index(���� �л꿡 �̿��Ѵ�).
   private
      checkrefilltime: longword;
      checkverifytime: longword;
      //specialrepairtime: longword;
      //specialrepair: integer;
      function  GetGoodsList (gindex: integer): TList;
      function  GetGoodsPrice (uitem: TUserItem): integer;
      function  GetSellPrice (whocret: TUserHuman; price: integer): integer;
      function  GetBuyPrice (price: integer): integer;
      procedure RefillGoods;
      procedure SaveUpgradeItemList;
      procedure LoadUpgradeItemList;
      procedure VerifyUpgradeList;
   protected
   public
      DealGoods: TStringList;  //����ϴ� ������ StdMode   ;�����Ұ�
      ProductList: TList;  //���Ǵ� ������ list of PTMarketProduct  ;�����Ұ�
      GoodsList: TList;  //���� �Ǹ��ϴ� ��ǰ ����Ʈ  ;�����Ұ�
      PriceList: TList;  //���� ����Ʈ, �ѹ� �Ǹŵ� �������� ���� ������ ����� ���´�.

      UpgradingList: TList;  //���׷��̵带 �ñ� ������ ���

      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
      procedure CheckNpcSayCommand (hum: TUserHuman; var source: string; tag: string); override;
      procedure UserCall (caller: TCreature); override;
      //------------------------------------------------------------------------
      // UserSelect���� �и�
      procedure SendGoodsEntry (who: TCreature; ltop: integer);  //
      procedure SendSellGoods (who: TCreature); //�ȱ� �޴��ش�.
      procedure SendRepairGoods (who: TCreature); //�����ϱ� �޴�
      procedure SendSpecialRepairGoods (who: TCreature); //Ư�������ϱ� �޴�
      procedure SendStorageItemMenu (who: TCreature);
      procedure SendStorageItemList (who: TCreature);
      procedure SendMakeDrugItemList (who: TCreature);
      procedure SendMakeFoodList (who: TCreature);
      procedure SendMakePotionList (who: TCreature);
      procedure SendMakeGemList (who: TCreature);
      procedure SendMakeItemList (who: TCreature);
      procedure SendMakeStuffList (who: TCreature);
      procedure SendMakeEtcList (who: TCreature);
      //------------------------------------------------------------------------
      //����ٹ̱�
      procedure SendDecoItemListShow (who: TCreature);
      //------------------------------------------------------------------------
      // ��Ź����
      procedure SendUserMarket( hum : TuserHuman ; ItemType : integer ; UserMode : integer );
      //------------------------------------------------------------------------
      procedure UserSelect (whocret: TCreature; selstr: string); override;
      procedure SayMakeItemMaterials (whocret: TCreature; selstr: string);
      procedure QueryPrice (whocret: TCreature; uitem: TUserItem);
      function  AddGoods (uitem: TUserItem): Boolean;
      function  UserSellItem (whocret: TCreature; uitem: TUserItem): Boolean;
      function  UserCountSellItem (whocret: TCreature; uitem: TUserItem; sellcnt: integer): Boolean;
      procedure QueryRepairCost (whocret: TCreature; uitem: TUserItem);
      function  UserRepairItem (whocret: TCreature; puitem: PTUserItem): Boolean;
      procedure UserSelectUpgradeWeapon (hum: TUserHuman);
      procedure UserSelectGetBackUpgrade (hum: TUserHuman);
      procedure PriceDown (index: integer);
      procedure PriceUp (index: integer);
      function  GetPrice (index: integer): integer;
      procedure NewPrice (index, price: integer);
//      function  IsDealingItem (stdmode: integer): Boolean;
      function  IsDealingItem (stdmode: integer ; shape :integer ): Boolean;
      procedure UserBuyItem (whocret: TUserHuman; itmname: string; serverindex, BuyCount: integer);
      procedure UserWantDetailItems (whocret: TCreature; itmname: string; menuindex: integer);
      procedure UserMakeNewItem (whocret: TUserHuman; itmname: string);
      procedure UserManufactureItem (whocret: TUserHuman; itmname: string);
      procedure ClearMerchantInfos;
      procedure LoadMerchantInfos;
      procedure LoadMarketSavedGoods;
      function CheckMakeItemCondition (hum: TUserHuman; itemname: string; sItemMakeIndex, sItemName, sItemCount: array of string; var iPrice, iMakeCount: Integer): Integer;
      function GetGradeOfGuardStoneByName ( strGuardStone: string ): Integer;
   end;

   TGuildOfficial = class (TNormNpc)
   private
      function  UserDeclareGuildWarNow (hum: TUserHuman; gname: string): integer;
      function  UserBuildGuildNow (hum: TUserHuman; gname: string): Integer;
      function  UserFreeGuild (hum: TUserHuman): integer;
      procedure UserDonateGold (hum: TUserHuman);
      procedure UserRequestCastleWar (hum: TUserHuman);
//      function UserGuildMemberRecall (hum: TUserHuman; man: string): Boolean;
   public
      constructor Create;
      destructor Destroy; override;
      procedure Run; override;
      procedure UserCall (caller: TCreature); override;
      procedure UserSelect (whocret: TCreature; selstr: string); override;
   end;

   TTrainer = class (TNormNpc)
   private
      strucktime: longword;
      damagesum: integer;
      struckcount: integer;
   public
      constructor Create;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
   end;

   TCastleManager = class (TMerchant)
   private
      procedure RepaireCastlesMainDoor (hum: TUserHuman);
      procedure RepaireCoreCastleWall (wall: integer; hum: TUserHuman);
      procedure HireCastleGuard (numstr: string; hum: TUserHuman);
      procedure HireCastleArcher (numstr: string; hum: TUserHuman);
   public
      constructor Create;
      procedure CheckNpcSayCommand (hum: TUserHuman; var source: string; tag: string); override;
      procedure UserCall (caller: TCreature); override;
      procedure UserSelect (whocret: TCreature; selstr: string); override;
   end;

   // ���� �����ȿ� ���� ��Ÿ���� NPC(sonmg)
   THiddenNpc = class (TMerchant)
   private
   protected
      RunDone: Boolean;
      DigupRange: integer;
      DigdownRange: integer;
      procedure CheckComeOut; dynamic;
      procedure ComeOut; dynamic;
      procedure ComeDown; dynamic;
   public
      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
   end;

implementation

uses
   svMain, RunSock, LocalDB, ObjMon2, Castle;


constructor TNormNpc.Create;
begin
   inherited Create;
   NeverDie := TRUE;
   RaceServer := RC_NPC;
   Light := 2;
   AntiPoison := 99;
   //SayStrings := TStringList.Create;
   Sayings := TList.Create;
   StickMode := TRUE;
   DefineDirectory := '';
   BoInvisible := FALSE;
   BoUseMapFileName := TRUE;

   CanSell      := FALSE;
   CanBuy       := FALSE;
   CanStorage   := FALSE;
   CanGetBack   := FALSE;
   CanRepair    := FALSE;
   CanMakeDrug  := FALSE;
   CanUpgrade   := FALSE;
   CanMakeItem  := FALSE;
   CanItemMarket:= FALSE;

   CanSpecialRepair  := FALSE;
   CanTotalRepair    := FALSE;

   // ���� ���
   CanAgitUsage   := FALSE;
   CanAgitManage  := FALSE;
   CanBuyDecoItem := FALSE;

   // ��Ÿ
   CanDoingEtc    := FALSE;

   BoSoundPlaying := FALSE;
   SoundStartTime := GetTickCount;

   MemorialCount := 0;
end;

destructor TNormNpc.Destroy;
var
   i, j: integer;
begin
   //for i:=0 to SayStrings.Count-1 do
   //   TStringList(SayStrings.Objects[i]).Free;
   //SayStrings.Free;
   for i:=0 to Sayings.Count-1 do begin
      Dispose (PTQuestRecord(Sayings[i]));
      //PTQuestRecord ���� ���� Free���� ���� (���� �ؾ���)
   end;
   Sayings.Free;
   inherited Destroy;
end;

procedure TNormNpc.RunMsg (msg: TMessageInfo);
begin
   inherited RunMsg (msg);
end;

procedure TNormNpc.Run;
begin
   inherited Run;
end;

{procedure TNormNpc.ArrangeSayStrings;
var
   i, k: integer;
   strs: TStringList;
   ptq: PTQuestRecord;
begin
   //for i:=0 to SayStrings.Count-1 do begin
   //   strs := TStringList(SayStrings.Objects[i]);
   //   for k:=1 to strs.Count-1 do begin
   //      strs[0] := strs[0] + strs[k];
   //   end;
   //end;

end; }

procedure TNormNpc.ActivateNpcUtilitys (saystr: string);
var
   lwstr: string;
begin
   lwstr := LowerCase (saystr);
   if pos ('@buy', lwstr) > 0 then CanBuy := TRUE;
   if pos ('@sell', lwstr) > 0 then CanSell := TRUE;
   if pos ('@storage', lwstr) > 0 then CanStorage := TRUE;
   if pos ('@getback', lwstr) > 0 then CanGetBack := TRUE;
   if pos ('@repair', lwstr) > 0 then CanRepair := TRUE;
   if pos ('@makedrug', lwstr) > 0 then CanMakeDrug := TRUE;
   if pos ('@upgradenow', lwstr) > 0 then CanUpgrade := TRUE;
   if pos ('@s_repair', lwstr) > 0 then CanSpecialRepair := TRUE;
   if pos ('@t_repair', lwstr) > 0 then CanTotalRepair := TRUE;
   // ������ ����
   if pos ('@makefood', lwstr) > 0 then CanMakeItem := TRUE;
   if pos ('@makepotion', lwstr) > 0 then CanMakeItem := TRUE;
   if pos ('@makegem', lwstr) > 0 then CanMakeItem := TRUE;
   if pos ('@makeitem', lwstr) > 0 then CanMakeItem := TRUE;
   if pos ('@makestuff', lwstr) > 0 then CanMakeItem := TRUE;  //�����߰�(sonmg)
   if pos ('@makeetc', lwstr) > 0 then CanMakeItem := TRUE;  //�����߰�(sonmg)
   // ��Ź����
   if pos( '@market_', lwstr ) > 0 then CanItemMarket := TRUE;
   // �������
   if pos( '@agitreg', lwstr ) > 0 then CanAgitUsage := TRUE;
   if pos( '@agitmove', lwstr ) > 0 then CanAgitUsage := TRUE;
   if pos( '@agitbuy', lwstr ) > 0 then CanAgitUsage := TRUE;
   if pos( '@agittrade', lwstr ) > 0 then CanAgitUsage := TRUE;
   // �������(����)
   if pos( '@agitextend', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@agitremain', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@@agitonerecall', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@agitrecall', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@@agitforsale', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@agitforsalecancel', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@gaboardlist', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@@guildagitdonate', lwstr ) > 0 then CanAgitManage := TRUE;
   if pos( '@viewdonation', lwstr ) > 0 then CanAgitManage := TRUE;
   // ����ٹ̱�
   if pos( '@ga_decoitem_buy', lwstr ) > 0 then CanBuyDecoItem := TRUE;
   if pos( '@ga_decomon_count', lwstr ) > 0 then CanBuyDecoItem := TRUE;
   // ��ġ
   if pos( '@@freepkother', lwstr ) > 0 then CanDoingEtc := TRUE;
end;

function GetPP (str: string): integer;
var
   n: integer;
begin
   Result := -1;
   if Length(str) = 2 then begin
      if UpCase(str[1]) = 'P' then begin
         n := Str_ToInt (str[2], -1);
         if n in [0..9] then
            Result := n;
      end;
      if UpCase(str[1]) = 'G' then begin
         n := Str_ToInt (str[2], -1);
         if n in [0..9] then
            Result := 100 + n;
      end;
      if UpCase(str[1]) = 'D' then begin
         n := Str_ToInt (str[2], -1);
         if n in [0..9] then
            Result := 200 + n;
      end;
      if UpCase(str[1]) = 'M' then begin
         n := Str_ToInt (str[2], -1);
         if n in [0..9] then
            Result := 300 + n;
      end;
   end;
end;

procedure TNormNpc.NpcSay (target: TCreature; str: string);  //���� �� ����... �ϵ��ڵ� ���� �ʴ� ���� ����
begin
   str := ReplaceChar (str, '\', char($a));
	target.SendMsg (self, RM_MERCHANTSAY, 0, 0, 0, 0, UserName + '/' + str);
end;

function TNormNpc.ChangeNpcSayTag (src, orgstr, chstr: string): string;
var
   n: integer;
   src1, src2: string;
begin
   n := pos(orgstr, src);
   if n > 0 then begin
      src1 := Copy(src, 1, n-1);
      src2 := Copy(src, n+Length(orgstr), Length(src));
      Result := src1 + chstr + src2;
   end else
      Result := src;
end;

procedure TNormNpc.CheckNpcSayCommand (hum: TUserHuman; var source: string; tag: string);
var
   data, str2: string;
   n: integer;
begin
   if tag = '$OWNERGUILD' then begin
      data := UserCastle.OwnerGuildName;
      if data = '' then data := 'GameManagerconsultation';
      source := ChangeNpcSayTag (source, '<$OWNERGUILD>', data);
   end;
   if tag = '$LORD' then begin
      if UserCastle.OwnerGuild <> nil then begin
         data := UserCastle.OwnerGuild.GetGuildMaster;
      end else begin
         {$IFDEF KOREA} data := 'Ԥ��';
         {$ELSE}        data := 'Ԥ��';
         {$ENDIF}
      end;
      source := ChangeNpcSayTag (source, '<$LORD>', data);
   end;
   if tag = '$GUILDWARFEE' then begin
      source := ChangeNpcSayTag (source, '<$GUILDWARFEE>', GetGoldStr(GUILDWARFEE));
   end;
   if tag = '$GUILDWARTIME' then begin
      source := ChangeNpcSayTag (source, '<$GUILDWARTIME>', IntToStr(GUILDWARTIME));
   end;
   if tag = '$CASTLEWARDATE' then begin
      if not UserCastle.BoCastleUnderAttack then begin
         data := UserCastle.GetNextWarDateTimeStr;
         if data <> '' then begin
            source := ChangeNpcSayTag (source, '<$CASTLEWARDATE>', data);
         end else begin
            {$IFDEF KOREA} source := '������û�й���ս\ \<����/@main> ';
            {$ELSE}        source := '������û�й���ս\ \<����/@main> ';
            {$ENDIF}
         end;
      end else begin
         {$IFDEF KOREA} source := '���ڹ����У�\ \<����/@main>';
         {$ELSE}        source := '���ڹ����У�\ \<����/@main>';
         {$ENDIF}
      end;
      source := ReplaceChar (source, '\', char($a));
   end;
   if tag = '$LISTOFWAR' then begin
      data := UserCastle.GetListOfWars;  //��� ���� ����
      if data <> '' then begin
         source := ChangeNpcSayTag (source, '<$LISTOFWAR>', data);
      end else begin
         {$IFDEF KOREA} source := '����δȷ��ʱ�䡭��\ \<����/@main>';
         {$ELSE}        source := '����δȷ��ʱ�䡭��\ \<����/@main';
         {$ENDIF}
      end;
      source := ReplaceChar (source, '\', char($a));
   end;
   if tag = '$USERNAME' then begin
      source := ChangeNpcSayTag (source, '<$USERNAME>', hum.UserName);
   end;

   if tag = '$PKTIME' then begin
      source := ChangeNpcSayTag (source, '<$PKTIME>',hum.GetPKTimeMin);
   end;
   //���� ���� ����
   if tag = '$SAVEITEM' then begin
      source := ChangeNpcSayTag (source, '<$SAVEITEM>', IntToStr(hum.SaveItems.Count));
   end;
   if tag = '$REMAINSAVEITEM' then begin
      source := ChangeNpcSayTag (source, '<$REMAINSAVEITEM>', IntToStr(MAXSAVELIMIT - hum.SaveItems.Count));
   end;
   if tag = '$MAXSAVEITEM' then begin
      source := ChangeNpcSayTag (source, '<$MAXSAVEITEM>', IntToStr(MAXSAVELIMIT));
   end;

   if tag = '$GAMEGOLD' then begin
      source := ChangeNpcSayTag (source, '<$GAMEGOLD>', IntToStr(hum.PotCash));
   end;

   //���� ���.
   if tag = '$GUILDAGITREGFEE' then begin
      source := ChangeNpcSayTag (source, '<$GUILDAGITREGFEE>', GetGoldStr(GUILDAGITREGFEE));
   end;
   if tag = '$GUILDAGITEXTENDFEE' then begin
      source := ChangeNpcSayTag (source, '<$GUILDAGITEXTENDFEE>', GetGoldStr(GUILDAGITEXTENDFEE));
   end;
   if tag = '$GUILDAGITMAXGOLD' then begin
      source := ChangeNpcSayTag (source, '<$GUILDAGITMAXGOLD>', GetGoldStr(GUILDAGITMAXGOLD));
   end;
   //����ٹ̱�.
   if tag = '$AGITGUILDNAME' then begin
      source := ChangeNpcSayTag (source, '<$AGITGUILDNAME>', hum.GetGuildNameHereAgit);
   end;
   if tag = '$AGITGUILDMASTER' then begin
      source := ChangeNpcSayTag (source, '<$AGITGUILDMASTER>', hum.GetGuildMasterNameHereAgit);
   end;

   if tag = '$MEMORIALCOUNT' then begin
      source := ChangeNpcSayTag (source, '<$MEMORIALCOUNT>', IntToStr(MemorialCount));
   end;

   if CompareLStr (tag, '$STR(', 5)  then begin
      ArrestStringEx (tag, '(', ')', str2);
      n := GetPP (str2);
      if n >= 0 then begin
         case n of
            0..9:       source := ChangeNpcSayTag (source, '<'+tag+'>', IntToStr(TUserHuman(hum).QuestParams[n]));
            100..109:   source := ChangeNpcSayTag (source, '<'+tag+'>', IntToStr(GrobalQuestParams[n-100]));
            200..209:   source := ChangeNpcSayTag (source, '<'+tag+'>', IntToStr(TUserHuman(hum).DiceParams[n-200]));
            300..309:   source := ChangeNpcSayTag (source, '<'+tag+'>', IntToStr(PEnvir.MapQuestParams[n-300]));
            400..409:   source := ChangeNpcSayTag (source, '<'+tag+'>', TUserHuman(hum).StringParams[n-400]);
            500..509:   source := ChangeNpcSayTag (source, '<'+tag+'>', GrobalStringParams[n-500]);
         end;
      end;
   end;
end;

procedure ReadStrings (flname: string; strlist: TStringList);
var
   f: TextFile;
   str: string;
begin
   strlist.Clear;
   {$I-}
   AssignFile (f, flname);
   FileMode := 0;  {Set file access to read only }
   Reset (f);
   while not EOF(f) do begin
      ReadLn (f, str);
      strlist.Add (str);
   end;
   CloseFile (f);
   //IOResult
   {$I+}
end;

procedure WriteStrings (flname: string; strlist: TStringList);
var
   f: TextFile;
   str: string;
   i: integer;
begin
   {$I-}
   AssignFile (f, flname);
   //FileMode := 2;  {Set file access to read only }
   Rewrite (f);
   for i:=0 to strlist.Count-1 do begin
      WriteLn (f, strlist[i]);
   end;
   CloseFile (f);
   //IOResult
   {$I+}
end;

procedure TNormNpc.NpcSayTitle (who: TCreature; title: string);
var
   latesttakeitem: string;
   pcheckitem, puTemp: PTUserItem;
   batchlist: TStringList;
   batchdelay, previousbatchdelay: integer;
   bosaynow: Boolean;

   //6-11
   function CheckNameAndDeleteFromFileList (uname, listfile: string): Boolean;
   var
      i: integer;
      str: string;
      strlist: TStringList;
   begin
      Result := FALSE;
      listfile := EnvirDir + listfile;
      if FileExists (listfile) then begin
         strlist := TStringList.Create;
         try
            ReadStrings (listfile, strlist);
         except
            MainOutMessage ('loading fail.... => ' + listfile);
         end;
         for i:=0 to strlist.Count-1 do begin
            str := Trim(strlist[i]);
            if str = uname then begin
               strlist.Delete (i);
               Result := TRUE;
               break;
            end;
         end;
         try
            WriteStrings (listfile, strlist);
         except
            MainOutMessage ('saving fail.... => ' + listfile);
         end;
         strlist.Free;
      end else
         MainOutMessage ('file not found => ' + listfile);
   end;
   //6-11
   function CheckNameFromFileList (uname, listfile: string): Boolean;
   var
      i: integer;
      str: string;
      strlist: TStringList;
   begin
      Result := FALSE;
      listfile := EnvirDir + listfile;
      if FileExists (listfile) then begin
         strlist := TStringList.Create;
         try
            ReadStrings (listfile, strlist);
         except
            MainOutMessage ('loading fail.... => ' + listfile);
         end;
         for i:=0 to strlist.Count-1 do begin
            str := Trim(strlist[i]);
            if str = uname then begin
               Result := TRUE;
               break;
            end;
         end;
         strlist.Free;
      end else
         MainOutMessage ('file not found => ' + listfile);
   end;
   //6-11
   procedure AddNameFromFileList (uname, listfile: string);
   var
      i: integer;
      str: string;
      strlist: TStringList;
      flag: Boolean;
   begin
      listfile := EnvirDir + listfile;
      strlist := TStringList.Create;
      if FileExists (listfile) then begin
         try
            ReadStrings (listfile, strlist);
         except
            MainOutMessage ('loading fail.... => ' + listfile);
         end;
      end;

      //flag := FALSE;
      //for i:=0 to strlist.Count-1 do begin
      //   str := Trim(strlist[i]);
      //   if str = uname then begin
      //      flag := TRUE;
      //      break;
      //   end;
      //end;
      //if not flag then   //������ �߰� ����

      strlist.Add (uname);

      try
         WriteStrings (listfile, strlist);
      except
         MainOutMessage ('saving fail.... => ' + listfile);
      end;
      strlist.Free;
   end;
   //6-11
   procedure DeleteNameFromFileList (uname, listfile: string);
   var
      i: integer;
      str: string;
      strlist: TStringList;
   begin
      listfile := EnvirDir + listfile;
      if FileExists (listfile) then begin
         strlist := TStringList.Create;
         try
            ReadStrings (listfile, strlist);
         except
            MainOutMessage ('loading fail.... => ' + listfile);
         end;
         for i:=0 to strlist.Count-1 do begin
            str := Trim(strlist[i]);
            if str = uname then begin
               strlist.Delete (i);
               break;
            end;
         end;
         try
            WriteStrings (listfile, strlist);
         except
            MainOutMessage ('saving fail.... => ' + listfile);
         end;
         strlist.Free;
      end else
         MainOutMessage ('file not found => ' + listfile);
   end;
   procedure ActionOfAddSkill (who: TCreature; magname: string; lv: integer);
   var
     I: Integer;
     hum : TUserHuman;
     pum: pTUserMagic;
     nLevel: Integer;
   begin
     nLevel := _MIN(3, lv);
     for i:=UserEngine.DefMagicList.Count-1 downto 0 do begin
       if CompareText (PTDefMagic(UserEngine.DefMagicList[i]).MagicName, magname) = 0 then begin
         if not who.IsMyMagic(PTDefMagic(UserEngine.DefMagicList[i]).MagicId) then begin
           New(pum);
           pum.pDef := PTDefMagic(UserEngine.DefMagicList[i]);
           pum.MagicId := PTDefMagic(UserEngine.DefMagicList[i]).MagicId;
           pum.Key := #0;
           pum.Level := nLevel;
           pum.CurTrain := 0;
           who.MagicList.Add(pum);

           if who.RaceServer = RC_USERHUMAN then begin
             hum := TUserHuman (who);
             hum.SendAddMagic (pum);
           end;

           who.RecalcAbilitys();
           who.SysMsg(PTDefMagic(UserEngine.DefMagicList[i]).MagicName + '��ϰ�ɹ�. ', 1);
         end;
         Break;
       end;
     end
   end;

   procedure ActionOfDelSkill (who: TCreature; magname: string);
   var
     I: Integer;
     hum : TUserHuman;
     pum: pTUserMagic;
     nLevel: Integer;
     nMagicCount: Integer;
   begin
     for I := who.MagicList.Count - 1 downto 0 do begin
       if who.MagicList.Count <= 0 then Break;
       pum := who.MagicList.Items[I];
       if CompareText ('ALL', magname) = 0 then begin
         if who.RaceServer = RC_USERHUMAN then begin
           TUserHuman(who).SendDelMagic(pum);
         end;
         who.MagicList.Delete(I);
         Dispose(pum);
         who.RecalcAbilitys();
       end else begin
         if CompareText (pum.pDef.MagicName, magname) = 0 then begin
           if who.IsMyMagic(pum.pDef.MagicId) then begin
             if who.RaceServer = RC_USERHUMAN then
               TUserHuman(who).SendDelMagic(pum);

             who.MagicList.Delete(I);
             Dispose(pum);
             who.RecalcAbilitys();
             Break;
           end;
         end;
       end;
     end;
   end;
   procedure ActionOfRepairAllItem (who: TCreature; pq: PTQuestActioninfo);
   var
     i: Integer;
     boIsHasItem: Boolean;
     sUserItemName : string;
     ps: PTStdItem;
   begin
     with who do begin
       for i := Low(UseItems) to High(UseItems) do begin
         if UseItems[i].Index <= 0 then  Continue;
         sUserItemName := UserEngine.GetStdItemName(UseItems[i].Index);
         ps := UserEngine.GetStdItem (UseItems[i].Index);

         if (ps.UniqueItem and $02) <> 0 then begin
           SysMsg(sUserItemName + ' ��ֹ����', 0);
           Continue;
         end;
         UseItems[i].Dura := UseItems[i].DuraMax;
         SendMsg(Self, RM_DURACHANGE, i, UseItems[i].Dura, UseItems[i].DuraMax, 0, '');
         boIsHasItem := True;
       end;
       if boIsHasItem then SysMsg('ȫ����Ʒ����ȫ�޸�', 1);
     end;
   end;
   function  CheckQuestCondition (pq: PTQuestRecord): Boolean;
   var
      i: integer;
   begin
      Result := TRUE;
      if pq.BoRequire then begin
         for i:=0 to MAXREQUIRE-1 do begin
            if pq.QuestRequireArr[i].RandomCount > 0 then begin
               if Random (pq.QuestRequireArr[i].RandomCount) <> 0 then begin
                  Result := FALSE;
                  break;
               end;
            end;
            if who.GetQuestMark (pq.QuestRequireArr[i].CheckIndex) <> pq.QuestRequireArr[i].CheckValue then begin
               Result := FALSE;
               break;
            end;
         end;
      end;
   end;
   function FindItemFromState (iname: string; count: integer): PTUserItem;
   var
      n: integer;
   begin
      Result := nil;
      if CompareLStr (iname, '[NECKLACE]', 4) then begin
         if who.UseItems[U_NECKLACE].Index > 0 then
            Result := @(who.UseItems[U_NECKLACE]);
         exit;
      end;
      if CompareLStr (iname, '[RING]', 4) then begin
         if who.UseItems[U_RINGL].Index > 0 then
            Result := @(who.UseItems[U_RINGL]);
         if who.UseItems[U_RINGR].Index > 0 then
            Result := @(who.UseItems[U_RINGR]);
         exit;
      end;
      if CompareLStr (iname, '[ARMRING]', 4) then begin
         if who.UseItems[U_ARMRINGL].Index > 0 then
            Result := @(who.UseItems[U_ARMRINGL]);
         if who.UseItems[U_ARMRINGR].Index > 0 then
            Result := @(who.UseItems[U_ARMRINGR]);
         exit;
      end;
      if CompareLStr (iname, '[WEAPON]', 4) then begin
         if who.UseItems[U_WEAPON].Index > 0 then
            Result := @(who.UseItems[U_WEAPON]);
         exit;
      end;
      if CompareLStr (iname, '[HELMET]', 4) then begin
         if who.UseItems[U_HELMET].Index > 0 then
            Result := @(who.UseItems[U_HELMET]);
         exit;
      end;
      // 2003/03/15 COPARK ������ �κ��丮 Ȯ��
      if CompareLStr (iname, '[BUJUK]', 4) then begin
         if who.UseItems[U_BUJUK].Index > 0 then
            Result := @(who.UseItems[U_BUJUK]);
         exit;
      end;
      if CompareLStr (iname, '[BELT]', 4) then begin
         if who.UseItems[U_BELT].Index > 0 then
            Result := @(who.UseItems[U_BELT]);
         exit;
      end;
      if CompareLStr (iname, '[BOOTS]', 4) then begin
         if who.UseItems[U_BOOTS].Index > 0 then
            Result := @(who.UseItems[U_BOOTS]);
         exit;
      end;
      if CompareLStr (iname, '[CHARM]', 4) then begin
         if who.UseItems[U_CHARM].Index > 0 then
            Result := @(who.UseItems[U_CHARM]);
         exit;
      end;

      Result := who.FindItemWear (iname, n);
      if n < count then
         Result := nil;
   end;
   function  CheckSayingCondition (clist: TList): Boolean;
   var
      i, k, m, n, param, tag, count, durasum, duratop: integer;
      ahour, amin, asec, amsec: word;
      pqc: PTQuestConditionInfo;
      pitem: PTUserItem;
      ps: PTStdItem;
      penv: TEnvirnoment;
      hum: TUserHuman;
      nFame: integer;
      WarriorCount, WizardCount, TaoistCount: integer;
      equalvar: integer;
      CheckMap: string;
      cret: TCreature;
      list: TList;
      flag: Boolean;
   begin
      Result := TRUE;

      for i:=0 to clist.Count-1 do begin
         pqc := PTQuestConditionInfo (clist[i]);
         case pqc.IfIdent of
            QI_CHECK:
               begin
                  param := Str_ToInt (pqc.IfParam, 0);
                  tag := Str_ToInt (pqc.IfTag, 0);
                  n := who.GetQuestMark (param);
                  if n = 0 then begin
                     if tag <> 0 then Result := FALSE;
                  end else
                     if tag = 0 then Result := FALSE;
               end;
            QI_CHECKOPENUNIT:
               begin
                  param := Str_ToInt (pqc.IfParam, 0);
                  tag := Str_ToInt (pqc.IfTag, 0);
                  n := who.GetQuestOpenIndexMark (param);
                  if n = 0 then begin
                     if tag <> 0 then Result := FALSE;
                  end else
                     if tag = 0 then Result := FALSE;
               end;
            QI_CHECKUNIT:
               begin
                  param := Str_ToInt (pqc.IfParam, 0);
                  tag := Str_ToInt (pqc.IfTag, 0);
                  n := who.GetQuestFinIndexMark (param);
                  if n = 0 then begin
                     if tag <> 0 then Result := FALSE;
                  end else
                     if tag = 0 then Result := FALSE;
               end;
            QI_RANDOM:
               begin
                  if Random(pqc.IfParamVal) <> 0 then Result := FALSE;
               end;
            QI_GENDER:
               begin
                  if CompareText (pqc.IfParam, 'MAN') = 0 then begin  //�䱸�� ����
                     if who.Sex <> 0 then Result := FALSE;
                  end else begin //
                     if who.Sex <> 1 then Result := FALSE;
                  end;
               end;
            QI_DAYTIME:
               begin
                  if CompareText (pqc.IfParam, 'SUNRAISE') = 0 then begin
                     if MirDayTime <> 0 then Result := FALSE;
                  end;
                  if CompareText (pqc.IfParam, 'DAY') = 0 then begin
                     if MirDayTime <> 1 then Result := FALSE;
                  end;
                  if CompareText (pqc.IfParam, 'SUNSET') = 0 then begin
                     if MirDayTime <> 2 then Result := FALSE;
                  end;
                  if CompareText (pqc.IfParam, 'NIGHT') = 0 then begin
                     if MirDayTime <> 3 then Result := FALSE;
                  end;
               end;
            QI_DAYOFWEEK:
               begin
                  if CompareLStr (pqc.IfParam, 'Sun', 3) then
                     if DayOfWeek(Date) <> 1 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Mon', 3) then
                     if DayOfWeek(Date) <> 2 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Tue', 3) then
                     if DayOfWeek(Date) <> 3 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Wed', 3) then
                     if DayOfWeek(Date) <> 4 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Thu', 3) then
                     if DayOfWeek(Date) <> 5 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Fri', 3) then
                     if DayOfWeek(Date) <> 6 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Sat', 3) then
                     if DayOfWeek(Date) <> 7 then Result := FALSE;
               end;
            QI_TIMEHOUR:
               begin
                  if (pqc.IfParamVal <> 0) and (pqc.IfTagVal = 0) then
                     pqc.IfTagVal := pqc.IfParamVal;
                  DecodeTime (Time, ahour, amin, asec, amsec);
                  if not ((ahour >= pqc.IfParamVal) and (ahour <= pqc.IfTagVal)) then
                     Result := FALSE;
               end;
            QI_TIMEMIN:
               begin
                  if (pqc.IfParamVal <> 0) and (pqc.IfTagVal = 0) then
                     pqc.IfTagVal := pqc.IfParamVal;
                  DecodeTime (Time, ahour, amin, asec, amsec);
                  if not ((amin >= pqc.IfParamVal) and (amin <= pqc.IfTagVal)) then
                     Result := FALSE;
               end;

            QI_CHECKITEM:
               begin
                  pcheckitem := who.FindItemNameEx (pqc.IfParam, count, durasum, duratop);
                  if count < pqc.IfTagVal then
                     Result := FALSE;
               end;
            QI_CHECKITEMW:
               begin
                  pcheckitem := FindItemFromState (pqc.IfParam, pqc.IfTagVal);
                  if pcheckitem = nil then
                     Result := FALSE;
               end;
            QI_CHECKGOLD:
               begin
                  if who.Gold < pqc.ifParamVal then
                     Result := FALSE;
               end;
            QI_ISTAKEITEM:
               begin
                  if latesttakeitem <> pqc.IfParam then
                     Result := FALSE;
               end;
            QI_CHECKLEVEL:
               begin
                  if who.Abil.Level < pqc.IfParamVal then
                     Result := FALSE;
               end;
            QI_CHECKJOB:
               begin
                  if CompareLStr (pqc.IfParam, 'Warrior', 3) then
                     if who.Job <> 0 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Wizard', 3) then
                     if who.Job <> 1 then Result := FALSE;
                  if CompareLStr (pqc.IfParam, 'Taoist', 3) then
                     if who.Job <> 2 then Result := FALSE;
               end;
            QI_CHECKDURA:
               begin
                  pcheckitem := who.FindItemNameEx (pqc.IfParam, count, durasum, duratop);
                  if Round(duratop/1000) < pqc.IfTagVal then
                     Result := FALSE;
               end;
            QI_CHECKDURAEVA:
               begin
                  pcheckitem := who.FindItemNameEx (pqc.IfParam, count, durasum, duratop);
                  if count > 0 then begin
                     if Round((durasum/count)/1000) < pqc.IfTagVal then
                        Result := FALSE;
                  end else
                     Result := FALSE;
               end;
            QI_CHECKPKPOINT:
               begin
                  if who.PKLevel < pqc.IfParamVal then
                     Result := FALSE;
               end;
            QI_CHECKLUCKYPOINT:
               begin
                  if who.BodyLuckLevel < pqc.IfParamVal then
                     Result := FALSE;
               end;
            QI_CHECKMON_MAP:
               begin
                  penv := GrobalEnvir.GetEnvir (pqc.IfParam);
                  if penv <> nil then
                     if UserEngine.GetMapMons (penv, nil) < pqc.IfTagVal then
                        Result := FALSE;
               end;
            QI_CHECKMON_NORECALLMOB_MAP:
               begin
                  penv := GrobalEnvir.GetEnvir (pqc.IfParam);
                  if penv <> nil then
                     if UserEngine.GetMapMonsNoRecallMob (penv, nil) < pqc.IfTagVal then
                        Result := FALSE;
               end;
            QI_CHECKMON_AREA:
               begin
               end;
            QI_CHECKHUM:
               begin
                  if UserEngine.GetHumCount (pqc.IfParam) < pqc.IfTagVal then
                     Result := FALSE;
               end;
            QI_CHECKBAGGAGE:
               begin
                  if who.CanAddItem then begin
                     if pqc.IfParam <> '' then begin
                        Result := FALSE;
                        ps := UserEngine.GetStdItemFromName (pqc.IfParam);
                        if ps <> nil then begin
                           if who.IsAddWeightAvailable (ps.Weight) then
                              Result := TRUE;
                        end;
                     end;
                  end else
                     Result := FALSE;
               end;
            //6-11
            QI_CHECKANDDELETENAMELIST:
               begin
                  if not CheckNameAndDeleteFromFileList (who.UserName, NpcBaseDir + pqc.IfParam{filename}) then
                     Result := FALSE;
               end;
            //6-11
            QI_CHECKANDDELETEIDLIST:
               begin
                  hum := TUserHuman (who);
                  if not CheckNameAndDeleteFromFileList (hum.UserId, NpcBaseDir + pqc.IfParam{filename}) then
                     Result := FALSE;
               end;
            //6-11
            QI_CHECKNAMELIST:
               begin
                  if not CheckNameFromFileList (who.UserName, NpcBaseDir + pqc.IfParam{filename}) then
                     Result := FALSE;
               end;

            //*dq
            QI_IFGETDAILYQUEST:
               begin
                  if who.GetDailyQuest <> 0 then
                     Result := FALSE;
               end;
            //*dq
            QI_RANDOMEX:
               begin
                  if Random(pqc.IfTagVal) >= pqc.IfParamVal then
                     Result := FALSE;
               end;
            //*dq
            QI_CHECKDAILYQUEST:
               begin
                  if who.GetDailyQuest <> pqc.IfParamVal then
                     Result := FALSE;
               end;

            QI_CHECKGRADEITEM:   //Event Grade
               begin
                  //------------------------------------------------------------
                  // IfParamVal : �̺�Ʈ ������ ���
                  // IfTagVal   : ���� ������ ����(ī��Ʈ �������� �ϳ��� ����)
                  // ���� ����� �������� ���� ���� �̻� ������ �ִ��� �˻��ؼ�
                  // ������ TRUE, ������ FALSE�� ������.
                  //------------------------------------------------------------
                  if who.FindItemEventGrade (pqc.IfParamVal, pqc.IfTagVal) = FALSE then
                     Result := FALSE;
               end;
            QI_CHECKBAGREMAIN:  // ����â�� Parameter ������ŭ ���� �ִ���
               begin
                  if who.CanAddItem then begin
                     if pqc.IfParamVal > 0 then begin
                        Result := FALSE;
                        if (MAXBAGITEM - who.ItemList.Count) >= pqc.IfParamVal then begin
                           Result := TRUE;
                        end;
                     end;
                  end else
                     Result := FALSE;
               end;

            QI_EQUALVAR:
               begin
                  equalvar := 0;
                  n := GetPP (pqc.IfParam);
                  m := GetPP (pqc.IfTag);
                  if m >= 0 then begin
                     case m of
                        0..9:
                           equalvar := TUserHuman(who).QuestParams[m];
                        100..109:
                           equalvar := GrobalQuestParams[m-100];
                        200..209:
                           equalvar := TUserHuman(who).DiceParams[m-200];
                        300..309:
                           equalvar := PEnvir.MapQuestParams[m-300];
                     end;
                  end;
                  if n >= 0 then begin
                     case n of
                        0..9:
                           if TUserHuman(who).QuestParams[n] <> equalvar then
                              Result := FALSE;
                        100..109:
                           //��������
                           if GrobalQuestParams[n-100] <> equalvar then
                              Result := FALSE;
                        200..209:
                           if TUserHuman(who).DiceParams[n-200] <> equalvar then
                              Result := FALSE;
                        300..309:
                           //����������
                           if PEnvir.MapQuestParams[n-300] <> equalvar then
                              Result := FALSE;
                     end;
                  end else
                     Result := FALSE;
               end;

            QI_EQUAL:
               begin
                  n := GetPP (pqc.IfParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           if TUserHuman(who).QuestParams[n] <> pqc.IfTagVal then
                              Result := FALSE;
                        100..109:
                           //��������
                           if GrobalQuestParams[n-100] <> pqc.IfTagVal then
                              Result := FALSE;
                        200..209:
                           if TUserHuman(who).DiceParams[n-200] <> pqc.IfTagVal then
                              Result := FALSE;
                        300..309:
                           //����������
                           if PEnvir.MapQuestParams[n-300] <> pqc.IfTagVal then
                              Result := FALSE;
                     end;
                  end else
                     Result := FALSE;
               end;
            QI_LARGE:
               begin
                  n := GetPP (pqc.IfParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           if TUserHuman(who).QuestParams[n] <= pqc.IfTagVal then
                              Result := FALSE;
                        100..109:
                           if GrobalQuestParams[n-100] <= pqc.IfTagVal then
                              Result := FALSE;
                        200..209:
                           if TUserHuman(who).DiceParams[n-200] <= pqc.IfTagVal then
                              Result := FALSE;
                        300..309:
                           if PEnvir.MapQuestParams[n-300] <= pqc.IfTagVal then
                              Result := FALSE;
                     end;
                  end else
                     Result := FALSE;
               end;
            QI_SMALL:
               begin
                  n := GetPP (pqc.IfParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           if TUserHuman(who).QuestParams[n] >= pqc.IfTagVal then
                              Result := FALSE;
                        100..109:
                           if GrobalQuestParams[n-100] >= pqc.IfTagVal then
                              Result := FALSE;
                        200..209:
                           if TUserHuman(who).DiceParams[n-200] >= pqc.IfTagVal then
                              Result := FALSE;
                        300..309:
                           if PEnvir.MapQuestParams[n-300] >= pqc.IfTagVal then
                              Result := FALSE;
                     end;
                  end else
                     Result := FALSE;
               end;
            QI_ISGROUPOWNER:
               begin
                  //�ڽ��� GroupOwner���� �˻�.
                  Result := FALSE;
                  if who <> nil then begin
                     if who.GroupOwner <> nil then begin
                        if who.GroupOwner = who then
                           Result := TRUE;
                     end;
                  end;
               end;
            QI_ISEXPUSER:
               begin
                  //�ڽ��� ü���� �������� �˻��Ѵ�.
                  Result := FALSE;
                  hum := TUserHuman (who);
                  if hum <> nil then begin
                     if hum.ApprovalMode = 1 then
                        Result := TRUE;
                  end;
               end;
            QI_CHECKLOVERFLAG:
               begin
                  if TUserHuman(who).fLover <> nil then begin
                     hum := UserEngine.GetUserHuman(TUserHuman(who).fLover.GetLoverName);
                     if hum <> nil then begin
                        param := Str_ToInt (pqc.IfParam, 0);
                        tag := Str_ToInt (pqc.IfTag, 0);
                        n := hum.GetQuestMark (param);
                        if n = 0 then begin
                           if tag <> 0 then Result := FALSE;
                        end else
                           if tag = 0 then Result := FALSE;
                     end else begin
                        Result := FALSE;
                     end;
                  end else begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKLOVERRANGE:
               begin
                  if TUserHuman(who).fLover <> nil then begin
                     hum := UserEngine.GetUserHuman(TUserHuman(who).fLover.GetLoverName);
                     if hum <> nil then begin
                        param := Str_ToInt (pqc.IfParam, 0);
                        if not( (abs(who.CX - hum.CX) <= param) and (abs(who.CY - hum.CY) <= param) ) then
                           Result := FALSE;
                     end else begin
                        Result := FALSE;
                     end;
                  end else begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKLOVERDAY:
               begin
                  if TUserHuman(who).fLover <> nil then begin
                     param := Str_ToInt( pqc.IfParam, 0 );
                     if Str_ToInt( TUserHuman(who).fLover.GetLoverDays, 0 ) < param then
                        Result := FALSE;
                  end else begin
                     Result := FALSE;
                  end;
               end;
            //��ġ
            QI_CHECKFAMEGRADE:
               begin
                  TUserHuman(who).GetFameName(nFame);
                  if nFame < pqc.IfParamVal then begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKFAMEPOINT:
               begin
                  nFame := TUserHuman(who).Abil.FameCur;
                  if nFame < pqc.IfParamVal then begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKFAMEBASEPOINT:
               begin
                  nFame := TUserHuman(who).Abil.FameBase;
                  if nFame < pqc.IfParamVal then begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKDONATION:
               begin
                  if TUserHuman(who).GetGuildAgitDonation < pqc.IfParamVal then
                     Result := FALSE;
               end;
            QI_ISGUILDMASTER:
               begin
                  if not who.IsGuildMaster then
                     Result := FALSE;
               end;
            QI_CHECKWEAPONBADLUCK:
               begin
                  if who.UseItems[U_WEAPON].Index <> 0 then begin
                     if not (who.UseItems[U_WEAPON].Desc[4] - who.UseItems[U_WEAPON].Desc[3] > 0) then begin //���ְ� �پ����� ��
                        Result := FALSE;
                     end;
                  end;
               end;
            QI_CHECKPREMIUMGRADE:
               begin
                  if who.PremiumGrade <> pqc.IfParamVal then begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKCHILDMOB:
               begin
                  if who.GetExistSlave(pqc.IfParam) = nil then begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKGROUPJOBBALANCE:
               begin
                  WarriorCount := 0;
                  WizardCount := 0;
                  TaoistCount := 0;
                  CheckMap := '';
                  for k:=0 to who.GroupMembers.Count-1 do begin
                     hum := UserEngine.GetUserHuman (who.GroupMembers[k]);
                     if hum <> nil then begin
                        //���� �ʿ� �ִ��� üũ
                        if CheckMap = '' then begin
                           CheckMap := hum.MapName;
                        end else begin
                           if CheckMap <> hum.MapName then begin
                              Result := FALSE;
                           end;
                        end;

                        if hum.Job = 0 then begin
                           Inc(WarriorCount);
                        end else if hum.Job = 1 then begin
                           Inc(WizardCount);
                        end else if hum.Job = 2 then begin
                           Inc(TaoistCount);
                        end;
                     end;
                  end;
                  if not( (WarriorCount = pqc.IfParamVal) and (WizardCount = pqc.IfParamVal) and (TaoistCount = pqc.IfParamVal) ) then begin
                     Result := FALSE;
                  end;
               end;
            QI_CHECKRANGEONELOVER:
               begin
                  //�ֺ��� ���� ���� ����� �ִ��� üũ
                  flag := FALSE;
                  list := TList.Create;
                  //������Ʈ�� ���� PEnvir ��ſ� who.PEnvir�� ����Ѵ�.
                  who.PEnvir.GetCreatureInRange (who.CX, who.CY, pqc.IfParamVal, TRUE, list);
                  for k:=0 to list.Count-1 do begin
                     cret := TCreature(list[k]);
                     if (cret <> nil) and (cret.RaceServer = RC_USERHUMAN) then begin
                        hum := TUserHuman(cret);
                        if (hum.fLover <> nil) and (hum.fLover.GetLoverName <> '') and (hum <> who) then begin
                           flag := TRUE;
                           break;
                        end;
                     end;
                  end;
                  list.Free;

                  if not flag then begin
                     Result := FALSE;
                  end;
               end;
            QI_EVENTCHECK: //ComeBack2005 �̺�Ʈ üũ
               begin
                  if not who.EventCheckFlag then Result := FALSE;
               end;
            QI_CHECKITEMWVALUE: //�������� ���� ������ ���ġ üũ
               begin
                  flag := FALSE;
                  pitem := FindItemFromState (pqc.IfParam, 1);
                  if pitem <> nil then begin
                     ps := UserEngine.GetStdItem(pitem.Index);
                     if ps <> nil then begin
                        if ps.Shape = PAIN_SERIES_SHAPE then begin
                           if pitem.Desc[10] >= pqc.IfTagVal then begin
                              flag := TRUE;
                           end;
                        end;
                     end;
                  end;

                  if not flag then
                     Result := FALSE;
               end;
            QI_CHECKFREEMODE:
               begin
                  if TUserHuman(who).ApprovalMode = 1 then begin
                     Result := true;
                  end else
                     Result := FALSE;
               end;
            //����ǲ�������
            QI_ISNEWHUMAN:
               begin
                 Result := TUserHuman(who).FirstTimeConnection;
               end;
            //�������ȼ���չ����
            QI_CHECKLEVELEX:
               begin
                 if pqc.IfParam = '>' then begin
                   Result := who.Abil.Level > pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '>=' then begin
                   Result := who.Abil.Level >= pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '<' then begin
                   Result := who.Abil.Level < pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '<=' then begin
                   Result := who.Abil.Level <= pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '=' then begin
                   Result := who.Abil.Level = pqc.IfTagVal;
                 end;
               end;
            QI_CHECKGAMEGOLD:
               begin
                 if pqc.IfParam = '>' then begin
                   Result := who.PotCash > pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '>=' then begin
                   Result := who.PotCash >= pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '<' then begin
                   Result := who.PotCash < pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '<=' then begin
                   Result := who.PotCash <= pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '=' then begin
                   Result := who.PotCash = pqc.IfTagVal;
                 end;
//                  if who.PotCash < pqc.ifParamVal then
//                     Result := FALSE;
               end;
            QI_CHECKIDLIST:
               begin
                 if not CheckNameFromFileList (TUserHuman(who).UserId, pqc.IfParam{filename}) then
                    Result := FALSE;
               end;
            QI_CHECKSLAVECOUNT:
               begin
                 if pqc.IfParam = '>' then begin
                   Result := who.SlaveList.Count > pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '>=' then begin
                   Result := who.SlaveList.Count >= pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '<' then begin
                   Result := who.SlaveList.Count < pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '<=' then begin
                   Result := who.SlaveList.Count <= pqc.IfTagVal;
                 end;
                 if pqc.IfParam = '=' then begin
                   Result := who.SlaveList.Count = pqc.IfTagVal;
                 end;
               end;
            QI_CHECKLEVELRANGE:
               begin
                 param := Str_ToInt( pqc.IfParam, 0);
                 Result := who.Abil.Level in [param..pqc.IfTagVal];
               end;
            QI_ISADMIN:
               begin
                  if not (who.UserDegree >= 8) then Result := False;
               end;
            QI_HASGUILD:
               begin
                 if who.MyGuild = nil then Result := False;
               end;
            QI_CHECKOFGUILD:
               begin
                 if who.MyGuild <> nil then begin
                    if CompareText(TGuild(who.MyGuild).GuildName, pqc.IfParam) <> 0 then Result := False;
                 end else begin
                    Result := False;
                 end;
               end;
            QI_ISCASTLEMASTER:
               begin
                 Result := False;
                 if UserCastle.IsOurCastle(TGuild(who.MyGuild)) and (who.IsGuildMaster) then
                  Result := True;
               end;
         end;
      end;
   end;
   procedure GotoQuest (num: integer);
   var
      i: integer;
   begin
      for i:=0 to Sayings.Count-1 do
         if PTQuestRecord (Sayings[i]).LocalNumber = num then begin
            PTQuestRecord (TUserHuman(who).CurQuest) := PTQuestRecord (Sayings[i]);
            TUserHuman(who).CurQuestNpc := self;
            NpcSayTitle (who, '@main');
            break;
         end;
   end;
   procedure GotoSay (saystr: string);
   begin
      NpcSayTitle (who, saystr);
   end;
   procedure TakeItemFromUser (iname: string; count: integer);
   var
      i: integer;
      pu: PTUserItem;
      ps: PTStdItem;
   begin
      pu := nil;
      ps := nil;
      if CompareText (iname, NAME_OF_MONEY) = 0 then begin
         who.DecGold (count);
         who.GoldChanged;
         latesttakeitem := NAME_OF_MONEY;

         AddUserLog ('10'#9 + //�Ǹ� �� ���̾�
                     who.MapName + ''#9 +
                     IntToStr(who.CX) + ''#9 +
                     IntToStr(who.CY) + ''#9 +
                     who.UserName + ''#9 +
                     NAME_OF_GOLD{'����'} + ''#9 +
                     IntToStr(count) + ''#9 +
                     '1'#9 +
                     UserName);
      end else if CompareText (iname, NAME_OF_PC) = 0 then begin
         TUserHuman(who).DecPotCash (count);
         TUserHuman(who).PotCashChanged;
         latesttakeitem := NAME_OF_PC;
        // TUserHuman(who).SysMsg(NAME_OF_PC + '���� ' + IntToStr(count), 0);        //Ԫ�����ٵ���ʾ



         AddUserLog ('10'#9 + //�Ǹ� �� ���̾�
                     who.MapName + ''#9 +
                     IntToStr(who.CX) + ''#9 +
                     IntToStr(who.CY) + ''#9 +
                     who.UserName + ''#9 +
                     NAME_OF_PC{'����'} + ''#9 +
                     IntToStr(count) + ''#9 +
                     '1'#9 +
                     UserName);

      end else
         for i:=who.ItemList.Count-1 downto 0 do begin
            if count <= 0 then break;
            pu := PTUserItem(who.ItemList[i]);
            ps := UserEngine.GetStdItem( pu.Index );
            if ps <> nil then begin
               if CompareText (ps.Name, iname) = 0 then begin
                  //ī��Ʈ������ (sonmg 2005/03/15)
                  if ps.OverlapItem >= 1 then begin
                     //�α׳���
                     AddUserLog ('10'#9 + //�Ǹ� �� ���̾�(ī��Ʈ������)
                                 who.MapName + ''#9 +
                                 IntToStr(who.CX) + ''#9 +
                                 IntToStr(who.CY) + ''#9 +
                                 who.UserName + ''#9 +
                                 IntToStr(pu.Index) + ''#9 +
                                 IntToStr(count) + ''#9 +  //count
                                 '1'#9 +
                                 UserName);

                     //-------------------------(sonmg 2005/03/15)
                     if pu.Dura >= count then begin
                        pu.Dura := pu.Dura - count;

                        if pu.Dura <= 0 then begin
                           if who.RaceServer = RC_USERHUMAN then begin
                              TUserHuman(who).SendDelItem (pu^);
                           end;
                           Dispose(pu);
                           who.ItemList.Delete (i);
                        end else begin
                           who.SendMsg(self, RM_COUNTERITEMCHANGE, 0, pu.MakeIndex, pu.Dura, 0, ps.Name);
                        end;
                     end else begin
                        if who.RaceServer = RC_USERHUMAN then begin
                           TUserHuman(who).SendDelItem (pu^);
                        end;
                        Dispose (pu);
                        who.ItemList.Delete (i);
                     end;
                     //-------------------------

//                     TUserHuman(who).SendDelItem (pu^);    // �̻��ϴ�.
                     latesttakeitem := UserEngine.GetStdItemName (pu^.index);
//                     Dispose (pu);
//                     who.ItemList.Delete (i);
//                     Dec (count);
                     break;
                  end else begin
                     //-----------------------------------------------------------
                     //�����̸� ������ üũ�ؼ� ���ڸ��� ���� ���������� �Ѿ.
                     if iname = GetUnbindItemName(SHAPE_AMULET_BUNCH) then begin
                        if pu.Dura < pu.DuraMax then
                           continue;
                     end;
                     //-----------------------------------------------------------

                     //�α׳���
                     AddUserLog ('10'#9 + //�Ǹ� �� ���̾�
                                 who.MapName + ''#9 +
                                 IntToStr(who.CX) + ''#9 +
                                 IntToStr(who.CY) + ''#9 +
                                 who.UserName + ''#9 +
                                 iname + ''#9 +
                                 IntToStr(pu.MakeIndex) + ''#9 +  //count
                                 '1'#9 +
                                 UserName);

                     TUserHuman(who).SendDelItem (pu^);    // �̻��ϴ�.
                     latesttakeitem := UserEngine.GetStdItemName (pu^.index);
                     Dispose (pu);
                     who.ItemList.Delete (i);
                     Dec (count);
                  end;
               end;
            end;
         end;
   end;
   // ���� ��� ������ �������� ��� �����´�.
   procedure TakeEventGradeItemFromUser (grade: integer);
   var
      i: integer;
      pu: PTUserItem;
      ps: PTStdItem;
   begin
      pu := nil;
      ps := nil;
      for i:=who.ItemList.Count-1 downto 0 do begin
         pu := PTUserItem(who.ItemList[i]);
         if pu <> nil then begin
            ps := UserEngine.GetStdItem(pu.Index);
            if ps <> nil then begin
               if ps.EffType2 = EFFTYPE2_EVENT_GRADE then begin
                  if ps.EffValue2 <= grade then begin
                     //�α׳���
                     AddUserLog ('10'#9 + //�Ǹ� �� ���̾�
                                 who.MapName + ''#9 +
                                 IntToStr(who.CX) + ''#9 +
                                 IntToStr(who.CY) + ''#9 +
                                 who.UserName + ''#9 +
                                 ps.Name + ''#9 +
                                 IntToStr(pu.MakeIndex) + ''#9 +  //count
                                 '1'#9 +
                                 UserName);

                     TUserHuman(who).SendDelItem (pu^);    // �̻��ϴ�.
                     latesttakeitem := UserEngine.GetStdItemName (pu^.index);
                     Dispose (pu);
                     who.ItemList.Delete (i);
                  end;
               end;
            end;
         end;
      end;
   end;
   procedure TakeWItemFromUser (iname: string; count: integer);
   var
      i: integer;
   begin
      if CompareLStr (iname, '[NECKLACE]', 4) then begin
         if who.UseItems[U_NECKLACE].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_NECKLACE]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_NECKLACE].index);
            who.UseItems[U_NECKLACE].Index := 0;
         end;
         exit;
      end;
      if CompareLStr (iname, '[RING]', 4) then begin
         if who.UseItems[U_RINGL].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_RINGL]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_RINGL].index);
            who.UseItems[U_RINGL].Index := 0;
            exit;
         end;
         if who.UseItems[U_RINGR].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_RINGR]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_RINGR].index);
            who.UseItems[U_RINGR].Index := 0;
            exit;
         end;
         exit;
      end;
      if CompareLStr (iname, '[ARMRING]', 4) then begin
         if who.UseItems[U_ARMRINGL].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_ARMRINGL]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_ARMRINGL].index);
            who.UseItems[U_ARMRINGL].Index := 0;
            exit;
         end;
         if who.UseItems[U_ARMRINGR].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_ARMRINGR]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_ARMRINGR].index);
            who.UseItems[U_ARMRINGR].Index := 0;
            exit;
         end;
         exit;
      end;
      if CompareLStr (iname, '[WEAPON]', 4) then begin
         if who.UseItems[U_WEAPON].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_WEAPON]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_WEAPON].index);
            who.UseItems[U_WEAPON].Index := 0;
         end;
         exit;
      end;
      if CompareLStr (iname, '[HELMET]', 4) then begin
         if who.UseItems[U_HELMET].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_HELMET]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_HELMET].index);
            who.UseItems[U_HELMET].Index := 0;
         end;
         exit;
      end;
      // 2003/03/15 COPARK ������ �κ��丮 Ȯ��
      if CompareLStr (iname, '[BUJUK]', 4) then begin
         if who.UseItems[U_BUJUK].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_BUJUK]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_BUJUK].index);
            who.UseItems[U_BUJUK].Index := 0;
         end;
         exit;
      end;
      if CompareLStr (iname, '[BELT]', 4) then begin
         if who.UseItems[U_BELT].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_BELT]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_BELT].index);
            who.UseItems[U_BELT].Index := 0;
         end;
         exit;
      end;
      if CompareLStr (iname, '[BOOTS]', 4) then begin
         if who.UseItems[U_BOOTS].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_BOOTS]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_BOOTS].index);
            who.UseItems[U_BOOTS].Index := 0;
         end;
         exit;
      end;
      if CompareLStr (iname, '[CHARM]', 4) then begin
         if who.UseItems[U_CHARM].Index > 0 then begin
            TUserHuman(who).SendDelItem (who.UseItems[U_CHARM]);
            latesttakeitem := UserEngine.GetStdItemName (who.UseItems[U_CHARM].index);
            who.UseItems[U_CHARM].Index := 0;
         end;
         exit;
      end;
      // 2003/03/15 COPARK ������ �κ��丮 Ȯ��
      for i:=0 to U_CHARM do begin     // 8->12
         if count <= 0 then break;
         if who.UseItems[i].Index > 0 then begin
            if CompareText (UserEngine.GetStdItemName (who.UseItems[i].Index), iname) = 0 then begin
               TUserHuman(who).SendDelItem (who.UseItems[i]);
               latesttakeitem := UserEngine.GetStdItemName (who.UseItems[i].index);
               who.UseItems[i].Index := 0;
               Dec (count);
            end;
         end;
      end;
   end;
   procedure GiveItemToUser (receivewho: TCreature; iname: string; count: integer);
   var
      i, idx: integer;
      pstd, pstd2: PTStdItem;
      pu: PTUserItem;
      wg: integer;
   begin
      if CompareText (iname, NAME_OF_MONEY) = 0 then begin
         receivewho.IncGold (count);
         receivewho.GoldChanged;

         AddUserLog ('9'#9 + //���� �� ���̾�
                     receivewho.MapName + ''#9 +
                     IntToStr(receivewho.CX) + ''#9 +
                     IntToStr(receivewho.CY) + ''#9 +
                     receivewho.UserName + ''#9 +
                     NAME_OF_GOLD{'����'} + ''#9 +
                     IntToStr(count) + ''#9 +  //count
                     '1'#9 +
                     UserName);
      end else if CompareText (iname, NAME_OF_PC) = 0 then begin
         TUserHuman(receivewho).IncPotCash(count);
         TUserHuman(receivewho).PotCashChanged;
//         TUserHuman(receivewho).SysMsg(NAME_OF_PC+'���� ' + IntToStr(count), 2);
         AddUserLog ('9'#9 + //���� �� ���̾�
                     receivewho.MapName + ''#9 +
                     IntToStr(receivewho.CX) + ''#9 +
                     IntToStr(receivewho.CY) + ''#9 +
                     receivewho.UserName + ''#9 +
                     NAME_OF_PC{'����'} + ''#9 +
                     IntToStr(count) + ''#9 +  //count
                     '1'#9 +
                     UserName);
      end else begin
         idx := 0;
         idx := UserEngine.GetStdItemIndex(iname);
         pstd := UserEngine.GetStdItem(idx);

         if (idx > 0) and (pstd <> nil) then begin
            for i:=0 to count-1 do begin
               // ī��Ʈ������
               if pstd.OverlapItem >= 1 then begin
                  if receivewho.UserCounterItemAdd(pstd.StdMode, pstd.Looks, count, iName, FALSE) then begin
                      AddUserLog('9'#9 + //���� �� ���̾�(ī��Ʈ������)
                          receivewho.MapName + ''#9 +
                          IntToStr(receivewho.CX) + ''#9 +
                          IntToStr(receivewho.CY) + ''#9 +
                          receivewho.UserName + ''#9 +
                          IntToStr(idx) + ''#9 +
                          IntToStr(count) + ''#9 +
                          '1'#9 +
                          UserName);
                      receivewho.WeightChanged;
                      exit;
                  end;
               end;

               if pstd.OverlapItem = 1 then
                  wg := receivewho.WAbil.Weight + (count div 10)
               else if pstd.OverlapItem >= 2 then
                  wg := receivewho.WAbil.Weight + (pstd.Weight * count)
               else
                  wg := receivewho.WAbil.Weight + pstd.Weight;

               if (receivewho.CanAddItem) {and (wg <= receivewho.WAbil.MaxWeight)} then begin
                  new (pu);
                  if UserEngine.CopyToUserItemFromName (iname, pu^) then begin
                     // gadget:ī��Ʈ������
                     if pstd.OverlapItem >= 1 then begin
                        pu.Dura := count;
                     end;

                     receivewho.ItemList.Add (pu);
                     TUserHuman(receivewho).SendAddItem (pu^);
                     //�α׳���
                     AddUserLog ('9'#9 + //���� �� ���̾�
                                 receivewho.MapName + ''#9 +
                                 IntToStr(receivewho.CX) + ''#9 +
                                 IntToStr(receivewho.CY) + ''#9 +
                                 receivewho.UserName + ''#9 +
                                 iname + ''#9 +
                                 IntToStr(pu.MakeIndex) + ''#9 +
                                 '1'#9 +
                                 UserName);
                     receivewho.WeightChanged;
                     if pstd.OverlapItem >= 1 then break;
                  end else
                     Dispose (pu);
               end else begin
                  new (pu);
                  if UserEngine.CopyToUserItemFromName (iname, pu^) then begin
                     pstd2 := UserEngine.GetStdItem(UserEngine.GetStdItemIndex(iname));
                     if pstd2 <> nil then
                     begin
                        if pstd2.OverlapItem >= 1 then begin
                           pu.Dura := count;  // gadget:ī��Ʈ������
                        end;
                        //�α׳���
                        AddUserLog ('9'#9 + //���� �� ���̾�
                                    receivewho.MapName + ''#9 +
                                    IntToStr(receivewho.CX) + ''#9 +
                                    IntToStr(receivewho.CY) + ''#9 +
                                    receivewho.UserName + ''#9 +
                                    iname + ''#9 +
                                    IntToStr(pu.MakeIndex) + ''#9 +
                                    '1'#9 +
                                    UserName);
                        receivewho.DropItemDown (pu^, 3, FALSE, receivewho, nil , 2);  //�����ð����� �ٸ� ����� �� �ݰ�
                     end;//if pstd2 <> nil then
                  end;
                  if pu <> nil then Dispose(pu);   // Memory Leak sonmg
               end;
            end;
         end;
      end;
   end;


   procedure ActionOfSysMsg(who: TCreature; infotype, msg:string);
   var
      n, k: Integer;
      typestr, tmpmsg, sendmsg: string;
      tag, rst: string;
   begin
      sendmsg := '';
      if infotype[1] = '[' then
        ArrestStringEx(infotype,'[',']', typestr)
      else if infotype[1] = '"' then
        ArrestStringEx (infotype, '"', '"', typestr)
      else typestr := infotype;

      if msg[1] = '%' then begin
         tmpmsg := Copy(msg, 2, Length(msg)-1);
         n := GetPP (tmpmsg);
         if n >= 0 then begin
            case n of
               400..409:  sendmsg :=  TUserHuman(who).StringParams[n-400];
               500..509:  sendmsg := GrobalStringParams[n-500];
            end;
         end;
      end else begin
         sendmsg := msg;
      end;

      rst := sendmsg;

      for k:=0 to 100 do begin
         if CharCount(rst, '>') >= 1 then begin
            rst := ArrestStringEx (rst, '<', '>', tag);
            CheckNpcSayCommand (TUserHuman(who), sendmsg, tag);
         end else
            break;
      end;

      if sendmsg <> '' then begin
         if UpperCase(typestr) = 'GROBAL' then begin
            UserEngine.SysMsgAll(sendmsg, nil);
         end else if UpperCase(typestr) = 'LOCAL' then begin
            UserEngine.SysMsgAll(sendmsg, TUserHuman(who).PEnvir);
         end else if  UpperCase(typestr) = 'PRIVATE' then begin
            TUserHuman(who).SysMsg(sendmsg, 0);
         end else begin
            UserEngine.SysMsgAll(sendmsg, typestr);
         end;
      end;
   end;



   function  DoActionList (alist: TList): Boolean;
   var
      i, k, n, n1, n2, ixx, iyy, param, tag, timerval, iparam1, iparam2, iparam3, iparam4: integer;
      sparam1, sparam2, sparam3, sparam4 : string;
      pqa: PTQuestActioninfo;
      list: TList;
      hum: TUserHuman;
      envir: TEnvirnoment;
      kind: integer;
      cMethod: Char;
   begin
      iparam2 := 0;
      iparam3 := 0;
      Result := TRUE; //CONTINUE �ǹ�
      timerval := 0;

      for i:=0 to alist.Count-1 do begin
         pqa := PTQuestActioninfo (alist[i]);
         case pqa.ActIdent of
            QA_SET:
               begin
                  param := Str_ToInt (pqa.ActParam, 0);
                  //if param > 100 then begin
                  tag := Str_ToInt (pqa.ActTag, 0);
                  who.SetQuestMark (param, tag);
                  //end;
               end;
            QA_OPENUNIT:
               begin
                  param := Str_ToInt (pqa.ActParam, 0);
                  tag := Str_ToInt (pqa.ActTag, 0);
                  who.SetQuestOpenIndexMark (param, tag);
               end;
            QA_SETUNIT:
               begin
                  param := Str_ToInt (pqa.ActParam, 0);
                  tag := Str_ToInt (pqa.ActTag, 0);
                  who.SetQuestFinIndexMark (param, tag);
               end;
            QA_TAKE:
               begin
                  TakeItemFromUser (pqa.ActParam, pqa.ActTagVal);
               end;
            QA_TAKEW:
               begin
                  TakeWItemFromUser (pqa.ActParam, pqa.ActTagVal);
               end;
            QA_GIVE:
               begin
                  GiveItemToUser (who, pqa.ActParam, pqa.ActTagVal);
               end;
            QA_CLOSE: //��ȭâ�� ����
               begin
                  who.SendMsg (self, RM_MERCHANTDLGCLOSE, 0, integer(self), 0, 0, '');
               end;
            QA_CLOSENOINVEN: //��ȭâ�� ����(�κ�â�� �ǵ帮�� ����)
               begin
                  who.SendMsg (self, RM_MERCHANTDLGCLOSE, 0, integer(self), 1, 0, '');
               end;
            QA_RESET:
               begin
                  //if pqa.ActParamVal > 100 then  //100�̸��� ������ �� ����
                  for k:=0 to pqa.ActTagVal-1 do
                     who.SetQuestMark (pqa.ActParamVal + k, 0);
               end;
            QA_RESETUNIT:
               begin
                  //for k:=0 to pqa.ActTagVal-1 do
                  //   if pqa.ActParamVal + k <= 100 then  //100���ϸ� ���� ��
                  //      who.SetQuestMark (pqa.ActParamVal + k, 0);
               end;
            QA_MAPMOVE:  //�����̵� ������
               begin
                  who.SendRefMsg (RM_SPACEMOVE_HIDE, 0, 0, 0, 0, '');
                  who.SpaceMove (pqa.ActParam, pqa.ActTagVal, pqa.ActExtraVal, 0);
                  bosaynow := TRUE;
               end;
            QA_MAPRANDOM:
               begin
                  who.SendRefMsg (RM_SPACEMOVE_HIDE, 0, 0, 0, 0, '');
                  who.RandomSpaceMove (pqa.ActParam, 0);
                  bosaynow := TRUE;
               end;
            QA_BREAK:
               Result := FALSE;  //break;
            QA_TIMERECALL:
               begin
                  TUserHuman(who).BoTimeRecall := TRUE;
                  TUserHuman(who).TimeRecallMap := TUserHuman(who).MapName;
                  TUserHuman(who).TimeRecallX := TUserHuman(who).CX;
                  TUserHuman(who).TimeRecallY := TUserHuman(who).CY;
                  TUserHuman(who).TimeRecallEnd := LongInt(GetTickCount) + pqa.ActParamVal * 60 * 1000;
               end;
            QA_TIMERECALLGROUP:
               begin
                  for k:=0 to who.GroupMembers.Count-1 do begin
                     hum := UserEngine.GetUserHuman (who.GroupMembers[k]);
                     if hum <> nil then begin
                        hum.BoTimeRecall := FALSE; //���� TimeRecall�� ����
                        hum.BoTimeRecallGroup := TRUE;
                        hum.TimeRecallMap := hum.MapName;
                        hum.TimeRecallX := hum.CX;
                        hum.TimeRecallY := hum.CY;
                        hum.TimeRecallEnd := LongInt(GetTickCount) + pqa.ActParamVal * 60 * 1000;
                     end;
                  end;
               end;
            QA_BREAKTIMERECALL:
               begin
                  TUserHuman(who).BoTimeRecall := FALSE;
                  TUserHuman(who).BoTimeRecallGroup := FALSE;
               end;
            QA_PARAM1:
               begin
                  iparam1 := pqa.ActParamVal;
                  sparam1 := pqa.ActParam;
               end;
            QA_PARAM2:
               begin
                  iparam2 := pqa.ActParamVal;
                  sparam2 := pqa.ActParam;
               end;
            QA_PARAM3:
               begin
                  iparam3 := pqa.ActParamVal;
                  sparam3 := pqa.ActParam;
               end;
            QA_PARAM4:
               begin
                  iparam4 := pqa.ActParamVal;
                  sparam4 := pqa.ActParam;
               end;
            QA_TAKECHECKITEM:
               begin
                  if pcheckitem <> nil then begin
                     who.DeletePItemAndSend (pcheckitem);
                  end;
               end;
            QA_MONGEN:
               begin
                  for k:=0 to pqa.ActTagVal-1 do begin
                     //pqa.ActTagVal : ����
                     //pqa.ActExtraVal : ����
                     //sparam1 : map
                     //iparam2 : x
                     //iparam3 : y
                     ixx := iparam2 - pqa.ActExtraVal + Random(pqa.ActExtraVal*2+1);
                     iyy := iparam3 - pqa.ActExtraVal + Random(pqa.ActExtraVal*2+1);
                     UserEngine.AddCreatureSysop (UpperCase(sparam1),  //map
                                                  ixx,
                                                  iyy,
                                                  pqa.ActParam); //mon-name
                  end;
               end;
            QA_MONCLEAR:
               begin
                  list := TList.Create;
                  UserEngine.GetMapMons (GrobalEnvir.GetEnvir(pqa.ActParam), list);
                  for k:=0 to list.Count-1 do begin
                     TCreature(list[k]).BoNoItem := TRUE;
                     TCreature(list[k]).WAbil.HP := 0;  //��� ���δ�.
                  end;
                  list.Free;
               end;
            QA_MOV:
               begin
                  n := GetPP (pqa.ActParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           TUserHuman(who).QuestParams[n] := pqa.ActTagVal;
                        100..109:
                           GrobalQuestParams[n-100] := pqa.ActTagVal;
                        200..209:
                           TUserHuman(who).DiceParams[n-200] := pqa.ActTagVal;
                        300..309:
                           PEnvir.MapQuestParams[n-300] := pqa.ActTagVal;
                     end;
                  end;
               end;
            QA_INC:
               begin
                  n := GetPP (pqa.ActParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           if pqa.ActTagVal > 1 then
                              TUserHuman(who).QuestParams[n] := TUserHuman(who).QuestParams[n] + pqa.ActTagVal
                           else
                              TUserHuman(who).QuestParams[n] := TUserHuman(who).QuestParams[n] + 1;
                        100..109:
                           if pqa.ActTagVal > 1 then
                              GrobalQuestParams[n-100] := GrobalQuestParams[n-100] + pqa.ActTagVal
                           else
                              GrobalQuestParams[n-100] := GrobalQuestParams[n-100] + 1;
                        200..209:
                           if pqa.ActTagVal > 1 then
                              TUserHuman(who).DiceParams[n-200] := TUserHuman(who).DiceParams[n-200] + pqa.ActTagVal
                           else
                              TUserHuman(who).DiceParams[n-200] := TUserHuman(who).DiceParams[n-200] + 1;
                        300..309:
                           if pqa.ActTagVal > 1 then
                              PEnvir.MapQuestParams[n-300] := PEnvir.MapQuestParams[n-300] + pqa.ActTagVal
                           else
                              PEnvir.MapQuestParams[n-300] := PEnvir.MapQuestParams[n-300] + 1;
                     end;
                  end;
               end;
            QA_DEC:
               begin
                  n := GetPP (pqa.ActParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           if pqa.ActTagVal > 1 then
                              TUserHuman(who).QuestParams[n] := TUserHuman(who).QuestParams[n] - pqa.ActTagVal
                           else
                              TUserHuman(who).QuestParams[n] := TUserHuman(who).QuestParams[n] - 1;
                        100..109:
                           if pqa.ActTagVal > 1 then
                              GrobalQuestParams[n-100] := GrobalQuestParams[n-100] - pqa.ActTagVal
                           else
                              GrobalQuestParams[n-100] := GrobalQuestParams[n-100] - 1;
                        200..209:
                           if pqa.ActTagVal > 1 then
                              TUserHuman(who).DiceParams[n-200] := TUserHuman(who).DiceParams[n-200] - pqa.ActTagVal
                           else
                              TUserHuman(who).DiceParams[n-200] := TUserHuman(who).DiceParams[n-200] - 1;
                        300..309:
                           if pqa.ActTagVal > 1 then
                              PEnvir.MapQuestParams[n-300] := PEnvir.MapQuestParams[n-300] - pqa.ActTagVal
                           else
                              PEnvir.MapQuestParams[n-300] := PEnvir.MapQuestParams[n-300] - 1;
                     end;
                  end;
               end;
            QA_SUM:
               begin
                  n1 := 0;
                  n := GetPP (pqa.ActParam);
                  if n >= 0 then begin
                     case n of
                        0..9:     n1 := TUserHuman(who).QuestParams[n];
                        100..109:  n1 := GrobalQuestParams[n-100];
                        200..209:  n1 := TUserHuman(who).DiceParams[n-200];
                        300..309:  n1 := PEnvir.MapQuestParams[n-300];
                     end;
                  end;
                  n2 := 0;
                  n := GetPP (pqa.ActTag);
                  if n >= 0 then begin
                     case n of
                        0..9:     n2 := TUserHuman(who).QuestParams[n];
                        100..109:  n2 := GrobalQuestParams[n-100];
                        200..209:  n2 := TUserHuman(who).DiceParams[n-200];
                        300..309:  n2 := PEnvir.MapQuestParams[n-300];
                     end;
                  end;
                  n := GetPP (pqa.ActParam);
                  if n >= 0 then begin
                     case n of
                        0..9:      TUserHuman(who).QuestParams[9] := TUserHuman(who).QuestParams[9] + n1 + n2;
                        100..109:  GrobalQuestParams[9] := GrobalQuestParams[9] + n1 + n2;
                        200..209:   TUserHuman(who).DiceParams[9] := TUserHuman(who).DiceParams[9] + n1 + n2;
                        300..309:   PEnvir.MapQuestParams[9] := PEnvir.MapQuestParams[9] + n1 + n2;
                     end;
                  end;
               end;

            QA_MOVRANDOM:  //MOVR
               begin
                  n := GetPP (pqa.ActParam);
                  if n >= 0 then begin
                     case n of
                        0..9:
                           TUserHuman(who).QuestParams[n] := Random(pqa.ActTagVal);
                        100..109:
                           GrobalQuestParams[n-100] := Random(pqa.ActTagVal);
                        200..209:
                           TUserHuman(who).DiceParams[n-200] := Random(pqa.ActTagVal);
                        300..309:
                           PEnvir.MapQuestParams[n-300] := Random(pqa.ActTagVal);
                     end;
                  end;
               end;
            QA_EXCHANGEMAP:
               begin
                  //�θ� ���
                  envir := GrobalEnvir.GetEnvir (pqa.ActParam);
                  if envir <> nil then begin
                     list := TList.Create;
                     UserEngine.GetAreaUsers (envir, 0, 0, 1000, list);
                     if list.Count > 0 then begin
                        //�Ѹ� ����
                        hum := TUserHuman (list[0]);
                        if hum <> nil then begin
                           hum.RandomSpaceMove (MapName, 0);
                        end;
                     end;
                     list.Free;
                  end;
                  //���� �̵�
                  who.RandomSpaceMove (pqa.ActParam, 0);
               end;
            QA_RECALLMAP:
               begin
                  //�θ� ���
                  envir := GrobalEnvir.GetEnvir (pqa.ActParam);
                  if envir <> nil then begin
                     list := TList.Create;
                     UserEngine.GetAreaUsers (envir, 0, 0, 1000, list);
                     for k:=0 to list.Count-1 do begin
                        hum := TUserHuman (list[k]);
                        if hum <> nil then begin
                           hum.RandomSpaceMove (MapName, 0);
                        end;
                        //22�� ����
                        if k > 20 then break;
                     end;
                     list.Free;
                  end;
               end;
            QA_BATCHDELAY:
               begin
                  batchdelay := pqa.ActParamVal * 1000;
               end;
            QA_ADDBATCH:
               begin
                  batchlist.AddObject (pqa.ActParam, TObject(batchdelay));
               end;
            QA_BATCHMOVE:
               begin
                  for k:=0 to batchlist.Count-1 do begin
                     who.SendDelayMsg (self, RM_RANDOMSPACEMOVE, 0, 0, 0, 0, batchlist[k], previousbatchdelay + integer(batchlist.Objects[k]));
                     previousbatchdelay := previousbatchdelay + integer(batchlist.Objects[k])
                  end;
               end;
            QA_PLAYDICE:
               begin
                  who.SendMsg (self, RM_PLAYDICE,
                                     pqa.ActParamVal,  //������ �ֻ��� ��
                                     MakeLong(MakeWord(TUserHuman(who).DiceParams[0],
                                                       TUserHuman(who).DiceParams[1]),
                                              MakeWord(TUserHuman(who).DiceParams[2],
                                                       TUserHuman(who).DiceParams[3])),
                                     MakeLong(MakeWord(TUserHuman(who).DiceParams[4],
                                                       TUserHuman(who).DiceParams[5]),
                                              MakeWord(TUserHuman(who).DiceParams[6],
                                                       TUserHuman(who).DiceParams[7])),
                                     MakeLong(MakeWord(TUserHuman(who).DiceParams[8],
                                                       TUserHuman(who).DiceParams[9]),
                                              0),
                                     pqa.ActTag);  //������ �̵� ��ȭ �±� ��)@diceresult
                  bosaynow := TRUE;
               end;
            QA_PLAYROCK:  //���������� ����
               begin
                  who.SendMsg (self, RM_PLAYROCK,
                                     pqa.ActParamVal,  //������ �ֻ��� ��
                                     MakeLong(MakeWord(TUserHuman(who).DiceParams[0],
                                                       TUserHuman(who).DiceParams[1]),
                                              MakeWord(TUserHuman(who).DiceParams[2],
                                                       TUserHuman(who).DiceParams[3])),
                                     MakeLong(MakeWord(TUserHuman(who).DiceParams[4],
                                                       TUserHuman(who).DiceParams[5]),
                                              MakeWord(TUserHuman(who).DiceParams[6],
                                                       TUserHuman(who).DiceParams[7])),
                                     MakeLong(MakeWord(TUserHuman(who).DiceParams[8],
                                                       TUserHuman(who).DiceParams[9]),
                                              0),
                                     pqa.ActTag);  //������ �̵� ��ȭ �±� ��)@diceresult
                  bosaynow := TRUE;
               end;
            //6-11
            QA_ADDNAMELIST:
               begin
                  AddNameFromFileList (who.UserName, NpcBaseDir + pqa.ActParam{filename});
               end;
            //6-11
            QA_DELETENAMELIST:
               begin
                  DeleteNameFromFileList (who.UserName, NpcBaseDir + pqa.ActParam{filename});
               end;
            //*DQ
            QA_RANDOMSETDAILYQUEST:
               begin
                  who.SetDailyQuest (pqa.ActParamVal + Random(pqa.ActTagVal - pqa.ActParamVal + 1));
               end;
            //*DQ
            QA_SETDAILYQUEST:
               begin
                  who.SetDailyQuest (pqa.ActParamVal);
               end;
            //����ġ �ִ� ��ũ��Ʈ
            QA_GIVEEXP:
               begin
                  // 4�ֳ� �̺�Ʈ�� ����ġ �ִ� ���(���� ���� ���)
                  who.WinExp( _MIN(pqa.ActParamVal, High(Integer)) );
                  MainOutMessage( 'GIVEEXP(' + IntToStr(_MIN(pqa.ActParamVal, High(Integer))) + ') : ' + who.UserName );
               end;

            QA_TAKEGRADEITEM: // Event Grade
               begin
                  TakeEventGradeItemFromUser (pqa.ActParamVal);
               end;

            QA_GOTOQUEST:
               begin
                  GotoQuest (pqa.ActParamVal);
               end;
            QA_ENDQUEST:
               begin
                  TUserHuman(who).CurQuest := nil;
               end;
            QA_GOTO:
               begin
                  GotoSay (pqa.ActParam);
               end;
            QA_SOUND:
               begin
                  who.SendMsg( self, RM_SOUND , 0 ,Str_ToInt( pqa.ActParam,0), 0 , 0 ,'');
               end;
            QA_SOUNDALL:
               begin
                  //�ð��� ������ �÷��� Reset
                  if GetTickCount - SoundStartTime > 25 * 1000{25��} then begin
                     SoundStartTime := GetTickCount;
                     BoSoundPlaying := FALSE;
                  end;

                  if not BoSoundPlaying then begin
                     BoSoundPlaying := TRUE;
                     //���� �÷��� ��û
                     SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
                  end;
               end;
            QA_CHANGEGENDER:
               begin
                  TUserHuman(who).CmdChangeSex;

                  if who.Sex = 1 then begin
                     {$IFDEF KOREA}
                     who.BoxMsg( '�����Ա��Ů�Ժ���Ҫ��������',1);
                     who.SysMsg( '�����Ա��Ů�Ժ���Ҫ��������',1);
                     {$ELSE}
                     who.BoxMsg( '����Լ�����������',1);
                     who.SysMsg( '����Լ�����������',1);
                     {$ENDIF}
                  end else begin
                     {$IFDEF KOREA}
                     who.BoxMsg( '��Ů�Ա�����Ժ���Ҫ��������',1);
                     who.SysMsg( '��Ů�Ա�����Ժ���Ҫ��������',1);
                     {$ELSE}
                     who.BoxMsg( '����Լ�����������',1);
                     who.SysMsg( '����Լ�����������',1);
                     {$ENDIF}
                  end;
               end;
            QA_KICK:
               begin
                  TUserHuman(who).EmergencyClose := TRUE;
               end;
            QA_MOVEALLMAP:
               begin
                  param := pqa.ActTagVal;
                  //�̵� ��ų ���
                  envir := GrobalEnvir.GetEnvir (MapName);
                  if envir <> nil then begin
                     list := TList.Create;
                     UserEngine.GetAreaUsers (envir, 0, 0, 1000, list);
                     for k:=0 to list.Count-1 do begin
                        hum := TUserHuman (list[k]);
                        if hum <> nil then begin
                           hum.RandomSpaceMove (pqa.ActParam, 0);
                        end;
                        //param�� ����
                        if k >= (param - 1) then break;
                     end;
                     list.Free;
                  end;
               end;
            QA_MOVEALLMAPGROUP:
               begin
                  if who.GroupOwner = nil then begin
                     // �׷��� ���� �ڱ� ȥ�ڸ� ���� ��
                     if (pqa.ActTag = '') and (pqa.ActExtra = '') then begin
                        who.RandomSpaceMove(pqa.ActParam, 0);
                     end else begin
                        who.SpaceMove (pqa.ActParam, pqa.ActTagVal, pqa.ActExtraVal, 0);
                     end;
                  end else if who.GroupOwner = who then begin //�ڽ��� �׷�¯
                     for k:=0 to who.GroupMembers.Count-1 do begin  //�ڽ� ����.
                        hum := UserEngine.GetUserHuman (who.GroupMembers[k]);
                        if hum <> nil then begin
                           // ���� �ʿ� �ִ� ����� ���� ������ �̵�.
                           if hum.MapName = MapName then begin
                              if (pqa.ActTag = '') and (pqa.ActExtra = '') then begin
                                 hum.RandomSpaceMove(pqa.ActParam, 0);
                              end else begin
                                 hum.SpaceMove (pqa.ActParam, pqa.ActTagVal, pqa.ActExtraVal, 0);
                              end;
                           end;
                        end;
                     end;
                  end;
               end;
            QA_RECALLMAPGROUP:
               begin
                  n := (GetTickCount - who.CGHIstart) div 1000;
                  who.CGHIstart := who.CGHIstart + longword(n * 1000);
                  if who.CGHIUseTime > n then who.CGHIUseTime := who.CGHIUseTime - n
                  else who.CGHIUseTime := 0;
                  if who.CGHIUseTime = 0 then begin
                     if who.GroupOwner = who then begin //�ڽ��� �׷�¯
                        for k:=1 to who.GroupMembers.Count-1 do begin  //�ڽ� ����
                           // ������ �ʿ� �ִ� ����� ��ȯ
                           TUserHuman(who).CmdRecallMan (who.GroupMembers[k], pqa.ActParam);
                        end;
                        who.CGHIstart := GetTickCount;
                        who.CGHIUseTime := 10;  //10�� ����
                     end;
                  end else begin
                     {$IFDEF KOREA} who.SysMsg (IntToStr(who.CGHIUseTime) + '�����ʹ��', 0);
                     {$ELSE}        who.SysMsg ('Can be used again after ' + IntToStr(who.CGHIUseTime) + ' seconds.', 0);
                     {$ENDIF}
                  end;
               end;
            QA_WEAPONUPGRADE:
               begin
                  if (pqa.ActParam = 'DC') or (pqa.ActParam = '����') then
                     TUserHuman(who).CmdRefineWeapon(pqa.ActTagVal, 0, 0, 0)
                  else if (pqa.ActParam = 'MC') or (pqa.ActParam = 'ħ��') then
                     TUserHuman(who).CmdRefineWeapon(0, pqa.ActTagVal, 0, 0)
                  else if (pqa.ActParam = 'SC') or (pqa.ActParam = '����') then
                     TUserHuman(who).CmdRefineWeapon(0, 0, pqa.ActTagVal, 0)
                  else if (pqa.ActParam = 'ACC') or (pqa.ActParam = '׼ȷ') then
                     TUserHuman(who).CmdRefineWeapon(0, 0, 0, pqa.ActTagVal);
               end;
            QA_SETALLINMAP:
               begin
                  param := Str_ToInt (pqa.ActParam, 0);
                  tag := Str_ToInt (pqa.ActTag, 0);
                  //�ʿ� �ִ� ��� ���
                  envir := GrobalEnvir.GetEnvir (MapName);
                  if envir <> nil then begin
                     list := TList.Create;
                     UserEngine.GetAreaUsers (envir, 0, 0, 1000, list);
                     for k:=0 to list.Count-1 do begin
                        hum := TUserHuman (list[k]);
                        if hum <> nil then
                           hum.SetQuestMark (param, tag);
                     end;
                     list.Free;
                  end;
               end;
            QA_INCPKPOINT:
               begin
                  param := Str_ToInt (pqa.ActParam, 0);
                  TUserHuman(who).IncPkPoint(param);
               end;
            QA_DECPKPOINT:
               begin
                  param := Str_ToInt (pqa.ActParam, 0);
                  TUserHuman(who).DecPkPoint(param);
               end;
            QA_MOVETOLOVER:   //���� ������ �̵�
               begin
                  if TUserHuman(who).fLover <> nil then begin
                     if TUserHuman(who).fLover.GetLoverName <> '' then
                        TUserHuman(who).CmdCharSpaceMove( TUserHuman(who).fLover.GetLoverName );
                  end;
               end;
            QA_BREAKLOVER:   //���� ���� �Ϲ� ����
               begin
                  TUserHuman(who).CmdBreakLoverRelation;
               end;

            QA_USEFAMEPOINT:   //��ġ ���
               begin
                  who.UseCurrentFamePoint( pqa.ActParamVal );
               end;
            QA_DECWEAPONBADLUCK:
               begin
                  who.DecWeaponBadLuck;
               end;
            QA_DECDONATION:   //�����α�
               begin
                  TUserHuman(who).DecGuildAgitDonation( pqa.ActParamVal );
               end;
            QA_SHOWEFFECT:    //�������Ʈ
               begin
                  if pqa.ActTagVal > 0 then tag := pqa.ActTagVal * 1000
                  else tag := 60000;

                  case pqa.ActParamVal of  //����Ʈ ����
                  1:
                     begin
                        who.SendRefMsg (RM_LOOPNORMALEFFECT, integer(self), tag, 0, NE_JW_EFFECT1, '');
                     end;
                  else
                     begin
                        who.SendRefMsg (RM_LOOPNORMALEFFECT, integer(self), tag, 0, NE_JW_EFFECT1, '');
                     end;
                  end;
               end;
            QA_MONGENAROUND:    //ĳ�� ������ ���� ��
               begin
                  for ixx:=who.CX-2 to who.CX+2 do begin
                     for iyy:=who.CY-2 to who.CY+2 do begin
                        //sparam1 : map
                        if sparam1 = '' then sparam1 := who.MapName;
                        if ( (abs(who.CX - ixx) = 2) or (abs(who.CY - iyy) = 2) )
                              and ( (abs(who.CX - ixx) mod 2 = 0) and (abs(who.CY - iyy) mod 2 = 0) ) then begin
                           //������Ʈ�� ���� PEnvir ��ſ� who.PEnvir�� ����Ѵ�.
                           if who.PEnvir.CanWalk(ixx, iyy, FALSE) then begin
                              UserEngine.AddCreatureSysop (UpperCase(sparam1),  //map
                                                           ixx,
                                                           iyy,
                                                           pqa.ActParam); //mon-name
                           end;
                        end;
                     end;
                  end;
               end;
            QA_RECALLMOB:
               begin
                  TUserHuman(who).CmdCallMakeSlaveMonster(pqa.ActParam{���̸�}, pqa.ActTag{������}, 3, 0);
               end;

            QA_SETLOVERFLAG:
               begin
                  if TUserHuman(who).fLover <> nil then begin
                     hum := UserEngine.GetUserHuman(TUserHuman(who).fLover.GetLoverName);
                     if hum <> nil then begin
                        param := Str_ToInt (pqa.ActParam, 0);
                        //if param > 100 then begin
                        tag := Str_ToInt (pqa.ActTag, 0);
                        hum.SetQuestMark (param, tag);
                        //end;
                     end;
                  end;
               end;
            QA_GUILDSECESSION:
               begin
                  if who.RaceServer = RC_USERHUMAN then
                     TUserHuman(who).GuildSecession;
               end;
            QA_GIVETOLOVER:
               begin
                  if TUserHuman(who).fLover <> nil then begin
                     hum := UserEngine.GetUserHuman(TUserHuman(who).fLover.GetLoverName);
                     if hum <> nil then begin
                        if (Abs(hum.CX-who.CX) <= 7) and (Abs(hum.CY-who.CY) <= 7) then begin
                           GiveItemToUser (hum, pqa.ActParam, pqa.ActTagVal);
                        end else begin
                           {$IFDEF KOREA} who.SysMsg('��İ���û�������', 0);
                           {$ELSE}        who.SysMsg('��İ���û�������', 0);
                           {$ENDIF}
                        end;
                     end else begin
                        {$IFDEF KOREA} who.SysMsg('�Ҳ�����İ���', 0);
                        {$ELSE}        who.SysMsg('�Ҳ�����İ���', 0);
                        {$ENDIF}
                     end;
                  end;
               end;
            QA_INCMEMORIALCOUNT:
               begin
                  MemorialCount := MemorialCount + pqa.ActParamVal;
               end;
            QA_DECMEMORIALCOUNT:
               begin
                  MemorialCount := MemorialCount - pqa.ActParamVal;
               end;
            QA_SAVEMEMORIALCOUNT:
               begin
                  WriteMemorialCount;
               end;
            //2005/12/14
            QA_INSTANTPOWERUP:
               begin
                  if (UPPERCASE(pqa.ActParam) = 'DC') then begin
                     kind := EABIL_DCUP;
                  end else if (UPPERCASE(pqa.ActParam) = 'MC') then begin
                     kind := EABIL_MCUP;
                  end else if (UPPERCASE(pqa.ActParam) = 'SC') then begin
                     kind := EABIL_SCUP;
                  end else if (UPPERCASE(pqa.ActParam) = 'HITSPEED') then begin
                     kind := EABIL_HITSPEEDUP;
                  end else if (UPPERCASE(pqa.ActParam) = 'HP') then begin
                     kind := EABIL_HPUP;
                  end else if (UPPERCASE(pqa.ActParam) = 'MP') then begin
                     kind := EABIL_MPUP;
                  end else begin
                     kind := -1;
                  end;
                  who.EnhanceExtraAbility( kind, pqa.ActTagVal, pqa.ActExtraVal div 60, pqa.ActExtraVal mod 60 );
                  who.RecalcAbilitys;
                  who.SendMsg (who, RM_ABILITY, 0, 0, 0, 0, '');
               end;
            QA_INSTANTEXPDOUBLE:
               begin
                  who.InstantExpDoubleTime := GetTickCount + LongWord(pqa.ActParamVal * 1000);
               end;
            QA_HEALING:
               begin
                  who.SendRefMsg (RM_NORMALEFFECT, 0, who.CX, who.CY, NE_USERHEALING, '');
                  who.IncHealing := who.IncHealing + pqa.ActParamVal;
                  who.PerHealing := 5;
               end;
            QA_UNIFYITEM:
               begin
                  if who.RaceServer = RC_USERHUMAN then
                     TUserHuman(who).UserUnifyItem( Integer(self), pqa.ActParam );
               end;
            QA_SENDMSG:
               begin
                  ActionOfSysMsg(who, pqa.ActParam, pqa.ActTag);
               end;
            QA_ADDIDLIST:
               begin
                  hum := TUserHuman (who);
                  AddNameFromFileList (hum.UserId, NpcBaseDir + pqa.ActParam{filename});
               end;
            QA_DELIDLIST:
               begin
                  hum := TUserHuman (who);
                  DeleteNameFromFileList (hum.UserId, NpcBaseDir + pqa.ActParam{filename});
               end;
            QA_SETITEMEVENT:
               begin
                  if (TUserHuman(who).latestuseitem <> '') and
                     (pqa.ActParamVal = TUserHuman(who).UseItemStdMode) and
                     (pqa.ActTagVal = TUserHuman(who).UseItemShape) then begin
                     TUserHuman(who).UseItemStdMode := -1;
                     TUserHuman(who).UseItemShape := -1;
                     GotoSay (pqa.ActExtra);
                  end;
               end;
            QA_USEITEMSTATUS:
               begin
                 if (pqa.ActParam = '1') or (UPPERCASE(pqa.ActParam) = 'TRUE') then
                    TUserHuman(who).UseItemStatus := True
                 else if (pqa.ActParam = '0') or (UPPERCASE(pqa.ActParam) = 'FALSE') then
                    TUserHuman(who).UseItemStatus := False;
               end;
            QA_KILLMONEXPRATE:
               begin
                 TUserHuman(who).KillMonExpRate := pqa.ActParamVal;
                 TUserHuman(who).KillMonExpTime := pqa.ActTagVal;
               end;
            QA_CHANGEHAIR:   //�ű��޸�ͷ��
               begin
                  param := _MIN(9, Str_ToInt(pqa.ActParam, 1));
                  TUserHuman(who).CmdChangeHair (param);
                  TUserHuman(who).FeatureChanged;
               end;
            QA_MESSAGEBOX:
               begin
                  who.BoxMsg(pqa.ActParam, 1);
               end;
            QA_CHANGEJOB:   //�ű��޸�ְҵ
               begin
                  TUserHuman(who).CmdChangeJob (pqa.ActParam);
                  TUserHuman(who).FeatureChanged;
                  TUserHuman(who).HasLevelUp (1);
               end;
           QA_ADDSKILL:
               begin
                  ActionOfAddSkill (who, pqa.ActParam, Str_ToInt(pqa.ActTag, 0));
               end;
           QA_DELSKILL:
               begin
                  ActionOfDelSkill (who, pqa.ActParam);
               end;
           QA_CHANGENAMECOLOR:
               begin
                  who.DefNameColor := Str_ToInt (pqa.ActParam, 255);
                  who.ChangeNameColor;
               end;
           QA_CHANGEMODE:
               begin
                  case pqa.ActParamVal of
                    1: begin
                      who.BoSysopMode := True;
                      who.SysMsg ('�������ģʽ', 1)
                    end;
                    2: begin
                      who.NeverDie := True;
                      who.SysMsg ('�����޵�ģʽ', 1)
                    end;
                    3: begin
                      who.SendRefMsg(RM_DISAPPEAR, 0, 0, 0, 0, '');
                      who.BoSuperviserMode := True;
                      who.SysMsg ('��������ģʽ', 1)

                    end;
                  end;

               end;    
            QA_REPAIRALL:
               begin
                  ActionOfRepairAllItem(who, pqa);
               end;
         end;
      end;
   end;
   procedure NpcSayProc (str: string; fast: Boolean);
   var
      k: integer;
      tag, rst: string;
   begin
      rst := str;
      for k:=0 to 100 do begin
         if CharCount(rst, '>') >= 1 then begin
            rst := ArrestStringEx (rst, '<', '>', tag);
            CheckNpcSayCommand (TUserHuman(who), str, tag);
         end else
            break;
      end;
      if fast then
         who.SendFastMsg (self, RM_MERCHANTSAY, 0, 0, 0, 0, UserName + '/' + str)
      else
         who.SendMsg (self, RM_MERCHANTSAY, 0, 0, 0, 0, UserName + '/' + str);
   end;
var
   i, j, m: integer;
   str, tag: string;
   pquest, pqr: PTQuestRecord;
   psay: PTSayingRecord;
   psayproc: PTSayingProcedure;
begin
   pquest := nil;
   psayproc := nil;
   batchlist := TStringList.Create;
   batchdelay := 1000;
   previousbatchdelay := 0;

   if TUserHuman(who).CurQuestNpc <> self then begin
      TUserHuman(who).CurQuestNpc := nil;
      TUserHuman(who).CurQuest := nil;
      FillChar (TUserHuman(who).QuestParams, sizeof(integer)*10, #0);
   end;

   if CompareText (title, '@main') = 0 then begin
      for i:=0 to Sayings.Count-1 do begin
         pqr := PTQuestRecord (Sayings[i]);
         for j:=0 to pqr.SayingList.Count-1 do begin
            psay := pqr.SayingList[j];
            if CompareText (psay.Title, title) = 0 then begin
               pquest := pqr;
               TUserHuman(who).CurQuest := pquest;
               TUserHuman(who).CurQuestNpc := self;
               break;
            end;
         end;
         if pquest <> nil then break;
      end;
   end;
   if pquest = nil then begin
      if TUserHuman(who).CurQuest <> nil then begin
         for i:=Sayings.Count-1 downto 0 do begin
            if TUserHuman(who).CurQuest = PTQuestRecord (Sayings[i]) then begin
               pquest := PTQuestRecord (Sayings[i]);
            end;
         end;
      end;
      if pquest = nil then begin
         for i:=Sayings.Count-1 downto 0 do begin
            //����Ʈ�� ������ �˻� �Ѵ�.
            if CheckQuestCondition (PTQuestRecord (Sayings[i])) then begin
               pquest := PTQuestRecord (Sayings[i]);
               TUserHuman(who).CurQuest := pquest;
               TUserHuman(who).CurQuestNpc := self;
            end;
         end;
      end;
   end;
   if pquest <> nil then begin
      for j:=0 to pquest.SayingList.Count-1 do begin
         psay := PTSayingRecord (pquest.SayingList[j]);
         if CompareText (psay.Title, title) = 0 then begin
            str := '';
            for m:=0 to psay.Procs.Count-1 do begin
               psayproc := PTSayingProcedure(psay.Procs[m]);
               if psayproc = nil then continue; // 2003-09-08 nil �˻�
               bosaynow := FALSE;
               if CheckSayingCondition (psayproc.ConditionList) then begin
                  //���� ���� ���, ��ȭ
                  str := str + psayproc.Saying;
                  //���� ���� ���, �׼�
                  if not DoActionList (psayproc.ActionList) then
                     break;
                  if bosaynow then begin
                     NpcSayProc (str, TRUE);
                     TUserHuman(who).CurSayProc := psayproc;
                  end;
               end else begin
                  //���� ������ ���, ��ȭ
                  str := str + psayproc.ElseSaying;
                  //���� ������ ���, �׼�
                  if not DoActionList (psayproc.ElseActionList) then
                     break;
                  if bosaynow then begin
                     NpcSayProc (str, TRUE);
                     TUserHuman(who).CurSayProc := psayproc;
                  end;
               end;
            end;

            if str <> '' then begin
               NpcSayProc (str, FALSE);
               TUserHuman(who).CurSayProc := psayproc;
            end;
            break;
         end;
      end;
   end;

   batchlist.Free;

end;

procedure TNormNpc.ClearNpcInfos;
var
   i, j, k, m: integer;
   pqr: PTQuestRecord;
   psay: PTSayingRecord;
   psayproc: PTSayingProcedure;
   pqcon: PTQuestConditionInfo;
   pqact: PTQuestActionInfo;
begin
   for i:=0 to Sayings.Count-1 do begin
      pqr := PTQuestRecord (Sayings[i]);
      for j:=0 to pqr.SayingList.Count-1 do begin
         psay := pqr.SayingList[j];
         for k:=0 to psay.Procs.Count-1 do begin
            psayproc := PTSayingProcedure(psay.Procs[k]);
            for m:=0 to psayproc.ConditionList.Count-1 do
               Dispose (PTQuestConditionInfo (psayproc.ConditionList[m]));
            for m:=0 to psayproc.ActionList.Count-1 do
               Dispose (PTQuestActionInfo (psayproc.ActionList[m]));
            for m:=0 to psayproc.ElseActionList.Count-1 do
               Dispose (PTQuestActionInfo (psayproc.ElseActionList[m]));
            psayproc.ConditionList.Free;
            psayproc.ActionList.Free;
            psayproc.ElseActionList.Free;
            Dispose (psayproc);
         end;
         psay.Procs.Free;
         Dispose (psay);
      end;
      pqr.SayingList.Free;
      Dispose (pqr);
   end;
   Sayings.Clear;
end;

procedure TNormNpc.LoadNpcInfos;
begin
   if BoUseMapFileName then begin
      NpcBaseDir := NPCDEFDIR;
      FrmDB.LoadNpcDef (self, DefineDirectory, UserName + '-' + MapName)
   end else begin
      NpcBaseDir := DefineDirectory;
      FrmDB.LoadNpcDef (self, DefineDirectory, UserName);
   end;
   //ArrangeSayStrings;
end;

procedure TNormNpc.LoadMemorialCount;
begin
   FrmDB.LoadMemorialCount (self, UserName + '-' + MapName);
end;

procedure TNormNpc.WriteMemorialCount;
begin
   FrmDB.WriteMemorialCount (self, UserName + '-' + MapName);
end;

procedure TNormNpc.UserCall (caller: TCreature);
begin
end;
procedure TNormNpc.UserSelect (whocret: TCreature; selstr: string);
begin
end;

{-------------------- TMerchant ----------------------}

constructor TMerchant.Create;
begin
   inherited Create;
   RaceImage := RCC_MERCHANT;  //����
   Appearance := 0;
   PriceRate := 100;
   NoSeal := FALSE;
   BoCastleManage := FALSE;
   BoHiddenNpc := FALSE;

   DealGoods := TStringList.Create;
   ProductList := TList.Create;
   GoodsList := TList.Create;
   PriceList := TList.Create;

   UpgradingList := TList.Create;

   checkrefilltime := GetTickCount;
   checkverifytime := GetTickCount;

   fSaveToFileCount := 0;
   //specialrepairtime := 0;
   //specialrepair := 0;
   CreateIndex := 0;
end;

destructor TMerchant.Destroy;
var
   i, k: integer;
   list: TList;
begin
   for i:=0 to ProductList.Count-1 do
      Dispose (PTMarketProduct (ProductList[i]));
   ProductList.Free;
   for i:=0 to GoodsList.Count-1 do begin
      list := TList (GoodsList[i]);
      for k:=0 to list.Count-1 do begin
         Dispose (PTUserItem (list[k]));
      end;
      list.Free;
   end;
   GoodsList.Free;
   for i:=0 to PriceList.Count-1 do begin
      Dispose (PTPricesInfo (PriceList[i]));
   end;
   PriceList.Free;
   for i:=0 to UpgradingList.Count-1 do
      Dispose (PTUpgradeInfo (UpgradingList[i]));
   UpgradingList.Free;
   inherited Destroy;
end;

procedure TMerchant.ClearMerchantInfos;
var
   i: integer;
begin
   for i:=0 to ProductList.Count-1 do
      Dispose (PTMarketProduct (ProductList[i]));
   ProductList.Clear;
   DealGoods.Clear;

   {inherited} ClearNpcInfos;  //�������� ���
end;

procedure TMerchant.LoadMerchantInfos;
var
   i: integer;
begin
   NpcBaseDir := MARKETDEFDIR;
   FrmDB.LoadMarketDef (self, MARKETDEFDIR, MarketName + '-' + MapName, TRUE);
   //ArrangeSayStrings;
   /////////////*****************
   //for i:=0 to SayStrings.Count-1 do begin
   //   if CompareText(SayStrings[i], '@makedrug') = 0 then begin
   //      NoSeal := TRUE;  //������ ����� �������� �ǸŴ� ����.
   //      break;
   //   end;
   //end;
end;

procedure TMerchant.LoadMarketSavedGoods;
begin
   FrmDB.LoadMarketSavedGoods (self, MarketName + '-' + MapName);
   FrmDB.LoadMarketPrices (self, MarketName + '-' + MapName);
   LoadUpgradeItemList;
end;

function  TMerchant.GetGoodsList (gindex: integer): TList;
var
   i: integer;
   l: TList;
   pstd: PTStdItem;
begin
   Result := nil;
   if gindex > 0 then
      try
      for i:=0 to GoodsList.Count-1 do begin
         l := TList(GoodsList[i]);
         if l.Count > 0 then
            if PTUserItem (l[0]).Index = gindex then begin
               Result := l;
               break;
            end;
      end;
      except
      end;
end;

procedure TMerchant.PriceUp (index: integer);
var
   i, price: integer;
   pstd: PTStdItem;
begin
   for i:=0 to PriceList.Count-1 do begin
      if PTPricesInfo(PriceList[i]).Index = index then begin
         price := PTPricesInfo(PriceList[i]).SellPrice;
         if price < Round(price * 1.1) then price := Round(price * 1.1)
         else price := price + 1;
         exit;
      end;
   end;
   pstd := UserEngine.GetStdItem (index);
   if pstd <> nil then
      NewPrice (index, Round (pstd.Price * 1.1));
end;

procedure TMerchant.PriceDown (index: integer);
var
   i, price: integer;
   pstd: PTStdItem;
begin
   for i:=0 to PriceList.Count-1 do begin
      if PTPricesInfo(PriceList[i]).Index = index then begin
         price := PTPricesInfo(PriceList[i]).SellPrice;
         if price > Round(price / 1.1) then price := Round(price / 1.1)
         else price := price - 1;
         price := _MAX(2, price); //������ 2���� ���� �� ����. //_MIN->_MAX�� ����(sonmg)
         exit;
      end;
   end;
   pstd := UserEngine.GetStdItem (index);
   if pstd <> nil then
      NewPrice (index, Round (pstd.Price * 1.1));
end;

procedure TMerchant.NewPrice (index, price: integer);
var
   pi: PTPricesInfo;
begin
   new (pi);
   pi.Index := index;
   pi.SellPrice := price;
   PriceList.Add (pi);
   FrmDB.WriteMarketPrices (self, MarketName + '-' + MapName);
end;

//������ ��ǥ ����
function  TMerchant.GetPrice (index: integer): integer; //-1: not found
var
   i, price: integer;
   pstd: PTStdItem;
begin
   price := -2;
   for i:=0 to PriceList.Count-1 do begin
      if PTPricesInfo(PriceList[i]).Index = index then begin
         price := PTPricesInfo(PriceList[i]).SellPrice;
         break;
      end;
   end;
   if price < 0 then begin
      pstd := UserEngine.GetStdItem (index);
      if (pstd <> nil) and IsDealingItem (pstd.StdMode, pstd.Shape ) then begin
         price := pstd.Price;
      end;
   end;
   Result := price;
end;

//������ ���� ����
function  TMerchant.GetGoodsPrice (uitem: TUserItem): integer;
var
   i, price, upg: integer;
   dam: Real;
   pstd: PTStdItem;
begin
   price := GetPrice (uitem.Index);
   if price > 0 then begin
      pstd := UserEngine.GetStdItem (uitem.Index);
      if pstd <> nil then
         if (pstd.OverlapItem < 1) and (pstd.StdMode > 4) and (pstd.DuraMax > 0) and
            (uitem.DuraMax > 0) and (pstd.StdMode <> 8) then begin   //�ʴ��� ����
            //����
            if pstd.StdMode = 40 then begin
               if (uitem.Dura <= uitem.DuraMax) then begin //�Ϲ� ���
                  dam := (price / 2 / uitem.DuraMax) * (uitem.DuraMax - uitem.Dura);
                  price := _MAX(2, Round(price - dam));
               end else begin //��ǰ�� ���� ���
                  price := price + Round((uitem.Dura-uitem.DuraMax) * (price/uitem.DuraMax*2)); //������ ���� �ö�
               end;
            end;
            //������
            if pstd.StdMode = 43 then begin
               if uitem.DuraMax < 10000 then uitem.DuraMax := 10000;
               if uitem.Dura <= uitem.DuraMax then begin //�Ϲ� ���
                  dam := (price / 2 / uitem.DuraMax) * (uitem.DuraMax - uitem.Dura);
                  price := _MAX(2, Round(price - dam));
               end else begin //��ǰ�� ���� ���
                  price := price + Round((uitem.Dura-uitem.DuraMax) * (price/uitem.DuraMax*1.3)); //������ ���� �ö�
               end;
            end;
            if (pstd.OverlapItem < 1) and (pstd.StdMode > 4) then begin //�þ�,��ũ��,���� ����
               //���׷��̵� �� �ɷ�
               // ������ ���....
               upg := 0;
               for i:=0 to 7 do begin  //�ɷ�ġ ����� 0..7
                  if (pstd.StdMode = 5) or (pstd.StdMode = 6) then begin //�����
                     if (i = 4) or (i = 9) then continue; //����, ���׷��̵� ���д� ����
                     if i = 6 then begin
                        if uitem.Desc[i] > 10 then //���� �ӵ� (+)
                           upg := upg + (uitem.Desc[i] - 10) * 2;
                        continue; //���ݼӵ�(-)�� ����
                     end;
                     upg := upg + uitem.Desc[i];
                  end else
                     upg := upg + uitem.Desc[i];
               end;
               if upg > 0 then begin  //���׷��̵� �� �������� ��δ�
                  price := price + (price div 5) * upg;
               end;

               //��ü ���� �˻�
               price := Round ((price / pstd.DuraMax) * uitem.DuraMax);
               //���� ���� �˻�
               dam := (price / 2 / uitem.DuraMax) * (uitem.DuraMax - uitem.Dura);
               price := _MAX(2, Round(price - dam));
            end;
         end;
   end;
   Result := price;
end;

//whocret: ���ǰ��� �������, ����� ���� ������ Ʋ���� �� �ִ�.
//price: ���� ����
function  TMerchant.GetSellPrice (whocret: TUserHuman; price: integer): integer;
var
   prate: integer;
begin
   if BoCastleManage then begin //���ȿ��� ����, ���� �����ϴ� ���Ŀ��鿡�Դ�
                              //�ΰ� �ش�.
      if UserCastle.IsOurCastle (TGuild(whocret.MyGuild)) then begin
         prate := _MAX(60, Round (PriceRate * 0.8));
         Result := Round (price / 100 * prate);
      end else
         Result := Round (price / 100 * PriceRate);
   end else
      Result := Round (price / 100 * PriceRate);
end;

function  TMerchant.GetBuyPrice (price: integer): integer;
begin
   Result := Round (price / 2);
end;

function  TMerchant.IsDealingItem (stdmode: integer ; shape :integer ): Boolean;
var
   i: integer;
   _stdmode : integer;
   _shape   : integer;
   str1 , str2 : string;
begin
   Result := FALSE;
   for i:=0 to DealGoods.Count-1 do begin
      str2 := GetValidStr3 ( DealGoods.Strings[i], str1, [',',' ']);
      _stdmode := Str_ToInt( str1 , -1 );
      _shape   := Str_ToInt( str2 , -1 );
      // Test 2003-09-20 PDS
      // MainOutMessage( 'Merchant Dealing Stdmode,Shape:'+IntTostr(_stdmode)+','+IntTostr(_shape));
      if ( _stdmode = stdmode )then
      begin
         if _shape <> -1 then
         begin
            if ( _shape = shape ) then
            begin
                result := TRUE;
                break;
            end;
         end
         else
         begin
           Result := TRUE;
           break;
         end;
      end;
   end;
end;

procedure TMerchant.RefillGoods; //���� �ð� üũ�ؼ� ������ ��ǰ�� �����ϰ� �ʿ��ϸ� ���� ����
   procedure RefillNow (var list: TList; itemname: string; fcount: integer);
   var
      i: integer;
      pu: PTUserItem;
      ps: PTStdItem;
   begin
      if list = nil then begin
         list := TList.Create;
         GoodsList.Add (list);
      end;
      for i:=0 to fcount-1 do begin
         new (pu);
         if UserEngine.CopyToUserItemFromName (itemname, pu^) then begin
            ps := UserEngine.GetStdItem(pu.Index);
            if ps <> nil then
            begin
               // ī��Ʈ������
               if ps.OverlapItem >= 1 then begin
                  pu.Dura := 1;
               end;

               list.Insert (0, pu); //���Ŵ� ó������..
            end//if ps <> nil then
            else
                Dispose(pu);
         end else
            Dispose (pu);
      end;
   end;
   procedure WasteNow (var list: TList; wcount: integer);
   var
      i: integer;
   begin
      for i:=list.Count-1 downto 0 do begin
         if wcount <= 0 then break;
         try
         Dispose (PTUserItem (list[i]));
         finally
         list.Delete (i);
         end;
         Dec (wcount);
      end;
   end;
var
   i,j, k, stock, gindex: integer;
   pp: PTMarketProduct;
   list, l: TList;
   flag : Boolean;
   step : integer;
   ItemChanged : Boolean;
begin
   ItemChanged := false;
   i    := 0;
   step := 0;
   try
      step := 0;
      for i:=0 to ProductList.Count-1 do begin
         step := 1;
         pp := ProductList[i];
       if GetTickCount - pp.ZenTime > longword(pp.ZenHour) * 60 * 1000 then begin
         // 2003/03/04 ���� �� Ÿ�� ���� 1�� -> 1�ð�
//         if GetTickCount - pp.ZenTime > longword(pp.ZenHour) * 60 * 60 * 1000 then begin
            step := 3;
            pp.ZenTime := GetTickCount;
            gindex := UserEngine.GetStdItemIndex (pp.GoodsName);  //�̸����� ������ �ε����� ����
            if gindex >= 0 then begin
               step := 4;
               list := nil;
               list := GetGoodsList (gindex);
               stock := 0;
               if list <> nil then stock := list.Count;
               if stock < pp.Count then begin //������ ����
                  step := 5;
                  PriceUp (gindex);
                  RefillNow (list, pp.GoodsName, pp.Count-stock);  //���� �߰��� �տ��� ����
//MainOutMessage('[[[Refill Goods...]]] NPC:' + UserName + '(' + IntToStr(CreateIndex) + ')'); // Lag Test
                  ItemChanged := true;
                  //����
                  // FrmDB.WriteMarketSavedGoods (self, MarketName + '-' + MapName);
                  // FrmDB.WriteMarketPrices (self, MarketName + '-' + MapName);
                  step := 6;
               end;
               if stock > pp.Count then begin //������ ���� ����. ������.
                  step := 7;
                  /////PriceDown (gindex);
                  WasteNow (list, stock - pp.Count); //�ڿ��� ���� ����
//MainOutMessage('[[[Waste Goods...]]] NPC:' + UserName); // Lag Test
                  ItemChanged := true;
                  //����
                  // FrmDB.WriteMarketSavedGoods (self, MarketName + '-' + MapName);
                  // FrmDB.WriteMarketPrices (self, MarketName + '-' + MapName);
                  step := 8;
               end;
            end;
         end;
      end;

      if ItemChanged then begin
         // 10 ���� �ѹ��� ������ �ϰ��Ѵ� 5�� x 10 = 50 �п� �ѹ��� �����
         if ( fSaveToFileCount >= 10 ) then begin
            FrmDB.WriteMarketSavedGoods (self, MarketName + '-' + MapName);
            FrmDB.WriteMarketPrices (self, MarketName + '-' + MapName);
            fSaveToFileCount := 0;
         end else begin
            inc ( fSaveToFileCount );
         end;
      end;
      //�̻������� ������ ������ ����� �����߿��� 1000�� �̻��̸� ������.
      //�� �������� ���� ���� 5000�� �̻� ����
      for j:=0 to GoodsList.Count-1 do begin
         step := 9;
         l := TList(GoodsList[j]);
         step := 10;
         if l.Count > 1000 then begin
            //�� �������� ���°��� �������� ����.
            flag := FALSE;
            for k:=0 to ProductList.Count-1 do begin
               step := 11;
               pp := ProductList[k];
               gindex := UserEngine.GetStdItemIndex (pp.GoodsName);  //�̸����� ������ �ε����� ����
               if PTUserItem (l[0]).Index = gindex then begin
                  step := 12;
                  flag := TRUE; //
                  break;
               end;
            end;
            step := 13;
            if not flag then begin
               WasteNow (l, l.count - 1000); //�ڿ��� ���� ����
            end else
               WasteNow (l, l.count - 5000); //�ڿ��� ���� ����
         end;
      end;

   except
      MainOutMessage ('Merchant RefillGoods Exception..Step=('+IntToStr(step)+')' );
   end;
end;

procedure TMerchant.CheckNpcSayCommand (hum: TUserHuman; var source: string; tag: string);
begin
   inherited CheckNpcSayCommand (hum, source, tag);
   if tag = '$PRICERATE' then begin
      source := ChangeNpcSayTag (source, '<$PRICERATE>', IntToStr(PriceRate));
   end;
   if tag = '$UPGRADEWEAPONFEE' then begin
      source := ChangeNpcSayTag (source, '<$UPGRADEWEAPONFEE>', IntToStr(UPGRADEWEAPONFEE));
   end;
   if tag = '$USERWEAPON' then begin
      if hum.UseItems[U_WEAPON].Index <> 0 then
         source := ChangeNpcSayTag (source, '<$USERWEAPON>', UserEngine.GetStdItemName(hum.UseItems[U_WEAPON].Index))
      else
         source := ChangeNpcSayTag (source, '<$USERWEAPON>', 'Weapon');
   end;
end;

procedure TMerchant.UserCall (caller: TCreature);
var
   data: string;
   n: integer;
begin
   NpcSayTitle (caller, '@main');
end;

procedure TMerchant.SaveUpgradeItemList;
begin
   try
      FrmDB.WriteMarketUpgradeInfos (UserName, UpgradingList);
   except
      MainOutMessage ('Failure in saving upgradinglist - ' + UserName);
   end;
end;

procedure TMerchant.LoadUpgradeItemList;
var
   i: integer;
begin
   for i:=0 to UpgradingList.Count-1 do
      Dispose (PTUpgradeInfo (UpgradingList[i]));
   UpgradingList.Clear;
   try
      FrmDB.LoadMarketUpgradeInfos (UserName, UpgradingList);
   except
      MainOutMessage ('Failure in loading upgradinglist - ' + UserName);
   end;
end;

//30�п� �� ���� �ʹ� ������µ� �� ã�ư��� �������� �����Ѵ�
//7�� �̻� �� ã�� ���� �������� �����ȴ�.
procedure TMerchant.VerifyUpgradeList;
var
   i, old   : integer;
   pup      : PTUpgradeInfo;
   realdate : Real;
begin
   old := 0;
   for i:=UpgradingList.Count-1 downto 0 do
   begin
      pup := PTUpgradeInfo (UpgradingList[i]);
      // TO PDS: CHeck Null..
      if pup <> Nil then begin

         realdate := real(Date ) - real(pup.readydate);

         try // Round �ÿ� ���� ������ ���� �߻� PDS
            old := Round(realdate);
         except
            on EInvalidOp do old := 0;
         end;

         if old >= 8 then begin //7+1�� �̻� ���� ��
            Dispose (pup);
            UpgradingList.Delete (i);
         end;

      end else begin
         MainOutMessage ('pup Is Nil... ');
      end;

   end;
end;

procedure TMerchant.UserSelectUpgradeWeapon (hum: TUserHuman);
   procedure PrepareWeaponUpgrade (ilist: TList; var adc, asc, amc, dura: byte);
   var
      i, k, d, s, m, dctop, dcsec, sctop, scsec, mctop, mcsec, durasum, duracount: integer;
      ps: PTStdItem;
      dellist: TStringList;
      sumlist: TList;
      std: TStdItem;
   begin
      dctop := 0; dcsec := 0;
      sctop := 0; scsec := 0;
      mctop := 0; mcsec := 0;
      durasum := 0;
      duracount := 0;
      dellist := nil;
      sumlist := TList.Create;

      for i := ilist.Count-1 downto 0 do begin
         if UserEngine.GetStdItemName(PTUserItem(ilist[i]).Index) = __BlackStone then begin
            sumlist.Add (pointer(Round(PTUserItem(ilist[i]).dura / 1000)));
            //durasum := durasum +
            //Inc (duracount);

            if dellist = nil then dellist := TStringList.Create;
            dellist.AddObject(__BlackStone, TObject(PTUserItem(ilist[i]).MakeIndex));

            Dispose(PTUserItem(ilist[i]));
            ilist.Delete (i);
         end else begin
            if IsUpgradeWeaponStuff (PTUserItem(ilist[i]).Index) then begin
               ps := UserEngine.GetStdItem (PTUserItem(ilist[i]).Index);
               if ps <> nil then begin
                  std := ps^;
                  ItemMan.GetUpgradeStdItem (PTUserItem(ilist[i])^, std);

                  d := 0;  s := 0;  m := 0;

                  case std.StdMode of
                     19,20,21: begin  //�����
                           d := Lobyte(std.DC) + Hibyte(std.DC);
                           s := Lobyte(std.SC) + Hibyte(std.SC);
                           m := Lobyte(std.MC) + Hibyte(std.MC);
                        end;
                     22,23: begin     //����
                           d := Lobyte(std.DC) + Hibyte(std.DC);
                           s := Lobyte(std.SC) + Hibyte(std.SC);
                           m := Lobyte(std.MC) + Hibyte(std.MC);
                        end;
                     24,26: begin     //����
                           d := Lobyte(std.DC) + Hibyte(std.DC) + 1;
                           s := Lobyte(std.SC) + Hibyte(std.SC) + 1;
                           m := Lobyte(std.MC) + Hibyte(std.MC) + 1;
                        end;
                  end;

                  if dctop < d then begin dcsec := dctop; dctop := d;
                  end else if dcsec < d then dcsec := d;

                  if sctop < s then begin scsec := sctop; sctop := s;
                  end else if scsec < s then scsec := s;

                  if mctop < m then begin mcsec := mctop; mctop := m;
                  end else if mcsec < m then mcsec := m;

                  if dellist = nil then dellist := TStringList.Create;
                  dellist.AddObject(ps.Name, TObject(PTUserItem(ilist[i]).MakeIndex));

                  //�α׳���
                  AddUserLog ('26'#9 + //����_
                              hum.MapName + ''#9 +
                              IntToStr(hum.CX) + ''#9 +
                              IntToStr(hum.CY) + ''#9 +
                              hum.UserName + ''#9 +
                              UserEngine.GetStdItemName (PTUserItem(ilist[i]).Index) + ''#9 +
                              IntToStr(PTUserItem(ilist[i]).MakeIndex) + ''#9 +
                              '1'#9 +
                              ItemOptionToStr(PTUserItem(ilist[i]).desc));
                  Dispose(PTUserItem(ilist[i]));
                  ilist.Delete (i);
               end;
            end;
         end;
      end;
      for i:=0 to sumlist.Count-1 do begin
         for k:=sumlist.Count-1 downto i+1 do begin
            if integer(sumlist[k]) > integer(sumlist[k-1]) then begin
               sumlist.Exchange (k, k-1);
            end;
         end;
      end;
      for i:=0 to sumlist.Count-1 do begin
         durasum := durasum + integer(sumlist[i]);
         inc (duracount);
         if duracount >= 5 then break;
      end;

      //���� ���, 5�� ���� ���� ������ ��庥����
      dura := Round(_MIN(5,duracount) + (durasum/duracount) / 5 * _MIN(5,duracount));

      adc := dctop + dctop div 5 + dcsec div 3;  //�ı� 5�̻� ����ġ
      asc := sctop + sctop div 5 + scsec div 3;
      amc := mctop + mctop div 5 + mcsec div 3;

      if dellist <> nil then begin
         hum.SendMsg (hum, RM_DELITEMS, 0, integer(dellist), 0, 0, '');
         //dellist �� RM_DELITEMS ���� FREE �ȴ�.
      end;

      if sumlist <> nil then sumlist.Free;
   end;
var
   i: integer;
   flag: Boolean;
   pup: PTUpgradeInfo;
   pstd: PTStdItem;
begin
   flag := FALSE;
   //��� �ִ� ������ ���׷��̵带 �ñ��.
   for i:=0 to UpgradingList.Count-1 do begin
      if hum.UserName = PTUpgradeInfo(UpgradingList[i]).UserName then begin
         NpcSayTitle (hum, '~@upgradenow_ing');
         exit;
      end;
   end;

   if hum.UseItems[U_WEAPON].Index <> 0 then begin   //
      //--------------------------------------
      //����ũ�������� ���� ���ñ��...
      pstd := UserEngine.GetStdItem (hum.UseItems[U_WEAPON].Index);
      if pstd <> nil then begin
         // => UNIQUEITEM �ʵ尡 00000001(2����)�� �����ϸ� ���úҰ�(���׷��̵� ����) ������(sonmg 2005/12/09)
         if {pstd.UniqueItem = 1} (pstd.UniqueItem and $01) <> 0 then begin
            {$IFDEF KOREA} hum.BoxMsg('���ص���Ŀ��������', 0);
            {$ELSE}        hum.BoxMsg('���ص���Ŀ��������', 0);
            {$ENDIF}
            exit;
         end;
      end;
      //--------------------------------------

      if hum.Gold >= UPGRADEWEAPONFEE then begin  //���� �ִ���
         if hum.FindItemName (__BlackStone) <> nil then begin  //��ö�� ������ �ִ���
            hum.DecGold (UPGRADEWEAPONFEE);
            if BoCastleManage then  //5%�� ������ ������.
               UserCastle.PayTax (UPGRADEWEAPONFEE);
            hum.GoldChanged;

            //���濡 �ִ� �������� ���� �ִ´�.
            new (pup);
            pup.UserName := hum.UserName;
            pup.uitem := hum.UseItems[U_WEAPON];

            //�α׳���
            AddUserLog ('25'#9 + //����_ +
                        hum.MapName + ''#9 +
                        IntToStr(hum.CX) + ''#9 +
                        IntToStr(hum.CY) + ''#9 +
                        hum.UserName + ''#9 +
                        UserEngine.GetStdItemName (hum.UseItems[U_WEAPON].Index) + ''#9 +
                        IntToStr(hum.UseItems[U_WEAPON].MakeIndex) + ''#9 +
                        '1'#9 +
                        ItemOptionToStr(UseItems[U_WEAPON].desc));

            hum.SendDelItem (hum.UseItems[U_WEAPON]); //Ŭ���̾�Ʈ�� �������� ����
            hum.UseItems[U_WEAPON].Index := 0;
            hum.RecalcAbilitys;
            hum.FeatureChanged;
            hum.SendMsg (hum, RM_ABILITY, 0, 0, 0, 0, '');
            //hum.SendMsg (hum, RM_SUBABILITY, 0, 0, 0, 0, '');

            PrepareWeaponUpgrade (hum.ItemList, pup^.updc, pup^.upsc, pup^.upmc, pup^.durapoint);

            pup.readydate := Now;
            pup.readycount := GetTickCount;

            UpgradingList.Add (pup);
            SaveUpgradeItemList;

            flag := TRUE;
         end;
      end;

   end;
   if flag then
      NpcSayTitle (hum, '~@upgradenow_ok')
   else
      NpcSayTitle (hum, '~@upgradenow_fail');
end;

procedure TMerchant.UserSelectGetBackUpgrade (hum: TUserHuman);
var
   i, per, n: integer;
   state, rand: integer;
   pup: PTUpgradeInfo;
   pu: PTUserItem;
begin
   state := 0;
   pup := nil;
   if hum.CanAddItem then begin
      for i:=0 to UpgradingList.Count-1 do begin
         if hum.UserName = PTUpgradeInfo(UpgradingList[i]).UserName then begin
            state := 1;  //�ñ� ���� ����
            if (GetTickCount - PTUpgradeInfo(UpgradingList[i]).readycount > 60 * 60 * 1000) or
               (hum.UserDegree >= UD_ADMIN)
            then begin
               //�� �Ǿ�����
               pup := PTUpgradeInfo(UpgradingList[i]);
               UpgradingList.Delete (i);
               SaveUpgradeItemList;
               state := 2;
               break;
            end;
         end;
      end;
      if (pup <> nil) then begin
         //���� ����
         case pup.durapoint of
            0..8:
               begin
//                  n := _MAX(3000, pup.uitem.DuraMax div 2);
                  if pup.uitem.DuraMax > 3000 then pup.uitem.DuraMax := pup.uitem.DuraMax - 3000
                  else pup.uitem.DuraMax := pup.uitem.DuraMax div 2;
                  if pup.uitem.Dura > pup.uitem.DuraMax then
                     pup.uitem.Dura := pup.uitem.DuraMax;
               end;
            9..15:
               begin
                  if Random(pup.durapoint) < 6 then
                     pup.uitem.DuraMax := _MAX(0, pup.uitem.DuraMax - 1000);  //DURAMAX����
               end;
            //16..19
            18..255:
               begin
                  case Random(pup.durapoint-18) of
                     1..4:  pup.uitem.DuraMax := pup.uitem.DuraMax + 1000;
                     5..7: pup.uitem.DuraMax := pup.uitem.DuraMax + 2000;
                     8..255: pup.uitem.DuraMax := pup.uitem.DuraMax + 4000;
                  end;
               end;
         end;

         if (pup.updc = pup.upmc) and (pup.upmc = pup.upsc) then begin
            rand := Random(3);
         end else rand := -1;

         //�ɷ�ġ
         if (pup.updc >= pup.upmc) and (pup.updc >= pup.upsc) or (rand = 0) then begin //�ı���
            //������ �� ���� ����
            per := _MIN(85, 10 + _MIN(11, pup.updc) * 7 +
                            pup.uitem.Desc[3]{���} - pup.uitem.Desc[4] +
                            hum.BodyLuckLevel);
            if Random(100) < per then begin
               pup.uitem.Desc[10] := 10;
               if (per > 63) and (Random(30) = 0) then pup.uitem.Desc[10] := 11;
               if (per > 79) and (Random(200) = 0) then pup.uitem.Desc[10] := 12;
            end else
               pup.uitem.Desc[10] := 1;
         end;
         if (pup.upmc >= pup.updc) and (pup.upmc >= pup.upsc) or (rand = 1) then begin //���¾�
            //������ �� ���� ����
            per := _MIN(85, 10 + _MIN(11, pup.upmc) * 7 +
                            pup.uitem.Desc[3] - pup.uitem.Desc[4] +
                            hum.BodyLuckLevel);
            if Random(100) < per then begin
               pup.uitem.Desc[10] := 20;
               if (per > 63) and (Random(30) = 0) then pup.uitem.Desc[10] := 21;
               if (per > 79) and (Random(200) = 0) then pup.uitem.Desc[10] := 22;
            end else
               pup.uitem.Desc[10] := 1;
         end;
         if (pup.upsc >= pup.upmc) and (pup.upsc >= pup.updc) or (rand = 2) then begin //���¾�
            //������ �� ���� ����
            per := _MIN(85, 10 + _MIN(11, pup.upsc) * 7 +
                            pup.uitem.Desc[3] - pup.uitem.Desc[4] +
                            hum.BodyLuckLevel);
            if Random(100) < per then begin
               pup.uitem.Desc[10] := 30;
               if (per > 63) and (Random(30) = 0) then pup.uitem.Desc[10] := 31;
               if (per > 79) and (Random(200) = 0) then pup.uitem.Desc[10] := 32;
            end else
               pup.uitem.Desc[10] := 1;
         end;

         new (pu);
         pu^ := pup.uitem;
         Dispose (pup);

         //�α׳���
         AddUserLog ('24'#9 + //��ã_ +
                     hum.MapName + ''#9 +
                     IntToStr(hum.CX) + ''#9 +
                     IntToStr(hum.CY) + ''#9 +
                     hum.UserName + ''#9 +
                     UserEngine.GetStdItemName (pu.Index) + ''#9 +
                     IntToStr(pu.MakeIndex) + ''#9 +
                     '1'#9 +
                     ItemOptionToStr(pu.desc));

         hum.AddItem (pu);
         hum.SendAddItem (pu^);

      end;

      case state of
         2: NpcSayTitle (hum, '~@getbackupgnow_ok');  //�ϼ�
         1: NpcSayTitle (hum, '~@getbackupgnow_ing');  //�۾���
         0: NpcSayTitle (hum, '~@getbackupgnow_fail');
      end;
   end else begin
      {$IFDEF KOREA} hum.SysMsg ('�㲻����Я��', 0);
      {$ELSE}        hum.SysMsg ('�㲻����Я��', 0);
      {$ENDIF}
      NpcSayTitle (hum, '@exit');
   end;
end;

///////////////////////////////////////////////////////////////
// UserSelect ���� �и�.
procedure TMerchant.SendGoodsEntry (who: TCreature; ltop: integer);  //
var
   i, count: integer;
   cg: TClientGoods;
   l: TList;
   pstd: PTStdItem;
   pu: PTUserItem;
   data: string;
begin
   data := '';
   count := 0;
   for i:=ltop to GoodsList.Count-1 do begin
      l := GoodsList[i];
      pu := PTUserItem (l[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := GetSellPrice (TUserHuman(who), GetPrice (pu.Index));//��ǥ ����, ������ ������.
         cg.Stock := l.Count;
         if (pstd.StdMode <= 4) or (pstd.StdMode = 42) or (pstd.StdMode = 31) then cg.SubMenu := 0 //�þ�,����,������, ����, ������..
         else cg.SubMenu := 1;

         // ī��Ʈ ������
         if pstd.OverlapItem >= 1 then
            cg.SubMenu := 2;

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
         Inc (count);
      end;
   end;
   who.SendMsg (self, RM_SENDGOODSLIST, 0, integer(self), count, 0, data);
end;
procedure TMerchant.SendSellGoods (who: TCreature); //�ȱ� �޴��ش�.
begin
   who.SendMsg (self, RM_SENDUSERSELL, 0, integer(self), 0, 0, '');
end;
procedure TMerchant.SendRepairGoods (who: TCreature); //�����ϱ� �޴�
begin
   who.SendMsg (self, RM_SENDUSERREPAIR, 0, integer(self), 0, 0, '');
end;
procedure TMerchant.SendSpecialRepairGoods (who: TCreature); //Ư�������ϱ� �޴�
var
   str: string;
begin
   //if specialrepair > 0 then begin
      {$IFDEF KOREA}
      str := '����һ��̫�����ˡ���������������Ͽ��������޲�\' +
                      '���۸������ͨ����������\ \ ' +
                      ' <����/@main> ';
      {$ELSE}
      str :=  '����һ��̫�����ˡ���������������Ͽ��������޲�\' +
                      '���۸������ͨ����������\ \ ' +
                      ' <����/@main> ';
      {$ENDIF}
//      str := ReplaceChar (str, '\', char($a));
//      NpcSay (who, str);
      NpcSayTitle (who, '@ready_s_repair');
      who.SendMsg (self, RM_SENDUSERSPECIALREPAIR, 0, integer(self), 0, 0, '');
   //end else begin
   //   {$IFDEF KOREA}
   //      NpcSay (who, '����... ��ᰡ �� �������� Ư��������\' +
   //             '����ڴ°�, ��ø� ��ٷ��� ��Ḧ ���� ��\' +
   //             '�ֳ�.. �ƽ����� ��ٷ��ְ�...\ \ <�ڷ�/@main>');
   //   {$ELSE}
   //      NpcSay (who, 'Sorry, but we ran out of material for special repairs\' +
   //             'Sorry but we have no materials for repairs, Please wait for a moment\' +
   //             ' \ <back/@main>');
   //   {$ENDIF}
   //   whocret.LatestNpcCmd := '@repair';
   //end;
end;
procedure TMerchant.SendStorageItemMenu (who: TCreature);
begin
   who.SendMsg (self, RM_SENDUSERSTORAGEITEM, 0, integer(self), 0, 0, '');
end;
procedure TMerchant.SendStorageItemList (who: TCreature);
begin
   who.SendMsg (self, RM_SENDUSERSTORAGEITEMLIST, 0, integer(self), 0, 0, '');
end;
procedure TMerchant.SendMakeDrugItemList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i:=0 to GoodsList.Count-1 do begin
      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEDRUGITEMLIST, 0, integer(self), 0, 0, data);
end;
///////////////////////////////////////////////////////
procedure TMerchant.SendMakeFoodList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i := 0 to GoodsList.Count-1 do begin
//      if i >= 12 then // MAKE FOOD
//         break;
      if i >= Str_ToInt(MakeItemIndexList[1], 0) - Str_ToInt(MakeItemIndexList[0], 0) then // MAKE FOOD
         break;

      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEITEMLIST, 0, integer(self), 1{���}, 0, data);
end;
///////////////////////////////////////////////////////
procedure TMerchant.SendMakePotionList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i := Str_ToInt(MakeItemIndexList[1], 0) - Str_ToInt(MakeItemIndexList[0], 0) to GoodsList.Count-1 do begin
//      if i >= 16 then // MAKE POTION
//         break;
      if i >= Str_ToInt(MakeItemIndexList[2], 0) - Str_ToInt(MakeItemIndexList[0], 0) then // MAKE FOOD
         break;

      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEITEMLIST, 0, integer(self), 2{���}, 0, data);
end;
///////////////////////////////////////////////////////
procedure TMerchant.SendMakeGemList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i := Str_ToInt(MakeItemIndexList[2], 0) - Str_ToInt(MakeItemIndexList[0], 0) to GoodsList.Count-1 do begin
//      if i >= 29 then // MAKE GEM
//         break;
      if i >= Str_ToInt(MakeItemIndexList[3], 0) - Str_ToInt(MakeItemIndexList[0], 0) then // MAKE FOOD
         break;

      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEITEMLIST, 0, integer(self), 3{���}, 0, data);
end;
///////////////////////////////////////////////////////
procedure TMerchant.SendMakeItemList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i := Str_ToInt(MakeItemIndexList[3], 0) - Str_ToInt(MakeItemIndexList[0], 0) to GoodsList.Count-1 do begin
//      if i >= 66 then // MAKE ITEM
//         break;
      if i >= Str_ToInt(MakeItemIndexList[4], 0) - Str_ToInt(MakeItemIndexList[0], 0) then // MAKE FOOD
         break;

      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEITEMLIST, 0, integer(self), 4{���}, 0, data);
end;
///////////////////////////////////////////////////////
procedure TMerchant.SendMakeStuffList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i := Str_ToInt(MakeItemIndexList[4], 0) - Str_ToInt(MakeItemIndexList[0], 0) to GoodsList.Count-1 do begin
      if i >= Str_ToInt(MakeItemIndexList[5], 0) - Str_ToInt(MakeItemIndexList[0], 0) then // MAKE STUFF
         break;

      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEITEMLIST, 0, integer(self), 5{���}, 0, data);
end;
///////////////////////////////////////////////////////
procedure TMerchant.SendMakeEtcList (who: TCreature);
const
   MAKEPRICE = 100;
var
   i, j: integer;
   data: string;
   cg: TClientGoods;
   pu: PTUserItem;
   pstd: PTStdItem;
   L: TList;
   sMakeItemName, sMakePrice: string;
begin
   data := '';
   for i := Str_ToInt(MakeItemIndexList[5], 0) - Str_ToInt(MakeItemIndexList[0], 0) to GoodsList.Count-1 do begin
      L := GoodsList[i];
      pu := PTUserItem (L[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         cg.Name := pstd.Name;
         cg.Price := MAKEPRICE;  //GetSellPrice (GetPrice (pu.Index));//�ุ��� ���
         for j:=0 to MakeItemList.Count-1 do begin
            sMakePrice := GetValidStr3(MakeItemList[j], sMakeItemName, [':']);
            if cg.Name = sMakeItemName then begin
               cg.Price := Str_ToInt(sMakePrice, 0);
               break;
            end;
         end;
         cg.Stock := 1;    //l.Count;
         cg.SubMenu := 0; //�þ�,����,������...

         data := data + cg.Name + '/' + IntToStr(cg.SubMenu) + '/' + IntToStr(cg.Price) + '/' + IntToStr(cg.Stock) + '/';
      end;
   end;
   if data <> '' then
      who.SendMsg (self, RM_SENDUSERMAKEITEMLIST, 0, integer(self), 6{���}, 0, data);
end;
///////////////////////////////////////////////////////////////

procedure TMerchant.UserSelect (whocret: TCreature; selstr: string);
var
   sel, body, rmsg: string;
   i: integer;
   goflag: Boolean;
   psayproc: PTSayingProcedure;
begin
   try
      if (BoCastleManage and UserCastle.BoCastleUnderAttack) or
         //��ϼ��ȿ� �ִ� ������ ������ �߿��� ������ ���� �ʴ´�.
         whocret.Death
      then begin
         ;
      end else begin
         body := GetValidStr3 (selstr, sel, [#13]);

         if (sel <> '') then begin

            goflag := TRUE;
{
            goflag := FALSE;
            if (CompareText(sel, '@main') <> 0) then begin
               if TUserHuman(whocret).CurSayProc <> nil then begin
                  psayproc := PTSayingProcedure(TUserHuman(whocret).CurSayProc);
                  for i:=0 to psayproc.AvailableCommands.Count-1 do begin
                     if CompareText(sel, psayproc.AvailableCommands[i]) = 0 then begin
                        goflag := TRUE;
                        break;
                     end;
                  end;
               end;
            end else
               goflag := TRUE;
}

            if (sel[1] = '@') then begin
//          if goflag and (sel[1] = '@') then begin
               rmsg := '';
               while TRUE do begin
                  whocret.LatestNpcCmd := sel;

                  //---------------------------------------
                  //���� ���ϴ� ���� ���α׷��Ǿ� ����
                  if CanSpecialRepair then
                     if CompareText(sel, '@s_repair') = 0 then begin
                        SendSpecialRepairGoods (whocret);
                        break;
                     end;
                  if CanTotalRepair then
                     if CompareText(sel, '@t_repair') = 0 then begin
                        SendSpecialRepairGoods (whocret);
                        break;
                     end;
                  //---------------------------------------

                  //���θ��ϴ� ���� �о ����.
                  NpcSayTitle (whocret, sel);

                  if CanBuy then
                     if CompareText(sel, '@buy') = 0 then begin
                        //��ǰ ������ ������.  10���� ��� ������.
                        SendGoodsEntry (whocret, 0);
                        break;
                     end;
                  if CanSell then
                     if CompareText(sel, '@sell') = 0 then begin
                        SendSellGoods (whocret);
                        break;
                     end;
                  if CanRepair then
                     if CompareText(sel, '@repair') = 0 then begin
                        SendRepairGoods (whocret);
                        break;
                     end;
                  if CanMakeDrug then
                     if CompareText(sel, '@makedrug') = 0 then begin
                        SendMakeDrugItemList (whocret);
                        break;
                     end;
                  if CompareText(sel, '@prices') = 0 then begin
                     //�ü� ����...
                     break;
                  end;
                  if CanStorage then
                     if CompareText(sel, '@storage') = 0 then begin
                        SendStorageItemMenu (whocret);
                        break;
                     end;
                  if CanGetBack then
                     if CompareText(sel, '@getback') = 0 then begin
                        SendStorageItemList (whocret);
                        break;
                     end;

                     //���� ���׷��̵�
                  if CanUpgrade then begin
                     if CompareText(sel, '@upgradenow') = 0 then begin
                        UserSelectUpgradeWeapon (TUserHuman(whocret));
                        break;
                     end;
                     if CompareText(sel, '@getbackupgnow') = 0 then begin
                        UserSelectGetBackUpgrade (TUserHuman(whocret));
                        break;
                     end;
                  end;

                  // ������ ����
                  if CanMakeItem then begin
                     if CompareText(sel, '@makefood') = 0 then begin
                        SendMakeFoodList (whocret);
//                        rmsg := '~@makefood';
//                        NpcSayTitle (whocret, rmsg);
//                        UserSelectMakeFood (TUserHuman(whocret));
                        break;
                     end;
                     if CompareText(sel, '@makepotion') = 0 then begin
                        SendMakePotionList (whocret);
//                        rmsg := '~@makepotion';
//                        NpcSayTitle (whocret, rmsg);
//                        UserSelectMakePotion (TUserHuman(whocret));
                        break;
                     end;
                     if CompareText(sel, '@makegem') = 0 then begin
                        SendMakeGemList (whocret);
//                        rmsg := '~@makegem';
//                        NpcSayTitle (whocret, rmsg);
//                        UserSelectMakeGem (TUserHuman(whocret));
                        break;
                     end;
                     if CompareText(sel, '@makeitem') = 0 then begin
                        SendMakeItemList (whocret);
//                        rmsg := '~@makeitem';
//                        NpcSayTitle (whocret, rmsg);
//                        UserSelectMakeItem (TUserHuman(whocret));
                        break;
                     end;
                     if CompareText(sel, '@makestuff') = 0 then begin
                        SendMakeStuffList (whocret);
//                        rmsg := '~@makestuff';
//                        NpcSayTitle (whocret, rmsg);
//                        UserSelectMakeStuff (TUserHuman(whocret));
                        break;
                     end;
                     if CompareText(sel, '@makeetc') = 0 then begin
                        SendMakeEtcList (whocret);
//                        rmsg := '~@makeetc';
//                        NpcSayTitle (whocret, rmsg);
//                        UserSelectMakeEtc (TUserHuman(whocret));
                        break;
                     end;
                  end;

                  //��Ź�ǸŰ���...
                  if CanItemMarket and ( whocret <> nil )and ( whocret.RaceServer = RC_USERHUMAN )then
                  begin
                    if  CompareText( sel, '@market_0') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_ALL,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_1') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_WEAPON,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_2') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_NECKLACE,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_3') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_RING,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_4') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_BRACELET,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_5') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_CHARM,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_6') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_HELMET,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_7') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_BELT,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_8') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_SHOES,  USERMARKET_MODE_BUY );
                        break;
                    end;

                    if  CompareText( sel, '@market_9') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_ARMOR,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_10') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_DRINK,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_11') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_JEWEL,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_12') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_BOOK,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_13') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_MINERAL,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_14') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_QUEST,  USERMARKET_MODE_BUY );
                        break;
                    end;
                    if  CompareText( sel, '@market_15') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_ETC,  USERMARKET_MODE_BUY );
                        break;
                    end;

                    if  CompareText( sel, '@market_100') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_SET,  USERMARKET_MODE_BUY );
                        break;
                    end;

                    if  CompareText( sel, '@market_200') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_MINE,  USERMARKET_MODE_INQUIRY );
                        break;
                    end;

                    if  CompareText( sel, '@market_sell') = 0 then
                    begin
                        SendUserMarket( TUserHuman ( whocret ) ,USERMARKET_TYPE_ALL,  USERMARKET_MODE_SELL );
                        break;
                    end;

                  end;

                  // ���� ���
                  if CanAgitUsage and {(ServerIndex = 0) and} (whocret <> nil) then begin
                     if CompareText( sel, '@agitreg') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitRegistration;
                     end;
                     if CompareText( sel, '@agitmove') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitAutoMove;
                     end;
                     if CompareText( sel, '@agitbuy') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitBuy ( 1 );
                     end;
                     if CompareText( sel, '@agittrade') = 0 then begin
                        TUserHuman(whocret).BoGuildAgitDealTry := TRUE; //����ŷ�����
                        TUserHuman(whocret).CmdTryGuildAgitTrade;
                     end;
                  end;
                  // ���� ���(����)
                  if CanAgitManage and {(ServerIndex = 0) and} (whocret <> nil) then begin
                     if CompareText( sel, '@agitextend') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitExtendTime( 1 );
                     end;
                     if CompareText( sel, '@agitremain') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitRemainTime;
                     end;
                     if CompareText( sel, '@@agitonerecall') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitRecall (body, FALSE);
                     end;
                     if CompareText( sel, '@agitrecall') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitRecall ('', TRUE);
                     end;
                     if CompareText( sel, '@@agitforsale') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitSale ( body );
                     end;
                     if CompareText( sel, '@agitforsalecancel') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitSaleCancel;
                     end;
                     if CompareText( sel, '@gaboardlist') = 0 then begin
                        TUserHuman(whocret).CmdGaBoardList ( 1 );
                     end;
                     if CompareText( sel, '@@guildagitdonate') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitDonate (body);
                     end;
                     if CompareText( sel, '@viewdonation') = 0 then begin
                        TUserHuman(whocret).CmdGuildAgitViewDonation;
                     end;
                     if CompareText( sel, '@gaboarddelall') = 0 then begin
                        TUserHuman(whocret).CmdGaBoardDelAll;
                     end;
                  end;
                  // ����ٹ̱�
                  if CanBuyDecoItem and (whocret <> nil) then begin
                     if CompareText( sel, '@ga_decoitem_buy') = 0 then begin
                        SendDecoItemListShow(whocret);
                     end;
                     if CompareText( sel, '@ga_decomon_count') = 0 then begin
                        TUserHuman(whocret).CmdAgitDecoMonCountHere;
                     end;
                  end;
                  // ��ġ
                  if CanDoingEtc and (whocret <> nil) then begin
                     if CompareText( sel, '@@freepkother') = 0 then begin
                        //PkPoint ����
                        if TUserHuman(whocret).CmdDeletePKPoint (body) then begin
                           //��ġ ��� ����
                           TUserHuman(whocret).ZeroFamePoint;
                           TUserHuman(whocret).BoxMsg('�����������' + body + '����Ϊ�ָ���', 0);
                        end;
                     end;
                  end;

                  if CompareText(sel, '@exit') = 0 then begin
                     whocret.SendMsg (self, RM_MERCHANTDLGCLOSE, 0, integer(self), 0, 0, '');
                     break;
                  end;
                  break;
               end;
            end;
         end;
      end;
   except
      MainOutMessage ('[Exception] TMerchant.UserSelect... ');
   end;
end;

// ���� ������ ��� ����.
procedure TMerchant.SayMakeItemMaterials (whocret: TCreature; selstr: string);
var
   rmsg: string;
begin
   rmsg := '@';

   // selstr is itemname...
   rmsg := rmsg + selstr;

   NpcSayTitle (whocret, rmsg);
end;

procedure TMerchant.QueryPrice (whocret: TCreature; uitem: TUserItem);
var
   i, buyprice: integer;
begin
   buyprice := GetBuyPrice (GetGoodsPrice (uitem));  //���� ������ �˷���
   if buyprice >= 0 then begin
      whocret.SendMsg (self, RM_SENDBUYPRICE, 0, buyprice, 0, 0, '');
   end else
      whocret.SendMsg (self, RM_SENDBUYPRICE, 0, 0, 0, 0, '');  //����..
end;

function  TMerchant.AddGoods (uitem: TUserItem): Boolean;
var
   pu: PTUserItem;
   list: TList;
   pstd: PTStdItem;
begin
   if uitem.DuraMax > 0 then begin //�������� 0�ΰ��� �ս� ó���Ѵ�. (������ ����)
      list := GetGoodsList (uitem.Index);
      if list = nil then begin
         list := TList.Create;
         GoodsList.Add (list);
      end;
      new (pu);
      // 2003/06/12 ����ڰ� ���� ������ �������� �ִ볻���� �����Ͽ�
      // �� ���ݿ� �ǻ�� ������ ����
      pstd := UserEngine.GetStdItem (uitem.Index);
      if pstd <> nil then begin
         //�������ȶ��,�������� ������ �ִ�� �������� �ʴ´�(sonmg 2004/07/16)
         if(pstd.StdMode = 0) or (pstd.StdMode = 31) or
          ((pstd.StdMode = 3) and ((pstd.Shape = 1) or (pstd.Shape = 2) or (pstd.Shape = 3) or (pstd.Shape = 5) or (pstd.Shape = 9)))
           {or (pstd.StdMode = 25)} or ((pstd.StdMode = 30) and (pstd.Shape = 0)) then begin
            uitem.Dura := uitem.DuraMax;
         end;
      end;
      pu^ := uitem;
      list.Insert (0, pu);
   end;
   Result := TRUE;
end;

function  TMerchant.UserSellItem (whocret: TCreature; uitem: TUserItem): Boolean;
   function CanSell (pu: PTUserItem): Boolean;
   var
      pstd: PTStdItem;
   begin
      Result := TRUE;
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         if (pstd.UniqueItem and $08) <> 0 then Result := FALSE; //UNIQUEITEM �ʵ尡 00001000(2����)�� �����ϸ� ��ȯ �� �����ŷ� �� �� ���� ������(sonmg 2005/03/14)
         if (pstd.StdMode = 25) or (pstd.StdMode = 30) then begin
            if pu.Dura < 4000 then
               Result := FALSE;
         end else if (pstd.StdMode = 8) then begin   //�ʴ����� �� �� ����.
            Result := FALSE;
         end;
      end;
   end;
var
   i, buyprice: integer;
   pstd : PTStdItem;
begin
   Result := FALSE;
   buyprice := GetBuyPrice (GetGoodsPrice (uitem));  //���� ���� ����
   if (buyprice >= 0) and (not NoSeal) and CanSell(@uitem) then begin    //����ڰ� ������ ����. ��ǰ ���Ե� ����
      if whocret.IncGold (buyprice) then begin

         //��ϼ����� ������ ���
         if BoCastleManage then  //5%�� ������ ������.
            UserCastle.PayTax (buyprice);

         whocret.SendMsg (self, RM_USERSELLITEM_OK, 0, whocret.Gold, 0, 0, '');
         //��ǰ�� �߰�
         AddGoods (uitem);

         //�α׳���
         pstd := UserEngine.GetStdItem(uitem.Index);
         if ( pstd <> nil ) and ( not IsCheapStuff (pstd.StdMode) ) then begin
            AddUserLog ('10'#9 + //�Ǹ�_ +
                        whocret.MapName + ''#9 +
                        IntToStr(whocret.CX) + ''#9 +
                        IntToStr(whocret.CY) + ''#9 +
                        whocret.UserName + ''#9 +
                        UserEngine.GetStdItemName (uitem.Index) + ''#9 +
                        IntToStr(uitem.MakeIndex) + ''#9 +
                        '1'#9 +
                        UserName);
         end;

         Result := TRUE;
      end else //���� �ʹ� ����.
         whocret.SendMsg (self, RM_USERSELLITEM_FAIL, 0, 0, 1, 0, '');
   end else //��� ����
      whocret.SendMsg (self, RM_USERSELLITEM_FAIL, 0, 0, 0, 0, '');
end;

//ī��Ʈ ������
function  TMerchant.UserCountSellItem (whocret: TCreature; uitem: TUserItem; sellcnt: integer): Boolean;
var
   remain: integer;
   i, buyprice: integer;
   pstd: PTStdItem;
begin
   Result := FALSE;
   buyprice := -1;

   pstd := UserEngine.GetStdItem(uitem.Index);
   if pstd <> nil then begin
      if IsDealingItem(pstd.StdMode, pstd.Shape) then
         buyprice := GetBuyPrice(GetGoodsPrice(uitem)) * sellcnt; //���� ���� ����
   end;

   remain := uitem.Dura - sellcnt;

   if (buyprice >= 0) and (not NoSeal) and (remain >= 0) then begin //����ڰ� ������ ����. ��ǰ ���Ե� ����
      if whocret.IncGold (buyprice) then begin

         //��ϼ����� ������ ���
         if BoCastleManage then  //5%�� ������ ������.
            UserCastle.PayTax (buyprice);

         whocret.SendMsg (self, RM_USERSELLCOUNTITEM_OK, 0, whocret.Gold, remain, sellcnt, '');

         //��ǰ�� �߰�
//         AddGoods (uitem);
         //�α׳���
         AddUserLog ('10'#9 + //�Ǹ�_ +
                     whocret.MapName + ''#9 +
                     IntToStr(whocret.CX) + ''#9 +
                     IntToStr(whocret.CY) + ''#9 +
                     whocret.UserName + ''#9 +
                     UserEngine.GetStdItemName (uitem.Index) + ''#9 +
                     IntToStr(uitem.MakeIndex) + ''#9 +
                     '1'#9 +
                     UserName);
         Result := TRUE;
      end else //���� �ʹ� ����.
         whocret.SendMsg (self, RM_USERSELLCOUNTITEM_FAIL, 0, 0, 0, 0, '');
   end else //��� ����
      whocret.SendMsg (self, RM_USERSELLCOUNTITEM_FAIL, 0, 0, 0, 0, '');
end;

procedure TMerchant.QueryRepairCost (whocret: TCreature; uitem: TUserItem);
var
   i, price, cost: integer;
begin
   price := GetSellPrice (TUserHuman(whocret), GetGoodsPrice (uitem)); //�ǸŰ������� ȯ����.
   if price > 0 then begin
      if (whocret.LatestNpcCmd = '@s_repair') or (whocret.LatestNpcCmd = '@t_repair') then begin //Ư������
         price := price * 3;
         //if specialrepair > 0 then
         //else whocret.LatestNpcCmd := '@fail_s_repair';     //Ư������ ��� ����..
      end;

      if uitem.DuraMax > 0 then
         cost := Round(((price div 3) / uitem.DuraMax) * _MAX(0, uitem.DuraMax-uitem.Dura))  //DURAMAX����
      else
         cost := 0;//price;

      whocret.SendMsg (self, RM_SENDREPAIRCOST, 0, cost, 0, 0, '');
   end else
      whocret.SendMsg (self, RM_SENDREPAIRCOST, 0, -1, 0, 0, '');  //����..
end;

function  TMerchant.UserRepairItem (whocret: TCreature; puitem: PTUserItem): Boolean;
var
   i, price, cost: integer;
   pstd: PTStdItem;
   repair_type : integer;
   str: string;
begin
   Result := FALSE;
   repair_type := 0;
   if whocret.LatestNpcCmd = '@fail_s_repair' then begin
      //Ư������ ����.
      {$IFDEF KOREA}
         str := '�Բ������Ǹ������������޲��Ĳ��ϡ���\ ' +
                        ' \ \<����/@main> ';
      {$ELSE}
         str := 'Sorry, but we have no material for special repairs at the moment..\ ' +
                        ' \ \<����/@main> ';
      {$ENDIF}
      str := ReplaceChar (str, '\', char($a));
      NpcSay (whocret, str);
      whocret.SendMsg (self, RM_USERREPAIRITEM_FAIL, 0, 0, 0, 0, '');
      exit;
   end;

   pstd := UserEngine.GetStdItem (puitem.Index);
   if pstd = nil then exit;

   price := GetSellPrice (TUserHuman(whocret), GetGoodsPrice (puitem^));
   if CanSpecialRepair and (whocret.LatestNpcCmd = '@s_repair') then begin //Ư������
      price := price * 3;
      if (pstd.StdMode <> 5) and (pstd.StdMode <> 6) then begin
         {$IFDEF KOREA}// MainOutMessage('��������(X): ' + whocret.UserName + ' - ' + pstd.Name);
         {$ELSE}      //  MainOutMessage('Special Repair(X): ' + whocret.UserName + ' - ' + pstd.Name);
         {$ENDIF}
         whocret.SendMsg (self, RM_USERREPAIRITEM_FAIL, 0, 0, 0, 0, '');
         exit; // gadget:���Ⱑ �ƴϸ� Ư������ ����.
      end else begin
         {$IFDEF KOREA} // MainOutMessage('��������: ' + whocret.UserName + '(' + whocret.MapName + ':' + IntToStr(whocret.CX) + ',' + IntToStr(whocret.CY) + ')' + ' - ' + pstd.Name);
         {$ELSE}
         {$ENDIF}
      end;
   end;

   if CanTotalRepair and (whocret.LatestNpcCmd = '@t_repair') then begin //�������
      price := price * 3;
      // ������� �̺�Ʈ 2003-06-26
      case pstd.StdMode of
      5,6,10,11,15,19,20,21,22,23,24,25,26,52,54:
         begin
            {$IFDEF KOREA} // MainOutMessage('����ά�޻: ' + whocret.UserName + '(' + whocret.MapName + ':' + IntToStr(whocret.CX) + ',' + IntToStr(whocret.CY) + ')' + ' - ' + pstd.Name)
            {$ELSE}
            {$ENDIF}
         end;
      else
         {$IFDEF KOREA} // MainOutMessage('����ά�޻(X): ' + whocret.UserName + ' - ' + pstd.Name);
         {$ELSE}        MainOutMessage('Perfect Repair(X): ' + whocret.UserName + ' - ' + pstd.Name);
         {$ENDIF}
         whocret.SendMsg (self, RM_USERREPAIRITEM_FAIL, 0, 0, 0, 0, '');
         exit; // pds:�̺�Ʈ �������
      end;

   end;

   // ����ũ������ �ʵ尡 3�̸� �����Ұ�.
   // or -> and (sonmg's bug 2003/12/03)
   if ((price > 0) and (pstd.StdMode <> 43)) and {(pstd.UniqueItem <> 3)} ((pstd.UniqueItem and $02) = 0) then begin  //������� �ʴ� ���� ���� �ȵ�
      if puitem.DuraMax > 0 then
         cost := Round(((price div 3) / puitem.DuraMax) * _MAX(0, puitem.DuraMax-puitem.Dura))  //DURAMAX����
      else
         cost := 0;//price;

      if ( cost > 0 ) and whocret.DecGold (cost) then begin

         //��ϼ����� ������ ���
         if BoCastleManage then  //5%�� ������ ������.
            UserCastle.PayTax (cost);

         if (CanSpecialRepair and (whocret.LatestNpcCmd = '@s_repair'))
            or (CanTotalRepair and (whocret.LatestNpcCmd = '@t_repair')) then begin //Ư������
            //Dec (specialrepair);
            //Ư�������� ������ �������� ����
            //puitem.DuraMax := puitem.DuraMax - _MAX(0, puitem.DuraMax-puitem.Dura) div 100;  //DURAMAX����
            puitem.Dura := puitem.DuraMax;

            whocret.SendMsg (self, RM_USERREPAIRITEM_OK, 0, whocret.Gold, puitem.Dura, puitem.DuraMax, '');

            {$IFDEF KOREA} str := '������ȥ�Ѿ��޺��ˡ���\ ' + '��ú�ʹ������\ \<����/@main> ';
            {$ELSE}        str := 'It seems to be repaired perfectly ...\use it well .\ \<back/@main>';
            {$ENDIF}
//            str := ReplaceChar (str, '\', char($a));
//            NpcSay (whocret, str);
            NpcSayTitle (whocret, '@succeed_s_repair');
            repair_type := 2;
         end else begin
            //�Ϲ� ����, �������� ���� ������
            puitem.DuraMax := puitem.DuraMax - _MAX(0, puitem.DuraMax-puitem.Dura) div 30;   //DURAMAX����
            puitem.Dura := puitem.DuraMax;

            whocret.SendMsg (self, RM_USERREPAIRITEM_OK, 0, whocret.Gold, puitem.Dura, puitem.DuraMax, '');
            NpcSayTitle (whocret, '~@repair');
            repair_type := 1;
         end;
         Result := TRUE;

         //���� �α� ����
         AddUserLog ('36'#9 + //����_ +
                 whocret.MapName + ''#9 +
                 IntToStr(cost) + ''#9 +
                 IntToStr(whocret.Gold) + ''#9 +
                 whocret.UserName + ''#9 +
                 intToStr(puitem.DuraMax) + ''#9 +
                 IntToStr(puitem.MakeIndex) + ''#9 +
                 intToStr(Repair_type)+#9 +
                 '0');


      end else //���� ����
         whocret.SendMsg (self, RM_USERREPAIRITEM_FAIL, 0, 0, 0, 0, '');
   end else
      whocret.SendMsg (self, RM_USERREPAIRITEM_FAIL, 0, 0, 0, 0, '');
end;

procedure TMerchant.UserBuyItem (whocret: TUserHuman; itmname: string; serverindex, BuyCount: integer);
var
   i, k, sellprice, rcode: integer;
   list: TList;
   pstd: PTStdItem;
   pu: PTUserItem;
   done: Boolean;
   CheckWeight : integer;
   iname : String;
   InviteResult : Boolean;
begin
   done := FALSE;
   InviteResult := TRUE;
   rcode := 1;  //��ǰ�� �� �ȷȽ��ϴ�.
   for i:=0 to GoodsList.Count-1 do begin
      if done then break;
      if NoSeal then break;  //������ ���Ĵ� ����
      list := GoodsList[i];
      pu := PTUserItem (list[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         // ī��Ʈ������
         if pstd.OverlapItem = 1 then
            CheckWeight := pstd.Weight + pstd.Weight * (BuyCount div 10)
         else if pstd.OverlapItem >= 2 then
            CheckWeight := pstd.Weight * BuyCount
         else
            CheckWeight := pstd.Weight;

         if whocret.IsAddWeightAvailable (CheckWeight) then begin
            if pstd.Name = itmname then begin
               for k:=0 to list.Count-1 do begin     //����ڰ� ������ �簨
                  pu := PTUserItem (list[k]);
                  if (pstd.StdMode <= 4) or (pstd.StdMode = 42) or (pstd.StdMode = 31) or (pu.MakeIndex = serverindex)  or (pstd.OverlapItem >= 1) then begin
                     //���� ����� ������ �־����.
                     //if pstd.StdMode <= 4 then sellprice := GetPrice (pu.Index) //��ǥ����
                     sellprice := GetSellPrice (whocret, GetGoodsPrice (pu^)) * BuyCount; //���� ����
                     if (whocret.Gold >= sellprice) and (sellprice > 0) then begin
                        if pstd.OverlapItem >= 1 then begin
                           pu.Dura := _MIN(1000, BuyCount);
                        end;

                        // 2003/03/04 ���� �� Ÿ�� ���� 1�� -> 1�ð�<- �� ����ũ�� �ڵ��Ǿ� �ִ� �׽�Ʈ ���� �ڵ�
{
                        // 2003/03/04 �๰, ������, ȶ��, �๭��, ���� ������ ���� ����� �����ش�
                        if(pstd.StdMode = 0) or //(pstd.StdMode = 25) or //������ ����
                         ((pstd.StdMode = 3) and ((pstd.Shape = 1) or (pstd.Shape = 2) or (pstd.Shape = 3) or (pstd.Shape = 5) or (pstd.Shape = 9))) or
                          ((pstd.StdMode = 30) and (pstd.Shape = 0)) or (pstd.StdMode = 31) then begin
                           iname := pstd.Name;
                           new(pu);
                           if UserEngine.CopyToUserItemFromName(iname, pu^) then begin
                              if whocret.AddItem(pu) then begin
//                                 whocret.Gold := whocret.Gold - sellprice;
                                 whocret.DecGold( sellprice );
                                 whocret.SendAddItem(pu^);
                                 //��ϼ����� ������ ���
                                 if BoCastleManage then  //5%�� ������ ������.
                                    UserCastle.PayTax (sellprice);
                                 //�α׳���
                                 AddUserLog ('9'#9 + //����_
                                             whocret.MapName + ''#9 +
                                             IntToStr(whocret.CX) + ''#9 +
                                             IntToStr(whocret.CY) + ''#9 +
                                             whocret.UserName + ''#9 +
                                             UserEngine.GetStdItemName (pu.Index) + ''#9 +
                                             IntToStr(pu.MakeIndex) + ''#9 +
                                             '1'#9 +
                                             UserName);
                                 rcode := 0;
                              end else begin
                                 Dispose(pu);
                                 rcode := 2;
                              end;
                           end else begin
                              Dispose(pu);
                              rcode := 2;
                           end;
                        end else begin
}

                           // ī��Ʈ ������
                           if pstd.OverlapItem >= 1 then begin
                              if whocret.UserCounterItemAdd(pstd.StdMode, pstd.Looks, BuyCount, pstd.Name, FALSE) then begin
//                                 whocret.Gold := whocret.Gold - sellprice;
                                 whocret.DecGold( sellprice );

//                                 Dispose(list[k]);    //���ƺ���...

                                 list.Delete(k);
                                 if list.Count = 0 then begin
                                    list.Free;
                                    GoodsList.Delete(i);
                                 end;

                                 whocret.WeightChanged;

                                 rcode := 0;
                                 done := TRUE;
                                 break;
                              end;
                           end;

                           InviteResult := TRUE;
                           //�ʴ��� ����.
                           if (pstd.StdMode = 8) and (pstd.Shape = SHAPE_OF_INVITATION) then begin
                              InviteResult := whocret.GuildAgitInvitationItemSet(pu);
                              if not InviteResult then begin
                                 {$IFDEF KOREA} whocret.SysMsg('��ֻ������Ĺ�������յ�����', 0);
                                 {$ELSE}        whocret.SysMsg('You can get an Invitation only in your guild territory.', 0);
                                 {$ENDIF}
                              end;
                           end;

                           if InviteResult then begin
                              if whocret.AddItem (pu) then begin
//                                 whocret.Gold := whocret.Gold - sellprice;
                                 whocret.DecGold( sellprice );

                                 //��ϼ����� ������ ���
                                 if BoCastleManage then  //5%�� ������ ������.
                                    UserCastle.PayTax (sellprice);

                                 whocret.SendAddItem (pu^);  //��� ����

                                 // �߿䵵�� �������� �������� �α׸� ������ �ʴ´�.
                                 if not IsCheapStuff (pstd.StdMode) then begin
                                    AddUserLog ('9'#9 + //����_
                                                whocret.MapName + ''#9 +
                                                IntToStr(whocret.CX) + ''#9 +
                                                IntToStr(whocret.CY) + ''#9 +
                                                whocret.UserName + ''#9 +
                                                UserEngine.GetStdItemName (pu.Index) + ''#9 +
                                                IntToStr(pu.MakeIndex) + ''#9 +
                                                '1'#9 +
                                                UserName);
                                 end;

                                 list.Delete (k);
                                 if list.Count = 0 then begin
                                    list.Free;
                                    GoodsList.Delete (i);
                                 end;
                                 rcode := 0;
                              end else
                                 rcode := 2;
                           end else begin
                              //�ʴ����� �� �� ������ ��������.
                              exit;
                           end;
                        // 2003/03/04 �๰, ������, ȶ��, �๭��, ���� ������ ���� ����� �����ش�
                        // end;
                     end else
                        rcode := 3; //���� ������.
                     done := TRUE;
                     break;
                  end;
               end;
            end;
         end else begin
            rcode := 2;  //�� �̻� �� �� ����.
         end;
      end;
   end;
   if rcode = 0 then begin
      whocret.SendMsg (self, RM_BUYITEM_SUCCESS, 0, whocret.Gold, serverindex{�ȸ� ������}, 0, '');
   end else begin
      whocret.SendMsg (self, RM_BUYITEM_FAIL, 0, rcode, 0, 0, '');
   end;
end;

procedure TMerchant.UserWantDetailItems (whocret: TCreature; itmname: string; menuindex: integer);
var
   i, k, count, grade: integer;
   rr: Real;
   data: string;
   list: TList;
   pstd: PTStdItem;
   pu: PTUserItem;
   cg: TClientGoods;
   citem: TClientItem;
begin
   count := 0;
   for i:=0 to GoodsList.Count-1 do begin
      list := GoodsList[i];
      pu := PTUserItem (list[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         if pstd.Name = itmname then begin
            if menuindex > list.Count-1 then menuindex := _MAX(0, list.Count-10);
            for k:=menuindex to list.Count-1 do begin
               pu := PTUserItem (list[k]);
               citem.S := pstd^;

               //�����ǼӼ� ���� �ȵ� �͵� �����
               if pstd.StdMode in [15,19,20,21,22,23,24,26,52,53,54] then begin
                  if pu.Desc[8] = 0 then begin //�Ӽ��� ������(sonmg 2005/04/07 ����)
                     citem.S.ItemDesc := citem.S.ItemDesc and (not IDC_UNIDENTIFIED);//$01;
                  end else begin
                     citem.S.ItemDesc := citem.S.ItemDesc or IDC_UNIDENTIFIED;//$01;
                  end;
               end;

               citem.UpgradeOpt := 0;
               citem.Dura := pu.Dura;
               citem.DuraMax := GetSellPrice (TUserHuman(whocret), GetGoodsPrice (pu^));  //���� �ڼ��� ����
               citem.MakeIndex := pu.MakeIndex;
               data := data + EncodeBuffer (@citem, sizeof(TClientItem)) + '/';

               Inc (count);
               if count >= 10 then break;
            end;
            break;
         end;
      end;
   end;
   whocret.SendMsg (self, RM_SENDDETAILGOODSLIST, 0, integer(self), count, menuindex, data);
end;

//////////////////////////////////////////
// ���� ���� ���
//////////////////////////////////////////
const
   MAX_SOURCECNT    = 6;
   //---------------//
   // ���� ���
   COND_FAILURE     = 0;
   COND_GEMFAIL     = 1;
   COND_SUCCESS     = 2;
   COND_MINERALFAIL = 3;
   COND_NOMONEY     = 4;
   COND_BAGFULL     = 5;
   //---------------//
   // ��ȣ�� ���
   GSG_ERROR       = 0;
   GSG_SMALL       = 1; //(��)
   GSG_MEDIUM      = 2; //(��)
   GSG_LARGE       = 3; //(��)
   GSG_GREATLARGE  = 4; //(Ư)
   GSG_SUPERIOR    = 5; //���� or �ż�
   //---------------//
//////////////////////////////////////////

procedure TMerchant.UserMakeNewItem (whocret: TUserHuman; itmname: string);
{
const
   COND_FAILURE = 0;
//   COND_GEMFAIL = 1;
   COND_SUCCESS = 2;
//   COND_MINERALFAIL = 3;
   COND_NOMONEY = 4;
   //---------------//
}
   function CheckCondition (hum: TUserHuman; itemname: string; var iPrice: Integer): Integer;
   var
      list: TStringList;
      k, i, sourcecount: integer;
      sourcename: string;
      condition: Integer;
      dellist: TStringList;
      pu: PTUserItem;
      ps: PTStdItem;
   begin
      condition := COND_FAILURE;
      list := GetMakeItemCondition (itemname, iPrice);

      if (hum.Gold < iPrice) then begin
         Result := COND_NOMONEY;
         exit;
      end;

      if list <> nil then begin
         condition := COND_SUCCESS;
         for k:=0 to list.Count-1 do begin  //����µ� �ʿ��� ���
            sourcename := list[k];
            sourcecount := integer (list.Objects[k]);
            for i:=0 to hum.ItemList.Count-1 do begin //�� ���濡 �������� �ִ��� �˻�
               pu := PTUserItem (hum.ItemList[i]);
               if sourcename = UserEngine.GetStdItemName(pu.Index) then begin
                  ps := UserEngine.GetStdItem (pu.Index);
                  if ps <> nil then
                  begin
                     // ī��Ʈ ������.
                     if ps.OverlapItem >= 1 then
                        sourcecount := sourcecount - _MIN(pu.Dura, sourcecount)
                     else
                        dec (sourcecount);  //���� �˻�..
                  end;
               end;
            end;
            if sourcecount > 0 then begin
               condition := COND_FAILURE;  //���� �̴��̸� ���� �ȸ�������.
               break;
            end;
         end;
         if condition = COND_SUCCESS then begin //������ ������ ���� �������.
            dellist := nil;
            for k:=0 to list.Count-1 do begin
               sourcename := list[k];
               sourcecount := integer (list.Objects[k]);
               for i:=hum.ItemList.Count-1 downto 0 do begin
                  pu := PTUserItem (hum.ItemList[i]);
                  if sourcecount > 0 then begin
                     if sourcename = UserEngine.GetStdItemName(pu.Index) then begin
                        ps := UserEngine.GetStdItem (pu.Index);
                        if ps <> nil then
                        begin
                           //ī��Ʈ ������.
                           if ps.OverlapItem >= 1 then begin
                              if pu.Dura < Integer(list.Objects[k]) then
                                 pu.Dura := 0
                              else
                                 pu.Dura := pu.Dura - Integer(list.Objects[k]);

                              if pu.Dura > 0 then begin
                                 hum.SendMsg(self, RM_COUNTERITEMCHANGE, 0, pu.MakeIndex, pu.Dura, 0, ps.Name);
                                 continue;
                              end;
                           end;
                           //�Ϲ� ������ �Ǵ� ī��Ʈ ������ ����
                           if dellist = nil then dellist := TStringList.Create;
                           dellist.AddObject(sourcename, TObject(PTUserItem (hum.ItemList[i]).MakeIndex));
                           Dispose (PTUserItem(hum.ItemList[i]));
                           hum.ItemList.Delete (i);
                           dec (sourcecount);
                        end;
                     end;
                  end else
                     break;
               end;
            end;
            if dellist <> nil then //dellist��  RM_DELITEMS���� Free��.
               hum.SendMsg (self, RM_DELITEMS, 0, integer(dellist), 0, 0, '');
         end;
      end;
      Result := condition;
   end;
const
   MAKEPRICE = 100;
var
   i, rcode: integer;
   done: Boolean;
   list: TList;
   pu, newpu: PTUserItem;
   pstd: PTStdItem;
   iMakePrice: Integer;
   iCheckResult: Integer;
begin
   iMakePrice := MAKEPRICE;

   done := FALSE;
   rcode := 1;
   for i:=0 to GoodsList.Count-1 do begin
      if done then break;
      list := GoodsList[i];
      pu := PTUserItem (list[0]);
      pstd := UserEngine.GetStdItem (pu.Index);
      if pstd <> nil then begin
         if pstd.Name = itmname then begin
            //������ ����� ��뵵 �Բ� üũ�Ѵ�.
            iCheckResult := CheckCondition (whocret, itmname, iMakePrice);
            if iCheckResult <> COND_NOMONEY then begin
               if iCheckResult = COND_SUCCESS then begin
                  new (newpu);
                  UserEngine.CopyToUserItemFromName (itmname, newpu^);
                  if whocret.AddItem (newpu) then begin
//                     whocret.Gold := whocret.Gold - iMakePrice;
                     whocret.DecGold( iMakePrice );
                     whocret.SendAddItem (newpu^);  //����� ����...
                     //�α׳���
                     AddUserLog ('2'#9 + //����_
                                 whocret.MapName + ''#9 +
                                 IntToStr(whocret.CX) + ''#9 +
                                 IntToStr(whocret.CY) + ''#9 +
                                 whocret.UserName + ''#9 +
                                 UserEngine.GetStdItemName (newpu.Index) + ''#9 +
                                 IntToStr(newpu.MakeIndex) + ''#9 +
                                 '1'#9 +
                                 UserName);
                     rcode := 0;
                  end else begin
                     Dispose (newpu);
                     rcode := 2;
                  end;
               end else
                  rcode := 4;
            end else
               rcode := 3;
         end;
      end;
   end;
   if rcode = 0 then begin
      whocret.SendMsg (self, RM_MAKEDRUG_SUCCESS, 0, whocret.Gold, 0, 0, '');
   end else begin
      whocret.SendMsg (self, RM_MAKEDRUG_FAIL, 0, rcode, 0, 0, '');
   end;
end;

// ������ ���� ���ν���.
procedure TMerchant.UserManufactureItem (whocret: TUserHuman; itmname: string);
const
   MAKEPRICE = 100;
var
   i, j, rcode: integer;
   done: Boolean;
   list: TList;
   pu, newpu: PTUserItem;
   pstd: PTStdItem;
   sMakeItemName: string;
   sItemMakeIndex: array [1..MAX_SOURCECNT] of string;
   sItemName: array [1..MAX_SOURCECNT] of string;
   sItemCount: array [1..MAX_SOURCECNT] of string;
   iCheckResult: Integer;
   iMakePrice, iMakeCount: integer;
   strSourceLog: string;
begin
   iMakePrice := MAKEPRICE;
   strSourceLog := '';

   try
      // RightStr := GetValidStr3 (OrgStr, LeftStr of Separator, Separator);
      itmname := GetValidStr3 (itmname, sMakeItemName, ['/']);
      for i:= 1 to MAX_SOURCECNT do begin
         itmname := GetValidStr3 (itmname, sItemMakeIndex[i], [':']);
         itmname := GetValidStr3 (itmname, sItemName[i], [':']);
         itmname := GetValidStr3 (itmname, sItemCount[i], ['/']);
      end;
      ///////////////////////////////////////////
{$IFDEF DEBUG}   //sonmg
      whocret.SysMsg (sMakeItemName, 0);
      for i := 1 to MAX_SOURCECNT do begin
         whocret.SysMsg (sItemMakeIndex[i] + sItemName[i] + sItemCount[i], 0);
         //���� ��� �α�
         strSourceLog := strSourceLog + sItemName[i];
         if i <> MAX_SOURCECNT then
            strSourceLog := strSourceLog + ','; //������ ��ᰡ �ƴϸ� ','�� ���δ�.
      end;
{$ENDIF}
      ///////////////////////////////////////////

      done := FALSE;
      rcode := 1;
      for i:=0 to GoodsList.Count-1 do begin
         if done then break;
         list := GoodsList[i];
         pu := PTUserItem (list[0]);
         pstd := UserEngine.GetStdItem (pu.Index);
         if pstd <> nil then begin
            if pstd.Name = sMakeItemName then begin
               //������ ����� ��뵵 �Բ� üũ�Ѵ�.
               iCheckResult := CheckMakeItemCondition (whocret, sMakeItemName, sItemMakeIndex, sItemName, sItemCount, iMakePrice, iMakeCount);
               if iCheckResult <> COND_NOMONEY then begin
                  if iCheckResult = COND_SUCCESS then begin
                     for j:=0 to iMakeCount-1 do begin
                        new (newpu);
                        UserEngine.CopyToUserItemFromName (sMakeItemName, newpu^);
                        if whocret.AddItem (newpu) then begin
//                           whocret.Gold := whocret.Gold - iMakePrice;
                           whocret.DecGold( iMakePrice );
                           whocret.SendAddItem (newpu^);  //����� ����...

                           // ���� ���� �α�
{
                           MainOutMessage( '[Manufacture ����] ' + whocret.UserName + ' ' + UserEngine.GetStdItemName (newpu.Index) + '(' + IntToStr(newpu.MakeIndex) + ') '
                              + '=> ������ ���:' + sItemName[1] + ', ' + sItemName[2]
                              + ', ' + sItemName[3] + ', ' + sItemName[4]
                              + ', ' + sItemName[5] + ', ' + sItemName[6] );
}

                           //�α׳���
                           AddUserLog ('2'#9 + //����_
                                       whocret.MapName + ''#9 +
                                       IntToStr(whocret.CX) + ''#9 +
                                       IntToStr(whocret.CY) + ''#9 +
                                       whocret.UserName + ''#9 +
                                       UserEngine.GetStdItemName (newpu.Index) + ''#9 +
                                       IntToStr(newpu.MakeIndex) + ''#9 +
                                       '1'#9 +
                                       UserName);
                           rcode := 0;
                        end else begin
                           Dispose (newpu);
                           rcode := 2;
                        end;
                     end;
                  end else if iCheckResult = COND_GEMFAIL then begin
                     // ���� ���� ���нÿ��� ���� ���� ������.
//                     whocret.Gold := whocret.Gold - iMakePrice;
                     whocret.DecGold( iMakePrice );
                     whocret.GoldChanged;

                     //�α׳���
                     AddUserLog ('2'#9 + //����_����
                                 whocret.MapName + ''#9 +
                                 IntToStr(whocret.CX) + ''#9 +
                                 IntToStr(whocret.CY) + ''#9 +
                                 whocret.UserName + ''#9 +
                                 'FAIL'#9 +
                                 '0'#9 +
                                 '1'#9 +
                                 UserName);
                     rcode := 5;
                  end else if iCheckResult = COND_MINERALFAIL then begin
                     rcode := 6;
                  end else if iCheckResult = COND_BAGFULL then begin
                     rcode := 7;
                  end else
                     rcode := 4;
               end else
                  rcode := 3;
            end;
         end;
      end;

      if rcode = 0 then begin
         whocret.SendMsg (self, RM_MAKEDRUG_SUCCESS, 0, whocret.Gold, 0, 0, '');
      end else begin
         whocret.SendMsg (self, RM_MAKEDRUG_FAIL, 0, rcode, 0, 0, '');
      end;
   except
      MainOutMessage ('[Exception] TMerchant.UserManufactureItem');
   end;
end;

////////////////////////////////////////////////////////////
// ��ȣ���� ����� ���� �Լ�.
function TMerchant.GetGradeOfGuardStoneByName ( strGuardStone: string ): Integer;
begin
   Result := GSG_ERROR;

   //Compare String...
   if ENGLISHVERSION or PHILIPPINEVERSION then begin
      if CompareBackLStr(strGuardStone, '(S)', 3) = TRUE then begin
         Result := GSG_SMALL;
      end else if CompareBackLStr(strGuardStone, '(M)', 3) = TRUE then begin
         Result := GSG_MEDIUM;
      end else if CompareBackLStr(strGuardStone, '(L)', 3) = TRUE then begin
         Result := GSG_LARGE;
      end else if (CompareBackLStr(strGuardStone, '(XL)', 4) = TRUE) or
          (CompareBackLStr(strGuardStone, 'XL', 2) = TRUE) then begin
         Result := GSG_GREATLARGE;
      end else if CompareBackLStr(strGuardStone, 'STONE', 5) = TRUE then begin
         Result := GSG_SUPERIOR;
      end else begin
         Result := GSG_ERROR;
      end;
   end else if KOREANVERSION then begin
      if CompareBackLStr(strGuardStone, '(��)', 4) = TRUE then begin
         Result := GSG_SMALL;
      end else if CompareBackLStr(strGuardStone, '(��)', 4) = TRUE then begin
         Result := GSG_MEDIUM;
      end else if CompareBackLStr(strGuardStone, '(��)', 4) = TRUE then begin
         Result := GSG_LARGE;
      end else if CompareBackLStr(strGuardStone, '(Ư)', 4) = TRUE then begin
         Result := GSG_GREATLARGE;
      end else if CompareBackLStr(strGuardStone, '����', 4) = TRUE then begin
         Result := GSG_SUPERIOR;
      end else if CompareBackLStr(strGuardStone, '�ż�', 4) = TRUE then begin
         Result := GSG_SUPERIOR;
      end else begin
         Result := GSG_ERROR;
      end;
   end else begin
      //�⺻��
      if CompareBackLStr(strGuardStone, '(��)', 4) = TRUE then begin
         Result := GSG_SMALL;
      end else if CompareBackLStr(strGuardStone, '(��)', 4) = TRUE then begin
         Result := GSG_MEDIUM;
      end else if CompareBackLStr(strGuardStone, '(��)', 4) = TRUE then begin
         Result := GSG_LARGE;
      end else if CompareBackLStr(strGuardStone, '(Ư)', 4) = TRUE then begin
         Result := GSG_GREATLARGE;
      end else if CompareBackLStr(strGuardStone, '����', 4) = TRUE then begin
         Result := GSG_SUPERIOR;
      end else if CompareBackLStr(strGuardStone, '�ż�', 4) = TRUE then begin
         Result := GSG_SUPERIOR;
      end else begin
         Result := GSG_ERROR;
      end;
   end;
end;

////////////////////////////////////////////////////////////
// ������� �ʿ��� ��ϰ� ���۹��� ����� ���Ͽ�
// ���ǿ� �´��� �ƴ��� üũ�ϰ� �������� �����ϴ� �Լ�.
function TMerchant.CheckMakeItemCondition (hum: TUserHuman; itemname: string; sItemMakeIndex, sItemName, sItemCount: array of string; var iPrice, iMakeCount: Integer): Integer;
var
   list: TStringList;
   k, i, j, icnt: integer;
   sourcecount, counteritmcount, itemp: integer;
   sourcemindex: integer;
   sourcename: string;
   condition: Integer;
   dellist: TStringList;
   pu: PTUserItem;
   ps: PTStdItem;
   iGuardStoneGrade: integer;
   iProbability: Integer;
   fTemporary: Real;
   iRequiredGuardStoneGrade: Integer;
   iSumOutfitAbil, iOutfitGrade: Integer;
   // ���ο� List
   sNewName: array [0..MAX_SOURCECNT-1] of string;
   sNewCount: array [0..MAX_SOURCECNT-1] of string;
   sNewMIndex: array [0..MAX_SOURCECNT-1] of string;
   iListDoubleCount: array [0..MAX_SOURCECNT-1] of Integer;
   checkcount: integer;
   bCheckMIndex: Boolean;
   // ��ũ��Ʈ ���ڿ� ����
   strPendant, strGuardStone, strGuardStone15, strGuardStoneXLHigher : string;
   delitemname : string;
begin
   strPendant := '';
   strGuardStone := '';
   strGuardStone15 := '';
   strGuardStoneXLHigher := '';

   if ENGLISHVERSION or PHILIPPINEVERSION then begin
      strPendant := '<PENDANT>';
      strGuardStone := '<GUARDSTONE>';
      strGuardStone15 := '<GUARDSTONE15>';
      strGuardStoneXLHigher := '<GUARDSTONE(XL)HIGHER>';
   end else if KOREANVERSION then begin
      strPendant := '<����>';
      strGuardStone := '<�ػ�ʯ>';
      strGuardStone15 := '<�ػ�ʯ15>';
      strGuardStoneXLHigher := '<�ػ�ʯ���أ�����>';
   end else begin
      //�⺻��
      strPendant := '<����>';
      strGuardStone := '<�ػ�ʯ>';
      strGuardStone15 := '<�ػ�ʯ15>';
      strGuardStoneXLHigher := '<�ػ�ʯ���أ�����>';
   end;

   iProbability := 0;
   fTemporary := 0;
   condition := COND_FAILURE;
   iRequiredGuardStoneGrade := 0;  //��ȣ�� �߰� Ȯ�� ���
   iOutfitGrade := 0;   //��ű� �߰� Ȯ�� ���
   iSumOutfitAbil := 0;
   iGuardStoneGrade := GSG_ERROR;

   list := GetMakeItemCondition (itemname, iPrice);

   // ����â ������ ���� Ȯ��
   if hum.CanAddItem = FALSE then begin
      Result := COND_BAGFULL;
      {$IFDEF KOREA} hum.SysMsg('��İ�����', 0);
      {$ELSE}        hum.SysMsg('Your bag is full.', 0);
      {$ENDIF}
      exit;
   end;

   if list <> nil then begin
      // ���۹��ڿ� ���ڼ����� ũ�� �ȵ�.
      if list.Count > MAX_SOURCECNT then
         MainOutMessage ('[Caution!] list.Count Overflow in TMerchant.UserManufactureItem');

      condition := COND_SUCCESS;

      // ���� Ÿ�� �˻�(��ȣ���� ������ �˻� sonmg)
      for j:= 0 to list.Count-1 do begin
         if UPPERCASE(list[j]) = strGuardStone then begin
            iRequiredGuardStoneGrade := 1;  // Ÿ�� A
         end else if UPPERCASE(list[j]) = strGuardStoneXLHigher then begin
            iRequiredGuardStoneGrade := 2;  // Ÿ�� B
         end else if UPPERCASE(list[j]) = strGuardStone15 then begin
            iRequiredGuardStoneGrade := 3;  // Ÿ�� C (��ȣ���� �Ϲ�, �������� 15�̻�)
         end;
      end;

      //------ ��� �˻� ------//
      // 1.���۹��ڿ��� ����â�� ��� �ִ���(Name�� MakeIndex) �˻�
      // ������ List���� �ش� ������ �̸��� MakeIndex ������Ʈ(StdMode����)
      for k:=0 to MAX_SOURCECNT-1 do begin  //���۹��ڿ�
         sourcemindex := Str_ToInt(sItemMakeIndex[k], 0);
         sourcename := sItemName[k];
         sourcecount := Str_ToInt(sItemCount[k], 0);

         for i:=0 to hum.ItemList.Count-1 do begin
            pu := PTUserItem (hum.ItemList[i]);
            // ������ �̸� ��
            if sItemName[k] = UserEngine.GetStdItemName(pu.Index) then begin
               ps := UserEngine.GetStdItem (pu.Index);
               if ps <> nil then
               begin
                  // ī��Ʈ ������.
                  if ps.OverlapItem >= 1 then begin
                     if pu.Dura < sourcecount then begin
                        sourcecount := sourcecount - pu.Dura;
                     end else begin
                        itemp := sourcecount;
                        sourcecount := _MAX(0, itemp - pu.Dura);
                     end;

                     if sourcecount <= 0 then begin
                        for j:= 0 to list.Count-1 do begin
                           if list[j] = sourcename then begin
                              sNewMIndex[j] := sItemMakeIndex[k];
                              sNewName[j] := sourcename;
                              sNewCount[j] := sItemCount[k];
                           end;
                        end;

                        break;
                     end;
                  end else begin
                     // MakeIndex ��
                     if sourcemindex = pu.MakeIndex then begin
                        for j:= 0 to list.Count-1 do begin
                           if list[j] = sourcename then begin
                              // ���� �������� �ΰ� �̻� ���� ��� ī��Ʈ ����
                              if sNewName[j] = sourcename then begin
                                 sNewCount[j] := IntToStr( Str_ToInt(sNewCount[j], 0) + 1 );
                              end else begin
                                 sNewCount[j] := sItemCount[k];
                                 sNewMIndex[j] := sItemMakeIndex[k];
                              end;

                              sNewName[j] := sourcename;
                           end;
                        end;

                        // <��ű�> <��ȣ��> <��ȣ��(Ư)�̻�> �������� ������
                        // ���۹��ڿ��� �ִ� �������� list�� ����Ѵ�.
                        if ps.StdMode in [19,20,21, 22,23, 24,26] then begin
                           for j:= 0 to list.Count-1 do begin
                              if UPPERCASE(list[j]) = strPendant then begin
                                 sNewMIndex[j] := sItemMakeIndex[k];
                                 sNewName[j] := sourcename;
                                 sNewCount[j] := sItemCount[k];

                                 // ��ű� �ı�,����,���� ���տ� ���� ��� ����...
                                 iSumOutfitAbil := HIBYTE(ps.DC) + HIBYTE(ps.MC) + HIBYTE(ps.SC);
                                 if ps.StdMode in [22,23] then begin //����
                                    if iSumOutfitAbil <= 3 then
                                       iOutfitGrade := 0   //����
                                    else if iSumOutfitAbil = 4 then
                                       iOutfitGrade := 1   //����
                                    else
                                       iOutfitGrade := 2;   //�ٱ�
                                 end else if ps.StdMode in [24,26] then begin //����
                                    if HIBYTE(ps.DC) > 0 then begin //�ı� ���� ����
                                       if iSumOutfitAbil = 1 then
                                          iOutfitGrade := 0   //����
                                       else if iSumOutfitAbil = 2 then
                                          iOutfitGrade := 1   //����
                                       else
                                          iOutfitGrade := 2;   //�ٱ�
                                    end else begin
                                       if iSumOutfitAbil = 1 then
                                          iOutfitGrade := 0   //����
                                       else if iSumOutfitAbil in [2,3] then
                                          iOutfitGrade := 1   //����
                                       else
                                          iOutfitGrade := 2;   //�ٱ�
                                    end;
                                 end else begin //�����
                                    if iSumOutfitAbil <= 3 then
                                       iOutfitGrade := 0   //����
                                    else if iSumOutfitAbil in [4,5] then
                                       iOutfitGrade := 1   //����
                                    else
                                       iOutfitGrade := 2;   //�ٱ�
                                 end;
                              end;
                           end;
                        end;
                        if ps.StdMode = 53 then begin
                           // ��ȣ�� ����� ����.
                           iGuardStoneGrade := GetGradeOfGuardStoneByName( sourcename );

                           for j := 0 to list.Count-1 do begin
                              if iGuardStoneGrade < GSG_GREATLARGE then begin
                                 if (UPPERCASE(list[j]) = strGuardStone) or (UPPERCASE(list[j]) = strGuardStone15) then begin
                                    sNewMIndex[j] := sItemMakeIndex[k];
                                    sNewName[j] := sourcename;
                                    sNewCount[j] := sItemCount[k];
                                 end;
                              end else if iGuardStoneGrade >= GSG_GREATLARGE then begin
                                 if (UPPERCASE(list[j]) = strGuardStone) or (UPPERCASE(list[j]) = strGuardStone15) or (UPPERCASE(list[j]) = strGuardStoneXLHigher) then begin
                                    sNewMIndex[j] := sItemMakeIndex[k];
                                    sNewName[j] := sourcename;
                                    sNewCount[j] := sItemCount[k];
                                 end;
                              end else begin
                                 // ��ȣ�� �̸��� �̻��ϴٸ� Error : Ȯ���� ������.
                                 MainOutMessage('[Caution!] TMerchant.UserManufactureItem iGuardStoneGrade = GSG_ERROR');
                              end;
                           end;
                        end;

                        //------ ���� ���� �˻� ------//
                        if ps.StdMode = 43 then begin //����
                           if iRequiredGuardStoneGrade = 1 then begin  // Ÿ�� A
                              if pu.Dura < 11500 then begin // ���� 12
                                 condition := COND_MINERALFAIL;
                              end;
                           end else if iRequiredGuardStoneGrade = 2 then begin  // Ÿ�� B
                              if pu.Dura < 14500 then begin // ���� 15
                                 condition := COND_MINERALFAIL;
                              end;
                           end else if iRequiredGuardStoneGrade = 3 then begin  // Ÿ�� C
                              if pu.Dura < 14500 then begin // ���� 15
                                 condition := COND_MINERALFAIL;
                              end;
                           end;
                        end;

                        dec (sourcecount);  //���� ����..
                     end;
                  end;
               end;//if ps <> nil then
            end;
         end;

         if sourcecount > 0 then begin
            condition := COND_FAILURE;  //���� �̴��̸� ���� �ȸ�������.
            break;
         end;
      end;

{$IFDEF DEBUG}
      for k:=0 to list.Count-1 do begin
         hum.SysMsg(sNewMIndex[k] + ' ' + sNewName[k] + ' ' + sNewCount[k], 2);
      end;
{$ENDIF}

      // 2.���ο� List�� list�� ���ǿ� �����ϴ��� �˻�
      // �� ������ ���� �� �ִ��� Ȯ��
      if (condition = COND_SUCCESS) or (condition = COND_MINERALFAIL) then begin
         checkcount := list.Count;
         for k:=0 to list.Count-1 do begin  //���ο� List
            sourcename := sNewName[k];
            sourcecount := Str_ToInt(sNewCount[k], 0);

            if (sourcename = list[k]) and (sourcecount >= Integer(list.Objects[k])) then begin
               iListDoubleCount[k] := sourcecount div Integer(list.Objects[k]);
               Dec(checkcount);
            end else if ( (UPPERCASE(list[k]) = strPendant) or (UPPERCASE(list[k]) = strGuardStone) or (UPPERCASE(list[k]) = strGuardStone15)
            or (UPPERCASE(list[k]) = strGuardStoneXLHigher) ) and (sourcecount >= Integer(list.Objects[k])) then begin
               iListDoubleCount[k] := sourcecount div Integer(list.Objects[k]);
               Dec(checkcount);
            end;
         end;

         if checkcount > 0 then
            condition := COND_FAILURE;  //���� �̴��̸� ���� �ȸ�������.
      end;

      //------ ��� ���� ------//
      // ����â���� ���ο� List�� �ش��ϴ� �������� �����Ѵ�.
      // ���� �� �ִ� ������ŭ �����ϰ� �������� �������� ����...
      if condition = COND_SUCCESS then begin
         //------ ���� �� �ִ� ���� ���(�ּҰ�) -----//
         iMakeCount := iListDoubleCount[0];
         for k:=0 to list.Count-1 do begin
            if iMakeCount > iListDoubleCount[k] then
               iMakeCount := iListDoubleCount[k];
//               hum.SysMsg(IntToStr(iListDoubleCount[k]), 1);
         end;
//            hum.SysMsg('����� ������ ���� : ' + IntToStr(iMakeCount), 2);

         // �ʿ��� ������ �ִ��� Ȯ��
         if (hum.Gold < iPrice * iMakeCount) then begin
            Result := COND_NOMONEY;
            exit;
         end;

         // ����â ������ �ִ��� Ȯ�� (sonmg 2004/02/21)
         if hum.Itemlist.Count + iMakeCount > MAXBAGITEM then begin
            Result := COND_BAGFULL;
            {$IFDEF KOREA} hum.SysMsg('��İ�����', 0);
            {$ELSE}        hum.SysMsg('Your bag is full.', 0);
            {$ENDIF}
            exit;
         end;

         //�ʱ�ȭ
         dellist := nil;

         // �ϴ� ���ο� List �׸� ������ ����
         // ������ ����� ������ ������ŭ Loop.
         // => ī��Ʈ�� list�� ī��Ʈ��ŭ ����
         // ==> ī��Ʈ �������� �ƴѵ� 2�� �̻� �ִ� ���� MakeIndex��
         //     ���۸���Ʈ(sMakeItemIndex)���� �����Ѵ�.
         //
         // �˾Ƶ� �� : ��ȣ���̳� ��ű��� ���Ե� ������ �� �� �̻� �Ѳ�����
         // ������ �ȵǰ� ���߿� �÷��� ���������� ������ �ȴ�.(sonmg 2003/12/19)
         for j:=0 to iMakeCount-1 do begin
            for k:=0 to list.Count-1 do begin  //���ο� List
               sourcemindex := Str_ToInt(sNewMIndex[k], 0);
               sourcename := sNewName[k];
               // ī��Ʈ�� list�� ī��Ʈ��ŭ ����(�ʿ��� ��ŭ�� ����)
               sourcecount := Integer(list.Objects[k]);
               counteritmcount := Integer(list.Objects[k]);

               for i:=hum.ItemList.Count-1 downto 0 do begin
                  pu := PTUserItem (hum.ItemList[i]);
                  if sourcecount > 0 then begin
                     if sourcename = UserEngine.GetStdItemName(pu.Index) then begin
                        ps := UserEngine.GetStdItem (pu.Index);
                        if ps <> nil then
                        begin
                           //ī��Ʈ ������.
                           if ps.OverlapItem >= 1 then begin
                              if pu.Dura < counteritmcount then begin
                                 counteritmcount := counteritmcount - pu.Dura;
                                 pu.Dura := 0;
                              end else begin
                                 itemp := counteritmcount;
                                 counteritmcount := _MAX(0, itemp - pu.Dura);
                                 pu.Dura := pu.Dura - itemp;
                              end;

                              if pu.Dura > 0 then begin
                                 hum.SendMsg(self, RM_COUNTERITEMCHANGE, 0, pu.MakeIndex, pu.Dura, 0, ps.Name);
                                 continue;
                              end;
                           end else begin
                              // MakeIndex ��
                              if pu.MakeIndex <> Str_ToInt(sNewMIndex[k], 0) then begin
                                 bCheckMIndex := FALSE;
                                 for icnt:= 0 to MAX_SOURCECNT-1 do begin
                                    if pu.MakeIndex = Str_ToInt(sItemMakeIndex[icnt], 0) then begin
                                       bCheckMIndex := TRUE;
                                       break;
                                    end;
                                 end;

                                 if bCheckMIndex = FALSE then
                                    continue;
                              end;
                           end;

                           //�Ϲ� ������ �Ǵ� ī��Ʈ ������ ����
                           if dellist = nil then dellist := TStringList.Create;
                           delitemname := UserEngine.GetStdItemName(pu.Index);
                           dellist.AddObject(delitemname, TObject(PTUserItem (hum.ItemList[i]).MakeIndex));

                           //�α׳���
                           AddUserLog ('44'#9 + //������_
                                       hum.MapName + ''#9 +
                                       IntToStr(hum.CX) + ''#9 +
                                       IntToStr(hum.CY) + ''#9 +
                                       hum.UserName + ''#9 +
                                       delitemname + ''#9 +
                                       IntToStr(PTUserItem (hum.ItemList[i]).MakeIndex) + ''#9 +
                                       '1'#9 +
                                       UserName);

                           Dispose (PTUserItem(hum.ItemList[i]));
                           hum.ItemList.Delete (i);
                           dec (sourcecount);
                        end;//if ps <> nil then
                     end;
                  end else
                     break;
               end;
            end;
         end;
         if dellist <> nil then //dellist��  RM_DELITEMS���� Free��.
            hum.SendMsg (self, RM_DELITEMS, 0, integer(dellist), 0, 0, '');

         // ����(1��) ���� ���� Ȯ�� ����...
         if iRequiredGuardStoneGrade > 0 then begin
            fTemporary := (hum.BodyLuck - hum.PlayerKillingPoint) / 250;

            if iRequiredGuardStoneGrade = 1 then
               iProbability := 50
            else if iRequiredGuardStoneGrade = 2 then
               iProbability := 50
            else if iRequiredGuardStoneGrade = 3 then
               iProbability := 50;

            if fTemporary >= 100 then
               iProbability := iProbability + 5
            else if (fTemporary < 100) and (fTemporary >= 50) then
               iProbability := iProbability + 3;

            // ��ȣ���� �߰� Ȯ�� ���� (sonmg 2003/12/19)
            case iGuardStoneGrade of
               GSG_SMALL         : iProbability := iProbability + 5;
               GSG_MEDIUM        : iProbability := iProbability + 10;
               GSG_LARGE         : iProbability := iProbability + 15;
               GSG_GREATLARGE    : iProbability := iProbability + 30;
               GSG_SUPERIOR      : iProbability := iProbability + 50;
            end;
         end;

         // 2�� ���� ���� Ȯ�� ����...
         if (iRequiredGuardStoneGrade = 1) or (iRequiredGuardStoneGrade = 3) then begin
            // ���� Ÿ��A ���� Ȯ�� ����...
            if iOutfitGrade = 0 then begin
               iProbability := iProbability + 10;
            end else if iOutfitGrade = 1 then begin
               iProbability := iProbability + 20;
            end else if iOutfitGrade = 2 then begin
               iProbability := iProbability + 40;
            end;

{$IFDEF DEBUG}
            // test
            hum.SysMsg('BodyLuck:' + FloatToStr(hum.BodyLuck) +
               ' - PKPoint:' + FloatToStr(hum.PlayerKillingPoint) +
               ' = ' + FloatToStr(fTemporary) + ', iProbability:' + IntToStr(iProbability) +
               ', DC/MC/SC SUM :' + IntToStr(iSumOutfitAbil), 0);
{$ENDIF}

            if Random(100) < iProbability then begin
               condition := COND_SUCCESS;
            end else begin
               condition := COND_GEMFAIL;
            end;
         end else if iRequiredGuardStoneGrade = 2 then begin
            // ���� Ÿ��B ���� Ȯ�� ����...
            // 2�� Ȯ�� ����.

{$IFDEF DEBUG}
            // test
            hum.SysMsg('BodyLuck:' + FloatToStr(hum.BodyLuck) +
               ' - PKPoint:' + FloatToStr(hum.PlayerKillingPoint) +
               ' = ' + FloatToStr(fTemporary) + ', iProbability:' + IntToStr(iProbability), 0);
{$ENDIF}

            if Random(100) < iProbability then begin
               condition := COND_SUCCESS;
            end else begin
               condition := COND_GEMFAIL;
            end;
         end;
      end;
   end;

{
   if condition = COND_GEMFAIL then begin
      // ���� ���� ���� �α�
      MainOutMessage( '[Gem Manufacture Failure ������������] ' + hum.UserName + ' ' + itemname + ' '
         + '=> Deleted Items(������ ���):' + sNewName[0] + ', ' + sNewName[1]
         + ', ' + sNewName[2] + ', ' + sNewName[3]
         + ', ' + sNewName[4] + ', ' + sNewName[5] + ' '
         + 'BodyLuck:' + FloatToStr(hum.BodyLuck)
         + ' - PK Point:' + FloatToStr(hum.PlayerKillingPoint)
         + ' / 250 = ' + FloatToStr(fTemporary) + ', Prob.Manufacture Gem(��������Ȯ��):' + IntToStr(iProbability) );
   end;
}

   if condition = COND_SUCCESS then begin
      // ���� ���� �α� -> ���
      MainOutMessage( '[Manufacture Success ��������] ' + hum.UserName + ' ' + itemname + '(' + IntToStr(iMakeCount) + '��)');
{
         + ' ' + '=> Deleted Items(������ ���):' + sNewName[0] + ', ' + sNewName[1]
         + ', ' + sNewName[2] + ', ' + sNewName[3]
         + ', ' + sNewName[4] + ', ' + sNewName[5] + ' '
         + 'BodyLuck:' + FloatToStr(hum.BodyLuck)
         + ' - PK Point:' + FloatToStr(hum.PlayerKillingPoint)
         + ' / 250 = ' + FloatToStr(fTemporary) + ', Prob.Manufacture Gem(��������Ȯ��):' + IntToStr(iProbability) );
}
   end;

   Result := condition;
end;

// ��Ź����
// Mode : 0 = ��ü , 1~13 ������ , 100 = ��Ʈ������ , 200 = �ڰ��ڽ��� �ø���
procedure TMerchant.SendUserMarket( hum : TuserHuman ; ItemType : integer ; UserMode : integer );
begin
    case UserMode of
    USERMARKET_MODE_BUY,    // ��¸��
    USERMARKET_MODE_INQUIRY:// ��ȸ���
        hum.RequireLoadUserMarket( ServerName+'_'+UserName , ItemType , Usermode , '','' );
    USERMARKET_MODE_SELL:   // �ǸŸ��
        hum.SendUserMarketSellReady( self); // NPC �� �Ѱ��ش�.
    end;
end;

procedure TMerchant.RunMsg (msg: TMessageInfo);
begin
   inherited RunMsg (msg);
end;

procedure TMerchant.Run;
var
   flag : integer;
   dwCurrentTick: longword;
   dwDelayTick: longword;
begin
   flag := 0;
   try
      //--------------------------------
      //Merchant ���� �л� �ڵ�(sonmg 2005/02/01)
      dwCurrentTick := GetTickCount;
      dwDelayTick   := CreateIndex * 500;
      if dwCurrentTick < dwDelayTick then
         dwDelayTick := 0;
      //--------------------------------

      if dwCurrentTick - checkrefilltime > 5 * 60 * 1000 + dwDelayTick then begin
         checkrefilltime := dwCurrentTick - dwDelayTick;
         flag := 1;
         RefillGoods;
         flag := 2;
         // TEST_TIME
         if g_TestTime = 10 then mainOutMessage( 'RefillGoods:'+IntToStr(dwCurrentTick - checkrefilltime) );
      end;
      if dwCurrentTick - checkverifytime > 601 {10 * 60} * 1000 then begin
         checkverifytime := dwCurrentTick;
         flag := 3;
         VerifyUpgradeList;
         flag := 4;
         // TEST_TIME
         if g_TestTime = 11 then mainOutMessage( 'VerifyUpgradeList:'+IntToStr(dwCurrentTick - checkverifytime) );

      end;
      //if GetTickCount - specialrepairtime > 10 * 60 * 1000 then begin  //10�п� 30��
      //   specialrepairtime := GetTickCount;
      //   Inc (specialrepair, 100);
      //end;
      if Random(50) = 0 then Turn (Random(8))
      else if Random(80) = 0 then
         SendRefMsg (RM_HIT, Dir, CX, CY, 0, '');

      if BoCastleManage and UserCastle.BoCastleUnderAttack then begin
         flag := 5;
         //�����߿� ��ϼ����� ������ ���� �ݴ´�.
         if not HideMode then begin
            SendRefMsg (RM_DISAPPEAR, 0, 0, 0, 0, '');
            HideMode := TRUE;
         end;
         flag := 6;
      end else begin
         if not BoHiddenNpc then begin
            //����
            if HideMode then begin
               HideMode := FALSE;
               SendRefMsg (RM_HIT, Dir, CX, CY, 0, '');
            end;
         end;
      end;

   except
      MainOutMessage ('[Exception] Merchant.Run (' + IntToStr(flag) + ') ' + MarketName + '-' + MapName);
   end;
   inherited Run;
end;

//����ٹ̱� ������ ��� ������
procedure TMerchant.SendDecoItemListShow (who: TCreature);
var
   i, count: integer;
   data: string;
begin
   data := '';
   count := 0;
   who.SendMsg (self, RM_DECOITEM_LISTSHOW, 0, integer(self), count, 0, data);
end;


{-----------------------------------------------------------------}


constructor TGuildOfficial.Create;
begin
   inherited Create;
   RaceImage := RCC_MERCHANT;  //����
   Appearance := 8;
end;

destructor TGuildOfficial.Destroy;
begin
   inherited Destroy;
end;

procedure TGuildOfficial.UserCall (caller: TCreature);
begin
   NpcSayTitle (caller, '@main');
   //NpcSay (caller, SayString);
end;

function  TGuildOfficial.UserBuildGuildNow (hum: TUserHuman; gname: string): integer;
var
   i: integer;
   pu: PTUserItem;
begin
   Result := 0;
   //���ĸ� ���� �ڰ��� �ִ��� �˻�
   //���Ŀ� ������ ���� ����
   //��100����, ���Ϳ��� ��
   gname := Trim(gname);
   pu := nil;
   if gname = '' then Result := -4;
   if hum.MyGuild = nil then begin
      if hum.Gold >= BUILDGUILDFEE then begin
         pu := hum.FindItemName (__WomaHorn);
         if pu <> nil then begin
            ;//���� ����
         end else Result := -3; //���� �������� ����
      end else Result := -2; //���� ����
   end else Result := -1; //�̹� ���Ŀ� ���ԵǾ� ����.

   //���ĸ� �����.
   if Result = 0 then begin
      if GuildMan.AddGuild (gname, hum.UserName) then begin
         UserEngine.SendInterMsg (ISM_ADDGUILD, ServerIndex, gname + '/' + hum.UserName);
         hum.SendDelItem (pu^); //Ŭ���̾�Ʈ�� ����
         hum.DelItem (pu.MakeIndex, __WomaHorn);
         hum.DecGold (BUILDGUILDFEE);
         hum.GoldChanged;
         //���������� �ٽ� �д´�.
         hum.MyGuild := GuildMan.GetGuildFromMemberName (hum.UserName);
         if hum.MyGuild <> nil then begin  //��忡 ���ԵǾ� �ִ� ���
            hum.GuildRankName := TGuild (hum.MyGuild).MemberLogin (hum, hum.GuildRank);
            //hum.SendMsg (self, RM_CHANGEGUILDNAME, 0, 0, 0, 0, '');
         end;

         //-----------------------
         //��ġ ȹ��(���Ļ���:+1000)
         if ENABLE_FAME_SYSTEM then begin
            hum.IncFamePoint( 1000 );
         end;
         //-----------------------
      end else
         Result := -4;
   end;

   case Result of
      0: hum.SendMsg (self, RM_BUILDGUILD_OK, 0, 0, 0, 0, '');
      else
         hum.SendMsg (self, RM_BUILDGUILD_FAIL, 0, Result, 0, 0, '');
   end;
end;

function  TGuildOfficial.UserDeclareGuildWarNow (hum: TUserHuman; gname: string): integer;
begin
   if GuildMan.GetGuild(gname) <> nil then begin
      if hum.Gold >= GUILDWARFEE then begin
         if hum.GuildDeclareWar (gname) = TRUE then begin
            hum.DecGold (GUILDWARFEE);
            hum.GoldChanged;
         end;
      end else begin
         {$IFDEF KOREA} hum.SysMsg ('���ȱ��', 0);
         {$ELSE}        hum.SysMsg ('Lack of Gold.', 0);
         {$ENDIF}
      end;
   end else begin
      {$IFDEF KOREA} hum.SysMsg (gname + ' �Ҳ����л�', 0);
      {$ELSE}        hum.SysMsg (gname + ' Cannot find Guild.', 0);
      {$ENDIF}
   end;
   Result := 1;
end;

{
function TGuildOfficial.UserGuildMemberRecall (hum: TUserHuman; man: string): Boolean;
var
   recallhum: TUserHuman;
   nx, ny, dx, dy: integer;
begin
   Result := FALSE;

   if hum.IsGuildMaster then begin   //��������
      recallhum := UserEngine.GetUserHuman (man);
      if recallhum <> nil then begin
         if hum.MyGuild = recallhum.MyGuild then begin
            if GetFrontPosition (hum, nx, ny) then begin
               if hum.GetRecallPosition (nx, ny, 3, dx, dy) then begin
                  recallhum.SendRefMsg (RM_SPACEMOVE_HIDE, 0, 0, 0, 0, '');
                  recallhum.SpaceMove (MapName, dx, dy, 0); //�����̵�
                  Result := TRUE;
               end;
            end else
               hum.SysMsg ('��ȯ�� �����߽��ϴ�.', 0);
         end;
      end else
         hum.SysMsg (man + '���� ã�� �� �����ϴ�.', 0);
   end else begin
      hum.BoxMsg('���ָ� ����� �� �ִ� ����Դϴ�.', 0);
   end;
end;
}

function  TGuildOfficial.UserFreeGuild (hum: TUserHuman): integer;
begin
   Result := 1;
end;

procedure TGuildOfficial.UserDonateGold (hum: TUserHuman);
begin
   hum.SendMsg (self, RM_DONATE_FAIL, 0, 0, 0, 0, '');
end;

procedure TGuildOfficial.UserRequestCastleWar (hum: TUserHuman);
var
   pu: PTUserItem;
begin
   if hum.IsGuildMaster and (not UserCastle.IsOurCastle (TGuild(hum.MyGuild))) then begin
      pu := hum.FindItemName (__ZumaPiece);
      if pu <> nil then begin
         if UserCastle.ProposeCastleWar (TGuild(hum.MyGuild)) then begin
            hum.SendDelItem (pu^); //Ŭ���̾�Ʈ�� ����
            hum.DelItem (pu.MakeIndex, __ZumaPiece);

            //�α� ����(�ָ���������)(sonmg 2005/04/08)
            AddUserLog ('10'#9 + //�Ǹ�_ +
                        hum.MapName + ''#9 +
                        IntToStr(hum.CX) + ''#9 +
                        IntToStr(hum.CY) + ''#9 +
                        hum.UserName + ''#9 +
                        __ZumaPiece + ''#9 +
                        '0' + ''#9 +
                        '1'#9 +
                        UserName);

            //-----------------------
            //��ġ ȹ��(������û:+500)
            if ENABLE_FAME_SYSTEM then begin
               hum.IncFamePoint( 500 );
            end;
            //-----------------------

            NpcSayTitle (hum, '~@request_ok');
         end else begin
            //�ߺ� ��û�ưų�, ���� ������ ���� ���
            {$IFDEF KOREA} hum.SysMsg ('���Ѿ��ύ��ͷ����', 0);
            {$ELSE}        hum.SysMsg ('You can not request at the moment.', 0);
            {$ENDIF}
         end;
      end else begin
         {$IFDEF KOREA} hum.SysMsg ('��û������ͷ��', 0);
         {$ELSE}        hum.SysMsg ('You have not a Piece of Zumataurus.', 0);
         {$ENDIF}
      end;
   end else begin
      //���İ� ���ų�, ���� ���ι��İ� ��û�� ���
      {$IFDEF KOREA} hum.SysMsg ('�������ȡ��', 0);
      {$ELSE}        hum.SysMsg ('Your request cancelled.', 0);
      {$ENDIF}
   end;
   hum.SendMsg (self, RM_MENU_OK, 0, 0, 0, 0, '');
end;

procedure TGuildOfficial.UserSelect (whocret: TCreature; selstr: string);
var
   sel, body: string;
begin
   try
      if selstr <> '' then begin
         if selstr[1] = '@' then begin
            body := GetValidStr3 (selstr, sel, [#13]);

            NpcSayTitle (whocret, sel);

            if CompareText(sel, '@@buildguildnow') = 0 then begin
               UserBuildGuildNow (TUserHuman(whocret), body);
            end;
            if CompareText(sel, '@@guildwar') = 0 then begin
               UserDeclareGuildWarNow (TUserHuman(whocret), body);
            end;
            if CompareText(sel, '@@donate') = 0 then begin
               UserDonateGold (TUserHuman(whocret));
            end;
            if CompareText(sel, '@requestcastlewarnow') = 0 then begin
               UserRequestCastleWar (TUserHuman(whocret));
            end;

            if CompareText(sel, '@exit') = 0 then begin
               whocret.SendMsg (self, RM_MERCHANTDLGCLOSE, 0, integer(self), 0, 0, '');
            end;
         end;
      end;
   except
      MainOutMessage ('[Exception] TGuildOfficial.UserSelect... ');
   end;
end;

procedure TGuildOfficial.Run;
begin
   if Random(40) = 0 then Turn (Random(8))
   else if Random(30) = 0 then
      SendRefMsg (RM_HIT, Dir, CX, CY, 0, '');
   inherited Run;
end;


{-------------------------------------------------------}

constructor TTrainer.Create;
begin
   inherited Create;
   strucktime := GetTickCount;
   damagesum := 0;
   struckcount := 0;
end;

procedure TTrainer.RunMsg (msg: TMessageInfo);
var
   str: string;
begin
   case msg.Ident of
      RM_REFMESSAGE:
         begin
            if (Integer(msg.Sender) = RM_STRUCK) and (msg.wParam <> 0) then begin
               damagesum := damagesum + msg.wParam;
               strucktime := GetTickCount;
               Inc (struckcount);
               {$IFDEF KOREA} Say ('�ƻ��� ' + IntToStr(msg.wParam) + ', ƽ�� ' + IntToStr(damagesum div struckcount));
               {$ELSE}        Say ('Destructive power is ' + IntToStr(msg.wParam) + ', Average  is ' + IntToStr(damagesum div struckcount));
               {$ENDIF}
            end;
         end;
(*
      RM_STRUCK:
         begin
            if (msg.Sender = self) and (msg.lParam3 <> 0) then begin
               damagesum := damagesum + msg.wParam;
               strucktime := GetTickCount;
               Inc (struckcount);
               {$IFDEF KOREA} Say ('�ı����� ' + IntToStr(msg.wParam) + ', ����� ' + IntToStr(damagesum div struckcount));
               {$ELSE}        Say ('Destructive power is ' + IntToStr(msg.wParam) + ', Average  is ' + IntToStr(damagesum div struckcount));
               {$ENDIF}
            end;
         end;
*)
      RM_MAGSTRUCK:
         begin
            if {(msg.Sender = self) and} (msg.lParam1 <> 0) then begin
                  damagesum := damagesum + msg.lParam1;
                  strucktime := GetTickCount;
                  Inc (struckcount);
                  {$IFDEF KOREA} Say ('�ƻ���' + IntToStr(msg.lParam1) + ', ƽ��ֵ' + IntToStr(damagesum div struckcount));
                  {$ELSE}        Say ('Destructive power is ' + IntToStr(msg.lParam1) + ', Average  is ' + IntToStr(damagesum div struckcount));
                  {$ENDIF}
            end;
         end;
   end;
end;

procedure TTrainer.Run;
begin
   if struckcount > 0 then begin
      if GetTickCount - strucktime > 3 * 1000 then begin
         {$IFDEF KOREA} Say ('���ƻ���' + IntToStr(damagesum) + 'ƽ���ƻ���' + IntToStr(damagesum div struckcount));
         {$ELSE}        Say ('Total destructive power is ' + IntToStr(damagesum) + ' Average destructive power is ' + IntToStr(damagesum div struckcount));
         {$ENDIF}
         struckcount := 0;
         damagesum := 0;
      end;
   end;
   inherited Run;
end;


//
// TCastleManager, (��ϼ����� �ش��)
// �����鿡�Ը� Ŭ���� �ǰ� �ϰ�, ���ֿ��Ը� �� �Ա�, �����
// �� �� �ְ� �Ѵ�.
//

constructor TCastleManager.Create;
begin
   inherited Create;
end;

procedure TCastleManager.CheckNpcSayCommand (hum: TUserHuman; var source: string; tag: string);
var
   str: string;
begin
   inherited CheckNpcSayCommand (hum, source, tag);
   if tag = '$CASTLEGOLD' then begin
      source := ChangeNpcSayTag (source, '<$CASTLEGOLD>', IntToStr(UserCastle.TotalGold));
   end;
   if tag = '$TODAYINCOME' then begin
      source := ChangeNpcSayTag (source, '<$TODAYINCOME>', IntToStr(UserCastle.TodayIncome));
   end;
   if tag = '$CASTLEDOORSTATE' then begin
      with TCastleDoor(UserCastle.MainDoor.UnitObj) do begin
         {$IFDEF KOREA}
            if Death then str := '�ƻ���'
            else if BoOpenState then str := '��'
            else str := '�ر�';
         {$ELSE}
            if Death then str := 'destroyed'
            else if BoOpenState then str := 'opened'
            else str := 'closed';
         {$ENDIF}
      end;
      source := ChangeNpcSayTag (source, '<$CASTLEDOORSTATE>', str);
   end;
   if tag = '$REPAIRDOORGOLD' then begin
      source := ChangeNpcSayTag (source, '<$REPAIRDOORGOLD>', IntToStr(CASTLEMAINDOORREPAREGOLD));
   end;
   if tag = '$REPAIRWALLGOLD' then begin
      source := ChangeNpcSayTag (source, '<$REPAIRWALLGOLD>', IntToStr(CASTLECOREWALLREPAREGOLD));
   end;
   if tag = '$GUARDFEE' then begin
      source := ChangeNpcSayTag (source, '<$GUARDFEE>', IntToStr(CASTLEGUARDEMPLOYFEE));
   end;
   if tag = '$ARCHERFEE' then begin
      source := ChangeNpcSayTag (source, '<$ARCHERFEE>', IntToStr(CASTLEARCHEREMPLOYFEE));
   end;

   if tag = '$GUARDRULE' then begin

   end;

end;

procedure TCastleManager.RepaireCastlesMainDoor (hum: TUserHuman);
begin
   if UserCastle.TotalGold >= CASTLEMAINDOORREPAREGOLD then begin
      if UserCastle.RepairCastleDoor then begin
         UserCastle.TotalGold := UserCastle.TotalGold - CASTLEMAINDOORREPAREGOLD;
         {$IFDEF KOREA} hum.SysMsg ('���޸�', 1);
         {$ELSE}        hum.SysMsg ('repaired.', 1);
         {$ENDIF}
      end else begin
         {$IFDEF KOREA} hum.SysMsg ('�������޷��޸���', 0);
         {$ELSE}        hum.SysMsg ('You cannot repair it now.', 0);
         {$ENDIF}
      end;
   end else begin
      {$IFDEF KOREA} hum.SysMsg ('Χǽ�ʽ𲻹�', 0);
      {$ELSE}        hum.SysMsg ('Fund of wall is not sufficient.', 0);
      {$ENDIF}
   end;
end;

procedure TCastleManager.RepaireCoreCastleWall (wall: integer; hum: TUserHuman);
var
   n: integer;
begin
   if UserCastle.TotalGold >= CASTLECOREWALLREPAREGOLD then begin
      n := UserCastle.RepairCoreCastleWall (wall);
      if n = 1 then begin
         UserCastle.TotalGold := UserCastle.TotalGold - CASTLECOREWALLREPAREGOLD;
         {$IFDEF KOREA} hum.SysMsg ('���޸�', 1);
         {$ELSE}        hum.SysMsg ('repaired.', 1);
         {$ENDIF}
      end else begin
         {$IFDEF KOREA} hum.SysMsg ('�������޷��޸���', 0);
         {$ELSE}        hum.SysMsg ('You cannot repair it now.', 0);
         {$ENDIF}
      end;
   end else begin
      {$IFDEF KOREA} hum.SysMsg ('Χǽ�ʽ𲻹�', 0);
      {$ELSE}        hum.SysMsg ('Fund of wall is not sufficient.', 0);
      {$ENDIF}
   end;
end;

procedure TCastleManager.HireCastleGuard (numstr: string; hum: TUserHuman);
var
   gnum, mrace: integer;
begin
   if UserCastle.TotalGold >= CASTLEGUARDEMPLOYFEE then begin
      gnum := Str_ToInt(numstr, 0) - 1;
      if gnum in [0..MAXGUARD-1] then begin
         if UserCastle.Guards[gnum].UnitObj = nil then begin
            if not UserCastle.BoCastleUnderAttack then begin
               with UserCastle.Guards[gnum] do begin
                  UnitObj := UserEngine.AddCreatureSysop (
                                             UserCastle.CastleMapName,
                                             X,
                                             Y,
                                             UnitName);
                  if UnitObj <> nil then begin
                     UserCastle.TotalGold := UserCastle.TotalGold - CASTLEGUARDEMPLOYFEE;
                     //TGuardUnit(UnitObj).OriginX := X;
                     //TGuardUnit(UnitObj).OriginY := Y;
                     //TGuardUnit(UnitObj).OriginDir := 3;
                     {$IFDEF KOREA} hum.SysMsg ('������ʿ', 1);
                     {$ELSE}        hum.SysMsg ('hired guard.', 1);
                     {$ENDIF}
                  end;
               end;
            end else begin
               {$IFDEF KOREA} hum.SysMsg ('�����ڲ��ܹ�����', 0);
               {$ELSE}        hum.SysMsg ('You cannot hire it right now.', 0);
               {$ENDIF}
            end;
         end else begin
            if not UserCastle.Guards[gnum].UnitObj.Death then begin
               {$IFDEF KOREA} hum.SysMsg ('�����Ѿ��������Ǹ��ط�', 0);
               {$ELSE}        hum.SysMsg ('Guard already exists in that place.', 0);
               {$ENDIF}
            end else begin
               {$IFDEF KOREA} hum.SysMsg ('�����ڲ��ܹ�����', 0);
               {$ELSE}        hum.SysMsg ('You cannot hire it right now.', 0);
               {$ENDIF}
            end;
         end;
      end else begin
         {$IFDEF KOREA} hum.SysMsg ('���������', 0);
         {$ELSE}        hum.SysMsg ('Wrong command.', 0);
         {$ENDIF}
      end;
   end else begin
      {$IFDEF KOREA} hum.SysMsg ('�����ʽ𲻹�', 0);
      {$ELSE}        hum.SysMsg ('Fund of wall is not sufficient.', 0);
      {$ENDIF}
   end;
end;

procedure TCastleManager.HireCastleArcher (numstr: string; hum: TUserHuman);
var
   gnum, mrace: integer;
begin
   if UserCastle.TotalGold >= CASTLEARCHEREMPLOYFEE then begin
      gnum := Str_ToInt(numstr, 0) - 1;
      if gnum in [0..MAXARCHER-1] then begin
         if UserCastle.Archers[gnum].UnitObj = nil then begin
            if not UserCastle.BoCastleUnderAttack then begin
               with UserCastle.Archers[gnum] do begin
                  UnitObj := UserEngine.AddCreatureSysop (
                                             UserCastle.CastleMapName,
                                             X,
                                             Y,
                                             UnitName);
                  if UnitObj <> nil then begin
                     UserCastle.TotalGold := UserCastle.TotalGold - CASTLEARCHEREMPLOYFEE;
                     TGuardUnit(UnitObj).Castle := UserCastle;
                     TGuardUnit(UnitObj).OriginX := X;
                     TGuardUnit(UnitObj).OriginY := Y;
                     TGuardUnit(UnitObj).OriginDir := 3;
                     {$IFDEF KOREA} hum.SysMsg ('���Ӷ�˹�����', 1);
                     {$ELSE}        hum.SysMsg ('You hired archer.', 1);
                     {$ENDIF}
                  end;
               end;
            end else begin
               {$IFDEF KOREA} hum.SysMsg ('�����ڲ��ܹ�����', 0);
               {$ELSE}        hum.SysMsg ('You cannot hire it right now.', 0);
               {$ENDIF}
            end;
         end else begin
            if not UserCastle.Archers[gnum].UnitObj.Death then begin
               {$IFDEF KOREA} hum.SysMsg ('�����Ѿ��������Ǹ��ط�', 0);
               {$ELSE}        hum.SysMsg ('Guard already exists in that place.', 0);
               {$ENDIF}
            end else begin
               {$IFDEF KOREA} hum.SysMsg ('�����ڲ��ܹ�Ӷ��', 0);
               {$ELSE}        hum.SysMsg ('You cannot hire it right now.', 0);
               {$ENDIF}
            end;
         end;
      end else begin
         {$IFDEF KOREA} hum.SysMsg ('���������', 0);
         {$ELSE}        hum.SysMsg ('Wrong command.', 0);
         {$ENDIF}
      end;
   end else begin
      {$IFDEF KOREA} hum.SysMsg ('�����ʽ𲻹�', 0);
      {$ELSE}        hum.SysMsg ('Fund of wall is not sufficient.', 0);
      {$ENDIF}
   end;
end;



procedure TCastleManager.UserCall (caller: TCreature);
begin
   if UserCastle.IsOurCastle (TGuild(caller.MyGuild)) then begin
      inherited UserCall (caller);
   end;
end;

procedure TCastleManager.UserSelect (whocret: TCreature; selstr: string);
var
   body, sel, rmsg: string;
begin
   try
      if selstr <> '' then begin
         if selstr[1] = '@' then begin
            body := GetValidStr3 (selstr, sel, [#13]);
            rmsg := '';
            while TRUE do begin
               whocret.LatestNpcCmd := selstr;

               NpcSayTitle (whocret, sel);

               //��ϼ������� ���ָ��
               if UserCastle.IsOurCastle(TGuild(whocret.MyGuild)) and (whocret.IsGuildMaster) then begin
                  if CompareText(sel, '@@withdrawal') = 0 then begin
                     case UserCastle.GetBackCastleGold (TUserHuman(whocret), abs(Str_ToInt(body,0))) of
                        -1:
                           begin
                              {$IFDEF KOREA} rmsg := UserCastle.OwnerGuildName + 'ֻ�������л���������ʹ��';
                              {$ELSE}                  rmsg := 'It is available only for Guild chief of' + UserCastle.OwnerGuildName;
                              {$ENDIF}
                           end;
                        -2:
                           begin
                              {$IFDEF KOREA} rmsg := '�ó���û����ô����';
                              {$ELSE}                  rmsg := 'That amount of Gold is not in this wall.';
                              {$ENDIF}
                           end;
                        -3:
                           begin
                              {$IFDEF KOREA} rmsg := '���޷�Я������Ķ���';
                              {$ELSE}                  rmsg := 'You cannot carry any more.';
                              {$ENDIF}
                           end;
                        1: UserSelect (whocret, '@main');
                     end;
                     whocret.SendMsg (self, RM_MENU_OK, 0, integer(self), 0, 0, rmsg);
                     break;
                  end;
                  if CompareText(sel, '@@receipts') = 0 then begin
                     case UserCastle.TakeInCastleGold (TUserHuman(whocret), abs(Str_ToInt(body,0))) of
                        -1:
                           begin
                              {$IFDEF KOREA} rmsg := UserCastle.OwnerGuildName + 'ֻ�������л���������ʹ��';
                              {$ELSE}                  rmsg := 'It is available only for Guild chief of ' + UserCastle.OwnerGuildName;
                              {$ENDIF}
                           end;
                        -2:
                           begin
                              {$IFDEF KOREA} rmsg := '��û����ô����';
                              {$ELSE}                  rmsg := 'You have not Gold of that amount.';
                              {$ENDIF}
                           end;
                        -3:
                           begin
                              {$IFDEF KOREA} rmsg := '���Ѿ��ﵽ�ڳ��ڴ����Ʒ��������';
                              {$ELSE}                  rmsg := 'It exceeds the limit of custody to the wall.';
                              {$ENDIF}
                           end;
                        1: UserSelect (whocret, '@main');
                     end;
                     whocret.SendMsg (self, RM_MENU_OK, 0, integer(self), 0, 0, rmsg);
                     break;
                  end;
                  if CompareText(sel, '@openmaindoor') = 0 then begin
                     UserCastle.ActivateMainDoor (FALSE);
                     break;
                  end;
                  if CompareText(sel, '@closemaindoor') = 0 then begin
                     UserCastle.ActivateMainDoor (TRUE);
                     break;
                  end;
                  if CompareText(sel, '@repairdoornow') = 0 then begin
                     RepaireCastlesMainDoor (TUserHuman(whocret));
                     UserSelect (whocret, '@main');
                     break;
                  end;
                  if CompareText(sel, '@repairwallnow1') = 0 then begin
                     RepaireCoreCastleWall (1, TUserHuman(whocret));
                     UserSelect (whocret, '@main');
                     break;
                  end;
                  if CompareText(sel, '@repairwallnow2') = 0 then begin
                     RepaireCoreCastleWall (2, TUserHuman(whocret));
                     UserSelect (whocret, '@main');
                     break;
                  end;
                  if CompareText(sel, '@repairwallnow3') = 0 then begin
                     RepaireCoreCastleWall (3, TUserHuman(whocret));
                     UserSelect (whocret, '@main');
                     break;
                  end;

                  if CompareLStr(sel, '@hireguardnow', 13) then begin
                     HireCastleGuard (Copy(sel,14,Length(sel)), TUserHuman(whocret));
                     UserSelect (whocret, '@hireguards');
                  end;

                  if CompareLStr(sel, '@hirearchernow', 14) then begin
                     HireCastleArcher (Copy(sel,15,Length(sel)), TUserHuman(whocret));
                     //UserSelect (whocret, '@hirearchers');
                     whocret.SendMsg (self, RM_MENU_OK, 0, integer(self), 0, 0, '');
                  end;

                  if CompareText(sel, '@exit') = 0 then begin
                     whocret.SendMsg (self, RM_MERCHANTDLGCLOSE, 0, integer(self), 0, 0, '');
                     break;
                  end;
               end else begin
                  {$IFDEF KOREA}
                     whocret.SendMsg (self, RM_MENU_OK, 0, integer(self), 0, 0, '��û��ʹ��Ȩ��');
                  {$ELSE}
                     whocret.SendMsg (self, RM_MENU_OK, 0, integer(self), 0, 0, 'You have no right.');
                  {$ENDIF}
               end;

               break;
            end;
         end;
      end;
   except
      MainOutMessage ('[Exception] TMerchant.UserSelect... ');
   end;
end;


{---------------------------HiddenNpc-----------------------------}

constructor THiddenNpc.Create;
begin
   inherited Create;
   RunDone := FALSE;
   ViewRange := 7;
   RunNextTick := 250;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   DigupRange := 4;
   DigdownRange := 4;
   HideMode := TRUE;
   StickMode := TRUE;
   BoHiddenNpc := TRUE;
end;

destructor THiddenNpc.Destroy;
begin
   inherited destroy;
end;

procedure THiddenNpc.ComeOut;
begin
   HideMode := FALSE;
//   SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
   SendRefMsg (RM_HIT, Dir, CX, CY, 0, '');
end;

procedure THiddenNpc.ComeDown;
var
   i: integer;
begin
//   SendRefMsg (RM_DIGDOWN, {Dir}0, CX, CY, 0, '');
   SendRefMsg (RM_DISAPPEAR, 0, 0, 0, 0, '');
   try
      for i:=0 to VisibleActors.Count-1 do
         Dispose (PTVisibleActor(VisibleActors[i]));
      VisibleActors.Clear;
   except
      MainOutMessage ('[Exception] THiddenNpc VisbleActors Dispose(..)');
   end;
   HideMode := TRUE;
end;

procedure THiddenNpc.CheckComeOut;
var
   i: integer;
   cret: TCreature;
begin
   for i:=0 to VisibleActors.Count-1 do begin
      cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
      if (not cret.Death) and (IsProperTarget(cret)) and (not cret.BoHumHideMode or BoViewFixedHide) then begin
         if (abs(CX-cret.CX) <= DigupRange) and (abs(CY-cret.CY) <= DigupRange) then begin
            ComeOut; //������ ������. ���δ�.
            break;
         end;
      end;
   end;
end;

procedure THiddenNpc.RunMsg (msg: TMessageInfo);
begin
   inherited RunMsg (msg);
end;

procedure THiddenNpc.Run;
var
   boidle: Boolean;
   nearcret : TCreature;
begin
   nearcret := nil;
   
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         WalkTime := GetCurrentTime;
         if HideMode then begin //���� ����� ��Ÿ���� �ʾ���.
            CheckComeOut;
         end else begin
            if GetCurrentTime - HitTime > GetNextHitTime then begin //��ӹ��� run ���� HitTime �缳����.
//               HitTime := GetTickCount; //�Ʒ� AttackTarget���� ��.
               nearcret := GetNearMonster;
            end;

            boidle := FALSE;
            if nearcret <> nil then begin
               if (abs(nearcret.CX-CX) > DigdownRange) or (abs(nearcret.CY-CY) > DigdownRange) then
                  boidle := TRUE;
            end else boidle := TRUE;

            if boidle then begin
               ComeDown; //�ٽ� ����.
            end;
         end;
      end;
   end;

   inherited Run;
end;

end.


