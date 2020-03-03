unit DBuild.LibraryPath;

interface

uses
  Registry,
  Windows,
  SysUtils,
  classes,
  DBuild.Config;

type
  TDelphiLibraryPath = class
  strict private
    class var FReg: TRegistry;
    class var FIsOpened: Boolean;
    class function OpenedKey: Boolean;
  private
    class procedure Initialize;
    class procedure ReleaseIstance;
  public
    class procedure Exec;
  end;

implementation

{ TDelphiLibraryPath }

uses DBuild.Console;

class procedure TDelphiLibraryPath.Exec;
var
  LIBRARY_PATH: TStringList;
  Path: string;
begin
  FIsOpened := OpenedKey;
  if FIsOpened then
  begin
    LIBRARY_PATH := TStringList.Create;
    try
      LIBRARY_PATH.Delimiter := ';';
      LIBRARY_PATH.StrictDelimiter := True;

      LIBRARY_PATH.Add('$(BDSLIB)\$(Platform)\release');
      LIBRARY_PATH.Add('$(BDSUSERDIR)\Imports');
      LIBRARY_PATH.Add('$(DELPHI)\Imports');
      LIBRARY_PATH.Add('$(BDSCOMMONDIR)\Dcp');
      LIBRARY_PATH.Add('$(DELPHI)\include');

      for Path in TDBuildConfig.GetInstance.LibraryPath.Values do
        LIBRARY_PATH.Add(FormatPath(Path));

      FReg.WriteString('Search Path', LIBRARY_PATH.DelimitedText);
    finally
      LIBRARY_PATH.Free;
    end;
  end;
end;

class procedure TDelphiLibraryPath.Initialize;
begin
  FReg := TRegistry.Create;
end;

class function TDelphiLibraryPath.OpenedKey: Boolean;
const
  LIBRARY_PATH_REG = '\Software\Embarcadero\BDS\%0:s\Library\%1:s';
var
  Reg: string;
begin
  try
    Reg := Format(LIBRARY_PATH_REG, [TDBuildConfig.GetInstance.Compiler.Version,
      TDBuildConfig.GetInstance.Compiler.PlataformToStr]);
    Result := FReg.OpenKey(Reg, false);
  except
    On E: Exception do
    begin
      TConsole.WriteFmt('Error on open %s windows registry', [Reg]);
      raise;
    end;
  end;
end;

class procedure TDelphiLibraryPath.ReleaseIstance;
begin
  if FIsOpened then
    FReg.CloseKey;
  FReg.Free;
end;

initialization

TDelphiLibraryPath.Initialize;

finalization

TDelphiLibraryPath.ReleaseIstance;

end.
