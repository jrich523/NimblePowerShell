
. $psScriptRoot\Utility.ps1
. $psScriptRoot\Login.ps1
. $psScriptRoot\Volume.ps1
. $psScriptRoot\array.ps1
. $psScriptRoot\perfpolicy.ps1
. $psScriptRoot\snap.ps1
. $psScriptRoot\Initiator.ps1
. $psScriptRoot\VolCol.ps1
. $psScriptRoot\CHAP.ps1


# set default pool, this is a failsafe and is overwritten upon connection
$script:poolname = "default"


$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = { 
    #this shouldnt be needed now
    #Clear-FormatData
}