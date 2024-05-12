Func _BDSStop($restart=False)

   Local $function_name = "Stop Server"
   _log($function_name & " Function Started", $function_name, False, True)

   ; Send busy signal
   _BDSBusy(True)
   Sleep(250)

   ; Then Stop
   If $restart = False Then
	  _BDSServerChat("The server is shutting down")
   Else
	  _BDSServerChat("The server is restarting")
   EndIf

   ; Make Backup Before Stopping [MOJANG FIX]
   ; ### 6/2/20 ADDED NEW SAVE / BACKUP SYSTEM
   ; Removed_BDSBackup() as this doesn't really work while the bds.exe is still running
   ; _BDSBackup()
   ; Instead add _BDSSave(False) just to make a quick save of the server (without a backup)
   _BDSSave(False)
   ; Now we need to actually shut the BDS.exe when restarting, make a proper backup and then restart
   ; ### 6/2/20 ADDED NEW SAVE SYSTEM

   ; 7/2/20 ### New Server Command System
   ; Local $input = StdinWrite($PID, "stop" & @LF)
   _BDSStdIn("stop" & @LF)

   sleep(1000)
   Local $result
   Local $keyword = "Quit correctly"
   Local $keylen = StringLen($keyword)
   Local $pos
   Local $response
   Local $stop_timer = TimerInit()

   _log("Wating for Stop Response", $function_name, False, True)
   While 1

	  sleep(100)

	  $response = _BDSProcessOutput(True)  ; True = Quick
	  _log($response, $function_name, False, True)

	  ;    Find data based on keyword search
	  $pos = StringInStr($response, $keyword, 0, -1)

	  ;    Returns 0 if key not found
	  If $pos > 0 Then

		 $result = "Server Stopped Correctly"
		 _log("Server Shutdown Correctly", $function_name, False, True)
		 ExitLoop

	  EndIf
	  If TimerDiff($stop_timer) > 5000 Then
		 $result = "Error Stopping Server - Force Closing"
		 _log("Server failed to stop - Force Closing", $function_name, True)
		 ExitLoop
	  EndIf

	  _log("Stop Response not found. Waiting before retry", $function_name, False, True)


   WEnd

   WinClose($window_title)
   $iPID = ProcessExists($server_file)		; Just incase process stays open
   ProcessClose($iPID)
   FileDelete($command_file)
   FileDelete($member_file)
   FileDelete($working_file)

   _BDSResponse($result)


   If $restart = False Then
	  ; Get last response before closing
	  $response = _BDSProcessOutput()

	  ; ### 6/2/20 ADDED NEW SAVE / BACKUP SYSTEM
	  ; Create full backup while serverfile is not running before Exit
	  _FullBackup()
	  sleep(1000)
	  _BDSExit()
   EndIf

   ; Remove busy signal
   _BDSBusy(False)

EndFunc


