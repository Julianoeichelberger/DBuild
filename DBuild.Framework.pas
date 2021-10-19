unit DBuild.Framework;

interface

uses
  SysUtils, DBuild.Config, DBuild.Console, DBuild.Params;

type
  TDBuild = class
  private
    class procedure Validate;
  public
    class procedure Execute;
  end;

implementation

Uses
  Registry, Windows, IOUtils, DBuild.Utils, DBuild.Config.Classes, DBuild.Package.Factory, DBuild.Resources;

{ TDBuild }

class procedure TDBuild.Validate;
begin
  if not TFile.Exists(TDBuildParams.ConfigFileName) then
    raise EDBuildException.Create(format(sConfigFileNotFound, [TDBuildParams.ConfigFileName]));

  if TConfig.Instance = nil then
    raise EDBuildException.Create(format(sInvalidConfigFile, [TDBuildParams.ConfigFileName]));
end;

class procedure TDBuild.Execute;
begin
  try
    try
      TDBuild.Validate;
      if TPackageFactory.New.CanExecute then
      begin
        TConsole.Banner;
        TPackageFactory.New.Execute;
        TConsole.PrintResult;
      end;
    except
      on E: Exception do
      begin
        ExitCode := 1;
        TConsole.Error(E.Message);
      end;
    end;
  finally
    if not TDBuildParams.IsCI then
    begin
      TConsole.Write('');
      TConsole.Write(sPressToExit);
      Readln;
    end
  end;
end;

end.
