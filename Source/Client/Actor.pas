unit Actor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grobal2, magiceff, Wil, ClFunc, HGETextures;

const
   MAXACTORSOUND = 3;
   CMMX     = 150;
   CMMY     = 200;

   HUMANFRAME = 600;
   MONFRAME  = 280;
   EXPMONFRAME = 360;
   SCULMONFRAME = 440;
   ZOMBIFRAME = 430;
   MERCHANTFRAME = 60;
   MAXSAY = 5;

   RUN_MINHEALTH = 10;
   DEFSPELLFRAME = 10;
   FIREHIT_READYFRAME = 6;
   MAGBUBBLEBASE = 3890;
   MAGBUBBLESTRUCKBASE = 3900; 
   MAXWPEFFECTFRAME = 5;
   WPEFFECTBASE = 3750;
   EFFECTBASE = 0;

type
   TActionInfo = record
      start   : word;              // ��ʼ֡
      frame   : word;              // ֡��
      skip    : word;              // ������֡��
      ftime   : word;              // ÿ֡���ӳ�ʱ�䣨���룩
      usetick : byte;              // ���ƽ, �̵� ���ۿ��� ����
   end;
   PTActionInfo = ^TActionInfo;

   //��ҵĶ�������
   THumanAction = record
      ActStand:      TActionInfo;   //1
      ActWalk:       TActionInfo;   //8
      ActRun:        TActionInfo;   //8
      ActRushLeft:   TActionInfo;
      ActRushRight:  TActionInfo;
      ActWarMode:    TActionInfo;   //1
      ActHit:        TActionInfo;   //6
      ActHeavyHit:   TActionInfo;   //6
      ActBigHit:     TActionInfo;   //6
      ActFireHitReady: TActionInfo; //6
      ActSpell:      TActionInfo;   //6
      ActSitdown:    TActionInfo;   //1
      ActStruck:     TActionInfo;   //3
      ActDie:        TActionInfo;   //4
   end;
   PTHumanAction = ^THumanAction;

   TMonsterAction = record
      ActStand:      TActionInfo;   //1
      ActWalk:       TActionInfo;   //8
      ActAttack:     TActionInfo;   //6
      ActCritical:   TActionInfo;   //6
      ActStruck:     TActionInfo;   //3
      ActDie:        TActionInfo;   //4
      ActDeath:      TActionInfo;
   end;
   PTMonsterAction = ^TMonsterAction;

const
   //���ද������
   //ÿ������ÿ������ÿ���Ա�600��ͼ
   //�輶��=L���Ա�=S����ʼ֡=L*600+600*S

   //Start:�ö�������������µĿ�ʼ֡
   //frame:�ö�����Ҫ��֡��
   //skip:������֡��
   HA: THumanAction = (//��ʼ֡       ��Ч֡     ����֡    ÿ֡�ӳ�
        ActStand:  (start: 0;      frame: 4;  skip: 4;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 64;     frame: 6;  skip: 2;  ftime: 90;   usetick: 2);
        ActRun:    (start: 128;    frame: 6;  skip: 2;  ftime: 120;  usetick: 3);
        ActRushLeft: (start: 128;    frame: 3;  skip: 5;  ftime: 120;  usetick: 3);
        ActRushRight:(start: 131;    frame: 3;  skip: 5;  ftime: 120;  usetick: 3);
        ActWarMode:(start: 192;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        //ActHit:    (start: 200;    frame: 5;  skip: 3;  ftime: 140;  usetick: 0);
        ActHit:    (start: 200;    frame: 6;  skip: 2;  ftime: 85;   usetick: 0);
        ActHeavyHit:(start: 264;   frame: 6;  skip: 2;  ftime: 90;   usetick: 0);
        ActBigHit: (start: 328;    frame: 8;  skip: 0;  ftime: 70;   usetick: 0);
        ActFireHitReady: (start: 192; frame: 6;  skip: 4;  ftime: 70;   usetick: 0);
        ActSpell:  (start: 392;    frame: 6;  skip: 2;  ftime: 60;   usetick: 0);
        ActSitdown:(start: 456;    frame: 2;  skip: 0;  ftime: 300;  usetick: 0);
        ActStruck: (start: 472;    frame: 3;  skip: 5;  ftime: 70;  usetick: 0);
        ActDie:    (start: 536;    frame: 4;  skip: 4;  ftime: 120;  usetick: 0)
      );

   MA9: TMonsterAction = (  //�౸��
        ActStand:  (start: 0;      frame: 1;  skip: 7;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 64;     frame: 6;  skip: 2;  ftime: 120;  usetick: 3);
        ActAttack: (start: 64;     frame: 6;  skip: 2;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 64;     frame: 6;  skip: 2;  ftime: 100;  usetick: 0);
        ActDie:    (start: 0;      frame: 1;  skip: 7;  ftime: 140;  usetick: 0);
        ActDeath:  (start: 0;      frame: 1;  skip: 7;  ftime: 0;    usetick: 0);
      );
   MA10: TMonsterAction = (  //������ʿ(8Frame¥��)
        //ÿ������8֡    //����������Ʋ�������м��֣�//������280��
        ActStand:  (start: 0;      frame: 4;  skip: 4;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 64;     frame: 6;  skip: 2;  ftime: 120;  usetick: 3);
        ActAttack: (start: 128;    frame: 4;  skip: 4;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 192;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 208;    frame: 4;  skip: 4;  ftime: 140;  usetick: 0);
        ActDeath:  (start: 272;    frame: 1;  skip: 0;  ftime: 0;    usetick: 0);
      );
   MA11: TMonsterAction = (  //�罿(10Frame¥��) //ÿ������10֡ //280,(360��),440,430,,
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 120;  usetick: 3);
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 140;  usetick: 0);
        ActDeath:  (start: 340;    frame: 1;  skip: 0;  ftime: 0;    usetick: 0);
      );
   MA12: TMonsterAction = (  //���, ������ �ӵ� ������.//ÿ������8֡��ÿ������8�����򣬹�7�ֶ��� (280),360,440,430,,
        ActStand:  (start: 0;      frame: 4;  skip: 4;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 64;     frame: 6;  skip: 2;  ftime: 120;  usetick: 3);
        ActAttack: (start: 128;    frame: 6;  skip: 2;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 192;    frame: 2;  skip: 0;  ftime: 150;  usetick: 0);
        ActDie:    (start: 208;    frame: 4;  skip: 4;  ftime: 160;  usetick: 0);
        ActDeath:  (start: 272;    frame: 1;  skip: 0;  ftime: 0;    usetick: 0);
      );
   MA13: TMonsterAction = (  //ʳ�˻�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 10;     frame: 8;  skip: 2;  ftime: 160;  usetick: 0); //����...
        ActAttack: (start: 30;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //actattack��30��ʼ�ǴӸ�����λ������Ч��
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 110;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0); //����110��ʼ����
        ActDie:    (start: 130;    frame: 10; skip: 0;  ftime: 120;  usetick: 0); //130��ʼ����Ч��
        ActDeath:  (start: 20;     frame: 9;  skip: 0;  ftime: 150;  usetick: 0); //20��ʼ��ʳ�˻�������Ч��Ҳ��������Ч�������������ã���ֻ��9֡���һ֡��ȥ
      );
   MA14: TMonsterAction = (  //mon3���������սʿ,,��������ͬma13
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start: 340;    frame: 10; skip: 0;  ftime: 100;  usetick: 0); //����ΰ��(��ȯ)
      );
   MA15: TMonsterAction = (  //����ս��
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start: 1;      frame: 1;  skip: 0;  ftime: 100;  usetick: 0);
      );
   MA16: TMonsterAction = (  //������� ������ mon5����ĵ罩ʬ����������ƶ���ħ�����������Ĺ���һ��??
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 160;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 4;  skip: 6;  ftime: 160;  usetick: 0);
        ActDeath:  (start: 0;      frame: 1;  skip: 0;  ftime: 160;  usetick: 0);
      );
   MA17: TMonsterAction = (  //�ٵ������� �� mon6�еĺ��н�������ʯĹʬ������һ����
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 60;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 100;  usetick: 0);
        ActDeath:  (start: 340;    frame: 1;  skip: 0;  ftime: 140;  usetick: 0); //
      );
   MA19: TMonsterAction = (  //���� (�״°� ��������)
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 140;  usetick: 0);
        ActDeath:  (start: 340;    frame: 1;  skip: 0;  ftime: 140;  usetick: 0); //
      );
   MA20: TMonsterAction = (  //�׾��� ��Ƴ��� ����)
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 100;  usetick: 0);
        ActDeath:  (start: 340;    frame: 10; skip: 0;  ftime: 170;  usetick: 0); //�ٽ� ��Ƴ���
      );
   MA21: TMonsterAction = (  //����
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0); //
        ActAttack: (start: 10;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //�� �߻�
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 20;     frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 30;     frame: 10; skip: 0;  ftime: 160;  usetick: 0);
        ActDeath:  (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0); //
      );
   MA22: TMonsterAction = (  //�������(���Ҵ���,�����屺)
        ActStand:  (start: 80;     frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 160;    frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 240;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0); //
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 320;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 340;    frame: 10; skip: 0;  ftime: 160;  usetick: 0);
        ActDeath:  (start: 0;      frame: 6;  skip: 4;  ftime: 170;  usetick: 0); //�������
      );
   MA23: TMonsterAction = (  //�ָ���
        ActStand:  (start: 20;     frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 100;    frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 180;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0); //
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 260;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 280;    frame: 10; skip: 0;  ftime: 160;  usetick: 0);
        ActDeath:  (start: 0;      frame: 20; skip: 0;  ftime: 100;  usetick: 0); //�������
      );
   MA24: TMonsterAction = (  //����, ���� 2����
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start:240;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActStruck: (start: 320;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 340;    frame: 10; skip: 0;  ftime: 140;  usetick: 0);
        ActDeath:  (start: 420;    frame: 1;  skip: 0;  ftime: 140;  usetick: 0); //
      );
   MA25: TMonsterAction = (  //���׿�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 70;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //����
        ActAttack: (start: 20;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //��������
        ActCritical:(start: 10;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //��ħ����(���Ÿ�)
        ActStruck: (start: 50;     frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 60;     frame: 10; skip: 0;  ftime: 200;  usetick: 0);
        ActDeath:  (start: 80;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //
      );
   MA26: TMonsterAction = (  //����,
        ActStand:  (start: 0;      frame: 1;  skip: 7;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;      frame: 0;  skip: 0;  ftime: 160;  usetick: 0); //����...
        ActAttack: (start: 56;     frame: 6;  skip: 2;  ftime: 500;  usetick: 0); //����
        ActCritical:(start: 64;    frame: 6;  skip: 2;  ftime: 500;  usetick: 0); //�ݱ�
        ActStruck: (start: 0;      frame: 4;  skip: 4;  ftime: 100;  usetick: 0);
        ActDie:    (start: 24;     frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start: 0;      frame: 0;  skip: 0;  ftime: 150;  usetick: 0); //����..
      );
   MA27: TMonsterAction = (  //����
        ActStand:  (start: 0;     frame: 1;  skip: 7;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;     frame: 0;  skip: 0;  ftime: 160;  usetick: 0); //����...
        ActAttack: (start: 0;     frame: 0;  skip: 0;  ftime: 250;  usetick: 0);
        ActCritical:(start: 0;    frame: 0;  skip: 0;  ftime: 250;  usetick: 0);
        ActStruck: (start: 0;     frame: 0;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 0;     frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start: 0;     frame: 0;  skip: 0;  ftime: 150;  usetick: 0); //����..
      );
   MA28: TMonsterAction = (  //�ż� (���� ��)
        ActStand:  (start: 80;     frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 160;    frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start:  0;     frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start:  0;     frame: 10; skip: 0;  ftime: 100;  usetick: 0); //����..
      );
   MA29: TMonsterAction = (  //�ż� (���� ��)
        ActStand:  (start: 80;     frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 160;    frame: 6;  skip: 4;  ftime: 160;  usetick: 3); //
        ActAttack: (start: 240;    frame: 6;  skip: 4;  ftime: 100;  usetick: 0);
        ActCritical:(start: 0;     frame: 10; skip: 0;  ftime: 100;  usetick: 0);
        ActStruck: (start: 320;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 340;    frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start:  0;     frame: 10; skip: 0;  ftime: 100;  usetick: 0); //����..
      );

   MA30: TMonsterAction = (  //�����ο�, ����, ������
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //
        ActAttack: (start: 10;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //������
        ActCritical:(start: 10;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //
        ActStruck: (start: 20;     frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 30;     frame: 20; skip: 0;  ftime: 150;  usetick: 0);
        ActDeath:  (start: 0;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //
      );
   MA31: TMonsterAction = (  //���ȰŹ�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //
        ActAttack: (start: 10;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //������
        ActCritical:(start: 0;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //
        ActStruck: (start: 0;     frame: 2;  skip: 8;  ftime: 100;  usetick: 0);
        ActDie:    (start: 20;     frame: 10; skip: 0;  ftime: 200;  usetick: 0);
        ActDeath:  (start: 0;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //
      );
   MA32: TMonsterAction = (  //����
        ActStand:  (start: 0;      frame: 1;  skip: 9;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;     frame: 6; skip: 4;  ftime: 200;  usetick: 3); //
        ActAttack: (start: 0;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //������
        ActCritical:(start: 0;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //
        ActStruck: (start: 0;     frame: 2;  skip: 8;  ftime: 100;  usetick: 0);
        ActDie:    (start: 80;     frame: 10; skip: 0;  ftime: 80;  usetick: 0);
        ActDeath:  (start: 80;     frame: 10; skip: 0;  ftime: 200;  usetick: 3); //
      );
   MA33: TMonsterAction = (  //������, ���߾� (�ָ�����), �յ�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 200;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //������
        ActCritical:(start: 340;   frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 200;  usetick: 0);
        ActDeath:  (start: 260;    frame: 10; skip: 0;  ftime: 200;  usetick: 0); //
      );
   // 2003/02/11
   MA34: TMonsterAction = (  //�ذ�ݿ�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 200;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //������
        ActCritical:(start: 320;   frame: 6;  skip: 4;  ftime: 120;  usetick: 0); //
        ActStruck: (start: 400;    frame: 2;  skip: 0;  ftime: 100;  usetick: 0);
        ActDie:    (start: 420;    frame: 20; skip: 0;  ftime: 200;  usetick: 0);
        ActDeath:  (start: 420;    frame: 20; skip: 0;  ftime: 200;  usetick: 0); //
      );
   MA50: TMonsterAction = (  //�Ϲ� NPC
        ActStand:  (start: 0;    frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActAttack: (start: 30;   frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 0;    frame: 1;  skip: 9;  ftime: 0;  usetick: 0);
        ActDie:    (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActDeath:  (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
      );
   MA51: TMonsterAction = (
        ActStand:  (start: 0;    frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActAttack: (start: 30;   frame: 20; skip: 0;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 0;    frame: 1;  skip: 9;  ftime: 0;  usetick: 0);
        ActDie:    (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActDeath:  (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
      );
   MA52: TMonsterAction = (  //
        ActStand:  (start: 30;    frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActAttack: (start: 30;   frame: 4; skip: 6;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 0;    frame: 1;  skip: 9;  ftime: 0;  usetick: 0);
        ActDie:    (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActDeath:  (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
      );
   // 2003/07/15 �߰��� ���ź�õ ��
   MA53: TMonsterAction = (  //���� ��õ ���, ������ �ӵ� ������.
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActAttack: (start: 80;     frame: 6;  skip: 4;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActDie:    (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActDeath:  (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
      );
   MA54: TMonsterAction = (  //���輮
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 300;  usetick: 0);
        ActWalk:   (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActAttack: (start: 10;     frame: 6;  skip: 4;  ftime: 150;  usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start: 20;     frame: 2;  skip: 0;  ftime: 150;  usetick: 0);
        ActDie:    (start: 30;     frame: 10; skip: 0;  ftime: 80;   usetick: 0);
        ActDeath:  (start: 0;      frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
      );
   MA55: TMonsterAction = (  //�����п�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 250;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 210;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 110;  usetick: 0); //������
        ActCritical:(start: 580;   frame: 20; skip: 0;  ftime: 135;  usetick: 0); //
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 120;  usetick: 0);
        ActDie:    (start: 260;    frame: 20; skip: 0;  ftime: 130;  usetick: 0);
        ActDeath:  (start: 260;    frame: 20; skip: 0;  ftime: 130;  usetick: 0); //
      );
   MA56: TMonsterAction = ( //����
        ActStand:  (start: 0;    frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;    frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
        ActAttack: (start: 0;    frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
        ActCritical:(start: 0;   frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
        ActStruck: (start: 0;    frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
        ActDie:    (start: 0;    frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
        ActDeath:  (start: 0;    frame: 2;  skip: 8;  ftime: 200;  usetick: 0);
      );
   MA57: TMonsterAction = (  // �������, �ɴ�
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 10;     frame: 8;  skip: 2;  ftime: 160;  usetick: 0); //����...
        ActAttack: (start:  0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActCritical:(start: 0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActStruck: (start:  0;     frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
//        ActDie:    (start: 30;     frame: 20; skip: 0;  ftime: 120;  usetick: 0); //�ɴ�
//        ActDeath:  (start: 30;     frame: 20; skip: 0;  ftime: 150;  usetick: 0);
        ActDie:    (start: 30;     frame: 10; skip: 0;  ftime: 120;  usetick: 0); //�������
        ActDeath:  (start: 30;     frame: 10; skip: 0; ftime: 150;  usetick: 0); //����..
      );
   MA58: TMonsterAction = (  // ����(õ��)
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 160;  usetick: 0);
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 160;  usetick: 0);
        ActCritical:(start:160;    frame: 6;  skip: 4;  ftime: 160;  usetick: 0); // SM_LIGHTING(�������=>����) �� ����
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 150;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start: 340;    frame: 10; skip: 0;  ftime: 100;  usetick: 0);
      );
   MA59: TMonsterAction = (  // FireDragon (ȭ��)
        ActStand:  (start: 0;     frame: 10; skip: 0;  ftime: 300;  usetick: 0);
        ActWalk:   (start: 10;    frame: 6;  skip: 4;  ftime: 150;  usetick: 0);
        ActAttack: (start: 20;    frame: 6;  skip: 4;  ftime: 150;  usetick: 0);
        ActCritical:(start:40;    frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActStruck: (start: 40;    frame: 2;  skip: 8;  ftime: 150;  usetick: 0);
        ActDie:    (start: 30;    frame: 6;  skip:  4; ftime: 150;  usetick: 0);
        ActDeath:  (start: 0;     frame: 0;  skip:  0; ftime: 0;    usetick: 0);
      );
   MA60: TMonsterAction = (  // �����Ż� (�뼮��)
        ActStand:  (start: 0;     frame: 10; skip: 0;  ftime: 300;  usetick: 0);
        ActWalk:   (start: 0;     frame: 10; skip: 0;  ftime: 300;  usetick: 0);
        ActAttack: (start: 10;    frame: 10; skip: 0;  ftime: 300;  usetick: 0);
        ActCritical:(start: 10;   frame: 10; skip: 0;  ftime: 100;  usetick: 0);
        ActStruck: (start: 0;     frame: 1;  skip: 9;  ftime: 300;  usetick: 0);
        ActDie:    (start: 0;     frame: 1;  skip: 9;  ftime: 300;  usetick: 0);
        ActDeath:  (start: 0;     frame: 1;  skip: 9;  ftime: 300;    usetick: 0);
      );
   MA61: TMonsterAction = ( // ���������� �Ҳ�NPC
        ActStand:  (start: 0;    frame: 20; skip: 0;  ftime: 100;  usetick: 0);
        ActWalk:   (start: 0;    frame: 0;  skip: 0;  ftime: 0;    usetick: 0);
        ActAttack: (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActCritical: (start: 0;   frame: 0; skip: 0;  ftime: 0;  usetick: 0);
        ActStruck: (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActDie:    (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
        ActDeath:  (start: 0;    frame: 0;  skip: 0;  ftime: 0;  usetick: 0);
      );
   MA62: TMonsterAction = (  //���δ���,�ָ��ݷ���,ȯ����ȣ, �Ź�(�ż�������)
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 250;  usetick: 0);
        ActWalk:   (start: 80;     frame: 6;  skip: 4;  ftime: 100;  usetick: 3); //
        ActAttack: (start: 160;    frame: 6;  skip: 4;  ftime: 110;  usetick: 0);
        ActCritical:(start: 340;   frame: 6;  skip: 4;  ftime: 150;  usetick: 0);
        ActStruck: (start: 240;    frame: 2;  skip: 0;  ftime: 120;  usetick: 0);
        ActDie:    (start: 260;    frame: 10; skip: 0;  ftime: 90;   usetick: 0);
        ActDeath:  (start: 420;    frame: 1;  skip: 0;  ftime: 140;  usetick: 0); //
      );
   MA63: TMonsterAction = (  //������
        ActStand:  (start: 0;      frame: 2;  skip: 8;  ftime: 1000;  usetick: 0);
        ActWalk:   (start: 0;      frame: 2;  skip: 8;  ftime: 1000;  usetick: 0);
        ActAttack: (start: 0;      frame: 2;  skip: 8;  ftime: 1000;  usetick: 0);
        ActCritical:(start: 0;     frame: 2;  skip: 8;  ftime: 1000;  usetick: 0);
        ActStruck: (start: 10;     frame: 6;  skip: 4;  ftime: 150;   usetick: 0);
        ActDie:    (start: 20;     frame: 2;  skip: 8;  ftime: 1000;  usetick: 0);
        ActDeath:  (start: 20;     frame: 2;  skip: 8;  ftime: 1000;  usetick: 0);
      );
   MA64: TMonsterAction = (  //ȣȥ��(�ʵ�)
        ActStand:  (start: 0;      frame: 4;  skip: 6;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 10;     frame: 4;  skip: 6;  ftime: 200;  usetick: 0); //����...
        ActAttack: (start: 20;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0);
        ActCritical:(start:20;     frame: 6;  skip: 4;  ftime: 120;  usetick: 0);
        ActStruck: (start: 30;     frame: 2;  skip: 8;  ftime: 100;  usetick: 0);
        ActDie:    (start: 40;     frame: 10; skip: 0;  ftime: 120;  usetick: 0);
        ActDeath:  (start: 40;     frame: 10; skip: 0;  ftime: 120;  usetick: 0); //����..
      );
   MA65: TMonsterAction = (  //ȣ�⿬
        ActStand:  (start: 0;      frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActWalk:   (start: 10;     frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActAttack: (start: 20;     frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActCritical:(start:20;     frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActStruck: (start: 30;     frame: 4;  skip: 6;  ftime: 100;  usetick: 0);
        ActDie:    (start: 40;     frame: 10; skip: 0;  ftime: 150;  usetick: 0);
        ActDeath:  (start: 40;     frame: 10; skip: 0;  ftime: 150;  usetick: 0);
      );
   MA66: TMonsterAction = (  //���õ��
        ActStand:  (start: 0;     frame: 20;  skip: 0;  ftime: 150;  usetick: 0);
        ActWalk:   (start: 0;     frame: 20;  skip: 0;  ftime: 150;  usetick: 3);
        ActAttack: (start: 20;    frame: 10;  skip: 0;  ftime: 150;  usetick: 0);
        ActCritical:(start:20;    frame: 10;  skip: 0;  ftime: 150;  usetick: 0);
        ActStruck: (start: 30;    frame: 2;   skip: 8;  ftime: 100;  usetick: 0);
        ActDie:    (start: 400;   frame: 18;  skip: 0;  ftime: 150;  usetick: 0);
        ActDeath:  (start: 400;   frame: 18;  skip: 0;  ftime: 150;  usetick: 0);
      );
   MA67: TMonsterAction = (  //ȣȥ�⼮
        ActStand:  (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActWalk:   (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 3);
        ActAttack: (start: 10;    frame: 4;   skip: 6;  ftime: 300;  usetick: 0);
        ActCritical:(start:10;    frame: 4;   skip: 6;  ftime: 300;  usetick: 0);
        ActStruck: (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActDie:    (start: 0;     frame: 4;   skip: 6;  ftime: 300;  usetick: 0);
        ActDeath:  (start: 0;     frame: 4;   skip: 6;  ftime: 300;  usetick: 0);
      );
   MA68: TMonsterAction = (  //NPC 3���� ���ֱ� ��Ǹ�
        ActStand:  (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActWalk:   (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 3);
        ActAttack: (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActCritical:(start:0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActStruck: (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActDie:    (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActDeath:  (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
      );
   MA69: TMonsterAction = (  //��
        ActStand:  (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActWalk:   (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActAttack: (start: 0;     frame: 4;   skip: 6;  ftime: 150;  usetick: 0);
        ActCritical:(start:0;     frame: 10;  skip: 0;  ftime: 150;  usetick: 0);
        ActStruck: (start: 10;    frame: 2;   skip: 8;  ftime: 150;  usetick: 0);
        ActDie:    (start: 20;    frame: 6;   skip: 4;  ftime: 150;  usetick: 0);
        ActDeath:  (start: 20;    frame: 6;   skip: 4;  ftime: 150;  usetick: 0);
      );
   MA70: TMonsterAction = ( //1��ͼNPC
        ActStand:  (start: 0;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        ActWalk:   (start: 0;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        ActAttack: (start: 0;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        ActCritical:(start: 0;   frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        ActStruck: (start: 0;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        ActDie:    (start: 0;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
        ActDeath:  (start: 0;    frame: 1;  skip: 0;  ftime: 200;  usetick: 0);
      );


   WORDER: Array[0..1, 0..599] of byte = (  //1: Ů,  0: ��
      (       //��
      //վ
      0,0,0,0,0,0,0,0,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,0,0,0,0,0,    0,0,0,0,1,1,1,1,
      0,0,0,0,1,1,1,1,    0,0,0,0,1,1,1,1,
      //��
      0,0,0,0,0,0,0,0,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,0,0,0,0,0,    0,0,0,0,0,0,0,1,
      0,0,0,0,0,0,0,1,    0,0,0,0,0,0,0,1,
      //��
      0,0,0,0,0,0,0,0,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,1,1,1,1,1,1,    0,0,1,1,1,0,0,1,
      0,0,0,0,0,0,0,1,    0,0,0,0,0,0,0,1,
      //war���
      0,1,1,1,0,0,0,0,
      //��
      1,1,1,0,0,0,1,1,    1,1,1,0,0,0,0,0,    1,1,1,0,0,0,0,0,
      1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,    1,1,1,0,0,0,0,0,
      0,0,0,0,0,0,0,0,    1,1,1,1,0,0,1,1,
      //�� 2
      0,1,1,0,0,0,1,1,    0,1,1,0,0,0,1,1,    1,1,1,0,0,0,0,0,
      1,1,1,0,0,1,1,1,    1,1,1,1,1,1,1,1,    0,1,1,1,1,1,1,1,
      0,0,0,1,1,1,0,0,    0,1,1,1,1,0,1,1,
      //�� 3
      1,1,0,1,0,0,0,0,    1,1,0,0,0,0,0,0,    1,1,1,1,1,0,0,0,
      1,1,0,0,1,0,0,0,    1,1,1,0,0,0,0,1,    0,1,1,0,0,0,0,0,
      0,0,0,0,1,1,1,0,    1,1,1,1,1,0,0,0,
      //����
      0,0,0,0,0,0,1,1,    0,0,0,0,0,0,1,1,    0,0,0,0,0,0,1,1,
      1,0,0,0,0,1,1,1,    1,1,1,1,1,1,1,1,    0,1,1,1,1,1,1,1,
      0,0,1,1,0,0,1,1,    0,0,0,1,0,0,1,1,
      //�ر�
      0,0,1,0,1,1,1,1,    1,1,0,0,0,1,0,0,
      //�±�
      0,0,0,1,1,1,1,1,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1,
      0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1,
      //������
      0,0,1,1,1,1,1,1,    0,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1,
      0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1
      ),

      (
      //����
      0,0,0,0,0,0,0,0,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,0,0,0,0,0,    0,0,0,0,1,1,1,1,
      0,0,0,0,1,1,1,1,    0,0,0,0,1,1,1,1,
      //�ȱ�
      0,0,0,0,0,0,0,0,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,0,0,0,0,0,    0,0,0,0,0,0,0,1,
      0,0,0,0,0,0,0,1,    0,0,0,0,0,0,0,1,
      //�ٱ�
      0,0,0,0,0,0,0,0,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,1,1,1,1,1,1,    0,0,1,1,1,0,0,1,
      0,0,0,0,0,0,0,1,    0,0,0,0,0,0,0,1,
      //war���
      1,1,1,1,0,0,0,0,
      //����
      1,1,1,0,0,0,1,1,    1,1,1,0,0,0,0,0,    1,1,1,0,0,0,0,0,
      1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,    1,1,1,0,0,0,0,0,
      0,0,0,0,0,0,0,0,    1,1,1,1,0,0,1,1,
      //���� 2
      0,1,1,0,0,0,1,1,    0,1,1,0,0,0,1,1,    1,1,1,0,0,0,0,0,
      1,1,1,0,0,1,1,1,    1,1,1,1,1,1,1,1,    0,1,1,1,1,1,1,1,
      0,0,0,1,1,1,0,0,    0,1,1,1,1,0,1,1,
      //����3
      1,1,0,1,0,0,0,0,    1,1,0,0,0,0,0,0,    1,1,1,1,1,0,0,0,
      1,1,0,0,1,0,0,0,    1,1,1,0,0,0,0,1,    0,1,1,0,0,0,0,0,
      0,0,0,0,1,1,1,0,    1,1,1,1,1,0,0,0,
      //����
      0,0,0,0,0,0,1,1,    0,0,0,0,0,0,1,1,    0,0,0,0,0,0,1,1,
      1,0,0,0,0,1,1,1,    1,1,1,1,1,1,1,1,    0,1,1,1,1,1,1,1,
      0,0,1,1,0,0,1,1,    0,0,0,1,0,0,1,1,
      //�ر�
      0,0,1,0,1,1,1,1,    1,1,0,0,0,1,0,0,
      //�±�
      0,0,0,1,1,1,1,1,    1,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1,
      0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1,
      //������
      0,0,1,1,1,1,1,1,    0,1,1,1,1,1,1,1,    1,1,1,1,1,1,1,1,
      1,1,1,1,1,1,1,1,    0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1,
      0,0,0,1,1,1,1,1,    0,0,0,1,1,1,1,1
      )
   );

   EffDir : array[0..7] of byte = (0, 0, 1, 1, 1, 1, 1, 0);


type
   TActor = class
      RecogId: integer;
      XX:   word;
      YY:   word;
      Dir:  byte;
      Sex:  byte;
      Race:    byte;
      Hair:    byte;
      Dress:   byte;
      Weapon:  byte;
      Job:  byte; //ְҵ 0:��ʿ  1:��ʦ  2:��ʿ
      AttackMode: byte; //����ģʽ
      Appearance: word;
//      DeathState: byte;
      Feature: integer;
      State:   integer;
      Death: Boolean;
      Skeleton: Boolean;
      BoDelActor: Boolean;
      BoDelActionAfterFinished: Boolean;
      DescUserName: string;  //�������ƣ���׺
      FameName: string; 
      UserName: string; //����
      NameColor: integer; //������ɫ
      Abil: TAbility;
      Gold: integer;
      PlayCash: integer;
      HitSpeed: shortint; //�����ٶ� 0: �⺻, (-)���� (+)����
      Visible: Boolean;
      BoHoldPlace: Boolean;

      Saying: array[0..MAXSAY-1] of string;  //���˵�Ļ�
      SayWidths: array[0..MAXSAY-1] of integer;  //ÿ�仰�Ŀ��
      SayTime: longword;
      SayX, SayY: integer;
      SayLineCount: integer;

      ShiftX:  integer;
      ShiftY:  integer;

      px:   integer;
      py:   integer;
      Rx, Ry: integer;
      DownDrawLevel: integer;  //�� �� ������ �׸��� ��...
      TargetX, TargetY: integer; //������ ���, ������ ������ �ϴ� ��� Ÿ���� ��ġ
      TargetRecog: integer; //
      HiterCode: integer;
      MagicNum: integer;
      CurrentEvent: integer; //������ �̺�Ʈ ���̵�
      BoDigFragment: Boolean;  //�̹� ��� ���� ĳ������..
      BoThrow: Boolean;

      BodyOffset, HairOffset, WingOffset, WeaponOffset, WeaponEffectOffset: integer;
      BoUseMagic: Boolean;
      BoHitEffect: Boolean;
      BoUseEffect: Boolean;  //ȿ���� ����ϴ���..
      HitEffectNumber: integer;
      WaitMagicRequest: longword;
      WaitForRecogId: integer;  //�ڽ��� ������� WaitFor�� actor�� visible ��Ų��.
      WaitForFeature: integer;
      WaitForStatus: integer;
      //BoEatEffect: Boolean;  //�� �Դ� ȿ��
      //EatEffectFrame: integer;
      //EatEffectTime: longword;

      CurEffFrame: integer;
      SpellFrame: integer; //������ ���� ������
      CurMagic: TUseMagicInfo;
      //GlimmingMode: Boolean;
      //CurGlimmer: integer;
      //MaxGlimmer: integer;
      //GlimmerTime: longword;
      GenAniCount: integer;
      BoOpenHealth: Boolean;
      Bo_OpenHealth:boolean;                 //������ʾ
      BoInstanceOpenHealth: Boolean;
      OpenHealthStart: longword;
      OpenHealthTime: integer;

      //SRc: TRect;  //Screen Rect ȭ���� ������ǥ(���콺 ����)
      BodySurface: TDXTexture;

      Grouped: Boolean; //���� �׷��� ���
      CurrentAction: integer;
      ReverseFrame: Boolean;
      WarMode: Boolean;
      WarModeTime: longword;
      ChrLight: integer;
      MagLight: integer;
      RushDir: integer;  //0, 1 �ѹ��� ���� �ѹ��� ������

      WalkFrameDelay: integer;  //�⺻ ���� Ŭ���̾�Ʈ�� ftime �̸�
                                //�������� ������ �������� ���� ������ �Ѵ�.

      LockEndFrame: Boolean;
      LastStruckTime: longword;
      SendQueryUserNameTime: longword;
      DeleteTime: longword;

      //���� ȿ��
      MagicStruckSound: integer;
      borunsound: Boolean;
      footstepsound: integer;  //���ΰ��ΰ��, CM_WALK, CM_RUN
      strucksound: integer;  //������ ���� �Ҹ�    SM_STRUCK
      struckweaponsound: integer;

      appearsound: integer;  //����Ҹ� 0
      normalsound: integer;  //�ϹݼҸ� 1
      attacksound: integer;  //         2
      weaponsound: integer; //          3
      screamsound: integer;  //         4
      diesound: integer;     //������   5  ���� �Ҹ�    SM_DEATHNOW
      die2sound: integer;

      magicstartsound: integer;
      magicfiresound: integer;
      magicexplosionsound: integer;

      Bo50LevelEffect: Boolean;
      FoodStickType: integer;
//      BoWriterEffect: Boolean;
      TempState:   byte; //���õ�� ���� ����

   private
   protected
      startframe: integer;
      endframe: integer;
      currentframe: integer;
      effectstart: integer;
      effectframe: integer;
      effectend: integer;
      effectstarttime: longword;
      effectframetime: longword;
      frametime: longword;   //�� �����Ӵ� �ð�
      starttime: longword;   //�ֱ��� �������� ���� �ð�
      maxtick: integer;
      curtick: integer;
      movestep: integer;
      msgmuch: Boolean;
      struckframetime: longword;
      currentdefframe: integer;
      defframetime: longword;
      defframecount: integer;
      defframetick: longword;
      SkipTick, SkipTick2: integer;
      smoothmovetime: longword;
      genanicounttime: longword;
      loadsurfacetime: longword;

      oldx, oldy, olddir: integer;
      actbeforex, actbeforey: integer;  //�ൿ ���� ��ǥ
      wpord: integer;

      procedure CalcActorFrame; dynamic;
      procedure DefaultMotion; dynamic;
      function  GetDefaultFrame (wmode: Boolean): integer; dynamic;
      procedure DrawEffSurface (dsurface, source: TDXTexture; ddx, ddy: integer; blend: Boolean; ceff: TColorEffect; blendmode: integer = 0);
      procedure DrawWeaponGlimmer (dsurface: TDXTexture; ddx, ddy: integer);
   public
      MsgList: TList;       //list of PTChrMsg
      RealActionMsg: TChrMsg; //FrmMain���� �����

      constructor Create; dynamic;
      destructor Destroy; override;
      procedure  SendMsg (ident: word; x, y, cdir, feature, state: integer; str: string; sound: integer);
      procedure  UpdateMsg (ident: word; x, y, cdir, feature, state: integer; str: string; sound: integer);
      procedure  CleanUserMsgs;
      procedure  ProcMsg;
      procedure  ProcHurryMsg;
      function   IsIdle: Boolean;
      function   ActionFinished: Boolean;
      function   CanWalk: Integer;
      function   CanRun: Integer;
      function   Strucked: Boolean;
      procedure  Shift (dir, step, cur, max: integer);
      procedure  ReadyAction (msg: TChrMsg);
      function   CharWidth: Integer;
      function   CharHeight: Integer;
      function   CheckSelect (dx, dy: integer): Boolean;
      procedure  CleanCharMapSetting (x, y: integer);
      procedure  Say (str: string);
      procedure  SetSound; dynamic;
      procedure  Run; dynamic;
      procedure  RunSound; dynamic;
      procedure  RunActSound (frame: integer); dynamic;
      procedure  RunFrameAction (frame: integer); dynamic;  //�����Ӹ��� ��Ư�ϰ� �ؾ�����
      procedure  ActionEnded; dynamic;
      function  Move (step: integer; out boChange: Boolean): Boolean;
      procedure  MoveFail;
      function   CanCancelAction: Boolean;
      procedure  CancelAction;
      procedure  FeatureChanged; dynamic;
      function   Light: integer; dynamic;
      procedure  LoadSurface; dynamic;
      function   GetDrawEffectValue: TColorEffect;
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); dynamic;
      procedure  DrawEff (dsurface: TDXTexture; dx, dy: integer); dynamic;
   end;


   TNpcActor = class (TActor)
   private
      // 2003/07/15 �ű� NPC �߰�
      ax, ay: integer;
      PlaySnow: Boolean;
      SnowStartTime: longword;
      EffectSurface: TDXTexture;
   public
      constructor Create; override;
      procedure  Run; override;
      procedure  CalcActorFrame; override;
      function   GetDefaultFrame (wmode: Boolean): integer; override;
      procedure  LoadSurface; override;
      // 2003/07/15 �ű� NPC �߰�
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
      procedure  DrawEff (dsurface: TDXTexture; dx, dy: integer); override;
   end;

   THumActor = class (TActor)
   private
      HairSurface: TDXTexture;
      WeaponSurface: TDXTexture;
      WingSurface: TDXTexture;
      BoWeaponEffect: Boolean;  //���� ���ü���,���� ȿ��
      CurWpEffect: integer;
      CurBubbleStruck: integer;
      wpeffecttime: longword;
      BoHideWeapon: Boolean;

      hpx, epx, epx2, epx3, epx4, wpx, wpx2:   integer;
      hpy, epy, epy2, epy3, epy4, wpy, wpy2:   integer;

      WingCurrentFrame   : integer;
      WingStartTime   : longword;
      WingFrameTime   : longword;              // ������ ����
      // 50Level Effect
      H50LevelEffectSurface: TDXTexture;
      H50LevelEffectOffset: integer;
      H50LevelEffectCurrentFrame   : integer;
      H50LevelEffectStartTime   : longword;
      H50LevelEffectFrameTime   : longword;
      Bo50LevelHEffect: Boolean;

      // ������ Event
      FoodStickDayEffectSurface: TDXTexture;
      FoodStickDayEffectSurface2: TDXTexture;
      FoodStickDayEffectOffset: integer;
      FoodStickDayEffectOffset2: integer;
      FoodStickDayEffectCurrentFrame   : integer;
      FoodStickDayEffectStartTime   : longword;
      FoodStickDayEffectFrameTime   : longword;
      BoFoodStickDayEffect: Boolean;

      // Writer Effect
{      HWriterEffectSurface: TDXTexture;
      HWriterEffectOffset: integer;
      HWriterEffectCurrentFrame   : integer;
      HWriterEffectStartTime   : longword;
      HWriterEffectFrameTime   : longword;
      BoWriterHEffect: Boolean;}
      // ���ļ�
      SKillCurrentFrame   : integer;
      SKillStartTime   : longword;
      SKillFrameTime   : longword;
      // 50LevelDress Effect
      Bo50DressHEffect: Boolean;

      WeaponEffectSurface: TDXTexture; //�İ�����
      WeaponEffectCurrentFrame   : integer;
      WeaponEffectStartTime   : longword;
      WeaponEffectFrameTime   : longword;

   protected
      procedure CalcActorFrame; override;
      procedure DefaultMotion; override;
      function  GetDefaultFrame (wmode: Boolean): integer; override;
   public
      constructor Create; override;
      destructor Destroy; override;
      procedure  Run; override;
      procedure  RunFrameAction (frame: integer); override;
      function   Light: integer; override;
      procedure  LoadSurface; override;
      procedure  DoWeaponBreakEffect;
      procedure  DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean ); override;
   end;

   function RaceByPM (race, appr: integer): PTMonsterAction;
   function GetMonImg (appr: integer): TWMImages;
   function GetOffset (appr: integer): integer;



implementation

uses
   ClMain, SoundUtil, clEvent, MShare;


function RaceByPM (race, appr: integer): PTMonsterAction;
begin
   Result := nil;
   case race of   // ������ Race�� RaceImg �� ������ ... COPARK
      9:       Result := @MA9;
      10:      Result := @MA10;
      11:      Result := @MA11;
      12, 24:  Result := @MA12;
      13:      Result := @MA13;
      14, 17, 18, 23:  Result := @MA14;
      15, 22, 111,112:  Result := @MA15; //�����ũ
      16:      Result := @MA16;
      30, 31:  Result := @MA17;
      19, 20, 21,
      37,                        //�񵶰Ź�
      101, //���(û����)
      40, 45, 52, 53, 95, 113,114,116:  //ġ��, �����ͼ�
               Result := @MA19;
      41, 42:  Result := @MA20;
      43:      Result := @MA21;
      47:      Result := @MA22;
      48, 49:  Result := @MA23;
      32:      Result := @MA24;  //����, ������ 2���� ���
      33:      Result := @MA25;  //���׿�, �˷��
      34,90:      Result := @MA30;  //�����ο�, ����, 90=>ȭ���
      35:      Result := @MA31;  //���ȰŹ�
      36:      Result := @MA32;  //����
      54:      Result := @MA28;
      55:      Result := @MA29;  //�ż�(������)
      60,61,62:Result := @MA33;  //������, �յ�, �ֺ���(���߿�)
      // 2003/02/11
      63:      Result := @MA34;
      64, 65, 66, 67, 68, 69, 102:    //���α�, �νı�, �ذ���, �ذ���, �ذ񹫻�, �ذ�ü� �߰�
               Result := @MA19;
      // 2003/03/04
      70,71,72,103,104,105,117,118:
               Result := @MA33;  //�ݾ߿��, �ݾ��»�, ���õ��, ��ö�ͼ�
      // 2003/07/15
      73:      Result := @MA19;  // ��������
      74:      Result := @MA19;  // �蹶ġ��޿���, �����̻�޿���, Į�ϱ޿���, �����ϱ޿���
      75:      Result := @MA54;  // ���輮1
      76:      Result := @MA53;  // ���ź�õ ���
      77:      Result := @MA54;  // ���輮2
      78:      Result := @MA55;  // ���ź�õ����
      79:      Result := @MA19;  // Ȱ�ϱ޿���
      80, 96:
               Result := @MA57;  // ���������

      81:      Result := @MA58;  // ����
      83:      Result := @MA59;  // ȭ�� FireDragon
      84,85,86,87,88,89:   Result := @MA60; // �����Ż�

      91,92,93,94:   Result := @MA62;  // 2004/03/23 ���δ���, �ָ��ݷ���, ȯ����ȣ, �Ź�(�ż�������) �߰�
      97:      Result := @MA63;  // ������

      98:      Result := @MA27;
      99:      Result := @MA26;

      100:      Result := @MA62; // Ȳ���̹���
      106:      Result := @MA64; // ȣȥ��
      107:      Result := @MA67; // ȣȥ�⼮
      108,109:  Result := @MA65; // ȣ�⿬
      110:      Result := @MA66; // ���õ��
      115:      Result := @MA11; // ȣ��
      119:      Result := @MA69; // ��

      50:  //npc
         case appr of
            23:
               begin
                  Result := @MA51;
               end;
            // 2003/07/15 ���ź�õ NPC
            27, 32,
            24, 25:
               begin
                  Result := @MA52;
               end;
            35..43, 48,49,50,52{,53,54,55,57,58,60,74,78..80}: // npc�߰�
               begin
                  Result := @MA56;//����
               end;
            44,45,46,47:// NewNpc
               begin
                  Result := @MA61;
               end;
//            56,59,68..73,75..77:
//               begin
//                  Result := @MA68; //���ֱ� ��Ǹ� �ִ°͵�
//               end;
            53..56://����ͼ��NPC
               begin
                  Result := @MA70;
               end;
            57..64, 65, 117://4��ͼ��NPC
               begin
                  Result := @MA67;
               end;

            else
               Result := @MA50; //�Ϲ� NPC
         end;
   end;
end;

function GetMonImg (appr: integer): TWMImages;
begin
   Result := WMonImg; //Default
   case (appr div 10) of
      0: Result := WMonImg;   //
      1: Result := WMon2Img;  //������
      2: Result := WMon3Img;
      3: Result := WMon4Img;
      4: Result := WMon5Img;
      5: Result := WMon6Img;
      6: Result := WMon7Img;
      7: Result := WMon8Img;
      8: Result := WMon9Img;
      9: Result := WMon10Img;
      10: Result := WMon11Img;
      11: Result := WMon12Img;
      12: Result := WMon13Img;
      13: Result := WMon14Img;
      14: Result := WMon15Img;
      15: Result := WMon16Img;
      16: Result := WMon17Img;
      17: Result := WMon18Img;
      18: Result := WMon19Img;
      // 2003/02/11 �ű� �� ����
      19: Result := WMon20Img;
      // 2003/03/04 �ű� �� ����
      20: Result := WMon21Img;
      // 2003/07/15 ���� ��õ �߰���
      21: Result := WMon22Img;
      22: Result := WMon23Img;
      23: Result := WMon24Img;
      24: Result := WMon25Img;

      80: Result := WDragonImg; // FireDragon

      90: Result := WEffectImg;  //����, ����
   end;
end;

function GetOffset (appr: integer): integer;
var
   nrace, npos: integer;
begin
   Result := 0;
   nrace := appr div 10;
   npos := appr mod 10;
   case nrace of
      0:    Result := npos * 280;  //8������
      1:    begin
      case npos of
               0,1: Result := npos * 230;
               2: Result := 280;
               3: Result := 350;//ȣ��
               4: Result := 700;//��
               5: Result := 740;//ȣ���߰�
               6: Result := 1100;//ȣ���߰�
            end;
            end;
      2, 3, 7..12, 14..16 :    Result := npos * 360;  //10������ �⺻

      13:   case npos of
               1: Result := 360;   //������ (����)
               2: Result := 440;   //���ȰŹ� (�����Ź�)
               3: Result := 550;   //����(�����Ź�)
               4: Result := 750;   //�̺�Ʈ ������AI �˷��
//               else Result := npos * 360;
            end;

      4:    begin
               Result := npos * 360;        //
               if npos = 1 then Result := 600;  //�񸷿���
            end;
      5:    Result := npos * 430;   //����
      6:    Result := npos * 440;   //�ָ�����,ȣ��,��
      17:   if npos = 2 then Result := 920 // ����
            else Result := npos * 350;   //�ż�
      18:   case npos of
               0: Result := 0;     //������
               1: Result := 520;   //�յ�
               2: Result := 950;   //�ָ�����(���߿�)
            end;
      // 2003/02/11 �ű� �� ����
      19:   case npos of
               0: Result := 0;     //���α�
               1: Result := 370;   //�νı�
               2: Result := 810;   //�ذ���
               3: Result := 1250;   //�ذ���
               4: Result := 1630;   //�ذ񹫻�
               5: Result := 2010;   //�ذ�ü�
               6: Result := 2390;   //�ذ�ݿ�
            end;
      // 2003/03/04 �ű� �� ����
      20:   case npos of
               0: Result := 0;     //�ݾ߱���
               1: Result := 360;   //�ݾߺ���
               2: Result := 720;   //�ݾ߿��
               3: Result := 1080;   //�ݾ�ǳ��
               4: Result := 1440;   //�ݾ�ȭ��
               5: Result := 1800;   //�ݾ߿��
               6: Result := 2350;   //�ݾ��»�
               7: Result := 3060;   //���õ��
            end;
      // 2003/07/15 �ű� �� ����
      21:   case npos of
               0: Result := 0;     //��������
               1: Result := 460;   //�蹶ġ��޿���
               2: Result := 820;   //�����̻�޿���
               3: Result := 1180;  //Į�ϱ޿���
               4: Result := 1540;  //�����ϱ޿���
               5: Result := 1900;  //Ȱ�ϱ޿���
               6: Result := 2260;  //â���
               7: Result := 2440;  //���輮1
               8: Result := 2570;  //���輮2
               9: Result := 2700;  //���ź�õ����
            end;
      // 2004/03/23 �űԸ��� �߰�
      22:   case npos of
               0: Result := 0;     //���δ���
               1: Result := 430;   //�ָ��ݷ���
               2: Result := 1290;  //ȯ����ȣ
               3: Result := 1810;  //�Ź�(�ż�������)
               4: Result := 2320;  //Ȳ���̹���
               5: Result := 2920;  //���(û����)
               6: Result := 3270;  //����Ȳ��
               7: Result := 3620;  //��������
               8: Result := 3970;  //������ ȯ����ȣ
            end;
      23:   case npos of //2005/07/20 �������
               0: Result := 0;     //����������
               1: Result := 440;   //����������
               2: Result := 820;   //����������
               3: Result := 1360;  //ȣȥ��
               4: Result := 1420;  //ȣȥ�⼮
               5: Result := 1450;  //ȣ�⿬(��)
               6: Result := 1560;  //ȣ�⿬(��)
               7: Result := 1670;  //���õ��
               8: Result := 2270;  //�����ũ(��)
               9: Result := 2700;  //�����ũ(��)
            end;
      24:   case npos of
               0: Result := 0;     //ġ��(��)
               1: Result := 350;   //ġ��(��)
               2: Result := 700;   //�����ͼ�
               3: Result := 1050;  //��ö�ͼ�
               4: Result := 1650;  //��������
            end;

      80:   case npos of // FireDragon
               0: Result := 0;     //ȭ��
               1: Result := 80;    //ȭ���
               2: Result := 300;   //�뼮����
               3: Result := 301;   //�뼮�����
               4: Result := 302;   //�뼮�����
               5: Result := 320;   //�뼮�¿��
               6: Result := 321;   //�뼮�¿���
               7: Result := 322;   //�뼮�¿���

            end;

      90:   case npos of
               0: Result := 80;   //����
               1: Result := 168;
               2: Result := 184;
               3: Result := 200;
            end;
   end;
end;

function GetNpcOffset (appr: integer): integer;
begin
   //npc��۴���
   case appr of
      0..22:
         Result := MERCHANTFRAME * appr;
      23:
         Result := 1380;
      // 2003/07/15 ���ź�õ NPC
      27, 32 :
         Result := 1620 + MERCHANTFRAME * (appr - 26) - 30;
      26,30,31,33,34,35..43: // 41:�����
         Result := 1620 + MERCHANTFRAME * (appr - 26);
//      42,43: //ȭ�Ժ�1,2
      28,29: Result := 1710 + MERCHANTFRAME * (appr - 28);
//         Result := 2580;
      44,45,46,47: //ž��1,2,3,4
         Result := 2640;
      48,49,50: //48:��� 49:�Խ��� 50:�μ�������
         Result := 2700 + MERCHANTFRAME * (appr - 48);
      51: // �α�NPC(�ͽ�)    //2004/05/27 50LevelQuest
         Result := 2880;
      52: //�����  //npc�߰�
         Result := 2960;
      //���޸�NPC
      53..56:
         Result := 3040 + 1 * (appr - 53);
      57..64:
         Result := 3060 + MERCHANTFRAME * (appr - 57);
      65:
         Result := 3600;
      66..74:
         Result := 3750 + 10 * (appr - 66);
      75,76:
         Result := 3840 + MERCHANTFRAME * (appr - 75);
      77..79:
         Result := 3960 + 20 * (appr - 77);
      //80NPCδ֪
      81..83:
         Result := 4060 + MERCHANTFRAME * (appr - 81);
      84: //����
         Result := 4240;
      85:
         Result := 4250;
      86..91:
         Result := 4490 + 10 * (appr - 86);
      92: //����¯
         Result := 4560;
      93:
         Result := 4600;
      94..103:
         Result := 4630 + 10 * (appr - 94);
      104:
         Result := 4770;
      105:
         Result := 4810;
      106:
         Result := 4840;
      //NPC2
      107..117:
         Result := 70 * (appr - 107);
      118:
         Result := 740;
      119..124:
         Result := 810 + 10 * (appr - 119);
      125..127:
         Result := 870 + 30 * (appr - 125);
      128..130:
         Result := 970 + 10 * (appr - 128);
      131:
         Result := 1020;
      132:
         Result := 1030;
      133..135:
         Result := 1060 + (appr - 133);
      136,137:
         Result := 1070 + 10 * (appr - 136);
//      54: //�칰
//         Result := 3070;
//      55: //��ü
//         Result := 3130;
//      56: //���
//         Result := 3190;
//      57: //�����ǹ�
//         Result := 3250;
//      58: //���ڼ���
//         Result := 3270;
//      59: //ȣȥ�⼮npc
//         Result := 3290;
//      60: //�ذ��ü-��������Ʈ
//         Result := 3330;
//      61,62,63,64: //������� �Ҳ� 1,2,3,4
//         Result := 3350;
//      65: //��ں�
//         Result := 3430;
//      66: //ũ��������Ʈ�� 2005/12/14
//         Result := 3450;
//      67: //�̾߱��ϴ¼���
//         Result := 3500;
//      68: //����
//         Result := 3570;
//      69: //Ʈ�����¼���
//         Result := 3610;
//      70: //�ɾ��ִ¼���(����)
//         Result := 3630;
//      71: //�ɾ��ִ¼���(���ʵ�)
//         Result := 3650;
//      72: //�ɾ��ִ¼���(�����ʵ�)
//         Result := 3670;
//      73: //�躸�¼���
//         Result := 3690;
//      74: //�źϼ���
//         Result := 3710;
//      75: //����
//         Result := 3730;
//      76: //ȣ���߰�
//         Result := 3770;
//      77: //ȣ���߹�
//         Result := 3810;
//      78: //��������
//         Result := 3850;
//      79: //��
//         Result := 3870;
//      80: //å��
//         Result := 3890;

      else
         Result := 1470 + MERCHANTFRAME * (appr - 24);
   end;
end;

constructor TActor.Create;
begin
   inherited Create;
   MsgList := TList.Create;
   RecogId := 0;
   BodySurface := nil;
   FillChar (Abil, sizeof(TAbility), 0);
   Gold := 0;
   Visible := TRUE;
   BoHoldPlace := TRUE;

   //���� �������� ����, ����� ������ ����
   //������ currentframe�� endframe�� �Ѿ����� ������ �Ϸ�Ȱ����� ��
   CurrentAction := 0;
   ReverseFrame := FALSE;
   ShiftX := 0;
   ShiftY := 0;
   DownDrawLevel := 0;
   currentframe := -1;
   effectframe := -1;
   RealActionMsg.Ident := 0;
   UserName := '';
   NameColor := clWhite;
   SendQueryUserNameTime := 0; //GetTickCount;

   WarMode := FALSE;
   WarModeTime := 0;    //War mode�� ����� ������ �ð�
   Death := FALSE;
   Skeleton := FALSE;
   BoDelActor := FALSE;
   BoDelActionAfterFinished := FALSE;
   
   ChrLight := 0;
   MagLight := 0;
   LockEndFrame := FALSE;
   smoothmovetime := 0; //GetTickCount;
   genanicounttime := 0;
   defframetime := 0;
   loadsurfacetime := GetTickCount;
   Grouped := FALSE;
   BoOpenHealth := FALSE;
   BoInstanceOpenHealth := FALSE;

   CurMagic.ServerMagicCode := 0;
   //CurMagic.MagicSerial := 0;

   SpellFrame := DEFSPELLFRAME;

   normalsound := -1;
   footstepsound := -1; //����  //���ΰ��ΰ��, CM_WALK, CM_RUN
   attacksound := -1;
   weaponsound := -1;
   strucksound := s_struck_body_longstick;  //������ ���� �Ҹ�    SM_STRUCK
   struckweaponsound := -1;
   screamsound := -1;
   diesound := -1;    //����    //������ ���� �Ҹ�    SM_DEATHNOW
   die2sound := -1;

//   BoWriterEffect := False;
   TempState := 1;
   FoodStickType := 0;
end;

destructor TActor.Destroy;
begin
   MsgList.Free;
   inherited Destroy;
end;

procedure TActor.SendMsg (ident: word; x, y, cdir, feature, state: integer; str: string; sound: integer);
var
   pmsg: PTChrMsg;
begin
   new (pmsg);
   pmsg.ident  := ident;
   pmsg.x      := x;
   pmsg.y      := y;
   pmsg.dir    := cdir;
   pmsg.feature:= feature;
   pmsg.state  := state;
   pmsg.saying := str;
   pmsg.Sound := sound;
   MsgList.Add (pmsg);
end;

procedure TActor.UpdateMsg (ident: word; x, y, cdir, feature, state: integer; str: string; sound: integer);
var
   i, n: integer;
   pmsg: PTChrMsg;
begin
   if self = Myself then begin
      n := 0;
      while TRUE do begin
         if n >= MsgList.Count then break;
         if (PTChrMsg (MsgList[n]).Ident >= 3000) and //Ŭ���̾�Ʈ���� ���� �޼�����
            (PTChrMsg (MsgList[n]).Ident <= 3099) or     //�����ص� �ȴ�.
            (PTChrMsg (MsgList[n]).Ident = ident) //������ ����
         then begin
            Dispose (PTChrMsg (MsgList[n]));
            MsgList.Delete (n);
         end else
            Inc (n);
      end;
      SendMsg (ident, x, y, cdir, feature, state, str, sound);
   end else begin
      //if not ((ident = SM_STRUCK) and (MsgList.Count >= 2)) then //�´� ���� ����
      if MsgList.Count > 0 then begin
         for i:=0 to MsgList.Count-1 do begin
            if PTChrMsg (MsgList[i]).Ident = ident then begin
               Dispose (PTChrMsg (MsgList[i]));
               MsgList.Delete (i);
               break;
            end;
         end;
      end;
      SendMsg (ident, x, y, cdir, feature, state, str, sound);
   end;
end;

procedure TActor.CleanUserMsgs;
var
   n: integer;
begin
   n := 0;
   while TRUE do begin
      if n >= MsgList.Count then break;
      if (PTChrMsg (MsgList[n]).Ident >= 3000) and //Ŭ���̾�Ʈ���� ���� �޼�����
         (PTChrMsg (MsgList[n]).Ident <= 3099)     //�����ص� �ȴ�.
         then begin
         Dispose (PTChrMsg (MsgList[n]));
         MsgList.Delete (n);
      end else
         Inc (n);
   end;
end;

procedure TActor.CalcActorFrame;
var
   pm: PTMonsterAction;
   haircount: integer;
begin
   BoUseMagic := FALSE;
   currentframe := -1;

   BodyOffset := GetOffset (Appearance);
   pm := RaceByPM (Race, Appearance);
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
      SM_WALK, SM_RUSH, SM_RUSHKUNG, SM_BACKSTEP:
         begin
            startframe := pm.ActWalk.start + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe + pm.ActWalk.frame - 1;
            frametime := WalkFrameDelay; //pm.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            movestep := 1;
            if CurrentAction = SM_BACKSTEP then
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1)
            else
               Shift (Dir, movestep, 0, endframe-startframe+1);
         end;
      {SM_BACKSTEP:
         begin
            startframe := pm.ActWalk.start + (pm.ActWalk.frame - 1) + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe - (pm.ActWalk.frame - 1);
            frametime := WalkFrameDelay; //pm.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            movestep := 1;
            Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
         end;}
      SM_HIT:
         begin
            startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
            endframe := startframe + pm.ActAttack.frame - 1;
            frametime := pm.ActAttack.ftime;
            starttime := GetTickCount;
            //WarMode := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
         end;
      SM_STRUCK:
         begin
            startframe := pm.ActStruck.start + Dir * (pm.ActStruck.frame + pm.ActStruck.skip);
            endframe := startframe + pm.ActStruck.frame - 1;
            frametime := struckframetime; //pm.ActStruck.ftime;
            starttime := GetTickCount;
            Shift (Dir, 0, 0, 1);
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
      SM_SKELETON:
         begin
            startframe := pm.ActDeath.start + Dir;
            endframe := startframe + pm.ActDeath.frame - 1;
            frametime := pm.ActDeath.ftime;
            starttime := GetTickCount;
         end;
   end;
end;

procedure TActor.ReadyAction (msg: TChrMsg);
var
   i, n: integer;
   pmag: PTUseMagicInfo;
   gCheck : Boolean;
begin
   actbeforex := XX;
   actbeforey := YY;

{   if msg.Ident = SM_ALIVE then begin
      Death := FALSE;
      Skeleton := FALSE;
   end;}

   if not Death then begin
      case msg.Ident of
         SM_TURN, SM_WALK, SM_BACKSTEP, SM_RUSH, SM_RUSHKUNG, SM_RUN, SM_DIGUP, SM_ALIVE:
            begin
               Feature := msg.feature;
               if msg.Ident <> SM_RUSH then State := msg.state;

               //ĳ������ �ΰ����� ���� ǥ��
               if State and STATE_OPENHEATH <> 0 then BoOpenHealth := TRUE
               // 2003/03/04 �׷�� Ž��ǥ��
               else begin
                   n := 0;
                   for i:=1 to ViewListCount do
                       if (ViewList[i].Index = RecogId) then n := i;
                   if n = 0 then
                       BoOpenHealth := FALSE;
               end;
            end;
      end;
//      if (msg.Ident = SM_DRAGON_FIRE1) or (msg.Ident = SM_DRAGON_FIRE2) or (msg.Ident = SM_DRAGON_FIRE3) or
//         (msg.Ident = SM_LIGHTING_1) then
      if msg.Ident in [SM_DRAGON_FIRE1,SM_DRAGON_FIRE2,SM_DRAGON_FIRE3,SM_LIGHTING_1..SM_LIGHTING_3] then
         n := 0;
      if msg.ident = SM_LIGHTING then
         n := 0;
      if Myself = self then begin
         if (msg.Ident = CM_WALK) then
            if not PlayScene.CanWalk (msg.x, msg.y) then
               exit;  //�̵� �Ұ�
         if (msg.Ident = CM_RUN) then
            if not PlayScene.CanRun (Myself.XX, Myself.YY, msg.x, msg.y) then
               exit; //�̵� �Ұ�

         //msg
         case msg.Ident of
            CM_TURN,
            CM_WALK,
            CM_SITDOWN,
            CM_RUN,
            CM_HIT,
            CM_POWERHIT,
            CM_LONGHIT,
            CM_WIDEHIT,
            // 2003/03/15 �űԹ���
            CM_CROSSHIT,
            CM_HEAVYHIT,
            CM_BIGHIT:
               begin
                  RealActionMsg := msg; //���� ����ǰ� �ִ� �ൿ, ������ �޼����� ����.
                  msg.Ident := msg.Ident - 3000;  //SM_?? ���� ��ȯ ��
               end;
            CM_THROW:
               begin
                  if feature <> 0 then begin
                     TargetX := TActor(msg.feature).XX;  //x ������ ��ǥ
                     TargetY := TActor(msg.feature).YY;    //y
                     TargetRecog := TActor(msg.feature).RecogId;
                  end;
                  RealActionMsg := msg;
                  msg.Ident := SM_THROW;
               end;
            CM_FIREHIT:
               begin
                  RealActionMsg := msg;
                  msg.Ident := SM_FIREHIT;
               end;
            // 2003/07/15 �űԹ���
            CM_TWINHIT:
               begin
                  RealActionMsg := msg;
                  msg.Ident := SM_TWINHIT;
               end;
            CM_SPELL:
               begin
                  RealActionMsg := msg;
                  pmag := PTUseMagicInfo (msg.feature);
                  RealActionMsg.Dir := pmag.MagicSerial;
                  msg.Ident := msg.Ident - 3000;  //SM_?? ���� ��ȯ ��
               end;
         end;

         oldx := XX;
         oldy := YY;
         olddir := Dir;
      end;
      case msg.Ident of
         SM_STRUCK:
            begin
               //Abil.HP := msg.x; {HP}
               //Abil.MaxHP := msg.y; {maxHP}
               //msg.dir {damage}
               //������ ������ �´� �ð��� ª��.
               MagicStruckSound := msg.x; //1�̻�, ����ȿ��
               n := Round (200 - Abil.Level * 5);
               if n > 80 then struckframetime := n
               else struckframetime := 80;
               LastStruckTime := GetTickCount;
//               gCheck := False;                        // �������˻������˵����Լ���ӵ��˴�Ķ���ʾѪ
//               if GroupIdList.Count > 0 then
//                  for i := 0 to GroupIdList.Count-1 do begin
//                      if integer(GroupIdList[i]) = HiterCode then begin
//                         gCheck := True;
//                         Break;
//                      end;
//                  end;
//
//               if ((Race <> 0) and (Race <> 34) and (HiterCode = Myself.RecogId) or gCheck) and (Abil.MaxHP < 2000) then begin   //2000HP���Ϲ��ﲻ��ʾѪ��
//                  if not BoInstanceOpenHealth then begin
//                     BoInstanceOpenHealth := TRUE;
//                     OpenHealthTime := 60 * 1000;
//                     OpenHealthStart := GetTickCount;
//                  end;
//               end;
//               if Race = 0 then BoInstanceOpenHealth := False;
            end;
         SM_SPELL:
            begin
               Dir := msg.dir;
               //msg.x  :targetx
               //msg.y  :targety
               pmag := PTUseMagicInfo (msg.feature);
               if pmag <> nil then begin
                  CurMagic := pmag^;
                  CurMagic.ServerMagicCode := -1; //FIRE ���
                  //CurMagic.MagicSerial := 0;
                  CurMagic.TargX := msg.x;
                  CurMagic.TargY := msg.y;
                  Dispose (pmag);
               end;
               //DScreen.AddSysMsg ('SM_SPELL');
            end;
         else begin
               XX := msg.x;
               YY := msg.y;
               Dir := msg.dir;
            end;
      end;

      CurrentAction := msg.Ident;
      CalcActorFrame;
      //DScreen.AddSysMsg (IntToStr(msg.Ident) + ' ' + IntToStr(XX) + ' ' + IntToStr(YY) + ' : ' + IntToStr(msg.x) + ' ' + IntToStr(msg.y));
   end else begin
      if msg.Ident = SM_SKELETON then begin
         CurrentAction := msg.Ident;
         CalcActorFrame;
         Skeleton := TRUE;
      end;
   end;
   if (msg.Ident = SM_DEATH) or (msg.Ident = SM_NOWDEATH) then begin
      if GroupIdList.Count > 0 then
         for i := 0 to GroupIdList.Count-1 do begin  // MonOpenHp
             if integer(GroupIdList[i]) = RecogId then begin
                GroupIdList.Delete(i);
                Break;
             end;
         end;
      Death := TRUE;
      PlayScene.ActorDied (self);
   end;

   RunSound;
end;

procedure TActor.ProcMsg;
var
   msg: TChrMsg;
   meff: TMagicEff;
begin
   while TRUE do begin
      if MsgList.Count <= 0 then break;
      if CurrentAction <> 0 then break;
      msg := PTChrMsg (MsgList[0])^;
      Dispose (PTChrMsg (MsgList[0]));
      MsgList.Delete (0);

      case msg.ident of
         SM_STRUCK:
            begin
               HiterCode := msg.Sound; //���� ������
               ReadyAction (msg);
            end;
         SM_DEATH,
         SM_NOWDEATH,
         SM_SKELETON,
         SM_ALIVE,
         // 2003/04/01 ��ǳ�� ���� ���
         SM_CROSSHIT,
         SM_TWINHIT,
         SM_STONEHIT,
         SM_ACTION_MIN..SM_ACTION_MAX,
         SM_ACTION2_MIN..SM_ACTION2_MAX,
         SM_DRAGON_LIGHTING..SM_LIGHTING_3,
         3000..3099: //Ŭ���̾�Ʈ �̵� �޼����� �����
            begin
               ReadyAction (msg);
            end;
         SM_SPACEMOVE_HIDE:
            begin
               meff := TScrollHideEffect.Create (250, 10, XX, YY, self);
               PlayScene.EffectList.Add (meff);
               PlaySound (s_spacemove_out);
            end;
         SM_SPACEMOVE_HIDE2:
            begin
               meff := TScrollHideEffect.Create (1590, 10, XX, YY, self);
               PlayScene.EffectList.Add (meff);
               PlaySound (s_spacemove_out);
            end;
         SM_SPACEMOVE_SHOW:
            begin
               meff := TCharEffect.Create (260, 10, self);
               PlayScene.EffectList.Add (meff);
               msg.ident := SM_TURN;
               ReadyAction (msg);
               PlaySound (s_spacemove_in);
            end;
         SM_SPACEMOVE_SHOW2:
            begin
               meff := TCharEffect.Create (1600, 10, self);
               PlayScene.EffectList.Add (meff);
               msg.ident := SM_TURN;
               ReadyAction (msg);
               PlaySound (s_spacemove_in);
            end;
         else
            begin
            end;
      end;
   end;

end;

procedure TActor.ProcHurryMsg; //���� ó���ؾ� �Ǵ� �޼��� ó����..
var
   n: integer;
   msg: TChrMsg;
   fin: Boolean;
begin
   n := 0;
   while TRUE do begin
      if MsgList.Count <= n then break;
      msg := PTChrMsg (MsgList[n])^;
      fin := FALSE;
      case msg.Ident of
         SM_MAGICFIRE:
            if CurMagic.ServerMagicCode <> 0 then begin
               CurMagic.ServerMagicCode := 111;
               CurMagic.Target := msg.x;
               if msg.y in [0..MAXMAGICTYPE-1] then
                  CurMagic.EffectType := TMagicType(msg.y);
               CurMagic.EffectNumber := msg.dir;
               CurMagic.TargX := msg.feature;
               CurMagic.TargY := msg.state;
               CurMagic.Recusion := TRUE;
               fin := TRUE;
               //DScreen.AddSysMsg ('SM_MAGICFIRE GOOD');
            end;
         SM_MAGICFIRE_FAIL:
            if CurMagic.ServerMagicCode <> 0 then begin
               CurMagic.ServerMagicCode := 0;
               fin := TRUE;
            end;
      end;
      if fin then begin
         Dispose (PTChrMsg (MsgList[n]));
         MsgList.Delete (n);
      end else
         Inc (n);
   end;
end;

function  TActor.IsIdle: Boolean;
begin
   if (CurrentAction = 0) and (MsgList.Count = 0) then
      Result := TRUE
   else Result := FALSE;
end;

function  TActor.ActionFinished: Boolean;
begin
   if (CurrentAction = 0) or (currentframe >= endframe) then
      Result := TRUE
   else Result := FALSE;
end;

function  TActor.CanWalk: Integer;
begin
   //��� ���� ������ ���� �� ����. or ���� ������
   if {(GetTickCount - LastStruckTime < 1300) or}(GetTickCount - LatestSpellTime < MagicPKDelayTime) then
      Result := -1   //������
   else
      Result := 1;
end;

function  TActor.CanRun: Integer;
begin
   //��ø�� �������ų�, ü���� �Ҹ�Ǿ����� �� �� ����..
   //��� ���� ������ �ٷ� �� �� ����..
   Result := 1;
   if Abil.HP < RUN_MINHEALTH then begin
      Result := -1;
   end else
   if {(GetTickCount - LastStruckTime < RUN_STRUCK_DELAY) or }(GetTickCount - LatestSpellTime < MagicPKDelayTime) then  //�����﹥�����Ƿ���Ҫ����
      Result := -2;

end;

function  TActor.Strucked: Boolean;
var
   i: integer;
begin
   Result := FALSE;
   for i:=0 to MsgList.Count-1 do begin
      if PTChrMsg (MsgList[i]).Ident = SM_STRUCK then begin
         Result := TRUE;
         break;
      end;
   end;
end;

//��������Ӱ����
//dir : ����
//step : �̵� ĭ
//cur : ���� ����
//max : �ִ� ����
procedure TActor.Shift (dir, step, cur, max: integer);
var
   unx, uny, ss, v: integer;
begin
   unx := UNITX * step;
   uny := UNITY * step;
   if cur > max then cur := max;
   Rx := XX;
   Ry := YY;
   ss := Round((max-cur-1) / max) * step;
   case dir of
      DR_UP:
         begin
            ss := Round((max-cur) / max) * step;
            ShiftX := 0;
            Ry := YY + ss;
            if ss = step then ShiftY := -Round(uny / max * cur)
            else ShiftY := Round(uny / max * (max-cur));
         end;
      DR_UPRIGHT:
         begin
            if max >= 6 then v := 2
            else v := 0;
            ss := Round((max-cur+v) / max) * step;
            Rx := XX - ss;
            Ry := YY + ss;
            if ss = step then begin
               ShiftX :=  Round(unx / max * cur);
               ShiftY := -Round(uny / max * cur);
            end else begin
               ShiftX := -Round(unx / max * (max-cur));
               ShiftY :=  Round(uny / max * (max-cur));
            end;
         end;
      DR_RIGHT:
         begin
            ss := Round((max-cur) / max) * step;
            Rx := XX - ss;
            if ss = step then ShiftX := Round(unx / max * cur)
            else ShiftX := -Round(unx / max * (max-cur));
            ShiftY := 0;
         end;
      DR_DOWNRIGHT:
         begin
            if max >= 6 then v := 2
            else v := 0;
            ss := Round((max-cur-v) / max) * step;
            Rx := XX - ss;
            Ry := YY - ss;
            if ss = step then begin
               ShiftX := Round(unx / max * cur);
               ShiftY := Round(uny / max * cur);
            end else begin
               ShiftX := -Round(unx / max * (max-cur));
               ShiftY := -Round(uny / max * (max-cur));
            end;
         end;
      DR_DOWN:
         begin
            if max >= 6 then v := 1
            else v := 0;
            ss := Round((max-cur-v) / max) * step;
            ShiftX := 0;
            Ry := YY - ss;
            if ss = step then ShiftY := Round(uny / max * cur)
            else ShiftY := -Round(uny / max * (max-cur));
         end;
      DR_DOWNLEFT:
         begin
            if max >= 6 then v := 2
            else v := 0;
            ss := Round((max-cur-v) / max) * step;
            Rx := XX + ss;
            Ry := YY - ss;
            if ss = step then begin
               ShiftX := -Round(unx / max * cur);
               ShiftY :=  Round(uny / max * cur);
            end else begin
               ShiftX :=  Round(unx / max * (max-cur));
               ShiftY := -Round(uny / max * (max-cur));
            end;
         end;
      DR_LEFT:
         begin
            ss := Round((max-cur) / max) * step;
            Rx := XX + ss;
            if ss = step then ShiftX := -Round(unx / max * cur)
            else ShiftX := Round(unx / max * (max-cur));
            ShiftY := 0;
         end;
      DR_UPLEFT:
         begin
            if max >= 6 then v := 2
            else v := 0;
            ss := Round((max-cur+v) / max) * step;
            Rx := XX + ss;
            Ry := YY + ss;
            if ss = step then begin
               ShiftX := -Round(unx / max * cur);
               ShiftY := -Round(uny / max * cur);
            end else begin
               ShiftX := Round(unx / max * (max-cur));
               ShiftY := Round(uny / max * (max-cur));
            end;
         end;
   end;
end;

procedure  TActor.FeatureChanged;
var
   haircount: integer;
begin
   case Race of
      //human
      0: begin
         hair   := HAIRfeature (Feature);         //����ȴ�.
         dress  := DRESSfeature (Feature);
         weapon := WEAPONfeature (Feature);
         BodyOffset := HUMANFRAME * Dress; //����0, ����1
         haircount := WHairImg.ImageCount div HUMANFRAME div 2;
         if hair > haircount-1 then hair := haircount-1;
         hair := hair * 2;
         if hair > 1 then
            HairOffset := HUMANFRAME * (hair + Sex)
         else HairOffset := -1;
         WeaponOffset := HUMANFRAME * weapon; //(shape*2 + Sex);
         if dress = 18 then WingOffset := 0                  // õ�ǹ���(��)
         else if dress = 19 then WingOffset := HUMANFRAME    // õ�ǹ���(��)
         else if dress = 20 then WingOffset := HUMANFRAME*2  // õ��һ���(��)
         else if dress = 21 then WingOffset := HUMANFRAME*3  // õ��һ���(��)
         else if dress in [22,23] then WingOffset := 352;    // 50������

         if weapon = 76 then WeaponEffectOffset := HUMANFRAME*4        // �İ����� ����Ʈ(��)
         else if weapon = 77 then WeaponEffectOffset := HUMANFRAME*5;  // �İ����� ����Ʈ(��)
      end;
      50: ;  //npc
      else begin
         Appearance := APPRfeature (Feature);
         BodyOffset := GetOffset (Appearance);
         //BodyOffset := MONFRAME * (Appearance mod 10);
      end;
   end;
end;

function   TActor.Light: integer;
begin
   Result := ChrLight;
end;

procedure  TActor.LoadSurface;
var
   mimg: TWMImages;
begin
   mimg := GetMonImg (Appearance);
   if mimg <> nil then begin
      if (not ReverseFrame) then
         BodySurface := mimg.GetCachedImage (GetOffset (Appearance) + currentframe, px, py)
      else
         BodySurface := mimg.GetCachedImage (
                            GetOffset (Appearance) + endframe - (currentframe-startframe),
                            px, py);
   end;
end;

function  TActor.CharWidth: Integer;
begin
   if BodySurface <> nil then
      Result := BodySurface.Width
   else Result := 48;
end;

function  TActor.CharHeight: Integer;
begin
   if BodySurface <> nil then
      Result := BodySurface.Height
   else Result := 70;
end;

function  TActor.CheckSelect (dx, dy: integer): Boolean;
var
   c: integer;
begin
   Result := FALSE;
   if BodySurface <> nil then begin
      c := BodySurface.Pixels[dx, dy];
      if (c <> 0) and
         ((BodySurface.Pixels[dx-1, dy] <> 0) and
          (BodySurface.Pixels[dx+1, dy] <> 0) and
          (BodySurface.Pixels[dx, dy-1] <> 0) and
          (BodySurface.Pixels[dx, dy+1] <> 0)) then
         Result := TRUE;
   end;
end;

procedure TActor.DrawEffSurface (dsurface, source: TDXTexture; ddx, ddy: integer; blend: Boolean; ceff: TColorEffect; blendmode: integer);
begin
   if State and $00800000 <> 0 then begin
      blend := TRUE;  //����
   end;
   if not Blend then begin
      if ceff = ceNone then begin
         if source <> nil then
            dsurface.Draw (ddx, ddy, source.ClientRect, source, TRUE);
      end else begin
         if source <> nil then begin 
            DrawEffect(dsurface, ddx, ddy, source, ceff, blend, blendmode);
//            ImgMixSurface.Draw (0, 0, source.ClientRect, source, FALSE);
//            DrawEffect (0, 0, source.Width, source.Height, ImgMixSurface, ceff);
//            dsurface.Draw (ddx, ddy, source.ClientRect, ImgMixSurface, TRUE);
         end;
      end;
   end else begin
      if ceff = ceNone then begin
         if source <> nil then
            DrawBlend (dsurface, ddx, ddy, source, 0);
      end else begin
         if source <> nil then begin  
           DrawEffect(dsurface, ddx, ddy, source, ceff, blend, blendmode);
//            ImgMixSurface.Fill(0);
//            ImgMixSurface.Draw (0, 0, source.ClientRect, source, FALSE);
//            DrawEffect (0, 0, source.Width, source.Height, ImgMixSurface, ceff);
//            DrawBlend (dsurface, ddx, ddy, ImgMixSurface, 0);
         end;
      end;
   end;
end;

procedure TActor.DrawWeaponGlimmer (dsurface: TDXTexture; ddx, ddy: integer);
var
   idx, ax, ay: integer;
   d: TDXTexture;
begin
   //������..(��ȭ��) �׷��� ����...
   (*if BoNextTimeFireHit and WarMode and GlimmingMode then begin
      if GetTickCount - GlimmerTime > 200 then begin
         GlimmerTime := GetTickCount;
         Inc (CurGlimmer);
         if CurGlimmer >= MaxGlimmer then CurGlimmer := 0;
      end;
      idx := GetEffectBase (5-1{��ȭ���¦��}, 1) + Dir*10 + CurGlimmer;
      d := WMagic.GetCachedImage (idx, ax, ay);
      if d <> nil then
         DrawBlend (dsurface, ddx + ax, ddy + ay, d, 1);
                          //dx + ax + ShiftX,
                          //dy + ay + ShiftY,
                          //d, 1);
   end;*)
end;

function TActor.GetDrawEffectValue: TColorEffect;
var
   ceff: TColorEffect;
begin
   ceff := ceNone;

   //���õ� ĳ�� ���.
   if (FocusCret = self) {or (MagicTarget = self)} then begin    //������ʧ
      ceff := ceBright;
   end;

   //�ߵ�
   if State and $80000000 <> 0 then begin        //POISON_DECHEALTH
      ceff := ceGreen;
   end;
   if State and $40000000 <> 0 then begin        //POISON_DAMAGEARMOR
      ceff := ceRed;
   end;
   if State and $20000000 <> 0 then begin        //POISON_ICE
      ceff := ceBlue;
   end;
   if State and $10000000 <> 0 then begin        //POISON_STUN
      ceff := ceYellow;
   end;
   if State and $08000000 <> 0 then begin        //POISON_SLOW
      ceff := ceFuchsia;
   end;
   if State and $04000000 <> 0 then begin        //POISON_STONE
      ceff := ceGrayScale;
   end;
   if State and $02000000 <> 0 then begin        //POISON_DONTMOVE
      ceff := ceGrayScale;   // ������ ����
   end;

   // 2004/03/22 50 LevelEffect
   if (Race = 0) and ((State and $00080000) <> 0) then //50LEVELEFFECT
      Bo50LevelEffect := True
   else Bo50LevelEffect := False;

{   FoodStickType := 0;
   if (Race = 0) and ((State and $00040000) <> 0) then //������
      FoodStickType := 2;
   if (Race = 0) and ((State and $00020000) <> 0) then //ȣ��
      FoodStickType := 1;
   if (Race = 0) and ((State and $00010000) <> 0) then //��Ʈ
      FoodStickType := 3;}

//   if (Race = 0) and (State and $00080000 <> 0) then //WRITEREFFECT
//      BoWriterEffect := True
//   else BoWriterEffect := False;

   Result := ceff;
end;

procedure  TActor.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   idx, ax, ay: integer;
   d: TDXTexture;
   ceff: TColorEffect;
   wimg: TWMImages;
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

   if BoUseMagic {and (EffDir[Dir] = 1)} and (CurMagic.EffectNumber > 0) then
      if CurEffFrame in [0..SpellFrame-1] then begin
         GetEffectBase (Curmagic.EffectNumber-1, 0, wimg, idx);
         idx := idx + CurEffFrame;
         if wimg <> nil then
            d := wimg.GetCachedImage (idx, ax, ay);
         if d <> nil then
            DrawBlend (dsurface,
                             dx + ax + ShiftX,
                             dy + ay + ShiftY,
                             d, 1);
      end;
end;

procedure  TActor.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
end;


function  TActor.GetDefaultFrame (wmode: Boolean): integer;
var
   cf, dr: integer;
   pm: PTMonsterAction;
begin
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;

   if Death then begin
      if Skeleton then
         Result := pm.ActDeath.start
      else Result := pm.ActDie.start + Dir * (pm.ActDie.frame + pm.ActDie.skip) + (pm.ActDie.frame - 1);
   end else begin
      defframecount := pm.ActStand.frame;
      if currentdefframe < 0 then cf := 0
      else if currentdefframe >= pm.ActStand.frame then cf := 0
      else cf := currentdefframe;
      Result := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip) + cf;
   end;
end;

procedure TActor.DefaultMotion;   //���� ����,  �⺻ �ڼ�..
begin
   ReverseFrame := FALSE;
   if WarMode then begin
      if (GetTickCount - WarModeTime > 4*1000) then //and not BoNextTimeFireHit then
         WarMode := FALSE;
   end;
   currentframe := GetDefaultFrame (WarMode);
   Shift (Dir, 0, 1, 1);
end;

//���� ������ �ʱ�ȭ �Ѵ�.
procedure TActor.SetSound;
var
   cx, cy, bidx, wunit, attackweapon: integer;
   hiter: TActor;
begin
   if Race = 0 then begin
      if (self = Myself) and
         ((CurrentAction=SM_WALK) or
          (CurrentAction=SM_BACKSTEP) or
          (CurrentAction=SM_RUN) or
          (CurrentAction=SM_RUSH) or
          (CurrentAction=SM_RUSHKUNG)
         )
      then begin
         cx := Myself.XX - Map.BlockLeft;
         cy := Myself.YY - Map.BlockTop;
         cx := cx div 2 * 2;
         cy := cy div 2 * 2;
         bidx := Map.MArr[cx, cy].BkImg and $7FFF;
         wunit := Map.MArr[cx, cy].Area;
         bidx := wunit * 10000 + bidx - 1;
         case bidx of
            //ª�� Ǯ
            330..349, 450..454, 550..554, 750..754,
            950..954, 1250..1254, 1400..1424, 1455..1474,
            1500..1524, 1550..1574:
               footstepsound := s_walk_lawn_l;

            //�߰�Ǯ

            //�� Ǯ
            250..254, 1005..1009, 1050..1054, 1060..1064, 1450..1454,
            1650..1654:
               footstepsound := s_walk_rough_l;

            //�� ��
            //�븮�� �ٴ�
            605..609, 650..654, 660..664, 2000..2049,
            3025..3049, 2400..2424, 4625..4649, 4675..4678:
               footstepsound := s_walk_stone_l;

            //������
            1825..1924, 2150..2174, 3075..3099, 3325..3349,
            3375..3399:
               footstepsound := s_walk_cave_l;

            //�����ٴ�
           3230, 3231, 3246, 3277:
               footstepsound := s_walk_wood_l;

           //����..
           3780..3799:
               footstepsound := s_walk_wood_l;

           3825..4434:
               if (bidx-3825) mod 25 = 0 then footstepsound := s_walk_wood_l
               else footstepsound := s_walk_ground_l;


            //����(�Ҹ� ���� �ȳ�)
             2075..2099, 2125..2149:
               footstepsound := s_walk_room_l;

            //����
            1800..1824:
               footstepsound := s_walk_water_l;

            else
               footstepsound := s_walk_ground_l;
         end;
         //��������
         if (bidx >= 825) and (bidx <= 1349) then begin
            if ((bidx-825) div 25) mod 2 = 0 then
               footstepsound := s_walk_stone_l;
         end;
         //��������
         if (bidx >= 1375) and (bidx <= 1799) then begin
            if ((bidx-1375) div 25) mod 2 = 0 then
               footstepsound := s_walk_cave_l;
         end;
         case bidx of
            1385, 1386, 1391, 1392:
               footstepsound := s_walk_wood_l;
         end;

         bidx := Map.MArr[cx, cy].MidImg and $7FFF;
         bidx := bidx - 1;
         case bidx of
            0..115:
               footstepsound := s_walk_ground_l;
            120..124:
               footstepsound := s_walk_lawn_l;
         end;

         bidx := Map.MArr[cx, cy].FrImg and $7FFF;
         bidx := bidx - 1;
         case bidx of
            //������
            221..289, 583..658, 1183..1206, 7163..7295,
            7404..7414:
               footstepsound := s_walk_stone_l;
            //��������
            3125..3267, {3319..3345, 3376..3433,} 3757..3948,
            6030..6999:
               footstepsound := s_walk_wood_l;
            //��ٴ�
            3316..3589:
               footstepsound := s_walk_room_l;
         end;
         if CurrentAction = SM_RUN then
            footstepsound := footstepsound + 2;

      end;

      if Sex = 0 then begin //����
         screamsound := s_man_struck;
         diesound := s_man_die;
      end else begin //����
         screamsound := s_wom_struck;
         diesound := s_wom_die;
      end;

      case CurrentAction of
         // 2003/03/15 �űԹ���
         SM_THROW, SM_HIT, SM_HIT+1, SM_HIT+2, SM_POWERHIT, SM_LONGHIT,
         SM_WIDEHIT, SM_FIREHIT, SM_CROSSHIT, SM_TWINHIT , SM_STONEHIT:
            begin
               case (weapon div 2) of
                  6, 20:  weaponsound := s_hit_short;
                  1, 27, 28 , 33:  weaponsound := s_hit_wooden;
                  2, 13, 9, 5, 14, 22, 25, 30, 35, 36, 37,38:  weaponsound := s_hit_sword;
                  4, 17, 10, 15, 16, 23, 26, 29, 31, 34:  weaponsound := s_hit_do;
                  3, 7, 11:  weaponsound := s_hit_axe;
                  24:  weaponsound := s_hit_club;
                  8, 12, 18, 21, 32:  weaponsound := s_hit_long;
                  else weaponsound := s_hit_fist;
               end;
            end;
         SM_STRUCK:
            begin
               if MagicStruckSound >= 1 then begin  //�������� ����
                  //strucksound := s_struck_magic;  //�ӽ�..
               end else begin
                  hiter := PlayScene.FindActor (HiterCode);
                  attackweapon := 0;
                  if hiter <> nil then begin //�������� �������� ���ȴ��� �˻�
                     attackweapon := hiter.weapon div 2;
                     if hiter.Race = 0 then
                        case (dress div 2) of
                           3: //����
                              case attackweapon of
                                 6:  strucksound := s_struck_armor_sword;
                                 1,2,4,5,9,10,13,14,15,16,17,
                                 22,23,24,25,26,27,28,29,30,31,33,34,35,36,37,38:
                                    strucksound := s_struck_armor_sword;
                                 3,7,11: strucksound := s_struck_armor_axe;
                                 8,12,18,21,32: strucksound := s_struck_armor_longstick;
                                 else strucksound := s_struck_armor_fist;
                              end;
                           else //�Ϲ�
                              case attackweapon of
                                 6: strucksound := s_struck_body_sword;
                                 1,2,4,5,9,10,13,14,15,16,17,
                                 22,23,24,25,26,27,28,29,30,31,33,34,35,36,37,38:
                                    strucksound := s_struck_body_sword;
                                 3,7,11: strucksound := s_struck_body_axe;
                                 8,12,18,21,32: strucksound := s_struck_body_longstick;
                                 else strucksound := s_struck_body_fist;
                              end;
                        end;
                  end;
               end;
            end;
      end;

      //���� �Ҹ�
      if BoUseMagic and (CurMagic.MagicSerial > 0) then begin
         magicstartsound := 10000 + CurMagic.MagicSerial * 10;
         magicfiresound := 10000 + CurMagic.MagicSerial * 10 + 1;
         magicexplosionsound := 10000 + CurMagic.MagicSerial * 10 + 2;
      end;

   end else begin
      if CurrentAction = SM_STRUCK then begin
         if MagicStruckSound >= 1 then begin  //�������� ����
            //strucksound := s_struck_magic;  //�ӽ�..
         end else begin
            hiter := PlayScene.FindActor (HiterCode);
            if hiter <> nil then begin  //�������� �������� ���ȴ��� �˻�
               attackweapon := hiter.weapon div 2;
               case attackweapon of
                  6: strucksound := s_struck_body_sword;
                  1,2,4,5,9,10,13,14,15,16,17,
                  22,23,24,25,26,27,28,29,30,31,33,34,35,36,37,38:
                  strucksound := s_struck_body_sword;
                  3,7,11: strucksound := s_struck_body_axe;
                  8,12,18,21,32: strucksound := s_struck_body_longstick;
                  else strucksound := s_struck_body_fist;
               end;
            end;
         end;
      end;

      if Race = 50 then begin
      end else begin
//      if Race = 91 then   // ���δ��� Appearance=> 220
//         DScreen.AddChatBoardString ('[Race = 91]Appearance=> '+IntToStr(Appearance), clYellow, clRed);
         appearsound := 200 + (Appearance) * 10;
         normalsound := 200 + (Appearance) * 10 + 1;
         attacksound := 200 + (Appearance) * 10 + 2;  //�����
         weaponsound := 200 + (Appearance) * 10 + 3;  //��(�����ֵη�)
         screamsound := 200 + (Appearance) * 10 + 4;
         diesound := 200 + (Appearance) * 10 + 5;
         die2sound := 200 + (Appearance) * 10 + 6;
      end;
   end;

   //Į �´� �Ҹ�
   if CurrentAction = SM_STRUCK then begin
      hiter := PlayScene.FindActor (HiterCode);
      attackweapon := 0;
      if hiter <> nil then begin  //�������� �������� ���ȴ��� �˻�
         attackweapon := hiter.weapon div 2;
         if hiter.Race = 0 then
            case (attackweapon div 2) of
               6, 20:  struckweaponsound := s_struck_short;
               1,27,28,33:  struckweaponsound := s_struck_wooden;
               2, 13, 9, 5, 14, 22,25,30,35,36,37,38:  struckweaponsound := s_struck_sword;
               4, 17, 10, 15, 16, 23,26,29,31,34:  struckweaponsound := s_struck_do;
               3, 7, 11:  struckweaponsound := s_struck_axe;
               24:  struckweaponsound := s_struck_club;
               8, 12, 18, 21,32:  struckweaponsound := s_struck_wooden; //long;
               //else struckweaponsound := s_struck_fist;
            end;
      end;
   end;
end;

procedure  TActor.RunSound;
begin
   borunsound := TRUE;
   SetSound;
   case CurrentAction of
      SM_STRUCK:
         begin
            if (struckweaponsound >= 0) then PlaySound (struckweaponsound);
            if (strucksound >= 0) then PlaySound (strucksound);
            if (screamsound >= 0) then PlaySound (screamsound);
         end;
      SM_NOWDEATH:
         begin
            if (diesound >= 0) then PlaySound (diesound);
         end;
      SM_THROW, SM_HIT, SM_FLYAXE, SM_LIGHTING, SM_DIGDOWN{������}:
         begin
            if((Race = 91) and (CurrentAction = SM_LIGHTING)) then PlaySound (2406) // ���δ��� Attact2 ����
            else if((Race = 92) and (CurrentAction = SM_LIGHTING)) then PlaySound (2416) // �ָ��ݷ��� Attact2 ����
            else if((Race = 93) and (CurrentAction = SM_LIGHTING)) then PlaySound (2426) // ȯ����ȣ Attact2 ����
            else if((Race = 94) and (CurrentAction = SM_LIGHTING)) then PlaySound (2436) // �Ź� Attact2 ����
            else if attacksound >= 0 then PlaySound (attacksound);
         end;
//      SM_ALIVE, SM_DIGUP{����,������}:
      SM_DIGUP{����,������}: //####
         begin
            PlaySound (appearsound);
         end;
      SM_SPELL:
         begin
            PlaySound (magicstartsound);
         end;
   end;
end;

procedure  TActor.RunActSound (frame: integer);
begin
   if borunsound then begin
      if Race = 0 then begin
         case CurrentAction of
            SM_THROW, SM_HIT, SM_HIT+1, SM_HIT+2:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  borunsound := FALSE;
               end;
            SM_POWERHIT:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  if Sex = 0 then PlaySound (s_yedo_man)
                  else PlaySound (s_yedo_woman);
                  borunsound := FALSE;
               end;
            SM_LONGHIT:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  PlaySound (s_longhit);
                  borunsound := FALSE; //�ѹ��� �Ҹ���
               end;
            SM_WIDEHIT:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  PlaySound (s_widehit);
                  borunsound := FALSE;
               end;
            SM_FIREHIT:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  PlaySound (s_firehit);
                  borunsound := FALSE;
               end;
            SM_CROSSHIT:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  PlaySound (s_crosshit);
                  borunsound := FALSE; //�ѹ��� �Ҹ���
               end;
            SM_TWINHIT:
               if frame = 2 then begin
                  PlaySound (weaponsound);
                  PlaySound (s_twinhit);
                  borunsound := FALSE;
               end;
         end;
      end else begin
         if Race = 50 then begin
         end else begin
          //(** �� ����
            if (CurrentAction = SM_WALK) or (CurrentAction = SM_TURN) then begin
               if (frame = 1) and (Random(8) = 1) then begin
                  PlaySound (normalsound);
                  borunsound := FALSE; //�ѹ��� �Ҹ���
               end;
            end;
            if CurrentAction = SM_HIT then begin
               if (frame = 3) and (attacksound >= 0) then begin
                  PlaySound (weaponsound);
                  borunsound := FALSE;
               end;
            end;
            case Appearance of
               80: //������
                  begin
                     if CurrentAction = SM_NOWDEATH then begin
                        if (frame = 2) then begin
                           PlaySound (die2sound);
                           borunsound := FALSE; //�ѹ��� �Ҹ���
                        end;
                     end;
                  end;
            end;
         end; //*)

      end;
   end;
end;

procedure  TActor.RunFrameAction (frame: integer);
begin
end;

procedure  TActor.ActionEnded;
begin
end;

procedure TActor.Run;
   function MagicTimeOut: Boolean;
   begin
//      if self = Myself then begin
         Result := GetTickCount - WaitMagicRequest > 3000;
//      end else
//         Result := GetTickCount - WaitMagicRequest > 2000;
      if Result then
         CurMagic.ServerMagicCode := 0;
   end;
var
   prv: integer;
   frametimetime: longword;
   bofly: Boolean;
begin

   if (CurrentAction = SM_WALK) or
      (CurrentAction = SM_BACKSTEP) or
      (CurrentAction = SM_RUN) or
      (CurrentAction = SM_RUSH) or
      (CurrentAction = SM_RUSHKUNG)
   then exit;

   msgmuch := FALSE;
   if self <> Myself then begin
      if MsgList.Count >= 2 then msgmuch := TRUE;
   end;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

//      if (self <> Myself) and (BoUseMagic) then begin
//         frametimetime := Round(frametime / 1.8);
//      end else begin
         if msgmuch then frametimetime := Round(frametime * 2 / 3)
         else frametimetime := frametime; //2004/04/07 �ӵ����� ����
//      end;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin
            //������ ��� ������ ��ȣ�� �޾�, ����/���и� Ȯ������
            //������������ ������.
            if BoUseMagic then begin
               if (CurEffFrame = SpellFrame-2) or (MagicTimeOut) then begin //��ٸ� ��
                  if (CurMagic.ServerMagicCode >= 0) or (MagicTimeOut) then begin //������ ���� ���� ���. ���� �ȿ����� ��ٸ�
                    Inc (currentframe);
                    Inc (CurEffFrame);
                    starttime := GetTickCount;
                  end;
               end else begin
                   if currentframe < endframe - 1 then Inc (currentframe);
                   Inc (CurEffFrame);
                   starttime := GetTickCount;
               end;
            end else begin
               Inc (currentframe);
               starttime := GetTickCount;
            end;

         end else begin
            if BoDelActionAfterFinished then begin
               //�� ������ �����.
               BoDelActor := TRUE;
            end;
            //������ ����.
            if self = Myself then begin
               //���ΰ� �ΰ��
               if FrmMain.ServerAcceptNextAction then begin
                  ActionEnded;
                  CurrentAction := 0;
                  BoUseMagic := FALSE;
               end;
            end else begin
               ActionEnded;
               CurrentAction := 0; //���� �Ϸ�
               BoUseMagic := FALSE;
            end;
         end;
         if BoUseMagic then begin
            //������ ���� ���
            if CurEffFrame = SpellFrame-1 then begin //���� �߻� ����
               //���� �߻�
               if CurMagic.ServerMagicCode > 0 then begin
                  with CurMagic do
                     PlayScene.NewMagic (self,
                                      ServerMagicCode,
                                      EffectNumber,
                                      XX,
                                      YY,
                                      TargX,
                                      TargY,
                                      Target,
                                      EffectType,
                                      Recusion,
                                      AniTime,
                                      bofly);
                  if bofly then
                     PlaySound (magicfiresound)
                  else
                     PlaySound (magicexplosionsound);
               end;
               //LatestSpellTime := GetTickCount;
               CurMagic.ServerMagicCode := 0;
            end;
         end;
      end;
      if Appearance in [0, 1, 43] then currentdefframe := -10
      else currentdefframe := 0;
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

function  TActor.Move (step: integer; out boChange: Boolean): Boolean;
var
   prv, curstep, maxstep: integer;
   fastmove, normmove: Boolean;
begin
   Result := FALSE;    
   boChange := False;
   fastmove := FALSE;
   normmove := FALSE;
   if (CurrentAction = SM_BACKSTEP) then //or (CurrentAction = SM_RUSH) or (CurrentAction = SM_RUSHKUNG) then
      fastmove := TRUE;
   if (CurrentAction = SM_RUSH) or (CurrentAction = SM_RUSHKUNG) then
      normmove := TRUE;
   // 2003/07/03 ��õĴ���
//   if ((UseItems[U_DRESS].S.Shape = 10) or
//       (UseItems[U_DRESS].S.Shape = 12) )and (UseItems[U_DRESS].Dura > 0) then begin
//      fastmove := TRUE;
//   end;

   if (self = Myself) and (not fastmove) and (not normmove) then begin
      BoMoveSlow := FALSE;
      BoMoveSlow2 := FALSE;      
      BoAttackSlow := FALSE;
      MoveSlowLevel := 0;
      MoveSlowValue := 0;
      //���γ��غ����̫�ղ�����20030715����
//      if Abil.Weight > Abil.MaxWeight then begin
//         MoveSlowLevel := Abil.Weight div Abil.MaxWeight;
//         BoMoveSlow := TRUE;
//      end;
//      if Abil.WearWeight > Abil.MaxWearWeight then begin
//         MoveSlowLevel := MoveSlowLevel + Abil.WearWeight div Abil.MaxWearWeight;
//         BoMoveSlow := TRUE;
//      end;
//      if Abil.HandWeight > Abil.MaxHandWeight then begin
//         BoAttackSlow := TRUE;
//      end;
      // 2003/07/15 �����̻� �߰� ��ȭ ... �̵� �ӵ�, ���� �ӵ� ��ȭ
      if State and $08000000 <> 0 then begin        //POISON_SLOW
         MoveSlowLevel := MoveSlowLevel + 5;
         MoveSlowValue := 1; //���ּ� ���ο� �ӵ� ����
         BoMoveSlow2 := TRUE;
         BoAttackSlow := TRUE;
      end;
         //���γ��غ���٣�
//      if BoMoveSlow and (SkipTick < MoveSlowLevel) then begin
//         Inc (SkipTick); //�ѹ� ����.
//         exit;
//      end else begin
//         SkipTick := 0;
//      end;
//
//      if BoMoveSlow2 and (SkipTick2 > MoveSlowValue) then
//      begin
//         SkipTick2 := 0;
//         exit;
//      end else begin
//         Inc (SkipTick2);
//      end;

      //���� ȿ��
      if (CurrentAction = SM_WALK) or
         (CurrentAction = SM_BACKSTEP) or
         (CurrentAction = SM_RUN) or
         (CurrentAction = SM_RUSH) or
         (CurrentAction = SM_RUSHKUNG)
      then begin
         case (currentframe - startframe) of
            1: PlaySound (footstepsound);
            4: PlaySound (footstepsound + 1);
         end;
      end;
   end;

   Result := FALSE;
   msgmuch := FALSE;
   if self <> Myself then begin
      if MsgList.Count >= 2 then msgmuch := TRUE;
   end;
   prv := currentframe;
   //�ȱ� �ٱ�
   if (CurrentAction = SM_WALK) or
      (CurrentAction = SM_RUN) or
      (CurrentAction = SM_RUSH) or
      (CurrentAction = SM_RUSHKUNG)
   then begin
      if (currentframe < startframe) or (currentframe > endframe) then begin
         currentframe := startframe - 1;
      end;
      if currentframe < endframe then begin
         Inc (currentframe);
         if msgmuch and not normmove then //or fastmove then
            if currentframe < endframe then
               Inc (currentframe);

         //�ε巴�� �̵��ϰ� �Ϸ���
         curstep := currentframe-startframe + 1;
         maxstep := endframe-startframe + 1;
         Shift (Dir, movestep, curstep, maxstep);
      end;
      if currentframe >= endframe then begin
         if self = Myself then begin
            if FrmMain.ServerAcceptNextAction then begin
               CurrentAction := 0;     //������ ��ȣ�� ������ ���� ����
               LockEndFrame := TRUE;   //�����ǽ�ȣ�� ��� �����������ӿ��� ����
               smoothmovetime := GetTickCount;
            end;
         end else begin
            CurrentAction := 0; //���� �Ϸ�
            LockEndFrame := TRUE;
            smoothmovetime := GetTickCount;
         end;
         Result := TRUE;
      end;
      if CurrentAction = SM_RUSH then begin
         if self = Myself then begin
            DizzyDelayStart := GetTickCount;
            DizzyDelayTime := 300; //������
         end;
      end;
      if CurrentAction = SM_RUSHKUNG then begin
         if currentframe >= endframe - 3 then begin
            XX := actbeforex;
            YY := actbeforey;
            Rx := XX;
            Ry := YY;
            CurrentAction := 0;
            LockEndFrame := TRUE;
            //smoothmovetime := GetTickCount;
         end;
      end;
      Result := TRUE;
   end;
   //�ް�����
   if (CurrentAction = SM_BACKSTEP) then begin
      if (currentframe > endframe) or (currentframe < startframe) then begin
         currentframe := endframe + 1;
      end;
      if currentframe > startframe then begin
         Dec (currentframe);
         if msgmuch or fastmove then
            if currentframe > startframe then Dec (currentframe);

         //�ε巴�� �̵��ϰ� �Ϸ���
         curstep := endframe - currentframe + 1;
         maxstep := endframe - startframe + 1;
         Shift (GetBack(Dir), movestep, curstep, maxstep);
      end;
      if currentframe <= startframe then begin
         if self = Myself then begin
            //if FrmMain.ServerAcceptNextAction then begin
               CurrentAction := 0;     //������ ��ȣ�� ������ ���� ����
               LockEndFrame := TRUE;   //�����ǽ�ȣ�� ��� �����������ӿ��� ����
               smoothmovetime := GetTickCount;

               //�ڷ� �и� ���� �ѵ��� �� �����δ�.
               DizzyDelayStart := GetTickCount;
               DizzyDelayTime := 1000; //1�� ������
            //end;
         end else begin
            CurrentAction := 0; //���� �Ϸ�
            LockEndFrame := TRUE;
            smoothmovetime := GetTickCount;
         end;
         Result := TRUE;
      end;
      Result := TRUE;
   end;
   if prv <> currentframe then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;  
      boChange := True;
   end;
end;

procedure TActor.MoveFail;
begin
   CurrentAction := 0; //���� �Ϸ�
   LockEndFrame := TRUE;
   Myself.XX := oldx;
   Myself.YY := oldy;
   Myself.Dir := olddir;
   CleanUserMsgs;
end;

function  TActor.CanCancelAction: Boolean;
begin
   Result := FALSE;
   if CurrentAction = SM_HIT then
      if not BoUseEffect then
         Result := TRUE;
end;

procedure TActor.CancelAction;
begin
   CurrentAction := 0; //���� �Ϸ�
   LockEndFrame := TRUE;
end;

procedure TActor.CleanCharMapSetting (x, y: integer);
begin
   Myself.XX := x;
   Myself.YY := y;
   Myself.RX := x;
   Myself.RY := y;
   oldx := x;
   oldy := y;
   CurrentAction := 0;
   currentframe := -1;
   CleanUserMsgs;
end;

procedure TActor.Say (str: string);
var
   i, len, aline, n: integer;
   dline, temp: string;
   loop: Boolean;
const
   MAXWIDTH = 150;
begin
   SayTime := GetTickCount;
   SayLineCount := 0;

   n := 0;
   loop := TRUE;
   while loop do begin
      temp := '';
      i := 1;
      len := Length (str);
      while TRUE do begin
         if i > len then begin
            loop := FALSE;
            break;
         end;
         if byte (str[i]) >= 128 then begin
            temp := temp + str[i];
            Inc (i);
            if i <= len then temp := temp + str[i]
            else begin
               loop := FALSE;
               break;
            end;
         end else
            temp := temp + str[i];

         aline := FrmMain.Canvas.TextWidth (temp);
         if aline > MAXWIDTH then begin
            Saying[n] := temp;
            SayWidths[n] := aline;
            Inc (SayLineCount);
            Inc (n);
            if n >= MAXSAY then begin
               loop := FALSE;
               break;
            end;
            str := Copy (str, i+1, Len-i);
            temp := '';
            break;
         end;
         Inc (i);
      end;
      if temp <> '' then begin
         if n < MAXWIDTH then begin
            Saying[n] := temp;
            SayWidths[n] := FrmMain.Canvas.TextWidth (temp);
            Inc (SayLineCount);
         end;
      end;
   end;
end;



{============================== NPCActor =============================}


// 2003/07/15 �ű� NPC �߰�
constructor TNpcActor.Create;
begin
   inherited Create;
   EffectSurface := nil;
   BoUseEffect   := FALSE;
   PlaySnow      := False;
end;

procedure TNpcActor.CalcActorFrame;
var
   pm: PTMonsterAction;
   haircount: integer;
begin
   BoUseMagic := FALSE;
   currentframe := -1;

   BodyOffset := GetNpcOffset (Appearance);

   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;
   Dir := Dir mod 3;  //������ 0, 1, 2 �ۿ� ����..
   case CurrentAction of
      SM_TURN: //NewNpc
         begin
//            if Appearance = 57 then begin
//               Dir := 0;
//               pm.ActStand.frame := 10;
//               pm.ActStand.ftime := 120;
//            end
//            else if Appearance in [58,60,69..74,78..80] then Dir := 0;
            if Appearance in [53..56,66..74,77..79,86..104,106,115,119..137] then Dir := 0;

            startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
            endframe := startframe + pm.ActStand.frame - 1;
            frametime := pm.ActStand.ftime;
            starttime := GetTickCount;
            defframecount := pm.ActStand.frame;
            Shift (Dir, 0, 0, 1);

            //������
            if Appearance in [86..90] then begin
               startframe := 0;
               endframe := 9;
               frametime := 150;
               starttime := GetTickCount;
               defframecount := 9;
            end;
            if Appearance in [91,92,94..103,106,115,119..137] then begin
               startframe := 0;
               endframe := 0;
               frametime := 150;
               starttime := GetTickCount;
               defframecount := 0;
            end;
            if ((Appearance = 33)) and (not BoUseEffect) then begin
               BoUseEffect   := TRUE;
               effectstart   := 30;
               effectframe   := effectstart;
               effectend     := effectstart + 9;
               effectstarttime := GetTickCount;
               effectframetime := 300;
            end
            else if Appearance in [42..47] then begin //FireDragon
               startframe := 20;
               endframe := 10;
               BoUseEffect   := TRUE;
               effectstart   := 0;
               effectframe   := 0;
               effectend     := 19;
               effectstarttime := GetTickCount;
               effectframetime := 100;
            end
            else if Appearance = 51 then begin //2004/05/27 50LevelQuest �α�
               BoUseEffect   := TRUE;
               effectstart   := 60;
               effectframe   := effectstart;
               effectend     := effectstart + 7;
               effectstarttime := GetTickCount;
               effectframetime := 500;
            end
            else if Appearance = 61 then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 240 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance = 62 then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 180 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance = 63 then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 120 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [64,65] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 60 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [66,67,69..74] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 4;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [117] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 4 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance = 92 then begin
               BoUseEffect   := TRUE;
               effectstart   := 10;
               effectframe   := effectstart;
               effectend     := effectstart + 9;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end

//            else if Appearance in [61..64] then begin //������� �Ҳ�
//               startframe := 6;
//               endframe := 7;
//               BoUseEffect   := TRUE;
//               effectstart   := 0;
//               effectframe   := 0;
//               effectend     := 4;
//               effectstarttime := GetTickCount;
//               effectframetime := 100;
//            end
//            else if Appearance = 65 then begin //��ں�
//               startframe := 8;
//               endframe := 9;
//               BoUseEffect   := TRUE;
//               effectstart   := 0;
//               effectframe   := 0;
//               effectend     := 5;
//               effectstarttime := GetTickCount;
//               effectframetime := 100;
//            end
            else if Appearance = 104 then begin
               startframe := 0;
               endframe := 19;
               frametime := 200;
               starttime := GetTickCount;
               defframecount := 19;
               BoUseEffect   := TRUE;
               effectstart   := 20;
               effectframe   := effectstart;
               effectend     := effectstart + 19;
               effectstarttime := GetTickCount;
               effectframetime := 200;
            end
            else if Appearance in [125..127,132] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 10 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 15;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [129..130] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 20 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 8;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
         end;
      SM_HIT:
         begin
            // 2003/07/15 �ű� NPC �߰�
//            if Appearance = 57 then begin
//               Dir := 0;
//               pm.ActStand.frame := 10;
//               pm.ActStand.ftime := 120;
//            end
//            else if Appearance in [58,60,69..74,78..80] then Dir := 0;
            if Appearance in [53..56,66..74,77..79,86..104,106,115,118..137] then Dir := 0;

            if Appearance in [33,34,52{,55..60,68..77},53..56,57..64,65,66..74,111..113,117] then begin //�ൿ ��Ǿ���, ���ֱ��Ǹ� ����
//            if Appearance = 55 then DScreen.AddChatBoardString ('Appearance = 55', clYellow, clRed);
               startframe := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip);
               endframe   := startframe + pm.ActStand.frame - 1;
               frametime  := pm.ActStand.ftime;
               starttime  := GetTickCount;
               defframecount := pm.ActStand.frame;
            end
            else if Appearance in [77..79,93] then begin
               startframe := 10;
               endframe := 19;
               frametime := pm.ActAttack.ftime;
               starttime := GetTickCount;
               defframecount := pm.ActStand.frame;
            end
            else if Appearance in [86..90] then begin
               startframe := 0;
               endframe := 9;
               frametime := 150;
               starttime := GetTickCount;
               defframecount := 9;
            end
            else if Appearance in [91,92,94..103,106,115,119..137] then begin
               startframe := 0;
               endframe := 0;
               frametime := 150;
               starttime := GetTickCount;
            end
            else if Appearance = 118 then begin
               startframe := 30;
               endframe := startframe + 21;
               frametime := 150;
               starttime := GetTickCount;
               defframecount := 21;
            end else begin
               startframe := pm.ActAttack.start + Dir * (pm.ActAttack.frame + pm.ActAttack.skip);
               endframe := startframe + pm.ActAttack.frame - 1;
//               if Appearance = 67 then endframe := startframe + 5;
               frametime := pm.ActAttack.ftime;
               starttime := GetTickCount;
               if Appearance = 51 then begin //2004/05/27 50LevelQuest �α�
                  BoUseEffect   := TRUE;
                  effectstart   := 60;
                  effectframe   := effectstart;
                  effectend     := effectstart + 7;
                  effectstarttime := GetTickCount;
                  effectframetime := 500;
               end
            end;
            if Appearance = 61 then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 240 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance = 62 then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 180 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance = 63 then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 120 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [64,65] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 60 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [66,67,69..74] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 4;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [117] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 4 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 3;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance = 92 then begin
               BoUseEffect   := TRUE;
               effectstart   := 10;
               effectframe   := effectstart;
               effectend     := effectstart + 9;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [125..127,132] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 10 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 15;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end
            else if Appearance in [129..130] then begin //������� �Ҳ�
               BoUseEffect   := TRUE;
               effectstart   := 20 + startframe;
               effectframe   := effectstart;
               effectend     := effectstart + 8;
               effectstarttime := GetTickCount;
               effectframetime := 150;
            end

//            if Appearance in [61..64] then begin //������� �Ҳ�
//               startframe := 6;
//               endframe := 7;
//               BoUseEffect   := TRUE;
//               effectstart   := 0;
//               effectframe   := 0;
//               effectend     := 4;
//               effectstarttime := GetTickCount;
//               effectframetime := 100;
//            end
//            else if Appearance = 65 then begin //��ں�
//               startframe := 8;
//               endframe := 9;
//               BoUseEffect   := TRUE;
//               effectstart   := 0;
//               effectframe   := 0;
//               effectend     := 5;
//               effectstarttime := GetTickCount;
//               effectframetime := 100;
//            end
            else if Appearance = 104 then begin //ũ��������Ʈ��
               startframe := 0;
               endframe := 19;
               frametime := 200;
               starttime := GetTickCount;
               defframecount := 19;
               BoUseEffect   := TRUE;
               effectstart   := 20;
               effectframe   := effectstart;
               effectend     := effectstart + 19;
               effectstarttime := GetTickCount;
               effectframetime := 200;
            end;
         end;
      SM_DIGUP:
         begin
            if Appearance = 52 then begin //2004/12/14 �����
               PlaySnow := True;
               SnowStartTime := GetTickCount + 23000;
               Randomize;
               SilenceSound;
               PlaySound (146+Random(7));
//   DScreen.AddChatBoardString ('����� SM_DIGUP PlaySong=> '+IntToStr(146+Random(7)), clYellow, clRed);
               BoUseEffect   := TRUE;
               effectstart   := 60;
               effectframe   := effectstart;
               effectend     := effectstart + 11;
               effectstarttime := GetTickCount;
               effectframetime := 100;
            end;
         end;
   end;
   if Appearance in [35..41,48..50,52{..55,57..65,69..74,78..80},53..56,66..74,77..79,86..104,106,115,119..137] then Dir := 0;
end;

function  TNpcActor.GetDefaultFrame (wmode: Boolean): integer;
var
   cf, dr: integer;
   pm: PTMonsterAction;
begin
   Result := 0;
   pm := RaceByPm (Race, Appearance);
   if pm = nil then exit;
   Dir := Dir mod 3;  //������ 0, 1, 2 �ۿ� ����..

   defframetick := pm.ActStand.frame;
   if Appearance in [35..41,48..50,52{..55,57..65,69..74,78..80},53..56,66..74,77..79,86..104,106,115,119..137] then Dir := 0;

   if currentdefframe < 0 then cf := 0
   else if currentdefframe >= pm.ActStand.frame then cf := 0
   else cf := currentdefframe;
   Result := pm.ActStand.start + Dir * (pm.ActStand.frame + pm.ActStand.skip) + cf;

//   if Appearance in [61..64] then begin //������� �Ҳ�
//      Result := 6;
//      BoUseEffect   := TRUE;
//   end
//   else if Appearance =65 then begin //��ں�
//      Result := 8;
//      BoUseEffect   := TRUE;
//   end
//   else if Appearance = 66 then begin  //ũ��������Ʈ��
//      Result := cf;
//      BoUseEffect   := TRUE;
//   end;
end;

procedure TNpcActor.LoadSurface;
begin
   case Race of
      //���� Npc
      50: begin
         if Appearance in [0..106] then BodySurface := WNpcImg.GetCachedImage (BodyOffset + currentframe, px, py)
         else BodySurface := WNpc2Img.GetCachedImage (BodyOffset + currentframe, px, py);
      end;
   end;

   if Appearance in [44..47{,61..65}] then begin // BodySurface �ʿ���� ���ǰ�� ����Ʈ�� �ʿ� (ž�� Object)
      BodySurface := nil;
   end;

   if BoUseEffect then begin // �ð���,ȭ�Ժ�,ž��,�ͽ�npc
      if Appearance in [33] then begin // ȭ�鿡 ��Ÿ���� ��ġ ����
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
      end
//      else if Appearance = 42 then begin// ���׾Ƹ�(��) Object�� ��ġ�� ���� �������.  FireDragon
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
//         ax := ax + 71;
//         ay := ay + 5;
//      end
//      else if Appearance = 43 then begin// ���׾Ƹ�(��)
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
//         ax := ax + 71;
//         ay := ay + 37;
//      end
      else if Appearance = 44 then begin// ž��(����)
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
         ax := ax + 7;
         ay := ay - 12;
      end
      else if Appearance = 45 then begin// ž��(���)
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
         ax := ax + 6;
         ay := ay - 12;
      end
      else if Appearance = 46 then begin// ž��(����)
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
         ax := ax + 7;
         ay := ay - 12;
      end
      else if Appearance = 47 then begin// ž��(�»�)
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
         ax := ax + 8;
         ay := ay - 12;
      end
      else if Appearance = 51 then begin// �ͽ� npc
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
      end
      else if Appearance = 52 then begin// �����
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
      end
      else if Appearance in [57..65,66,67,69..74,92] then begin// �����
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
      end
      else if Appearance in [117,125..127,129..130,132] then begin// �����
         EffectSurface := WNpc2Img.GetCachedImage (BodyOffset + effectframe, ax, ay);
//      end
//      else if Appearance = 61 then begin// ������� �Ҳ�(�»�)
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
//         ax := ax + 25;
//         ay := ay - 8;
//      end
//      else if Appearance = 62 then begin// ������� �Ҳ�(���)
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
//         ax := ax + 7;
//         ay := ay - 7;
//      end
//      else if Appearance = 63 then begin// ������� �Ҳ�(����)
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
//         ax := ax - 4;
//         ay := ay + 8;
//      end
//      else if Appearance = 64 then begin// ������� �Ҳ�(����)
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
//         ax := ax - 11;
//         ay := ay + 8;
//      end
//      else if Appearance = 65 then begin// ��ں�
//         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
      end
      else if Appearance = 104 then begin// ũ��������Ʈ��
         EffectSurface := WNpcImg.GetCachedImage (BodyOffset + effectframe, ax, ay);
      end;

   end;

end;

procedure TNpcActor.Run;
var
   prv : integer;
   effectframetimetime : longword;
begin
   inherited Run;
   // 2003/07/15 �ű� NPC �߰�
   prv := effectframe;
   if BoUseEffect then begin
      if msgmuch then effectframetimetime := Round(effectframetime * 2 / 3)
      else effectframetimetime := effectframetime;
      if GetTickCount - effectstarttime > effectframetimetime then begin
         effectstarttime := GetTickCount;
         if effectframe < effectend then begin
            Inc (effectframe);
         end else begin
            if PlaySnow then begin
               if SnowStartTime < GetTickCount then begin
                  BoUseEffect := False;
                  PlaySnow    := False;
                  SnowStartTime := GetTickCount;
               end;
               effectframe := effectstart;
            end
            else effectframe := effectstart;
            effectstarttime := GetTickCount;
         end;
      end;
   end;
   if (prv <> effectframe) then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;
end;

// 2003/07/15 �ű� NPC �߰�
procedure  TNpcActor.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   idx, ax, ay: integer;
   d: TDXTexture;
   ceff: TColorEffect;
   wimg: TWMImages;
begin
   Dir := Dir mod 3;  //������ 0, 1, 2 �ۿ� ����..
   if GetTickCount - loadsurfacetime > 60 * 1000 then begin
      loadsurfacetime := GetTickCount;
      LoadSurface;
   end;

   ceff := GetDrawEffectValue;

   if BodySurface <> nil then begin
      if Appearance = 51 then begin //�ͽ� npc
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, True, ceff);
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, True, ceff);
      end
      else if Appearance in [86..90] then begin
         DrawBlend (dsurface,
                    dx + px + ShiftX,
                    dy + py + ShiftY,
                    BodySurface, 1);
      end
      else
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, blend, ceff);
   end;
// inherited DrawChr(dsurface, dx, dy, blend);
end;

procedure TNpcActor.DrawEff (dsurface: TDXTexture; dx, dy: integer);
begin
   if BoUseEffect then
      if EffectSurface <> nil then begin
         DrawBlend (dsurface,
                    dx + ax + ShiftX,
                    dy + ay + ShiftY,
                    EffectSurface, 1);
      end;
end;


{============================== HUMActor =============================}

//            ����

{-------------------------------}


constructor THumActor.Create;
begin
   inherited Create;
   HairSurface := nil;
   WeaponSurface := nil;
   WingSurface := nil;
   WeaponEffectSurface := nil;
   BoWeaponEffect := FALSE;

   WingFrameTime := 150;
   WingStartTime := GetTickCount;
   WingCurrentFrame := 0;
   WingOffset := 0;

   WeaponEffectFrameTime := 150;
   WeaponEffectStartTime := GetTickCount;
   WeaponEffectCurrentFrame := 0;
   WeaponEffectOffset := HUMANFRAME*4;

   H50LevelEffectSurface := nil;
   H50LevelEffectFrameTime := 150;
   H50LevelEffectStartTime := GetTickCount;
   H50LevelEffectCurrentFrame := 0;
   H50LevelEffectOffset := 312;

   FoodStickDayEffectSurface := nil;
   FoodStickDayEffectSurface2 := nil;
   FoodStickDayEffectFrameTime := 120;
   FoodStickDayEffectStartTime := GetTickCount;
   FoodStickDayEffectCurrentFrame := 0;
   FoodStickDayEffectOffset := 440;
   FoodStickDayEffectOffset2 := 420;

{   HWriterEffectSurface := nil;
   HWriterEffectFrameTime := 90;
   HWriterEffectStartTime := GetTickCount;
   HWriterEffectCurrentFrame := 0;
   HWriterEffectOffset := 328;}

end;

destructor THumActor.Destroy;
begin
   inherited Destroy;
end;

procedure THumActor.CalcActorFrame;
var
   haircount: integer;
begin
   BoUseMagic := FALSE;
   BoHitEffect := FALSE;
   currentframe := -1;
   //human
   hair   := HAIRfeature (Feature);         //����ȴ�.
//   dress  := DRESSfeature (Feature); //���º��� �ʰ��������� ������ ��, �׷��� �ּ� ó��
//      DScreen.AddChatBoardString ('CalcActorFrame() dress=> '+IntToStr(dress), clYellow, clRed);
   weapon := WEAPONfeature (Feature);
   BodyOffset := HUMANFRAME * (dress); //Sex; //����0, ����1

   haircount := WHairImg.ImageCount div HUMANFRAME div 2;
   if hair > haircount-1 then hair := haircount-1;
   hair := hair * 2;
   if hair > 1 then
      HairOffset := HUMANFRAME * (hair + Sex)
   else HairOffset := -1;
   WeaponOffset := HUMANFRAME * weapon; //(weapon*2 + Sex);
   if dress = 18 then WingOffset := 0                  // �����޷�(��)
   else if dress = 19 then WingOffset := HUMANFRAME    // �����޷�(��)
   else if dress = 20 then WingOffset := HUMANFRAME*2  // õ��һ���(��)
   else if dress = 21 then WingOffset := HUMANFRAME*3 // õ��һ���(��)
   else if dress in [22,23] then WingOffset := 352; // 50������

   if weapon = 76 then WeaponEffectOffset := HUMANFRAME*4        // �İ����� ����Ʈ(��)
   else if weapon = 77 then WeaponEffectOffset := HUMANFRAME*5;  // �İ����� ����Ʈ(��)

   case CurrentAction of
      SM_TURN:
         begin
            startframe := HA.ActStand.start + Dir * (HA.ActStand.frame + HA.ActStand.skip);
            endframe := startframe + HA.ActStand.frame - 1;
            frametime := HA.ActStand.ftime;
            starttime := GetTickCount;
            defframecount := HA.ActStand.frame;
            Shift (Dir, 0, 0, endframe-startframe+1);
         end;
      SM_WALK,
      SM_BACKSTEP:
         begin
            startframe := HA.ActWalk.start + Dir * (HA.ActWalk.frame + HA.ActWalk.skip);
            endframe := startframe + HA.ActWalk.frame - 1;
            frametime := HA.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := HA.ActWalk.UseTick;
            curtick := 0;
            //WarMode := FALSE;
            movestep := 1;
            if CurrentAction = SM_BACKSTEP then
               Shift (GetBack(Dir), movestep, 0, endframe-startframe+1)
            else
               Shift (Dir, movestep, 0, endframe-startframe+1);
         end;
      SM_RUSH:
         begin
            if RushDir = 0 then begin
               RushDir := 1;
               startframe := HA.ActRushLeft.start + Dir * (HA.ActRushLeft.frame + HA.ActRushLeft.skip);
               endframe := startframe + HA.ActRushLeft.frame - 1;
               frametime := HA.ActRushLeft.ftime;
               starttime := GetTickCount;
               maxtick := HA.ActRushLeft.UseTick;
               curtick := 0;
               movestep := 1;
               Shift (Dir, 1, 0, endframe-startframe+1);
            end else begin
               RushDir := 0;
               startframe := HA.ActRushRight.start + Dir * (HA.ActRushRight.frame + HA.ActRushRight.skip);
               endframe := startframe + HA.ActRushRight.frame - 1;
               frametime := HA.ActRushRight.ftime;
               starttime := GetTickCount;
               maxtick := HA.ActRushRight.UseTick;
               curtick := 0;
               movestep := 1;
               Shift (Dir, 1, 0, endframe-startframe+1);
            end;
         end;
      SM_RUSHKUNG:
         begin
            startframe := HA.ActRun.start + Dir * (HA.ActRun.frame + HA.ActRun.skip);
            endframe := startframe + HA.ActRun.frame - 1;
            frametime := HA.ActRun.ftime;
            starttime := GetTickCount;
            maxtick := HA.ActRun.UseTick;
            curtick := 0;
            movestep := 1;
            Shift (Dir, movestep, 0, endframe-startframe+1);
         end;
      {SM_BACKSTEP:
         begin
            startframe := pm.ActWalk.start + (pm.ActWalk.frame - 1) + Dir * (pm.ActWalk.frame + pm.ActWalk.skip);
            endframe := startframe - (pm.ActWalk.frame - 1);
            frametime := pm.ActWalk.ftime;
            starttime := GetTickCount;
            maxtick := pm.ActWalk.UseTick;
            curtick := 0;
            movestep := 1;
            Shift (GetBack(Dir), movestep, 0, endframe-startframe+1);
         end;  }
      SM_SITDOWN:
         begin
            startframe := HA.ActSitdown.start + Dir * (HA.ActSitdown.frame + HA.ActSitdown.skip);
            endframe := startframe + HA.ActSitdown.frame - 1;
            frametime := HA.ActSitdown.ftime;
            starttime := GetTickCount;
         end;
      SM_RUN:
         begin
            startframe := HA.ActRun.start + Dir * (HA.ActRun.frame + HA.ActRun.skip);
            endframe := startframe + HA.ActRun.frame - 1;
            frametime := HA.ActRun.ftime;
            starttime := GetTickCount;
            maxtick := HA.ActRun.UseTick;
            curtick := 0;
            //WarMode := FALSE;
            if CurrentAction = SM_RUN then movestep := 2
            else movestep := 1;
            //movestep := 2;
            Shift (Dir, movestep, 0, endframe-startframe+1);
         end;
      SM_THROW:
         begin
            startframe := HA.ActHit.start + Dir * (HA.ActHit.frame + HA.ActHit.skip);
            endframe := startframe + HA.ActHit.frame - 1;
            frametime := HA.ActHit.ftime;
            starttime := GetTickCount;
            WarMode := TRUE;
            WarModeTime := GetTickCount;
            BoThrow := TRUE;
            Shift (Dir, 0, 0, 1);
         end;
      // 2003/03/15 �űԹ���
      SM_HIT, SM_POWERHIT, SM_LONGHIT, SM_WIDEHIT, SM_FIREHIT, SM_CROSSHIT, SM_TWINHIT:
         begin
//          DScreen.AddSysMsg (UserName +' ''s Current Action =' + IntToStr(CurrentAction));
            startframe := HA.ActHit.start + Dir * (HA.ActHit.frame + HA.ActHit.skip);
            endframe := startframe + HA.ActHit.frame - 1;
            frametime := HA.ActHit.ftime;
            starttime := GetTickCount;
            WarMode := TRUE;
            WarModeTime := GetTickCount;
            if (CurrentAction = SM_POWERHIT) then begin
               BoHitEffect := TRUE;
               MagLight := 2;
               HitEffectNumber := 1;
            end;
            if (CurrentAction = SM_LONGHIT) then begin
               BoHitEffect := TRUE;
               MagLight := 2;
               HitEffectNumber := 2;
            end;
            if (CurrentAction = SM_WIDEHIT) then begin
               BoHitEffect := TRUE;
               MagLight := 2;
               HitEffectNumber := 3;
            end;
            if (CurrentAction = SM_FIREHIT) then begin
               BoHitEffect := TRUE;
               MagLight := 2;
               HitEffectNumber := 4;
            end;
            // 2003/03/15 �űԹ���
            if (CurrentAction = SM_CROSSHIT) then begin
               BoHitEffect := TRUE;
               MagLight := 2;
               HitEffectNumber := 6;
            end;
            if (CurrentAction = SM_TWINHIT) then begin
               BoHitEffect := TRUE;
               MagLight := 2;
               HitEffectNumber := 7;
            end;

            Shift (Dir, 0, 0, 1);
         end;
      SM_HEAVYHIT:
         begin
            startframe := HA.ActHeavyHit.start + Dir * (HA.ActHeavyHit.frame + HA.ActHeavyHit.skip);
            endframe := startframe + HA.ActHeavyHit.frame - 1;
            frametime := HA.ActHeavyHit.ftime;
            starttime := GetTickCount;
            WarMode := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
         end;
      SM_BIGHIT:
         begin
            startframe := HA.ActBigHit.start + Dir * (HA.ActBigHit.frame + HA.ActBigHit.skip);
            endframe := startframe + HA.ActBigHit.frame - 1;
            frametime := HA.ActBigHit.ftime;
            starttime := GetTickCount;
            WarMode := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
         end;
      SM_SPELL:
         begin
            startframe := HA.ActSpell.start + Dir * (HA.ActSpell.frame + HA.ActSpell.skip);
            endframe := startframe + HA.ActSpell.frame - 1;
            frametime := HA.ActSpell.ftime;
            starttime := GetTickCount;
            CurEffFrame := 0;
            BoUseMagic := TRUE;
            case CurMagic.EffectNumber of
               22: begin //�ڼ�ȭ
                     MagLight := 4;  //�ڼ�ȭ
                     SpellFrame := 10; //�ڼ�ȭ�� 10 ���������� ����
                  end;
               26: begin //Ž���Ŀ�
                     MagLight := 2;
                     SpellFrame := 20;
                     frametime := frametime div 2;
                  end;
               35: begin //�������� PDS 2003-03-27
                     MagLight := 2;  //��������
                     SpellFrame := 15; //��������� 15 ���������� ����
                  end;
               43: begin // ������
                     MagLight := 2;
                     SpellFrame := 20;
                     frametime := 70;
                  end;
               44: begin // ���ļ�
                  startframe := HA.ActBigHit.start + Dir * (HA.ActBigHit.frame + HA.ActBigHit.skip);
                  endframe := startframe + HA.ActBigHit.frame - 1;
//                  frametime := HA.ActBigHit.ftime;
                  frametime := 50;   //2004/09/09 ���ļ� �ӵ� ������
                  starttime := GetTickCount;
                  MagLight := 2;
                  SpellFrame := 20;
                  SKillStartTime    := GetTickCount;
                  SKillCurrentFrame := 0;
//                  SKillFrametime    := 80;
                  SKillFrametime    := frametime;
                  BoHitEffect := TRUE;
                  HitEffectNumber := 8;
                  PlaySound (weaponsound);
                  PlaySound (s_twinhit);
                  end;
               45: begin //ȭ��⿰
                     MagLight := 2;
                     SpellFrame := 10;//23;
                     frametime := 100;//100;
                     FrmMain.UseNormalEffect (NE_FIRECIRCLE, self.XX, self.YY); // ���� ������ �����ϼ� �ְ� �Ϸ���
                  end;
               47: begin // ���°�
                     MagLight := 2;
                     SpellFrame := 10;
                     frametime := 80;
                  end;
               else begin //.....  ��ȸ����, ������ȸ, ����ǳ
                  MagLight := 2;
                  SpellFrame := DEFSPELLFRAME;
               end;
            end;
            WaitMagicRequest := GetTickCount;
            WarMode := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
         end;
      (*SM_READYFIREHIT:
         begin
            startframe := HA.ActFireHitReady.start + Dir * (HA.ActFireHitReady.frame + HA.ActFireHitReady.skip);
            endframe := startframe + HA.ActFireHitReady.frame - 1;
            frametime := HA.ActFireHitReady.ftime;
            starttime := GetTickCount;

            BoHitEffect := TRUE;
            HitEffectNumber := 4;
            MagLight := 2;

            CurGlimmer := 0;
            MaxGlimmer := 6;

            WarMode := TRUE;
            WarModeTime := GetTickCount;
            Shift (Dir, 0, 0, 1);
         end; *)
      SM_STRUCK:
         begin
            startframe := HA.ActStruck.start + Dir * (HA.ActStruck.frame + HA.ActStruck.skip);
            endframe := startframe + HA.ActStruck.frame - 1;
            frametime := struckframetime; //HA.ActStruck.ftime;
            starttime := GetTickCount;
            Shift (Dir, 0, 0, 1);

            genanicounttime := GetTickCount;
            CurBubbleStruck := 0;
         end;
      SM_NOWDEATH:
         begin
            startframe := HA.ActDie.start + Dir * (HA.ActDie.frame + HA.ActDie.skip);
            endframe := startframe + HA.ActDie.frame - 1;
            frametime := HA.ActDie.ftime;
            starttime := GetTickCount;
         end;
   end;
end;

procedure THumActor.DefaultMotion;
begin
   inherited DefaultMotion;
   if (Dress in [22,23]) and (currentframe < 536) then begin
      if GetTickCount - WingStartTime > 100 then begin
         if WingCurrentFrame < 19 then
            Inc (WingCurrentFrame)
         else begin
            if Not Bo50DressHEffect then Bo50DressHEffect := True
            else Bo50DressHEffect := False;
            WingCurrentFrame := 0;
         end;
//         DScreen.AddSysMsg ('THumActor.DefaultMotion=>(Dress in [22,23])');
         WingStartTime := GetTickCount;
      end;
      WingSurface := WEffectImg.GetCachedImage (WingOffset + WingCurrentFrame, epx, epy);
   end
   else if (Dress in [18,19,20,21]) and (currentframe < 64) then begin
      if GetTickCount - WingStartTime > WingFrametime then begin
         if WingCurrentFrame < 7 then
            Inc (WingCurrentFrame)
         else
            WingCurrentFrame := 0;
//         DScreen.AddSysMsg ('THumActor.DefaultMotion=>(Dress in [Wing])');
         WingStartTime := GetTickCount;
      end;
      WingSurface := WHumWing.GetCachedImage (WingOffset + Dir*8 + WingCurrentFrame, epx, epy);
   end;
   if currentframe > 535 then Bo50DressHEffect := False;

   if Bo50LevelEffect then begin
      if GetTickCount - H50LevelEffectStartTime > H50LevelEffectFrameTime then begin
         if H50LevelEffectCurrentFrame < 7 then
            Inc (H50LevelEffectCurrentFrame)
         else begin
            H50LevelEffectCurrentFrame := 0;
            Bo50LevelHEffect := Not Bo50LevelHEffect;
         end;
         H50LevelEffectStartTime := GetTickCount;
      end;
      H50LevelEffectSurface := WEffectImg.GetCachedImage (H50LevelEffectOffset + H50LevelEffectCurrentFrame, epx2, epy2);
   end;

   if FoodStickType > 0 then begin
      if GetTickCount - FoodStickDayEffectStartTime > FoodStickDayEffectFrameTime then begin
         if FoodStickDayEffectCurrentFrame < 14 then
            Inc (FoodStickDayEffectCurrentFrame)
         else begin
            FoodStickDayEffectCurrentFrame := 0;
         end;
         FoodStickDayEffectStartTime := GetTickCount;
      end;
      FoodStickDayEffectSurface := WEffectImg.GetCachedImage (FoodStickDayEffectOffset + FoodStickDayEffectCurrentFrame, epx3, epy3);
      FoodStickDayEffectSurface2 := WEffectImg.GetCachedImage (FoodStickDayEffectOffset2 + FoodStickDayEffectCurrentFrame, epx4, epy4);
   end;

{   if BoWriterEffect then begin
      if GetTickCount - HWriterEffectStartTime > HWriterEffectFrameTime then begin
         if HWriterEffectCurrentFrame < 9 then
            Inc (HWriterEffectCurrentFrame)
         else begin
            HWriterEffectCurrentFrame := 0;
            BoWriterHEffect := Not BoWriterHEffect;
         end;
         HWriterEffectStartTime := GetTickCount;
      end;
      HWriterEffectSurface := WEffectImg.GetCachedImage (HWriterEffectOffset + HWriterEffectCurrentFrame, epx3, epy3);
   end;}

end;

function  THumActor.GetDefaultFrame (wmode: Boolean): integer;
var
   cf, dr: integer;
   pm: PTMonsterAction;
begin
   //GlimmingMode := FALSE;
   //dr := Dress div 2;            //HUMANFRAME * (dr)
   if Death then
      Result := HA.ActDie.start + Dir * (HA.ActDie.frame + HA.ActDie.skip) + (HA.ActDie.frame - 1)
   else
   if wmode then begin
      //GlimmingMode := TRUE;
      Result := HA.ActWarMode.start + Dir * (HA.ActWarMode.frame + HA.ActWarMode.skip);
   end else begin
      defframecount := HA.ActStand.frame;
      if currentdefframe < 0 then cf := 0
      else if currentdefframe >= HA.ActStand.frame then cf := 0 //HA.ActStand.frame-1
      else cf := currentdefframe;
      Result := HA.ActStand.start + Dir * (HA.ActStand.frame + HA.ActStand.skip) + cf;
   end;
end;

procedure  THumActor.RunFrameAction (frame: integer);
var
   meff: TMapEffect;
   event: TClEvent;
   mfly: TFlyingAxe;
begin
   BoHideWeapon := FALSE;
   if CurrentAction = SM_HEAVYHIT then begin
      if (frame = 5) and (BoDigFragment) then begin
         BoDigFragment := FALSE;
         meff := TMapEffect.Create (8 * Dir, 3, XX, YY);
         meff.ImgLib := WEffectImg;
         meff.NextFrameTime := 80;
         PlaySound (s_strike_stone);
         //PlaySound (s_drop_stonepiece);
         PlayScene.EffectList.Add (meff);
         event := EventMan.GetEvent (XX, YY, ET_PILESTONES);
         if event <> nil then
            event.EventParam := event.EventParam + 1;
      end;
   end;
   if CurrentAction = SM_THROW then begin
      if (frame = 3) and (BoThrow) then begin
         BoThrow := FALSE;
         mfly := TFlyingAxe (PlayScene.NewFlyObject (self,
                          XX,
                          YY,
                          TargetX,
                          TargetY,
                          TargetRecog,
                          mtFlyAxe));
         if mfly <> nil then begin
            TFlyingAxe(mfly).ReadyFrame := 40;
            mfly.ImgLib := WMon3Img;
            mfly.FlyImageBase := FLYOMAAXEBASE;
         end;

      end;
      if frame >= 3 then
         BoHideWeapon := TRUE;
   end;
end;

procedure  THumActor.DoWeaponBreakEffect;
begin
   BoWeaponEffect := TRUE;
   CurWpEffect := 0;
end;

procedure  THumActor.Run;
   function MagicTimeOut: Boolean;
   begin
//      if self = Myself then begin
         Result := GetTickCount - WaitMagicRequest > 3000;
//      end else
//         Result := GetTickCount - WaitMagicRequest > 2000;
      if Result then
         CurMagic.ServerMagicCode := 0;
   end;
var
   prv: integer;
   frametimetime: longword;
   bofly: Boolean;
begin
   if GetTickCount - genanicounttime > 120 then begin //�ּ��Ǹ� ��... �ִϸ��̼� ȿ��
      genanicounttime := GetTickCount;
      Inc (GenAniCount);
      if GenAniCount > 100000 then GenAniCount := 0;
      Inc (CurBubbleStruck);
   end;
   if BoWeaponEffect then begin  //���� ���/�μ��� ȿ��
      if GetTickCount - wpeffecttime > 120 then begin
         wpeffecttime := GetTickCount;
         Inc (CurWpEffect);
         if CurWpEffect >= MAXWPEFFECTFRAME then
            BoWeaponEffect := FALSE;
      end;
   end;

   if (CurrentAction = SM_WALK) or
      (CurrentAction = SM_BACKSTEP) or
      (CurrentAction = SM_RUN) or
      (CurrentAction = SM_RUSH) or
      (CurrentAction = SM_RUSHKUNG)
   then exit;

   msgmuch := FALSE;
   if self <> Myself then begin
      if MsgList.Count >= 2 then msgmuch := TRUE;
   end;

   //���� ȿ��
   RunActSound (currentframe - startframe);
   RunFrameAction (currentframe - startframe);

   prv := currentframe;
   if CurrentAction <> 0 then begin
      if (currentframe < startframe) or (currentframe > endframe) then
         currentframe := startframe;

//      if (self <> Myself) and (BoUseMagic) then begin
//         frametimetime := Round(frametime / 1.8);
//      end else begin
         if msgmuch then frametimetime := Round(frametime * 2 / 3)
         else frametimetime := frametime; //2004/04/07 �ӵ����� ����
//      end;

      if GetTickCount - starttime > frametimetime then begin
         if currentframe < endframe then begin

            //������ ��� ������ ��ȣ�� �޾�, ����/���и� Ȯ������
            //������������ ������.
            if BoUseMagic then begin
               if (CurEffFrame = SpellFrame-2) or (MagicTimeOut) then begin //��ٸ� ��
                  if (CurMagic.ServerMagicCode >= 0) or (MagicTimeOut) then begin //������ ���� ���� ���. ���� �ȿ����� ��ٸ�
                     Inc (currentframe);
                     Inc(CurEffFrame);
                     starttime := GetTickCount;
                  end;
               end else begin
                  if currentframe < endframe - 1 then Inc (currentframe);
                  Inc (CurEffFrame);
                  starttime := GetTickCount;
               end;
            end else begin
               Inc (currentframe);
               starttime := GetTickCount;
            end;

         end else begin
            if self = Myself then begin
               if FrmMain.ServerAcceptNextAction then begin
                  CurrentAction := 0;
                  BoUseMagic := FALSE;
               end;
            end else begin
               CurrentAction := 0; //���� �Ϸ�
               BoUseMagic := FALSE;
            end;
            BoHitEffect := FALSE;
         end;
         if BoUseMagic then begin
            if CurEffFrame = SpellFrame-1 then begin //���� �߻� ����
               //���� �߻�
               if CurMagic.ServerMagicCode > 0 then begin
                  with CurMagic do
                     PlayScene.NewMagic (self,
                                      ServerMagicCode,
                                      EffectNumber,
                                      XX,
                                      YY,
                                      TargX,
                                      TargY,
                                      Target,
                                      EffectType,
                                      Recusion,
                                      AniTime,
                                      bofly);
                  if bofly then
                     PlaySound (magicfiresound)
                  else
                     PlaySound (magicexplosionsound);
               end;
               if self = Myself then
                  LatestSpellTime := GetTickCount;
               CurMagic.ServerMagicCode := 0;
            end;
         end;

      end;
      if Race = 0 then currentdefframe := 0
      else currentdefframe := -10;
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

function   THumActor.Light: integer;
var
   l: integer;
begin
   l := ChrLight;
   if l < MagLight then begin
      if BoUseMagic or BoHitEffect then
         l := MagLight;
   end;
   Result := l;
end;

procedure  THumActor.LoadSurface;
begin
   BodySurface := WHumImg.GetCachedImage (BodyOffset + currentframe, px, py);
   if HairOffset >= 0 then
      HairSurface := WHairImg.GetCachedImage (HairOffset + currentframe, hpx, hpy)
   else HairSurface := nil;
   if (Dress in [22,23]) and (currentframe < 536) then begin
      if GetTickCount - WingStartTime > 100 then begin
         if WingCurrentFrame < 19 then
            Inc (WingCurrentFrame)
         else begin
            if Not Bo50DressHEffect then Bo50DressHEffect := True
            else Bo50DressHEffect := False;
            WingCurrentFrame := 0;
         end;

//         DScreen.AddSysMsg ('SF=>'+ IntToStr(Dir*8)+' CF=>'+ IntToStr(WingCurrentFrame)+' THumActor');
         WingStartTime := GetTickCount;
      end;
      WingSurface := WEffectImg.GetCachedImage (WingOffset + WingCurrentFrame, epx, epy);
   end
   else if (Dress in [18,19,20,21]) and (currentframe < 64) then begin
      if GetTickCount - WingStartTime > WingFrametime then begin
         if WingCurrentFrame < 7 then
            Inc (WingCurrentFrame)
         else
            WingCurrentFrame := 0;
//         DScreen.AddSysMsg ('SF=>'+ IntToStr(Dir*8)+' CF=>'+ IntToStr(WingCurrentFrame)+' THumActor');
         WingStartTime := GetTickCount;
      end;
      WingSurface := WHumWing.GetCachedImage (WingOffset + Dir*8 + WingCurrentFrame, epx, epy)
   end
   else if Dress in [18,19,20,21] then
      WingSurface := WHumWing.GetCachedImage (WingOffset + currentframe, epx, epy);

   if currentframe > 535 then Bo50DressHEffect := False;

   if Bo50LevelEffect then begin
      if GetTickCount - H50LevelEffectStartTime > H50LevelEffectFrameTime then begin
         if H50LevelEffectCurrentFrame < 7 then
            Inc (H50LevelEffectCurrentFrame)
         else begin
            H50LevelEffectCurrentFrame := 0;
            Bo50LevelHEffect := Not Bo50LevelHEffect;
         end;
         H50LevelEffectStartTime := GetTickCount;
      end;
      H50LevelEffectSurface := WEffectImg.GetCachedImage (H50LevelEffectOffset + H50LevelEffectCurrentFrame, epx2, epy2);
   end;

   if FoodStickType > 0 then begin
      if GetTickCount - FoodStickDayEffectStartTime > FoodStickDayEffectFrameTime then begin
         if FoodStickDayEffectCurrentFrame < 14 then
            Inc (FoodStickDayEffectCurrentFrame)
         else begin
            FoodStickDayEffectCurrentFrame := 0;
         end;
         FoodStickDayEffectStartTime := GetTickCount;
      end;
      FoodStickDayEffectSurface := WEffectImg.GetCachedImage (FoodStickDayEffectOffset + FoodStickDayEffectCurrentFrame, epx3, epy3);
      FoodStickDayEffectSurface2 := WEffectImg.GetCachedImage (FoodStickDayEffectOffset2 + FoodStickDayEffectCurrentFrame, epx4, epy4);
   end;

{   if (Weapon in [76,77]) and (currentframe < 64) then begin
      if GetTickCount - WeaponEffectStartTime > WeaponEffectFrametime then begin
         if WeaponEffectCurrentFrame < 7 then
            Inc (WeaponEffectCurrentFrame)
         else
            WeaponEffectCurrentFrame := 0;
//         DScreen.AddSysMsg ('THumActor.DefaultMotion=>(Dress in [Wing])');
         WeaponEffectStartTime := GetTickCount;
      end;
      WeaponEffectSurface := WHumWing.GetCachedImage (WeaponEffectOffset + Dir*8 + WeaponEffectCurrentFrame, wpx2, wpy2);
   end;}

{   if BoWriterEffect then begin
      if GetTickCount - HWriterEffectStartTime > HWriterEffectFrameTime then begin
         if HWriterEffectCurrentFrame < 9 then
            Inc (HWriterEffectCurrentFrame)
         else begin
            HWriterEffectCurrentFrame := 0;
            BoWriterHEffect := Not BoWriterHEffect;
         end;
         HWriterEffectStartTime := GetTickCount;
      end;
      HWriterEffectSurface := WEffectImg.GetCachedImage (HWriterEffectOffset + HWriterEffectCurrentFrame, epx3, epy3);
   end;}

   WeaponSurface := WWeapon.GetCachedImage (WeaponOffset + currentframe, wpx, wpy);
   WeaponEffectSurface := WHumWing.GetCachedImage (WeaponEffectOffset + currentframe, wpx2, wpy2);

end;

procedure  THumActor.DrawChr (dsurface: TDXTexture; dx, dy: integer; blend: Boolean; WingDraw: Boolean );
var
   idx, ax, ay: integer;
   d: TDXTexture;
   ceff: TColorEffect;
   wimg: TWMImages;
begin
   if not (Dir in [0..7]) then exit;
   if GetTickCount - loadsurfacetime > 60 * 1000 then begin
      loadsurfacetime := GetTickCount;
      LoadSurface; //bodysurface���� loadsurface�� �ٽ� �θ��� �ʾ� �޸𸮰� �����Ǵ� ���� ����
   end;

   ceff := GetDrawEffectValue;


   if Race = 0 then begin
      if (currentframe >= 0) and (currentframe <= 599) then
         wpord := WORDER[Sex, currentframe];

// 2�� ��� --------------------------------------------------------------------
      if Dress in [18,19,20,21] then
      begin

        if self = Myself then
        begin
           if blend then
              if ((Dir = DR_DOWN ) or (Dir = DR_DOWNRIGHT) or (Dir = DR_DOWNLEFT )) and (WingSurface <> nil)
                   and (not WingDraw) then
                    DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1)
           else
              if ((Dir = DR_DOWN ) or (Dir = DR_DOWNRIGHT) or (Dir = DR_DOWNLEFT )) and (WingSurface <> nil)
                   and WingDraw then
                    DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1);
        end
        else
        begin
           if ((FocusCret <> nil) or (MagicTarget <> nil)) and blend and
               ((Dir = DR_DOWN ) or (Dir = DR_DOWNRIGHT) or (Dir = DR_DOWNLEFT )) and (WingSurface <> nil)
                   and (not WingDraw) then
                    DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1)
           else if ((Dir = DR_DOWN ) or (Dir = DR_DOWNRIGHT) or (Dir = DR_DOWNLEFT )) and (WingSurface <> nil)
                and WingDraw then
                DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1);
        end;

      end;

// 2�� ��� --------------------------------------------------------------------

      if (wpord = 0) and (not blend) and (Weapon >= 2) and (WeaponSurface <> nil) and (not BoHideWeapon) then begin
         DrawEffSurface (dsurface, WeaponSurface, dx + wpx + ShiftX, dy + wpy + ShiftY, blend, ceNone);  //Į�� ���� �Ⱥ���
         if Weapon in [76,77] then
            DrawBlend (dsurface, dx + wpx2 + ShiftX, dy + wpy2 + ShiftY, WeaponEffectSurface, 1);
      end;

      //���� �׸���
      if BodySurface <> nil then
         DrawEffSurface (dsurface, BodySurface, dx + px + ShiftX, dy + py + ShiftY, blend, ceff);
      if Not (Dress in [24,25]) then
         if HairSurface <> nil then
            DrawEffSurface (dsurface, HairSurface, dx + hpx + ShiftX, dy + hpy + ShiftY, blend, ceff);

      //���̴� ������ ���� ��,�Ӹ�,���⸦ �׸��� ������ �޶�����.
      if (wpord = 1) and {(not blend) and} (Weapon >= 2) and (WeaponSurface <> nil) and (not BoHideWeapon) then begin
         DrawEffSurface (dsurface, WeaponSurface, dx + wpx + ShiftX, dy + wpy + ShiftY, blend, ceNone);
         if Weapon in [76,77] then
            DrawBlend (dsurface, dx + wpx2 + ShiftX, dy + wpy2 + ShiftY, WeaponEffectSurface, 1);
      end;

// 2����� ---------------------------------------------------------------------
      if Dress in [18,19,20,21] then
      begin

        if self = Myself then
        begin
           if blend then
             if ((Dir = DR_UP ) or (Dir = DR_UPLEFT) or (Dir = DR_UPRIGHT ) or (Dir = DR_LEFT) or (Dir = DR_RIGHT ))
                   and (WingSurface <> nil) and (not WingDraw) then
                    DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1)
           else
              if ((Dir = DR_UP ) or (Dir = DR_UPLEFT) or (Dir = DR_UPRIGHT ) or (Dir = DR_LEFT) or (Dir = DR_RIGHT ))
                   and (WingSurface <> nil) and WingDraw then
                    DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1);
        end
        else
        begin
           if ((FocusCret <> nil) or (MagicTarget <> nil)) and
               ((Dir = DR_UP ) or (Dir = DR_UPLEFT) or (Dir = DR_UPRIGHT ) or (Dir = DR_LEFT) or (Dir = DR_RIGHT ))
                   and (WingSurface <> nil) and (not WingDraw) then
                    DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1)
           else if ((Dir = DR_UP ) or (Dir = DR_UPLEFT) or (Dir = DR_UPRIGHT ) or (Dir = DR_LEFT) or (Dir = DR_RIGHT ))
                and (WingSurface <> nil) and WingDraw then
                 DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1);
        end;

      end;

// 2����� ---------------------------------------------------------------------

      // 50������ ����Ʈ
      if (Dress in [22,23] )and Bo50DressHEffect and (WingSurface <> nil) then
         DrawBlend (dsurface, dx + epx + ShiftX, dy + epy + ShiftY, WingSurface, 1);

      // 50Level Effect
      if (Bo50LevelEffect) and (Bo50LevelHEffect) then
         DrawBlend (dsurface, dx + epx2 + ShiftX, dy + epy2 + ShiftY, H50LevelEffectSurface, 1);

      // Writer Effect
//      if (BoWriterEffect) and (BoWriterHEffect) then
//         DrawBlend (dsurface, dx + epx3 + ShiftX, dy + epy3 + ShiftY, HWriterEffectSurface, 1);

      //�ּ��Ǹ��� ���
      if State and $00100000{STATE_BUBBLEDEFENCEUP} <> 0 then begin  //�ּ��Ǹ�
         if (CurrentAction = SM_STRUCK) and (CurBubbleStruck < 3) then
            idx := MAGBUBBLESTRUCKBASE + CurBubbleStruck
         else
            idx := MAGBUBBLEBASE + (GenAniCount mod 3);
         d := WMagic.GetCachedImage (idx, ax, ay);
         if d <> nil then
            DrawBlend (dsurface,
                             dx + ax + ShiftX,
                             dy + ay + ShiftY,
                             d, 1);
      end;

      //---�����ε��� �̺�Ʈ------------------------------------------------------------------------------
      FoodStickType := 0;
      if RecogId = Myself.RecogId then begin
      if (UseItems[U_RIGHTHAND].S.Name <> '') and (UseItems[U_RIGHTHAND].S.Looks = 863) and CouplePower then begin
         FoodStickType := 3;
         FoodStickDayEffectOffset  := 550;
         FoodStickDayEffectOffset2 := 530;
         BoFoodStickDayEffect := True;
         FoodStickDayEffectFrameTime := 100;
         if FoodStickDayEffectSurface <> nil then
            DrawBlend (dsurface, dx + epx3 + ShiftX, dy + epy3 + ShiftY, FoodStickDayEffectSurface, 1);
         if FoodStickDayEffectSurface2 <> nil then
            dsurface.Draw (dx + epx4 + ShiftX, dy + epy4 + ShiftY, FoodStickDayEffectSurface2.ClientRect, FoodStickDayEffectSurface2, TRUE);
      end
      else if (UseItems[U_RIGHTHAND].S.Name <> '') and (UseItems[U_RIGHTHAND].S.Looks = 863) then begin
         FoodStickType := 1;
         if MySelf.Sex = 0 then begin
            FoodStickDayEffectOffset  := 490;
            FoodStickDayEffectOffset2 := 470;
         end
         else begin
            FoodStickDayEffectOffset  := 510;
            FoodStickDayEffectOffset2 := 470;
         end;
         BoFoodStickDayEffect := True;
         FoodStickDayEffectFrameTime := 100;
         if FoodStickDayEffectSurface <> nil then
            DrawBlend (dsurface, dx + epx3 + ShiftX, dy + epy3 + ShiftY, FoodStickDayEffectSurface, 1);
         if FoodStickDayEffectSurface2 <> nil then
            dsurface.Draw (dx + epx4 + ShiftX, dy + epy4 + ShiftY, FoodStickDayEffectSurface2.ClientRect, FoodStickDayEffectSurface2, TRUE);
      end
      else if (UseItems[U_RIGHTHAND].S.Name <> '') and (UseItems[U_RIGHTHAND].S.Looks = 918) then begin
         FoodStickType := 2;
         FoodStickDayEffectOffset  := 440;
         FoodStickDayEffectOffset2 := 420;
         BoFoodStickDayEffect := True;
         FoodStickDayEffectFrameTime := 120;
         if FoodStickDayEffectSurface <> nil then
            DrawBlend (dsurface, dx + epx3 + ShiftX, dy + epy3 + ShiftY, FoodStickDayEffectSurface, 1);
         if FoodStickDayEffectSurface2 <> nil then
            dsurface.Draw (dx + epx4 + ShiftX, dy + epy4 + ShiftY, FoodStickDayEffectSurface2.ClientRect, FoodStickDayEffectSurface2, TRUE);
//               DrawEffSurface (dsurface, FoodStickDayEffectSurface2, dx + epx4 + ShiftX, dy + epy4 + ShiftY, blend, ceNone);
      end;
      end;
//      else FoodStickType := 0;
      //-------------------------------------------------------------------------------------------------

   end;

   if BoHitEffect and (HitEffectNumber = 8) then begin
   end else begin
   if BoUseMagic {and (EffDir[Dir] = 1)} and (CurMagic.EffectNumber > 0) then begin
      if CurEffFrame in [0..SpellFrame-1] then begin
         GetEffectBase (CurMagic.EffectNumber-1, 0, wimg, idx);
         idx := idx + CurEffFrame;
         if wimg <> nil then
            d := wimg.GetCachedImage (idx, ax, ay);
         if d <> nil then
            DrawBlend (dsurface,
                             dx + ax + ShiftX,
                             dy + ay + ShiftY,
                             d, 1);
      end;
   end;
   end;

   // ���ļ� ���� ó��
   if BoHitEffect and (HitEffectNumber = 8) then begin
      if GetTickCount - SKillStartTime > SKillFrametime then begin
         if SKillCurrentFrame < (14) then
            Inc (SKillCurrentFrame)
         else begin
            SKillCurrentFrame := 0;
            BoHitEffect := False;
         end;
         SKillStartTime := GetTickCount;
      end;
      idx := Dir*20;
      wimg := WMagic2;
      if wimg <> nil then
         d := wimg.GetCachedImage ((740+idx) + SKillCurrentFrame, ax, ay);
//      DScreen.AddChatBoardString ('SKillCurrentFrame=>'+IntToStr(SKillCurrentFrame), clYellow, clRed);
      if d <> nil then
         DrawBlend (dsurface,
                          dx + ax + ShiftX,
                          dy + ay + ShiftY,
                          d, 1);
   end
   //�˹� ȿ��
   else if BoHitEffect and (HitEffectNumber > 0) then begin
      GetEffectBase (HitEffectNumber-1, 1, wimg, idx);
      idx := idx + Dir*10 + (currentframe-startframe);
      if wimg <> nil then
         d := wimg.GetCachedImage (idx, ax, ay);
      if d <> nil then
         DrawBlend (dsurface,
                          dx + ax + ShiftX,
                          dy + ay + ShiftY,
                          d, 1);
   end;

   //���� �԰� ���� ȿ��
   //if BoEatEffect then begin
   //   if GetTickCount - EatEffectTime > 70 then begin
   //      EatEffectTime := GetTickCount;
   //      Inc (EatEffectFrame);
   //   end;
   //   if EatEffectFrame >= 6 then begin
   //      BoEatEffect := FALSE;
   //      EatEffectFrame := 0;
   //   end;
   //
   //   d := WEffectImg.GetCachedImage (296 + EatEffectFrame, ax, ay);
   //   if d <> nil then
   //      DrawBlend (dsurface,
   //                       dx + ax + ShiftX,
   //                       dy + ay + ShiftY,
   //                       d, 1);
   //end;

   //���� ���/�μ��� ȿ��
   if BoWeaponEffect then begin
      idx := WPEFFECTBASE + Dir*10 + CurWpEffect;
      d := WMagic.GetCachedImage (idx, ax, ay);
      if d <> nil then
         DrawBlend (dsurface,
                     dx + ax + ShiftX,
                     dy + ay + ShiftY,
                     d, 1);
   end;

end;

end.








