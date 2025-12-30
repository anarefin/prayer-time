# How to Run in iPhone Simulator

This guide explains how to run the "Jamaat at Masjid" app on an iPhone Simulator.

## Prerequisites
- macOS
- Xcode installed (download from App Store)
- Flutter installed

## Steps

### 1. Open Simulator directly
You can open the Simulator without Xcode by running:
```bash
open -a Simulator
```

### 2. List Available Simulators
Run the following command to see available devices:
```bash
flutter devices
```
If you don't see any iOS simulators, verify you have them installed in Xcode (Xcode > Settings > Platforms).

### 3. Run from Terminal
To run the app on a specific simulator (e.g., iPhone 15 Pro):
```bash
flutter run -d "iPhone 15 Pro"
```
Or simply run and select from the list:
```bash
flutter run
```

### 4. Run from VS Code / Cursor
1. Click the device selector in the bottom right status bar (or run `Flutter: Select Device` from command palette).
2. Select an iOS Simulator.
3. Press `F5` to start debugging.

## Common Issues
- **CocoaPods not installed**: If `flutter run` fails on iOS, try running:
  ```bash
  cd ios
  rm -rf Pods
  rm Podfile.lock
  pod install --repo-update
  cd ..
  ```
- **Signing issues**: For Simulator, signing is usually not required. If you face issues, ensure you are running `flutter run` which handles debug builds automatically.
