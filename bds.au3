#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         FoxyNotail
 Version:Local	 3.5
 Date: 			 14/4/02

 Script Function:
	Lightweight looping script to read STDOUT and poss STDIN to and from Server


#ce ----------------------------------------------------------------------------

Global $script_name = "BDS"
Global $gui = False

; Include Required Files, Includes & Functions
#include "inc/init.au3"
Global $verbose_logging = True

; Check if already open, if open then alert
If WinExists($window_title) Then
   _log("The server is already running", "BDS Starting", True)
   ;MsgBox(48, "Alert", " The server is already running")
   Exit
EndIf

OnAutoItExitRegister(_BDSExit)
_BDSStart()

$delay_timer = TimerInit()
$response_timer = TimerInit()

While 1

   ; Get Stdout from Server
   ; ### 6/2/20 - Made this run every cycle instead of every 250ms
   _BDSProcessOutput()

   ; Check if command has been sent
   _BDSProcessInput()

   ; Do this every 5 seconds
   ; ### 6/2/20 - Made this run every 5s instead of every 250ms
   If TimerDiff($delay_timer) > 5000 Then ; 1 minute
	  _BDSCheckRunning()
	  $delay_timer = TimerInit()
   EndIf

   ; Do this every 1 minute
   ; ### 6/2/20 - Turned this off
   If TimerDiff($response_timer) > 60000 Then ; 2 minutes
	  _BDSCheckResponse()
	  $response_timer = TimerInit()
   EndIf

   Sleep(100)

WEnd
Exit
