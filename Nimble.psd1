#
# Module manifest for module 'nimble'
#
# Generated by: Justin Rich
#
# Generated on: 5/23/2013
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = '' ## V3 only!!
ModuleToProcess = 'nimble.psm1'

# Version number of this module.
ModuleVersion='1.1.20140407.1024'

# ID used to uniquely identify this module
GUID = 'be855a56-8d9a-40ce-89a1-c645c318b67d'

# Author of this module
Author = 'Justin Rich'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2013 Justin Rich. All rights reserved.'

# Description of the functionality provided by this module
# Description = ''

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @('NimbleGM.dll')

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @('Nimble.Types.ps1xml')

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @('Nimble.format.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = 'Add-NSInitiatorGroupToVolume','Add-NSInitiatorToGroup','Connect-NSArray',
                    'Get-NSArray','Get-NSInitiatorGroup','Get-NSPerfPolicy','Get-NSSnapShot',
                    'Get-NSVolume','New-NSClone','New-NSInitiatorGroup','New-NSPerfPolicy',
                    'New-NSSnapshot','New-NSVolume','Remove-NSInitiatorFromGroup','Remove-NSInitiatorGroup',
                    'Remove-NSSnapShot','Remove-NSVolume','Set-NSVolumeState','Get-NSVolumeACL','Get-NSVolumeCollection',
                    'New-NSChapUser','Get-NSChapUser','Remove-NSChapUser',
                    'Test-NSConnection','Convert-NSTime'

# Cmdlets to export from this module
#CmdletsToExport = '*'

# Variables to export from this module
#VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module.
# ModuleList = @()

# List of all files packaged with this module
FileList = @('Array.ps1','GroupMgmt.dll','Initiator.ps1','Login.ps1','Nimble.format.ps1xml','Nimble.Types.ps1xml',
            'Nimble.psd1','Nimble.psm1','PerfPolicy.ps1','README.md','Snap.ps1','Utility.ps1','Volume.ps1','VolCol.ps1','CHAP.ps1')

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
#DefaultCommandPrefix = ''

}

