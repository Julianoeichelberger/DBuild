unit DBuild.Console;

interface

type
  TConsoleColor = (Normal, Red, Blue, Green);

  TConsole = Record
  public
    class procedure Output(const AText: string; const AColor: TConsoleColor = Normal); static;
    class procedure Error(const AText: string); static;
    class procedure ErrorFmt(const AText: string; AParams: Array of const); static;
    class procedure Write(const AText: string); static;
    class procedure WriteFmt(const AText: string; AParams: Array of const); static;
    class procedure Line; static;
    class procedure Banner; static;
    class procedure PrintResult(const AWarn, AErrors: Integer; ATime: TDateTime); static;
    class procedure DebugInfo(const AText: string; AParams: Array of const); static;
  end;

implementation

Uses
  System.SysUtils,
  winapi.windows,
  DBuild.Config,
  DBuild.Utils, DBuild.Params;

{ TConsole }

class procedure TConsole.Error(const AText: string);
begin
  TConsole.Output(AText, Red);

  // raise EDBuildException.Create(AText);
end;

class procedure TConsole.ErrorFmt(const AText: string; AParams: array of const);
begin
  Error(Format(AText, AParams));
end;

class procedure TConsole.Line;
begin
  TConsole.Output('**********************************************************************');
  TConsole.Output('');
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
  TConsole.Write('**********************************************************************');
  TConsole.Write('*        DBuild - (c) 2020 - Juliano Eichelberger                    *');
  TConsole.Write('*                                                                    *');
  TConsole.Write('*        License - http://www.apache.org/licenses/LICENSE-2.0        *');
  TConsole.Write('**********************************************************************');
  TConsole.Write('');
  TConsole.DebugInfo('Rootdir = %s', [GetRootDir]);
end;

class procedure TConsole.DebugInfo(const AText: string; AParams: array of const);
begin
  if TDBuildParams.IsDebug then
    TConsole.Output('DEBUG: ' + Format(AText, AParams), Blue);
end;

class procedure TConsole.PrintResult(const AWarn, AErrors: Integer; ATime: TDateTime);
var
  Col: TConsoleColor;
begin
  Col := Green;
  if AErrors > 0 then
    Col := Red;

  TConsole.Output('**********************************************************************', Col);
  TConsole.Output('*    DBuild output result                                            *', Col);
  TConsole.Output('*                                                                    *', Col);
  TConsole.Output(Format('*    %d hints/warnings found                                          *', [AWarn]), Col);
  TConsole.Output(Format('*    %d erro(s) found                                                 *', [AErrors]), Col);
  TConsole.Output(Format('*    %s duration                                               *',
    [FormatDateTime('hh:mm:ss', ATime)]), Col);
  TConsole.Output('*                                                                    *', Col);
  TConsole.Output('**********************************************************************', Col);
end;

end.
