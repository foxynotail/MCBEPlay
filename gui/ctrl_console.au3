$console_label = GUICtrlCreateLabel("Console Output:", $left, $top, 100, $row)
GUICtrlSetFont($console_label, 8.5, 600 ,0)

$top = $top + $row
$console_edit = GUICtrlCreateEdit("Console Output", $left, $top, $2column, $console_height, $ES_READONLY + $WS_VSCROLL)
GUICtrlSetFont($console_edit, 8.5, 400 ,0, "Lucida Console")
GUICtrlSetBkColor($console_edit, 0xFFFFFF)
GUICtrlSetLimit($console_edit, -1)

$top = $top + $console_height+$margin

$console_input_label = GUICtrlCreateLabel("Console Command: ", $left, $top+4, $column - 200, 25)
GUICtrlSetFont($console_input_label, 8.5, 600 ,0)

$console_input = GUICtrlCreateInput("", $left + $column + $margin - 200, $top-1, $column - 40 + 200, 25)
GUICtrlSetOnEvent($console_input, "_guiConsoleInput")

GUICtrlSetFont($console_input, 8.5, 400 ,0, "Lucida Console")
Local $accelerators[1][2]
	  $accelerators[0][0] = "{ENTER}"
	  $accelerators[0][1] = $console_input

$console_button = GUICtrlCreateButton("Go", $left + $2column - 40 + $margin, $top-1, 25)
GUICtrlSetOnEvent($console_button, "_guiConsoleInputButton")
GUICtrlSetFont($console_button, 8.5, 400 ,0, "")

$top = $top + $row + $margin + $margin