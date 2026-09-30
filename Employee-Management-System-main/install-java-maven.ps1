$ErrorActionPreference = 'Stop'

$toolsDir = Join-Path $env:USERPROFILE 'Tools'
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

$jdkZip = Join-Path $toolsDir 'jdk-21.zip'
$mavenZip = Join-Path $toolsDir 'apache-maven-3.9.9-bin.zip'
$jdkRoot = Join-Path $toolsDir 'jdk-21'
$mavenRoot = Join-Path $toolsDir 'apache-maven-3.9.9'

if (-not (Test-Path $jdkRoot)) {
    if (-not (Test-Path $jdkZip)) {
        Invoke-WebRequest -Uri 'https://aka.ms/download-jdk/microsoft-jdk-21.0.12.1-windows-x64.zip' -OutFile $jdkZip
    }
    Expand-Archive -Path $jdkZip -DestinationPath $toolsDir -Force
    $jdkExtracted = Get-ChildItem $toolsDir -Directory | Where-Object { $_.Name -like 'jdk-*' } | Sort-Object Name -Descending | Select-Object -First 1
    if ($jdkExtracted) {
        if (Test-Path $jdkRoot) { Remove-Item $jdkRoot -Recurse -Force }
        Rename-Item -Path $jdkExtracted.FullName -NewName 'jdk-21'
    }
}

if (-not (Test-Path $mavenRoot)) {
    if (-not (Test-Path $mavenZip)) {
        Invoke-WebRequest -Uri 'https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip' -OutFile $mavenZip
    }
    Expand-Archive -Path $mavenZip -DestinationPath $toolsDir -Force
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathsToAdd = @(
    (Join-Path $jdkRoot 'bin'),
    (Join-Path $mavenRoot 'bin')
)
foreach ($p in $pathsToAdd) {
    if ($userPath -notmatch [regex]::Escape($p)) {
        $userPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $p } else { "$userPath;$p" }
    }
}
[Environment]::SetEnvironmentVariable('Path', $userPath, 'User')

Write-Host 'Java and Maven installed successfully.'
