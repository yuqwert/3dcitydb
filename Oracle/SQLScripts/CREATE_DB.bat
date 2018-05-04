@echo off
:: Shell script to create an instance of the 3D City Database
:: on Oracle Spatial/Locator

:: Provide your database details here -----------------------------------------
set SQLPLUSBIN=path_to_sqlplus
set HOST=your_host_address
set PORT=1521
set SID=your_SID_or_database_name
set USERNAME=your_username
::-----------------------------------------------------------------------------

:: add sqlplus to PATH
set PATH=%SQLPLUSBIN%;%PATH%
:: cd to path of the shell script
cd /d %~dp0

:: Interactive mode or usage with arguments? ----------------------------------
if NOT [%1]==[] (
  GOTO:args
)

:: Prompt for SRSNO -----------------------------------------------------------
:srid
set var=
echo.
echo Please enter a valid SRID (e.g. Berlin: 81989002): Press ENTER to use default.
set /p var="(default SRID=81989002): "

IF /i NOT "%var%"=="" (
  set SRSNO=%var%
) else (
  set SRSNO=81989002
)

:: SRID is numeric?
SET "num="&for /f "delims=0123456789" %%i in ("%var%") do set num=%%i
IF defined num (
  echo.
  echo SRID must be numeric. Please retry.
  goto:srid
)


:: Prompt for GMLSRSNAME ------------------------------------------------------
set var=
echo.
echo Please enter the corresponding SRSName to be used in GML exports. Press ENTER to use default.
set /p var="(default GMLSRSNAME=urn:ogc:def:crs,crs:EPSG:6.12:3068,crs:EPSG:6.12:5783): "

IF /i NOT "%var%"=="" (
  set GMLSRSNAME=%var%
) else (
  set GMLSRSNAME=urn:ogc:def:crs,crs:EPSG:6.12:3068,crs:EPSG:6.12:5783
)

:: Prompt for VERSIONING ------------------------------------------------------
:versioning
set var=
echo.
echo Shall versioning be enabled? (yes/no): Press ENTER to use default.
set /p var="(default VERSIONING=no): "

IF /i NOT "%var%"=="" (
  set VERSIONING=%var%
) else (
  set VERSIONING=no
)

set res=f
IF /i "%VERSIONING%"=="no" (set res=t)
IF /i "%VERSIONING%"=="yes" (set res=t)
IF "%res%"=="f" (
  echo Illegal input! Enter yes or no.
  GOTO:versioning
)

:: Prompt for DBVERSION -------------------------------------------------------
:dbversion
set var=
echo.
echo Which database license are you using? (Oracle Spatial(S)/Oracle Locator(L)): Press ENTER to use default.
set /p var="(default DBVERSION=Oracle Spatial(S)): "

IF /i NOT "%var%"=="" (
  set DBVERSION=%var%
) else (
  set DBVERSION=S
)

set res=f
IF /i "%DBVERSION%"=="s" (set res=t)
IF /i "%DBVERSION%"=="l" (set res=t)
IF "%res%"=="f" (
  echo Illegal input! Enter S or L.
  GOTO:dbversion
)

:: Run CREATE_DB.sql to create the 3D City Database instance ------------------
sqlplus "%USERNAME%@\"%HOST%:%PORT%/%SID%\"" @CREATE_DB.sql "%SRSNO%" "%GMLSRSNAME%" "%VERSIONING%" "%DBVERSION%"

GOTO:EOF

:args
:: Correct number of args present? --------------------------------------------
set argC=0
for %%x in (%*) do Set /A argC+=1

echo %argC%

if NOT %argC% EQU 9 (
  echo ERROR: Invalid number of arguments. 1>&2
  GOTO:EOF
)

:: Parse args -----------------------------------------------------------------
:: %1 = HOST
:: %2 = POST
:: %3 = SID
:: %4 = USERNAME
:: $5 = PASSWORD
:: %6 = DBVERSION
:: %7 = VERSIONING
:: %8 = SRSNO
:: %9 = GMLSRSNAME

set HOST=%1
set PORT=%2
set SID=%3
set USERNAME=%4
set PASSWORD=%5
set DBVERSION=%6
set VERSIONING=%7
set SRSNO=%8
set GMLSRSNAME=%9

:: Run CREATE_DB.sql to create the 3D City Database instance ------------------
sqlplus "%USERNAME%/\"%PASSWORD%\"@\"%HOST%:%PORT%/%SID%\"" @CREATE_DB.sql "%SRSNO%" "%GMLSRSNAME%" "%VERSIONING%" "%DBVERSION%"
