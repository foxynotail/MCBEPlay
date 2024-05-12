; Added 6/2/20
; Makes a backup of the server during save ProcessClose

Func _BDSBackup($response)

   Local $function_name = "Backup Server"
   _log($function_name & " Function Started", $function_name, False, True)

   ; Send busy signal
   _BDSBusy(True)

   FileDelete($error_file)

   _BDSServerChat("Backup Started")

   ; Run save hold
   Local $backup_timer = TimerInit()

   ;    Find data based on keyword search
   Local $keyword = "level.dat"
   Local $keylen = StringLen($keyword)
   Local $pos
   Local $result
   Local $error_found = False
   Local $save_data

   ; Check which line of response the save data is on
   Local $lines = StringSplit($response, @LF)
   For $i = 1 To UBound($lines) - 1
	  $pos = StringInStr($lines[$i], $keyword, 2)
	  If $pos > 0 Then
		 $save_data = $lines[$i]
	  EndIf
   Next
   ; Remove Whitespace from Save Data String
   $save_data = StringStripWS($save_data, 8)

   _log("Creating Array of Files to Save", $function_name)
   Local $save_files = StringSplit($save_data, ",")

   $timestamp = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC

   Local $src_dir = $world_dir & "\" & $level_name & "\"
   Local $dst_file = $level_name & "-" & $timestamp & "\"
   Local $dst_dir = $save_dir & "\" & $dst_file

   ; Get an array of all files to save
   ; Get 2nd array containing file lengths required
   Dim $file_list[1]
   Dim $file_lengths[1]
   If($save_files[0] > 0) Then ; Zero point on array is array length

	  For $i = 1 To UBound($save_files)-1

	  Local $data = $save_files[$i]

		 If StringInStr($save_files[$i], ":") Then

			Local $file_split = StringSplit($save_files[$i], ":")
			Local $file = $file_split[1]
			Local $file_size = $file_split[2]
			_arrayAdd($file_lengths, $file_size)

			Local $strip_slash = StringSplit($file, "/")
			Local $file = $strip_slash[2]
			_arrayAdd($file_list, $file)
		 EndIf

	   Next
	EndIf

   ; Once we have all of the files and lengths we need to copy them to the destination directory
   Dim $dst_files[1]
   Dim $req_lengths[1]

   _log("Copying Files", $function_name, False, True)

   For $i = 1 To UBound($file_list)-1

	  Local $file = $file_list[$i]

	  Local $src_path = $src_dir & $file
	  Local $dst_path = $dst_dir & $file

	  Local $file_exists = True

	  ; Check File Exists to Copy
	  If NOT FileExists($src_path) Then

		 $src_path = $src_dir & "db\" & $file
		 $dst_path = $dst_dir & "db\" & $file
		 If NOT FileExists($src_path) Then

		 _log("Source file does not exist: " & $src_path, $function_name, True)
		 $error_found = True
		 $file_exists = False

		 EndIf
	  EndIf

	  If $file_exists Then

		 _arrayAdd($dst_files, $dst_path)
		 _arrayAdd($req_lengths, $file_lengths[$i])
		 ; Copy File from World Folder to Save Location
		 ;_log("Copying File: " & $file, $function_name)
		 If FileCopy($src_path, $dst_path, 8) < 1 Then
			_log("Error Copying File: " & $src_path & " > " & $dst_path, $function_name, True)
			$error_found = True
		 EndIf

	  EndIf

   Next

   Local $result = "Files copied"
   If $error_found = True Then
	  $result = "Files copied with errors"
   EndIf
   _BDSResponse($result)

   ; Truncate all of the files
   _log("Truncating Copied Files", $function_name, False, True)
   For $i = 1 To UBound($dst_files)-1

	  Local $file = $dst_files[$i]
	  Local $req_size = $req_lengths[$i]
	  Local $dst_size = FileGetSize($dst_files[$i])

	  If $dst_size > $req_size Then

		 ; Truncate file to set file length
		 $hFile = _WinAPI_CreateFile($file, 2, 4)
		 _WinAPI_SetFilePointer($hFile, $req_size)
		 _WinAPI_SetEndOfFile($hFile)
		 $iSize = _WinAPI_GetFileSizeEx($hFile)
		 _WinAPI_CloseHandle($hFile)

		 Local $dFileSize = FileGetSize($file)

		 If $req_size <> $dFileSize Then
			_log("Error truncating " & $file &" from " & $dst_size & " bytes to " & $req_size & "bytes", $function_name, True)
			$error_found = True
		 Else
			_log("Succesfully truncated " & $file & " from " & $dst_size & " bytes to " & $req_size & "bytes", $function_name, False)
		 EndIf
	  Else
		 ;_log("File already correct size. No Truncation required", $function_name, False)
	  EndIf

   Next

   $backup_time = TimerDiff($backup_timer)
   $backup_time = Floor($backup_time/1000)

   If $error_found Then
	  $result = "Backup process finished with errors [" & $backup_time & " seconds]"
	  _log($result, $function_name, True)

	  _log("Renaming Backup with FAILED_ prefix", $function_name, False, True)
	  $fail_dir = $save_dir & "\FAILED_" & $dst_file
	  If DirMove($dst_dir , $fail_dir) < 1 Then
		 _log("Error renaming failed backup: " & $dst_dir & " > " & $fail_dir, $function_name, True)
	  EndIf
	  _BDSServerChat("Error with Backup")


   Else
	  $result = "Backup process finished succesfully [" & $backup_time & " seconds]"
	  _log($result, $function_name, False, True)
	  If $backup_time > 10 Then
		 _BDSServerChat("Backup Complete [" & $backup_time & " seconds]")
	  Else
		 _BDSServerChat("Backup Complete")
	  EndIf

   EndIf

   ; Create backedup file
   If FileExists($backedup_file) Then
	  FileDelete($backedup_file)
   EndIf
   $oFile = FileOpen($backedup_file, 2)
   FileClose($oFile)

   _BDSResponse($result)
   ; Remove busy signal
   _BDSBusy(False)

EndFunc

