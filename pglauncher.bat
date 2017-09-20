@echo off

:: task list
:: 1.bug fix, a variable string contains a parenthesis will break the if statement
:: 2.new feature, record the successful path, use the path first before search for the program at the next time

:: -----------------------------------------------------------------------------
:pglauncher     -- launch the first program[%~1] find in folder[%~2]
::              -- programExec:     The execute file.
::              -- programDir:      The directory to search [programExec] in.
if "%~1" == "/?" call :help_end ":help_pglauncher" ":eo_in_common" "/Q" "0" & exit/b rem 这里有问题，找不到label
if "%~1" == "" call :help_end ":help_pglauncher" ":eo_in_common" "/Q" "0" & exit/b
setlocal enabledelayedexpansion

set "procArch="
for /f "tokens=* delims=" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /s /f "PROCESSOR_ARCHITECTURE" /e') do (
    for /f "tokens=3 delims= " %%b in ("%%a") do (
        if "!procArch!" == "" set "procArch=%%b"
    )
)

set "programExec=%~1"
set "programDir=%~2"
set "programPath="

::notice, please avoid space character in the following variables.
if /i "%procArch%" == "x86" (
    ::set "programPath1=%ProgramFiles% (x86)"
    set "programPath1=%systemdrive%\Progra~2"
    set "programPath2=%program86%"
    set "programPath3=%ProgramFiles%"
    set "programPath4=%Program%"
) else (
    set "programPath1=%ProgramFiles%"
    set "programPath2=%program%"
    ::set "programPath3=%ProgramFiles% (x86)"
    set "programPath3=%systemdrive%\Progra~2"
    set "programPath4=%program86%"
)
set "programPath5=%appdata%"
set "programPath6=%appdata%\..\Local"

call launcher /S "%programPath1%\%programDir%" "%programExec%" && (
    call :eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath2%\%programDir%" "%programExec%" && (
    call :eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath3%\%programDir%" "%programExec%" && (
    call :eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath4%\%programDir%" "%programExec%" && (
    call :eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath5%\%programDir%" "%programExec%" && (
    call :eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath6%\%programDir%" "%programExec%" && (
    call :eo_in_common /Q /E & exit/b
)

call :eo_in_common /Q /E 1
exit/b
:: -----------------------------------------------------------------------------
:help_pglauncher  -- Display help information
echo/
echo/:pglauncher
echo/  Launch [specified program] first found [in specified folder] in program folder
echo/    %~n0 [program] [folder]
echo/        program:     The name of the [program] you want to find and launch.
echo/        folder:      In just this [folder] in ProgramFiles folder %~n0 will
echo/                     search. If it's not set, %~n0 will search [program] in
echo/                     [%programfiles%] and [%programfiles% (x86)].
echo/
exit/b

:help_end       -- Call [help] and then goto [label] with [exitCode]
::              -- help:        The label of help. Ex: :help_xxx
::              -- label:       The label to goto. Ex: :eos_xxx
::              -- arguments:   Arguments. Arguments for [label].
set "labelcall=%~1"
set "labelgoto=%~2"
:: -----------------------------------------------------------------------------
setlocal enabledelayedexpansion
set "arguments="
:loop_help_end_1
if "%~3" == "" goto :done_help_end_1
if not "%~3" == "" (
    if "!arguments!" == "" (
        set "arguments="%~3""
    ) else (
        set "arguments=!arguments! "%~3""
    )
    shift /3
)
goto :loop_help_end_1
:done_help_end_1
(endlocal
    set "arguments=%arguments%"
)

set errlvl=0
if not "%labelcall:~0,1%" == ":" set errlvl=1
if "%labelcall:~1" == "" set errlvl=1
if %errlvl% equ 0 call %labelcall%

set errlvl=0
if not "%labelgoto:~0,1%" == ":" set errlvl=1
if "%labelgoto:~1" == "" set errlvl=1
if %errlvl% equ 0 call %labelgoto% %arguments%

:eo_help_end
exit/b
:: -----------------------------------------------------------------------------
:eo_in_common   -- Do something before exit.
::              -- errlvl:      Will be used as exit Code.
::              -- /E           ENDLOCAL, toggle this if and ENDLOCAL for caller
::                              is needed.
::              -- /Q           Quiet mode, without this, a pause will be
::                              executed before exit.
setlocal enabledelayedexpansion

set "exitcode="
set "modeE="
set "modeQ="

:loop_eo_in_common_1
if "%~1" == "" goto :done_eo_in_common_1
if not "%~1" == "" (
    set "arg1=%~1"
    if not "!arg1:~0,1!" == "/" (

        if "!exitcode!" == "" set "exitcode=!arg1!"

    ) else (
        set "arg1=!arg1:~1!"
        :loop_eo_in_common_1_1
        if not "!arg1!" == "" (
            set "chr1=!arg1:~0,1!"
            set "arg1=!arg1:~1!"

            if /i "!chr1!" == "Q" set "modeQ=1"
            if /i "!chr1!" == "E" set "modeE=1"

            goto :loop_eo_in_common_1_1
        )
    )
    shift
)
goto :loop_eo_in_common_1
:done_eo_in_common_1

if not "%exitcode%" == "" set "errlvl=%exitcode%"
if "%errlvl%" == "" set "errlvl=0"
if not "%modeQ%" == "1" pause
if "%modeE%" == "1" (
    (endlocal
        set "errlvl=%errlvl%"
    )
)

(endlocal
    set "errlvl=%errlvl%"
)
exit/b %errlvl%
:: -----------------------------------------------------------------------------
