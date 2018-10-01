@echo off
call "%TEMP%\sakuraupdate\_setenv.bat"

@echo _runas      =%_runas%
@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
if not "%targetfile1%"=="" echo targetfile1 =%targetfile1%
if not "%targetfile2%"=="" echo targetfile2 =%targetfile2%
if not "%targetfile3%"=="" echo targetfile3 =%targetfile3%
if not "%targetfile4%"=="" echo targetfile4 =%targetfile4%
if not "%targetfile5%"=="" echo targetfile5 =%targetfile5%
if not "%targetfile6%"=="" echo targetfile6 =%targetfile6%
if not "%targetfile7%"=="" echo targetfile7 =%targetfile7%
if not "%targetfile8%"=="" echo targetfile8 =%targetfile8%
if not "%targetfile9%"=="" echo targetfile9 =%targetfile9%

set _fileupdate=%~dp0fileupdate.bat

if "%_runas%"=="" goto :L1
powershell -NoProfile -ExecutionPolicy unrestricted -Command "Start-Process -File \"%_fileupdate%\" -Wait %_runas%"
goto :L2

:L1
call "%_fileupdate%"

:L2

if "%targetfile1%"=="sakura.exe" goto :L3
if "%targetfile1%"=="plugin" goto :L3
if "%targetfile2%"=="sakura.exe" goto :L3
if "%targetfile2%"=="plugin" goto :L3
if "%targetfile3%"=="sakura.exe" goto :L3
if "%targetfile3%"=="plugin" goto :L3
if "%targetfile4%"=="sakura.exe" goto :L3
if "%targetfile4%"=="plugin" goto :L3
if "%targetfile5%"=="sakura.exe" goto :L3
if "%targetfile5%"=="plugin" goto :L3
if "%targetfile6%"=="sakura.exe" goto :L3
if "%targetfile6%"=="plugin" goto :L3
if "%targetfile7%"=="sakura.exe" goto :L3
if "%targetfile7%"=="plugin" goto :L3
if "%targetfile8%"=="sakura.exe" goto :L3
if "%targetfile8%"=="plugin" goto :L3
if "%targetfile9%"=="sakura.exe" goto :L3
if "%targetfile9%"=="plugin" goto :L3
goto :end

:L3
echo サクラエディタを再起動します。
if not exist "%sakurafolder%\sakura.exe" goto :end
start "" "%sakurafolder%\sakura.exe"

:end
