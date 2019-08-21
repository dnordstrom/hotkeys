;
; Remaps
; For inspecting scan codes and virtual key codes of your keys, I recommend the EK Switch Hitter
; keyboard diagnostics tool (link below), as well as your script's key history view, accessible by
; calling `KeyHistory()`.
;
; Reference:
;   EK Switch Hitter: https://www.majorgeeks.com/files/details/switch_hitter.html

; Keys remapped using Windows scancode map

; Top row:
;   PrintScreen -> F13
;   ScrollLock -> F14
;   Pause
;     Special key with long 6-byte scan code (E1 1D 45 E1 9D C5), making it unsuitable for this
;     method which is limited to 2-byte codes. Using just the first two bytes works, but remaining
;     bytes will be interpreted as an unwanted extra NumLock press that may break functionality.
;     Remapping the NumLock key to 00_00 (disabling it) prevents it from being triggered, but a 
;     00_00 scan code will still be sent. While this prevents initially *setting* the key as a
;     hotkey in some applications (due to only 00_00 is picked up since it's triggered last),
;     it doesn't affect actually *using* the key. E.g. remapping Pause to F15 (and NumLock to 00_00)
;     will send F15 first, then 00_00. To get around this, we can use an on-screen keyboard to
;     initially set the F15 hotkey, or simply strip away the 00_00 using AHK: `$F15::Send('{F15}')`.
;
; Bottom row:
;   RAlt -> F16
;   AppsKey -> F17
;   RCtrl -> F18
;
; Other:
;   CapsLock -> AppsKey

; Restore original function of Windows scancode map keys

; F13::ScrollLock
; F14::CapsLock
; F16::RAlt
; F17::AppsKey
; F18::RCtrl

;
; Unknown keys do nothing (fixes issue with Pause key remapped using scancode map)
;

VKFF::return
