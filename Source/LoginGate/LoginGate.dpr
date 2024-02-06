program LoginGate;

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  GeneralConfig in 'GeneralConfig.pas' {frmGeneralConfig},
  IDSrvConfig in 'IDSrvConfig.pas' {frmIDSrvConfig},
  Grobal2 in '..\Common\Grobal2.pas',
  EDcode in '..\Common\EdCode.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'LoginGate';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TfrmGeneralConfig, frmGeneralConfig);
  Application.CreateForm(TfrmIDSrvConfig, frmIDSrvConfig);
  Application.Run;
end.

