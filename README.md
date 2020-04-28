# Automate Tools

This repository is a collection of PowerShell modules and tools to be used in conjunction with ConnectWise Automate. One of the basic features of the modules is to provide a flexible way to transfer data from the endpoint to the Automate system. There will be other tools included here that can be used as tools for technicians.

### Installation Guide
Automate Tools was developed to be hosted from your own environment. This could be a web server, ftp server, S3 bucket, etc. Basically, you need to offer a zipped archive at a web address. You could also host the files in your LTShare and use Automate (LabTech) to deploy the package.

1. Clone or download this repository (if you want to edit or make your own changes, otherwise go to step 2)

  ```git clone https://github.com/dylanbartos/AutomateTools [DestinationPath]```

2. Download the latest zip archive from releases page.

3. Make modifications to the "AutomateTools\config\config.json" file as necessary
 - update_uri (the web address of AT-Version.config in step 4)
 - update_zip_uri (the web address of AutomateTools.zip in step 4)

4. Upload the "AutomateTools.zip" archive to a web hosting destination or your LT server. Upload the AT-Version.config to a web hosting destination or your LT server.

5. Run the installation script below, modifying the web address to your hosted path. If you are pushing the package from the LabTech server, simply push it into a directory and modify the Expand-Archive section. You can remove the Invoke-WebRequest section.

  ```Invoke-WebRequest -Uri "https://example.com/AutomateTools.zip" -OutFile "$home\Downloads\AutomateTools.zip"; Expand-Archive "$home\Downloads\AutomateTools.zip" "C:\AutomateTools" -Force; cd "C:\AutomateTools\bin"; ./AT-Install.ps1```

6. You should receive an "Installation Completed Successfully" message. If not, check to ensure that the "profile.ps1" was loaded at "C:\Windows\System32\WindowsPowerShell\v1.0\".

7. Run the cleanup script below to remove temporary installation files.

  ```Remove-Item "$home\Downloads\AutomateTools.zip" -Force```

8. You can now start executing the cmdlets documented in [Commands](../blob/master/Commands.md). Note that you will need to open a new PowerShell session before the cmdlets will be available to you.
