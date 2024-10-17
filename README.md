# WindowsAutounattendSetupScript

## Description 📝

Welcome to the **WindowsAutounattendSetupScript**! 🎉 This PowerShell script is your trusty sidekick for creating a configuration file called `autounattend.xml`. This file lets you install Windows without having to answer annoying questions - because it's long, it's boring, and because time is money.

## Features 🌟

With this script, you can choose:
- **Account name**: Set your own personalized username for your new Windows installation.
- **Password**: Decide whether you want to secure your account with a password.
- **Display language**: Select your preferred display language, which will also match your keyboard layout.
- **Region**: Select your region. We advise you to set “Universal English” to limit the number of bloatware.

### Privacy 🚫📊
By default, the script answers “no” to all Microsoft's privacy questions about data collection and telemetry. Because really, who wants to give Microsoft info, and who's s*d* to choose “yes” and give EVEN more personal information? 

## Requirements 📋

- The script removes annoying requirements for Windows 11 installation, such as :
  - TPM 2.0
  - Secure boot
  - Processor generation checks
- No need to log in to Microsoft account
- This script bypasses the OOBE (Out-Of-Box Experience), allowing you to install Windows without needing an Internet connection
  
## How to use it ⚙️

1. **Download or clone this repository**.
2. **Execute the script**: Run the script by clicking "Run with PowerShell" (preferably as administrator, even if the script is supposed to run as a script if you haven't done so). If the "Run with PowerShell" button is not available, you can set `powershell.exe` as the default application for `.ps1` scripts. See [this guide](https://www.top-password.com/blog/set-ps1-script-to-open-with-powershell-by-default/#:~:text=Check%20the%20box%20labeled%20%E2%80%9CAlways,select%20the%20powershell.exe%20file.) for instructions.
3. **Follow the prompts**: Answer the interactive questions to configure your installation parameters.

### Troubleshooting 🔧
If the script doesn't run, check that you've enabled script execution. To do this, download and run the following script, and choose 1 (Thanks Fr33thy ❤️):
- [Allow Scripts](https://github.com/FR33THYFR33THY/Ultimate-Windows-Optimization-Guide/blob/main/Allow%20Scripts.cmd)

### Acknowledgements 🙏
This project was inspired by :
- [Ultimate Windows Optimization Guide](https://github.com/fr33thytweaks/Ultimate-Windows-Optimization-Guide/blob/main/2%20Refresh/4%20Autounattend.ps1)
- [Rufus](https://github.com/pbatard/rufus)

### Future Plans 🚀
The goal is to make the script even more customizable for everyone. I aim to eliminate as many problems as possible by using try-catch blocks (because surely there must be some) and optimize the code to be cleaner and more concise.
