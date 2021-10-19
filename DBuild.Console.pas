unit DBuild.Console;

interface

uses
  Generics.Collections, DBuild.Config.Classes;

type
  TConsoleColor = (Normal, Red, Blue, Green);

  TConsole = Record
  public const
    LINE_LEN = 70;
  public
    class procedure Banner; static;
    class procedure Output(const AText: string; const AColor: TConsoleColor = Normal); static;

    class procedure Error(const AText: string); static;
    class procedure ErrorFmt(const AText: string; AParams: Array of const); static;
    class procedure Write(const AText: string); static;
    class procedure WriteFmt(const AText: string; AParams: Array of const); static;
    class procedure Debug(const ATitle: string; const AText: string); static;

    class procedure PrintResult; static;
  end;

implementation

Uses
  System.SysUtils, IOUtils, WinAPI.windows, DBuild.Config, DBuild.Params, DBuild.Statistics, DBuild.Resources, DBuild.Utils;

{ TConsole }

class procedure TConsole.Error(const AText: string);
begin
  TConsole.Output(AText, Red);
end;

class procedure TConsole.ErrorFmt(const AText: string; AParams: array of const);
begin
  Error(Format(AText, AParams));
end;

class procedure TConsole.Output(const AText: string; const AColor: TConsoleColor);
var
  ConOut: THandle;
  BufInfo: TConsoleScreenBufferInfo;
begin
  if AColor = Normal then
  begin
    System.Writeln(AText);
    exit;
  end;

  ConOut := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(ConOut, BufInfo);
  case AColor of
    Red:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_INTENSITY or FOREGROUND_RED);
    Blue:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_INTENSITY or FOREGROUND_BLUE);
    Green:
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_INTENSITY or FOREGROUND_GREEN);
  end;

  System.Writeln(AText);

  SetConsoleTextAttribute(ConOut, BufInfo.wAttributes);
end;

class procedure TConsole.Write(const AText: string);
begin
  System.Writeln(AText);
end;

class procedure TConsole.WriteFmt(const AText: string; AParams: array of const);
begin
  System.Writeln(Format(AText, AParams));
end;

class procedure TConsole.Banner;
begin
  TConsole.Output(sLine, Green);
  TConsole.Output(sCopyrights, Green);
  TConsole.Output(sLine2, Green);
  TConsole.Output(sLicenseInfo, Green);
  TConsole.Output(sLine2, Green);
  TConsole.Output(RPad(sHeadPlataform, [TConfig.Instance.Compiler.Plataform], LINE_LEN, ' ') + '*', Green);
  TConsole.Output(RPad(sHeadDelphiVersion, [TConfig.Instance.Compiler.Version], LINE_LEN, ' ') + '*', Green);
  TConsole.Output(RPad(sHeadConfig, [TConfig.Instance.Compiler.Config], LINE_LEN, ' ') + '*', Green);
  TConsole.Output(RPad(sHeadTarget, [TConfig.Instance.Compiler.Action], LINE_LEN, ' ') + '*', Green);
  TConsole.Output(sLine2, Green);
  TConsole.Output(sLine, Green);
  TConsole.Write('');
end;

class procedure TConsole.Debug(const ATitle: string; const AText: string);
begin
  if not TDBuildParams.IsDebug then
    exit;

  TConsole.Output(RPad('-------- %s ', [ATitle], LINE_LEN + 1, '-'), Red);
  System.Writeln(AText);
  TConsole.Output(RPad('--------', [''], LINE_LEN + 1, '-'), Red);
end;

class procedure TConsole.PrintResult;
var
  Col: TConsoleColor;
begin
  Col := Green;
  if TStatistic.Data.ErrorsCount > 0 then
    Col := Red;

  TConsole.Output(RPad(sDBuildResultDelimiter, [TConfig.Instance.Compiler.Action.toUpper], LINE_LEN + 1, '*'), Col);
  TConsole.Output(sLine2, Col);
  TConsole.Output(RPad(sResultHintsWarns, [TStatistic.Data.WarningsCount], LINE_LEN, ' ') + '*', Col);
  TConsole.Output(RPad(sResultErrors, [TStatistic.Data.ErrorsCount], LINE_LEN, ' ') + '*', Col);
  TConsole.Output(RPad(sResultDuration, [TStatistic.Data.TotalTime], LINE_LEN, ' ') + '*', Col);
  TConsole.Output(sLine2, Col);
  TConsole.Output(RPad(sDBuildResultDelimiter, [TConfig.Instance.Compiler.Action.toUpper], LINE_LEN + 1, '*'), Col);
end;

end.
