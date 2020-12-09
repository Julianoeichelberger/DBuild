unit DBuild.Utils;

interface

uses
  IOUtils,
  SysUtils;

type
  EDBuildException = class(Exception);

function GetRootDir: string;
function FormatPathByVariable(APath, AName, AValue: string; AIsSO: Boolean): string;

implementation

function GetRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
end;

function FormatPathByVariable(APath, AName, AValue: string; AIsSO: Boolean): string;
Var
  Value: string;
begin
  Value := AValue;
  if AIsSO then
  begin
    Value := StringReplace(Value, '$(', '', []);
    Value := StringReplace(Value, ')', '', []);
    Value := GetEnvironmentVariable(Value);
  end;
  Result := StringReplace(APath, AName, Value, [rfReplaceAll, rfIgnoreCase]);
end;

end.
