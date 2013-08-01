# Command Line Interface for WildCommander

<img src="https://raw.github.com/acidrave/CLi-for-WildCommander/master/misc/screenshot.png"
 alt="CLi Example" title="Command Line Interface for WildCommander" align="center" />

Command Line Interface (further simply CLi) is plugin for WildCommander.
CLi extend interface WildCommander with help command line and few commands, also
allows you to run simplified version of SH scripts.

<img src="https://raw.github.com/acidrave/CLi-for-WildCommander/master/misc/screenshot2.png"
 alt="CLi Example" title="Command Line Interface for WildCommander" align="center" />

WildCommander written by [Budder](http://budder.narod.ru/) for [PentEvo/ZX Evolution](http://www.nedopc.com/zxevo/zxevo_eng.php) (Modern ZX Spectrum's clone).
More information can be found at the bottom of this readme file.

<img src="https://raw.github.com/acidrave/CLi-for-WildCommander/master/misc/nyancat.png"
 alt="CLi Example" title="Command Line Interface for WildCommander" align="center" />

## Installation

For usage Cli requires the latest version of WildCommder. You can get it [here](https://code.google.com/p/zx-evo-fpga/source/browse/#svn%2Fbranches%2Ftslabs%2Fpentevo%2Fsoft%2FWC%2Fexe).
Simple copy CLI.WMF into WC directory and run manually or write into wc.ini:

    Wild Commander configuration file v0.1
    CLI     .WMF

Restart WildCommder, press F10 and select "Command Line Interface" in menu list. Also you
can press ENTER at the *.sh file and start the execution of the script without running CLi.

<img src="https://raw.github.com/acidrave/CLi-for-WildCommander/master/misc/aperture.png"
 alt="CLi Example" title="Command Line Interface for WildCommander" align="center" />

## Usage

Type "help" into command line for the list available commands.

	1>help

You also can you use escape codes like \\xNN, where NN - hex value. For example \\x10\\x00 - switch ink to the
black color, or \\x11\\x0F switch paper into white color. Code \\x10\\x10 - return ink to the default color.

## Emulation

If you don't have a real PentEvo/ZX Evolution with firmware from [TS-Labs](https://code.google.com/p/zx-evo-fpga/source/browse/#svn%2Fbranches%2Ftslabs%2Fpentevo%2Favr%2Fcurrent%2Fdefault)
but you want to test this platform & software, you can download "Unreal Speccy" emulator TS-Labs edition [here](https://code.google.com/p/zx-evo-fpga/source/browse/branches/tslabs/pentevo/unreal/Unreal/bin/unreal.7z).

## Building

To build the project from source we use [sjasmplus](http://sourceforge.net/projects/sjasmplus/) assembler,
but you can use any available assembler that supports Zilog Z80 processor.

## YouTube

Also you can view "how it's works" at [youtube](http://www.youtube.com/watch?v=Duo4MfBhUQA).

## Special thanks

Big thanks to:
> - Robat(Wizard^DT) for the screensaver example code
> - Budder/MGN for their help with information, consultations and help with code.
> - TS-Labs for PentEvo firmware & Unreal Speccy modification.
> - CHRV & all members of [NedoPC](http://www.nedopc.com/) for PentEvo/ZX Evolution board.

## License
Source Copyright © 2012,2013 Breeze Fishbone and contributors. Distributed under the BSD License. See the file LICENCE.
