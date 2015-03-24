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
function Get-NSChapUser
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,
                   Position=0)]
        $Username="*"
    )

    Begin
    {
        Test-NSConnection
        $chaps = new-object Nimble.ChapUser
        $rtncode=$script:nsunit.getChapUserList($script:sid.value,[ref]$chaps)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
        }
    }
    Process
    {
        $chaps | ? {$_.name -like $Username} 
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
function New-NSChapUser
{
    [CmdletBinding()]
    #[OutputType([int])]
    Param
    (
        # Username
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $Username,

        # User password
        [Parameter(Mandatory=$true,
                   Position=1)]
        [validateLength(12,16)]
        [ValidateScript({$_ -notmatch '[\[\]&;`]'})]
        [string]
        $Password,

        # Description of user
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $Description
    )

        #make sure you're connected first, this will throw an error and stop processing
        Test-NSConnection

        $chapAttr = new-object Nimble.ChapUserCreateAttr
        $chapAttr.name = $Username
        $chapAttr.password =  $Password
        
        if($Description)
        {
            $chapAttr.description = $Description
        }

        $rtncode = $Script:NSUnit.createChapUser($sid.Value,$chapAttr)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error creating CHAP user $($chapAttr.name) ! code: $rtncode"
        }

        #Get-NSChapUser $chapAttr.name


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
function Remove-NSChapUser
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]

    Param
    (
        # Name of the volume you'd like to delete
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,
                   ParameterSetName="string")]
        [string]
        $Username,

        # Param2 help description
        [switch]
        $Force,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,
                   ParameterSetName="inputobject")]
        [Nimble.ChapUser]
        $InputObject
    )

    Begin
    {
        Test-NSConnection
        
        if($Force){$ConfirmPreference= 'None'}
    }
    Process
    {
        
        if($InputObject)
        {
            $user = $InputObject
        }
        else
        {

            $user = Get-NSChapUser $Username
            if(-not $user){return}
        }

        <# change to assignments
        $conns = $vol.numconnections
        if($conns -gt 0)
        {
            if(-not $PSCmdlet.ShouldProcess("Connected Sessions","There are $conns open still, terminate?","Connected Hosts"))
            {
                break #might need return
            }
        }
        #>
        
        ##delete
        if($PSCmdlet.ShouldProcess($user.name,"Delete CHAP user"))
        {
            #set offline
            $rtncode = $Script:nsunit.deleteChapUser($sid.value,$user.name)
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