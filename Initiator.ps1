<#
.Synopsis
   Get Initiator Groups
.DESCRIPTION
   Returns all Initiator Groups registered on the unit
.EXAMPLE
   Get-NSInitiatorGroup
.EXAMPLE
   Get-NSInitiatorGroup -Name ESXStorage
#>
function Get-NSInitiatorGroup
{
    [CmdletBinding()]
    Param
    (
        
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ParameterSetName="string")]
        $Name = "*",
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ParameterSetName="InputObject")]
        [vol]
        $InputObject
    )

    Begin
    {
        $rtnigrp = @()
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        $igrp = New-Object initiatorgrp
        $rtncode = $Script:NSUnit.getinitiatorgrpList($sid.Value, [ref]$igrp)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting initiator list! code: $rtncode" -ErrorAction Stop
        }
            
    }
    Process
    {
        $igrp | where {$_.name -like $name}
    }
    End
    {

    }
}

<#
.Synopsis
   Add an Initiator to a group
.DESCRIPTION
   This will add an initiator to a group allowing it access.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Add-NSInitiatorToGroup
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0)]
        [string]
        $Name,
        # Assign an IP restriction to the group
        $ip,
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $InitiatorGroup
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
        foreach($init in $Name)
        {
            $InitiatorGroup = Get-NSInitiatorGroup $InitiatorGroup | select -ExpandProperty name
            $i = New-Object initiator
            $i.name = $init
            $i.ip = $ip
            $rtncode = $Script:NSUnit.addInitiator($sid.Value,$InitiatorGroup, $i)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error adding $init to the list! code: $rtncode"
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
function Remove-NSInitiatorFromGroup
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0,parametersetname='name')]
        $Name,
        [Parameter(ValueFromPipeline=$true,Position=0,parametersetname='ip')]
        $IP,
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $InitiatorGroup,
        #force
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
        foreach($init in $Name)
        {
            $i = New-Object initiator
            $i.name = $init
            $rtncode = $Script:NSUnit.addInitiatort($sid.Value,$InitiatorGroup, $i)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error adding $init to the list! code: $rtncode"
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
function New-NSInitiatorGroup
{
    [CmdletBinding()]
    Param
    (
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)]
        [ValidatePattern('^[a-z,A-Z,\d,\.,-]+$')]
        $Name,
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $Description
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
        foreach($gname in $Name)
        {
            $g = New-Object InitiatorGrpCreateAttr
            $g.name = $gname
            $g.description = $Description
            $rtncode = $Script:NSUnit.CreateInitiatorGrp($sid.Value,$g)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error creating $gname initiator group! code: $rtncode"
            }
        }
        Get-InitiatorGroup $gname
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
function Remove-NSInitiatorGroup
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
    Param
    (
        # group name
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Name
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        if($Force){$ConfirmPreference= 'None'}
        $volumes = Get-Volume
        $RejectAll = $false;
        $ConfirmAll = $false;
    }
    Process
    {
        foreach($gname in $Name)
        {
            $InUseVols = ($volumes | ?{$_.acllist.initiatorgrp -eq $gname} | select -exp name) -join ", "
            if($InUseVols)
            {
                if($PSCmdlet.ShouldContinue("Remove in use initiator $gname? It's currently in use on $InUseVols","In use initiator group",[ref]$ConfirmAll,[ref]$RejectAll))
                {
                    $rtncode = $Script:NSUnit.DeleteInitiatorGrp($sid.Value,$gname)
                }
            }
            else
            {
                $rtncode = $Script:NSUnit.DeleteInitiatorGrp($sid.Value,$gname)
            }
            if($rtncode -ne "Smok" -and $rtncode)
            {
                Write-Error "Error deleting '$gname' initiator group! code: $rtncode"
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
function Add-NSInitiatorGroupToVolume
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
        $InitiatorGroup,
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $Volume,
        #access type
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]
        [ValidateSet("Both", "Snapshot", "Volume")]
        $Access="Both"
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
        #if object given, get names
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}else{$Volume = Get-NSVolume $Volume | select -ExpandProperty name}
        if($InitiatorGroup.gettype().name -eq "initiatorgrp"){$InitiatorGroup=$InitiatorGroup.name}else{$InitiatorGroup = Get-NSInitiatorGroup $InitiatorGroup | select -ExpandProperty name}
        
        $applyto = switch($Access){
                    "Both"{[smvolaclapply]::SMvolaclapplytoboth}
                    "Snapshot"{[smvolaclapply]::SMvolaclapplytosnap}
                    "Volume"{[smvolaclapply]::SMvolaclapplytovol}
                    }

        $rtncode = $Script:NSUnit.addVolAcl($script:sid.value,$Volume,$applyto ,"*",$InitiatorGroup)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error adding $init to the list! code: $rtncode"
        }
    }
    End
    {
    }
}