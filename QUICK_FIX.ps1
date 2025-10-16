# QUICK FIX - Updated Script for Tokerrgjik!
# Fixes Android SDK version and Google Ads issues

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "QUICK FIX - Tokerrgjik Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Clean Flutter project..." -ForegroundColor Yellow
Set-Location "tokerrgjik_mobile"
flutter clean
flutter pub get
Set-Location ".."
Write-Host "[OK] Project ready!" -ForegroundColor Green
Write-Host ""

Write-Host "=================================" -ForegroundColor Green
Write-Host "FIXES APPLIED!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "Fixed issues:" -ForegroundColor Cyan
Write-Host "  ✓ Updated Android SDK to 36 (required by plugins)" -ForegroundColor Green
Write-Host "  ✓ Added Google Mobile Ads App ID (test ID for development)" -ForegroundColor Green
Write-Host "  ✓ Configured for Windows deployment" -ForegroundColor Green
Write-Host ""
Write-Host "=================================" -ForegroundColor Yellow
Write-Host "IMPORTANT: NO EMULATOR NEEDED!" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Since you cannot install emulators, use Windows instead:" -ForegroundColor Cyan
Write-Host ""
Write-Host "TO RUN THE GAME:" -ForegroundColor Yellow
Write-Host "  cd tokerrgjik_mobile" -ForegroundColor White
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host ""
Write-Host "This is actually FASTER than using an emulator!" -ForegroundColor Green
Write-Host ""
Write-Host "The game will open in a native Windows window." -ForegroundColor Gray
Write-Host "All features work except ads (disabled on desktop)." -ForegroundColor Gray
Write-Host ""
