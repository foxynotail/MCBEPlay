; Get Data From Options File
Func _optionsGet($file)

   Local $options
   $res = _FileReadToArray($file, $options)

   For $i = 1 to UBound($options) -1

	  If StringInStr($options[$i],"=") AND StringLeft($options[$i], 1) <> "#" Then

		 Local $line = StringSplit($options[$i], "=");
		 Local  $key = $line[1];
		 Local  $val = StringStripWS($line[2], 2)

		 ; Strip comments
		 If StringInStr($val, "#") <> 0 Then
			$val_split = StringSplit($val, "#")
			$val = StringStripWS($val_split[1], 2)
		 EndIf

		 ; Swap "-" to "_" [server.properties]
		 $key = StringReplace($key, "-", "_")

		 ; Create Global Variable From Key -> Val
		 Assign($key, $val, $ASSIGN_FORCEGLOBAL)

	  EndIf
   Next
EndFunc