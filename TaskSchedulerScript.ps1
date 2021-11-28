
using module .\ImageDownloads.psm1
$verbosePreference = 'Continue'
$progressPreference = 'SilentlyContinue'

$img = [ImageDownload]::new()

Clear-Host
$img.AddDownloadType([OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::Travel, 'C:\Users\JimD\Pictures\OutdoorPhotographer'))
$img.AddDownloadType([OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::FeaturedStories, 'C:\Users\JimD\Pictures\OutdoorPhotographer'))
$img.AddDownloadType([OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::FavoritePlaces, 'C:\Users\JimD\Pictures\OutdoorPhotographer'))
$img.AddDownloadType([NasaAPOD]::new('C:\Users\JimD\Pictures\Nasa'))
$img.AddDownloadType([EarthObservatoryPOD]::new( 'C:\Users\JimD\Pictures\EarthObservatory'))

if ($img.TestInternetConnection()) {
  $img.Invoke()
  $img.Results | Out-File  'c:\temp\ImgDownload.log' -Append
}

