unit DBuild.Config;

interface

type
  TCompiler = class
  strict private
  type
    TActionTarget = (Build, Compile, Clean);
    TPlataform = (Win32, Win64);
  private
    FVersion: string;
    FPlataform: TPlataform;
    FAction: TActionTarget;
    FmsBuild: string;
    FConfig: string;
    FBplOutput: string;
    FDcuOutput: string;
    FDcpOutput: string;
    function GetmsBuild: string;
    function GetBplOutput: string;
    function GetDcuOutput: string;
    function GetDcpOutput: string;
  public
    constructor Create;

    function PlataformToStr: string;
    function ActionToStr: string;

    property Action: TActionTarget read FAction write FAction;
    property BplOutput: string read GetBplOutput write FBplOutput;
    property DcuOutput: string read GetDcuOutput write FDcuOutput;
    property DcpOutput: string read GetDcpOutput write FDcpOutput;
    property Config: string read FConfig write FConfig;
    property MSBuild: string read GetmsBuild write FmsBuild;
    property Plataform: TPlataform read FPlataform write FPlataform;
    property Version: string read FVersion write FVersion;
  end;

  TLogLevel = (OutputFile, Quiet, Minimal, Normal, Detailed, Diagnostic);

  TLog = class
  private
    FOutputFile: Boolean;
    FLevel: TLogLevel;
  public
    constructor Create;

    function LevelStr: string;

    property OutputFile: Boolean read FOutputFile write FOutputFile;
    property Level: TLogLevel read FLevel write FLevel;
  end;

  TFailure = class
  private
    FMax_warnings_acceptable: Integer;
    FError: Boolean;
  public
    property Error: Boolean read FError write FError;
    property Max_warnings_acceptable: Integer read FMax_warnings_acceptable write FMax_warnings_acceptable;
  end;

  TVariableData = Class
  private
    FName: string;
    FFromWindows: Boolean;
    FValue: string;
  public
    property Name: string read FName write FName;
    property Value: string read FValue write FValue;
    property FromWindows: Boolean read FFromWindows write FFromWindows;
  End;

  TVariable = class
  private
    FValues: TArray<TVariableData>;
  public
    function FormatPath(const APath: string): string;

    property Values: TArray<TVariableData> read FValues write FValues;
  end;

  TLibraryPath = class
  private
    FValues: TArray<string>;
  public
    property Values: TArray<string> read FValues write FValues;
  end;

  TPackage = class
  private type
    TVersion = Record
      Major: Word;
      Minor: Word;
      Release: Word;
      Build: Word;
    End;
  private
    FPath: string;
    FInstalled: Boolean;
    FVersion: TVersion;
    function GetPath: string;
  public
    function Name: string;

    function VersionToStr: string;

    property Installed: Boolean read FInstalled write FInstalled;
    property Path: string read GetPath write FPath;
    property Version: TVersion read FVersion write FVersion;
  end;

  TDBuildConfig = class
  strict private
    class var FInstance: TDBuildConfig;
  private
    FVariable: TVariable;
    FCompiler: TCompiler;
    FLibraryPath: TLibraryPath;
    FPackages: TArray<TPackage>;
    FLog: TLog;
    FFailure: TFailure;
    function FileAsText: string;
    function FromJsonString(AJsonString: string): TDBuildConfig;
  public
    constructor Create;
    destructor Destroy; override;
    function ToJsonString: string;

    class function GetInstance: TDBuildConfig;

    procedure ReplaceConfig;
    procedure LoadConfig;

    property Variable: TVariable read FVariable write FVariable;
    property Compiler: TCompiler read FCompiler write FCompiler;
    property LibraryPath: TLibraryPath read FLibraryPath write FLibraryPath;
    property Log: TLog read FLog write FLog;
    property Packages: TArray<TPackage> read FPackages write FPackages;
    property Failure: TFailure read FFailure write FFailure;
  end;

function FormatPath(const APath: string): string;

implementation

Uses
  Generics.Collections, IOUtils, Rtti, SysUtils, Classes, Rest.Json, DBuild.Params, DBuild.Utils;

function FormatPath(const APath: string): string;
begin
  Result := TDBuildConfig.GetInstance.Variable.FormatPath(APath);
end;

{ TCompiler }

constructor TCompiler.Create;
begin
  FVersion := '20.0';
  FPlataform := Win32;
  FAction := Build;
  FConfig := 'Debug';
end;

function TCompiler.GetBplOutput: string;
begin
  Result := FormatPath(FBplOutput);
end;

function TCompiler.GetDcpOutput: string;
begin
  Result := FormatPath(FDcpOutput);
end;

function TCompiler.GetDcuOutput: string;
begin
  Result := FormatPath(FDcuOutput);
end;

function TCompiler.GetmsBuild: string;
begin
  Result := FmsBuild;
  if Result.IsEmpty then
    Result := GetRootDir + 'MSBuild.exe';
end;

function TCompiler.ActionToStr: string;
begin
  Result := TRttiEnumerationType.GetName(FAction);
end;

function TCompiler.PlataformToStr: string;
begin
  Result := TRttiEnumerationType.GetName(FPlataform);
end;

{ TLog }

constructor TLog.Create;
begin
  FOutputFile := True;
  FLevel := TLogLevel.OutputFile;
end;

function TLog.LevelStr: string;
begin
  Result := TRttiEnumerationType.GetName(FLevel);
end;

{ TVariable }

function TVariable.FormatPath(const APath: string): string;
var
  VarData: TVariableData;
  Value: string;
begin
  Result := APath;
  for VarData in FValues do
  begin
    Value := VarData.Value;
    if VarData.FromWindows then
    begin
      Value := StringReplace(Value, '$(', '', []);
      Value := StringReplace(Value, ')', '', []);
      Value := GetEnvironmentVariable(Value);
    end;
    Result := StringReplace(Result, VarData.Name, Value, [rfReplaceAll, rfIgnoreCase]);
  end;
end;

{ TPackage }

function TPackage.GetPath: string;
begin
  Result := FormatPath(FPath);
end;

function TPackage.Name: string;
begin
  Result := TPath.GetFileNameWithoutExtension(FPath);
end;

function TPackage.VersionToStr: string;
begin
  Result := Format('%d.%d.%d.%d', [FVersion.Major, FVersion.Minor, FVersion.Release, FVersion.Build]);
end;

{ TDBuildConfig }

constructor TDBuildConfig.Create;
begin
  FVariable := TVariable.Create;
  FCompiler := TCompiler.Create;
  FLibraryPath := TLibraryPath.Create;
  FLog := TLog.Create;
  FFailure := TFailure.Create;
end;

destructor TDBuildConfig.Destroy;
var
  Pack: TPackage;
begin
  FLog.Free;
  FVariable.Free;
  FCompiler.Free;
  FLibraryPath.Free;
  for Pack in FPackages do
    Pack.Free;
  FFailure.Free;
  inherited;
end;

function TDBuildConfig.FileAsText: string;
var
  FileConfig: TStringList;
begin
  FileConfig := TStringList.Create;
  try
    FileConfig.LoadFromFile(TDBuildParams.ConfigFileName);
    Result := FileConfig.Text;
  finally
    FileConfig.Free;
  end;
end;

function TDBuildConfig.FromJsonString(AJsonString: string): TDBuildConfig;
begin
  Result := TJson.JsonToObject<TDBuildConfig>(AJsonString);
end;

class function TDBuildConfig.GetInstance: TDBuildConfig;
begin
  Result := FInstance;
end;

procedure TDBuildConfig.LoadConfig;
begin
  if not Assigned(FInstance) then
    FInstance := FromJsonString(FileAsText);
end;

procedure TDBuildConfig.ReplaceConfig;
var
  FileConfig: TStringList;
begin
  FileConfig := TStringList.Create;
  try
    FileConfig.Text := FInstance.ToJsonString;
    FileConfig.SaveToFile(TDBuildParams.ConfigFileName);
  finally
    FileConfig.Free;
  end;
end;

function TDBuildConfig.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

end.
