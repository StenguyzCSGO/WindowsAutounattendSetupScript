# Check if the user is running as Administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

# Set the interface configuration
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
Clear-Host

# Maximize PowerShell window
$hwnd = (Get-Process -Id $PID).MainWindowHandle
$signature = @"
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
Add-Type -MemberDefinition $signature -Name Win32ShowWindow -Namespace Win32Functions
[Win32Functions.Win32ShowWindow]::ShowWindow($hwnd, 3) # 3 = SW_MAXIMIZE

# Save the autounattend configuration
$MultilineComment = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>{LANG}</InputLocale>
            <SystemLocale>{REGION}</SystemLocale>
            <UILanguage>{LANG}</UILanguage>
            <UILanguageFallback>{LANG}</UILanguageFallback>
            <UserLocale>{REGION}</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <TimeZone>Central Standard Time</TimeZone>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Home</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <PlainText>true</PlainText>
                    <Value></Value>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Group>Administrators</Group>
                        <Name>{USERNAME}</Name>
                        <Password>
                            <PlainText>true</PlainText>
                            <Value></Value>
                        </Password>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
    </settings>
    <settings pass="specialize">
        <!-- Placeholder for BitLocker settings -->
    </settings>
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>{LANG}</InputLocale>
            <SystemLocale>{REGION}</SystemLocale>
            <UILanguage>{LANG}</UILanguage>
            <UILanguageFallback>{LANG}</UILanguageFallback>
            <UserLocale>{REGION}</UserLocale>
            <SetupUILanguage>
                <UILanguage>{LANG}</UILanguage>
            </SetupUILanguage>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Path>reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d 1 /f</Path>
                    <Description>Add BypassTPMCheck</Description>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Path>reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d 1 /f</Path>
                    <Description>Add BypassRAMCheck</Description>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <Path>reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d 1 /f</Path>
                    <Description>Add BypassSecureBootCheck</Description>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>4</Order>
                    <Path>reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d 1 /f</Path>
                    <Description>Add BypassCPUCheck</Description>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>5</Order>
                    <Path>reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d 1 /f</Path>
                    <Description>Add BypassStorageCheck</Description>
                </RunSynchronousCommand>
            </RunSynchronous>
            <Diagnostics>
                <OptIn>false</OptIn>
            </Diagnostics>
            <DynamicUpdate>
                <Enable>false</Enable>
                <WillShowUI>OnError</WillShowUI>
            </DynamicUpdate>
            <UserData>
                <AcceptEula>true</AcceptEula>
                <ProductKey>
                    <Key></Key>
                </ProductKey>
            </UserData>
        </component>
    </settings>
</unattend>
"@

# Save the XML template to a temporary file
$path = "$env:TEMP\autounattend.xml"
Set-Content -Path $path -Value $MultilineComment -Force

# Prompt for the account name
$username = Read-Host -Prompt "Enter Account Name"

# Language selection
Clear-Host
$languageOptions = @(
    @{ Code = "af-ZA"; Name = "Afrikaans (South Africa)" },
    @{ Code = "ar-AE"; Name = "Arabic (United Arab Emirates)" },
    @{ Code = "ar-BH"; Name = "Arabic (Bahrain)" },
    @{ Code = "ar-DZ"; Name = "Arabic (Algeria)" },
    @{ Code = "ar-EG"; Name = "Arabic (Egypt)" },
    @{ Code = "ar-IQ"; Name = "Arabic (Iraq)" },
    @{ Code = "ar-JO"; Name = "Arabic (Jordan)" },
    @{ Code = "ar-KW"; Name = "Arabic (Kuwait)" },
    @{ Code = "ar-LB"; Name = "Arabic (Lebanon)" },
    @{ Code = "ar-LY"; Name = "Arabic (Libya)" },
    @{ Code = "ar-MA"; Name = "Arabic (Morocco)" },
    @{ Code = "ar-OM"; Name = "Arabic (Oman)" },
    @{ Code = "ar-QA"; Name = "Arabic (Qatar)" },
    @{ Code = "ar-SA"; Name = "Arabic (Saudi Arabia)" },
    @{ Code = "ar-SY"; Name = "Arabic (Syria)" },
    @{ Code = "ar-TN"; Name = "Arabic (Tunisia)" },
    @{ Code = "ar-YE"; Name = "Arabic (Yemen)" },
    @{ Code = "be-BY"; Name = "Belarusian (Belarus)" },
    @{ Code = "bg-BG"; Name = "Bulgarian (Bulgaria)" },
    @{ Code = "bs-BA"; Name = "Bosnian (Bosnia and Herzegovina)" },
    @{ Code = "ca-ES"; Name = "Catalan (Spain)" },
    @{ Code = "cs-CZ"; Name = "Czech (Czech Republic)" },
    @{ Code = "cy-GB"; Name = "Welsh (United Kingdom)" },
    @{ Code = "da-DK"; Name = "Danish (Denmark)" },
    @{ Code = "de-AT"; Name = "German (Austria)" },
    @{ Code = "de-CH"; Name = "German (Switzerland)" },
    @{ Code = "de-DE"; Name = "German (Germany)" },
    @{ Code = "el-GR"; Name = "Greek (Greece)" },
    @{ Code = "en-AU"; Name = "English (Australia)" },
    @{ Code = "en-CA"; Name = "English (Canada)" },
    @{ Code = "en-GB"; Name = "English (United Kingdom)" },
    @{ Code = "en-IE"; Name = "English (Ireland)" },
    @{ Code = "en-IN"; Name = "English (India)" },
    @{ Code = "en-JM"; Name = "English (Jamaica)" },
    @{ Code = "en-NZ"; Name = "English (New Zealand)" },
    @{ Code = "en-PH"; Name = "English (Philippines)" },
    @{ Code = "en-US"; Name = "English (United States)" },
    @{ Code = "en-ZA"; Name = "English (South Africa)" },
    @{ Code = "es-AR"; Name = "Spanish (Argentina)" },
    @{ Code = "es-BO"; Name = "Spanish (Bolivia)" },
    @{ Code = "es-CL"; Name = "Spanish (Chile)" },
    @{ Code = "es-CO"; Name = "Spanish (Colombia)" },
    @{ Code = "es-CR"; Name = "Spanish (Costa Rica)" },
    @{ Code = "es-DO"; Name = "Spanish (Dominican Republic)" },
    @{ Code = "es-ES"; Name = "Spanish (Spain)" },
    @{ Code = "es-GT"; Name = "Spanish (Guatemala)" },
    @{ Code = "es-HN"; Name = "Spanish (Honduras)" },
    @{ Code = "es-MX"; Name = "Spanish (Mexico)" },
    @{ Code = "es-NI"; Name = "Spanish (Nicaragua)" },
    @{ Code = "es-PA"; Name = "Spanish (Panama)" },
    @{ Code = "es-PE"; Name = "Spanish (Peru)" },
    @{ Code = "es-PR"; Name = "Spanish (Puerto Rico)" },
    @{ Code = "es-UY"; Name = "Spanish (Uruguay)" },
    @{ Code = "es-VE"; Name = "Spanish (Venezuela)" },
    @{ Code = "et-EE"; Name = "Estonian (Estonia)" },
    @{ Code = "eu-ES"; Name = "Basque (Spain)" },
    @{ Code = "fa-IR"; Name = "Persian (Iran)" },
    @{ Code = "fi-FI"; Name = "Finnish (Finland)" },
    @{ Code = "fo-FO"; Name = "Faroese (Faroe Islands)" },
    @{ Code = "fr-BE"; Name = "French (Belgium)" },
    @{ Code = "fr-CA"; Name = "French (Canada)" },
    @{ Code = "fr-FR"; Name = "French (France)" },
    @{ Code = "fr-CH"; Name = "French (Switzerland)" },
    @{ Code = "ga-IE"; Name = "Irish (Ireland)" },
    @{ Code = "gd-GB"; Name = "Scottish Gaelic (United Kingdom)" },
    @{ Code = "gl-ES"; Name = "Galician (Spain)" },
    @{ Code = "he-IL"; Name = "Hebrew (Israel)" },
    @{ Code = "hi-IN"; Name = "Hindi (India)" },
    @{ Code = "hr-HR"; Name = "Croatian (Croatia)" },
    @{ Code = "hu-HU"; Name = "Hungarian (Hungary)" },
    @{ Code = "hy-AM"; Name = "Armenian (Armenia)" },
    @{ Code = "id-ID"; Name = "Indonesian (Indonesia)" },
    @{ Code = "is-IS"; Name = "Icelandic (Iceland)" },
    @{ Code = "it-CH"; Name = "Italian (Switzerland)" },
    @{ Code = "it-IT"; Name = "Italian (Italy)" },
    @{ Code = "ja-JP"; Name = "Japanese (Japan)" },
    @{ Code = "jw-ID"; Name = "Javanese (Indonesia)" },
    @{ Code = "ka-GE"; Name = "Georgian (Georgia)" },
    @{ Code = "kk-KZ"; Name = "Kazakh (Kazakhstan)" },
    @{ Code = "km-KH"; Name = "Khmer (Cambodia)" },
    @{ Code = "kn-IN"; Name = "Kannada (India)" },
    @{ Code = "ko-KR"; Name = "Korean (South Korea)" },
    @{ Code = "ky-KG"; Name = "Kyrgyz (Kyrgyzstan)" },
    @{ Code = "lt-LT"; Name = "Lithuanian (Lithuania)" },
    @{ Code = "lv-LV"; Name = "Latvian (Latvia)" },
    @{ Code = "mk-MK"; Name = "Macedonian (Macedonia)" },
    @{ Code = "ml-IN"; Name = "Malayalam (India)" },
    @{ Code = "mn-MN"; Name = "Mongolian (Mongolia)" },
    @{ Code = "mr-IN"; Name = "Marathi (India)" },
    @{ Code = "ms-MY"; Name = "Malay (Malaysia)" },
    @{ Code = "mt-MT"; Name = "Maltese (Malta)" },
    @{ Code = "nb-NO"; Name = "Norwegian Bokmål (Norway)" },
    @{ Code = "ne-NP"; Name = "Nepali (Nepal)" },
    @{ Code = "nl-BE"; Name = "Dutch (Belgium)" },
    @{ Code = "nl-NL"; Name = "Dutch (Netherlands)" },
    @{ Code = "pl-PL"; Name = "Polish (Poland)" },
    @{ Code = "pt-BR"; Name = "Portuguese (Brazil)" },
    @{ Code = "pt-PT"; Name = "Portuguese (Portugal)" },
    @{ Code = "ro-RO"; Name = "Romanian (Romania)" },
    @{ Code = "ru-RU"; Name = "Russian (Russia)" },
    @{ Code = "si-LK"; Name = "Sinhala (Sri Lanka)" },
    @{ Code = "sk-SK"; Name = "Slovak (Slovakia)" },
    @{ Code = "sl-SI"; Name = "Slovene (Slovenia)" },
    @{ Code = "so-SO"; Name = "Somali (Somalia)" },
    @{ Code = "sq-AL"; Name = "Albanian (Albania)" },
    @{ Code = "sr-SP"; Name = "Serbian (Serbia)" },
    @{ Code = "su-ID"; Name = "Sundanese (Indonesia)" },
    @{ Code = "sv-SE"; Name = "Swedish (Sweden)" },
    @{ Code = "sw-KE"; Name = "Swahili (Kenya)" },
    @{ Code = "ta-IN"; Name = "Tamil (India)" },
    @{ Code = "te-IN"; Name = "Telugu (India)" },
    @{ Code = "th-TH"; Name = "Thai (Thailand)" },
    @{ Code = "tr-TR"; Name = "Turkish (Turkey)" },
    @{ Code = "uk-UA"; Name = "Ukrainian (Ukraine)" },
    @{ Code = "ur-PK"; Name = "Urdu (Pakistan)" },
    @{ Code = "vi-VN"; Name = "Vietnamese (Vietnam)" },
    @{ Code = "xh-ZA"; Name = "Xhosa (South Africa)" },
    @{ Code = "yi-001"; Name = "Yiddish (International)" },
    @{ Code = "zu-ZA"; Name = "Zulu (South Africa)" }
)

# Language selection
Clear-Host
$languageInstructions = "Please choose the language of the installed Windows operating system using the corresponding index"
$languagePrompt = ""

# Build the language list
for ($i = 0; $i -lt $languageOptions.Count; $i++) {
    $languagePrompt += "$($i + 1). $($languageOptions[$i].Code) - $($languageOptions[$i].Name)`n" # Add line break
}

# Display the full language list followed by instructions
Write-Host $languagePrompt
Write-Host $languageInstructions

# Prompt for language index after showing the list
$languageIndex = Read-Host -Prompt "Enter the number corresponding to your chosen language"

# Verify language selection
while ($languageIndex -notin 1..$languageOptions.Count) {
    Write-Host "Invalid choice. Please enter a valid number corresponding to the desired language."
    $languageIndex = Read-Host -Prompt "Enter the number corresponding to your chosen language"
}
$selectedLanguage = $languageOptions[$languageIndex - 1].Code

# Region selection
Clear-Host
$regionOptions = @(
    @{ Code = "fr-FR"; Name = "French (France)" },
    @{ Code = "en-GB"; Name = "English (United Kingdom)" },
    @{ Code = "en-US"; Name = "English (United States)" },
    @{ Code = "en-001"; Name = "English (International) - RECOMMENDED to choose Universal English as region" },
    @{ Code = "es-ES"; Name = "Spanish (Spain)" },
    @{ Code = "de-DE"; Name = "German (Germany)" },
    @{ Code = "it-IT"; Name = "Italian (Italy)" },
    @{ Code = "pt-BR"; Name = "Portuguese (Brazil)" },
    @{ Code = "zh-CN"; Name = "Chinese (Simplified, China)" },
    @{ Code = "ja-JP"; Name = "Japanese (Japan)" },
    @{ Code = "ko-KR"; Name = "Korean (South Korea)" },
    @{ Code = "ru-RU"; Name = "Russian (Russia)" },
    @{ Code = "nl-NL"; Name = "Dutch (Netherlands)" },
    @{ Code = "sv-SE"; Name = "Swedish (Sweden)" },
    @{ Code = "da-DK"; Name = "Danish (Denmark)" },
    @{ Code = "fi-FI"; Name = "Finnish (Finland)" },
    @{ Code = "no-NO"; Name = "Norwegian (Norway)" },
    @{ Code = "pl-PL"; Name = "Polish (Poland)" },
    @{ Code = "tr-TR"; Name = "Turkish (Turkey)" },
    @{ Code = "hi-IN"; Name = "Hindi (India)" },
    @{ Code = "ar-SA"; Name = "Arabic (Saudi Arabia)" },
    @{ Code = "th-TH"; Name = "Thai (Thailand)" }
)

# Region selection
Clear-Host
$regionInstructions = "Please choose the region of the installed Windows operating system using the corresponding index"
$regionPrompt = ""

# Build the region list
for ($i = 0; $i -lt $regionOptions.Count; $i++) {
    $regionPrompt += "$($i + 1). $($regionOptions[$i].Code) - $($regionOptions[$i].Name)`n" # Add line break
}

# Display the full region list followed by instructions
Write-Host $regionPrompt
Write-Host $regionInstructions

# Prompt for region index after showing the list
$regionIndex = Read-Host -Prompt "Enter the number corresponding to your chosen region"

# Verify region selection
while ($regionIndex -notin 1..$regionOptions.Count) {
    Write-Host "Invalid choice. Please enter a valid number corresponding to the desired region."
    $regionIndex = Read-Host -Prompt "Enter the number corresponding to your chosen region"
}
$selectedRegion = $regionOptions[$regionIndex - 1].Code

# Ask if the user wants to disable BitLocker
Clear-Host
$disableBitLocker = Read-Host -Prompt "Do you want to disable BitLocker? (Y/N)"

# Verify BitLocker selection
while ($disableBitLocker -ne "Y" -and $disableBitLocker -ne "N") {
    Write-Host "Invalid choice. Please enter 'Y' for Yes or 'N' for No."
    $disableBitLocker = Read-Host -Prompt "Do you want to disable BitLocker? (Y/N)"
}

# Modify the XML based on BitLocker choice
if ($disableBitLocker -eq "Y") {
    # Add BitLocker settings to the XML
    $bitLockerSettings = @"
        <component name="Microsoft-Windows-BitLocker-DriveEncryption" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DriveEncryption>
                <OSVolume>Disabled</OSVolume>
            </DriveEncryption>
        </component>
"@
    # Insert BitLocker settings in the specialize section
    $MultilineComment = $MultilineComment -replace "<!-- Placeholder for BitLocker settings -->", $bitLockerSettings
} else {
    # Remove the placeholder if BitLocker is not disabled
    $MultilineComment = $MultilineComment -replace "<!-- Placeholder for BitLocker settings -->", ""
}

# Replace placeholders in the XML template with user inputs
$MultilineComment = $MultilineComment -replace "{USERNAME}", $username -replace "{LANG}", $selectedLanguage -replace "{REGION}", $selectedRegion

# Save the modified XML to the temporary file
Set-Content -Path $path -Value $MultilineComment -Force

# Convert the file to UTF-8
Get-Content "$env:TEMP\autounattend.xml" | Set-Content -Encoding utf8 "$env:C:\Windows\Temp\autounattend.xml" -Force

# Delete the old autounattend file
Remove-Item -Path $path -Force | Out-Null

# Prompt the user to move autounattend to the USB drive
Clear-Host
$file = "$env:C:\Windows\Temp\autounattend.xml"
$destination = Read-Host -Prompt "Enter USB Drive Letter" 
$destination += ":\" 
Move-Item -Path $file -Destination $destination -Force

# Open the USB directory to confirm
Start-Process $destination
