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
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   Position=0)]
        #TODO: wont handle array of names
        #Takes either a vol or string
        $Volume,
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
    Param
    (
        # New name for snapshot
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true,ParameterSetName="inobj")]
        [vol]
        $InputObject,
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        $Name,
        # Volume you'd like to take a snapshot of
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="string")]
        [string]
        $Volume,
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
        if($InputObject)
        {
            $Volume = $InputObject.name
        }
        else
        {
            #bypass CASE issues
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
                   Position=0)]
        [string]
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
        if($Force){$ConfirmPreference= 'None'}
    }
    Process
    {
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
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
                   Position=2,
                   ParameterSetName="string")]
        
        [string]
        $Snap,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
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