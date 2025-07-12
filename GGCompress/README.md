# GnuGetText for Delphi

AFAIK the GnuGetText for Delphi package is the only FLOSS-compatible translation tool out there. If you want to
translate your free software and not pay for a proprietary tool you might want to have a look.

Currently, GnuGetText for Delphi is maintained by Dr. Jürgen Rathleff. Find the source 
[here](https://github.com/jrathlev/GnuGetText-for-Delphi)

Some months ago I have added a function to GnuGetText that allows embedding .mo-files as RCDATA resources instead of
loading them from the file system or manipulating the executable image file.

.mo-files contain mainly text with some additional binary index data, so they can be compressed very well. This project
demonstrates embedding of compressed binary data (.mo-files) that can be used transparently by GnuGetText for Delphi.

## How to use

### Step 1: compress mo files automatically

The subproject CompressCmd.exe is a command line application that compresses every .mo-file found in a specified path
into a file ending in '.mo.compressed'. It accepts a mandatory directory as first and only parameter and processes all
.mo-files in all of the subdirectories. Make sure to wrap the directory in quotes should it contain spaces.

CompressCmd.exe should be called in your pre-build event like this:

```
CompressCmd "$(PROJECTDIR)"
```

For this to work you have to put CompressCmd.exe in your path. You have to compile your application at least once so 
the compressed files are created.

### Step 2: include the compressed mo-files as RCDATA resources

In Delphi select Project > Ressources and Pictures. Add all your compressed .mo-files and give them a resource ID following
this schema:

```
IDR_TRANSLATE_<LNG>_<DOMAIN>_C
```

Example: The italian file .\locale\IT\LC_MESSAGES\default.mo.compressed should be added with ID 
**IDR_TRANSLATE_IT_DEFAULT_C**

Omit the "_C" when adding the **uncompressed** version of your .mo-files which also works.
