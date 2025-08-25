$serverJob = $null;
try {
  pushd "${PSScriptRoot}/AdsServerEmu";

  $osVersion = [System.Environment]::OSVersion.ToString().ToLower();

  $platform = if ($osVersion.Contains("windows")) {
    "win-x64"
  } elseif ($osVersion.Contains("linux")) {
    "linux-x64"
  } else {
    exit 1;
  }

  dotnet publish -r $platform -c Release;

  $serverJob = Start-ThreadJob {
    & "${using:PSScriptRoot}/AdsServerEmu/bin/Release/net10.0/${using:platform}/publish/AdsServerEmu.exe"
  }

  sleep 1

  echo "Warming up, this takes a while"
  # warmup the dotnet JIT with 3 runs
  foreach ($i in 0..2) {
    cargo bench *>&1 | Out-Null;
  }

  cargo bench
} finally {
  popd

  if ($serverJob) {
    $serverJob.StopJob();
  }
}
