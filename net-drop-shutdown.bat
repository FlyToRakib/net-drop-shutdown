@echo off
title Internet Monitor
echo Monitoring internet connection... Keep this window open.

:loop
:: Ping Google's DNS server (8.8.8.8) to check for internet
ping 8.8.8.8 -n 1 -w 2000 >nul

:: If the ping fails, it means the internet is down
if errorlevel 1 (
    echo Internet disconnected! Initiating shutdown in 10 seconds...
    shutdown /s /t 10 /c "Internet connection lost. Shutting down."
    exit
)

:: Wait 30 seconds before checking again
timeout /t 30 /nobreak >nul
goto loop