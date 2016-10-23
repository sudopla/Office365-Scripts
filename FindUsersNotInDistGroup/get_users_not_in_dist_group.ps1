#Connect to EOP and Office365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential

$message = "This script will find all the users that are not under a specific distribution group."
Write-Output $message

$dist_group_search = Read-Host 'Type the name of the distribution group: '


#Function to find distro group for a user
function get_distro_groups_for_user($user_to_look_for) {
    $Mailbox=get-Mailbox $user_to_look_for
    $DN=$mailbox.DistinguishedName
    $Filter = "Members -like ""$DN"""
    Get-DistributionGroup -ResultSize Unlimited -Filter $Filter
} 
 
#just find Users with Licenses and not block credentials
$users = Get-MsolUser | Where-Object {($_.IsLicensed -eq $true) -and ($_.BlockCredential -eq $false)} | Select UserPrincipalName  

#There is not a funtion to get all the Users that belong to a Distribution Group so one the solution would be to check for every user if this belongs to that group
foreach($user in $users){
    $distro_groups = get_distro_groups_for_user($user.UserPrincipalName)

    $belong_to_group = 'no'

    foreach($group in $distro_groups){
        if($group.Name -eq $dist_group_search){
            $belong_to_group = 'yes'
        }    
    }
    if($belong_to_group -eq 'no'){
        $message = "The user: " + $user.UserPrincipalName +" don't belong to this distribution group"
        Write-Output $message
    }
}

#Close EOP Session
Remove-PSSession $Session