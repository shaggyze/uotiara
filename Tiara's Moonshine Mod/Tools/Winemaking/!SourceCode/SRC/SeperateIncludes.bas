Attribute VB_Name = "modSeperateIncludes"
Option Explicit
Private Const INCLUDE_Seperator$ = vbCrLf & "; ----------------------------------------------------------------------------" & vbCrLf
Private Const INCLUDE_START$ = INCLUDE_Seperator & "; <AUT2EXE INCLUDE-START: "
Private Const INCLUDE_END$ = INCLUDE_Seperator & "; <AUT2EXE INCLUDE-END: "
Private Const INCLUDE_Close$ = ">" & INCLUDE_Seperator
   
Private Const INCLUDE_FirstLine = "#include-once"
Private Const INCLUDE_FirstLine_Len = 13
   
Private Const INCLUDE_REPLACE_START = "#include <"
Private Const INCLUDE_REPLACE_END = ">"
Private IncludeList As New Collection
Private IncludeListCount&
Private IncludeFileName As New ClsFilename

Dim Str As StringReader
Dim Level&

Public Sub SeperateIncludes()
   
   FrmMain.log ""
   FrmMain.log "==============================================================="
   FrmMain.log "Seperating Includes of : " & FileName.FileName
   
   
  'Read *.au3 into ScriptData
   Dim ScriptData$
   With File
      .Create FileName.FileName
      ScriptData = .Data
      .CloseFile
   End With
 
' delete old script
'   Kill FileName.FileName
'   FileRename FileName.FileName, FileName.FileName & "_"
   
   
  
 ' Make DirName with scriptname
   With IncludeFileName
      .mvarFileName = FileName.mvarFileName
      .Name = "_" & .Name & "_Seperated\"
      .NameWithExt = ""
   End With
   
   FrmMain.log "  " & Len(ScriptData) & " byte loaded."
   
   
   SeperateIncludes2 ScriptData
   
End Sub


Public Sub SeperateIncludes2(ScriptData$)
   
  '
   Set Str = New StringReader
   Str = ScriptData
   Str.DisableAutoMove = True
   
   Level = 0
   IncludeListCount = 0
   SeperateIncludes_Recursiv INCLUDE_END$
   
   If Level <> 0 Then Err.Raise vbObjectError, , "INCLUDE-START/END unembalanced: (" & Level & " too much) in ScriptData: " & Str & vbCrLf & "ignored: " & Str.FixedString(-1)
   
End Sub


Private Sub SeperateIncludes_Recursiv(ByVal EndSym$)
   
 ' Scan for StartSym until end of String
   Do While Str.EOS = False
      
    ' Test for "; <AUT2EXE INCLUDE-START: "
      If INCLUDE_START$ = Str.FixedString(Len(INCLUDE_START$)) Then

       ' Set Script Cut Position
         Dim ScriptCutPos_Start&
         ScriptCutPos_Start = Str.Position
         
         Str.Move Len(INCLUDE_START$)
       
       ' === Cut out include path ===
         Dim pathStartPos&
         pathStartPos = Str.Position
         
         Dim pathEndPos&
         pathEndPos& = Str.FindString(INCLUDE_Close) ' - Len(INCLUDE_Close)
         
         Dim IncludePath As ClsFilename
         Set IncludePath = New ClsFilename
         IncludePath = Str.FixedString(pathEndPos - pathStartPos)
        
      ' === Generate Output path+name for include ===
      ' Copy Original IncludeName to Output IncludeName + Create Output IncludeName Dir
      ' D:\Program Files\AutoIt3\Include\UpDownConstants.au3 -> C:\myscripts\AutoIt3\Include\UpDownConstants.au3
         Dim IncludePathNew As ClsFilename
         Set IncludePathNew = New ClsFilename
         IncludePathNew.NameWithExt = IncludePath.NameWithExt
        
       'CopyName last two path parts
       ' Example: "D:\Program Files\AutoIt3\Include\" ->  "AutoIt3\Include\"
         Dim PathParts, PathPartsCount
         PathParts = Split(IncludePath.Path, "\")
         PathPartsCount = UBound(PathParts)
         If PathPartsCount > 2 Then
            IncludePathNew.Path = PathParts(PathPartsCount - 2) & "\" & _
                               PathParts(PathPartsCount - 1) & "\"
         ElseIf PathPartsCount > 1 Then
            IncludePathNew.Path = PathParts(PathPartsCount - 1) & "\"
            
         Else
            IncludePathNew.Path = "Inc\"
            
         End If
         
        'First Include is the MainScript - Place it in the ScriptDir
         If IncludeListCount = 0 Then IncludePathNew.Path = ""
         
                               
                              
         Inc IncludeListCount
                               
       ' show IncludeFileName
         FrmMain.log Space(Level) & "#" & IncludeListCount & " " & IncludePath & vbTab & " -> " & IncludePathNew
                               
       ' Make includepath for insert "#include <...>" l
         Dim IncludeLinePath$
         IncludeLinePath = IIf(IncludePathNew.Path Like "AutoIt3\Include\", "", IncludePathNew.Path) & IncludePathNew.NameWithExt
         
        'Add Script path   Example: "AutoIt3\Include\"-> "f:\myscripts\AutoIt3\Include\"
         IncludePathNew.Path = IncludeFileName.Path & IncludePathNew.Path
         IncludePathNew.MakePath
          
          
       ' === Recursiv Call of this function ===
       ' ; ----------------------------------------------------------------------------
       ' ; <AUT2EXE INCLUDE-START: D:\Program Files\AutoIt3\Include\UpDownConstants.au3>
       ' ; ----------------------------------------------------------------------------
         Str.Move Len(INCLUDE_Close) + (pathEndPos - pathStartPos)
         
       ' Store Position to cut out Text later
         Dim ScriptTextStartPos&
         ScriptTextStartPos = Str.Position
         
         Dim newEndSym$
         newEndSym = INCLUDE_END & IncludePath & INCLUDE_Close
         
      '! Recursiv Call of this function !
         Inc Level
         SeperateIncludes_Recursiv newEndSym
         
       ' now the function returned because some
       ' ; ----------------------------------------------------------------------------
       ' ; <AUT2EXE INCLUDE-END: D:\Program Files\AutoIt3\Include\UpDownConstants.au3>
       ' ; ----------------------------------------------------------------------------
       ' were found.
       ' Note: String position pointer is at the beginning
         Dim ScriptTextEndPos&
         ScriptTextEndPos = Str.Position
         
       ' Seek to end of '; <AUT2EXE INCLUDE-END'
         Str.Move Len(newEndSym)
         Dim ScriptCutPos_End&
         ScriptCutPos_End& = Str.Position
                  
         
         Dim tmpstr2$
         Inc ScriptCutPos_Start
         Inc ScriptCutPos_End
         
         
        'Filter out duplicates
         On Error Resume Next
         IncludeList.Add IncludePathNew.FileName, IncludePathNew.FileName
         If (Err = 0) Then
'        If Len(ScriptData) > (6 + INCLUDE_FirstLine_Len) Then
          
          ' Copy include Text(without '; <AUT2EXE INCLUDE' Comments) to ScriptData
            Dim ScriptData$
            Str.Position = ScriptTextStartPos
            ScriptData = INCLUDE_FirstLine & Str.FixedString(ScriptTextEndPos - ScriptTextStartPos)
            
   
          ' show ScriptData
            FrmMain.Txt_Script = ScriptData
          
          ' Save ScriptData to file
            Dim IncludeFile As New FileStream
            With IncludeFile
               .Create IncludePathNew.FileName, True, False, False
               .Data = ScriptData
               .CloseFile
            End With
           
         Else
         
           ' Log
            If Err = 457 Then '"Dieser Schlüssel ist bereits einem Element dieser Auflistung zugeordnet"
               FrmMain.log Space(Level) & "Duplicate Include - Skipped"
            Else
               FrmMain.log Space(Level) & "Unexp. Err: " & Err.Description
            End If
          
         End If

       ' Delete Include from ScriptFile and Replace it with '#include'
         tmpstr2 = Str.mvardata
         Dim IncludeLine$
         IncludeLine = INCLUDE_REPLACE_START & IncludeLinePath & INCLUDE_REPLACE_END
         
         FrmMain.Txt_Script = strCutOut(tmpstr2, ScriptCutPos_Start, ScriptCutPos_End - ScriptCutPos_Start, IncludeLine)
         Str.mvardata = tmpstr2
         
        
        'Seek back where deleting of include text started
         Str.Position = ScriptCutPos_Start

      
    ' Test for "; <AUT2EXE INCLUDE-END: "
      ElseIf EndSym = Str.FixedString(Len(EndSym)) Then ' "; <AUT2EXE INCLUDE-END: "...
           
            Dec Level
            Exit Do

      End If
      
    ' Move to next Position in String to test for '; <AUT2EXE INCLUDE XXX'
      Str.Move 1
      
   Loop
   
End Sub
