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
function Get-NSPerfPolicy
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
        $rtnpol=@()
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        $perfpoollist = new-object PerformancePolicy
        $rtncode = $script:nsunit.getperfpollist($script:sid.value,[ref]$perfpoollist)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
        }
    }
    Process
    {
        if($name)
        {
            $rtnpol += $perfpoollist | where { $_.name -like $name}
        }
        else
        {
            $rtnpol = $perfpoollist
        }
    }
    End
    {
        $rtnpol
    }
}