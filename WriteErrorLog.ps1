<#
.SYNOPSIS
Writes errors that occur in powershell scripts into error log file.
.DESCRIPTION
Writes errors that occur in powershell scripts into error log file.
Error log file and error log folder will be created if doesn't exist.
Error log file name is Error_Log.txt and it has been saved into ..\Documents\PSlogs\

.PARAMETER hostname
Name of the computer that is failing.

.PARAMETER env
Environment where computer is located. For example: Production, Acceptance, Test, Course etc.

.PARAMETER logicalname
Type of the server that is failing. For example: Application, Web, Integration, FTP, Scan, etc.

.PARAMETER errormsg
Error message.

.PARAMETER scriptname
Name of the powershell script that is failing.

.PARAMETER failinglinenumber
Line number in the script that is failing.

.PARAMETER failingline
Content of failing line.

.PARAMETER pscommandpath
Path to the powershell command.

.PARAMETER positionmsg
Error message position.

.PARAMETER stacktrace
Stack trace of the error.

.EXAMPLE
Write-ErrorLog -hostname "Server1" -env "PROD" -logicalname "APP1" -errormsg "Error Message" -exception "HResult 0789343" -scriptname "Test.ps1" -failinglinenumber "25" -failingline "Get-Service" -pscommandpath "Command pathc." -positionmsg "Position message" -stacktrace "Stack trace"

.EXAMPLE
Help Write-ErrorLog -Full

.INPUTS
System.String

InputObject parameters are strings.
.OUTPUTS
External text file. ..\Documents\PSlogs\Error_Log.txt

.NOTES
FunctionName : Write-ErrorLog
Created by   : Dejan Mladenovic
Date Coded   : 10/31/2018 19:06:41
More info    : https://improvescripting.com/

.LINK
https://improvescripting.com/how-to-log-powershell-errors-and-much-more/
Out-File
#>
Function Write-ErrorLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Error message.')]
        [string]$errormsg,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Name of the script that is failing.')]
        [string]$scriptname,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Script fails at line number.')]
        [string]$failinglinenumber,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Failing line looks like.')]
        [string]$failingline,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Powershell command path.')]
        [string]$pscommandpath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Position message.')]
        [string]$positionmsg,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Stack trace.')]
        [string]$stacktrace,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Inner exception messages.')]
        [string]$innerExMsgs


    )
    BEGIN {

        [string]$scriptPath = Get-Location

        $errorlogfile = "$scriptPath\Error_Log.txt"
        $errorlogfolder = $scriptPath

        if ( !( Test-Path -Path $errorlogfolder -PathType 'Container' ) ) {

            Write-Verbose "Create error log folder in: $errorlogfolder"
            New-Item -Path $errorlogfolder -ItemType 'Container' -ErrorAction Stop

            if ( !( Test-Path -Path $errorlogfile -PathType 'Leaf' ) ) {
                Write-Verbose "Create error log file in folder $errorlogfolder with name Error_Log.txt"
                New-Item -Path $errorlogfile -ItemType 'File' -ErrorAction Stop
            }
        }
    }
    PROCESS {

        #Write-Verbose "Start writing to Error log file. $errorlogfile"
        $timestamp = Get-Date
        #IMPORTANT: Read just first value from collection not the whole collection.
        '   ' | Out-File $errorlogfile -Append
        '************************************************************************************************************' | Out-File $errorlogfile -Append
        "Error happend at time: $timestamp on a computer: $hostname - $env - $logicalname" | Out-File $errorlogfile -Append
        "Error message: $errormsg" | Out-File $errorlogfile -Append
        "Inner Exception Messages: $innerExMsgs" | Out-File $errorlogfile -Append
        "Failing script: $scriptname" | Out-File $errorlogfile -Append
        "Failing at line number: $failinglinenumber" | Out-File $errorlogfile -Append
        "Failing at line: $failingline" | Out-File $errorlogfile -Append
        "Powershell command path: $pscommandpath" | Out-File $errorlogfile -Append
        "Position message: $positionmsg" | Out-File $errorlogfile -Append
        "Stack trace: $stacktrace" | Out-File $errorlogfile -Append
        '------------------------------------------------------------------------------------------------------------' | Out-File $errorlogfile -Append

        #Write-Verbose "Finish writing to Error log file. $errorlogfile"
    }
    END {

    }
}
#region Execution examples
#Write-ErrorLog -hostname "Server1" -env "PROD" -logicalname "APP1" -errormsg "Error Message" -exception "HResult 0789343" -scriptname "Test.ps1" -failinglinenumber "25" -failingline "Get-Service" -pscommandpath "Command pathc." -positionmsg "Position message" -stacktrace "Stack trace" -Verbose
#endregion
