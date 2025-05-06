# PowerShell script to find a specific alias in Exchange On-Premise

# Define the alias to search for
$aliasToSearch = "your_alias@domain.com"

# Add the Exchange cmdlets to the session
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

# Search for the SMTP address directly in all email addresses
$recipient = Get-Recipient -ResultSize Unlimited | Where-Object { $_.EmailAddresses -contains "SMTP:$aliasToSearch" }

# Output the result if found
if ($recipient) {
    $recipient | Select-Object Name, Alias, PrimarySmtpAddress
} else {
    Write-Host "No recipient found with SMTP address '$aliasToSearch'."
}
