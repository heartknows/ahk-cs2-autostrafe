#NoEnv
#SingleInstance Force
#InstallKeybdHook
#InstallMouseHook
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , High
SetBatchLines -1
SendMode Input

DllCall("winmm\timeBeginPeriod", "UInt", 1)

iniPath := A_ScriptDir . "\settings.ini"
LoadSettings()

Menu, Tray, NoStandard
Menu, Tray, Add, Open Dashboard, ShowGui
Menu, Tray, Add
Menu, Tray, Add, Reload, ReloadScript
Menu, Tray, Add, Exit, ExitApp
Menu, Tray, Default, Open Dashboard

currentBoundKey := activationKey
currentPanicKey := panicKey
Hotkey, *$%currentBoundKey%, DoLongjumpStrafe, On
Hotkey, *%currentPanicKey%, DoPanicExit, On

BuildModernGUI()
return

DoPanicExit:
    SendInput {Space up}
    SendInput {LCtrl up}
    SendInput {a up}
    SendInput {d up}
    SendInput {w up}
    SendInput {s up}
    ExitApp
return

DoLongjumpStrafe:
    SendInput {w up}
    SendInput {s up}

    SendInput {LCtrl down}
    SendInput {Space down}
    duckActive := true
    duckStartTime := A_TickCount
    
    if (humanizeEnabled) {
        Random, targetDuckHold, %minDuckHold%, %maxDuckHold%
        Random, keyHold, 15, 25
    } else {
        targetDuckHold := maxDuckHold
        keyHold := 20
    }

    DllCall("Sleep", "UInt", keyHold)
    SendInput {Space up}

    if (humanizeEnabled) {
        Random, curJumpDelay, %minJumpDelay%, %maxJumpDelay%
    } else {
        curJumpDelay := maxJumpDelay
    }

    startJump := A_TickCount
    While (A_TickCount - startJump < curJumpDelay)
    {
        if (!GetKeyState(activationKey, "P"))
            break

        if (duckActive && (A_TickCount - duckStartTime >= targetDuckHold))
        {
            if (!GetKeyState("LCtrl", "P"))
                SendInput {LCtrl up}
            duckActive := false
        }
        DllCall("Sleep", "UInt", 1)
    }

    While GetKeyState(activationKey, "P")
    {
        SendInput {a up}
        SendInput {d down}
        
        if (humanizeEnabled) {
            Random, curDuration, %minStrafeDur%, %maxStrafeDur%
        } else {
            curDuration := maxStrafeDur
        }

        start := A_TickCount
        While (A_TickCount - start < curDuration)
        {
            if (!GetKeyState(activationKey, "P"))
                break 2

            if (duckActive && (A_TickCount - duckStartTime >= targetDuckHold))
            {
                if (!GetKeyState("LCtrl", "P"))
                    SendInput {LCtrl up}
                duckActive := false
            }
            
            if (humanizeEnabled) {
                Random, curTurn, %minTurnPower%, %maxTurnPower%
                jitterY := jitterEnabled ? RanInt(-1, 1) : 0
            } else {
                curTurn := maxTurnPower
                jitterY := 0
            }
            
            DllCall("mouse_event", "UInt", 1, "Int", curTurn, "Int", jitterY, "UInt", 0, "UInt", 0)
            DllCall("Sleep", "UInt", 1)
        }

        SendInput {d up}
        SendInput {a down}
        
        if (humanizeEnabled) {
            Random, curDuration, %minStrafeDur%, %maxStrafeDur%
        } else {
            curDuration := maxStrafeDur
        }

        start := A_TickCount
        While (A_TickCount - start < curDuration)
        {
            if (!GetKeyState(activationKey, "P"))
                break 2

            if (duckActive && (A_TickCount - duckStartTime >= targetDuckHold))
            {
                if (!GetKeyState("LCtrl", "P"))
                    SendInput {LCtrl up}
                duckActive := false
            }
            
            if (humanizeEnabled) {
                Random, curTurn, %minTurnPower%, %maxTurnPower%
                jitterY := jitterEnabled ? RanInt(-1, 1) : 0
            } else {
                curTurn := maxTurnPower
                jitterY := 0
            }
            
            DllCall("mouse_event", "UInt", 1, "Int", -curTurn, "Int", jitterY, "UInt", 0, "UInt", 0)
            DllCall("Sleep", "UInt", 1)
        }
    }

    SendInput {Space up}
    if (!GetKeyState("LCtrl", "P"))
        SendInput {LCtrl up}
    SendInput {a up}
    SendInput {d up}
return

BuildModernGUI() {
    global
    Gui, +AlwaysOnTop -MaximizeBox -MinimizeBox -Caption +Border
    Gui, Color, 181920, 242634
    
    ; Title Bar (Draggable area)
    Gui, Add, Text, x0 y0 w375 h40 Background20222e gGuiMove
    Gui, Font, s11 Bold c6366F1, Segoe UI
    Gui, Add, Text, x20 y10 BackgroundTrans, LJ STRAFE ENGINE
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x175 y12 BackgroundTrans, v2.4 PRO
    
    ; Close Button (✕)
    Gui, Font, s11 Bold c94A3B8, Segoe UI
    Gui, Add, Text, x375 y0 w45 h40 Center Background20222e 0x200 gCloseGui, ✕

    ; Section: Keybinds
    Gui, Font, s9 Bold cA5B4FC, Segoe UI
    Gui, Add, Text, x20 y55 BackgroundTrans, KEY BINDINGS
    
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Text, x25 y85 BackgroundTrans, Activation Key:
    Gui, Add, Button, x170 y80 w220 h28 vBtnAct gRecordActKey, %activationKey%
    
    Gui, Add, Text, x25 y120 BackgroundTrans, Panic Exit Key:
    Gui, Add, Button, x170 y115 w220 h28 vBtnPanic gRecordPanicKey, %panicKey%

    ; Divider
    Gui, Add, Text, x20 y155 w375 h1 0x10

    ; Section: Dynamics & Delays
    Gui, Font, s9 Bold cA5B4FC, Segoe UI
    Gui, Add, Text, x20 y170 BackgroundTrans, TIMINGS & BEHAVIOR
    
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Text, x25 y200 BackgroundTrans, Duck Hold (Ctrl):
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x170 y200 BackgroundTrans, Min
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x200 y195 w55 h24 Number Center vgui_minDuckHold, %minDuckHold%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x270 y200 BackgroundTrans, Max
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x300 y195 w55 h24 Number Center vgui_maxDuckHold, %maxDuckHold%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x365 y200 BackgroundTrans, ms

    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Text, x25 y235 BackgroundTrans, Jump Pre-Delay:
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x170 y235 BackgroundTrans, Min
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x200 y230 w55 h24 Number Center vgui_minJumpDelay, %minJumpDelay%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x270 y235 BackgroundTrans, Max
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x300 y230 w55 h24 Number Center vgui_maxJumpDelay, %maxJumpDelay%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x365 y235 BackgroundTrans, ms

    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Text, x25 y270 BackgroundTrans, Strafe Step Duration:
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x170 y270 BackgroundTrans, Min
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x200 y265 w55 h24 Number Center vgui_minStrafeDur, %minStrafeDur%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x270 y270 BackgroundTrans, Max
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x300 y265 w55 h24 Number Center vgui_maxStrafeDur, %maxStrafeDur%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x365 y270 BackgroundTrans, ms

    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Text, x25 y305 BackgroundTrans, Mouse Turn Force:
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x170 y305 BackgroundTrans, Min
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x200 y300 w55 h24 Number Center vgui_minTurnPower, %minTurnPower%
    Gui, Font, s8 Normal c64748B, Segoe UI
    Gui, Add, Text, x270 y305 BackgroundTrans, Max
    Gui, Font, s9 Normal cE2E8F0, Segoe UI
    Gui, Add, Edit, x300 y300 w55 h24 Number Center vgui_maxTurnPower, %maxTurnPower%

    ; Divider
    Gui, Add, Text, x20 y340 w375 h1 0x10

    ; Humanization Switches
    Gui, Font, s9 Bold cA5B4FC, Segoe UI
    Gui, Add, Text, x20 y355 BackgroundTrans, PROTECTION & RNG
    
    Gui, Font, s9 Normal cCBD5E1, Segoe UI
    Gui, Add, CheckBox, x25 y385 Checked%humanizeEnabled% vgui_humanizeEnabled BackgroundTrans, Enable Dynamic Range (Anti-Pattern)
    Gui, Add, CheckBox, x25 y415 Checked%jitterEnabled% vgui_jitterEnabled BackgroundTrans, Enable Vertical Micro-Jitter (Y-Axis Noise)

    ; Bottom Control Action (Full Width Save)
    Gui, Add, Button, x20 y460 w375 h36 gSaveSettings, SAVE CHANGES
}

GuiMove:
    PostMessage, 0xA1, 2,,, A
return

ShowGui:
    GuiControl,, BtnAct, %activationKey%
    GuiControl,, BtnPanic, %panicKey%
    Gui, Show, w420 h515, LJ Strafe Engine
return

CloseGui:
GuiClose:
GuiEscape:
    Gui, Hide
return

RecordActKey:
    GuiControl,, BtnAct, [ Press key or mouse ]
    captured := CaptureNextInput()
    if (captured != "")
        tempActivationKey := captured
    else
        tempActivationKey := activationKey
    GuiControl,, BtnAct, %tempActivationKey%
return

RecordPanicKey:
    GuiControl,, BtnPanic, [ Press key or mouse ]
    captured := CaptureNextInput()
    if (captured != "")
        tempPanicKey := captured
    else
        tempPanicKey := panicKey
    GuiControl,, BtnPanic, %tempPanicKey%
return

CaptureNextInput() {
    mouseKeys := ["LButton", "RButton", "MButton", "XButton1", "XButton2"]
    KeyWait, LButton

    ih := InputHook("V L1 T10", "{Space}{LAlt}{RAlt}{LControl}{RControl}{LShift}{RShift}{Tab}{Enter}{Esc}{BS}{Del}{Ins}{Home}{End}{PgUp}{PgDn}{Up}{Down}{Left}{Right}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}")
    ih.Start()
    
    Loop
    {
        if (!ih.InProgress)
            break

        for idx, mKey in mouseKeys
        {
            if (GetKeyState(mKey, "P"))
            {
                ih.Stop()
                KeyWait, %mKey%
                return mKey
            }
        }
        Sleep, 10
    }

    if (ih.EndKey != "")
        return ih.EndKey
    if (ih.Input != "")
        return ih.Input
    return ""
}

SaveSettings:
    Gui, Submit, NoHide

    if (tempActivationKey != "")
        activationKey := tempActivationKey
    if (tempPanicKey != "")
        panicKey := tempPanicKey

    Hotkey, *$%currentBoundKey%, Off
    Hotkey, *%currentPanicKey%, Off

    minDuckHold     := gui_minDuckHold
    maxDuckHold     := gui_maxDuckHold
    minJumpDelay    := gui_minJumpDelay
    maxJumpDelay    := gui_maxJumpDelay
    minStrafeDur    := gui_minStrafeDur
    maxStrafeDur    := gui_maxStrafeDur
    minTurnPower    := gui_minTurnPower
    maxTurnPower    := gui_maxTurnPower
    humanizeEnabled := gui_humanizeEnabled
    jitterEnabled   := gui_jitterEnabled

    IniWrite, %activationKey%,   %iniPath%, Settings, activationKey
    IniWrite, %panicKey%,        %iniPath%, Settings, panicKey
    IniWrite, %minDuckHold%,     %iniPath%, Settings, minDuckHold
    IniWrite, %maxDuckHold%,     %iniPath%, Settings, maxDuckHold
    IniWrite, %minJumpDelay%,    %iniPath%, Settings, minJumpDelay
    IniWrite, %maxJumpDelay%,    %iniPath%, Settings, maxJumpDelay
    IniWrite, %minStrafeDur%,    %iniPath%, Settings, minStrafeDur
    IniWrite, %maxStrafeDur%,    %iniPath%, Settings, maxStrafeDur
    IniWrite, %minTurnPower%,    %iniPath%, Settings, minTurnPower
    IniWrite, %maxTurnPower%,    %iniPath%, Settings, maxTurnPower
    IniWrite, %humanizeEnabled%, %iniPath%, Settings, humanizeEnabled
    IniWrite, %jitterEnabled%,   %iniPath%, Settings, jitterEnabled

    currentBoundKey := activationKey
    currentPanicKey := panicKey
    Hotkey, *$%currentBoundKey%, DoLongjumpStrafe, On
    Hotkey, *%currentPanicKey%, DoPanicExit, On

    Gui, Hide
return

LoadSettings() {
    global
    IniRead, activationKey,   %iniPath%, Settings, activationKey, Space
    IniRead, panicKey,        %iniPath%, Settings, panicKey, Delete
    IniRead, minDuckHold,     %iniPath%, Settings, minDuckHold, 45
    IniRead, maxDuckHold,     %iniPath%, Settings, maxDuckHold, 55
    IniRead, minJumpDelay,    %iniPath%, Settings, minJumpDelay, 5
    IniRead, maxJumpDelay,    %iniPath%, Settings, maxJumpDelay, 7
    IniRead, minStrafeDur,    %iniPath%, Settings, minStrafeDur, 55
    IniRead, maxStrafeDur,    %iniPath%, Settings, maxStrafeDur, 75
    IniRead, minTurnPower,    %iniPath%, Settings, minTurnPower, 11
    IniRead, maxTurnPower,    %iniPath%, Settings, maxTurnPower, 16
    IniRead, humanizeEnabled, %iniPath%, Settings, humanizeEnabled, 1
    IniRead, jitterEnabled,   %iniPath%, Settings, jitterEnabled, 1
}

ReloadScript:
    Reload
return

ExitApp:
    ExitApp
return

RanInt(min, max) {
    Random, rand, %min%, %max%
    return rand
}