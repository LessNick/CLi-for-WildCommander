; CLi System messages

welcomeMsg	db		16,6,"Command Line Interface for WildCommander v0.04",#0d
			db		16,7,"2012 (C) Breeze\\Fishbone Crew",#0d,#0d
			db		16,13,"Type ",20," help ",20," to display the full list of commands.",#0d

readyMsg	db		#0d,16,16,"1>"
			db		#00

errorMsg	db		#0d
			db		16,10,"Error! Unknown command.",#0d,#0d
			db		#00

errorParMsg	db		#0d
			db		16,10,"Error! Wrong parameters.",#0d,#0d
			db		#00

anyKeyMsg	db		#0d
			db		16,7,"Press any key to continue.",#0d
endMsg		db		#0d,#00

passedMsg	db		#0d
			db		16,4,"Passed! ;)",#0d,#0d
			db		#00

wrongDevMsg	db		#0d
			db		16,10,"Error! Wrong device ID.",#0d,#0d
			db		#00

dirNotFoundMsg
			db		#0d
			db		16,10,"Error! Directory not found.",#0d,#0d
			db		#00

fileNotFoundMsg
			db		#0d
			db		16,10,"Error! File not found.",#0d,#0d
			db		#00

cantReadDirMsg
			db		#0d
			db		16,10,"Error! Can't read directory.",#0d,#0d
			db		#00

helpMsg		db		#0d,#0d
			db		16,13,"Available commands(embedded):",16,16
			db		#0d,#00

wrongPathMsg
			db		#0d
			db		16,10,"Error! Wrong path.",#0d,#0d
			db		#00
