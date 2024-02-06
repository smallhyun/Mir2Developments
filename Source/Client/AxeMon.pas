unit AxeMon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grobal2, HGETextures,  ClFunc, magiceff, Actor, SoundUtil, ClEvent, ExtCtrls;

const
   DEATHEFFECTBASE = 340;
   DEATHFIREEFFECTBASE = 2860;
   AXEMONATTACKFRAME = 6;
   KUDEGIGASBASE = 1445;
   COWMONFIREBASE = 1800;
   COWMONLIGHTBASE = 1900;
   ZOMBILIGHTINGBASE = 350;
   ZOMBIDIEBASE = 340;
   ZOMBILIGHTINGEXPBASE = 520;
   SCULPTUREFIREBASE = 1680;
   MOTHPOISONGASBASE = 3590;
   DUNGPOISONGASBASE = 3590;
   WARRIORELFFIREBASE = 820;
   SUPERIORGUARDEFFECTBASE = 760;
   ELECTRONICSCOPIONEFFECTBASE = 430;
   KINGBIGEFFECTBASE = 860;
   KINGOFSCOLPTUREKINGEFFECTBASE = 1380;
   KINGOFSCOLPTUREKINGDEATHEFFECTBASE = 1470;
   KINGOFSCOLPTUREKINGATTACKEFFECTBASE = 1490;
   // 2003/02/11
   TOXICPOISONGASBASE = 720;
   SAMURAIDIEBASE = 350;
   SKELMUJANGDIEBASE = 1160;
   SKELSOLDIERDIEBASE = 1600;
   SKELSAMURAIDIEBASE = 1600;
   SKELARCHERDIEBASE = 1600;
   SKELETONKINGEFFECT1BASE = 2980;     //������
   SKELETONKINGEFFECT2BASE = 3060;     //�̵�
   SKELETONKINGEFFECT3BASE = 3140;     //��������
   SKELETONKINGEFFECT4BASE = 3220;     //��ȯ����
   SKELETONKINGEFFECT5BASE = 3300;     //���Ÿ�����
   SKELETONKINGEFFECT6BASE = 3380;     //�±�
   SKELETONKINGEFFECT7BASE = 3400;     //�ױ�
   SKELETONKINGEFFECT8BASE = 3570;     //���󰡴� ����Ʈ
   // 2003/03/04
   BANYAGUARDRIGHTDIEBASE  = 2320;           //�ݾ߿�� �ױ�
   BANYAGUARDLEFTDIEBASE   = 2870;           //�ݾ��»� �ױ�
   BANYAGUARDRIGHTHITBASE  = 2230;           //�ݾ߿�� ����
   BANYAGUARDLEFTHITBASE   = 2780;           //�ݾ��»� ����
   BANYAGUARDLEFTFLYBASE   = 2960;           //�ݾ߿�� ����
   DEADCOWKINGHITBASE      = 3490;           //���õ�� ����
   DEADCOWKINGFLYBASE      = 3580;           //���õ�� ���Ÿ�����
   // 2003/07/15
   PBSTONE1IDLEBASE        = 2490;           //���輮1 ������
   PBSTONE1ATTACKBASE      = 2500;           //���輮1 ����
   PBSTONE1DIEBASE         = 2530;           //���輮1 �ױ�
   PBSTONE2IDLEBASE        = 2620;           //���輮2 ������
   PBSTONE2ATTACKBASE      = 2630;           //���輮2 ����
   PBSTONE2DIEBASE         = 2660;           //���輮2 �ױ�
   PBKINGATTACK1BASE       = 3440;           //�츶��õȲ ����1
   PBKINGATTACK2BASE       = 3520;           //�츶��õȲ ����2
   PBKINGDIEBASE           = 3120;           //�츶��õȲ �ױ�

type
   TSkeletonOma = class (TActor)
   private
   protected
      EffectSurface: TDXTexture;
      ax, ay: integer;
      SitDown : Boolean;
   public
      constructor Create; override;
      //destructor Destroy; override;
      procedure CalcActorFrame; override;
      function  GetDefaultFrame (wmode: Boolean): integer; override;
      procedure LoadSurface; override;
      procedure Run; override;
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
   end;

   TDualAxeOma = class (TSkeletonOma)  //���������� ��
   private
   public
      procedure Run; override;
   end;

   TCatMon = class (TSkeletonOma)
   private
   public
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
   end;

   TArcherMon = class (TCatMon)
   public
      procedure Run; override;
   end;

   TScorpionMon = class (TCatMon)
   public
   end;

   THuSuABi = class (TSkeletonOma)
   public
      procedure LoadSurface; override;
   end;

   TZombiDigOut = class (TSkeletonOma)
   public
      procedure RunFrameAction (frame: integer); override;
   end;

   TZombiZilkin = class (TSkeletonOma)
   public
   end;

   TWhiteSkeleton = class (TSkeletonOma)
   public
   end;


   TGasKuDeGi = class (TActor)
   protected
      AttackEffectSurface: TDXTexture;
      DieEffectSurface: TDXTexture;
      BoUseDieEffect: Boolean;
      firedir, fire16dir, ax, ay, bx, by: integer;
   public
      constructor Create; override;
      procedure CalcActorFrame; override;
      function  GetDefaultFrame (wmode: Boolean): integer; override;
      procedure LoadSurface; override;
      procedure Run; override;
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;

   TFireCowFaceMon = class (TGasKuDeGi)
   public
      function   Light: integer; override;
   end;

   TCowFaceKing = class (TGasKuDeGi)
   public
      function   Light: integer; override;
   end;

   TZombiLighting = class (TGasKuDeGi)
   protected
   public
   end;

   TSuperiorGuard = class (TGasKuDeGi)   //���� ���
   public
   end;

   TExplosionSpider = class (TGasKuDeGi)  //����
   public
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
   end;

   TFlyingSpider = class (TSkeletonOma)  //�񵶰Ź�
   public
      procedure CalcActorFrame; override;
   end;

   TSculptureMon = class (TSkeletonOma)
   private
      AttackEffectSurface: TDXTexture;
      ax, ay, firedir: integer;
   public
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
      function  GetDefaultFrame (wmode: Boolean): integer; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
      procedure Run; override;
   end;

   TSculptureKingMon = class (TSculptureMon)
   public
   end;

   TSmallElfMonster = class (TSkeletonOma)
   public
   end;

   TWarriorElfMonster = class (TSkeletonOma)
   private
      oldframe: integer;
   public
      procedure  RunFrameAction (frame: integer); override;  //�����Ӹ��� ��Ư�ϰ� �ؾ�����
   end;

   TElectronicScolpionMon = class (TGasKuDeGi)   //������(����)
   public
      procedure CalcActorFrame; override;
      procedure  LoadSurface; override;
   end;

   TBossPigMon = class (TGasKuDeGi)              //�յ�
   public
      procedure  LoadSurface; override;
   end;

   TKingOfSculpureKingMon = class (TGasKuDeGi)   //�ָ�����(���߿�)
   public
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
   end;

   // 2003/02/11 �ű� �� �߰�
   TSkeletonKingMon = class (TGasKuDeGi)   //�ذ�ݿ�
   public
      procedure Run; override;
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
   end;
   TSamuraiMon = class (TGasKuDeGi)   //���α�
   public
   end;
   TSkeletonSoldierMon = class (TGasKuDeGi)   //�ذ���,�ذ񹫻�,�ذ���
   public
   end;
   TSkeletonArcherMon = class (TArcherMon)   //�ذ�ü�
   protected
      DieEffectSurface: TDXTexture;
      BoUseDieEffect: Boolean;
      bx, by: integer;
   public
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
      procedure Run; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;

   // 2003/03/04 �ű� �� �߰�
   TBanyaGuardMon = class (TSkeletonArcherMon)   //�ݾ߿��,�ݾ��»�,���õ��
   protected
      AttackEffectSurface: TDXTexture;
   public
      constructor Create; override;
      procedure Run; override;
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;

   // 2003/07/15 ���ź�õ �� �߰�...���輮
   TStoneMonster = class(TSkeletonArcherMon)
   protected
      AttackEffectSurface: TDXTexture;
   public
      constructor Create; override;
      procedure Run; override;
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;
   TPBOMA1Mon = class (TCatMon)
   public
      procedure Run; override;
   end;
   TPBOMA6Mon = class (TCatMon)
   public
      procedure Run; override;
   end;

   TAngel = class (TBanyaGuardMon)
   px2, py2 :integer;
   BodySurface2: TDXTexture;
   public
      procedure LoadSurface; override;
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
   end;

   TFireDragon = class (TSkeletonArcherMon)
      LightningTimer: TTimer;
   protected
      AttackEffectSurface: TDXTexture;
   public
      procedure LightningTimerTimer(Sender: TObject);
      constructor Create; override;
      destructor  Destroy; override;
      procedure Run; override;
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;

   TDragonStatue = class (TSkeletonArcherMon) // �뼮��
   protected
      AttackEffectSurface: TDXTexture;
   public
      constructor Create; override;
      procedure Run; override;
      procedure CalcActorFrame; override;
      procedure LoadSurface; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;

   TJumaThunderMon = class (TSculptureMon) // �ָ��ݷ���
   public
      constructor Create; override;
      procedure LoadSurface; override;
      procedure DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
//      function  GetDefaultFrame (wmode: Boolean): integer; override;
      procedure CalcActorFrame; override;
//      procedure Run; override;
//      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
   end;


implementation

uses
   ClMain, Wil, MShare;


{============================== TSkeletonOma =============================}

//      �ذ� ����(�ذ�, ū�����ذ�, �ذ�����)

{--------------------------}


constructor TSkeletonOma.Create;
begin
   inherited Create;
   EffectSurface := nil;
   BoUseEffect := FALSE;
end;

procedure TSkeletonOma.CalcActorFrame;
var
   pm: PTMonsterAction;
   haircount: integer;
begin
   currentframe := -1;
   ReverseFrame := FALSE;
   BoUseEffect := FALSE;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;
   case CurrentAction of
      SM_TURN:
         begin
            if Race in [93,100] then SitDown := False; // ȯ����ȣ, �̹���
            if Race in [107,108,109] then startframe := pm.ActStand.start
            else startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
            endframe := startframe + pm.ActStand.frame - 1;
            frametime := pm.ActStand.ftime;
            if Race in [93,94] then frametime := 200; //ȯ����ȣ,�Ź�(�ż�������) �����Ӽӵ�
            starttime := GetTickCount;
            defframecount := pm.ActStand.frame;
            Shift (Dir, 0, 0, 1);

            if Race in [108,109] then begin
               BoUseEffect := TRUE;
               effectstarttime := GetTickCount;
            end;

         end;
      SM_WALK, SM_BACKSTEP:
         begin
            if Race in [93,100] then SitDown := False; // ȯ����ȣ, �̹���
            if Race in [107,108,109] then startframe := pm.ActWalk.start
            else startframe := pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe + pm.ActWalk.frame - 1;
            frametime := WalkFrameDelay; //pm.ActWalk.ftime;
            if Race in [93,94] then frametime := 150; //ȯ����ȣ,�Ź�(�ż�������) �����Ӽӵ�
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            //WarMode := FALSE;
            movestep := 1;
            if Race in [108,109] then begin
               if (Random(3000) mod 3) = 1 then begin
                  if Race = 108 then PlaySound(2551);
                  if Race = 109 then PlaySound(2561);
               end;
               BoUseEffect := TRUE;
               effectstarttime := GetTickCount;
            end;

            if CurrentAction = SM_WALK then
               Shift (Dir, movestep, 0, endframe-startframe+1)
            else  //sm_backstep
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
         end;
      SM_DIGUP: //�ȱ� ����, SM_DIGUP, ���� ����.
         begin
            if Race in [93,100] then SitDown := False;
            if (Race = 23) or (Race = 81) then begin //or (Race = 54) or (Race = 55) then begin
               //���
               startframe := pm.ActDeath.start;
            end else begin
               startframe := pm.ActDeath.start + Dir * (pm.ActDeath.frame + pm.ActDeath.skip);
            end;
            endframe := startframe + pm.ActDeath.frame - 1;
            frametime := pm.ActDeath.ftime;
            starttime := GetTickCount;
            //WarMode := FALSE;
            Shift (Dir, 0, 0, 1);
         end;
      SM_DIGDOWN:
         begin
            if Race = 55 then begin
               //�ż�1 �� ��� ������
               startframe := pm.ActCritical.start + Dir * (pm.ActCritical.frame + pm.ActCritical.skip);
               endframe := startframe + pm.ActCritical.frame - 1;
               frametime := pm.ActCritical.ftime;
               starttime := GetTickCount;
               ReverseFrame := TRUE;
               //WarMode := FALSE;
               Shift (Dir, 0, 0, 1);
            end;
//           if Race = 93 then begin // ȯ����ȣ
           if Race in [93,100] then begin // ȯ����ȣ //####
               SitDown := True;
               startframe := 420 + Dir * 10;
               endframe := startframe + 3;
               frametime := 300;
               starttime := GetTickCount;
//               ReverseFrame := TRUE;
               //WarMode := FALSE;
               Shift (Dir, 0, 0, 1);
            end;
         end;
      SM_HIT,
      SM_FLYAXE,
      SM_LIGHTING:
         begin
            if Race in [111,112] then startframe := 340 + Dir * 10
            else startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;
            //WarMode := TRUE;
            WarModeTime := GetTickCount;

            if (Race = 16) or (Race = 54) then
               BoUseEffect := TRUE;
            Shift (Dir, 0, 0, 1);
         end;
      SM_STRUCK:
         begin
            if Race in [93,100] then SitDown := False; //ȯ����ȣ, �̹���
            if Race in [107,108,109] then startframe := pm.ActStruck.start
            else startframe := pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
            endframe := startframe + pm.ActStruck.frame - 1;
            frametime := struckframetime; //pm.ActStruck.ftime;
            if Race = 93 then frametime := 110 //ȯ����ȣ �����Ӽӵ�
            else if Race = 94 then frametime := 130; //�Ź�(�ż�������) �����Ӽӵ�
            endframe := startframe + pm.ActStruck.frame - 1;
            frametime := struckframetime; //pm.ActStruck.ftime;
            starttime := GetTickCount;
            if Race in [108,109] then begin
               BoUseEffect := TRUE;
               effectstarttime := GetTickCount;
            end;
         end;
      SM_DEATH:
         begin
            if Race = 92 then BoUseEffect := False; //�ָ��ݷ����ΰ��
            if Race in [107,108,109] then startframe := pm.ActDie.start
            else startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            startframe := endframe; //
            frametime := pm.ActDie.ftime;
            if Race = 93 then frametime := 160; //ȯ����ȣ �����Ӽӵ�
            if Race = 94 then frametime := 110; //�Ź�(�ż�������) �����Ӽӵ�
            starttime := GetTickCount;
         end;
      SM_NOWDEATH:
         begin
            if Race in [107,108,109] then startframe := pm.ActDie.start
            else startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;
            if Race <> 22 then BoUseEffect := TRUE;
            if Race = 92 then BoUseEffect := False; //�ָ��ݷ����ΰ��
         end;
      SM_SKELETON:
         begin
            startframe := pm.ActDeath.start;
            endframe := startframe + pm.ActDeath.frame - 1;
            frametime := pm.ActDeath.ftime;
            starttime := GetTickCount;
         end;
{      SM_ALIVE:  //####Org
         begin
            startframe := pm.ActDeath.start + Dir * (pm.ActDeath.frame + pm.ActDeath.skip);
            endframe := startframe + pm.ActDeath.frame - 1;
            frametime := pm.ActDeath.ftime;
            starttime := GetTickCount;
         end;}
   end;
end;

function  TSkeletonOma.GetDefaultFrame (wmode: Boolean): integer;
var
   cf, dr: integer;
   pm: PTMonsterAction;
begin
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   if Death then begin
      //������ ���
      if Appearance in [30..34, 151] then //������ ��� ��ü�� ����� ���� ���� ���� ����
         DownDrawLevel := 1;

      if Skeleton then
         Result := pm.ActDeath.start
      else if Race = 110 then begin
              Result := 417;
              BoUseEffect := False;
      end
//      else if Race = 107 then Result := pm.ActStand.start + cf
      else if Race in [107,108,109] then begin
              Result := pm.ActDie.start + (pm.ActDie.frame - 1);
              BoUseEffect := False;
      end
      else Result := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip) + (pm.ActDie.frame - 1);
   end else begin
      if SitDown and (Race in [93,100]) then begin //�̹��� ####
//      DScreen.AddChatBoardString ('GetDefaultFrame : SitDown and (Race = 93)', clYellow, clRed);
         defframecount := 4;
         if currentdefframe < 0 then cf := 0
         else if currentdefframe >= 4 then cf := 0
         else cf := currentdefframe;
         Result := 420 + Dir * 10 + cf;
      end
      else begin
         defframecount := pm.ActStand.frame;
         if currentdefframe < 0 then cf := 0
         else if currentdefframe >= pm.ActStand.frame then cf := 0
         else cf := currentdefframe;
         if Race = 110 then begin
            case TempState of
               1: startframe := 0;
               2: startframe := 80;
               3: startframe := 160;
               4: startframe := 240;
               5: startframe := 320;
            end;
            Result := startframe + cf
         end
         else if Race in [107,108,109] then Result := pm.ActStand.start + cf
         else if Race in [108,109] then Result := pm.ActStand.start + cf
         else Result := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip) + cf;
      end;

      if Race in [108,109] then begin
         BoUseEffect := True;
         effectstarttime := GetTickCount;
         effectframetime := pm.ActStand.ftime;
      end;
      if Race = 108 then effectframe := 1500 + currentframe
      else if Race = 109 then effectframe := 1610 + currentframe;

      if Race = 110 then begin
         BoUseEffect := True;
         effectstarttime := GetTickCount;
         effectframetime := pm.ActStand.ftime;
         effectframe := 1710 + currentframe;
//      DScreen.AddChatBoardString ('@@@GetDefaultFrame effectframe=> '+InttoStr(effectframe), clYellow, clRed);
      end;

   end;
end;

procedure  TSkeletonOma.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      //����
      14, 15, 17, 22, 53:
         begin
            if BoUseEffect then
               EffectSurface := WMon3Img.GetCachedImage (DEATHEFFECTBASE + currentframe-startframe, ax, ay);
         end;
      23:
         begin
            if CurrentAction = SM_DIGUP then begin
               BodySurface := nil;
               EffectSurface := WMon4Img.GetCachedImage (BodyOffset + currentframe, ax, ay);
               BoUseEffect := TRUE;
            end else
               BoUseEffect := FALSE;
         end;
   end;
end;

procedure  TSkeletonOma.Run;
var
   prv: integer;
   frametimetime: longword;
   bofly: Boolean;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
         end;
      end;

      if Race = 92 then begin
         if (CurrentAction = SM_LIGHTING) and (currentframe-startframe = 4) then begin
            if BoViewEffect then begin
               PlayScene.NewMagic (self, MAGIC_DUN_THUNDER, MAGIC_DUN_THUNDER, XX, YY, TargetX, TargetY, TargetRecog, mtThunder, FALSE, 30, bofly);
               PlaySound (8301);
            end;
         end;
      end;

      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;

end;


procedure  TSkeletonOma.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   idx: integer;
   d: TDXTexture;
   ceff: TColorEffect;
begin
   if not (Dir in [0..7]) then exit;
   if GetTickCount - loadsurfacetime > 60 * 1000 then begin
      loadsurfacetime := GetTickCount;
      LoadSurface; //bodysurface���� loadsurface�� �ٽ� �θ��� �ʾ� �޸𸮰� �����Ǵ� ���� ����
   end;

   ceff := GetDrawEffectValue;

   if BodySurface <> nil then begin
      DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, blend, ceff);
   end;

   if BoViewEffect then begin
   if BoUseEffect and (Race <> 92) then //�ָ��ݷ����� �ƴϸ�..
      if EffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    EffectSurface, 1);
      end;
   end;
end;




{============================== TSkeletonOma =============================}

//      �ذ� ����(�ذ�, ū�����ذ�, �ذ�����)

{--------------------------}


procedure  TDualAxeOma.Run;
var
   prv: integer;
   frametimetime: longword;
   meff: TFlyingAxe;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   //�����Ӹ��� �ؾ� ����
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
         end;
         if (CurrentAction = SM_FLYAXE) and (currentframe-startframe = AXEMONATTACKFRAME-4) then begin //������ ���� ����
            //���� �߻�
            meff := TFlyingAxe (PlayScene.NewFlyObject (self,
                             XX,
                             YY,
                             TargetX,
                             TargetY,
                             TargetRecog,
                             mtFlyAxe));
            if meff <> nil then begin
               meff.ImgLib := WMon3Img;
               case Race of
                  15: meff.FlyImageBase := FLYOMAAXEBASE;
                  22: meff.FlyImageBase := THORNBASE;
                  111: begin
                       meff.FlyImageBase := 2356;
                       meff.ImgLib := WMon24Img;
                       end;
                  112: begin
                       meff.FlyImageBase := 2786;
                       meff.ImgLib := WMon24Img;
                       end;
               end;
            end;
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;

end;


{============================== TWarriorElfMonster =============================}

//         TCatMon : ����,  �������� �ذ��̶� ����, ������ �ִϰ� ����.


procedure  TWarriorElfMonster.RunFrameAction (frame: integer); //�����Ӹ��� ��Ư�ϰ� �ؾ�����
var
   meff: TMapEffect;
   event: TClEvent;
begin
   if CurrentAction = SM_HIT then begin
      if (frame = 5) and (oldframe <> frame) then begin
         meff := TMapEffect.Create (WARRIORELFFIREBASE + 10 * Dir + 1, 5, XX, YY);
         meff.ImgLib := WMon18Img;
         meff.NextFrameTime := 100;
         PlayScene.EffectList.Add (meff);
      end;
      oldframe := frame;
   end;
end;

{============================== TCatMon =============================}

//         TCatMon : ����,  �������� �ذ��̶� ����, ������ �ִϰ� ����.

{--------------------------}


procedure  TCatMon.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   idx: integer;
   d: TDXTexture;
   ceff: TColorEffect;
begin
   if not (Dir in [0..7]) then exit;
   if GetTickCount - loadsurfacetime > 60 * 1000 then begin
      loadsurfacetime := GetTickCount;
      LoadSurface; //bodysurface���� loadsurface�� �ٽ� �θ��� �ʾ� �޸𸮰� �����Ǵ� ���� ����
   end;

   ceff := GetDrawEffectValue;

   if BodySurface <> nil then
      if Race = 81 then //����
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, False, ceNone)
      else
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, blend, ceff);
end;


{============================= TArcherMon =============================}


procedure TArcherMon.Run;
var
   prv: integer;
   frametimetime: longword;
   meff: TFlyingAxe;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   //�����Ӹ��� �ؾ� ����
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
         end;
         if (CurrentAction = SM_FLYAXE) and (currentframe-startframe = 4) then begin
            //ȭ�� ����
//(** 6����ġ

            meff := TFlyingArrow (PlayScene.NewFlyObject (self,
                             XX,
                             YY,
                             TargetX,
                             TargetY,
                             TargetRecog,
                             mtFlyArrow));
            if meff <> nil then begin
               meff.ImgLib := WEffectImg;
               meff.NextFrameTime := 30;
               meff.FlyImageBase := ARCHERBASE2;
            end;
//**)
(** ����
            meff := TFlyingArrow (PlayScene.NewFlyObject (self,
                             XX,
                             YY,
                             TargetX,
                             TargetY,
                             TargetRecog,
                             mtFlyAxe));
            if meff <> nil then begin
               meff.ImgLib := WMon5Img;
               meff.NextFrameTime := 30;
               meff.FlyImageBase := ARCHERBASE;
            end;
//**)
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;

end;


{============================= TZombiDigOut =============================}


procedure TZombiDigOut.RunFrameAction (frame: integer);
var
   clevent: TClEvent;
begin
   if CurrentAction = SM_DIGUP then begin
      if frame = 6 then begin
         clevent := TClEvent.Create (CurrentEvent, XX, YY, ET_DIGOUTZOMBI);
         clevent.Dir := Dir;
         EventMan.AddEvent (clevent);
         //pdo.DSurface := WMon6Img.GetCachedImage (ZOMBIDIGUPDUSTBASE+Dir, pdo.px, pdo.py);
      end;
   end;
end;


{============================== THuSuABi =============================}

//      ����ƺ�

{--------------------------}


procedure  THuSuABi.LoadSurface;
begin
   inherited LoadSurface;
   if BoViewEffect then begin
   if BoUseEffect then
      EffectSurface := WMon3Img.GetCachedImage (DEATHFIREEFFECTBASE + currentframe-startframe, ax, ay);
   end;
end;


{============================== TGasKuDeGi =============================}
//      ���������� (������� ������)
{--------------------------}
constructor TGasKuDeGi.Create;
begin
   inherited Create;
   AttackEffectSurface := nil;
   DieEffectSurface := nil;
   BoUseEffect := FALSE;
   BoUseDieEffect := FALSE;
end;

procedure TGasKuDeGi.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of
      SM_TURN:
         begin
            startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
            endframe := startframe + pm.ActStand.frame - 1;
            frametime := pm.ActStand.ftime;
            starttime := GetTickCount;
            defframecount := pm.ActStand.frame;
            Shift (Dir, 0, 0, 1);
         end;
      SM_WALK:
         begin
            startframe := pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe + pm.ActWalk.frame - 1;
            frametime := WalkFrameDelay; //pm.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            //WarMode := FALSE;
            movestep := 1;
            if CurrentAction = SM_WALK then
               Shift (Dir, movestep, 0, endframe-startframe+1)
            else  //sm_backstep
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
         end;
      SM_HIT,
      SM_LIGHTING:
         begin
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;
            //WarMode := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;

            if Race = 20 then effectend := endframe + 1
            else effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;

            //16������ ���� ����
            actor := PlayScene.FindActor (TargetRecog);
            if actor <> nil then begin
               PlayScene.ScreenXYfromMCXY (XX, YY, scx, scy);
               PlayScene.ScreenXYfromMCXY (actor.XX, actor.YY, stx, sty);
               fire16dir := GetFlyDirection16 (scx, scy, stx, sty);
               //meff := TCharEffect.Create (ZOMBILIGHTINGEXPBASE, 12, actor);  //�´� ��� ȿ��
               //meff.ImgLib := WMon5Img;
               //meff.NextFrameTime := 50;
               //PlayScene.EffectList.Add (meff);
            end else
               fire16dir := firedir * 2;
         end;
      SM_STRUCK:
         begin
            startframe := pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
            endframe := startframe + pm.ActStruck.frame - 1;
            frametime := struckframetime; //pm.ActStruck.ftime;
            starttime := GetTickCount;
         end;
      SM_DEATH:
         begin
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            startframe := endframe; //
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;
         end;
      SM_NOWDEATH:
         begin
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;
            // 2003/02/11
            if (Race = 40) or (Race = 65) or (Race = 66) or (Race = 67) or (Race = 68) or (Race = 69) then  //���� ����
               BoUseDieEffect := TRUE;
         end;
      SM_SKELETON:
         begin
            startframe := pm.ActDeath.start;
            endframe := startframe + pm.ActDeath.frame - 1;
            frametime := pm.ActDeath.ftime;
            starttime := GetTickCount;
         end;
   end;
end;

function  TGasKuDeGi.GetDefaultFrame (wmode: Boolean): integer;
var
   cf, dr: integer;
   pm: PTMonsterAction;
begin
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   if Death then begin
      if Skeleton then
         Result := pm.ActDeath.start
      else if Race = 95 then
         Result := 3580
      else Result := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip) + (pm.ActDie.frame - 1);
   end else begin
      defframecount := pm.ActStand.frame;
      if currentdefframe < 0 then cf := 0
      else if currentdefframe >= pm.ActStand.frame then cf := 0
      else cf := currentdefframe;
      Result := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip) + cf;
   end;
end;

procedure  TGasKuDeGi.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      //����
      24: //���� ���,  TActor�� ��ӹ��� ����� ���ݿ� ȿ���� ����
         begin
            if BoUseEffect then
               AttackEffectSurface := WMonImg.GetCachedImage (
                        SUPERIORGUARDEFFECTBASE + Dir * 8 + effectframe-effectstart,
                        ax, ay);
         end;
      16:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon3Img.GetCachedImage (
                        KUDEGIGASBASE-1 + (firedir * 10) + effectframe-effectstart, //������ ó�� �������� �ʰ� ������.
                        ax, ay);
         end;
      20:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon4Img.GetCachedImage (
                        COWMONFIREBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;
      21:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon4Img.GetCachedImage (
                        COWMONLIGHTBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;
      40:
         begin
            if BoUseEffect then begin
               AttackEffectSurface := WMon5Img.GetCachedImage (
                        ZOMBILIGHTINGBASE + (fire16dir * 10) + effectframe-effectstart, //
                        ax, ay);
            end;
            if BoUseDieEffect then begin
               DieEffectSurface := WMon5Img.GetCachedImage (
                        ZOMBIDIEBASE + currentframe-startframe, //
                        bx, by);
            end;
         end;
      52, 95:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon4Img.GetCachedImage (
                        MOTHPOISONGASBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;
      53:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon3Img.GetCachedImage (
                        DUNGPOISONGASBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;
      // 2003/02/11 ���α�, �νı�, �ذ���, �ذ���, �ذ񹫻�, �ذ�ü� �߰�
      64:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon20Img.GetCachedImage (
                        TOXICPOISONGASBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;
      65:
         begin
            if BoUseDieEffect then begin
               DieEffectSurface := WMon20Img.GetCachedImage (
                        SAMURAIDIEBASE + currentframe-startframe, //
                        bx, by);
            end;
         end;
      66:
         begin
            if BoUseDieEffect then begin
               DieEffectSurface := WMon20Img.GetCachedImage (
                        SKELSAMURAIDIEBASE + currentframe-startframe, //
                        bx, by);
            end;
         end;
      67:
         begin
            if BoUseDieEffect then begin
               DieEffectSurface := WMon20Img.GetCachedImage (
                        SKELMUJANGDIEBASE + dir*10 + currentframe-startframe, //
                        bx, by);
            end;
         end;
      68:
         begin
            if BoUseDieEffect then begin
               DieEffectSurface := WMon20Img.GetCachedImage (
                        SKELSOLDIERDIEBASE + currentframe-startframe, //
                        bx, by);
            end;
         end;
   end;
end;

procedure  TGasKuDeGi.Run;
var
   prv: integer;
   effectframetimetime, frametimetime: longword;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   if BoUseEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
            BoUseEffect := FALSE;
         end;
      end;
   end;

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseDieEffect := FALSE;
         end;

      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;

end;


procedure  TGasKuDeGi.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   idx: integer;
   d: TDXTexture;
   ceff: TColorEffect;
begin
   if not (Dir in [0..7]) then exit;
   if GetTickCount - loadsurfacetime > 60 * 1000 then begin
      loadsurfacetime := GetTickCount;
      LoadSurface; //bodysurface���� loadsurface�� �ٽ� �θ��� �ʾ� �޸𸮰� �����Ǵ� ���� ����
   end;

   ceff := GetDrawEffectValue;

   if (Race = 95) and Death then begin
      BodySurface := WMon4Img.GetCachedImage ( 3580, px, py);
      blend := True;
      if BodySurface <> nil then
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, blend, ceff);
   end
   else if BodySurface <> nil then
      DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, blend, ceff);

end;

procedure TGasKuDeGi.DrawEff (dsurface: TDXTexture; dx, dy: integer);
var
   idx: integer;
   d: TDXTexture;
   ceff: TColorEffect;
begin
   if BoViewEffect then begin
   if BoUseEffect then
      if AttackEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    AttackEffectSurface, 1);
      end;
   if BoUseDieEffect then
      if DieEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + bx + ShiftX,
                    dy + by + ShiftY,
                    DieEffectSurface, 1);
      end;
   end;
end;




{-----------------------------------------------------------}
//����


procedure TExplosionSpider.CalcActorFrame;
var
   pm: PTMonsterAction;
begin
   inherited CalcActorFrame;

   //pm := RaceByPm (Race, Appearance);
   //if pm = nil then exit;

   case CurrentAction of
      SM_HIT:
         begin
            BoUseEffect := FALSE;
         end;
      SM_NOWDEATH:
         begin
            effectstart := startframe;
            effectframe := startframe;
            effectstarttime := GetTickCount;
            effectframetime := frametime; //pm.ActDie.ftime;
            effectend := endframe;
            BoUseEffect := TRUE;
         end;
   end;
end;

procedure TExplosionSpider.LoadSurface;
begin
   inherited LoadSurface;
   if BoUseEffect then begin
      AttackEffectSurface := WMon14Img.GetCachedImage (
               730 + effectframe-effectstart,
               ax, ay);
   end;
end;



{-----------------------------------------------------------}
//�񵶰Ź�


procedure TFlyingSpider.CalcActorFrame;
var
   pm: PTMonsterAction;
   meff: TMagicEff;
begin
   inherited CalcActorFrame;

   case CurrentAction of
      SM_NOWDEATH:
         begin
            //effectstart := startframe;
            //effectframe := startframe;
            //effectstarttime := GetTickCount;
            //effectframetime := frametime; //pm.ActDie.ftime;
            //effectend := endframe + 5;
            //BoUseEffect := TRUE;
            meff := TNormalDrawEffect.Create (XX, YY,
                                                WMon12Img,
                                                1420,  //���� ��ġ
                                                20,    //������
                                                frametime,  //������
                                                TRUE);

            if meff <> nil then begin
               meff.MagOwner := Myself;  //�� ��������
               PlayScene.EffectList.Add (meff);
            end;
         end;
   end;
end;



{-----------------------------------------------------------}


function  TFireCowFaceMon.Light: integer;
var
   l: integer;
begin
   l := ChrLight;
   if l < 2 then begin
      if BoUseEffect then
         l := 2;
   end;
   Result := l;
end;

function  TCowFaceKing.Light: integer;
var
   l: integer;
begin
   l := ChrLight;
   if l < 2 then begin
      if BoUseEffect then
         l := 2;
   end;
   Result := l;
end;


{-----------------------------------------------------------}

//procedure TZombiLighting.Run;


{-----------------------------------------------------------}


procedure TSculptureMon.CalcActorFrame;
var
   pm: PTMonsterAction;
   haircount: integer;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;
   BoUseEffect := FALSE;

   case CurrentAction of
      SM_TURN:
         begin
            if (State and STATE_STONE_MODE) <> 0 then begin
               if (Race = 48) or (Race = 49) then
                  startframe := pm.ActDeath.start // + Dir * (pm.ActDeath.frame + pm.ActDeath.skip)
               else
                  startframe := pm.ActDeath.start + Dir * (pm.ActDeath.frame + pm.ActDeath.skip);
               endframe := startframe;
               frametime := pm.ActDeath.ftime;
               starttime := GetTickCount;
               defframecount := pm.ActDeath.frame;
            end else begin
               startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
               endframe := startframe + pm.ActStand.frame - 1;
               frametime := pm.ActStand.ftime;
               starttime := GetTickCount;
               defframecount := pm.ActStand.frame;
            end;
            Shift (Dir, 0, 0, 1);
         end;
      SM_WALK, SM_BACKSTEP:
         begin
            startframe := pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe + pm.ActWalk.frame - 1;
            frametime := WalkFrameDelay; //pm.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            //WarMode := FALSE;
            movestep := 1;
            if CurrentAction = SM_WALK then
               Shift (Dir, movestep, 0, endframe-startframe+1)
            else  //sm_backstep
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
         end;
      SM_DIGUP: //�ȱ� ����, SM_DIGUP, ���� ����.
         begin
            if (Race = 48) or (Race = 49) then begin
               startframe := pm.ActDeath.start;
            end else begin
               startframe := pm.ActDeath.start + Dir * (pm.ActDeath.frame + pm.ActDeath.skip);
            end;
            endframe := startframe + pm.ActDeath.frame - 1;
            frametime := pm.ActDeath.ftime;
            starttime := GetTickCount;
            //WarMode := FALSE;
            Shift (Dir, 0, 0, 1);
         end;
      SM_HIT:
         begin
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;
            if Race = 49 then begin
               BoUseEffect := TRUE;
               firedir := Dir;
               effectframe := 0; //startframe;
               effectstart := 0; //startframe;
               effectend := effectstart + 8;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
            end;
            Shift (Dir, 0, 0, 1);
         end;
      SM_STRUCK:
         begin
            startframe := pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
            endframe := startframe + pm.ActStruck.frame - 1;
            frametime := struckframetime; //pm.ActStruck.ftime;
            starttime := GetTickCount;
         end;
      SM_DEATH:
         begin
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            startframe := endframe; //
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;
         end;
      SM_NOWDEATH:
         begin
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;
         end;
   end;
end;

procedure  TSculptureMon.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      48, 49:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon7Img.GetCachedImage (
                        SCULPTUREFIREBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;
   end;
end;

function  TSculptureMon.GetDefaultFrame (wmode: Boolean): integer;
var
   cf, dr: integer;
   pm: PTMonsterAction;
   effectframetimetime, frametimetime: longword;
begin
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   if Death then begin
      Result := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip) + (pm.ActDie.frame - 1);
   end else begin
      if (State and STATE_STONE_MODE) <> 0 then begin
         case Race of
            47: Result := pm.ActDeath.start + Dir * (pm.ActDeath.frame + pm.ActDeath.skip);
            48, 49: Result := pm.ActDeath.start;
            92: begin
                   BoUseEffect := False;
                   Result := 420 + Dir * 10;
                end;
         end;
      end else begin
         defframecount := pm.ActStand.frame;
         if currentdefframe < 0 then cf := 0
         else if currentdefframe >= pm.ActStand.frame then cf := 0
         else cf := currentdefframe;
         Result := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip) + cf;

         if Race = 92 then begin
            if Not BoUseEffect then begin
               effectframe := 940 + Dir * 10;
               effectstart := 940 + Dir * 10;
               effectend := effectstart + pm.ActStand.frame-1;//endframe;
               effectstarttime := GetTickCount;
               effectframetime := pm.ActStand.ftime+50;
            end;

            BoUseEffect := True;
            effectframetimetime := effectframetime;
            if GetTickCount - effectstarttime > effectframetimetime-50 then begin
               // 50���� ������ run������ effectstarttime ���� ���ϱ� ������ ���� ��ƾ�� Ÿ������..
               effectstarttime := GetTickCount;
               if effectframe < effectend then begin
                  Inc (effectframe);
               end else begin
                  BoUseEffect := FALSE;
               end;
            end;
         end;
      end;
   end;
end;

procedure TSculptureMon.DrawEff (dsurface: TDXTexture; dx, dy: integer);
var
   idx: integer;
   d: TDXTexture;
   ceff: TColorEffect;
begin
   if BoUseEffect then
      if AttackEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    AttackEffectSurface, 1);
      end;
end;

procedure TSculptureMon.Run;
var
   effectframetimetime, frametimetime: longword;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;
   if BoUseEffect then begin
      effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
//            if Race <> 92 then BoUseEffect := FALSE; // �ָ��ݷ����� �ƴϸ�..
            BoUseEffect := FALSE;
         end;
      end;
   end;
   inherited Run;
end;


//----------------------------------------------------------------------------
//  TElectronicScolpionMon  ������ (����)


procedure TElectronicScolpionMon.CalcActorFrame;
var   
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of
      SM_HIT:
         begin
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
      {      BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;  }
         end;
      SM_LIGHTING:   //ũ��ƽ�� ����
         begin
            startframe := pm.ActCritical.start + Dir * (pm.ActCritical.frame + pm.ActCritical.skip);
            endframe := startframe + pm.ActCritical.frame - 1;
            frametime := pm.ActCritical.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;
      else
         inherited CalcActorFrame;
   end;

end;

procedure  TElectronicScolpionMon.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      60:
         begin
            if BoUseEffect then
               case CurrentAction of
                  SM_HIT:
                     ;
                  SM_LIGHTING:
                     AttackEffectSurface := WMon19Img.GetCachedImage (
                              ELECTRONICSCOPIONEFFECTBASE + (firedir * 10) + effectframe-effectstart, //
                              ax, ay);
               end;
         end;

   end;
end;


//----------------------------------------------------------------------------

//  TBossPigMon  �յ�,  �͵���


procedure  TBossPigMon.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      61:
         begin
            if BoUseEffect then
               AttackEffectSurface := WMon19Img.GetCachedImage (
                        KINGBIGEFFECTBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
         end;

   end;
end;



//----------------------------------------------------------------------------
//  TKingOfSculpureKingMon  ��õ���� (���߿�)
procedure TKingOfSculpureKingMon.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of
      SM_HIT:
         begin
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;  
         end;
      SM_LIGHTING:   //ũ��ƽ�� ����
         begin
            startframe := pm.ActCritical.start + Dir * (pm.ActCritical.frame + pm.ActCritical.skip);
            endframe := startframe + pm.ActCritical.frame - 1;
            frametime := pm.ActCritical.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;
      SM_NOWDEATH:
         begin
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;

            effectframe := pm.ActDie.start;
            effectstart := pm.ActDie.start;
            effectend := pm.ActDie.start + pm.ActDie.frame - 1;

            effectstarttime := GetTickCount;
            effectframetime := frametime;

            BoUseEffect := TRUE;
         end;
      else
         inherited CalcActorFrame;
   end;

end;

procedure  TKingOfSculpureKingMon.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      62:
         begin
            if BoUseEffect then
               case CurrentAction of
                  SM_HIT:
                     AttackEffectSurface := WMon19Img.GetCachedImage (
                        KINGOFSCOLPTUREKINGATTACKEFFECTBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
                  SM_LIGHTING:
                     AttackEffectSurface := WMon19Img.GetCachedImage (
                        KINGOFSCOLPTUREKINGEFFECTBASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
                  SM_NOWDEATH:
                     AttackEffectSurface := WMon19Img.GetCachedImage (
                        KINGOFSCOLPTUREKINGDEATHEFFECTBASE + effectframe-effectstart, //
                        ax, ay);
               end;
         end;
   end;
end;

//----------------------------------------------------------------------------
// 2003/02/11
//  TSkeletonKingMon  �ذ�ݿ�
procedure TSkeletonKingMon.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of

      SM_WALK, SM_BACKSTEP:
         begin
            startframe:= pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe  := startframe + pm.ActWalk.frame - 1;
            frametime := pm.ActWalk.ftime;
            starttime := GetTickCount;
            effectframe := pm.ActWalk.start;
            effectstart := pm.ActWalk.start;
            effectend := pm.ActWalk.start + pm.ActWalk.frame - 1;
            effectstarttime := GetTickCount;
            effectframetime := frametime;
            BoUseEffect := TRUE;

            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            movestep := 1;
            if CurrentAction = SM_WALK then
               Shift (Dir, movestep, 0, endframe-startframe+1)
            else  //sm_backstep
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
         end;
      SM_STRUCK:
         begin
            startframe:= pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
            endframe  := startframe + pm.ActStruck.frame - 1;
            frametime := pm.ActStruck.ftime;
            starttime := GetTickCount;

            effectframe := pm.ActStruck.start;
            effectstart := pm.ActStruck.start;
            effectend := pm.ActStruck.start + pm.ActStruck.frame - 1;

            effectstarttime := GetTickCount;
            effectframetime := frametime;

            BoUseEffect := TRUE;
         end;

      SM_HIT:
         begin
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;  
         end;
      SM_FLYAXE:     //���Ÿ�����
         begin
            startframe := pm.ActCritical.start + Dir * (pm.ActCritical.frame + pm.ActCritical.skip);
            endframe := startframe + pm.ActCritical.frame - 1;
            frametime := pm.ActCritical.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;
      SM_LIGHTING:   //��ȯ����
         begin
            startframe := pm.ActAttack.start + 80 + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe  := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;
            firedir := Dir;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;

            effectstarttime := GetTickCount;
            effectframetime := frametime;  
         end;
      SM_NOWDEATH:
         begin
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            frametime := pm.ActDie.ftime;
            starttime := GetTickCount;

            effectframe := pm.ActDie.start;
            effectstart := pm.ActDie.start;
            effectend := pm.ActDie.start + pm.ActDie.frame - 1;

            effectstarttime := GetTickCount;
            effectframetime := frametime;

            BoUseEffect := TRUE;
         end;
      else
         inherited CalcActorFrame;
   end;

end;

procedure  TSkeletonKingMon.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      63:
         begin
            if BoUseEffect then
               case CurrentAction of
                  SM_WALK:
                     AttackEffectSurface := WMon20Img.GetCachedImage (
                        SKELETONKINGEFFECT2BASE + (Dir * 10) + effectframe-effectstart, //
                        ax, ay);
                  SM_STRUCK:
                     AttackEffectSurface := WMon20Img.GetCachedImage (
                        SKELETONKINGEFFECT6BASE + (Dir * 2) + effectframe-effectstart, //
                        ax, ay);
                  SM_HIT:
                     AttackEffectSurface := WMon20Img.GetCachedImage (
                        SKELETONKINGEFFECT3BASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
                  SM_FLYAXE:
                     AttackEffectSurface := WMon20Img.GetCachedImage (
                        SKELETONKINGEFFECT5BASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
                  SM_LIGHTING:
                     AttackEffectSurface := WMon20Img.GetCachedImage (
                        SKELETONKINGEFFECT4BASE + (firedir * 10) + effectframe-effectstart, //
                        ax, ay);
                  SM_NOWDEATH:
                     AttackEffectSurface := WMon20Img.GetCachedImage (
                        SKELETONKINGEFFECT7BASE + dir*20 + effectframe-effectstart, //
                        ax, ay);
               end;
         end;
   end;
end;

procedure TSkeletonKingMon.Run;
var
   prv: integer;
   effectframetimetime, frametimetime: longword;
   meff: TFlyingAxe;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   if BoUseEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
            BoUseEffect := FALSE;
         end;
      end;
   end;

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
            BoUseDieEffect := FALSE;
         end;
         if (CurrentAction = SM_FLYAXE) and (currentframe-startframe = 4) then begin
            meff := TFlyingFireBall (PlayScene.NewFlyObject (self,
                             XX,
                             YY,
                             TargetX,
                             TargetY,
                             TargetRecog,
                             mtFireBall));

            if meff <> nil then begin
               meff.ImgLib := WMon20Img; //WMon5Img;
               meff.NextFrameTime := 40;
               meff.FlyImageBase := SKELETONKINGEFFECT8BASE;
            end;
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;

// 2003/02/11
procedure  TSkeletonArcherMon.LoadSurface;
begin
   inherited LoadSurface;
   if BoUseDieEffect then begin
      DieEffectSurface := WMon20Img.GetCachedImage (
               SKELARCHERDIEBASE + currentframe-startframe, bx, by);
   end;
end;

procedure TSkeletonArcherMon.CalcActorFrame;
begin
   inherited CalcActorFrame;
   case CurrentAction of
      SM_NOWDEATH:
         begin
            if(Race <> 72)then
               BoUseDieEffect := TRUE;
            if Race in [91,94,102] then BoUseDieEffect := False; // ���δ����̸� �״� ����Ʈ �ȳ���
         end;
   end;
end;

procedure TSkeletonArcherMon.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
   inherited DrawEff(dsurface, dx, dy);
   if BoViewEffect then begin
   if BoUseDieEffect then
      if DieEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + bx + ShiftX,
                    dy + by + ShiftY,
                    DieEffectSurface, 1);
      end;
   end;
end;

procedure  TSkeletonArcherMon.Run;
var
   frametimetime: longword;
begin
   if msgmuch then frametimetime := Round(frametime * 2 / 3)
   else frametimetime := frametime;
   
   if CurrentAction <> 0 then begin
      if GetTickCount - starttime > frametimetime then begin
         if currentframe >= endframe then begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseDieEffect := FALSE;
         end;
      end;
   end;
   inherited Run;
end;

// 2003/03/04
constructor TBanyaGuardMon.Create;
begin
   inherited Create;
   AttackEffectSurface := nil;
end;

procedure  TBanyaGuardMon.LoadSurface;
begin
   inherited LoadSurface;
   if BoUseDieEffect then begin
      case Race of
         70:
               DieEffectSurface := WMon21Img.GetCachedImage (
                     BANYAGUARDRIGHTDIEBASE + currentframe-startframe,
                     bx, by);
         71:
               DieEffectSurface := WMon21Img.GetCachedImage (
                     BANYAGUARDLEFTDIEBASE + (Dir * 10) + currentframe-startframe,
                     bx, by);
         78:
               DieEffectSurface := WMon22Img.GetCachedImage (
                     PBKINGDIEBASE + (Dir * 20) + currentframe-startframe,
                     bx, by);
         93:   begin //ȯ����ȣ
                  DieEffectSurface := WMon23Img.GetCachedImage (
                        1790 + currentframe-startframe,
                        bx, by);
               end;
         100:  begin //Ȳ���̹��� //#### ȯ�̷��, û����
                  DieEffectSurface := WMon23Img.GetCachedImage (
                        2900 + currentframe-startframe, bx, by);
               end;
         103,104,105:  begin //��������״� ����Ʈ
                  DieEffectSurface := WMon24Img.GetCachedImage (
                        340 + currentframe-startframe, bx, by);
                  if (currentframe - startframe ) = 0 then PlaySound (10420);
               end;
         108:   begin //ȣ�⿬(��)
                  DieEffectSurface := WMon24Img.GetCachedImage (
                        1540 + currentframe-startframe, bx, by);
               end;
         109:   begin //ȣ�⿬(��)
                  DieEffectSurface := WMon24Img.GetCachedImage (
                        1650 + currentframe-startframe, bx, by);
               end;
         117: BoUseDieEffect := False;
      end;
   end else if BoUseEffect then begin
      case Race of
         70:
            begin
                case CurrentAction of
                   SM_HIT:
                      AttackEffectSurface := WMon21Img.GetCachedImage (
                         BANYAGUARDRIGHTHITBASE + (Dir * 10) + effectframe-effectstart, //
                         ax, ay);
                end;
            end;
         71:
            begin
                case CurrentAction of
                   SM_HIT:
                      AttackEffectSurface := WMon21Img.GetCachedImage (
                         BANYAGUARDLEFTHITBASE + (Dir * 10) + effectframe-effectstart, //
                         ax, ay);
                   SM_LIGHTING,
                   SM_FLYAXE:
                      AttackEffectSurface := WMon21Img.GetCachedImage (
                         BANYAGUARDLEFTFLYBASE + (Dir * 10) + effectframe-effectstart, //
                         ax, ay);
                end;
            end;
         72:
            begin
                case CurrentAction of
                   SM_HIT:
                      AttackEffectSurface := WMon21Img.GetCachedImage (
                         DEADCOWKINGHITBASE + (Dir * 10) + effectframe-effectstart, //
                         ax, ay);
                end;
            end;
         78:
            begin
                case CurrentAction of
                   SM_HIT:
                      AttackEffectSurface := WMon22Img.GetCachedImage (
                         PBKINGATTACK1BASE + (Dir * 10) + effectframe-effectstart, //
                         ax, ay);
                end;
            end;
         94: // �Ź�
            begin
                if CurrentAction = SM_LIGHTING then begin
                   BoUseEffect := TRUE;
                   AttackEffectSurface := WMon23Img.GetCachedImage (
                      2230 + (Dir * 10) + effectframe-effectstart, ax, ay);
                end
                else BoUseEffect := False;
            end;
         100: //####
             if CurrentAction in [SM_LIGHTING, SM_LIGHTING_1] then begin
                   BoUseEffect := TRUE;
                   AttackEffectSurface := WMon23Img.GetCachedImage (
                      2820 + (Dir * 10) + effectframe-effectstart, ax, ay);
             end
             else BoUseEffect := False;
         103: //���������� ũ��Ƽ�� ����Ʈ
             if  CurrentAction = SM_LIGHTING then
                AttackEffectSurface := WMon24Img.GetCachedImage (
                   350 + (Dir * 10) + effectframe-effectstart, ax, ay);
         105: //���������� ��ȯ ����Ʈ
             if  CurrentAction = SM_LIGHTING_2 then begin
                AttackEffectSurface := WMagic2.GetCachedImage (effectframe, ax, ay);
             end;
         108: //ȣ�⿬(��) ����Ʈ
             begin
                if not BoUseDieEffect then begin
                   effectframetime := frametime;
                   AttackEffectSurface := WMon24Img.GetCachedImage (
                      1500 + currentframe, ax, ay);
                end;
             end;
         109: //ȣ�⿬(��) ����Ʈ
             begin
                if not BoUseDieEffect then begin
                   effectframetime := frametime;
                   AttackEffectSurface := WMon24Img.GetCachedImage (
                      1610 + currentframe, ax, ay);
                end;
             end;
      end;
   end;
end;

procedure TBanyaGuardMon.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of
      SM_HIT:         // �ٰŸ� ����
         begin
            if Race in [93,100] then SitDown := False; //�̹��� ####
            Shift (Dir, 0, 0, 1);
            if Race in [107,108,109] then startframe := pm.ActAttack.start
            else startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe  := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            if Race = 93 then frametime := 80; //ȯ����ȣ �����Ӽӵ�
            if Race = 94 then frametime := 130; //�Ź�(�ż�������) �����Ӽӵ�
            if Race = 100 then frametime := 100; //�̹���
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            if Race in [103,104,105] then  BoUseEffect := False
            else BoUseEffect := TRUE;

            effectframe := startframe;
            effectstart := startframe;
            effectend := endframe;
            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;
//    SM_FLYAXE,     //���Ÿ�����...
      SM_LIGHTING_1,
      SM_LIGHTING:
         begin
            if Race in [93,100] then SitDown := False; //�̹���
            if Race = 107 then begin
               if CurrentAction = SM_LIGHTING then startframe := pm.ActCritical.start
               else startframe := 15;
            end
            else if Race in [108,109] then startframe := pm.ActCritical.start
            else startframe := pm.ActCritical.start + Dir * (pm.ActCritical.frame + pm.ActCritical.skip);
            endframe   := startframe + pm.ActCritical.frame - 1;
            frametime  := pm.ActCritical.ftime;
            starttime  := GetTickCount;
            CurEffFrame := 0;
            BoUseMagic := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);

            if (Race in [103,104]) then begin //����������,���������� ũ��Ƽ�� ���� ���ݵ�������
               startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
               endframe   := startframe + pm.ActAttack.frame - 1;
               frametime  := pm.ActAttack.ftime;
               starttime  := GetTickCount;
            end;

            if (Race = 71) then begin //�ݾ� �»縸 ����Ʈ�� ����
               BoUseEffect := TRUE;
               effectframe := startframe;
               effectstart := startframe;
               effectend   := endframe;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
            end
            else if  Race = 94 then begin //New�Ź� ���� ����Ʈ, �̹���
               BoUseEffect := TRUE;
               effectframe := 420 + Dir * 10;
               effectstart := effectframe;
               effectend   := effectframe+9;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
            end
            else if Race = 100 then begin //New�Ź� ���� ����Ʈ, �̹���
               BoUseEffect := TRUE;
               effectframe := 500 + Dir * 10;
               effectstart := effectframe;
               effectend   := effectframe+5;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
            end
            else if Race = 103 then begin //���������� ũ��Ƽ�� ����Ʈ
//      DScreen.AddChatBoardString ('���������� SM_LIGHTING:', clYellow, clRed);
               BoUseEffect := TRUE;
               effectframe := 350 + Dir * 10;
               effectstart := effectframe;
               effectend   := effectframe+5;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
            end
            else if (Race = 107) and (CurrentAction = SM_LIGHTING_1) then begin
//      DScreen.AddChatBoardString ('ȣȥ�⼮ SM_LIGHTING_1 ��ȯ����', clYellow, clRed);
               effectframe := currentframe+5;
               effectstart := effectframe;
               effectend   := effectframe+3;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
               PlaySound(1900);
            end
            else if Race in [108,109] then begin
               BoUseEffect := TRUE;
               BoUseMagic := False;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
//   DScreen.AddChatBoardString ('ȣ�⿬ SM_LIGHTING', clYellow, clRed); //#####
               if Race = 108 then PlaySound (2552);
               effectframe := 1520;
               effectstart := 1520;
               effectend := 1529;
               if Race = 109 then begin
                  PlaySound (2562);
                  effectframe := 1630;
                  effectstart := 1630;
                  effectend := 1639;
               end;
            end

         end;
      SM_LIGHTING_2:
         begin
            if Race = 105 then begin
//      DScreen.AddChatBoardString ('���������� ��ȯ!!!!!!!!', clYellow, clRed);
               startframe := 420 + Dir * 10;
               endframe   := startframe + 9;
               frametime  := pm.ActCritical.ftime;
               starttime  := GetTickCount;
               WarModeTime := GetTickCount;
               Shift (Dir, 0, 0, 1);

               BoUseEffect := TRUE;
               effectframe := 0;
               effectstart := 0;
               effectend   := 10;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
               PlaySound (2528);
            end;
         end;

      else
         inherited CalcActorFrame;
   end;
end;

procedure TBanyaGuardMon.Run;
var
   prv: integer;
   effectframetimetime, frametimetime: longword;
   meff: TFlyingAxe;
   bofly: Boolean;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   if BoUseEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
            BoUseEffect := FALSE;
         end;
      end;
   end;

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
            BoUseDieEffect := FALSE;
         end;

         if BoViewEffect or ( ((Race = 70)or( Race = 81)) and (CurrentAction = SM_LIGHTING) ) then begin
//         if BoViewEffect then begin

         if (CurrentAction = SM_LIGHTING_1) and (currentframe-startframe = 4) then begin
            if(Race = 100) then begin    //�̹��� ��õȭ
//      DScreen.AddChatBoardString ('�̹���-SM_LIGHTING_1 //�̹��� ��õȭ', clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_SERPENT_1,
                                      MAGIC_SERPENT_1,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtThunder,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (159);
                PlaySound (2449);//8101
            end;
            if(Race = 104) then begin    //����������:ȭ��
//      DScreen.AddChatBoardString ('���������� ȭ��', clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_FOX_FIRE1,
                                      MAGIC_FOX_FIRE1,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtThunder,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (2517);
            end;
            if(Race = 105) then begin    //����������:���ּ�
//      DScreen.AddChatBoardString ('���������� ���ּ�', clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_FOX_CURSE,
                                      MAGIC_FOX_CURSE,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtExploBujauk,
                                      FALSE,
                                      30,
                                      bofly);
               magicfiresound  := 10131;
               magicexplosionsound := 2527;
            end;

         end
         else if (CurrentAction = SM_LIGHTING) and (Race = 107) and (currentframe-startframe = 1)then begin
//      DScreen.AddChatBoardString ('ȣȥ�⼮ SM_LIGHTING ������������!!', clYellow, clRed);
             PlayScene.NewMagic (self,
                                   MAGIC_SIDESTONE_ATT1,
                                   MAGIC_SIDESTONE_ATT1,
                                   XX,
                                   YY,
                                   XX,       //TargetX,
                                   YY,       //TargetY,
                                   RecogId,  //TargetRecog,
                                   mtGroundEffect,
                                   FALSE,
                                   30,
                                   bofly);
             PlaySound (2562);
         end
         else if (CurrentAction = SM_LIGHTING) and (currentframe-startframe = 4) then begin
            if(Race = 70) or ( Race = 81) then begin    //����
                PlayScene.NewMagic (self,
                                      MagicNum, //11,
                                      8,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtThunder,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (10112);
            end;
            if(Race = 71) then begin    //ȭ�̾
                PlayScene.NewMagic (self,
                                      1, //11,
                                      1,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtFly,
                                      TRUE,
                                      30,
                                      bofly);
                PlaySound (10012);
            end;

            if(Race = 72) then begin    //������
                PlayScene.NewMagic (self,
                                      11,
                                      32,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtGroundEffect,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (2276);
            end;
            if(Race = 78) then begin
                PlayScene.NewMagic (self,
                                      11,
                                      37,
                                      XX,
                                      YY,
                                      XX,       //TargetX,
                                      YY,       //TargetY,
                                      RecogId,  //TargetRecog,
                                      mtGroundEffect,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (2396);
            end;
            if(Race = 93) then begin    //�����  //ȯ����ȣ
                PlayScene.NewMagic (self,
                                      39,
                                      39,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtFly,
                                      TRUE,
                                      30,
                                      bofly);
                PlaySound (10390);
            end;
            if(Race = 94) then begin
               PlaySound (2437);  //�Ź�
            end;
            if(Race = 103) then begin
               PlaySound (2506);
            end;
            if(Race = 104) then begin    //����������
//      DScreen.AddChatBoardString ('���������� ����', clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_FOX_THUNDER, //11,
                                      MAGIC_FOX_THUNDER,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtThunder,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (2516);
            end;
            if(Race = 105) then begin    //����������:�����
//      DScreen.AddChatBoardString ('���������� �����', clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_FOX_FIRE2,
                                      MAGIC_FOX_FIRE2,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtExploBujauk,
                                      FALSE,
                                      30,
                                      bofly);
               magicstartsound := 10130;
               magicfiresound  := 10131;
               magicexplosionsound := 2526;
            end;
            if(Race = 117) then begin    //��ö�ͼ�: ������
                PlayScene.NewMagic (self,
                                      MAGIC_TURTLE_WARTERATT,
                                      MAGIC_TURTLE_WARTERATT,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtFly,
                                      TRUE,
                                      30,
                                      bofly);
                PlaySound (2374);
            end;
         end;
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if Race in [108,109] then begin
         if GetTickCount - defframetime > 150 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end
      else if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;

   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;

end;

procedure TBanyaGuardMon.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
   inherited DrawEff(dsurface, dx, dy);
   if BoViewEffect then begin
   if BoUseEffect then
      if AttackEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    AttackEffectSurface, 1);
      end;
   end;
end;

constructor TStoneMonster.Create;
begin
   inherited Create;
   AttackEffectSurface := nil;
   BoUseEffect    := FALSE;
   BoUseDieEffect := FALSE;
end;

procedure  TStoneMonster.LoadSurface;
begin
   inherited LoadSurface;
   if BoUseDieEffect then begin
      case Race of
         75:   DieEffectSurface := WMon22Img.GetCachedImage (
                     PBSTONE1DIEBASE + effectframe-effectstart, bx, by);
         77:   DieEffectSurface := WMon22Img.GetCachedImage (
                     PBSTONE2DIEBASE + effectframe-effectstart, bx, by);
      end;
   end else if BoUseEffect then begin
      case Race of
         75: begin
                case CurrentAction of
                   SM_HIT: AttackEffectSurface := WMon22Img.GetCachedImage (
                           PBSTONE1ATTACKBASE + effectframe-effectstart, ax, ay);
                   SM_TURN:AttackEffectSurface := WMon22Img.GetCachedImage (
                           PBSTONE1IDLEBASE + effectframe-effectstart, ax, ay);
                end;
             end;
         77: begin
                case CurrentAction of
                   SM_HIT: AttackEffectSurface := WMon22Img.GetCachedImage (
                           PBSTONE2ATTACKBASE + effectframe-effectstart, ax, ay);
                   SM_TURN:AttackEffectSurface := WMon22Img.GetCachedImage (
                           PBSTONE2IDLEBASE + effectframe-effectstart, ax, ay);
                end;
             end;
      end;
   end;
end;

procedure TStoneMonster.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   BoUseMagic    := FALSE;
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   Dir := 0;
   case CurrentAction of
      SM_TURN:
         begin
            startframe := pm.ActStand.start;
            endframe := startframe + pm.ActStand.frame - 1;
            frametime := pm.ActStand.ftime;
            starttime := GetTickCount;
            defframecount := pm.ActStand.frame;
            if not BoUseEffect then begin
               BoUseEffect := TRUE;
               effectframe := startframe;
               effectstart := startframe;
               effectend   := endframe;
               effectstarttime := GetTickCount;
               effectframetime := 300;
            end;
         end;
      SM_HIT:
         begin
            startframe := pm.ActAttack.start;
            endframe  := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            if not BoUseEffect then begin
               BoUseEffect := TRUE;
               effectframe := startframe;
               effectstart := startframe;
               effectend   := startframe + 25;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end;
         end;
      SM_STRUCK:
         begin
            startframe := pm.ActStruck.start;
            endframe   := startframe + pm.ActStruck.frame - 1;
            frametime  := struckframetime; //pm.ActStruck.ftime;
            starttime  := GetTickCount;
         end;
      SM_DEATH:
         begin
            startframe := pm.ActDie.start;
            endframe   := startframe + pm.ActDie.frame - 1;
            startframe := endframe; //
            frametime  := pm.ActDie.ftime;
            starttime  := GetTickCount;
         end;
      SM_NOWDEATH:
         begin
            startframe := pm.ActDie.start;
            endframe   := startframe + pm.ActDie.frame - 1;
            frametime  := pm.ActDie.ftime;
            starttime  := GetTickCount;
            BoUseDieEffect := TRUE;
            effectframe := startframe;
            effectstart := startframe;
            effectend   := startframe + 19;
            effectstarttime := GetTickCount;
            effectframetime := 80;
         end;
      {
      SM_SKELETON:
         begin
            startframe := pm.ActDeath.start;
            endframe   := startframe + pm.ActDeath.frame - 1;
            frametime  := pm.ActDeath.ftime;
            starttime  := GetTickCount;
         end;
      }
   end;
end;

procedure TStoneMonster.Run;
var
   prv, prv2: integer;
   effectframetimetime, frametimetime: longword;
   bofly: Boolean;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   prv2 := effectframe;
   if BoUseEffect or BoUseDieEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
            if BoUseEffect    then BoUseEffect    := FALSE;
            if BoUseDieEffect then BoUseDieEffect := FALSE;
         end;
      end;
   end;

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            CurrentAction := 0; //���� �Ϸ�
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if (prv <> currentframe) or (prv2 <> effectframe) then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;

procedure TStoneMonster.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
   inherited DrawEff(dsurface, dx, dy);
   if BoViewEffect then begin
   if BoUseEffect then
      if AttackEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    AttackEffectSurface, 1);
      end;
   end;
end;

procedure TPBOMA1Mon.Run;
var
   prv: integer;
   frametimetime: longword;
   meff: TFlyingBug;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;
   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
         end;                                                       // 4
         if (CurrentAction = SM_FLYAXE) and (currentframe-startframe = 4) then begin
            meff := TFlyingBug(PlayScene.NewFlyObject (self,
                             XX,
                             YY,
                             TargetX,
                             TargetY,
                             TargetRecog,
                             mtFlyBug));
            if meff <> nil then begin
               meff.ImgLib := WMon22Img;
               meff.NextFrameTime := 50; // 50
               meff.FlyImageBase := 350;
               meff.MagExplosionBase := 430
            end;
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;

procedure TPBOMA6Mon.Run;
var
   prv: integer;
   frametimetime: longword;
   meff: TFlyingAxe;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;
   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
         end;
         if (CurrentAction = SM_FLYAXE) and (currentframe-startframe = 4) then begin
            meff := TFlyingAxe (PlayScene.NewFlyObject (self,
                             XX,
                             YY,
                             TargetX,
                             TargetY,
                             TargetRecog,
                             mtFlyBolt));
            if meff <> nil then begin
               meff.ImgLib := WMon22Img;
               meff.NextFrameTime := 30;
               meff.FlyImageBase := 1989;
            end;
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;

//õ �� (����)------------------------------------------------------------------------

procedure  TAngel.LoadSurface;
var
   mimg: TWMImages;
begin

   mimg := GetMonImg (Appearance);
   if mimg <> nil then begin
      if (not ReverseFrame) then begin
         BodySurface := mimg.GetCachedImage (GetOffset (Appearance) + currentframe, px, py);
         BodySurface2 := mimg.GetCachedImage (1280 + currentframe, px2, py2); // ����ƴ� �̹���
      end
      else begin
         BodySurface := mimg.GetCachedImage ( GetOffset (Appearance) + endframe - (currentframe-startframe), px, py);
         BodySurface2 := mimg.GetCachedImage (1280 + endframe - (currentframe-startframe), px2, py2);
      end;
   end;
end;

procedure  TAngel.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   nx, ny : integer;
   ceff: TColorEffect;
begin
   if not (Dir in [0..7]) then exit;
   if GetTickCount - loadsurfacetime > 60 * 1000 then begin
      loadsurfacetime := GetTickCount;
      LoadSurface; //bodysurface���� loadsurface�� �ٽ� �θ��� �ʾ� �޸𸮰� �����Ǵ� ���� ����
   end;

   ceff := GetDrawEffectValue;
   if (BodySurface <> nil) and (BodySurface2 <> nil) then begin
      Drawblend(dsurface,  dx + px + ShiftX, dy + py + ShiftY,BodySurface,1);
      if AngelFastDraw then blend := False;//����
      DrawEffSurface (dsurface, BodySurface2, dx + px2 + ShiftX, dy + py2 + ShiftY, blend, ceff);
   end;

end;

//��õ����(ȭ��) -------------------------------------------------------------------------------
constructor TFireDragon.Create;
begin
   inherited Create;

   AttackEffectSurface := nil;
   LightningTimer := TTimer.Create (nil);
   if Race = 83 then LightningTimer.Interval := 70
   else if Race = 110 then LightningTimer.Interval := 10;
   LightningTimer.Tag := 0;
   LightningTimer.OnTimer := LightningTimerTimer;
   LightningTimer.Enabled := False; //FireDragon
end;

destructor TFireDragon.Destroy;
begin

   if LightningTimer <> nil then LightningTimer.Free;

   inherited Destroy;

end;

procedure  TFireDragon.LoadSurface;
var
   mimg: TWMImages;
begin
   mimg := WDragonImg;

   if Race in [110,118] then begin
      BoUseEffect := True;
      if Death then BoUseEffect := FALSE
   end;

   if mimg <> nil then begin
      if (not ReverseFrame) then begin
          if Race = 83 then begin
             case CurrentAction of
                SM_LIGHTING:
                   BodySurface := WDragonImg.GetCachedImage ( 40+ currentframe, px, py);
                SM_DRAGON_FIRE1: // FireDragon
                   BodySurface := WDragonImg.GetCachedImage ( 10+ currentframe, px, py);
                SM_DRAGON_FIRE2:
                   BodySurface := WDragonImg.GetCachedImage ( 20+ currentframe, px, py);
                SM_DRAGON_FIRE3:
                   BodySurface := WDragonImg.GetCachedImage ( 30+ currentframe, px, py);
                else
                   BodySurface := mimg.GetCachedImage (GetOffset (Appearance) + currentframe, px, py);
             end;
          end
          else if Race = 110 then
                  BodySurface := WMon24Img.GetCachedImage ( 1670 + currentframe, px, py)
          else if Race = 118 then
                  BodySurface := WMon25Img.GetCachedImage ( 1650 + currentframe, px, py);

      end
      else begin
          if Race = 83 then begin
             case CurrentAction of
                SM_LIGHTING:
                   BodySurface := WDragonImg.GetCachedImage ( 40+ endframe - currentframe, ax, ay);
                SM_DRAGON_FIRE1: // FireDragon
                   BodySurface := WDragonImg.GetCachedImage ( 10+ endframe - currentframe, ax, ay);
                SM_DRAGON_FIRE2:
                   BodySurface := WDragonImg.GetCachedImage ( 20+ endframe - currentframe, ax, ay);
                SM_DRAGON_FIRE3:
                   BodySurface := WDragonImg.GetCachedImage ( 30+ endframe - currentframe, ax, ay);
                else
                   BodySurface := mimg.GetCachedImage (GetOffset (Appearance) + endframe - currentframe, px, py);
             end;
          end
          else if Race = 110 then
                  BodySurface := WMon24Img.GetCachedImage ( 1670 + currentframe, px, py)
          else if Race = 118 then
                  BodySurface := WMon25Img.GetCachedImage ( 1650 + currentframe, px, py);
      end;
   end;

   if BoUseEffect then begin
       if Race = 83 then begin
          case CurrentAction of
             SM_LIGHTING:
                AttackEffectSurface := WDragonImg.GetCachedImage ( 60+ effectframe, ax, ay);
             SM_DRAGON_FIRE1: // FireDragon
                AttackEffectSurface := WDragonImg.GetCachedImage ( 90+ effectframe, ax, ay);
             SM_DRAGON_FIRE2:
                AttackEffectSurface := WDragonImg.GetCachedImage (100+ effectframe, ax, ay);
             SM_DRAGON_FIRE3:
                AttackEffectSurface := WDragonImg.GetCachedImage (110+ effectframe, ax, ay);
          end;
       end
       else if Race = 110 then begin
//            if CurrentAction = SM_NOWDEATH then
            if ((1670 + currentframe+20) > 2089) and ((1670 + currentframe+20) < 2108)  then begin
//      DScreen.AddChatBoardString ('���õ�� �״� ����Ʈ: effectframe=> '+InttoStr(1670 + currentframe+60), clYellow, clRed);
               AttackEffectSurface := WMon24Img.GetCachedImage ( 1670 + currentframe+20, ax, ay);
            end
            else
               AttackEffectSurface := WMon24Img.GetCachedImage ( 1670 + currentframe+40, ax, ay);
       end
       else if Race = 118 then begin
               AttackEffectSurface := WMon25Img.GetCachedImage ( 1650+670 + currentframe, ax, ay);
//      DScreen.AddChatBoardString ('��������: effectframe=> '+InttoStr(1650+670 + currentframe), clYellow, clRed);
       end;
   end;
   if Race = 83 then begin
      px := px - 14;
      py := py - 15;
      ax := ax - 14;
      ay := ay - 15;
   end;

end;

procedure TFireDragon.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
//   startframe2: integer;
begin
   if Race <> 118 then Dir := 0;
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of

      SM_TURN:
         begin
            starttime := GetTickCount;
            defframecount := pm.ActStand.frame;
            Shift (Dir, 0, 0, 1);
            if Race = 110 then begin
               case TempState of
                  1: startframe := 0;
                  2: startframe := 80;
                  3: startframe := 160;
                  4: startframe := 240;
                  5: startframe := 320;
               end;
               WarMode := True;
               frametime := 150;
               endframe := startframe + 19;
               starttime := GetTickCount;
               defframecount := 20;
               BoUseEffect := TRUE;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Race = 118 then begin
//      DScreen.AddChatBoardString ('�������� SM_TURN:', clYellow, clRed);
               startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
               endframe := startframe + pm.ActStand.frame - 1;
               frametime := pm.ActStand.ftime;
               starttime := GetTickCount;
               defframecount := pm.ActStand.frame;
               Shift (Dir, 0, 0, 1);
//               BoUseEffect := TRUE;
            end;
         end;
      SM_WALK, SM_BACKSTEP:
         begin
            if Race = 118 then begin
//      DScreen.AddChatBoardString ('�������� SM_WALK:', clYellow, clRed);
               startframe := pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
               endframe := startframe + pm.ActWalk.frame - 1;
               frametime := WalkFrameDelay; //pm.ActWalk.ftime;
               starttime := GetTickCount;
               maxtick := pm.ActWalk.UseTick;
               curtick := 0;
//               BoUseEffect := TRUE;
               //WarMode := FALSE;
               movestep := 1;
               if CurrentAction = SM_WALK then
                  Shift (Dir, movestep, 0, endframe-startframe+1)
               else  //sm_backstep
                  Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
            end;
         end;
      SM_HIT:    // �ٰŸ� ����
         begin
            if Race = 118 then begin
//      DScreen.AddSysMsg ('�������� SM_HIT:');
               Shift (Dir, 0, 0, 1);
               startframe := pm.ActAttack.start + Dir * 10;
               endframe  := startframe + 9;
               frametime := pm.ActAttack.ftime;
               starttime := GetTickCount;
               WarModeTime := GetTickCount;
//               BoUseEffect := TRUE;
            end;
         end;

      SM_LIGHTING,SM_LIGHTING_1..SM_LIGHTING_3:
//      SM_DRAGON_LIGHTING:
         begin
            startframe := 0;
            endframe   := 19;
            frametime  := 150;

            starttime  := GetTickCount;

            BoUseEffect := TRUE;
            effectframe := 0;
            effectstart := 0;

            effectend   := 19;
            effectstarttime := GetTickCount;
            effectframetime := 150;

            CurEffFrame := 0;
            BoUseMagic := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);

            if Race = 110 then begin
               case TempState of
                  1: startframe := 20;
                  2: startframe := 100;
                  3: startframe := 180;
                  4: startframe := 260;
                  5: startframe := 340;
               end;
               endframe   := startframe + 9;
               frametime  := 150;
               BoUseEffect := TRUE;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end;
            if (CurrentAction = SM_LIGHTING) and (Race = 118) then begin
               Shift (Dir, 0, 0, 1);
               startframe := 340 + Dir * 10;
               endframe  := startframe + 5;
               frametime := pm.ActAttack.ftime;
               starttime := GetTickCount;
               WarModeTime := GetTickCount;
               PlaySound(2642);
//               BoUseEffect := TRUE;
            end
            else if (CurrentAction = SM_LIGHTING_1) and (Race = 118) then begin
               Shift (Dir, 0, 0, 1);
               startframe := 420 + Dir * 10;
               endframe  := startframe + 5;
               frametime := pm.ActCritical.ftime;
               starttime := GetTickCount;
               WarModeTime := GetTickCount;
//               BoUseEffect := TRUE;
            end
            else if (CurrentAction = SM_LIGHTING_2) and (Race = 118) then begin
               Shift (Dir, 0, 0, 1);
               startframe := 500 + Dir * 10;
               endframe  := startframe + 5;
               frametime := 120;
               starttime := GetTickCount;
               WarModeTime := GetTickCount;
//               BoUseEffect := TRUE;
            end
            else if (CurrentAction = SM_LIGHTING_3) and (Race = 118) then begin
               Shift (Dir, 0, 0, 1);
               startframe := 580 + Dir * 10;
               endframe  := startframe + 7;
               frametime := 120;
               starttime := GetTickCount;
               WarModeTime := GetTickCount;
//               BoUseEffect := TRUE;
            end;
         end;
      SM_DRAGON_FIRE1, SM_DRAGON_FIRE2, SM_DRAGON_FIRE3:
         begin
            if Race = 83 then begin
               startframe := 0;
               endframe   := 5;
               frametime  := 150;
               starttime  := GetTickCount;

               BoUseEffect := TRUE;
               effectframe := 0;
               effectstart := 0;

               effectend   := 10;
               effectstarttime := GetTickCount;
               effectframetime := 150;

               CurEffFrame := 0;
               BoUseMagic := TRUE;
               WarModeTime := GetTickCount;
               Shift (Dir, 0, 0, 1);
            end;
         end;
      SM_STRUCK:
         begin
            if Race = 83 then begin
               startframe := 0;
               endframe := 9;
               frametime := 300; //pm.ActStruck.ftime;
               starttime := GetTickCount;
            end;
            if Race = 118 then begin
               startframe := pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
               endframe := startframe + pm.ActStruck.frame - 1;
               frametime := struckframetime; //pm.ActStruck.ftime;
               starttime := GetTickCount;
//               BoUseEffect := TRUE;
            end;
         end;
      SM_NOWDEATH:
         begin
            if Race = 110 then begin
//      DScreen.AddChatBoardString ('���õ�� SM_NOWDEATH:', clYellow, clRed);
               startframe := pm.ActDie.start;
               endframe := startframe + pm.ActDie.frame - 1;
               frametime := pm.ActDie.ftime;
               starttime := GetTickCount;

               BoUseEffect := TRUE;
               effectframe := 420;
               effectstart := 420;
               frametime := 150;
               endframe := startframe + 17;
               starttime := GetTickCount;
//               defframecount := 18;
               BoUseEffect := TRUE;
               effectstarttime := GetTickCount;
               effectframetime := 150;
//               PlaySound (159);
            end
            else if Race = 118 then begin
               startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
               endframe := startframe + pm.ActDie.frame - 1;
               frametime := pm.ActDie.ftime;
               starttime := GetTickCount;
               BoUseEffect := TRUE;
            end;
         end;
      SM_DEATH:
         begin
            if Race = 118 then begin
{               startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
               endframe := startframe + pm.ActDie.frame - 1;
               startframe := endframe;
               frametime := pm.ActDie.ftime;
               starttime := GetTickCount;}
               BoUseEffect := TRUE;
            end;
         end;
      SM_DIGUP: //�ȱ� ����, SM_DIGUP, ���� ����.
         begin
            if Race = 83 then begin
               //WarMode := FALSE;
               Shift (0, 0, 0, 1);
               startframe := 0;
               endframe := 9;
               frametime := 300;
               starttime := GetTickCount;
            end;
         end;
   end;
   if Race in [108,109,110,118] then BoUseEffect := True;
end;


procedure TFireDragon.Run;
var
   prv: integer;
   effectframetimetime, frametimetime: longword;
   meff: TFlyingAxe;
   bofly: Boolean;
   tx, ty, i : integer;
begin
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   //���� ȿ��
   if borunsound then begin
      PlaySound(8201);
      borunsound := False;
    end;

   if BoUseEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
//            if Not ((Race = 110) and ((1670 + currentframe+20) > 2089) and ((1670 + currentframe+20) < 2108))  then
            if Race in [108,109,110,118] then begin
               if Death then BoUseEffect := FALSE
               else BoUseEffect := TRUE;
            end
            else BoUseEffect := FALSE;
         end;
      end;
   end;

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
            BoUseDieEffect := FALSE;
         end;

         if Race = 118 then begin
            if (CurrentAction = SM_LIGHTING_1) and (currentframe-startframe = 4) then begin
//      DScreen.AddChatBoardString ('��������-���� SM_LIGHTING_1:', clYellow, clRed);
//      DScreen.AddSysMsg ('��������-���� SM_LIGHTING_1:');
                PlayScene.NewMagic (self,
                                      MAGIC_KINGTURTLE_ATT1,
                                      MAGIC_KINGTURTLE_ATT1,
                                      XX,
                                      YY,
                                      XX,       //TargetX,
                                      YY,       //TargetY,
                                      RecogId,  //TargetRecog,
                                      mtGroundEffect,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (10022);
            end
            else if (CurrentAction = SM_LIGHTING_2) and (currentframe-startframe = 4) then begin
//      DScreen.AddChatBoardString ('��������-��ü������ SM_LIGHTING_2:', clYellow, clRed);
//      DScreen.AddSysMsg ('��������-��ü������ SM_LIGHTING_2:');
               if Not LightningTimer.Enabled then begin
                  LightningTimer.Enabled := True;
                  PlaySound (10450); //���ʻ��
               end;
            end
            else if (CurrentAction = SM_LIGHTING_3) and (currentframe-startframe = 1) then begin
//      DScreen.AddChatBoardString ('��������-���ͼ�ȯ SM_LIGHTING_3:', clYellow, clRed);
//      DScreen.AddSysMsg ('��������-���ͼ�ȯ SM_LIGHTING_3:');
                PlayScene.NewMagic (self,
                                      MAGIC_KINGTURTLE_ATT3,
                                      MAGIC_KINGTURTLE_ATT3,
                                      XX,
                                      YY,
                                      XX,       //TargetX,
                                      YY,       //TargetY,
                                      RecogId,  //TargetRecog,
                                      mtGroundEffect,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (10160);
            end

         end
         else if Race = 110 then begin //�������� ���� ����
            if (CurrentAction = SM_LIGHTING) and (currentframe-startframe = 1) then begin
//      DScreen.AddChatBoardString ('���õ�� SM_LIGHTING-������� State=> '+IntToStr(TempState), clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_SOULBALL_ATT1,
                                      MAGIC_SOULBALL_ATT1,
                                      XX,
                                      YY,
                                      XX,       //TargetX,
                                      YY,       //TargetY,
                                      RecogId,  //TargetRecog,
                                      mtGroundEffect,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (2576);
            end
//            else if (CurrentAction = SM_LIGHTING_1) and (currentframe = 4) then begin
            else if (CurrentAction = SM_LIGHTING_1) and (currentframe-startframe = 1) then begin
//      DScreen.AddChatBoardString ('���õ�� SM_LIGHTING_1-���Ÿ� �������� State=> '+IntToStr(TempState), clYellow, clRed);
                PlayScene.NewMagic (self,
                                      MAGIC_SOULBALL_ATT2, //���Ÿ����� ����
                                      MAGIC_SOULBALL_ATT2,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtThunder,
                                      FALSE,
                                      30,
                                      bofly);
                PlaySound (2577);
            end
            else if (CurrentAction = SM_LIGHTING_2) and (currentframe-startframe = 1)then begin
//            else if (CurrentAction = SM_LIGHTING_2) and (currentframe = 4) then begin
//      DScreen.AddChatBoardString ('���õ�� SM_LIGHTING_2-�ʻ�� State=> '+IntToStr(TempState), clYellow, clRed);
               if Not LightningTimer.Enabled then begin
                  LightningTimer.Enabled := True;
                  PlaySound (2578); //���ʻ��
               end;
            end
         end
         else if (CurrentAction = SM_LIGHTING) and (currentframe-startframe = 4) then begin
            PlaySound (8202);
            LightningTimer.Enabled := True;
         end
         else if ((CurrentAction = SM_DRAGON_FIRE1) or (CurrentAction = SM_DRAGON_FIRE2) or (CurrentAction = SM_DRAGON_FIRE3))
             and (currentframe-startframe = 4) then begin

                PlayScene.NewMagic (self,
                                      CurrentAction, //11,
                                      CurrentAction,
                                      XX,
                                      YY,
                                      TargetX,
                                      TargetY,
                                      TargetRecog,
                                      mtFly,
                                      TRUE,
                                      30,
                                      bofly);
                PlaySound (8203);
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end else begin
      if Race = 110 then begin
         if GetTickCount - defframetime > 150 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
//      DScreen.AddChatBoardString ('���õ�� DefaultMotion currentdefframe=> '+InttoStr(currentdefframe), clYellow, clRed);
         DefaultMotion;
      end
      else if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;


procedure TFireDragon.LightningTimerTimer(Sender: TObject);
var
   tx, ty, n, kx, ky : integer;
   bofly: Boolean;
begin

    if Race = 83 then begin
       if LightningTimer.Tag = 0 then begin
          LightningTimer.Tag := LightningTimer.Tag + 1;
          LightningTimer.Interval := 800;
          Exit;
       end
       else LightningTimer.Interval := 70;
       tx := XX - 5;
       ty := YY + 3;

       Randomize;
       if LightningTimer.Tag = 0 then begin
          PlayScene.NewMagic (self, SM_DRAGON_LIGHTING, SM_DRAGON_LIGHTING, XX, YY, tx-3, ty+3, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, SM_DRAGON_LIGHTING, SM_DRAGON_LIGHTING, XX, YY, tx-3, ty-3, 0, mtThunder, FALSE, 30, bofly);
       end;

       n := random(4);
       kx := random(7);
       ky := random(5);
       case n of
          0: PlayScene.NewMagic (self, SM_DRAGON_LIGHTING, SM_DRAGON_LIGHTING, XX, YY, tx+kx-2, ty-ky+1, 0, mtThunder, FALSE, 30, bofly);
          1: PlayScene.NewMagic (self, SM_DRAGON_LIGHTING, SM_DRAGON_LIGHTING, XX, YY, tx-kx,   ty+ky, 0, mtThunder, FALSE, 30, bofly);
          2: PlayScene.NewMagic (self, SM_DRAGON_LIGHTING, SM_DRAGON_LIGHTING, XX, YY, tx-kx,   ty-ky+1, 0, mtThunder, FALSE, 30, bofly);
          3: PlayScene.NewMagic (self, SM_DRAGON_LIGHTING, SM_DRAGON_LIGHTING, XX, YY, tx+kx-2, ty+ky, 0, mtThunder, FALSE, 30, bofly);
       end;

       if (LightningTimer.Tag mod 3) = 0 then PlaySound (8206);
       LightningTimer.Interval := LightningTimer.Interval + 15;
       LightningTimer.Tag := LightningTimer.Tag+1;

       if LightningTimer.Tag > 7 then begin
          LightningTimer.Interval := 70;
          LightningTimer.Tag := 0;
          LightningTimer.Enabled := False;
       end;
    end
    else if Race = 110 then begin //���õ��
       if LightningTimer.Tag = 0 then begin
          LightningTimer.Tag := LightningTimer.Tag + 1;
          LightningTimer.Interval := 10;
          Exit;
       end;
//       else LightningTimer.Interval := 500;

       tx := Myself.XX;
       ty := Myself.YY;

//       Randomize;
       n := random(4);
       kx := random(7);
       ky := random(5);

       if LightningTimer.Tag = 0 then begin
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_1, MAGIC_SOULBALL_ATT3_1, XX, YY, tx, ty, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_2, MAGIC_SOULBALL_ATT3_2, XX, YY, tx-2, ty, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_3, MAGIC_SOULBALL_ATT3_3, XX, YY, tx, ty-2, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_4, MAGIC_SOULBALL_ATT3_4, XX, YY, tx-kx, ty-ky, 0, mtThunder, FALSE, 30, bofly);
          LightningTimer.Interval := 500;
       end
       else if LightningTimer.Tag = 2 then begin
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_1, MAGIC_SOULBALL_ATT3_1, XX, YY, tx-2, ty-2, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_2, MAGIC_SOULBALL_ATT3_2, XX, YY, tx+2, ty-2, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_3, MAGIC_SOULBALL_ATT3_3, XX, YY, tx+kx, ty, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_4, MAGIC_SOULBALL_ATT3_4, XX, YY, tx-kx, ty, 0, mtThunder, FALSE, 30, bofly);
       end;

       PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_5, MAGIC_SOULBALL_ATT3_5, XX, YY, tx+kx, ty-ky, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_1, MAGIC_SOULBALL_ATT3_1, XX, YY, tx-kx-2, ty+ky, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_2, MAGIC_SOULBALL_ATT3_2, XX, YY, tx-kx, ty-ky, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_3, MAGIC_SOULBALL_ATT3_3, XX, YY, tx+kx+2, ty+ky, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_4, MAGIC_SOULBALL_ATT3_4, XX, YY, tx+kx, ty, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_SOULBALL_ATT3_5, MAGIC_SOULBALL_ATT3_5, XX, YY, tx-kx, ty, 0, mtThunder, FALSE, 30, bofly);

//       if (LightningTimer.Tag mod 3) = 0 then PlaySound (8206);
       LightningTimer.Interval := LightningTimer.Interval + 100;
       LightningTimer.Tag := LightningTimer.Tag+1;

       if LightningTimer.Tag > 7 then begin
          LightningTimer.Interval := 10;
          LightningTimer.Tag := 0;
          LightningTimer.Enabled := False;
       end;
    end
    else if Race = 118 then begin //��������
       if LightningTimer.Tag = 0 then begin
          LightningTimer.Tag := LightningTimer.Tag + 1;
          LightningTimer.Interval := 10;
          Exit;
       end;
//       else LightningTimer.Interval := 500;

       tx := Myself.XX;
       ty := Myself.YY;

//       Randomize;
       n := random(4);
       kx := random(7);
       ky := random(5);

       if LightningTimer.Tag = 0 then begin
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx, ty, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx-2, ty+2, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx, ty+3, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx-kx, ty-ky+1, 0, mtThunder, FALSE, 30, bofly);
          LightningTimer.Interval := 500;
       end
       else if LightningTimer.Tag = 2 then begin
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx-2, ty+3, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx+2, ty+2, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx+kx, ty, 0, mtThunder, FALSE, 30, bofly);
          PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx-kx, ty+1, 0, mtThunder, FALSE, 30, bofly);
       end;

       PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx+kx, ty-ky+1, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx-kx-2, ty+ky+2, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx-kx, ty-ky+3, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx+kx+2, ty+ky+1, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_2, MAGIC_KINGTURTLE_ATT2_2, XX, YY, tx+kx, ty+2, 0, mtThunder, FALSE, 30, bofly);
       PlayScene.NewMagic (self, MAGIC_KINGTURTLE_ATT2_1, MAGIC_KINGTURTLE_ATT2_1, XX, YY, tx-kx, ty, 0, mtThunder, FALSE, 30, bofly);

       if LightningTimer.Tag = 4 then PlaySound (10450);
       LightningTimer.Interval := LightningTimer.Interval + 200;
       LightningTimer.Tag := LightningTimer.Tag+1;

       if LightningTimer.Tag > 7 then begin
          LightningTimer.Interval := 10;
          LightningTimer.Tag := 0;
          LightningTimer.Enabled := False;
       end;
    end;


end;

procedure TFireDragon.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
   inherited DrawEff(dsurface, dx, dy);
   if (Race = 83) or (Race = 110) or BoViewEffect then begin
   if BoUseEffect then
      if AttackEffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    AttackEffectSurface, 1);
      end;
   end;
end;

// �����Ż�(�뼮��) -----------------------------------------------------------------------------

constructor TDragonStatue.Create;
begin
   inherited Create;
   AttackEffectSurface := nil;
end;

procedure  TDragonStatue.LoadSurface;
var
   mimg: TWMImages;
begin
   mimg := WDragonImg;

   if mimg <> nil then
      BodySurface := mimg.GetCachedImage (GetOffset(Appearance), px, py);

   if BoUseEffect then begin
      case Race of
         84,85,86: begin // �뼮���
             EffectSurface := WDragonImg.GetCachedImage (
                310 + effectframe, ax, ay);
         end;
         87,88,89: begin // �뼮����
             EffectSurface := WDragonImg.GetCachedImage (
                330 + effectframe, ax, ay);
          end;
      end;
   end;

end;

procedure TDragonStatue.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   Dir := 0;
   currentframe := -1;
   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);

   case CurrentAction of
      SM_LIGHTING:
         begin
            startframe  := 0;
            endframe    := 9;
            frametime  := 100;
            starttime  := GetTickCount;

            BoUseEffect := TRUE;
            effectstart := 0;
            effectframe := 0;
            effectend   := 9;
            effectstarttime := GetTickCount;
            effectframetime := 100;
         end;
      SM_DIGUP: //�ȱ� ����, SM_DIGUP, ���� ����.
         begin
            Shift (0, 0, 0, 1);
            startframe := 0;
            endframe := 9;
            frametime := 100;
            starttime := GetTickCount;
         end;
   end;
end;

procedure TDragonStatue.Run;
var
   prv: integer;
   effectframetimetime, frametimetime: longword;
   meff: TFlyingAxe;
   bofly: Boolean;
   tx, ty, i : integer;
begin
   Dir := 0;
   if (CurrentAction = SM_WALK) or (CurrentAction = SM_BACKSTEP) or (CurrentAction = SM_RUN) then exit;

   msgmuch := FALSE;
   if MsgList.Count >= 2 then msgmuch := TRUE;

   if BoUseEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
            BoUseEffect := FALSE;
         end;
      end;
   end;

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

      if msgmuch then frametimetime := Round(frametime * 2 / 3)
      else frametimetime := frametime;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            Inc (currentframe);
            starttime := GetTickCount;
         end else begin
            //������ ����.
            CurrentAction := 0; //���� �Ϸ�
            BoUseEffect := FALSE;
            BoUseDieEffect := FALSE;
         end;

         if (CurrentAction = SM_LIGHTING) and (currentframe = 4) then begin
            PlayScene.NewMagic (self, MAGIC_FIREBURN, MAGIC_FIREBURN, XX, YY, TargetX, TargetY, 0, mtThunder, FALSE, 30, bofly);
            PlaySound(8222);
         end;
      end;
      currentdefframe := 0;
      defframetime := GetTickCount;
   end
    else begin
      if GetTickCount - smoothmovetime > 200 then begin
         if GetTickCount - defframetime > 500 then begin
            defframetime := GetTickCount;
            Inc (currentdefframe);
            if currentdefframe >= defframecount then
               currentdefframe := 0;
         end;
         DefaultMotion;
      end;
   end;

   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;

procedure TDragonStatue.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
   inherited DrawEff(dsurface, dx, dy);
   if BoViewEffect then begin
   if BoUseEffect then
      if EffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    EffectSurface, 1);
      end;
   end;
end;

// �ָ��ݷ��� -----------------------------------------------------------------------------------------

constructor TJumaThunderMon.Create;
begin
   inherited Create;
   BoUseEffect := True;
   AttackEffectSurface := nil;
end;

procedure  TJumaThunderMon.LoadSurface;
begin
   inherited LoadSurface;
   case Race of
      //����
      92:
         begin
            if BoUseEffect then begin
               EffectSurface := WMon23Img.GetCachedImage (effectframe, ax, ay);
            end;
         end;
   end;
end;

procedure TJumaThunderMon.DrawEff (dsurface: TDXTexture; dx, dy: integer);
var
   idx: integer;
   d: TDXTexture;
   ceff: TColorEffect;
begin
   if BoViewEffect then begin
   if BoUseEffect then
      if EffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    EffectSurface, 1);
      end;
   end;
end;

procedure TJumaThunderMon.CalcActorFrame;
var
   pm: PTMonsterAction;
   actor: TActor;
   haircount, scx, scy, stx, sty: integer;
   meff: TCharEffect;
begin
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   case CurrentAction of
      SM_HIT, // �ٰŸ� ����
      SM_FLYAXE:
         begin
            BoUseEffect := TRUE;
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe  := startframe + pm.ActAttack.frame - 1;
            frametime := 110;
            starttime := GetTickCount;

            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
            BoUseEffect := TRUE;

            effectframe := 1100 + Dir * 10;
            effectstart := 1100 + Dir * 10;
            effectend := effectstart + pm.ActAttack.frame-1;//endframe;
            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;

      SM_TURN:
         begin
            if (State and STATE_STONE_MODE) <> 0 then begin
               BoUseEffect := False;
               startframe := 420 + Dir * 10;
               endframe := startframe;
               frametime := 100;
               starttime := GetTickCount;
               defframecount := 6;
            end else begin
               BoUseEffect := True;
               startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
               endframe := startframe + pm.ActStand.frame - 1;
               frametime := 250;
               starttime := GetTickCount;
               defframecount := pm.ActStand.frame;

               effectframe := 940 + Dir * 10;
               effectstart := 940 + Dir * 10;
               effectend := effectstart + pm.ActStand.frame-1;//endframe;
               effectstarttime := GetTickCount;
               effectframetime := frametime;
            end;

            Shift (Dir, 0, 0, 1);
         end;
      SM_WALK, SM_BACKSTEP:
         begin
            BoUseEffect := TRUE;
            startframe := pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe + pm.ActWalk.frame - 1;
            frametime := 160; //pm.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;

            effectframe := 1020 + Dir * 10;;
            effectstart := 1020 + Dir * 10;;
            effectend := effectstart + pm.ActWalk.frame-1;//endframe;
            effectstarttime := GetTickCount;
            effectframetime := frametime;

            //WarMode := FALSE;
            movestep := 1;
            if CurrentAction = SM_WALK then begin
               Shift (Dir, movestep, 0, endframe-startframe+1)
            end
            else begin  //sm_backstep
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
            end;
         end;

      SM_DIGUP: //�ȱ� ����, SM_DIGUP, ���� ����.
         begin
            startframe := 420 + Dir * 10;
            endframe := startframe + 5;
            frametime := 150;
            starttime := GetTickCount;
            //WarMode := FALSE;
            Shift (Dir, 0, 0, 1);
         end;

      SM_STRUCK:
         begin
            BoUseEffect := TRUE;
            startframe := pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
            endframe := startframe + pm.ActStruck.frame - 1;
            frametime := 90; //pm.ActStruck.ftime;
            starttime := GetTickCount;

            effectframe := 1180 + Dir * 10;
            effectstart := 1180 + Dir * 10;
            effectend := effectstart + pm.ActStruck.frame-1;//endframe;
            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;

      SM_DEATH:
         begin
            BoUseEffect := False;
            startframe := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip);
            endframe := startframe + pm.ActDie.frame - 1;
            startframe := endframe; //
            frametime := 100;
            starttime := GetTickCount;
         end;

      SM_LIGHTING:
         begin
            BoUseEffect := TRUE;
//            startframe := 770 + Dir * 10;
            startframe := 340 + Dir * 10;
            endframe   := startframe + 5;
            frametime  := 180;
            starttime  := GetTickCount;
            CurEffFrame := 0;
            BoUseMagic := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);

            effectframe := 1200 + Dir * 10;
            effectstart := 1200 + Dir * 10;
            effectend := effectstart + 5;//endframe;
            effectstarttime := GetTickCount;
            effectframetime := frametime;
         end;
      else
         inherited CalcActorFrame;
   end;
end;

end.
