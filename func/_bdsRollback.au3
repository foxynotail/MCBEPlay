Func _BDSRollback()

   Local $function_name = "Rollback Server"
   _log($function_name & " Function Started", $function_name, False, True)

   _BDSBusy(True)

   $src_path = $world_dir & "\" & $level_name
   Local $db_path = $src_path & "\db"
   Local $modified = FileGetTime($db_path, $FT_MODIFIED, $FT_STRING)

   $dst_path = $save_dir & "\FAILED_" & $level_name & "-" & $modified

   ; Copy World Folder to Failed Saves Folder
   Local $copied = DirCopy($src_path, $dst_path, 1)
   If $copied == 0 Then
	  _log("Error copying world directory to failed saves", $function_name, True)
	  _BDSResponse("Error copying world directory to failed saves")
	  ; Remove busy signal
	  _BDSBusy(False)
	  Return False
   EndIf

   ; 2. Check Number of Saves
   Local $saves = _FileListToArrayRec($save_dir, "*|FAILED_*;ROLLBACK_*", $FLTAR_FILESFOLDERS, $FLTAR_NORECUR, $FLTAR_SORT)
   Local $save
   Local $save_file

   ; 3. If < 1 then Exit & Error
   If Not IsArray($saves) Then
	  _log("No saves available. Unable to roll back", $function_name, True)
	  _BDSResponse("No saves available. Unable to roll back")
	  ; Remove busy signal
	  _BDSBusy(False)
	  Return False
   ElseIf $saves[0] < 2 Then
	  ; If there is only one save file there is no point in working the array, just use this data
	  _log("Save found. Rolling back...", $function_name, False, True)
	  $save = $saves[1]
	  $save_file = $save
   Else

	  _log("Saves Found. Sorting Data", $function_name, False, False)
	  ; If Array not empty then loop to get file dates
	  Local $created
	  Local $lastcreated = 0
	  Local $latest_save

	  For $i = 1 To UBound($saves)-1

		 ; Remove trailing slash from directory
		 $save = $saves[$i]
		 $created = FileGetTime($save_dir & "\" & $save, $FT_CREATED, 1)
		 If $created > $lastcreated Then
			$lastcreated = $created
			$latest_save = $save
		 EndIf
	  Next

	  $save_file = $latest_save
	  _log("Latest Save File: " & $save_file, $function_name, False, True)

   EndIf

   ; 4. If > 1 then copy latest save to world folder
   ; First remove all db files - deleted dir - world_path\level_name\db
   $purge_path = $world_dir & "\" & $level_name & "\db"
   _log("Purging Existing DB files from World Folder", $function_name, False)

   ; Check db folder exists to purge
   If FileExists($purge_path) Then

	  Local $purge = DirRemove($purge_path, 1)
	  If $purge == 0 Then
		 _log("Unable to delete existing DB data", $function_name, True)
	  Else
		 _log("Existing DB files Purged Succesfully", $function_name, False, True)

	  EndIf
   Else
	  _log("No files to purge", $function_name, False)
   EndIf

   _log("Copying Save Data to World File", $function_name, False)

   Local $src_path = $save_dir & "\" & $save_file
   Local $dst_path = $world_dir & "\" & $level_name

   Local $copy = DirCopy($src_path, $dst_path, $FC_OVERWRITE)
   If $copy == 0 Then
	  _log("Error copying save data to world directory", $function_name, True)
	  _BDSResponse("Error copying save data to world directory")
	  ; Remove busy signal
	  _BDSBusy(False)
	  Return False
   Else
	  _log("Save data copied to world directory succesfully", $function_name, False, True)
   EndIf

   ; 5. Move copied Rollback folder to saves/title/ROLLBACK_level-timestamp so we don't use this one again
   _log("Renaming bolled back save folder to add ROLLBACK_ prefix", $function_name, False)
   $dst_path = $save_dir & "\ROLLBACK_" & $save_file
   $move = DirMove($src_path, $dst_path, $FC_OVERWRITE)

   If $move == 0 Then
	  _log("Error renaming failed save", $function_name, True)
	  _BDSResponse("Error renaming failed save")
	  ; Remove busy signal
	  _BDSBusy(False)
	  Return False
   Else
	  _log("Rolled back save folder renamed: " & $dst_path, $function_name, False, True)
   EndIf

   _log("Rollback Completed Succesfully", $function_name, False, True)
   _BDSResponse("Rollback Completed Succesfully")
   ; Remove busy signal
   _BDSBusy(False)
   Return True

EndFunc


