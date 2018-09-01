@echo off
call "%TEMP%\sakuraupdate\_setenv.bat"

rem set srcfile=%srcfolder%\%targetfile%
rem set newfile=%targetfolder%\%targetfile%
rem set oldfile=%targetfolder%\%targetfile%.old

@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile  =%targetfile%

set _fileupdate=%~dp0fileupdate.bat

if not "%targetfile%"=="plugin" goto :L0
copy /y "%~dp0fileupdate.bat" "%TEMP%\sakuraupdate\fileupdate.bat"
set _fileupdate=%TEMP%\sakuraupdate\fileupdate.bat

:L0
if "%_runas%"=="" goto :L1
powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process -File \"%_fileupdate%\" -Wait %_runas%"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
goto :L2

:L1
call "%_fileupdate%"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

:L2

if "%targetfile%"=="sakura.exe" goto :L3
if "%targetfile%"=="plugin" goto :L3
goto :end

:L3
echo サクラエディタを再起動します。
rem @timeout /t 2
start "" "%targetfolder%\sakura.exe"

:end
rem timeout /t 10
