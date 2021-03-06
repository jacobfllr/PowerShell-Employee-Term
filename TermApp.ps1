######################################
##									##
##	Employee Termination Script		##
##									##
######################################


#Import Snapins for AD and Exchange
##Add-PSSNapin -Name Microsoft.Exchange.Management.PowerShell.E2010
Import-Module ActiveDirectory 

Function DateEntry() {
	$Date = [string](Get-Date).Day + "-" + (Get-Date).Month + "-" + (Get-Date).Year
	return ($Date)
}

#Pass username to $termuser variable
#Prompt for Username
$termuser = read-host "Enter user name to disable"

#Exports Group Memberships to CSV
$target = "\\BUSIT04\deploy$\term\" + $termuser + ".csv"
Get-ADPrincipalGroupMembership $termuser | select name | Export-Csv -path $target
write-host "* Groups have been exported to" $target

#Move to "Disabled Users" OU
$UserDN  = (Get-ADUser -Identity $termuser)
if (($UserDN).Enabled -eq $true) {
	Move-ADObject -Identity $UserDN -TargetPath 'OU=Disabled Users,OU=_SPREMPLOYEES,DC=stpaulrad,DC=com'
    write-host "* " $termuser "moved to Disabled Users"
}else{ 
    Write-Warning -Message "$UserDN has already been disabled or was not found." 
    Exit
}

#ADD LOOP HERE TO RE-PROMPT FOR USERNAME... MAKE USERNAME INTO FUNCTION?

write-host "* " $termuser "moved to Disabled Users"
#Change Description to "Terminated DD.MM.YYYY - CURRENT USER"
$terminatedby = $env:username
$termDate = get-date -uformat "%m.%d.%Y"
$termUserDesc = "Terminated " + $termDate + " - " + $terminatedby
set-ADUser $termuser -Description $termUserDesc 
write-host "* " $termuser "description set to" $termUserDesc


#Move Documents folder 
move-item \\dc1fs01\e$\Users\$termuser "\\dc1fs01\e$\Disabled Users Docs\$termuser"
write-host "* Documents folder moved to \\dc1fs01\e$\Disabled Users Docs\$termuser"

##########
#Perform check to see if csv exists before removing groups.
#############
##Variables##
$csvpath = "C:\




#removes from all distribution groups
$dlists =(Get-ADUser $termuser -Properties memberof | select -expand memberof)
foreach($dlist in $dlists){Remove-ADGroupMember $termuser -Identity $dlist -Confirm:$False}
write-host "* Removed from all distribution and security groups"



#disable user
Disable-ADAccount -Identity $termuser

write-host "*** " $termuser "account has been disabled ***"