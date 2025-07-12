# DelphiFun

A collection of some functions I wrote for other applications or out of boredom.

# GGCompress

Demo how to add translations to your app with GnuGetText for Delphi and compress them with ZLib.

# ProgressBar

I needed some simple and embeddable progress bar frame... this is what I came up with in less than 1 hour.

# CheckingCertificates

Demo project to read a certificate from any executable and show it's owner, issuing CA, fingerprint and decide
whether it's trusted by Windows or not.

# FindLaunchingShortcut

Find out if your app has been launched by a Shortcut file and retrieve the shortcut's filename.
Intention: If the shortcut's parameters are invalid you now have the opportunity to ask the user to delete it.

# Nullable

An **extremely simple** implementation of Nullable<T>. Consider using Nullable from the Spring4D framework instead
which is much more sophisticated.

# My version of TEnumConverter

Providing easy conversion between string representation <-> Enum <-> Integer 

# A look at IfThen

Every new Delphi programmer should be aware that in any common IfThen implementation, both return values for the conditions are
calculated by the compiler prior to calling the IfThen construct. This poses no problem when working with constants but will
when the calculations are costly i.e. when retrieving different rows from a database based on the condition.

Check the IfThen project for a solution using Generics and anonymous functions.

# Yet another TExecutor implementation

TExecutor executes a binary file either in foreground or background.

* callback functions for success or error
* Various methods to detect ending apps: by process id, image name, or image path
* Option to check if the binary is digitally signed

# Detect when a new drive letter gets attached to the Windows file system

Windows broadcasts new devices to all applications that have a main window handle using the WM_DEVICECHANGE message.
Unfortunately the necessary constants or structures are not included in Delphi 11 Community Edition.

This introduces the missing DBTTypes.pas unit and a sample app that notifies the user when a new drive appears or disappears.

# Read desktop shortcut and extract it's configured icon

Drop a desktop shortcut on this demo window and it will read the shortcut file, determine and retrieve the
appropriate icon.

# Intercept (duplicate) console application output

Now a tough one (I think)

There are hundreds of examples of how to **redirect** output from a console application to your own application. Basically you pass 
inheritable anonymous pipe handles to CreateProcess() which will then get attached to the console. It's your app which reads the
console app output from the pipe.

However, this solution has a major drawback: The console window is empty. So most people just hide the window with SW_HIDE.

A solution is to attach your own process to the child console applications window and echo the output while it's recorded with a
simple call to Write(). You can find an example in InterceptConsoleOutput.dpr.

Refer to https://learn.microsoft.com/en-us/windows/console/getconsoleoutputcp if you need to translate the captured output to your
codepage (e.g. when German "Umlauts" are broken.)

# WMI (Windows Management Instrumentation) example to find your MachineUUID

The problem with WMI is not to get the information extracted, but to find it. There is a huge amount of information about
your computer and operating system waiting for you.

Read more about WMI on Wikipedia [https://en.wikipedia.org/wiki/Windows_Management_Instrumentation]

Of particular interest is the class Win32_ComputerSystemProduct which is used in this demo:

```
  Name                  : Parallels Virtual Platform
  Version               : None
  Caption               : Computersystemprodukt
  Description           : Computersystemprodukt
  IdentifyingNumber     : Parallels-74 88 82 30 DB 3D 4C B0 A7 1D A6 FB FB D2 57 7E
  SKUNumber             :
  Vendor                : Parallels International GmbH.
  UUID                  : 30828874-3DDB-B04C-A71D-A6FBFBD2577E
  PSComputerName        :
  CimClass              : root/cimv2:Win32_ComputerSystemProduct
  CimInstanceProperties : (Caption, Description, IdentifyingNumber, Name...)
  CimSystemProperties   : Microsoft.Management.Infrastructure.CimSystemProperties
```
Also of interest is the Win32_OperatingSystem that is a bag of information about your installed Windows:
```
  Status                                    : OK
  Name                                      : Microsoft Windows 11 Pro|C:\WINDOWS|\Device\Harddisk0\Partition3
  FreePhysicalMemory                        : 4773060
  FreeSpaceInPagingFiles                    : 514572
  FreeVirtualMemory                         : 5117040
  Caption                                   : Microsoft Windows 11 Pro
  Description                               :
  InstallDate                               : 18.06.2024 18:25:45
  CreationClassName                         : Win32_OperatingSystem
  CSCreationClassName                       : Win32_ComputerSystem
  CSName                                    : VM-DELPHI-XE
  CurrentTimeZone                           : 120
  Distributed                               : False
  LastBootUpTime                            : 03.09.2024 09:16:26
  LocalDateTime                             : 03.09.2024 09:44:32
  MaxNumberOfProcesses                      : 4294967295
  MaxProcessMemorySize                      : 137438953344
  NumberOfLicensedUsers                     :
  NumberOfProcesses                         : 153
  NumberOfUsers                             : 2
  OSType                                    : 18
  OtherTypeDescription                      :
  SizeStoredInPagingFiles                   : 524288
  TotalSwapSpaceSize                        :
  TotalVirtualMemorySize                    : 8893744
  TotalVisibleMemorySize                    : 8369456
  Version                                   : 10.0.22631
  BootDevice                                : \Device\HarddiskVolume1
  BuildNumber                               : 22631
  BuildType                                 : Multiprocessor Free
  CodeSet                                   : 1252
  CountryCode                               : 49
  CSDVersion                                :
  DataExecutionPrevention_32BitApplications : True
  DataExecutionPrevention_Available         : True
  DataExecutionPrevention_Drivers           : True
  DataExecutionPrevention_SupportPolicy     : 2
  Debug                                     : False
  EncryptionLevel                           : 256
  ForegroundApplicationBoost                : 2
  LargeSystemCache                          :
  Locale                                    : 0407
  Manufacturer                              : Microsoft Corporation
  MUILanguages                              : (de-DE, en-US)
  OperatingSystemSKU                        : 48
  Organization                              :
  OSArchitecture                            : 64-Bit
  OSLanguage                                : 1031
  OSProductSuite                            : 256
  PAEEnabled                                :
  PlusProductID                             :
  PlusVersionNumber                         :
  PortableOperatingSystem                   : False
  Primary                                   : True
  ProductType                               : 1
  RegisteredUser                            : Olray
  SerialNumber                              : 12345-10000-00001-12345
  ServicePackMajorVersion                   : 0
  ServicePackMinorVersion                   : 0
  SuiteMask                                 : 272
  SystemDevice                              : \Device\HarddiskVolume3
  SystemDirectory                           : C:\WINDOWS\system32
  SystemDrive                               : C:
  WindowsDirectory                          : C:\WINDOWS
  PSComputerName                            :
  CimClass                                  : root/cimv2:Win32_OperatingSystem
  CimInstanceProperties                     : (Caption, Description, InstallDate, Name...)
  CimSystemProperties                       : Microsoft.Management.Infrastructure.CimSystemProperties
```
There are dozens of other classes you can explore. Open a PowerShell window and use the following Cmdlet: **Get-CimClass** to get a list.

*  Win32_Share lists all network shares
*  Win32_VideoController fetches information about your video card

If Get-CimClass shows something of interest use the following Cmdlet to display all members of this class:

```
  Get-CimInstance -Class <Class> | Format-List *
```