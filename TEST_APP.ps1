# Quick Test Script
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Testing TOKERRGJIK App" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking available devices..." -ForegroundColor Yellow
cd .\tokerrgjik_mobile\
flutter devices

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  Ready to run!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "To run the app, use:" -ForegroundColor Cyan
Write-Host "  cd .\tokerrgjik_mobile\" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Or to run on specific device:" -ForegroundColor Cyan
Write-Host "  flutter run -d <device-id>" -ForegroundColor White
Write-Host ""
