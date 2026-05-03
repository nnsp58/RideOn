@echo off
echo ===============================================
echo  RideOn Play Store - Keystore Generator
echo ===============================================
echo.
echo Ye script ek release keystore banayegi jo Google Play Store ke liye zaroori hai.
echo Aapko apne data khud daalne honge.
echo.
echo ===============================================

echo.
echo ---- Step 1: Keystore banana ----
echo.
echo Apna alias name daale (koi yaadgaar naam, jaise: rideon-key):
set /p ALIAS=
echo.
echo Keystore ka password daale (kam se kam 6 characters):
set /p PASSWORD=
echo.
echo Password dobara daale:
set /p CONFIRM=
echo.
if not "%PASSWORD%"=="%CONFIRM%" (
    echo ERROR: Password match nahi ho raha. Script band ho rahi hai.
    pause
    exit /b 1
)

echo.
echo Apna naam ya organization daale (CN, jaise: RideOn India Pvt Ltd):
set /p CN=
echo Apne city ka naam daale (jaise: Noida):
set /p CITY=
echo Apne state ka naam daale (jaise: Uttar Pradesh):
set /p STATE=
echo Desh ka code daale (jaise: IN):
set /p COUNTRY=

echo.
echo ---- Keystore ban raha hai... ----
echo.

set KEYSTORE=%cd%\release\rideon-release-key.jks

keytool -genkey -v ^
  -keystore "%KEYSTORE%" ^
  -alias %ALIAS% ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -storepass %PASSWORD% ^
  -keypass %PASSWORD% ^
  -dname "CN=%CN%, OU=%CITY%, O=%STATE%, C=%COUNTRY%"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Keystore banane mein error aaya.
    pause
    exit /b 1
)

echo.
echo ---- Step 2: Properties file banana ----
echo.
echo Apna keystore path upar se copy karke yahan paste karein:
echo (Default: %KEYSTORE%)
set /p KSPATH=

REM Properties file banana
(
echo storePassword=%PASSWORD%
echo keyPassword=%PASSWORD%
echo keyAlias=%ALIAS%
echo storeFile=%KSPATH%
) > "%cd%\android\key.properties"

echo.
echo ===============================================
echo  SUCCESS!
echo ===============================================
echo.
echo Keystore save hua: %KEYSTORE%
echo Properties save hue: android\key.properties
echo.
echo *** IMPORTANT ***
echo Is file ko safe jagah backup karein: release\rideon-release-key.jks
echo Ye file khoya toh app Play Store par update nahi hoga!
echo.
echo Ab aap build_release.bat run kar sakte hain.
echo ===============================================
pause
