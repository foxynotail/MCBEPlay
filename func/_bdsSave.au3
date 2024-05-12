Func _BDSSave($auto_backup=False)

   Local $function_name = "Save Server"
   _log($function_name & " Function Started", $function_name, False, True)
   _BDSBusy(True)
   $input = StdinWrite($PID, "save hold" & @LF)
   Sleep(500)
   _BDSProcessOutput(True)
   _BDSStdIn("save query" & @LF)
   Sleep(500)
   Local $try = 1
   Local $success = False
   While 1
	  $response = _BDSProcessOutput(True)
	  If StringInStr($response, "level.dat", 0) > 0 Then
		 $success = True
		 ExitLoop
	  EndIf
	  If $try >= 10 Then
		 ExitLoop
	  EndIf
	  $try = $try + 1
	  Sleep(1000)
   WEnd

   ; If Backup True then make a backup during save process
   If $success = True Then

	  _log("Save Completed Succesfully", $function_name, False, True)
	  If $auto_backup = True Then
		 _log("Starting backup", $function_name, False, True)
		 _BDSBackup($response)
	  EndIf

	  _BDSStdIn("save resume" & @LF)
	  Sleep(500)
	  _BDSProcessOutput(True)
	  _BDSServerChat("Saved")

   Else

	  _log("Save Completed with Errors", $function_name, False, True)
	  _BDSServerChat("Error Saving")

   EndIf

   ; Create saved file
   If FileExists($saved_file) Then
	  FileDelete($saved_file)
   EndIf
   _log("Creating Saved File", $function_name, False, True)
   $oFile = FileOpen($saved_file, 2)
   FileClose($oFile)

   _BDSBusy(False)

#CS
   ; Send busy signal
   _log("Setting BDS Busy = True", $function_name, False, True)
   _BDSBusy(True)

   _log("Deleting Error File", $function_name, False, True)
   FileDelete($error_file)
   ; Run save resume first to make sure previous save attempt isn't causing issues
   ; 7/2/20 ### New Server Command System
   ; $input = StdinWrite($PID, "save resume" & @LF)
   ;_BDSStdIn("save resume" & @LF) ; Removing this as it's unnecessary 7/2/20
   ;_log("Sending save resume to clear previous save attempt (if any)", $function_name)

   ;    Find data based on keyword search
   Local $keyword = "level.dat"
   Local $keylen = StringLen($keyword)
   Local $pos
   Local $result
   Local $response
   Local $response_found = False
   Local $response_timer = TimerInit()
   Local $error_found = False

   ; 6/2/20 Turning off due to spam
   ;_BDSServerChat("Server Saving")

   ; Run save hold
   _log("Setting Save Timer", $function_name, False, True)
   Local $save_timer = TimerInit()

   ; 7/2/20 ### New Server Command System
   ; $input = StdinWrite($PID, "save hold" & @LF)
   _log("Sending Save Hold Command", $function_name, False, True)
   _BDSStdIn("save hold" & @LF)
   _log("Sleeping 2s", $function_name, False, True)
   Sleep(2000)

   _BDSProcessOutput(True)
   _log("Running Save Query Loop", $function_name)

   While 1

	  ; 7/2/20 ### New Server Command System
	  ; $input = StdinWrite($PID, "save query" & @LF)
	  _log("Sending Save Query Command", $function_name, False, True)
	  _BDSStdIn("save query" & @LF)

	  _log("Sleeping for 2s", $function_name, False, True)
	  Sleep(2000)

	  ; 7/2/20 ### New Server Command System
	  _log("Processing output", $function_name, False, True)
	  $response = _BDSProcessOutput(True)
	  $pos = StringInStr($response, $keyword, 2)

	  ;    Returns 0 if key not found
	  If $pos > 0 Then

		 $response_found = True
		 $result = "Save Query Response Found"
		 _log("Save Response Found", $function_name)
		 ExitLoop

	  EndIf

	  If TimerDiff($response_timer) > 5000 Then
		 $result = "Save Query Response Not Found"
		 _log("Server failed to save", $function_name, True)
		 ExitLoop
	  EndIf

   WEnd
   _log("Sending response result", $function_name, False, True)
   _BDSResponse($result)

   If $response_found = False Then
	  ; Run save resume again to close save call

	  _log("Sending save resume", $function_name)

	  ; 7/2/20 ### New Server Command System
	  ; $input = StdinWrite($PID, "save resume" & @LF)
	  _BDSStdIn("save resume" & @LF)
	  _log("Sleeping 2s", $function_name, False, True)
	  Sleep(2000)
	  _BDSProcessOutput(True)
	  $result = "Save process failed. No Response Found."
	  _log($result, $function_name, True)

   Else

	  ; If response found then continue

	  ; If Backup True then make a backup during save process
	  If $auto_backup = True Then

		 _log("Starting backup", $function_name, False, True)
		 _BDSBackup($response, $pos)
	  EndIf

	  ; Send busy signal
	  _log("Setting BDS Busy = True", $function_name, False, True)
	  _BDSBusy(True)


	  _log("Calculating Save Time", $function_name, False, True)
	  $save_time = TimerDiff($save_timer)
	  $save_time = Floor($save_time/1000)

	  If $error_found Then

		 $result = "Save process finished with errors [" & $save_time & " seconds]"
		 _log($result, $function_name, True)
		 $dst_dir = "FAILED_" & $src_dir
		 DirMove($src_dir, $dst_dir)
		 _BDSServerChat("Error with Save")
	  Else
		 $result = "Save process finished succesfully [" & $save_time & " seconds]"
		 _log($result, $function_name, False, True)

		 ; 6/2/20 Only show time if more than 10 seconds and a backup has not been made because of chat spam
		 If $auto_backup = False AND $save_time > 10 Then
			_BDSServerChat("Save Complete [" & $save_time & " seconds]")
		 ElseIf $auto_backup = False Then
			_BDSServerChat("Saved")
		 EndIf

	  EndIf

	  ; Create saved file
	  If FileExists($saved_file) Then
		 log("Deleting Saved File", $function_name, False, True)
		 FileDelete($saved_file)
	  EndIf
	  _log("Creating Saved File", $function_name, False, True)
	  $oFile = FileOpen($saved_file, 2)
	  FileClose($oFile)


   EndIf

   _log("Sending Response Result", $function_name, False, True)
   _BDSResponse($result)
   ; Remove busy signal

#CE

   _log("Setting BDS Busy = False", $function_name, False, True)
   _BDSBusy(False)

EndFunc

