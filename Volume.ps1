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
    $SMA = 'System.Management.Automation'
    $Type = 'Collections.ObjectModel.Collection[System.Attribute]'
    $paramName = 'PerformancePolicy'

    $AttributeMandatory = New-Object "$SMA.ParameterAttribute" -Property @{
        ParameterSetName = "__AllParameterSets"
        Position = 3
        Mandatory = $true
    }

    $paramoptions = Get-NSPerfPolicy | select -exp name

    $AttributeValidate = New-Object "$SMA.ValidateSetAttribute" -ArgumentList $paramoptions

    $AttributeCollection = New-Object $Type 
    $AttributeCollection.Add($AttributeMandatory)
    $AttributeCollection.Add($AttributeValidate)

    $Param = @{
    TypeName = "$SMA.RuntimeDefinedParameter"
    ArgumentList = @($paramName, [string], $AttributeCollection)
    }
    $Parameter = New-Object @Param
            
    $Dictionary = New-Object "$SMA.RuntimeDefinedParameterDictionary"
    $Dictionary.Add($paramName, $Parameter)
    $Dictionary
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
        $attr.perfpolname = $PerformancePolicy
        if($MultipleInitiator)
        {
            $attr.multiinitiator = $true
        }
        

    }
    Process
    {
        $str = $attr.name = $Name
        $rtncode = $gm.createVol($script:sid.Value,$attr,[ref]$str)
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