# DBuild

# DBuild is a way to compile Delphi Application/package easily (CI/CD). Work with BPL/DLL/EXE and Win32 and Win64.

e.g: DBuild.exe -lp -b -ci -cfg "c:/DBuild.json"  

Param -lp  you can reset the delphi librarypath;

Param -b   you'll make the build of the projects defined in DBuild.json;

Param -ci  Execute in continuoes integration mode (without waiting for command);

Param -cfg It's for specify the configuration file directory "c:/DBuild.json". Defaults it's the same path of the DBuild.exe.
