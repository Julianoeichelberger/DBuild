unit DBuild.Utils;

interface

uses
  SysUtils;

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

function RPad(AStr: string; AParams: array of const; ALen: Integer; AChar: Char): string;
function FmtWndEnv(const APath: string): string;

implementation

function RPad(AStr: string; AParams: array of const; ALen: Integer; AChar: Char): string;
begin
  Result := Format(AStr, AParams);
  while Result.length < ALen do
    Result := Result + AChar;
end;

function FmtWndEnv(const APath: string): string;
begin

end;

end.
