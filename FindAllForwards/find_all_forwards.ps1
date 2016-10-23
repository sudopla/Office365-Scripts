#Connnect to EoP
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session


#User to find, email to find all forwardings
$message = "This script is going to find all the users or distribution groups that are forwaring their emails to this User."
Write-Output $message

$user_to_find = Read-Host 'Type the username: '

#Function 
function get_distro_groups_for_user($user_to_look_for) {
    $Mailbox=get-Mailbox $user_to_look_for
    $DN=$mailbox.DistinguishedName
    $Filter = "Members -like ""$DN"""
    Get-DistributionGroup -ResultSize Unlimited -Filter $Filter
} 


#1. Find all user(s) forwarding email to this user (Mail Flow web portal)

#Recursive function to find all the forwarding chain
function get_all_forwards($user_identity){
  
    $mailboxes = Get-Mailbox | Where ForwardingAddress -eq $user_identity | select UserPrincipalName, DisplayName, Identity
    
    if($mailboxes){
        foreach($mailbox in $mailboxes){
            $output1 = "`n" + $mailbox.DisplayName +" emails ("+$mailbox.UserPrincipalName+")" +" are being forwarded to " + $user_identity     
            Write-Output $output1
            get_all_forwards($mailbox.Identity)  #keep the chain
        }   
    } else {
        $output = "No one is forwarding emails to " + $user_identity
        Write-Output $output
    }
}

get_all_forwards($user_to_find)


#2. Find all distro groups the user belongs to

$distro_groups = get_distro_groups_for_user($user_to_find)

$output1 = "Distribution Group(s) this user belongs to: "
Write-Output "`n"
Write-Output $output1

foreach($group in $distro_groups){
    $output2 = "   " + $group.Name + " (" + $group.PrimarySmtpAddress + ")"
    Write-Output $output2
}

#2.a Find if someone is forwarding to any of these distro groups 

$output1 = "`nSee if there are other emails being forwarded to any of the distribution groups displayed before ..."
Write-Output $output1

$temp = 0
foreach($group in $distro_groups){
    $mailboxes = Get-Mailbox | Where ForwardingAddress -eq $group.PrimarySmtpAddress | select UserPrincipalName, DisplayName

    if($mailboxes){
        $temp = 1
        foreach($mailbox in $mailboxes){
            $output2 = "   " + $mailbox.DisplayName + "(" + $mailbox.UserPrincipalName + ")"
            Write-Output $output2
        }
    } 
}

if($temp -eq 0){
    Write-Output "   No"
}


#Close EOP Session
Remove-PSSession $Session