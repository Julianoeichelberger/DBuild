unit DBuild.Package.Factory;

interface

uses
  DBuild.Interfaces, DBuild.Config.Classes;

type
  TPackageFactory = class(TInterfacedObject, IPackageFactory)
  private
    procedure ProcessStep(const AProcessor: IPackageAction);
    function CanExecute: boolean;
    procedure StartConsole(const APackageName: string);
    procedure EndConsole(const APackageName: string);
    procedure Execute;
  public
    class function New: IPackageFactory;
  end;

implementation

{ TPackageFactory }

uses
  DBuild.Console, DBuild.LibraryPath, DBuild.Package.Metrics, DBuild.Package.Compile, DBuild.Package.Install, DBuild.Config,
  DBuild.Utils, DBuild.Resources, DBuild.Params;

class function TPackageFactory.New: IPackageFactory;
begin
  Result := TPackageFactory.Create;
end;

procedure TPackageFactory.ProcessStep(const AProcessor: IPackageAction);
begin
  if not AProcessor.CanExecute then
    exit;
  AProcessor.BeforeExecute;
  try
    AProcessor.Execute;
  finally
    AProcessor.AfterExecute;
  end;
end;

procedure TPackageFactory.StartConsole(const APackageName: string);
begin
  TConsole.Output(RPad(sStartPackage, [APackageName], TConsole.LINE_LEN + 1, '*'), Normal);
end;

function TPackageFactory.CanExecute: boolean;
begin
  Result := TDBuildParams.Install or TDBuildParams.Metrics or TDBuildParams.Build;
end;

procedure TPackageFactory.EndConsole(const APackageName: string);
begin
  TConsole.Write('');
  TConsole.Output(RPad(sEndPackage, [APackageName], TConsole.LINE_LEN + 1, '*'), Normal);
  TConsole.Output(sLine, Normal);
  TConsole.Write('');
end;

procedure TPackageFactory.Execute;
var
  Current: TPackage;
begin
  ProcessStep(TDelphiLibraryPath.New);
  for Current in TConfig.Instance.Packages do
  begin
    StartConsole(Current.Name);
    try
      ProcessStep(TPackageCompile.New(Current));
      ProcessStep(TPackageInstall.New(Current));
      ProcessStep(TPackageMetrics.New(Current));
    finally
      EndConsole(Current.Name);
    end;
  end;
end;

end.
