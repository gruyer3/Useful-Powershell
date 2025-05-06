# This script ensures that all shared mailboxes permissions are removed from users specified in csv file
# CSV file should provide two user properties which is User logon name and Canonical name, as below:
#          User;CanonicalName
#          "domain\username";"CanonicalName"
#          "domain\username2";"CanonicalName2"
# etc. 

# Add the Exchange cmdlets to the session
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Start transcription
# Make sure you've provided the correct path 
Start-Transcript -Path "C:\your\path\$(Get-Date -Format 'yyyy-MM-dd')_RemoveSharedMailboxesPermissions_Transcript.log" -Append

# Import users' UPNs from a CSV file
$users = Import-Csv -Path "C:\your\path\CSVFileName.csv" -Encoding UTF8 -Delimiter ";"
$users | Format-Table

# Get all shared mailboxes permissions and store them in a variable
$permissions = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Get-MailboxPermission | Select-Object identity,user,accessrights
$send_as = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Get-RecipientPermission 

# Remove Full Access permissions
# Use -WhatIf parameter to avoid unexpected issues
foreach ($permission in $permissions) {
    foreach ($user in $users) {
        $var = $permission.User
        if ($var.RawIdentity -eq $user.User) {
            Write-Host "Removing FullAccess permission for user $($user.User) on mailbox $($permission.Identity) with access rights $($permission.AccessRights)" -ForegroundColor Green
            Remove-MailboxPermission -Identity $permission.Identity -User $user.User -AccessRights $permission.AccessRights -Confirm:$false #-WhatIf
        }
    }
}

# Remove Send As permissions
# Use -WhatIf parameter to avoid unexpected issues
foreach ($sends in $send_as) {
    foreach ($user in $users) {
        if ($sends.Trustee -eq $user.CanonicalName) {
            Write-Host "Removing Send As permission for user $($sends.Trustee) on mailbox $($sends.Identity)" -ForegroundColor Yellow
            Remove-ADPermission -Identity $sends.Identity -User $user.User -ExtendedRights "Send As" -Confirm:$false #-WhatIf
        }
    }
}

# Stop transcription
Stop-Transcript