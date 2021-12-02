unit DBuild.Resources;

interface

resourcestring
  sMetricsCommand = 'AuditsCLI.exe --metrics --%0:s -o"%1:s%2:s.%0:s" -u"%3:s" "%4:s" ';
  sMetricsSourceNotFound = 'Metrics aren''t available if projects.%s.source is empty';
  sStartMetrics = 'Starting to collect metrics...';
  sCouldNotUpdateLibraryPath = 'Could not update librarypath. Delphi installation is missing';
  sLibraryPathWindowsRegistry = '\Software\Embarcadero\BDS\%0:s\Library\%1:s';
  sLibraryPathWasUpdated = '*********************** LIBRARY PATH WAS UPDATED **********************';
  sLibraryPathWasntUpdated = '*********************** LIBRARY PATH WASN''T UPDATED *******************';
  sMaxWarningsReached = 'Maximum warnings reached [%d]';
  sPressToExit = 'Press ENTER to exit...';
  sWereFoundErrors = 'Were found %d error(s)';
  sRexExGetHintWarningsCount = '([0-9])+';
  sMSBuildCommand =
    '%FrameworkDir%\MSBuild.exe /p:platform=%s /t:%s /p:config=%s /p:DCC_BPLOutput="%s" /p:DCC_DCUOutput="%s" /p:DCC_DCPOutput="%s" %s "%s"';
  sMSBuildLogCommand = '/v:Minimal /flp:logfile=%s%s.log ';
  sDelphiEnvVariablesCommand = '%sBin\rsvars.bat';
  sConfigFileNotFound = 'configuration file %s not found';
  sInvalidConfigFile = 'Invalid configuration file %s';
  sMSBuildNotFound = 'MSBuild not found';
  sStartBuild = 'Starting %s. [%s]';
  sSuccessBuildpt_BR = 'compilação com êxito.';
  sSuccessBuildpt_PT = 'compilação efectuada com êxito.';
  sFailedBuildpt = 'falha da compilação.';
  sStartPackage = '******************* Start %s ';
  sEndPackage = '********************* End %s ';
  sLine = '***********************************************************************';
  sLine2 = '*                                                                     *';
  sResultArrow = '  -----> ';
  sOutputMetricsFileNotFound = '  It wasn''t possible generate %s on metrics execution!';
  sBplNotFound = '%s not found on instalation!';
  sDBuildResultDelimiter = '***************************** DBUILD %s ';
  sResultHintsWarns = '* %d hints/warnings found';
  sResultErrors = '* %d erro(s) found';
  sResultDuration = '* %s duration';
  sCopyrights = '*        DBuild - Version 2.0 - (c) 2021 - Juliano Eichelberger       *';
  sLicenseInfo = '*        License - http://www.apache.org/licenses/LICENSE-2.0         *';
  sHeadPlataform = '*        Plataform: %s';
  sHeadDelphiVersion = '*        Delphi Version: %s';
  sHeadConfig = '*        Configuration: %s';
  sHeadTarget = '*        Target: %s';

implementation

end.
