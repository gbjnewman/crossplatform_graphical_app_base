@echo off
setlocal

REM clear console screen
cls

REM CHECK WHETHER THE MICROSOFT C/C++ COMPILER IS AVAILABLE

where cl >nul 2>nul

if %ERRORLEVEL% EQU 0 (
    goto compiler_ready
)

REM CL.EXE WAS NOT FOUND
REM Try to locate Visual Studio using Microsoft's vswhere.exe.
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

if not exist "%VSWHERE%" (
    echo ERROR: Could not find vswhere.exe.
    echo.
    echo Visual Studio or Visual Studio Build Tools may not be installed.
    echo Make sure the "Desktop development with C++" workload is installed.
    echo.
    exit /b 1
)

REM FIND THE NEWEST VISUAL STUDIO INSTALLATION THAT CONTAINS
REM THE MSVC C++ TOOLCHAIN
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VS_PATH=%%i"
)


REM MAKE SURE A SUITABLE VISUAL STUDIO INSTALLATION WAS FOUND
if not defined VS_PATH (
    echo ERROR: Visual Studio was found, but the MSVC C++ tools were not.
    echo.
    echo Install the "Desktop development with C++" workload.
    echo.
    exit /b 1
)


REM ACTIVATE THE VISUAL STUDIO DEVELOPER ENVIRONMENT
call "%VS_PATH%\Common7\Tools\VsDevCmd.bat" -arch=x64 >nul

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to initialize the Visual Studio build environment.
    exit /b 1
)


REM VERIFY THAT CL.EXE IS NOW AVAILABLE
where cl >nul 2>nul

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Visual Studio environment loaded, but cl.exe is still unavailable.
    exit /b 1
)

:compiler_ready

REM CREATE THE BUILD DIRECTORY
if not exist build mkdir build

REM ENTER THE BUILD DIRECTORY
pushd build

REM COMPILE AND LINK THE GAME

cl ^
    /nologo ^
    /Zi ^
    /FC ^
    /I ..\SDL3\include ^
    ..\code\main.cpp ^
    /link ^
    /SUBSYSTEM:WINDOWS ^
    /LIBPATH:..\SDL3\lib\x64 ^
    SDL3.lib ^
    /OUT:game.exe

REM CHECK WHETHER COMPILATION/LINKING FAILED
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo BUILD FAILED
    popd
    exit /b 1
)

REM COPY SDL3.DLL NEXT TO GAME.EXE
REM /Y
REM     Overwrite an existing copy without asking.
copy /Y ..\SDL3\lib\x64\SDL3.dll . >nul

REM RETURN TO THE PROJECT DIRECTORY
popd

REM SUCCESS
echo.
echo BUILD SUCCESSFUL
echo Executable: build\game.exe
echo.

endlocal