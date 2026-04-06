@echo off
:: Check if this window was opened as the emergency alert screen
if "%1"=="alert" goto alert_screen

title Internet Monitor
echo Monitoring internet connection... Keep this window hidden.

:loop
:: Ping Google to check connection
ping 8.8.8.8 -n 1 -w 2000 >nul

:: If the ping fails...
if errorlevel 1 (
    :: 1. Start the Windows background shutdown timer (30 seconds)
    shutdown /s /t 15 /c "Internet connection lost."
    
    :: 2. Pop open the bright red interactive warning window
    start "WARNING: SHUTDOWN" cmd /c "%~f0" alert
    
    :: 3. Stop the background monitor
    exit
)

:: Wait 30 seconds before checking again
timeout /t 15 /nobreak >nul
goto loop


:: ==========================================
::        EMERGENCY ALERT SCREEN CODE
:: ==========================================
:alert_screen
:: Start the timer at 30 seconds
set SECONDS=15

:timer_loop
:: Clear the screen so the text doesn't stack up
cls
:: Change background to bright RED (4) and text to WHITE (F)
color 4F
:: Make the window a nice compact size
mode con: cols=60 lines=12

echo ========================================================
echo                INTERNET DISCONNECTED!
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
echo                 SHUTDOWN CANCELLED!
echo ========================================================
echo.
echo You are safe. You can now close this window.
pause >nul
exit