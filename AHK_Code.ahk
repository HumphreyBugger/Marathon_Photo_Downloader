#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;Create directories for photo downloads/archiving
Directory_Check_1=%A_ScriptDir%\Photo_Archive
Directory_Check_2=%A_ScriptDir%\Photo_Dump
IfNotExist, %Directory_Check_1%
	{
	FileCreateDir, %Directory_Check_1%
	}
IfNotExist, %Directory_Check_2%
	{
	FileCreateDir, %Directory_Check_2%
	}

;Setup based on previous submission
FileReadLine,Prev_Photos_Starter,%A_ScriptDir%\Photo_Archive\setup.config,1
FileReadLine,Prev_Checks,%A_ScriptDir%\Photo_Archive\setup.config,2

SetTimer,GuiUpdate,500
Gui,Font,s15 cFFFFFF,Calibri
Gui,color,000051
Height:=50
Width1:=300
Width2:=300
xFactor1:=5
xFactor2:=xFactor1+Width1+5
Y_GUI:=5
SubmitWidth:=80

Gui,Add,Text,x%xFactor1% y%Y_GUI% w%Width1% h%Height%,Photo of Interest
Gui,Font,c000000,Calibri
Gui,Add,Edit,vPhoto_Starter x%xFactor2% y%Y_GUI% w%Width2% h%Height% Number,%Prev_Photos_Starter%
Gui,Font,cFFFFFF,Calibri

Y_GUI:=Y_GUI+Height+5
Gui,Add,Text,x%xFactor1% y%Y_GUI% w%Width1% h%Height%,Number of Photos to Check on each side of number (up to 200):
Gui,Font,c000000,Calibri
Gui, Add, Edit,x%xFactor2% y%Y_GUI% w%Width2% h%Height%
Gui,Add,UpDown,vPhotos_To_Check Range1-200 x%xFactor2% y%Y_GUI% w%Width2% h%Height%,%Prev_Checks%
;Not the best edit control, but I'm lazy.

Gui,Font,cFFFFFF,Calibri
Y_GUI:=Y_GUI+5+Height
Height:=20
Gui,Add,Button,gContinueOn Default x5 y%Y_GUI% w600 h100,Submit!
Gui,Show,,Automater
return

ContinueOn:
Gui,Submit
Gui,Destroy
FileDelete,%A_ScriptDir%\Photo_Archive\setup.config
FileAppend,%Photo_Starter%`n%Photos_To_Check%,%A_ScriptDir%\Photo_Archive\setup.config
Underscore_Pos:=0
StringGetPos,Underscore_Pos,Photo_Starter,_
If Underscore_Pos = 0
	{
	MsgBox,There needs to be a group number`, an underscore`, and then the photo number.`nFor example: 3017_038303`nThis can be found in the text below the marathon photo or in the URL.
	Reload
	}
To_RightTrim:=StrLen(Photo_Starter)-Underscore_Pos
StringTrimRight,Photo_Group,Photo_Starter,%To_RightTrim%
To_LeftTrim:=Underscore_Pos+1
StringTrimLeft,Photo_Starter,Photo_Starter,%To_LeftTrim%
Photo_Starter+=0

Starter+=0
Starter:=floor(Photo_Starter-Photos_To_Check)
Num_Photos:=Photos_To_Check*2
First_Pic:=Starter
GoSub,Photo_Download
return

Photo_Download:
If Num_Photos > 1000
	{
	MsgBox,Too many photos... Did you really just edit this script to download more photos? Come on. Have a heart.
	ExitApp
	}
MsgBox,4,Marathon Photo Confirmation,All files are going to be deleted from the following folder. Continue?`n%A_ScriptDir%\Photo_Dump
IfMsgBox No
	{
	MsgBox,Exiting Marathon Photo Downloader
	ExitApp
	}
FileDelete,%A_ScriptDir%\Photo_Dump\*.JPG
Starter_Backup:=Starter
Looper:=0
Gui,Font,s20 cFFFFFF,Calibri
Gui,color,000051
Gui,Add,Text,vPhoto_Text,Downloading Photos... %Looper% of %Num_Photos% downloaded.
Gui,Add,Progress,vPhoto_Progress w300 R0-100
Gui,Show
Loop %Num_Photos%
	{
	Looper+=1
	If Looper > 1000
		{
		MsgBox,Seriously it's too many photos.
		ExitApp
		}
	If Starter <10
		{
		Num_Zeros:=5
		}
	Else
		{
		If Starter <100
			{
			Num_Zeros:=4
			}
		Else
			{
			If Starter <1000
				{
				Num_Zeros:=3
				}
			Else
				{
				If Starter <10000
					{
					Num_Zeros:=2
					}
				Else
					{
					If Starter <100000
						{
						Num_Zeros:=1
						}
					Else
						{
						Num_Zeros:=0
						}
					}
				}
			}
		}
	Starter_URL:=Starter
	Loop %Num_Zeros%
		{
		Starter_URL=0%Starter_URL%
		}
	UrlDownloadToFile,https://fp-zoom-us.s3.amazonaws.com/%Photo_Group%/%Photo_Group%_%Starter_URL%.JPG,%A_ScriptDir%\Photo_Dump\%Photo_Group%_%Starter_URL%.JPG
	Starter+=1
	}
return

GuiUpdate:
Progress_Val:=floor((Looper/Num_Photos)*100)
GuiControl,,Photo_Progress,%Progress_Val%
GuiControl,,Photo_Text,Downloading Photos... %Looper% of %Num_Photos% downloaded.
return

GuiClose:
ExitApp
return
