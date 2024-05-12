Func _guiUpdateServerStatus()

   Local $function_name = "Update Server Status"
   ;_log($function_name & " Function Started", $function_name)

   If $server_error = False Then
	  Switch $server_status
		 Case True
		 GUICtrlSetData($state_label2, "[RUNNING]")
		 GUICtrlSetColor($state_label2, $COLOR_GREEN)
		 Case False
		 GUICtrlSetData($state_label2, "[STOPPED]")
		 GUICtrlSetColor($state_label2, $COLOR_BLUE)
	  EndSwitch
   Else
	  Switch $server_error
		 Case "CRASH"
		 GUICtrlSetData($state_label2, "[CRASHED]")
		 GUICtrlSetColor($state_label2, $COLOR_RED)
		 Case "UNRESPONSIVE"
		 GUICtrlSetData($state_label2, "[UNRESPONSIVE]")
		 GUICtrlSetColor($state_label2, $COLOR_MAROON)
		 Case "ERROR"
		 GUICtrlSetData($state_label2, "[ERROR]")
		 GUICtrlSetColor($state_label2, $COLOR_FUCHSIA)
	  EndSwitch
   EndIf
EndFunc
Func _guiUpdateWorkingStatus()

   Local $function_name = "Update Working Status"
   ;_log($function_name & " Function Started", $function_name)

   Switch $server_working
	  Case True
	  GUICtrlSetData($state_label3, "[BUSY]")
	  GUICtrlSetColor($state_label3, $COLOR_RED)
	  Case False
	  GUICtrlSetData($state_label3, "[IDLE]")
	  GUICtrlSetColor($state_label3, $COLOR_GREEN)
   EndSwitch
EndFunc


Func _guiWriteToEditObject($string, $object, $max_lines, $error, $update=True)

   Local $function_name = "Write to Edit Object"
   ;_log($function_name & " Function Started", $function_name)

   Local $data = $string

   If $update = True Then
	  $data = GUICtrlRead($object) & $string
   EndIf

   Local $lines = StringSplit($data, @CRLF, 2)

   If IsArray($lines) Then

	  Local $start_line = 0

	  If $lines > $max_lines Then
		 $start_line = $lines - $max_lines
	  EndIf

	  $data = ""
	  For $i = $start_line To UBound($lines)-1
		 Local $line = StringStripWS($lines[$i], 8)
		 If StringLen($line)>0 Then
			$data &= $lines[$i] & @CRLF
		 EndIf
	  Next
   EndIf

   Local $length = StringLen($data)

   GUICtrlSetData($object, $data)
   _GUICtrlEdit_SetSel($object, $length, $length)
   _GUICtrlEdit_Scroll($object, $SB_SCROLLCARET)

EndFunc

Func _guiWriteToDebug($string, $error=False)

   Local $function_name = "Write to Debug"
   ;_log($function_name & " Function Started", $function_name)
   _guiWriteToEditObject($string, $debug_edit, $max_debug_lines, $error, True)

EndFunc

Func _guiWriteToConsole($string)

   Local $function_name = "Write to Console"
   ;_log($function_name & " Function Started", $function_name)
   _guiWriteToEditObject($string, $console_edit, $max_console_lines, False, False)

EndFunc

Func _guiUpdateConsole()

   Local $function_name = "Update Console"
   ;_log($function_name & " Function Started", $function_name)
   Local $check_size = FileGetSize($console_log)
   If $check_size <> $console_size Then ; Console Log Changed so update

	  Global $console_size = $check_size
	  Local $console_data = FileRead(_serverGetConsoleLog())
	  _guiWriteToConsole($console_data)

   EndIf
EndFunc


Func _guiSetLastSaveTime($datetime)

   Local $function_name = "Set Last Save Time"
   _log($function_name & " Function Started", $function_name)

   _log("Setting Last Save Time to: " & $datetime, $function_name, False, True)
   $oFile = FileOpen($save_file, 2)
   FileWrite($oFile, $datetime)
   FileClose($oFile)

EndFunc

Func _guiGetLastSaveTime()

   Local $function_name = "Get Last Save Time"
   _log($function_name & " Function Started", $function_name)

   $oFile = FileOpen($save_file)
   Local $save_time = FileRead($oFile)
   FileClose($oFile)

   Return $save_time

EndFunc


Func _guiSetLastBackupTime($datetime)

   Local $function_name = "Set Last Backup Time"
   _log($function_name & " Function Started", $function_name)

   _log("Setting Last Backup Time to: " & $datetime, $function_name, False, True)
   $oFile = FileOpen($backup_file, 2)
   FileWrite($oFile, $datetime)
   FileClose($oFile)

EndFunc


Func _guiGetLastBackupTime()

   Local $function_name = "Get Last Backup Time"
   _log($function_name & " Function Started", $function_name)

   Local $backup_time = 0

   ; Get time since most recent backup
   ; First find if any backups made
   ; Then get the last one

   ; If backup time file doesn't exist then search for backup folders (Don't do this every time as it will be laggy)
   If FileExists($backup_file) Then

	  $oFile = FileOpen($backup_file)
	  Local $backup_time = FileRead($oFile)
	  FileClose($oFile)

   Else

	  If Not FileExists($save_dir) Then
		 DirCreate($save_dir)
	  EndIf

	  Local $folders = _FileListToArrayRec($save_dir, "*" & $level_name & "-*", $FLTAR_FOLDERS, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_FULLPATH)
	  If @error Then
		 _log("No Saves in Save Folder", $function_name, False)
		 $backup_time = "2020/01/01 00:00:00"
	  Else

		 Local $date_string
		 Local $latest_save

		 For $i = 1 To UBound($folders)-1
			If StringInStr($folders[$i], $level_name & "-") Then
			   $date_string = FileGetTime($folders[$i], $FT_CREATED, $FT_STRING)
			   If $date_string > $backup_time Then
				  $backup_time = $date_string
				  $latest_save = $folders[$i]
			   EndIf
			EndIf
		 Next

		 $good_date = FileGetTime($latest_save, $FT_CREATED, 0)
		 Local $backup_time = $good_date[0] & "/" & $good_date[1] & "/" & $good_date[2] & " " & $good_date[3] & ":" & $good_date[4] & ":" & $good_date[5]

		 ; Save this to a file so that we don't need to keep running folder searches 4 times / second
		 _guiSetLastBackupTime($backup_time)

	  EndIf

   EndIf

   Return $backup_time

EndFunc

Func _guiMinsSince($time)
   Return _DateDiff('n', $time, _NowCalc())
EndFunc

Func _guiUpdateMembers()
   Local $function_name = "Update Members"
   ;_log($function_name & " Function Started", $function_name)

   Local $members[1]
   If FileExists($member_file) Then
	  _FileReadToArray($member_file, $members)
	  If $members = 0 Then
		 Local $members[1]
	  EndIf
   EndIf
   $members_online = UBound($members)-1
   If $members_online > 0 Then
	  $member_string = ""
	  For $i = 1 To $members_online
		 If StringLen($members[$i]) > 0 Then
			$member_string &= $members[$i] & ", "
		 EndIf
	  Next
	  $member_string = StringLeft($member_string, StringLen($member_string)-2)
	  GUICtrlSetData($members_label, "Members Online: " & $members_online & " " & $member_string)
   Else
	  GUICtrlSetData($members_label, "Members Online: " & $members_online)
   EndIf

   ; If someone joins an empty server then don't save (For AutoSave)
   If $members_online > 0 AND $members_online_last = 0 Then
	  _guiSetLastSaveTime(_NowCalc()) ; Set last save time to no
	  _log("Member joined empty server: Resetting Last save time to now", $function_name, False, True)
   EndIf
   $members_online_last = $members_online ; Reset members online last

EndFunc