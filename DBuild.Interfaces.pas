unit DBuild.Interfaces;

interface


type
  IPackageAction = Interface
    ['{8C8D34A0-EFE6-4E43-8C01-E5AD1FBEA4DE}']
    procedure Execute;
    function CanExecute: boolean;
    procedure BeforeExecute;
    procedure AfterExecute;
  End;

  IPackageFactory = Interface
    ['{6938CA5C-A600-4698-A596-1E72D314945A}']
    procedure Execute;
  end;

  IPaths = Interface
    ['{5FBF0229-35BA-4865-8295-EEE22025623C}']
    function RootDir: string;
    function DefaultOutputLogs: string;
    function DefaultOutputMetrics: string;
    function DelphiInstalation(var AVersion: string): string;
    function MsBuild(const ADelphiInstallPath: string; const AMSBuildDir: string): string;
    function Format(const APath: string; AEnvs: boolean = True): string;
    function FormatEnvToBatFile(const APath: string): string;
  End;

implementation

end.
