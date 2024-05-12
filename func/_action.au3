; 6/2/20 New Save / Restart System
Func _actionStartServer()

   Local $function_name = "Start Server Action"
   _log($function_name & " Function Started", $function_name)

   If $server_working = True Then
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   _runScript("bds")

EndFunc

Func _actionStopServer()

   Local $function_name = "Stop Server Action"
   _log($function_name & " Function Started", $function_name)

   If $server_working = True Then
	  _log("Action cancelled as server is busy", $function_name, True)
   EndIf

   Global $server_working = True

   ; Send stop command to server via command text file
   ; Server will then process that and stop the server
   _serverSendCommand("stop")

   Global $server_working = False

EndFunc

Func _actionSaveServer($force = True)

   Local $function_name = "Save Server Action"
   _log($function_name & " Function Started", $function_name)

   If $server_working = True Then
	  _log("Action cancelled as server is busy", $function_name, True)
   EndIf
   Global $server_working = True

   ; Send save command to server via command text file
   ; Server will then process that and save the server

   ; ### :- 6/2/20 New System for Backups
   Local $last_backup = _guiGetLastBackupTime()
   Local $mins_since_backup = _guiMinsSince($last_backup)
   $next_backup = _DateAdd("n", $backup_interval, $last_backup)
   $seconds_to_backup = _DateDiff("s", _NowCalc(), $next_backup)
   If $seconds_to_backup <= 0 Then
	  _log("Running Save with Backup", $function_name, False, True)
	  _serverSendCommand("backup")
   Else
	  _log("Running Save without Backup", $function_name, False, True)
	  _serverSendCommand("save")
   EndIf


   Global $server_working = False

EndFunc

Func _actionBackupServer($force = True)

   Local $function_name = "Backup Server Action"
   _log($function_name & " Function Started", $function_name)

   If $server_working = True Then
	  _log("Action cancelled as server is busy", $function_name, True)
   EndIf
   Global $server_working = True

   ; Send backup command to server via command text file
   ; Server will then process that and backup the server
   _serverSendCommand("backup")

   Global $server_working = False

EndFunc

Func _actionRestartServer()

   Local $function_name = "Restart Server Action"
   _log($function_name & " Function Started", $function_name, False, True)

   If $server_working = True Then
	  _log("Action cancelled as server is busy", $function_name, True)
   EndIf

   Global $server_working = True
   _serverSendCommand("restart")

   Global $server_working = False

EndFunc

Func _actionRollbackServer()

   MsgBox(64, "Info", "The rollback may take a few minutes. " & @CRLF & "Please don't close the GUI until it has finished.")

   Local $function_name = "Rollback Server Action"
   _log($function_name & " Function Started", $function_name)

   If $server_working = True Then
	  _log("Action cancelled as server is busy", $function_name, True)
   EndIf

   ; Can't do this while server is running so can't do via command File
   ; Need to do this within GUI
   ; Just use _BSDRollback() here?
   Global $server_working = True

   _BDSRollback() ; Works!

   Global $server_working = False

EndFunc

Func _actionReloadWhitelist()

   Global $server_working = True
   _serverSendCommand("whitelist reload")

   Global $server_working = False
EndFunc

Func _actionReloadPermissions()

   Global $server_working = True
   _serverSendCommand("permissions reload")

   Global $server_working = False
EndFunc

Func _actionSendInput()
   Local $function_name = "Send Console Command"
   _log($function_name & " Function Started", $function_name, False, True)

   Global $server_working = True

   Local $command = GUICTRLRead($console_input)
   GUICtrlSetData($console_input, "")
   If StringLeft($command, 1) = "/" Then
	  $msg = StringRight($command, StringLen($command)-1)
   EndIf

   _serverSendCommand($command)
   Global $server_working = False
EndFunc

Func _actionSetData($key, $val)

   Local $function_name = "Set Data"
   _log($function_name & " Function Started", $function_name)

   Local $options
   _FileReadToArray($options_file, $options)
   Local $lines = ""

   For $i = 1 to UBound($options) -1
	  $line = $options[$i]
	  If StringLeft($line, StringLen($key)) = $key Then
		 $line = $key & "=" & $val
	  EndIf
	  $lines &= $line & @CRLF
   Next

   $oFile = FileOpen($options_file, 2)
   $oWrite = FileWrite($oFile, $lines)
   FileClose($oFile)
EndFunc

Func _actionKeepAlive()

   Local $function_name = "Keep Alive"
   _log($function_name & " Function Started", $function_name)

   ; Once triggered, don't trigger again for at least 2 minutes to prevent spamming
   ; Set 2 minute timer to reset keepalive trigger
   If $keepalive_triggered = True AND TimerDiff($keepalive_timer) > 120000 Then
	  $keepalive_triggered = False
	  _log("Keep Alive Trigger Reset", $function_name, False, True)
   EndIf

   ; If server not detected running after 5 seconds then autostart
   If $keepalive = "true" AND $keepalive_triggered = False AND $server_stopped = False AND $server_status = False AND $server_working = False Then
	  Global $keepalive_triggered = True
	  Global $keepalive_timer = TimerInit()
	  _runScript("bds")
	  _log("Keep Alive Triggered", $function_name, False, True)
   EndIf

EndFunc
