@echo off
setlocal enabledelayedexpansion

:: Install Archivist on Windows

:: Variables
if defined VERSION (
  :: Remove trailing spaces
  for /l %%v in (1,1,100) do if "!VERSION:~-1!"==" " set VERSION=v!VERSION:~0,-1!
) else (
  set VERSION=latest
)

if defined CIRDL (
  for /l %%v in (1,1,100) do if "!CIRDL:~-1!"==" " set CIRDL=!CIRDL:~0,-1!
) else (
  set CIRDL=false
)

if defined INSTALL_DIR (
  for /l %%v in (1,1,100) do if "!INSTALL_DIR:~-1!"==" " set INSTALL_DIR=!INSTALL_DIR:~0,-1!
) else (
  set "INSTALL_DIR=%LOCALAPPDATA%\Archivist"
)

set ARCHIVIST_ARCHIVE_PREFIX=archivist
set CIRDL_ARCHIVE_PREFIX=cirdl
set ARCHIVIST_BINARY_PREFIX=archivist
set CIRDL_BINARY_PREFIX=cirdl

if defined WINDOWS_LIBS (
  for /l %%v in (1,1,100) do if "!WINDOWS_LIBS:~-1!"==" " set WINDOWS_LIBS=!WINDOWS_LIBS:~0,-1!
) else (
  set WINDOWS_LIBS=true
)

if defined BASE_URL (
  for /l %%v in (1,1,100) do if "!BASE_URL:~-1!"==" " set BASE_URL=!BASE_URL:~0,-1!
) else (
  set BASE_URL=https://github.com/durability-labs/archivist-node
)

set API_BASE_URL=https://api.github.com/repos/durability-labs/archivist-node

if defined TEMP_DIR (
  for /l %%v in (1,1,100) do if "!TEMP_DIR:~-1!"==" " set TEMP_DIR=!TEMP_DIR:~0,-1!
) else (
  set TEMP_DIR=.
)

:: Colors
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: Help
if "%1" == "help" (
  echo %ESC%[93mUsage:%ESC%[%m
  set SCRIPT_NAME=%~n0%~x0
  set URL=https://get.archivist.storage/!SCRIPT_NAME!
  set "COMMAND=curl -sO !URL!"
  echo   !COMMAND! ^&^& !SCRIPT_NAME!
  echo   !COMMAND! ^&^& set VERSION=0.1.7 ^& set CIRDL=true ^& !SCRIPT_NAME!
  echo   !COMMAND! ^&^& set VERSION=0.1.7 ^& set WINDOWS_LIBS=false ^& !SCRIPT_NAME!
  echo   !COMMAND! ^&^& set VERSION=0.1.7 ^& set "INSTALL_DIR=C:\Program Files\Archivist" ^& !SCRIPT_NAME!
  echo.
  echo %ESC%[93mVariables:%ESC%[%m
  echo   - VERSION=0.1.7                            - archivist and cird version to install
  echo   - CIRDL=true                               - install cirdl
  echo   - "INSTALL_DIR=C:\Program Files\Archivist" - directory to install binaries
  echo   - WINDOWS_LIBS=false                       - download and install archive without the libs
  echo   - BASE_URL=http://localhost:8080           - custom base URL for binaries downloading
  exit /b 0
)

goto :run

:: Show
:show_start
echo.
echo  %~1
echo.
exit /b 0

:show_progress
echo   - %~1
exit /b 0

:: Not used yet
:: :show_pass
:: echo   - %~1
:: exit /b 0

:show_fail
echo.
echo   %ESC%[91mError: %~2%ESC%[%m
echo.
exit /b 1

:show_end
echo.
echo   %ESC%[92m%~1%ESC%[%m
echo.
exit /b 0

:: Run
:run

:: Start
call :show_start "Installing Archivist..."

:: Version
set message="Computing version"
call :show_progress %message%
if "%VERSION%" == "latest" (
  for /f delims^=^"^ tokens^=4 %%v in ('curl -Ls %API_BASE_URL%/releases/latest ^| find "tag_name"') do set VERSION=%%v
)

:: Archives and binaries
set message="Computing archives and binaries names"
call :show_progress %message%
::: Set variables
if "%CIRDL%" == "true" (
  set "ARCHIVES=%ARCHIVIST_ARCHIVE_PREFIX% %CIRDL_ARCHIVE_PREFIX%"
  set "BINARIES=%ARCHIVIST_BINARY_PREFIX% %CIRDL_BINARY_PREFIX%"
) else (
  set ARCHIVES=%ARCHIVIST_ARCHIVE_PREFIX%
  set BINARIES=%ARCHIVIST_BINARY_PREFIX%
)

:: Get the current OS
set message="Checking the current OS"
call :show_progress %message%
set OS=windows
for /f "tokens=4-5 delims=. " %%i in ('ver') do set OS_VER=%%i.%%j
for /f "skip=1 tokens=*" %%a in ('wmic os get caption ^| findstr /r /v "^$"') do set "OS_NAME=%%a"

::: Not supported
if not "%OS_VER%" == "10.0" (
  call :show_fail %message% "Unsupported OS - %OS_NAME%"
  goto :delete
)

:: Get the current architecture
set message="Checking the current architecture"
call :show_progress %message%
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set ARCHITECTURE=amd64) else (set ARCHITECTURE=arm64)

::: Not supported
if not "%ARCHITECTURE%" == "amd64" (
  call :show_fail %message% "Unsupported architecture - %PROCESSOR_ARCHITECTURE%"
  goto :delete
)

:: Archive and binaries names
if "%WINDOWS_LIBS%" == "true" (
  set ARCHIVE_SUFFIX=%VERSION%-%OS%-%ARCHITECTURE%-libs.zip
  set BINARY_SUFFIX=%VERSION%-%OS%-%ARCHITECTURE%
) else (
  set ARCHIVE_SUFFIX=%VERSION%-%OS%-%ARCHITECTURE%.zip
  set BINARY_SUFFIX=%VERSION%-%OS%-%ARCHITECTURE%
)

:: Download
for %%f in (%ARCHIVES%) do (
  set ARCHIVE=%%f
  set ARCHIVE_NAME=!ARCHIVE!-%ARCHIVE_SUFFIX%

  for %%f in (!ARCHIVE_NAME! !ARCHIVE_NAME!.sha256) do (
    set ARCHIVE=%%f
    echo %BASE_URL% | find /i "https://github.com/" >nul
    if !errorlevel! equ 0 (
      set DOWNLOAD_URL=%BASE_URL%/releases/download/%VERSION%/!ARCHIVE!
    ) else (
      set DOWNLOAD_URL=%BASE_URL%/%VERSION%/!ARCHIVE!
    )

    set message="Downloading !ARCHIVE!"
    call :show_progress !message!
    @rem we can't rely on http_code - https://github.com/curl/curl/issues/13845
    @rem for /f "delims=" %%s in ('curl --write-out %%{http_code} --connect-timeout 5 --retry 5 -sL !DOWNLOAD_URL! -o !TEMP_DIR!\!ARCHIVE!') do set http_code=%%s
    curl --fail --connect-timeout 10 --retry 10 -sL !DOWNLOAD_URL! -o !TEMP_DIR!\!ARCHIVE!
    if !errorlevel! neq 0 (
      call :show_fail !message! "Failed to download !DOWNLOAD_URL!"
      goto :delete
    )
  )
)

:: Checksum
for %%f in (%ARCHIVES%) do (
  set ARCHIVE=%%f
  set ARCHIVE_NAME=!ARCHIVE!-%ARCHIVE_SUFFIX%
  set message="Verifying checksum for !ARCHIVE_NAME!"
  call :show_progress !message!
  for /f "delims=" %%f in ('certUtil -hashfile !ARCHIVE_NAME! SHA256 ^| find /v ":"') do set "ACTUAL_HASH=%%f"
  for /f "tokens=1" %%f in (!ARCHIVE_NAME!.sha256) do set EXPECTED_HASH=%%f
  if not "!ACTUAL_HASH!" == "!EXPECTED_HASH!" (
    call :show_fail !message! "Checksum verification failed for !ARCHIVE_NAME!. Expected: !EXPECTED_HASH!, Got: !ACTUAL_HASH!"
    goto :delete
  )
)

:: Create directory
set message="Creating installation directory %INSTALL_DIR%"
call :show_progress !message!
if not exist %INSTALL_DIR% mkdir %INSTALL_DIR%
if not !errorlevel! == 0 (
  call :show_fail !message! "Failed to create %INSTALL_DIR%"
  goto :delete
)

:: Extract
for %%f in (%ARCHIVES%) do (
  set ARCHIVE=%%f
  set ARCHIVE_NAME=!ARCHIVE!-%ARCHIVE_SUFFIX%
  set message="Extracting !ARCHIVE_NAME! to %INSTALL_DIR%"
  call :show_progress !message!
  tar -xf !ARCHIVE_NAME! -C %INSTALL_DIR%
  if not !errorlevel! == 0 (
    call :show_fail !message! "Failed to extract !ARCHIVE_NAME!"
    goto :delete
  )
)

:: Rename
for %%f in (%BINARIES%) do (
  set BINARY=%%f
  set BINARY_NAME=!BINARY!-%BINARY_SUFFIX%
  set message="Renaming !BINARY_NAME!.exe to !BINARY!.exe"
  call :show_progress !message!
  move /Y "%INSTALL_DIR%\!BINARY_NAME!.exe" "%INSTALL_DIR%\!BINARY!.exe" >nul
  if not !errorlevel! == 0 (
    call :show_fail !message! "Failed to rename %INSTALL_DIR%\!BINARY_NAME!.exe to %INSTALL_DIR%\!BINARY!.exe"
  )
)

:: Cleanup
set message="Cleanup"
call :show_progress %message%
for %%f in (%ARCHIVES%) do (
  set ARCHIVE=%%f
  set ARCHIVE_NAME=!ARCHIVE!-!ARCHIVE_SUFFIX!
  del /Q %TEMP_DIR%\!ARCHIVE_NAME!*
  if !errorlevel! neq 0 (
    call :show_fail !message! "Failed to delete %TEMP_DIR%\!ARCHIVE_NAME!*"
    goto :delete
  )
)

:: End
:end
call :show_end "Setup completed successfully!"

:: Set PATH
echo %PATH% | find /i "%INSTALL_DIR%" >nul
if not %errorlevel% equ 0 (
  echo %ESC%[93m Update current session PATH:%ESC%[%m
  echo  set "PATH=%%PATH%%%INSTALL_DIR%;"
  echo.
  echo %ESC%[93m Update PATH permanently and add %INSTALL_DIR%:%ESC%[%m
  echo   - Control Panel -- System -- Advanced System settings -- Environment Variables
  echo   - Alternatively, type 'environment variables' into the Windows Search box
  @rem we can't rely on setx - https://ss64.com/nt/path.html
  @rem setx PATH "%PATH%%INSTALL_DIR;" >nul 2>&1
)

:: Self delete
:delete
goto 2>nul & del "%~f0"
