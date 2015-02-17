## cmdlets to create
## new-nsvolumecollection
## get-  probably need format file for it
## remove-
## add-* might be a couple needed



#######################################################
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
function Get-NSVolumeCollection
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0)]
        [string[]]
        $Name = "*"
    )

Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        $ppl = new-object Nimble.ProtectionPolicy 
        $rtncode = $Script:NSUnit.getProtPolList($sid.Value, [ref]$ppl)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume collection list! code: $rtncode" -ErrorAction Stop
        }
            
    }
    Process
    {
        foreach($n in $Name)
        {
            $ppl | where {$_.name -like $n}
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
function Remove-NSVolumeCollection
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    Begin
    {
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
function New-NSVolumeCollection
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string]
        $Name
    )

    Begin
    {
        Test-NSConnection
        $ppc = new-object Nimble.ProtPolCreateAttr

    }
    Process
    {
        
        $ppc.name = $Name
        $str=""
        $rtncode = $script:nsunit.createProtPol($script:sid.Value,$attr)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error Creating Volume Collection $Name! code: $rtncode"
        }
        Get-NSVolumeCollection $Name
    }
    End
    {
    }
}