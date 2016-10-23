$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential

$user_list = Get-MsolUser | Where City -eq 'Old_City' | select DisplayName, UserPrincipalName

$user_modified = @()

foreach ($user in $user_list) {

    if ($user.City -eq 'Old_City'){
        
        Set-MsolUser -UserPrincipalName $user.UserPrincipalName -Office 'New_Office' -StreetAddress 'New_Address' -City 'New_City' -PostalCode 'New_PostalCode' 
    
        #Log User modified. 
        $Object = new-object PSObject
        $Object | add-member -membertype NoteProperty -name "DisplayName" -Value $user.DisplayName
        $Object | add-member -membertype NoteProperty -name "UserPrincipalName" -Value $user.UserPrincipalName
        $user_modified += $Object
    }
}

$user_modified | Export-Csv -path C:\User_Modified.csv -NoTypeInformation 


