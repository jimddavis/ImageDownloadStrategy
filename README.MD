# **Powershell Image Download Using Strategy Pattern**


A Class based module implementing the Strategy pattern to download images from different sources on the web. Includes concrete strategy classes to download from the following sources.
* NASA Astronomy Picture of the Day using NASA Open API
* Earth Observatory Picture of the Day from their RSS feed
* Outdoor Photography from three RSS feeds, all in one script.

&nbsp;


## **Overview of Feeds Used By This Module**


### **NASA Open API**
NASA Open APIs can be found at the [NASA APIs](https://api.nasa.gov/) website.  All API calls require an api_key as a parameter.  NASA provides the DEMO_KEY for demonstration and testing purposes, but it has daily limits.

The rate limits for the DEMO_KEY are:
* Hourly Limit: 30 requests per IP address per hour.
* Daily Limit: 50 requests per IP address per day.

You can [sign up for your own key](https://api.nasa.gov/) to remove those limits.

This module uses the [NASA APOD Open API](https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY) with the DEMO_KEY.

&nbsp;


### **Earth Observatory RSS Feed**
* [Earth Observatory Image of the Day RSS feed](https://earthobservatory.nasa.gov/feeds/image-of-the-day.rss)
* [All Earth Observatory RSS feeds](https://earthobservatory.nasa.gov/subscribe/feeds)
* [The Earth Observatory web site](https://earthobservatory.nasa.gov/)

&nbsp;


### **Outdoor Photography RSS Feeds**
* [Favorite Places RSS Feed](https://www.outdoorphotographer.com/on-location/favorite-places/feed/)
* [Featured Stories RSS Feed](https://www.outdoorphotographer.com/on-location/featured-stories/feed/)
* [Travel RSS Feed](https://www.outdoorphotographer.com/on-location/travel/feed/)
* [All Outdoor Photography RSS Feeds](https://www.outdoorphotographer.com/rss-feeds/)

&nbsp;


## **Where the Image Files are Stored**
The core Context class ImageDownload has the following defaults, which can be overridden in each of the concrete class implementations. If these folders to not exist, they are created.

* Image download folder:  USER\Pictures\ImageDownloads
* Temp working folder for storing files: C:\temp

&nbsp;


## **Classes and Enums**

All classes are in the module file ImageDownloads.psm1

![This is an image](/images/ImageDownloads.png)

Image generated by [PSClassUtils](https://www.powershellgallery.com/packages/PSClassUtils/2.6.3) Write-CUClassDiagram

&nbsp;

### **OutdoorPhotoFeedEnum**

RSS Feeds available from https://www.outdoorphotographer.com/rss-feeds/. &nbsp;&nbsp;
Used in OutdoorPhotographer constructor.

&nbsp;

### **class DownloadInfo**

Rich results information and data structure used by ImageDownload class.

&nbsp;

### **class DownloadType**

Base class for different download feeds.  Implements the Strategy Interface of strategy pattern.

&nbsp;

### **class ImageDownload**

Main class.  The "Context" class of the Strategy pattern.  Will only download an image if it does not already exist in the destination folder.

&nbsp;

### **class NasaAPOD**

Concrete Stategy class for downloading from the NASA Astronomy Picture of the Day Open API

&nbsp;

### **class EarthObservatoryPOD**

Concrete Stategy class for downloading from Earth Observatory Image of the Day RSS Feed

&nbsp;


### **class OutdoorPhotographer**

Concrete Stategy class for downloading from Outdoor Photographer RSS Feeds

&nbsp;

## **Supporting Module and Script Files**

&nbsp;

### **Write-VerboseColored.psm1**

A simple module that allows changing the forecolor of the Verbose output stream so it is not always Yellow.
```
   Write-VerboseColored 'Your Text'  SystemColor
```

Allowed colors are Black, Blue, Cyan,  DarkBlue, DarkCyan, Darkgray, DarkMagenta, DarkGreen, DarkRed, DarkYellow,   Gray, Green, Magenta, Red, Yellow, and White.

&nbsp;


### **WriteErrorLog.ps1**

A simple module for logging errors.  This module is part of the [Efficiency Booster PowerShell Project](https://www.improvescripting.com/efficiency-booster/) from ImproveScripting.com.

&nbsp;


## **Powershell Version**
Minimum Powershell 7.0. 	&nbsp;
This was written in Powershell 7.2 on Windows 11 and not tested on any other platform.

&nbsp;


## **Schedule Script to Run Daily on Windows**
1. Open Task Scheduler
2. Create a new local task
3. Give it a name and description; NASA POD Download, for example.
4. Set a trigger as desired, _Every day at 8 am_ for example.
5. Select the Action Start a program:
	- Program/Script: pwsh.exe
	- Add Arguments: -ExecutionPolicy Bypass -file "C:\FULLPATH\NameOfScript.ps1"
	- Start In: C:\FULLPATH    Same path as in arguments.  *The task will not run successfully without this as the "using module" statements will fail since they are looked for in the same directory as the script.*


&nbsp;


### **Note:**
Before being able to run this script without using VS Code, you will need to set the execution policy.
1. Run PowerShell as Administrator
2. Run the following command to unblock the script:
	- _Unblock-File -Path c:\Path\to\script.ps1_
3. Run the following command to allow the script to run:
	- _Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine_
	Note this grants ANY script to run. Its easy, but not the safest approach.

	&nbsp;

## **Comments About This Module**

I am a beginner with Powershell and the basis for the code in this module was taken from a variety of other examples on the web, with a fair amount of research to work out problems.  It does not represent best practices.  I looked at a few examples and picked what seemed like a good idea to me!

I wrote this because I got excited about viewing NASA images on my computer, and just happened to run accross a Powershell script on the internet that set the NASA Astronomy Picture of the Day to the Windows Background.  I use [John's Background Switcher](https://johnsad.ventures/software/backgroundswitcher/) to change my background every 30 seconds, so I just wanted to store the pictures locally.

Then I discovered the Earth Observatory web site, then the Outdoor Photographer RSS Feed. Then, as an ex C# developer (12 years ago) I got curious about classes, and with 3 iterations it evolved into this.

This was an exercise in getting the pictures, learning a bit about Powershell, setting up a Git repository, and learning to format the README file. I learned a lot.  It has been frustrating and fun and gratifying.  Hopefully someone else finds this useful.


&nbsp;

## Author

Jim Davis: 	&nbsp; Owner of the [Hummingbird Healing Center](https://hummingbirdhealingcenter.org/)




