Attribute VB_Name = "GlobalDefs"
Option Explicit

Public File As New FileStream
'Public FileName As New ClsFilename

Public Const ERR_NO_AUT_EXE& = vbObjectError + &H10
Public Const ERR_NO_OBFUSCATE_AUT& = vbObjectError + &H20

Public Const DE_OBFUSC_TYPE_NOT_OBFUSC& = 0
Public Const DE_OBFUSC_TYPE_VANZANDE& = 1
Public Const DE_OBFUSC_TYPE_ENCODEIT& = 2

Public Const NO_AUT_DE_TOKEN_FILE& = &H100

Public ExtractedFiles As Collection

Public IsCommandlineMode As Boolean
Public IsOpt_QuitWhenFinish As Boolean
Public IsOpt_RunSilent As Boolean





Sub DoEventsSeldom()
   If Rnd < 0.01 Then DoEvents
End Sub

Sub DoEventsVerySeldom()
   If Rnd < 0.00001 Then
      DoEvents
   End If
End Sub



Sub SaveScriptData(ScriptData$)

   With FrmMain
   ' Adding a underscope '_' for lines longer than 2047
   ' so Tidy will not complain
      FrmMain.log "Try to breaks very long lines (about 2000 chars) by adding '_'+<NewLine> ..."
      ScriptData = AddLineBreakToLongLines(Split(ScriptData, vbCrLf))
   
'debug
'FrmMain.Chk_TmpFile.Value = vbChecked
   
    ' overwrite script
      If FrmMain.Chk_TmpFile.Value = vbChecked Then
         FileName.Name = FileName.Name & "_restore"
         .log "Saving script to: " & FileName.FileName
      Else
'         FileDelete FileName.Name
         .log "Save/overwrite script to: " & FileName.FileName
      End If

     
     File.Create FileName.FileName, True, False, False
     File.Position = 0
     File.FixedString(-1) = ScriptData
     File.setEOF
     File.CloseFile
     
      
       
     FrmMain.Txt_Script = ScriptData
     
     .log ""
     .log "Running 'Tidy.exe " & FileName.NameWithExt & "' to improve sourcecode readablity."
     
     Dim cmdline$, parameters$, Logfile$
     cmdline = App.Path & "\Tidy\Tidy.exe"
     parameters = """" & FileName & """" ' /KeepNVersions=1
     .log cmdline & " " & parameters
     
     Dim TidyExitCode&
     TidyExitCode = ShellEx(cmdline, parameters)
     .log "Tidy.exe ExitCode: " & TidyExitCode
   
      Dim TidyBackupFileName As New ClsFilename
      TidyBackupFileName.mvarFileName = FileName.mvarFileName
      TidyBackupFileName.Name = TidyBackupFileName.Name & "_old1"
      
    ' Delete Tidy BackupFile
      If FrmMain.Chk_TmpFile.Value = vbUnchecked Then
         .log "Deleting Tidy BackupFile..." ' & TidyBackupFileName.NameWithExt
         FileDelete TidyBackupFileName.FileName
      End If
     
     

     
     File.Create FileName.FileName
     ScriptData = File.FixedString(-1)
     File.CloseFile
   
     FrmMain.Txt_Script = ScriptData
     
  End With
End Sub

