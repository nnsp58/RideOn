@echo off
echo ===============================================
echo  RideOn - Google Play Store Build Script
echo ===============================================
echo.

cd /d "%~dp0.."

echo ---- Step 1: Keystore check ----
if not exist "android\key.properties" (
    echo ERROR: key.properties file nahi mili!
    echo Pehle "create_keystore.bat" run karein.
    pause
    exit /b 1
)

echo key.properties mili. Signing configured hai.
echo.

echo ---- Step 2: Dependencies clean ----
flutter clean
flutter pub get
echo.

echo ---- Step 3: Dependencies check ----
flutter pub outdated --no-dev-dependencies
echo.

echo ---- Step 4: Code generation (Freezed + JSON) ----
echo Running build_runner...
dart run build_runner build --delete-conflicting-outputs
echo.

echo ---- Step 5: App verification ----
flutter analyze
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: flutter analyze mein issues mile.
    echo Fix karein phir retry karein, ya 'y' daba kar continue karein.
    set /p CONTINUE=Continue? (y/n):
    if /i not "%CONTINUE%"=="y" exit /b 1
)
echo.

echo ---- Step 6: Build AAB (Release for Play Store) ----
echo Isme 5-15 minute lag sakte hain.
echo.
flutter build appbundle --release --obfuscate
echo.

if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ===============================================
    echo  SUCCESS! AAB file ready hai Play Store ke liye
    echo ===============================================
    echo.
    echo Output: build\app\outputs\bundle\release\app-release.aab
    echo.
    echo Is file ko Play Console par Upload karein:
    echo   1. https://play.google.com/console
    echo   2. Apna app select karein
    echo   3. "Create release" par click karein
    echo   4. AAB upload karein, review complete, phir "Submit for review" karein
    echo ===============================================
    dir build\app\outputs\bundle\release\app-release.aab
) else (
    echo ===============================================
    echo  ERROR: AAB build fail ho gayi!
    echo  Upar error log check karein.
    echo ===============================================
)

echo.
pause
