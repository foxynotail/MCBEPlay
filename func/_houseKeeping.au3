Func _houseKeeping()

   Local $function_name = "House Keeping"
   _log($function_name & " Function Started", $function_name)

   ; Split log, error log, member Log into files of 1mb
   _splitFiles($log)
   _splitFiles($error_log)
   _splitFiles($member_log)

   ; Delete log & console log files over x days old
   _purgeFiles($log_dir, $keep_logs)
   _purgeFiles($session_dir, $keep_logs)

   ; If keeping daily saves
   If $keep_daily_saves > 0 Then
	  _dailySaves()
   EndIf
   _tidySaves()


EndFunc

Func _purgeFolders($directory, $keep_time)

   Local $function_name = "Purge Folders"
   _log($function_name & " Function Started", $function_name)

   Local $items = _FileListToArray($directory, "*", $FLTA_FOLDERS, True)
   For $i = 1 To UBound($items)-1
	  Local $lDate = FileGetTime($items[$i], $FT_CREATED)
	  Local $date = $lDate[0]&"/"&$lDate[1]&"/"&$lDate[2]&" "&$lDate[3]&":"&$lDate[4]&":"&$lDate[5]
	  If _DateDiff("D", $date, _NowCalc()) > $keep_time Then
		 _log("Removing Folder: " & $items[$l], $function_name, False, True)
		 DirRemove($items[$l], 1)
	  EndIf
   Next
EndFunc

Func _purgeFiles($directory, $keep_time)

   Local $function_name = "Purge Files"
   _log($function_name & " Function Started", $function_name)

   Local $items = _FileListToArray($directory, "*", $FLTA_FILES, True)
   For $i = 1 To UBound($items)-1
	  Local $lDate = FileGetTime($items[$i], $FT_CREATED)
	  Local $date = $lDate[0]&"/"&$lDate[1]&"/"&$lDate[2]&" "&$lDate[3]&":"&$lDate[4]&":"&$lDate[5]
	  If _DateDiff("D", $date, _NowCalc()) > $keep_time Then
		 _log("Removing File: " & $items[$i], $function_name, False, True)
		 FileDelete($items[$i])
	  EndIf
   Next
EndFunc

Func _splitFiles($file_name)

   Local $function_name = "Split Logs"
   _log($function_name & " Function Started", $function_name)

   ; Split File
   Local $file_size = FileGetSize($file_name)
   If $file_size > 1048576 Then ; 1MB

	  Local $file_string = StringRegExpReplace($file_name, "\.[^.]*$", "") ; Remove file extension
	  Local $new_file = $file_string & "-" & $timestamp & ".txt"

	  Local $move = FileMove($file_name, $new_file)
	  If $move == 0 Then
		 _log("Error Splitting File", $function_name, True)
		 Return False
	  Else
		 _log("File Split successfully", $function_name, False, True)
		 Local $oFile = FileOpen($file_name, 0)
		 FileClose($oFile)
	  EndIf
   EndIf
   Return True
EndFunc




Func _dailySaves()

   ; ### 6/2/20 - As daily saves weren't getting saved we split this into 2
   ; 1. Rename one save from each day as DAILY_{savename} - Prefer FULL_ saves
   ; 2. Delete all NONE_DAILY saves older than save_days

   Local $function_name = "Daily Saves"
   _log($function_name & " Function Started", $function_name)

   ; Get a list of all the actual save folders from the save path ; Ignore failed saves
   $folders = _FileListToArrayRec($save_dir, "*" & $level_name & "-*|FAILED_", $FLTAR_FOLDERS, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_NOPATH)
   If Not IsArray($folders) Then
	  Return False
   EndIf

   ; Make sure it is a save folder
   Local $saves[1]
   For $i = 1 To UBound($folders)-1
	  If StringInStr($folders[$i], $level_name & "-") Then
		 _arrayAdd($saves, $folders[$i])
	  EndIf
   Next

   ; Get one save from each date (Priority 1. DAILY_, 2. FULL_, 3. Latest, 4. Other)

   Dim $dates[1]
   Dim $occurances[1]

   ; For each save, check how many saves (occurances) per day
   For $i = 1 To UBound($saves)-1
	  ; If save has trailing slash then remove
	  If StringRight($saves[$i], 1) = "/" Then
		 $save = StringLeft($saves[$i], StringLen($saves[$i])-1)
	  Else
		 $save = $saves[$i]
	  EndIf
	  If StringInStr($save, "-") Then
		 $split = StringSplit($save, "-")
		 $datetime = $split[2]
		 $date = StringLeft($datetime, 8)
		 $y = StringLeft($date, 4)
		 $m = StringMid($date, 5, 2)
		 $d = StringMid($date, 7, 2)

		 $nice_date = $y & "/" & $m & "/" & $d

		 ; If datedif > keep_daily_Saves then delete the save
		 $days_old = _DateDiff("D", $nice_date, _NowCalc())
		 If $days_old > $keep_daily_saves Then
			_log("Deleting Save (Older than " & $keep_daily_saves & " days): " & $save, $function_name, False, True)
			If DirRemove($save_dir & "\" & $save, 1) < 1 Then
			   _log("Error deleting folder: " & $save_dir & "\" & $save, $function_name, True)
			   Run("cmd.exe /k RMDIR " & $save_dir & "\" & $save & " /s /q")
			EndIf
		 Else
			; Otherwise add this save to the list of saves to process
			If _ArraySearch($dates, $date) = -1 Then
			   ; If new date then add to array
			   _arrayAdd($dates, $date)
			   _arrayAdd($occurances, 1)
			Else
			   ; If old date then update number of occurences
			   $key = _ArraySearch($dates, $date)
			   $occurances[$key] = $occurances[$key] + 1
			EndIf
		 EndIf
	  EndIf
   Next

   ; For each date within $dates, if more than one occurance look for DAILY_ or FULL_
   For $i = 1 To Ubound($dates)-1
	  $date = $dates[$i]
	  If $occurances[$i] > 1 Then

		 Local $save_to_keep = ""
		 ; Search folder for saves during this date
		 $saves_in_date = _FileListToArrayRec($save_dir, "*" & $level_name & "-" & $date & "*|FAILED_", $FLTAR_FOLDERS, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_NOPATH)
		 If Not IsArray($saves_in_date) Then
			Return False
		 EndIf

		 For $s = 1 To UBound($saves_in_date)-1
			If StringLeft($saves_in_date[$s], 6) = "DAILY_" Then
			   ;_log("DAILY Search: " & StringLeft($saves_in_date[$s], 6) & " > " & $saves_in_date[$s], $function_name, False, True)
			   $save_to_keep = $saves_in_date[$s]
			EndIf
		 Next
		 If $save_to_keep = "" Then
			For $s = 1 To UBound($saves_in_date)-1
			   If StringLeft($saves_in_date[$s], 5) = "FULL_" Then
				  ;_log("FULL Search: " & StringLeft($saves_in_date[$s], 5) & " > " & $saves_in_date[$s], $function_name, False, True)
				  $save_to_keep = $saves_in_date[$s]
			   EndIf
			Next
		 EndIf
		 If $save_to_keep = "" Then
			;_log("None Found > " & $saves_in_date[1], $function_name, False, True)
			$save_to_keep = $saves_in_date[1]
		 EndIf
		 _log("Save to keep: " & $save_to_keep, $function_name)


		 ; Rename save to keep with DAILY_ prefix (But don't add prefix if already exists)
		 If StringLeft($save_to_keep, 6) <> "DAILY_" Then
			If DirMove($save_dir & "\" & $save_to_keep, $save_dir & "\" & "DAILY_" & $save_to_keep) < 1 Then
			   _log("Error renaming daily save: " & $save_to_keep, $function_name, True)
		    EndIf
		 EndIf

		 ; No need to delete the other saves from that date as they will be handled my _tidySaves function
	  Else

		 ; If only one occurance of this date then make sure this is the daily
		 ; Search folder for saves during this date
		 $saves = _FileListToArrayRec($save_dir, "*" & $level_name & "-" & $date & "*", $FLTAR_FOLDERS, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_NOPATH)
		 If Not IsArray($saves) Then
			Return False
		 EndIf

		 ; Rename save to keep with DAILY_ prefix (But don't add prefix if already exists)
		 If StringLeft($saves[1], 6) <> "DAILY_" Then
			If DirMove($save_dir & "\" & $saves[1], $save_dir & "\" & "DAILY_" & $saves[1]) < 1 Then
			  _log("Error renaming daily save: " & $saves[1], $function_name, True)
		   EndIf
		 EndIf
	  EndIf
   Next
EndFunc



Func _tidySaves()

   ; Tidy saves can delete all saves older than keep_saves variable not prefixed with DAILY_

   Local $function_name = "Tidy Saves"
   _log($function_name & " Function Started", $function_name)

    ; Get a list of all the actual save folders from the save path
   $folders = _FileListToArrayRec($save_dir, "*" & $level_name & "-*|DAILY_*", $FLTAR_FOLDERS, $FLTAR_NORECUR, $FLTAR_SORT, $FLTAR_NOPATH)
   If Not IsArray($folders) Then
	  Return False
   EndIf

   ; Make sure it is a save folder
   Local $saves[1]
   For $i = 1 To UBound($folders)-1
	  If StringInStr($folders[$i], $level_name & "-") Then
		 _arrayAdd($saves, $folders[$i])
	  EndIf
   Next

   ; For each save, check how old it is
   For $i = 1 To UBound($saves)-1

	  ; If save has trailing slash then remove
	  If StringRight($saves[$i], 1) = "/" Then
		 $save = StringLeft($saves[$i], StringLen($saves[$i])-1)
	  Else
		 $save = $saves[$i]
	  EndIf
	  If StringInStr($save, "-") Then
		 $split = StringSplit($save, "-")
		 $datetime = $split[2]
		 $date = StringLeft($datetime, 8)
		 $y = StringLeft($date, 4)
		 $m = StringMid($date, 5, 2)
		 $d = StringMid($date, 7, 2)

		 $nice_date = $y & "/" & $m & "/" & $d

		 ; If datedif > keep_daily_Saves then delete the save
		 $days_old = _DateDiff("D", $nice_date, _NowCalc())
		 If $days_old > $keep_saves Then
			_log("Deleting Save (Older than " & $keep_saves & " days): " & $save, $function_name, False, True)
			If DirRemove($save_dir & "\" & $save, 1) < 1 Then
			   _log("Error deleting folder: " & $save_dir & "\" & $save, $function_name, True)
			   Run("cmd.exe /k RMDIR " & $save_dir & "\" & $save & " /s /q")
			EndIf
		 EndIf
	  EndIf
   Next

EndFunc