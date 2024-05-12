Func _cleanUp()


   ; House Keeping: Split Logs & Remove logs older than x Days
   _cleanLogs($log_dir, "log-*", 1)
   _cleanLogs($log_dir, "error-*", 1)

EndFunc