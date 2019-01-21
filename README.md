# MSC Explorer
View and/or run MSC files in the Windows\System32 folder for the Microsoft Management Console (mmc.exe)

## Current Release
[MSC Explorer 32 Bit]()<br />
[MSC Explorer 64 Bit]()<br />
[Release Page - Source Files](https://github.com/Lateralus138/MSC-Explorer/releases/latest)

## Example Code - FileInfo() & AnimateWindowEx() - ShowCase
```
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
```
## Motivation

I wanted a better way to view and run MSC files.

## Installation

Portable program (Plans for installer and portable option).


## Test
I have tested on Windows 10 64 Bit

## Contributors

Ian Pride @ faithnomoread@yahoo.com - [Lateralus138] @ New Pride Services 

## License

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

	License provided in gpl.txt

