# Windows Terminal Configuration
This folder backs up your custom settings for the Windows Terminal application.

## How to backup your current Terminal settings:
1. Open **PowerShell** or **Windows Terminal**.
2. Navigate to this exact directory (`windows/terminal`).
3. Run the following command to copy your current settings file into this folder, overwriting the `settings.json` file here:
```ps1
cp $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json .
```

## How to restore your Terminal settings on a new machine:
1. Open **PowerShell** or **Windows Terminal**.
2. Navigate to this exact directory (`windows/terminal`).
3. Run the following command to copy this backed-up `settings.json` file to your active Terminal settings location:
```ps1
cp settings.json $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```
4. Restart your Windows Terminal to see the restored settings.

## How to make `wt.exe` available

Add to your PATH `C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.23.20211.0_x64__8wekyb3d8bbwe`
