@echo off
echo ====================================================
echo   MEMBUAT FILE run.bat
echo ====================================================

echo flutter clean
flutter clean

echo flutter pub get
flutter pub get

echo flutter run -d chrome
flutter run -d chrome

echo ====================================================
echo   Selesai! Sekarang pakai R atau r di terminal
echo ====================================================
pause