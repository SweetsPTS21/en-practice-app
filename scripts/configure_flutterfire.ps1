param(
    [string]$ProjectId = "en-practice",
    [string]$AndroidPackageName = "com.swpts.enpractice",
    [string]$IosBundleId = "com.swpts.enpractice"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir ".."))

function Get-LocalProperties {
    $localPropertiesPath = Join-Path $repoRoot "android/local.properties"
    $properties = @{}

    if (-not (Test-Path -LiteralPath $localPropertiesPath)) {
        return $properties
    }

    foreach ($line in Get-Content -LiteralPath $localPropertiesPath) {
        if ($line -match "^\s*([^#][^=]+?)\s*=\s*(.+?)\s*$") {
            $properties[$matches[1]] = $matches[2]
        }
    }

    return $properties
}

function Resolve-Executable {
    param(
        [string[]]$Candidates,
        [string]$Label
    )

    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        try {
            if (Test-Path -LiteralPath $candidate) {
                return (Resolve-Path -LiteralPath $candidate).Path
            }
        } catch {
            continue
        }

        $command = Get-Command $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            return $command.Source
        }
    }

    throw "$Label was not found. Install it first or expose it via PATH."
}

function Get-NpmGlobalPrefix {
    $npm = Get-Command "npm.cmd" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $npm) {
        $npm = Get-Command "npm" -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if (-not $npm) {
        return $null
    }

    $prefix = & $npm.Source prefix -g 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    return $prefix.Trim()
}

Push-Location $repoRoot
try {
    $localProperties = Get-LocalProperties
    $flutterSdk = if ($localProperties.ContainsKey("flutter.sdk")) {
        $localProperties["flutter.sdk"]
    } else {
        $env:FLUTTER_ROOT
    }

    $npmGlobalPrefix = Get-NpmGlobalPrefix

    $flutter = Resolve-Executable -Label "Flutter SDK" -Candidates @(
        $(if ($flutterSdk) { Join-Path $flutterSdk "bin/flutter.bat" }),
        $(if ($flutterSdk) { Join-Path $flutterSdk "bin/flutter" }),
        "flutter.bat",
        "flutter"
    )
    $dart = Resolve-Executable -Label "Dart SDK" -Candidates @(
        $(if ($flutterSdk) { Join-Path $flutterSdk "bin/dart.bat" }),
        $(if ($flutterSdk) { Join-Path $flutterSdk "bin/dart" }),
        "dart.bat",
        "dart"
    )
    $firebase = Resolve-Executable -Label "Firebase CLI" -Candidates @(
        $env:FIREBASE_CLI,
        $(if ($npmGlobalPrefix) { Join-Path $npmGlobalPrefix "firebase.cmd" }),
        (Join-Path $repoRoot "node_modules/.bin/firebase.cmd"),
        "firebase.cmd",
        "firebase"
    )

    & $firebase login:list | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Firebase CLI is not authenticated. Run 'firebase login' first."
    }

    & $flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get failed."
    }

    & $dart pub global run flutterfire_cli:flutterfire --version | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "flutterfire_cli is not installed. Install it first with 'dart pub global activate flutterfire_cli'."
    }

    & $dart pub global run flutterfire_cli:flutterfire configure `
        --project=$ProjectId `
        --android-package-name=$AndroidPackageName `
        --ios-bundle-id=$IosBundleId `
        --yes

    if ($LASTEXITCODE -ne 0) {
        throw "flutterfire configure failed."
    }
}
finally {
    Pop-Location
}
