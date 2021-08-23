unit DBuild.Output;

interface

uses
  Classes,
  Generics.Collections,
  DBuild.Config;

type
  TDBuildOutput = class
  private
    class var FWarningsCount: Integer;
    class var FErrorsCount: Integer;
    class var FTotalTime: TDateTime;
    class var FListApp: TDictionary<TPackage, Boolean>;
    class procedure Initialize;
    class procedure Finalize;
  public
    class procedure ShowResult;

    class procedure Debug(AVarList: TArray<TVariableData>);

    class procedure Open(const App: TPackage);
    class procedure Close(const App: TPackage); overload;
    class procedure Close(const App: TPackage; AStr: string); overload;

    class function TryClose(const App: TPackage; AStr: string): Boolean;
  end;

implementation

{ TDBuildOutput }

uses
  SysUtils,
  DateUtils,
  Windows,
  IOUtils,
  RegularExpressions,
  DBuild.Utils,
  DBuild.Console,
  DBuild.Params;

class procedure TDBuildOutput.Finalize;
begin
  FListApp.Free;
end;

class procedure TDBuildOutput.Initialize;
begin
  FListApp := TDictionary<TPackage, Boolean>.Create;
  FTotalTime := Now;
  FErrorsCount := 0;
  FWarningsCount := 0;
end;

class function TDBuildOutput.TryClose(const App: TPackage; AStr: string): Boolean;

  procedure ExtractCounters;
  var
    RegularExpression: TRegEx;
    Match: TMatch;
    StrCompare: string;
    Index: Integer;
  begin
    RegularExpression.Create('([0-9])+');
    Index := AStr.IndexOf('aviso(s)');
    if Index >= 0 then
    begin
      StrCompare := Copy(AStr, Index - 10, Index + 10);
      Match := RegularExpression.Match(StrCompare);
      if Match.Success then
        inc(FWarningsCount, StrToIntDef(Match.Value, 0));
    end;
    Index := AStr.IndexOf('erro(s)');
    if Index >= 0 then
    begin
      StrCompare := Copy(AStr, Index - 10, Index + 10);
      Match := RegularExpression.Match(StrCompare);
      if Match.Success then
        inc(FErrorsCount, StrToIntDef(Match.Value, 0));
    end;
  end;

var
  Str: string;
begin
  Result := False;
  AStr := AStr.ToLower;
  if AStr.Contains('compilação com êxito.') or AStr.Contains('compilação efectuada com êxito.') then
  begin
    if AStr.Length < 1000 then
      TConsole.Output(AStr)
    else
      TConsole.Output(Copy(AStr, AStr.Length - 1000, AStr.Length - 1));
    ExtractCounters;
    FListApp.Items[App] := True;
    TConsole.Output('');
    TConsole.Output('SUCCESS', Green);
    Result := True;
  end
  else if AStr.Contains('falha da compilação.') then
  begin

    if AStr.Length < 1000 then
      Str := AStr
    else
      Str := Copy(AStr, AStr.Length - 1000, AStr.Length - 1);

    TConsole.Output(Str, Red);
    ExtractCounters;
    FListApp.Items[App] := True;

    TConsole.Output('');
    TConsole.Output('FAILED', Red);
    Result := True;

    if TDBuildConfig.GetInstance.Failure.Error then
    begin
      raise EDBuildException.Create('Process stoped');
    end;
  end;

  if (FWarningsCount > TDBuildConfig.GetInstance.Failure.Max_warnings_acceptable) and
    (TDBuildConfig.GetInstance.Failure.Max_warnings_acceptable > -1) then
    raise EDBuildException.CreateFmt('Maximum warnings reached [%d]', [FWarningsCount]);
end;

class procedure TDBuildOutput.Open(const App: TPackage);
begin
  TConsole.Output(Format('Starting %s. [%s]', [TDBuildConfig.GetInstance.Compiler.ActionToStr, App.Name]));
  TConsole.Output('Platform: ' + TDBuildConfig.GetInstance.Compiler.PlataformToStr);
  TConsole.Output('');
  FListApp.Add(App, False);
end;

class procedure TDBuildOutput.Debug(AVarList: TArray<TVariableData>);
var
  VarI: TVariableData;
  Value: string;
begin
  if not TDBuildParams.IsDebug then
    exit;
  for VarI in AVarList do
  begin
    Value := VarI.Value;
    if VarI.FromWindows then
    begin
      Value := StringReplace(Value, '$(', '', []);
      Value := StringReplace(Value, ')', '', []);

      Value := GetEnvironmentVariable(Value);
    end;
    TConsole.DebugInfo('Variable %s = %s', [VarI.Name, Value]);
  end;
  TConsole.Line;
end;

class procedure TDBuildOutput.Close(const App: TPackage; AStr: string);
begin
  TConsole.Output(AStr, Red);
  FListApp.Items[App] := True;
  inc(FErrorsCount);
  TConsole.Output('');
  TConsole.Output('FAILED', Red);
end;

class procedure TDBuildOutput.Close(const App: TPackage);
var
  LFile: TStringList;
  LogFile: string;
begin
  if not FListApp.Items[App] then
  begin
    LFile := TStringList.Create;
    try
      LogFile := GetRootDir + 'logs\' + App.Name + '.log';
      if TFile.Exists(LogFile) then
      begin
        LFile.LoadFromFile(LogFile);
        TryClose(App, LFile.Text);
        if not FListApp.Items[App] then
          Close(App, LFile.Text);
      end
      else
      begin
        Close(App, Format('Log file [%s] not found', [LogFile]));
      end;
    finally
      LFile.Free;
    end;
  end;
  TConsole.Line;
end;

class procedure TDBuildOutput.ShowResult;
begin
  FTotalTime := TimeOf(Now - FTotalTime);

  TConsole.PrintBuildResult(FWarningsCount, FErrorsCount, FTotalTime);

  if not TDBuildParams.IsCI then
  begin
    TConsole.Write('');
    TConsole.Write('Press ENTER to exit...');
    Readln;
  end
  else
  begin
    if FErrorsCount > 0 then
      raise EDBuildException.CreateFmt('Were found %d error(s)', [FErrorsCount]);
  end;
end;

initialization

TDBuildOutput.Initialize;

finalization

TDBuildOutput.Finalize;

end.
