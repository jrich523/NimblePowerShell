<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Connect-NSArray
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $SystemName,

        # Param2 help description
        [string]
        $UserName="admin",
        [string]
        $Password
    )
    #check for it blah blah
    $script:nsunit = New-Object GroupMgmt
    $script:nsunit.Url = "http://"+$SystemName+":4210/soap"
    $script:sid = [ref]""
    $return = $script:nsunit.login($UserName, $Password, $script:sid)
    if ($return -eq "SMok") {
      $arrname = $script:nsunit.getControllerName($sid.value)
      Write-Host "Logged into array @ " $arrname
    }
    else {
      Write-Host "Couldn't login to " $script:nsunit.Url
    }
}