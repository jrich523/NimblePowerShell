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
function Get-NSSnapShot
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   Position=0)]
        #TODO: wont handle array of names
        #Takes either a vol or string
        $Volume
    )

    Begin
    {
        $rtnsnaps = @()
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        $snaps = New-Object snap
        $rtncode = $Script:NSUnit.getSnapList($sid.Value, $Volume, [ref]$snaps)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
        }
    }
    Process
    {
        #filter handles by soap call
    }
    End
    {
        $snaps
    }
}

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
function New-NSSnapshot
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        #new name for snapshot
        $Name,
        #volume you'd like to snap
        $Volume,
        $Description,
        [switch]
        $Online,
        [switch]
        $Writable
    )

    Begin
    {
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        ##set prop
        $snapattr = New-Object snapcreateattr
        $snapattr.name = $Name
        if($Description){$snapattr.description = $Description}
        if($Online){$snapattr.online=$true}
        if($Writable){$snapattr.writable=$true}
        $str=""
        
        $rtncode = $Script:NSUnit.snapVol($sid.Value, $Volume, $snapattr,[ref]$str)
        
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
        }
    }
    Process
    {
    }
    End
    {
    }
}