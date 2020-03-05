unit DBuild.Package.Compile;

interface

uses
  Classes,
  DBuild.Config,
  DBuild.Console;

type
  TPackageCompile = class
  strict private
    class var FDelphiInstallDir: string;
    class var FArquivo: TStringList;
    class function CreateDefaultBatFile(const APackage: TPackage): string;
    class procedure Run(const APackage: TPackage; const AParams: string);
  private
    class procedure Initialize;
    class procedure ReleaseIstance;
  public
    class procedure Exec(const APackage: TPackage);
  end;

implementation

Uses
  Vcl.Forms,
  Registry,
  Windows,
  SysUtils,
  DateUtils,
  IOUtils,
  ShellAPI,
  DBuild.Utils, DBuild.Output;

{ TPackageCompile }

// https://stackoverflow.com/questions/9119999/getting-output-from-a-shell-dos-app-into-a-delphi-app
class procedure TPackageCompile.Run(const APackage: TPackage; const AParams: string);
const
  READ_BUFFER_SIZE = 2400;
var
  Security: TSecurityAttributes;
  readableEndOfPipe, writeableEndOfPipe: THandle;
  start: TStartUpInfo;
  ProcessInfo: TProcessInformation;
  Buffer: PAnsiChar;
  BytesRead, AppRunning: DWORD;
  StartExe: TDateTime;
begin
  Security.nLength := SizeOf(TSecurityAttributes);
  Security.bInheritHandle := True;
  Security.lpSecurityDescriptor := nil;

  if CreatePipe(readableEndOfPipe, writeableEndOfPipe, @Security, 0) then
  begin
    Buffer := AllocMem(READ_BUFFER_SIZE + 1);
    FillChar(start, SizeOf(start), #0);
    start.cb := SizeOf(start);

    start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
    start.hStdInput := GetStdHandle(STD_INPUT_HANDLE);

    start.hStdOutput := writeableEndOfPipe;
    start.hStdError := writeableEndOfPipe;
    start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;

    ProcessInfo := Default (TProcessInformation);

    StartExe := Now;
    if CreateProcess(nil, PChar(AParams), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, ProcessInfo) then
    begin
      repeat
        AppRunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
        Application.ProcessMessages;

        if SecondsBetween(Now, StartExe) > 12 then
          Break;
      until (AppRunning <> WAIT_TIMEOUT);

      repeat
        BytesRead := 0;
        ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, BytesRead, nil);
        Buffer[BytesRead] := #0;
        OemToAnsi(Buffer, Buffer);
        TDBuildOutput.Exec(APackage, String(Buffer));
      until (BytesRead < READ_BUFFER_SIZE);
    end;
    FreeMem(Buffer);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(readableEndOfPipe);
    CloseHandle(writeableEndOfPipe);
  end;
end;

class procedure TPackageCompile.Exec(const APackage: TPackage);
var
  Params: string;
begin
  if not Assigned(FArquivo) then
    Initialize;
  try
    Params := CreateDefaultBatFile(APackage);
    Run(APackage, Params);
    TFile.Delete(Params);
    // if TDBuildConfig.GetInstance.Log.Level = TLogLevel.OutputFile then
    // TDBuildOutput.Exec(APackage);
  except
    on E: Exception do
      TConsole.Error(E.Message);
  end;
end;

class function TPackageCompile.CreateDefaultBatFile(const APackage: TPackage): string;
const
  COMMAND = '%s /p:platform=%s /t:%s /p:config=%s /p:DCC_BPLOutput="%s" /p:DCC_DCUOutput="%s" /p:DCC_DCPOutput="%s" %s "%s"';

  COMMAND_LOG = '%s /flp:logfile=logs/%s.log ';
var
  msExec, msLog: string;
begin
  FArquivo.Clear;
  FArquivo.Add(Format('call "%sBin\rsvars.bat"', [FDelphiInstallDir]));
  FArquivo.Add('');

  msLog := '';
  if TDBuildConfig.GetInstance.Log.Level <> TLogLevel.OutputFile then
    msLog := Format(' /v:%s', [TDBuildConfig.GetInstance.Log.LevelStr]);

  msLog := Format(COMMAND_LOG, [msLog, APackage.Name]);

  msExec := Format(COMMAND, [TDBuildConfig.GetInstance.Compiler.MSBuild, TDBuildConfig.GetInstance.Compiler.PlataformToStr,
    TDBuildConfig.GetInstance.Compiler.ActionToStr, TDBuildConfig.GetInstance.Compiler.Config,
    TDBuildConfig.GetInstance.Compiler.BplOutput, TDBuildConfig.GetInstance.Compiler.DcuOutput,
    TDBuildConfig.GetInstance.Compiler.DcpOutput, msLog, APackage.Path]);

  FArquivo.Add(msExec);

  Result := GetRootDir + 'execute.bat';
  FArquivo.SaveToFile(Result);
end;

class procedure TPackageCompile.Initialize;
const
  PATH_KEY = 'Software\Embarcadero\BDS\%s';
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey(Format(PATH_KEY, [TDBuildConfig.GetInstance.Compiler.Version]), false);
    FDelphiInstallDir := Reg.ReadString('rootdir');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;

  TDirectory.CreateDirectory(GetRootDir + 'Logs');
  FArquivo := TStringList.Create;
end;

class procedure TPackageCompile.ReleaseIstance;
begin
  FArquivo.Free;
end;

initialization

// TPackageCompile.Initialize;

finalization

TPackageCompile.ReleaseIstance;

end.
