#SingleInstance force
#Include functions.ahk

DetectHiddenWindows True

;
; UI
;

global mainWindow := GuiCreate()
global mainWindowTitle := 'ahk_id ' mainWindow.Hwnd
global mainWindowBackground := 'f9f9f9'
global mainWindowTransColor := 'ff00ff'

winWidth :=  600

mainWindow.MarginY := 16
mainWindow.MarginX := 16
mainWindow.Opt('+ToolWindow +0x40000 +AlwaysOnTop -Caption +LastFound')
mainWindow.OnEvent('Escape', (*) => fadeWindow(mainWindowTitle))
mainWindow.BackColor := mainWindowBackground
mainWindow.SetFont('s14 c333333', 'Segoe UI Semilight')

textBox := mainWindow.Add('Edit', 'vTextBox BackgroundFFFFFF w' winWidth)

actionList := mainWindow.Add('ListBox', 'r5 vActionItems w' winWidth) 
actionList.Add(['Reload', 'Edit', 'View'])
actionList.SetFont('s11 c333333', 'Segoe UI Semilight')

;
; Hotkeys
;

Hotkey('F15', (*) => showWindow(mainWindowTitle))

Hotkey('If', (*) => WinActive(mainWindowTitle) && mouseIsOver(mainWindowTitle, ''))
Hotkey('LButton', (*) => dragWindow(mainWindowTitle))
Hotkey('If')

;
; Functions
;

; Fade window to transparent, hide it, and reset transparency values
fadeWindow(winTitle := 'A', duration := 250) {
  if (winTitle := WinExist(winTitle)) {
    win := GuiFromHwnd(winTitle)
    winTitle := 'ahk_id ' winTitle
    transLevel := WinGetTransparent(winTitle) || 255
    fadeDuration := duration
    fadeStep := 5
    fadeIterations := transLevel / fadeStep
    fadeSleepDuration := fadeDuration / fadeIterations

    while (0 <= transLevel -= fadeStep) {
      WinSetTransColor(mainWindowTransColor ' ' transLevel, winTitle)
      precisionSleep(fadeSleepDuration)
    }

    win.Hide()
    WinSetTransColor(mainWindowTransColor ' 255', winTitle)
  }
}

; Restore colors and transparency and show the window
showWindow(mainWindowTitle) {
  if (winId := WinExist(mainWindowTitle)) {
    win := GuiFromHwnd(winId)

    win.Show()
    WinSetTransColor(mainWindowTransColor ' 255', mainWindowTitle)
    WinWaitNotActive(mainWindowTitle)
    fadeWindow(mainWindowTitle)
  }
}

; Move window by left clicking and dragging the window background
dragWindow(winTitle) {
  CoordMode('Mouse', 'Screen')

  MouseGetPos(currentX, currentY, winId, controlClass)
  WinGetPos(winX, winY, , , winTitle)

  relativeX := currentX - winX
  relativeY := currentY - winY

  ; Make sure the right window is clicked and no control clicked
  if (winId = WinExist(winTitle) && controlClass = '') {
    SetWinDelay(0)

    while (GetKeyState('LButton', 'P')) {
      MouseGetPos(currentX, currentY)
      WinMove(currentX - relativeX, currentY - relativeY,,, winTitle)
    }
  }
}