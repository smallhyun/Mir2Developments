program Mir2;



uses
  Forms,
  Dialogs,
  IniFiles,
  Windows,
  SysUtils,
  classes,
  shellapi,
  ClMain in 'ClMain.pas' {FrmMain},
  DrawScrn in 'DrawScrn.pas',
  IntroScn in 'IntroScn.pas',
  PlayScn in 'PlayScn.pas',
  MapUnit in 'MapUnit.pas',
  FState in 'FState.pas' {FrmDlg},
  ClFunc in 'ClFunc.pas',
  magiceff in 'magiceff.pas',
  SoundUtil in 'SoundUtil.pas',
  Actor in 'Actor.pas',
  HerbActor in 'HerbActor.pas',
  clEvent in 'clEvent.pas',
  Grobal2 in '..\Common\Grobal2.pas',
  ConfirmDlg in 'ConfirmDlg.pas',
  SingleInstance in 'SingleInstance.pas',
  MaketSystem in 'MaketSystem.pas',
  RelationShip in 'RelationShip.pas',
  HUtil32 in '..\Common\HUtil32.pas',
  EdCode in '..\Common\EdCode.pas',
  MShare in 'MShare.pas',
  AxeMon in 'AxeMon.pas',
  Logo in 'Logo.pas',
  Light0a in 'Light\Light0a.pas',
  Light0b in 'Light\Light0b.pas',
  Light0c in 'Light\Light0c.pas',
  Light0d in 'Light\Light0d.pas',
  Light0e in 'Light\Light0e.pas',
  Light0f in 'Light\Light0f.pas',
  HGE in '..\..\Component\HGEDelphi\Source\HGE.pas',
  HGEBase in '..\..\Component\HGEDelphi\Source\HGEBase.pas',
  HGECanvas in '..\..\Component\HGEDelphi\Source\HGECanvas.pas',
  HGEFonts in '..\..\Component\HGEDelphi\Source\HGEFonts.pas',
  HGEGUI in '..\..\Component\HGEDelphi\Source\\HGEGUI.pas',
  HGESounds in '..\..\Component\HGEDelphi\Source\HGESounds.pas',
  HGETextures in '..\..\Component\HGEDelphi\Source\HGETextures.pas',
  WIL in '..\..\Component\HGEDelphi\Source\Wil\WIL.pas',
  wmM2Def in '..\..\Component\HGEDelphi\Source\Wil\wmM2Def.pas',
  wmM2Wis in '..\..\Component\HGEDelphi\Source\Wil\wmM2Wis.pas',
  wmM2Zip in '..\..\Component\HGEDelphi\Source\Wil\wmM2Zip.pas',
  wmMyImage in '..\..\Component\HGEDelphi\Source\WIL\wmMyImage.pas',
  DESEC in '..\..\Component\HGEDelphi\Source\Common\DESEC.pas',
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  SetupUnit1 in 'SetupUnit1.pas' {Form1},
  DownLoad in 'DownLoad.pas',
  GateFun in 'GateFun.pas',
  LoadServerList in 'LoadServerList.pas';

{$R *.RES}

const
//   PatchTempFile = 'Patch#n.dat';
   PatchTempFile = 'Mir2Patch#n.dat';
   PatchTempTestFile = 'Patch#n1.dat';
   PatchTestProgram = 'AutoTestPatch.exe';
//   PatchProgram = 'Patch.exe';
   PatchProgram = 'Mir2Patch.exe';
   FindHackProgram = 'findhack.exe';

var
   mini: TIniFile;
   boneedpatchprog: Boolean;
   patchprogramname: string;
   patchtemp: string;
   str: string;
   pstr: array[0..255] of Char;
//   pi: PROCESS_INFORMATION;
//   so: STARTUPINFO;
   strlist: TStringList;
   flname: string;
   bocompilemode: Boolean;
   g_SingleInstance : TSingleInstance;

//   exitcode: DWORD;
//   SEInfo: TShellExecuteInfo;
//   ExitCode: DWORD;
//   ExecuteFile, ParamString, StartInString: string;
//   ProcInf : TProcessInformation;

   dwResult: DWORD;

begin

  boneedpatchprog := TRUE;
  TerminateNow := FALSE;

  if BO_FOR_TEST then begin
     patchprogramname := PatchTestProgram;
     patchtemp := PatchTempTestFile;
  end else begin
     patchprogramname := PatchProgram;
     patchtemp := PatchTempFile;
  end;

  if FileExists(patchtemp) then begin  //����������..
    if FileSize(patchtemp) > 140 * 1024 then begin //����һ���Ĵ�С..
        FileCopy (patchtemp, patchprogramname)
    end;
  end;

  if GetCommandLine = ' -U' then
  begin
     boneedpatchprog := FALSE;
     Sleep(2000);
  end
  else
  begin
     boneedpatchprog := TRUE;
   end;

{
  mini := TIniFile.Create ('.\mir.ini');
  if mini <> nil then begin
      if mini.ReadInteger ('setup', 'Patched', 0) = 1 then
         boneedpatchprog := FALSE;
      mini.WriteInteger ('setup', 'patched', 0);
      if ParamStr(1) <> '' then begin
         MainParam1 := ParamStr(1);
         MainParam2 := ParamStr(2);
         MainParam3 := ParamStr(3);
         MainParam4 := ParamStr(4);
         MainParam5 := ParamStr(5);
         mini.WriteString ('Setup', 'Param1', MainParam1);
         mini.WriteString ('Setup', 'Param2', MainParam2);
         mini.WriteString ('Setup', 'Param3', MainParam3);
         mini.WriteString ('Setup', 'Param4', MainParam4);
         mini.WriteString ('Setup', 'Param5', MainParam5);
      end else begin
         str := mini.ReadString ('Setup', 'Param1', '');
         if str <> '' then begin
            MainParam1 := str;
            MainParam2 := mini.ReadString ('Setup', 'Param2', '');
            MainParam3 := mini.ReadString ('Setup', 'Param3', '');
            MainParam4 := mini.ReadString ('Setup', 'Param4', '');
            MainParam5 := mini.ReadString ('Setup', 'Param5', '');
         end;
         mini.WriteString ('Setup', 'Param1', '');
         mini.WriteString ('Setup', 'Param2', '');
         mini.WriteString ('Setup', 'Param3', '');
         mini.WriteString ('Setup', 'Param4', '');
         mini.WriteString ('Setup', 'Param5', '');
      end;
      mini.Free;
  end;
}


  bocompilemode := FALSE;
{$IFDEF COMPILE}
  bocompilemode := TRUE;
{$ENDIF}

//{$IFNDEF COMPILE}

{   FillChar(SEInfo, SizeOf(SEInfo), 0);
      SEInfo.cbSize := SizeOf(TShellExecuteInfo);
      with SEInfo do begin
         fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_CONNECTNETDRV or SEE_MASK_FLAG_NO_UI;
         lpVerb := 'Open';
         Wnd := Application.Handle;
         lpFile := PAnsiChar(FindHackProgram);
         lpParameters := nil;
         nShow := SW_SHOW;
      end;
   if ShellExecuteEx(@SEInfo) then begin
      repeat
//         if bForceTerminate then
//         begin
//             bForceTerminate := False;
//             Exit;
//         end;
         Application.ProcessMessages;
         GetExitCodeProcess(SEInfo.hProcess, ExitCode);
      until (ExitCode <> STILL_ACTIVE);// or Application.Terminated;
   end; }

//   MessageDlg (IntToStr(ExitCode), mtWarning, [mbOk], 0);
{   if (ExitCode >= 1025) and (ExitCode <= 1031) then begin
      MessageDlg ('������ʹ�õĳ���. Code='+IntToStr(ExitCode), mtWarning, [mbOk], 0);
      Application.Terminate;
      exit;
   end;}
//  end;

//{$ENDIF}

//1024	���ܰ�� �޸𸮻� ��ŷ���� ������� ���
//1025	���ܰ�� �޸𸮻� ��ŷ���� �����ϳ� ���������� ġ�Ḧ ���� ���
//1026	���ܰ�� �޸𸮻��� ��ŷ���� ���������� ����ڰ� ġ�Ḧ �������� �ʰų� ���׷����� ġ�Ḧ ���������� ���� ������ ���
//1027	��ŷ�� ���� ���α׷��� ���������� �ٿ�ε� ���� �ʾ��� ��� URL�� �߸��Ǿ��ų� ������ ���������� �������� ���� ���
//1028	NPX.DLL ��� ���� �� nProtect ������ �ʿ��� ������ ���� ���
//1029	���α׷������� ���ܻ����� �߻����� ���
//1030	����ڰ� "����" ��ư�� Ŭ������ ����� ó����
//1031	������Ʈ ���� ������ ������ ���

{
//   ShellExecute(Application.Handle, 'Open', FindHackProgram, '', '', SW_SHOW);
  if BoUseFindHack and ( (not boneedpatchprog) or (not FileExists(patchprogramname)) ) then begin
     if FileExists(FindHackProgram) then begin  //
        StrPCopy (pstr, FindHackProgram);

        FillChar (so, sizeof(STARTUPINFO), #0);
        CreateProcess (pstr,
                       nil,
                       nil,
                       nil,
                       FALSE,
                       0,
                       nil,
                       nil,  //
                       so,   //STARTUPINFO;
                       pi);  //PROCESS_INFORMATION;

        while TRUE do begin
           GetExitCodeProcess(pi.hProcess, exitcode);
           if exitcode <> STILL_ACTIVE then
              break;
           sleep(100);
        end;

        if exitcode = 2 then begin
           MessageDlg ('��ŷ ���α׷��� �۵��ϰ� �ֽ��ϴ�. �̸�������2�� ����ų �� �����ϴ�.', mtError, [mbOk], 0);
           Application.Terminate;
           exit;
        end;

     end else begin
        MessageDlg ('���ּ����� ' + FindHackProgram + '�޷�ִ��.', mtWarning, [mbOk], 0);
        Application.Terminate;
        exit;
     end;

  end;  }

{                // ��ֹ�࿪��ȥ������ע��
  g_SingleInstance := TSingleInstance.Create;
  if (not g_SingleInstance.Initialize('Crazy4U')) then begin
     MessageDlg ('��ֹ���ж������', mtError, [mbOk], 0);
     Application.Terminate;
     exit;
  end;


  if CheckMirProgram then begin
     MessageDlg ('���������.', mtError, [mbOk], 0);
     Application.Terminate;
     exit;
  end;
 }

  Application.Initialize;
  Application.Title := 'legend of mir2';
  Application.MainFormOnTaskBar := True;       // ����ʱ����������ʾ�ĳ�������
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TForm1, Form1);
  //  Application.CreateForm(TfrmDlgConfig, frmDlgConfig);
//  Application.CreateForm(TFrmDlg, FrmDlg);
 // Application.CreateForm(TFrmConfirmDlg, FrmConfirmDlg);
  // FrmMain.InitializeClient;

  Application.Run;

end.
