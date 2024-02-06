unit UnitLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzBmpBtn, RzBckgnd, RzButton, RzRadChk, RzTray, SetupUnit1,
  ExtCtrls, OleCtrls, SHDocVw, jpeg, ImgButton;

type
  TFrmLogin = class(TForm)
    suiclose: TImgButton;
    suiminapp: TImgButton;
    suiImageButton1: TImgButton;
    suiImageButton2: TImgButton;
    ReStartup: TTimer;
    NexTimer: TTimer;
    WebBrowser1: TWebBrowser;
    Startup: TTimer;
    suiImageButton3: TImgButton;
    suiComboBox1: TComboBox;
    RzBackground1: TRzBackground;
    Img1: TImage;
    Img2: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RzBmpButton1Click(Sender: TObject);
    procedure RzBackground1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure suicloseClick(Sender: TObject);
    procedure suiminappClick(Sender: TObject);
    procedure suiImageButton1Click(Sender: TObject);
    procedure suiImageButton2Click(Sender: TObject);
    procedure ReStartupTimer(Sender: TObject);
    procedure StartupTimer(Sender: TObject);
    procedure suiImageButton3Click(Sender: TObject);
    procedure suiComboBox1Change(Sender: TObject);
    procedure suiComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RzBackground1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    private
    { Private declarations }
  public
    procedure AddCombobox;
    procedure CreateParams(var Params:TCreateParams);override;
  end;

var
  FrmLogin: TFrmLogin;
  Aes_Key: string[16] = '8879585887958567';      //�Զ���������
  title :string = '��������'; //��¼�����ϽǱ�������
  ServerList1 :string = 'http://lb.1xlala.com/upload/1675538761.txt'; // �б��ַ
  ServerList2 :string = 'http://lb.1xlala.com/upload/1675538770.txt'; //�����б��ַ
  Homeindex :string = 'http://www.1mir2.com'; //������ť��ַ
  weblink :string = 'http://www.1mir2.com/mainindex.htm';// LINK���ڵ�ַ
  lnkname   :string = '��������'; //�����ݷ�ʽ����
  UpdateUrl: string = 'http://www.1mir2.com/download11/UpList.txt';  //�Զ����µ�ַ
  batFile: TStringList;
implementation

uses
  ClMain, MShare , DownLoad ,GateFun, LoadServerList ,ShellAPI;
  var
   Svrlist: _ServerList;

{$R *.dfm}


procedure TFrmLogin.AddCombobox;
var
  i: Integer;
begin

  Svrlist := LoadUrlList(ServerList1, ServerList2);
  if Length(Svrlist) > 0 then begin
    suiComboBox1.Style := csDropDownList;
    for i := 0 to Length(Svrlist) - 1 do begin
      if Svrlist[i].Note <> '0' then   //����б�עΪ0���Ͳ���ʾ��ע
        suiComboBox1.Items.Add(Svrlist[i].SName + '  ' + Svrlist[i].Note)   //����������ٸ��ո����ʾ��ע
      else
        suiComboBox1.Items.Add(Svrlist[i].SName);
    end;
    suiComboBox1.ItemIndex := 0;
    NetPort := Svrlist[0].Port;
    NetSvrAddr := Svrlist[0].Addr;
    NowSvrName := Svrlist[0].SName;
  end else begin
    suiComboBox1.Text := '��Ϸ�б��ȡʧ�ܡ�';
  end;

end;


procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if batFile.Count > 0 then
    begin
      batFile.SaveToFile(DefDir + 'ReStart.bat');
      WinExec(PAnsiChar(DefDir + 'ReStart.bat'), SW_HIDE)
    end;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
  //����Ƿ���Ŀ¼
  function CheckMirDir(DirName: string): Boolean;
  begin
    if (not DirectoryExists(DirName + '/Data')) or
      (not DirectoryExists(DirName + '/Map')) or
      (not DirectoryExists(DirName + '/Wav')) then
      Result := FALSE else Result := True;
  end;
begin
  DoubleBuffered := True;
  suiComboBox1.Text := '���ڶ�ȡ��Ϸ�б�';
  Label1.Caption := title;
  CreateDesktopShortcut(ParamStr(0) , '' , lnkname);    //�����洴����ݷ�ʽ����
  if not CheckMirDir(ExtractFileDir(ParamStr(0))) then begin
    Application.MessageBox('�Ҳ�����ϷĿ¼·�����뽫��¼����������ͻ����ڴ򿪣�', PChar(ExtractFileDir(ParamStr(0))), MB_OK + MB_ICONSTOP);
    Application.Terminate;
  end;
end;

procedure TFrmLogin.FormDestroy(Sender: TObject);
begin
  FrmLogin:= nil;
  Application.Terminate;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TFrmLogin.ReStartupTimer(Sender: TObject);
begin
  FreeAndNil(Sender);
  Self.Close;
end;

procedure TFrmLogin.RzBackground1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFrmLogin.RzBackground1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 ReleaseCapture;
 Perform(WM_SYSCOMMAND, $F017 , 0);  //����϶���¼������
end;

procedure TFrmLogin.RzBmpButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmLogin.StartupTimer(Sender: TObject);
begin
  FreeAndNil(Sender);
  if (ParamStr(1) <> '-NOUPDATE') then  begin
    suiImageButton2.Caption := '���ڸ��¡�';
    UpdateThread.Create(UpdateUrl);
  end;
  AddCombobox;    //��ȡ�б��ַ
  WebBrowser1.Navigate(weblink); //��ȡ������ҳ��ַ
end;

procedure TFrmLogin.suicloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmLogin.suiComboBox1Change(Sender: TObject);
var
 i : Integer;
begin
  //suiImageButton2.SetFocus;
  i := suiComboBox1.ItemIndex;
  if i < 0 then Exit;
  
  NetPort  := Svrlist[i].Port;
  NetSvrAddr  := Svrlist[i].Addr;
  NowSvrName := Svrlist[i].SName;
end;

procedure TFrmLogin.suiComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

procedure TFrmLogin.suiImageButton1Click(Sender: TObject);
begin
  Form1.Left := Self.Left + 126;
  Form1.Top := Self.Top + 65;
  Form1.ShowModal;
end;

procedure TFrmLogin.suiImageButton2Click(Sender: TObject);
begin
  if _Isupdateing then exit;

  {if CheckBoxWin.Checked then g_boFullScreen := False
  else g_boFullScreen := True; }
  g_boFullScreen := False;

  if Form1.RzRadioButton1.Checked then g_FScreenMode := 1
  else g_FScreenMode := 0;

  Application.CreateForm(TFrmMain, FrmMain);
  FrmLogin.Hide;
  FrmMain.Show;
end;

procedure TFrmLogin.suiImageButton3Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(Homeindex), nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmLogin.suiminappClick(Sender: TObject);
begin
  Application.Minimize; 
end;


procedure TFrmLogin.CreateParams(var Params: TCreateParams);
  function RandomGetPass():string;
  var
    s,s1:string;
    I,i0:Byte;
  begin
    s:='123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
    s1:='';
    Randomize(); //�������
    for i:=0 to 5 do begin
      i0:=random(35);
      s1:=s1+copy(s,i0,1);
    end;
    Result := s1;
  end;
begin
  inherited CreateParams(Params);
  strpcopy(pChar(@Params.WinClassName),RandomGetPass);
end;
initialization
  batFile := TStringList.Create;

finalization
  FreeAndNil(batFile);

end.
