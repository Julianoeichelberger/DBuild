program DBuild;

{$APPTYPE CONSOLE}
{$R *.res}


uses
  System.SysUtils,
  System.Classes,
  DBuild.Params in 'src\DBuild.Params.pas',
  DBuild.Console in 'src\DBuild.Console.pas',
  DBuild.Config in 'src\DBuild.Config.pas',
  DBuild.Config.Classes in 'src\DBuild.Config.Classes.pas',
  DBuild.Package.Install in 'src\DBuild.Package.Install.pas',
  DBuild.Package.Compile in 'src\DBuild.Package.Compile.pas',
  DBuild.Package.Factory in 'src\DBuild.Package.Factory.pas',
  DBuild.Package.Metrics in 'src\DBuild.Package.Metrics.pas',
  DBuild.Utils in 'src\DBuild.Utils.pas',
  DBuild.LibraryPath in 'src\DBuild.LibraryPath.pas',
  DBuild.Framework in 'src\DBuild.Framework.pas',
  DBuild.Interfaces in 'src\DBuild.Interfaces.pas',
  DBuild.Resources in 'src\DBuild.Resources.pas',
  DBuild.Path in 'src\DBuild.Path.pas',
  DBuild.Statistics in 'src\DBuild.Statistics.pas',
  DBuild.ShellExecute in 'src\DBuild.ShellExecute.pas';

begin
  TDBuild.Execute;

end.
