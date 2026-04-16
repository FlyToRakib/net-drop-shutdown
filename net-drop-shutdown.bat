@echo off
:: Check if this window was opened as the emergency alert screen
if "%1"=="alert" goto alert_screen

title Internet Monitor
echo Monitoring internet connection... Keep this window hidden.

:loop
:: 1. Ping Google DNS. We use 'find "TTL="' to ensure a genuine internet response.
ping 8.8.8.8 -n 1 -w 2000 | find "TTL=" >nul

:: If ErrorLevel is 0, the ping succeeded. Jump to the wait timer.
if %errorlevel% equ 0 goto internet_is_up

:: 2. If Google fails, wait 3 seconds to ignore micro-drops, then check Cloudflare DNS.
timeout /t 3 /nobreak >nul
ping 1.1.1.1 -n 1 -w 2000 | find "TTL=" >nul

:: If Cloudflare responds, the internet is still up. Jump to the wait timer.
if %errorlevel% equ 0 goto internet_is_up

:: 3. If BOTH pings fail, it's a true outage. Trigger the shutdown sequence.
:: Start the Windows background shutdown timer (15 seconds)
shutdown /s /t 15 /c "Internet connection lost."

:: Pop open the bright red interactive warning window
start "WARNING: SHUTDOWN" cmd /c "%~f0" alert

:: Stop the background monitor
exit

:internet_is_up
:: Wait 15 seconds before checking again
timeout /t 15 /nobreak >nul
goto loop


:: ==========================================
::        EMERGENCY ALERT SCREEN CODE
:: ==========================================
:alert_screen
:: Start the timer at 15 seconds
set SECONDS=15

:timer_loop
:: Clear the screen so the text doesn't stack up
cls
:: Change background to bright RED (4) and text to WHITE (F)
color 4F
:: Make the window a nice compact size
mode con: cols=60 lines=12

echo ========================================================
echo                 INTERNET DISCONNECTED!
echo ========================================================
echo.
echo    Windows will shut down in: %SECONDS% seconds...
echo.
echo    [C] - CANCEL the shutdown
echo    [I] - IGNORE and shut down right now
echo.

:: Wait exactly 1 second for user input. Default to 'N' (None) if nothing pressed.
choice /c CIN /t 1 /d N /n >nul

:: Check which key the user pressed
if errorlevel 3 goto tick
if errorlevel 2 goto force_shutdown
if errorlevel 1 goto cancel_shutdown

:tick
:: Subtract 1 from the timer
set /a SECONDS=%SECONDS%-1
:: If timer is greater than 0, loop back to the top and update the screen
if %SECONDS% GTR 0 goto timer_loop

:: If it reaches 0, close the window (Windows is already shutting down in the background)
exit

:force_shutdown
:: User pressed 'I' -> Force instant shutdown
shutdown /s /t 0
exit

:cancel_shutdown
:: User pressed 'C' -> Cancel the Windows shutdown
shutdown /a
cls
color 2F
echo ========================================================
echo                  SHUTDOWN CANCELLED!
echo ========================================================
echo.
echo You are safe. You can now close this window.
pause >nul
exit
