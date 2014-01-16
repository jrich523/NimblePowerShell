<#
.Synopsis
   List all volumes
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
        $Name = "*"
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
        $vols | where {$_.name -like $name}
    }
    End
    {
        
    }
}
<#
.Synopsis
   Creates a new volume.
.DESCRIPTION
   Creates a new volume allowing you to set all aspects of the volume properties but does not handle security.
.EXAMPLE
   New-NSVolume -Name TestVolume -Size 2tb
.EXAMPLE
  New-NSVolume -Name ESXVolume01 -Size 2tb -MultipleInitiator -Description "ESX datastore"
#>
function New-NSVolume
{
    [CmdletBinding()]
    Param
    (
        # The name can only contain letters,numbers,dash,dot.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [ValidatePattern('^[a-z,A-Z,\d,\.,-]+$')]
        [string]
        $Name,

        # Set the size of the volume, PowerShell unit notation can be used, for example 2tb
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        
        $Size,

        # Set the volume description
        [string]
        $Description,

        # Enables Multiple Initiators (VM or Cluster use)
        [switch]
        $MultipleInitiator,
        
        # Reserved space for the volume.
        [ValidateRange(0,100)]
        [int]
        $VolumeReserve=0,

        # Volume Quota
        [ValidateRange(0,100)]
        [int]
        $VolumeQuota=100,

        # Volume warning percent, default is 80%
        [ValidateRange(0,100)]
        [int]
        $VolumeWarning=80,

        # Reserve for snapshot
        [ValidateRange(0,100)]
        [int]
        $SnapShotReserve=0,

        # SnapShot quota, a value of -1 means unlimited, which is the default.
        [ValidateRange(-1,100)]
        [int]
        $SnapShotQuota=-1,

        # SnapShot warning percent
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
        $attr.quota = $Size * ($VolumeQuota/100)
        $attr.reserve = $Size * ($VolumeReserve/100)
        #snap prop
        if($SnapShotQuota -eq -1)
        {
            $attr.snapquota = 9223372036854775807  ##unlimited
        }
        else
        {
            $attr.snapquota = $size * ($SnapShotQuota /100)
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
        $str=""
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
   Change the Volume State.
.DESCRIPTION
   Allows you to set the volumes state to online or offline.
.EXAMPLE
   Set-NSVolumeState $myvol -offline
.EXAMPLE
   Set-NSVolumeState volName -online
#>
function Set-NSVolumeState
{
    [CmdletBinding()]
    Param
    (
        # Volume to set.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $Volume,

        # Set volume online.
        [parameter(mandatory=$true,parametersetname='on')]
        [switch]
        $Online,
        # Set volume Offline.
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
   Deletes a volume. This cmdlet will have additional error checking. Please use caution when using it.
.DESCRIPTION
   This will remove a volume from the unit
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
function Get-NSVolumeACL
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,
                   ParameterSetName="InputObject")]
        [vol]
        $InputObject,

        # Param2 help description
        [string]
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Volume")]
        $Volume
    )

    Begin
    {
    }
    Process
    {
        throw "NotImplimented"
    }
    End
    {
    }
}