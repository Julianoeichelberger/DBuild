unit DBuild.Output;

interface

uses
  Classes,
  DBuild.Config;

type
  TDBuildOutput = class
  private
    class var FWarningsCount: Integer;
    class var FErrorsCount: Integer;
    class var FTotalTime: TDateTime;
  public
    class procedure Initialize;
    class procedure Finalize;
    // class procedure Exec(const App: TPackage);
    class procedure Exec(const App: TPackage; AStr: string);
  end;

implementation

{ TDBuildOutput }

uses
  SysUtils,
  DateUtils,
  IOUtils,
  RegularExpressions,
  DBuild.Utils,
  DBuild.Console;

class procedure TDBuildOutput.Initialize;
begin
  FTotalTime := Now;
  FErrorsCount := 0;
  FWarningsCount := 0;
end;

class procedure TDBuildOutput.Exec(const App: TPackage; AStr: string);

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
    TConsole.Output(Format('%s successfully compiled', [App.Name]), Green);
    TConsole.Output('');
    TConsole.Output(AStr);
    ExtractCounters;
    TConsole.Line;
  end
  else if AStr.Contains('compilação com erro.') then
  begin
    TConsole.Output(Format('%s compiled with errors', [App.Name]), Red);
    TConsole.Output('');
    TConsole.Output(AStr, Red);
    ExtractCounters;
  end;
end;

class procedure TDBuildOutput.Finalize;
var
  Col: TConsoleColor;
begin
  Col := Green;
  if FErrorsCount > 0 then
    Col := Red;

  FTotalTime := TimeOf(Now - FTotalTime);

  TConsole.Output
    ('**************************************************** DBUILD RESULT ****************************************************',
    Col);
  TConsole.Output(Format('  %d hints/warnings found', [FWarningsCount]), Col);
  TConsole.Output(Format('  %d erro(s) found', [FErrorsCount]), Col);
  TConsole.Output(Format('  %s duration', [FormatDateTime('hh:mm:ss', FTotalTime)]), Col);
  TConsole.Output
    ('***********************************************************************************************************************',
    Col);
end;

initialization

TDBuildOutput.Initialize;

end.
