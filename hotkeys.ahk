;
; Leader hotkeys
;   Note: CapsLock is remapped to RShift in Windows registry, so RShift means the physical CapsLock
;   key. LWin is also remapped to RCtrl. This makes the keys more useful when gaming without AHK
;   running, which is good since anti-cheat clients obviously dislike AHK.
;

; Leader only
;   Show tray menu
leaderHotkey(, (*) => A_TrayMenu.Show())

; Leader + F1
;   Show help dialog
leaderHotkey('F1', 'toggleHelpDialog')

; Leader + `
;   Exit script
leaderHotkey('``', (*) =>
  success(TITLE ' off')
  SetTimer(() => ExitApp(0), TRAY_NOTIFICATION_DURATION * -1000)
)

; Leader + Tab
;   Reload script
leaderHotkey('Tab', 'Reload')

; Leader + Enter
;   Open new terminal (Leader + Shift + Enter for command prompt)
leaderHotkey('Enter', (*) => runInShell(GetKeyState('LShift', 'P') ? A_ComSpec : TERMINAL))

; Leader + Escape
;   Open task manager
leaderHotkey('Escape', (*) => runInShell('taskmgr.exe'))

; Leader + R
;   Run active selection (or clipboard as fallback) as command or application
leaderHotkey('r', (*) => withSelectionOrClipboard(content => runInShell('"' content '"', true)))

; Leader + G
;   Search selected or copied text with Google
leaderHotkey('g', (*) => withSelectionOrClipboard(content => runInShell('https://google.com/search?q=' encodeUriComponent(content), true)))

; Leader + Left Click
;   Toggle color picker
leaderHotkey('LButton', 'toggleColorPicker', 'T2')

; Leader + H/J/K/L
;   Vim-style navigation
leaderHotkey('h', (*) => Send("{Left}"))
leaderHotkey('j', (*) => Send("{Down}"))
leaderHotkey('k', (*) => Send("{Up}"))
leaderHotkey('l', (*) => Send("{Right}"))



;
; Twitch
;

Hotkey('IfWinActive', 'Twitch')

; Leader + E
;   Open Twitch stream in VLC (Leader + LShift + E for audio only). If Firefox or Chrome is
;   active, the current URL will be used. If the current URL is not a valid Twitch channel, we check
;   the clipboard content for a valid URL ('twitch.tv/channel', optional 'www' and 'http://').
leaderHotkey('e', 'openTwitchStream')



;
; YouTube
;

Hotkey('IfWinActive', 'YouTube')

; Leader + E
;   Open YouTube video in VLC (Leader + LShift + E for audio in Foobar2000). If Firefox or Chrome is
;   active, the current URL will be used. If the current URL is not a valid YouTube video, we check
;   the clipboard content for a valid URL.
leaderHotkey('e', 'openYouTubeStream')



;
; Visual Studio Code
;

Hotkey('IfWinActive', 'ahk_exe Code - Insiders.exe')

; Leader + B
;   Toggle more UI visibility when toggling sidebar (Ctrl + B to toggle sidebar, Ctrl + Alt + B to
;   toggle activity bar, and Alt + B to toggle status bar)
leaderHotkey('b', (*) => Send('{Ctrl Down}b{Alt Down}b{Ctrl Up}b{Alt Up}'))



;
; VLC Media Player
;

Hotkey('IfWinActive', 'ahk_exe vlc.exe')

Hotkey('$a', (*) => Send('!ia'))  ; A to show advanced controls
Hotkey('$q', (*) => Send('^l'))   ; Q to show playlist
Hotkey('$z', (*) => Send('^h'))   ; Z to show minimal interface

Hotkey('If')



;
; Cursor over taskbar
;

Hotkey('If', (*) => mouseIsOver('ahk_class Shell_TrayWnd', 'MSTaskListWClass1'))

; Control volume by scrolling
Hotkey('WheelUp', (*) => Send('{Volume_Up}'))     ; Scroll up to increase volume
Hotkey('WheelDown', (*) => Send('{Volume_Down}')) ; Scroll up to decrease volume

; Double click taskbar for file explorer
Hotkey('LButton', (*) => ifDoubleClick((*) => Send('#e')))

; Middle click taskbar for file explorer
Hotkey('MButton', (*) => Send('#e'))

Hotkey('If')



;
; Cursor over clock
;

Hotkey('If', (*) => mouseIsOver('ahk_class Shell_TrayWnd', 'TrayClockWClass1'))

; Control volume by scrolling
Hotkey('WheelUp', (*) => ControlSend('^{Up}', , 'VLC media player'))
Hotkey('WheelDown', (*) => ControlSend('^{Down}', , 'VLC media player'))

; Middle click clock for emoji panel
Hotkey('MButton', (*) => Send('#.'))

Hotkey('If')



;
; Other
;

; Alt + Left Click and Drag
;   Move the window that's currently under the cursor
!LButton::
  CoordMode('Mouse', 'Screen')

  MouseGetPos(, , winId) ; Get ID of window under cursor
  WinGetPos(winX, winY, , , 'ahk_id ' winId) ; Get position of window
  MouseGetPos(currentX, currentY) ; Get cursor position on the screen

  relativeX := currentX - winX
  relativeY := currentY - winY

  ; Return if the window is maximized or minimized
  if (WinGetMinMax('ahk_id ' winId) = 0) {
    SetWinDelay(0)

    ; Move window until mouse button is released
    while (GetKeyState('LButton', 'P')) {
      MouseGetPos(currentX, currentY)
      WinMove(currentX - relativeX, currentY - relativeY,,, 'ahk_id ' winId)
    }
  }

  return