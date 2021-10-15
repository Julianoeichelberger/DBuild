unit DBuild.Params;

interface

type
  TDBuildParams = class
  private type
  strict private
    class function FoundParam(const AValue: string): Integer;
  public
    class function ConfigFileName: string;
    class function UpdateLibraryPath: Boolean;
    class function IsCI: Boolean;
    class function Install: Boolean;
    class function IsDebug: Boolean;
    class function Metrics: Boolean;
    class function Build: Boolean;
  end;

implementation

{ TDBuildParams }

uses
  SysUtils, Registry, DBuild.Path;

class function TDBuildParams.ConfigFileName: string;
var
  IndexCfg: Integer;
begin
  Result := TDBUildPath.New.RootDir + 'DBuild.yaml';
  IndexCfg := FoundParam('-cfg') + 1;
  if Pred(IndexCfg) > 0 then
    Result := ParamStr(IndexCfg);
end;

class function TDBuildParams.Build: Boolean;
begin
  Result := FoundParam('-b') > 0;
end;

class function TDBuildParams.FoundParam(const AValue: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 1 to ParamCount do
  begin
    if ParamStr(I).ToUpper = AValue.ToUpper then
      Exit(I);
  end;
end;

class function TDBuildParams.Install: Boolean;
begin
  Result := FoundParam('-i') > 0;
end;

class function TDBuildParams.IsCI: Boolean;
begin
  Result := FoundParam('-ci') > 0;
end;

class function TDBuildParams.IsDebug: Boolean;
begin
  Result := FoundParam('-debug') > 0;
end;

class function TDBuildParams.Metrics: Boolean;
begin
  Result := FoundParam('-m') > 0;
end;

class function TDBuildParams.UpdateLibraryPath: Boolean;
begin
  Result := FoundParam('-lp') > 0;
end;

end.
