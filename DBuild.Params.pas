unit DBuild.Params;

interface

uses
  IOUtils,
  SysUtils;

type
  TParamsValue = Record
    LibraryPath: Boolean;
    ConfigPath: string;
  End;

  TParam = Record
    Value: string;
    Index: Integer;
  End;

  TDBuildParams = class
  strict private
    class var FParams: TParamsValue;
    class function FoundParam(const AValue: string): TParam;
  private
    class procedure Initialize;
  public
    class function ResetLibraryPath: Boolean;
    class function ConfigFileName: string;
  end;

implementation

{ TDBuildParams }

uses
  DBuild.Banner,
  DBuild.Utils;

class function TDBuildParams.ConfigFileName: string;
begin
  Result := FParams.ConfigPath;
end;

class function TDBuildParams.FoundParam(const AValue: string): TParam;
var
  I: Integer;
begin
  Result.Value := '';
  Result.Index := -1;
  for I := 1 to ParamCount do
  begin
    if ParamStr(I).ToUpper = AValue.ToUpper then
    begin
      Result.Value := AValue;
      Result.Index := I;
      Exit;
    end;
  end;
end;

class procedure TDBuildParams.Initialize;
var
  IndexCfg: Integer;
begin
  FParams.ConfigPath := GetRootDir + 'DBuild.json';;
  FParams.LibraryPath := FoundParam('-lp').Index > 0;
  IndexCfg := FoundParam('-cfg').Index + 1;
  if Pred(IndexCfg) > 0 then
    FParams.ConfigPath := ParamStr(IndexCfg);
end;

class function TDBuildParams.ResetLibraryPath: Boolean;
begin
  Result := FParams.LibraryPath;
end;

initialization

TDBuildParams.Initialize;

end.
