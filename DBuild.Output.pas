unit DBuild.Output;

interface

uses
  Classes, Generics.Collections, DBuild.Config, DBuild.Config.Classes;

type
  TDBuildOutput = class
  private
    class var FWarningsCount: Integer;
    class var FErrorsCount: Integer;
    class var FTotalTime: TDateTime;
  //  class var FListApp: TDictionary<TPackage, Boolean>;
//    class procedure Initialize;
//    class procedure Finalize;
  public
//    class procedure ShowResult;
//    class procedure StartBuild(const App: TPackage);
//    class procedure CloseBuild(const App: TPackage); overload;
//
//    class function TryCloseBuild(const App: TPackage; AStr: string): Boolean;
  end;

implementation

{ TDBuildOutput }
//
//uses
//  SysUtils, DateUtils, Windows, IOUtils, RegularExpressions, DBuild.Utils, DBuild.Console, DBuild.Params, DBuild.Path,
//  DBuild.Resources;
//
//class procedure TDBuildOutput.Initialize;
//begin
//  FListApp := TDictionary<TPackage, Boolean>.Create;
//  FTotalTime := Now;
//  FErrorsCount := 0;
//  FWarningsCount := 0;
//end;
//
//class procedure TDBuildOutput.Finalize;
//begin
//  FListApp.Free;
//end;
//
//class function TDBuildOutput.TryCloseBuild(const App: TPackage; AStr: string): Boolean;
//var
//  WarnsCount: Integer;
//
//  procedure ExtractCounters;
//  var
//    RegularExpression: TRegEx;
//    Match: TMatch;
//    StrCompare: string;
//    Index: Integer;
//  begin
//    RegularExpression.Create(sRexExGetHintWarningsCount);
//    Index := AStr.IndexOf('aviso(s)');
//    if Index >= 0 then
//    begin
//      StrCompare := Copy(AStr, Index - 10, Index + 10);
//      Match := RegularExpression.Match(StrCompare);
//      if Match.Success then
//      begin
//        WarnsCount := StrToIntDef(Match.Value, 0);
//        inc(FWarningsCount, WarnsCount);
//      end;
//    end;
//    Index := AStr.IndexOf('erro(s)');
//    if Index >= 0 then
//    begin
//      StrCompare := Copy(AStr, Index - 10, Index + 10);
//      Match := RegularExpression.Match(StrCompare);
//      if Match.Success then
//        inc(FErrorsCount, StrToIntDef(Match.Value, 0));
//    end;
//  end;
//
//begin
//  WarnsCount := 0;
//  Result := True;
//  AStr := AStr.ToLower;
//  if AStr.Contains('compilação com êxito.') or AStr.Contains('compilação efectuada com êxito.') then
//  begin
//    ExtractCounters;
//    FListApp.Items[App] := True;
//    TConsole.PrintPackageBuildResult(Success);
//  end
//  else if AStr.Contains('falha da compilação.') then
//  begin
//    if AStr.Length < 1000 then
//      TConsole.Output(AStr, Red)
//    else
//      TConsole.Output(Copy(AStr, AStr.Length - 1000, AStr.Length - 1), Red);
//    ExtractCounters;
//    FListApp.Items[App] := True;
//
//    TConsole.PrintPackageBuildResult(Failed);
//
//    raise EDBuildException.Create(TConfig.Instance.Compiler.Action + ' failed');
//  end;
//
//  if (WarnsCount > App.Max_warnings) and (App.Max_warnings > -1) then
//    raise EDBuildException.CreateFmt(sMaxWarningsReached, [FWarningsCount]);
//end;
//
//class procedure TDBuildOutput.StartBuild(const App: TPackage);
//begin
//  TConsole.Output(Format('Starting %s. [%s]', [TConfig.Instance.Compiler.Action, App.Plataform]));
//  TConsole.Output('');
//  FListApp.Add(App, false);
//end;
//
//class procedure TDBuildOutput.CloseBuild(const App: TPackage);
//
//  procedure ForceClose(const App: TPackage; AStr: string);
//  begin
//    TConsole.Output(AStr, Red);
//    FListApp.Items[App] := True;
//    inc(FErrorsCount);
//    TConsole.PrintPackageBuildResult(NotFound);
//  end;
//
//var
//  LFile: TStringList;
//  LogFile: string;
//begin
//  if not FListApp.Items[App] then
//  begin
//    LFile := TStringList.Create;
//    try
//      LogFile := IncludeTrailingPathDelimiter(TDBUildPath.New.Format(TConfig.Instance.Compiler.LogOutput)) + App.Name + '.log';
//      if TFile.Exists(LogFile) then
//      begin
//        LFile.LoadFromFile(LogFile);
//        TryCloseBuild(App, LFile.Text);
//        if not FListApp.Items[App] then
//          ForceClose(App, LFile.Text);
//      end;
//    finally
//      LFile.Free;
//    end;
//  end;
//end;
//
//class procedure TDBuildOutput.ShowResult;
//begin
//  FTotalTime := TimeOf(Now - FTotalTime);
//
//  TConsole.PrintBuildResult(FWarningsCount, FErrorsCount, FTotalTime);
//
//  if TDBuildParams.IsCI then
//    if FErrorsCount > 0 then
//      raise EDBuildException.CreateFmt(sWereFoundErrors, [FErrorsCount]);
//end;

//initialization
//
//TDBuildOutput.Initialize;
//
//finalization
//
//TDBuildOutput.Finalize;

end.
