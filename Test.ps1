
using module .\ImageDownloads.psm1
$verbosePreference = 'Continue'
$progressPreference = 'SilentlyContinue'

Clear-Host

$img = [ImageDownload]::new()

#$img.AddDownloadType([NasaAPOD]::new('C:\Users\JimD\Pictures\Nasa'))
#$img.AddDownloadType([EarthObservatoryPOD]::new('C:\Users\JimD\Pictures\EarthObservatory'))

#$test = [TestEnum]::new([OutdoorPhotoFeedEnum]::FavoritePlaces)

$op = [OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::FeaturedStories)
$op.GetEnumVal()
$op.DownloadFolder = 'C:\Users\JimD\Pictures\OutdoorPhotographer'
$op.TempFolder = 'C:\temp\OutdoorPhotography'

$img.AddDownloadType($op)

#$img.AddDownloadType([OutdoorPhotographer]::new('C:\Users\JimD\Pictures\OutdoorPhotographer'))


if ($img.TestInternetConnection()) {
  $img.Invoke()

  $img.Results | Format-list
  $img.Results | Out-File  'c:\temp\ImgDownload.log' -Append

}



