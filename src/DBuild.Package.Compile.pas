unit DBuild.Package.Compile;

interface

uses
  Classes, DBuild.Interfaces, DBuild.Config.Classes, DBuild.Statistics;

type
  TPackageCompile = class(TInterfacedObject, IPackageAction)
  strict private
    FPackage: TPackage;
    FFileName: string;
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
  Vcl.Forms, Registry, Windows, SysUtils, DateUtils, IOUtils, ShellAPI, DBuild.ShellExecute, DBuild.Console,
  DBuild.Utils, DBuild.Config, DBuild.Params, DBuild.Path, DBuild.Resources;

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
  RunCmdAndWait(FFileName);
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
  LogFile: TStringList;
  FileName: string;
begin
  Status := TBuildStatus.Unknown;
  LogFile := TStringList.Create;
  try
    FileName :=
      TDBuildPath.New.ReplaceEnvToValues(TConfig.Instance.Compiler.LogOutput) + FPackage.Name + '.log';
    if TFile.Exists(FileName) then
    begin
      LogFile.LoadFromFile(FileName);
      Status := TStatistic.EndPackage(FPackage, LogFile.Text);
    end
    else
      TConsole.ErrorFmt('Log file %s not found!', [FileName]);
  finally
    LogFile.Free;
  end;

  PrintResult(Status);
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
const
  CMD =
    '%%FrameworkDir%%\MSBuild.exe' +
    ' "%s" /t:%s /p:platform=%s /p:config=%s ' +
    ' /p:DCC_BPLOutput=%s /p:DCC_DCUOutput=%s /p:DCC_DCPOutput=%s ' +
    ' /p:DCC_BuildAllUnits=true /v:Minimal /flp:logfile=%s%s.log ';
var
  ExecCommand: string;
  BatFile: TStringList;
begin
  BatFile := TStringList.Create;
  try
    BatFile.LoadFromFile(Format(sDelphiEnvVariablesCommand, [TConfig.DelphiInstalationPath]));

    ExecCommand := Format(CMD, [FPackage.Project,
      TConfig.Instance.Compiler.Action,
      TConfig.Instance.Compiler.Plataform,
      TConfig.Instance.Compiler.Config,
      TDBuildPath.New.FormatEnvToBatFormat(TConfig.Instance.Compiler.BplOutput),
      TDBuildPath.New.FormatEnvToBatFormat(TConfig.Instance.Compiler.DcuOutput),
      TDBuildPath.New.FormatEnvToBatFormat(TConfig.Instance.Compiler.DcpOutput),
      TDBuildPath.New.ReplaceEnvToValues(TConfig.Instance.Compiler.LogOutput),
      FPackage.Name]);

    TConsole.Debug('Compile command', ExecCommand);

    BatFile.Add(ExecCommand);
    TConsole.Debug('Compile command file ', BatFile.Text);
    result := TDBuildPath.New.RootDir + 'execute.bat';
    BatFile.SaveToFile(result);
  finally
    BatFile.Free;
  end;
end;

end.
