using module .\WriteErrorLog.ps1
using module .\Write-VerboseColored.psm1

enum OutdoorPhotoFeedEnum {
  FavoritePlaces  = 1
  FeaturedStories = 2
  Travel          = 3
}

class DownloadInfo {

  [string]   $FeedName
  [bool]     $Success
  [string]   $StatusMsg
  [string]   $FeedURL
  [string]   $ImgURL
  [string]   $ImgName
  [string]   $ImgFileSize
  [string]   $DownloadFolder
  [string]   $TempFolder
  [DateTime] $StartTime
  [timespan] $ElapsedTime

  <#
      Feeds can have multiple images to download, and each one needs a new copy
      of the DownloadInfo class. This creates a copy of the existing object,
      then sets $downloadInfo to the new version.  This way the Results array
      gets a new instance for each image.
  #>
  [DownloadInfo] Clone() {

    $copy = [DownloadInfo]::new()
    $copy.Success        = $this.Success
    $copy.FeedName       = $this.FeedName
    $copy.FeedURL        = $this.FeedURL
    $copy.ImgURL         = $this.ImgURL
    $copy.ImgName        = $this.ImgName
    $copy.ImgFileSize    = $this.ImgFileSize
    $copy.DownloadFolder = $this.DownloadFolder
    $copy.TempFolder     = $this.TempFolder
    $copy.StatusMsg      = $this.StatusMsg
    #$copy.StartTime      = $this.StartTime
    #$copy.ElapsedTime    = $this.ElapsedTime

    return $copy
  }
}

class DownloadType  {

  [string] $Name
  hidden [DateTime] $StartTime

  DownloadType($name) {
    $this.Name = $name
  }

  [TimeSpan] GetElapsed(){
    return [DateTime]::Now - $this.StartTime
  }

}

class ImageDownload {

  hidden [string] $DEFAULT_TEMP_FOLDER = 'c:\temp'
  hidden [string] $DEFAULT_DOWNLOAD_FOLDER = "$env:USERPROFILE\Pictures\ImageDownloads"
  hidden [DownloadInfo[]] $Results = @()
  hidden [DownloadType[]] $DownloadTypes = @()
  [DownloadInfo]$downloadInfo


  #region Constructors
  ImageDownload () {
    $this.Init()
  }


  ImageDownload ([string] $downloadFolder) {

    $this.Init()
    $this.DEFAULT_DOWNLOAD_FOLDER = $downloadFolder

  }


  ImageDownload ([string] $downloadFolder, [string] $tempFolder) {

    $this.Init()
    $this.DEFAULT_DOWNLOAD_FOLDER = $downloadFolder
    $this.DEFAULT_TEMP_FOLDER = $tempFolder

  }
  #endregion



  [void] hidden Init() {

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'silentlyContinue'

  }

  [bool] TestInternetConnection() {

    try {
      Write-VerboseColored 'Testing for Internet Connection'   DarkMagenta
      if (!(Test-Connection -TargetName google.com -Count 1 -Quiet)) {
        throw New-Object System.Net.Http.HttpRequestException 'No Internet connection available and one is required for this script.  Terminating script execution.'
      }
      return $true
    }
    catch {
      Write-VerboseColored 'No Internet is available.  Terminating script execution' Red
      $this.LogError($_)
      return $false
    }
  }


  [void] SetImageFileSize () {

    $file = $this.downloadInfo.DownloadFolder + '\' + $this.downloadInfo.ImgName
    $this.downloadInfo.ImgFileSize = (Get-Item $file).length.ToString('n0') + ' KB'
  }

  <#
     Assumes $downloadInfo object has been populated with needed information
  #>
  [void] DownloadImageFromURL () {

    [string] $URL = $this.downloadInfo.ImgURL
    [string] $destFolder = $this.downloadInfo.DownloadFolder

    if (!(Test-Path $destFolder)) { mkdir $destFolder }

    # Extract the name of the image file for storing locally and see if it exists in download folder
    $imgName = $URL.Substring($URL.LastIndexOf('/') + 1)
    $this.downloadInfo.ImgName = $imgName

    # Only download the image if it is not already in the destination folder
    if ((Test-Path "$destFolder\$imgName")) {
      $this.downloadInfo.Success = $false
      $this.downloadInfo.StatusMsg = "File $imgName already exists"
      $this.SetImageFileSize()
      return
    }

    try {
      Write-VerboseColored "Downloading image $imgName "  DarkMagenta
      Invoke-WebRequest $URL -OutFile "$destFolder\$imgName"

      $this.downloadInfo.Success = $true
      $this.downloadInfo.StatusMsg = "Successfully downloaded image $imgName"
      $this.SetImageFileSize()
    }
    catch {
      Write-VerboseColored "Error downloading image $URL" Red
      $this.LogError($_)
      $this.downloadInfo.Success = $false
      $this.downloadInfo.StatusMsg = "An error occured trying to download image $URL.  Please see the error log for details."

      # Calling object may want to process the error
      throw $_
    }

  }


  [void] LogError( [System.Management.Automation.ErrorRecord]$ex ) {

    $errormsg = $ex.ToString()
    $stacktrace = $ex.ScriptStackTrace
    $failingline = $ex.InvocationInfo.Line
    $positionmsg = $ex.InvocationInfo.PositionMessage
    $pscommandpath = $ex.InvocationInfo.PSCommandPath
    $failinglinenumber = $ex.InvocationInfo.ScriptLineNumber
    $scriptname = $ex.InvocationInfo.ScriptName

    [string]	$InnerExpMsgs = "All Inner Exception Messages: `r`n"
    [int] $cnt = 0
    $InEx = $_.Exception

    while ($InEx) {
      $cnt++
      if ($cnt -gt 1) {
        $InnerExpMsgs += "Inner Exception $cnt : " + $InEx.Message + "`r`n"
        $InEx = $InEx.InnerException
      }
	  }


    $ErrorArguments = @{
      'errormsg'          = $errormsg;
      'stacktrace'        = $stacktrace;
      'failingline'       = $failingline;
      'positionmsg'       = $positionmsg;
      'pscommandpath'     = $pscommandpath;
      'failinglinenumber' = $failinglinenumber;
      'scriptname'        = $scriptname;
      'innerExMsgs'       = $InnerExpMsgs
    }

    Write-ErrorLog @ErrorArguments

  }


  [void] AddDownloadType ([DownloadType] $type) {
    $this.DownloadTypes += $type

  }

  [void] Invoke() {
    $this.DownloadTypes | ForEach-Object {

      # For each iteration we need a new DownloadInfo object
      $this.downloadInfo = [DownloadInfo]::new()
      $this.downloadInfo.DownloadFolder = $this.DEFAULT_DOWNLOAD_FOLDER
      $this.downloadInfo.TempFolder = $this.DEFAULT_TEMP_FOLDER

      try {
        $_.Invoke($this)
      }
      catch {
        $this.LogError($_)
        break
      }
    }
  }
}

class NasaAPOD : DownloadType {

  [string] $NasaApiKey = 'DEMO_KEY'
  [string] $DownloadFolder

  #region Constructors
  NasaAPOD () : base('NasaAPOD') {}

  NasaAPOD ([string] $downloadFolder) : base('NasaAPOD') {

    $this.DownloadFolder = $downloadFolder

  }

  NasaAPOD ([string] $apiKey, [string] $downloadFolder) : base('NasaAPOD') {

    $this.NasaApiKey = $apiKey
    $this.DownloadFolder = $downloadFolder

  }
  #endregion

  [void] Invoke ([ImageDownload] $D) {

    Write-VerboseColored 'Starting download NASA APOD Feed' DarkMagenta
    $this.StartTime = [DateTime]::Now

    $uri = 'https://api.nasa.gov/planetary/apod?api_key={0}' -f $this.NasaApiKey
    $D.downloadInfo.StartTime = $this.StartTime
    $D.downloadInfo.FeedURL = $uri
    $D.downloadInfo.FeedName = $this.Name

    # Get the APOD data from NASA
    try {
      $imgInfo = Invoke-WebRequest -Uri $uri | ConvertFrom-Json
      $imgURL = $imgInfo.url

    }
    catch {
      Write-VerboseColored 'An error occured downloading NASA APOD Feed' RED
      $D.LogError()
      $D.downloadInfo.ElapsedTime = $this.GetElapsed()
      $D.Results += $D.downloadInfo
      return

    }

    #Populate DownloadInfo object.  Required by $D.DownloadImageFromURL()
    $D.downloadInfo.imgURL = $imgURL

    # Use default download folder if one not provide in constructor
    if ($this.DownloadFolder -ne $null) {$D.downloadInfo.DownloadFolder = $this.DownloadFolder}

    try {
      Write-VerboseColored "Trying download from $imgURL " DarkMagenta
      $D.DownloadImageFromURL()

    }
    catch {
      Write-VerboseColored 'An error occured downloading image NASA APOD' RED
      #Error logging done in $D.DownloadImageFromURL().  No extra action needed
    }
    finally {
      $D.downloadInfo.ElapsedTime = $this.GetElapsed()
      $D.Results += $D.downloadInfo
    }
  }
}


class EarthObservatoryPOD : DownloadType {

  $RSSFeed = "https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss"
  [string] $DownloadFolder
  [string] $TempFolder

  #region Constructors
  EarthObservatoryPOD () : base('EarthObservatoryPOD') {  }

  EarthObservatoryPOD ([string] $downloadFolder) : base('EarthObservatoryPOD') {

    $this.DownloadFolder = $downloadFolder

  }

  EarthObservatoryPOD ([string] $downloadFolder, [string] $tempFolder) : base('EarthObservatoryPOD') {

    $this.DownloadFolder = $downloadFolder
    $this.TempFolder = $tempFolder

  }
  #endregion


  [void] Invoke ([ImageDownload] $D) {

    $StdImageSuffix = '_th.'
    $LrgImageSuffix = "_lrg."

    Write-VerboseColored 'Starting download of Earth Observatory Image of the Day Feed' DarkMagenta

    if ($this.DownloadFolder -ne $null) { $D.downloadInfo.DownloadFolder = $this.DownloadFolder }
    if ($this.TempFolder -ne $null) { $D.downloadInfo.TempFolder = $this.TempFolder }
    $D.downloadInfo.FeedURL = $this.RSSFeed
    $D.downloadInfo.FeedName = $this.Name

    $outFile = $D.downloadInfo.TempFolder + '\EarthObservatory.rss'

    try {
      if (!(Test-Path $D.downloadInfo.TempFolder)) { mkdir $D.downloadInfo.TempFolder }
      Invoke-RestMethod -Uri $this.RSSFeed -OutFile $outFile
      [xml]$resp = Get-Content -Path C:\temp\EarthObservatory.rss

      #  Add the 'media' namespace so we can query for <media:thumbnail> nodes
      $ns = New-Object Xml.XmlNamespaceManager($resp.NameTable)
      $ns.AddNamespace('media', 'http://search.yahoo.com/mrss/')
      #  Get all the thumbnail nodes
      $imgURLS = $resp.SelectNodes('//item/media:thumbnail[@url]', $ns)

      # Loop through all returned media:thumbnail nodes, get the img url, and download
      foreach ( $i in $imgURLS) {

        # Make a cloned instance of downloadInfo for next image
        $D.downloadInfo = $D.downloadInfo.Clone()

        $imgURL = $i.url

        # Uncomment next line if you want high res images, 2-8 MB as opposed to 80-300 KB.
        # The RSS feed contains thumbnail images around 400-600px in width.
        # The files with  "_lrg" at end of the name are 1000px and wider.
        $imgURL = $imgURL.Replace($StdImageSuffix, $LrgImageSuffix)
        $imgName = $imgURL.Substring($i.url.LastIndexOf('/') + 1)

        $D.downloadInfo.ImgName = $imgName
        $D.downloadInfo.ImgURL = $imgURL
        $D.downloadInfo.StartTime = [DateTime]::Now

        try {
          $D.DownloadImageFromURL()
        }
        catch [Microsoft.PowerShell.Commands.HttpResponseException] {

          Write-VerboseColored "Caught an HttpResponseException " red
          # Large image does not exist. Retry with $StdImageSuffix
          if (($_.Exception.Response.StatusCode -eq 'NotFound') -and ($imgName.Contains($LrgImageSuffix)) ) {
            Write-VerboseColored "A File Not Found error occured occured attempting download of large version of image $imgName" YELLOW

            try {
              $D.downloadInfo.ImgName = $imgName.Replace($LrgImageSuffix , $StdImageSuffix)
              $D.downloadInfo.ImgURL = $imgURL.Replace($LrgImageSuffix , $StdImageSuffix)
              $D.DownloadImageFromURL()
            }
            catch {
              Write-VerboseColored "An error occured on retry downloading smaller image $imgName" Red

            }
          }
        }
        catch {
          Write-VerboseColored "An error occured downloading image $imgName" Red
        }
        finally {
          $D.downloadInfo.ElapsedTime = [DateTime]::Now - $D.downloadInfo.StartTime
          $D.Results += $D.downloadInfo

        }

      }

    }
    catch {
      Write-VerboseColored "An error occured processing the Earth Observatory RSS feed. " red
      $D.LogError($_)
    }
  }
}




class OutdoorPhotographer : DownloadType {

  $RSSFeed = 'https://www.outdoorphotographer.com/on-location/favorite-places/feed/'
  [string] $DownloadFolder
  [string] $TempFolder

  [OutdoorPhotoFeedEnum] $FeedType



  #region Constructors
  OutdoorPhotographer () : base('OutdoorPhotographer') {  }

  OutdoorPhotographer ([string] $downloadFolder) : base('OutdoorPhotographer') {

    $this.DownloadFolder = $downloadFolder

  }

  OutdoorPhotographer ([string] $downloadFolder, [string] $tempFolder) : base('OutdoorPhotographer') {

    $this.DownloadFolder = $downloadFolder
    $this.TempFolder = $tempFolder

  }

  OutdoorPhotographer ([OutdoorPhotoFeedEnum] $feedType, [string] $downloadFolder) : base('OutdoorPhotographer') {

    $this.FeedType = $FeedType
    $this.DownloadFolder = $downloadFolder

    switch ($FeedType) {
      'FavoritePlaces'  { $this.RSSFeed = 'https://www.outdoorphotographer.com/on-location/favorite-places/feed/' }
      'FeaturedStories' { $this.RSSFeed = 'https://www.outdoorphotographer.com/on-location/featured-stories/feed/' }
      'Travel'          { $this.RSSFeed = 'https://www.outdoorphotographer.com/on-location/travel/feed/' }
    }

  }
  #endregion


  [string] GetEnumVal () {

    return $this.FeedType
  }


  <#
   #  Download RSS feed to local a file then load it into an XML object.
   #  The image URLs we want are in a CDATA section of the item/description nodes.
   #  Select all the item/description nodes, and loop through the set to
   #  process each node found.
  #>
  [void] Invoke ([ImageDownload] $D) {

    $feed = $this.RSSFeed

    Write-VerboseColored "Starting download of Outdoor Photography Feed $feed" DarkMagenta

    if ($this.DownloadFolder -ne $null) { $D.downloadInfo.DownloadFolder = $this.DownloadFolder }
    if ($this.TempFolder -ne $null) { $D.downloadInfo.TempFolder = $this.TempFolder }
    $D.downloadInfo.FeedURL = $this.RSSFeed
    $D.downloadInfo.FeedName = $this.Name

    $outFile = $D.downloadInfo.TempFolder + '\OutdoorPhotography.rss'

    try {
      if (!(Test-Path $D.downloadInfo.TempFolder)) { mkdir $D.downloadInfo.TempFolder }
      Invoke-RestMethod -Uri $this.RSSFeed -OutFile $outFile
    }
    catch {
      Write-VerboseColored 'An error occured downloading the Outdoor Photography RSS Feed' Red
      $D.LogError($_)
      return
    }

    [xml]$resp = Get-Content -Path $outFile
    $imgURLS = $resp.SelectNodes('//item/description')

    for ($i = 0; $i -lt $imgURLS.Count; $i++) {
      Write-VerboseColored "Processing <description> Element # $i" Green
      $zz = $imgURLS[$i]
      $content = $zz.InnerText

      # Wrap the InnerText, which is html, in <xml> tags so it is well formed xml.
      $content = '<xml>' + $content + '</xml>'

      try {
        # Load the extracted text into an xml object and get the img node.
        # In this feed there is only one in the <description> element.
        [xml]$desc = $content
        $img = $desc.SelectNodes('//img')
        $D.downloadInfo.ImgURL = [String]$img.src
        $D.DownloadImageFromURL()
      }
      catch {
        # Errors here are almost alway bad xml in the CDATA
        # Errors caught in $D.DownloadImageFromURL() are logged there
        if ( ($_.Exception.InnerException.InnerException -ne $null) -and ($_.Exception.InnerException.InnerException.GetType().Name -eq 'XMLException') ) {
          Write-Verbose 'XML Parsing error loading CDATA html into XMLReader.  Skipping this <description> element'
          $exp = $_.Exception.InnerException.InnerException
          $msg = "XMLException: " + $exp.Message
          try {
            throw ( New-Object System.Exception( $msg , $exp ) )
          }
          catch {
            $D.LogError($_)
            $D.downloadInfo.Success = $false
            $D.downloadInfo.StatusMsg = 'XML Parsing error loading CDATA html into XMLReader.  Skipping this <description> element'
          }
        }
      }
      finally {
        $D.downloadInfo.ElapsedTime = $this.GetElapsed()
        $D.Results += $D.downloadInfo
      }

      continue

    }
  }
}




