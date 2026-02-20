# Homebrew Configuration
This folder contains the `Brewfile`, which tracks all the packages installed via Homebrew on your Mac. This allows you to easily restore your environment.

## How to backup your currently installed Homebrew packages:
1. Open the **Terminal** application.
2. Navigate to this directory (`osx/brew`).
3. Run the following command to overwrite the `Brewfile` with your currently installed packages:
```sh
brew bundle dump --file=Brewfile --force
```

## How to install packages from this Brewfile on a new machine:
1. Open the **Terminal** application.
2. Navigate to this directory (`osx/brew`).
3. Run the following command to install all listed packages:
```sh
brew bundle --file=Brewfile
```

---

### Troubleshooting: Java (OpenJDK)
If you install Kotlin via Homebrew, it requires a Java Runtime (JVM) to work. macOS has a built-in Java locator tool, but it doesn't automatically detect the OpenJDK installed by Homebrew. 

To fix this so macOS can find Java, run this command in your Terminal (it will ask for your administrator password):
```sh
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
```
