unit DBuild.Package.Metrics;

interface

uses
  DBuild.Interfaces, DBuild.Config.Classes;

type
  TPackageMetrics = class(TInterfacedObject, IPackageAction)
  private
    FPackage: TPackage;
    FFileName: string;
    function CreateDefaultBatFile: string;
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

uses
  IOUtils, Classes, SysUtils, DBuild.Resources, DBuild.ShellExecute, DBuild.Utils, DBuild.Config, DBuild.Console, DBuild.Params,
  DBuild.Path;

{ TPackageMetrics }

procedure TPackageMetrics.PrintResult;
begin
  TConsole.Output('');
  if TFile.Exists(FFileName) then
    TConsole.Output(sResultArrow + 'METRICS SUCCESS', Green)
  else
  begin
    TConsole.Output(Format(sOutputMetricsFileNotFound, [FFileName]), Red);
    TConsole.Output(sResultArrow + 'METRICS FAILED', Red);
  end;
  TConsole.Output('');
end;

procedure TPackageMetrics.AfterExecute;
begin
  PrintResult;
  if TFile.Exists(FFileName) then
    TFile.Delete(FFileName);
end;

procedure TPackageMetrics.BeforeExecute;
begin
  TConsole.Output(sStartMetrics);
  TConsole.Output('');
  FFileName := CreateDefaultBatFile;
end;

function TPackageMetrics.CanExecute: Boolean;
begin
  Result := TConfig.Instance.Metrics.Active and TDBuildParams.Metrics;
end;

constructor TPackageMetrics.Create(APackage: TPackage);
begin
  FPackage := APackage;
end;

class function TPackageMetrics.New(APackage: TPackage): IPackageAction;
begin
  Result := TPackageMetrics.Create(APackage);
end;

function TPackageMetrics.CreateDefaultBatFile: string;
var
  ExecCommand: string;
  BatFile: TStringList;
begin
  if FPackage.UnitsPaths.IsEmpty then
  begin
    TConsole.ErrorFmt(sMetricsSourceNotFound, [FPackage.Name]);
    exit('');
  end;

  BatFile := TStringList.Create;
  try
    BatFile.Add(Format('cd "%s"', [TConfig.DelphiInstalationPath]));

    ExecCommand := Format(sMetricsCommand, [TConfig.Instance.Metrics.OutputExt,
      TDBUildPath.New.ReplaceEnvToValues(TConfig.Instance.Metrics.OutputPath),
      FPackage.Name, FPackage.UnitsPaths, FPackage.Project]);

    BatFile.Add(ExecCommand);
    TConsole.Debug('Metrics command', BatFile.Text);
    Result := TDBUildPath.New.RootDir + 'metrics.bat';
    BatFile.SaveToFile(Result);
  finally
    BatFile.Free;
  end;
end;

procedure TPackageMetrics.Execute;
begin
  RunCmdAndWait(FFileName);
end;

end.
