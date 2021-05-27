unit DBuild.Params;

interface

uses
  IOUtils,
  SysUtils;

type
  TParamsValue = Record
    LibraryPath: Boolean;
    Build: Boolean;
    ConfigPath: string;
    Debug: Boolean;
    IsCI: Boolean;
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
    class function UpdateLibraryPath: Boolean;
    class function IsCI: Boolean;
    class function IsDebug: Boolean;
    class function ConfigFileName: string;
    class function Enabled: Boolean;
  end;

implementation

{ TDBuildParams }

uses
  DBuild.Utils;

class function TDBuildParams.ConfigFileName: string;
begin
  Result := FParams.ConfigPath;
end;

class function TDBuildParams.Enabled: Boolean;
begin
  Result := FParams.Build;
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
  FParams.Debug := FoundParam('-debug').Index > 0;
  FParams.IsCI := FoundParam('-ci').Index > 0;
  FParams.Build := FoundParam('-b').Index > 0;
  IndexCfg := FoundParam('-cfg').Index + 1;
  if Pred(IndexCfg) > 0 then
    FParams.ConfigPath := ParamStr(IndexCfg);
end;

class function TDBuildParams.IsCI: Boolean;
begin
  Result := FParams.IsCI;
end;

class function TDBuildParams.IsDebug: Boolean;
begin
  Result := FParams.Debug;
end;

class function TDBuildParams.UpdateLibraryPath: Boolean;
begin
  Result := FParams.LibraryPath;
end;

initialization

TDBuildParams.Initialize;

end.
