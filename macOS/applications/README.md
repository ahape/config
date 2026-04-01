# macOS Applications Backup
This folder stores a list of currently installed macOS applications to help you easily review and reinstall them on a new machine.

## How to backup your applications list:
1. Open the **Terminal** application on your Mac.
2. Run the following command to generate a list of all apps in your Applications folder and save it to `applications.txt`:
```sh
ls -1 /Applications > applications.txt
```
3. Commit and push the updated `applications.txt` file to your repository.
