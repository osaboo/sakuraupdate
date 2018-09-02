@echo off
call "%TEMP%\sakuraupdate\_setenv.bat"

rem set srcfile=%srcfolder%\%targetfile%
rem set newfile=%targetfolder%\%targetfile%
rem set oldfile=%targetfolder%\%targetfile%.old

@echo _runas      =%_runas%
@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile1 =%targetfile1%
@echo targetfile2 =%targetfile2%
@echo targetfile3 =%targetfile3%
@echo targetfile4 =%targetfile4%

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
goto :end

:L3
echo サクラエディタを再起動します。
rem @timeout /t 2
if not exist "%sakurafolder%\sakura.exe" goto :end
start "" "%sakurafolder%\sakura.exe"

:end
rem timeout /t 10
