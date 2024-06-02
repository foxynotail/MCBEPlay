Func _BDSExit()
   Local $function_name = "BDS Exit"
   _log("Exit Called", $function_name)
   WinClose($window_title)
   $iPID = ProcessExists($server_file)		; Just incase process stays open
   ProcessClose($iPID)
   FileDelete($command_file)
   FileDelete($member_file)
   FileDelete($working_file)
   _BDSBusy(False)
   Exit
EndFunc

; :- 7/2/20 ### Adding new system to send & receive data from server to try figure out why crashing during a save

Func _BDSStdIn($command)

   Local $function_name = "StdinWrite"

   ;_log("Sending Command to Server: " & $command, $function_name, False, False)

   ; Add delay as test to see if bedrock_server is crashing on save due to too many requests
   ;sleep(250)
   StdinWrite($PID, $command)

   If @error Then
	  _log("Error Sending Command to Server: " & $command, $function_name, True)
	  _BDSErrorFile("UNRESPONSIVE")
   EndIf

EndFunc

Func _BDSStdOut()

   Local $function_name = "StdoutRead"

   ;_log("Reading Server Output", $function_name, False, False)
   Local $output = StdoutRead($PID) ; Store the output of StdoutRead to a variable.

   If @error Then ; Exit the loop if the process closes or StdoutRead returns an error.
	  _log("Error Reading Output from Server", $function_name, True)
	  _BDSErrorFile("UNRESPONSIVE")
   EndIf

   Return $output

EndFunc

; -: 7/2/20 ###

Func _BDSCheckRunning()
   If Not WinExists($window_title) Then
	  _BDSExit()
   EndIf
EndFunc

Func _BDSCheckResponse()

   Local $function_name = "Check Response"

   Local $responsive = True
   Local $reponse_command = @LF

   Local $try = 1
   Local $output

   ; 7/2/20 ### New Server Command System
   ; Local $response = StdinWrite($PID, $reponse_command)
   _BDSStdIn($reponse_command)
   While 1
	  If $try > 1 Then
		 _log("Attempting to get response from server. [" & $try & "/20]", $function_name, False, True)
	  EndIf
	  Sleep(300)
	  $output = _BDSStdOut()
	  If StringLen($output) > 0 Then
		If FileExists($error_file) Then
			FileDelete($error_file) ;Remove Error Banner if still alive
		EndIf
	    ExitLoop
	  EndIf
	  If $try > 20 Then
		 $responsive = False
		 ExitLoop
	  EndIf
	  $try = $try + 1
   WEnd

   If $responsive = False Then
	  _log("No Response from BDS", $function_name, True)
	  _BDSErrorFile("UNRESPONSIVE")
	  _BDSExit()
   EndIf

EndFunc

Func _BDSProcessInput()
   Local $function_name = "Process Input"
   If FileExists($command_file) Then
	  _log("Process Input Function Started", $function_name, False, False)
	  Local $command = FileRead($command_file)
	  FileDelete($command_file)
	  If StringLen($command)>0 Then
		 _BDSBusy(True)
		 Switch $command
		 Case "stop"
			_BDSStop(False)  ; True = Restart, False = Shutdown
		 Case "save"
			_BDSSave(False)
		 Case "backup"
			_BDSSave(True)  ; True = Make Backup during Save, False = Just Save
		 Case "restart"
			_BDSRestart()
		 Case "rollback"
			_BDSRollback()
		 Case Else
			; 7/2/20 ### New Server Command System
			; Local $input = StdinWrite($PID, $command & @LF)
			_BDSStdIn($command & @LF)
		 EndSwitch
		 _BDSBusy(False)
	  EndIf
   EndIf

EndFunc
; 7/2/20 - Turned off returns - Why is BDS crashing after save, even when not backing up?
; Something weird happening here

Func _BDSProcessOutput($quick=False)
   Local $function_name = "Process Output"

   ; 7/2/20 ### New Server Command System
	; Local $output = StdoutRead($PID)
   Local $output = _BDSStdOut()

   If StringLen($output) > 0 Then
	  ; If data more than one line then split lines and parse each
	  Local $lines = StringSplit($output, @LF, 2)
	  If Not IsArray($lines) Then
		 Dim $lines[1] = $output
	  EndIf
	  Local $line
	  For $i = 0 To UBound($lines)-1
		 $line = $lines[$i]
		 If StringLen($line) > 0 Then
			_BDSWriteToFile($line)
			If $quick = False Then
			   ; If contains member info then add to member Log
			   _BDSFindMember($line)
			   ; Check if errors
			   _BDSCheckError($line)
			   ; Check if crash
			   _BDSCheckCrash($line)
			EndIf
		 EndIf
	  Next
   EndIf
   Return $output
EndFunc

Func _BDSWriteToFile($data)
   Local $function_name = "Write To File"
   ; Write data to console file
   Local $oFile = FileOpen($bds_file, 1)
   FileWrite($oFile, $data)
   FileClose($oFile)
   ; Split Console File if too big
   Local $file_size = FileGetSize($bds_file)
   If $file_size > 500000 Then ; 0.5MB
   ;If $file_size > 500 Then ; DEBUGGING
	  ; How many files with this timestamp?
	  Local $num_files = 1
	  Local $bds_part = StringRegExpReplace($bds_file, "\.[^.]*$", "") ; Remove .txt extension
	  $bds_part = StringTrimRight($bds_part, 3) ; Remove [1]
	  Local $files = _FileListToArray($session_dir, $bds_part & "*", $FLTA_FILES)
	  If IsArray($files) Then
		 Local $num_files = $files[0]
	  EndIf
	  Global $bds_file = $session_dir & "\" & $bds_part & "[" & $num_files+1 & "].txt"
	  _log("Started Next Log File: " & $bds_file, $function_name)
   EndIf
EndFunc

Func _BDSFindMember($data)
   Local $function_name = "Find Member"
   ;[2019-11-17 10:42:08 INFO] Player connected: foxynotail, xuid: 2535421815690915
   ;[2019-11-17 10:42:08 INFO] Player discconnected: foxynotail, xuid: 2535421815690915
   Local $keyword = "Player "
   Local $keylen = StringLen($keyword)
   Local $pos

   $pos = StringInStr($data, $keyword, 2)
   If $pos > 1 Then
	  Local $string = StringRight($data, StringLen($data)-($pos+$keylen)+1)
	  Local $split = StringSplit($string, ":")
	  ; [0] = Count, [1] = connected/disconnected, [2] = player, xuid, [3] = xuid
	  Local $action = StringStripWS($split[1], 8)
	  Local $player_split = StringSplit($split[2], ",")
	  Local $player = StringStripWS($player_split[1], 8)
	  Local $xuid = StringStripWS($split[2], 8)

	  ; If disconnecting remove members from temp member file
	  ; If connecting add member to temp member file
	  ; Check if member exists in temporary members file
	  Local $members
	  _FileReadToArray($member_file, $members)
	  If Not IsArray($members) Then
		 Dim $members[1]
	  EndIf
	  ; Is player in array?
	  Local $search = _ArraySearch($members, $player)
	  If $search > 0 AND $action = "disconnected" Then
		 _log("Removing member from temp file: " & $player, $function_name)
		 _ArrayDelete($members,$search)
	  ElseIf $search < 0 AND $action = "connected" Then
		 _log("Adding member to temp file: " & $player, $function_name)
		 _ArrayAdd($members,$player)
	  EndIf

	  ; Add to member log
	  Local $member_string = ""
	  For $i = 1 To UBound($members)-1
		 $member_string &= $members[$i] & @CRLF
	  Next
	  Local $oFile = FileOpen($member_file, 2)
	  FileWrite($oFile, $member_string)
	  FileClose($oFile)

	  $string = _NowCalc() & " : " & $player & " " & $action & " [xuid: " & $xuid & "]" & @CRLF
	  _log("Adding Member Data to Log: " & $string, $function_name)
	  Local $oFile = FileOpen($member_log, 1)
	  FileWrite($oFile, $string)
	  FileClose($oFile)
	  _log($player & " " & $action, $function_name, False, True)
	  _BDSResponse($player & " " & $action & " [xuid: " & $xuid & "]")

	  ; If member disconnected then need to trigger save if save hasn't taken place in a while i.e Player logs out before AutoSave and AutoSave Pauses
	  If $action = "disconnected" AND UBound($members)-1 = 0 Then ; Only trigger if 0 players left in game

		 $last_save_time = _BDSTrueSaveTime()
		 $mins_since_save = _guiMinsSince($last_save_time)

		 If $mins_since_save > $min_save_time Then

			_log("Saving because player disconnected", $function_name, False, True)
			_BDSResponse("Saving because player disconnected")
			_BDSSave(False)

		 EndIf
	  EndIf


   EndIf
EndFunc

Func _BDSCheckError($data)
   Local $function_name = "Check Error"
   Local $keyword = "ERROR"
   Local $keyword2 = "minecraft:trial_chambers/chamber/end"
   Local $keylen = StringLen($keyword)
   Local $pos
   Local $pos2
   $pos = StringInStr($data, $keyword, 2)
   $pos2 = StringInStr($data, $keyword2, 2)
   If $pos > 1 And $pos2 = 0 Then ;Suppress logging jigsaw errors
	  _log("Error Found in BDS Output: [" & $data & "]", $function_name, True)
	   _BDSErrorFile("ERROR")
	  ; _BDSExit() ;No need to reboot on the Jigsaw error
   EndIf
EndFunc


Func _BDSCheckCrash($data)

   ; Can't get this to work at this end as BDS closing before we can get output
   ; But only if we actually detect the crash! :SHRUG:
   ; Now checking output from GUI for crash logs

   Local $function_name = "Check Crash"
   ;_log("Crash Check", $function_name, False)
   ; Crashreporter comes after start of crash Log
   ; First line is [20191113 19:34:36 INFO] Package: .....
   ;Local $keyword = "CrashReporter"
   Local $keyword = $server_dir
   Local $keylen = StringLen($keyword)
   Local $pos
   $pos = StringInStr($data, $keyword, 2)
   If $pos > 0 Then
	  ; CrashReport Found
	  _BDSBusy(True)
	  _BDSErrorFile("CRASH")
	  _log("Crash Found in BDS Output: [" & $data & "]", $function_name, True)
	  _BDSCrashReport()
	  _BDSBusy(False)
	  _BDSExit()
   EndIf
EndFunc

Func _BDSCrashReport()

   ; This doesn't work as the system doesn't seem to get time to run it before it closes
   Local $function_name = "Crash Report"
   ; Find start of report
   Local $pos = 0
   Local $keyword = "Package"
   Local $keylen = StringLen($keyword)
   Local $data = FileRead($bds_file)
   Local $pos = StringInStr($data, $keyword, 0, -1) - 27
   Local $crash_report = StringMid($data, $pos)
   Local $timestamp = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC
   Local $crash_file = $log_dir & "\crash_report-" & $timestamp & ".txt"
   $oFile = FileOpen($crash_file, 2)
   FileWrite($oFile, $crash_report)
   FileClose($oFile)
EndFunc

Func _BDSErrorFile($string)
   Local $function_name = "Error File"
   Local $oFile = FileOpen($error_file, 2)
   FileWrite($oFile, $string)
   FileClose($oFile)
EndFunc

Func _BDSServerChat($string)
   Local $function_name = "Server Chat"

   ; 7/2/20 ### New Server Command System
   ; $input = StdinWrite($PID, "say " & $string & @LF)
   _log("Sending Chat to Game: " & $string, $function_name, False, True)
   _BDSStdIn("say " & $string & @LF)

   ;If @error > 1 Then
	  ;_log("No Response from BDS", $function_name, True)
	  ;_BDSErrorFile("UNRESPONSIVE")
	  ;_BDSExit()
   ;EndIf
EndFunc

Func _BDSBusy($state)

   Switch $state
   Case True
	  ; Send busy signal
	  $oFile = FileOpen($working_file, 1)
	  FileClose($oFile)
   Case False
	  ; Remove busy signal
	  FileDelete($working_file)
   EndSwitch

EndFunc

Func _BDSResponse($string)

   Local $oFile = FileOpen($response_file, 2)
   FileWrite($oFile, $string)
   FileClose($oFile)
   Sleep(300)

EndFunc

Func _BDSTrueSaveTime()

   Local $function_name = "Get Last True Save Time"
   _log($function_name & " Function Started", $function_name)

   Local $saves = _FileListToArrayRec($save_dir, "*|FAILED_;ROLLBACK_", $FLTAR_FOLDERS, 0, 0, 2)

   If Not IsArray($saves) Then
	  Return "2001-01-01 00:00:00" ;Return an old date number so system knows it's been a long time since last save (i.e. no saves found!)
   EndIf
   If $saves[0] < 1 Then
	  ; No data to get from
	  Return "2001-01-01 00:00:00" ;Return an old date so system knows it's been a long time since last save (i.e. no saves found!)
   EndIf

   Local $latest = 0
   Local $latest_save

   For $i = 1 To UBound($saves)-1

	  ; Remove trailing slash from folder names
	  Local $save = $saves[$i]
	  Local $file_time = FileGetTime($save, $FT_CREATED, 1)

	  If $file_time > $latest Then
		 $latest = $file_time
		 $latest_save = $save
	  EndIf
   Next
   Local $file_time = FileGetTime($latest_save, $FT_CREATED, 0)
   Local $save_time = $file_time[0] & "/" & $file_time[1] & "/" & $file_time[2] & " " & $file_time[3] & ":" & $file_time[4] & ":" & $file_time[5]

   Return $save_time

EndFunc
