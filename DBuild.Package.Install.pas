unit DBuild.Package.Install;

interface

uses
  Registry,
  Windows,
  SysUtils,
  DBuild.Config;

type
  TPackageInstall = class
  strict private
    class var FReg: TRegistry;
    class var FIsOpened: Boolean;
    class function OpenedInstallPackageKey: Boolean;
  private
    class procedure Initialize;
    class procedure ReleaseIstance;
  public
    class procedure RegisterBPL(const APackage: TPackage);
  end;

implementation

{ TPackageInstall }

uses
  DBuild.Console;

class procedure TPackageInstall.Initialize;
begin
  FReg := TRegistry.Create;
end;

class function TPackageInstall.OpenedInstallPackageKey: Boolean;
const
  PATH_KEY = 'Software\Embarcadero\BDS\%s\Known Packages';
var
  Path: string;
begin
  Result := False;
  Path := Format(PATH_KEY, [TDBuildConfig.GetInstance.Compiler.Version]);
  try
    FReg.RootKey := HKEY_CURRENT_USER;
    Result := FReg.OpenKey(Path, True);
  except
    On E: Exception do
      TConsole.ErrorFmt('Error on open %s windows registry', [Path]);
  end;
end;

class procedure TPackageInstall.RegisterBPL(const APackage: TPackage);
const
  BPL_COMMMON_DIR = '$(BDSCOMMONDIR)\Bpl\';
var
  BplName: string;
begin
  if not FIsOpened then
    FIsOpened := OpenedInstallPackageKey;

  if FIsOpened then
  begin
    try
      BplName := Format('%s%s.bpl', [IncludeTrailingPathDelimiter(TDBuildConfig.GetInstance.Compiler.BplOutput), APackage.Name]);

      FReg.WriteString(BplName, APackage.Name);
    except
      On E: Exception do
        TConsole.ErrorFmt('Error on write %s in windows registry', [BplName]);
    end;
  end;
end;

class procedure TPackageInstall.ReleaseIstance;
begin
  if FIsOpened then
    FReg.CloseKey;
  FReg.Free;
end;

initialization

TPackageInstall.Initialize;

finalization

TPackageInstall.ReleaseIstance;

end.
