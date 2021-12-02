unit DBuild.Path;

interface

uses
  IOUtils, Registry, Classes, Windows, Vcl.Forms, DateUtils, RegularExpressions, SysUtils, DBuild.Interfaces;

type
  TDBUildPath = class(TInterfacedObject, IPaths)
  private
    function RootDir: string;
    function DelphiInstalation(var AVersion: string): string;
    function FormatSlash(const APath: string): string;
    function FormatEnvToBatFormat(const APath: string): string;
    function ReplaceEnvToValues(const APath: string): string;
    function DefaultOutputLogs: string;
    function DefaultOutputMetrics: string;
  public
    class function New: IPaths;
  end;

implementation


{ TDBUildPath }

uses DBuild.Console;

function TDBUildPath.DefaultOutputLogs: string;
begin
  Result := RootDir + 'logs\';
end;

function TDBUildPath.DefaultOutputMetrics: string;
begin
  Result := RootDir + 'metrics\';
end;

function TDBUildPath.DelphiInstalation(var AVersion: string): string;
const
  PATH_KEY = 'Software\Embarcadero\BDS';
var
  Reg: TRegistry;
  Versions: TStringList;
  I: Integer;

  function GetPath: string;
  begin
    try
      Reg.CloseKey;
      Reg.OpenKey(SysUtils.Format(PATH_KEY + '\%s', [AVersion]), false);
      Result := Reg.ReadString('rootdir');
      if not Result.IsEmpty then
      begin
        Reg.CloseKey;
        exit;
      end;
    except
      Result := '';
    end;
  end;

begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if not AVersion.IsEmpty then
    begin
      Result := GetPath;
      if not Result.IsEmpty then
        exit;
    end;

    Versions := TStringList.Create;
    try
      Reg.OpenKey(PATH_KEY, false);
      Reg.GetKeyNames(Versions);
      for I := Versions.count - 1 downto 0 do
      begin
        AVersion := Versions.Strings[I];
        Result := GetPath;
        if not Result.IsEmpty then
          break;
      end;
    finally
      Versions.Free;
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

function TDBUildPath.FormatEnvToBatFormat(const APath: string): string;
const
  REG_EX = '(?<=\$\()(.*?)(\))';
var
  MathRes: TMatch;
  VarName: string;
begin
  Result := APath;
  while (Result.IndexOf('$') > -1) do
  begin
    MathRes := TRegEx.Match(Result, REG_EX);
    if MathRes.Success and (MathRes.Groups.count > 0) then
    begin
      VarName := StringReplace(StringReplace(
        MathRes.Groups.Item[1].Value, '(', '', []), ')', '', []);
      Result := StringReplace(Result,
        SysUtils.Format('$(%s)', [VarName]), '%' + VarName + '%', [rfReplaceAll, rfIgnoreCase]);
    end;
  end;
end;

function TDBUildPath.FormatSlash(const APath: string): string;
begin
  Result := StringReplace(APath, '/', '\', [rfReplaceAll]);
end;

class function TDBUildPath.New: IPaths;
begin
  Result := TDBUildPath.Create;
end;

function TDBUildPath.ReplaceEnvToValues(const APath: string): string;
const
  REG_EX = '(?<=\$\()(.*?)(\))';
var
  MathRes: TMatch;
  VarName, VarValue: string;
begin
  Result := APath;
  while (Result.IndexOf('$') > -1) do
  begin
    MathRes := TRegEx.Match(Result, REG_EX);
    if MathRes.Success and (MathRes.Groups.count > 0) then
    begin
      VarName := StringReplace(StringReplace(
        MathRes.Groups.Item[1].Value, '(', '', []), ')', '', []);

      VarValue := GetEnvironmentVariable(VarName);
      Result := StringReplace(Result,
        SysUtils.Format('$(%s)', [VarName]), VarValue, [rfReplaceAll, rfIgnoreCase]);
    end;
  end;
end;

function TDBUildPath.RootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
end;

end.
