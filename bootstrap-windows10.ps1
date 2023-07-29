[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $Arguments = "& '" + $MyInvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $Arguments
    Break
}

# ---------------------------------------------------------------
# Registry keys
# ---------------------------------------------------------------

$CUContentDeliveryManagerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$CUPersonalizePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$CUDWMPath = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"
$CUMousePath = "HKCU:\Control Panel\Mouse"
$CUExplorerPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$LMExplorerPoliciesPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$LMEdgePoliciesPath = "HKLM:\SOFTWARE\Policies\Edge"


# ---------------------------------------------------------------
# Theme options
# ---------------------------------------------------------------

# Dark mode
Set-ItemProperty -Path $CUPersonalizePath -Name AppsUseLightTheme -Value 0
Set-ItemProperty -Path $CUPersonalizePath -Name SystemUsesLightTheme -Value 0

# Don't color taskbar and start menu
Set-ItemProperty -Path $CUPersonalizePath -Name ColorPrevalence -Value 0


# ---------------------------------------------------------------
# DWM Properties
# ---------------------------------------------------------------

# Accent color
Set-ItemProperty -Path $CUDWMPath -Name AccentColor -Value "ffd77800"

# Color title bars
Set-ItemProperty -Path $CUDWMPath -Name ColorPrevalence -Value 1


# ---------------------------------------------------------------
# Explorer options
# ---------------------------------------------------------------

# Show extensions
Set-ItemProperty -Path $CUExplorerPath -Name HideFileExt 0


# ---------------------------------------------------------------
# Taskbar options
# ---------------------------------------------------------------

# Turn off news and interests
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds -Name ShellFeedsTaskbarViewMode -Value 2

# Button mode search
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 1

# Remove task view
Set-ItemProperty -Path $CUExplorerPath -Name ShowTaskViewButton -Value 0


# ---------------------------------------------------------------
# Windows options
# ---------------------------------------------------------------

# Disable nagware and ads
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name ContentDeliveryAllowed -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name SoftLandingEnabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name SystemPaneSuggestionsEnabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name SilentInstalledAppsEnabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name SubscribedContent-338388Enabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name SubscribedContent-338389Enabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name OemPreInstalledAppsEnabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name PreInstalledAppsEnabled -Value 0
Set-ItemProperty -Path $CUContentDeliveryManagerPath -Name PreInstalledAppsEverEnabled -Value 0

# Remove OneDrive from startup
Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name OneDrive

# Remove Skype
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage

# Remove stupid Edge search bar
New-Item $LMEdgePoliciesPath -Force | Out-Null
Set-ItemProperty -Path $LMEdgePoliciesPath -Name WebWidgetAllowed -Value 0
Set-ItemProperty -Path $LMEdgePoliciesPath -Name WebWidgetIsEnabledOnStartup -Value 0

# Remove meet now
New-Item $LMExplorerPoliciesPath -Force | Out-Null
Set-ItemProperty -Path $LMExplorerPoliciesPath -Name HideSCAMeetNow -Value 1

# Set 1:1 mouse curve for sensitivity 6 out of 11 ticks, 100% scale
Set-ItemProperty -Path $CUMousePath -Name MouseSpeed -Value 0
Set-ItemProperty -Path $CUMousePath -Name MouseThreshold1 -Value 0
Set-ItemProperty -Path $CUMousePath -Name MouseThreshold2 -Value 0
Set-ItemProperty -Path $CUMousePath -Name MouseSensitivity -Value 10
Set-ItemProperty -Path $CUMousePath -Name SmoothMouseXCurve -Value 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00
Set-ItemProperty -Path $CUMousePath -Name SmoothMouseYCurve -Value 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00


# ---------------------------------------------------------------
# Software
# ---------------------------------------------------------------

# Download and install winget
$HasWinget = Get-AppPackage -name "Microsoft.DesktopAppInstaller"
if (!$HasWinget) {
    $releases = Invoke-RestMethod -uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    Add-AppPackage -Path ($releases.assets | Where { $_.name.Contains("msix") } | Select -First 1).browser_download_url
    Write-Host "Installed winget"
}

# Install apps
winget install Brave.Brave
winget install Discord.Discord
winget install Discord.Discord.Canary
winget install vscode
winget install Git.Git
winget install chrisant996.Clink
winget install Microsoft.WindowsTerminal
winget install VB-Audio.Voicemeeter.Banana
winget install 7zip.7zip
winget install subhra74.XtremeDownloadManager
winget install Valve.Steam

# Install VS Code extensions
$Extensions = @(
    "ms-vscode.cpptools",
    "ms-vscode.cmake-tools",
    "twxs.cmake",
    "AlexDauenhauer.catppuccin-noctis",
    "thang-nm.catppuccin-perfect-icons",
    "MS-vsliveshare.vsliveshare",
    "ritwickdey.LiveServer"
)

foreach ($Entry in $Extensions) {
    Write-Host "Installing extension: $Entry"
    Start-Process -FilePath "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code" -ArgumentList "--install-extension $Entry" -Wait
}

# Scratch folder
$Script = @"
@echo off
rmdir /s /q "Scratch Folder"
mkdir "Scratch Folder"
"@
$DesktopPath = [Environment]::GetFolderPath("Desktop");
$Script | Out-File -FilePath "$DesktopPath\Clear Scratch.bat" -Encoding UTF8
New-Item -ItemType Directory "Scratch Folder"

Write-Host "Press any key to reboot or close to reboot later"
Pause
Restart-Computer