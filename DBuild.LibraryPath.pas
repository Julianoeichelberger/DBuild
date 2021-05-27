unit DBuild.LibraryPath;

interface

uses
  Registry,
  Windows,
  SysUtils,
  classes,
  DBuild.Config;

type
  IDelphiLibraryPath = Interface
    ['{3803840C-BE04-40A4-B882-AE9B0728E67C}']
    procedure Update;
  End;

  TDelphiLibraryPath = class(TInterfacedObject, IDelphiLibraryPath)
  private
    function GetUpdatedList: string;
  public
    procedure Update;

    class function New: IDelphiLibraryPath;
  end;

implementation

{ TDelphiLibraryPath }

uses DBuild.Console, DBuild.Utils;

function TDelphiLibraryPath.GetUpdatedList: string;
var
  Paths: TStringList;
  Path, FormtPath: string;
begin
  Paths := TStringList.Create;
  try
    Paths.Delimiter := ';';
    Paths.StrictDelimiter := True;

    Paths.Add('$(BDSLIB)\$(Platform)\release');
    Paths.Add('$(BDSUSERDIR)\Imports');
    Paths.Add('$(DELPHI)\Imports');
    Paths.Add('$(BDSCOMMONDIR)\Dcp');
    Paths.Add('$(DELPHI)\include');

    for Path in TDBuildConfig.GetInstance.LibraryPath.Values do
    begin
      FormtPath := FormatPath(Path);
      Paths.Add(FormtPath);

      TConsole.DebugInfo('Add LibraryPath = %s', [FormtPath]);
    end;
    Result := Paths.DelimitedText;
  finally
    Paths.Free;
  end;
end;

class function TDelphiLibraryPath.New: IDelphiLibraryPath;
begin
  Result := TDelphiLibraryPath.Create;
end;

procedure TDelphiLibraryPath.Update;
const
  LIBRARY_PATH_REG = '\Software\Embarcadero\BDS\%0:s\Library\%1:s';
var
  Reg: TRegistry;
  RegStr: string;
begin
  Reg := TRegistry.Create;
  try
    RegStr := Format(LIBRARY_PATH_REG, [TDBuildConfig.GetInstance.Compiler.Version,
      TDBuildConfig.GetInstance.Compiler.PlataformToStr]);
    if not Reg.OpenKey(RegStr, false) then
    begin
      TConsole.PrintErrorResult('Can not find delphi instalation');
      if TDBuildConfig.GetInstance.Failure.Error then
      begin
        ExitCode := 1;
        raise EDBuildException.Create('Can not find delphi instalation');
      end;
    end;

    Reg.WriteString('Search Path', GetUpdatedList);
    TConsole.PrintOkResult('LibraryPath was updated');
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

end.
