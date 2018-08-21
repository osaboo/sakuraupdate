@echo on
call "%TEMP%\sakuraupdate\_setenv.bat"

set srcfile=%srcfolder%\%targetfile%
set newfile=%targetfolder%\%targetfile%
set oldfile=%targetfolder%\%targetfile%.old

@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile  =%targetfile%

if "%_runas%"=="" goto :L1
powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process -File \"%~dp0fileupdate.bat\" -Wait %_runas%"
goto :L2

:L1
call "%~dp0fileupdate.bat"

:L2
if not "%targetfile%"=="sakura.exe" goto :end
@timeout /t 2
echo サクラエディタを再起動します。
start "" "%targetfolder%\sakura.exe"

:end
timeout /t 10
