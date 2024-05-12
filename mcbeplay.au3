#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         FoxyNotail
 Version:Local	 3.5
 Date: 			 14/4/02

 Script Function:
	MCBEPlay BDS Server System

#ce ----------------------------------------------------------------------------

Global $script_name = "GUI"
Global $gui = True

; Include Required Files, Includes & Functions
#include "inc/init.au3"

; Check if already open, if open then alert
If WinExists("[GUI] " & $window_title) Then
   MsgBox(48, "Alert", " The server is already running")
   Exit
EndIf

; Check server not running and remove files on start (Incase closed improperly)
If FileExists($working_file) AND Not WinExists($window_title) Then
   FileDelete($working_file)
   FileDelete($member_file)
   FileDelete($error_file)
   FileDelete($command_file)
   FileDelete($response_file)
EndIf

; Setup GUI
#include "gui/init.au3"

#include "gui/func.au3"

; Setup Timers
Local $aTimer = TimerInit()
Local $bTimer = TimerInit()
Local $cTimer = TimerInit()


While 1
   #include "inc/timers.au3"
WEnd
GUIDelete()


#cs ----------------------------------------------------------------------------

We're now going to use StdoutRead and StdinWrite to communicate with the server
We will read the output to a variable and a file every 250ms and split the Console
file when it gets over 1024kb so we're not lagging too much

We're going to call all intensive (working) scripts externally and use
files to indicated if thigs are running i.e. saving_file, stopping_file, restarting_file
etc.
Can we use one file (server_status.txt) and have the contents = offline, busy, idle, error?
And a 2nd file for specific data? (server_process.txt) = starting,restarting,stopping,saving,rollingback
Will busy suffice? I think it will

Update 18-11-19:- Turns out you can't call StdoutRead or StdinWrite using just the PID.
You need to call it from the same script that ran the run function which means we cannot
hook into the server if it's already running and we also cannot use the start_server function
as an external function.

Plan B: We create a very light script(BDS) to start the server and monitor the output to a text file
that is automatically truncated. - DONE
We then use this system to pass data to that script using ControlSend command - Not actually
sure if this will work so we need to check it out. First!
The problem with ControlSend is it simulates keyboard input which means if the server is running
on an active pc, if the user is typing then the keyboard input can be sent to the server
by mistake causing problems.
The ideal solution is to use strinwrite but again, we can only call this from the script
that ran the server. So the alternative is to create a "command.txt" file with a command in
and have the BDS script check for commands.txt file and read it then process into the server
using StdinWrite - DONE


#ce ----------------------------------------------------------------------------