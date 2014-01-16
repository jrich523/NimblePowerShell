param([string]$InstallDirectory)

if ('' -eq $InstallDirectory)
{
    $personalModules = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath WindowsPowerShell\Modules
    if (($env:PSModulePath -split ';') -notcontains $personalModules)
    {
        Write-Warning "$personalModules is not in `$env:PSModulePath"
    }

    if (!(Test-Path $personalModules))
    {
        Write-Error "$personalModules does not exist"
    }

    $InstallDirectory = Join-Path -Path $personalModules -ChildPath Nimble
}
if (!(Test-Path $InstallDirectory))
{
    $null = mkdir $InstallDirectory    
}

$wc = New-Object System.Net.WebClient
$wc.DownloadFile("https://raw.github.com/jrich523/NimblePowerShell/master/Nimble.psd1","$installDirectory\Nimble.psd1")
Push-Location
(Import-LocalizedData -FileName Nimble.psd1).filelist | %{$wc.DownloadFile("https://raw.github.com/jrich523/NimblePowerShell/master/$_","$installDirectory\$_")
gci | Unblock-File
Pop-Location
