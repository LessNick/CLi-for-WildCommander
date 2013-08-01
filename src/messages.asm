;---------------------------------------
; CLi System messages
;---------------------------------------
;                                     ,
;              ,.        _,---._ __  / \
;             /  )    .-'       `./ /   \
;            (  (   ,'            `/    /|
;             \  `-"             \'\   / |
;              `.              ,  \ \ /  |
;               /`.          ,'-`----Y   |
;              (            ;        |   '
;              |  ,-.    ,-'         |  /
;              |  | (   |        hjw | /
;              )  |  \  `.___________|/
;              `--'   `--'

versionMsg	db	16,6,"Command Line Interface for WildCommander v0.14b",#0d
		db	16,7,"2012,2013 ",127," Breeze\\\\Fishbone Crew",#0d
		db	#00

typeHelpMsg	db	#0d
		db	16,colorInfo,"Type ",20," help ",20," to display the full list of commands.",#0d,#0d
		db	16,16
		db	#00

readyMsg	db	"1>"
		db	#00

errorMsg	db	16,colorError,"Error! Unknown command.",#0d
		db	16,16
		db	#00

errorParMsg	db	16,colorError,"Error! Wrong parameters.",#0d
		db	16,16
		db	#00

anyKeyMsg	db	16,7,"Press any key to continue.",#0d
		db	16,16
		db	#00

restoreMsg	db	16,16,17,16
		db	#0d,#00

wrongDevMsg	db	16,colorError,"Error! Wrong device ID.",#0d
		db	16,16
		db	#00

dirNotFoundMsg	db	16,colorError,"Error! Directory not found.",#0d
		db	16,16
		db	#00

fileNotFoundMsg	db	16,colorError,"Error! File not found.",#0d
		db	16,16
		db	#00

cantReadDirMsg	db	16,colorError,"Error! Can't read directory.",#0d
		db	16,16
		db	#00

helpMsg		db	16,colorOk,"Available commands(embedded):",16,16
		db	16,16
		db	#0d,#00

helpMsg2	db	#0d,16,colorOk,"Available commands(external):",16,16
		db	16,16
		db	#0d,#00

wrongPathMsg	db	16,colorError,"Error! Wrong path.",#0d
		db	16,16
		db	#00

wrongQuote	db	16,colorError,"Error! Unmatched \".",#0d
		db	16,16
		db	#00

wrongAppMsg	db	16,colorError,"Error! Wrong application file format.",#0d
		db	16,16
		db	#00

wrongPalMsg	db	16,colorError,"Error! Wrong palette file format.",#0d
		db	16,16
		db	#00

wrongFileSizeMsg
		db	16,colorError,"Error! Wrong file size.",#0d
		db	16,16
		db	#00

unknownParamsMsg
		db	16,colorError,"Error! Unknown parameter ",#00

clearingMsg	db	16,colorInfo,"Clearing...",#0d
		db	16,16
		db	#00

initMsg	db	16,colorInfo,"Initializing...",#09
		db	16,16
		db	#00

loadingMsg	db	16,colorInfo,"Loading...",#09,#00

waitStep_01	db	#0c,"|",#00
waitStep_02	db	#0c,"/",#00
waitStep_03	db	#0c,"-",#00
waitStep_04	db	#0c,"\\\\",#00
waitEnd		db	#0c," ",#00

brokenMsg	db	16,15
		ds	6,#0d
		include	"brokenLogo.asm"
		db	#0d
		db	16,6,#09,"       CLi couldn't find the following system directories:",#0d
		db	16,colorWarning,#09,#09,"       bin, fonts, libs, locale or system!",#0d,#0d,#0d
		db	16,2,#09,#09,"     Get fresh copy at http://bit.ly/Cli4WC",#0d,#0d,#0d
		db	16,15,#09,#09,#09,"    Press ",20," any key ",20," to exit.",#0d
		db	#00

statusOkMsg	db	16,16,"[ ",16,colorOk,"  OK  ",16,16," ]",#0d,#00
statusErrorMsg	db	16,16,"[ ",16,colorError,"ERROR!",16,16," ]",#0d,#00
