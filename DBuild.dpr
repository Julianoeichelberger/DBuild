program DBuild;

{$APPTYPE CONSOLE}
{$R *.res}


uses
  System.SysUtils,
  System.Classes,
  DBuild.Params in 'DBuild.Params.pas',
  DBuild.Console in 'DBuild.Console.pas',
  DBuild.Config in 'DBuild.Config.pas',
  DBuild.Config.Classes in 'DBuild.Config.Classes.pas',
  DBuild.Package.Install in 'DBuild.Package.Install.pas',
  DBuild.Package.Compile in 'DBuild.Package.Compile.pas',
  DBuild.Package.Factory in 'DBuild.Package.Factory.pas',
  DBuild.Package.Metrics in 'DBuild.Package.Metrics.pas',
  DBuild.Utils in 'DBuild.Utils.pas',
  DBuild.LibraryPath in 'DBuild.LibraryPath.pas',
  DBuild.Framework in 'DBuild.Framework.pas',
  DBuild.Interfaces in 'DBuild.Interfaces.pas',
  DBuild.Resources in 'DBuild.Resources.pas',
  DBuild.Path in 'DBuild.Path.pas',
  DBuild.Statistics in 'DBuild.Statistics.pas',
  DBuild.ShellExecute in 'DBuild.ShellExecute.pas';

begin
  TDBuild.Execute;

end.
