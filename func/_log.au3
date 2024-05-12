Func _log($string, $function_name, $error=False, $important=False)

   If Not IsDeclared("script_name") Then
	  $script_name = "Unknown"
   EndIf

   Local $log_data = "[" & $script_name & "] > [" & $server_title & "] > [" & $function_name & "] > "

   If $error = True OR $important = True OR ($important = False AND $verbose_logging = True) Then

	  _FileWriteLog($log, $log_data & $string) ; log
	  If $gui = True Then
		 _guiWriteToDebug(_NowCalc() & " : " & $log_data & $string, False)
	  EndIf

   EndIf
   If $error = True Then
	  _FileWriteLog($error_log, $log_data & $string) ; log
	  If $gui = True Then
		 _guiWriteToDebug(_NowCalc() & " : " & $log_data & $string, True)
	  EndIf
   EndIf

EndFunc