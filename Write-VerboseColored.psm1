
<#
    This function allows writing to the Write-Verbose stream using colored output.
    It works by changing the (Get-Host)PrivateData.VerboseForegroundColor and
    VerboseBackgroundColor values, then resetting them to original values.
#>
function Write-VerboseColored {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory = $True,
      Valuefrompipeline = $true)]
    [String]$message,
    [Parameter(
      Mandatory = $False,
      ValueFromPipeline = $True,
      ValueFromPipelinebyPropertyName = $True)]
    [ConsoleColor] $ForegroundColor,

    [Parameter(
      Mandatory = $False,
      ValueFromPipeline = $True,
      ValueFromPipelinebyPropertyName = $True)]
    [ConsoleColor] $BackgroundColor
  )

  begin {
    $window_private_data = (Get-Host).PrivateData;
    # saving the original colors
    $saved_background_color = $window_private_data.VerboseBackgroundColor
    $saved_foreground_color = $window_private_data.VerboseForegroundColor
    # setting the new colors
    if ( $BackgroundColor -ne $null) {
      $window_private_data.VerboseBackgroundColor = $BackgroundColor;
    }

    if ($ForegroundColor -ne $null) {
      $window_private_data.VerboseForegroundColor = $ForegroundColor;
    }
  }

  process {
    foreach ($Message in $Message) {
      # Write-Host Considered Harmful - see http://www.jsnover.com/blog/2013/12/07/write-host-considered-harmful/
      # first way how to correctly write it
      #Write-host $message;
      Write-Verbose -Message $message;
      # second correct way how to write it
      #$VerbosePreference = "Continue"
      #Write-Verbose $Message;
    }
  }
  end {
    $window_private_data.VerboseBackgroundColor = $saved_background_color;
    $window_private_data.VerboseForegroundColor = $saved_foreground_color;
  }
}
