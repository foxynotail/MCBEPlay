$top = $margin
$left = $2column + ($margin * 2)

$state_label = GUICtrlCreateLabel("Server State: ", $left, $top, 80, $row)
GUICtrlSetFont($state_label, 8.5, 600 ,0)

$state_label2 = GUICtrlCreateLabel("[OFFLINE] ", $left + 180 , $top, 120, $row, $SS_RIGHT)
GUICtrlSetFont($state_label2, 8.5, 600 ,0)
GUICtrlSetColor($state_label2, $COLOR_BLUE)

$state_label3 = GUICtrlCreateLabel("[IDLE] ", $left + 300 , $top, 40, $row, $SS_RIGHT)
GUICtrlSetFont($state_label3, 8.5, 600 ,0)
GUICtrlSetColor($state_label3, $COLOR_GREEN)

$top = $top + $margin

$top = $top + $row - 5
$button_start = GUICtrlCreateButton("Start", $left, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_start, "_guiStartButton")
$button_stop = GUICtrlCreateButton("Stop", $left+($column/2)+5, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_stop, "_guiStopButton")

$top = $top + $row + $margin
$button_restart = GUICtrlCreateButton("Restart", $left, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_restart, "_guiRestartButton")
$button_save = GUICtrlCreateButton("Save", $left+($column/2)+5, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_save, "_guiSaveButton")

$top = $top + $row + $margin
$button_rollback = GUICtrlCreateButton("Rollback", $left, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_rollback, "_guiRollbackButton")
$button_openfolder = GUICtrlCreateButton("Open Folder", $left+($column/2)+5, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_openfolder, "_guiOpenFolder")

$top = $top + $row + $margin
$button_options = GUICtrlCreateButton("BDS Options", $left, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_options, "_guiOpenOptions")
$button_properties = GUICtrlCreateButton("Server Properties", $left+($column/2)+5, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_properties, "_guiOpenProperties")

$top = $top + $row + $margin
$button_whitelist = GUICtrlCreateButton("Reload Whitelist", $left, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_whitelist, "_guiReloadWhitelistButton")
$button_permissions = GUICtrlCreateButton("Reload Permissions [Broken]", $left+($column/2)+5, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_permissions, "_guiReloadPermissionsButton")

$top = $top + $row + $margin
$button_logs = GUICtrlCreateButton("View Logs", $left, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_logs, "_guiOpenLogs")
$button_saves = GUICtrlCreateButton("View Saves", $left+($column/2)+5, $top, ($column/2)-5)
GUICtrlSetOnEvent($button_saves, "_guiOpenSaves")

$top = $top + $row + $margin
GUICtrlCreateGraphic($left, $top, $column, 1, $SS_GRAYRECT)

; AUTO START SERVER

$top = $top + $margin/2
$autoRollback_checkbox = GUICtrlCreateCheckbox("Auto Rollbacks", $left, $top, $column/2, 30)
GUICtrlSetOnEvent($autoRollback_checkbox, "_guiRollbackCheckbox")
If $rollback = "true" Then
   GUICtrlSetState($autoRollback_checkbox, 1)
Else
   GUICtrlSetState($autoRollback_checkbox, 0)
EndIf

$keepalive_checkbox = GUICtrlCreateCheckbox("Keep Alive Server", $left+($column/2), $top, $column/2, 30)
GUICtrlSetOnEvent($keepalive_checkbox, "_guiKeepaliveCheckbox")
If $keepalive = "true" Then
   GUICtrlSetState($keepalive_checkbox, 1)
Else
   GUICtrlSetState($keepalive_checkbox, 0)
EndIf

$top = $top + $row + $margin+4
GUICtrlCreateGraphic($left, $top, $column, 1, $SS_GRAYRECT)

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked