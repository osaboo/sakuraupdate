call "%TEMP%\sakuraupdate\_setenv.bat"

set srcfile=%srcfolder%\%targetfile%
set newfile=%targetfolder%\%targetfile%
set oldfile=%targetfolder%\%targetfile%.old

@echo srcfolder   =%srcfolder%
@echo targetfolder=%targetfolder%
@echo targetfile  =%targetfile%

if "%targetfolder%"=="" goto :err

@timeout /t 3
if "%targetfile%"=="sakura.exe" taskkill /im %targetfile%
@if "%targetfile%"=="sakura.exe" @timeout /t 3

del "%oldfile%"
ren "%newfile%" %targetfile%.old
@if exist "%newfile%" goto :err
copy /y "%srcfile%" "%newfile%"
@echo %newfile%ÇÃç∑Çµë÷Ç¶Ç…ê¨å˜ÇµÇ‹ÇµÇΩÅB
@timeout /t 3
goto :end
:err
@echo %newfile%ÇÃç∑Çµë÷Ç¶Ç…é∏îsÇµÇ‹ÇµÇΩÅB
@timeout /t 5
:end
