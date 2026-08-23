@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Auto Setup - WinRAR, Node.js, Python, VS Community & Open Ports
color 0A

:: ============================================================
::  Auto Setup (tanpa winget - download installer langsung)
::  - Install Google Chrome (MSI enterprise offline)
::  - Install WinRAR 7.11, Node.js v22 LTS, Python 3.12
::  - Install Visual Studio Community 2022 + workload C++ (MSVC)
::  - Buka port TCP 443, 80 dan UDP 17091, 28028
::  - File installer yang sudah didownload TIDAK didownload ulang
::  WAJIB dijalankan sebagai Administrator!
:: ============================================================

net session >nul 2>&1
if !errorlevel! neq 0 (
    echo.
    echo [ERROR] Harus dijalankan sebagai Administrator!
    echo Klik kanan file ini lalu pilih "Run as administrator"
    echo.
    pause
    exit /b 1
)

set "DLD=%TEMP%\autosetup_download"
if not exist "!DLD!" mkdir "!DLD!"
set "PF86=%ProgramFiles(x86)%"

echo ============================================
echo        AUTO SETUP DIMULAI...
echo ============================================
echo   Folder download: !DLD!
echo.

:: ------------------------------------------------------------
:: [1/7] GOOGLE CHROME
:: ------------------------------------------------------------
echo [1/7] Menginstall Google Chrome...
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    echo       ^>^> Chrome sudah terinstall, dilewati.
    goto :winrar
)
if exist "!PF86!\Google\Chrome\Application\chrome.exe" (
    echo       ^>^> Chrome sudah terinstall, dilewati.
    goto :winrar
)
call :Download "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" "!DLD!\chrome-setup.msi"
if !errorlevel! neq 0 (
    echo       ^>^> GAGAL download Chrome. Periksa koneksi internet.
    goto :winrar
)
echo       ^>^> Install Chrome berjalan...
msiexec /i "!DLD!\chrome-setup.msi" /qn /norestart
if !errorlevel! equ 0 (
    echo       ^>^> Chrome BERHASIL diinstall.
) else (
    echo       ^>^> Chrome GAGAL diinstall. Kode error: !errorlevel!
)

:: ------------------------------------------------------------
:: [2/7] WINRAR
:: ------------------------------------------------------------
:winrar
echo.
echo [2/7] Menginstall WinRAR...
if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo       ^>^> WinRAR sudah terinstall, dilewati.
    goto :node
)
call :Download "https://www.rarlab.com/rar/winrar-x64-711.exe" "!DLD!\winrar-setup.exe"
if !errorlevel! neq 0 (
    echo       ^>^> GAGAL download WinRAR. Periksa koneksi internet.
    goto :node
)
echo       ^>^> Install WinRAR berjalan...
"!DLD!\winrar-setup.exe" /S
timeout /t 15 /nobreak >nul
if exist "C:\Program Files\WinRAR\WinRAR.exe" (
    echo       ^>^> WinRAR BERHASIL diinstall.
) else (
    echo       ^>^> WinRAR mungkin belum selesai, cek manual nanti.
)

:: ------------------------------------------------------------
:: [3/7] NODE.JS LTS v22
:: ------------------------------------------------------------
:node
echo.
echo [3/7] Menginstall Node.js v22 LTS...
where node >nul 2>&1
if !errorlevel! equ 0 (
    echo       ^>^> Node.js sudah terinstall, dilewati.
    goto :python
)
call :Download "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi" "!DLD!\node-setup.msi"
if !errorlevel! neq 0 (
    echo       ^>^> GAGAL download Node.js. Periksa koneksi internet.
    goto :python
)
echo       ^>^> Install Node.js berjalan...
msiexec /i "!DLD!\node-setup.msi" /qn /norestart
if !errorlevel! equ 0 (
    echo       ^>^> Node.js BERHASIL diinstall.
) else (
    echo       ^>^> Node.js GAGAL diinstall. Kode error: !errorlevel!
)

:: ------------------------------------------------------------
:: [4/7] PYTHON 3.12
:: ------------------------------------------------------------
:python
echo.
echo [4/7] Menginstall Python 3.12...
where python >nul 2>&1
if !errorlevel! equ 0 (
    echo       ^>^> Python sudah terinstall, dilewati.
    goto :vsc
)
call :Download "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe" "!DLD!\python-setup.exe"
if !errorlevel! neq 0 (
    echo       ^>^> GAGAL download Python. Periksa koneksi internet.
    goto :vsc
)
echo       ^>^> Install Python berjalan...
"!DLD!\python-setup.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_launcher=1
if !errorlevel! equ 0 (
    echo       ^>^> Python BERHASIL diinstall.
) else (
    echo       ^>^> Python GAGAL diinstall. Kode error: !errorlevel!
)

:: ------------------------------------------------------------
:: [5/7] VISUAL STUDIO COMMUNITY 2022 (MSVC)
:: ------------------------------------------------------------
:vsc
echo.
echo [5/7] Menginstall Visual Studio Community 2022 + MSVC (C++ workload)...
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" (
    echo       ^>^> VS Community 2022 sudah terinstall, dilewati.
    goto :tcpports
)
call :Download "https://aka.ms/vs/17/release/vs_Community.exe" "!DLD!\vs_Community.exe"
if !errorlevel! neq 0 (
    echo       ^>^> GAGAL download VS Community. Periksa koneksi internet.
    goto :tcpports
)
echo       ^>^> Install VS Community berjalan (bisa 15-45 menit, mohon tunggu)...
"!DLD!\vs_Community.exe" --quiet --norestart --wait --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended
set "VSCODE=!errorlevel!"
if !VSCODE! equ 0 (
    echo       ^>^> VS Community BERHASIL diinstall.
) else if !VSCODE! equ 3010 (
    echo       ^>^> VS Community BERHASIL diinstall (perlu restart PC).
) else (
    echo       ^>^> VS Community selesai dengan kode: !VSCODE! ^(cek log di %%TEMP%%^)
)

:: ------------------------------------------------------------
:: [6/7] PORT TCP 443 & 80
:: ------------------------------------------------------------
:tcpports
echo.
echo [6/7] Membuka port TCP 443 dan TCP 80...

netsh advfirewall firewall delete rule name="AutoSetup TCP 443" >nul 2>&1
netsh advfirewall firewall add rule name="AutoSetup TCP 443" dir=in action=allow protocol=TCP localport=443 >nul 2>&1
if !errorlevel! equ 0 (echo       ^>^> TCP 443 BERHASIL dibuka.) else (echo       ^>^> TCP 443 GAGAL dibuka.)

netsh advfirewall firewall delete rule name="AutoSetup TCP 80" >nul 2>&1
netsh advfirewall firewall add rule name="AutoSetup TCP 80" dir=in action=allow protocol=TCP localport=80 >nul 2>&1
if !errorlevel! equ 0 (echo       ^>^> TCP 80 BERHASIL dibuka.) else (echo       ^>^> TCP 80 GAGAL dibuka.)

:: ------------------------------------------------------------
:: [7/7] PORT UDP 17091 & 28028
:: ------------------------------------------------------------
echo.
echo [7/7] Membuka port UDP 17091 dan UDP 28028...

netsh advfirewall firewall delete rule name="AutoSetup UDP 17091" >nul 2>&1
netsh advfirewall firewall add rule name="AutoSetup UDP 17091" dir=in action=allow protocol=UDP localport=17091 >nul 2>&1
if !errorlevel! equ 0 (echo       ^>^> UDP 17091 BERHASIL dibuka.) else (echo       ^>^> UDP 17091 GAGAL dibuka.)

netsh advfirewall firewall delete rule name="AutoSetup UDP 28028" >nul 2>&1
netsh advfirewall firewall add rule name="AutoSetup UDP 28028" dir=in action=allow protocol=UDP localport=28028 >nul 2>&1
if !errorlevel! equ 0 (echo       ^>^> UDP 28028 BERHASIL dibuka.) else (echo       ^>^> UDP 28028 GAGAL dibuka.)

:: ------------------------------------------------------------
:: Selesai
:: ------------------------------------------------------------
set "PATH=!PATH!;C:\Program Files\nodejs;C:\Program Files\Python312;C:\Program Files\Python312\Scripts"

echo.
echo ============================================
echo        SETUP SELESAI!
echo ============================================
echo   - Chrome (MSI x64) : silent via msiexec
echo   - WinRAR 7.11      : silent install (/S)
echo   - Node.js v22.14.0 : MSI silent
echo   - Python 3.12.9    : PATH otomatis
echo   - VS Comm 2022     : workload NativeDesktop (MSVC/C++)
echo   - TCP 443, 80      : ALLOW inbound
echo   - UDP 17091, 28028 : ALLOW inbound
echo.
echo Catatan: Restart terminal / PC agar PATH aktif penuh,
echo lalu tes dengan: node -v , python --version , cl  (di x64 Native Tools Prompt)
echo Installer tersimpan di: !DLD!  (tidak didownload ulang saat run berikutnya)
echo.
pause
exit /b 0

:: ============================================================
:: FUNGSI DOWNLOAD (pakai PowerShell, tanpa winget)
:: - Jika file sudah pernah didownload -> LEWATI download
:: Usage: call :Download "URL" "FILE_TUJUAN"
:: ============================================================
:Download
if exist "%~2" (
    echo       ^>^> %~nx2 sudah ada di folder download, lewati download.
    exit /b 0
)
echo       ^>^> Downloading: %~nx1 ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -Uri '%~1' -OutFile '%~2' -UseBasicParsing -TimeoutSec 1800 } catch { exit 1 }"
if !errorlevel! neq 0 exit /b 1
if not exist "%~2" exit /b 1
echo       ^>^> Download selesai: %~nx2
exit /b 0
