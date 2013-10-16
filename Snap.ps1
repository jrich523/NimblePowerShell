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
        [Parameter(manditory=$true,ValueFromPipeline=$true,
                   Position=0)]
        #TODO: wont handle array of names
        #Takes either a vol or string
        $Volume,
        [string]
        $SnapName
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
function Remove-NSSnapShot
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]

    Param
    (
        # Name of the volume you'd like to delete
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Name,

        #
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $Volume,
        
        # Param2 help description
        [switch]
        $Force
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
        if($Force){$ConfirmPreference= 'None'}
    }
    Process
    {
        if($PSCmdlet.ShouldProcess($name,"Delete Snapshot from $volume"))
        {
            $rtncode = $Script:nsunit.deleteSnap($sid.value,$volume,$name)
            if($rtncode -ne "SMok")
            {
                write-error "Delete failed! Code: $rtncode"
            }
        }
    }
    End
    {

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
function New-NSClone
{
    [CmdletBinding()]
    Param
    (
        # can only contain letters,numbers,dash,dot - write regex
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [ValidatePattern('^[a-z,A-Z,\d,\.,-]+$')]
        [string]
        $Name,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        
        $Size,

        #desc
        [string]
        $Description,

        #more
        [switch]
        $MultipleInitiator,
        
        #details
        [ValidateRange(0,100)]
        [int]
        $VolumeReserve=0,

        #details
        [ValidateRange(0,100)]
        [int]
        $VolumeQuote=100,

        #details
        [ValidateRange(0,100)]
        [int]
        $VolumeWarning=80,

        #details
        [ValidateRange(0,100)]
        [int]
        $SnapShotReserve=0,

        #details - -1 means unlimited
        [ValidateRange(-1,100)]
        [int]
        $SnapShotQuote=-1,

        #details
        [ValidateRange(0,100)]
        [int]
        $SnapShotWarning=0

    )
    DynamicParam {

        New-DynamicParam -Name PerformancePolicy -Options (Get-NSPerfPolicy | select -ExpandProperty name) -Manditory -Position 3
    }
    Begin
    {
        $attr = New-Object VolCreateAttr
        $attr.size = $Size
        #vol prop
        $attr.warnlevel = $Size * ($VolumeWarning /100)
        $attr.quota = $Size * ($VolumeQuote/100)
        $attr.reserve = $Size * ($VolumeReserve/100)
        #snap prop
        if($SnapShotQuote -eq -1)
        {
            $attr.snapquota = 9223372036854775807  ##unlimited
        }
        else
        {
            $attr.snapquota = $size * ($SnapShotQuote /100)
        }
        $attr.snapreserve = $Size * ($SnapShotReserve/100)
        $attr.snapwarnlevel = $size * ($SnapShotWarning/100)
        #gen prop
        $attr.description = $Description
        $attr.online = $true
        $attr.perfpolname = $PSBoundParameters.PerformancePolicy
        
        if($MultipleInitiator)
        {
            $attr.multiinitiator = $true
        }
        

    }
    Process
    {
        $attr.name = $Name
        $rtncode = $script:nsunit.createVol($script:sid.Value,$attr,[ref]$str)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error Creating volume $Name! code: $rtncode"
        }
        Get-NSVolume $Name

    }
    End
    {
    }
}