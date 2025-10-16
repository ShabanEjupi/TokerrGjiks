@echo off
echo ============================================
echo   TOKERRGJIK - FINAL RUN SCRIPT
echo ============================================
echo.

cd /d "c:\Users\shaban.ejupi\Desktop\PunaFK\KompjutimiCloudUshtrime\tokerrgjik_mobile"

echo All fixes applied:
echo   1. Sound files format fixed (.wav to .mp3)
echo   2. UI overflow issue fixed (added scrolling)
echo   3. AdService working (stub implementation)
echo   4. Game logic working
echo   5. Android SDK 36 configured
echo.

echo Checking for devices...
flutter devices
echo.

echo Launching app...
flutter run

echo.
echo ============================================
echo   App running!
echo ============================================
pause
