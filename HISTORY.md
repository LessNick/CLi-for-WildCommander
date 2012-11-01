## 0.14 (2012-10-31)

 * add support tabulating (\t) 
 * remove command about
 * add crash screen if system has wrong configuration
 * add ignore case for commands(embedded)
 * fix exec. second run is't work again.
 * add information to CLi api header

## 0.12 (2012-10-22)

 * change gfxcls to clear with help dma
 * fix help list exernal cmd if "/bin" is't exist
 * add command gfxloadpal - load independent palette for graphics mode
 * add loadResoure function for application
 * add GLi (Graphics Library interface)
 * add demo "Boing" for GLi & test system

## 0.10 (2012-10-19)

 * add switch between first(txt) & second(gfx) screen with help combination alt+f1/alt+f2
 * cd fix if path not found
 * file search buffer fix
 * try exec file if it start as ./filename
 * add exec files from /bin directory
 * add command rehash (rescan /bin directory)
 * add command gfxcls (clear graphics (second) screen)
 * add command screen switch between first & second screen (for scripts)
 * add command gfxborder, set border's color of second(gfx) screen 
 * add command loadpal, load palette from file to current

## 0.08 (2012-10-14)

 * source code tabulating correct to standart 8 pos.
 * fix scroll limit
 * fix echo command for correct parse "
 * fix cd & path ..
 * add command exec (execute application)

## 0.06 (2012-10-09)

* Full code refactoring
* Added scroll for output (tnx 4 budder)

## 0.05 (2012-10-02)

* simple backup XD
* no work code

## 0.04 (2012-09-29)

* Added commands: cd with full path, pwd
* Some bugfixes with ls & cd

## 0.03 (2012-09-28)

* Added commands: sh, help
* Some bugfixes with empty string
* Code refactoring
* Independent case for entered names of files or directories

## 0.02 (2012-09-26)

* Added commands: ls(dir), cd

## 0.01 (2012-09-26)

* First commit