unit GeneralConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin;

type
  TfrmGeneralConfig = class(TForm)
    GroupBoxNet: TGroupBox;
    LabelGateIPaddr: TLabel;
    EditGateIPaddr: TEdit;
    EditGatePort: TEdit;
    LabelGatePort: TLabel;
    EditServerPort: TEdit;
    LabelServerPort: TLabel;
    LabelServerIPaddr: TLabel;
    EditServerIPaddr: TEdit;
    GroupBoxInfo: TGroupBox;
    Label1: TLabel;
    EditTitle: TEdit;
    TrackBarLogLevel: TTrackBar;
    LabelShowLogLevel: TLabel;
    ButtonOK: TButton;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    EditMaxConnect: TSpinEdit;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RadioAddTempList: TRadioButton;
    RadioAddBlockList: TRadioButton;
    RadioDisConnect: TRadioButton;
    EditSessionTimeOutTime: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    EditConnSpaceOfIPaddr: TEdit;
    GroupBox2: TGroupBox;
    EditEncKeyFile: TEdit;
    procedure ButtonOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGeneralConfig: TfrmGeneralConfig;

implementation

uses Func;

{$R *.dfm}

procedure TfrmGeneralConfig.ButtonOKClick(Sender: TObject);
var
  sGateIPaddr, sServerIPaddr, sTitle, sEditEncKeyFile: string;
  nGatePort, nServerPort, nShowLogLv: Integer;
  tSessionTimeOutTime: LongWord;
  tConnSpaceOfIPaddr: Integer;
begin
  sGateIPaddr := Trim(EditGateIPaddr.Text);
  nGatePort := Str_ToInt(Trim(EditGatePort.Text), -1);
  sServerIPaddr := Trim(EditServerIPaddr.Text);
  nServerPort := Str_ToInt(Trim(EditServerPort.Text), -1);
  sTitle := Trim(EditTitle.Text);
  sEditEncKeyFile := Trim(EditEncKeyFile.Text);
  nShowLogLv := TrackBarLogLevel.Position;
  tSessionTimeOutTime := Str_ToInt(Trim(EditSessionTimeOutTime.Text), 0);
  nMaxConnOfIPaddr := EditMaxConnect.Value;
  tConnSpaceOfIPaddr := Str_ToInt(Trim(EditConnSpaceOfIPaddr.Text), -1);
  if RadioDisConnect.Checked then BlockMethod := mDisconnect;
  if RadioAddBlockList.Checked then BlockMethod := mBlockList;
  if RadioAddTempList.Checked then BlockMethod := mBlock;

  if not IsIPaddr(sGateIPaddr) then begin
    Application.MessageBox('请输入正确的IP地址！！！', '错误信息', MB_OK +
      MB_ICONERROR);
    EditGateIPaddr.SetFocus;
    exit;
  end;

  if (nGatePort < 0) or (nGatePort > 65535) then begin
    Application.MessageBox('请输入正确的端口号,端口范围:1-65535！！！',
      '错误信息', MB_OK + MB_ICONERROR);
    EditGatePort.SetFocus;
    exit;
  end;

  if not IsIPaddr(sServerIPaddr) then begin
    Application.MessageBox('请输入正确的IP地址！！！', '错误信息', MB_OK +
      MB_ICONERROR);
    EditServerIPaddr.SetFocus;
    exit;
  end;

  if (nServerPort < 0) or (nServerPort > 65535) then begin
    Application.MessageBox('请输入正确的端口号,端口范围:1-65535！！！',
      '错误信息', MB_OK + MB_ICONERROR);
    EditServerPort.SetFocus;
    exit;
  end;
  if sTitle = '' then begin
    Application.MessageBox('请输入网关标题！！！', '错误信息', MB_OK +
      MB_ICONERROR);
    EditTitle.SetFocus;
    exit;
  end;

  if tSessionTimeOutTime = 0 then begin
    Application.MessageBox('请输入正确的会话超时时间！！！', '错误信息', MB_OK +
      MB_ICONERROR);
    EditSessionTimeOutTime.SetFocus;
    exit;
  end;

  if tConnSpaceOfIPaddr < 0 then begin
    Application.MessageBox('请输入正确的每IP间隔时间！！！', '错误信息', MB_OK +
      MB_ICONERROR);
    EditConnSpaceOfIPaddr.SetFocus;
    exit;
  end;

  nShowLogLevel := nShowLogLv;
  TitleName := sTitle;
  ServerAddr := sServerIPaddr;
  ServerPort := nServerPort;
  GateAddr := sGateIPaddr;
  GatePort := nGatePort;
  sEnckeyFileName := sEditEncKeyFile;
  dwSessionTimeOutTime := tSessionTimeOutTime * 1000;
  dwConnSpaceOfIPaddr := tConnSpaceOfIPaddr;
  Conf.WriteString(GateClass, 'Title', TitleName);
  Conf.WriteString(GateClass, 'ServerAddr', ServerAddr);
  Conf.WriteInteger(GateClass, 'ServerPort', ServerPort);
  Conf.WriteString(GateClass, 'GateAddr', GateAddr);
  Conf.WriteInteger(GateClass, 'GatePort', GatePort);
  Conf.WriteInteger(GateClass, 'ShowLogLevel', nShowLogLevel);
  Conf.WriteInteger(GateClass, 'SessionTimeOutTime', dwSessionTimeOutTime);
  Conf.WriteInteger(GateClass, 'MaxConnOfIPaddr', nMaxConnOfIPaddr);
  Conf.WriteInteger(GateClass, 'ConnSpaceOfIPaddr', dwConnSpaceOfIPaddr);
  Conf.WriteInteger(GateClass, 'BlockMethod', Integer(BlockMethod));
  Conf.WriteString(GateClass, 'EnckeyFileName', sEnckeyFileName);

  Close;
end;

end.
