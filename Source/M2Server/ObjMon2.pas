unit ObjMon2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, Grobal2, Envir, EdCode, ObjBase,
  M2Share, Event, ObjMon;


type
   TDoorState = (dsOpen, dsClose, dsBroken);

   TStickMonster = class (TAnimal)
   private
   protected
      RunDone: Boolean;
      DigupRange: integer;
      DigdownRange: integer;
      function  AttackTarget: Boolean; dynamic;
      procedure CheckComeOut; dynamic;
      procedure ComeOut; dynamic;
      procedure ComeDown; dynamic;
   public
      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
   end;

   TBeeQueen = class (TAnimal)   //�񸷿���, ����
   private
      //childcount: integer;
      childlist: TList;  //������ ���ϵ��� ����Ʈ
   protected
      procedure MakeChildBee;
   public
      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
   end;

   TCentipedeKingMonster = class (TStickMonster)
   private
      appeartime: longword;
   protected
      function  FindTarget: Boolean;
      function  AttackTarget: Boolean; override;
   public
      constructor Create;
      procedure ComeOut; override;
      procedure Run; override;
   end;

   TBigHeartMonster = class (TAnimal)  //������, �������
   private
   protected
      function  AttackTarget: Boolean; dynamic;
   public
      constructor Create;
      procedure Run; override;
   end;

   TBamTreeMonster = class (TAnimal)
   public
      StruckCount, DeathStruckCount: integer;
      constructor Create;
      procedure Struck (hiter: TCreature); override;
      procedure Run; override;
   end;

   TMonsterBox = class (TBamTreeMonster)
   public
      constructor Create;
      procedure Die; override;
   end;

   TSpiderHouseMonster = class (TAnimal)   //���ȰŹ�, ����
   private
      childlist: TList;  //������ ���ϵ��� ����Ʈ
   protected
      procedure MakeChildSpider;
   public
      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
   end;

   TExplosionSpider = class (TMonster)
   public
      maketime: longword;
      constructor Create;
      procedure DoSelfExplosion;
      function  AttackTarget: Boolean; override;
      procedure Run; override;
   end;


   //���, ����, �ü�

   TGuardUnit = class (TAnimal)
      OriginX, OriginY, OriginDir: integer;
   public
      procedure Struck (hiter: TCreature); override;
      function  IsProperTarget (target: TCreature): Boolean; override;
   end;

   TArcherGuard = class (TGuardUnit)
   private
      procedure ShotArrow (targ: TCreature);
   public
      constructor Create;
      procedure Run; override;
   end;

   TArcherMaster = class (TATMonster)   //�ü�ȣ����
   private
      procedure ShotArrow (targ: TCreature);
   public
      constructor Create;
      function  AttackTarget: Boolean; override;
      procedure Run; override;
   end;

   TArcherPolice = class (TArcherGuard)
   private
   public
      constructor Create;
   end;

   TCastleDoor = class (TGuardUnit)
   public
      BrokenTime: longword; //�μ��� �ð�
      BoOpenState: Boolean;  //���ΰ�� �������ִ���
      constructor Create;
      procedure Run; override;
      procedure Initialize; override;
      procedure Die; override;
      procedure RepairStructure;
      procedure ActiveDoorWall (dstate: TDoorState); //TRUE: �̵���, false:����, ��������
      procedure OpenDoor;
      procedure CloseDoor;
   end;

   TWallStructure = class (TGuardUnit)
   public
      BrokenTime: longword;
      BoBlockPos: Boolean;
      constructor Create;
      procedure Initialize; override;
      procedure Die; override;
      procedure RepairStructure;
      procedure Run; override;
   end;


   TSoccerBall = class (TAnimal)
   public
      GoPower: integer;
      constructor Create;
      procedure Struck (hiter: TCreature); override;
      procedure Run; override;
   end;

   TMineMonster = class (TAnimal)
   private
   protected
      RunDone: Boolean;
      DigupRange: integer;
      DigdownRange: integer;
      function  AttackTarget: Boolean; dynamic;
      procedure CheckComeOut; dynamic;
      procedure ComeOut; dynamic;
   public
      constructor Create;
      destructor Destroy; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
   end;

   //ȣȥ��
   TStickBlockMonster = class (TStickMonster)
   private
      DontAttack: Boolean;
      BoCallFollower: Boolean;
      BoTransparent: Boolean;
      FirstComeOut: Boolean;
      SecondMovement: Boolean;
      FirstStruck: Boolean;
      Caller: TCreature;
      ComeoutTime: Longword;
      TargetDisappearTime: Longword;
      childlist: TList;  //����� �� ������ ����Ʈ
      OldTargetCret: TCreature;
   protected
      function  FindTarget: Boolean;
      function  AttackTarget: Boolean; override;
   public
      constructor Create;
      destructor Destroy; override;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure ComeOut; override;
      procedure ComeDown; override;
      procedure CallFollower; dynamic;
      procedure Die; override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Struck (hiter: TCreature); override;
      procedure Run; override;
   end;

implementation

uses
   svMain, Castle, Guild;


constructor TStickMonster.Create;
begin
   inherited Create;
   RunDone := FALSE;
   ViewRange := 7;
   RunNextTick := 250;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   RaceServer := RC_KILLINGHERB;
   DigupRange := 4;
   DigdownRange := 4;
   HideMode := TRUE;
   StickMode := TRUE;
   BoAnimal := TRUE;  //��� ��������, �����ʿ��Ű� ����.
end;

destructor TStickMonster.Destroy;
begin
   inherited Destroy;
end;

function  TStickMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if TargetInAttackRange (TargetCret, targdir) then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            TargetFocusTime := GetTickCount;
            Attack (TargetCret, targdir);
         end;
         Result := TRUE;
      end else begin
         if TargetCret.MapName = self.MapName then
            SetTargetXY (TargetCret.CX, TargetCret.CY)
         else
            LoseTarget;  //<!!����> TargetCret := nil�� �ٲ�
      end;
   end;
end;

procedure TStickMonster.ComeOut;
begin
   HideMode := FALSE;
   SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
end;

procedure TStickMonster.ComeDown;
var
   i: integer;
begin
   SendRefMsg (RM_DIGDOWN, {Dir}0, CX, CY, 0, '');
   try
      for i:=0 to VisibleActors.Count-1 do
         Dispose (PTVisibleActor(VisibleActors[i]));
      VisibleActors.Clear;
   except
      MainOutMessage ('[Exception] TStickMonster VisbleActors Dispose(..)');
   end;
   HideMode := TRUE;
end;

procedure TStickMonster.CheckComeOut;
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

procedure TStickMonster.RunMsg (msg: TMessageInfo);
begin
   inherited RunMsg (msg);
end;

procedure TStickMonster.Run;
var
   boidle: Boolean;
begin
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
               ///HitTime := GetTickCount; //�Ʒ� AttackTarget���� ��.
               MonsterNormalAttack;
            end;

            boidle := FALSE;
            if TargetCret <> nil then begin
               if (abs(TargetCret.CX-CX) > DigdownRange) or (abs(TargetCret.CY-CY) > DigdownRange) then
                  boidle := TRUE;
            end else boidle := TRUE;

            if boidle then
               ComeDown //�ٽ� ����.
            else
               if AttackTarget then begin
                  inherited Run;
                  exit;
               end;
         end;
      end;
   end;

   inherited Run;

end;

// Mine Monster -----------------------------------------------------------------
constructor TMineMonster.Create;
begin
   inherited Create;
   RunDone := FALSE;
   ViewRange := 7;
   RunNextTick := 250;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   RaceServer := RC_MINE;
   DigupRange := 4;
   DigdownRange := 4;
   HideMode := TRUE;
   StickMode := TRUE;
   BoAnimal := FALSE;  //��� ��������, �����ʿ��Ű� ����.
end;

destructor TMineMonster.Destroy;
begin
   inherited Destroy;
end;

function  TMineMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   WAbil.HP := 0;
   Result := TRUE;
end;

procedure TMineMonster.ComeOut;
begin
   HideMode := FALSE;
   SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
end;


procedure TMineMonster.CheckComeOut;
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

procedure TMineMonster.RunMsg (msg: TMessageInfo);
begin
   inherited RunMsg (msg);
end;

procedure TMineMonster.Run;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         WalkTime := GetCurrentTime;
         if HideMode then begin //���� ����� ��Ÿ���� �ʾ���.
            CheckComeOut;
         end
         else
         begin
            if GetCurrentTime - HitTime > GetNextHitTime then
            begin //��ӹ��� run ���� HitTime �缳����.
               ///HitTime := GetTickCount; //�Ʒ� AttackTarget���� ��.
               if AttackTarget then begin
                  inherited Run;
                  exit;
               end;

            end;
         end;
      end;
   end;

   inherited Run;

end;


{--------------------------------------------------------------}
//����

constructor TBeeQueen.Create;
begin
   inherited Create;
   ViewRange := 9;
   RunNextTick := 250;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   StickMode := TRUE;
   childlist := TList.Create;
end;

destructor TBeeQueen.Destroy;
begin
   childlist.Free;
   inherited Destroy;
end;

procedure TBeeQueen.MakeChildBee;
begin
   if childlist.Count < 15 then begin
      SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');
      SendDelayMsg (self, RM_ZEN_BEE, 0, 0, 0, 0, '', 500);
   end;
end;

procedure TBeeQueen.RunMsg (msg: TMessageInfo);
var
   nx, ny: integer;
   monname: string;
   mon: TCreature;
begin
   case msg.Ident of
      RM_ZEN_BEE:
         begin
            monname := __Bee;  //����
            mon := UserEngine.AddCreatureSysop (PEnvir.MapName, CX, CY, monname);
            if mon <> nil then begin
               mon.SelectTarget (TargetCret);
               childlist.Add (mon);
            end;
         end;
   end;
   inherited RunMsg (msg);
end;

procedure TBeeQueen.Run;
var
   i: integer;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
    if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         WalkTime := GetCurrentTime;
         if GetCurrentTime - HitTime > GetNextHitTime then begin //��ӹ��� run ���� HitTime �缳����.
            HitTime := GetTickCount;
            MonsterNormalAttack;

            if TargetCret <> nil then
               MakeChildBee;

         end;

         for i:=childlist.Count-1 downto 0 do begin
            if (TCreature(childlist[i]).Death) or (TCreature(childlist[i]).BoGhost) then begin
               childlist.Delete(i);
            end;
         end;
      end;
   end;

   inherited Run;
end;



{--------------------------------------------------------------}
//���׿�, �˷��

constructor TCentipedeKingMonster.Create;
begin
   inherited Create;
   ViewRange := 6;
   DigupRange := 4;
   DigdownRange := 6;
   BoAnimal := FALSE;
   appeartime := GetTickCount;
end;

function  TCentipedeKingMonster.FindTarget: Boolean;
var
   i: integer;
   cret: TCreature;
begin
   Result := FALSE;
   for i:=0 to VisibleActors.Count-1 do begin
      cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
      if (not cret.Death) and IsProperTarget(cret) then begin
         if (abs(CX-cret.CX) <= ViewRange) and (abs(CY-cret.CY) <= ViewRange) then begin
            Result := TRUE;
            break;
         end;
      end;
   end;
end;

function  TCentipedeKingMonster.AttackTarget: Boolean;
var
   i, pwr: integer;
   cret: TCreature;
   targdir: byte;
begin
   Result := FALSE;
   if FindTarget then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         //inherited HitHit (nil, HM_CROSSHIT, Dir);
         HitMotion (RM_HIT, self.Dir, CX, CY);

         with WAbil do
            pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );

         for i:=0 to VisibleActors.Count-1 do begin
            cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
            if (not cret.Death) and IsProperTarget(cret) then begin
               if (abs(CX-cret.CX) <= ViewRange) and (abs(CY-cret.CY) <= ViewRange) then begin
                  TargetFocusTime := GetTickCount;

                  SendDelayMsg (self, RM_DELAYMAGIC, pwr, MakeLong(cret.CX, cret.CY), 2, integer(cret), '', 600);
                  //cret.SendDelayMsg (self, RM_MAGSTRUCK, 0, acpwr, 0, 0, '', 600);
                  if Random(4) = 0 then begin
                     if Random(3) <> 0 then
                        cret.MakePoison (POISON_DECHEALTH, 60, 3)   //ü���� ����
                     else
                        cret.MakePoison (POISON_STONE, 5{�ð�,��}, 0);
                  end;

                  TargetCret := cret;
               end;
            end;
         end;
      end;
      Result := TRUE;
   end;
end;

procedure TCentipedeKingMonster.ComeOut;
begin
   inherited ComeOut;
   WAbil.HP := WAbil.MaxHP;   //������ϸ� ü���� ����
end;


procedure TCentipedeKingMonster.Run;   //���׿�,�˷��
var
   i, dis, d: integer;
   cret, nearcret: TCreature;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
     if IsMoveAble then begin
      if GetCurrentTime - WalkTime > NextWalkTime then begin
         WalkTime := GetCurrentTime;
         if HideMode then begin //���� ����� ��Ÿ���� �ʾ���.
            if GetTickCount - appeartime > 10 * 1000 then begin
               for i:=0 to VisibleActors.Count-1 do begin
                  cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
                  if (not cret.Death) and (IsProperTarget(cret)) and (not cret.BoHumHideMode or BoViewFixedHide) then begin
                     if (abs(CX-cret.CX) <= DigupRange) and (abs(CY-cret.CY) <= DigupRange) then begin
                        ComeOut; //������ ������. ���δ�.
                        appeartime := GetTickCount;
                        break;
                     end;
                  end;
               end;
            end;
         end else begin
            if GetTickCount - appeartime > 3 * 1000 then begin
               if AttackTarget then begin
                  inherited Run;
                  exit;
               end else begin  //���� ����
                  if GetTickCount - appeartime > 10 * 1000 then begin
                     ComeDown;
                     appeartime := GetTickCount;
                  end;
               end;
            end;
         end;
      end;
   end;

   inherited Run;
end;


{--------------------------------------------------------------}
//TBigHeartMonster

constructor TBigHeartMonster.Create;
begin
   inherited Create;
   ViewRange := 16;
   BoAnimal := FALSE;
end;

function  TBigHeartMonster.AttackTarget: Boolean;
var
   i, pwr: integer;
   cret: TCreature;
   ev2: TEvent;
begin
   Result := FALSE;
   if GetCurrentTime - HitTime > GetNextHitTime then begin
      HitTime := GetCurrentTime;
      HitMotion (RM_HIT, self.Dir, CX, CY);

      with WAbil do
         pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );

      for i:=0 to VisibleActors.Count-1 do begin
         cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
         if (not cret.Death) and IsProperTarget(cret) then begin
            if (abs(CX-cret.CX) <= ViewRange) and (abs(CY-cret.CY) <= ViewRange) then begin

               //����....
               SendDelayMsg (self, RM_DELAYMAGIC, pwr, MakeLong(cret.CX, cret.CY), 1{range}, integer(cret), '', 200);
               SendRefMsg (RM_NORMALEFFECT, 0, cret.CX, cret.CY, NE_HEARTPALP, '');

               //ev2 := TEvent (PEnvir.GetEvent (cret.CX, cret.CY));    //���� ȿ��, ����
               //if ev2 = nil then begin
               //   ev2 := TPileStones.Create (PEnvir, cret.CX, cret.CY, ET_HEARTPALP, 3 * 60 * 1000, TRUE);
               //   EventMan.AddEvent (ev2);
               //end;


            end;
         end;
      end;

      Result := TRUE;
   end;
end;

procedure TBigHeartMonster.Run;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
     if IsMoveAble then begin
      if VisibleActors.Count > 0 then
         AttackTarget;
   end;
   inherited Run;
end;


{--------------------------------------------------------------}
//�㳪��


constructor TBamTreeMonster.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   StruckCount := 0;
   DeathStruckCount := 0;  //HP;;;
end;

procedure TBamTreeMonster.Struck (hiter: TCreature);
begin
   inherited Struck (hiter);
   Inc (StruckCount);
end;

procedure TBamTreeMonster.Run;
begin
   if DeathStruckCount = 0 then
      DeathStruckCount := WAbil.MaxHP;
   WAbil.HP := WAbil.MaxHP;

   if StruckCount >= DeathStruckCount then
      WAbil.HP := 0;

   inherited Run;
end;



{--------------------------------------------------------------}
//���͹ڽ�
constructor TMonsterBox.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   StruckCount := 0;
   DeathStruckCount := 0;  //HP;;;
end;

procedure TMonsterBox.Die;
var
   monname: string;
   mon: TCreature;
begin
   inherited Die;
   if (Random(100) mod 10) = 1 then begin
      //����ų �����̸�
      monname := '�罿';
      mon := UserEngine.AddCreatureSysop (PEnvir.MapName, CX, CY, monname);
   end;
end;


{--------------------------------------------------------------}
//���ȰŹ�,  �Ź���


constructor TSpiderHouseMonster.Create;
begin
   inherited Create;
   ViewRange := 9;
   RunNextTick := 250;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   StickMode := TRUE;
   childlist := TList.Create;
end;

destructor TSpiderHouseMonster.Destroy;
begin
   childlist.Free;
   inherited Destroy;
end;

procedure TSpiderHouseMonster.MakeChildSpider;
begin
   if childlist.Count < 15 then begin
      SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');
      SendDelayMsg (self, RM_ZEN_BEE, 0, 0, 0, 0, '', 500);
   end;
end;

procedure TSpiderHouseMonster.RunMsg (msg: TMessageInfo);
var
   nx, ny: integer;
   monname: string;
   mon: TCreature;
begin
   case msg.Ident of
      RM_ZEN_BEE:
         begin
            monname := __Spider;  //����

            //�Ź��� ���⿡ ���� ���� �Ź��� ��ġ�� ����
            nx := CX;
            ny := CY+1;

            if PEnvir.CanWalk (nx, ny, TRUE) then begin
               mon := UserEngine.AddCreatureSysop (PEnvir.MapName, nx, ny, monname);
               if mon <> nil then begin
                  mon.SelectTarget (TargetCret);
                  childlist.Add (mon);
               end;
            end;
         end;
   end;
   inherited RunMsg (msg);
end;

procedure TSpiderHouseMonster.Run;
var
   i: integer;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
     if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         WalkTime := GetCurrentTime;
         if GetCurrentTime - HitTime > GetNextHitTime then begin //��ӹ��� run ���� HitTime �缳����.
            HitTime := GetTickCount;
            MonsterNormalAttack;

            if TargetCret <> nil then
               MakeChildSpider;

         end;

         for i:=childlist.Count-1 downto 0 do begin
            if (TCreature(childlist[i]).Death) or (TCreature(childlist[i]).BoGhost) then begin
               childlist.Delete(i);
            end;
         end;
      end;
   end;

   inherited Run;
end;



{--------------------------------------------------------------}
//����,  ���� �Ź�

constructor TExplosionSpider.Create;
begin
   inherited Create;
   ViewRange := 5;
   RunNextTick := 250;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := 0; //GetTickCount;
   maketime := GetTickCount;
end;

procedure TExplosionSpider.DoSelfExplosion;
var
   i, pwr, dam: integer;
   cret: TCreature;
begin
   WAbil.HP := 0;  //����
   //������ �������� �ش�.

   with WAbil do
      pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );

   for i:=0 to VisibleActors.Count-1 do begin
      cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
      if (abs(cret.CX-CX) <= 1) and (abs(cret.CY-CY) <= 1) then begin
         if (not cret.Death) and (IsProperTarget(cret)) then begin
            dam := 0;
            dam := dam + cret.GetHitStruckDamage (self, pwr div 2);
            dam := dam + cret.GetMagStruckDamage (self, pwr div 2);
            if dam > 0 then begin
               cret.StruckDamage (dam, self);
               cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                        cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 700);
            end;
         end;
      end;
   end;
end;

function  TExplosionSpider.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if TargetInAttackRange (TargetCret, targdir) then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            TargetFocusTime := GetTickCount;
            //����....
            DoSelfExplosion;
         end;
         Result := TRUE;
      end else begin
         if TargetCret.MapName = self.MapName then
            SetTargetXY (TargetCret.CX, TargetCret.CY)
         else
            LoseTarget;  //<!!����> TargetCret := nil�� �ٲ�
      end;
   end;
end;

procedure TExplosionSpider.Run;
begin
   if (not Death) and (not BoGhost) then begin
      if GetTickCount - maketime > 1 * 60 * 1000 then begin  //����
         maketime := GetTickCount;
         DoSelfExplosion;
      end;
   end;
   inherited Run;
end;


{--------------------------------------------------------------}
// TGuardUnit

procedure TGuardUnit.Struck (hiter: TCreature);
begin
   inherited Struck (hiter);
   if Castle <> nil then begin
      hiter.BoCrimeforCastle := TRUE;
      hiter.CrimeforCastleTime := GetTickCount;
   end;
end;

function  TGuardUnit.IsProperTarget (target: TCreature): Boolean;
begin
   Result := FALSE;
   if Castle <> nil then begin
      if LastHiter = target then Result := TRUE;

      if target.BoCrimeforCastle then begin
         if GetTickCount - target.CrimeforCastleTime < 2 * 60 * 1000 then begin //5��
            Result := TRUE;
         end else
            target.BoCrimeforCastle := FALSE;
         if TCreature(target).Castle <> nil then begin
            target.BoCrimeforCastle := FALSE;
            Result := FALSE;
         end;
      end;

      //�⺻ ���� ��� (���������� ���� �����ϴ� ���)
      if TUserCastle(Castle).BoCastleUnderAttack then begin
         Result := TRUE;
      end;

      if TUserCastle(Castle).OwnerGuild <> nil then begin
         if target.Master = nil then begin
            if ((TUserCastle(Castle).OwnerGuild = target.MyGuild) or
               TUserCastle(Castle).OwnerGuild.IsAllyGuild (TGuild(target.MyGuild))) and
               (LastHiter <> target)
            then
               Result := FALSE;
         end else begin
            if ((TUserCastle(Castle).OwnerGuild = target.Master.MyGuild) or
               TUserCastle(Castle).OwnerGuild.IsAllyGuild (TGuild(target.Master.MyGuild))) and
               (LastHiter <> target.Master) and
               (LastHiter <> target)
            then
               Result := FALSE;
         end;
      end;
      
      if target.BoSysopMode or
         target.BoStoneMode or
         (target.RaceServer >= RC_NPC) and (target.RaceServer < RC_ANIMAL) or
         (target = self) or
         (TCreature(target).Castle = self.Castle)
      then  //���, ����,...
          Result := FALSE;

   end else begin
      ///Result := inherited IsProperTarget (target);

      //�ڽ��� ������
      if LastHiter = target then Result := TRUE;

      //���� �ú��� �����ϴ� ���� ����
      if target.TargetCret <> nil then
         if target.TargetCret.RaceServer = RC_ARCHERGUARD then
            Result := TRUE;

      if target.PKLevel >= 2 then begin  //�ü��� �����̸� �����Ѵ�.
         Result := TRUE;
      end;

      if target.BoSysopMode or target.BoStoneMode or (target = self) then  //���, ����,...
          Result := FALSE;
   end;
end;



{--------------------------------------------------------------}
// TArcherGuard

constructor TArcherGuard.Create;
begin
   inherited Create;
   ViewRange := 12;
   WantRefMsg := TRUE;
   Castle := nil;
   OriginDir := -1;
   RaceServer := RC_ARCHERGUARD;
end;

//�ݵ�� target <> nil
procedure TArcherGuard.ShotArrow (targ: TCreature);
var
   dam, armor: integer;
begin
   if targ = nil then exit;

   Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
   with WAbil do
      dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
   if dam > 0 then begin
      //armor := (Lobyte(targ.WAbil.AC) + Random(ShortInt(Hibyte(targ.WAbil.AC)-Lobyte(targ.WAbil.AC)) + 1));
      //dam := dam - armor;
      //if dam <= 0 then
      //   if dam > -10 then dam := 1;
      dam := targ.GetHitStruckDamage (self, dam);
   end;
   if dam > 0 then begin
      targ.SetLastHiter (self);
      targ.ExpHiter := nil; //����ġ��
      targ.StruckDamage (dam, self);
      targ.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
               targ.WAbil.HP{lparam1}, targ.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 600 + _MAX(Abs(CX-targ.CX),Abs(CY-targ.CY)) * 50);
   end;
   SendRefMsg (RM_FLYAXE, Dir, CX, CY, Integer(targ), '');
end;

procedure TArcherGuard.Run;
var
   i, d, dis: integer;
   cret, nearcret: TCreature;
begin
   dis := 9999;
   nearcret := nil;
//   if not Death and not BoGhost and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
     if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         WalkTime := GetCurrentTime;
         for i:=0 to VisibleActors.Count-1 do begin
            cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
            if (not cret.Death) and (IsProperTarget(cret)) then begin
               d := abs(CX-cret.CX) + abs(CY-cret.CY);
               if d < dis then begin
                  dis := d;
                  nearcret := cret;
               end;
            end;
         end;
         if nearcret <> nil then begin
            SelectTarget (nearcret);
         end else begin
            LoseTarget;
         end;
      end;
      if TargetCret <> nil then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            ShotArrow (TargetCret);
         end;
      end else begin
         if OriginDir >= 0 then
            if OriginDir <> Dir then
               Turn (OriginDir);
      end;
   end;
   inherited Run;

end;


{--------------------------------------------------------------}
// TArcherMaster

constructor TArcherMaster.Create;
begin
   inherited Create;
   ViewRange := 12;
end;

//�ݵ�� target <> nil
procedure TArcherMaster.ShotArrow (targ: TCreature);
var
   dam, armor: integer;
begin
   if targ = nil then exit;

   //�þ� ���� �� Ÿ�ٸ� ����
   if not ( (abs(CX-targ.CX) <= ViewRange) and (abs(CY-targ.CY) <= ViewRange) ) then exit;

   if (not targ.Death) and IsProperTarget(targ) then begin
      Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
      //Ÿ�� ������ ���� ������ ����
      if (MultiplyTargetLevelMin > 0) and (MultiplyTargetLevelMin > 0) then begin
         with WAbil do
            dam := Trunc(targ.Abil.Level * MultiplyTargetLevelMin div 100) + Lobyte(DC) + Random((Trunc(targ.Abil.Level * MultiplyTargetLevelMax div 100) + Hibyte(DC)-Lobyte(DC)) + 1);
      end else begin
         with WAbil do
            dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
      end;
      if dam > 0 then begin
         //armor := (Lobyte(targ.WAbil.AC) + Random(ShortInt(Hibyte(targ.WAbil.AC)-Lobyte(targ.WAbil.AC)) + 1));
         //dam := dam - armor;
         //if dam <= 0 then
         //   if dam > -10 then dam := 1;
         dam := targ.GetHitStruckDamage (self, dam);
      end;
      if dam > 0 then begin
         targ.SetLastHiter (self);
         targ.ExpHiter := nil; //����ġ��
         targ.StruckDamage (dam, self);
         targ.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                  targ.WAbil.HP{lparam1}, targ.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 600 + _MAX(Abs(CX-targ.CX),Abs(CY-targ.CY)) * 50);
      end;
      SendRefMsg (RM_FLYAXE, Dir, CX, CY, Integer(targ), '');
   end;
end;

function  TArcherMaster.AttackTarget: Boolean;
var
   i, pwr: integer;
   cret: TCreature;
   targdir: byte;
begin
   Result := FALSE;
   if GetCurrentTime - HitTime > GetNextHitTime then begin
      HitTime := GetCurrentTime;
      ShotArrow(TargetCret);
   end;
   Result := TRUE;
end;

procedure TArcherMaster.Run;
var
   i, dis, d: integer;
   cret, nearcret: TCreature;
   nx, ny: integer;
begin
   dis := 9999;
   nearcret := nil;
   if not RunDone and IsMoveAble then begin
      if GetTickCount - SearchEnemyTime > 5000 then begin
         SearchEnemyTime := GetTickCount;
         //��ӹ��� run ���� HitTime �缳����.
         for i:=0 to VisibleActors.Count-1 do begin
            cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
            if (not cret.Death) and (IsProperTarget(cret)) and (not cret.BoHumHideMode or BoViewFixedHide) then begin
               d := abs(CX-cret.CX) + abs(CY-cret.CY);
               if d < dis then begin
                  dis := d;
                  nearcret := cret;
               end;
            end;
         end;
         if nearcret <> nil then
            SelectTarget (nearcret);
      end;

      AttackTarget;

      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         //��ӹ��� run���� WalkTime �缳����
         if TargetCret <> nil then
            if (abs(CX-TargetCret.CX) <= 4) and (abs(CY-TargetCret.CY) <= 4) then begin
               if (abs(CX-TargetCret.CX) <= 2) and (abs(CY-TargetCret.CY) <= 2) then begin
                  if Random(3) = 0 then begin
                     //�ʹ� ������ ������.
                     GetBackPosition (self, TargetX, TargetY);
                     if TargetX <> -1 then begin //������ ���� ����
                        GotoTargetXY;
                     end;
                  end;
               end;
            end else if (abs(CX-TargetCret.CX) > 5) or (abs(CY-TargetCret.CY) > 5) then begin
               if Random(2) = 0 then begin
                  Dir := GetNextDirection (CX, CY, TargetCret.CX, TargetCret.CY);
                  //�ʹ� �ָ� ������ ��.
                  if GetNextPosition (PEnvir, CX, CY, Dir, 1, nx, ny) then begin
                     TargetX := nx;
                     TargetY := ny;
                     GotoTargetXY;
                  end;
               end;
            end;
      end;
   end;
   inherited Run;
end;


{--------------------------------------------------------------}
//�ü�����

constructor TArcherPolice.Create;
begin
   inherited Create;
   RaceServer := RC_ARCHERPOLICE;  //��ȭ���� ������ �ȵǰ�
end;


{--------------------------------------------------------------}
//����, ����

constructor TCastleDoor.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   StickMode := TRUE;
   BoOpenState := FALSE; //���� ����
   AntiPoison := 200;
   //HideMode := TRUE;  //���� ��ô� �Ⱥ��̴� �����
end;

procedure TCastleDoor.Initialize;
begin
   Dir := 0;  //�ʱ����
   inherited Initialize;
   if WAbil.HP > 0 then begin
      if BoOpenState then ActiveDoorWall (dsOpen)
      else ActiveDoorWall (dsClose);
   end else
      ActiveDoorWall (dsBroken);
end;

//���� ������
procedure TCastleDoor.RepairStructure;
var
   n, newdir: integer;
begin
   if not BoOpenState then begin
      newdir := 3 - Round (WAbil.HP / WAbil.MaxHP * 3);
      if not (newdir in [0..2]) then newdir := 0;
      Dir := newdir;
      SendRefMsg (RM_ALIVE, Dir, CX, CY, 0, '');
   end;
end;

//��ϼ����� ��쿡�� ���
procedure TCastleDoor.ActiveDoorWall (dstate: TDoorState);
var
   bomove: Boolean;
begin
   PEnvir.GetMarkMovement (CX, CY-2, TRUE);
   PEnvir.GetMarkMovement (CX+1, CY-1, TRUE);
   PEnvir.GetMarkMovement (CX+1, CY-2, TRUE);
   if dstate = dsClose then bomove := FALSE
   else bomove := TRUE;

   PEnvir.GetMarkMovement (CX, CY, bomove);
   PEnvir.GetMarkMovement (CX, CY-1, bomove);
   PEnvir.GetMarkMovement (CX, CY-2, bomove);
   PEnvir.GetMarkMovement (CX+1, CY-1, bomove);
   PEnvir.GetMarkMovement (CX+1, CY-2, bomove);
   PEnvir.GetMarkMovement (CX-1, CY, bomove);
   PEnvir.GetMarkMovement (CX-2, CY, bomove);
   PEnvir.GetMarkMovement (CX-1, CY-1, bomove);
   PEnvir.GetMarkMovement (CX-1, CY+1, bomove);
   if dstate = dsOpen then begin
      PEnvir.GetMarkMovement (CX, CY-2, FALSE);
      PEnvir.GetMarkMovement (CX+1, CY-1, FALSE);
      PEnvir.GetMarkMovement (CX+1, CY-2, FALSE);
   end;
end;

procedure TCastleDoor.OpenDoor;
begin
   if not Death then begin
      Dir := 7; //�Ⱥ��̴� ����
      SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
      BoOpenState := TRUE;
      BoStoneMode := TRUE;  //���� ����
      ActiveDoorWall (dsOpen);  //�̵������ϰ�
      HoldPlace := FALSE;  //�ڸ����� ����
   end;
end;

procedure TCastleDoor.CloseDoor;
begin
   if not Death then begin
      Dir := 3 - Round (WAbil.HP / WAbil.MaxHP * 3);
      if not (Dir in [0..2]) then Dir := 0;
      SendRefMsg (RM_DIGDOWN, {Dir}0, CX, CY, 0, '');
      BoOpenState := FALSE;
      BoStoneMode := FALSE;  //����
      ActiveDoorWall (dsClose);  //�̵� ���ϰ�
      HoldPlace := TRUE;  //�ڸ����� ��
   end;
end;

procedure TCastleDoor.Die;
begin
   inherited Die;
   BrokenTime := GetTickCount;
   ActiveDoorWall (dsBroken);  //�̵������ϰ�
end;

procedure TCastleDoor.Run;
var
   n, newdir: integer;
begin
   if Death and (Castle <> nil) then begin
      DeathTime := GetTickCount;  //�������� �ʴ´�.
   end else
      HealthTick := 0;  //ü���� �ٽ� ���� �ʴ´�.

   if not BoOpenState then begin
      newdir := 3 - Round (WAbil.HP / WAbil.MaxHP * 3);
      if (newdir <> Dir) and (newdir < 3) then begin  //���� 0,1,2
         Dir := newdir;
         SendRefMsg (RM_TURN, Dir, CX, CY, 0, '');
      end;
   end;

   inherited Run;
end;



//---------------------------------------------------------------------
//����,

constructor TWallStructure.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   StickMode := TRUE;
   BoBlockPos := FALSE;
   AntiPoison := 200;
   //HideMode := TRUE;
end;

procedure TWallStructure.Initialize;
begin
   Dir := 0;  //�ʱ����
   inherited Initialize;
end;

//���� ������
procedure TWallStructure.RepairStructure;
var
   n, newdir: integer;
begin
   if WAbil.HP > 0 then newdir := 3 - Round (WAbil.HP / WAbil.MaxHP * 3)
   else newdir := 4;
   if not (newdir in [0..4]) then newdir := 0;
   Dir := newdir;
   SendRefMsg (RM_ALIVE, Dir, CX, CY, 0, '');
end;

procedure TWallStructure.Die;
begin
   inherited Die;
   BrokenTime := GetTickCount;
end;

procedure TWallStructure.Run;
var
   n, newdir: integer;
begin
   if Death then begin
      DeathTime := GetTickCount;  //�������� �ʴ´�.
      if BoBlockPos then begin
         PEnvir.GetMarkMovement (CX, CY, TRUE);  //�̵� �����ϰ�
         BoBlockPos := FALSE;
      end;
   end else begin
      HealthTick := 0;  //ü���� �ٽ� ���� �ʴ´�.
      if not BoBlockPos then begin
         PEnvir.GetMarkMovement (CX, CY, FALSE);  //�̵� ���ϰ�
         BoBlockPos := TRUE;
      end;
   end;

   if WAbil.HP > 0 then newdir := 3 - Round (WAbil.HP / WAbil.MaxHP * 3)
   else newdir := 4;
   if (newdir <> Dir) and (newdir < 5) then begin  //���� 0,1,2,3,4
      Dir := newdir;
      SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');  //�μ����� �ִϸ��̼�
   end;

   inherited Run;
end;


//---------------------------------------------------------------------
// �౸��

constructor TSoccerBall.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   NeverDie := TRUE;
   GoPower := 0;
   TargetX := -1;
end;

procedure TSoccerBall.Struck (hiter: TCreature);
var
   nx, ny: integer;
begin
   if hiter <> nil then begin
      Dir := hiter.Dir;  //��������� �������� ���� ����.
      GoPower := GoPower + 4 + Random (4);
      GoPower := _MIN (20, GoPower);
      GetNextPosition (PEnvir, CX, CY, Dir, GoPower, nx, ny);
      TargetX := nx;
      TargetY := ny;
   end;

end;


procedure TSoccerBall.Run;
var
   i, dis, nx, ny, nnx, nny: integer;
   bohigh: Boolean;
begin
   bohigh := false; // �౸���� ��ġ�� �ȵ� 
   if GoPower > 0 then begin
      if GetNextPosition (PEnvir, CX, CY, Dir, 1, nx, ny) then begin
         if not PEnvir.CanWalk (nx, ny, bohigh) then begin  //���� �ε���
            case Dir of
               0: Dir := 4;
               1: Dir := 7;
               2: Dir := 6;
               3: Dir := 5;
               4: Dir := 0;
               5: Dir := 3;
               6: Dir := 2;
               7: Dir := 1;
            end;
            GetNextPosition (PEnvir, CX, CY, Dir, GoPower, nx, ny);
            TargetX := nx;
            TargetY := ny;
         end;
      end;
   end else
      TargetX := -1;

   if TargetX <> -1 then begin
      GotoTargetXY;
      if (TargetX = CX) and (TargetY = CY) then
         GoPower := 0;
   end;

   inherited Run;

end;

{--------------------------------------------------------------}
//ȣȥ��

constructor TStickBlockMonster.Create;
begin
   inherited Create;
   ViewRange := 7;
   DigupRange := 4;
   DigdownRange := 4;
   BoCallFollower := TRUE;
   BoTransparent := FALSE;
   FirstComeOut := TRUE;
   SecondMovement := FALSE;
   DontAttack := TRUE;
   childlist := TList.Create;
   RaceServer := RC_STICKBLOCK;
   FirstStruck := FALSE;
   ComeoutTime := 0;
   TargetDisappearTime := 0;
   Caller := nil;
   OldTargetCret := nil;
   BoAnimal := FALSE;  //�丮�� �ʵ���...
end;

destructor TStickBlockMonster.Destroy;
begin
   childlist.Free;
   inherited Destroy;
end;

function  TStickBlockMonster.FindTarget: Boolean;
var
   i: integer;
   cret: TCreature;
begin
   Result := FALSE;
   for i:=0 to VisibleActors.Count-1 do begin
      cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
      if (not cret.Death) and IsProperTarget(cret) then begin
         if (abs(CX-cret.CX) <= ViewRange) and (abs(CY-cret.CY) <= ViewRange) then begin
            if cret.RaceServer = RC_USERHUMAN then begin
               //Ÿ�� ����
               TargetCret := cret;
               OldTargetCret := TargetCret;

               Result := TRUE;
               break;
            end;
         end;
      end;
   end;
end;

procedure TStickBlockMonster.Attack (target: TCreature; dir: byte);
var
   i, k,  mx, my, dam, armor: integer;
   wide: integer;
   rlist: TList;
   cret: TCreature;
   pwr: integer;
begin
   if target = nil then exit;

   wide := 0;
   Self.Dir := GetNextDirection (CX, CY, target.CX, target.CY);
   SendRefMsg (RM_HIT, self.Dir, CX, CY, Integer(target), '');
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   if pwr <= 0 then exit;

   rlist := TList.Create;
   GetMapCreatures (PEnvir, target.CX, target.CY, wide, rlist);
   for i:=0 to rlist.Count-1 do begin
      cret := TCreature (rlist[i]);
      if IsProperTarget(cret) then begin
         SelectTarget (cret);
         cret.SendRefMsg (RM_NORMALEFFECT, 0, cret.CX, cret.CY, NE_SOULSTONE_HIT, '');
         cret.SendDelayMsg (self, RM_MAGSTRUCK, 0, pwr, 0, 0, '', 600);
      end;
   end;
   rlist.Free;

end;

function  TStickBlockMonster.AttackTarget: Boolean;
var
   i, pwr: integer;
   cret: TCreature;
   targdir: byte;
begin
   Result := FALSE;
   if DontAttack then exit;

   if FindTarget then begin
      //ó�� Ÿ���� �ٲ��� ����.
      if OldTargetCret <> TargetCret then TargetCret := OldTargetCret;

      if TargetCret <> nil then begin
         if TargetInAttackRange (TargetCret, targdir) then begin
            if GetCurrentTime - HitTime > GetNextHitTime then begin
               HitTime := GetCurrentTime;

               if Random(8) = 0 then begin
                  TargetCret.MakePoison (POISON_STONE, 5{�ð�,��}, 0);
               end else begin
                  Attack(TargetCret, targdir);
               end;
               Result := TRUE;
            end;
         end;
      end;
   end;
end;

procedure TStickBlockMonster.ComeOut;
begin
   inherited ComeOut;
   if BoCallFollower then begin
      if FindTarget then begin
         if TargetCret <> nil then begin
            if FirstComeOut then begin
               FirstComeOut := FALSE;
               SecondMovement := TRUE;
               TargetCret.MakePoison (POISON_STONE, 5{�ð�,��}, 0);
            end;
         end;
      end;
   end;
end;

procedure TStickBlockMonster.ComeDown;
begin
   //ó�� ����.
end;

procedure TStickBlockMonster.CallFollower;
const
   MAX_FOLLOWERS = 2;
var
   i, nx, ny, dx, dy: integer;
   monname: string;
   mon: TCreature;
   followers: array[0..MAX_FOLLOWERS-1] of string;
begin
   if TargetCret <> nil then begin
      nx := TargetCret.CX;
      ny := TargetCret.CY;

      //����ų �����̸�
      followers[0] := UserName;
      followers[1] := '11';//'ȣȥ��00';   //�̹��� �Ⱥ���

      for dx:=-1 to 1 do begin
         for dy:=-1 to 1 do begin
            if ((nx + dx = CX) and (ny + dy = CY)) or ((nx + dx = TargetCret.CX) and (ny + dy = TargetCret.CY)) then continue;

            //�밢��
            if abs(dx) = abs(dy) then begin
               monname := followers[1];
            end else begin
               monname := followers[0];
            end;
            if PEnvir.CanWalk( nx + dx, ny + dy, FALSE ) then begin
               mon := UserEngine.AddCreatureSysop (MapName, nx + dx, ny + dy, monname);
               if mon <> nil then begin
                  // ���� ������ �����̸�
                  if mon.RaceServer = RC_STICKBLOCK then begin
                     TStickBlockMonster(mon).BoCallFollower := FALSE;
                     //������� ����
                     if mon.UserName = followers[1] then begin
                        TStickBlockMonster(mon).BoTransparent := TRUE;
                     end;
                     TStickBlockMonster(mon).ComeOut;
                     TStickBlockMonster(mon).Caller := self;
                     childlist.Add (mon);
                  end;
               end;
            end;
         end;
      end;
      self.ComeOut;
   end;
end;

procedure TStickBlockMonster.Die;
var
   i: integer;
begin
   inherited Die;
   if BoCallFollower then begin
      for i:=childlist.Count-1 downto 0 do begin
         if not TCreature(childlist[i]).Death then begin
            TCreature(childlist[i]).LastHiter := nil;
            TCreature(childlist[i]).ExpHiter := nil;
            TCreature(childlist[i]).BoNoitem := TRUE; //���� ȣȥ���� �������� �ȶ�����(sonmg 2005/10/21)
            TCreature(childlist[i]).Die;
         end;
      end;
   end;
end;

procedure TStickBlockMonster.RunMsg (msg: TMessageInfo);
var
   nx, ny: integer;
   monname: string;
   mon: TCreature;
   i: integer;
   check: Boolean;
   hiter : TCreature;
begin
   hiter := nil;
   case msg.Ident of
      RM_REFMESSAGE:
         begin
            if Integer(msg.Sender) = RM_STRUCK then begin
               check := FALSE;

               hiter := TCreature(msg.lParam3);

               if (hiter <> nil) and (hiter.RaceServer = RC_USERHUMAN) then begin
                  //���� ���� �¾��� �� follower�� �߿� ���� ���� ���� ������ �ٷ� ����
                  if BoCallFollower then begin
                     for i:=0 to childlist.count-1 do begin
                        if TStickBlockMonster(childlist[i]).FirstStruck then begin
                           check := TRUE;
                        end;
                     end;
                     if (not check) and (DontAttack) then begin
                        if not Death then begin
                           FirstStruck := TRUE;
                           Die;
{$IFDEF DEBUG}
//UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' ����! : ' + TargetCret.UserName);//test
{$ENDIF}
                        end;
                     end;
                     DontAttack := FALSE;
                  end else begin
                     WAbil.HP := WAbil.MaxHP;
                     if not BoTransparent then begin
                        //follower�� �¾��� �� ���� ���� ���� ���� �ʾ����� FirstStruck TRUE�� ����
                        //(��ȥ������ �������°�?)
                        if (Caller <> nil) and (Caller.RaceServer = RC_STICKBLOCK) and not TStickBlockMonster(Caller).FirstStruck then begin
                           FirstStruck := TRUE;
                           //���� �� ���� ����
                           TStickBlockMonster(Caller).DontAttack := FALSE;
                        end;
                     end;
                  end;
               end;
            end;
         end;
      RM_MAGSTRUCK:
         begin
            if BoCallFollower then begin
               DontAttack := FALSE;
            end else begin
               WAbil.HP := WAbil.MaxHP;
               exit;
            end;
         end;
   end;
   inherited RunMsg (msg);
end;

procedure TStickBlockMonster.Struck (hiter: TCreature);
begin
{
   if not BoCallFollower then begin
      WAbil.HP := WAbil.MaxHP;
      exit;
   end else begin
      DontAttack := FALSE;
   end;
}

   inherited Struck(hiter);
end;

procedure TStickBlockMonster.Run;
var
   i, dis, d, nx, ny: integer;
   cret, nearcret: TCreature;
   targdir: byte;
begin
   //ó�� Ÿ���� �ٲ��� ����.
   if OldTargetCret <> TargetCret then TargetCret := OldTargetCret;

   if GetCurrentTime - WalkTime > GetNextWalkTime then begin
      if BoCallFollower and (not Death) then begin
         if (Caller <> nil) and (Caller.RaceServer = RC_STICKBLOCK) and not TStickBlockMonster(Caller).DontAttack then begin
            DontAttack := FALSE;
         end;
         if TargetCret <> nil then begin
            if (not FirstComeOut) and SecondMovement then begin
               SecondMovement := FALSE;
               case Random(4) of
               0: begin
                     nx := 0;
                     ny := -1;
                  end;
               1: begin
                     nx := 0;
                     ny := 1;
                  end;
               2: begin
                     nx := -1;
                     ny := 0;
                  end;
               else
                  begin
                     nx := 1;
                     ny := 0;
                  end;
               end;
               SpaceMove ( MapName, TargetCret.CX + nx, TargetCret.CY + ny, 2);
               CallFollower;  //���ϵ��� �ҷ���
               ComeoutTime := GetTickCount;
            end;

            //�ð��� �帣��
            if (ComeoutTime <> 0) and (GetTickCount - ComeoutTime > 10000) then begin
               //���� �� ���� ����
               if DontAttack then
                  DontAttack := FALSE;
            end;
         end;

         if DontAttack = FALSE then begin
            if TargetCret <> nil then begin
               if not TargetInAttackRange (TargetCret, targdir) then begin
                  if (TargetDisappearTime = 0) then begin
                     if (ComeoutTime <> 0) and (GetTickCount - ComeoutTime > 15000) then begin
                        TargetDisappearTime := GetTickCount;
                     end;
                  end;
               end;
            end else begin
               if (TargetDisappearTime = 0) then begin
                  if (ComeoutTime <> 0) and (GetTickCount - ComeoutTime > 15000) then begin
                     TargetDisappearTime := GetTickCount;
                  end;
               end;
            end;

            if (TargetDisappearTime <> 0) and (GetTickCount - TargetDisappearTime > 10000) then begin
               if not Death then begin
                  FirstStruck := TRUE;
                  Die;
               end;
            end;
         end;
      end;
   end;

   inherited Run;
end;


end.
