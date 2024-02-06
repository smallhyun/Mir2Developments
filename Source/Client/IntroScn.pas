unit IntroScn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, StdCtrls, Controls, Forms,
  Dialogs, extctrls, FState, Grobal2, SoundUtil, HUtil32, HGETextures, EdCode;

const
  SELECTEDFRAME = 16;
  FREEZEFRAME = 13;
  EFFECTFRAME = 14;

type
  TLoginState = (lsLogin, lsNewid, lsNewidRetry, lsChgpw, lsCloseAll);
  TSceneType = (stIntro, stLogin, stSelectCountry, stSelectChr, stNewChr, stLoading, stLoginNotice, stPlayGame);

  TSelChar = record
    Valid: Boolean;
    UserChr: TUserCharacterInfo;
    Selected: Boolean;
    FreezeState: Boolean;
    Unfreezing: Boolean;
    FireIng:Boolean;
    Freezing: Boolean;
    AniIndex: integer;
    DarkLevel: integer;
    EffIndex: integer;
    starttime: longword;
    moretime: longword;
    startefftime: longword;
  end;

  TScene = class
  private
  public
    SceneType: TSceneType;
    constructor Create(scenetype: TSceneType);
    procedure Initialize; dynamic;
    procedure Finalize; dynamic;
    procedure OpenScene; dynamic;
    procedure CloseScene; dynamic;
    procedure OpeningScene; dynamic;
    procedure KeyPress(var Key: Char); dynamic;
    procedure KeyDown(var Key: Word; Shift: TShiftState); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure PlayScene(MSurface: TDXTexture); dynamic;
  end;

  TIntroScene = class(TScene)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure OpenScene; override;
    procedure CloseScene; override;
    procedure PlayScene(MSurface: TDXTexture); override;
  end;

  TLoginScene = class(TScene)
      //LbServerList: TButtonListBox;

  private
    EdNewId: TEdit;
    EdNewPasswd: TEdit;
    EdConfirm: TEdit;
    EdYourName: TEdit;
    EdSSNo: TEdit;
    EdBirthDay: TEdit;
    EdQuiz1: TEdit;
    EdAnswer1: TEdit;
    EdQuiz2: TEdit;
    EdAnswer2: TEdit;
    EdPhone: TEdit;
    EdMobPhone: TEdit;
    EdEMail: TEdit;
    EdChgId: TEdit;
    EdChgCurrentpw: TEdit;
    EdChgNewPw: TEdit;
    EdChgRepeat: TEdit;
    CurFrame, MaxFrame: integer;
    StartTime: longword;
    NowOpening: Boolean;
    BoOpenFirst: Boolean;
    NewIdRetryUE: TUserEntryInfo;
    NewIdRetryAdd: TUserEntryAddInfo;
    procedure EdLoginIdKeyPress(Sender: TObject; var Key: Char);
    procedure EdLoginPasswdKeyPress(Sender: TObject; var Key: Char);
    procedure EdNewIdKeyPress(Sender: TObject; var Key: Char);
    procedure EdNewOnEnter(Sender: TObject);
    function CheckUserEntrys: Boolean;
    function NewIdCheckNewId: Boolean;
    function NewIdCheckSSno: Boolean;
    function NewIdCheckBirthDay: Boolean;

      // 20003-09-05 Encrypt LoginId,PasswordmCharName
    function GetLoginId: string;
    procedure SetLogId(id: string);
    function GetLoginPasswd: string;
    procedure SetLoginPasswd(pw: string);
  public
    EdId: TEdit;      //
    EdPasswd: TEdit;  //

    BoUpdateAccountMode: Boolean;
      //LoginId, LoginPasswd: string;
      //2003-09-05 Encrypt LoginID & Password
    EncLoginId, EncLoginPasswd: string;
    property LoginId: string read GetLoginId write SetLogId;
    property LoginPasswd: string read GetLoginPasswd write SetLoginPasswd;
    constructor Create;
    destructor Destroy; override;
    procedure OpenScene; override;
    procedure CloseScene; override;
    procedure PlayScene(MSurface: TDXTexture); override;
    procedure ChangeLoginState(state: TLoginState);
    procedure NewClick;
    procedure NewIdRetry(boupdate: Boolean);
    procedure UpdateAccountInfos(ue: TUserEntryInfo);
    procedure OkClick;
    procedure ChgPwClick;
    procedure NewAccountOk;
    procedure NewAccountClose;
    procedure ChgpwOk;
    procedure ChgpwCancel;
    procedure HideLoginBox;
    procedure OpenLoginDoor;
    procedure PassWdFail;
  end;

  TSelectChrScene = class(TScene)
  private
    SoundTimer: TTimer;
    CreateChrMode: Boolean;
    EdChrName: TEdit;
    procedure SoundOnTimer(Sender: TObject);
    procedure MakeNewChar(index: integer);
    procedure EdChrnameKeyPress(Sender: TObject; var Key: Char);
    function GetJobName(job: integer): string;
  public
    NewIndex: integer;
    ChrArr: array[0..2] of TSelChar;
    constructor Create;
    destructor Destroy; override;
    procedure OpenScene; override;
    procedure CloseScene; override;
    procedure PlayScene(MSurface: TDXTexture); override;
    procedure SelChrSelect1Click;
    procedure SelChrSelect2Click;
    procedure SelChrSelect3Click;
    procedure SelChrStartClick;
    procedure SelChrNewChrClick;
    procedure SelChrEraseChrClick;
    procedure SelChrCreditsClick;
    procedure SelChrExitClick;
    procedure SelChrNewClose;
    procedure SelChrNewJob(job: integer);
    procedure SelChrNewSex(sex: integer);
    procedure SelChrNewPrevHair;
    procedure SelChrNewNextHair;
    procedure SelChrNewOk;
    procedure ClearChrs;
    procedure AddChr(uname: string; job, hair, level, sex: integer);
    procedure SelectChr(index: integer);
  end;

  TLoginNotice = class(TScene)
  private
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  ClMain, MShare;

constructor TScene.Create(scenetype: TSceneType);
begin
  scenetype := scenetype;
end;

procedure TScene.Initialize;
begin
end;

procedure TScene.Finalize;
begin
end;

procedure TScene.OpenScene;
begin
  ;
end;

procedure TScene.CloseScene;
begin
  ;
end;

procedure TScene.OpeningScene;
begin
end;

procedure TScene.KeyPress(var Key: Char);
begin
end;

procedure TScene.KeyDown(var Key: Word; Shift: TShiftState);
begin
end;

procedure TScene.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TScene.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TScene.PlayScene(MSurface: TDXTexture);
begin
  ;
end;

{------------------- TIntroScene ----------------------}
constructor TIntroScene.Create;
begin
  inherited Create(stIntro);
end;

destructor TIntroScene.Destroy;
begin
  inherited Destroy;
end;

procedure TIntroScene.OpenScene;
begin
end;

procedure TIntroScene.CloseScene;
begin
end;

procedure TIntroScene.PlayScene(MSurface: TDXTexture);
begin
end;

{--------------------- Login ----------------------}
// 20003-09-05 Encrypt LoginId,PasswordmCharName
function TLoginScene.GetLoginId: string;
begin
  Result := DecodeString(EncLoginId);
end;

procedure TLoginScene.SetLogId(id: string);
begin
  EncLoginId := EncodeString(id);
end;

function TLoginScene.GetLoginPasswd: string;
begin
  Result := DecodeString(EncLoginPasswd);
end;

procedure TLoginScene.SetLoginPasswd(pw: string);
begin
  EncLoginPasswd := EncodeString(pw);
end;

constructor TLoginScene.Create;
var
  nx, ny: integer;
begin
  inherited Create(stLogin);

  EdId := TEdit.Create(FrmMain.Owner);
  with EdId do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Color := clWhite;
    Font.Size := 10;
    MaxLength := 20;
    BorderStyle := bsNone;
    OnKeyPress := EdLoginIdKeyPress;
    Visible := FALSE;
    Tag := 10;
  end;

  EdPasswd := TEdit.Create(FrmMain.Owner);
  with EdPasswd do
  begin
    Parent := FrmMain;
    Color := clBlack;
    Font.Size := 10;
    MaxLength := 10;
    Font.Color := clWhite;
    BorderStyle := bsNone;
    PasswordChar := '*';
    OnKeyPress := EdLoginPasswdKeyPress;
    Visible := FALSE;
    Tag := 10;
  end;

  nx := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 79;
  ny := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 64;
  EdNewId := TEdit.Create(FrmMain.Owner);
  with EdNewId do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 116;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdNewPasswd := TEdit.Create(FrmMain.Owner);
  with EdNewPasswd do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 137;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    PasswordChar := '*';
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdConfirm := TEdit.Create(FrmMain.Owner);
  with EdConfirm do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 158;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    PasswordChar := '*';
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdYourName := TEdit.Create(FrmMain.Owner);
  with EdYourName do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 187;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 20;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdSSNo := TEdit.Create(FrmMain.Owner);
  with EdSSNo do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 207;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 14;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdBirthDay := TEdit.Create(FrmMain.Owner);
  with EdBirthDay do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 227;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdQuiz1 := TEdit.Create(FrmMain.Owner);
  with EdQuiz1 do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 163;
    Left := nx + 161;
    Top := ny + 256;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 20;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdAnswer1 := TEdit.Create(FrmMain.Owner);
  with EdAnswer1 do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 163;
    Left := nx + 161;
    Top := ny + 276;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 12;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdQuiz2 := TEdit.Create(FrmMain.Owner);
  with EdQuiz2 do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 163;
    Left := nx + 161;
    Top := ny + 297;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 20;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdAnswer2 := TEdit.Create(FrmMain.Owner);
  with EdAnswer2 do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 163;
    Left := nx + 161;
    Top := ny + 317;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 12;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdPhone := TEdit.Create(FrmMain.Owner);
  with EdPhone do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 347;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 14;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdMobPhone := TEdit.Create(FrmMain.Owner);
  with EdMobPhone do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 368;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 13;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;
  EdEMail := TEdit.Create(FrmMain.Owner);
  with EdEMail do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 116;
    Left := nx + 161;
    Top := ny + 388;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 40;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 11;
  end;

  nx := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 192;
  ny := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 150;
  EdChgId := TEdit.Create(FrmMain.Owner);
  with EdChgId do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 137;
    Left := nx + 239;
    Top := ny + 117;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 12;
  end;
  EdChgCurrentPw := TEdit.Create(FrmMain.Owner);
  with EdChgCurrentPw do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 137;
    Left := nx + 239;
    Top := ny + 149;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    PasswordChar := '*';
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 12;
  end;
  EdChgNewPw := TEdit.Create(FrmMain.Owner);
  with EdChgNewPw do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 137;
    Left := nx + 239;
    Top := ny + 176;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    PasswordChar := '*';
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 12;
  end;
  EdChgRepeat := TEdit.Create(FrmMain.Owner);
  with EdChgRepeat do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 137;
    Left := nx + 239;
    Top := ny + 208;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    MaxLength := 10;
    PasswordChar := '*';
    Visible := FALSE;
    OnKeyPress := EdNewIdKeyPress;
    OnEnter := EdNewOnEnter;
    Tag := 12;
  end;

   {LbServerList := TButtonListBox.Create (FrmMain.Owner);
   with LbServerList do begin
      Parent := FrmMain; Height := 18 * 13 + 7; Width := 183;
      Left := (SCREENWIDTH - Width) div 2 - 13;
      Top := (SCREENHEIGHT - Height) div 2 - 14;
      ItemHeight := 32;
      Depth := 3;
      NormalFontColor := clBlack;
      SelectFontColor := clNavy; //Yellow;
      //BorderStyle := bsNone;
      //Color := clBlack;
      //Font.Color := clWhite;
      Font.Size := 11;
      Style := lbOwnerDrawFixed;
      Visible := FALSE;
   end; }
end;

destructor TLoginScene.Destroy;
begin
  inherited Destroy;
end;

procedure TLoginScene.OpenScene;
var
  i: integer;
  str: string;
  bzRegBool, szOptionBool: Bool;
  Result: LongInt;
begin
  CurFrame := 0;
  MaxFrame := 10;
  LoginId := '';
  LoginPasswd := '';
  with EdId do
  begin
    Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 350;
    Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 259;
    Height := 16;
    Width := 137;
    Visible := FALSE;
  end;
  with EdPasswd do
  begin
    Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 350;
    Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 291;
    Height := 16;
    Width := 137;
    Visible := FALSE;
  end;

  BoOpenFirst := TRUE;

  FrmDlg.DLogin.Visible := TRUE;
  FrmDlg.DNewAccount.Visible := FALSE;
  NowOpening := FALSE;
  PlayBGM (bmg_intro);
end;

procedure TLoginScene.CloseScene;
var
  bzClose: Bool;
begin
  EdId.Visible := FALSE;
  EdPasswd.Visible := FALSE;
  FrmDlg.DLogin.Visible := FALSE;
  SilenceSound;

{   FNPKCloseDriver := GetProcAddress(FKeyHwnd, 'NPKCloseDriver');
   if @FNPKCloseDriver <> nil then begin
      bzClose := FNPKCloseDriver(hCryptHWnd);
         if not bzClose then
            Showmessage('[Űũ��Ʈ] ����̹� �ݱ� ����');
   end
   else begin
      Showmessage('[Űũ��Ʈ] ����̹� ũ���� �Լ� Ȯ�� ����');
   end;
   FreeLibrary(FKeyHwnd);}
//   if @FKeyHwnd = nil then
//      Showmessage('FreeLibrary(FKeyHwnd) �� FKeyHwnd = nil ')
//   else
//      Showmessage('FreeLibrary(FKeyHwnd) �� FKeyHwnd <> nil ');

end;

procedure TLoginScene.EdLoginIdKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    LoginId := LowerCase(EdId.Text);
    if LoginId <> '' then
    begin
      EdPasswd.SetFocus;
    end;
  end;
    if Key = #32 then Key := #0;
end;

procedure TLoginScene.EdLoginPasswdKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '~') or (Key = '''') then
    Key := '_';
  if Key = #13 then
  begin
    Key := #0;
    LoginId := LowerCase(EdId.Text);
    LoginPasswd := EdPasswd.Text;
    if (LoginId <> '') and (LoginPasswd <> '') then
    begin
         //�������� �α��� �Ѵ�.
      FrmMain.SendLogin(LoginId, LoginPasswd);
      EdId.Text := '';
      EdPasswd.Text := '';
      EdId.Visible := FALSE;
      EdPasswd.Visible := FALSE;
    end
    else if (EdId.Visible) and (EdId.Text = '') then
      EdId.SetFocus;
  end;
end;

procedure TLoginScene.PassWdFail;
begin
  EdId.Visible := TRUE;
  EdPasswd.Visible := TRUE;
  EdId.SetFocus;
end;

function TLoginScene.NewIdCheckNewId: Boolean;
begin
  Result := TRUE;
  EdNewId.Text := Trim(EdNewId.Text);
  if Length(EdNewId.Text) < 3 then
  begin
      //FrmDlg.DMessageDlg ('IDӦ��������3���ַ���', [mbOk]);
    Beep;
    EdNewId.SetFocus;
    Result := FALSE;
  end;
end;

function TLoginScene.NewIdCheckSSno: Boolean;
var
  str, t1, t2, t3, syear, smon, sday: string;
  ayear, amon, aday, sex: integer;
  flag: Boolean;
begin
  Result := TRUE;
  str := EdSSNo.Text;
  str := GetValidStr3(str, t1, ['-']);
  GetValidStr3(str, t2, ['-']);
  flag := TRUE;
  if (Length(t1) = 6) and (Length(t2) = 7) then
  begin
    smon := Copy(t1, 3, 2);
    sday := Copy(t1, 5, 2);
    amon := Str_ToInt(smon, 0);
    aday := Str_ToInt(sday, 0);
    if (amon <= 0) or (amon > 12) then
      flag := FALSE;
    if (aday <= 0) or (aday > 31) then
      flag := FALSE;
    sex := Str_ToInt(Copy(t2, 1, 1), 0);
    if (sex <= 0) or (sex > 2) then
      flag := FALSE;
  end
  else
    flag := FALSE;
  if not flag then
  begin
    Beep;
    EdSSNo.SetFocus;
    Result := FALSE;
  end;
end;

function TLoginScene.NewIdCheckBirthDay: Boolean;
var
  str, t1, t2, t3, syear, smon, sday: string;
  ayear, amon, aday, sex: integer;
  flag: Boolean;
begin
  Result := TRUE;
  flag := TRUE;
  str := EdBirthDay.Text;
  str := GetValidStr3(str, syear, ['/']);
  str := GetValidStr3(str, smon, ['/']);
  str := GetValidStr3(str, sday, ['/']);
  ayear := Str_ToInt(syear, 0);
  amon := Str_ToInt(smon, 0);
  aday := Str_ToInt(sday, 0);
  if (ayear <= 1890) or (ayear > 2101) then
    flag := FALSE;
  if (amon <= 0) or (amon > 12) then
    flag := FALSE;
  if (aday <= 0) or (aday > 31) then
    flag := FALSE;
  if not flag then
  begin
    Beep;
    EdBirthDay.SetFocus;
    Result := FALSE;
  end;
end;

procedure TLoginScene.EdNewIdKeyPress(Sender: TObject; var Key: Char);
var
  str, t1, t2, t3, syear, smon, sday: string;
  ayear, amon, aday, sex: integer;
  flag: Boolean;
begin
  if (Sender = EdNewPasswd) or (Sender = EdChgNewPw) or (Sender = EdChgRepeat) then
    if (Key = '~') or (Key = '''') or (Key = ' ') then
      Key := #0;
  if Key = #13 then
  begin
    Key := #0;
    if Sender = EdNewId then
    begin
      if not NewIdCheckNewId then
        exit;
    end;
    if Sender = EdNewPasswd then
    begin
      if Length(EdNewPasswd.Text) < 4 then
      begin
        FrmDlg.DMessageDlg ('����Ӧ��������4���ַ���', [mbOk]);
        Beep;
        EdNewPasswd.SetFocus;
        exit;
      end;
    end;
    if Sender = EdConfirm then
    begin
      if EdNewPasswd.Text <> EdConfirm.Text then
      begin
        FrmDlg.DMessageDlg ('����ȷ�ϴ������ٴ����롣', [mbOk]);
        Beep;
        EdConfirm.SetFocus;
        exit;
      end;
    end;
    if (Sender = EdYourName) or (Sender = EdQuiz1) or (Sender = EdAnswer1) or (Sender = EdQuiz2) or (Sender = EdAnswer2) or (Sender = EdPhone) or (Sender = EdMobPhone) or (Sender = EdEMail) then
    begin
      TEdit(Sender).Text := Trim(TEdit(Sender).Text);
      if TEdit(Sender).Text = '' then
      begin
        Beep;
        TEdit(Sender).SetFocus;
        exit;
      end;
    end;
    if (Sender = EdSSNo) and (KoreanVersion) then
    begin
      if not NewIdCheckSSno then
        exit;
    end;
    if Sender = EdBirthDay then
    begin
      if not NewIdCheckBirthDay then
        exit;
    end;
    if TEdit(Sender).Text <> '' then
    begin
      if Sender = EdNewId then
        EdNewPasswd.SetFocus;
      if Sender = EdNewPasswd then
        EdConfirm.SetFocus;
      if Sender = EdConfirm then
        EdYourName.SetFocus;
      if Sender = EdYourName then
        EdSSNo.SetFocus;
      if Sender = EdSSNo then
        EdBirthDay.SetFocus;
      if Sender = EdBirthDay then
        EdQuiz1.SetFocus;
      if Sender = EdQuiz1 then
        EdAnswer1.SetFocus;
      if Sender = EdAnswer1 then
        EdQuiz2.SetFocus;
      if Sender = EdQuiz2 then
        EdAnswer2.SetFocus;
      if Sender = EdAnswer2 then
        EdPhone.SetFocus;
      if Sender = EdPhone then
        EdMobPhone.SetFocus;
      if Sender = EdMobPhone then
        EdEMail.SetFocus;
      if Sender = EdEMail then
      begin
        if EdNewId.Enabled then
          EdNewId.SetFocus
        else if EdNewPasswd.Enabled then
          EdNewPasswd.SetFocus;
      end;

      if Sender = EdChgId then
        EdChgCurrentPw.SetFocus;
      if Sender = EdChgCurrentPw then
        EdChgNewPw.SetFocus;
      if Sender = EdChgNewPw then
        EdChgRepeat.SetFocus;
      if Sender = EdChgRepeat then
        EdChgId.SetFocus;
    end;
  end;
end;

procedure TLoginScene.EdNewOnEnter(Sender: TObject);
var
  hx, hy: integer;
begin
  FrmDlg.NAHelps.Clear;
  hx := TEdit(Sender).Left + TEdit(Sender).Width + 10;
  hy := TEdit(Sender).Top + TEdit(Sender).Height - 18;
  if Sender = EdNewId then
  begin
    FrmDlg.NAHelps.Add('���ID�������������ݵ���ϣ�');
    FrmDlg.NAHelps.Add('�ַ�������');
    FrmDlg.NAHelps.Add('ID����������4λ��');
    FrmDlg.NAHelps.Add('�����������������Ϸ�н�ɫ������');
    FrmDlg.NAHelps.Add('����ϸѡ�����ID,');
    FrmDlg.NAHelps.Add('��ĵ�½������');
    FrmDlg.NAHelps.Add(' �����������з�������');
    FrmDlg.NAHelps.Add('');
    FrmDlg.NAHelps.Add('���ǽ�������һ����ͬ��');
    FrmDlg.NAHelps.Add('���֣����������Ϸ��ɫ��');
    FrmDlg.NAHelps.Add('���Ǹ���������');
  end;
  if Sender = EdNewPasswd then
  begin
    FrmDlg.NAHelps.Add('������������һ��');
    FrmDlg.NAHelps.Add('��ϣ��������ַ�');
    FrmDlg.NAHelps.Add('�����֡�����');
    FrmDlg.NAHelps.Add('������Ҫ��4λ��');
    FrmDlg.NAHelps.Add('����������ס��');
    FrmDlg.NAHelps.Add('�����ǵ���Ϸ�������Ҫ��,');
    FrmDlg.NAHelps.Add('������ȷ�����Ѿ��Ǻ�������');
    FrmDlg.NAHelps.Add('���ǽ�������ò�Ҫ��');
    FrmDlg.NAHelps.Add('һ���򵥵�����');
    FrmDlg.NAHelps.Add('������һЩ');
    FrmDlg.NAHelps.Add('����ȫ����');
  end;
  if Sender = EdConfirm then
  begin
    FrmDlg.NAHelps.Add('�ٴ���������');
    FrmDlg.NAHelps.Add('��ȷ��');
  end;
  if Sender = EdYourName then
  begin
    FrmDlg.NAHelps.Add('�������ȫ��.');
  end;
  if Sender = EdSSNo then
  begin
    FrmDlg.NAHelps.Add('�����������֤��');
    FrmDlg.NAHelps.Add('���֤) 720101-146720');
  end;
  if Sender = EdBirthDay then
  begin
    FrmDlg.NAHelps.Add('�������ĳ������ں��·�');
    FrmDlg.NAHelps.Add('��/��/��/: 1977/10/15');
  end;
  if Sender = EdQuiz1 then
  begin
    FrmDlg.NAHelps.Add('������һ��������ʾ����');
    FrmDlg.NAHelps.Add('����ȷ,ֻ���㱾�˲�֪���������.');
    FrmDlg.NAHelps.Add('');
  end;
  if Sender = EdAnswer1 then
  begin
    FrmDlg.NAHelps.Add('���������������');
    FrmDlg.NAHelps.Add('�𰸡�');
  end;
  if Sender = EdQuiz2 then
  begin
    FrmDlg.NAHelps.Add('������һ��������ʾ����');
    FrmDlg.NAHelps.Add('����ȷ,ֻ���㱾�˲�֪���������.');
    FrmDlg.NAHelps.Add('');
  end;
  if Sender = EdAnswer2 then
  begin
    FrmDlg.NAHelps.Add('���������������');
    FrmDlg.NAHelps.Add('�𰸡�');
  end;
  if (Sender = EdYourName) or (Sender = EdSSNo) or (Sender = EdQuiz1) or (Sender = EdQuiz2) or (Sender = EdAnswer1) or (Sender = EdAnswer2) then
  begin
    FrmDlg.NAHelps.Add('�����������ȷ');
    FrmDlg.NAHelps.Add('����Ϣ��');
    FrmDlg.NAHelps.Add('���ʹ���˴�����Ϣ,');
    FrmDlg.NAHelps.Add('');
    FrmDlg.NAHelps.Add('�㽫���ܽ���');
    FrmDlg.NAHelps.Add('�������еķ���');
    FrmDlg.NAHelps.Add('������ṩ��');
    FrmDlg.NAHelps.Add('������Ϣ,����ʻ����� ');
    FrmDlg.NAHelps.Add('ȡ�� ��');
  end;

  if Sender = EdPhone then
  begin
    FrmDlg.NAHelps.Add('�������ĵ绰');
    FrmDlg.NAHelps.Add('����.');
  end;
  if Sender = EdMobPhone then
  begin
    FrmDlg.NAHelps.Add('���������ֻ�����.');
  end;
  if Sender = EdEMail then
  begin
    FrmDlg.NAHelps.Add('���������ʼ���ַ������ʼ�����');
    FrmDlg.NAHelps.Add('���ڷ������ǵ�һЩ��������');
    FrmDlg.NAHelps.Add('�����յ�������µ�һЩ');
    FrmDlg.NAHelps.Add('��Ϣ��');
  end;
end;

procedure TLoginScene.HideLoginBox;
begin
   //EdId.Visible := FALSE;
   //EdPasswd.Visible := FALSE;
   //FrmDlg.DLogin.Visible := FALSE;
  ChangeLoginState(lsCloseAll);
end;

procedure TLoginScene.OpenLoginDoor;
begin
  NowOpening := TRUE;
  StartTime := GetTickCount;
  HideLoginBox;
  PlaySound(s_rock_door_open);
end;

procedure TLoginScene.PlayScene(MSurface: TDXTexture);
var
  d: TDXTexture;
begin
   //if not ServerConnected then exit;
  if BoOpenFirst then
  begin
    BoOpenFirst := FALSE;
    EdId.Visible := TRUE;
    EdPasswd.Visible := TRUE;
    EdId.SetFocus;
  end;
  d := WChrSel.Images[102 - 80];
  if d <> nil then
  begin
    MSurface.Draw((g_FScreenWidth - d.Width) div 2, (g_FScreenHeight - d.Height) div 2, d.ClientRect, d, FALSE);
  end;
   //�����ٶ�
  if NowOpening then
  begin
    if GetTickCount - StartTime > 120 then
    begin
      StartTime := GetTickCount;
      Inc(CurFrame);
    end;
    if CurFrame >= MaxFrame - 1 then
    begin
      CurFrame := MaxFrame - 1;
      if not DoFadeOut and not DoFadeIn then
      begin
        DoFadeOut := TRUE;
        DoFadeIn := TRUE;
        FadeIndex := 29;
      end;
    end;
    d := WChrSel.Images[103 + CurFrame - 80];
    if d <> nil then
      MSurface.Draw((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 152, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 96, d.ClientRect, d, True);
    if DoFadeOut then
    begin
      if FadeIndex <= 1 then
      begin
//       WProgUse.ClearCache;
//       WChrSel.ClearCache;
        Sleep(500);
        DScreen.ChangeScene(stSelectChr);
      end;
    end;
  end;
end;

procedure TLoginScene.ChangeLoginState(state: TLoginState);
var
  i, focus: integer;
  c: TControl;
begin
  focus := -1;
  case state of
    lsLogin:
      focus := 10;
    lsNewIdRetry, lsNewId:
      focus := 11;
    lsChgpw:
      focus := 12;
    lsCloseAll:
      focus := -1;
  end;
  with FrmMain do
  begin  //login
    for i := 0 to ControlCount - 1 do
    begin
      c := Controls[i];
      if c is TEdit then
      begin
        if c.Tag in [10..12] then
        begin
          if c.Tag = focus then
          begin
            c.Visible := TRUE;
            TEdit(c).Text := '';
          end
          else
          begin
            c.Visible := FALSE;
            TEdit(c).Text := '';
          end;
        end;
      end;
    end;
    if not KoreanVersion then
      EdSSNo.Visible := FALSE;

    case state of
      lsLogin:
        begin
          FrmDlg.DNewAccount.Visible := FALSE;
          FrmDlg.DChgPw.Visible := FALSE;
          FrmDlg.DLogin.Visible := TRUE;
          if EdId.Visible then
            EdId.SetFocus;
        end;
      lsNewIdRetry, lsNewId:
        begin
          if BoUpdateAccountMode then
            EdNewId.Enabled := FALSE
          else
            EdNewId.Enabled := TRUE;
          FrmDlg.DNewAccount.Visible := TRUE;
          FrmDlg.DChgPw.Visible := FALSE;
          FrmDlg.DLogin.Visible := FALSE;
          if EdNewId.Visible and EdNewId.Enabled then
          begin
            EdNewId.SetFocus;
          end
          else
          begin
            if EdConfirm.Visible and EdConfirm.Enabled then
              EdConfirm.SetFocus;
          end;
        end;
      lsChgpw:
        begin
          FrmDlg.DNewAccount.Visible := FALSE;
          FrmDlg.DChgPw.Visible := TRUE;
          FrmDlg.DLogin.Visible := FALSE;
          if EdChgId.Visible then
            EdChgId.SetFocus;
        end;
      lsCloseAll:
        begin
          FrmDlg.DNewAccount.Visible := FALSE;
          FrmDlg.DChgPw.Visible := FALSE;
          FrmDlg.DLogin.Visible := FALSE;
        end;
    end;
  end;
end;

procedure TLoginScene.NewClick;
begin
  BoUpdateAccountMode := FALSE;
  FrmDlg.NewAccountTitle := '';
  ChangeLoginState(lsNewId);
end;

procedure TLoginScene.NewIdRetry(boupdate: Boolean);
begin
  BoUpdateAccountMode := boupdate;
  ChangeLoginState(lsNewidRetry);
  EdNewId.Text := NewIdRetryUE.LoginId;
  EdNewPasswd.Text := NewIdRetryUE.Password;
  EdYourName.Text := NewIdRetryUE.UserName;
  EdSSNo.Text := NewIdRetryUE.SSNo;
  EdQuiz1.Text := NewIdRetryUE.Quiz;
  EdAnswer1.Text := NewIdRetryUE.Answer;
  EdPhone.Text := NewIdRetryUE.Phone;
  EdEMail.Text := NewIdRetryUE.EMail;
  EdQuiz2.Text := NewIdRetryAdd.Quiz2;
  EdAnswer2.Text := NewIdRetryAdd.Answer2;
  EdMobPhone.Text := NewIdRetryAdd.MobilePhone;
  EdBirthDay.Text := NewIdRetryAdd.BirthDay;
end;

procedure TLoginScene.UpdateAccountInfos(ue: TUserEntryInfo);
begin
  NewIdRetryUE := ue;
  FillChar(NewIdRetryAdd, sizeof(TUserEntryAddInfo), #0);
  BoUpdateAccountMode := TRUE;
  NewIdRetry(TRUE);
  FrmDlg.NewAccountTitle := '(����д���ʻ���Ϣ�����б�������ݡ�)';
end;

procedure TLoginScene.OkClick;
var
  key: char;
begin
  key := #13;
  EdLoginPasswdKeyPress(self, key);
end;

procedure TLoginScene.ChgPwClick;
begin
  ChangeLoginState(lsChgPw);
end;

function TLoginScene.CheckUserEntrys: Boolean;
begin
  Result := FALSE;
  EdNewId.Text := Trim(EdNewId.Text);
  EdQuiz1.Text := Trim(EdQuiz1.Text);
  EdYourName.Text := Trim(EdYourName.Text);
  if not NewIdCheckNewId then
    exit;

  if KoreanVersion then
  begin
    if not NewIdCheckSSNo then
      exit;
  end;

  if not NewIdCheckBirthday then
    exit;
  if Length(EdNewId.Text) < 3 then
  begin
    EdNewId.SetFocus;
    exit;
  end;
  if Length(EdNewPasswd.Text) < 3 then
  begin
    EdNewPasswd.SetFocus;
    exit;
  end;
  if EdNewPasswd.Text <> EdConfirm.Text then
  begin
    EdConfirm.SetFocus;
    exit;
  end;
  if Length(EdQuiz1.Text) < 1 then
  begin
    EdQuiz1.SetFocus;
    exit;
  end;
  if Length(EdAnswer1.Text) < 1 then
  begin
    EdAnswer1.SetFocus;
    exit;
  end;
  if Length(EdQuiz2.Text) < 1 then
  begin
    EdQuiz2.SetFocus;
    exit;
  end;
  if Length(EdAnswer2.Text) < 1 then
  begin
    EdAnswer2.SetFocus;
    exit;
  end;
  if Length(EdYourName.Text) < 1 then
  begin
    EdYourName.SetFocus;
    exit;
  end;
  if KoreanVersion then
  begin
    if Length(EdSSNo.Text) < 1 then
    begin
      EdSSNo.SetFocus;
      exit;
    end;
  end;
  Result := TRUE;
end;

procedure TLoginScene.NewAccountOk;
var
   ue: TUserEntryInfo;
   ua: TUserEntryAddInfo;
begin
   if CheckUserEntrys then begin
      FillChar (ue, sizeof(TUserEntryInfo), #0);
      FillChar (ua, sizeof(TUserEntryAddInfo), #0);

      ue.LoginId := LowerCase(EdNewId.Text);

      ue.Password := EdNewPasswd.Text;
      ue.UserName := EdYourName.Text;
      //
      if KoreanVersion then
         ue.SSNo := EdSSNo.Text
      else
          ue.SSNo := '650101-1455111';

      ue.Quiz := EdQuiz1.Text;
      ue.Answer := Trim(EdAnswer1.Text);
      ue.Phone := EdPhone.Text;
      ue.EMail := Trim(EdEMail.Text);

      ua.Quiz2 := EdQuiz2.Text;
      ua.Answer2 := Trim(EdAnswer2.Text);
      ua.Birthday := EdBirthday.Text;
      ua.MobilePhone := EdMobPhone.Text;

      NewIdRetryUE := ue;    //��õ��� ���
      NewIdRetryUE.LoginId := '';
      NewIdRetryUE.Password := '';
      NewIdRetryAdd := ua;

      if not BoUpdateAccountMode then
         FrmMain.SendNewAccount (ue, ua)
      else
         FrmMain.SendUpdateAccount (ue, ua);
      BoUpdateAccountMode := FALSE;
      NewAccountClose;
   end;
end;


procedure TLoginScene.NewAccountClose;
begin
  if not BoUpdateAccountMode then
    ChangeLoginState(lsLogin);
end;

procedure TLoginScene.ChgpwOk;
var
  uid, passwd, newpasswd: string;
begin
  if EdChgNewPw.Text = EdChgRepeat.Text then
  begin
    uid := EdChgId.Text;
    passwd := EdChgCurrentPw.Text;
    newpasswd := EdChgNewPw.Text;
    FrmMain.SendChgPw(uid, passwd, newpasswd);
    ChgpwCancel;
  end
  else
  begin
    FrmDlg.DMessageDlg('����ȷ�ϲ���ȷ��', [mbOk]);
    EdChgNewPw.SetFocus;
  end;
end;

procedure TLoginScene.ChgpwCancel;
begin
  ChangeLoginState(lsLogin);
end;

{-------------------- TSelectChrScene ------------------------}
constructor TSelectChrScene.Create;
begin
  CreateChrMode := FALSE;
  FillChar(ChrArr, sizeof(TSelChar) * 2, #0);
  ChrArr[0].FreezeState := TRUE;
  ChrArr[1].FreezeState := TRUE;
  NewIndex := 0;
  EdChrName := TEdit.Create(FrmMain.Owner);
  with EdChrName do
  begin
    Parent := FrmMain;
    Height := 16;
    Width := 137;
    BorderStyle := bsNone;
    Color := clBlack;
    Font.Color := clWhite;
    ImeMode := LocalLanguage;
    MaxLength := 14;
    Visible := FALSE;
    OnKeyPress := EdChrnameKeyPress;
  end;
  SoundTimer := TTimer.Create(FrmMain.Owner);
  with SoundTimer do
  begin
    OnTimer := SoundOnTimer;
    Interval := 1;
    Enabled := FALSE;
  end;
  inherited Create(stSelectChr);
end;

destructor TSelectChrScene.Destroy;
begin
  inherited Destroy;
end;

procedure TSelectChrScene.OpenScene;
begin
  FrmDlg.DSelectChr.Visible := TRUE;
  SoundTimer.Enabled := TRUE;
  SoundTimer.Interval := 1;
end;

procedure TSelectChrScene.CloseScene;
begin
  SilenceSound;
  FrmDlg.DSelectChr.Visible := FALSE;
  SoundTimer.Enabled := FALSE;
end;

procedure TSelectChrScene.SoundOnTimer(Sender: TObject);
begin
  PlayBGM(bmg_select);
  SoundTimer.Enabled := FALSE;
   //SoundTimer.Interval := 38 * 1000;
end;

procedure TSelectChrScene.SelChrSelect1Click;
begin
  if CreateChrMode then
    SelChrNewClose;
  if (not ChrArr[0].Selected) and (ChrArr[0].Valid) then
  begin
    if ChrArr[0].Freezing then
       begin
          ChrArr[0].Freezing := FALSE;
          ChrArr[0].FreezeState := TRUE;
          ChrArr[0].aniIndex := 0;
       end;
    if ChrArr[1].Unfreezing then
       begin
          ChrArr[1].Unfreezing := FALSE;
          ChrArr[1].FreezeState := FALSE;
          ChrArr[1].aniIndex := 0;
       end;

    ChrArr[0].Selected := TRUE;
    ChrArr[1].Selected := FALSE;
    ChrArr[0].Unfreezing := TRUE;
    ChrArr[0].FireIng:=true;
    ChrArr[0].effIndex:=0;
    ChrArr[0].AniIndex := 0;
    ChrArr[0].DarkLevel := 0;
    ChrArr[0].EffIndex := 0;
    ChrArr[0].StartTime := GetTickCount;
    ChrArr[0].MoreTime := GetTickCount;
    ChrArr[0].StartEffTime := GetTickCount;
    PlaySound(s_meltstone);
  end;
end;

procedure TSelectChrScene.SelChrSelect2Click;
begin
  if (not ChrArr[1].Selected) and (ChrArr[1].Valid) then
  begin

    if ChrArr[1].Freezing then
       begin
          ChrArr[1].Freezing := FALSE;
          ChrArr[1].FreezeState := TRUE;
          ChrArr[1].aniIndex := 0;
       end;
    if ChrArr[0].Unfreezing then
       begin
          ChrArr[0].Unfreezing := FALSE;
          ChrArr[0].FreezeState := FALSE;
          ChrArr[0].aniIndex := 0;
       end;
    ChrArr[1].FireIng:=true;
    ChrArr[1].effIndex:=0;
    ChrArr[1].Selected := TRUE;
    ChrArr[0].Selected := FALSE;
    ChrArr[1].Unfreezing := TRUE;
    ChrArr[1].AniIndex := 0;
    ChrArr[1].DarkLevel := 0;
    ChrArr[1].EffIndex := 0;
    ChrArr[1].StartTime := GetTickCount;
    ChrArr[1].MoreTime := GetTickCount;
    ChrArr[1].StartEffTime := GetTickCount;
    PlaySound(s_meltstone);
  end;
end;

procedure TSelectChrScene.SelChrSelect3Click;
begin
  if (not ChrArr[2].Selected) and (ChrArr[2].Valid) then
  begin
    ChrArr[2].Selected := TRUE;
    ChrArr[0].Selected := FALSE;
    ChrArr[1].Selected := FALSE;
    ChrArr[2].Unfreezing := TRUE;
    ChrArr[2].AniIndex := 0;
    ChrArr[2].DarkLevel := 0;
    ChrArr[2].EffIndex := 0;
    ChrArr[2].StartTime := GetTickCount;
    ChrArr[2].MoreTime := GetTickCount;
    ChrArr[2].StartEffTime := GetTickCount;
    PlaySound(s_meltstone);
  end;
end;

procedure TSelectChrScene.SelChrStartClick;
var
  chrname: string;
begin
  chrname := '';
  if ChrArr[0].Valid and ChrArr[0].Selected then
  begin
    if ChrArr[0].UserChr.EncName = DecodeString(ChrArr[0].UserChr.EncEncName) then
      chrname := ChrArr[0].UserChr.EncName
    else
      Exit;
  end;
  if ChrArr[1].Valid and ChrArr[1].Selected then
  begin
    if ChrArr[1].UserChr.EncName = DecodeString(ChrArr[1].UserChr.EncEncName) then
      chrname := ChrArr[1].UserChr.EncName
    else
      Exit;
  end;

  if chrname <> '' then
  begin
      if not DoFadeOut and not DoFadeIn then
      begin
        DoFastFadeOut := TRUE;
        FadeIndex := 29;
      end;
      FrmMain.SendSelChr(chrname);
    end else
    FrmDlg.DMessageDlg('һ��ʼ��Ӧ�ô���һ���½�ɫ��\�����ѡ��<������ɫ>����ܽ���һ���½�ɫ�ˡ�', [mbOk]);
end;

procedure TSelectChrScene.SelChrNewChrClick;
begin
  if not ChrArr[0].Valid or not ChrArr[1].Valid then
  begin
    if not ChrArr[0].Valid then
      MakeNewChar(0)
    else
      MakeNewChar(1);
  end
  else
    FrmDlg.DMessageDlg('�����Ϊÿ���������ʻ�����������ɫ��', [mbOk]);
end;

procedure TSelectChrScene.SelChrEraseChrClick;
var
  n: integer;
  charname: string;
begin
  n := 0;
  if ChrArr[0].Valid and ChrArr[0].Selected then
    n := 0;
  if ChrArr[1].Valid and ChrArr[1].Selected then
    n := 1;
  charname := DecodeString(ChrArr[n].UserChr.EncName);
  if (ChrArr[n].Valid) and (not ChrArr[n].FreezeState) and (charname <> '') then
  begin
      //��� �޼����� ������.
    if mrYes = FrmDlg.DMessageDlg('"' + charname + '" ɾ���Ľ�ɫ�ǲ��ܱ��ָ��ġ�\һ��ʱ���ڣ��㽫����ʹ����ͬ�Ľ�ɫ����\�������Ҫɾ����ɫ��', [mbYes, mbNo]) then
      FrmMain.SendDelChr(ChrArr[n].UserChr.EncName);
  end;
end;

procedure TSelectChrScene.SelChrCreditsClick;
begin

  BoOneClick := FALSE;
  OneClickMode := toNone;
  with FrmMain do
  begin
    CSocket.Active := False;
    CSocket.Port := 7000;  //��¼����ͨѶ�˿�

    if MainParam1 = '' then
      CSocket.Address := SERVERADDR
    else
    begin
      if (MainParam1 <> '') and (MainParam2 = '') then
        CSocket.Address := MainParam1;
      if (MainParam2 <> '') and (MainParam3 = '') then
      begin
        CSocket.Address := MainParam1;
        CSocket.Port := Str_ToInt(MainParam2, 0);
      end;
      if (MainParam3 <> '') then
      begin
        if CompareText(MainParam1, '/KWG') = 0 then
        begin
          CSocket.Address := kornetworldaddress;  //game.megapass.net';
          CSocket.Port := 9000;
          BoOneClick := TRUE;
          OneClickMode := toKornetWorld;
          with KornetWorld do
          begin
            CPIPcode := MainParam2;
            SVCcode := MainParam3;
            LoginID := MainParam4;
            CheckSum := MainParam5; //'dkskxhdkslxlkdkdsaaaasa';
          end;
        end
        else
        begin
          CSocket.Address := MainParam2;
          CSocket.Port := Str_ToInt(MainParam3, 0);
          BoOneClick := TRUE;
        end;
      end;
    end;
    if BO_FOR_TEST then
      CSocket.Address := TESTSERVERADDR;
    CSocket.Active := True;
  end;
  DScreen.ChangeScene(stLogin);
  ConnectionStep := cnsLogin;
end;

procedure TSelectChrScene.SelChrExitClick;
begin
  FrmMain.Close;
end;

procedure TSelectChrScene.ClearChrs;
begin
  FillChar(ChrArr, sizeof(TSelChar) * 2, #0);
  ChrArr[0].FreezeState := FALSE;
  ChrArr[1].FreezeState := TRUE;
  ChrArr[0].Selected := TRUE;
  ChrArr[1].Selected := FALSE;
  ChrArr[0].UserChr.EncName := '';
  ChrArr[1].UserChr.EncName := '';
end;

procedure TSelectChrScene.AddChr(uname: string; job, hair, level, sex: integer);
var
  n: integer;
begin
  if not ChrArr[0].Valid then
    n := 0
  else if not ChrArr[1].Valid then
    n := 1
  else
    exit;
  ChrArr[n].UserChr.EncName := EncodeString(uname);
  ChrArr[n].UserChr.Job := job;
  ChrArr[n].UserChr.Hair := hair;
  ChrArr[n].UserChr.Level := level;
  ChrArr[n].UserChr.Sex := sex;
  ChrArr[n].Valid := TRUE;
  ChrArr[n].UserChr.EncEncName := EncodeString(EncodeString(uname));
end;

procedure TSelectChrScene.MakeNewChar(index: integer);
begin
{
   CreateChrMode := TRUE;
   NewIndex := index;
   FrmDlg.DCreateChr.Left := (SCREENWIDTH - FrmDlg.DCreateChr.Width) div 2 ;
   FrmDlg.DCreateChr.Top := 15;

   FrmDlg.DCreateChr.Tag := NewIndex;
   FrmDlg.DCreateChr.ShowModal;
}
  CreateChrMode := TRUE;
  NewIndex := index;
  if index = 0 then
  begin
    FrmDlg.DCreateChr.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 415;
    FrmDlg.DCreateChr.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 15;
  end
  else
  begin
    FrmDlg.DCreateChr.Left := (g_FScreenWidth - DEFSCREENWIDTH) div 2 + 75;
    FrmDlg.DCreateChr.Top := (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 15;
  end;

  FrmDlg.DCreateChr.Visible := TRUE;
  ChrArr[NewIndex].Valid := TRUE;
  ChrArr[NewIndex].FreezeState := FALSE;
  EdChrName.Left := FrmDlg.DCreateChr.Left + 71;
  EdChrName.Top := FrmDlg.DCreateChr.Top + 107;
  EdChrName.Visible := TRUE;
  EdChrName.SetFocus;
  SelectChr(NewIndex);
  FillChar(ChrArr[NewIndex].UserChr, sizeof(TUserCharacterInfo), #0);
end;

procedure TSelectChrScene.EdChrnameKeyPress(Sender: TObject; var Key: Char);
begin

end;

function TSelectChrScene.GetJobName(job: integer): string;
begin
  Result := '';
  case job of
    0:
      Result := '��ʿ';
    1:
      Result := 'ħ��ʦ';
    2:
      Result := '��ʿ';
  end;
end;

procedure TSelectChrScene.SelectChr(index: integer);
begin
  ChrArr[index].Selected := TRUE;
  ChrArr[index].DarkLevel := 30;
  ChrArr[index].starttime := GetTickCount;
  ChrArr[index].Moretime := GetTickCount;
  if index = 0 then
  begin
    ChrArr[1].Selected := FALSE;
    ChrArr[2].Selected := FALSE;
  end
  else if index = 1 then
  begin
    ChrArr[0].Selected := FALSE;
    ChrArr[2].Selected := FALSE;
  end
  else
  begin
    ChrArr[0].Selected := FALSE;
    ChrArr[1].Selected := FALSE;
  end;
end;

procedure TSelectChrScene.SelChrNewClose;
begin
  ChrArr[NewIndex].Valid := FALSE;
  ChrArr[NewIndex].Selected := FALSE;
// FrmDlg.DMessageDlg ('NewIndex=> '+IntToStr(NewIndex), [mbYes, mbNo]);
  CreateChrMode := FALSE;
  FrmDlg.DCreateChr.Visible := FALSE;
  EdChrName.Visible := FALSE;

//   SelChrSelect1Click;
//   if not ChrArr[0].Selected then begin
  ChrArr[0].Selected := TRUE;
  ChrArr[0].FreezeState := FALSE;
//   end;
end;

procedure TSelectChrScene.SelChrNewOk;
var
  chrname, shair, sjob, ssex: string;
begin
  chrname := Trim(EdChrName.Text);
  if chrname <> '' then
  begin
    ChrArr[NewIndex].Valid := FALSE;
    CreateChrMode := FALSE;
    FrmDlg.DCreateChr.Visible := FALSE;
    EdChrName.Visible := FALSE;

    ChrArr[0].Selected := TRUE;
    ChrArr[0].FreezeState := FALSE;

    shair := IntToStr(1 + Random(5)); //////****IntToStr(ChrArr[NewIndex].UserChr.Hair);
    sjob := IntToStr(ChrArr[NewIndex].UserChr.Job);
    ssex := IntToStr(ChrArr[NewIndex].UserChr.Sex);
    FrmMain.SendNewChr(FrmMain.LoginId, chrname, shair, sjob, ssex);
  end;
end;

procedure TSelectChrScene.SelChrNewJob(job: integer);
begin
  if (job in [0..2]) and (ChrArr[NewIndex].UserChr.Job <> job) then
  begin
    ChrArr[NewIndex].UserChr.Job := job;
    SelectChr(NewIndex);
  end;
end;

procedure TSelectChrScene.SelChrNewSex(sex: integer);
begin
  if sex <> ChrArr[NewIndex].UserChr.Sex then
  begin
    ChrArr[NewIndex].UserChr.Sex := sex;
    SelectChr(NewIndex);
  end;
end;

procedure TSelectChrScene.SelChrNewPrevHair;
begin
end;

procedure TSelectChrScene.SelChrNewNextHair;
begin
end;

procedure TSelectChrScene.PlayScene(MSurface: TDXTexture);
var
  n, bx, by, ex, ey, fx, fy, img: integer;
  d, e, dd: TDXTexture;
  svname: string;
begin
  d := WProgUse.Images[65];
  if d <> nil then
  begin
    MSurface.Draw((g_FScreenWidth - d.Width) div 2, (g_FScreenHeight - d.Height) div 2, d.ClientRect, d, FALSE);
  end;
  for n := 0 to 1 do
  begin
    if ChrArr[n].Valid then
    begin
      ex := 90;
      ey := 60 - 2;
      case ChrArr[n].UserChr.Job of
        0:
          begin
            if ChrArr[n].UserChr.Sex = 0 then
            begin
              bx := 71;
              by := 75 - 23; //��
              fx := bx;
              fy := by;
            end
            else
            begin
              bx := 65;
              by := 75 - 2 - 18;  //Ů
              fx := bx - 28 + 28;
              fy := by - 16 + 16;
            end;
          end;
        1:
          begin
            if ChrArr[n].UserChr.Sex = 0 then
            begin
              bx := 77;
              by := 75 - 29;
              fx := bx;
              fy := by;
            end
            else
            begin
              bx := 141 + 30;
              by := 85 + 14 - 2;
              fx := bx - 30;
              fy := by - 14;
            end;
          end;
        2:
          begin
            if ChrArr[n].UserChr.Sex = 0 then
            begin
              bx := 85;
              by := 75 - 12;
              fx := bx;
              fy := by;
            end
            else
            begin
              bx := 141 + 23;
              by := 85 + 20 - 2;
              fx := bx - 23;
              fy := by - 20;
            end;
          end;
      end;
      if n = 1 then
      begin
        ex := 430;
        ey := 60;
        bx := bx + 340;
        by := by + 2;
        fx := fx + 340;
        fy := fy + 2;
      end;
      if ChrArr[n].Unfreezing then
      begin
        img := 140 - 80 + ChrArr[n].UserChr.Job * 40 + ChrArr[n].UserChr.Sex * 120;
        d := WChrSel.Images[img + ChrArr[n].aniIndex];
//        e := WChrSel.Images[4 + ChrArr[n].effIndex];
        if d <> nil then
          MSurface.Draw((g_FScreenWidth - DEFSCREENWIDTH) div 2 + bx, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + by, d.ClientRect, d, TRUE);
//        if e <> nil then
//          DrawBlend(MSurface, (g_FScreenWidth - DEFSCREENWIDTH) div 2 + ex, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + ey, e, 1);
        if GetTickCount - ChrArr[n].starttime > 100 then
        begin
          ChrArr[n].starttime := GetTickCount;
          ChrArr[n].aniIndex := ChrArr[n].aniIndex + 1;
        end;
//        if GetTickCount - ChrArr[n].startefftime > 110 then
//        begin
//          ChrArr[n].startefftime := GetTickCount;
//          ChrArr[n].effIndex := ChrArr[n].effIndex + 1;
//               if ChrArr[n].effIndex > EFFECTFRAME-1 then           //ѡ���ɫ����
//                  ChrArr[n].effIndex := EFFECTFRAME-1;
//        end;
        if ChrArr[n].aniIndex > FREEZEFRAME - 1 then
        begin
          ChrArr[n].Unfreezing := FALSE;
          ChrArr[n].FreezeState := FALSE;
          ChrArr[n].aniIndex := 0;
        end;
      end
      else if not ChrArr[n].Selected and (not ChrArr[n].FreezeState and not ChrArr[n].Freezing) then
      begin
        ChrArr[n].Freezing := TRUE;
        ChrArr[n].aniIndex := 0;
        ChrArr[n].starttime := GetTickCount;
      end;
      if ChrArr[n].Freezing then
      begin
        img := 140 - 80 + ChrArr[n].UserChr.Job * 40 + ChrArr[n].UserChr.Sex * 120;
        d := WChrSel.Images[img + FREEZEFRAME - ChrArr[n].aniIndex - 1];
        if d <> nil then
          MSurface.Draw((g_FScreenWidth - DEFSCREENWIDTH) div 2 + bx, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + by, d.ClientRect, d, TRUE);
        if GetTickCount - ChrArr[n].starttime > 100 then
        begin
          ChrArr[n].starttime := GetTickCount;
          ChrArr[n].aniIndex := ChrArr[n].aniIndex + 1;
        end;
        if ChrArr[n].aniIndex > FREEZEFRAME - 1 then
        begin
          ChrArr[n].Freezing := FALSE;
          ChrArr[n].FreezeState := TRUE;
          ChrArr[n].aniIndex := 0;
        end;
      end;
      if not ChrArr[n].Unfreezing and not ChrArr[n].Freezing then
      begin
        if not ChrArr[n].FreezeState then
        begin
          img := 120 - 80 + ChrArr[n].UserChr.Job * 40 + ChrArr[n].aniIndex + ChrArr[n].UserChr.Sex * 120;
          d := WChrSel.Images[img];
          if d <> nil then
          begin
            if ChrArr[n].DarkLevel > 0 then
            begin
//                     dd := TDXTexture.Create (FrmMain.DXDraw1.DDraw);
//                     dd.SystemMemory := TRUE;
//                     dd.SetSize (d.Width, d.Height);
//                     dd.Draw (0, 0, d.ClientRect, d, FALSE);
//                     MakeDark (dd, 30-ChrArr[n].DarkLevel);
//                     MSurface.Draw (fx, fy, dd.ClientRect, dd, TRUE);
//                     dd.Free;
            end
            else
              MSurface.Draw((g_FScreenWidth - DEFSCREENWIDTH) div 2 + fx, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + fy, d.ClientRect, d, TRUE);

          end;
        end
        else
        begin    
          img := 140 - 80 + ChrArr[n].UserChr.Job * 40 + ChrArr[n].UserChr.Sex * 120;
          d := WChrSel.Images[img];
          if d <> nil then
            MSurface.Draw((g_FScreenWidth - DEFSCREENWIDTH) div 2 + bx, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + by, d.ClientRect, d, TRUE);
        end;
        if ChrArr[n].Selected then
        begin
          if GetTickCount - ChrArr[n].starttime > 300 then
          begin
            ChrArr[n].starttime := GetTickCount;
            ChrArr[n].aniIndex := ChrArr[n].aniIndex + 1;
            if ChrArr[n].aniIndex > SELECTEDFRAME - 1 then
              ChrArr[n].aniIndex := 0;
          end;
          if GetTickCount - ChrArr[n].moretime > 25 then
          begin
            ChrArr[n].moretime := GetTickCount;
            if ChrArr[n].DarkLevel > 0 then
              ChrArr[n].DarkLevel := ChrArr[n].DarkLevel - 1;
          end;
        end;
      end;
      if ChrArr[n].FireIng then
      begin
          e := WChrSel.Images[4 + ChrArr[n].effIndex];
          if e <> nil then
             DrawBlend(MSurface, (g_FScreenWidth - DEFSCREENWIDTH) div 2 + ex, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + ey, e, 1);
          if GetTickCount - ChrArr[n].startefftime > 100 then
          begin
            ChrArr[n].startefftime := GetTickCount;
            ChrArr[n].effIndex := ChrArr[n].effIndex + 1;
             if ChrArr[n].effIndex > EFFECTFRAME-1 then
                begin
                  ChrArr[n].FireIng:=false;
                  ChrArr[n].effIndex:=0;
                end;
          end;
      end;

      if n = 0 then
      begin
        if ChrArr[n].UserChr.EncName <> '' then
        begin
          with g_DXCanvas do
          begin
//                  SetBkMode (Canvas.Handle, TRANSPARENT);
            Textout((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 117, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 492 + 2, DecodeString(ChrArr[n].UserChr.EncName), clWhite);
            Textout((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 117, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 523, IntToStr(ChrArr[n].UserChr.Level), clWhite);
            Textout((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 117, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 553, GetJobName(ChrArr[n].UserChr.Job), clWhite);
//                  Canvas.Release;
          end;
        end;
      end
      else
      begin
        if ChrArr[n].UserChr.EncName <> '' then
        begin
          with g_DXCanvas do
          begin
//                  SetBkMode (Canvas.Handle, TRANSPARENT);
            Textout((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 671, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 492 + 4, DecodeString(ChrArr[n].UserChr.EncName), clWhite);
            Textout((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 671, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 525, IntToStr(ChrArr[n].UserChr.Level), clWhite);
            Textout((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 671, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 555, GetJobName(ChrArr[n].UserChr.Job), clWhite);
//                  Canvas.Release;
          end;
        end;
      end;
      with g_DXCanvas do
      begin
//            SetBkMode (Canvas.Handle, TRANSPARENT);
        if BO_FOR_TEST then
          svname := 'testserver '
        else
          svname := ServerName;
        TextOut((g_FScreenWidth - DEFSCREENWIDTH) div 2 + 405 - TextWidth(svname) div 2, (g_FScreenHeight - DEFSCREENHEIGHT) div 2 + 8, svname, clWhite);
//            Canvas.Release;
      end;
    end;
  end;
end;

{--------------------------- TLoginNotice ----------------------------}

constructor TLoginNotice.Create;
begin
  inherited Create(stLoginNotice);
end;

destructor TLoginNotice.Destroy;
begin
  inherited Destroy;
end;

end.

