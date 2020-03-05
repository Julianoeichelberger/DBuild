program DBuild;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  DBuild.Params in 'DBuild.Params.pas',
  DBuild.Config in 'DBuild.Config.pas',
  DBuild.Console in 'DBuild.Console.pas',
  DBuild.Package.Install in 'DBuild.Package.Install.pas',
  DBuild.Utils in 'DBuild.Utils.pas',
  DBuild.Package.Compile in 'DBuild.Package.Compile.pas',
  DBuild.LibraryPath in 'DBuild.LibraryPath.pas',
  DBuild.Framework in 'DBuild.Framework.pas',
  DBuild.Banner in 'DBuild.Banner.pas',
  DBuild.Output in 'DBuild.Output.pas';

begin
  try
    TBanner.Print;
    TDBuild.Execute;
    TDBuildOutput.Finalize;

    Readln;
  except
    on E: Exception do
      TConsole.WriteFmt('%s: %s', [E.ClassName, E.Message]);
  end;

end.
