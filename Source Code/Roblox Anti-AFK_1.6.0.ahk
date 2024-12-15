#Requires AutoHotkey >=2.0
#SingleInstance Force

; #######################

; Variables

global SettingsExists := IniRead("Settings.ini", "System", "Exists", false)
global RequiredExists := IniRead("Required.ini", "System", "Exists", false)

createDefaultSettings()
createDefaultSettings(*)
{
	global SettingsExists
	global RequiredExists

	if not RequiredExists
	{
		IniWrite(true, "Required.ini", "System", "Exists")
		IniWrite(false, "Required.ini", "Warning", "AcceptedWarning")
	}
	if not SettingsExists
	{
		IniWrite(true, "Settings.ini", "System", "Exists")
		IniWrite(1, "Settings.ini", "Settings", "SoundMode")
	}

	SettingsExists := IniRead("Settings.ini", "System", "Exists", false)
	RequiredExists := IniRead("Required.ini", "System", "Exists", false)
}



global version := "1.6.0"

global MinutesToWait := 15
global SecondsToWait := MinutesToWait * 60
global lastUpdateTime := A_TickCount
global CurrentElapsedTime := 0
global playSounds := IniRead("Settings.ini", "Settings", "SoundMode", 1)
global isActive := 1
global FirstRun := True
global MainUI := ""

global UI_Width := "500"
global UI_Height := "300"
global Min_UI_Width := "500"
global Min_UI_Height := "300"

; Core UI Buttons
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
global CreditsLink := ""
global EditCooldownButton := ""
global ResetCooldownButton := ""
global MainUI_Warning := ""
global EditorButton := ""
global ScriptDirButton := ""

; Extras Menu
global ShowingExtrasUI := false 

global OpenExtrasLabel := ""
global CloseExtrasButton := ""
global GitHubLink := ""
global DonationLink := ""
global DiscordLink := ""

; Light/Dark mode colors
global updateTheme := true

global blnLightMode := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
global intWindowColor := (!blnLightMode and updateTheme) and "404040" or "EEEEEE"
global intControlColor := (!blnLightMode and updateTheme) and "606060" or "FFFFFF"
global intProgressBarColor := (!blnLightMode and updateTheme) and "757575" or "dddddd"
global ControlTextColor := (!blnLightMode and updateTheme) and "FFFFFF" or "000000"
global linkColor := (!blnLightMode and updateTheme) and "99c3ff" or "4787e7"
global currentTheme := blnLightMode
global lastTheme := currentTheme

global wasActiveWindow := false

global ControlResize := (Target, position, size) => ResizeMethod(Target, position, size)
global MoveControl := (Target, position, size) => MoveMethod(Target, position, size)
global AcceptedWarning := IniRead("Required.ini", "Warning", "AcceptedWarning", createWarningUI())

; ================================================= ;
global clamp := (n, low, hi) => Min(Max(n, low), hi)
; ================================================= ;

createWarningUI(*)
{
	local accepted := IniRead("Required.ini", "Warning", "AcceptedWarning", false)
	if accepted
	{
		if MainUI_Warning
			MainUI_Warning.Destroy()
		if not MainUI
			return CreateGui()
		return
	}

	; Global Variables
	global blnLightMode := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	global MainUI_Warning := Gui("")
	MainUI_Warning.BackColor := intWindowColor

	; Local Variables
	local UI_Width_Warning := "1200"
	local UI_Height_Warning := "100"

	; Colors
	global blnLightMode := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	global intWindowColor := (!blnLightMode and updateTheme) and "404040" or "EEEEEE"
	global intControlColor := (!blnLightMode and updateTheme) and "606060" or "FFFFFF"
	global intProgressBarColor := (!blnLightMode and updateTheme) and "757575" or "dddddd"
	global ControlTextColor := (!blnLightMode and updateTheme) and "FFFFFF" or "000000"
	global linkColor := (!blnLightMode and updateTheme) and "99c3ff" or "4787e7"

	; Controls
	local warning_Text_Header := MainUI_Warning.Add("Text","h30 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, "WARNING")
	warning_Text_Header.SetFont("s24 w1000", "Consolas")
	warning_Text_Header.Opt("Center cff4840")
	
    ; ##############################################
    ; Body 1
	local warning_Text_Body1 := MainUI_Warning.Add("Link", "h80 w315", 'This script is provided by')
	warning_Text_Body1.SetFont("s12 w300", "Arial")
	warning_Text_Body1.Opt("c" ControlTextColor)
	
	local JEEBUS_LINK1 := MainUI_Warning.Add("Link", "x+-140 h20 w125 c" linkColor, '<a href="https://www.roblox.com/users/3817884/profile">@WoahItsJeebus</a>')
	JEEBUS_LINK1.SetFont("s12 w300", "Arial")
	LinkUseDefaultColor(JEEBUS_LINK1)

	local warning_Text_Body1_5 := MainUI_Warning.Add("Link", "x+0 h20 w300", 'and is intended solely for the purpose of')
	warning_Text_Body1_5.SetFont("s12 w300", "Arial")
	warning_Text_Body1_5.Opt("c" ControlTextColor)

    ; ###############################################
    ; Body 2
	local warning_Text_Body2 := MainUI_Warning.Add("Link", "y+0 x" MainUI_Warning.MarginX . " h80 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, 'maintaining an active Roblox session while the user can do other tasks simultaneously. This is achieved by periodically activating the first found Roblox process window and clicking the center of the window.')
	warning_Text_Body2.SetFont("s12 w300", "Arial")
	warning_Text_Body2.Opt("c" ControlTextColor)

	local warning_Text_Body3 := MainUI_Warning.Add("Text", "h60 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, 'While Roblox does not typically take action on the use of autoclickers, the rules of some games may prohibit the use of such tools. Use of this script is at your own risk.')
	warning_Text_Body3.SetFont("s12 w500", "Arial")
	warning_Text_Body3.Opt("c" ControlTextColor)

	local SeparationLine := MainUI_Warning.Add("Text", "0x7 h1 w" UI_Width_Warning/2) ; Separation Space
	SeparationLine.BackColor := "0x8"
	
	local important_Text_Body_Part1 := MainUI_Warning.Add("Text", "h20 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, '- Modifying this script in such a way that does not abide by the Roblox')
	important_Text_Body_Part1.SetFont("s12 w600", "Arial")
	important_Text_Body_Part1.Opt("c" ControlTextColor)

	local TOS_Link := MainUI_Warning.Add("Link", "y+-1 h20 w295 c" linkColor, '<a href="https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use">Terms of Service</a>')
	TOS_Link.SetFont("s12 w600", "Arial")
	LinkUseDefaultColor(TOS_Link)

	local important_Text_Body_Part2 := MainUI_Warning.Add("Text", "x+-160 h20 w" UI_Width_Warning/2.75-MainUI_Warning.MarginX, 'can lead to actions taken by the Roblox Corporation')
	important_Text_Body_Part2.SetFont("s12 w600", "Arial")
	important_Text_Body_Part2.Opt("c" ControlTextColor)
	
	local important_Text_Body_Part2_5 := MainUI_Warning.Add("Text", "y+-1 x" MainUI_Warning.MarginX . " h20 w" UI_Width_Warning/2-MainUI_Warning.MarginX, 'including but not limited to account suspension or banning.')
	important_Text_Body_Part2_5.SetFont("s12 w600", "Arial")
	important_Text_Body_Part2_5.Opt("c" ControlTextColor)
	
	local JEEBUS_LINK2 := MainUI_Warning.Add("Link", "h20 w295 c" linkColor, '<a href="https://www.roblox.com/users/3817884/profile">@WoahItsJeebus</a>')
	JEEBUS_LINK2.SetFont("s12 w600", "Arial")
	LinkUseDefaultColor(JEEBUS_LINK2)
	
	local important_Text_Body_Part3 := MainUI_Warning.Add("Text", "x+-155 h20 w" UI_Width_Warning/2.75-MainUI_Warning.MarginX, "is not responsible for any misuse of this script or any")
	important_Text_Body_Part3.SetFont("s12 w600", "Arial")
	important_Text_Body_Part3.Opt("c" ControlTextColor)

	local important_Text_Body_Part3_5 := MainUI_Warning.Add("Text", "y+-1 x" MainUI_Warning.MarginX . " h20 w" UI_Width_Warning/2-MainUI_Warning.MarginX, 'consequences arising from such misuse.')
	important_Text_Body_Part3_5.SetFont("s12 w600", "Arial")
	important_Text_Body_Part3_5.Opt("c" ControlTextColor)

	local important_Text_Body2 := MainUI_Warning.Add("Text", "h40 w" UI_Width_Warning/2-MainUI_Warning.MarginX*2, '`nBy proceeding, you acknowledge and agree to these terms.')
	important_Text_Body2.SetFont("s12 w600", "Arial")
	important_Text_Body2.Opt("Center c" ControlTextColor)
	
	local ok_Button_Warning := MainUI_Warning.Add("Button", "h40 w" UI_Width_Warning/4-MainUI_Warning.MarginX*2, "I AGREE")
	ok_Button_Warning.Move(UI_Width_Warning/7.5)
	ok_Button_Warning.SetFont("s14 w600", "Arial")
	ok_Button_Warning.Opt("c" ControlTextColor . " Background" intWindowColor)
	
	ok_Button_Warning.OnEvent("Click", CloseWarning)
	
	MainUI_Warning.OnEvent("Close", CloseWarning)
	MainUI_Warning.Title := "Roblox Anti-AFK"
	
	CloseWarning(*)
	{
		
		IniWrite(true, "Required.ini", "Warning", "AcceptedWarning")
		
		if not MainUI
			return CreateGui()
	}
	
	; Show UI
	MainUI_Warning.Show("AutoSize Center h500")
}

; ================================================= ;

CreateGui(*)
{
	global version
	global UI_Width := "500"
	global UI_Height := "300"
	global Min_UI_Width := "500"
	global Min_UI_Height := "300"
	
	global playSounds
	global isActive
	
	global MainUI
	global MainUI_Warning
	global EditButton
	global ExitButton
	global CoreToggleButton
	global SoundToggleButton
	global ReloadButton
	global EditCooldownButton
	global EditorButton
	global ScriptDirButton
	
	global WaitProgress
	global WaitTimerLabel
	global ElapsedTimeLabel
	global MinutesToWait
	global ResetCooldownButton

	global CreditsLink
	global OpenExtrasLabel

	global MoveControl
	global ControlResize

	; Colors
	global blnLightMode := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	global intWindowColor := (!blnLightMode and updateTheme) and "404040" or "EEEEEE"
	global intControlColor := (!blnLightMode and updateTheme) and "606060" or "FFFFFF"
	global intProgressBarColor := (!blnLightMode and updateTheme) and "757575" or "dddddd"
	global ControlTextColor := (!blnLightMode and updateTheme) and "FFFFFF" or "000000"
	global linkColor := (!blnLightMode and updateTheme) and "99c3ff" or "4787e7"

	global IntValue := Integer(0)
	
	; Destroy old UI object
	if MainUI
	{
		MainUI.Destroy()
		MainUI := ""
	}
	
	if MainUI_Warning
		MainUI_Warning.Destroy()

	; Create new UI
	global MainUI := Gui() ; Create UI window
	MainUI.BackColor := intWindowColor
	MainUI.OnEvent("Close", CloseApp)
	MainUI.Title := "Roblox Anti-AFK"
	MainUI.SetFont("s14 w500", "Courier New")
	MainUI.Move(, , UI_Width, UI_Height)
	
	local UI_Margin_Width := UI_Width-MainUI.MarginX
	local UI_Margin_Height := UI_Height-MainUI.MarginY
	
	local Header := MainUI.Add("Text", "Section Center cff4840 h100 w" UI_Margin_Width,"`nRoblox Anti-AFK Script — V" version)
	Header.SetFont("s22 w600", "Ink Free")
	
	; ########################
	; 		  Buttons
	; ########################
	; local activeText_Core := isActive and "Enabled" or "Disabled"
	activeText_Core := (isActive == 3 and "Enabled") or (isActive == 2 and "Waiting...") or "Disabled"
	CoreToggleButton := MainUI.Add("Button", "h40 w" UI_Margin_Width/2, "Anti-AFK: " activeText_Core)
	CoreToggleButton.OnEvent("Click", ToggleCore)
	CoreToggleButton.Opt("Background" intWindowColor)

	local activeText_Sound := (playSounds == 1 and "All") or (playSounds == 2 and "Less") or (playSounds == 3 and "None")
	
	SoundToggleButton := MainUI.Add("Button", "x+0 h40 w" UI_Margin_Width/2, "Sounds: " activeText_Sound)
	SoundToggleButton.OnEvent("Click", ToggleSound)
	SoundToggleButton.Opt("Background" intWindowColor)
	
	; ##############################
	
	; Calculate initial control width based on GUI width and margins
	InitialWidth := UI_Width - (2 * UI_Margin_Width)
	;X := 0, Y := 0, UI_Width := 0, UI_Height := 0
	
	; Get the client area dimensions
	MainUI.GetPos(&X, &Y, &UI_Width, &UI_Height)
	NewButtonWidth := (UI_Width - (2 * UI_Margin_Width)) / 3
	
	local pixelSpacing := 5

	; Edit
	EditButton := MainUI.Add("Button","xs h40 w" UI_Margin_Width/3, "Edit Script")
	EditButton.OnEvent("Click", EditApp)
	EditButton.SetFont("s12 w500", "Consolas")
	EditButton.Opt("Background" intWindowColor)
	
	; Reload
	ReloadButton := MainUI.Add("Button", "x+1 h40 w" (UI_Margin_Width/3), "Relaunch Script")
	ReloadButton.OnEvent("Click", ReloadScript)
	ReloadButton.SetFont("s12 w500", "Consolas")
	ReloadButton.Opt("Background" intWindowColor)
	
	; Exit
	ExitButton := MainUI.Add("Button", "x+1 h40 w" (UI_Margin_Width/3), "Close Script")
	ExitButton.OnEvent("Click", CloseApp)
	ExitButton.SetFont("s12 w500", "Consolas")
	ExitButton.Opt("Background" intWindowColor)

	; ###############################
	
	; Editor Selector
	EditorButton := MainUI.Add("Button", "xs h30 w" UI_Margin_Width/2, "Select Script Editor")
	EditorButton.OnEvent("Click", SelectEditor)
	EditorButton.SetFont("s12 w500", "Consolas")
	EditorButton.Opt("Background" intWindowColor)

	; Open Script Directory
	ScriptDirButton := MainUI.Add("Button", "x+0 h30 w" UI_Margin_Width/2, "Open Script Directory")
	ScriptDirButton.OnEvent("Click", OpenScriptDir)
	ScriptDirButton.SetFont("s12 w500", "Consolas")
	ScriptDirButton.Opt("Background" intWindowColor)

	SeparationLine := MainUI.Add("Text", "xs 0x7 h1 w" UI_Margin_Width) ; Separation Space
	SeparationLine.BackColor := "0x8"
	
	; Cooldown Duration
	EditCooldownButton := MainUI.Add("Button", "xs h30 w" UI_Margin_Width, "Edit Cooldown")
	EditCooldownButton.OnEvent("Click", CooldownEditPopup)
	EditCooldownButton.SetFont("s12 w500", "Consolas")
	EditCooldownButton.Opt("Background" intWindowColor)

	; Progress Bar
	WaitTimerLabel := MainUI.Add("Text", "Section Center 0x300 0xC00 h28 w" UI_Margin_Width, "0%")
	WaitProgress := MainUI.Add("Progress", "Section Center h50 w" UI_Margin_Width)
	ElapsedTimeLabel := MainUI.Add("Text", "Section Center 0x300 0xC00 h28 w" UI_Margin_Width, "00:00 / 0 min")
	ElapsedTimeLabel.SetFont("s18 w500", "Consolas")
	WaitTimerLabel.SetFont("s18 w500", "Consolas")
	
	WaitTimerLabel.Opt("Background" intWindowColor . " c" ControlTextColor)
	ElapsedTimeLabel.Opt("Background" intWindowColor . " c" ControlTextColor)
	WaitProgress.Opt("Background" intProgressBarColor)

	
	; Reset Cooldown
	ResetCooldownButton := MainUI.Add("Button", "h30 w" UI_Margin_Width, "Reset")
	ResetCooldownButton.OnEvent("Click", ResetCooldown)
	ResetCooldownButton.SetFont("s12 w500", "Consolas")
	ResetCooldownButton.Opt("Background" intWindowColor)
	; Credits
	CreditsLink := MainUI.Add("Link", "c" linkColor . " Section Left w" UI_Margin_Width/2, 'Created by <a href="https://www.roblox.com/users/3817884/profile">@WoahItsJeebus</a>')
	CreditsLink.SetFont("s12 w700", "Ink Free")
	CreditsLink.Opt("c" linkColor)
	LinkUseDefaultColor(CreditsLink)

	; Version
	OpenExtrasLabel := MainUI.Add("Text", "x+0 Section Right 0x300 0xC00 w" UI_Margin_Width/2, "Extras")
	OpenExtrasLabel.SetFont("s12 w700", "Ink Free")
	OpenExtrasLabel.Opt("c" linkColor)
	OpenExtrasLabel.OnEvent("Click", ToggleExtrasUI)

	; LinkUseDefaultColor(VersionHyperlink)
	
	; Update ElapsedTimeLabel with the formatted time and total wait time in minutes
    UpdateTimerLabel()
	
	
	; ###########################################################
	; #################### Button Formatting ####################
	; ###########################################################
	
	DoResize(*) {
		ControlResize(WaitTimerLabel, 0, 1)
		ControlResize(ElapsedTimeLabel, 0, 1)
		ControlResize(WaitProgress, 0, 1)
		ControlResize(SeparationLine, 0, 1)
		
		ControlResize(EditCooldownButton, 0, 1)
		
		ControlResize(ResetCooldownButton, 0, 1)
		MoveControl(ResetCooldownButton, 3.05, 1)
		
		ControlResize(CoreToggleButton, 0, 2)
		ControlResize(SoundToggleButton, 2.05, 2)
		
		ControlResize(EditorButton, 0, 2)
		ControlResize(ScriptDirButton, 2.05, 2)
		
		ControlResize(EditButton, 0, 3)
		ControlResize(ExitButton, 1.578, 3)
		ControlResize(ReloadButton, 3, 3)
		
		ControlResize(CreditsLink, 0, 2)
		ControlResize(OpenExtrasLabel, 2, 2)
		; ControlResize(VersionHyperlink, 2, 2)
	}
	
	; Define the resize event handler as a separate function
	ResizeScriptControlButtons(*) {
		DoResize()
	}
	
	; ResizeScriptControlButtons()
	; MainUI.OnEvent("Size", ResizeScriptControlButtons)
	MainUI.Show("AutoSize Center")
	
	; ####################################
	
	CreateExtrasGUI()

	; Indicate UI was fully created
	if playSounds == 1
		Loop 2
			SoundBeep(300, 200)
	
	; Listen for theme updates
	loop
	{
		RedrawUserInterface()
		Sleep(100)
	}
}

CreateExtrasGUI(*)
{
	global MoveControl
	global ControlResize
	global UI_Width
	global UI_Height
	global DiscordLink
	global VersionHyperlink
	global CloseExtrasButton
	
	; Create new UI
	global ExtrasUI := Gui("-SysMenu") ; Create UI window
	ExtrasUI.BackColor := intWindowColor
	ExtrasUI.OnEvent("Close", ToggleExtrasUI)
	
	ExtrasUI.Title := "Extras"
	ExtrasUI.SetFont("s14 w500", "Courier New")
	ExtrasUI.Move(, , 500, 300)
	
	local UI_Margin_Width := UI_Width-ExtrasUI.MarginX
	local UI_Margin_Height := UI_Height-ExtrasUI.MarginY
	
	; Discord
	DiscordLink := ExtrasUI.Add("Link", "Center c" linkColor . " h40 w90", '<a href="https://discord.gg/w8QdNsYmbr">Discord</a>')
	DiscordLink.SetFont("s20 w700", "Ink Free")
	DiscordLink.Opt("c" linkColor)
	LinkUseDefaultColor(DiscordLink)
	
	; Version
	VersionHyperlink := ExtrasUI.Add("Link", "x+0 h40 w90", '<a href="https://github.com/WoahItsJeebus/Roblox-Anti-AFK">GitHub</a>')
	VersionHyperlink.SetFont("s20 w700", "Ink Free")
	VersionHyperlink.Opt("c" linkColor)
	LinkUseDefaultColor(VersionHyperlink)

	CloseExtrasButton := ExtrasUI.Add("Button", "h30 w" UI_Margin_Width, "Close")
	CloseExtrasButton.OnEvent("Click", ToggleExtrasUI)
	CloseExtrasButton.SetFont("s12 w500", "Consolas")
	CloseExtrasButton.Opt("Background" intControlColor)

	ControlResize(DiscordLink, 0, 2)
	ControlResize(VersionHyperlink, 2.05, 2)
	ControlResize(CloseExtrasButton, 0, 1)

	ControlResize(CloseExtrasButton, 0, 1)
	MoveControl(CloseExtrasButton, 4.25, 1)
	; ControlResize(DiscordLink, 0, 2)
}

ToggleExtrasUI(*)
{
	global ShowingExtrasUI
	global ExtrasUI

	if not ExtrasUI
		return

	if not ShowingExtrasUI
		ExtrasUI.Show("Center AutoSize")
	else
		ExtrasUI.Hide()
	
	ShowingExtrasUI := not ShowingExtrasUI
}

RedrawUserInterface(*)
{
	global MainUI
	global EditButton
	global ExitButton
	global CoreToggleButton
	global SoundToggleButton
	global ReloadButton
	global EditCooldownButton
	global EditorButton
	global ScriptDirButton

	global WaitProgress
	global WaitTimerLabel
	global ElapsedTimeLabel
	global MinutesToWait
	global VersionHyperlink
	global CreditsLink
	global ResetCooldownButton

	; Colors
	global blnLightMode := RegRead("HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	global intWindowColor := (!blnLightMode and updateTheme) and "404040" or "EEEEEE"
	global intControlColor := (!blnLightMode and updateTheme) and "606060" or "FFFFFF"
	global intProgressBarColor := (!blnLightMode and updateTheme) and "757575" or "dddddd"
	global ControlTextColor := (!blnLightMode and updateTheme) and "FFFFFF" or "000000"
	global linkColor := (!blnLightMode and updateTheme) and "99c3ff" or "4787e7"
	
	global currentTheme := blnLightMode
	global lastTheme
	
	if lastTheme != currentTheme and MainUI
	{
		lastTheme := currentTheme
		MainUI.BackColor := intWindowColor
		
		EditButton.Opt("Background" intWindowColor)
		ExitButton.Opt("Background" intWindowColor)
		CoreToggleButton.Opt("Background" intWindowColor)
		SoundToggleButton.Opt("Background" intWindowColor)
		ReloadButton.Opt("Background" intWindowColor)
		ScriptDirButton.Opt("Background" intWindowColor)
		EditorButton.Opt("Background" intWindowColor)
		EditCooldownButton.Opt("Background" intWindowColor)
		WaitProgress.Opt("Background" intProgressBarColor)
		ResetCooldownButton.Opt("Background" intWindowColor)
		WaitTimerLabel.Opt("Background" intWindowColor . " c" ControlTextColor)
		ElapsedTimeLabel.Opt("Background" intWindowColor . " c" ControlTextColor)

		EditButton.Redraw()
		ExitButton.Redraw()
		CoreToggleButton.Redraw()
		SoundToggleButton.Redraw()
		ReloadButton.Redraw()
		ScriptDirButton.Redraw()
		EditorButton.Redraw()
		WaitProgress.Redraw()
		WaitTimerLabel.Redraw()
		ElapsedTimeLabel.Redraw()
		ResetCooldownButton.Redraw()
		CreditsLink.Opt("c" linkColor)

		; VersionHyperlink.Opt("c" linkColor)
	}
}

CooldownEditPopup(*)
{
	global MinutesToWait
	global SecondsToWait
	global MainUI
	global clamp := (n, low, hi) => Min(Max(n, low), hi)
	
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
	global lastUpdateTime := isActive > 1 and lastUpdateTime or A_TickCount

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
	global CoreToggleButton
	global ElapsedTimeLabel
	global WaitProgress
	global WaitTimerLabel
	global lastUpdateTime := A_TickCount
	
	activeText_Core := (isActive == 3 and "Enabled") or (isActive == 2 and "Waiting...") or "Disabled"
	CoreToggleButton.Text := "Anti-AFK: " activeText_Core
	CoreToggleButton.Redraw()

	if isActive == 2 and getRobloxHWND()
		ToggleCore(,3)
	else if isActive == 3 and not getRobloxHWND()
		ToggleCore(,2)

	; Reset cooldown progress bar
	UpdateTimerLabel()
	WaitProgress.Value := 0
    WaitTimerLabel.Text := Round(WaitProgress.Value, 0) "%"
}

isWaitingForRoblox(*)
{
	global isActive
	
	if isActive == 2 and not getRobloxHWND()
		return true

	return false
}

switchActiveState(*)
{
	global isActive
	; local toggleWithWindowExisting := (getRobloxHWND() and isActive == 1 and 3) or (getRobloxHWND() and isActive == 3 and 1) or 0
	; local toggleWaiting := (isActive == 1 and not getRobloxHWND() and 2) or (isActive == 2 and not getRobloxHWND() and 1) or isFullActive() == 2 and 2 or 0

	; if toggleWithWindowExisting and toggleWithWindowExisting == 3
	; 	isActive := 3
	; else if toggleWaiting and toggleWaiting == 2
	; 	isActive := 2
	; else isActive := 1
	isActive := isActive < 3 and isActive + 1 or 1
	if isActive == 3 and not getRobloxHWND()
		isActive := 1
	return isActive
}	

ToggleCore(optionalControl?, forceState?, *)
{
	; Variables
	global isActive
	global FirstRun

	
	isActive := forceState or switchActiveState()
	; isActive := forceState or (getRobloxHWND() and isActive == 1 and 3) or (getRobloxHWND() and isActive == 3 and 1) or (isActive == 1 and not getRobloxHWND() and 2) or (isActive == 2 and not getRobloxHWND() and 1) or isFullActive() == 2 and 2
	global CoreToggleButton

	activeText_Core := (isActive == 3 and "Enabled") or (isActive == 2 and "Waiting...") or "Disabled"
	CoreToggleButton.Text := "Anti-AFK: " activeText_Core
	CoreToggleButton.Redraw()

	; Reset cooldown
	ResetCooldown()
	
	UpdateTimerLabel()
	; Toggle Timer
	if isActive > 1
	{
		FirstRun := True
		return SetTimer(RunCore, 100)
	}
	else if isActive == 1
		return SetTimer(RunCore, 0)

	; isActive := 1
	ResetCooldown()
	SetTimer(RunCore, 0)
	return
}

ReloadScript(*)
{
	Reload
}

getRobloxHWND(*)
{	
	local RobloxWindows := []
	local windowsVersion_Roblox := WinExist("ahk_exe ApplicationFrameHost.exe") and WinGetTitle(WinExist("ahk_exe ApplicationFrameHost.exe")) = "Roblox" and WinExist("ahk_exe ApplicationFrameHost.exe")
	local websiteVersion_Roblox := WinExist("ahk_exe RobloxPlayerBeta.exe") and WinExist("ahk_exe RobloxPlayerBeta.exe")
	
	if not windowsVersion_Roblox and not websiteVersion_Roblox
		return false
	if websiteVersion_Roblox
		RobloxWindows.Push(websiteVersion_Roblox)
	if windowsVersion_Roblox
		RobloxWindows.Push(windowsVersion_Roblox)

	return RobloxWindows
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

	global wasActiveWindow

	; Check for Roblox process
	if not getRobloxHWND()
		ResetCooldown()
	; 	ToggleCore(, 2)
	
	; Check if the toggle has been switched off
	if isActive == 1
		return
	
	if (FirstRun or WaitProgress.Value >= 100) and getRobloxHWND()
	{
		; Kill FirstRun for automation
		if FirstRun
			FirstRun := False
		
		ResetCooldown()
		
		if playSounds == 1
			RunWarningSound()
		
		if isActive == 1
			return
		
		; Indicate target found with audible beep
		if playSounds == 2
			SoundBeep(2000, 70)
		
		; Get old mouse pos
		MouseGetPos &OldPosX, &OldPosY, &windowID
		
		local wasMinimized := False
		
		;---------------
		; Find and activate Roblox processes
		local robloxProcesses := getRobloxHWND()
		
		if robloxProcesses.Length > 1
		{
			for i,v in robloxProcesses
			{
				ClickRobloxWindows(v)
			}
		}
		else
			ClickRobloxWindows(robloxProcesses[1])
		
		
		; Activate previous application window & reposition mouse
		if not wasActiveWindow
		{
			WinActivate windowID
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

; ###########################################################
; #################### Button Formatting ####################
; ###########################################################


ResizeMethod(TargetButton, optionalX, objInGroup) {
	local parentUI := TargetButton.Gui
	
	; Calculate initial control width based on GUI width and margins
	local X := 0, Y := 0, UI_Width := 0, UI_Height := 0
	local UI_Margin_Width := UI_Width-parentUI.MarginX
	
	; Get the client area dimensions
	parentUI.GetPos(&X, &Y, &UI_Width, &UI_Height)
	NewButtonWidth := (UI_Width - (2 * UI_Margin_Width))
	
	; Prevent negative button widths
	if (NewButtonWidth < UI_Margin_Width/(objInGroup or 1)) {
		NewButtonWidth := UI_Margin_Width/(objInGroup or 1)  ; Set to 0 if the width is negative
	}
	
	OldButtonPosX := 0, OldY := 0, OldWidth := 0, OldHeight := 0
	TargetButton.GetPos(&OldButtonPosX, &OldY, &OldWidth, &OldHeight)
	
	; Move
	TargetButton.Move(optionalX > 0 and 0 + (UI_Width / optionalX) or 0 + parentUI.MarginX, , )
}

MoveMethod(Target, position, size) {
	local parentUI := Target.Gui
	
	local X := 0, Y := 0, UI_Width := 0, UI_Height := 0
	local UI_Margin_Width := UI_Width-parentUI.MarginX
	
	; Calculate initial control width based on GUI width and margins
	X := 0, Y := 0, UI_Width := 0, UI_Height := 0
	
	; Get the client area dimensions
	parentUI.GetPos(&X, &Y, &UI_Width, &UI_Height)
	NewButtonWidth := (UI_Width - (2 * UI_Margin_Width))
	
	; Prevent negative button widths
	if (NewButtonWidth < UI_Margin_Width/(size or 1)) {
		NewButtonWidth := UI_Margin_Width/(size or 1)  ; Set to 0 if the width is negative
	}
	
	OldButtonPosX := 0, OldY := 0, OldWidth := 0, OldHeight := 0
	Target.GetPos(&OldButtonPosX, &OldY, &OldWidth, &OldHeight)
	
	; Resize
	Target.Move(position > 0 and 0 + (UI_Width / position) or 0 + parentUI.MarginX, , position > 0 and 0 + (UI_Width / position) or 0 + parentUI.MarginX)
}

; ###############################
ClickRobloxWindows(process)
{
	global wasActiveWindow := WinActive(process) and true or false
	if not wasActiveWindow
		WinActivate(process)
	
	;---------------
	; Was Roblox the last focused window?
	if not wasActiveWindow
	{
		WinGetPos &WindowX, &WindowY, &Width, &Height, WinGetTitle("A")
		MouseMove Width/2, Height/2, 0
	}
	
	; Click
	Send "{Click 5}"
}


; ###############################
; ########### Sounds ############
; ###############################
RunWarningSound(*)
{

	Loop 3
		{
			if isActive == 1
			break

			if playSounds == 1
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
	local newMode := playSounds < 3 and playSounds + 1 or 1
	IniWrite(newMode, "Settings.ini", "Settings", "SoundMode")
	playSounds := IniRead("Settings.ini", "Settings", "SoundMode", 1)

	local activeText_Sound := (playSounds == 1 and "All") or (playSounds == 2 and "Less") or (playSounds == 3 and "None")
	
	; Setup Sound Toggle Button
	if SoundToggleButton
		SoundToggleButton.Text := "Sounds: " activeText_Sound
	
	return
}


; Extra Functions
LinkUseDefaultColor(CtrlObj, Use := True)
{
	LITEM := Buffer(4278, 0)                  ; 16 + (MAX_LINKID_TEXT * 2) + (L_MAX_URL_LENGTH * 2)
	NumPut("UInt", 0x03, LITEM)               ; LIF_ITEMINDEX (0x01) | LIF_STATE (0x02)
	NumPut("UInt", Use ? 0x10 : 0, LITEM, 8)  ; ? LIS_DEFAULTCOLORS : 0
	NumPut("UInt", 0x10, LITEM, 12)           ; LIS_DEFAULTCOLORS
	While DllCall("SendMessage", "Ptr", CtrlObj.Hwnd, "UInt", 0x0702, "Ptr", 0, "Ptr", LITEM, "UInt") ; LM_SETITEM
	   NumPut("Int", A_Index, LITEM, 4)
	CtrlObj.Opt("+Redraw")
}