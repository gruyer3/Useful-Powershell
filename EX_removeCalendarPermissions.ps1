# This script removes calendar permissions from users specified in the csv file
# May be useful if you'd like to remove calendar permissions delegated to many users at once

### WARNING! this script have one flaw which is removing permissions based on user Display Name property
### Please be aware of that before using it on a production environment

# Add the Exchange cmdlets to the session
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Start transcription
# Make sure you've provided the path where you'd like to save transcription
Start-Transcript -Path "C:\your\path\$(Get-Date -Format 'yyyy-MM-dd')_RemoveCalendarPermissions_Transcript.log" -Append

# Import users' UPNs from a CSV file
# The script have one flaw which is using users Display Name for filtering and removing permissions
$users = Import-Csv -Path "C:\your\path\CSVFileName.csv" -Encoding UTF8 -Delimiter ";"
$users | Format-Table

# Filter mailboxes to only include users from a specific OU
# Filtering ensures more smooth script performance but if you'd like to get through every object it may be removed
# Provide your preffered OU scope in $ou variable or comment / delete the line along with what's after the pipeline in $mailboxes variable
$ou = "OU=your,OU=preferred,OU=scope,DC=domain,DC=com"
$mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.DistinguishedName -like "*$ou*" }

# Loop through each mailbox and remove calendar permissions
foreach ($mailbox in $mailboxes) {
    foreach ($user in $users) {
        $userDN = $user.DisplayName
        # Calendar folders may be called differently depending on Outlook's language settings
        $localizedCalendars = @("Calendar", "Kalender", "Kalendář", "Calendrier", "Calendario", "Kalendár", "Kalendarz")
        $calendars = $null

        foreach ($localizedCalendar in $localizedCalendars) {
            $calendars = Get-MailboxFolderPermission -Identity "$($mailbox.PrimarySmtpAddress):\$localizedCalendar" -ErrorAction SilentlyContinue
            if ($calendars -ne $null) {
            break
            }
        }

        if ($calendars -eq $null) {
            Write-Output "No calendar permissions found for $($mailbox.PrimarySmtpAddress) in any language" -ForegroundColor Cyan
            continue
        }
        $permissions = $calendars.User
        if ($permissions.DisplayName -eq $userDN) {
            Write-Output "Removing $userDN from $($mailbox.PrimarySmtpAddress):\$localizedCalendar" -ForegroundColor Yellow
            # Use -WhatIf parameter first to avoid unexpected issues
            Remove-MailboxFolderPermission -Identity "$($mailbox.PrimarySmtpAddress):\$localizedCalendar" -User $userDN -Confirm:$false #-WhatIf
        }
    }
}

# Stop transcription
Stop-Transcript