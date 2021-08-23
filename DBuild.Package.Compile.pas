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
  Vcl.Forms, Registry, Windows, SysUtils, DateUtils, IOUtils, ShellAPI, DBuild.Utils, DBuild.Output;

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

  StartExe := Now;

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

    if CreateProcess(nil, PChar(AParams), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, ProcessInfo) then
    begin
      repeat
        AppRunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
        Application.ProcessMessages;

        if SecondsBetween(Now, StartExe) > 12 then
        begin
          TConsole.DebugInfo('CreateProcess timeout', []);
          Break;
        end;
      until (AppRunning <> WAIT_TIMEOUT);

      repeat
        BytesRead := 0;
        ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, BytesRead, nil);
        Buffer[BytesRead] := #0;
        OemToAnsi(Buffer, Buffer);
        TDBuildOutput.TryClose(APackage, String(Buffer));
      until (BytesRead < READ_BUFFER_SIZE);
    end
    else
      TConsole.DebugInfo('Can not create process to file %s', [AParams]);
    FreeMem(Buffer);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(readableEndOfPipe);
    CloseHandle(writeableEndOfPipe);
  end;
  TDBuildOutput.Close(APackage);
end;

class procedure TPackageCompile.Exec(const APackage: TPackage);
var
  Params: string;
begin
  if not Assigned(FArquivo) then
  begin
    Initialize;
    TDBuildOutput.Debug(TDBuildConfig.GetInstance.Variable.Values);
  end;

  try
    TDBuildOutput.Open(APackage);
    Params := CreateDefaultBatFile(APackage);
    Run(APackage, Params);
    TFile.Delete(Params);
  except
    on E: EDBuildException do
    begin
      if TDBuildConfig.GetInstance.Failure.Error then
      begin
        ExitCode := 1;
        raise;
      end;
    end;
    on E: Exception do
    begin
      TConsole.Error(E.Message);
      if TDBuildConfig.GetInstance.Failure.Error then
      begin
        ExitCode := 1;
        raise;
      end;
    end;
  end;
end;

class function TPackageCompile.CreateDefaultBatFile(const APackage: TPackage): string;
const
  COMMAND = 'MSBuild.exe /p:platform=%s /t:%s /p:config=%s;VersionAssembly=%s /p:DCC_BPLOutput="%s" /p:DCC_DCUOutput="%s" /p:DCC_DCPOutput="%s" %s "%s"';

  COMMAND_LOG = '%s /flp:logfile=logs/%s.log ';
var
  msExec, msLog: string;
begin
  if not TFile.Exists(APackage.Path) then
  begin
    TDBuildOutput.Close(APackage, Format('project "%s" not found', [APackage.Path]));
    exit;
  end;
  FArquivo.Clear;
//  FArquivo.Add(Format('call "%sBin\rsvars.bat"', [FDelphiInstallDir]));
  FArquivo.Add('');
  FArquivo.Add(Format('cd "%s"', [TPath.GetDirectoryName(TDBuildConfig.GetInstance.Compiler.MSBuild)]));

  msLog := Format(COMMAND_LOG, ['/v:Minimal', APackage.Name]);

  msExec := Format(COMMAND, [
    TDBuildConfig.GetInstance.Compiler.PlataformToStr,
    TDBuildConfig.GetInstance.Compiler.ActionToStr,
    TDBuildConfig.GetInstance.Compiler.Config,
    APackage.VersionToStr,
    TDBuildConfig.GetInstance.Compiler.BplOutput,
    TDBuildConfig.GetInstance.Compiler.DcuOutput,
    TDBuildConfig.GetInstance.Compiler.DcpOutput, msLog, APackage.Path]);

  FArquivo.Add(msExec);

  Result := GetRootDir + 'execute.bat';

  TConsole.DebugInfo('Command to execute = %s', [FArquivo.Text]);
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

  TConsole.DebugInfo('Delphi installed path = %s', [FDelphiInstallDir]);
  TDirectory.CreateDirectory(GetRootDir + 'Logs');
  FArquivo := TStringList.Create;
end;

class procedure TPackageCompile.ReleaseIstance;
begin
  FArquivo.Free;
end;

initialization

finalization

TPackageCompile.ReleaseIstance;

end.
