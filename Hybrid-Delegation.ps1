FULL ACCESS
###########################################
#     full access (MailboxPermission)     #
###########################################
Add-MailboxPermission -Identity "Terry Adams" -User "Kevin Kelly" -AccessRights FullAccess -InheritanceType All

###########################################
# SET Automapping (msExchDelegateListLink)
###########################################

$A = Get-ADUser MAILBOX
$b = Get-ADUser USER
$dn = $b.DistinguishedName
Set-ADUser -Identity $A.DistinguishedName -Add @{msExchDelegateListLink=$dn}

#######
# GET #
#######

$A = Get-ADUser MAILBOX
get-ADUser -Identity $A.DistinguishedName -Properties msExchDelegateListLink | select -ExpandProperty msExchDelegateListLink

###########################################
#   ACLABLE 
###########################################

Set-OrganizationConfig -ACLableSyncedObjectEnabled $True

###########################################
#            update mailboxes             #
#       (ACLable user MBX onprem)         #
###########################################

$mbxs = get-mailbox -ResultSize unlimited | ? { $_.recipienttypedetails -eq "UserMailbox" }
Foreach ($M in $mbxs) { Set-ADUser $M.distinguishedname -Replace @{msExchRecipientDisplayType=-1073741818} }

###########################################
#         update remotemailboxes          #
#      (ACLable remote MBX cloud)         #
###########################################
$RmtMbx = get-remotemailbox -ResultSize unlimited | ? { $_.recipienttypedetails -eq 'RemoteUserMailbox' } 
Foreach ($R in $RmtMbx) { Set-ADUser $R.distinguishedname -Replace @{msExchRecipientDisplayType=-1073740282} }

###########################################
#    Azure AD Connect -> Refresh Schema   #
#      ++ multiple initial syncs          #
###########################################

###########################################
#            SENDAS ACCESS                #
###########################################
# Local --> Cloud has to be set from Onprem
# Cloud --> Local has to be set from Cloud
###########################################
#       NEW - ONPREM "Send As"            #
###########################################

    $MBX = "accessed@mailbox"
   $user = "accessing@USER"

$M = get-aduser -filter { userprincipalname -eq $MBX }
$U = get-aduser -filter { userprincipalname -eq $user}
$Param = @{ Identity = $M.distinguishedname
                User = $U.distinguishedname
        AccessRights = ExtendedRight
      ExtendedRights = "Send As" }
   Add-ADPermission @Param

###########################################
#      NEW - CLOUD SendAs                 #
###########################################

     $MBX = "accessed@mailbox"
    $user = "accessing@USER"

$Param = @{ Identity = $MBX
             Trustee = $user
        AccessRights = SendAs }
Add-RecipientPermission @Param

###########################################
##  CLASSIC - ONPREM "Send As"            #
###########################################

$MBX = "accessed@mailbox"
$user = "accessing@USER"

$M = get-aduser -filter { userprincipalname -eq $MBX }
$U = get-aduser -filter { userprincipalname -eq $user}

Add-ADPermission -Identity $M.distinguishedname -User $U.distinguishedname -AccessRights ExtendedRight -ExtendedRights "Send As"
###########################################
#   CLASSIC - CLOUD SendAs
###########################################
$MBX = "accessed@mailbox"
$user = "accessing@USER"

Add-RecipientPermission -Identity $MBX -Trustee $user -AccessRights SendAs -Confirm:$false

###########################################
#        ON BEHALF ACCESS (outlook)       #
###########################################
# Local -> Cloud  - set from Onprem       #
# Cloud -> Local has to be set from Cloud #
###########################################
#      cloud > onprem mailuser            #
###########################################

set-mailbox MBX-grantonbehalfto USER

###########################################
#   onprem remotemailbox > onpem mailbox  #
###########################################

set-remotemailbox MBX -grantonbehalfto USER

