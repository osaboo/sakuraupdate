@echo off
call "%TEMP%\sakuraupdate\_setenv.bat"

@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile1 =%targetfile1%
@echo targetfile2 =%targetfile2%
@echo targetfile3 =%targetfile3%
@echo targetfile4 =%targetfile4%

if "%targetfolder%"=="" goto :end

set _num=0
:LOOP
set /A _num=_num+1
if "%_num%"=="1" set targetfile=%targetfile1%
if "%_num%"=="2" set targetfile=%targetfile2%
if "%_num%"=="3" set targetfile=%targetfile3%
if "%_num%"=="4" set targetfile=%targetfile4%
if "%_num%"=="5" goto :LEXIT
if "%targetfile%"=="" goto :LEXIT

set srcfile=%srcfolder%\%targetfile%
set newfile=%targetfolder%\%targetfile%
set oldfile=%targetfolder%\%targetfile%.old

rem @timeout /t 3
if "%targetfile%"=="plugin" goto :plugin

if "%targetfile%"=="sakura.exe" taskkill /im %targetfile%
@if "%targetfile%"=="sakura.exe" @cscript //nologo %~dp0sleep.vbs 1000
if "%targetfile%"=="sakura.exe" taskkill /im %targetfile%
@if "%targetfile%"=="sakura.exe" @cscript //nologo %~dp0sleep.vbs 1000
rem @timeout /t 3

if exist "%oldfile%" del "%oldfile%"
ren "%newfile%" %targetfile%.old
@if exist "%newfile%" goto :err
copy /y "%srcfile%" "%newfile%"
@echo %newfile%の差し替えに成功しました。
rem @timeout /t 3
goto :LOOP

:plugin
taskkill /im sakura.exe
xcopy /i /y "%srcfolder%" "%targetfolder%"
@echo プラグインの差し替えに成功しました。
goto :LOOP

:err
@echo %newfile%の差し替えに失敗しました。
pause
goto :LOOP

:LEXIT
cscript //nologo %~dp0sleep.vbs 2000
rem @timeout /t 5
:end

