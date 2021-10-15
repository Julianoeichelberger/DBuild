unit DBuild.Utils;

interface

uses
  IOUtils, Registry, Classes, Windows, Vcl.Forms, DateUtils, RegularExpressions, SysUtils;

const
  DEFAULT_PLATAFORM = 'Win32';
  DEFAULT_CONFIG = 'Debug';
  DEFAULT_ACTION = 'Build';
  DEFAULT_COMPILER_VERSION = '20.0';
  DEFAULT_BPL_OUTPUT_PATH = '$(BDSCOMMONDIR)\Bpl';
  DEFAULT_DCP_OUTPUT_PATH = '$(BDSCOMMONDIR)\Dcp';
  DEFAULT_DCU_OUTPUT_PATH = '$(BDSCOMMONDIR)\Dcu';
  DEFAULT_QA_OUTPUT_EXT = 'html';

type
  EDBuildException = class(Exception);

procedure RunCmd(var ALogOutput: string; const ACommand: string);
function RPad(AStr: string; AParams: array of const; ALen: Integer; AChar: Char): string;

implementation

function RPad(AStr: string; AParams: array of const; ALen: Integer; AChar: Char): string;
begin
  Result := Format(AStr, AParams);
  while Result.length < ALen do
    Result := Result + AChar;
end;

// https://stackoverflow.com/questions/9119999/getting-output-from-a-shell-dos-app-into-a-delphi-app
procedure RunCmd(var ALogOutput: string; const ACommand: string);
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
  ALogOutput := '';
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

    if CreateProcess(nil, PChar(ACommand), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, ProcessInfo) then
    begin
      repeat
        AppRunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
        Application.ProcessMessages;

        if SecondsBetween(Now, StartExe) > 12 then
          break;
      until (AppRunning <> WAIT_TIMEOUT);

      repeat
        BytesRead := 0;
        ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, BytesRead, nil);
        Buffer[BytesRead] := #0;
        OemToAnsi(Buffer, Buffer);
        ALogOutput := String(Buffer);
      until (BytesRead < READ_BUFFER_SIZE);
    end;
    FreeMem(Buffer);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(readableEndOfPipe);
    CloseHandle(writeableEndOfPipe);
  end;
end;

end.
