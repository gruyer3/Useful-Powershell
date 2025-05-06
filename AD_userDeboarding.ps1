# Script that I've been using in case of user deboarding process
# It takes care of all the tasks required for AD user account object
# Be aware that this script was written with compliance in a specific organization requirements and may not be suitable in every case

# Start transcription
# Make sure you've provided the correct path 
Start-Transcript -Path "C:\your\path\$(Get-Date -Format 'yyyy-MM-dd')_userDeboarding.log" -Append

# Prompt for the AD account username or provide specified value directly in variable
$username = Read-Host "Enter AD account username"

# Generate password and change it twice
$password = -join ((48..57) + (65..90) + (97..122) + (33..47) | Get-Random -Count 10 | ForEach-Object { [char]$_ })
Write-Host "Changing password once"
Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -String $password -AsPlainText -Force)

$password = -join ((48..57) + (65..90) + (97..122) + (33..47) | Get-Random -Count 10 | ForEach-Object { [char]$_ })
Write-Host "Changing password twice"
Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -String $password -AsPlainText -Force)

# Delete phone number to avoid potential issues with GAL
Write-Host "Removing phone number"
Set-ADUser -Identity $username -Clear mobile

# Disable the account
Write-Host "Disabling account"
Disable-ADAccount -Identity $username

# Move the account to OU that's not syncing to Entra
$userZZZ = "OU=your,OU=specified,OU=path,DC=domain,DC=com"
Write-Host "Moving to the specified OU"
Get-ADUser -Identity $username | Move-ADObject -TargetPath $userZZZ

# Clear all groups
Write-Host "Groups membership cleanup"
$username | Get-ADPrincipalGroupMembership | ? {$_.Name -ne "Domain Users"} | Remove-ADGroupMember -Members $username -Confirm:$false

# Stop transcription
Stop-Transcript