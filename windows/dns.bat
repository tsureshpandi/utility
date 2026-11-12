@echo off
setlocal EnableExtensions

:MENU
cls
echo ==========================================
echo          WINDOWS DNS MANAGER
echo ==========================================
echo.
echo   1. Set Custom DNS
echo   2. Restore Automatic DNS (DHCP)
echo   3. Exit
echo.
set /p "CHOICE=Select an option (1-3): "

if "%CHOICE%"=="1" goto CUSTOM
if "%CHOICE%"=="2" goto RESTORE
if "%CHOICE%"=="3" exit /b

echo Invalid selection!
pause
goto MENU


:CUSTOM
cls
echo ==========================================
echo             CUSTOM DNS SETUP
echo ==========================================
echo.

set "DNS1=1.1.1.1"
set "DNS2=1.0.0.1"

set /p "DNS1=Enter Primary DNS [1.1.1.1]: "
if not defined DNS1 set "DNS1=1.1.1.1"

set /p "DNS2=Enter Secondary DNS [1.0.0.1]: "
if not defined DNS2 set "DNS2=1.0.0.1"

goto DETECT


:RESTORE
cls
echo ==========================================
echo          RESTORE AUTOMATIC DNS
echo ==========================================
echo.
goto DETECT


:DETECT
echo Detecting active network adapter...

set "ADAPTER="

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway} | Select-Object -First 1 -ExpandProperty InterfaceAlias"`) do (
    set "ADAPTER=%%A"
)

if not defined ADAPTER (
    echo.
    echo ERROR: No active network adapter found!
    pause
    goto MENU
)

echo.
echo Active Adapter: %ADAPTER%
echo.

if "%CHOICE%"=="1" goto APPLY
if "%CHOICE%"=="2" goto AUTO


:APPLY
echo Applying custom DNS...
echo.

netsh interface ipv4 set dnsservers name="%ADAPTER%" source=static address=%DNS1% validate=no

if errorlevel 1 goto FAILED

netsh interface ipv4 add dnsservers name="%ADAPTER%" address=%DNS2% index=2 validate=no

if errorlevel 1 goto FAILED

ipconfig /flushdns

echo.
echo ==========================================
echo         CUSTOM DNS APPLIED!
echo ==========================================
echo Adapter  : %ADAPTER%
echo Primary  : %DNS1%
echo Secondary: %DNS2%
echo.
goto END


:AUTO
echo Restoring automatic DNS...

netsh interface ipv4 set dnsservers name="%ADAPTER%" source=dhcp

if errorlevel 1 goto FAILED

ipconfig /flushdns

echo.
echo ==========================================
echo       AUTOMATIC DNS RESTORED!
echo ==========================================
echo Adapter: %ADAPTER%
echo DNS     : DHCP
echo.
goto END


:FAILED
echo.
echo ERROR: DNS configuration failed!
echo Please run this file as Administrator.
echo.

:END
pause
goto MENU

