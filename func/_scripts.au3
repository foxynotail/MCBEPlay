Func _runScript($script)

   If $debug_mode = False AND FileExists($script & ".exe") Then
	  Return Run($script & ".exe")
   Else
	  Return _RunAU3($script & ".au3")
   EndIf

EndFunc


Func _RunAU3($sFilePath, $sWorkingDir = "", $iShowFlag = @SW_SHOW, $iOptFlag = 0)

   Return Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $sFilePath & '"', $sWorkingDir, $iShowFlag, $iOptFlag)

EndFunc