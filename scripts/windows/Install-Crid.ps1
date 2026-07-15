[CmdletBinding()]
param(
    [Parameter()]
    [string]$MsixPath,

    [Parameter()]
    [string]$CertificatePath,

    [Parameter()]
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-SingleReleaseFile {
    param(
        [AllowEmptyString()]
        [string]$ExplicitPath,

        [Parameter(Mandatory)]
        [string]$Filter,

        [Parameter(Mandatory)]
        [string]$Label
    )

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    $matches = @(Get-ChildItem -LiteralPath $PSScriptRoot -File -Filter $Filter)
    if ($matches.Count -ne 1) {
        throw "Expected exactly one $Label next to this installer, but found $($matches.Count)."
    }
    return $matches[0].FullName
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Quote-ProcessArgument {
    param([Parameter(Mandatory)][string]$Value)
    return '"' + $Value.Replace('"', '\"') + '"'
}

function Get-MsixIdentity {
    param([Parameter(Mandatory)][string]$Path)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry = $archive.GetEntry('AppxManifest.xml')
        if ($null -eq $entry) {
            throw 'The package does not contain AppxManifest.xml.'
        }
        $reader = [System.IO.StreamReader]::new($entry.Open())
        try {
            [xml]$manifest = $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }
    }
    finally {
        $archive.Dispose()
    }

    return [pscustomobject]@{
        Name = [string]$manifest.Package.Identity.Name
        Version = [version]$manifest.Package.Identity.Version
    }
}

try {
    if ([Environment]::OSVersion.Version.Major -lt 10) {
        throw 'Crid requires Windows 10 or later.'
    }

    $resolvedMsix = Resolve-SingleReleaseFile -ExplicitPath $MsixPath -Filter '*.msix' -Label 'MSIX package'
    $resolvedCertificate = Resolve-SingleReleaseFile -ExplicitPath $CertificatePath -Filter '*.cer' -Label 'signing certificate'

    $certificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new(
        $resolvedCertificate
    )

    if ($ValidateOnly) {
        $signature = Get-AuthenticodeSignature -FilePath $resolvedMsix
        if ($null -eq $signature.SignerCertificate) {
            throw 'The MSIX does not contain an Authenticode signer certificate.'
        }
        if ($signature.SignerCertificate.Thumbprint -ne $certificate.Thumbprint) {
            throw 'The MSIX signer does not match the bundled public certificate.'
        }
        $identity = Get-MsixIdentity -Path $resolvedMsix
        Write-Host "Validated $($identity.Name) $($identity.Version) and its bundled certificate."
        exit 0
    }
    $trustedCertificate = Get-ChildItem -Path Cert:\LocalMachine\TrustedPeople |
        Where-Object Thumbprint -EQ $certificate.Thumbprint |
        Select-Object -First 1

    if ($null -eq $trustedCertificate -and -not (Test-IsAdministrator)) {
        Write-Host 'Crid needs one administrator confirmation to trust its signing certificate.'
        $powershell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $elevationArguments = @(
            '-NoLogo'
            '-NoProfile'
            '-ExecutionPolicy'
            'Bypass'
            '-File'
            (Quote-ProcessArgument $PSCommandPath)
            '-MsixPath'
            (Quote-ProcessArgument $resolvedMsix)
            '-CertificatePath'
            (Quote-ProcessArgument $resolvedCertificate)
        )
        $elevated = Start-Process -FilePath $powershell -Verb RunAs -ArgumentList $elevationArguments -Wait -PassThru
        exit $elevated.ExitCode
    }

    if ($null -eq $trustedCertificate) {
        Write-Host 'Trusting the Crid signing certificate...'
        Import-Certificate -FilePath $resolvedCertificate -CertStoreLocation 'Cert:\LocalMachine\TrustedPeople' | Out-Null
    }
    else {
        Write-Host 'The Crid signing certificate is already trusted.'
    }

    $signature = Get-AuthenticodeSignature -FilePath $resolvedMsix
    if ($signature.Status -ne [System.Management.Automation.SignatureStatus]::Valid) {
        throw "The MSIX signature is not valid after certificate installation: $($signature.Status)."
    }

    $identity = Get-MsixIdentity -Path $resolvedMsix
    $installed = Get-AppxPackage -Name $identity.Name | Select-Object -First 1
    if ($null -ne $installed -and [version]$installed.Version -eq $identity.Version) {
        Write-Host "Crid $($identity.Version) is already installed."
        exit 0
    }

    if ($null -eq $installed) {
        Write-Host "Installing Crid $($identity.Version)..."
    }
    else {
        Write-Host "Updating Crid from $($installed.Version) to $($identity.Version)..."
    }

    Add-AppxPackage -Path $resolvedMsix -ForceApplicationShutdown -ForceUpdateFromAnyVersion

    $installed = Get-AppxPackage -Name $identity.Name | Select-Object -First 1
    if ($null -eq $installed -or [version]$installed.Version -ne $identity.Version) {
        throw 'Windows did not report the expected Crid package after deployment.'
    }

    Write-Host "Crid $($installed.Version) is ready. Open it from the Start menu."
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
