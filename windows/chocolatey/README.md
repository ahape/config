# Chocolatey Packages Backup
This folder tracks all the Windows applications and packages installed via the Chocolatey package manager. 

## How to export your currently installed packages:
1. Open **PowerShell as an Administrator** (Right-click the Start button -> Windows PowerShell (Admin) or Terminal (Admin)).
2. Navigate to this directory (`windows/chocolatey`).
3. Run the following command to save your installed packages to `choco-packages.config`:
```ps1
choco export choco-packages.config
```

## How to install these packages on a new machine:
1. Ensure Chocolatey is installed on the new machine.
2. Open **PowerShell as an Administrator**.
3. Navigate to this directory (`windows/chocolatey`).
4. Run the following command to install all packages listed in the config file:
```ps1
choco install choco-packages.config -y
```
