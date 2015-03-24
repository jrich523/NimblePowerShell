<#
.Synopsis
   Gets all performance policies on the unit.
.DESCRIPTION
   Queries the unit for all configured performance policies
.EXAMPLE
   Get-NSPerfPolicy
.EXAMPLE
   Get-NSPerfPolicy -name "VMware ESX 5"
#>
function Get-NSPerfPolicy
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Name="*"
    )

    Begin
    {
        Test-NSConnection
        $perfpoollist = new-object Nimble.PerformancePolicy
        $rtncode = $script:nsunit.getperfpollist($script:sid.value,[ref]$perfpoollist)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode"
        }
    }
    Process
    {
        $perfpoollist | where { $_.name -and $_.name -like $name }
    }
    End
    {
    }
}

<#
.Synopsis
   Create a new performance policy.
.DESCRIPTION
   Defines a new performance policy to be created.
.EXAMPLE
   
.EXAMPLE
   
#>
function New-NSPerfPolicy
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $Name,

        # Param2 help description
        [string]
        $Description,
        
        [Parameter(Mandatory=$true,
                   Position=1)]
        [int]
        $BlockSize,

        [switch]
        $Compress,

        [switch]
        $Cache

    )
    #no pipping so no need for begin/process/end blocks
    Test-NSConnection
    $attr = new-object Nimble.PerfPolCreateAttr
    $attr.name = $Name
    $attr.description = $Description
    $attr.blocksize = $BlockSize
    
    if($Compress){$attr.compress=$true}
    if($Cache){$attr.cache=$true}

    $str=""
    $rtncode = $script:nsunit.createPerfPol($script:sid.Value,$attr)
    if($rtncode -ne "Smok")
    {
        Write-Error "Error Creating performance policy '$Name'! code: $rtncode"
    }
    Get-NSPerfPolicy $Name

}