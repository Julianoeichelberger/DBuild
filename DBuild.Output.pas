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

    class procedure Open(const App: TPackage);
    class procedure Close(const App: TPackage);

    class procedure Line(const App: TPackage; AStr: string);
  end;

implementation

{ TDBuildOutput }

uses
  SysUtils,
  DateUtils,
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

class procedure TDBuildOutput.Line(const App: TPackage; AStr: string);

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

begin
  AStr := AStr.ToLower;
  if AStr.Contains('compilação com êxito.') then
  begin
    TConsole.Output('SUCCESS', Green);
    TConsole.Output('');
    if AStr.Length < 1000 then
      TConsole.Output(AStr)
    else
      TConsole.Output(Copy(AStr, AStr.Length - 1000, AStr.Length - 1));
    ExtractCounters;
    FListApp.Items[App] := True;
  end
  else if AStr.Contains('falha da compilação.') then
  begin
    TConsole.Output('FAILED', Red);
    TConsole.Output('');
    if AStr.Length < 1000 then
      TConsole.Output(AStr, Red)
    else
      TConsole.Output(Copy(AStr, AStr.Length - 1000, AStr.Length - 1), Red);

    TConsole.Output(AStr, Red);
    ExtractCounters;
    FListApp.Items[App] := True;
  end;
end;

class procedure TDBuildOutput.Open(const App: TPackage);
begin
  TConsole.Output(Format('Starting %s. [%s]', [TDBuildConfig.GetInstance.Compiler.ActionToStr, App.Name]));
  TConsole.Output('');
  FListApp.Add(App, False);
end;

class procedure TDBuildOutput.Close(const App: TPackage);
var
  LFile: TStringList;
begin
  if not FListApp.Items[App] then
  begin
    LFile := TStringList.Create;
    try
      LFile.LoadFromFile(GetRootDir + 'logs\' + App.Name + '.log');
      TDBuildOutput.Line(App, LFile.Text);
      if not FListApp.Items[App] then
        TConsole.Output(Format('it is not possible to identify the result of the action [%s]', [App.Name]), Red);
    finally
      LFile.Free;
    end;
  end;
  TConsole.Line;
end;

class procedure TDBuildOutput.ShowResult;
begin
  FTotalTime := TimeOf(Now - FTotalTime);

  TConsole.PrintResult(FWarningsCount, FErrorsCount, FTotalTime);

  if not TDBuildParams.IsCI then
  begin
    TConsole.Write('');
    TConsole.Write('Press ENTER to exit...');
    Readln;
  end;
end;

initialization

TDBuildOutput.Initialize;

finalization

TDBuildOutput.Finalize;

end.
