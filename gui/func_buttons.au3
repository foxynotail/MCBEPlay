; Start Button
Func _guiStartButton()

   Local $function_name = "Start Button"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_status = True Then
	  MsgBox(48, "Alert", " The server is already running")
	  Return False
   EndIf

   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   $t = MsgBox(4, "Wait...", "Are you sure you want to start the server?")
   If $t = 6 Then
	  _actionStartServer()
   EndIf

   Global $server_stopped = False ; For KeepAlive

EndFunc

; Stop Button
Func _guiStopButton()

   Local $function_name = "Stop Button"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_status = False Then
	  MsgBox(48, "Alert", " The server is not running")
	  Return False
   EndIf
   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   $t = MsgBox(4, "Wait...", "Are you sure you want to stop the server?")
   If $t = 6 Then
	  _actionStopServer()
   EndIf

   Global $server_stopped = True ; For KeepAlive
EndFunc

; Save Button
Func _guiSaveButton()

   Local $function_name = "Save Button"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   If $server_status = True Then
	  $t = MsgBox(4, "Wait...", "Are you sure you want to save the server?")
	  If $t = 6 Then
		 _actionSaveServer()
	  EndIf
   Else
	  $t = MsgBox(4, "Wait...", "Are you sure you want to backup the server?")
	  If $t = 6 Then
		 _actionFullBackupServer()
	  EndIf
   EndIf
EndFunc

; Restart Button
Func _guiRestartButton()

   Local $function_name = "Restart Button"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_status = False Then
	  MsgBox(48, "Alert", " The server is not running")
	  Return False
   EndIf
   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   $t = MsgBox(4, "Wait...", "Are you sure you want to restart the server?")
   If $t = 6 Then
	  _actionRestartServer()
   EndIf
EndFunc

; Rollback Button
Func _guiRollbackButton()

   Local $function_name = "Rollback Button"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_status = True Then
	  MsgBox(48, "Alert", " The server is running")
	  Return False
   EndIf
   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   $t = MsgBox(4, "Wait...", "Are you sure you want to rollback to the most recent save?")
   If $t = 6 Then
	  _actionRollbackServer()
   EndIf

EndFunc

; Reload Whitelist Button
Func _guiReloadWhitelistButton()

   Local $function_name = "Reload Whitelist"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   If $server_status = False Then
	  MsgBox(48, "Alert", "The Server is not running")
   Else
	  $t = MsgBox(4, "Wait...", "Are you sure you want to reload the whitelist?")
	  If $t = 6 Then
		 _actionReloadWhitelist()
	  EndIf
   EndIf
EndFunc
; Reload Permissions
Func _guiReloadPermissionsButton()

   Local $function_name = "Reload Permissions"
   _log($function_name & " Clicked", $function_name, False, True)

   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf

   If $server_status = False Then
	  MsgBox(48, "Alert", "The Server is not running")
   Else
	  $t = MsgBox(4, "Wait...", "Are you sure you want to reload permissions?")
	  If $t = 6 Then
		 _actionReloadPermissions()
	  EndIf
   EndIf
EndFunc

; Open Folder Button
Func _guiOpenFolder()
   Run("Explorer.exe " & @ScriptDir)
EndFunc

; Open BDS Options Button
Func _guiOpenOptions()
   Run('C:\Windows\Notepad.exe "' & $options_file & '"')
EndFunc

; Open Server Properties Button
Func _guiOpenProperties()
   Run('C:\Windows\Notepad.exe "' & $server_dir & '\server.properties' & '"')
EndFunc

; Open Logs Button
Func _guiOpenLogs()
   Run("Explorer.exe " & $log_dir)
EndFunc

; Open Saves Button
Func _guiOpenSaves()
   Run("Explorer.exe " & $save_dir)
EndFunc

; Change Auto Start
Func _guiRollbackCheckbox()

   Local $function_name = "Auto Rollback Checkbox"
   _log($function_name & " Clicked", $function_name)

   If _IsChecked($autoRollback_checkbox) Then
	  _actionSetData("rollback", "true")
	  _log("[Rollback Checkbox] > Set Rollback System On", $function_name, False, True)
   Else
	  _actionSetData("rollback", "false")
	  _log("[Rollback Checkbox] > Set Rollback System Off", $function_name, False, True)
   EndIf
EndFunc

; Change Keep Alive
Func _guiKeepaliveCheckbox()

   Local $function_name = "Keepalive Checkbox"
   _log($function_name & " Clicked", $function_name)
   If _IsChecked($keepalive_checkbox) Then
	  _actionSetData("keepalive", "true")
	  $keepalive = "true"
	  _log("[Keepalive Checkbox] > Set Keep Alive On", $function_name, False, True)
   Else
	  _actionSetData("keepalive", "false")
	  $keepalive = "false"
	  _log("[Keepalive Checkbox] > Set Keep Alive Off", $function_name, False, True)
   EndIf
EndFunc

; Server Commands
Func _guiConsoleInput()

   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf
   If $server_status = False Then
	  MsgBox(48, "Alert", "The server is not running")
   Else
	  _actionSendInput()
   EndIf
EndFunc

   If $server_working = True Then
	  MsgBox(48, "Alert", " The server is busy")
	  _log("Action cancelled as server is busy", $function_name, True)
	  Return False
   EndIf
Func _guiConsoleInputButton()
   If $server_status = False Then
	  MsgBox(48, "Alert", "The Server is not running")
   Else
	  _actionSendInput()
   EndIf
EndFunc