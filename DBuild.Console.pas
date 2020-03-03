unit DBuild.Console;

interface

type
  TConsole = Record
  public
    class procedure Output(const AText: string); static;
    class procedure Error(const AText: string); static;
    class procedure ErrorFmt(const AText: string; AParams: Array of const); static;
    class procedure Write(const AText: string); static;
    class procedure WriteFmt(const AText: string; AParams: Array of const); static;
  end;

implementation

Uses
  System.SysUtils,
  winapi.windows,
  DBuild.Config,
  DBuild.Utils;

{ TConsole }

class procedure TConsole.Error(const AText: string);
var
  ConOut: THandle;
  BufInfo: TConsoleScreenBufferInfo;
begin
  ConOut := GetStdHandle(STD_OUTPUT_HANDLE);
  GetConsoleScreenBufferInfo(ConOut, BufInfo);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_INTENSITY or FOREGROUND_RED);

  System.Writeln(AText);

  SetConsoleTextAttribute(ConOut, BufInfo.wAttributes);

  raise EDBuildException.Create(AText);
end;

class procedure TConsole.ErrorFmt(const AText: string; AParams: array of const);
begin
  Error(Format(AText, AParams));
end;

class procedure TConsole.Output(const AText: string);
begin

end;

class procedure TConsole.Write(const AText: string);
begin
  System.Writeln(AText);
end;

class procedure TConsole.WriteFmt(const AText: string; AParams: array of const);
begin
  System.Writeln(Format(AText, AParams));
end;

end.
