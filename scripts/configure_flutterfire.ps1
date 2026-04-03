param(
    [string]$ProjectId = "en-practice",
    [string]$AndroidPackageName = "com.swpts.enpractice",
    [string]$IosBundleId = "com.swpts.enpractice"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir ".."))
$dart = "C:\Users\sonpt1\flutter-sdk\bin\dart.bat"
$flutter = "C:\Users\sonpt1\flutter-sdk\bin\flutter.bat"

function Assert-PathExists {
    param(
        [string]$Path,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label was not found at: $Path"
    }
}

function Assert-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found on PATH."
    }
}

Push-Location $repoRoot
try {
    Assert-PathExists -Path $dart -Label "Dart SDK"
    Assert-PathExists -Path $flutter -Label "Flutter SDK"
    Assert-Command "firebase"

    & firebase login:list | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Firebase CLI is not authenticated. Run 'firebase login' first."
    }

    & $flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get failed."
    }

    & $dart pub global run flutterfire_cli:flutterfire configure `
        --project=$ProjectId `
        --android-package-name=$AndroidPackageName `
        --ios-bundle-id=$IosBundleId

    if ($LASTEXITCODE -ne 0) {
        throw "flutterfire configure failed."
    }
}
finally {
    Pop-Location
}
