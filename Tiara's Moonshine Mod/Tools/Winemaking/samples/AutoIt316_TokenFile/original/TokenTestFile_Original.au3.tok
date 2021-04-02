;----------------------------------------------------
; TestFile - for AutoIt3 tokens expansions (Decomiler)
;----------------------------------------------------

;PreProcessor
#NoTrayIcon

;AutoItFunction  UserString  Macro 
FileInstall('>>>AUTOIT SCRIPT<<<', @ScriptDir & '\TokenTestFile_Extracted.au3')
Exit

;operators
$Dummy = (1+2-3/4)^2
$Dummy += 1>2<3<>4>=5<=6=7&8
$Dummy -= true==true=true
$Dummy /= 0x1
$Dummy *= 1.123					;Float Number
$Dummy &= 1.5e3					;Float Number
$Dummy = 1234567887654321		;int64 Number

;UserFunction
myfunc($Dummy,$Dummy)

;user Varible
$oShell = ObjCreate("shell.application")    ; Get the Windows Shell Object

;Properties
$oShellWindows=$oShell.windows   


func myfunc($value,$value2)
	dim $Array1[4]
	$Array1[2]=1
	$Dummy = " "" "
	$Dummy = ' " '
	$Dummy = " ' ' """"  "

endfunc

exit
