@echo off
SET PROJECT=cli
sjasmplus.exe --lst=%PROJECT%.lst --inc=src\. src\main.asm
