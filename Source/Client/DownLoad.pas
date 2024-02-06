unit DownLoad;

interface

uses
  Windows, SysUtils, Classes, ExtActns, WinInet, MyProbar,UnitLogin;

type
  UpdateThread = class(TThread)
    Downtxturl: string;
    B0, B1, B2, B3, B4: string;
    ProBarMax, ProBarPos,ProBarMax1, ProBarPos1: Cardinal;
    ReStartApp : Boolean;
    PBar1, PBar2: Imagebar;
  protected
    procedure Execute; override;
    function DownLoadFile(url, SavePath: string; Moder: Boolean): Boolean;
    procedure URL_OnDownloadProgress(Sender: TDownLoadURL; Progress, ProgressMax: Cardinal;
    StatusCode: TURLDownloadStatus; StatusText: string; var Cancel: Boolean);
    procedure ResetVcl;
    procedure ResetVcl_end;
  public
    constructor Create(url : string);
    destructor destroy; override;
  end;

    UpListinfo = record
    iFileName: string[255];
    iMd5: string[32]
  end;

  PUpListinfo = ^UpListinfo;

var
  _Isupdateing: Boolean = False;
  DefDir: string;

implementation


{$R ZIP.RES}
{$R BMP.RES}

uses
  MyAes, GateFun, sevenzip;
{============================================================================}
procedure MakeBat(IFILE: string);
begin
  try
    batFile.Clear;
    batFile.Add('@echo off');
    batFile.Add(Format('if not exist "%s" goto exitbat', [DefDir + 'TEMP\' + IFILE]));
    batFile.Add(':appdel');
    batFile.Add(Format('del "%s"',[ParamStr(0)]));
    batFile.Add(Format('if exist "%s" goto appdel', [ParamStr(0)]));
    batFile.Add(':appcopy');
    batFile.Add(Format('copy "%s" "%s"', [DefDir + 'TEMP\' + IFILE, DefDir]));
    batFile.Add(Format('if not exist "%s" goto appcopy', [DefDir + IFILE]));
    batFile.Add(Format('rd /s /q "%s"', [DefDir + 'TEMP']));
    batFile.Add(Format('start %s -NOUPDATE', [DefDir + IFILE]));
    batFile.Add(':exitbat');
    batFile.Add('del %0');
  finally
  end;
end;


function BytesToStr(iBytes: Integer): string;
var
  iKb: Integer;
begin
  iKb := Round(iBytes / 1024);
  if iKb > 1000 then
    Result := Format('%.2f MB', [iKb / 1024])
  else
    Result := Format('%d KB', [iKb]);
end;

function PercentageStr(iMax, iMin: Integer): string;
var
  r: Integer;
  s: Real;
begin
  if iMax > iMin then begin
    s := iMin / iMax;
    r := trunc(s * 100);
    Result := Q_IntToStr(r) + '%';
  end
  else begin
    Result := '100%';
  end;
end;


function GetUrlFileName(url: string): string;
begin
  url := StringReplace(StrRScan(PChar(url), '/'), '/', '', [rfReplaceAll]);
  if Pos('=', url) > 0 then
    url := StringReplace(StrRScan(PChar(url), '='), '=', '', [rfReplaceAll]);
  Result := url;
end;


function De7ZIP(const _Open, _Save: string): Boolean;
var
  Arch: I7zInArchive;
begin
  Arch := CreateInArchive(CLSID_CFormat7z);
  try
    Arch.OpenFile(_Open);
    Arch.ExtractTo(_Save);
    Result := True;
  except
    Result := False;
  end;
  Arch := nil;
end;

procedure DeleteIECacheALL;
var
  lpEntryInfo: PInternetCacheEntryInfo;
  hCacheDir: LongWord;
  dwEntrySize: LongWord;
  cachefile: string;
begin
  try
    dwEntrySize := 0;
    FindFirstUrlCacheEntry(nil, TInternetCacheEntryInfo(nil^), dwEntrySize);
    GetMem(lpEntryInfo, dwEntrySize);
    if dwEntrySize > 0 then
      lpEntryInfo^.dwStructSize := dwEntrySize;
    hCacheDir := FindFirstUrlCacheEntry(nil, lpEntryInfo^, dwEntrySize);
    if hCacheDir <> 0 then begin
      repeat
        if (lpEntryInfo^.CacheEntryType) and (NORMAL_CACHE_ENTRY) = NORMAL_CACHE_ENTRY then
          cachefile := pchar(lpEntryInfo^.lpszSourceUrlName);
        DeleteUrlCacheEntry(pchar(cachefile));
        FreeMem(lpEntryInfo, dwEntrySize);
        dwEntrySize := 0;
        FindNextUrlCacheEntry(hCacheDir, TInternetCacheEntryInfo(nil^), dwEntrySize);
        GetMem(lpEntryInfo, dwEntrySize);
        if dwEntrySize > 0 then
          lpEntryInfo^.dwStructSize := dwEntrySize;
      until not FindNextUrlCacheEntry(hCacheDir, lpEntryInfo^, dwEntrySize);
    end;
    FreeMem(lpEntryInfo, dwEntrySize);
    FindCloseUrlCache(hCacheDir);
  except
  end;
end;

constructor UpdateThread.Create(url : string);
begin
  _Isupdateing := True;
  inherited Create(False);
  PBar1 := nil;
  PBar2 := nil;
  PBar1 := Imagebar.Create(FrmLogin.img1);
  PBar2 := Imagebar.Create(FrmLogin.img2);
  Downtxturl := url;
  ReStartApp := False;
  FreeOnTerminate := True;
end;

destructor UpdateThread.destroy;
begin
  inherited;
  if PBar1 <> nil then PBar1.Free;
  if PBar2 <> nil then PBar2.Free;
  _Isupdateing := False;
  if ReStartApp then FrmLogin.ReStartup.Enabled := True else FrmLogin.NexTimer.Enabled := True;

end;

procedure ExtractRes;
var
  Res1: TResourceStream;
begin
  Res1 := TResourceStream.Create(HInstance, 'Mir3_ZIP', 'EXEFILE');
  try
    Res1.SavetoFile(GetCurrentDir + '/7z.dll');
  finally
    FreeAndNil(Res1);
  end;

end;

procedure UpdateThread.Execute;
var
  i, Lcount: Integer;
  DefDownPath, DefUpListPath, TmpDownPath, M5 , MyMd5: string;
  DefWebDir, tmp, iFile, iFileName, iFileDir, NextUrl, NextPath: string;
  Load: TMemoryStream;
  LoadPoint, NextPoint: Pointer;
  Next, SvrSize: DWORD;
  _List: UpListinfo;
begin
  try
    MyMd5 := GetFileMd5(ParamStr(0));
    DeleteIECacheALL;
    DefDownPath := DefDir + 'DownLoad\';
    TmpDownPath := DefDir + 'TEMP\';
    DefUpListPath := DefDir + 'DownLoad\UpList.txt';
    if not DirectoryExists(DefDownPath) then ForceDirectories(DefDownPath);
    if not DownLoadFile(Downtxturl, DefUpListPath, False) then Exit;
    if not FileExists(DefDir + '7z.dll') then ExtractRes;
    Load := TMemoryStream.Create;
    try
      if not DeAesFiletoMemStrmeam(DefUpListPath, Aes_Key, Load) then Exit;
      if Load.Size < SizeOf(UpListinfo) then Exit;
      tmp := GetUrlFileName(Downtxturl);
      DefWebDir := Copy(Downtxturl, 1, Q_PosStr(tmp, Downtxturl) - 1);
      Lcount := Load.Size div SizeOf(UpListinfo);
      ProBarMax1 := Lcount;
      LoadPoint := Load.Memory;
      Next := 0;
      SvrSize := SizeOf(UpListinfo);
      for i := 1 to Lcount do begin
        ProBarPos1 := i;
        NextPoint := Pointer(DWORD(LoadPoint) + Next);
        CopyMemory(@_List, NextPoint, SvrSize);
        Inc(Next, SvrSize);
        iFile := StringReplace(_List.iFileName, '.\', DefDir, []);
        iFileName := ExtractFileName(iFile);
        iFileDir := ExtractFilePath(iFile);
        M5 := _List.iMd5;
        B0 := Format('[ %d / %d ] "%s" ', [i, Lcount, iFileName]);
        if (GetFileMd5(iFile) <> M5) and (MyMd5 <> M5) then begin
          NextUrl := Format('%s%s.7z', [DefWebDir, iFileName]);
          NextPath := Format('%s%s.7z', [DefDownPath, iFileName]);
          if SameText(DefDir + 'Set00.dat', iFile) then ReStartApp := True;
          if SameText(iFileName, 'Mir2.exe') then begin   //更新登录器自身必须上传MIR2.EXE文件
            if not DirectoryExists(TmpDownPath) then ForceDirectories(TmpDownPath);
            iFileDir := TmpDownPath;
            ReStartApp := True;
            MakeBat(iFileName);
          end;
          if DownLoadFile(NextUrl, NextPath, True) then De7ZIP(NextPath, iFileDir);
        end
        else begin
          B1 := B0 + '跳过更新…';
          B2 := '';
        end;
        B4 := PercentageStr(Lcount, i);
        Synchronize(ResetVcl);
      end;
    finally
      FreeAndNil(Load);
    end;
  finally
    if DirectoryExists(DefDownPath) then DelDirectory(DefDownPath);
    Synchronize(ResetVcl_end);
  end;
end;

function UpdateThread.DownLoadFile(url, SavePath: string; Moder: Boolean): Boolean;
var
  DownLoadURL1: TDownLoadURL;
begin
  DownLoadURL1 := TDownLoadURL.Create(nil);
  try
    DownLoadURL1.URL := url;
    DownLoadURL1.Filename := SavePath;
    if Moder then DownLoadURL1.OnDownloadProgress := URL_OnDownloadProgress;
    DownLoadURL1.ExecuteTarget(nil);
    Result := True;
  except
    Result := False;
  end;
  FreeAndNil(DownLoadURL1);
end;

procedure UpdateThread.URL_OnDownloadProgress(Sender: TDownLoadURL; Progress, ProgressMax: Cardinal; StatusCode: TURLDownloadStatus; StatusText: string; var Cancel: Boolean);
begin
  try
    ProBarMax := ProgressMax div 100;
    ProBarPos := Progress div 100;
    case StatusCode of
      dsFindingResource:
        B1 := B0 + '正在从服务器查找资源…';
      dsConnecting:
        B1 := B0 + '正在确认补丁下载服务器…';
      dsBeginDownloadData:
        B1 := B0 + '准备下载文件…';
      dsDownloadingData:
        B1 := B0 + '下载中…';
      dsEndDownloadData:
        B1 := B0 + '下载完成…';
    end;
    B2 := Format('下载进度 : %s / %s', [BytesToStr(Progress), BytesToStr(ProgressMax)]);
    B3 := PercentageStr(ProBarMax, ProBarPos);
    Synchronize(ResetVcl);
  except
  end;
end;

procedure UpdateThread.ResetVcl;
begin
  if Length(B1) > 75 then B1 := Copy(B1 , 1 , 74) + '…';

  FrmLogin.Label3.Caption := B1;
  FrmLogin.Label4.Caption := B2;
  FrmLogin.Label5.Caption := B3;
  FrmLogin.Label6.Caption := B4;
  PBar1.Change(ProBarMax, ProBarPos);
  PBar2.Change(ProBarMax1, ProBarPos1);
end;

procedure UpdateThread.ResetVcl_end;
begin
  FrmLogin.Label3.Caption := '';
  FrmLogin.Label4.Caption := '';
  FrmLogin.Label5.Caption := '100%';
  FrmLogin.Label6.Caption := '100%';
  FrmLogin.suiImageButton2.Caption := '开始游戏';
  PBar1.Change(1, 1);
  PBar2.Change(1, 1);
end;

initialization
begin
  DefDir := GetCurrentDir + '\';
end;
end.

