# Automate - Windows Server Backup

This is a PowerShell script intended to be used in conjunction with ConnectWise Automate for collecting data from a Windows Server Backup instance.

## Design

This script is being created to work around a few shortcomings of the Automate system. Specifically, the Automate built in scripting system sometimes produces unexpected results when running PowerShell code natively. A common work around to this problem is to copy and execute the script locally. Then, import the output data back into the Automate scripting system. This script is designed to work in this way. The output results from the script are in standard XML format. This allows very consistent and reliable results over other possible methods that I have tested.

## Prerequisites

If you intend to use this script as intended, you will need:

1. ConnectWise Automate
2. Windows Server Backup installed on the target server.
3. Some output for the data collected:
  - Extra Data Fields that you have configured.
  - A table in your SQL database if have the appropriate knowledge and understanding for that.
  - Some sort of notification mechanism such as a ticket, alert, or email generator.
4. The PowerShell Execution Policy should be set appropriately for script execution.

## Operation

1. Create an Automate script that downloads a copy of the script locally.
2. Execute the local script from Automate by using 'Shell' or 'Shell Enhanced':
  - Don't use the options to 'run as admin' If that seems wrong to you, read this excellent article: (https://bit.ly/2Ogq3js)
  - Calling PowerShell from the 'Shell' means you should be running a command like:
  ```
  powershell -command "C:\MyFolder\Get-WSBData.ps1"
  ```
3. Import the data back to the Automate script
4. Set the data to an EDF, create an alert, or make a ticket. Your choice.

## Notes

I wrote up the readme off the top of my head. As I complete the script, I'll add more detail.
