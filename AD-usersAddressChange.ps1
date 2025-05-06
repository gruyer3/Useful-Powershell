# Script should be used to globally change AD users address properties
# Especially useful during offices move

# Search for all AD users with specified address properties
$allUsers = Get-ADUser -Filter {streetAddress -eq "Old address line 1
Old address line 2"} -Properties streetAddress, City, postalCode 

# Loop through each user and set new address
foreach ($user in $allUsers)
{
    Set-ADUser $user -StreetAddress "New address line 1
New address line 2"
    Set-ADUser $user -City "New City"
    Set-ADUser $user -PostalCode "New Postal Code"
}