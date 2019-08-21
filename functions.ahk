;
; Functions
;

;
; Convenience
;

leaderHotkey(keyName := '', funcName := '', options := '') {
  keys := (keyName = '' ?  LEADER : LEADER ' & ' keyName)
  action := (funcName = '' ? Func('MsgBox').Bind(keyName ' was pressed') : funcName)

  Hotkey(keys, action, options)
}

; Pass a file path to an application using Windows shell
runInShell(command, show := true, wait := false) {
  shell := ComObjCreate("WScript.Shell")
  shell.Run(command, show, wait)
}

withSelection(funcName := 'TrayTip') {
  ; Check if argument is function name (String) or reference (Func)
  dataType := Type(funcName)
  func := dataType = 'Func' ? funcName : Func(funcName)
  selection := getActiveSelection()
  
  ; Pass selection to function
  func.Call(selection || 'No selection found')
}

withSelectionOrClipboard(funcName := 'TrayTip') {
  ; Check if argument is function name (String) or reference (Func)
  dataType := Type(funcName)
  func := dataType = 'Func' ? funcName : Func(funcName)
  selection := getActiveSelection()
  
  ; Pass selection or clipboard to function
  func.Call(selection || Clipboard)
}

withActiveUrl(func := 'TrayTip') {
  ; Check if argument is function name (String) or reference (Func)
  dataType := Type(funcName)
  func := dataType = 'Func' ? funcName : Func(funcName)
  url := getActiveUrl()

  if (url) {
    func(url)
  } else {
    failure('No URL found')
  }
}

getActiveSelection() {
  ; Back up and empty clipboard--use as fallback if no selection is found
  oldClipboardData := ClipboardAll()
  oldClipboardText := Clipboard
  Clipboard := ''

  ; Copy selected text to clipboard
  Send('^c')
  ClipWait(0.5)

  ; Save selection and reset clipboard
  selection := Clipboard
  Clipboard := oldClipboardData

  return selection
}

getActiveUrl() {
  ; Focus URL bar using Alt + D
  Send('!d')
  Sleep(50)

  ; Back up and empty clipboard--use as fallback if no selection is found
  oldClipboardData := ClipboardAll()
  oldClipboardText := Clipboard
  Clipboard := ''

  ; Copy selected text to clipboard
  Send('^c')
  ClipWait(0.5)

  ; Save selection and reset clipboard
  url := Clipboard
  Clipboard := oldClipboardData

  return url
}

encodeUriComponent(uri) {
  document := ComObjCreate('HTMLfile')
  document.Write('<body><script>document.write(encodeURIComponent("' uri '"));</script>')
  Return(document.body.innerText)
}

decodeUriComponent(uri) {
  document := ComObjCreate('HTMLfile')
  document.Write('<body><script>document.write(decodeURIComponent("' uri '"));</script>')
  Return(document.body.innerText)
}



;
; Twitch
;

; Open Twitch Stream in VLC or Foobar2000 using StreamLink
openTwitchStream() {
  ; Parse channel name from active URL, selection, or clipboard
  url := getActiveUrl()
  selection := getActiveSelection() || Clipboard
  channel := GetTwitchChannelFromUrl(url) || GetTwitchChannelFromUrl(selection)

  ; If we found a Twitch channel to open
  if (channel) {
    if (GetKeyState('LShift', 'P')) {
      success('Opening Twitch video')
      openTwitchStreamVideo(channel)
    } else {
      success('Opening Twitch audio')
      openTwitchStreamAudio(channel)
    }
  } else {
    failure('Invalid Twitch URL')
  }

  ; Restore clipboard
  Clipboard := oldClipboard
}

; Open YouTube video or playlist in VLC or Foobar2000
openYouTubeStream() {
  ; Parse channel name from active URL--try clipboard if no active URL is found
  url := getActiveUrl()

  if (!isValidYouTubeUrl(url)) {
    url := getActiveSelection() || Clipboard
  }

  ; If we found a video or playlist to open
  if (isValidYouTubeUrl(url)) {
    if (GetKeyState('LShift', 'P')) {
      success('Opening YouTube video')
      openYouTubeVideo(url)
    } else {
      success('Opening YouTube audio')
      openYouTubeAudio(url)
    }
  } else {
    failure('Invalid YouTube URL')
  }
}

; Open YouTube video or playlist in VLC
openYouTubeVideo(url) {
  runInShell(Format('vlc "{1}"', url))
}

; Open YouTube video or playlist in Foobar2000
openYouTubeAudio(url) {
  runInShell(Format('"{1}" "fy+{2}"', FOOBAR, url))
}

; Open Twitch stream in VLC using StreamLink
openTwitchStreamVideo(channel) {
  runInShell('streamlink twitch.tv/' channel ' best', false)
}

; Open Twitch stream as audio only in Foobar2000 using StreamLink
openTwitchStreamAudio(channel) {
  tmpfile := A_ScriptDir '\tmp.out'
  command := A_ComSpec ' /c streamlink.exe --stream-url twitch.tv/' channel ' audio_only > ' tmpfile

  runInShell(command, 0, true)

  file := FileOpen(tmpfile, 'r')
  url := file.ReadLine()
  file.Close()
  FileDelete(tmpfile)
  
  runInShell(Format('"{1}" "{2}"', FOOBAR, url))
}

; Parse Twitch channel name from URL (with or without 'https://' and 'www')
getTwitchChannelFromUrl(url) {
  channel := ''

  if (isValidTwitchUrl(url)) {
    channel := RegExReplace(url, '^(https?:\/\/)?(www\.)?twitch.tv\/([^/]+)(.*)$', '$3')
  }

  return channel
}

; Validate Twitch channel URL
isValidTwitchUrl(url) {
  return RegExMatch(url, '^(https?:\/\/)?(www\.)?twitch.tv\/.+$')
}

; Validate YouTube URL
isValidYouTubeUrl(url) {
  return RegExMatch(url, '^(https?:\/\/)?(www\.)?youtube.com\/(playlist|watch)?.+$')
}



;
; User interface
;

; Prepare help dialog
buildHelpDialog() {
  dialog := GuiCreate(, HELP_HANDLE)
  dialog.Opt('+LastFound +AlwaysOnTop -Caption +ToolWindow')

  dialog.SetFont('w600 s10', 'Segoe UI')
  dialog.Add('Text', , TITLE)
  dialog.SetFont('w400 s10', 'Segoe UI')
  dialog.Add('Text', , HELP_TEXT)

  dialog.OnEvent('Close', (*) => dialog.Hide())
  dialog.OnEvent('Escape', (*) => dialog.Hide())

  return dialog
}

; Toggle help dialog
toggleHelpDialog() {
  if (WinActive(HELP_HANDLE)) {
    helpDialog.Hide()
  } else {
    helpDialog.Show()
    SetTimer((*) => helpDialog.Hide(), HELP_DURATION * -1000)
  }
}

; Build tray menu with custom items
buildTrayMenu() {
  global colorPickerLastColor
  global ColorMenu
  global TwitchMenu

  ; Twitch submenu
  TwitchMenu := MenuCreate()
  TwitchMenu.Add('&Browse', (*) => runInShell('https://www.twitch.tv/directory'))
  TwitchMenu.Add()
  TwitchMenu.Add('Halocene', (*) => openTwitchStreamAudio('halocene'))
  TwitchMenu.Add('RelaxBeats', (*) => openTwitchStreamAudio('relaxbeats'))
  TwitchMenu.Add()
  TwitchMenu.Add('n0thing', (*) => openTwitchStreamVideo('n0thing'))

  ; Taskbar submenu
  TaskbarMenu := MenuCreate()
  TaskbarMenu.Add('Clean up taskbar', (*) => hideWindowGroupFromTaskbar('HideFromTaskbar'))
  TaskbarMenu.Add('Restore taskbar', (*) => showWindowGroupInTaskbar('HideFromTaskbar'))

  ; Color picker submenu
  ColorMenu := MenuCreate()
  ColorMenu.Add(hexToString(colorPickerLastColor), (*) => Clipboard := hexToString(colorPickerLastColor))
  ColorMenu.Add(hexToRgbString(colorPickerLastColor), (*) => Clipboard := hexToRgbString(colorPickerLastColor))
  ColorMenu.Add('Toggle &picker', (*) => toggleColorPicker())

  ; Tray menu
  A_TrayMenu.Delete()
  A_TrayMenu.Add(A_IconTip, (*) => A_TrayMenu.Show())
  A_TrayMenu.Add('&Reload', (*) => Reload())
  A_TrayMenu.Add('&View', (*) => KeyHistory())
  A_TrayMenu.Add('&Edit', (*) => runInShell(Format('"{1}" "{2}"', EDITOR, A_ScriptDir), false))
  A_TrayMenu.Add()
  A_TrayMenu.Add('&Twitch', TwitchMenu)
  A_TrayMenu.Add('&Reddit', (*) => runInShell('https://www.reddit.com'))
  A_TrayMenu.Add('&HLTV', (*) => runInShell('https://www.hltv.org'))
  A_TrayMenu.Add()
  A_TrayMenu.Add('&Power plan', (*) => runInShell(A_ComSpec ' /c powercfg.cpl', false))
  A_TrayMenu.Add()
  A_TrayMenu.Add('Task&bar', TaskbarMenu)
  A_TrayMenu.Add('&Color picker', ColorMenu)
  A_TrayMenu.Add('&Inspector', (*) => toggleInspector())
  A_TrayMenu.Add()
  A_TrayMenu.Add('Help', (*) => toggleHelpDialog())
  A_TrayMenu.Add('&Exit', (*) => ExitApp(0))
  A_TrayMenu.ClickCount := 1
  A_TrayMenu.Default := '1&'
}

updateTrayMenu() {
  global colorPickerLastColor
  global ColorMenu
  global TwitchMenu

  ColorMenu.Rename('1&', hexToString(colorPickerLastColor))
  ColorMenu.Rename('2&', hexToRgbString(colorPickerLastColor))
}

; Show success notification in tray
success(message) {
  TrayTip('' , message, 'Mute')

  ; Hide after delay (negative value means timer only runs once)
  SetTimer('hideNotification', TRAY_NOTIFICATION_DURATION * -1000)
}

; Show failure notification in tray
failure(message) {
  TrayTip('' , message, 'Mute')

  ; Hide after delay (negative value means timer only runs once)
  SetTimer('hideNotification', TRAY_NOTIFICATION_DURATION * -1000)
}

; Hides any visible tray notification
hideNotification() {
  TrayTip() ; Attempt to hide it the normal way

  if (SubStr(A_OSVersion,1,3) = '10.') {
      A_IconHidden := true
      Sleep(200)
      A_IconHidden := false
  }
}

;
; Windows features
;

toggleTaskView() {
  runInShell('explorer.exe shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}')
}

; Hide taskbar icons for windows matching the window group
;   Source from https://lexikos.github.io/v2/docs/commands/DllCall.htm#ExTaskbar
hideWindowGroupFromTaskbar(group) {
  taskbarList := createTaskbarListComObject()
  windowList := WinGetList('ahk_group ' group)
  deleteTabAddr := vtable(taskbarList, 5)

  Loop(windowList.Count()) {
    DllCall(deleteTabAddr, 'ptr', taskbarList, 'ptr', windowList[A_Index])
  }

  ObjRelease(taskbarList)
}

; Show taskbar icons for windows matching the window group
;   Source from https://lexikos.github.io/v2/docs/commands/DllCall.htm#ExTaskbar
showWindowGroupInTaskbar(group) {
  taskbarList := createTaskbarListComObject()
  windowList := WinGetList( , , 'Program Manager')
  addTabAddr := vtable(taskbarList, 4)

  Loop(windowList.Count()) {
    DllCall(addTabAddr, 'ptr', taskbarList, 'ptr', windowList[A_Index])
  }

  ObjRelease(taskbarList)
}

; Returns initialized TaskbarList object--remember to ObjRelease() it when done
createTaskbarListComObject() {
  Interface := '{56FDF342-FD6D-11d0-958A-006097C9A090}'
  CLSID := '{56FDF344-FD6D-11d0-958A-006097C9A090}'
  
  taskbarList := ComObjCreate(CLSID, Interface)
  hrInitAddr := vtable(taskbarList, 3)

  DllCall(hrInitAddr, 'ptr', taskbarList)
  
  return taskbarList
}

; NumGet(ptr+0) returns the address of the object's virtual function table (vtable for short). The
; remainder of the expression retrieves the address of the nth function's address from the vtable.
vtable(ptr, n) => NumGet(NumGet(ptr+0), n*A_PtrSize)

; Turn off monitors
turnOffMonitors() {
  SendMessage('0x112', '0xF170', 2, , 'Program Manager')
}


;
; Miscellaneous features
;

toggleColorPicker() {
  global colorPickerLastColor
  global colorPickerIsActive

  colorPickerIsActive := !colorPickerIsActive

  if (colorPickerIsActive) {
    SetTimer('updateColorPicker', 5)
    Hotkey('LButton', 'toggleColorPicker', 'On')
    Hotkey('Escape', 'toggleColorPicker', 'On')
    Hotkey(LEADER, 'toggleColorPicker', 'On')
  } else {
    SetTimer('updateColorPicker', 'Delete')
    Hotkey('LButton', 'toggleColorPicker', 'Off')
    Hotkey('Escape', 'toggleColorPicker', 'Off')
    Hotkey(LEADER, 'toggleColorPicker', 'Off')
    
    ToolTip()
    updateTrayMenu()

    Clipboard := hexToString(colorPickerLastColor)
    success('Copied ' hexToString(colorPickerLastColor))
  }
}

updateColorPicker() {
  global colorPickerLastColor

  MouseGetPos(x, y)
  colorPickerLastColor := PixelGetColor(x, y)
  ToolTip(hexToString(colorPickerLastColor), x + 10, y)
}

hexToRgbString(hexColor) {
  red := hexColor >> 16 & 0xFF
  green := hexColor >> 8 & 0xFF
  blue := hexColor & 0xFF

  return Format('rgb({1}, {2}, {3})', red, green, blue)
}

hexToString(hexColor) {
  return StrUpper(Format("#{1:x}", colorPickerLastColor))
}

; Inspect the properties of the window and control under the cursor
toggleInspector(showResultsOnClose := true) {
  global inspectorLastInfo
  global inspectorIsActive

  inspectorIsActive := !inspectorIsActive

  if (inspectorIsActive) {
    SetTimer('updateInspector', 5)

    ; Hotkey(LEADER, 'toggleInspector', 'On')
    Hotkey('Enter', 'toggleInspector', 'On')
    Hotkey('LButton', 'toggleInspector', 'On')
    Hotkey('RButton', Func('toggleInspector').Bind(false), 'On')
    Hotkey('Escape', Func('toggleInspector').Bind(false), 'On')
  } else {
    SetTimer('updateInspector', 'Delete')

    ; Hotkey(LEADER, 'toggleInspector', 'Off')
    Hotkey('Enter', 'toggleInspector', 'Off')
    Hotkey('LButton', 'toggleInspector', 'Off')
    Hotkey('RButton', 'toggleInspector', 'Off')
    Hotkey('Escape', 'toggleInspector', 'Off')
    
    ToolTip()

    logPath := A_ScriptDir '\inspect.log'
    log := FileOpen(logPath, 'w')
    log.Write(inspectorLastInfo)
    log.Close()
    
    ; Open inspection details unless cancelled
    if (showResultsOnClose) {
      runInShell(logPath)
    }
    
    inspectorLastInfo := ''
  }
}

updateInspector() {
  global inspectorLastInfo

  CoordMode('ToolTip', 'Screen')

  MouseGetPos(x, y, windowId, controlId, 2)
  WinGetPos(winX, winY, winWidth, winHeight, 'ahk_id ' windowId)
  ControlGetPos(conX, conY, conWidth, conHeight, controlId, 'ahk_id ' windowId)
  windowInfo := Format('
    (
      Window ID: {1}
      Window Class: {2}
      Window Title: {3}
      Window PID: {4}
      Window Path: {5}
      Window Position: {6}
      Control ID: {7}
      Control ClassNN: {8}
      Control Position: {9}
    )',
    windowId,
    WinGetClass('ahk_id ' windowId),
    WinGetTitle('ahk_id ' windowId),
    WinGetPID('ahk_id ' windowId),
    WinGetProcessPath('ahk_id ' windowId),
    Format('X:{1} Y:{2} W:{3} H:{4}', winX, winY, winWidth, winHeight),
    controlId,
    ControlGetClassNN(controlId, 'ahk_id ' windowId),
    Format('X:{1} Y:{2} W:{3} H:{4}', conX, conY, conWidth, conHeight)
  )

  helpInfo := '
    (

      
Esc or right click to close
Enter, leader, or left click to open results
    )'

  if (windowInfo != inspectorLastInfo) {
    inspectorLastInfo := windowInfo

    ToolTip(inspectorLastInfo helpInfo, 0, 0)
  }
}

isDoubleClick() {
  return A_ThisHotKey = 'LButton' && A_PriorHotKey = A_ThisHotKey && A_TimeSincePriorHotkey < DllCall("GetDoubleClickTime")
}

ifDoubleClick(funcName) {
  if (isDoubleClick()) {
    ; Check if argument is function name (String) or reference (Func)
    func := Type(funcName) = 'Func' ? funcName : Func(funcName)
    func.Call()
  } else {
    Send('{LButton}')
  }
}

; Checks if the mouse pointer is hovering over the specified window and
; (optionally) control. If `controlClass` is omitted, it will be ignored. If
; `controlClass` is a string, it will be checked against hovered controls.
; An empty string is a match if no control is being hovered.
mouseIsOver(winTitle, controlClass := false) {
	MouseGetPos(,, win, control)

  windowMatch := WinExist(winTitle) = win
  controlMatch := Type(control) = 'Integer' || control = controlClass

	return windowMatch && controlMatch
}

handleClipboardChange(type) {
  if (DllCall('IsClipboardFormatAvailable', 'uint', 1)) {
    TrayTip('Text copied')
  } else if (DllCall('IsClipboardFormatAvailable', 'uint', 15)) {
    TrayTip('Files copied')
  } else {
    TrayTip('Other content copied')
  }
}

; Improved sleep method using the Windows high resolution performance counter,
; allowing durations shorter than the 10-15 ms possible by the standard
; `Sleep()` function
precisionSleep(duration) {
  DllCall('Winmm\timeBeginPeriod', 'UInt', 3)
  DllCall('Sleep', 'UInt', duration)
  DllCall('Winmm\timeEndPeriod', 'UInt', 3)
}

; OnClipboardChange('handleClipboardChange')