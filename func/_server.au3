Func _serverCheckOnline()

   Local $function_name = "Server Check Status"
   ;_log($function_name & " Function Started", $function_name)
   Global $server_status = True
   If Not WinExists($window_title) Then
	  ;_log("Server Window Not Found", $function_name)
	  Global $server_status = False
   EndIf
   Return $server_status
EndFunc

Func _serverCheckError()

   Local $function_name = "Server Check Error"
   ;_log($function_name & " Function Started", $function_name)
   Global $server_error = False
   If FileExists($error_file) Then
	  Global $server_error = FileRead($error_file)
   EndIf
   Return $server_error

EndFunc

Func _serverCheckWorking()

   Local $function_name = "Server Check Working"
   ;_log($function_name & " Function Started", $function_name)
   Global $server_working = False
   If FileExists($working_file) Then
	  Global $server_working = True
   EndIf
   Return $server_working

EndFunc

Func _serverGetConsoleLog()

   ; The most recent (created) file will be the active console file
   Local $function_name = "Server Get Console Log"
   ;_log($function_name & " Function Started", $function_name)

   Local $result
   Local $files = _FileListToArray($session_dir, "bds-*", $FLTA_FILES, True)
   If Not IsArray($files) Then
	  Return False
   EndIf
   Local $num_files = $files[0]

   If $num_files < 1 Then
	  ;_log("No console logs found", $function_name, True)

	  $result = False
   ElseIf $num_files < 2 Then
	  ;_log("Only one console log found: " & $files[1], $function_name)
	  $result = $files[1]
   Else
	  ;_log("Multiple Console Logs Found", $function_name)
	  Local $latest = 0
	  Local $file
	  For $i = 1 To $num_files

		 Local $file_time = FileGetTime($files[$i], 1, 1)
		 If $file_time > $latest Then
			$latest = $file_time
			$file = $files[$i]
		 EndIf

	  Next
	  _log("Most Recent File: " & $file, $function_name)
	  $result = $file
   EndIf

   Global $console_log = $result
   Return $console_log

EndFunc

Func _serverGetFirstConsoleLog()

   Local $function_name = "Server Get First Console Log"
   ;_log($function_name & " Function Started", $function_name)

   If StringLen($console_log) < 1 Then
	  Return False
   EndIf
   ; Get timestamp from current console Log
   Local $file_name = StringRegExpReplace($console_log, "\.[^.]*$", "")
   $file_name = StringTrimRight($file_name, 3)
   $file_name &= "[1].txt"

   If FileExists($file_name) Then
	  Return $file_name
   EndIf
   Return $console_log

EndFunc

Func _serverGetTitle($PID)

 Local $WinList = WinList()

 For $i = 1 To $WinList[0][0]
	 If WinGetProcess($WinList[$i][1], "") = $PID And $WinList[$i][0] <> "" Then
		 Return $WinList[$i][0]; --> name of title
	 EndIf
  Next

EndFunc

Func _serverGetStartTime()

   Local $function_name = "Get Server Start Time"
   _log($function_name & " Function Started", $function_name)
   If StringLen($console_log) < 1 Then
	  Return False
   EndIf

   Local $first_log = _serverGetFirstConsoleLog()
   Local $file_time = FileGetTime($first_log, $FT_CREATED, 0)
   Local $start_time = $file_time[0] & "/" & $file_time[1] & "/" & $file_time[2] & " " & $file_time[3] & ":" & $file_time[4] & ":" & $file_time[5]

   Return $start_time

EndFunc

Func _serverResponseFileCheck()

   Local $function_name = "Server Response"
   _log($function_name & " Function Started", $function_name)

   If FileExists($response_file) Then
	  Local $response = FileRead($response_file)
	  _log($response, $function_name, False, True)
	  FileDelete($response_file)
   EndIf

EndFunc

Func _serverBackupFileCheck()

   Local $function_name = "Server Backup Response"
   _log($function_name & " Function Started", $function_name)

   If FileExists($backedup_file) Then
	  Local $file_time = FileGetTime($backedup_file, $FT_CREATED, 0)
	  Local $backup_time = $file_time[0] & "/" & $file_time[1] & "/" & $file_time[2] & " " & $file_time[3] & ":" & $file_time[4] & ":" & $file_time[5]
	  _log("Backup file found. Last backup: " & $backup_time, $function_name, False, True)
	  _guiSetLastBackupTime($backup_time)
	  FileDelete($backedup_file)
   EndIf

EndFunc

; ### 6/2/20 New Save / Restart System
Func _serverRestartFileCheck()

   Local $function_name = "Server Restart Response"
   _log($function_name & " Function Started", $function_name)

   ; If a restart file exists, the server is currently undergoing a restart process and may be saving.
   ; We do NOT want keep alive / auto save kicking in during this time

   If FileExists($restart_file) Then
	  $server_working = True
	  _log("Server restart file exists.", $function_name)
   EndIf

EndFunc

Func _serverSaveFileCheck()

   Local $function_name = "Server Save Check"
   _log($function_name & " Function Started", $function_name)

   If FileExists($saved_file) Then
	  Local $file_time = FileGetTime($saved_file, $FT_CREATED, 0)
	  Local $save_time = $file_time[0] & "/" & $file_time[1] & "/" & $file_time[2] & " " & $file_time[3] & ":" & $file_time[4] & ":" & $file_time[5]
	  _log("Saved file found. Last save: " & $save_time, $function_name, False, True)
	  _guiSetLastSaveTime($save_time)
	  FileDelete($saved_file)
   EndIf

EndFunc

Func _serverSendCommand($command)

   $oFile = FileOpen($command_file, 2)
   FileWrite($oFile, $command)
   FileClose($oFile)

EndFunc