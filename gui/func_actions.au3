Func _Exit()

   If WinExists($window_title) OR ProcessExists($server_file) Then
	  MsgBox(48, "Alert", "The server is still running." & @CRLF & "Please use the Stop command or button to stop the server")
   EndIf

   Exit
EndFunc

Func _autoSave()

   Local $function_name = "Auto Save"
   _log($function_name & " Function Started", $function_name)

   ; If someone joins an empty server then don't save
   ; This is handled in members check _gui.au3 _guiUpdateMembers() function

   ; If there were members online but they all left then trigger a save
   ; This is handled in _bds.au3 __BDSFindMember function

   ; When was last start / save?
   Local $last_start = _serverGetStartTime()
   Local $last_save = _guiGetLastSaveTime()

   Local $mins_since_start = _guiMinsSince($last_start)
   Local $mins_since_save = _guiMinsSince($last_save)

   GUICtrlSetData($ls_label, "Last Save: " & $last_save)

   $next_save = _DateAdd("n", $save_interval, $last_save)
   $seconds_to_save = _DateDiff("s", _NowCalc(), $next_save)

   GUICtrlSetData($ns_label, "Next Save: " & $next_save)

   ; ### :- 6/2/20 New System for Backups
   Local $last_backup = _guiGetLastBackupTime()
   Local $mins_since_backup = _guiMinsSince($last_backup)
   $next_backup = _DateAdd("n", $backup_interval, $last_backup)
   $seconds_to_backup = _DateDiff("s", _NowCalc(), $next_backup)
   GUICtrlSetData($lb_label, "Last Backup: " & $last_backup)
   GUICtrlSetData($nb_label, "Next Backup: " & $next_backup)
   ; ### -: 6/2/20 New System for Backups

   ; If no members online then don't save
   If $members_online < 1 Then
	  GUICtrlSetData($save_label, "AutoSave Paused")
	  Return False
   EndIf

   $minutes_to_save = $seconds_to_save/60
   $hours_to_save = $seconds_to_save/60/60

   $iHour = Floor($hours_to_save)
   $rMin = $minutes_to_save - ($iHour*60)
   $iMin = Floor($rMin)
   $rSec = $seconds_to_save - ($iHour*60*60) - ($iMin*60)
   $iSec = Floor($rSec)

   GUICtrlSetData($save_label, "Saving in " & $iHour & "h " & $iMin & "m " & $iSec & "s")

   ; ### :- 6/2/20 New System for Backups

   $minutes_to_backup = $seconds_to_backup/60
   $hours_to_backup = $seconds_to_backup/60/60
   ; ### -: 6/2/20 New System for Backups

   $iHour = Floor($hours_to_backup)
   $rMin = $minutes_to_backup - ($iHour*60)
   $iMin = Floor($rMin)
   $rSec = $seconds_to_backup - ($iHour*60*60) - ($iMin*60)
   $iSec = Floor($rSec)

   GUICtrlSetData($backup_label, "Backing Up in " & $iHour & "h " & $iMin & "m " & $iSec & "s")

   ; ### 6/2/20 New System for Backups

   ; If last save was more than save_interval minutes ago then trigger save
   If $seconds_to_save <= 0 Then

	  If $server_status = False Then
		 ;_log("Server not running", $function_name, True)
		 Return False
	  EndIf

	  If $server_working = True Then
		 ;_log("Server busy", $function_name, True)
		 Return False
	  EndIf

	  If $mins_since_save < $min_save_time Then ;Don't save if time within last save time
		 _log("It's less than " & $min_save_time & " minutes since the last save. Not saving", $function_name, False, True)
		 Return False
	  EndIf

	  ; If it's less than 2 mins till the next save but the server only just started / saved (less than 2 mins ago)
	  ; Then increase the time to next save to 2 minutes
	  If $mins_since_start <= $min_save_time OR $mins_since_save <= $min_save_time Then
		 _log("It's less than " & $min_save_time & " minutes since the last start / save. Not saving", $function_name, False, True)
		 Return False
	  EndIf

	  GUICtrlSetData($ls_label, "Save in progress.")
	  GUICtrlSetData($ns_label, "Please wait...")
	  GUICtrlSetData($save_label, "")

	  ; If last backup was more than backup_interval minutes ago then trigger backup
	  If $seconds_to_backup <= 0 Then
		 _log("Backup Starting", $function_name, False, True)
		 GUICtrlSetData($lb_label, "Backup in progress.")
		 GUICtrlSetData($nb_label, "Please wait...")
		 GUICtrlSetData($backup_label, "")
		 _actionBackupServer(True)

	  Else

		 _log("Auto Save Starting", $function_name, False, True)
		 _actionSaveServer(True)

	  EndIf


   EndIf

EndFunc



Func _autoRestart()

   Local $function_name = "Auto Restart"
   _log($function_name & " Function Started", $function_name)

   If $server_status = False Then
	  Return False
   EndIf

   If $server_working = True Then
	  Return False
   EndIf

   ; Once triggered, don't trigger again for at least 1 minute to prevent spamming
   ; Set 2 minute timer to reset keepalive trigger
   If $chat_triggered = True AND TimerDiff($chat_timer) > 60000 Then
	  $chat_triggered = False
	  _log("Chat Trigger Reset", $function_name, False, True)
   EndIf

   ; When was last restart?
   Local $last_start = _serverGetStartTime()
   GUICtrlSetData($lr_label, "Last restart: " & $last_start)

   If $auto_restart == "time" Then
	  $result = _autoRestartTime($last_start)
   Else
	  $result = _autoRestartInterval($last_start)
   EndIf
   $seconds_to_restart = $result
   $minutes_to_restart = $seconds_to_restart/60
   $hours_to_restart = $seconds_to_restart/60/60

   $iHour = Floor($hours_to_restart)
   $rMin = $minutes_to_restart - ($iHour*60)
   $iMin = Floor($rMin)
   $rSec = $seconds_to_restart - ($iHour*60*60) - ($iMin*60)
   $iSec = Floor($rSec)

   GUICtrlSetData($restart_label, "Restarting in " & $iHour & "h " & $iMin & "m " & $iSec & "s")

   ; If restart less than 5 minutes away then tell server
   If $seconds_to_restart = 300 AND $seconds_to_restart >= 290 Then

	  If $chat_triggered = False Then
		 _log("Chat: Server is restarting in 5 minutes", $function_name, False, True)
		 _serverSendCommand("say Server is restarting in 5 minutes")
		 Global $chat_triggered = True
		 Global $chat_timer = TimerInit()
	  EndIf

   EndIf
   ; If restart less than 1 minute away then tell server
   If $seconds_to_restart <= 60 AND $seconds_to_restart >= 50 Then


	  If $chat_triggered = False Then
		 _log("Chat: Server is restarting in 1 minute", $function_name, False, True)
		 _serverSendCommand("say Server is restarting in 1 minute")
		 Global $chat_triggered = True
		 Global $chat_timer = TimerInit()
	  EndIf

   EndIf
   ; If restart less than 5 seconds away then tell server
   If $seconds_to_restart <= 10 AND $seconds_to_restart >= 6 Then

	  If $chat_triggered = False Then
		 _log("Chat: Server is restarting", $function_name, False, True)
		 _serverSendCommand("say Server is restarting")
		 Global $chat_triggered = True
		 Global $chat_timer = TimerInit()
	  EndIf

   EndIf

   ; If last restart was more than restart_interval minutes ago then trigger restart
   If $seconds_to_restart <= 5 AND $seconds_to_restart >= 0 Then

	  _log("Restart Triggered [Seconds <= 5]", $function_name, False, True)

	  _log("Auto Restart Starting", $function_name)

	  If $server_status = False Then
		 _log("Server not running", $function_name, True)
		 Return False
	  EndIf

	  If $server_working = True Then
		 _log("Server busy", $function_name, True)
		 Return False
	  EndIf

	  GUICtrlSetData($lr_label, "Restart in progress.")
	  GUICtrlSetData($nr_label, "Please wait...")
	  GUICtrlSetData($restart_label, "")
	  _actionRestartServer()

   EndIf

EndFunc

Func _autoRestartTime($last_restart)

   Local $seconds_to_restart = 86401 ; 1 second more than 24 hrs

   For $i = 0 To UBound($restart_times) - 1

	  ; For each time determine no of seconds till next restart
	  $restart_date = @YEAR & "/" & @MON & "/" & @MDAY & " " & $restart_times[$i] & ":00"
	  $seconds = _DateDiff("s", _NowCalc(), $restart_date)
	  ; If seconds is negative then time has passed, set date to tomorrow and try
	  If $seconds < 0 Then

		 Local $full_date = @YEAR & "/" & @MON & "/" & @MDAY & " " & $restart_times[$i] & ":00"
		 $restart_date = _DateAdd("D", 1, $full_date)
		 $seconds = _DateDiff("s", _NowCalc(), $restart_date)

	  EndIf
	  If $seconds < $seconds_to_restart Then
		 $seconds_to_restart = $seconds
	  EndIf

   Next

   $next_restart = _DateAdd("s", $seconds_to_restart, _NowCalc())
   GUICtrlSetData($nr_label, "Next restart: " & $next_restart)

   Return $seconds_to_restart

EndFunc

Func _autoRestartInterval($last_restart)

   $next_restart = _DateAdd("h", $restart_interval, $last_restart)
   GUICtrlSetData($nr_label, "Next restart: " & $next_restart)

   $seconds_to_restart = _DateDiff("s", _NowCalc(), $next_restart)

   Return $seconds_to_restart

EndFunc