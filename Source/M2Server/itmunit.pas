unit itmunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  D7ScktComp, syncobjs, MudUtil, HUtil32, Grobal2, Math;

type
   TItemUnit = class
   private
   public
      function  GetUpgrade (count, ran: integer): integer;
      function  GetUpgrade2 (x, a: integer): integer;
      procedure UpgradeRandomWeapon (pu: PTUserItem); //���⸦ �����ϰ� ���׷��̵� �Ѵ�.
      procedure UpgradeRandomDress (pu: PTUserItem);  //���� �����ϰ� ���׷��̵���.
      procedure UpgradeRandomNecklace (pu: PTUserItem);
      procedure UpgradeRandomBarcelet (pu: PTUserItem);
      procedure UpgradeRandomNecklace19 (pu: PTUserItem);
      procedure UpgradeRandomRings (pu: PTUserItem);
      procedure UpgradeRandomRings23 (pu: PTUserItem);
      procedure UpgradeRandomHelmet (pu: PTUserItem);

      procedure RandomSetUnknownHelmet (pu: PTUserItem);
      procedure RandomSetUnknownRing (pu: PTUserItem);
      procedure RandomSetUnknownBracelet (pu: PTUserItem);

      function GetUpgradeStdItem (ui: TUserItem; var std: TStdItem):integer;

      //���� ��ȯ �Լ�
      function RealAttackSpeed( wAtkSpd: WORD ): integer;   //-10~15�� ���� ���� ���� ����
      function NaturalAttackSpeed( iAtkSpd: integer ): WORD;   //0 �̻��� ���� ���� ���Ӱ�
      function GetAttackSpeed( bStdAtkSpd, bUserAtkSpd: BYTE ): BYTE;
      function UpgradeAttackSpeed( bUserAtkSpd: BYTE; iUpValue: integer ): BYTE;

   end;

implementation

uses
   svMain;


function  TItemUnit.GetUpgrade (count, ran: integer): integer;
var
   i: integer;
begin
   Result := 0;
   for i:=0 to count-1 do begin
      if Random(ran) = 0 then Result := Result + 1
      else break;
   end;
end;

function  TItemUnit.GetUpgrade2 (x, a: integer): integer;
var
   i: integer;
   iProb : integer;
begin
   Result := 0;
//   Result := Trunc(Sqrt(10000 - Power(x+a, 2)) / (100 + Power(x, 2)));
//   iProb := Trunc((Sqrt(10000 - Power(x+a, 2)) / (100 + Power(x, 2))) * 100);
   for i:=x downto 1 do begin
      if i > x div 2 then begin
         //Ȯ���� ���� �� ����
         iProb := Trunc((Sqrt(Power(a, 2) - Power(i, 2)) / (a * i + Power(i, 2))) * 100);
      end else begin
         //Ȯ���� ���� �� ����
         iProb := Trunc( (Sqrt(1 - (Power(i, 2) / Power(a, 2))) * 100) / sqrt(i) );
      end;
        if Random(650) < iProb then begin        //����װ����Ʒ���ʣ�����ԽС����Խ��  ԭ����500
         Result := i{x} div 3;
         break;
      end;
   end;

{
   Result := 0;
//   Result := Trunc(Sqrt(10000 - Power(x+a, 2)) / (100 + Power(x, 2)));
//   iProb := Trunc((Sqrt(10000 - Power(x+a, 2)) / (100 + Power(x, 2))) * 100);
   for i:=x downto 1 do begin
      iProb := Trunc((Sqrt(Power(a, 2) - Power(x, 2)) / (a * x + Power(x, 2))) * 100);
      if Random(100) < iProb then begin
//         Result := x div 3;
         Result := i div 3;
         break;
      end;
   end;
}
end;

//�Ķ���� pu�� �ݵ�� �����̴�.
//TUserItem�� Desc�� ���׷��̵� �� 0:DC 1:MC 2:SC
procedure TItemUnit.UpgradeRandomWeapon (pu: PTUserItem);
var
   up, n, i, incp: integer;
begin
   //�ı� �ɼ�
   up := GetUpgrade (12, 15);
   if Random(15) = 0 then pu.Desc[0] := 1+up; //DC

   //���ݼӵ�
   up := GetUpgrade (12, 15);
   if Random(20) = 0 then begin  //���� �ӵ�
      incp := (1+up) div 3;  //�� �� �ٵ���
      if incp > 0 then begin
         if Random(3) <> 0 then  pu.Desc[6] := incp  //���ݼӵ� (-)
         else pu.Desc[6] := 10 + incp;  //���ݼӵ� (+)
      end;
   end;

   //����
   up := GetUpgrade (12, 15);
   if Random(15) = 0 then pu.Desc[1] := 1+up; //MC

   //����
   up := GetUpgrade (12, 15);
   if Random(15) = 0 then pu.Desc[2] := 1+up; //SC

   //��Ȯ
   up := GetUpgrade (12, 15);
   if Random(24) = 0 then pu.Desc[5] := 1 + (up div 2); //��Ȯ(+)

   //����
   up := GetUpgrade (12, 12);
   if Random(3) < 2 then begin
      n := (1+up)*2000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;

   //����
   up := GetUpgrade (12, 15);
   if Random(10) = 0 then
      pu.Desc[7] := 1 + (up div 2); //������ �ܴ��� ����

end;

procedure TItemUnit.UpgradeRandomDress (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //���
   up := GetUpgrade (6, 15);
   if Random(30) = 0 then pu.Desc[0] := 1+up; //AC

   //����
   up := GetUpgrade (6, 15);
   if Random(30) = 0 then pu.Desc[1] := 1+up; //MAC

   //�ı�
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 10);
   if Random(8) < 6 then begin
      n := (1+up)*2000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;


procedure TItemUnit.UpgradeRandomNecklace (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //��Ȯ
   up := GetUpgrade (6, 30);
   if Random(60) = 0 then pu.Desc[0] := 1+up; //AC(HIT)

   //��ø
   up := GetUpgrade (6, 30);
   if Random(60) = 0 then pu.Desc[1] := 1+up; //MAC(SPEED)

   //�ı�
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 12);
   if Random(20) < 15 then begin  //����
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;

procedure TItemUnit.UpgradeRandomBarcelet (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //���
   up := GetUpgrade (6, 20);
   if Random(20) = 0 then pu.Desc[0] := 1+up; //AC

   //����
   up := GetUpgrade (6, 20);
   if Random(20) = 0 then pu.Desc[1] := 1+up; //MAC

   //�ı�
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 12);
   if Random(20) < 15 then begin  //����
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;

procedure TItemUnit.UpgradeRandomNecklace19 (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //����ȸ��
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[0] := 1+up; //����ȸ��

   //���
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[1] := 1+up; //���

   //�ı�
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 10);
   if Random(4) < 3 then begin //������ ���׷��̵�
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;

procedure TItemUnit.UpgradeRandomRings (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //�ı�
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 12);
   if Random(4) < 3 then begin //������ ���׷��̵�
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;

procedure TItemUnit.UpgradeRandomRings23 (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //�ߵ�����
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[0] := 1+up; //�ߵ�����

   //�ߵ�ȸ��
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[1] := 1+up; //�ߵ�ȸ��

   //�ı�
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 12);
   if Random(4) < 3 then begin
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;

procedure TItemUnit.UpgradeRandomHelmet (pu: PTUserItem);
var
   i, n, up: integer;
begin
   //���
   up := GetUpgrade (6, 20);
   if Random(40) = 0 then pu.Desc[0] := 1+up; //AC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[1] := 1+up; //MAC

   //�ı�
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[2] := 1+up; //DC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[3] := 1+up; //MC

   //����
   up := GetUpgrade (6, 20);
   if Random(30) = 0 then pu.Desc[4] := 1+up; //SC

   //����
   up := GetUpgrade (6, 12);
   if Random(4) < 3 then begin
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;
end;

//-------------------------------------------------------------
// ������ ������ (����)

//����
procedure TItemUnit.RandomSetUnknownHelmet (pu: PTUserItem);
var
   i, n, up, sum: integer;
begin
   //���
//   up := GetUpgrade (4, 3) + GetUpgrade (4, 8) + GetUpgrade (4, 20);
   up := GetUpgrade2 (12, 13) + GetUpgrade2 (9, 10);
   if up > 0 then pu.Desc[0] := up; //AC
   sum := up;

   //����
//   up := GetUpgrade (4, 3) + GetUpgrade (4, 8) + GetUpgrade (4, 20);
   up := GetUpgrade2 (9, 10);
   if up > 0 then pu.Desc[1] := up; //MAC
   sum := sum + up;

   //�ı�
//   up := GetUpgrade (3, 15) + GetUpgrade (3, 30);
   up := GetUpgrade2 (6, 7);
   if up > 0 then pu.Desc[2] := up; //DC
   sum := sum + up;

   //����
//   up := GetUpgrade (3, 15) + GetUpgrade (3, 30);
   up := GetUpgrade2 (6, 7);
   if up > 0 then pu.Desc[3] := up; //MC
   sum := sum + up;

   //����
//   up := GetUpgrade (3, 15) + GetUpgrade (3, 30);
   up := GetUpgrade2 (6, 7);
   if up > 0 then pu.Desc[4] := up; //SC
   sum := sum + up;

   //����
   up := GetUpgrade (6, 30);
   if up > 0 then begin
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;

   //�������� �ʴ� ������
   if Random(30) = 0 then
      pu.Desc[7] := 1;  //�������� �ʴ� �Ӽ�
   pu.Desc[8] := 1;  //������ �Ӽ�

   //���� �ʿ�ġ�� ����
   if sum >= 3 then begin
      if (pu.Desc[0] >= 5) then begin //�� ŭ
         pu.Desc[5] := 1; //����
         pu.Desc[6] := 25 + pu.Desc[0] * 3;
         exit;
      end;
      if (pu.Desc[2] >= 2) then begin //�ı��� ŭ
         pu.Desc[5] := 1; //����
         pu.Desc[6] := 35 + pu.Desc[2] * 4;
         exit;
      end;
      if (pu.Desc[3] >= 2) then begin //���� ŭ
         pu.Desc[5] := 2; //�ʸ�
         pu.Desc[6] := 18 + pu.Desc[3] * 2;
         exit;
      end;
      if (pu.Desc[4] >= 2) then begin //���� ŭ
         pu.Desc[5] := 3; //�ʵ�
         pu.Desc[6] := 18 + pu.Desc[4] * 2;
         exit;
      end;
      pu.Desc[6] := 18 + sum * 2;
   end;
end;

//������ ������ (����)

procedure TItemUnit.RandomSetUnknownRing (pu: PTUserItem);
var
   i, n, up, sum: integer;
begin
   //�ı�
//   up := GetUpgrade (3, 4) + GetUpgrade (3, 8) + GetUpgrade (6, 20);
   up := GetUpgrade2 (12, 13) + GetUpgrade2 (12, 13);
   if up > 0 then pu.Desc[2] := up; //DC
   sum := up;

   //����
//   up := GetUpgrade (3, 4) + GetUpgrade (3, 8) + GetUpgrade (6, 20);
   up := GetUpgrade2 (12, 13) + GetUpgrade2 (12, 13);
   if up > 0 then pu.Desc[3] := up; //MC
   sum := sum + up;

   //����
//   up := GetUpgrade (3, 4) + GetUpgrade (3, 8) + GetUpgrade (6, 20);
   up := GetUpgrade2 (12, 13) + GetUpgrade2 (9, 10);
   if up > 0 then pu.Desc[4] := up; //SC
   sum := sum + up;

   //����
   up := GetUpgrade (6, 30);
   if up > 0 then begin //������ ���׷��̵�
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;

   //�������� �ʴ� ������
   if Random(30) = 0 then
      pu.Desc[7] := 1;  //�������� �ʴ� �Ӽ�
   pu.Desc[8] := 1;  //������ �Ӽ�

   //���� �ʿ�ġ�� ����
   if sum >= 3 then begin
      if (pu.Desc[2] >= 3) then begin //�ı��� ŭ
         pu.Desc[5] := 1; //����
         pu.Desc[6] := 25 + pu.Desc[2] * 3;
         exit;
      end;
      if (pu.Desc[3] >= 3) then begin //���°� ŭ
         pu.Desc[5] := 2; //�ʸ�
         pu.Desc[6] := 18 + pu.Desc[3] * 2;
         exit;
      end;
      if (pu.Desc[4] >= 3) then begin //���°� ŭ
         pu.Desc[5] := 3; //�ʵ�
         pu.Desc[6] := 18 + pu.Desc[4] * 2;
         exit;
      end;
      pu.Desc[6] := 18 + sum * 2;
   end;
end;

//������ ������ ����

procedure TItemUnit.RandomSetUnknownBracelet (pu: PTUserItem);
var
   i, n, up, sum: integer;
begin
   //���
//   up := GetUpgrade (3, 5) + GetUpgrade (5, 20);
   up := GetUpgrade2 (12, 13);
   if up > 0 then pu.Desc[0] := up; //AC
   sum := up;

   //����
//   up := GetUpgrade (3, 5) + GetUpgrade (5, 20);
   up := GetUpgrade2 (9, 10);
   if up > 0 then pu.Desc[1] := up; //MAC
   sum := sum + up;

   //�ı�
//   up := GetUpgrade (3, 15) + GetUpgrade (5, 30);
   up := GetUpgrade2 (6, 7) + GetUpgrade2 (6, 7);
   if up > 0 then pu.Desc[2] := up; //DC
   sum := sum + up;

   //����
//   up := GetUpgrade (3, 15) + GetUpgrade (5, 30);
   up := GetUpgrade2 (6, 7) + GetUpgrade2 (6, 7);
   if up > 0 then pu.Desc[3] := up; //MC
   sum := sum + up;

   //����
//   up := GetUpgrade (3, 15) + GetUpgrade (5, 30);
   up := GetUpgrade2 (6, 7) + GetUpgrade2 (6, 7);
   if up > 0 then pu.Desc[4] := up; //SC
   sum := sum + up;

   //����
   up := GetUpgrade (6, 30);
   if up > 0 then begin  //����
      n := (1+up)*1000;
      pu.DuraMax := _MIN(65000, integer(pu.DuraMax) + n);
      pu.Dura := _MIN(65000, integer(pu.Dura) + n);
   end;

   //�������� �ʴ� ������
   if Random(30) = 0 then
      pu.Desc[7] := 1;  //�������� �ʴ� �Ӽ�
   pu.Desc[8] := 1;  //������ �Ӽ�

   //���� �ʿ�ġ�� ����
   if sum >= 2 then begin
      if (pu.Desc[0] >= 3) then begin //�� ŭ
         pu.Desc[5] := 1; //����
         pu.Desc[6] := 25 + pu.Desc[0] * 3;
         exit;
      end;
      if (pu.Desc[2] >= 2) then begin //�ı��� ŭ
         pu.Desc[5] := 1; //����
         pu.Desc[6] := 30 + pu.Desc[2] * 3;
         exit;
      end;
      if (pu.Desc[3] >= 2) then begin //���°� ŭ
         pu.Desc[5] := 2; //�ʸ�
         pu.Desc[6] := 20 + pu.Desc[3] * 2;
         exit;
      end;
      if (pu.Desc[4] >= 2) then begin //���°� ŭ
         pu.Desc[5] := 3; //�ʵ�
         pu.Desc[6] := 20 + pu.Desc[4] * 2;
         exit;
      end;
      pu.Desc[6] := 18 + sum * 2;
   end;
end;


//���׷��̵� ���� ������ stditem���� ����
//std + pu = std
function TItemUnit.GetUpgradeStdItem (ui: TUserItem; var std: TStdItem) : integer;
var
   UCount  : integer;
begin
   UCount := 0;
   case std.StdMode of
      5,6: //����
      begin
         std.DC := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[0]));
         std.MC := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[1]));
         std.SC := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[2]));
         //3:���, 4:����, 5:��Ȯ, 6:���ݼӵ�
         std.AC := MakeWord (Lobyte(std.AC) + ui.Desc[3], Hibyte(std.AC) + ui.Desc[5]);  //���, ��Ȯ
         std.MAC:= MakeWord (Lobyte(std.MAC) + ui.Desc[4], Hibyte(std.MAC));  //����

         //���Ӱ��� ����.
         std.MAC:= MAKEWORD( LOBYTE(std.MAC), GetAttackSpeed( HIBYTE(std.MAC), ui.Desc[6] ) );

{
         //������ 10���� ���� ���� ���� ó��.
         if HiByte(std.MAC) > 10 then begin
            std.Mac:= MakeWord (Lobyte(std.MAC), Hibyte(std.MAC) + ui.Desc[6]);  //���ݼӵ�(-/+)
         end else begin
            if Hibyte(std.MAC) >= ui.Desc[6] then
               std.Mac:= MakeWord (Lobyte(std.MAC), ABS( ui.Desc[6] - Hibyte(std.MAC) ))  //���ݼӵ�(-/+)
            else
               std.Mac:= MakeWord (Lobyte(std.MAC), ABS( ui.Desc[6] - Hibyte(std.MAC) ) + 10);  //���ݼӵ�(-/+)
         end;
}

         if ui.Desc[7] in [1..10] then begin
            // �ż��� �پ� ������ ������ �������� �ʴ´�(sonmg 2005/02/16)
            if std.SpecialPwr >= 0 then
               std.SpecialPwr := ui.Desc[7]; //������ ������ ��Ÿ��
         end;
         if ui.Desc[10] <> 0 then
            std.ItemDesc := std.ItemDesc or IDC_UNIDENTIFIED;//$01;

         std.Slowdown := std.Slowdown + ui.Desc[12];
         std.Tox := std.Tox + ui.Desc[13];

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );
         if ui.Desc[5] > 0 then inc ( UCount );
         if ui.Desc[6] > 0 then inc ( UCount );
         if ui.Desc[7] > 0 then inc ( UCount );
         if ui.Desc[12] > 0 then inc ( UCount );
         if ui.Desc[13] > 0 then inc ( UCount );


      end;
      10,11: //��
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.DC  := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[2]));
         std.MC  := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[3]));
         std.SC  := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[4]));
         //added by sonmg
         std.Agility  := std.Agility + ui.Desc[11];
         std.MgAvoid := std.MgAvoid + ui.Desc[12];
         std.ToxAvoid := std.ToxAvoid + ui.Desc[13];

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );
         if ui.Desc[11] > 0 then inc ( UCount );
         if ui.Desc[12] > 0 then inc ( UCount );
         if ui.Desc[13] > 0 then inc ( UCount );

      end;
      15: //����(added by sonmg)
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.DC  := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[2]));
         std.MC  := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[3]));
         std.SC  := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[4]));
         //added by sonmg
         std.Accurate  := std.Accurate + ui.Desc[11];
         std.MgAvoid := std.MgAvoid + ui.Desc[12];
         std.ToxAvoid := std.ToxAvoid + ui.Desc[13];

         if ui.Desc[5] > 0 then  //�ʿ�(��,�ı�,����,����)
            std.Need := ui.Desc[5];
         if ui.Desc[6] > 0 then
            std.NeedLevel := ui.Desc[6];
         //if ui.Desc[7] > 0 then begin // : �������� �ʴ� �Ӽ�
         //   std.ItemDesc := std.ItemDesc or IDC_UNABLETAKEOFF;  //���ʿ�
         //end;
         //if ui.Desc[8] > 0 then begin // : �����ǼӼ� �������� �ɷ�ġ�� ������ ����
         //   std.ItemDesc := std.ItemDesc or IDC_UNIDENTIFIED;   //���ʿ�
         //end;

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );
         if ui.Desc[11] > 0 then inc ( UCount );
         if ui.Desc[12] > 0 then inc ( UCount );
         if ui.Desc[13] > 0 then inc ( UCount );

      end;
      19,20,21: //�����
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.DC  := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[2]));
         std.MC  := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[3]));
         std.SC  := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[4]));
         //added by sonmg
         std.AtkSpd  := std.AtkSpd + ui.Desc[9];
         std.Undead := std.Undead + ui.Desc[10];   //PAIN �ø���
         std.Slowdown := std.Slowdown + ui.Desc[12];
         std.Tox := std.Tox + ui.Desc[13];

         if std.StdMode = 19 then
            std.Accurate := std.Accurate + ui.Desc[11]
         else if std.StdMode = 20 then
            std.MgAvoid := std.MgAvoid + ui.Desc[11]
         else if std.StdMode = 21 then begin
            std.Accurate := std.Accurate + ui.Desc[11];
            std.MgAvoid := std.MgAvoid + ui.Desc[7];  // 7���� ��� ���ϳ�?(sonmg)
         end;

         if ui.Desc[5] > 0 then  //�ʿ�(��,�ı�,����,����)
            std.Need := ui.Desc[5];
         if ui.Desc[6] > 0 then
            std.NeedLevel := ui.Desc[6];
         //if ui.Desc[7] > 0 then begin // : �������� �ʴ� �Ӽ�
         //   std.ItemDesc := std.ItemDesc or IDC_UNABLETAKEOFF;  //���ʿ�
         //end;
         //if ui.Desc[8] > 0 then begin // : �����ǼӼ� �������� �ɷ�ġ�� ������ ����
         //   std.ItemDesc := std.ItemDesc or IDC_UNIDENTIFIED;   //���ʿ�
         //end;

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );
         if ui.Desc[9] > 0 then inc ( UCount );
         if ui.Desc[11] > 0 then inc ( UCount );
         if ui.Desc[12] > 0 then inc ( UCount );
         if ui.Desc[13] > 0 then inc ( UCount );

      end;
      22,23: //����
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.DC  := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[2]));
         std.MC  := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[3]));
         std.SC  := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[4]));
         //added by sonmg
         std.AtkSpd  := std.AtkSpd + ui.Desc[9];
         std.Undead := std.Undead + ui.Desc[10];   //PAIN �ø���
         std.Slowdown := std.Slowdown + ui.Desc[12];
         std.Tox := std.Tox + ui.Desc[13];

         if ui.Desc[5] > 0 then  //�ʿ�(��,�ı�,����,����)
            std.Need := ui.Desc[5];
         if ui.Desc[6] > 0 then
            std.NeedLevel := ui.Desc[6];
         //if ui.Desc[7] > 0 then begin // : �������� �ʴ� �Ӽ�
         //   std.ItemDesc := std.ItemDesc or IDC_UNABLETAKEOFF;  //���ʿ�
         //end;
         //if ui.Desc[8] > 0 then begin // : �����ǼӼ� �������� �ɷ�ġ�� ������ ����
         //   std.ItemDesc := std.ItemDesc or IDC_UNIDENTIFIED;   //���ʿ�
         //end;

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );
         if ui.Desc[9] > 0 then inc ( UCount );
         if ui.Desc[12] > 0 then inc ( UCount );
         if ui.Desc[13] > 0 then inc ( UCount );

      end;
      24: //����24
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.DC  := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[2]));
         std.MC  := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[3]));
         std.SC  := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[4]));

         if ui.Desc[5] > 0 then  //�ʿ�(��,�ı�,����,����)
            std.Need := ui.Desc[5];
         if ui.Desc[6] > 0 then
            std.NeedLevel := ui.Desc[6];
         //if ui.Desc[7] > 0 then begin // : �������� �ʴ� �Ӽ�
         //   std.ItemDesc := std.ItemDesc or IDC_UNABLETAKEOFF;  //���ʿ�
         //end;
         //if ui.Desc[8] > 0 then begin // : �����ǼӼ� �������� �ɷ�ġ�� ������ ����
         //   std.ItemDesc := std.ItemDesc or IDC_UNIDENTIFIED;   //���ʿ�
         //end;

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );

      end;
      26: //����26
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.DC  := MakeWord (Lobyte(std.DC), _MIN(255, Hibyte(std.DC) + ui.Desc[2]));
         std.MC  := MakeWord (Lobyte(std.MC), _MIN(255, Hibyte(std.MC) + ui.Desc[3]));
         std.SC  := MakeWord (Lobyte(std.SC), _MIN(255, Hibyte(std.SC) + ui.Desc[4]));

         //added by sonmg
         std.Undead := std.Undead + ui.Desc[10];   //PAIN �ø���
         std.Accurate  := std.Accurate + ui.Desc[11];
         std.Agility  := std.Agility + ui.Desc[12];

         if ui.Desc[5] > 0 then  //�ʿ�(��,�ı�,����,����)
            std.Need := ui.Desc[5];
         if ui.Desc[6] > 0 then
            std.NeedLevel := ui.Desc[6];
         //if ui.Desc[7] > 0 then begin // : �������� �ʴ� �Ӽ�
         //   std.ItemDesc := std.ItemDesc or IDC_UNABLETAKEOFF;  //���ʿ�
         //end;
         //if ui.Desc[8] > 0 then begin // : �����ǼӼ� �������� �ɷ�ġ�� ������ ����
         //   std.ItemDesc := std.ItemDesc or IDC_UNIDENTIFIED;   //���ʿ�
         //end;

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[4] > 0 then inc ( UCount );
         if ui.Desc[11] > 0 then inc ( UCount );
         if ui.Desc[12] > 0 then inc ( UCount );

      end;
      52: //�Ź�(added by sonmg)
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.Agility := std.Agility + ui.Desc[3];

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );

      end;
      53: //��ȣ��(added by sonmg 2006/01/17)
      begin
         std.Undead := std.Undead + ui.Desc[10];   //PAIN �ø���
      end;
      54: //��Ʈ(added by sonmg)
      begin
         std.AC  := MakeWord (Lobyte(std.AC), _MIN(255, Hibyte(std.AC) + ui.Desc[0]));
         std.MAC := MakeWord (Lobyte(std.MAC),_MIN(255, Hibyte(std.MAC)+ ui.Desc[1]));
         std.Accurate := std.Accurate + ui.Desc[2];
         std.Agility := std.Agility + ui.Desc[3];
         std.ToxAvoid := std.ToxAvoid + ui.Desc[13];

         if ui.Desc[0] > 0 then inc ( UCount );
         if ui.Desc[1] > 0 then inc ( UCount );
         if ui.Desc[2] > 0 then inc ( UCount );
         if ui.Desc[3] > 0 then inc ( UCount );
         if ui.Desc[13] > 0 then inc ( UCount );

      end;
   end;

   Result := UCount;
end;

// ��� ���Ӱ��� ���� ����(-10~15)������ ��ȯ���ִ� �Լ�.
function TItemUnit.RealAttackSpeed( wAtkSpd: WORD ): integer;
begin
   if wAtkSpd <= 10 then
      Result := - wAtkSpd
   else
      Result := wAtkSpd - 10;
end;

// ���� ����(-10~15)���� ��� ���Ӱ����� ��ȯ���ִ� �Լ�.
function TItemUnit.NaturalAttackSpeed( iAtkSpd: integer ): WORD;
begin
   if iAtkSpd <= 0 then
      Result := - iAtkSpd
   else
      Result := iAtkSpd + 10;
end;

// ���ҽ��� ������ ��� ���Ӱ��� �޾Ƽ� �� ������ ���� ��� ���Ӱ����� �����ִ� �Լ�.
function TItemUnit.GetAttackSpeed( bStdAtkSpd, bUserAtkSpd: BYTE ): BYTE;
var
   iTemp: integer;
begin
   iTemp := RealAttackSpeed( bStdAtkSpd ) + RealAttackSpeed( bUserAtkSpd );

   Result := BYTE( NaturalAttackSpeed( iTemp ) );
end;

// ���ҽ��� ������ ��� ���Ӱ��� �޾Ƽ� ���׷��̵� ���� �ݿ��Ͽ� �����ϴ� �Լ�.
// ���ϰ� : ������ ��� ���Ӱ�.
function TItemUnit.UpgradeAttackSpeed( bUserAtkSpd: BYTE; iUpValue: integer ): BYTE;
var
   iTemp: integer;
begin
   iTemp := RealAttackSpeed( bUserAtkSpd ) + iUpValue;

   Result := BYTE( NaturalAttackSpeed( iTemp ) );
end;


end.
