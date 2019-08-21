;
; NORD's AutoHotkey configuration
;

#Persistent
#SingleInstance Force
#MenuMaskKey VK07
#InstallKeybdHook



;
; Options
;

; Title used in menus, dialogs, and titles/handles
global TITLE := 'NORDcuts'

; Leader/modifier key
global LEADER := 'AppsKey'

; Preferred start directory for terminal emulator
global HOME := 'D:\Code'

; Path to preferred editor
global EDITOR := 'code-insiders'

; Path to preferred terminal emulator
global TERMINAL := 'C:\Users\dnordstrom\AppData\Local\wsltty\bin\mintty.exe --WSL=WLinux --configdir=C:\Users\dnordstrom\AppData\Roaming\wsltty'

; Path to Foobar2000
global FOOBAR := 'C:\Program Files (x86)\foobar2000\foobar2000.exe'

; Path to tray icon file
global TRAY_ICON := A_ScriptDir '\assets\tray.ico'

; Duration of tray notifications
global TRAY_NOTIFICATION_DURATION := 2.3 ; Seconds

; Help dialog content, window handle, and duration before auto-hiding
global HELP_HANDLE := Format('{1} - {2}', TITLE, A_ScriptName)
global HELP_DURATION := 3.3 ; Seconds
global HELP_TEXT := Format('
  (
    date: {1}
    time: {2}
    ts: {3}
  )',
  FormatTime(, A_Tab 'yyyy/dd/MM'),
  FormatTime(, A_Tab 'hh:mm:ss tt'),
  FormatTime(, A_Tab 'yyyyMMddHHmm')
)



;
; Setup
;

; Set working directory, match mode, and hotstring trigger characters
SetWorkingDir(HOME)
SetTitleMatchMode(2)        ; Match anywhere in window title
DetectHiddenWindows('On')   ; Match hidden windows
DetectHiddenText('Off')     ; Match hidden text
Hotstring('EndChars', '`t') ; Only Tab triggers hotstrings
SetNumLockState('AlwaysOff')
SetCapsLockState('AlwaysOff')
SetScrollLockState('AlwaysOff')

; Windows to remove from taskbar
GroupAdd('HideFromTaskbar', 'VLC media player ahk_exe vlc.exe')
GroupAdd('HideFromTaskbar', 'VoiceMeeter ahk_exe voicemeeterpro.exe')
GroupAdd('HideFromTaskbar', 'Voicemeeter.Remote ahk_exe VoicemeeterMacroButtons.exe')

; Remove icons from taskbar
hideWindowGroupFromTaskbar('HideFromTaskbar')

; Color picker last selected value
global colorPickerLastColor := 0xFFFFFF

; Color picker state
global colorPickerIsActive := false

; Build help dialog
global helpDialog := buildHelpDialog()

; Build tray menu
A_IconTip := TITLE
TraySetIcon(TRAY_ICON)
buildTrayMenu()

; Show startup notification
success(TITLE ' on')



;
; Functionality
;

#Include functions.ahk
#Include hotkeys.ahk
#Include hotstrings.ahk
#Include remaps.ahk
