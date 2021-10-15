unit DBuild.Package.Compile;

interface

uses
  Classes, DBuild.Interfaces, DBuild.Config, DBuild.Config.Classes, DBuild.Statistics;

type
  TPackageCompile = class(TInterfacedObject, IPackageAction)
  strict private
    FPackage: TPackage;
    FFileName: string;
    FOutputLog: string;
    function CreateDefaultBatFile: string;
    procedure Execute;
    function CanExecute: boolean;
    procedure AfterExecute;
    procedure BeforeExecute;
    procedure PrintResult(const Status: TBuildStatus);
  public
    constructor Create(APackage: TPackage);
    class function New(APackage: TPackage): IPackageAction;
  end;

implementation

Uses
  Vcl.Forms, Registry, Windows, SysUtils, DateUtils, IOUtils, ShellAPI, DBuild.Utils, DBuild.Console,
  DBuild.Params, DBuild.Path, DBuild.Resources;

{ TPackageCompile }

constructor TPackageCompile.Create(APackage: TPackage);
begin
  FPackage := APackage;
end;

class function TPackageCompile.New(APackage: TPackage): IPackageAction;
begin
  result := TPackageCompile.Create(APackage);
end;

procedure TPackageCompile.Execute;
begin
  RunCmd(FOutputLog, FFileName);
end;

procedure TPackageCompile.PrintResult(const Status: TBuildStatus);
const
  STATUS_STR: array [TBuildStatus] of string = (' SUCCESS', ' FAILED', ' UNKNOWN RESULT');
  STATUS_COLOR_INDEX: array [TBuildStatus] of Integer = (3, 1, 2);
begin
  TConsole.Output('');
  TConsole.Output(sResultArrow + TConfig.Instance.Compiler.Action.toUpper + STATUS_STR[Status],
    TConsoleColor(STATUS_COLOR_INDEX[Status]));
  TConsole.Output('');
end;

procedure TPackageCompile.AfterExecute;
var
  Status: TBuildStatus;
begin
  Status := TStatistic.EndPackage(FPackage, FOutputLog);
  PrintResult(Status);
  // TDBuildOutput.TryCloseBuild(FPackage, FOutputLog);

  if TFile.Exists(FFileName) then
    TFile.Delete(FFileName);

  if Status = TBuildStatus.Failed then
    raise EDBuildException.Create(TConfig.Instance.Compiler.Action + ' failed');

  TStatistic.WarningsLimitExceeded(FPackage);
end;

procedure TPackageCompile.BeforeExecute;
begin
  TConsole.Output(Format(sStartBuild, [TConfig.Instance.Compiler.Action, FPackage.Plataform]));
  TConsole.Output('');
  FFileName := CreateDefaultBatFile;
  TStatistic.InitPackage(FPackage);
end;

function TPackageCompile.CanExecute: boolean;
begin
  result := TDBuildParams.Build;
end;

function TPackageCompile.CreateDefaultBatFile: string;
var
  ExecCommand, LogCommnad: string;
  BatFile: TStringList;
begin
  BatFile := TStringList.Create;
  try
    BatFile.Add(Format(sDelphiEnvVariablesCommand, [TConfig.DelphiInstalationPath]));
    BatFile.Add('');
    BatFile.Add(Format('cd "%s"', [TPath.GetDirectoryName(TConfig.Instance.Compiler.MSBuild)]));

    LogCommnad := Format(sMSBuildLogCommand, [
      IncludeTrailingPathDelimiter(TDBUildPath.New.Format(TConfig.Instance.Compiler.LogOutput)), FPackage.Name]);

    ExecCommand := Format(sMSBuildCommand, [
      TConfig.Instance.Compiler.Plataform,
      TConfig.Instance.Compiler.Action,
      TConfig.Instance.Compiler.Config,
      TConfig.Instance.Compiler.BplOutput,
      TConfig.Instance.Compiler.DcuOutput,
      TConfig.Instance.Compiler.DcpOutput,
      LogCommnad,
      FPackage.Project]);

    BatFile.Add(TDBUildPath.New.FormatEnvToBatFile(ExecCommand));
    TConsole.Debug('Compile command', BatFile.Text);
    result := TDBUildPath.New.RootDir + 'execute.bat';
    BatFile.SaveToFile(result);
  finally
    BatFile.Free;
  end;
end;

end.
