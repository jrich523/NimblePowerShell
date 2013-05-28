

. $psScriptRoot\Login.ps1
. $psScriptRoot\Volume.ps1
. $psScriptRoot\array.ps1
. $psScriptRoot\perfpolicy.ps1
. $psScriptRoot\snap.ps1
. $psScriptRoot\Initiator.ps1

$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = { 
    Clear-FormatData
}