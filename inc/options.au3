; Get Options from Options File
_optionsGet($options_file)

; Convert Restart Times into Array
Local $restart_time = $restart_times
Global $restart_times[0]
If StringLen($restart_time) > 1 Then
   ; Split comma separated values
   If StringInStr($restart_time, ",") <> 0 Then
	  ; Set global array
	  Global $restart_times = StringSplit($restart_time, ",")
	  _ArrayDelete($restart_times, 0)
	  For $i = 1 To UBound($restart_times)-1
		 ; Remove anything that's not a time

		 If StringInStr($restart_times[$i], ":") == 0 Then
			_ArrayDelete($restart_times, $i)
		 EndIf
	  Next
	  _ArraySort($restart_times)
   Else
	  Global $restart_times[1]
	  $restart_times[0] = $restart_time
   EndIf
EndIF

; Set Variables
Global $title_fix = StringStripWS ($server_title, $STR_STRIPALL)
Global $window_title = $MCBEPlay & " - " & $server_title

; Set Files
Global $server = $server_dir & "\" & $server_file
Global $log = $log_dir & "\log.txt"
Global $error_log = $log_dir & "\error.txt"
Global $member_log = $log_dir & "\members.txt"
Global $properties_file = $server_dir & "\server.properties"

; Set Directories
Global $session_dir = $log_dir & "\sessions"

; Create Directories
If Not FileExists($save_dir) Then
   DirCreate($save_dir)
EndIf

If Not FileExists($log_dir) Then
   DirCreate($log_dir)
EndIf

If Not FileExists($session_dir) Then
   DirCreate($session_dir)
EndIf

; Get Properties from server.properties File
_optionsGet($properties_file)

If $verbose_logging == "true" Then
   $verbose_logging = True
ElseIf $verbose_logging = "false" Then
   $verbose_logging = False
Else
   $verbose_logging = False
EndIf