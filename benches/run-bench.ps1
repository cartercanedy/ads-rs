using namespace System.Runtime.InteropServices;

$serverJob = $null;
try {
  pushd "${PSScriptRoot}/AdsServerEmu";

  $platform = if ([RuntimeInformation]::IsOSPlatform([OSPlatform]::Windows)) {
    "win-x64"
  } elseif ([RuntimeInformation]::IsOSPlatform([OSPlatform]::Linux)) {
    "linux-x64"
  } else {
    exit 1;
  }

  dotnet publish -r $platform -c Release;

  $publishRoot = "${PSScriptRoot}/AdsServerEmu/bin/Release/net9.0/${platform}/publish"

  $exePath = if ([RuntimeInformation]::IsOSPlatform([OSPlatform]::Windows)) {
    "${publishRoot}/AdsServerEmu.exe"
  } else {
    cp "$publishRoot/appSettings.json" .;
    "${publishRoot}/AdsServerEmu"
  };

  $serverJob = Start-ThreadJob {
    $env:COMPlus_JITMinOpts = 1;
    & "${using:exePath}";
  }

  sleep 1

  cargo bench
} finally {
  if ([System.IO.File]::Exists("${PSScriptRoot}/appSettings.json")) {
    rm "${PSScriptRoot}/appSettings.json";
  }

  popd;

  if ($serverJob) {
    $serverJob.StopJob();
  }
}
