
using module .\ImageDownloads.psm1
$verbosePreference = 'Continue'            # Show output from the Verbose stream
$progressPreference = 'SilentlyContinue'   # Suppress progress indicator from Invoke-WebRequest.
                                           # Set to 'Continue' to show it.


Clear-Host

# Create the main Context class
$img = [ImageDownload]::new()

# Add Strategies to be invoked.
# Note if you run all this you will download about 40 images and 230 MB of data
# A second run will not download any images, as it first checks if the file exists.

# Store in default $env:USERPROFILE\Pictures\ImageDownloads folder
$img.AddDownloadType([NasaAPOD]::new())
$img.AddDownloadType([EarthObservatoryPOD]::new())

# Store in specified Pictures Folder
$img.AddDownloadType([OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::FeaturedStories, "$env:USERPROFILE\Pictures\OutdoorPhotographer"))
$img.AddDownloadType([OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::FavoritePlaces, "$env:USERPROFILE\Pictures\OutdoorPhotographer"))
$img.AddDownloadType([OutdoorPhotographer]::new([OutdoorPhotoFeedEnum]::Travel, "$env:USERPROFILE\Pictures\OutdoorPhotographer"))



# Store images in some random folder
$img.AddDownloadType([NasaAPOD]::new('c:\temp\Nasa\Pictures\APOD'))

# Test for internect connection first.  No point running if one does not exist
if ($img.TestInternetConnection()) {
  $img.Invoke()

  # Display results to console
  $img.Results | Format-list

  # Write results to a file
  $img.Results | Out-File  'c:\temp\ImgDownload.log' -Append

}



