unit DBuild.Statistics;

interface

uses
  Generics.Collections, DBuild.Config.Classes;

type
  TDataStatistic = Record
    WarningsCount: Integer;
    ErrorsCount: Integer;
    FTotalTime: TDateTime;
    procedure Create;
    procedure IncError(ACount: Integer);
    procedure IncWarning(ACount: Integer);

    function TotalTime: string;
  end;

  TBuildStatus = (Success, Failed, Unknown);

  TStatistic = class
  private
    class var FData: TDataStatistic;
    class var FListApp: TDictionary<TPackage, Boolean>;
  private
    class procedure Init;
    class function ItWasSuccess(const ALogs: string): Boolean;
    class function ItWasFailed(const ALogs: string): Boolean;
    class procedure ExtractStatistics(const ALogs: string);
  public
    class procedure InitPackage(const APackage: TPackage);
    class function EndPackage(const APackage: TPackage; const ALogs: string): TBuildStatus;
    class procedure WarningsLimitExceeded(const APackage: TPackage);
    class function Data: TDataStatistic;
  end;

implementation

uses
  SysUtils, RegularExpressions, DBuild.Resources, DBuild.Console, DBuild.Utils;

{ TDataStatistic }

procedure TDataStatistic.Create;
begin
  WarningsCount := 0;
  ErrorsCount := 0;
  FTotalTime := Now;
end;

procedure TDataStatistic.IncError(ACount: Integer);
begin
  Inc(ErrorsCount, ACount);
end;

procedure TDataStatistic.IncWarning(ACount: Integer);
begin
  Inc(WarningsCount, ACount);
end;

function TDataStatistic.TotalTime: string;
begin
  Result := FormatDateTime('hh:mm:ss', Now - FTotalTime);
end;

{ TStatistic }

class procedure TStatistic.Init;
begin
  FListApp := TDictionary<TPackage, Boolean>.Create;
  FData.Create;
end;

class procedure TStatistic.InitPackage(const APackage: TPackage);
begin
  FListApp.Add(APackage, false);
end;

class procedure TStatistic.ExtractStatistics(const ALogs: string);
var
  RegularExpression: TRegEx;
  Match: TMatch;
  StrCompare: string;
  Index: Integer;
begin
  RegularExpression.Create(sRexExGetHintWarningsCount);
  Index := ALogs.ToLower.IndexOf('aviso(s)');
  if Index >= 0 then
  begin
    StrCompare := Copy(ALogs.ToLower, Index - 10, Index + 10);
    Match := RegularExpression.Match(StrCompare);
    if Match.Success then
      FData.IncWarning(StrToIntDef(Match.Value, 0));
  end;
  Index := ALogs.ToLower.IndexOf('erro(s)');
  if Index >= 0 then
  begin
    StrCompare := Copy(ALogs.ToLower, Index - 10, Index + 10);
    Match := RegularExpression.Match(StrCompare);
    if Match.Success then
      FData.IncError(StrToIntDef(Match.Value, 0));
  end;
end;

class function TStatistic.ItWasFailed(const ALogs: string): Boolean;
begin
  Result := ALogs.ToLower.Contains(sFailedBuildpt)
end;

class function TStatistic.ItWasSuccess(const ALogs: string): Boolean;
begin
  Result := ALogs.ToLower.Contains(sSuccessBuildpt_BR) or ALogs.ToLower.Contains(sSuccessBuildpt_PT);
end;

class function TStatistic.Data: TDataStatistic;
begin
  Result := FData;
end;

class function TStatistic.EndPackage(const APackage: TPackage; const ALogs: string): TBuildStatus;
begin
  Result := Unknown;
  if FListApp.Items[APackage] then
    exit;

  ExtractStatistics(ALogs);
  FListApp.Items[APackage] := True;
  if ItWasSuccess(ALogs) then
    exit(Success);

  if ItWasFailed(ALogs) then
  begin
    if ALogs.Length < 1000 then
      TConsole.Output(ALogs, Red)
    else
      TConsole.Output(Copy(ALogs, ALogs.Length - 1000, ALogs.Length - 1), Red);
    exit(Failed);
  end;
  TConsole.Output(ALogs, Red);
end;

class procedure TStatistic.WarningsLimitExceeded(const APackage: TPackage);
begin
  if (FData.WarningsCount > APackage.Max_warnings) and (APackage.Max_warnings > -1) then
    raise EDBuildException.CreateFmt(sMaxWarningsReached, [FData.WarningsCount]);
end;

initialization

TStatistic.Init;

finalization

end.
