unit DBuild.Framework;

interface

uses
  SysUtils,
  DBuild.Config,
  DBuild.Console,
  DBuild.LibraryPath,
  DBuild.Package.Compile,
  DBuild.Package.Install,
  DBuild.Params;

type
  TDBuild = class
  private
    function ValidatedParams: Boolean;
  public
    class procedure Execute;
  end;

implementation

Uses
  IOUtils, DBuild.Output;

{ TDBuild }

function TDBuild.ValidatedParams: Boolean;
begin
  Result := False;
  if not TFile.Exists(TDBuildParams.ConfigFileName) then
  begin
    TConsole.PrintErrorResult(format('configuration file %s not found', [TDBuildParams.ConfigFileName]));
    ExitCode := 1;
    exit;
  end;

  try
    TDBuildConfig.GetInstance.LoadConfig;
  except
    TConsole.PrintErrorResult(format('Invalid configuration file %s', [TDBuildParams.ConfigFileName]));
    ExitCode := 1;
    exit;
  end;

  if not TFile.Exists(TDBuildConfig.GetInstance.Compiler.MSBuild) then
  begin
    TConsole.PrintErrorResult('MSBuild not found');
    ExitCode := 1;
    exit;
  end;
  Result := True;
end;

class procedure TDBuild.Execute;
var
  Build: TDBuild;
  Pack: TPackage;
begin
  TConsole.Banner;
  Build := TDBuild.Create;
  try
    if not Build.ValidatedParams then
      exit;

    if TDBuildParams.UpdateLibraryPath then
      TDelphiLibraryPath.New.Update;

    if not TDBuildParams.Enabled then
      exit;
    for Pack in TDBuildConfig.GetInstance.Packages do
    begin
      TPackageCompile.Exec(Pack);
      // if TDBuildConfig.GetInstance.Log.Level = OutputFile then
      // begin
      // end;
      if Pack.Installed then
        TPackageInstall.RegisterBPL(Pack);
    end;
    TDBuildOutput.ShowResult;
  finally
    Build.Free;
  end;
end;

end.
