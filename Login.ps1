<#
.Synopsis
   Connects to Nimble Storge Device
.DESCRIPTION
   This initializeds the connection in to the storage unit. 
   Currently there is no hiding of the password, this will be implimented in future versions
.EXAMPLE
   Connect-NSArray -SystemName 192.168.15.23 -password theunitpassword

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
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $Password,
        # Specify a default pool name to be used. 'Default' is the default.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]
        $PoolName="default"
    )
    
    #save default pool name
    $script:poolname = $PoolName

    #check for it blah blah

    $script:nsunit = New-Object Nimble.GroupMgmt
    $script:nsunit.Url = "http://"+$SystemName+":4210/soap"
    $script:sid = [ref]""
    $return = $script:nsunit.login($UserName, $Password, $script:sid)
    if ($return -eq "SMok") {
      $err = New-Object Nimble.smErrorType
      $script:GroupConfig = $script:nsunit.getGroupConfig($script:sid.value,[ref]$err)
      $script:ArrayInfo = new-object Nimble.Array
      #todo: need to figure out the best way to find the name
      #$script:nsunit.getArrayInfo($script:sid.value,name,[ref]$script:ArrayInfo)
      $arrname = $script:GroupConfig.groupname
      Write-Host "Logged into array @ $arrname"
    }
    else {
      Write-Host "Couldn't login to " $script:nsunit.Url
    }
}