#update mailboxes
$mbxs = get-mailbox -ResultSize unlimited

 Foreach ($M in $mbxs) { Set-ADUser $M.distinguishedname -Replace @{msExchRecipientDisplayType=-1073741818} }

 #update remotemailboxes

 $RmtMbx = get-remotemailbox -ResultSize unlimited

Foreach ($R in $RmtMbx) { Set-ADUser $R.distinguishedname -Replace @{msExchRecipientDisplayType=-1073740282} }
 
#ACCESS
#onprem
$MBX = "accessed@mailbox"
$user = "accessing@USER"
$M = get-aduser -filter { userprincipalname -eq $MBX }
$U = get-aduser -filter { userprincipalname -eq $user}
Add-ADPermission -Identity $M.distinguishedname -User $U.distinguishedname -AccessRights ExtendedRight -ExtendedRights "Send As"
 
#cloud
$MBX = "accessed@mailbox"
$user = "accessing@USER"
Add-RecipientPermission -Identity $MBX -Trustee $user -AccessRights SendAs -Confirm:$false
 
 

