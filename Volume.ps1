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
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Name,

        # Param2 help description
        [Int64]
        $Size,

        #desc
        $Description,

        #more
        $more
    )
    DynamicParam {
    $SMA = 'System.Management.Automation'
    $Type = 'Collections.ObjectModel.Collection[System.Attribute]'
    $Name = 'PerformancePolicy'

    $AttributeMandatory = New-Object "$SMA.ParameterAttribute" -Property @{
        ParameterSetName = "__AllParameterSets"
        Mandatory = $true
    }

    $Names = Get-NSPerfPolicy | select -exp name

    $AttributeValidate = New-Object "$SMA.ValidateSetAttribute" -ArgumentList $Names

    $AttributeCollection = New-Object $Type 
    $AttributeCollection.Add($AttributeMandatory)
    $AttributeCollection.Add($AttributeValidate)

    $Param = @{
    TypeName = "$SMA.RuntimeDefinedParameter"
    ArgumentList = @($Name, [string], $AttributeCollection)
    }
    $Parameter = New-Object @Param
            
    $Dictionary = New-Object "$SMA.RuntimeDefinedParameterDictionary"
    $Dictionary.Add($Name, $Parameter)
    $Dictionary
}
    Begin
    {
        $attr = New-Object VolCreateAttr
        $attr.size = $size
        $attr.warnlevel = $size * .8
        $attr.quota = $size
        $attr.snapquota = 9223372036854775807  ##unlimited
        $attr.name = "AutoTest"
        $attr.description = "PowerShell Creation"
        $attr.online = $true
        $attr.perfpolname = "default"

        $str = $attr.name
        $gm.createVol($sid,$attr,[ref]$str)

    }
    Process
    {
    }
    End
    {
    }
}