;---------------------------------------
; CLi System messages
;---------------------------------------
;                                     ,
;              ,-.       _,---._ __  / \
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

versionMsg	db	16,6,"Command Line Interface for WildCommander v0.12",#0d
		db	16,7,"2012 (C) Breeze\\\\Fishbone Crew",#0d
		db	#00

typeHelpMsg	db	#0d
		db	16,colorInfo,"Type ",20," help ",20," to display the full list of commands.",#0d,#0d
		db	16,16
		db	#00

aboutMsg	db	#0d
		db	16,08,"Source & current version - ",16,13,"http://bit.ly/Cli4WC",#0d,#0d
		db	16,02,"Special thanks:",#0d
		db	16,08," - ",16,15,"Robat(Wizard^DT)",16,08," for the screensaver example code",#0d
		db	16,08," - ",16,15,"Budder^MGN",16,08," for the help with code",#0d
		db	16,08," - ",16,15,"TS-Labs",16,08," for the firmware & emulator",#0d
		db	16,08," - ",16,15,"CHRV & NedoPC",16,08," for the PentEvo hardware",#0d
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

noBinDirMsg	db	16,colorWarning,"Warning! \"/bin\" directory not found.",#0d
		db	16,16
		db	#00	

clearingMsg	db	16,colorInfo,"Clearing...",#0d
		db	16,16
		db	#00