# telly-opus

IPTV proxy for Plex Live TV written in Golang, with ffmpeg audio output in OPUS format
This project is based on tellytv/telly


## This readme refers to version 1.1.0.29 .  It does not apply to versions other than that.

# Configuration

Here's an example configuration file. **You will need to create this file.**  It should be placed in `/etc/telly/telly.config.toml` or `$HOME/.telly/telly.config.toml` or `telly.config.toml` in the directory that telly is running from.

> NOTE "the directory telly is running from" is your CURRENT WORKING DIRECTORY.  For example, if telly and its config file file are in `/opt/telly/` and you run telly from your home directory, telly will not find its config file because it will be looking for it in your home directory.  If this makes little sense to you, use one of the other two locations OR cd into the directory where telly is located before running it from the command line.

> ATTENTION Windows users: be sure that there isn’t a hidden extension on the file.  Telly can't read its config file if it's named something like `telly.config.toml.txt`.

```toml
# THIS SECTION IS REQUIRED ########################################################################
[Discovery]                                    # most likely you won't need to change anything here
  Device-Auth = "telly123"                     # These settings are all related to how telly identifies
  Device-ID = "12345678"                       # itself to Plex.
  Device-UUID = ""
  Device-Firmware-Name = "hdhomeruntc_atsc"
  Device-Firmware-Version = "20150826"
  Device-Friendly-Name = "telly"
  Device-Manufacturer = "Silicondust"
  Device-Model-Number = "HDTC-2US"
  SSDP = true

# Note on running multiple instances of telly
# There are three things that make up a "key" for a given Telly Virtual DVR:
# Device-ID [required], Device-UUID [optional], and port [required]
# When you configure your additional telly instances, change:
# the Device-ID [above] AND
# the Device-UUID [above, if you're entering one] AND
# the port [below in the "Web" section]

# THIS SECTION IS REQUIRED ########################################################################
[IPTV]
  Streams = 1               # number of simultaneous streams that the telly virtual DVR will provide
                            # This is often 1, but is set by your iptv provider; for example, 
                            # Vaders provides 5
  Starting-Channel = 10000  # When telly assigns channel numbers it will start here
  XMLTV-Channels = true     # if true, any channel numbers specified in your M3U file will be used.
# FFMpeg = true             # if this is uncommented, streams are buffered through ffmpeg; 
                            # ffmpeg must be installed and on your $PATH
                            # if you want to use this with Docker, be sure you use the correct docker image
# if you DO NOT WANT TO USE FFMPEG leave this commented; DO NOT SET IT TO FALSE
  
# THIS SECTION IS REQUIRED ########################################################################
[Log]
  Level = "info"            # Only log messages at or above the given level. [debug, info, warn, error, fatal]
  Requests = true           # Log HTTP requests made to telly

# THIS SECTION IS REQUIRED ########################################################################
[Web]
  Base-Address = "0.0.0.0:6077"   # Set this to the IP address of the machine telly runs on
  Listen-Address = "0.0.0.0:6077" # this can stay as-is

# THIS SECTION IS NOT USEFUL ======================================================================
#[SchedulesDirect]           # If you have a Schedules Direct account, fill in details and then
                             # UNCOMMENT THIS SECTION
#  Username = ""             # This is under construction; no provider
#  Password = ""             # works with it at this time

# AT LEAST ONE SOURCE IS REQUIRED #################################################################
# NONE OF THESE EXAMPLES WORK AS-IS; IF YOU DON'T CHANGE IT, DELETE IT ############################
[[Source]]
  Name = ""                 # Name is optional and is used mostly for logging purposes
  Provider = "Custom"       # DO NOT CHANGE THIS IF YOU ARE ENTERING URLS OR FILE PATHS
                            # "Custom" is telly's internal identifier for this 'Provider'
                            # If you change it to "NAMEOFPROVIDER" telly's reaction will be
                            # "I don't recognize a provider called 'NAMEOFPROVIDER'."
  M3U = "http://myprovider.com/playlist.m3u"  # These can be either URLs or fully-qualified paths.
  EPG = "http://myprovider.com/epg.xml"
  # THE FOLLOWING KEYS ARE OPTIONAL IN THEORY, REQUIRED IN PRACTICE
  Filter = "Sports|Premium Movies|United States.*|USA"
  FilterKey = "group-title" # FilterKey normally defaults to whatever the provider file says is best, 
                            # otherwise you must set this.
  FilterRaw = false         # FilterRaw will run your regex on the entire line instead of just specific keys.
  Sort = "group-title"      # Sort will alphabetically sort your channels by the M3U key provided
# END TELLY CONFIG  ###############################################################################
```

# FFMpeg

Telly can buffer the streams to Plex through ffmpeg.  This has the potential for several benefits, but today it primarily:

1. Allows support for stream formats that may cause problems for Plex directly.
2. Eliminates the use of redirects and makes it possible for telly to report exactly why a given stream failed.
3. Makes use of the OPUS audio format

To take advantage of this, ffmpeg must be installed and available in your path.

# Docker

To use telly-opus, use the following docker-compose:
## docker-compose
```
version: "3.8"

services:
  telly:
    build:
      context: https://github.com/bphett/telly-opus.git
      dockerfile: Dockerfile.ffmpeg
    ports:
      - "6077:6077"
    environment:
      - TZ=America/Chicago
    volumes:
      - ${ConfigFolder}:/etc/telly
    env_file:
      - stack.env  
    restart: unless-stopped
```

${ConfigFolder} in your stack.env should be set to wherever you have your M3U and the telly config file. I placed mine on a Windows Share.
