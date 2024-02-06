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

  if FileExists(patchtemp) then begin  //껸땀넋埼긴뫘..
    if FileSize(patchtemp) > 140 * 1024 then begin //낚법寧땍돨댕鬼..
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
      MessageDlg ('뵙嶠포賈痰돨넋埼. Code='+IntToStr(ExitCode), mtWarning, [mbOk], 0);
      Application.Terminate;
      exit;
   end;}
//  end;

//{$ENDIF}

//1024	진단결과 메모리상에 해킹툴이 존재않을 경우
//1025	진단결과 메모리상에 해킹툴이 존재하나 정상적으로 치료를 했을 경우
//1026	진단결과 메모리상의 해킹툴을 감지했으나 사용자가 치료를 선택하지 않거나 프그램에서 치료를 정상적으로 하지 못했을 경우
//1027	해킹툴 진단 프로그램이 정상적으로 다운로드 되지 않았을 경우 URL이 잘못되었거나 서버가 정상적으로 동작하지 않을 경우
//1028	NPX.DLL 등록 에러 및 nProtect 구동에 필요한 파일이 없을 경우
//1029	프로그램내에서 예외사항이 발생했을 경우
//1030	사용자가 "종료" 버튼을 클릭했을 경우의 처리값
//1031	업데이트 서버 접속을 실패한 경우

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
           MessageDlg ('해킹 프로그램이 작동하고 있습니다. 미르의전설2를 실행킬 수 없습니다.', mtError, [mbOk], 0);
           Application.Terminate;
           exit;
        end;

     end else begin
        MessageDlg ('흙핫쇱꿎넋埼 ' + FindHackProgram + '轟랬獵契.', mtWarning, [mbOk], 0);
        Application.Terminate;
        exit;
     end;

  end;  }

{                // 쐐岺뜩역，혼딜�龜쬈▧�
  g_SingleInstance := TSingleInstance.Create;
  if (not g_SingleInstance.Initialize('Crazy4U')) then begin
     MessageDlg ('쐐岺頓契뜩몸넋埼', mtError, [mbOk], 0);
     Application.Terminate;
     exit;
  end;


  if CheckMirProgram then begin
     MessageDlg ('눈펜넋埼쇱꿴.', mtError, [mbOk], 0);
     Application.Terminate;
     exit;
  end;
 }

  Application.Initialize;
  Application.Title := 'legend of mir2';
  Application.MainFormOnTaskBar := True;       // 폘땡珂훨蛟으杰鞫刻돨넋埼츰냔
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TForm1, Form1);
  //  Application.CreateForm(TfrmDlgConfig, frmDlgConfig);
//  Application.CreateForm(TFrmDlg, FrmDlg);
 // Application.CreateForm(TFrmConfirmDlg, FrmConfirmDlg);
  // FrmMain.InitializeClient;

  Application.Run;

end.
