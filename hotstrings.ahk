;
; Hotstrings
;

; Current date
::date::
  Send(FormatTime(, 'dd/MM/yyyy'))
  return

; Current time
::time::
  Send(FormatTime(, 'hh:mm:ss tt'))
  return

; Current timestamp
::ts::
  Send(FormatTime(, 'yyyyMMddHHmm'))
  return
