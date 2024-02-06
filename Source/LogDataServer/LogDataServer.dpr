program LogDataServer;

uses
  Forms,
  LogDataMain in 'LogDataMain.pas' {FrmLogData},
  Grobal2 in '..\Common\Grobal2.pas',
  HUtil32 in '..\Common\HUtil32.pas';
{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'LogDataServer';
  Application.CreateForm(TFrmLogData, FrmLogData);
  Application.Run;
end.
