unit DBuild.Framework;

interface

uses
  SysUtils,
  DBuild.Config,
  DBuild.Console,
  DBuild.LibraryPath,
  DBuild.Package.Compile,
  DBuild.Package.Install,
  DBuild.Params,
  DBuild.Utils;

type
  TDBuild = class
  private
    function ValidatedParams: Boolean;
  public
    class procedure Execute;
  end;

implementation

Uses
  IOUtils;

{ TDBuild }

function TDBuild.ValidatedParams: Boolean;
begin
  Result := False;
  if not TFile.Exists(TDBuildParams.ConfigFileName) then
  begin
    TConsole.ErrorFmt('configuration file %s not found', [TDBuildParams.ConfigFileName]);
    exit;
  end;

  try
    TDBuildConfig.GetInstance.LoadConfig;
  except
    TConsole.ErrorFmt('Invalid configuration file %s', [TDBuildParams.ConfigFileName]);
    exit;
  end;

  if not TFile.Exists(TDBuildConfig.GetInstance.Compiler.MSBuild) then
  begin
    TConsole.Error('MSBuild not found');
    exit;
  end;
  Result := True;
end;

class procedure TDBuild.Execute;
var
  Build: TDBuild;
  Pack: TPackage;
begin
  Build := TDBuild.Create;
  try
    if not Build.ValidatedParams then
      exit;

    if TDBuildParams.ResetLibraryPath then
      TDelphiLibraryPath.Exec;

    if TDBuildParams.ExitAfterResetLibPath then
      exit;

    for Pack in TDBuildConfig.GetInstance.Packages do
    begin
      TPackageCompile.Exec(Pack);
//      if TDBuildConfig.GetInstance.Log.Level = OutputFile then
//      begin
//      end;
      if Pack.Installed then
        TPackageInstall.RegisterBPL(Pack);
    end;
  finally
    Build.Free;
  end;
end;

end.
