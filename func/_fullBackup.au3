Func _FullBackup()

   Local $function_name = "Full Backup"
   _log($function_name & " Function Started", $function_name, False, True)

   ; Send busy signal
   _BDSBusy(True)

   Local $save_timer = TimerInit()
   Local $error_found = False

   FileDelete($error_file)
   $timestamp = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC

   Local $src_dir = $world_dir & "\" & $level_name
   Local $dst_dir = $save_dir & "\FULL_" & $level_name & "-" & $timestamp

    _log("Copying Directory", $function_name, False, True)

   If DirCopy($src_dir, $dst_dir, 1) < 1 Then
	  _log("Error Copying Save Folder: " & $src_dir & " > " & $dst_dir, $function_name, True)
	  $error_found = True
   EndIf

   $save_time = TimerDiff($save_timer)
   $save_time = Floor($save_time/1000)

   If $error_found Then
	  $result = "Full Save process failed [" & $save_time & " seconds]"
	  _log("Full Save failed! [" & $save_time & " seconds]", $function_name, True)
	  $dst_dir = "FAILED_" & $src_dir
	  If DirMove($src_dir, $dst_dir, 1) < 1 Then
		 _log("Error Moving Failed Folder: " & $src_dir & " > " & $dst_dir, $function_name, True)
		 $error_found = True
	  EndIf
	  _BDSResponse($result)
   Else
	  $result = "Full Backup Finished Succesfully [" & $save_time & " seconds]"
	  _log($result, $function_name, False, True)
	  _BDSResponse($result)

	  ; Create backedup file
	  If FileExists($backedup_file) Then
		 FileDelete($backedup_file)
	  EndIf
	  $oFile = FileOpen($backedup_file, 2)
	  FileClose($oFile)

   EndIf


   ; Remove busy signal
   _BDSBusy(False)

EndFunc

