@echo off
call "%TEMP%\sakuraupdate\_setenv.bat"

set srcfile=%srcfolder%\%targetfile%
set newfile=%targetfolder%\%targetfile%
set oldfile=%targetfolder%\%targetfile%.old

@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile  =%targetfile%

if "%targetfolder%"=="" goto :err

rem @timeout /t 3
if "%targetfile%"=="plugin" goto :plugin

if "%targetfile%"=="sakura.exe" taskkill /im %targetfile%
@if "%targetfile%"=="sakura.exe" @timeout /t 3

del "%oldfile%"
ren "%newfile%" %targetfile%.old
@if exist "%newfile%" goto :err
copy /y "%srcfile%" "%newfile%"
@echo %newfile%の差し替えに成功しました。
rem @timeout /t 3
goto :end

:plugin
taskkill /im sakura.exe
xcopy /i /y "%srcfolder%" "%targetfolder%"
@echo プラグインの差し替えに成功しました。
goto :end

:err
@echo %newfile%の差し替えに失敗しました。

rem @timeout /t 5
:end
