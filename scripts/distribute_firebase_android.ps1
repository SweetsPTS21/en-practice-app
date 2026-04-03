param(
    [ValidateSet("apk", "aab")]
    [string]$Artifact = "apk",

    [ValidateSet("debug", "release")]
    [string]$BuildMode = "release",

    [string]$EnvFile = ".env.firebase",
    [string]$AppEnvFile = ".env.app",
    [string]$ArtifactPath,
    [switch]$SkipBuild
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

function Import-DotEnv {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    foreach ($rawLine in Get-Content -LiteralPath $Path) {
        $line = $rawLine.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
            continue
        }

        $parts = $line.Split("=", 2)
        if ($parts.Count -ne 2) {
            continue
        }

        $name = $parts[0].Trim()
        $value = $parts[1].Trim()

        if (
            ($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))
        ) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

function Resolve-RepoPath {
    param([string]$PathValue)

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $PathValue))
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

function Add-FileOption {
    param(
        [System.Collections.Generic.List[string]]$Arguments,
        [string]$OptionName,
        [string]$PathValue
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return
    }

    $resolvedPath = Resolve-RepoPath $PathValue
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Configured path for $OptionName does not exist: $resolvedPath"
    }

    $Arguments.Add($OptionName)
    $Arguments.Add($resolvedPath)
}

function Add-DartDefineOption {
    param(
        [System.Collections.Generic.List[string]]$Arguments,
        [string]$Name,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    $Arguments.Add("--dart-define=$Name=$Value")
}

Push-Location $repoRoot
try {
    $resolvedEnvFile = Resolve-RepoPath $EnvFile
    Import-DotEnv -Path $resolvedEnvFile
    $resolvedAppEnvFile = Resolve-RepoPath $AppEnvFile
    Import-DotEnv -Path $resolvedAppEnvFile

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
    $firebase = Resolve-Executable -Label "Firebase CLI" -Candidates @(
        $env:FIREBASE_CLI,
        $(if ($npmGlobalPrefix) { Join-Path $npmGlobalPrefix "firebase.cmd" }),
        (Join-Path $repoRoot "node_modules/.bin/firebase.cmd"),
        "firebase.cmd",
        "firebase"
    )

    $appId = if (-not [string]::IsNullOrWhiteSpace($env:FIREBASE_APP_ID_ANDROID)) {
        $env:FIREBASE_APP_ID_ANDROID
    } else {
        $env:FIREBASE_ANDROID_APP_ID
    }
    if ([string]::IsNullOrWhiteSpace($appId)) {
        throw "FIREBASE_APP_ID_ANDROID is required. Set it in environment variables or .env.firebase."
    }

    if ($Artifact -eq "aab" -and $BuildMode -ne "release" -and [string]::IsNullOrWhiteSpace($ArtifactPath)) {
        throw "Automatic AAB builds currently support only -BuildMode release."
    }

    if (-not $SkipBuild) {
        if ([string]::IsNullOrWhiteSpace($env:API_BASE_URL)) {
            throw "API_BASE_URL is required for distribution builds. Set it in .env.app or the current environment."
        }

        $flutterBuildArgs = [System.Collections.Generic.List[string]]::new()
        if ($Artifact -eq "apk") {
            $flutterBuildArgs.AddRange([string[]]@("build", "apk", "--$BuildMode"))
        } else {
            $flutterBuildArgs.AddRange([string[]]@("build", "appbundle", "--release"))
        }

        Add-DartDefineOption -Arguments $flutterBuildArgs -Name "API_BASE_URL" -Value $env:API_BASE_URL
        Add-DartDefineOption -Arguments $flutterBuildArgs -Name "INTERNAL_KEY" -Value $env:INTERNAL_KEY

        & $flutter @flutterBuildArgs

        if ($LASTEXITCODE -ne 0) {
            throw "Flutter build failed."
        }
    }

    $resolvedArtifactPath = if ([string]::IsNullOrWhiteSpace($ArtifactPath)) {
        if ($Artifact -eq "apk") {
            Join-Path $repoRoot "build/app/outputs/flutter-apk/app-$BuildMode.apk"
        } else {
            Join-Path $repoRoot "build/app/outputs/bundle/release/app-release.aab"
        }
    } else {
        Resolve-RepoPath $ArtifactPath
    }

    if (-not (Test-Path -LiteralPath $resolvedArtifactPath)) {
        throw "Artifact not found: $resolvedArtifactPath"
    }

    $firebaseArgs = [System.Collections.Generic.List[string]]::new()
    $firebaseArgs.Add("appdistribution:distribute")
    $firebaseArgs.Add($resolvedArtifactPath)
    $firebaseArgs.Add("--app")
    $firebaseArgs.Add($appId)

    Add-FileOption -Arguments $firebaseArgs -OptionName "--release-notes-file" -PathValue $env:FIREBASE_RELEASE_NOTES_FILE
    if (-not [string]::IsNullOrWhiteSpace($env:FIREBASE_TESTERS)) {
        $firebaseArgs.Add("--testers")
        $firebaseArgs.Add($env:FIREBASE_TESTERS)
    }
    Add-FileOption -Arguments $firebaseArgs -OptionName "--testers-file" -PathValue $env:FIREBASE_TESTERS_FILE
    if (-not [string]::IsNullOrWhiteSpace($env:FIREBASE_TESTER_GROUPS)) {
        $firebaseArgs.Add("--groups")
        $firebaseArgs.Add($env:FIREBASE_TESTER_GROUPS)
    }
    Add-FileOption -Arguments $firebaseArgs -OptionName "--groups-file" -PathValue $env:FIREBASE_GROUPS_FILE

    if (-not [string]::IsNullOrWhiteSpace($env:FIREBASE_TOKEN)) {
        $firebaseArgs.Add("--token")
        $firebaseArgs.Add($env:FIREBASE_TOKEN)
    }

    & $firebase @firebaseArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Firebase App Distribution upload failed."
    }
}
finally {
    Pop-Location
}
