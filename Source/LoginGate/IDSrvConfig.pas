unit IDSrvConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmIDSrvConfig = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Button1: TButton;
    C_EnRegUser: TCheckBox;
    C_EnModPass: TCheckBox;
    C_EnableIDSrv: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    E_ACCOUNTServer: TEdit;
    E_ACCOUNTDB: TEdit;
    E_ACCOUNTID: TEdit;
    E_ACCOUNTPWS: TEdit;
    CBNoThisSQL: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure C_EnableIDSrvClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmIDSrvConfig: TfrmIDSrvConfig;

implementation

uses Func;

{$R *.dfm}

procedure TfrmIDSrvConfig.FormShow(Sender: TObject);
begin
  if boEnableIDSrv then begin
    CBNoThisSQL.Enabled := True;
    C_EnRegUser.Enabled := True;
    C_EnModPass.Enabled := True;
    E_ACCOUNTServer.Enabled := True;
    E_ACCOUNTDB.Enabled := True;
    E_ACCOUNTID.Enabled := True;
    E_ACCOUNTPWS.Enabled := True;
  end
  else begin
    CBNoThisSQL.Enabled := False;
    C_EnRegUser.Enabled := False;
    C_EnModPass.Enabled := False;
    E_ACCOUNTServer.Enabled := False;
    E_ACCOUNTDB.Enabled := False;
    E_ACCOUNTID.Enabled := False;
    E_ACCOUNTPWS.Enabled := False;
  end;
end;

procedure TfrmIDSrvConfig.C_EnableIDSrvClick(Sender: TObject);
begin
  if C_EnableIDSrv.Checked then begin
    CBNoThisSQL.Enabled := True;
    C_EnRegUser.Enabled := True;
    C_EnModPass.Enabled := True;
    E_ACCOUNTServer.Enabled := True;
    E_ACCOUNTDB.Enabled := True;
    E_ACCOUNTID.Enabled := True;
    E_ACCOUNTPWS.Enabled := True;
  end
  else begin
    CBNoThisSQL.Enabled := False;
    C_EnRegUser.Enabled := False;
    C_EnModPass.Enabled := False;
    E_ACCOUNTServer.Enabled := False;
    E_ACCOUNTDB.Enabled := False;
    E_ACCOUNTID.Enabled := False;
    E_ACCOUNTPWS.Enabled := False;
  end;
end;

procedure TfrmIDSrvConfig.Button1Click(Sender: TObject);
begin
  boEnableIDSrv := C_EnableIDSrv.Checked;
  boEnRegUser := C_EnRegUser.Checked;
  boEnModPass := C_EnModPass.Checked;
  ACCOUNTServer := Trim(E_ACCOUNTServer.Text);
  ACCOUNTDB := Trim(E_ACCOUNTDB.Text);
  ACCOUNTID := Trim(E_ACCOUNTID.Text);
  ACCOUNTPWS := Trim(E_ACCOUNTPWS.Text);
  boNoThisSQL := CBNoThisSQL.Checked;
  Conf.WriteBool(GateClass, 'EnableIDSrv', boEnableIDSrv);
  Conf.WriteBool(GateClass, 'EnRegUser', boEnRegUser);
  Conf.WriteBool(GateClass, 'EnModPass', boEnModPass);
  Conf.WriteString(GateClass, 'ACCOUNTServer', ACCOUNTServer);
  Conf.WriteString(GateClass, 'ACCOUNTDB', ACCOUNTDB);
  Conf.WriteString(GateClass, 'ACCOUNTID', ACCOUNTID);
  Conf.WriteString(GateClass, 'ACCOUNTPWS', ACCOUNTPWS);
  Conf.WriteBool(GateClass, 'NoThisSQL', boNoThisSQL);
  Close;
end;

end.
