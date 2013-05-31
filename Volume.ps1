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
function Get-NSVolume
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Name
    )

    Begin
    {
        $rtnvols = @()
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        $vols = New-Object Vol
        $rtncode = $Script:NSUnit.getVolList($sid.Value, [ref]$vols)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
        }
            
    }
    Process
    {
        if($name)
        {
            $rtnvols += $vols | where {$_.name -like $name}
        }
        else
        {
            $rtnvols = $vols
        }
    }
    End
    {
        $rtnvols
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
function New-NSVolume
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
function Set-NSVolumeState
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Volume,

        # Param2 help description
        [parameter(mandatory=$true,parametersetname='on')]
        [switch]
        $Online,
        [parameter(mandatory=$true,parametersetname='off')]
        [switch]
        $Offline
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
        $on = if($Online){$true}else{$false}
        $rtncode = $Script:NSUnit.onlineVol($sid.Value, $volume,$On)
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
function Remove-NSVolume
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]

    Param
    (
        # Name of the volume you'd like to delete
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Name,

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
        
        ###if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
        if($Force){$ConfirmPreference= 'None'}
    }
    Process
    {
        
        $vol = Get-NSVolume $name
        $conns = $vol.numconnections
        ## delete snaps
            ##todo: impliment snap delete logic
            ## it WILL delete when there are snaps
        ## take offline
        if($conns -gt 0)
        {
            if(-not $PSCmdlet.ShouldProcess("Connected Sessions","There are $conns open still, terminate?","Connected Hosts"))
            {
                break
            }
        }
        if($vol.online)
        {
            if($PSCmdlet.ShouldProcess($name,"Take volume offline"))
            {
                Set-NSVolumeState -Volume $name -Offline
            }
            else
            {
                break
            }
        }

        ##delete
        if($PSCmdlet.ShouldProcess($name,"Delete Volume"))
        {
            #set offline
            $rtncode = $Script:nsunit.deleteVol($sid.value,$name)
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