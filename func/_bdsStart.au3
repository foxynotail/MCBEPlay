Func _BDSStart()

   Local $function_name = "Start Server"
   _log($function_name & " Function Started", $function_name, False, True)

   ; Get timestamp again for new $bds_file
   Global $timestamp = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC ; YYYYMMDDHHMMSS
   Global $bds_file = $session_dir & "\bds-" & $timestamp & "[1].txt"

   ; Delete error file if exists
   If FileExists($error_file) Then
	  FileDelete($error_file)
   EndIf

   ; Delete restart file if exists
   If FileExists($restart_file) Then
	  FileDelete($restart_file)
   EndIf

   ; Do a quick check to make sure the bedrock_server.exe process is not running. Somehow this can end up running on it's own
   If ProcessExists($server_file) Then
	  _log("A server process is already running", $function_name, True)
	  $iPID = ProcessExists($server_file)		; Just incase process stays open
	  ProcessClose($iPID)
	  Sleep(300)
	  ;MsgBox(48, "Alert", "A server process is already running")
	  Exit
   EndIf

   ; Send busy signal
   _BDSBusy(True)

   Local $attempt = 1
   Local $result

   While 1

	  _log("Attempting Start Process [" & $attempt & "/3]", $function_name, False, True)
	  Local $result = _BDSStartProcess()

	  If $result <> True Then
		 _log("Start process failed", $function_name, True)
		 If $attempt < 3 Then ; If first and second try doesn't work then kill processes and try again
			WinClose($window_title)
			WinClose($server_file)
			$iPID = ProcessExists($server_file)		; Just incase process stays open
			ProcessClose($iPID)
			$attempt = $attempt + 1
			Sleep(300)
		 Else

			If $rollback = "true" Then ; If 3 tries fail then rollback
			   _log("Auto rollback system active. Rolling back", $function_name, False, True)
			   If _BDSRollback() = True Then
				  _BDSSave()
			   Else
				  _log("Auto Rollback system failed. Closing Server", $function_name, True)
				  _BDSResponse("Auto rollback system failed Closing server")
				  _BDSExit()
			   EndIf
			Else ; If 3 tries fail and rollback system off then exit
			   _log("Auto rollback system inactive. Closing Server", $function_name, False, True)
			   _BDSResponse("Auto rollback system inactive. Closing server")
			   _BDSExit()
			EndIf
		 EndIf
	  EndIf

	  _log("Start process succesfull", $function_name)
	  ExitLoop ; If result = True then exit loop

   WEnd
   ; Remove busy signal
   _BDSBusy(False)

EndFunc

Func _BDSStartProcess()

   Local $function_name = "Start Server Process"

   ; All we're going to do is start the server and loop a read / write command
   Local $cmd = '"' & $server
   ;Global $PID = Run(@ComSpec & " /K " & $server, $server_dir, @SW_SHOW, $STDIN_CHILD + $STDOUT_CHILD) ; Testing
   Global $PID = Run(@ComSpec & " /K " & $server, $server_dir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD) ; Release
   Sleep(1000) ; !!! sleep !! or process is NOT in the list yet !!

   $title = _serverGetTitle($PID)
   WinSetTitle($title, "", $window_title)
   $hWnd = WinGetHandle($window_title)

   Local $keyword = "Server started."
   Local $keylen = StringLen($keyword)
   Local $pos
   Local $response
   Local $start_timer = TimerInit()
   Local $error_found = False

   _log("Wating for Start Response", $function_name, False, True)
   While 1

	  $response = _BDSProcessOutput()

	  sleep(250)

	  ;    Find data based on keyword search
	  $pos = StringInStr($response, $keyword, 0, -1)

	  If TimerDiff($start_timer) > 60000 Then
		 $error_found = True
		 $result = "Server failed to start"
		 _log("Server failed to start", $function_name, True)
		 ExitLoop
	  EndIf
	  ;    Returns 0 if key not found
	  If $pos > 0 Then
		 $result = "Server started succesfully"
		 _log("Server started succesfully", $function_name, False, True)
		 ExitLoop
	  EndIf

   WEnd

   _BDSResponse($result)

   If $error_found = True Then
	  Return False
   EndIf

   ; Create saved file (Because we want the last save time to be the time the server started last)
   ; The server will / should have saved when it was shut down before
   If FileExists($saved_file) Then
	  FileDelete($saved_file)
   EndIf
   $oFile = FileOpen($saved_file, 2)
   FileClose($oFile)

   Return True
EndFunc


