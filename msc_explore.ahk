;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MSC Explorer                                                                          ;
; © 2019 Ian Pride - New Pride Software                                                 ;
; View and/or run MSC files found in Windows\System32                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Directives                                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#SingleInstance,Force
SetWorkingDir %A_ScriptDir%
SetBatchLines,-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Vars                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
title := "MSC Explorer"
sys32 := A_WinDir "\System32"
mscArray := []
mscPathsArray := []
mscNameArray := []
clrs := {	"red"		:	"0xF71717"	;
		,	"lightshade":	"0xC7C7C7"	;
		,	"light"		:	"0xE7E7E7"	;
		,	"dark"		:	"0x171717"	;
		,	"shade"		:	"0x000000"	;
		,	"hilight"	:	"0xFFFFFF"	}
OnMessages(	{	0x200	:	"WM_MOUSEMOVE"			;
			,	0x201	:	"WM_LBUTTONDOWN"		;
			,	0x202	:	"WM_LBUTTONUP"			;
			,	0x203	:	"WM_LBUTTONDBLCLK"		;
			,	0x216	:	"WM_MOVING"				})
loop,files,%sys32%\*.msc
	mscArray.Push(A_LoopFileFullPath)
for mscidx, mscfile in mscArray
	mscPathsArray[mscidx] := SplitPath(mscfile)
for mscidx,mscfile in mscPathsArray
	mscNameArray[mscidx] := StrReplace(mscfile.FileName,".msc")
mscidx := mscfile := ""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Menu                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu,Tray,NoStandard
Menu,Tray,Icon,% A_IsCompiled?A_ScriptFullPath:"mmc.exe",,1
Menu,Tray,Tip,%title%
Menu,Tray,Add,&About %title%,About
Menu,Tray,Icon,&About %title%,user32.dll,5,24
Menu,Tray,Add
Menu,Tray,Add,E&xit,MSCGuiGuiClose
Menu,Tray,Icon,E&xit,user32.dll,4,24
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Gui                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MSCGui := New Gui("MSCGui")
MSCGui.Color(clrs.dark,clrs.hilight)
MSCGui.Margin(0,0)
MSCGui.Font("Segoe UI","s14","q2")
MSCGui.CustomButton(title,,clrs.dark,0,0,396,32,clrs.hilight,clrs.light,"HPVar","HTVar","HPHwnd","HTHwnd")
MSCGui.Picture(A_IsCompiled?A_ScriptFullPath:"mmc.exe","x4","y4","+BackgroundTrans","w24","h24")
MSCGui.CustomButton("__",,clrs.dark,300,0,48,32,clrs.light,clrs.light,"_PVar","_TVar","_PHwnd","_THwnd")
MSCGui.CustomButton("X",,clrs.dark,348,0,48,32,clrs.light,clrs.light,"XPVar","XTVar","XPHwnd","XTHwnd")
MSCGui.Font("Segoe UI","s11")
MSCGui.Text("List of MSC (.msc) programs in " sys32,"w" 380,"+Center","c" clrs.light,"x8","Section","y+8","HwndListTxt")
MSCGui.Font("Segoe UI","s10")
MSCGui.ListBox(DelimStrFromArray(,mscNameArray),"r18","xp","y+8","w" 380,"gSelectMsc","vCurrentMsc","AltSubmit","Choose1","+E0x00020000","HwndSelectHwnd")
MSCGui.Submit("NoHide")
MSCGui.Font("Segoe UI","s11")
MSCGui.Text(mscNameArray[CurrentMsc] " Information:","w" 380,"xp","y+8","vnfoTxt","c" clrs.light,"+Center")
MSCGui.Font("Segoe UI","s8")
MSCGui.ListBox(Nfo(mscArray[CurrentMsc]),"r5","xp","y+8","+ReadOnly","w" 380,"vnfoBox","+E0x08000000","+E0x00020000")
MSCGui.Checkbox("&Administrator","xp","y+8","Checked","vadmin","h24","c" clrs.light)
MSCGui.Checkbox("No &ToolTips","x+8","yp","vnott","h24","c" clrs.light)
MSCGui.CustomButton("&Start Selected",,clrs.dark,"+8","p",157,24,clrs.hilight,clrs.light,"StartPVar","StartTVar","StartPHwnd","StartTHwnd")
MSCGui.Picture("user32.dll","Icon5","x+8","yp","w24","h24","gAbout")
MSCGui.Text("","x0","y+0","w" 396)
MSCGui.Options("+LastFound","-Caption","+Border","+OwnDialogs")
MSCGui.Show(title,"AutoSize")

ScriptHwnd := WinExist()
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Hotkeys                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#If WinActive("ahk_id " ScriptHwnd)
Enter::
	SetTimer,RunSelected,-1
return
#If
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Functions                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include msc_explore_funcs.ahk
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Classes                                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include Gui.aclass
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Init - Subs                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SelectMsc:
	MSCGui.Submit("NoHide")
	GuiControl,,nfoTxt,% mscNameArray[CurrentMsc] " Information:"
	GuiControl,,nfoBox,% "|" Nfo(mscArray[CurrentMsc])
return
RunSelected:
	Run(COMSPEC " /k " mscArray[CurrentMsc],sys32 "\","Hide",mscNameArray[CurrentMsc] "PID",admin)
return
MSCGuiGuiClose:
	ExitApp
