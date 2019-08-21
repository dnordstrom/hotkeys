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

; Contact details
:o:address::
  (
    Daniel Nordström
    Faktorigatan 7
    853 56 Sundsvall
  )
:o:street::Faktorigatan 7
:o:zip::853 56
:o:city::Sundsvall
:*o:d@::d@mrnordstrom.com

;
; Auto-corrections
;