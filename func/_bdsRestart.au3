Func _BDSRestart()

   Local $function_name = "Restart Server"
   _log($function_name & " Function Started", $function_name, False, True)

   ; Then Stop
   Local $response = _BDSStop(True)

   ; ### 6/2/20 ADDED NEW SAVE / BACKUP SYSTEM (BELOW REMOVED)
   ; If keep alive is turned on, it may trigger a restart while the server is making a backup.
   ; So we need to make restart_file to tell keep alive that the server is restarting

   ; Create restart file
   _log("Creating Restarting File", $function_name, False, True)
   $oFile = FileOpen($restart_file, 2)
   FileClose($oFile)

   _FullBackup()
   sleep(1000)

   _log("Restarting BDS", $function_name, False, True)
   _BDSStart()

   ; Kill the restart file
   If FileExists($restart_file) Then
	  FileDelete($restart_file)
   EndIf

EndFunc


