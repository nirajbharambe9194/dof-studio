@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ============================================================
echo                 DoF STUDIO - ONE CLICK START
echo ============================================================
echo.

where node >nul 2>&1
if errorlevel 1 (
  echo ERROR: Node.js is not installed or not in PATH.
  echo Install Node.js LTS and run this file again.
  pause
  exit /b 1
)

where npm >nul 2>&1
if errorlevel 1 (
  echo ERROR: npm is not available.
  pause
  exit /b 1
)

set "ROOT=%~dp0"
set "BACKEND=%ROOT%backend"
set "FRONTEND=%ROOT%frontend"

if not exist "%BACKEND%\.env" (
  echo Creating backend\.env ...
  >"%BACKEND%\.env" echo DATABASE_URL="mysql://root:root@localhost:3306/dof"
  >>"%BACKEND%\.env" echo JWT_SECRET="dof-studio-local-secret-change-me"
  >>"%BACKEND%\.env" echo PORT=4000
  >>"%BACKEND%\.env" echo CORS_ORIGIN="http://localhost:5173"
)

if not exist "%FRONTEND%\.env" (
  echo Creating frontend\.env ...
  >"%FRONTEND%\.env" echo VITE_API_URL="http://localhost:4000/api"
)

echo.
echo [1/6] Checking MySQL...
sc query type= service state= all | findstr /I "mysql" >nul
if errorlevel 1 (
  echo MySQL service was not found.
  echo Please install MySQL Server and make sure it is running.
  pause
  exit /b 1
)

for /f "tokens=1" %%S in ('sc query type^= service state^= all ^| findstr /I "mysql"') do (
  sc start "%%S" >nul 2>&1
)

timeout /t 2 /nobreak >nul

echo.
echo [2/6] Checking database "dof"...
set "MYSQL_EXE="
if exist "%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe" set "MYSQL_EXE=%ProgramFiles%\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist "%ProgramFiles%\MySQL\MySQL Server 8.4\bin\mysql.exe" set "MYSQL_EXE=%ProgramFiles%\MySQL\MySQL Server 8.4\bin\mysql.exe"
if exist "%ProgramFiles%\MySQL\MySQL Server 9.0\bin\mysql.exe" set "MYSQL_EXE=%ProgramFiles%\MySQL\MySQL Server 9.0\bin\mysql.exe"

if not defined MYSQL_EXE (
  for /f "delims=" %%M in ('where mysql 2^>nul') do if not defined MYSQL_EXE set "MYSQL_EXE=%%M"
)

if not defined MYSQL_EXE (
  echo MySQL client "mysql.exe" was not found in PATH.
  echo Add MySQL\bin to PATH or install MySQL Server.
  pause
  exit /b 1
)

set /p MYSQL_PASS=Enter MySQL root password [default: root]: 
if not defined MYSQL_PASS set "MYSQL_PASS=root"

"%MYSQL_EXE%" -u root -p%MYSQL_PASS% -e "CREATE DATABASE IF NOT EXISTS dof CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1
if errorlevel 1 (
  echo.
  echo ERROR: Cannot connect to MySQL with the supplied root password.
  echo Update backend\.env DATABASE_URL if your password is different.
  pause
  exit /b 1
)

echo Database is ready.

echo.
echo [3/6] Installing/checking backend dependencies...
cd /d "%BACKEND%"
if not exist node_modules npm install
call npx prisma generate
if errorlevel 1 goto :error

echo.
echo [4/6] Updating database and seeding manufacturer catalog...
call npx prisma db push
if errorlevel 1 goto :error
call npx prisma db seed
if errorlevel 1 goto :error

echo.
echo [5/6] Starting DoF Studio API...
start "DoF Studio - Backend API" cmd /k "cd /d ""%BACKEND%"" && npm run dev"

timeout /t 5 /nobreak >nul

echo.
echo [6/6] Starting React frontend...
cd /d "%FRONTEND%"
if not exist node_modules npm install
start "DoF Studio - Frontend" cmd /k "cd /d ""%FRONTEND%"" && npm run dev"

timeout /t 7 /nobreak >nul
start "" "http://localhost:5173"

echo.
echo ============================================================
echo                 DoF STUDIO IS RUNNING
echo ============================================================
echo Frontend: http://localhost:5173
echo API:      http://localhost:4000/api/health
echo MySQL:    localhost:3306/dof
echo Catalog:  Manufacturer catalog + personal custom catalog
echo.
echo Keep the two opened command windows running.
echo Use stop.bat to stop the application.
echo ============================================================
pause
exit /b 0

:error
echo.
echo ============================================================
echo STARTUP FAILED. Read the error above.
echo ============================================================
pause
exit /b 1
