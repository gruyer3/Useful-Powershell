# This script is capable of disabling forwarding to specified users mailboxes on the on premise Exchange servers
# May be useful in case of user deboarding process or if you'd like to disable forwarding for multiple users
# CSV file that's used to identify users must at least contain information about objects CanonicalName and DisplayName as below:
#       CanonicalName;DisplayName
#       "Object_CanonicalName";"Object_DisplayName"
#       "Object2_CanonicalName";"Object2_DisplaName"
# etc.

# Import the Exchange module
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Start transcription, make sure you're choosing your preferred path
Start-Transcript -Path "C:\your\path\$(Get-Date -Format 'yyyy-MM-dd')_RemoveForwarding_Transcript.log" -Append

# Import users' info from a CSV file
# Make sure you've changed path in $users variable to your CSV file path
$users = Import-Csv -Path "C:\your\path\CSV_FileName.csv" -Encoding UTF8 -Delimiter ";"
$users | Format-Table

# If you have many objects, you may specify the OU you'd like to go with, so the script runs more smoothly
# Change $ou variable to your specified path or comment/delete it if you wouldn't like to use that functionality
$ou = "OU=your,OU=path,DC=domain,DC=com"
# If you'd like to search through every object, you should remove filtering with Where-Object { $_.DistinguishedName -like "*$ou*" } along with one of the pipelines
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.DistinguishedName -like "*$ou*" } | Select-Object DisplayName, PrimarySmtpAddress, ForwardingAddress, ForwardingSmtpAddress

# Loop through each object and disable forwarding if the logic matches
# Use -WhatIf parameter first to avoid unexpected issues
foreach ($mailbox in $mailboxes) {
    foreach ($user in $users) {
        $userCN = $user.CanonicalName

        if ($mailbox.ForwardingAddress -eq $userCN) {
            Write-Host "Match found: Removing forwarding from $($mailbox.DisplayName) to mailbox $($user.DisplayName)" -ForegroundColor Yellow
            # Converting PrimarySmtpAddress to string ensures compatibility
            Set-Mailbox -Identity $($mailbox.PrimarySmtpAddress.ToString()) -ForwardingAddress $null -ForwardingSmtpAddress $null -Confirm:$false #-WhatIf 
        }
    }
}

# Stop transcription
Stop-Transcript