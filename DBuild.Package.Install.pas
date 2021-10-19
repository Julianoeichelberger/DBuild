unit DBuild.Package.Install;

interface

uses
  Registry, Windows, SysUtils, DBuild.Interfaces, DBuild.Config.Classes, DBuild.Config;

type
  TPackageInstall = class(TInterfacedObject, IPackageAction)
  strict private
    FPackage: TPackage;
    FReg: TRegistry;
    FFileName: string;
  private
    procedure Execute;
    function CanExecute: Boolean;
    procedure AfterExecute;
    procedure BeforeExecute;
    procedure PrintResult;
  public
    constructor Create(APackage: TPackage);
    class function New(APackage: TPackage): IPackageAction;
  end;

implementation

{ TPackageInstall }

uses
  DBuild.Console, DBuild.Params, DBuild.Resources, DBuild.Path;

constructor TPackageInstall.Create(APackage: TPackage);
begin
  FReg := TRegistry.Create;
  FPackage := APackage;
end;

class function TPackageInstall.New(APackage: TPackage): IPackageAction;
begin
  result := TPackageInstall.Create(APackage);
end;

procedure TPackageInstall.AfterExecute;
begin
  FReg.CloseKey;
  FReg.Free;
end;

procedure TPackageInstall.BeforeExecute;
const
  PATH_KEY = 'Software\Embarcadero\BDS\%s\Known Packages';
begin
  try
    FReg.RootKey := HKEY_CURRENT_USER;
    FReg.OpenKey(Format(PATH_KEY, [TConfig.Instance.Compiler.Version]), True);
  except
    On E: Exception do
      TConsole.ErrorFmt('Error on open windows registry [%s]', [E.message]);
  end;
  FFileName := Format('%s%s.bpl', [TDBUildPath.New.ReplaceEnvToValues(
    IncludeTrailingPathDelimiter(TConfig.Instance.Compiler.BplOutput)), FPackage.Name]);
end;

function TPackageInstall.CanExecute: Boolean;
begin
  result := TDBuildParams.Install and FPackage.Installed;
end;

procedure TPackageInstall.PrintResult;
begin
  TConsole.Output('');
  if not FReg.ReadString(FFileName).Contains('not found') then
    TConsole.Output(sResultArrow + 'INSTALATION SUCCESS', Green)
  else
  begin
    TConsole.Output(Format(sBplNotFound, [FFileName]), Red);
    TConsole.Output(sResultArrow + 'INSTALATION FAILED', Red);
  end;
  TConsole.Output('');
end;

procedure TPackageInstall.Execute;
begin
  try
    if not TDBuildParams.IsDebug then
    begin
      FReg.WriteString(FFileName, FPackage.Name);
      PrintResult;
    end;
    TConsole.Debug('Install package', FReg.ReadString(FFileName));
  except
    TConsole.ErrorFmt('Error on write %s in windows registry', [FFileName]);
  end;
end;

end.
