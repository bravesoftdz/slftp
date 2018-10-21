@echo off
REM
REM Quick and dirty SLFTP-Cryptconf Delphi compilation script
REM
set CC=C:\Program Files (x86)\CodeGear\RAD Studio\5.0\bin\dcc32.exe
set CC_ND_32=C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32.exe
set CC_ND_64=C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc64.exe
set CFLAGS=-B -$O+,C+,D-,L- 
set CDBFLAGS=-B -$O+,C+,D+,L+
set CINCLUDES=

if /I "%~1" == "" goto :cryptconf
if /I "%~1" == "cryptconf" goto :cryptconf
if /I "%~1" == "cryptconf_nd" goto :cryptconf_nd_32
if /I "%~1" == "cryptconf_nd_32" goto :cryptconf_nd_32
if /I "%~1" == "cryptconf_nd_64" goto :cryptconf_nd_64
if /I "%~1" == "clean" goto :clean

goto :error

:cryptconf
del /q *.exe *.dcu
echo Compiling RELEASE Win32 cryptconf.exe
"%CC%" %CFLAGS% %CINCLUDES% cryptconf.dpr
if errorlevel 1 (
   echo Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
goto :eof

:cryptconf_nd_32
del /q *.exe *.dcu
echo Compiling NEWDELPHI RELEASE Win32 cryptconf.exe
"%CC_ND_32%" %CFLAGS% %CINCLUDES% cryptconf.dpr
if errorlevel 1 (
   echo Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
goto :eof

:cryptconf_nd_64
del /q *.exe *.dcu
echo Compiling NEWDELPHI RELEASE Win64 cryptconf.exe
"%CC_ND_64%" %CFLAGS% %CINCLUDES% cryptconf.dpr
if errorlevel 1 (
   echo Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
goto :eof

:clean
echo Cleaning files
del /q *.exe *.dcu
goto :eof

:error
echo Unknown target!
echo Valid targets: cryptconf cryptconf_nd cryptconf_nd_32 cryptconf_nd_64 clean
echo Default: cryptconf
goto :eof
