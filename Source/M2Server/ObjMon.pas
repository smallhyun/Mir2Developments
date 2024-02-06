unit ObjMon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, Grobal2, Envir, EdCode, ObjBase,
  Event;


type
   TMonster = class (TAnimal)
   private
      thinktime: longword;
   protected
      RunDone: Boolean;
      DupMode: Boolean;
      function  AttackTarget: Boolean; dynamic;
   public
      constructor Create;
      destructor Destroy; override;
      function  MakeClone (mname: string; src: TCreature): TCreature;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
      function  Think: Boolean;
      procedure RecalcAbilitys; override;
   end;

   TChickenDeer = class (TMonster)
   public
      constructor Create;
      procedure Run; override;
   end;


   TATMonster = class (TMonster)
   private
   protected
   public
      constructor Create;
      destructor Destroy; override;
      procedure Run; override;
   end;

   TSlowATMonster = class (TATMonster)
   public
      constructor Create;
   end;

   TScorpion = class (TATMonster)
   private
   public
      constructor Create;
   end;

   TSpitSpider = class (TATMonster)
   private
   public
      BoUsePoison: Boolean;
      constructor Create;
      procedure  SpitAttack (dir: byte);
      function  AttackTarget: Boolean; override;
   end;

   THighRiskSpider = class (TSpitSpider)
   public
      constructor Create;
   end;

   TBigPoisionSpider = class (TSpitSpider)
   public
      constructor Create;
   end;

   TGasAttackMonster = class (TATMonster)
   private
   public
      constructor Create;
      function  GasAttack (dir: byte): TCreature; dynamic;
      function  AttackTarget: Boolean; override;
   end;

   TCowMonster = class (TATMonster)
   public
      constructor Create;
   end;

   TMagCowMonster = class (TATMonster)
   private
   public
      constructor Create;
      procedure MagicAttack (dir: byte);
      function  AttackTarget: Boolean; override;
   end;

   TCowKingMonster = class (TAtMonster)
   private
      JumpTime: longword;  //¼ø°£ÀÌµ¿À» ÇÑ´Ù.
      CrazyReadyMode: Boolean;
      CrazyKingMode: Boolean;
      CrazyCount: integer;
      crazyready: longword;
      crazytime: longword;
      oldhittime: integer;
      oldwalktime: integer;
   public
      constructor Create;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure Initialize; override;
      procedure Run; override;
   end;

   TLightingZombi = class (TMonster) //µµ¸Á°¡Áö ¾Ê°í °ø°ÝÇÔ,
   private
   public
      constructor Create;
      procedure LightingAttack (dir: integer);
      procedure Run; override;
   end;


   TDigOutZombi = class (TMonster)
   protected
      procedure ComeOut;
   public
      constructor Create;
      procedure Run; override;
   end;

   TZilKinZombi = class (TATMonster)
   private
      deathstart: longword;
      LifeCount: integer; //³²Àº Àç»ý
      RelifeTime: longword;
   public
      constructor Create;
      procedure Run; override;
      procedure Die; override;
   end;

   TWhiteSkeleton = class (TATMonster)
   private
      bofirst: Boolean;
   public
      constructor Create;
      procedure RecalcAbilitys; override;
      procedure ResetSkeleton;
      procedure Run; override;
   end;



   TScultureMonster = class (TMonster)
   private
   public
      constructor Create;
      procedure MeltStone;
      procedure MeltStoneAll;
      procedure Run; override;
   end;

   TScultureKingMonster = class (TMonster)
   private
      DangerLevel: integer;
      childlist: TList;  //¸¸µé¾î ³½ ºÎÇÏÀÇ ¸®½ºÆ®
   public
      BoCallFollower: Boolean;
      constructor Create;
      destructor Destroy; override;
      procedure CallFollower; dynamic;
      procedure MeltStone;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure Run; override;
   end;

   TGasMothMonster = class (TGasAttackMonster)
   public
      constructor Create;
      procedure Run; override;
      function  GasAttack (dir: byte): TCreature; override;
   end;

   TGasDungMonster = class (TGasAttackMonster)
   public
      constructor Create;
   end;

   TElfMonster = class (TMonster)
   private
      bofirst: Boolean;
   public
      constructor Create;
      procedure RecalcAbilitys; override;
      procedure ResetElfMon;
      procedure AppearNow;
      procedure Run; override;
   end;

   TElfWarriorMonster = class (TSpitSpider)
   private
      bofirst: Boolean;
      FirstHp:Word;       //ÉñÊÞÅ¿ÏÂÈ¥µ±Ç°HPÎ´»Ö¸´
      changefacetime: longword;
   public
      constructor Create;
      procedure RecalcAbilitys; override;
      procedure ResetElfMon;
      procedure AppearNow;
      procedure Run; override;
   end;

   TCriticalMonster = class (TATMonster)   ///°­·ÂÇÑ Å©¸®Æ¼ÄÃÀ» °¡ÇÏ´Â ¸ó½ºÅÍ
   public
      criticalpoint: integer;
      constructor Create;
      procedure Attack (target: TCreature; dir: byte); override;
   end;

   TDoubleCriticalMonster = class (TATMonster)   ///°­·ÂÇÑ µÎÄ­ Å©¸®Æ¼ÄÃÀ» °¡ÇÏ´Â ¸ó½ºÅÍ
   public
      criticalpoint: integer;
      constructor Create;
      procedure DoubleCriticalAttack (dam: integer; dir: byte);
      procedure Attack (target: TCreature; dir: byte); override;
   end;

   // 2003/02/11 ÇØ°ñ¹Ý¿Õ, ÇØ°ñº´Á¹ (¿ø°Å¸® Á÷Á¢°ø°Ý)
   TSkeletonKingMonster = class (TScultureKingMonster)
   public
      RunDone: Boolean;
      ChainShot: integer;
      ChainShotCount: integer;
      constructor Create;
      procedure CallFollower; override;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure Run; override;
      procedure RangeAttack (targ: TCreature); dynamic;
      function  AttackTarget: Boolean; override;
   end;
   // 2003/02/11 ÇØ°ñº´Á¹ (¿ø°Å¸® Á÷Á¢°ø°Ý)
   TSkeletonSoldier = class (TATMonster)
   private
   public
      constructor Create;
      procedure RangeAttack (dir: byte);
      function  AttackTarget: Boolean; override;
   end;

   // 2003/03/04 »ç¿ìÃµ¿Õ (±Ù°Å¸® Á÷Á¢°ø°Ý, ¿ø°Å¸® ¸¶¹ý°ø°Ý, ½ºÇÃ·¹½¬ µ¥¹ÌÁö)
   TDeadCowKingMonster = class (TSkeletonKingMonster)
   public
      constructor Create;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure RangeAttack (targ: TCreature); override;
      function  AttackTarget: Boolean; override;
   end;
   // 2003/03/04 ¹Ý¾ßÁÂ/¿ì»ç (±Ù°Å¸® ¸¶¹ý°ø°Ý, ¿ø°Å¸® ¸¶¹ý°ø°Ý)
   TBanyaGuardMonster = class (TSkeletonKingMonster)
   public
      constructor Create;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure RangeAttack (targ: TCreature); override;
      function  AttackTarget: Boolean; override;
   end;

   // 2003/07/15 °ú°ÅºñÃµ ¸¶°è¼®
   TStoneMonster = class (TMonster)
   public
      constructor Create;
      procedure Run; override;
   end;

   TPBKingMonster = class (TDeadCowKingMonster)
   public
      constructor Create;
      procedure Attack (target: TCreature; dir: byte); override;
      procedure RangeAttack (targ: TCreature); override;
      function  AttackTarget: Boolean; override;
      procedure Run; override;
   end;

   TGoldenImugi = class (TATMonster)
   public
      DontAttack: Boolean;
      DontAttackCheck: Boolean;
      AttackState: Boolean;
      InitialState: Boolean;
      ChildMobRecalled: Boolean;
      FinalWarp: Boolean;
      FirstCheck: Boolean;
      TwinGenDelay: integer;
      sectick: longword;
      RevivalTime: longword;
      WarpTime: longword;
      TargetTime: longword;
      RangeAttackTime: longword;
      OldTargetCret: TCreature;
      constructor Create;
      procedure Attack (targ: TCreature; dir: byte); override;
      procedure RangeAttack (targ: TCreature);
      procedure RangeAttack2 (targ: TCreature);
      function  AttackTarget: Boolean; override;
      procedure Struck (hiter: TCreature); override;
      procedure RunMsg (msg: TMessageInfo); override;
      procedure Run; override;
      procedure Die; override;
   end;

   TPhisicalFarAttackMonster = class (TSkeletonKingMonster)
   public
      constructor Create;
      procedure RangeAttack (targ: TCreature); override;
      function  AttackTarget: Boolean; override;
   end;

implementation

uses
   svMain, M2Share;


constructor TMonster.Create;
begin
   inherited Create;
   DupMode := FALSE;
   RunDone := FALSE;
   thinktime := GetTickCount;
   ViewRange := 5;
   RunNextTick := 250;
   SearchRate := 3000 + longword(Random(2000));
   SearchTime := GetTickCount;
   RaceServer := RC_MONSTER;
end;

destructor TMonster.Destroy;
begin
   inherited Destroy;
end;

function  TMonster.MakeClone (mname: string; src: TCreature): TCreature;
var
   mon: TCreature;
begin
   Result := nil;
   mon := UserEngine.AddCreatureSysop (src.PEnvir.MapName, src.CX, src.CY, mname);
   if mon <> nil then begin
      mon.Master := src.Master;
      mon.MasterRoyaltyTime := src.MasterRoyaltyTime;
      mon.SlaveMakeLevel := src.SlaveMakeLevel;
      mon.SlaveExpLevel := src.SlaveExpLevel;
      mon.RecalcAbilitys; //ApplySlaveLevelAbilitys;
      mon.ChangeNameColor;
      if src.Master <> nil then begin
         src.Master.SlaveList.Add (mon);
      end;

      //´É·ÂÄ¡, »óÅÂ º¹»ç
      mon.WAbil := src.WAbil;
      Move (src.StatusArr, mon.StatusArr, sizeof(word)*STATUSARR_SIZE);
      Move (src.StatusValue, mon.StatusValue, sizeof(byte)*STATUSARR_SIZE);
      mon.TargetCret := src.TargetCret;
      mon.TargetFocusTime := src.TargetFocusTime;
      mon.LastHiter := src.LastHiter;
      mon.LastHitTime := src.LastHitTime;
      mon.Dir := src.Dir;

      Result := mon;
   end;
end;

procedure TMonster.RunMsg (msg: TMessageInfo);
begin
   //case msg.Ident of
   //   RM_DELAYATTACK:
    //     begin
    //        attack (TCreature(msg.lparam1), msg.wparam);
    //     end;
    //  else
   inherited RunMsg (msg);
   //end;
end;

function  TMonster.Think: Boolean;
var
   oldx, oldy: integer;
begin
   Result := FALSE;
   if GetTickCount - ThinkTime > 3000 then begin
      ThinkTime := GetTickCount;
      if PEnvir.GetDupCount(CX, CY) >= 2 then begin
         DupMode := TRUE;
      end;
      if not IsProperTarget(TargetCret) then
         TargetCret := nil;
   end;

   //ÀÚ¸®°¡ Áßº¹µÈ °æ¿ì ÀÚ¸®¸¦ ÇÇÇÑ´Ù.
   // °íÁ¤¸ó½ºÅÍ´Â ÀÚ¸®¸¦ ¿òÁöÀÌÁö ¾Ê´Â´Ù. not BoDontMove
   if DupMode and (not BoDontMove) then begin
      oldx := self.CX;
      oldy := self.CY;
      WalkTo (Random(8), FALSE);
      if (oldx <> self.CX) or (oldy <> self.CY) then begin
         DupMode := FALSE;
         Result := TRUE;
      end;
   end;

end;

function  TMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if (not TargetCret.Death) and IsProperTarget(TargetCret) then begin
         if TargetInAttackRange (TargetCret, targdir) then begin
            if GetCurrentTime - HitTime > GetNextHitTime then begin
               HitTime := GetCurrentTime;
               TargetFocusTime := GetTickCount;
               Attack (TargetCret, targdir);
               BreakHolySeize;
            end;
            Result := TRUE;
         end else begin
            if TargetCret.MapName = self.MapName then
               SetTargetXY (TargetCret.CX, TargetCret.CY)
            else
               LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
         end;
      end;
   end;
end;

procedure TMonster.Run;
var
   rx, ry, bx, by: integer;
begin
//   if (not BoGhost) and (not Death) and (not HideMode) and (not BoStoneMode) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if not HideMode and not BoStoneMode and IsMoveAble then begin
      if Think then begin //°ãÄ¡Áö ¾Ê°Ô ÇÔ
         inherited Run;
         exit;
      end;
      if BoWalkWaitMode then begin
         if Integer(GetTickCount - WalkWaitCurTime) > WalkWaitTime then
            BoWalkWaitMode := FALSE;
      end;

      if not BoWalkWaitMode and (GetCurrentTime - WalkTime > GetNextWalkTime) then begin
         WalkTime := GetCurrentTime;
         Inc (WalkCurStep);
         if WalkCurStep > WalkStep then begin
            WalkCurStep := 0;
            BoWalkWaitMode := TRUE;
            WalkWaitCurTime := GetTickCount;
         end;

         if not BoRunAwayMode then begin
            if not NoAttackMode then begin
               if TargetCret <> nil then begin
                  if AttackTarget then begin
                     //---------------------(sonmg 2004/12/27)
                     if (Master <> nil) then begin
                        //°ø°ÝÁß¿¡ ÁÖÀÎÀÌ °­Á¦·Î ºÎ¸£¸é
                        if ForceMoveToMaster then begin
                           ForceMoveToMaster := false;
                           GetBackPosition (Master, bx, by);  //ÁÖÀÎÀÇ µÚ·Î °¨
                           TargetX := bx;
                           TargetY := by;
                           SpaceMove (Master.PEnvir.MapName, TargetX, TargetY, 1);
                        end;
                     end;
                     //---------------------
                     inherited Run;
                     exit;
                  end;
               end else begin
                  TargetX := -1;
                  if BoHasMission then begin
                     TargetX := Mission_X;
                     TargetY := Mission_Y;
                  end;
               end;
            end;
            if (Master <> nil) then begin //¼ÒÈ¯¼ö°¡ °ø°Ý ÁßÀÏ ¶§´Â ¿Ö Master¸¦ ÀÎ½ÄÇÒ ¼ö ¾øÀ»±î? AttackTarget´ÙÀ½¿¡ Â÷´ÜµÇ±â ¶§¹®...
               if (TargetCret = nil) or (BoLoseTargetMoment) then begin //ÁÖÀÎÀÌ ÀÖÀ¸¸é ÁÖÀÎÀ» µû¶ó°£´Ù.
                  BoLoseTargetMoment := FALSE;
                  GetBackPosition (Master, bx, by);  //ÁÖÀÎÀÇ µÚ·Î °¨
                  if (abs(TargetX-bx) > 1) or (abs(TargetY-bx) > 1) then begin
                     TargetX := bx;
                     TargetY := by;
                     if (abs(CX-bx) <= 2) and (abs(CY-by) <= 2) then begin
                        if PEnvir.GetCreature (bx, by, TRUE) <> nil then begin
                           TargetX := CX;  //´õ ÀÌ»ó ¿òÁ÷ÀÌÁö ¾Ê´Â´Ù.
                           TargetY := CY;
                        end;
                     end;
                  end;
               end;
               //ÁÖÀÎ°ú ³Ê¹« ¶³¾îÁ® ÀÖÀ¸¸é...
               if ForceMoveToMaster or ( (not Master.BoSlaveRelax) and
                  ((PEnvir <> Master.PEnvir) or
                   (abs(CX-Master.CX) > 20) or
                   (abs(CY-Master.CY) > 20)
                  ))
               then begin
                  ForceMoveToMaster := false;
                  //-------------(sonmg 2004/12/24)
                  GetBackPosition (Master, bx, by);  //ÁÖÀÎÀÇ µÚ·Î °¨
                  TargetX := bx;
                  TargetY := by;
                  //-------------
                  SpaceMove (Master.PEnvir.MapName, TargetX, TargetY, 1);
               end;
            end;
         end else begin
            //µµ¸Á°¡´Â ¸ðµåÀÌ¸é TargetX, TargetY·Î µµ¸Á°¨...
            if RunAwayTime > 0 then begin  //½Ã°£ Á¦ÇÑÀÌ ÀÖÀ½
               if GetTickCount - RunAwayStart > longword(RunAwayTime) then begin
                  BoRunAwayMode := FALSE;
                  RunAwayTime := 0;
               end;
            end;
         end;

         if Master <> nil then begin
            if Master.BoSlaveRelax then begin
               //ÁÖÀÎÀÌ ÈÞ½ÄÇÏ¶ó°í ÇÔ...
               inherited Run;
               exit;
            end;
         end;

         if TargetX <> -1 then begin //°¡¾ßÇÒ °÷ÀÌ ÀÖÀ½
            GotoTargetXY;
         end else begin
            // 2003/03/18 ½Ã¾ß³»¿¡ ¾Æ¹«µµ ¾øÀ¸¸é ¹èÈ¸ÇÏÁö ¾ÊÀ½
            if (TargetCret = nil) and ((RefObjCount > 0) or (HideMode)) then
//          if (TargetCret = nil) then
               Wondering; //¹èÈ¸ÇÔ
         end;
      end;
   end;

   inherited Run;
end;

procedure TMonster.RecalcAbilitys;
var
   i, oldlight, n, m: integer;
   cghi: array[0..3] of Boolean;
   pstd: PTStdItem;
   temp: TAbility;
   oldhmode: Boolean;
begin
// MainOutMessage ('[TMonster.RecalcAbilitys] ' + UserName );
   FillChar (AddAbil, sizeof(TAddAbility), 0);
   temp := WAbil;
   WAbil := Abil;
   WAbil.HP := temp.HP;
   WAbil.MP := temp.MP;
   WAbil.Weight := 0;
   WAbil.WearWeight := 0;
   WAbil.HandWeight := 0;
   AntiPoison := 0; //±âº» 2%(sonmg)
   PoisonRecover := 0;
   HealthRecover := 0;
   SpellRecover := 0;
   AntiMagic := 1;   //±âº» 10% => 2%
   Luck := 0;
   HitSpeed := 0;
   oldhmode := BoHumHideMode;
   BoHumHideMode := FALSE;

   //Æ¯¼öÇÑ ´É·Â
   BoAbilSpaceMove := FALSE;
   BoAbilMakeStone := FALSE;
   BoAbilRevival := FALSE;
   BoAddMagicFireball := FALSE;
   BoAddMagicHealing := FALSE;
   BoAbilAngerEnergy := FALSE;
   BoMagicShield := FALSE;
   BoAbilSuperStrength := FALSE;
   BoFastTraining := FALSE;
   BoAbilSearch := FALSE;

   if (BoFixedHideMode) and (StatusArr[STATE_TRANSPARENT] > 0) then  //Àº½Å¼ú
      BoHumHideMode := TRUE;

   if BoHumHideMode then begin
      if not oldhmode then begin
         CharStatus := GetCharStatus;
         CharStatusChanged;
      end;
   end else begin
      if oldhmode then begin
         StatusArr[STATE_TRANSPARENT] := 0;
         CharStatus := GetCharStatus;
         CharStatusChanged;
      end;
   end;

   //AccuracyPoint, SpeedPoint Àú¼³Á¤, ¹«¼ú·Î ¿Ã¶ó°£´Ù.
   RecalcHitSpeed;

   SpeedPoint := SpeedPoint + AddAbil.SPEED;
   AccuracyPoint := AccuracyPoint + AddAbil.HIT;
   AntiPoison := AntiPoison + AddAbil.AntiPoison;
   PoisonRecover := PoisonRecover + AddAbil.PoisonRecover;
   HealthRecover := HealthRecover + AddAbil.HealthRecover;
   SpellRecover := SpellRecover + AddAbil.SpellRecover;
   AntiMagic := AntiMagic + AddAbil.AntiMagic;
   Luck := Luck + AddAbil.Luck;
   Luck := Luck - AddAbil.UnLuck;
   HitSpeed := AddAbil.HitSpeed;

   WAbil.MaxHP := Abil.MaxHP + AddAbil.HP;
   WAbil.MaxMP := Abil.MaxMP + AddAbil.MP;

   WAbil.AC := MakeWord (Lobyte(AddAbil.AC) + Lobyte(Abil.AC), Hibyte(AddAbil.AC) + Hibyte(Abil.AC));
   WAbil.MAC := MakeWord (Lobyte(AddAbil.MAC) + Lobyte(Abil.MAC), Hibyte(AddAbil.MAC) + Hibyte(Abil.MAC));
   WAbil.DC := MakeWord (Lobyte(AddAbil.DC) + Lobyte(Abil.DC), Hibyte(AddAbil.DC) + Hibyte(Abil.DC));
   WAbil.MC := MakeWord (Lobyte(AddAbil.MC) + Lobyte(Abil.MC), Hibyte(AddAbil.MC) + Hibyte(Abil.MC));
   WAbil.SC := MakeWord (Lobyte(AddAbil.SC) + Lobyte(Abil.SC), Hibyte(AddAbil.SC) + Hibyte(Abil.SC));

   //¸¶¹ýÀ¸·Î °É¸° ¼³Á¤
   if StatusArr[STATE_DEFENCEUP] > 0 then begin //¹æ¾î·Â »ó½Â
{
      WAbil.AC := MakeWord ( Lobyte(WAbil.AC), // + 2 + (Abil.Level div 8),
                             Hibyte(WAbil.AC) + 2 + (Abil.Level div 7) );
}
      //»õ °ø½Ä(sonmg 2005/06/03)
      WAbil.AC := MakeWord ( Lobyte(WAbil.AC),
                             _MIN( 255, Hibyte(WAbil.AC) + (Abil.Level div 7) + StatusValue[STATE_DEFENCEUP] ) );
   end;
   if StatusArr[STATE_MAGDEFENCEUP] > 0 then begin //¸¶Ç×·Â »ó½Â
{
      WAbil.MAC := MakeWord ( Lobyte(WAbil.MAC), // + 2 + (Abil.Level div 8),
                              Hibyte(WAbil.MAC) + 2 + (Abil.Level div 7) );
}
      //»õ °ø½Ä(sonmg 2005/06/03)
      WAbil.MAC := MakeWord ( Lobyte(WAbil.MAC),
                              _MIN( 255, Hibyte(WAbil.MAC) + (Abil.Level div 7) + StatusValue[STATE_MAGDEFENCEUP] ) );
   end;

   //¹°¾àÀ¸·Î Áõ»çÇÑ ´É·Â ¼³Á¤
   if ExtraAbil[EABIL_DCUP] > 0 then begin
      WAbil.DC := MakeWord(
                     Lobyte(WAbil.DC),
                     _MIN( 255, Hibyte(WAbil.DC) + ExtraAbil[EABIL_DCUP] )
                  );
   end;
   if ExtraAbil[EABIL_MCUP] > 0 then begin
      WAbil.MC := MakeWord(
                     Lobyte(WAbil.MC),
                     _MIN( 255, Hibyte(WAbil.MC) + ExtraAbil[EABIL_MCUP] )
                  );
   end;
   if ExtraAbil[EABIL_SCUP] > 0 then begin
      WAbil.SC := MakeWord(
                     Lobyte(WAbil.SC),
                     _MIN( 255, Hibyte(WAbil.SC) + ExtraAbil[EABIL_SCUP] )
                  );
   end;
   if ExtraAbil[EABIL_HITSPEEDUP] > 0 then begin
      HitSpeed := HitSpeed + ExtraAbil[EABIL_HITSPEEDUP];
   end;
   if ExtraAbil[EABIL_HPUP] > 0 then begin
      WAbil.MaxHP := WAbil.MaxHP + ExtraAbil[EABIL_HPUP];
   end;
   if ExtraAbil[EABIL_MPUP] > 0 then begin
      WAbil.MaxMP := WAbil.MaxMP + ExtraAbil[EABIL_MPUP];
   end;

   if RaceServer >= RC_ANIMAL then begin
      //if Master <> nil then
      ApplySlaveLevelAbilitys;
   end;
end;

{----------------------------------------------------------------------}


constructor TChickenDeer.Create;
begin
   inherited Create;
   ViewRange := 5;
end;

procedure TChickenDeer.Run;
var
   i, d, dis, ndir, runx, runy: integer;
   cret, nearcret: TCreature;
begin
   dis := 9999;
   nearcret := nil;
//   if not Death and not RunDone and not BoGhost and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if not RunDone and IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         //»ó¼Ó¹ÞÀº run ¿¡¼­ WalkTime Àç¼³Á¤ÇÔ.
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
         if nearcret <> nil then begin
            BoRunAwayMode := TRUE; //´Þ¾Æ³ª´Â ¸ðµå
            TargetCret := nearcret;
         end else begin
            BoRunAwayMode := FALSE;
            TargetCret := nil;
         end;
      end;
      if BoRunAwayMode and (TargetCret <> nil) then begin
         if GetCurrentTime - WalkTime > GetNextWalkTime then begin
            //»ó¼Ó¹ÞÀº run¿¡¼­ WalkTime Àç¼³Á¤ÇÔ
            if (abs(CX-TargetCret.CX) <= 6) and (abs(CY-TargetCret.CY) <= 6) then begin
               //µµ¸Á°¨.
               ndir := GetNextDirection (TargetCret.CX, TargetCret.CY, CX, CY);
               GetNextPosition (PEnvir, TargetCret.CX, TargetCret.CY, ndir, 5, TargetX, TargetY);
            end;
         end;
      end;
   end;
   inherited Run;
end;

{------------------- TATMonster -------------------}

constructor TATMonster.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
end;

destructor TATMonster.Destroy;
begin
   inherited Destroy;
end;

procedure TATMonster.Run;   //°¡Àå °¡±î¿î ³ðºÎÅÍ °ø°ÝÇÑ´Ù.
begin
//   if not Death and not RunDone and not BoGhost and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if not RunDone and IsMoveAble then begin
      if (GetTickCount - SearchEnemyTime > 8000) or ((GetTickCount - SearchEnemyTime > 1000) and (TargetCret = nil)) then begin
         SearchEnemyTime := GetTickCount;
         MonsterNormalAttack;
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}

constructor TSlowATMonster.Create;
begin
   inherited Create;
end;


{---------------------------------------------------------------------------}

//TScorpion  (Àü°¥)


constructor TScorpion.Create;
begin
   inherited Create;
   BoAnimal := TRUE;  //½ä¸é Àü°¥²¿¸®°¡ ³ª¿È
end;


{---------------------------------------------------------------------------}

//TSpitSpider (Ä§¹ñ´Â °Å¹Ì)

constructor TSpitSpider.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
   BoAnimal := TRUE;  //½ä¸é Ä§°Å¹ÌÀÌ»¡ÀÌ ³ª¿È
   BoUsePoison := TRUE;
end;

//Ä§¹ñ´Â ¸ó½ºÅÍÀÇ °ø°Ý
//¸ó½ºÅÍ¸¸ »ç¿ëÇÔ
procedure  TSpitSpider.SpitAttack (dir: byte);
var
   i, k,  mx, my, dam, armor: integer;
   cret: TCreature;
begin
   self.Dir := dir;
   with WAbil do
      dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
   if dam <= 0 then exit;

   SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');

   for i:=0 to 4 do
      for k:=0 to 4 do begin
         if SpitMap[dir, i, k] = 1 then begin
            mx := CX - 2 + k;
            my := CY - 2 + i;
            cret := TCreature (PEnvir.GetCreature (mx, my, TRUE));
            if (cret <> nil) and (cret <> self) then begin
               if IsProperTarget(cret) then begin //cret.RaceServer = RC_USERHUMAN then begin
                  //¸Â´ÂÁö °áÁ¤
                  if Random(cret.SpeedPoint) < AccuracyPoint then begin
                     //Ä§°Å¹Ì Ä§Àº ¸¶¹ý¹æ¾î·Â¿¡ È¿°ú ÀÖÀ½.
                     //armor := (Lobyte(cret.WAbil.MAC) + Random(ShortInt(Hibyte(cret.WAbil.MAC)-Lobyte(cret.WAbil.MAC)) + 1));
                     //dam := dam - armor;
                     //if dam <= 0 then
                     //   if dam > -10 then dam := 1;
                     dam := cret.GetMagStruckDamage (self, dam);
                     if dam > 0 then begin
                        cret.StruckDamage (dam, self);
                        cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                 cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '',
                                 300);

                        if BoUsePoison then begin
                           //Ã¼·ÂÀÌ °¨¼ÒÇÏ´Â µ¶¿¡ Áßµ¶ µÈ´Ù.
                           if Random(20 + cret.AntiPoison) = 0 then
                              cret.MakePoison (POISON_DECHEALTH, 30, 1);   //Ã¼·ÂÀÌ °¨¼Ò
                           //if Random(2) = 0 then
                           //   cret.MakePoison (POISON_STONE, 5);   //¸¶ºñ
                        end;
                     end;
                  end;

               end;
            end;
         end;
      end;

end;

function  TSpitSpider.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if TargetInSpitRange (TargetCret, targdir) then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            TargetFocusTime := GetTickCount;
            SpitAttack (targdir);
            BreakHolySeize;
         end;
         Result := TRUE;
      end else begin
         if TargetCret.MapName = self.MapName then
            SetTargetXY (TargetCret.CX, TargetCret.CY)
         else
            LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
      end;
   end;
end;


{---------------------------------------------------------------------------}

// °Å´ë °Å¹Ì



constructor THighRiskSpider.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   BoUsePoison := FALSE;
end;


{---------------------------------------------------------------------------}

// °Å´ë µ¶°Å¹Ì

constructor TBigPoisionSpider.Create;
begin
   inherited Create;
   BoAnimal := FALSE;
   BoUsePoison := TRUE;
end;


{---------------------------------------------------------------------------}

//TGasAttackMonster (°¡½º ½î´Â ±¸µ¥±â)


constructor TGasAttackMonster.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
   BoAnimal := TRUE;  //½ä¸é ±¸·æÈ¯ÀÌ ³ª¿È
end;

function  TGasAttackMonster.GasAttack (dir: byte): TCreature;
var
   i, k,  mx, my, dam, armor: integer;
   cret: TCreature;
begin
   Result := nil;
   self.Dir := dir;
   with WAbil do
      dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
   if dam <= 0 then exit;

   SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');

   cret := GetFrontCret;
   if cret <> nil then begin
      if IsProperTarget (cret) then begin 
         //¸Â´ÂÁö °áÁ¤
         if Random(cret.SpeedPoint) < AccuracyPoint then begin
            //±¸´õ±â °¡½º´Â ¸¶¹ý¹æ¾î·Â¿¡ È¿°ú ÀÖÀ½.
            //armor := (Lobyte(cret.WAbil.MAC) + Random(ShortInt(Hibyte(cret.WAbil.MAC)-Lobyte(cret.WAbil.MAC)) + 1));
            //dam := dam - armor;
            //if dam <= 0 then
            //   if dam > -10 then dam := 1;
            dam := cret.GetMagStruckDamage (self, dam);
            if dam > 0 then begin
               cret.StruckDamage (dam, self);
               cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                        cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '',
                        300);

               //¸¶ºñ µÇ´Â µ¶¿¡ Áßµ¶ µÈ´Ù.
               if RaceServer = RC_TOXICGHOST then
               begin
                  if Random(20 + cret.AntiPoison) = 0 then
                     cret.MakePoison (POISON_DECHEALTH, 30, 1);   //Ã¼·Â°¨¼Ò
               end else begin
                  if Random(20 + cret.AntiPoison) = 0 then
                     cret.MakePoison (POISON_STONE, 5, 0);   //¸¶ºñ
               end;
               Result := cret;
            end;
         end;

      end;
   end;
end;

function  TGasAttackMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if TargetInAttackRange (TargetCret, targdir) then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            TargetFocusTime := GetTickCount;
            GasAttack (targdir);
            BreakHolySeize;
         end;
         Result := TRUE;
      end else begin
         if TargetCret.MapName = self.MapName then
            SetTargetXY (TargetCret.CX, TargetCret.CY)
         else
            LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
      end;
   end;
end;


{---------------------------------------------------------------------------}

// ¿ì¸é±Í

constructor TCowMonster.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
end;


// TMagCowMonster   ¸¶¹ý½î´Â ¿ì¸é±Í


constructor TMagCowMonster.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
end;

procedure TMagCowMonster.MagicAttack (dir: byte);
var
   i, k,  mx, my, dam, armor: integer;
   cret: TCreature;
begin
   self.Dir := dir;
   with WAbil do
      dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
   if dam <= 0 then exit;

   SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');

   cret := GetFrontCret;
   if cret <> nil then begin
      if IsProperTarget (cret) then begin  //.RaceServer = RC_USERHUMAN then begin //»ç¶÷¸¸ °ø°ÝÇÔ
         //¸Â´ÂÁö °áÁ¤ (¸¶¹ý È¸ÇÇ·Î °áÁ¤)
         if cret.AntiMagic <= Random(50) then begin
            //¸¶¹ý¹æ¾î·Â¿¡ È¿°ú ÀÖÀ½.
            //armor := (Lobyte(cret.WAbil.MAC) + Random(ShortInt(Hibyte(cret.WAbil.MAC)-Lobyte(cret.WAbil.MAC)) + 1));
            //dam := dam - armor;
            //if dam <= 0 then
            //   if dam > -10 then dam := 1;
            dam := cret.GetMagStruckDamage (self, dam);
            if dam > 0 then begin
               cret.StruckDamage (dam, self);
               cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                        cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '',
                        300);
            end;
         end;

      end;
   end;
end;

function  TMagCowMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if TargetInAttackRange (TargetCret, targdir) then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            TargetFocusTime := GetTickCount;
            MagicAttack (targdir);
            BreakHolySeize;
         end;
         Result := TRUE;
      end else begin
         if TargetCret.MapName = self.MapName then
            SetTargetXY (TargetCret.CX, TargetCret.CY)
         else
            LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
      end;
   end;
end;


{---------------------------------------------------------------------------}

// TCowKingMonster    ¿ì¸é±Í¿Õ

constructor TCowKingMonster.Create;
begin
   inherited Create;
   SearchRate := 500 + longword(Random(1500));
   JumpTime := GetTickCount;
   RushMode := TRUE; //¸¶¹ý¿¡ ¸Â¾Æµµ µ¹ÁøÇÑ´Ù.
   CrazyCount := 0;
   CrazyReadyMode := FALSE;
   CrazyKingMode := FALSE;
end;

procedure TCowKingMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
begin
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
  { inherited} HitHit2 (target, pwr div 2, pwr div 2, TRUE);
end;

procedure TCowKingMonster.Initialize;
begin
   oldhittime := NextHitTime;
   oldwalktime := NextWalkTime;
   inherited Initialize;
end;

procedure TCowKingMonster.Run;
var
   nn, nx, ny, old: integer;
   ncret: TCreature;
begin
   if not Death and not RunDone and not BoGhost then begin
      if GetTickCount - JumpTime > 30 * 1000 then begin
         JumpTime := GetTickCount;
         if (TargetCret <> nil) and (SiegeLockCount >= 5) then begin  //4¸í¿¡°Ô µÑ·¯ ½×ÀÓ
            //nn := Random(VisibleActors.Count-2) + 1;
            //ncret := TCreature (PTVisibleActor(VisibleActors[nn]).cret);
            //if ncret <> nil then SelectTarget (ncret);
            GetBackPosition (TargetCret, nx, ny);
            if PEnvir.CanWalk (nx, ny, FALSE) then begin
               SpaceMove (PEnvir.MapName, nx, ny, 0);
            end else
               RandomSpaceMove (PEnvir.MapName, 0);
            exit;
         end;
      end;
      old := CrazyCount;
      CrazyCount := 7 - WAbil.HP div (WAbil.MaxHP div 7);

      if (CrazyCount >= 2) and (CrazyCount <> old) then begin
         CrazyReadyMode := TRUE;
         CrazyReady := GetTickCount;
      end;

      if CrazyReadyMode then begin  //¸Â°í¸¸ ÀÖÀ½
         if GetTickCount - CrazyReady < 8 * 1000 then begin
            NextHitTime := 10000;
         end else begin
            CrazyReadyMode := FALSE;
            CrazyKingMode := TRUE;
            CrazyTime := GetTickCount;
         end;
      end;
      if CrazyKingMode then begin  //ÆøÁÖ
         if GetTickCount - CrazyTime < 8 * 1000 then begin
            NextHitTime := 500;
            NextWalkTime := 400;
         end else begin
            CrazyKingMode := FALSE;
            NextHitTime := oldhittime;
            NextWalkTime := oldwalktime;
         end;
      end;

   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
// ÁÖ¼úÁ»ºñ, ¶óÀÌÆ®´× Á»ºñ

constructor TLightingZombi.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
end;

//TargetCret <> nil
procedure TLightingZombi.LightingAttack (dir: integer);
var
   i, k,  sx, sy, tx, ty, mx, my, pwr: integer;
begin
   self.Dir := dir;

   SendRefMsg (RM_LIGHTING, 1, CX, CY, Integer(TargetCret), '');

   if GetNextPosition (PEnvir, CX, CY, dir, 1, sx, sy) then begin
      GetNextPosition (PEnvir, CX, CY, dir, 9, tx, ty);
      with WAbil do
         pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );
      MagPassThroughMagic (sx, sy, tx, ty, dir, pwr, TRUE);
   end;

   BreakHolySeize;

end;

procedure TLightingZombi.Run;
var
   i, dis, d, targdir: integer;
   cret, nearcret: TCreature;
begin
   dis := 9999;
   nearcret := nil;
//   if not Death and not RunDone and not BoGhost and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if not RunDone and IsMoveAble then begin
      if (GetTickCount - SearchEnemyTime > 8000) or ((GetTickCount - SearchEnemyTime > 1000) and (TargetCret = nil)) then begin
         SearchEnemyTime := GetTickCount;
         MonsterNormalAttack;
      end;
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         //»ó¼Ó¹ÞÀº run¿¡¼­ WalkTime Àç¼³Á¤ÇÔ
         if TargetCret <> nil then
            if (abs(CX-TargetCret.CX) <= 4) and (abs(CY-TargetCret.CY) <= 4) then begin
               if (abs(CX-TargetCret.CX) <= 2) and (abs(CY-TargetCret.CY) <= 2) then
                  //³Ê¹« °¡±î¿ì¸é, Àß µµ¸Á ¾È°¨.
                  if Random(3) <> 0 then begin
                     inherited Run;
                     exit;
                  end;
                //µµ¸Á°¨.
               GetBackPosition (self, TargetX, TargetY);
            end;
      end;
      if TargetCret <> nil then begin
         if (abs(CX-TargetCret.CX) < 6) and (abs(CY-TargetCret.CY) < 6) then begin
            if GetCurrentTime - HitTime > GetNextHitTime then begin
               HitTime := GetCurrentTime;
               targdir := GetNextDirection (CX, CY, TargetCret.CX, TargetCret.CY);
               LightingAttack (targdir);
            end;
         end;
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
//¶¥ÆÄ°í ³ª¿À´Â Á»ºñ


constructor TDigOutZombi.Create;
begin
   inherited Create;
   RunDone := FALSE;
   ViewRange := 7;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   RaceServer := RC_DIGOUTZOMBI;
   HideMode := TRUE;
end;

procedure TDigOutZombi.ComeOut;
var
   event: TEvent;
begin
   event := TEvent.Create (PEnvir, CX, CY, ET_DIGOUTZOMBI, 5 * 60 * 1000, TRUE);
   if ( event <> nil ) and ( event.IsAddToMap = true ) then
   begin
     EventMan.AddEvent (event);
     HideMode := FALSE;
     SendRefMsg (RM_DIGUP, Dir, CX, CY, integer(event), '');
     Exit;
   end;

   if event <> nil then event.Free;
end;

procedure TDigOutZombi.Run;
var
   i, dis, d, targdir: integer;
   cret, nearcret: TCreature;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         nearcret := nil;
         //WalkTime := GetTickCount;  »ó¼Ó¹ÞÀº run¿¡¼­ Àç¼³Á¤ÇÔ
         if HideMode then begin //¾ÆÁ÷ ¸ð½ÀÀ» ³ªÅ¸³»Áö ¾Ê¾ÒÀ½.
            for i:=0 to VisibleActors.Count-1 do begin
               cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
               if (not cret.Death) and (IsProperTarget(cret)) and (not cret.BoHumHideMode or BoViewFixedHide) then begin
                  if (abs(CX-cret.CX) <= 3) and (abs(CY-cret.CY) <= 3) then begin
                     ComeOut; //¹ÛÀ¸·Î ³ª¿À´Ù. º¸ÀÎ´Ù.
                     WalkTime := GetCurrentTime + 1000;
                     break;
                  end;
               end;
            end;
         end else begin
            if (GetTickCount - SearchEnemyTime > 8000) or ((GetTickCount - SearchEnemyTime > 1000) and (TargetCret = nil)) then begin
               SearchEnemyTime := GetTickCount;
               MonsterNormalAttack;
            end;
         end;
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
//Á×¾ú´Ù ±ú¾î³ª´Â Á»ºñ


constructor TZilKinZombi.Create;
begin
   inherited Create;
   ViewRange := 6;
   SearchRate := 2500 + longword(Random(1500));
   SearchTime := GetTickCount;
   RaceServer := RC_ZILKINZOMBI;
   LifeCount := 0;
   if Random(3) = 0 then
      LifeCount := 1 + Random(3);
end;

procedure TZilKinZombi.Die;
begin
   inherited Die;
   if LifeCount > 0 then begin
      deathstart := GetTickCount;
      RelifeTime := (4 + Random (20)) * 1000;
   end;
   Dec (LifeCount);
end;

procedure TZilKinZombi.Run;
begin
   // Æ¯º°ÇÑ °æ¿ì¶ó IsMoveAble ½Î¿ëÇÒ¼ö ¾øÀ½
   if Death and (not BoGhost) and (LifeCount >= 0) and
      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
      (StatusArr[POISON_STUN] = 0)and (StatusArr[POISON_DONTMOVE] = 0) then begin  //Á×¾úÀ½, °í½ºÆ®»óÅÂ´Â ¾Æ´Ô
      if VisibleActors.Count > 0 then begin
         if GetTickCount - deathstart >= RelifeTime then begin
            Abil.MaxHP := Abil.MaxHP div 2;
            FightExp := FightExp div 2;
            Abil.HP  := Abil.MaxHP;
            WAbil.HP := Abil.MaxHP;
            Alive;
            WalkTime := GetCurrentTime + 1000;
         end;
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
//¹é°ñ:  ¼ÒÈ¯¼ö


constructor TWhiteSkeleton.Create;
begin
   inherited Create;
   bofirst := TRUE;
   HideMode := TRUE;
   RaceServer := RC_WHITESKELETON;
   ViewRange := 6;
end;

procedure TWhiteSkeleton.RecalcAbilitys;
begin
   inherited RecalcAbilitys;
//   ResetSkeleton;
//   ApplySlaveLevelAbilitys;
end;

procedure TWhiteSkeleton.ResetSkeleton;
begin
   NextHitTime := 3000 - (SlaveMakeLevel * 600);
   NextWalkTime := 1200 - (SlaveMakeLevel * 250);
   //WAbil.DC := MakeWord(Lobyte(WAbil.DC), Hibyte(WAbil.DC) + SlaveMakeLevel);
   //WAbil.MaxHP := WAbil.MaxHP + SlaveMakeLevel * 5;
   //WAbil.HP := WAbil.MaxHP;
   //AccuracyPoint := 11 + SlaveMakeLevel;
   WalkTime := GetCurrentTime + 2000;
end;

procedure TWhiteSkeleton.Run;
var
   i: integer;
begin
   if bofirst then begin
      bofirst := FALSE;
      Dir := 5;
      HideMode := FALSE;
      SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
      ResetSkeleton;
   end;
   inherited Run;
end;

{---------------------------------------------------------------------------}
//¼®»ó¸óÆ®½¢: ¿°¼ÒÀå±º, ¿°¼Ò´ëÀå


constructor TScultureMonster.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
   ViewRange := 7;
   BoStoneMode := TRUE; //Ã³À½¿¡´Â µ¹·Î ±»¾îÁ® ÀÖÀ½...
   CharStatusEx := STATE_STONE_MODE;
   BoDontMove := true;
   MeltArea   := 2;
end;

procedure TScultureMonster.MeltStone;
begin
   CharStatusEx := 0;
   CharStatus := GetCharStatus;
   SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');  //³ì´Â ¾Ö´Ï¸ÞÀÌ¼Ç
   BoStoneMode := FALSE;
   BoDontMove  := false;
end;

procedure TScultureMonster.MeltStoneAll;
var
   i: integer;
   cret: TCreature;
   rlist: TList;
begin
   MeltStone;
   rlist := TList.Create;
   GetMapCreatures (PEnvir, CX, CY, 7, rlist);
   for i:=0 to rlist.Count-1 do begin
      cret := TCreature (rlist[i]);
      if cret.BoStoneMode then begin
         if cret is TScultureMonster then
            TScultureMonster(cret).MeltStone;
      end;
   end;
   rlist.Free;
end;

procedure TScultureMonster.Run;
var
   i, dis, d, targdir: integer;
   cret, nearcret: TCreature;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         nearcret := nil;
         //WalkTime := GetTickCount;  »ó¼Ó¹ÞÀº run¿¡¼­ Àç¼³Á¤ÇÔ
         if BoStoneMode then begin //¾ÆÁ÷ ¸ð½ÀÀ» ³ªÅ¸³»Áö ¾Ê¾ÒÀ½.
            for i:=0 to VisibleActors.Count-1 do begin
               cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
               if (not cret.Death) and (IsProperTarget(cret)) and (not cret.BoHumHideMode or BoViewFixedHide) then begin
                  if (abs(CX-cret.CX) <= MeltArea) and (abs(CY-cret.CY) <= MeltArea) then begin
                     MeltStoneAll; //¼®»ó»óÅÂ¿¡¼­ ³ì´Â´Ù, ÁÖÀÇµ¿·áµéµµ ÇÔ²² ³ì´Â´Ù.
                     WalkTime := GetCurrentTime + 1000;
                     break;
                  end;
               end;
            end;
         end else begin
            if (GetTickCount - SearchEnemyTime > 8000) or ((GetTickCount - SearchEnemyTime > 1000) and (TargetCret = nil)) then begin
               SearchEnemyTime := GetTickCount;
               MonsterNormalAttack;
            end;
         end;
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
//ÁÖ¸¶¿Õ


constructor TScultureKingMonster.Create;
begin
   inherited Create;
   SearchRate := 1500 + longword(Random(1500));
   ViewRange := 8;
   BoStoneMode := TRUE; //Ã³À½¿¡´Â µ¹·Î ±»¾îÁ® ÀÖÀ½...
   CharStatusEx := STATE_STONE_MODE;
   Dir := 5;
   DangerLevel := 5; //5¹øÀÇ À§±â..
   childlist := TList.Create;
   BoCallFollower := TRUE;
end;

destructor TScultureKingMonster.Destroy;
begin
   childlist.Free;
   inherited Destroy;
end;

procedure TScultureKingMonster.MeltStone;
var
   i: integer;
   cret: TCreature;
   event: TEvent;
begin
   event := TEvent.Create (PEnvir, CX, CY, ET_SCULPEICE, 5 * 60 * 1000, TRUE);
   if ( event <> nil ) and ( event.IsAddToMap = true ) then
   begin
     CharStatusEx := 0;
     CharStatus := GetCharStatus;
     SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
     BoStoneMode := FALSE;
     EventMan.AddEvent (event);
     Exit;
   end;

   if event <> nil then event.Free;
end;

procedure TScultureKingMonster.CallFollower;
const
   MAX_FOLLOWERS = 4;
var
   i, count, nx, ny: integer;
   monname: string;
   mon: TCreature;
   followers: array[0..MAX_FOLLOWERS-1] of string; // = (ÁÖ¸¶È£¹ý', ÁÖ¸¶½ÅÀå', ¸¶±Ã»ç', ½û±â³ª¹æ');
begin
   count := 6 + Random (6);
   GetFrontPosition (self, nx, ny);

   followers[0] := __ZumaMonster1;
   followers[1] := __ZumaMonster2;
   followers[2] := __ZumaMonster3;
   followers[3] := __ZumaMonster4;

   for i:=1 to count do begin
      if childlist.Count < 30 then begin
         monname := followers[Random(MAX_FOLLOWERS)];
         mon := UserEngine.AddCreatureSysop (MapName, nx, ny, monname);
         if mon <> nil then
            childlist.Add (mon);
      end;
   end;
end;

procedure TScultureKingMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
begin
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   {inherited} HitHit2 (target, 0, pwr, TRUE);
end;

procedure TScultureKingMonster.Run;
var
   i, dis, d, targdir: integer;
   cret, nearcret: TCreature;
begin
//   if (not BoGhost) and (not Death) and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
  if IsMoveAble then begin
      if GetCurrentTime - WalkTime > GetNextWalkTime then begin
         nearcret := nil;
         //WalkTime := GetTickCount;  »ó¼Ó¹ÞÀº run¿¡¼­ Àç¼³Á¤ÇÔ
         if BoStoneMode then begin //¾ÆÁ÷ ¸ð½ÀÀ» ³ªÅ¸³»Áö ¾Ê¾ÒÀ½.
            for i:=0 to VisibleActors.Count-1 do begin
               cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
               if (not cret.Death) and (IsProperTarget(cret)) and (not cret.BoHumHideMode or BoViewFixedHide) then begin
                  if (abs(CX-cret.CX) <= 2) and (abs(CY-cret.CY) <= 2) then begin
                     MeltStone; //¼®»ó»óÅÂ¿¡¼­ ³ì´Â´Ù
                     WalkTime := GetCurrentTime + 2000;
                     break;
                  end;
               end;
            end;
         end else begin
            if (GetTickCount - SearchEnemyTime > 8000) or ((GetTickCount - SearchEnemyTime > 1000) and (TargetCret = nil)) then begin
               SearchEnemyTime := GetTickCount;
               MonsterNormalAttack;
            end;

            if BoCallFollower then begin
               //5¹øÀÇ ½Ã·Ã
               if ((WAbil.HP / WAbil.MaxHP * 5) < DangerLevel) and (DangerLevel > 0) then begin
                  Dec (DangerLevel);
                  CallFollower;
               end;
               if WAbil.HP = WAbil.MaxHP then DangerLevel := 5;  //ÃÊ±âÈ­
            end;

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


{---------------------------------------------------------------------------}
//½û±â³ª¹æ, ¼ûÀº »ç¶÷À» º¼ ¼ö ÀÖÀ½, °¡½º(µðÅØÆ®)

constructor TGasMothMonster.Create;
begin
   inherited Create;
   ViewRange := 7;
end;

function  TGasMothMonster.GasAttack (dir: byte): TCreature;
var
   cret: TCreature;
begin
   cret := inherited GasAttack (dir);
   if cret <> nil then begin  //ÀÌ °¡½º´Â Àº½ÅÀÌ Ç®¸°´Ù.
      if Random(3) = 0 then begin
         //if cret.BoFixedHideMode then begin //°íÁ¤ Àº½Å¼ú, Åõ¸í¹ÝÁöµµ Ç®¸²
            if cret.BoHumHideMode then begin
               cret.StatusArr[STATE_TRANSPARENT] := 1;
            end;
         //end;
      end;
   end;
   Result := cret;
end;

procedure TGasMothMonster.Run;   //°¡Àå °¡±î¿î ³ðºÎÅÍ °ø°ÝÇÑ´Ù.
var
   i, dis, d: integer;
   cret, nearcret: TCreature;
begin
   dis := 9999;
   nearcret := nil;
//   if not Death and not RunDone and not BoGhost and
//      (StatusArr[POISON_STONE] = 0) and (StatusArr[POISON_ICE] = 0) and
//      (StatusArr[POISON_STUN] = 0) then begin
   if not RunDone and IsMoveAble then begin
      if (GetTickCount - SearchEnemyTime > 8000) or ((GetTickCount - SearchEnemyTime > 1000) and (TargetCret = nil)) then begin
         SearchEnemyTime := GetTickCount;
         MonsterDetecterAttack;   //¼û¾îÀÖ´Â ¸÷À» º¼ ¼ö ÀÖ´Ù.
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
//µÕ, °¡½º(¸¶ºñ)

constructor TGasDungMonster.Create;
begin
   inherited Create;
   ViewRange := 7;
end;


{---------------------------------------------------------------------------}
//½Å¼ö (º¯½Å Àü)

constructor TElfMonster.Create;
begin
   inherited Create;
   ViewRange := 6;
   HideMode := TRUE;
   NoAttackMode := TRUE;
   bofirst := TRUE;
end;

procedure TElfMonster.RecalcAbilitys;
begin
   inherited RecalcAbilitys;
   ResetElfMon;
end;

procedure TElfMonster.ResetElfMon;
begin
   //NextHitTime := 3000 - (SlaveMakeLevel * 600);  //°ø°Ý ¾ÈÇÔ
   NextWalkTime := 500 - (SlaveMakeLevel * 50);
   WalkTime := GetCurrentTime + 2000;
end;

procedure TElfMonster.AppearNow;
begin
   bofirst := FALSE;
   HideMode := FALSE;
   //SendRefMsg (RM_TURN, Dir, CX, CY, 0, '');
   //Appear;
   //ResetElfMon;
   RecalcAbilitys;
   WalkTime := WalkTime + 800; //º¯½ÅÈÄ ¾à°£ µô·¹ÀÌ ÀÖÀ½
end;

procedure TElfMonster.Run;
var
   cret: TCreature;
   bochangeface: Boolean;
begin
   if bofirst then begin
      bofirst := FALSE;
      HideMode := FALSE;
      SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
      ResetElfMon;
   end;
   if Death then begin  //½Å¼ö´Â ½ÃÃ¼°¡ ¾ø´Ù.
      if GetTickCount - DeathTime > 2 * 1000 then begin
         MakeGhost(1);
      end;
   end else begin
      bochangeface := FALSE;
      if TargetCret <> nil then bochangeface := TRUE;
      if Master <> nil then
         if (Master.TargetCret <> nil) or (Master.LastHiter <> nil) then
            bochangeface := TRUE;

      if bochangeface then begin  //°ø°Ý ´ë»óÀÌ ÀÖ´Â °æ¿ì->º¯½Å
         cret := MakeClone (__ShinSu1, self);
         if cret <> nil then begin
//            SendRefMsg (RM_CHANGEFACE, 0, integer(self), integer(cret), 0, '');
            if cret is TElfWarriorMonster then
               TElfWarriorMonster(cret).AppearNow;
            Master := nil;
            KickException;
         end;
      end;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
//½Å¼ö (º¯½Å ÈÄ)


constructor TElfWarriorMonster.Create;
begin
   inherited Create;
   ViewRange := 6;
   HideMode := TRUE;
   //NoAttackMode := TRUE;
   bofirst := TRUE;
   BoUsePoison := FALSE;
end;

procedure TElfWarriorMonster.RecalcAbilitys;
begin
   inherited RecalcAbilitys;
//   ResetElfMon;
end;

procedure TElfWarriorMonster.ResetElfMon;
begin
   //NextHitTime := 3000 - (SlaveMakeLevel * 600);
   //NextWalkTime := 1200 - (SlaveMakeLevel * 250);
   NextHitTime := 1500 - (SlaveMakeLevel * 100);
   NextWalkTime := 500 - (SlaveMakeLevel * 50);
   WalkTime := GetCurrentTime + 2000;
end;

procedure TElfWarriorMonster.AppearNow;
begin
   bofirst := FALSE;
   HideMode := FALSE;
   FirstHp := Self.WAbil.MaxHP;    //ÉñÊÞÅ¿ÏÂÈ¥µ±Ç°HPÎ´»Ö¸´
   SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
   RecalcAbilitys;
   ResetElfMon;
   WalkTime := WalkTime + 800; //º¯½ÅÈÄ ¾à°£ µô·¹ÀÌ ÀÖÀ½
   changefacetime := GetTickCount;
end;

procedure TElfWarriorMonster.Run;
var
   cret: TCreature;
   bochangeface: Boolean;
begin
   if bofirst then begin
      bofirst := FALSE;
      HideMode := FALSE;
      SendRefMsg (RM_DIGUP, Dir, CX, CY, 0, '');
      ResetElfMon;
   end;
   if Death then begin  //½Å¼ö´Â ½ÃÃ¼°¡ ¾ø´Ù.
      if GetTickCount - DeathTime > 2 * 1000 then begin
         MakeGhost(2);
      end;
   end else begin
      bochangeface := TRUE;
      if TargetCret <> nil then bochangeface := FALSE;
      if Master <> nil then
         if (Master.TargetCret <> nil) or (Master.LastHiter <> nil) then
            bochangeface := FALSE;

      if bochangeface then begin  //°ø°Ý ´ë»óÀÌ ÀÖ´Â °æ¿ì->º¯½Å
         if GetTickCount - changefacetime > 60 * 1000 then begin
            if Self.WAbil.HP > FirstHp then  Self.WAbil.HP := FirstHp;     //ÉñÊÞÅ¿ÏÂÈ¥µ±Ç°HPÎ´»Ö¸´
            cret := MakeClone (__ShinSu, self);
            if cret <> nil then begin
               SendRefMsg (RM_DIGDOWN, {Dir}0, CX, CY, 0, ''); //º¯½ÅÀÌ ³¡³­ ÈÄ¿¡ »ç¶óÁø´Ù.
               SendRefMsg (RM_CHANGEFACE, 0, integer(self), integer(cret), 0, '');
               if cret is TElfMonster then begin
                  TElfMonster(cret).AppearNow;
               end;
               Master := nil;
               KickException;
            end;
         end;
      end else
         changefacetime := GetTickCount;
   end;
   inherited Run;
end;


{---------------------------------------------------------------------------}
// °­·ÂÇÑ Å©¸®Æ¼ÄÃ °ø°ÝÀ» ÇÏ´Â ¸ó½ºÅÍ


constructor TCriticalMonster.Create;
begin
   inherited Create;
   criticalpoint := 0;
end;

procedure TCriticalMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
begin
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   Inc (criticalpoint);

   if (criticalpoint > 5) or (Random(10) = 0) then begin
      criticalpoint := 0;
      pwr := Round (pwr * (Abil.MaxMP / 10));
      {inherited} HitHitEx2 (target, RM_LIGHTING, 0, pwr, TRUE);
   end else
      {inherited} HitHit2 (target, 0, pwr, TRUE);
end;


{---------------------------------------------------------------------------}
// °­·ÂÇÑ µÎÄ­ Å©¸®Æ¼ÄÃ °ø°ÝÀ» ÇÏ´Â ¸ó½ºÅÍ


constructor TDoubleCriticalMonster.Create;
begin
   inherited Create;
   criticalpoint := 0;
end;

procedure  TDoubleCriticalMonster.DoubleCriticalAttack (dam: integer; dir: byte);
var
   i, k,  mx, my, armor: integer;
   cret: TCreature;
begin
   self.Dir := dir;
   if dam <= 0 then exit;

   SendRefMsg (RM_LIGHTING, self.Dir, CX, CY, 0, '');

   for i:=0 to 4 do
      for k:=0 to 4 do begin
         if SpitMap[dir, i, k] = 1 then begin
            mx := CX - 2 + k;
            my := CY - 2 + i;
            cret := TCreature (PEnvir.GetCreature (mx, my, TRUE));
            if (cret <> nil) and (cret <> self) then begin
               if IsProperTarget(cret) then begin //cret.RaceServer = RC_USERHUMAN then begin
                  //¸Â´ÂÁö °áÁ¤
                  if Random(cret.SpeedPoint) < AccuracyPoint then begin
                     //Ä§°Å¹Ì Ä§Àº ¸¶¹ý¹æ¾î·Â¿¡ È¿°ú ÀÖÀ½.
                     //armor := (Lobyte(cret.WAbil.MAC) + Random(ShortInt(Hibyte(cret.WAbil.MAC)-Lobyte(cret.WAbil.MAC)) + 1));
                     //dam := dam - armor;
                     //if dam <= 0 then
                     //   if dam > -10 then dam := 1;
                     dam := cret.GetMagStruckDamage (self, dam);
                     if dam > 0 then begin
                        cret.StruckDamage (dam, self);
                        cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                 cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '',
                                 300);

                     end;
                  end;

               end;
            end;
         end;
      end;
end;

procedure TDoubleCriticalMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
begin
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   Inc (criticalpoint);

   if (criticalpoint > 5) or (Random(10) = 0) then begin
      criticalpoint := 0;
      pwr := Round (pwr * (Abil.MaxMP / 10));
      DoubleCriticalAttack (pwr, Dir);
   end else
      {inherited} HitHit2 (target, 0, pwr, TRUE);
end;

// 2003/02/11 ÇØ°ñº´»ç
constructor TSkeletonSoldier.Create;
begin
   inherited Create;
end;

procedure  TSkeletonSoldier.RangeAttack (dir: byte);
var
   i, k,  mx, my, dam, armor: integer;
   cret: TCreature;
   pwr: integer;
begin
   self.Dir := dir;
   with WAbil do
      dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
   if dam <= 0 then exit;

   SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');

   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   for i:=0 to 4 do
      for k:=0 to 4 do begin
         if SpitMap[dir, i, k] = 1 then begin
            mx := CX - 2 + k;
            my := CY - 2 + i;
            cret := TCreature (PEnvir.GetCreature (mx, my, TRUE));
            if (cret <> nil) and (cret <> self) then begin
               if IsProperTarget(cret) then begin //cret.RaceServer = RC_USERHUMAN then begin
                  //¸Â´ÂÁö °áÁ¤
                  if Random(cret.SpeedPoint) < AccuracyPoint then begin
                     {inherited} HitHit2 (cret, 0, pwr, TRUE);
                  end;
               end;
            end;
         end;
      end;
end;

function  TSkeletonSoldier.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if TargetInSpitRange (TargetCret, targdir) then begin
         if GetCurrentTime - HitTime > GetNextHitTime then begin
            HitTime := GetCurrentTime;
            TargetFocusTime := GetTickCount;
            RangeAttack (targdir);
            BreakHolySeize;
         end;
         Result := TRUE;
      end else begin
         if TargetCret.MapName = self.MapName then
            SetTargetXY (TargetCret.CX, TargetCret.CY)
         else
            LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
      end;
   end;
end;

constructor TSkeletonKingMonster.Create;
begin
   inherited Create;
   ChainShotCount := 6;
   BoStoneMode := FALSE;
   CharStatusEx := 0;
   CharStatus := GetCharStatus;
end;

procedure TSkeletonKingMonster.CallFollower;
const
   MAX_SKELFOLLOWERS = 3;
var
   i, count, nx, ny: integer;
   monname: string;
   mon: TCreature;
   followers: array[0..MAX_SKELFOLLOWERS-1] of string; // = (ÇØ°ñ¹«Àå, ÇØ°ñ±Ã¼ö, ÇØ°ñº´Á¹);
begin
   SendRefMsg (RM_LIGHTING, self.Dir, CX, CY, 0, '');
   count := 4 + Random (4);
   GetFrontPosition (self, nx, ny);

   //Á¨½ÃÅ³ ¸ó½ºÅÍÀÌ¸§
{$IFDEF KOREA}
   followers[0] := 'ÇØ°ñ¹«Àå';
   followers[1] := 'ÇØ°ñ±Ã¼ö';
   followers[2] := 'ÇØ°ñº´Á¹';
{$ELSE}
   followers[0] := 'BoneCaptain';
   followers[1] := 'BoneArcher';
   followers[2] := 'BoneSpearman';
{$ENDIF}

   for i:=1 to count do begin
      if childlist.Count < 20 then begin
         monname := followers[Random(MAX_SKELFOLLOWERS)];
         mon := UserEngine.AddCreatureSysop (MapName, nx, ny, monname);
         if mon <> nil then
            childlist.Add (mon);
      end;
   end;
end;

procedure TSkeletonKingMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
begin
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   {inherited} HitHit2 (target, 0, pwr, TRUE);
end;

procedure TSkeletonKingMonster.Run;
var
   i, dis, d, targdir: integer;
   cret : TCreature;
begin
   inherited Run;
end;

procedure TSkeletonKingMonster.RangeAttack (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   dam, armor: integer;
begin
   if targ = nil then exit;

   if PEnvir.CanFly (CX, CY, targ.CX, targ.CY) then begin //µµ³¢°¡ ³¯¾Æ°¥¼ö ÀÖ´ÂÁö.
      Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
      with WAbil do
         dam := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );
      if dam > 0 then begin
         dam := targ.GetHitStruckDamage (self, dam);
      end;
      if dam > 0 then begin
         targ.StruckDamage (dam, self);
         targ.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                  targ.WAbil.HP{lparam1}, targ.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 600 + _MAX(Abs(CX-targ.CX),Abs(CY-targ.CY)) * 50);
      end;
      SendRefMsg (RM_FLYAXE, Dir, CX, CY, Integer(targ), '');
   end;
end;

function  TSkeletonKingMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         if (abs(CX-TargetCret.CX) <= 7) and (abs(CY-TargetCret.CY) <= 7) then begin
            if TargetInAttackRange (TargetCret, targdir) then begin
               TargetFocusTime := GetTickCount;
               Attack (TargetCret, targdir);
               Result := TRUE;
            end else begin
               if ChainShot < ChainShotCount-1 then begin
                  Inc (ChainShot);
                  TargetFocusTime := GetTickCount;
                  RangeAttack (TargetCret);
               end else begin
                  if Random(5) = 0 then
                     ChainShot := 0;
               end;
               Result := TRUE;
            end;
         end else begin
            if TargetCret.MapName = self.MapName then begin
               if (abs(CX-TargetCret.CX) <= 11) and (abs(CY-TargetCret.CY) <= 11) then begin
                  SetTargetXY (TargetCret.CX, TargetCret.CY)
               end;
            end else begin
               LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
            end;
         end;
      end;
   end;
end;

// 2003/03/04 ¹Ý¾ßÁÂ»ç, ¹Ý¾ß¿ì»ç
constructor TBanyaGuardMonster.Create;
begin
   inherited Create;
   ChainShotCount := 6;
   BoCallFollower := FALSE;
end;

procedure TBanyaGuardMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
begin
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   {inherited} HitHit2 (target, 0, pwr, TRUE);
end;

procedure TBanyaGuardMonster.RangeAttack (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   i, pwr, dam: integer;
   sx, sy, tx, ty : integer;
   list: TList;
   cret: TCreature;
begin
   if targ = nil then exit;

   Self.Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
   SendRefMsg (RM_LIGHTING, self.Dir, CX, CY, Integer(targ), '');
   if GetNextPosition (PEnvir, CX, CY, dir, 1, sx, sy) then begin
      GetNextPosition (PEnvir, CX, CY, dir, 9, tx, ty);
      with WAbil do
         pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );

      list := TList.Create;
      PEnvir.GetAllCreature (targ.CX, targ.CY, TRUE, list);
      for i:=0 to list.Count-1 do begin
         cret := TCreature(list[i]);
         if IsProperTarget (cret) then begin
            dam := cret.GetMagStruckDamage (self, pwr);
            if dam > 0 then begin
               cret.StruckDamage (dam, self);
               cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                  cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 800);
            end;
         end;
      end;
      list.Free;
   end;
end;

function  TBanyaGuardMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         if (abs(CX-TargetCret.CX) <= 7) and (abs(CY-TargetCret.CY) <= 7) then begin
            if (TargetInAttackRange (TargetCret, targdir)) and (Random(3)<>0) then begin
               TargetFocusTime := GetTickCount;
               Attack (TargetCret, targdir);
               Result := TRUE;
            end else begin
               if ChainShot < ChainShotCount-1 then begin
                  Inc (ChainShot);
                  TargetFocusTime := GetTickCount;
                  RangeAttack (TargetCret);
               end else begin
                  if Random(5) = 0 then
                     ChainShot := 0;
               end;
               Result := TRUE;
            end;
         end else begin
            if TargetCret.MapName = self.MapName then begin
               if (abs(CX-TargetCret.CX) <= 11) and (abs(CY-TargetCret.CY) <= 11) then begin
                  SetTargetXY (TargetCret.CX, TargetCret.CY)
               end;
            end else begin
               LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
            end;
         end;
      end;
   end;
end;

// 2003/03/04 »ç¿ìÃµ¿Õ
constructor TDeadCowKingMonster.Create;
begin
   inherited Create;
   ChainShotCount := 6;
   BoCallFollower := FALSE;
end;

procedure TDeadCowKingMonster.Attack (target: TCreature; dir: byte);
var
   pwr: integer;
   i, ix, iy, ixf, ixt, iyf, iyt, dam: integer;
   list: TList;
   cret: TCreature;
begin
   Self.Dir := GetNextDirection (CX, CY, target.CX, target.CY);
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));

      ixf := _MAX(0, CX - 1); ixt := _MIN(pEnvir.MapWidth-1,  CX + 1);
      iyf := _MAX(0, CY - 1); iyt := _MIN(pEnvir.MapHeight-1, CY + 1);

   for ix := ixf to ixt do begin
      for iy := iyf to iyt do begin
         list := TList.Create;
         PEnvir.GetAllCreature (ix, iy, TRUE, list);
         for i:=0 to list.Count-1 do begin
            cret := TCreature(list[i]);
            if IsProperTarget (cret) then begin
               dam := cret.GetMagStruckDamage (self, pwr);
               if dam > 0 then begin
                  cret.StruckDamage (dam, self);
                  cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                     cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 200);
               end;
            end;
         end;
         list.Free;
      end;
   end;
   SendRefMsg (RM_HIT, self.Dir, CX, CY, Integer(target), '');
// inherited HitHit2 (target, 0, pwr, TRUE);
end;

procedure TDeadCowKingMonster.RangeAttack (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   i, ix, iy, ixf, ixt, iyf, iyt, pwr, dam: integer;
   sx, sy, tx, ty : integer;
   list: TList;
   cret: TCreature;
begin
   if targ = nil then exit;

   Self.Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
   SendRefMsg (RM_LIGHTING, self.Dir, CX, CY, Integer(targ), '');
   if GetNextPosition (PEnvir, CX, CY, dir, 1, sx, sy) then begin
      GetNextPosition (PEnvir, CX, CY, dir, 9, tx, ty);
      with WAbil do
         pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );

      ixf := _MAX(0, targ.CX - 2); ixt := _MIN(pEnvir.MapWidth-1,  targ.CX + 2);
      iyf := _MAX(0, targ.CY - 2); iyt := _MIN(pEnvir.MapHeight-1, targ.CY + 2);

      for ix := ixf to ixt do begin
         for iy := iyf to iyt do begin
            list := TList.Create;
            PEnvir.GetAllCreature (ix, iy, TRUE, list);
            for i:=0 to list.Count-1 do begin
               cret := TCreature(list[i]);
               if IsProperTarget (cret) then begin
                  dam := cret.GetMagStruckDamage (self, pwr);
                  if dam > 0 then begin
                     cret.StruckDamage (dam, self);
                     cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                        cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 800);
                  end;
               end;
            end;
            list.Free;
         end;
      end;
   end;
end;

function  TDeadCowKingMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         if (abs(CX-TargetCret.CX) <= 7) and (abs(CY-TargetCret.CY) <= 7) then begin
            if (TargetInAttackRange (TargetCret, targdir)) and (Random(3)<>0) then begin
               TargetFocusTime := GetTickCount;
               Attack (TargetCret, targdir);
               Result := TRUE;
            end else begin
               if ChainShot < ChainShotCount-1 then begin
                  Inc (ChainShot);
                  TargetFocusTime := GetTickCount;
                  RangeAttack (TargetCret);
               end else begin
                  if Random(5) = 0 then
                     ChainShot := 0;
               end;
               Result := TRUE;
            end;
         end else begin
            if TargetCret.MapName = self.MapName then begin
               if (abs(CX-TargetCret.CX) <= 11) and (abs(CY-TargetCret.CY) <= 11) then begin
                  SetTargetXY (TargetCret.CX, TargetCret.CY)
               end;
            end else begin
               LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
            end;
         end;
      end;
   end;
end;

// 2003/07/15 °ú°ÅºñÃµ ¸¶°è¼®
constructor TStoneMonster.Create;
begin
   inherited Create;
   ViewRange := 7;
   StickMode := TRUE;
end;

procedure TStoneMonster.Run;
var
   boidle: Boolean;
   i, ix, iy : integer;
   cret : TCreature;
   pva: PTVisibleActor;
   BoRecalc : Boolean;
   ixf, ixt, iyf, iyt : integer;
   list: TList;
begin
   if (not BoGhost) and (not Death) then begin
      // 5ÃÊ¸¶´Ù ÇÑ¹ø¾¿ ¹ßµ¿
      if GetCurrentTime - WalkTime > 5000 {NextWalkTime} then begin
         WalkTime := GetCurrentTime;

         ixf := _MAX(0, CX - 3); ixt := _MIN(pEnvir.MapWidth-1,  CX + 3);
         iyf := _MAX(0, CY - 3); iyt := _MIN(pEnvir.MapHeight-1, CY + 3);

         list := TList.Create;
         for ix := ixf to ixt do begin
            for iy := iyf to iyt do begin
               list.Clear;
               PEnvir.GetAllCreature (ix, iy, TRUE, list);
               for i:=0 to list.Count-1 do begin
                  cret := TCreature(list[i]);
                  BoRecalc := FALSE;
                  if (cret <> nil) and
                     (cret.RaceServer <> RC_USERHUMAN) and
                     (cret.Master = nil) and
                     (not cret.BoGhost) and (not cret.Death) then begin
                     if RaceServer = RC_PBMSTONE1 then begin  // °ø°Ý·Â °­È­ ¸¶°è¼®
                        if cret.ExtraAbil[EABIL_DCUP] = 0 then begin
                           BoRecalc := TRUE;
                           cret.ExtraAbil[EABIL_DCUP] := 15;
                           cret.ExtraAbilFlag[EABIL_DCUP] := 0;
                           cret.ExtraAbilTimes[EABIL_DCUP] := GetTickCount + 15100;
                        end;
                     end else begin
                        if cret.StatusArr[STATE_DEFENCEUP] = 0 then begin
                           BoRecalc := TRUE;
                           cret.StatusArr[STATE_DEFENCEUP] := 8;
                           cret.StatusTimes[STATE_DEFENCEUP] := GetTickCount;
                        end;

                        if cret.StatusArr[STATE_MAGDEFENCEUP] = 0 then begin
                           BoRecalc := TRUE;
                           cret.StatusArr[STATE_MAGDEFENCEUP] := 8;
                           cret.StatusTimes[STATE_MAGDEFENCEUP] := GetTickCount;
                        end;
                     end;
                     if BoRecalc then begin
                        cret.RecalcAbilitys;
                     end;
                  end;
                  if (Random(6) = 0) and BoRecalc then
                     SendRefMsg (RM_HIT, 0, CX, CY, 0, '')
               end;
            end;
         end;
         list.Free;
         if Random(2) = 0 then
            SendRefMsg (RM_TURN, 0, CX, CY, 0, '');
      end;
   end;
   inherited Run;
end;

//ÆÄÈ²¸¶½Å =====================================================================
constructor TPBKingMonster.Create;
begin
   inherited Create;
   ChainShotCount := 3;
   ViewRange := 12;
end;


procedure TPBKingMonster.Run ;
begin
   // ÆÄÈ²¸¶½ÅÀ» ¸Ê°¡ÀåÀÚ¸®·Î µ¥¸®±¸ °¡¼­Á×ÀÌ´Â°Å ¹æÁö
   if PEnvir <> nil then begin
      // ¸ÊÀÇ ¿Ü°û¾Ö À§Ä¡ÇØ ÀÖ´Ù¸é. °£´ÜÇÑ °è»êÀÌ¹Ç·Î °è¼Ó »ý°¢ÇÏ°Ô ÇØµµµÈ´Ù.
      // ÆÄÈ²¸¶½ÅÀÌ ÀÖ´Â 66 ¸ÊÀº 300 x 300 ¸ÊÀÌ´Ù.
      if ( CX < 50 ) or ( CX > PEnvir.MapWidth  - 70 ) or
            ( CY < 40 ) or ( CY > PEnvir.MapHeight - 70 ) then begin
         // Å¸°ÙÀÌ ÀÖÀ¸¸é ¾ø¿£ÈÄ¿¡
         LoseTarget;
         // ³»ºÎ ¾ÈÂÊÀ¸·Î ÀÌµ¿... 10Å¸ÀÏ ¾ÈÂÊ¿¡¼­ ³ªÅ¸³ª°Ô ÇÏÀÚ. °æ°èºÎºÐÀº ¾ÈÁÁÀ½
         SpaceMove ( PEnvir.MapName,
                     random( PEnvir.MapWidth  - 140 ) + 60 ,
                     random( PEnvir.MapHeight - 130 ) + 50 ,
                     1);
      end;
   end;

   // ±âÁ¸ ½ÇÇàÀ» ÇÑ´Ù.
   inherited Run;
end;

procedure TPBKingMonster.Attack (target: TCreature; dir: byte);
var
   i, ix, iy, ix2, iy2, levelgap, push: integer;
   ixf, ixt, iyf, iyt, pwr, dam: integer;
   list: TList;
   cret: TCreature;
begin
   Self.Dir := GetNextDirection (CX, CY, target.CX, target.CY);
   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));

   ixf := _MAX(0, CX - 2); ixt := _MIN(pEnvir.MapWidth-1,  CX + 2);
   iyf := _MAX(0, CY - 2); iyt := _MIN(pEnvir.MapHeight-1, CY + 2);

   for ix := ixf to ixt do begin
      for iy := iyf to iyt do begin
         list := TList.Create;
         PEnvir.GetAllCreature (ix, iy, TRUE, list);
         for i:=0 to list.Count-1 do begin
            cret := TCreature(list[i]);
            if IsProperTarget (cret) then begin
               dam := cret.GetMagStruckDamage (self, pwr);
               if dam > 0 then begin
                  cret.StruckDamage (dam, self);
                  cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                     cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 200);
                  if Random(10) = 0 then
                     cret.MakePoison (POISON_STONE, 5, 0);
               end;
            end;
         end;
         list.Free;
      end;
   end;
   SendRefMsg (RM_HIT, self.Dir, CX, CY, Integer(target), '');
   // ¹Ð¾î³¾ ¹æÇâ È®ÀÎ
   ix := 0; iy := 0; ix2 := 0; iy2 := 0;
   case self.Dir of
   0: begin
         ix := CX;                                    iy := _MAX(0, CY - 1);
         ix2:= CX;                                    iy2:= _MAX(0, CY - 2);
      end;
   1: begin
         ix := _MIN(pEnvir.MapWidth-1,  CX + 1);      iy := _MAX(0, CY - 1);
         ix2:= _MIN(pEnvir.MapWidth-1,  CX + 2);      iy2:= _MAX(0, CY - 2);
      end;
   2: begin
         ix := _MIN(pEnvir.MapWidth-1,  CX + 1);      iy := CY;
         ix2:= _MIN(pEnvir.MapWidth-1,  CX + 2);      iy2:= CY;
      end;
   3: begin
         ix := _MIN(pEnvir.MapWidth-1,  CX + 1);      iy := _MIN(pEnvir.MapHeight-1, CY + 1);
         ix2:= _MIN(pEnvir.MapWidth-1,  CX + 2);      iy2:= _MIN(pEnvir.MapHeight-1, CY + 2);
      end;
   4: begin
         ix := CX;                                    iy := _MIN(pEnvir.MapHeight-1, CY + 1);
         ix2:= CX;                                    iy2:= _MIN(pEnvir.MapHeight-1, CY + 2);
      end;
   5: begin
         ix := _MAX(0, CX - 1);                       iy := _MIN(pEnvir.MapHeight-1, CY + 1);
         ix2:= _MAX(0, CX - 2);                       iy2:= _MIN(pEnvir.MapHeight-1, CY + 2);
      end;
   6: begin
         ix := _MAX(0, CX - 1);                       iy := CY;
         ix2:= _MAX(0, CX - 2);                       iy2:= CY;
      end;
   7: begin
         ix := _MAX(0, CX - 1);                       iy := _MAX(0, CY - 1);
         ix2:= _MAX(0, CX - 2);                       iy2:= _MAX(0, CY - 2);
      end;
   end;

   list := TList.Create;
   list.Clear;
   PEnvir.GetAllCreature (ix, iy, TRUE, list);
// MainOutMessage ('[TPBKingMonster] ix,iy,Count=' + IntToStr(ix)+'/'+IntToStr(iy)+'/'+IntToStr(list.Count));
   for i:=0 to list.Count-1 do begin
      cret := TCreature(list[i]);
      if IsProperTarget (cret) then begin
         if (not cret.Death) and ((cret.RaceServer = RC_USERHUMAN) or (cret.Master <> nil)) then begin
            levelgap := 60 - cret.Abil.Level;
            if (Random(20) < 4+levelgap) then begin
               push := 3 + Random(3);
               cret.CharPushed (Self.Dir, push);
            end;
         end;
      end;
   end;
   list.Free;

   list := TList.Create;
   PEnvir.GetAllCreature (ix2, iy2, TRUE, list);
// MainOutMessage ('[TPBKingMonster] ix2,iy2,Count=' + IntToStr(ix2)+'/'+IntToStr(iy2)+'/'+IntToStr(list.Count));
   for i:=0 to list.Count-1 do begin
      cret := TCreature(list[i]);
      if IsProperTarget (cret) then begin
         if (not cret.Death) and ((cret.RaceServer = RC_USERHUMAN) or (cret.Master <> nil)) then begin
            levelgap := 60 - cret.Abil.Level;
            if (Random(20) < 4+levelgap) then begin
               push := 3 + Random(3);
               cret.CharPushed (Self.Dir, push);
            end;
         end;
      end;
   end;
   list.Free;
end;

procedure TPBKingMonster.RangeAttack (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   i, ix, iy, ixf, ixt, iyf, iyt, pwr, dam: integer;
   sx, sy, tx, ty : integer;
   list: TList;
   cret: TCreature;
begin
   inherited RangeAttack(targ);
   // ½Ã¾ß³» ¸ðµç ÄÉ¸¯/¼ÒÈ¯¸÷ ÇÇ±ïÀ½
   for i := 0 to VisibleActors.Count-1 do begin
      cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
      if IsProperTarget (cret) then begin
         if (cret.RaceServer = RC_USERHUMAN) or (cret.Master <> nil) then begin
            dam := (cret.WAbil.HP div 4);
            cret.DamageHealth( dam, 0 ); //º¸È£ÀÇ¹ÝÁöÀû¿ë 2004-01-17
            cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                               cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 800);
         end;
      end;
   end;
end;

function  TPBKingMonster.AttackTarget: Boolean;
var
   targdir: byte;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         if (abs(CX-TargetCret.CX) <= 12) and (abs(CY-TargetCret.CY) <= 12) then begin
            if (TargetInSpitRange (TargetCret, targdir)) and (Random(3)<>0) then begin
               TargetFocusTime := GetTickCount;
               Attack (TargetCret, targdir);

               try
                  if( ( random(3)= 0) and ( VisibleActors.Count > 0  ) )then
                  begin
                     TargetCret := TCreature (PTVisibleActor(VisibleActors[ Random(VisibleActors.Count) ]).cret);
                     if ( TargetCret <> nil )then
                     begin
                        SetTargetXY (TargetCret.CX, TargetCret.CY);
                     end;
                  end;
               except
                    MainOutMessage ('[Exception] TPBKingMonster.AttackTarget fail target change 1');
               end;

               Result := TRUE;
            end else begin
               if ChainShot < ChainShotCount-1 then begin
                  Inc (ChainShot);
                  TargetFocusTime := GetTickCount;
                  RangeAttack (TargetCret);
               end else begin
                  if Random(5) = 0 then
                     ChainShot := 0;
                  // 3ÃÊ
                  try

                  if ( GetCurrentTime > LongInt( 3000 + TargetFocusTime )) and ( VisibleActors.Count > 0 ) then
                  begin
                     TargetCret := TCreature (PTVisibleActor(VisibleActors[ Random(VisibleActors.Count) ]).cret);
                     if ( TargetCret <> nil )then
                     begin
                        SetTargetXY (TargetCret.CX, TargetCret.CY);
                        TargetFocusTime := GetTickCount;
                     end;
                  end;

                  except
                    MainOutMessage ('[Exception] TPBKingMonster.AttackTarget fail target change 2');
                  end;
               end;
               Result := TRUE;
            end;
         end else begin
            if TargetCret.MapName = self.MapName then begin
               if (abs(CX-TargetCret.CX) <= 11) and (abs(CY-TargetCret.CY) <= 11) then begin
                  SetTargetXY (TargetCret.CX, TargetCret.CY)
               end;
            end else begin
               LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
            end;
         end;
      end;
   end;
end;

//È²±ÝÀÌ¹«±â(ºÎ·æ±Ý»ç) =====================================================================
constructor TGoldenImugi.Create;
begin
   inherited Create;
   ViewRange := 12;
   TwinGenDelay := 100;  //3ÃÊ´ÜÀ§
   sectick := GetTickCount;
//   DontBagItemDrop := TRUE;
//   DontBagGoldDrop := TRUE;
   BoNoItem := TRUE;
   FirstCheck := TRUE;

   DontAttack := TRUE;
   DontAttackCheck := FALSE;
   AttackState := FALSE;
   InitialState := FALSE;
   ChildMobRecalled := FALSE;
   FinalWarp := FALSE;

   RevivalTime := GetTickCount;
   WarpTime := GetTickCount;

   TargetTime := GetTickCount;
   RangeAttackTime := GetTickCount;
   OldTargetCret := nil;
end;

procedure TGoldenImugi.RunMsg (msg: TMessageInfo);
begin
   case msg.Ident of
      RM_MAKEPOISON:
         begin
            DontAttack := FALSE;
         end;
   end;

   inherited RunMsg (msg);
end;

procedure TGoldenImugi.Run ;
var
   ix, iy, ndir: integer;
   nx, ny: integer;
   cret: TCreature;
   imugicount, snakecount: integer;
begin
   cret := nil;
   snakecount := 0;
   // Â¦ÀÌ¹«±â »ý¼º Á¶°Ç
   // 3ÃÊ¿¡ ÇÑ¹ø¾¿ °Ë»ç
   if GetTickCount - sectick > 3000 then begin
      BreakHolySeize;
      imugicount := 0;
      sectick := GetTickCount;
      if PEnvir <> nil then begin
         for ix := 0 to PEnvir.MapWidth -1 do begin
            for iy := 0 to PEnvir.MapHeight -1 do begin
               cret := TCreature (PEnvir.GetCreature (ix, iy, TRUE));
               if cret <> nil then begin
                  if (not cret.Death) and (cret.RaceServer = RC_GOLDENIMUGI) then begin
                     if not self.Death then begin
                        if DontAttackCheck then
                           TGoldenImugi(cret).DontAttack := FALSE
                        else if DontAttack = FALSE then
                           DontAttackCheck := TRUE;
                     end;
                     Inc(imugicount);
                     if imugicount > 2 then begin
                        cret.MakeGhost(8);
                     end;
                     // ÀÌ ºÎºÐÀº µÎ¹øÂ° ÀÌ¹«±â¸¸ »ý°¢ÇÏ´Â ºÎºÐ.
                     if (imugicount = 2) and (cret <> self) then begin
                        // ÀÏÁ¤ ¹üÀ§ ÀÌ»ó ¶³¾îÁ® ÀÖÀ¸¸é Â¦ÀÌ¹«±â ÀÚ¸®·Î ÀÌµ¿ÇÑ´Ù.
                        if (abs(cret.CX - self.CX) >= 10) or (abs(cret.CY - self.CY) >= 10) then begin
                           // ³»°¡ WarpTimeÀÌ ¿À·¡µÆÀ¸¸é ³»°¡ ¿öÇÁÇÑ´Ù.
                           if self.WarpTime < TGoldenImugi(cret).WarpTime then begin
                              // ¿öÇÁ NormalEffect
                              SendRefMsg (RM_NORMALEFFECT, 0, CX, CY, NE_SN_MOVEHIDE, '');
                              SpaceMove (cret.PEnvir.MapName, cret.CX, cret.CY, 0);
                              WarpTime := GetTickCount;
                              SendRefMsg (RM_NORMALEFFECT, 0, CX, CY, NE_SN_MOVESHOW, '');
                           end else begin
                              // ³»°¡ WarpTimeÀÌ ÃÖ±ÙÀÌ¸é WarpTimeÀÌ ¿À·¡µÈ ÀÌ¹«±â°¡ ¿öÇÁÇÑ´Ù.
                              // ¿öÇÁ NormalEffect
                              cret.SendRefMsg (RM_NORMALEFFECT, 0, cret.CX, cret.CY, NE_SN_MOVEHIDE, '');
                              cret.SpaceMove (self.PEnvir.MapName, self.CX, self.CY, 0);
                              TGoldenImugi(cret).WarpTime := GetTickCount;
                              cret.SendRefMsg (RM_NORMALEFFECT, 0, cret.CX, cret.CY, NE_SN_MOVESHOW, '');
                           end;
                        end;
                        // ³Ê¹« °¡±îÀÌ ÀÖÀ¸¸é ¶³¾î¶ß¸°´Ù.
                        if (abs(cret.CX - self.CX) <= 2) and (abs(cret.CY - self.CY) <= 2) then begin
                           //µµ¸Á°¨.
                           if Random(3) = 0 then begin
                              ndir := GetNextDirection (cret.CX, cret.CY, self.CX, self.CY);
                              GetNextPosition (PEnvir, cret.CX, cret.CY, ndir, 5, self.TargetX, self.TargetY);
                           end;
                        end;
                     end;
                  end;
                  if (not cret.Death) and (cret.UserName = __WhiteSnake) then begin
                     Inc(snakecount);
                  end;
               end;
            end;
         end;
      end;

      //Ã³À½ Ã¼Å©ÀÎ °æ¿ì
      if FirstCheck then begin
         FirstCheck := FALSE;
         TwinGenDelay := 1;
      end;

      // ÀÌ¹«±â°¡ È¥ÀÚ ÀÖÀ¸¸é Â¦ÀÌ¹«±â¸¦ »ý¼ºÇÑ´Ù.(ºÎÈ°)
      if imugicount = 1 then begin
         if TwinGenDelay <= 0 then begin
            cret := UserEngine.AddCreatureSysop (PEnvir.MapName, _MIN(CX+2, PEnvir.MapWidth-1), CY, __GoldenImugi);
            if cret <> nil then begin
               if not DontAttack then begin
                  {$IFDEF KOREA}
                  UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' -' + __GoldenImugi + ' ÁÖÀ§¿¡ ºÎÈ°ÀÇ ±â¿îÀÌ ´À²¸Áý´Ï´Ù.');
                  {$ELSE}
                  UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' -' + __GoldenImugi + ' has recalled its clone.');
                  {$ENDIF}
               end;
               // ºÎÈ° ½ÃÅ² ½Ã°£
               RevivalTime := GetTickCount;

               // ºÎÈ° ½ÃÀü NormalEffect
               SendRefMsg (RM_LIGHTING, self.Dir, self.CX, self.CY, Integer(self), '');
               // ºÎÈ° NormalEffect
               cret.SendRefMsg (RM_NORMALEFFECT, 0, cret.CX, cret.CY, NE_SN_RELIVE, '');
               // Ã¼·Â Á¶Á¤
               if not DontAttack then begin
                  cret.WAbil.HP := (cret.WAbil.MaxHP div 3) * 2;
               end;

               if DontAttack then begin
                  //°ø°Ý »óÅÂ°¡ ¾Æ´Ï¸é ºÎÈ° ½ÃÅ² ÈÄ¿¡ ´Ù½Ã Àáµç´Ù.
                  InitialState := FALSE;
               end;
            end;
            TwinGenDelay := 100;
         end;
         Dec(TwinGenDelay);

         //ÀÌ¹«±â°¡ ÇÑ¸¶¸® ³²¾Æ ÀÖÀ¸¸é ½ÃÃ¼¸¦ ¸¸µéÁö ¾Ê´Â´Ù.
         if Death then begin
            MakeGhost(8);
         end;
      end else if imugicount >= 2 then begin
         FirstCheck := FALSE;
         TwinGenDelay := 100;
      end;
   end;

   if DontAttack = FALSE then begin
      if AttackState = FALSE then begin
         SendRefMsg (RM_TURN, Dir, CX, CY, 0, '');
         AttackState := TRUE;
         BoDontMove := FALSE;
      end;
   end else begin
      if InitialState = FALSE then begin
         SendRefMsg (RM_DIGDOWN, Dir, CX, CY, 0, '');
         InitialState := TRUE;
         BoDontMove := TRUE;
      end;
   end;

   //¹é»ç ¸¶¸®¼ö * Ã¼·Â È¸º¹·®
   if snakecount > 0 then begin
      AddAbil.HealthRecover := snakecount * 2;
      HealthRecover := AddAbil.HealthRecover;
   end else begin
      AddAbil.HealthRecover := 0;
      HealthRecover := AddAbil.HealthRecover;
   end;

   //Ã¼·ÂÀÌ 50% ³²¾ÒÀ»¶§ ¹é»ç ¼ÒÈ¯
   if WAbil.HP <= WAbil.MaxHP div 2 then begin
      if not ChildMobRecalled then begin
         GetFrontPosition(self, nx, ny);
         UserEngine.AddCreatureSysop (PEnvir.MapName, nx, ny, __WhiteSnake);
         UserEngine.AddCreatureSysop (PEnvir.MapName, nx, ny, __WhiteSnake);
         ChildMobRecalled := TRUE;
      end;
   end;

   //Ã¼·ÂÀÌ 10% ³²¾ÒÀ»¶§ ·£´ý ¿öÇÁ
   if WAbil.HP <= WAbil.MaxHP div 10 then begin
      if not FinalWarp then begin
         //60ÃÊ µ¿¾È ¹æ¾î·Â/¸¶¹æ·Â Áõ°¡
         MagDefenceUp(60, 20);
         MagMagDefenceUp(60, 20);
         LoseTarget;

         // ¿öÇÁ NormalEffect
         SendRefMsg (RM_NORMALEFFECT, 0, CX, CY, NE_SN_MOVEHIDE, '');
//         SpaceMove (PEnvir.MapName, Random(PEnvir.MapWidth), Random(PEnvir.MapHeight), 0);
         RandomSpaceMoveInRange(0, 30, 80);
         WarpTime := GetTickCount;
         SendRefMsg (RM_NORMALEFFECT, 0, CX, CY, NE_SN_MOVESHOW, '');
         FinalWarp := TRUE;
      end;
   end;

   // ±âÁ¸ ½ÇÇàÀ» ÇÑ´Ù.
   inherited Run;
end;

procedure  TGoldenImugi.Attack (targ: TCreature; dir: byte);
var
   i, k,  mx, my, dam, armor: integer;
   cret: TCreature;
   pwr: integer;
begin
   //targ´Â ¾²ÀÌÁö ¾ÊÀ½

   self.Dir := dir;
   with WAbil do
      dam := Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1);
   if dam <= 0 then exit;

   SendRefMsg (RM_HIT, self.Dir, CX, CY, 0, '');

   with WAbil do
      pwr := GetAttackPower (Lobyte(DC), SmallInt(Hibyte(DC)-Lobyte(DC)));
   for i:=0 to 4 do
      for k:=0 to 4 do begin
         if SpitMap[dir, i, k] = 1 then begin
            mx := CX - 2 + k;
            my := CY - 2 + i;
            cret := TCreature (PEnvir.GetCreature (mx, my, TRUE));
            if (cret <> nil) and (cret <> self) then begin
               if IsProperTarget(cret) then begin //cret.RaceServer = RC_USERHUMAN then begin
                  //¸Â´ÂÁö °áÁ¤
                  if Random(cret.SpeedPoint) < AccuracyPoint then begin
                     {inherited} HitHit2 (cret, 0, pwr, TRUE);
                  end;
               end;
            end;
         end;
      end;
end;

procedure TGoldenImugi.RangeAttack (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   i, pwr, dam: integer;
   sx, sy, tx, ty : integer;
   list: TList;
   cret: TCreature;
begin
   if targ = nil then exit;

   Self.Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
   SendRefMsg (RM_LIGHTING_1, self.Dir, CX, CY, Integer(targ), '');
   if GetNextPosition (PEnvir, CX, CY, dir, 1, sx, sy) then begin
      GetNextPosition (PEnvir, CX, CY, dir, 9, tx, ty);
      with WAbil do
         pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );

      list := TList.Create;
      PEnvir.GetCreatureInRange (targ.CX, targ.CY, 1, TRUE, list);
      for i:=0 to list.Count-1 do begin
         cret := TCreature(list[i]);
         if IsProperTarget (cret) then begin
            dam := cret.GetMagStruckDamage (self, pwr);
            if dam > 0 then begin
               cret.StruckDamage (dam, self);
               cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                  cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 800);
            end;
         end;
      end;
      list.Free;
   end;
end;

procedure TGoldenImugi.RangeAttack2 (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   i, ix, iy, ixf, ixt, iyf, iyt, pwr, dam: integer;
   sx, sy, tx, ty : integer;
   list: TList;
   cret: TCreature;
begin
   if targ = nil then exit;

   // µ¶¾È°³ NormalEffect
   SendRefMsg (RM_LIGHTING, self.Dir, CX, CY, Integer(self), '');
   SendRefMsg (RM_NORMALEFFECT, 0, CX, CY, NE_POISONFOG, '');

   // ½Ã¾ß³» ¸ðµç Ä³¸¯/¼ÒÈ¯¸÷ Áßµ¶
   for i := 0 to VisibleActors.Count-1 do begin
      cret := TCreature (PTVisibleActor(VisibleActors[i]).cret);
      if (not cret.Death) and IsProperTarget (cret) then begin
         if (cret.RaceServer = RC_USERHUMAN) or (cret.Master <> nil) then begin
            //¹æ¾î·ÂÀÌ °¨¼ÒÇÏ´Â µ¶¿¡ Áßµ¶ µÈ´Ù.
            if Random(2 + cret.AntiPoison) = 0 then
               cret.MakePoison (POISON_DAMAGEARMOR, 60, 5);
         end;
      end;
   end;
end;

function  TGoldenImugi.AttackTarget: Boolean;
var
   targdir: byte;
   cret: TCreature;
begin
   Result := FALSE;
   cret := nil;
   if DontAttack then begin
      LoseTarget;
      exit;
   end;

   if ( GetCurrentTime < LongInt( LongWord(Random(3000) + 4000) + TargetTime ) ) then begin
      if OldTargetCret <> nil then
         TargetCret := OldTargetCret;
   end;

   if TargetCret <> nil then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         if (abs(CX-TargetCret.CX) <= 11) and (abs(CY-TargetCret.CY) <= 11) then begin
            if ((TargetInSpitRange (TargetCret, targdir)) and (Random(3) < 2)) or (GetTickCount - RevivalTime < 3000) then begin
               TargetFocusTime := GetTickCount;
               Dir := GetNextDirection (CX, CY, TargetCret.CX, TargetCret.CY);
               Attack (TargetCret, targdir);

//UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' Attack : ' + TargetCret.UserName);//test

               Result := TRUE;
            end else begin
               if ( GetCurrentTime < LongInt( 8000 + TargetTime ) ) then begin
                  TargetFocusTime := GetTickCount;
                  if (GetCurrentTime < LongInt(30000 + RangeAttackTime)) and (Random(10)<8) then begin
                     RangeAttack (TargetCret);
//UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' RangeAttack : ' + TargetCret.UserName);//test
                  end else begin
                     RangeAttack2 (TargetCret);
                     RangeAttackTime := GetTickCount;
//UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' RangeAttack (2)');//test
                  end;
               end else begin
                  try
                     if ( VisibleActors.Count > 0 ) then begin
                        cret := TCreature (PTVisibleActor(VisibleActors[ Random(VisibleActors.Count) ]).cret);
                        if cret <> nil then begin
                           if not cret.Death then begin
                              TargetCret := cret;
                              OldTargetCret := TargetCret;
//UserEngine.CryCry (RM_CRY, PEnvir, CX, CY, 10000, ' Targeting : ' + TargetCret.UserName);//test
                              SetTargetXY (TargetCret.CX, TargetCret.CY);
                              TargetFocusTime := GetTickCount;
                              TargetTime := GetTickCount;
                           end;
                        end;
                     end;
                  except
                    MainOutMessage ('[Exception] TGoldenImugi.AttackTarget fail target change 3');
                  end;
               end;
               Result := TRUE;
            end;
         end else begin
            if TargetCret.MapName = self.MapName then begin
               if (abs(CX-TargetCret.CX) <= ViewRange) and (abs(CY-TargetCret.CY) <= ViewRange) then begin
                  SetTargetXY (TargetCret.CX, TargetCret.CY)
               end;
            end else begin
               LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
            end;
         end;
      end;
   end;
end;

procedure TGoldenImugi.Struck (hiter: TCreature);
begin
   // ¸ÂÀ¸¸é °ø°Ý¸ðµå·Î º¯°æ
   DontAttack := FALSE;
end;

procedure TGoldenImugi.Die;
var
   ix, iy: integer;
   cret: TCreature;
   imugicount: integer;
begin
   imugicount := 0;
   //³»°¡ ¸¶Áö¸· ÀÌ¹«±âÀÌ¸é ¾ÆÀÌÅÛÀ» ¶³±º´Ù.
   if PEnvir <> nil then begin
      for ix := 0 to PEnvir.MapWidth -1 do begin
         for iy := 0 to PEnvir.MapHeight -1 do begin
            cret := TCreature (PEnvir.GetCreature (ix, iy, TRUE));
            if cret <> nil then begin
               if (not cret.Death) and (cret.RaceServer = RC_GOLDENIMUGI) then begin
                  Inc(imugicount);
               end;
            end;
         end;
      end;
   end;
   if imugicount = 1 then begin
//      DontBagItemDrop := FALSE;
//      DontBagGoldDrop := FALSE;
      BoNoItem := FALSE;
   end;

   inherited Die;
end;

//¹°¸® ¿ø°Å¸® °ø°Ý ¸ó½ºÅÍ(sonmg 2005/12/23)
constructor TPhisicalFarAttackMonster.Create;
begin
   inherited Create;
   ChainShotCount := 6;
   BoCallFollower := FALSE;
end;

procedure TPhisicalFarAttackMonster.RangeAttack (targ: TCreature); //¹Ýµå½Ã target <> nil
var
   i, pwr, dam: integer;
   sx, sy, tx, ty : integer;
   list: TList;
   cret: TCreature;
begin
   if targ = nil then exit;

   Self.Dir := GetNextDirection (CX, CY, targ.CX, targ.CY);
   SendRefMsg (RM_LIGHTING, self.Dir, CX, CY, Integer(targ), '');
   if GetNextPosition (PEnvir, CX, CY, dir, 1, sx, sy) then begin
      GetNextPosition (PEnvir, CX, CY, dir, 9, tx, ty);
      //Å¸°Ù ·¹º§¿¡ µû¸¥ µ¥¹ÌÁö Á¶Á¤
      if (MultiplyTargetLevelMin > 0) and (MultiplyTargetLevelMax > 0) then begin
         with WAbil do
            pwr := _MAX( 0, Trunc(targ.Abil.Level * MultiplyTargetLevelMin div 100) + Lobyte(DC) + Random((Trunc(targ.Abil.Level * MultiplyTargetLevelMax div 100) + Hibyte(DC)-Lobyte(DC)) + 1) );
      end else begin
         with WAbil do
            pwr := _MAX( 0, Lobyte(DC) + Random(SmallInt(Hibyte(DC)-Lobyte(DC)) + 1) );
      end;

      list := TList.Create;
      PEnvir.GetAllCreature (targ.CX, targ.CY, TRUE, list);
      for i:=0 to list.Count-1 do begin
         cret := TCreature(list[i]);
         if IsProperTarget (cret) then begin
            dam := cret.GetHitStruckDamage (self, pwr);
            if dam > 0 then begin
               cret.StruckDamage (dam, self);
               cret.SendDelayMsg (TCreature(RM_STRUCK), RM_REFMESSAGE, dam{wparam},
                                  cret.WAbil.HP{lparam1}, cret.WAbil.MaxHP{lparam2}, Longint(self){hiter}, '', 800);
            end;
         end;
      end;
      list.Free;
   end;
end;

function  TPhisicalFarAttackMonster.AttackTarget: Boolean;
var
   targdir: byte;
   nx, ny: integer;
begin
   Result := FALSE;
   if TargetCret <> nil then begin
      if GetCurrentTime - HitTime > GetNextHitTime then begin
         HitTime := GetCurrentTime;
         if TargetCret.MapName = self.MapName then begin
            if (abs(CX-TargetCret.CX) <= 5) and (abs(CY-TargetCret.CY) <= 5) then begin
               if (abs(CX-TargetCret.CX) <= 2) and (abs(CY-TargetCret.CY) <= 2) then begin
                  if Random(3) = 0 then begin
                     //³Ê¹« °¡±î¿ì¸é µµ¸Á°¨.
                     GetBackPosition (self, TargetX, TargetY);
                     if TargetX <> -1 then begin //°¡¾ßÇÒ °÷ÀÌ ÀÖÀ½
                        GotoTargetXY;
                     end;
                  end;
               end;

               if (TargetInAttackRange (TargetCret, targdir)) and (Random(3)<>0) then begin
                  TargetFocusTime := GetTickCount;
                  RangeAttack (TargetCret);
                  Result := TRUE;
               end else begin
                  if ChainShot < ChainShotCount-1 then begin
                     Inc (ChainShot);
                     TargetFocusTime := GetTickCount;
                     RangeAttack (TargetCret);
                  end else begin
                     if Random(5) = 0 then
                        ChainShot := 0;
                  end;
                  Result := TRUE;
               end;
            end else begin
               if Random(2) = 0 then begin
                  Dir := GetNextDirection (CX, CY, TargetCret.CX, TargetCret.CY);
                  //³Ê¹« ¸Ö¸é °¡±îÀÌ °¨.
                  if GetNextPosition (PEnvir, CX, CY, Dir, 1, nx, ny) then begin
                     SetTargetXY (nx, ny)
                  end;
               end;
            end;
         end else begin
            LoseTarget;  //<!!ÁÖÀÇ> TargetCret := nil·Î ¹Ù²ñ
         end;
      end;
   end;
end;


end.
