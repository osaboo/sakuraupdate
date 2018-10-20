@echo off
call "%TEMP%\sakuraupdate\_setenv.bat"

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

if "%targetfolder%"=="" goto :end

set _num=0
:LOOP
set /A _num=_num+1
if "%_num%"=="1" set targetfile=%targetfile1%
if "%_num%"=="2" set targetfile=%targetfile2%
if "%_num%"=="3" set targetfile=%targetfile3%
if "%_num%"=="4" set targetfile=%targetfile4%
if "%_num%"=="5" set targetfile=%targetfile5%
if "%_num%"=="6" set targetfile=%targetfile6%
if "%_num%"=="7" set targetfile=%targetfile7%
if "%_num%"=="8" set targetfile=%targetfile8%
if "%_num%"=="9" set targetfile=%targetfile9%
if "%_num%"=="10" goto :LEXIT
if "%targetfile%"=="" goto :LEXIT

set srcfile=%srcfolder%\%targetfile%
set newfile=%targetfolder%\%targetfile%
set oldfile=%targetfolder%\%targetfile%.old

if "%targetfile%"=="plugin" goto :plugin

if not exist "%srcfile%" goto :err0

if "%targetfile%"=="sakura.exe" taskkill /im %targetfile% 2>nul
@if "%targetfile%"=="sakura.exe" @cscript //nologo %~dp0sleep.vbs 1000
if "%targetfile%"=="sakura.exe" taskkill /im %targetfile% 2>nul
@if "%targetfile%"=="sakura.exe" @cscript //nologo %~dp0sleep.vbs 1000

if exist "%oldfile%" del "%oldfile%"
ren "%newfile%" %targetfile%.old
@if exist "%newfile%" goto :err
@echo copy from "%srcfile%"
@echo      to   "%newfile%"
copy /y "%srcfile%" "%newfile%"
@if not exist "%newfile%" goto :err
@echo %newfile%の差し替えに成功しました。
goto :LOOP

:plugin
taskkill /im sakura.exe
xcopy /i /y "%srcfolder%" "%targetfolder%"
@echo プラグインの差し替えに成功しました。
goto :LOOP

:err0
echo コピー元の %srcfile% がありません。

:err
@echo %newfile%の差し替えに失敗しました。サクラエディタを再起動してやり直してください。
pause
goto :LOOP

:LEXIT
cscript //nologo %~dp0sleep.vbs 2000
:end
