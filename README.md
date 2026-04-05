# Windows Internet Monitor & Auto-Shutdown

A very lightweight, resource-friendly Windows batch script that continuously monitors your internet connection. If the connection drops, it automatically triggers a PC shutdown. 

Perfect for situations where you want your computer to safely power off if it loses network access while left unattended.

## Features
* **Extremely Lightweight:** Uses built-in Windows commands (`ping`). Negligible CPU and RAM usage.
* **Safe for Hardware:** Does not write logs to the drive, causing zero wear and tear on SSDs/HDDs.
* **Customizable Timers:** Easily change how often it checks the connection and how long the shutdown timer lasts.

## The Script (`InternetMonitor.bat`)

```cmd
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