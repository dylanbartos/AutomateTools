# Automate Tools

This repository is a collection of PowerShell modules and tools to be used in conjunction with ConnectWise Automate. One of the basic features of the modules is to provide a flexible way to transfer data from the endpoint to the Automate system. There will be other tools included here that can be used as tools for technicians.

### Installation Guide
Automate Tools was developed to be hosted from your own environment. This could be a web server, ftp server, S3 bucket, etc. Basically, you need to offer a zipped archive at a web address. You could also host the files in your LTShare and use Automate (LabTech) to deploy the package.

1. Clone or download this repository

  ```git clone https://github.com/dylanbartos/AutomateTools [DestinationPath]```

2. Zip all files inside of "..\AutomateTools\AutomateTools" and name it "AutomateTools.zip". This archive contains all of the .ps1 files.

3. Upload your "AutomateTools.zip" archive to a web hosting destination. 

4. Run the installation script below, modifying the web address to your hosted path.

  ```Invoke-WebRequest -Uri "https://example.com/AutomateTools.zip" -OutFile "$home\Downloads\AutomateTools.zip"; Expand-Archive "$home\Downloads\AutomateTools.zip" "$home\Downloads\AutomateTools" -Force; cd "$home\Downloads\AutomateTools"; ./AT-Install.ps1```

5. You should receive an "Installation Completed Successfully" message. If not, check to ensure that the "profile.ps1" was loaded at "C:\Windows\System32\WindowsPowerShell\v1.0\".

6. Run the cleanup script below to remove temporary installation files.

  ```Remove-Item "$home\Downloads\AutomateTools.zip", "$home\Downloads\AutomateTools" -Force```

7. You can now start executing the cmdlets documented in [Commands](../blob/master/Commands.md). Note that you will need to open a new PowerShell session before the cmdlets will be available to you.
