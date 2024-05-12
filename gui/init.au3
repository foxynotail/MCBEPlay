; GUI VARS
$width = 1060
$height = 600
$column = 340
$row = 20
$margin = 10
$2column = ($column * 2) + $margin
$top = $margin
$left = $margin
$console_height = $row*20

Opt("GUIOnEventMode", 1)

GUICreate("[GUI] " & $window_title, $width, $height)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetFont(8.5,400)

; Console Window
#include "ctrl_console.au3"

; Debug Console
#include "ctrl_debug.au3"

; Controls
#include "ctrl_control.au3"

; AUTO SAVE SYSTEM
#include "ctrl_autosave.au3"

; AUTO RESTART SYSTEM
#include "ctrl_autorestart.au3"

; Members
#include "ctrl_members.au3"



$website_label = GUICtrlCreateLabel("http://foxynotail.com", 10, 582, 150, 18)
GUICtrlSetFont($website_label, 8.5, 400 ,0)
GUICtrlSetColor($website_label, $COLOR_BLUE)
GUICtrlSetOnEvent($website_label, "_webLink")

Func _webLink()
   ShellExecute('http://foxynotail.com')
EndFunc

$youtube_label = GUICtrlCreateLabel("YouTube", 150, 582, 100, 18)
GUICtrlSetFont($youtube_label, 8.5, 400 ,0)
GUICtrlSetColor($youtube_label, $COLOR_BLUE)
GUICtrlSetOnEvent($youtube_label, "_youtubeLink")

Func _youtubeLink()
   ShellExecute('https://www.youtube.com/user/foxynotail')
EndFunc


$discord_label = GUICtrlCreateLabel("Discord", 240, 582, 100, 18)
GUICtrlSetFont($discord_label, 8.5, 400 ,0)
GUICtrlSetColor($discord_label, $COLOR_BLUE)
GUICtrlSetOnEvent($discord_label, "_discordLink")

Func _discordLink()
   ShellExecute('http://discord.gg/BqGKecr')
EndFunc

$copyright_label = GUICtrlCreateLabel("Copyright © 2020, FoxyNoTail", 850, 582, 200, 18, $SS_RIGHT)
GUICtrlSetFont($copyright_label, 8.5, 400 ,0)


GUISetState(@SW_SHOW)

