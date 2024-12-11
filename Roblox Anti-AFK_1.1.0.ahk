; Variables
global version := "1.1.0"

global MinutesToWait := 15
global SecondsToWait := MinutesToWait * 60
global lastUpdateTime := A_TickCount
global CurrentElapsedTime := 0
global playSounds := True
global isActive := False
global MainUI := ""

global UI_Width := "500"
global UI_Height := "300"
global Min_UI_Width := "500"
global Min_UI_Height := "300"

global EditButton := ""
global ExitButton := ""
global CoreToggleButton := ""
global SoundToggleButton := ""
global ReloadButton := ""
global Core_Status_Bar := ""
global Sound_Status_Bar := ""
global WaitProgress := ""
global WaitTimerLabel := ""
global NextCheckTime := ""
global ElapsedTimeLabel := ""
global VersionHyperlink := ""
global EditCooldownButton := ""
global ResetCooldownButton := ""
global MainUI_Warning := ""

global FirstRun := True

clamp := (n, low, hi) => Min(Max(n, low), hi)
; ================================================= ;

createWarningUI(*)
{
	global MainUI_Warning := Gui("")
	
	local UI_Width_Warning := "1200"
	local UI_Height_Warning := "100"
	
	local warning_Text_Header := MainUI_Warning.Add("Text", "h30 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, "WARNING")
	warning_Text_Header.SetFont("s24 w1000", "Consolas")
	warning_Text_Header.Opt("Center cff0000")
	
	local warning_Text_Body := MainUI_Warning.Add("Link", "h80 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, 'This script is provided by <a href="https://www.roblox.com/users/3817884/profile">@WoahItsJeebus</a> and is intended solely for the purpose of maintaining an active Roblox session while the user can do other tasks simultaneously. This is achieved by periodically activating the first found Roblox process window and clicking the center of the window.')
	warning_Text_Body.SetFont("s12 w300", "Arial")
	
	local warning_Text_Body2 := MainUI_Warning.Add("Text", "h60 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, '`nWhile Roblox does not typically take action on the use of autoclickers, the rules of some games may prohibit the use of such tools. Use of this script is at your own risk.')
	warning_Text_Body2.SetFont("s12 w500", "Arial")
	
	local SeparationLine := MainUI_Warning.Add("Text", "0x7 h1 w" UI_Width_Warning/2) ; Separation Space
	SeparationLine.BackColor := "0x8"
	
	local important_Text_Body := MainUI_Warning.Add("Link", "h100 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, '- Modifying this script in such a way that does not abide by the Roblox <a href="https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use">Terms of Service</a> can lead to actions taken by the Roblox Corporation, including but not limited to account suspension or banning.`n- <a href="https://www.roblox.com/users/3817884/profile">@WoahItsJeebus</a> is not responsible for any misuse of this script or any consequences arising from such misuse.')
	important_Text_Body.SetFont("s12 w600", "Arial")
	
	local important_Text_Body2 := MainUI_Warning.Add("Text", "h40 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, '`nBy proceeding, you acknowledge and agree to these terms.')
	important_Text_Body2.SetFont("s12 w600", "Arial")
	important_Text_Body2.Opt("Center")
	; ============================================= ;
	local ok_Button_Warning := MainUI_Warning.Add("Button", "h40 w" UI_Width_Warning/4-MainUI_Warning.MarginX*2, "I AGREE")
	ok_Button_Warning.Move(UI_Width_Warning/7.5)
	ok_Button_Warning.SetFont("s14 w600", "Arial")
	
	ok_Button_Warning.OnEvent("Click", CloseWarning)
	
	MainUI_Warning.OnEvent("Close", CloseWarning)
	MainUI_Warning.Title := "Roblox Anti-AFK Script"
	
	CloseWarning(*)
	{
		MainUI_Warning.Destroy()
		return CreateGui()
	}
	
	; Show UI
	MainUI_Warning.Show("AutoSize Center h500")
}

; ================================================= ;

createWarningUI()

CreateGui(*)
{
	global version
	global MainUI
	global UI_Width
	global UI_Height
	global Min_UI_Width
	global Min_UI_Height
	
	global playSounds
	global isActive
	
	global EditButton
	global ExitButton
	global CoreToggleButton
	global SoundToggleButton
	global ReloadButton
	global EditCooldownButton

	global WaitProgress
	global WaitTimerLabel
	global ElapsedTimeLabel
	global MinutesToWait
	global VersionHyperlink
	global ResetCooldownButton

	global IntValue := Integer(0)
	
	; Destroy old UI object
	if MainUI
	{
		MainUI.Destroy()
		MainUI := ""
	}
	
	; Create new UI
	global MainUI := Gui("+MinSize550x520") ; Create UI window
	MainUI.OnEvent("Close", CloseApp)
	MainUI.Title := "Roblox Anti-AFK Script"
	MainUI.SetFont("s14 w500", "Courier New")
	MainUI.Move(, , UI_Width, UI_Height)
	
	local UI_Margin_Width := UI_Width-MainUI.MarginX
	local UI_Margin_Height := UI_Height-MainUI.MarginY
	
	local Header := MainUI.Add("Text", "Section Center h100 w" UI_Margin_Width,"`nRoblox Anti-AFK Script — V" version)
	Header.SetFont("s22 w600", "Ink Free")
	
	; ########################
	; 		  Buttons
	; ########################
	local activeText_Core
	if isActive
	activeText_Core := "Enabled"
	else
	activeText_Core := "Disabled"
	
	CoreToggleButton := MainUI.Add("Button", "h40 w" UI_Margin_Width/2, "Anti-AFK: " activeText_Core)

	CoreToggleButton.OnEvent("Click", ToggleCore, not isActive)
	
	local activeText_Sound := playSounds and "Unmuted" or activeText_Sound := "Muted"
	
	SoundToggleButton := MainUI.Add("Button", "x+m h40 w" UI_Margin_Width/2, "Sounds: " activeText_Sound)
	SoundToggleButton.OnEvent("Click", ToggleSound)
	
	; ##############################
	
	; Calculate initial control width based on GUI width and margins
	InitialWidth := UI_Width - (2 * UI_Margin_Width)
	X := 0, Y := 0, UI_Width := 0, UI_Height := 0
	
	; Get the client area dimensions
	MainUI.GetPos(&X, &Y, &UI_Width, &UI_Height)
	NewButtonWidth := (UI_Width - (2 * UI_Margin_Width)) / 3
	
	; Edit
	EditButton := MainUI.Add("Button", "Center xs h40 w" UI_Margin_Width/3, "Edit Script")
	EditButton.OnEvent("Click", EditApp)
	EditButton.SetFont("s12 w500", "Consolas")
	
	; Exit
	ExitButton := MainUI.Add("Button", "x+m h40 w" UI_Margin_Width/3 + 6, "Close Script")
	ExitButton.OnEvent("Click", CloseApp)
	ExitButton.SetFont("s12 w500", "Consolas")
	
	; Reload
	ReloadButton := MainUI.Add("Button", "x+m h40 w" UI_Margin_Width/3, "Relaunch Script")
	ReloadButton.OnEvent("Click", ReloadScript)
	ReloadButton.SetFont("s12 w500", "Consolas")
	
	; ###############################
	
	; Editor Selector
	EditorButton := MainUI.Add("Button", "xp xm h30 w" UI_Margin_Width/2, "Select Script Editor")
	EditorButton.OnEvent("Click", SelectEditor)
	EditorButton.SetFont("s12 w500", "Consolas")
	
	; Open Script Directory
	ScriptDirButton := MainUI.Add("Button", "x+m h30 w" UI_Margin_Width/2, "Open Script Directory")
	ScriptDirButton.OnEvent("Click", OpenScriptDir)
	ScriptDirButton.SetFont("s12 w500", "Consolas")
	
	SeparationLine := MainUI.Add("Text", "0x7 h1 w" UI_Margin_Width) ; Separation Space
	SeparationLine.BackColor := "0x8"
	
	; Cooldown Duration
	EditCooldownButton := MainUI.Add("Button", "h30 w" UI_Margin_Width, "Edit Cooldown")
	EditCooldownButton.OnEvent("Click", CooldownEditPopup)
	EditCooldownButton.SetFont("s12 w500", "Consolas")

	; Progress Bar
	WaitTimerLabel := MainUI.Add("Text", "Section Center 0x300 0xC00 h28 w" UI_Margin_Width, "0%")
	WaitProgress := MainUI.Add("Progress", "h50 w" UI_Margin_Width)
	ElapsedTimeLabel := MainUI.Add("Text", "Section Center 0x300 0xC00 h28 w" UI_Margin_Width, "00:00 / 0 min")
	ElapsedTimeLabel.SetFont("s18 w500", "Consolas")
	WaitTimerLabel.SetFont("s18 w500", "Consolas")
	
	; Reset Cooldown
	ResetCooldownButton := MainUI.Add("Button", "h30 w" UI_Margin_Width, "Reset")
	ResetCooldownButton.OnEvent("Click", ResetCooldown)
	ResetCooldownButton.SetFont("s12 w500", "Consolas")

	; Credits
	CreditsLink := MainUI.Add("Link", "Section Left w" UI_Margin_Width/2, 'Created by <a href="https://www.roblox.com/users/3817884/profile">@WoahItsJeebus</a>')
	CreditsLink.SetFont("s12 w700", "Ink Free")	
	
	; Version
	VersionHyperlink := MainUI.Add("Link", "x+m Section Right w" UI_Margin_Width/2, '<a href="https://github.com/WoahItsJeebus/Roblox-Anti-AFK">GitHub</a>')
	VersionHyperlink.SetFont("s12 w700", "Ink Free")
	
	; Update ElapsedTimeLabel with the formatted time and total wait time in minutes
    UpdateTimerLabel()
	
	
	
	
	
	; ###########################################################
	; #################### Button Formatting ####################
	; ###########################################################
	ControlResize(TargetButton, optionalX, objInGroup) {
		local UI_Margin_Width := UI_Width-MainUI.MarginX
		
		; Calculate initial control width based on GUI width and margins
		X := 0, Y := 0, UI_Width := 0, UI_Height := 0
		
		; Get the client area dimensions
		MainUI.GetPos(&X, &Y, &UI_Width, &UI_Height)
		NewButtonWidth := (UI_Width - (2 * UI_Margin_Width))
		
		; Prevent negative button widths
		if (NewButtonWidth < UI_Margin_Width/(objInGroup or 1)) {
			NewButtonWidth := UI_Margin_Width/(objInGroup or 1)  ; Set to 0 if the width is negative
		}
		
		OldButtonPosX := 0, OldY := 0, OldWidth := 0, OldHeight := 0
		TargetButton.GetPos(&OldButtonPosX, &OldY, &OldWidth, &OldHeight)
		
		; Move
		TargetButton.Move(optionalX > 0 and 0 + (UI_Width / optionalX) or 0 + MainUI.MarginX, , )
	}

	ControlMove(TargetButton, optionalX, objInGroup) {
		local UI_Margin_Width := UI_Width-MainUI.MarginX
		
		; Calculate initial control width based on GUI width and margins
		X := 0, Y := 0, UI_Width := 0, UI_Height := 0
		
		; Get the client area dimensions
		MainUI.GetPos(&X, &Y, &UI_Width, &UI_Height)
		NewButtonWidth := (UI_Width - (2 * UI_Margin_Width))
		
		; Prevent negative button widths
		if (NewButtonWidth < UI_Margin_Width/(objInGroup or 1)) {
			NewButtonWidth := UI_Margin_Width/(objInGroup or 1)  ; Set to 0 if the width is negative
		}
		
		OldButtonPosX := 0, OldY := 0, OldWidth := 0, OldHeight := 0
		TargetButton.GetPos(&OldButtonPosX, &OldY, &OldWidth, &OldHeight)
		
		; Resize
		TargetButton.Move(optionalX > 0 and 0 + (UI_Width / optionalX) or 0 + MainUI.MarginX, , optionalX > 0 and 0 + (UI_Width / optionalX) or 0 + MainUI.MarginX)
	}
	
	
	DoResize(*) {
		ControlResize(WaitTimerLabel, 0, 1)
		ControlResize(ElapsedTimeLabel, 0, 1)
		ControlResize(WaitProgress, 0, 1)
		ControlResize(SeparationLine, 0, 1)
		
		ControlResize(EditCooldownButton, 0, 1)
		
		ControlResize(ResetCooldownButton, 0, 1)
		ControlMove(ResetCooldownButton, 3.05, 1)
		
		ControlResize(CoreToggleButton, 0, 2)
		ControlResize(SoundToggleButton, 2.05, 2)
		
		ControlResize(EditorButton, 0, 2)
		ControlResize(ScriptDirButton, 2.05, 2)
		
		ControlResize(EditButton, 0, 3)
		ControlResize(ExitButton, 1.578, 3)
		ControlResize(ReloadButton, 3, 3)
		
		ControlResize(CreditsLink, 0, 2)
		ControlResize(VersionHyperlink, 2, 2)
	}
	
	; Define the resize event handler as a separate function
	ResizeScriptControlButtons(*) {
		DoResize()
	}
	
	ResizeScriptControlButtons()
	MainUI.OnEvent("Size", ResizeScriptControlButtons)
	MainUI.Show("AutoSize Center")
	
	; ####################################
	
	; Indicate loop began
	if playSounds
	{
		Loop 2
		SoundBeep(300, 200)
	}
}

CooldownEditPopup(*)
{
	global MinutesToWait
	global SecondsToWait
	global MainUI

	local InpBox := InputBox("1 - 15 minutes", "Edit Cooldown", "w100 h100")
	
	if InpBox.Result != "Cancel" and IsNumber(InpBox.Value)
	{
		MinutesToWait := clamp((InpBox.Value),1,15)
		SecondsToWait := clamp((InpBox.Value * 60),60,900)
		UpdateTimerLabel()
	}
	else if InpBox.Result != "Cancel" and not IsNumber(InpBox.Value) and InpBox.Value != ""
		MsgBox("Please enter a valid number to update the cooldown!","Cooldown update error","T5")

	return MinutesToWait
}

UpdateTimerLabel(*)
{
	global isActive
	global MinutesToWait
	global ElapsedTimeLabel
	global CurrentElapsedTime
	global lastUpdateTime := isActive and lastUpdateTime or A_TickCount

	; Calculate and update progress bar
    secondsPassed := (A_TickCount - lastUpdateTime) / 1000  ; Convert ms to seconds
    finalProgress := (secondsPassed / SecondsToWait) * 100
	
	; Calculate and format CurrentElapsedTime as MM:SS
    currentMinutes := Floor(secondsPassed / 60)
    currentSeconds := Round(Mod(secondsPassed, 60),0)
	
	CurrentElapsedTime := Format("{:02}:{:02}", currentMinutes, currentSeconds)

	local mins_suffix := MinutesToWait > 1 and "minutes" or "minute"
	ElapsedTimeLabel.Text := CurrentElapsedTime " / " MinutesToWait " " mins_suffix
}

OpenScriptDir(*)
{
	SetWorkingDir A_InitialWorkingDir
	Run '"explorer.exe" "A_WorkingDir"'
}

SelectEditor(*)
{
	Editor := FileSelect(2,, "Select your editor", "Programs (*.exe)")
	RegWrite Format('"{1}" "%L"', Editor), "REG_SZ", "HKCR\AutoHotkeyScript\Shell\Edit\Command"
}

CloseApp(*)
{
	ExitApp
}

EditApp(*)
{
	Edit
}

Roblox_Not_Found(*)
{
	msgBox("Roblox Player not found!`n`nMake sure Roblox is running and you're using one of the following supported Roblox clients:`n`n(RobloxPlayerBeta.exe`nBloxstrap client also supported!)", "Jeebus's Roblox Anti-AFK Script", "T20")
}

ResetCooldown(*)
{
	global isActive
	global CoreToggleButton
	global ElapsedTimeLabel
	global WaitProgress
	global WaitTimerLabel
	global lastUpdateTime := A_TickCount

	; Setup Core Toggle Button
	activeText_Core := (isActive and "Enabled") or "Disabled"
	CoreToggleButton.Text := "Anti-AFK: " activeText_Core
	CoreToggleButton.Redraw()
	
	; Reset cooldown progress bar
	UpdateTimerLabel()
	WaitProgress.Value := 0
    WaitTimerLabel.Text := Round(WaitProgress.Value, 0) "%"
}

ToggleCore(optionalControl?, forceState?, *)
{
	; Variables
	global isActive
	global FirstRun

	isActive := forceState or not isActive
	
	; Reset cooldown
	ResetCooldown()
	
	UpdateTimerLabel()
	; Toggle Timer
	if isActive and getRobloxHWND()
	{
		FirstRun := True
		return SetTimer(RunCore, 100)
	}
	else if not isActive and getRobloxHWND()
		return SetTimer(RunCore, 0)

	isActive := false
	ResetCooldown()
	
	return Roblox_Not_Found()
}

ReloadScript(*)
{
	Reload
}

getRobloxHWND(*)
{	
	local HWID := (WinExist("Roblox") and WinExist("ahk_exe ApplicationFrameHost.exe")) or WinExist("ahk_exe RobloxPlayerBeta.exe") or False	
	return HWID
}

RunCore(*)
{
	global FirstRun
	global MainUI
	global UI_Width
	global UI_Height
	global playSounds
	global isActive
	
	global EditButton
	global ExitButton

	global ReloadButton
	global CoreToggleButton
	
	global lastUpdateTime
	global MinutesToWait
	global SecondsToWait
	global WaitProgress
	global WaitTimerLabel
	global CurrentElapsedTime

	; Check for Roblox process
	if not getRobloxHWND()
	return ToggleCore(, false)
	
	; Check if the toggle has been switched off
	if not isActive
		return
	
	if (FirstRun or WaitProgress.Value >= 100) and getRobloxHWND()
	{
		; Kill FirstRun for automation
		if FirstRun
			FirstRun := False
		
		ResetCooldown()

		if playSounds
			RunWarningSound()
		
		if not isActive
			return
		
		; Indicate target found with audible beep
		if playSounds
		SoundBeep(2000, 70)
		
		; Get old mouse pos
		MouseGetPos &OldPosX, &OldPosY, &windowID
		
		; Local variables
		local wasActiveWindow := False
		local wasMinimized := False
		
		;---------------
		; Find and activate Roblox window
		local robloxProcessID := getRobloxHWND()
		
		if not WinActive(robloxProcessID)
			WinActivate(robloxProcessID)
		else
			wasActiveWindow := True
		
		;---------------
		
		; Was Roblox the last focused window?
		if not wasActiveWindow
		{
			WinGetPos &WindowX, &WindowY, &Width, &Height, WinGetTitle("A")
			MouseMove Width/2, Height/2, 0
		}
		
		; Click
		Send "{Click 5}"
		
		; Activate previous application window & reposition mouse
		WinActivate windowID
		if not wasActiveWindow
		{
			MouseMove OldPosX, OldPosY, 0
		}
		
		WaitProgress.Value := 0
		lastUpdateTime := A_TickCount
	}
	
	; Calculate and progress visuals
    secondsPassed := (A_TickCount - lastUpdateTime) / 1000  ; Convert ms to seconds
    finalProgress := (secondsPassed / SecondsToWait) * 100
	UpdateTimerLabel()

    ; Update UI elements for progress
    WaitProgress.Value := finalProgress
    WaitTimerLabel.Text := Round(WaitProgress.Value, 0) "%"
}

; Sounds
RunWarningSound(*)
{

	Loop 3
		{
			if not isActive
			break

			if playSounds
				SoundBeep(1000, 80)
			else
				break

			Sleep 1000
		}
}

ToggleSound(*)
{
	global playSounds
	global SoundToggleButton
	playSounds := not playSounds
	
	local activeText_Sound := (playSounds and "Unmuted") or "Muted"
	
	; Setup Sound Toggle Button
	if SoundToggleButton
		SoundToggleButton.Text := "Sounds: " activeText_Sound
	
	return
}