<#
.Synopsis
   Returns all snapshots
.DESCRIPTION
   Gets a list of all snapshots on the system
.EXAMPLE
   Get-NSSnapShot
.EXAMPLE
   Get-NSSnapshot
#>
function Get-NSSnapShot
{
    [CmdletBinding()]
    [OutputType([snap])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   Position=0)]
        #TODO: wont handle array of names
        #Takes either a vol or string
        $Volume,
        # Snap name you are looking for, wildcards are accepted.
        [Parameter(Position=1)]
        [string]
        $SnapName = "*"
    )

    Begin
    {
        
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        
    }
    Process
    {
        
        if($Volume)
        {
            if($Volume.gettype().name -ne "vol"){$Volume=Get-NSVolume -Name $Volume}
            $snaps = New-Object snap
            $rtncode = $Script:NSUnit.getSnapList($sid.Value, $Volume.Name, [ref]$snaps)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
            }
            else
            {
                $snaps | ?{$_.name -like $SnapName}
            }
        }
        else
        {
            
            Get-NSVolume | Get-NSSnapShot -SnapName $SnapName
        }
    }
    End
    {
    }
}

<#
.Synopsis
   Creates a new snapshot
.DESCRIPTION
   Takes a new snapshot of a specified volume, allowing you to control if its writeable and if its online or not.
.EXAMPLE
   Get-NSVolume -name testvol | New-NSSnapshot -name Test1
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-NSSnapshot
{
    [CmdletBinding()]
    [OutputType([snap])]
    Param
    (
        # New name for snapshot
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Name,
        # volume you'd like to take a snapshot of. This uses a Vol objecct, for pipeline use with other cmdlets
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeLine=$true,ParameterSetName="inobj")]
        [vol]
        $InputObject,
        # Volume you'd like to take a snapshot of
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="volume")]
        [string]
        $Volume,
        # Volume collection you'd like to take a snapshot of.
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="volumeCollection")]
        [string]
        $VolumeCollection,
        $Description,
        [switch]
        $Online,
        [switch]
        $Writable
    )

    Begin
    {
        
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
    }
    Process
    {
        
        
        Write-Verbose "Checking to see if Snap name is in use"
        if(Get-NSSnapShot -SnapName $name)
        {
            Write-Error "Snap $name is already in use"
            return
        }
        
        if($VolumeCollection)
        {
            Write-Verbose "Creating snapshot from volume collection"
            #handles case issues and checks for volumes to snap
            if($col = Get-NSVolumeCollection -Name $VolumeCollection)
            {
                if($col.volumes)
                {
                    $VolumeCollection = $col.name

                    $sppr = new-object snapprotpolrequest
                    $sppr.name = $Name
                    if($Description){$sppr.description = $Description}
                    if($Online){$sppr.online=$true}
                    if($Writable){$sppr.writable=$true}

                    $rtncode = $Script:NSUnit.snapProtPol($sid.Value,$VolumeCollection,$sppr)
                }
                else
                {
                    Write-Error "Volume collection has no volumes in it"
                    return
                }
            }
            else
            {
                Write-Error "Cant find volume collection"
                return
            }
        }
        else
        {
            if($InputObject)
            {
                Write-Verbose "Volume object passed in, using that"
                $Volume = $InputObject.name
            }
            else
            {
                #bypass CASE issues
                Write-Verbose "volume names passed in, looking for volume object"
                $Volume = Get-NSVolume | ?{$_.name -eq $Volume} | select -ExpandProperty Name
            }
            ##set prop
            $snapattr = New-Object snapcreateattr
            $snapattr.name = $Name
            if($Description){$snapattr.description = $Description}
            if($Online){$snapattr.online=$true}
            if($Writable){$snapattr.writable=$true}
            $str=""
        
            $rtncode = $Script:NSUnit.snapVol($sid.Value, $Volume, $snapattr,[ref]$str)
        }



        if($rtncode -ne "Smok")
        {
            Write-Error "Error creating snapshot! code: $rtncode" -ErrorAction Stop
        }
        else
        {
            Get-NSSnapShot -Volume $Volume -SnapName $Name
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
function Remove-NSSnapShot
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]

    Param
    (
        # Name of the volume you'd like to delete
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName="cmd",
                   Position=0)]
        [string]
        $SnapName,

        #
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ParameterSetName="cmd",
                   Position=1)]
        $Volume,
        # the Snap object to remove
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="InputObject",
                   Position=0)]
        [snap]
        $InputObject,
        
        # Bypass any prompting and just remove it
        [switch]
        $Force
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        if($Force){$ConfirmPreference= 'None'}
    }
    Process
    {
        if($InputObject){$Volume = $InputObject.volume;$SnapName=$InputObject.name}
        if($Volume -is "vol"){$Volume=$Volume.name}
        if($PSCmdlet.ShouldProcess($Volume,"Delete Snapshot '$SnapName'"))
        {
            $rtncode = $Script:nsunit.deleteSnap($sid.value,$volume,$SnapName)
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
   Creates clone of a snapshot
.DESCRIPTION
   Creates a zero write clone from a snapshot
.EXAMPLE
   
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-NSClone
{
    [CmdletBinding()]
    Param
    (
        # Name of the new cloned volume
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ParameterSetName="string",
                   Position=1)]
        [Parameter(Mandatory=$true,
                   ParameterSetName="inobj",
                   Position=1)]
        [ValidatePattern('^[a-z,A-Z,\d,\.,-]+$')]
        [string]
        $Name,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   Position=2,
                   ParameterSetName="string")]
        
        [string]
        $Snap,
        [Parameter(Mandatory=$true,
                   Position=3,
                   ParameterSetName="string")]
        [string]
        $Volume,
        # Snapshot object to make a clone of
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ParameterSetName="inobj")]
        [snap]
        $InputObject

    )
    Begin
    {  
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
    }
    Process
    {
        
        if(Get-NSVolume -Name $name)
        {
            Write-Error "Name ($name) already in use!"
        }
        else
        {
            if($InputObject)
            {
                Write-Debug "snap passed in"
                $Snap = $InputObject.name
                $volume = $InputObject.volume
            }
            else
            {
                #avoid any case issues
                Write-Debug "Using strnig names"
                $tempSnap = Get-NSSnapShot -Volume $Volume -SnapName $Name
                $snap = $tempSnap.name
                $volume = $tempSnap.volume
            }
            $volobj = Get-NSVolume -Name $Volume
            Write-Debug "using snap: $Snap"
            Write-Debug "using volume: $volume"
            
            $attr = new-object VolCreateAttr
            $attr.name = $Name
            $attr.size = $volobj.Size
            #vol prop
            $attr.warnlevel = $volobj.warnlevel
            $attr.quota = $volobj.quota
            $attr.reserve = $volobj.reserve
            #snap prop
            $attr.snapquota =$volobj.snapquota
            $attr.snapreserve = $volobj.snapreserve
            $attr.snapwarnlevel = $volobj.snapwarnlevel
            #gen prop
            
            $attr.online = $true
            $attr.perfpolname = $volobj.perfpolname
        
            $attr.multiinitiator = $volobj.multiinitiator
            
            
            $rtncode = $script:nsunit.CloneVol($script:sid.Value,$Volume,$Snap,$attr)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error Creating volume $Name! code: $rtncode"
            }
            Get-NSVolume $Name
        }
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
function Set-NSSnapState
{
    [CmdletBinding()]
    Param
    (
        # Volume to set.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,ParameterSetName="snap")]
        [string]
        $Volume,
        # Snap to set.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=1,ParameterSetName="snap")]
        [string]
        $SnapName,

        # Set volume online.
        [parameter(mandatory=$true,parametersetname='on')]
        [parameter(parametersetname='snap')]
        [parameter(parametersetname='inputobject')]
        [switch]
        $Online,
        # Set volume Offline.
        [parameter(mandatory=$true,parametersetname='off')]
        [parameter(parametersetname='snap')]
        [parameter(parametersetname='inputobject')]
        [switch]
        $Offline
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
    }
    Process
    {
        Write-Host "Vol is $Volume and Snap is $SnapName"
        if($Volume){$volume = Get-NSVolume $Volume|select -ExpandProperty name}
        if($SnapName){$snap = Get-NSSnapShot $SnapName|select -ExpandProperty name}
        #Write-Host "Vol is $volume and Snap is $snap"
        #if($InputObject){$Volume = $InputObject.name}
        $on = if($Online){$true}else{$false}
        $rtncode = $Script:NSUnit.onlineSnap($sid.Value, $volume, $SnapName, $on)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting snapshot list!! code: $rtncode" -ErrorAction Stop
        }
    }
    End
    {
    }
}