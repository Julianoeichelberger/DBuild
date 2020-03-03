unit DBuild.Banner;

interface

Uses
  DBuild.Console;

type
  TBanner = class
    class procedure Print;
  end;

implementation

{ TBanner }

class procedure TBanner.Print;
begin
  TConsole.Write('**********************************************************************');
  TConsole.Write('*        DBuild - (c) 2020 - Juliano Eichelberger                    *');
  TConsole.Write('*                                                                    *');
  TConsole.Write('*        License - http://www.apache.org/licenses/LICENSE-2.0        *');
  TConsole.Write('**********************************************************************');
end;

end.
