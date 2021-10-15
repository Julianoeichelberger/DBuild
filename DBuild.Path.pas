unit DBuild.Path;

interface

uses
  IOUtils, Registry, Classes, Windows, Vcl.Forms, DateUtils, RegularExpressions, SysUtils, DBuild.Interfaces;

type
  TDBUildPath = class(TInterfacedObject, IPaths)
  private
    function RootDir: string;
    function DelphiInstalation(var AVersion: string): string;
    function MsBuild(const ADelphiInstallPath: string; const AMSBuildDir: string): string;
    function Format(const APath: string; AEnvs: boolean = True): string;
    function FormatEnvToBatFile(const APath: string): string;
    function DefaultOutputLogs: string;
    function DefaultOutputMetrics: string;
  public
    class function New: IPaths;
  end;

implementation


{ TDBUildPath }

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

function TDBUildPath.Format(const APath: string; AEnvs: boolean): string;
const
  REG_EX = '(?<=\$\()(.*?)(\))';
var
  MathRes: TMatch;
  VarName, VarValue: string;
begin
  Result := StringReplace(APath, '/', '\', [rfReplaceAll]);
  if not AEnvs then
    exit;
  while (Result.IndexOf('$') > -1) do
  begin
    MathRes := TRegEx.Match(Result, REG_EX);
    if MathRes.Success and (MathRes.Groups.count > 0) then
    begin
      VarName := MathRes.Groups.Item[1].Value;
      VarValue := GetEnvironmentVariable(VarName);
      Result := StringReplace(Result,
        SysUtils.Format('$(%s)', [VarName]), VarValue, [rfReplaceAll, rfIgnoreCase]);
    end;
  end;
end;

function TDBUildPath.FormatEnvToBatFile(const APath: string): string;
begin
  Result := StringReplace(APath, '$(', '%', [rfReplaceAll]);
  Result := StringReplace(Result, ')', '%', [rfReplaceAll]);
end;

function TDBUildPath.MsBuild(const ADelphiInstallPath, AMSBuildDir: string): string;
const
  MsBuild = 'MSBuild.exe';
var
  FileBat: TStringList;
  FileName: string;
  Idx: Integer;
begin
  Result := AMSBuildDir;
  if Result.IsEmpty then
    Result := RootDir + MsBuild;

  FileName := IncludeTrailingPathDelimiter(ADelphiInstallPath) + 'Bin\rsvars.bat';
  if not TFile.Exists(Result) and TFile.Exists(FileName) then
  begin
    FileBat := TStringList.Create;
    try
      FileBat.LoadFromFile(FileName);
      FileBat.Find('@SET FrameworkDir=', Idx);
      if Idx > -1 then
        Result := IncludeTrailingPathDelimiter(FileBat.Strings[Idx].Split(['='])[1]) + MsBuild;
    finally
      FileBat.Free;
    end;
  end;
end;

class function TDBUildPath.New: IPaths;
begin
  Result := TDBUildPath.Create;
end;

function TDBUildPath.RootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
end;

end.
