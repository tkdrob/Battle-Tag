@echo off
if exist "C:\Users\All Users\ntuser.dat" goto win7
if exist "C:\Users\Default\ntuser.dat" goto win7
if exist "C:\Documents and Settings\All Users\ntuser.dat" goto winxp
if exist "C:\Documents and Settings\Default User\ntuser.dat" goto winxp
:win7
    net session >nul 2>&1
    if %errorLevel% == 0 (
        goto gotAdmin
    ) else (
	goto UACPrompt
    )
goto UACPrompt
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
echo done
pause
exit
:gotAdmin
for /f "usebackq" %%m in (`dir /b c:\users`) do (
del "C:\Users\%%m\AppData\Roaming\BattleTag\Settings\user.settings"
)
SETLOCAL
SET someOtherProgram=SomeOtherProgram.exe
TASKKILL /IM "%someOtherProgram%"
DEL "%~f0"
:winxp
for /f "usebackq" %%m in (`dir /b c:\Documents and Settings`) do (
del "C:\Documents and Settings\%%m\Application Data\BattleTag\Settings\user.settings"
)
SETLOCAL
SET someOtherProgram=SomeOtherProgram.exe
TASKKILL /IM "%someOtherProgram%"
DEL "%~f0"