## 0.14c (2013-08-01)

* fixed run *.sh scripts
* refactoring call api functions
* added NeoGS Card driver
* added Kempston Mouse driver
* added external command loadmod for upload mod file into NeoGS Card
* added external command type for display text files
* added external command micetest for testing kempstone mouse
* fixed dma clear screen
* added function callback for application while is switching text/gfx mode (alt+f1/f2)
* added function setresolution for gfx mode
* fixed wrong parse external commands with length 8 bytes

## 0.14 (2012-10-31)

 * added support tabulating (\t) 
 * remove command about
 * added crash screen if system has wrong configuration
 * added ignore case for commands(embedded)
 * fixed exec. second run is't work again.
 * added information to CLi api header
 * restructure bin hierarchy
 * added command loadfont
 * fixed bugs in resource load
 * added status for loadResource function (ok/error)
 * added support delete(#0c - one step back/left) for print function
 * added progress wait indicator
 * fixed restore current path of params for call from /bin
 * fixed /bin list (adding only files with empty extention (executable))

## 0.12 (2012-10-22)

 * change gfxcls to clear with help dma
 * fixed help list exernal cmd if "/bin" is't exist
 * added command gfxloadpal - load independent palette for graphics mode
 * added loadResoure function for application
 * added GLi (Graphics Library interface)
 * added demo "Boing" for GLi & test system

## 0.10 (2012-10-19)

 * added switch between first(txt) & second(gfx) screen with help combination alt+f1/alt+f2
 * added command cd if path not found
 * fixed file search buffer
 * try exec file if it start as ./filename
 * added exec files from /bin directory
 * added command rehash (rescan /bin directory)
 * added command gfxcls (clear graphics (second) screen)
 * added command screen switch between first & second screen (for scripts)
 * added command gfxborder, set border's color of second(gfx) screen 
 * added command loadpal, load palette from file to current

## 0.08 (2012-10-14)

 * source code tabulating correct to standart 8 pos.
 * fixed scroll limit
 * fixed echo command for correct parse "
 * fixed cd & path ..
 * added command exec (execute application)

## 0.06 (2012-10-09)

* full code refactoring
* added scroll for output (tnx 4 budder)

## 0.05 (2012-10-02)

* simple backup XD
* no work code

## 0.04 (2012-09-29)

* added commands: cd with full path, pwd
* Some bugfixes with ls & cd

## 0.03 (2012-09-28)

* added commands: sh, help
* Some bugfixes with empty string
* Code refactoring
* Independent case for entered names of files or directories

## 0.02 (2012-09-26)

* added commands: ls(dir), cd

## 0.01 (2012-09-26)

* First commit