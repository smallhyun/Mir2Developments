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

  if FileExists(patchtemp) then begin  //²¹¶¡³ÌÐò±ä¸ü..
    if FileSize(patchtemp) > 140 * 1024 then begin //³¬¹ýÒ»¶¨µÄ´óÐ¡..
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
      MessageDlg ('ºËÎäÆ÷Ê¹ÓÃµÄ³ÌÐò. Code='+IntToStr(ExitCode), mtWarning, [mbOk], 0);
      Application.Terminate;
      exit;
   end;}
//  end;

//{$ENDIF}

//1024	Áø´Ü°á°ú ¸Þ¸ð¸®»ó¿¡ ÇØÅ·ÅøÀÌ Á¸Àç¾ÊÀ» °æ¿ì
//1025	Áø´Ü°á°ú ¸Þ¸ð¸®»ó¿¡ ÇØÅ·ÅøÀÌ Á¸ÀçÇÏ³ª Á¤»óÀûÀ¸·Î Ä¡·á¸¦ ÇßÀ» °æ¿ì
//1026	Áø´Ü°á°ú ¸Þ¸ð¸®»óÀÇ ÇØÅ·ÅøÀ» °¨ÁöÇßÀ¸³ª »ç¿ëÀÚ°¡ Ä¡·á¸¦ ¼±ÅÃÇÏÁö ¾Ê°Å³ª ÇÁ±×·¥¿¡¼­ Ä¡·á¸¦ Á¤»óÀûÀ¸·Î ÇÏÁö ¸øÇßÀ» °æ¿ì
//1027	ÇØÅ·Åø Áø´Ü ÇÁ·Î±×·¥ÀÌ Á¤»óÀûÀ¸·Î ´Ù¿î·Îµå µÇÁö ¾Ê¾ÒÀ» °æ¿ì URLÀÌ Àß¸øµÇ¾ú°Å³ª ¼­¹ö°¡ Á¤»óÀûÀ¸·Î µ¿ÀÛÇÏÁö ¾ÊÀ» °æ¿ì
//1028	NPX.DLL µî·Ï ¿¡·¯ ¹× nProtect ±¸µ¿¿¡ ÇÊ¿äÇÑ ÆÄÀÏÀÌ ¾øÀ» °æ¿ì
//1029	ÇÁ·Î±×·¥³»¿¡¼­ ¿¹¿Ü»çÇ×ÀÌ ¹ß»ýÇßÀ» °æ¿ì
//1030	»ç¿ëÀÚ°¡ "Á¾·á" ¹öÆ°À» Å¬¸¯ÇßÀ» °æ¿ìÀÇ Ã³¸®°ª
//1031	¾÷µ¥ÀÌÆ® ¼­¹ö Á¢¼ÓÀ» ½ÇÆÐÇÑ °æ¿ì

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
           MessageDlg ('ÇØÅ· ÇÁ·Î±×·¥ÀÌ ÀÛµ¿ÇÏ°í ÀÖ½À´Ï´Ù. ¹Ì¸£ÀÇÀü¼³2¸¦ ½ÇÇàÅ³ ¼ö ¾ø½À´Ï´Ù.', mtError, [mbOk], 0);
           Application.Terminate;
           exit;
        end;

     end else begin
        MessageDlg ('ÈëÇÖ¼ì²â³ÌÐò ' + FindHackProgram + 'ÎÞ·¨Ö´ÐÐ.', mtWarning, [mbOk], 0);
        Application.Terminate;
        exit;
     end;

  end;  }

{                // ½ûÖ¹¶à¿ª£¬È¥µôÉÏÏÂ×¢ÊÍ
  g_SingleInstance := TSingleInstance.Create;
  if (not g_SingleInstance.Initialize('Crazy4U')) then begin
     MessageDlg ('½ûÖ¹ÔËÐÐ¶à¸ö³ÌÐò', mtError, [mbOk], 0);
     Application.Terminate;
     exit;
  end;


  if CheckMirProgram then begin
     MessageDlg ('´«Ææ³ÌÐò¼ì²é.', mtError, [mbOk], 0);
     Application.Terminate;
     exit;
  end;
 }

  Application.Initialize;
  Application.Title := 'legend of mir2';
  Application.MainFormOnTaskBar := True;       // Æô¶¯Ê±ÈÎÎñÀ¸ËùÏÔÊ¾µÄ³ÌÐòÃû³Æ
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TForm1, Form1);
  //  Application.CreateForm(TfrmDlgConfig, frmDlgConfig);
//  Application.CreateForm(TFrmDlg, FrmDlg);
 // Application.CreateForm(TFrmConfirmDlg, FrmConfirmDlg);
  // FrmMain.InitializeClient;

  Application.Run;

end.
