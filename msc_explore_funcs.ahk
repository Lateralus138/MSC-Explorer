About()
{	global
	local i
	if A_IsCompiled
		i := FileInfo(A_ScriptFullPath) 
	else
		i :=	{	"ProductName"		:	title
			,	"ProductVersion"	:	1
			,	"FileVersion"		:	"1.1.21.19"
			,	"LegalCopyright"	:	"© 2019 Ian Pride - New Pride Software"
			,	"FileDescription"	:	"View and/or run MSC files for the Microsoft Management Console (mmc.exe)"}
	MsgBox,8256,About %title%	,	% i.ProductName " V" i.ProductVersion
							.	"`nVersion: " i.FileVersion "`n" i.LegalCopyright
							.	"`n`n" i.FileDescription "`n`nYou can run a file by:`n" A_Tab "Hitting [Enter]`n" A_Tab "Clicking the [Start Selected] button`n" A_Tab "Double clicking an entry"
}
Nfo(file)
{	return DelimStrFromArray(,FileInfoObj(file))
}
FileInfoObj(mscFile)
{	if (FileExist(mscFile) And (SubStr(mscFile,StrLen(mscFile)-3))=".msc")
	{	obj := []
		loop,read,%mscFile%
		{	if (InStr(A_LoopReadLine,"{71E5B33E-1064-11D2-808F-0000F875A9CE}") Or activated)
			{	if InStr(A_LoopReadLine,"</Strings>")
					break
				activated := true
				startIdx++
				if (startIdx<=2)
					continue
				obj.Push(ExtractXmlString(A_LoopReadLine))
			}
		}
		return obj
	}
}
FileInfo(file := "",select := "")
{	data := 0
	if dataSz := DllCall("Version\GetFileVersionInfoSizeW","WStr",file,"Int",0)
	{	if DllCall("Version\GetFileVersionInfoW","WStr",file,"Int",0,"UInt",VarSetCapacity(ret,dataSz),"Str",ret)
		{	if select
			{	if DllCall("Version\VerQueryValueW","Str",ret,"WStr","\StringFileInfo\040904B0\" select,"PtrP",data,"Int",0)
					return StrGet(data,"UTF-16")
			}else
			{	retArray := {}
				for idx, type in	[	"FileDescription"	,	"FileVersion"
									,	"InternalName"		,	"LegalCopyright"
									,	"OriginalFilename"	,	"ProductName"
									,	"ProductVersion"	]
				{	DllCall("Version\VerQueryValueW","Str",ret,"WStr","\StringFileInfo\040904B0\" type,"PtrP",data,"Int",0)
					retArray[type] := StrGet(data,"UTF-16")
				}
				return retArray
			}
		}
	}
}
GetExtension(file)
{	return (SubStr(SubStr(file,-3),1,1)=".")?SubStr(file,-2):""
}
DelimStrFromArray(delim:="|",arrays*)
{	for iidx, iitem in arrays
		if IsObject(iitem)
			for sidx, sitem in iitem
				str.=sitem delim
		else
			str.=iitem delim
	return SubStr(str,1,StrLen(str)-1)
}
Run(target,work_dir:="",opts:="",pidvar:="",admin:=0)
{	global
	local tmpv:=pidvar
	if ! admin
	{	try,run,%target%,%work_dir%,%opts%,%tmpv%
	}else
	{	try,Run *RunAs %target%,%work_dir%,%opts%,%tmpv%
		catch ERR
			return
	}
	return ! ErrorLevel
}
SplitPath(path,array:=0)
{	if FileExist(path)
	{	SplitPath,path,a,b,c,d,e
		return	%	!array
				?	{"FileName":a,"Dir":b,"Extension":c,"NameNoext":d,"Drive":e}
				:	[a,b,c,d,e]
	}
}
ExtractXmlString(string)
{	match = 
(
<String(.*)">
)
	string := RegExReplace(string,match)
	string := StrReplace(string,"</String>")
	string=%string%
	return string
}
quote(string,mode:=0) ; mode defaults to double quotes
{	mode:=!mode?"""":"`'"
	return mode string mode
}
OnMessages(msgObj)
{	if IsObject(msgObj)
	{	for msg, func in msgObj 
			OnMessage(msg,func)
		return 1
	}
}
WM_MOUSEMOVE(args*)
{	global
	static clrSeta,clrSetb,StaticRolling
	MouseGetPos,,,A_WindowId,A_ControlId,2
	MouseGetPos,,,,A_ControlName
	WinTrans := false
	WinSet("Transparent",255,"ahk_id " MSCGui.Hwnd)
	WinSet("Transparent","Off","ahk_id " MSCGui.Hwnd)
	xy := HiLoBytes(args[2])
	if (args[4]=HPHwnd)
	{	if (xy.Low>=300 And xy.Low<=347)
		{	clrSetb := true
			GuiControl,% "+c" clrs.lightshade " Background" clrs.lightshade,%_PHwnd%
			WinSet,Redraw,,ahk_id %_PHwnd%
			WinSet,Redraw,,ahk_id %_THwnd%
		}else
		{	if clrSetb
			{	clrSetb := false
				GuiControl,% "+c" clrs.light " Background" clrs.light,%_PHwnd%
				WinSet,Redraw,,ahk_id %_PHwnd%
				WinSet,Redraw,,ahk_id %_THwnd%
			}	
		}
		if  (xy.Low>=348)
		{	clrSeta := true
			GuiControl,% "+c" clrs.red " Background" clrs.red,%XPHwnd%
			GuiControl,% "+c" clrs.light,%XTHwnd%
			WinSet,Redraw,,ahk_id %XPHwnd%
			WinSet,Redraw,,ahk_id %XTHwnd%
		}else
		{	if clrSeta
			{	clrSeta := false
				GuiControl,% "+c" clrs.light " Background" clrs.light,%XPHwnd%
				GuiControl,% "+c" clrs.dark,%XTHwnd%
				WinSet,Redraw,,ahk_id %XPHwnd%
				WinSet,Redraw,,ahk_id %XTHwnd%
			}	
		}
	}else
	{	if clrSeta
		{	clrSeta := false
			GuiControl,% "+c" clrs.light " Background" clrs.light,%XPHwnd%
			GuiControl,% "+c" clrs.dark,%XTHwnd%
			WinSet,Redraw,,ahk_id %XPHwnd%
			WinSet,Redraw,,ahk_id %XTHwnd%
		}
		if clrSetb
		{	clrSetb := false
			GuiControl,% "+c" clrs.light " Background" clrs.light,%_PHwnd%
			WinSet,Redraw,,ahk_id %_PHwnd%
			WinSet,Redraw,,ahk_id %_THwnd%
		}
	}
}
DecToHex(num){
	If num Is Not Number
		Return
	restore:=A_FormatInteger
	SetFormat,IntegerFast,H
	num+=0
	SetFormat,Integer,%restore%
	Return num
}
WM_LBUTTONDOWN(args*)
{	global
	if (args[4]=HPHwnd)
	{	if (xy.Low>=300 And xy.Low<=347)
		{	WinMinimize,ahk_id %ScriptHwnd%
			return
		}
		if (xy.Low>=348)
		{	AnimateWindowEx(ScriptHwnd,"Hide|Blend",500)
			ExitApp
		}
		PostMessage, 0xA1, 2,,,% "ahk_id " MSCGui.Hwnd
		return
	}
	if (args[4]=StartPHwnd)
	{	AnimateWindowEx(StartPHwnd,"Hide|SlideUp",50)
		AnimateWindowEx(StartTHwnd,"Hide|SlideDown",49)
		AnimateWindowEx(StartTHwnd,"SlideDown",48)
		AnimateWindowEx(StartPHwnd,"SlideUp",47)
		WinSet,Redraw,,ahk_id %StartTHwnd%
		SetTimer,RunSelected,-1
	}
}
WM_MOVING()
{	global
	WinTrans := true
	WinSet("Transparent",127,"ahk_id " MSCGui.Hwnd)
}
WinGet(attrib,win*)
{	id:=WinExist(win[1],win[2],win[3],win[4])
	WinGet,result,%attrib%,% (id?"ahk_id " id:"")
	if (attrib="List")
	{	tmp:=[]
		loop,%result%
			tmp[A_Index]:=result%A_Index%
		result:=tmp
	}
	return result
}
WM_LBUTTONDBLCLK(args*)
{	global
	if (args[4]=SelectHwnd)
		SetTimer,RunSelected,-1
}
WM_LBUTTONUP(args*)
{	global
	MSCGui.Submit("NoHide")
	xy := HiLoBytes(args[2])
	MouseGetPos,mX,mY,mWinId,mCtrlId,2
	if (args[4]=SelectHwnd And !nott)
	{	t := Func("timedToolTip").Bind(	"Start by clicking the " 
									.	quote("Start Selected") " button, "
									.	"double clicking, or hitting [Enter]",,24,mY+8,,"Client")
		SetTimer,%t%,-1500
	}	
}
WinSet(attrib,val:="",w_argV*)
{	if id:=WinExist(w_argV[1],w_argV[2],w_argV[3]w_argV[4])
	{	WinSet,%attrib%,%val%,ahk_id %id%
		return id
	}
}
AnimateWindowEx(hwnd,opts,time:=200)
{	DetectHiddenWindows,On
	if WinExist("ahk_id " hwnd)
	{	DetectHiddenWindows,Off
		options := 0
		optList :=	{	"Activate" 	: 0x00020000,	"Blend" 	: 0x00080000
					,	"Center"   	: 0x00000010,	"Hide" 		: 0x00010000
					,	"RollRight"	: 0x00000001,	"RollLeft"  : 0x00000002
					,	"RollDown" 	: 0x00000004,	"RollUp"   	: 0x00000008
					,	"SlideRight": 0x00040001,	"SlideLeft"	: 0x00040002
					,	"SlideDown"	: 0x00040004,	"SlideUp"	: 0x00040008	}
		loop,parse,opts,|
			options |= optList[A_LoopField]
		return DllCall("AnimateWindow","UInt",hwnd,"Int",time,"UInt",options)	
	}
	DetectHiddenWindows,Off
}
killToolTip(byId:=0)
{	if current_tt:=WinExist("ahk_class tooltips_class32")
	{	if (byId+0)
		{	if (winexist("ahk_id " byId)=current_tt)
			{	winclose,ahk_id %byId%
				return ! winexist("ahk_id " byId)
			}else	return
		}else
		{	winclose,ahk_id %current_tt%
			return ! winexist("ahk_id " current_tt)		
		}	
	}
}
bubbleToolTip(str,x:="",y:="",idx:=1,coordmode:="Screen",addStyles*){
	If (idx>20 Or !(idx+0))
		Return
	If addStyles.MaxIndex()
		For idx, hex in addStyles
			addedS+=hex
	CoordMode,ToolTip,%coordmode%
	ToolTip,% " ",%x%,%y%,%idx%
	id:=WinExist("ahk_class tooltips_class32")
	WinSet,Style,%addedS%+0x94000044,% "ahk_id " WinExist("ahk_id " id)
	ToolTip,%str%,%x%,%y%,%idx%
	CoordMode,ToolTip
	Return id
}
timedToolTip(txt,time:=1500,x:="",y:="",idx:=1,coordmode:="Screen"){
	id:=bubbleToolTip(txt,x,y,idx,coordmode)
	killTip:=Func("killToolTip").Bind(id)
	SetTimer,%killTip%,% "-" time
	return id
}
HiLoBytes(bytes,array:=0)
{	return	!	array
			?	{"High":(bytes>>16) & 0xffff,"Low":bytes & 0xffff}
			:	[(bytes>>16) & 0xffff,bytes & 0xffff]
}