; Use AdlibRegister for AutoSave / AutoRestart

If TimerDiff($aTimer) > 1000 Then 		; Do something every 1 second

   _guiUpdateServerStatus()
   _guiUpdateWorkingStatus()
   _guiUpdateConsole()
   If $server_status = True Then
	  _serverGetConsoleLog() 		; Find the currently active console log
	  If $auto_save = "True" Then
		 _autoSave()
	  EndIf
	  _autoRestart()
   EndIf
   If $server_error = "CRASH" Then
	  sleep(2000)
	  _runScript("bds")
	  _log("Crash Restart Triggered", "GUI SYSTEM", False, True)
   EndIf

   $aTimer = TimerInit()
EndIf


If TimerDiff($bTimer) > 10000 Then 		; Do something every 10 seconds

   _actionKeepAlive()		; If server isn't running then start it - Careful this isn't triggered during rollback / restart actions
   $bTimer = TimerInit()
EndIf


If TimerDiff($cTimer) > 300000 Then 		; Do something every 5 minutes

   ; House keeping
   _houseKeeping()
   ;_runScript("google_dns") ; Not for public Use
   $cTimer = TimerInit()
EndIf


; Do something every 1/4 second
_serverCheckOnline()
_serverCheckError()
_serverCheckWorking()
_serverResponseFileCheck()
_serverBackupFileCheck()
_serverRestartFileCheck()
_serverSaveFileCheck()
_guiUpdateMembers()

Sleep(250)