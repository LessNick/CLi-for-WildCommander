;---------------------------------------
; CLi System messages
;---------------------------------------
welcomeMsg	db		16,6,"Command Line Interface for WildCommander v0.06",#0d
			db		16,7,"2012 (C) Breeze\\\\Fishbone Crew",#0d,#0d
			db		16,13,"Type ",20," help ",20," to display the full list of commands.",#0d,#0d
			db		16,16
			db		#00

readyMsg	db		"1>"
			db		#00

errorMsg	db		16,10,"Error! Unknown command.",#0d
			db		16,16
			db		#00

errorParMsg	db		16,10,"Error! Wrong parameters.",#0d
			db		16,16
			db		#00

anyKeyMsg	db		16,7,"Press any key to continue.",#0d
			db		16,16
			db		#00

restoreMsg	db		16,16,17,16
			db		#0d,#00

wrongDevMsg	db		16,10,"Error! Wrong device ID.",#0d
			db		16,16
			db		#00

dirNotFoundMsg
			db		16,10,"Error! Directory not found.",#0d
			db		16,16
			db		#00

fileNotFoundMsg
			db		16,10,"Error! File not found.",#0d
			db		16,16
			db		#00

cantReadDirMsg
			db		16,10,"Error! Can't read directory.",#0d
			db		16,16
			db		#00

helpMsg		db		16,13,"Available commands(embedded):",16,16
			db		16,16
			db		#0d,#00

wrongPathMsg
			db		16,10,"Error! Wrong path.",#0d
			db		16,16
			db		#00
