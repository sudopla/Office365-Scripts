#Connect to EOP and Office365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $credential

#Get all the users with Exchange Online Plan 2 license
$email_account = Get-MsolUser | Where-Object { $_.Licenses.AccountSKUid -eq 'corpepals:EXCHANGEENTERPRISE' } | select DisplayName, SignInName 

$lines = @()

foreach ($item in $email_account) {

    $share = Get-Mailbox -Identity $item.SignInName | select IsShared
    
    if ($share.IsShared -eq $true) {

       #get mailbox size
       $TotalItemSize = Get-MailboxStatistics -Identity $item.SignInName | select TotalItemSize
        
       #get Delegation users
       $share_users = Get-MailboxPermission -Identity $item.SignInName | select User

       $recipients = ""

        foreach($recipient_email in $share_users.User) {
                #real users are shown with the email address
                if($recipient_email.Contains('@')){
                        $recipients = $recipients + $recipient_email + ', '
                }
        }

       $Object = new-object PSObject
       $Object | add-member -membertype NoteProperty -name "DisplayName" -Value $item.DisplayName
       $Object | add-member -membertype NoteProperty -name "SignInName" -Value $item.SignInName
       $Object | add-member -membertype NoteProperty -name "TotalItemSize" -Value $TotalItemSize.TotalItemSize
       $Object | add-member -membertype NoteProperty -name "Recipients" -Value $recipients
       
       $lines += $Object    

    } 
    
}

$lines | Export-Csv C:\Shared_Mailboxes.csv -NoTypeInformation