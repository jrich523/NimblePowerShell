<#
.Synopsis
   Generally this shouldnt be needed.
.DESCRIPTION
   This gives you access to the SOAP object so you can call methods directly. the SID is the auth token.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-NSArray
{
    [CmdletBinding()]
    Param()
    new-object psobject -Property @{
    Unit=$script:nsunit
    SID=$script:sid
    }

}

function Test-NSConnection {

    if(-not $Script:NSUnit)
    {
            Write-Error "Connect to unit first!" -ErrorAction Stop
    }
}