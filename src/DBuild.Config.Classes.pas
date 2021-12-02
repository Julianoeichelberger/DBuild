unit DBuild.Config.Classes;

interface

uses
  Classes;

type
  TCompiler = class
  private
    FVersion: string;
    FPlataform: string;
    FAction: string;
    FConfig: string;
    FBplOutput: string;
    FDcuOutput: string;
    FDcpOutput: string;
    FLogOutput: string;
    procedure SetBplOutput(const Value: string);
    procedure SetDcpOutput(const Value: string);
    procedure SetDcuOutput(const Value: string);
    procedure SetLogOutput(const Value: string);
    procedure SetAction(const Value: string);
    procedure SetConfig(const Value: string);
    procedure SetPlataform(const Value: string);
  public
    constructor Create;

    property Action: string read FAction write SetAction;
    property Config: string read FConfig write SetConfig;
    property Plataform: string read FPlataform write SetPlataform;
    property Version: string read FVersion write FVersion;
    property BplOutput: string read FBplOutput write SetBplOutput;
    property DcuOutput: string read FDcuOutput write SetDcuOutput;
    property DcpOutput: string read FDcpOutput write SetDcpOutput;
    property LogOutput: string read FLogOutput write SetLogOutput;
  end;

  TPackage = Record
  private
    FPath: string;
    FInstalled: Boolean;
    FName: string;
    FMax_warnings: Integer;
    FPlataform: string;
    FSource: TStringList;
    Flibrarypath: Boolean;
    procedure SetPlataform(const Value: string);
    function Getlibrarypath: Boolean;
    procedure SetPath(const Value: string);
  public
    procedure Create;
    procedure Destroy;

    function UnitsPaths: string;
    function Project: string;

    property Installed: Boolean read FInstalled write FInstalled;
    property librarypath: Boolean read Getlibrarypath write Flibrarypath;
    property Path: string read FPath write SetPath;
    property Name: string read FName write FName;
    property Source: TStringList read FSource write FSource;
    property Max_warnings: Integer read FMax_warnings write FMax_warnings;
    property Plataform: string read FPlataform write SetPlataform;
  end;

  TMetrics = class
  private
    FActive: Boolean;
    FOutputExt: string;
    FOutputPath: string;
    procedure SetOutputExt(const Value: string);
    procedure SetOutputPath(const Value: string);
  public
    property Active: Boolean read FActive write FActive;
    property OutputExt: string read FOutputExt write SetOutputExt;
    property OutputPath: string read FOutputPath write SetOutputPath;
  End;

  TDBuildConfig = class
  private
    FCompiler: TCompiler;
    Flibrarypath: TStringList;
    FPackages: TArray<TPackage>;
    FMetrics: TMetrics;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddPackage(APackage: TPackage);

    property Compiler: TCompiler read FCompiler write FCompiler;
    property librarypath: TStringList read Flibrarypath write Flibrarypath;
    property Metrics: TMetrics read FMetrics write FMetrics;
    property Packages: TArray<TPackage> read FPackages;
  end;

implementation

Uses
  Generics.Collections, DBuild.Utils, IOUtils, Rtti, Windows, SysUtils, DBuild.Path;

{ TCompiler }

constructor TCompiler.Create;
begin
  FVersion := '20.0';
  FPlataform := 'Win32';
  FAction := 'Build';
  FConfig := 'Debug';
end;

procedure TCompiler.SetAction(const Value: string);
begin
  FAction := Value.ToLower;
  if FAction.IsEmpty or (FAction <> 'build') and (FAction <> 'compile') and (FAction <> 'clean') then
    FAction := DEFAULT_ACTION;
end;

procedure TCompiler.SetConfig(const Value: string);
begin
  FConfig := Value;
  if FConfig.IsEmpty then
    FConfig := DEFAULT_CONFIG;
end;

procedure TCompiler.SetPlataform(const Value: string);
begin
  FPlataform := Value;
  if FPlataform.IsEmpty or (FPlataform <> 'Win32') and (FPlataform <> 'Win64') then
    FPlataform := DEFAULT_PLATAFORM;
end;

procedure TCompiler.SetBplOutput(const Value: string);
begin
  FBplOutput := TDBUildPath.New.FormatSlash(Value);
  if not FBplOutput.IsEmpty then
    FBplOutput := IncludeTrailingPathDelimiter(FBplOutput);
end;

procedure TCompiler.SetDcpOutput(const Value: string);
begin
  FDcpOutput := TDBUildPath.New.FormatSlash(Value);
  if FDcpOutput.IsEmpty then
    FDcpOutput := DEFAULT_DCP_OUTPUT_PATH;
end;

procedure TCompiler.SetDcuOutput(const Value: string);
begin
  FDcuOutput := TDBUildPath.New.FormatSlash(Value);
  if FDcuOutput.IsEmpty then
    FDcuOutput := DEFAULT_DCU_OUTPUT_PATH;
end;

procedure TCompiler.SetLogOutput(const Value: string);
begin
  FLogOutput := TDBUildPath.New.FormatSlash(Value);
  if FLogOutput.IsEmpty then
    FLogOutput := TDBUildPath.New.DefaultOutputLogs;
  FLogOutput := IncludeTrailingPathDelimiter(FLogOutput);
end;

{ TPackage }

procedure TPackage.Create;
begin
  FSource := TStringList.Create;
end;

procedure TPackage.Destroy;
begin
  FSource.Free;
end;

function TPackage.Getlibrarypath: Boolean;
begin
  if FPath.IsEmpty then
    exit(false);
  Result := Flibrarypath;
end;

function TPackage.Project: string;
begin
  Result := Format('%s%s.dproj', [TDBUildPath.New.ReplaceEnvToValues(FPath), FName]);
end;

procedure TPackage.SetPath(const Value: string);
begin
  FPath := IncludeTrailingPathDelimiter(TDBUildPath.New.FormatSlash(Value));
end;

procedure TPackage.SetPlataform(const Value: string);
begin
  FPlataform := Value;
  if FPlataform.IsEmpty or (FPlataform <> 'Win32') and (FPlataform <> 'Win64') then
    FPlataform := DEFAULT_PLATAFORM;
end;

function TPackage.UnitsPaths: string;
begin
  Result := StringReplace(FSource.DelimitedText, ',', ';', [rfReplaceAll]);
end;

{ TMetrics }

procedure TMetrics.SetOutputExt(const Value: string);
begin
  FOutputExt := Value;
  if FOutputExt.IsEmpty or (FOutputExt.ToLower <> 'html') and (FOutputExt.ToLower <> 'xml') then
    FOutputExt := DEFAULT_QA_OUTPUT_EXT;
end;

procedure TMetrics.SetOutputPath(const Value: string);
begin
  FOutputPath := TDBUildPath.New.FormatSlash(Value);
  if FOutputPath.IsEmpty then
    FOutputPath := TDBUildPath.New.DefaultOutputMetrics;
  FOutputPath := IncludeTrailingPathDelimiter(FOutputPath);
end;

{ TDBuildConfig }

procedure TDBuildConfig.AddPackage(APackage: TPackage);
begin
  FPackages := FPackages + [APackage];
end;

constructor TDBuildConfig.Create;
begin
  FCompiler := TCompiler.Create;
  Flibrarypath := TStringList.Create;
  FMetrics := TMetrics.Create;
end;

destructor TDBuildConfig.Destroy;
var
  Package: TPackage;
begin
  for Package in FPackages do
    Package.Destroy;
  FMetrics.Free;
  FCompiler.Free;
  Flibrarypath.Free;
  inherited;
end;

end.
