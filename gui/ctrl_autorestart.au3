
$top = $top + $row
GUICtrlCreateGraphic($left, $top, $column, 1, $SS_GRAYRECT)

$top = $top + $margin
$autorestart_label = GUICtrlCreateLabel("Auto Restart System: ", $left, $top, $column/2, $row)
GUICtrlSetFont($autorestart_label, 8.5, 600 ,0)

$restart_label = GUICtrlCreateLabel("Restarting in 0h 0m 0s", $left+($column/2), $top, $column/2, $row, $SS_RIGHT)
GUICtrlSetFont($restart_label, 8.5, 400 ,0)

If $auto_restart == "interval" Then

   $top = $top + $row
   $restartinterval_label = GUICtrlCreateLabel("Restart Interval: Every " & $restart_interval & " hours", $left, $top, $column, $row)
   GUICtrlSetFont($restartinterval_label, 8.5, 400 ,0)

   $top = $top + $row
   $lr_label = GUICtrlCreateLabel("Last Restart: ", $left, $top, $width, $row)
   GUICtrlSetFont($lr_label, 8.5, 400 ,0)
   $top = $top + $row
   $nr_label = GUICtrlCreateLabel("Next Restart: ", $left, $top, $width, $row)
   GUICtrlSetFont($nr_label, 8.5, 400 ,0)
   $top = $top + $row

Else

   $top = $top + $row

   $r = 1
   $l = $left

   For $i = 0 to UBound($restart_times) -1

	  GUICtrlCreateLabel($restart_times[$i], $l, $top, 50)

	  If $r = 6 Then
		 $l = $left
		 $top = $top + $row
		 $r = 1
	  Else
		 $l = $l + 60
		 $r = $r + 1
	  EndIf

   Next

   $top = $top + $row
   $lr_label = GUICtrlCreateLabel("Last Restart: ", $left, $top, $width, $row)
   GUICtrlSetFont($lr_label, 8.5, 400 ,0)
   $top = $top + $row
   $nr_label = GUICtrlCreateLabel("Next Restart: ", $left, $top, $width, $row)
   GUICtrlSetFont($nr_label, 8.5, 400 ,0)
   $top = $top + $row


EndIf
