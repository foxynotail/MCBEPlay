$top = $top + $margin
$autosave_label = GUICtrlCreateLabel("Auto Save System: ", $left, $top, $column/2, $row)
GUICtrlSetFont($autosave_label, 8.5, 600 ,0)

$save_label = GUICtrlCreateLabel("Saving in 0h 0m 0s", $left+($column/2), $top, $column/2, $row, $SS_RIGHT)
GUICtrlSetFont($save_label, 8.5, 400 ,0)

$backup_label = GUICtrlCreateLabel("Backing Up in 0h 0m 0s", $left+($column/2), $top+$row, $column/2, $row, $SS_RIGHT)
GUICtrlSetFont($backup_label, 8.5, 400 ,0)

$top = $top + $row
$saveinterval_label = GUICtrlCreateLabel("Backup Inteval: Every " & $backup_interval & " minutes", $left, $top, $column/2, $row)
GUICtrlSetFont($saveinterval_label, 8.5, 400 ,0)

$top = $top + $row
$ls_label = GUICtrlCreateLabel("Last Save: ", $left, $top, $width, $row)
GUICtrlSetFont($ls_label, 8.5, 400 ,0)
$lb_label = GUICtrlCreateLabel("Last Backup: ", $left+($column/2), $top, $width, $row)
GUICtrlSetFont($lb_label, 8.5, 400 ,0)
$top = $top + $row
$ns_label = GUICtrlCreateLabel("Next Save: ", $left, $top, $width, $row)
GUICtrlSetFont($ns_label, 8.5, 400 ,0)
$nb_label = GUICtrlCreateLabel("Next Backup: ", $left+($column/2), $top, $width, $row)
GUICtrlSetFont($nb_label, 8.5, 400 ,0)