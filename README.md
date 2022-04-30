# CLogger

CLogger is a light weight contest logger that is primarily desgined to be used in CW contesting in conjunction with [CWkeyer](https://github.com/etamme/cwkeyer), as a very simple serial keying interface.

It features: 
- Run, and search and pounce modes  
- Dynamic function key configuration 
- Call and exchange auto fills from callfile
- Automatic DUPE checking
- LOTW compatible ADIF output

To Use:
- Clone repo and [CWkeyer](https://github.com/etamme/cwkeyer)
- Symlink keyer.py from cwkeyer into the clogger root directory
- Copy clogger.cfg.sample to clogger.cfg
- Configure via clogger.cfg
- Configure applicable contest files
- Update [Call History Files](https://n1mmwp.hamdocs.com/mmfiles/categories/callhistory/) as necessary

![demo](https://i.imgur.com/E5HjEoR.gif)

## cwkeyer and hamlib keyer
cwkeyer works in a similar way to cwdaemon; by keying the transmitter via the RTS or DTR pins of the computer serial port. It does the timing of the cw characters in computer software.
- Can work with any rig using a simple transistor and capacitor circuit connected to key port of the transceiver
- Can also use the built-in serial ports of many rigs

Hamlib is used to read frequency in CLogger, but it can also key the transmitter. It does this by sending text over the CAT protocol to the radio's built-in keyer.
- Uses Rig's CPU for perfect timing
- Allows both CAT and CW keying over the same serial tty device without conflicts (only a single application accesses it)
- Keyer speed stays synced between CLogger and Rig
- Works with WFView so can be used on the local computer for fully remote operation.
- New feature of Hamlib; may not work properly before version 4.1.
- Limited radios supported*

*Several radios support sending CW with hamlib, but CLogger also makes use of the "morse_wait" command to correctly time the CQ repeat, and "stop_morse" command to immediately stop the keyer when ESC is pressed. The IC-7300 was the first radio to be supported with all 3 functions in hamlib.

## WFView
Example tested and working config connecting to WFView's pseudo TTY device with an IC-7300:

```
 rig="3073"
 rigdevice="/home/pi/rig-pty1"
 keywithhamlib="true"
 rigoptions=""
 rigctl="/usr/local/bin/rigctl" #Compiled hamlib v4.1
```
