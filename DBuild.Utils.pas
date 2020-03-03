unit DBuild.Utils;

interface

uses
  IOUtils,
  SysUtils;

type
  EDBuildException = class(Exception);

function GetRootDir: string;

implementation

function GetRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
end;

end.
