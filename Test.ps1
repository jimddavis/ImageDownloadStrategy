
using module .\ImageDownloads.psm1
$verbosePreference = 'Continue'
$progressPreference = 'SilentlyContinue'

Clear-Host

$img = [ImageDownload]::new()

#$img.AddDownloadType([NasaAPOD]::new('c:\temp'))
#$img.AddDownloadType([NasaAPOD]::new())

$img.AddDownloadType([EarthObservatoryPOD]::new())

$img.AddDownloadType([OutdoorPhotographer]::new())


if ($img.TestInternetConnection()) {
  $img.Invoke()

  $img.Results | Format-list
  $img.Results | Out-File  'c:\temp\ImgDownload.log' -Append

}

