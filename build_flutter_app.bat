@echo off
REM Debugging mode to see each command executed
setlocal enabledelayedexpansion

REM Build the Android App Bundle (AAB)
echo Building AAB...
flutter build appbundle
echo flutter build appbundle finished with exit code %errorlevel%
if %errorlevel% neq 0 (
    echo Error: Failed to build AAB.
    pause
    exit /b %errorlevel%
)

REM Step: Check if AAB exists
echo Checking if AAB exists...
if not exist "build\app\outputs\bundle\release\app-release.aab" (
    echo Error: AAB was not built successfully. Please check for errors.
    pause
    exit /b 1
)

REM Build the APK
echo Building APK...
flutter build apk --release
echo flutter build apk finished with exit code %errorlevel%
if %errorlevel% neq 0 (
    echo Error: Failed to build APK.
    pause
    exit /b %errorlevel%
)

REM Check if APK exists
echo Checking if APK exists...
if not exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo Error: APK was not built successfully. Please check for errors.
    pause
    exit /b 1
)

echo Build completed successfully!
echo AAB: build\app\outputs\bundle\release\app-release.aab
echo APK: build\app\outputs\flutter-apk\app-release.apk
pause
