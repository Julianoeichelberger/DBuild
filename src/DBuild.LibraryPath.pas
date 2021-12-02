unit DBuild.LibraryPath;

interface

uses
  Registry, Windows, SysUtils, DBuild.Interfaces, classes, DBuild.Config;

type
  TDelphiLibraryPath = class(TInterfacedObject, IPackageAction)
  private
    FLibraryPath: TStringList;
    FUpdated: boolean;
    procedure Execute;
    function CanExecute: boolean;
    procedure AfterExecute;
    procedure BeforeExecute;
  public
    class function New: IPackageAction;
  end;

implementation

{ TDelphiLibraryPath }

uses
  Types, DBuild.Console, DBuild.Config.classes, DBuild.Params, DBuild.Resources;

class function TDelphiLibraryPath.New: IPackageAction;
begin
  result := TDelphiLibraryPath.Create;
end;

procedure TDelphiLibraryPath.AfterExecute;
begin
  if FUpdated then
  begin
    TConsole.Debug('Library path: ', FLibraryPath.DelimitedText);
    TConsole.Output(sLibraryPathWasUpdated, Green);
  end
  else
    TConsole.Output(sLibraryPathWasntUpdated, Red);

  FLibraryPath.Free;
end;

procedure TDelphiLibraryPath.BeforeExecute;
begin
  FUpdated := True;
  FLibraryPath := TStringList.Create;
  FLibraryPath.Delimiter := ';';
  FLibraryPath.StrictDelimiter := True;
  FLibraryPath.Duplicates := dupIgnore;
end;

function TDelphiLibraryPath.CanExecute: boolean;
begin
  result := TDBuildParams.UpdateLibraryPath;
end;

procedure TDelphiLibraryPath.Execute;
var
  Reg: TRegistry;
  RegStr: string;
  Package: TPackage;
begin
  Reg := TRegistry.Create;
  try
    RegStr := Format(sLibraryPathWindowsRegistry, [
      TConfig.Instance.Compiler.Version, TConfig.Instance.Compiler.Plataform]);

    if not Reg.OpenKey(RegStr, false) then
    begin
      TConsole.Error(sCouldNotUpdateLibraryPath);
      FUpdated := false;
      exit;
    end;

    FLibraryPath.Add('$(BDSLIB)\$(Platform)\release');
    FLibraryPath.Add('$(BDSUSERDIR)\Imports');
    FLibraryPath.Add('$(DELPHI)\Imports');
    FLibraryPath.Add('$(BDSCOMMONDIR)\Dcp');
    FLibraryPath.Add('$(DELPHI)\include');
    FLibraryPath.AddStrings(TConfig.Instance.LibraryPath);

    for Package in TConfig.Instance.Packages do
    begin
      if Package.Name.isEmpty or not Package.LibraryPath then
        continue;

      FLibraryPath.AddStrings(Package.Source);
    end;

    if not TDBuildParams.IsDebug then
      Reg.WriteString('Search Path', FLibraryPath.DelimitedText);
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

end.
