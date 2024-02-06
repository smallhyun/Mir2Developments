program SelGate;

uses
  Forms,
  BCmain2 in 'BCmain2.pas' {FrmMain},
  HUtil32 in '..\Common\HUtil32.pas',
  EDcode in '..\Common\EDCode.pas',
  Grobal2 in '..\Common\Grobal2.pas',
  showip in 'showip.pas'; {FrmShowIp}
{$R *.RES}
begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmShowIp, FrmShowIp);
  Application.Run;
end.
