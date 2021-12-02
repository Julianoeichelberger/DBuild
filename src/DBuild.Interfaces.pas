unit DBuild.Interfaces;

interface


type
  IPackageFactory = Interface
    ['{6938CA5C-A600-4698-A596-1E72D314945A}']
    function CanExecute: boolean;
    procedure Execute;
  end;

  IPackageAction = Interface
    ['{8C8D34A0-EFE6-4E43-8C01-E5AD1FBEA4DE}']
    procedure Execute;
    function CanExecute: boolean;
    procedure BeforeExecute;
    procedure AfterExecute;
  End;

  IPaths = Interface
    ['{5FBF0229-35BA-4865-8295-EEE22025623C}']
    function RootDir: string;
    function DefaultOutputLogs: string;
    function DefaultOutputMetrics: string;
    function DelphiInstalation(var AVersion: string): string;
    function FormatSlash(const APath: string): string;
    function FormatEnvToBatFormat(const APath: string): string;
    function ReplaceEnvToValues(const APath: string): string;
  End;

implementation

end.
