unit Castle;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, Grobal2, Envir, EdCode, ObjBase,
  M2Share, Guild, IniFiles, ObjMon2;

const
{$IFDEF KOREA}
   CASTLEFILENAME = 'Sabuk.txt';
   CASTLENAMEDEF  = 'ɳ�Ϳ�';
{$ELSE}
   CASTLEFILENAME = 'Sabuk.txt';
   CASTLENAMEDEF  = 'SabukWall';
{$ENDIF}
   CASTLEATTACERS = 'AttackSabukWall.txt';
   CASTLEMAXGOLD = 100000000;
   TODAYGOLD     = 5000000;
   CASTLECOREMAP = '0150';
   CASTLEBASEMAP = 'D701';
   COREDOORX = 631;
   COREDOORY = 274;
   MAXARCHER = 12;
   MAXGUARD = 4;

type
   TDefenseUnit = record
      X: integer;
      Y: integer;
      UnitName: string;
      BoDoorOpen: Boolean;  //TCastleDoor �� ���
      HP: integer;
      UnitObj: TCreature;  //TWallStructure or TSolder
   end;

   TAttackerInfo = record
      AttackDate: TDateTime;
      GuildName: string;
      Guild: TGuild;
   end;
   PTAttackerInfo = ^TAttackerInfo;

   TUserCastle = class
   private
      procedure SaveToFile (flname: string);
      procedure LoadFromFile (flname: string);
      procedure SaveAttackerList;
   public
      CastlePEnvir: TEnvirnoment;
      CorePEnvir: TEnvirnoment;  //����, �� ���� �����ϸ� ���� ������ ������ �Ѵ�.
      BasementEnvir: TEnvirnoment;
      CoreCastlePDoorCore: PTDoorCore;
      CastleMapName: string;
      CastleName: string;
      OwnerGuildName: string;
      OwnerGuild: TGuild;
      CastleMap: string;
      CastleStartX, CastleStartY: integer;

      LatestOwnerChangeDateTime: TDateTime;  //���������� ���� ������ �ٲ� �ð�
      LatestWarDateTime: TDateTime;   //���������� �������� ���۵� �ð�
      BoCastleWarChecked: Boolean;
      BoCastleUnderAttack: Boolean;  //������ ������
      BoCastleWarTimeOut10min: Boolean;
      BoCastleWarTimeOutRemainMinute: integer;
      CastleAttackStarted: longword;
      SaveCastleGoldTime: longword;

      //�������� �����ڿ� ����
      AttackerList: TList;  //���ݹ��� ����Ʈ
      RushGuildList: TList;  //�������� �ϰ� �ִ� ����

      MainDoor: TDefenseUnit; //TCastleDoor;  //����
      LeftWall: TDefenseUnit; //TWallStructure;
      CenterWall: TDefenseUnit; //TWallStructure;
      RightWall: TDefenseUnit; //TWallStructure;
      Guards: array[0..MAXGUARD-1] of TDefenseUnit;
      Archers: array[0..MAXARCHER-1] of TDefenseUnit;

      IncomeToday: TDateTime;  //���� ������ �ȱ� ������ ��
      TotalGold: integer;  //��ü �������� ���� ��(���� �ڱ�), 1000�����̻� �� �� ����.
      TodayIncome: integer;  //���� �������� ���� ��, 10������ ���� �� ����.

      constructor Create;
      destructor Destroy; override;
      procedure Initialize;
      procedure Run;  //10�ʿ� �ѹ�

      procedure SaveAll;
      procedure LoadAttackerList;

      function  GetCastleStartMap: string;
      function  GetCastleStartX: integer;
      function  GetCastleStartY: integer;
      function  CanEnteranceCoreCastle (xx, yy: integer; hum: TUserHuman): Boolean;
      function  IsOurCastle (g: TGuild): Boolean;
      function  IsCastleMember (hum: TUserHuman): Boolean;
      function  IsCastleAllyMember (hum: TUserHuman): Boolean;
      procedure ActivateDefeseUnits (active: Boolean);
      procedure ActivateMainDoor (active: Boolean);

      procedure PayTax (goodsprice: integer);
      function  GetBackCastleGold (hum: TUserHuman; howmuch: integer): integer;  //���ְ� ���� ���� ����.
      function  TakeInCastleGold (hum: TUserHuman; howmuch: integer): integer; //���ְ� ���� ���� ����
      function  RepairCastleDoor: Boolean;
      function  RepairCoreCastleWall (wallnum: integer): integer;

      //������ ��û ����
      function  IsAttackGuild (aguild: TGuild): Boolean;
      function  ProposeCastleWar (aguild: TGuild): Boolean;
      function  GetNextWarDateTimeStr: string;
      function  GetListOfWars: string;
      procedure StartCastleWar;

      //������ ��
      function  IsCastleWarArea (penvir: TEnvirnoment; x, y: integer): Boolean;
      function  IsRushCastleGuild (aguild: TGuild): Boolean;
      function  IsRushAllyCastleGuild (aguild: TGuild): Boolean;
      function  GetRushGuildCount: integer;
      function  CheckCastleWarWinCondition (aguild: TGuild): Boolean;
      procedure ChangeCastleOwner (guild: TGuild);
      procedure FinishCastleWar;

   end;


implementation

uses
   svMain;


//��ϼ��� ������ ��ϼ��� �ִ� ���������� ����Ȱ�
//�ٸ� ���������� �б⸸ �Ѵ�.

constructor TUserCastle.Create;
begin
   OwnerGuild := nil;
   CastleMap := '3';
   CastleStartX := 644;
   CastleStartY := 290;
   CastleName := CASTLENAMEDEF;
   CastlePEnvir := nil;
   CoreCastlePDoorCore := nil;

   BoCastleWarChecked := FALSE;  //���� 20�ÿ� üũ ����
   BoCastleUnderAttack := FALSE;
   BoCastleWarTimeOut10min := FALSE;
   BoCastleWarTimeOutRemainMinute := 0;

   AttackerList := TList.Create;
   RushGuildList := TList.Create;

   SaveCastleGoldTime := GetTickCount;
end;

destructor TUserCastle.Destroy;
begin
   AttackerList.Free;
   RushGuildList.Free;
   inherited Destroy;
end;

procedure TUserCastle.Initialize;
var
   i: integer;
   pd: PTDoorInfo;
begin
   LoadFromFile (CASTLEFILENAME);
   LoadAttackerList;

   //�������� ����Ǵ� �������� ����, (��ϼ��� ����������)
   if ServerIndex <> GrobalEnvir.GetServer (CastleMapName) then
      exit;

   CorePEnvir := GrobalEnvir.GetEnvir (CASTLECOREMAP);
   if CorePEnvir = nil then begin
      {$IFDEF KOREA}
      ShowMessage (CASTLECOREMAP + ' ���� ã�� �� �����ϴ�. (������ ������ ����)');
      {$ELSE}
      ShowMessage (CASTLECOREMAP + ' No map found. ( No inner wall map of wall conquest war )');
      {$ENDIF}
   end;

   BasementEnvir := GrobalEnvir.GetEnvir (CASTLEBASEMAP);
   if CorePEnvir = nil then
      ShowMessage (CASTLEBASEMAP + ' - map not found !!');

//(*** �������� ����Ǹ�
   CastlePEnvir := GrobalEnvir.GetEnvir (CastleMapName);
   if CastlePEnvir <> nil then begin
      with MainDoor do begin
         UnitObj := UserEngine.AddCreatureSysop (
                                    CastleMapName,
                                    X,
                                    Y,
                                    UnitName);
         if UnitObj <> nil then begin
            UnitObj.WAbil.HP := HP;
            TGuardUnit(UnitObj).Castle := self;
            if BoDoorOpen then
               TCastleDoor(MainDoor.UnitObj).OpenDoor;
         end else
            ShowMessage ('[Error] UserCastle.Initialize MainDoor.UnitObj = nil');
      end;
      with LeftWall do begin
         UnitObj := UserEngine.AddCreatureSysop (
                                    CastleMapName,
                                    X,
                                    Y,
                                    UnitName);
         if UnitObj <> nil then begin
            UnitObj.WAbil.HP := HP;
            TGuardUnit(UnitObj).Castle := self;
         end else
            ShowMessage ('[Error] UserCastle.Initialize LeftWall.UnitObj = nil');
      end;
      with CenterWall do begin
         UnitObj := UserEngine.AddCreatureSysop (
                                    CastleMapName,
                                    X,
                                    Y,
                                    UnitName);
         if UnitObj <> nil then begin
            UnitObj.WAbil.HP := HP;
            TGuardUnit(UnitObj).Castle := self;
         end else
            ShowMessage ('[Error] UserCastle.Initialize CenterWall.UnitObj = nil');
      end;
      with RightWall do begin
         UnitObj := UserEngine.AddCreatureSysop (
                                    CastleMapName,
                                    X,
                                    Y,
                                    UnitName);
         if UnitObj <> nil then begin
            UnitObj.WAbil.HP := HP;
            TGuardUnit(UnitObj).Castle := self;
         end else
            ShowMessage ('[Error] UserCastle.Initialize RightWall.UnitObj = nil');
      end;

      for i:=0 to MAXARCHER-1 do begin
         with Archers[i] do begin
            if HP > 0 then begin
               UnitObj := UserEngine.AddCreatureSysop (
                                          CastleMapName,
                                          X,
                                          Y,
                                          UnitName);
               if UnitObj <> nil then begin
                  TGuardUnit(UnitObj).Castle := self;
                  UnitObj.WAbil.HP := HP;
                  TGuardUnit(UnitObj).OriginX := X;
                  TGuardUnit(UnitObj).OriginY := Y;
                  TGuardUnit(UnitObj).OriginDir := 3;
               end else
                  ShowMessage ('[Error] UserCastle.Initialize Archer -> UnitObj = nil');
            end;
         end;
      end;

      for i:=0 to MAXGUARD-1 do begin
         with Guards[i] do begin
            if HP > 0 then begin
               UnitObj := UserEngine.AddCreatureSysop (
                                          CastleMapName,
                                          X,
                                          Y,
                                          UnitName);
               if UnitObj <> nil then begin
                  UnitObj.WAbil.HP := HP;
                  //TGuardUnit(UnitObj).OriginX := X;
                  //TGuardUnit(UnitObj).OriginY := Y;
                  //TGuardUnit(UnitObj).OriginDir := 3;
               end else
                  ShowMessage ('[Error] UserCastle.Initialize Archer -> UnitObj = nil');
            end;
         end;
      end;


   end else
      ShowMessage ('<Critical Error> UserCastle : [Defense]->CastleMap is invalid value');

   //��ϼ��� ������
   with GrobalEnvir do begin
      for i:=0 to CastlePEnvir.DoorList.Count-1 do begin
         pd := PTDoorInfo(CastlePEnvir.DoorList[i]);
         if (abs(pd.DoorX-COREDOORX) <= 3) and (abs(pd.DoorY-COREDOORY) <= 3) then begin
            CoreCastlePDoorCore := pd.pCore;
         end;
      end;
   end;


//*)
end;

procedure TUserCastle.SaveAll;
begin
   SaveToFile (CASTLEFILENAME);  //������ ���������� �����
end;

//AttackerList
procedure TUserCastle.SaveAttackerList;
var
   i: integer;
   strlist: TStringList;
   flname: string;
begin
   flname := CastleDir + CASTLEATTACERS;
   strlist := TStringList.Create;
   for i:=0 to AttackerList.Count-1 do begin
      strlist.Add (PTAttackerInfo (AttackerList[i]).GuildName +
                   '       "' + DateToStr(PTAttackerInfo (AttackerList[i]).AttackDate) + '"'
                  );
   end;
   try
      strlist.SaveToFile (flname);
   except
      {$IFDEF KOREA}
      MainOutMessage (flname + ' Saving error...');
      {$ELSE}
      MainOutMessage (flname + 'Saving error...');
      {$ENDIF}
   end;
   strlist.Free;
end;

//AttackerList
procedure TUserCastle.LoadAttackerList;
var
   i: integer;
   strlist: TStringList;
   pattack: PTAttackerInfo;
   aguild: TGuild;
   flname, gname, adate: string;
begin
   flname := CastleDir + CASTLEATTACERS;
   if not FileExists (flname) then exit;
   strlist := TStringList.Create;
   try
      strlist.LoadFromFile (flname);
      for i:=0 to AttackerList.Count-1 do Dispose(PTAttackerInfo(AttackerList[i]));
      AttackerList.Clear;
      for i:=0 to strlist.Count-1 do begin
         adate := GetValidStr3(strlist[i], gname, [' ', #9]);
         aguild := GuildMan.GetGuild(gname);
         if aguild <> nil then begin
            new (pattack);
            ArrestStringEx (adate, '"', '"', adate);
            try
               pattack.AttackDate := StrToDate (adate);
            except
               pattack.AttackDate := Date;
            end;
            pattack.GuildName := gname;
            pattack.Guild := aguild;
            AttackerList.Add (pattack);
         end;
      end;
   except
      {$IFDEF KOREA}
      MainOutMessage (flname + ' Reading failed...');
      {$ELSE}
      MainOutMessage (flname + ' Reading failed...');
      {$ENDIF}
   end;
   strlist.Free;
end;

procedure TUserCastle.SaveToFile (flname: string);
var
   i: integer;
   ini: TIniFile;
begin
   //��ϼ��� �ִ� ���������� ������ �Ѵ�.
   if ServerIndex = GrobalEnvir.GetServer(CastleMapName) then begin
      ini := TIniFile.Create (CastleDir + flname);
      if ini <> nil then begin
         ini.WriteString ('setup', 'CastleName', CastleName);
         ini.WriteString ('setup', 'OwnGuild', OwnerGuildName);

         ini.WriteDateTime ('setup', 'ChangeDate', LatestOwnerChangeDateTime);
         ini.WriteDateTime ('setup', 'WarDate', LatestWarDateTime);

         ini.WriteDateTime ('setup', 'IncomeToday', IncomeToday);
         ini.WriteInteger ('setup', 'TotalGold', TotalGold);
         ini.WriteInteger ('setup', 'TodayIncome', TodayIncome);

         //����, ����...
         if MainDoor.UnitObj <> nil then begin
            ini.WriteBool ('defense', 'MainDoorOpen', TCastleDoor(MainDoor.UnitObj).BoOpenState);
            ini.WriteInteger ('defense', 'MainDoorHP', TCastleDoor(MainDoor.UnitObj).WAbil.HP);
         end;

         if LeftWall.UnitObj <> nil then
            ini.WriteInteger ('defense', 'LeftWallHP', TCastleDoor(LeftWall.UnitObj).WAbil.HP);
         if CenterWall.UnitObj <> nil then
            ini.WriteInteger ('defense', 'CenterWallHP', TCastleDoor(CenterWall.UnitObj).WAbil.HP);
         if RightWall.UnitObj <> nil then
            ini.WriteInteger ('defense', 'RightWallHP', TCastleDoor(RightWall.UnitObj).WAbil.HP);

         for i:=0 to MAXARCHER-1 do begin
            with Archers[i] do begin
               ini.WriteInteger ('defense', 'Archer_' + IntToStr(i+1) + '_X', X);
               ini.WriteInteger ('defense', 'Archer_' + IntToStr(i+1) + '_Y', Y);
               if UnitObj <> nil then
                  ini.WriteInteger ('defense', 'Archer_' + IntToStr(i+1) + '_HP', TArcherGuard(UnitObj).WAbil.HP)
               else ini.WriteInteger ('defense', 'Archer_' + IntToStr(i+1) + '_HP', 0);
            end;
         end;

         for i:=0 to MAXGUARD-1 do begin
            with Guards[i] do begin
               ini.WriteInteger ('defense', 'Guard_' + IntToStr(i+1) + '_X', X);
               ini.WriteInteger ('defense', 'Guard_' + IntToStr(i+1) + '_Y', Y);
               if UnitObj <> nil then
                  ini.WriteInteger ('defense', 'Guard_' + IntToStr(i+1) + '_HP', TGuardUnit(UnitObj).WAbil.HP)
               else ini.WriteInteger ('defense', 'Guard_' + IntToStr(i+1) + '_HP', HP);
            end;
         end;


         ini.Free;
      end;
   end;
end;

procedure TUserCastle.LoadFromFile (flname: string);
var
   i: integer;
   ini: TIniFile;
begin
   ini := TIniFile.Create (CastleDir + flname);
   if ini <> nil then begin
      CastleName := ini.ReadString ('setup', 'CastleName', CASTLENAMEDEF);
      OwnerGuildName := ini.ReadString ('setup', 'OwnGuild', '');

      LatestOwnerChangeDateTime := ini.ReadDateTime ('setup', 'ChangeDate', Now);
      LatestWarDateTime := ini.ReadDateTime ('setup', 'WarDate', Now);

      IncomeToday := ini.ReadDateTime ('setup', 'IncomeToday', Now);
      TotalGold := ini.ReadInteger ('setup', 'TotalGold', 0);
      TodayIncome := ini.ReadInteger ('setup', 'TodayIncome', 0);

      CastleMapName := ini.ReadString ('defense', 'CastleMap', '3');

      MainDoor.X := ini.ReadInteger ('defense', 'MainDoorX', 0);
      MainDoor.Y := ini.ReadInteger ('defense', 'MainDoorY', 0);
      MainDoor.UnitName := ini.ReadString ('defense', 'MainDoorName', '');
      MainDoor.BoDoorOpen := ini.ReadBool ('defense', 'MainDoorOpen', TRUE);
      MainDoor.HP := ini.ReadInteger ('defense', 'MainDoorHP', 2000);
      MainDoor.UnitObj := nil;

      LeftWall.X := ini.ReadInteger ('defense', 'LeftWallX', 0);
      LeftWall.Y := ini.ReadInteger ('defense', 'LeftWallY', 0);
      LeftWall.UnitName := ini.ReadString ('defense', 'LeftWallName', '');
      LeftWall.HP := ini.ReadInteger ('defense', 'LeftWallHP', 2000);
      LeftWall.UnitObj := nil;

      CenterWall.X := ini.ReadInteger ('defense', 'CenterWallX', 0);
      CenterWall.Y := ini.ReadInteger ('defense', 'CenterWallY', 0);
      CenterWall.UnitName := ini.ReadString ('defense', 'CenterWallName', '');
      CenterWall.HP := ini.ReadInteger ('defense', 'CenterWallHP', 2000);
      CenterWall.UnitObj := nil;

      RightWall.X := ini.ReadInteger ('defense', 'RightWallX', 0);
      RightWall.Y := ini.ReadInteger ('defense', 'RightWallY', 0);
      RightWall.UnitName := ini.ReadString ('defense', 'RightWallName', '');
      RightWall.HP := ini.ReadInteger ('defense', 'RightWallHP', 2000);
      RightWall.UnitObj := nil;

      for i:=0 to MAXARCHER-1 do begin
         with Archers[i] do begin
            X  := ini.ReadInteger ('defense', 'Archer_' + IntToStr(i+1) + '_X', 0);
            Y  := ini.ReadInteger ('defense', 'Archer_' + IntToStr(i+1) + '_Y', 0);
            HP := ini.ReadInteger ('defense', 'Archer_' + IntToStr(i+1) + '_HP', 0);
            {$IFDEF KOREA}
            UnitName := '�ú�';
            {$ELSE}
            UnitName := 'Archer';
            {$ENDIF}
            UnitObj := nil;
         end;
      end;

      for i:=0 to MAXGUARD-1 do begin
         with Guards[i] do begin
            X  := ini.ReadInteger ('defense', 'Guard_' + IntToStr(i+1) + '_X', 0);
            Y  := ini.ReadInteger ('defense', 'Guard_' + IntToStr(i+1) + '_Y', 0);
            HP := ini.ReadInteger ('defense', 'Guard_' + IntToStr(i+1) + '_HP', 0);
            {$IFDEF KOREA}
            UnitName := 'ȣ����';
            {$ELSE}
            UnitName := 'Guard';
            {$ENDIF}
            UnitObj := nil;
         end;
      end;

      ini.Free;
   end;

   OwnerGuild := GuildMan.GetGuild (OwnerGuildName);

end;


//------------------------------------------------------------------------
//UserCastle.run

//10�ʿ� �ѹ��� ����
procedure TUserCastle.Run;
var
   i: integer;
   ahour, amin, asec, amsec: word;
   ayear, amon, aday, ayear2, amon2, aday2: word;
   str, strRemainMinutes: string;
   RemainMinutes: longword;
begin
   if ServerIndex <> GrobalEnvir.GetServer (CastleMapName) then
      exit;

   DecodeDate (Date, ayear, amon, aday);
   DecodeDate (IncomeToday, ayear2, amon2, aday2);

   //�������� �Ѿ�� ������ ������ �ʱ�ȭ ��Ŵ
   if (ayear <> ayear2) or (amon <> amon2) or (aday <> aday2) then begin
      TodayIncome := 0;
      IncomeToday := Now;
      BoCastleWarChecked := FALSE;
   end;

   //**�׽�Ʈ
   //DecodeTime (Time, ahour, amin, asec, amsec);
   //if amin = 1 then BoCastleWarChecked := FALSE;

   //���� ���� 8�ø��� ������ ������ Ȯ���Ѵ�.
   if not BoCastleWarChecked and not BoCastleUnderAttack then begin
      DecodeTime (Time, ahour, amin, asec, amsec);

{$IFDEF DEBUG} //������ �׽�Ʈ ********
ahour := 20;
amin := 1;
asec := 1;
{$ENDIF}

      //if amin = 0 then begin  //�� �� ������
      if ahour = 20 then begin //����8��
         BoCastleWarChecked := TRUE;  //�ѹ��� �˻���

         RushGuildList.Clear;
         //������ ����Ʈ�� �˻�
         for i:=AttackerList.Count-1 downto 0 do begin
            DecodeDate (PTAttackerInfo (AttackerList[i]).AttackDate, ayear2, amon2, aday2);
            if (ayear=ayear2) and (amon=amon2) and (aday=aday2) then begin
               //������ ����
               BoCastleUnderAttack := TRUE;
               BoCastleWarTimeOut10min := FALSE;
               LatestWarDateTime := Now;
               CastleAttackStarted := GetTickCount;
               RushGuildList.Add (PTAttackerInfo (AttackerList[i]).Guild);
               Dispose (PTAttackerInfo (AttackerList[i]));  //�޸�����
               AttackerList.Delete (i);
            end;
         end;

         //�������� ������ �˸���.
         if BoCastleUnderAttack then begin

            RushGuildList.Add (OwnerGuild);  //���� �ڵ����� ���ݹ����� ��

            StartCastleWar;

            SaveAttackerList;

            UserEngine.SendInterMsg (ISM_RELOADCASTLEINFO, ServerIndex, '');

            //�������� �������� ������ ������.
            {$IFDEF KOREA}
            str := '[ɳ�Ϳ˹���ս�Ѿ���ʼ]';
            {$ELSE}
            str := '[Sabuk wall conquest war started.]';
            {$ENDIF}
            UserEngine.SysMsgAll (str);
            UserEngine.SendInterMsg (ISM_SYSOPMSG, ServerIndex, str);

            ActivateMainDoor (TRUE);  //�ڵ����� ������ ����
         end;

      end;

   end;

   //���� ���� ����.
   for i:=0 to MAXGUARD-1 do
      if Guards[i].UnitObj <> nil then
         if Guards[i].UnitObj.BoGhost then Guards[i].UnitObj := nil;
   for i:=0 to MAXARCHER-1 do
      if Archers[i].UnitObj <> nil then
         if Archers[i].UnitObj.BoGhost then Archers[i].UnitObj := nil;


   //������ ���� ���, ������ ������ 3�ð��� ������ �������� ����ȴ�.
   if BoCastleUnderAttack then begin
      LeftWall.UnitObj.BoStoneMode := FALSE;
      CenterWall.UnitObj.BoStoneMode := FALSE;
      RightWall.UnitObj.BoStoneMode := FALSE;

      if not BoCastleWarTimeOut10min then begin
         if GetTickCount - CastleAttackStarted > (2 * 60 * 60 * 1000 - (10 * 60 * 1000)) then begin
            //10����
            BoCastleWarTimeOut10min := TRUE;
            BoCastleWarTimeOutRemainMinute := 10;
            //�������� �������� ������ ������.
            {$IFDEF KOREA}
            str := '[ɳ�Ϳ˹���ս����10���Ӻ����]';
            {$ELSE}
            str := '[Sabuk War 10 Minutes remaining.]';
            {$ENDIF}
            UserEngine.SysMsgAll (str);
            UserEngine.SendInterMsg (ISM_SYSOPMSG, ServerIndex, str);
         end;
      end else if BoCastleWarTimeOutRemainMinute > 0 then begin
         strRemainMinutes := '';
         RemainMinutes := ((2 * 60 * 60 * 1000) - (GetTickCount - CastleAttackStarted));

         if (RemainMinutes > 9 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 9 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '9';
            BoCastleWarTimeOutRemainMinute := 9;
         end else if (RemainMinutes > 8 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 8 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '8';
            BoCastleWarTimeOutRemainMinute := 8;
         end else if (RemainMinutes > 7 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 7 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '7';
            BoCastleWarTimeOutRemainMinute := 7;
         end else if (RemainMinutes > 6 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 6 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '6';
            BoCastleWarTimeOutRemainMinute := 6;
         end else if (RemainMinutes > 5 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 5 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '5';
            BoCastleWarTimeOutRemainMinute := 5;
         end else if (RemainMinutes > 4 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 4 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '4';
            BoCastleWarTimeOutRemainMinute := 4;
         end else if (RemainMinutes > 3 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 3 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '3';
            BoCastleWarTimeOutRemainMinute := 3;
         end else if (RemainMinutes > 2 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 2 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '2';
            BoCastleWarTimeOutRemainMinute := 2;
         end else if (RemainMinutes > 1 * 60 * 1000 - 5 * 1000) and (RemainMinutes < 1 * 60 * 1000 + 5 * 1000) then begin
            strRemainMinutes := '1';
            BoCastleWarTimeOutRemainMinute := 1;
         end else if RemainMinutes <= 1 * 60 * 1000 - 5 * 1000 then begin
            strRemainMinutes := '';
            BoCastleWarTimeOutRemainMinute := 0;
         end else begin
            strRemainMinutes := '';
         end;

         if strRemainMinutes <> '' then begin
            {$IFDEF KOREA}
            str := '[ɳ�Ϳ˹���ս����' + strRemainMinutes + '���Ӻ����]';
            {$ELSE}
            str := '[Sabuk War ' + strRemainMinutes + ' Minutes remaining.]';
            {$ENDIF}
            {debug code}MainOutMessage(str); //sonmg test
            UserEngine.SysMsgAll (str);
            UserEngine.SendInterMsg (ISM_SYSOPMSG, ServerIndex, str);
         end;
      end;
      if GetTickCount - CastleAttackStarted > 2 * 60 * 60 * 1000 then begin
         //Ÿ�Ӿƿ��� ���, �������� ����.
         FinishCastleWar;
      end;
   end else begin
      LeftWall.UnitObj.BoStoneMode := TRUE;
      CenterWall.UnitObj.BoStoneMode := TRUE;
      RightWall.UnitObj.BoStoneMode := TRUE;
   end;


end;


function  TUserCastle.GetCastleStartMap: string;
begin
   Result := CastleMapName;
end;

function  TUserCastle.GetCastleStartX: integer;
begin
   Result := CastleStartX - 4 + Random(9);
end;

function  TUserCastle.GetCastleStartY: integer;
begin
   Result := CastleStartY - 4 + Random(9);
end;

function  TUserCastle.CanEnteranceCoreCastle (xx, yy: integer; hum: TUserHuman): Boolean;
begin
   Result := IsOurCastle (TGuild(hum.MyGuild));
   if not Result then begin
      with LeftWall do begin
         if UnitObj <> nil then
            if UnitObj.Death then
               if (UnitObj.CX = xx) and (UnitObj.CY = yy) then
                  Result := TRUE;
      end;
      with CenterWall do begin
         if UnitObj <> nil then
            if UnitObj.Death then
               if (UnitObj.CX = xx) and (UnitObj.CY = yy) then
                  Result := TRUE;
      end;
      with RightWall do begin
         if UnitObj <> nil then
            if UnitObj.Death then
               if (UnitObj.CX = xx) and (UnitObj.CY = yy) then
                  Result := TRUE;
      end;
   end;
end;

function  TUserCastle.IsOurCastle (g: TGuild): Boolean;
begin
   if g = nil then begin
      Result := FALSE;
      exit;
   end;
   Result := (UserCastle.OwnerGuild = g) and (UserCastle.OwnerGuild <> nil);
end;

function  TUserCastle.IsCastleMember (hum: TUserHuman): Boolean;
begin
   Result := IsOurCastle (TGuild(hum.MyGuild));
end;

function  TUserCastle.IsCastleAllyMember (hum: TUserHuman): Boolean;
var
   i: integer;
begin
   Result := FALSE;
   if hum.MyGuild = nil then exit;
   if IsOurCastle (TGuild(hum.MyGuild)) then begin
      Result := TRUE;
      exit;
   end;
   for i:=0 to TGuild(hum.MyGuild).AllyGuilds.Count-1 do begin
      if IsOurCastle (TGuild(TGuild(hum.MyGuild).AllyGuilds.Objects[i])) then begin
         Result := TRUE;
         exit;
      end;
   end;
end;

procedure TUserCastle.ActivateDefeseUnits (active: Boolean);
begin
   if MainDoor.UnitObj <> nil then  MainDoor.UnitObj.HideMode := active;
   if LeftWall.UnitObj <> nil then  LeftWall.UnitObj.HideMode := active;
   if CenterWall.UnitObj <> nil then  CenterWall.UnitObj.HideMode := active;
   if RightWall.UnitObj <> nil then  RightWall.UnitObj.HideMode := active;
end;

procedure TUserCastle.ActivateMainDoor (active: Boolean);
begin
   //MainDoor.UnitObj.HideMode := active;
   if MainDoor.UnitObj <> nil then begin
      if not MainDoor.UnitObj.Death then begin
         if active then begin
            if TCastleDoor(MainDoor.UnitObj).BoOpenState then
               TCastleDoor(MainDoor.UnitObj).CloseDoor
         end else begin
            if not TCastleDoor(MainDoor.UnitObj).BoOpenState then
               TCastleDoor(MainDoor.UnitObj).OpenDoor;
         end;
      end;
   end;
end;


//��ϼ����� �������� ������ ��� �� �� ���� ������ �ٴ´�.
procedure TUserCastle.PayTax (goodsprice: integer);
var
   tax: integer;
begin
   // 2003/07/15 ��� ���� ���� ���� 0.05 -> 0.10
   tax := Round (goodsprice * 0.1);  //������ 5%�� ����   0.05
   if TodayIncome + tax <= TODAYGOLD then begin
      TodayIncome := TodayIncome + tax;
   end else begin
      if TodayIncome >= TODAYGOLD then begin
         tax := 0;
      end else begin
         tax := TODAYGOLD - TodayIncome;
         TodayIncome := TODAYGOLD;
      end;
   end;
   if tax > 0 then begin
      if int64(TotalGold) + tax <= CASTLEMAXGOLD then begin
         TotalGold := TotalGold + tax;
      end else
         TotalGold := CASTLEMAXGOLD;
   end;

   if GetTickCount - SaveCastleGoldTime > 10 * 60 * 1000 then begin
      SaveCastleGoldTime := GetTickCount;
      AddUserLog ('23'#9 + //������_
                  '0'#9 +
                  '0'#9 +
                  '0'#9 +
               {$IFDEF KOREA}
                  'autosave'#9 +
               {$ELSE}
                  'Autosaving'#9 +
               {$ENDIF}
                  NAME_OF_GOLD{'����'} + ''#9 +
                  IntToStr(TotalGold) + ''#9 +
                  '0'#9 +
                  '0');
   end;
end;

//���ְ� ���� ���� ����.
//-1: ���ְ� �ƴ�
//-2: �׸�ŭ ���� ����
//-3: ã���̰� ���� �� �̻� �� �� ����
//1 : ����
function  TUserCastle.GetBackCastleGold (hum: TUserHuman; howmuch: integer): integer;
begin
   Result := -1;
   if (hum.MyGuild = UserCastle.OwnerGuild) and (hum.GuildRank = 1) then begin
      if howmuch <= TotalGold then begin
         if hum.Gold + howmuch <= hum.AvailableGold then begin
            TotalGold := TotalGold - howmuch;
            hum.IncGold (howmuch);

            //�α׳���
            AddUserLog ('22'#9 + //������_
                        hum.MapName + ''#9 +
                        IntToStr(hum.CX) + ''#9 +
                        IntToStr(hum.CY) + ''#9 +
                        hum.UserName + ''#9 +
                        NAME_OF_GOLD{'����'} + ''#9 +
                        IntToStr(howmuch) + ''#9 +
                        '1'#9 +
                        '0');
            hum.GoldChanged;
            Result := 1;
         end else
            Result := -3;
      end else
         Result := -2;
   end;
end;

//���ְ� ���� ���� ����
//-1: ���ְ� �ƴ�
//-2: �׸�ŭ ���� ����
//-3: ã���̰� ���� �� �̻� �� �� ����
function  TUserCastle.TakeInCastleGold (hum: TUserHuman; howmuch: integer): integer;
begin
   Result := -1;
   if (hum.MyGuild = UserCastle.OwnerGuild) and (hum.GuildRank = 1) then begin
      if howmuch <= hum.Gold then begin
         if int64(howmuch) + TotalGold <= CASTLEMAXGOLD then begin
            hum.DecGold (howmuch);
            TotalGold := TotalGold + howmuch;

            //�α׳���
            AddUserLog ('23'#9 + //������_
                        hum.MapName + ''#9 +
                        IntToStr(hum.CX) + ''#9 +
                        IntToStr(hum.CY) + ''#9 +
                        hum.UserName + ''#9 +
                        NAME_OF_GOLD{'����'} + ''#9 +
                        IntToStr(howmuch) + ''#9 +
                        '0'#9 +
                        '0');
            hum.GoldChanged;
            Result := 1;
         end else
            Result := -3;
      end else
         Result := -2;
   end;
end;

//������ ��ģ��.
function  TUserCastle.RepairCastleDoor: Boolean;
begin
   Result := FALSE;
   with MainDoor do begin
      if (UnitObj <> nil) and (not BoCastleUnderAttack) then begin
         if UnitObj.WAbil.HP < UnitObj.WAbil.MaxHP then begin
            if not UnitObj.Death then begin
               //�������� ���� 10���� ������ ��ĥ �� �ִ�.
               if GetTickCount - TCastleDoor(UnitObj).StruckTime > 1 * 60 * 1000 then begin
                  UnitObj.WAbil.HP := UnitObj.WAbil.MaxHP;
                  TCastleDoor(UnitObj).RepairStructure;  //���ο� ����� ������.
                  Result := TRUE;
               end;
            end else begin
               //���ĵ� ��쿡�� 1�ð� �Ŀ� ��ĥ �� ����
               if GetTickCount - TCastleDoor(UnitObj).BrokenTime > 1 * 60 * 1000 then begin
                  UnitObj.WAbil.HP := UnitObj.WAbil.MaxHP;
                  UnitObj.Death := FALSE;
                  TCastleDoor(UnitObj).BoOpenState := FALSE;
                  TCastleDoor(UnitObj).RepairStructure;  //���ο� ����� ������.
                  Result := TRUE;
               end;
            end;
         end;
      end;
   end;
end;

//������ ��ģ��.
function  TUserCastle.RepairCoreCastleWall (wallnum: integer): integer;
var
   wall: TWallStructure;
begin
   Result := 0;
   case wallnum of
      1: wall := TWallStructure (LeftWall.UnitObj);
      2: wall := TWallStructure (CenterWall.UnitObj);
      3: wall := TWallStructure (RightWall.UnitObj);
      else exit;
   end;
   if (wall <> nil) and (not BoCastleUnderAttack) then begin
      if wall.WAbil.HP < wall.WAbil.MaxHP then begin
         if not wall.Death then begin
            //�������� ���� 10���� ������ ��ĥ �� �ִ�.
            if GetTickCount - wall.StruckTime > 1 * 60 * 1000 then begin
               wall.WAbil.HP := wall.WAbil.MaxHP;
               wall.RepairStructure;  //���ο� ����� ������.
               Result := 1;
            end;
         end else begin
            //���ĵ� ��쿡�� 1�ð� �Ŀ� ��ĥ �� ����
            if GetTickCount - wall.BrokenTime > 1 * 60 * 1000 then begin
               wall.WAbil.HP := wall.WAbil.MaxHP;
               wall.Death := FALSE;
               wall.RepairStructure;  //���ο� ����� ������.
               Result := 1;
            end;
         end;
      end;
   end;
end;


//������ �����ڿ� ����

function  TUserCastle.IsAttackGuild (aguild: TGuild): Boolean;
var
   i: integer;
begin
   Result := FALSE;
   for i:=0 to AttackerList.Count-1 do begin
      if aguild = PTAttackerInfo (AttackerList[i]).Guild then begin
         Result := TRUE;
         break;
      end;
   end;
end;

//�������� ���� ��û�� �� �ִ��� ����..
function  TUserCastle.ProposeCastleWar (aguild: TGuild): Boolean;
var
   pattack: PTAttackerInfo;
begin
   Result := FALSE;
   if not IsAttackGuild (aguild) then begin         //�ߺ���û�� �ȵ�
      new (pattack);


      pattack.AttackDate := CalcDay (Date, 1+1);  //�ύͷ�񹥳�ʱ�� Ĭ����1+3


      pattack.GuildName := aguild.GuildName;
      pattack.Guild := aguild;
      AttackerList.Add (pattack);

      SaveAttackerList;
      UserEngine.SendInterMsg (ISM_RELOADCASTLEINFO, ServerIndex, '');
      Result := TRUE;
   end;
end;

function  TUserCastle.GetNextWarDateTimeStr: string;
var
   ayear, amon, aday: word;
begin
   Result := '';
   if AttackerList.Count > 0 then begin
      if ENGLISHVERSION then begin  //�ܱ��� ����
         Result := DateToStr(PTAttackerInfo (AttackerList[0]).AttackDate);
      end else if PHILIPPINEVERSION then begin  //�ʸ��� ����
         Result := DateToStr(PTAttackerInfo (AttackerList[0]).AttackDate);
      end else begin
         DecodeDate (PTAttackerInfo (AttackerList[0]).AttackDate, ayear, amon, aday);
         // 2003/04/01 ���� ����
         {$IFDEF KOREA}
         Result := IntToStr(ayear) + '��' + IntToStr(amon) + '��' + IntToStr(aday) + '��';
         {$ELSE}
         Result := IntToStr(ayear) + 'Year' + IntToStr(amon) + 'Month' + IntToStr(aday) + 'Day';
         {$ENDIF}
      end;
   end;

end;

function  TUserCastle.GetListOfWars: string;
var
   i, len: integer;
   y, m, d, ayear, amon, aday: word;
   str: string;
begin
   Result := '';
   ayear := 0;  amon := 0;  aday := 0;
   len := 0;
   for i:=0 to AttackerList.Count-1 do begin
      DecodeDate (PTAttackerInfo (AttackerList[i]).AttackDate, y, m, d);
      if (y <> ayear) or (m <> amon) or (d <> aday) then begin
         ayear := y;
         amon := m;
         aday := d;
         if Result <> '' then Result := Result + '\';
         if ENGLISHVERSION then begin  //�ܱ��� ����
            Result := Result + DateToStr(PTAttackerInfo (AttackerList[i]).AttackDate) + '\';
         end else if PHILIPPINEVERSION then begin  //�ʸ��� ����
            Result := Result + DateToStr(PTAttackerInfo (AttackerList[i]).AttackDate) + '\';
         end else begin
            {$IFDEF KOREA}
            Result := Result + IntToStr(ayear) + '��' + IntToStr(amon) + '��' + IntToStr(aday) + '��\';
            {$ELSE}
            Result := Result + IntToStr(ayear) + 'Year' + IntToStr(amon) + 'Month' + IntToStr(aday) + 'Day\';
            {$ENDIF}
         end;
         len := 0;
      end;
      if len > 40 then begin
         Result := Result + '\';
         len := 0;
      end;
      str := '"' + PTAttackerInfo (AttackerList[i]).GuildName + '" ';
      len := len + Length(str);
      Result := Result + str;

   end;
end;

procedure TUserCastle.StartCastleWar;
var
   i: integer;
   ulist: TList;
   hum: TUserHuman;
begin
   ulist := TList.Create;
   UserEngine.GetAreaUsers (CastlePEnvir, CastleStartX, CastleStartY, 100, ulist);
   for i:=0 to ulist.Count-1 do begin
      hum := TUserHuman(ulist[i]);
      hum.UserNameChanged; //ChangeNameColor;
   end;
   ulist.Free;
end;



//������ �߿� ����..

function  TUserCastle.IsCastleWarArea (penvir: TEnvirnoment; x, y: integer): Boolean;
begin
   Result := FALSE;
   if penvir = CastlePEnvir then begin
      if (abs(CastleStartX - x) < 100) and (abs(CastleStartY - y) < 100) then
         Result := TRUE;
   end;
   if (penvir = CorePEnvir) or
      (penvir = BasementEnvir)
   then Result := TRUE;
end;

function  TUserCastle.IsRushCastleGuild (aguild: TGuild): Boolean;
var
   i: integer;
begin
   Result := FALSE;
   if aguild = nil then exit;
   for i:=0 to RushGuildList.Count-1 do begin
      if RushGuildList[i] = aguild then begin
         Result := TRUE;
         break;
      end;
   end;
end;

function  TUserCastle.IsRushAllyCastleGuild (aguild: TGuild): Boolean;
var
   i, j: integer;
begin
   Result := FALSE;
   if aguild = nil then exit;
   for i:=0 to RushGuildList.Count-1 do begin
      if RushGuildList[i] = aguild then begin
         Result := TRUE;
         break;
      end;
      for j:=0 to aguild.AllyGuilds.Count-1 do begin
         if RushGuildList[i] = aguild.AllyGuilds.Objects[j] then begin
            Result := TRUE;
            exit;
         end;
      end;
   end;
end;

function  TUserCastle.GetRushGuildCount: integer;
begin
   Result := RushGuildList.Count;
end;

//�������� �ٸ� ���� ��� ������ ��쿡 �¸� ������ �ȴ�.
function  TUserCastle.CheckCastleWarWinCondition (aguild: TGuild): Boolean;
var
   i: integer;
   ulist: TList;
   flag: Boolean;
begin
   Result := FALSE;
   flag := FALSE;
   if GetTickCount - CastleAttackStarted > 10 * 60 * 1000 then begin  //���� ���� 10���� ������ ������ ����
      ulist := TList.Create;
      UserEngine.GetAreaUsers (CorePEnvir, 0, 0, 1000, ulist);
      flag := TRUE;
      for i:=0 to ulist.Count-1 do begin
         if (not TCreature(ulist[i]).Death) and (TCreature(ulist[i]).MyGuild <> aguild) then begin
            flag := FALSE;  //�츮���� �̿��� ���İ� ���� ����
            break;
         end;
      end;
      ulist.Free;
   end;
   Result := flag;
end;

procedure TUserCastle.ChangeCastleOwner (guild: TGuild);
var
   oldguild: TGuild;
   str: string;
begin
   oldguild := OwnerGuild;
   OwnerGuild := guild;
   OwnerGuildName := TGuild(guild).GuildName;
   LatestOwnerChangeDateTime := Now;  //
   SaveToFile (CASTLEFILENAME);

   if oldguild <> nil then
      oldguild.MemberNameChanged;
   if OwnerGuild <> nil then
      OwnerGuild.MemberNameChanged;

   {$IFDEF KOREA}
   str := '(*)ɳ�Ϳ��ѱ� "' + OwnerGuildName + '" ռ��!!';
   {$ELSE}
   str := '(*) "' + OwnerGuildName + '" Occupying Sabuk wall !!';
   {$ENDIF}

   UserEngine.SysMsgAll (str);
   UserEngine.SendInterMsg (ISM_SYSOPMSG, ServerIndex, str);
   
   {$IFDEF KOREA}
   MainOutMessage ('[ɳ�Ϳ��ѱ�  ' + OwnerGuildName + ' ռ��]');
   {$ELSE}
   MainOutMessage ('[ɳ�Ϳ��ѱ�  ' + OwnerGuildName + ' ռ��]');
   {$ENDIF}

end;

procedure TUserCastle.FinishCastleWar;
var
   i: integer;
   ulist: TList;
   hum: TUserHuman;
   str: string;
begin
   BoCastleUnderAttack := FALSE;  //�������� ������.
   RushGuildList.Clear;

   //���������� �¸��� �� �̿ܿ� ��� ����� �ٸ� ������ ���ư�
   ulist := TList.Create;
   UserEngine.GetAreaUsers (CastlePEnvir, CastleStartX, CastleStartY, 100, ulist);
   for i:=0 to ulist.Count-1 do begin
      hum := TUserHuman(ulist[i]);
      if hum <> nil then begin
         hum.BoInFreePKArea := FALSE;  //������ ��
         //hum.SendAreaState;
         //hum.UserNameChanged; //ChangeNameColor;
         if hum.MyGuild <> OwnerGuild then begin
            //-----------------------
            //��ġ ����(��������:-5000/-500)
            if ENABLE_FAME_SYSTEM then begin
               if hum.IsGuildMaster then hum.DecFamePoint( 5000 )
               else hum.DecFamePoint( 500 );
            end;
            //-----------------------
            hum.RandomSpaceMove (hum.HomeMap, 0);
         end else begin
            //-----------------------
            //��ġ ȹ��(��������:+10000/+1000)
            if ENABLE_FAME_SYSTEM then begin
               if hum.IsGuildMaster then hum.IncFamePoint( 10000 )
               else hum.IncFamePoint( 1000 );
            end;
            //-----------------------
         end;
      end;
   end;
   ulist.Free;

   //�������� �������� ������ ������.
   {$IFDEF KOREA}
   str := '[ɳ�Ϳ˹���ս�Ѿ�����]';
   {$ELSE}
   str := '[Sabuk wall conquest war ended.]';
   {$ENDIF}
   UserEngine.SysMsgAll (str);
   UserEngine.SendInterMsg (ISM_SYSOPMSG, ServerIndex, str);
end;



end.
