VERSION 5.00
Begin VB.Form FrmMain 
   Caption         =   "myAut2Exe >The Open Source AutoIT/AutoHotKey script decompiler<"
   ClientHeight    =   9510
   ClientLeft      =   2595
   ClientTop       =   4935
   ClientWidth     =   9345
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   9510
   ScaleWidth      =   9345
   Begin VB.Frame Fr_Options 
      Height          =   855
      Left            =   120
      TabIndex        =   6
      Top             =   8520
      Width           =   9135
      Begin VB.CheckBox Chk_TmpFile 
         Caption         =   "Don't delete temp files (for ex. compressed scriptdata)"
         Height          =   435
         Left            =   120
         TabIndex        =   12
         Top             =   240
         Width           =   2655
      End
      Begin VB.CheckBox Chk_NormalSigScan 
         Caption         =   "Use 'normal' Au3_Signature to find start of script"
         Height          =   195
         Left            =   4920
         TabIndex        =   11
         Top             =   240
         Width           =   3975
      End
      Begin VB.CheckBox Chk_NoDeTokenise 
         Caption         =   "Disable Detokeniser"
         Height          =   195
         Left            =   8760
         TabIndex        =   10
         ToolTipText     =   "Enable that when you decompile AutoItScripts lower than ver 3.1.6"
         Top             =   480
         Visible         =   0   'False
         Width           =   5295
      End
      Begin VB.CheckBox Chk_verbose 
         Caption         =   "Verbose LogOutput"
         Height          =   195
         Left            =   4920
         MaskColor       =   &H8000000F&
         TabIndex        =   9
         Top             =   510
         Width           =   1800
      End
      Begin VB.CheckBox Chk_ForceOldScriptType 
         Caption         =   "Force Old Script Type"
         Height          =   255
         Left            =   2880
         TabIndex        =   8
         Top             =   480
         Value           =   2  'Zwischenzustand
         Width           =   3255
      End
      Begin VB.CheckBox Chk_RestoreIncludes 
         Caption         =   "Restore Includes"
         Height          =   195
         Left            =   2880
         TabIndex        =   7
         Top             =   240
         Value           =   1  'Aktiviert
         Width           =   1560
      End
   End
   Begin VB.CommandButton cmd_MD5_pwd_Lookup 
      Caption         =   "Lookup Passwordhash"
      Height          =   375
      Left            =   7440
      TabIndex        =   4
      ToolTipText     =   "Copies hash to clipboard and does an online query."
      Top             =   120
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.Timer Timer_OleDrag 
      Enabled         =   0   'False
      Interval        =   100
      Left            =   240
      Top             =   480
   End
   Begin VB.CommandButton Cmd_About 
      Caption         =   "About"
      Height          =   375
      Left            =   8640
      TabIndex        =   2
      Top             =   0
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.TextBox Txt_Filename 
      Height          =   375
      Left            =   120
      OLEDropMode     =   1  'Manuell
      TabIndex        =   1
      Text            =   "Drag the compiled AutoItExe / AutoHotKeyExe or obfucated script in here, or enter/paste path+filename."
      ToolTipText     =   "Drag in or type in da file"
      Top             =   120
      Width           =   9135
   End
   Begin VB.ListBox List1 
      Height          =   2010
      Left            =   120
      TabIndex        =   0
      ToolTipText     =   "Double click to see more !"
      Top             =   6480
      Width           =   9135
   End
   Begin VB.ListBox List_Source 
      Appearance      =   0  '2D
      Height          =   5685
      ItemData        =   "frmMain.frx":628A
      Left            =   120
      List            =   "frmMain.frx":628C
      TabIndex        =   5
      Top             =   600
      Visible         =   0   'False
      Width           =   9135
   End
   Begin VB.TextBox Txt_Script 
      Height          =   5775
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   3
      Top             =   600
      Width           =   9135
   End
End
Attribute VB_Name = "FrmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Option Explicit


'for mt_MT_Init to do a multiplation without 'overflow error'
'Private Declare Function Mul Lib "MSVBVM60.DLL" Alias "_allmul" (ByVal dw1 As Long, ByVal dw2 As Long, ByVal dw3 As Long, ByVal dw4 As Long) As Long

'Mersenne Twister
Private Declare Function MT_Init Lib "MT.DLL" (ByVal initSeed As Long) As Long
Private Declare Function MT_GetI8 Lib "MT.DLL" () As Long

'Private Declare Function Uncompress Lib "LZSS.DLL" (ByVal CompressedData$, ByVal CompressedDataSize&, ByVal OutData$, ByVal OutDataSize&) As Long
'Private Declare Function GetUncompressedSize Lib "LZSS.DLL" (ByVal CompressedData$, ByRef nUncompressedSize&) As Long

'Dim PE As New PE_info
Dim DeObfuscate As New ClsDeobfuscator

Dim FilePath_for_Txt$


'Const MD5_CRACKER_URL$ = "http://gdataonline.com/qkhash.php?mode=txt&hash="
Const MD5_CRACKER_URL$ = "http://www.md5cracker.de/crack.php?form=Cracken&md5="
'   http://www.milw0rm.com/cracker/info.php?'


Sub FL_verbose(text)
   log_verbose H32(File.Position - 1) & " -> " & text
End Sub

Sub log_verbose(TextLine$)
   If Chk_verbose.Value = vbChecked Then log TextLine
End Sub



Sub FL(text)
   log H32(File.Position - 1) & " -> " & text
End Sub

Public Sub LogSub(TextLine$)
   log "  " & TextLine
End Sub


Public Sub log2(TextLine$)
'   log TextLine$
End Sub

'/////////////////////////////////////////////////////////
'// log -Add an entry to the Log
Public Sub log(TextLine$)
On Error Resume Next
   List1.AddItem TextLine
'   List1.AddItem H32(GetTickCount) & vbTab & TextLine
 
 ' Process windows messages (=Refresh display)
   If (List1.ListCount < 10000) Or (Rnd < 0.1) Then
       ' Scroll to last item ; when there are more than &h7fff items there will be an overflow error
      Dim ListCount&
      List1.ListIndex = List1.ListCount - 1
      DoEvents
   End If
End Sub

'/////////////////////////////////////////////////////////
'// log_clear - Clears all log entries
Public Sub log_clear()
On Error Resume Next
   List1.Clear
End Sub




Private Sub Cmd_About_Click()
   FrmAbout.Show vbModal
End Sub

Private Sub cmd_MD5_pwd_Lookup_Click()
   Clipboard.Clear
   Clipboard.SetText MD5PassphraseHashText

   Dim hProc&
   hProc = ShellExecute(0, "open", MD5_CRACKER_URL$ & MD5PassphraseHashText, "", "", 1)

End Sub


'///////////////////////////////////////////
'// General Load/Save Configuration Setting
Private Function ConfigValue_Load(Key$, Optional DefaultValue)
   ConfigValue_Load = GetSetting(App.Title, Me.Name, Key, DefaultValue)
End Function
Property Let ConfigValue_Save(Key$, Value As Variant)
      SaveSetting App.Title, Me.Name, Key, Value
End Property



'///////////////////////////////////////////
'// Load/Save a CheckBox State
Sub CheckBox_Load(ByVal ChkBox As CheckBox)
   ChkBox.Value = ConfigValue_Load(ChkBox.Name, ChkBox.Value)
End Sub
Sub CheckBox_Save(ByVal ChkBox As CheckBox)
   ConfigValue_Save(ChkBox.Name) = ChkBox.Value
End Sub


'///////////////////////////////////////////
'// Load/Save a Form Setting
  'Iterate through all Item on the OptionsFrame
  'incase it's no Checkbox a 'type mismatch error' will occur
  'and due to "On Error Resume Next" it skip the call
Sub FormSettings_Load()
   On Error Resume Next
   
   Dim controlItem
   For Each controlItem In Fr_Options.Container
      CheckBox_Load controlItem
   Next
 
End Sub
Sub FormSettings_Save()
   On Error Resume Next
   
   Dim controlItem
   For Each controlItem In Fr_Options.Container
      CheckBox_Save controlItem
   Next
End Sub


Private Sub Form_Load()

  
   FrmMain.Caption = FrmMain.Caption & " " & App.Major & "." & App.Minor & " build(" & App.Revision & ")"
   
   FormSettings_Load
   
   'Extent Listbox width
   Listbox_SetHorizontalExtent List1, 6000
   
 
 ' Commandlinesupport   :)
   ProcessCommandline

  'Show Form if SilentMode is not Enable
   If IsOpt_RunSilent = False Then Me.Show

  
  'Open the File that was set by the commandline
   If IsCommandlineMode Then
      Txt_Filename = FileName
   Else
      Txt_Filename_Change
   End If
End Sub
   
   
Private Sub ProcessCommandline()

   Dim CommadLine As New CommandLine
   With CommadLine
   
      If .NumberOfCommandLineArgs Then
      
         log "Cmdline Args: " & .CommandLine
         
         Dim arg
         For Each arg In .getArgs
            
           'Check for options
            If arg Like "[/-]*" Then

               If arg Like "?[qQ]" Then
                  IsOpt_QuitWhenFinish = True
                  LogSub "Option 'QuitWhenFinish' enabled."
                  
               ElseIf arg Like "?[sS]" Then
                  IsOpt_RunSilent = True
                  LogSub "Option 'RunSilent' enabled."
                  
               Else
                  LogSub "ERR_Unknow option: '" & arg & "'"
                  
               End If
               
          ' Check if CommandArg is a FileName
            Else
           
               If IsCommandlineMode Then
                  LogSub "ERR_Invalid Argument ('" & arg & "') filename already set."
                  
               Else
                  If FileExists(arg) Then
                     IsCommandlineMode = True
                     FileName = arg
                     LogSub "FileName : " & arg
                  Else
                     LogSub "ERR_Invalid Argument. Can't open file '" & arg & "'"
                  End If
               End If
               
            End If
         Next
      End If
   End With

   'Verify
   If IsOpt_RunSilent And Not (IsOpt_QuitWhenFinish) Then
      LogSub "ERR 'RunSilent' only makes sence together with 'QuitWhenFinish'. As long as you don't also enable 'QuitWhenFinish' 'RunSilent' is ignored "
      IsOpt_RunSilent = False
   End If

End Sub

Private Function FileExists(FileName) As Boolean
   On Error GoTo FileExists_err
   FileExists = FileLen(FileName)

FileExists_err:
End Function

Public Function GetLogdata$()
   Dim LogData As New clsStrCat
   LogData.Clear
   Dim i
   For i = 0 To List1.ListCount
      LogData.Concat (List1.List(i) & vbCrLf)
   Next
   
   GetLogdata = LogData.Value
   
End Function

Private Sub Form_Unload(Cancel As Integer)
   FormSettings_Save
  
 'Close might be clicked 'inside' some DoEvents so
 'in case it was do a hard END
   End
End Sub

Private Sub List1_DblClick()
   frmLogView.txtlog = GetLogdata()
   frmLogView.Show
End Sub


Private Sub Timer_OleDrag_Timer()
   Timer_OleDrag.Enabled = False
   Txt_Filename = FilePath_for_Txt
End Sub


Private Sub Txt_Filename_Change()
   
   On Error GoTo Txt_Filename_err
   If FileExists(Txt_Filename) Then
      
     'Clear Log (expect when run via commandline)
      If IsCommandlineMode = False Then List1.Clear
      Txt_Script = ""
      
      FileName = Txt_Filename
      
      
      log String(80, "=")
'      log "           -=  " & Me.Caption & "  =-"
      log Me.Caption
      log String(80, "=")
'      log ""
         
      Decompile
      
      log "Testing for Scripts that were obfuscate by 'Jos van der Zande AutoIt3 Source Obfuscator v1.0.15 [July 1, 2007]' or 'EncodeIt 2.0'"

      For Each FileName In ExtractedFiles
'         If FileName.Ext Like "*.au*" Then
            On Error Resume Next
            log String(79, "=")
         DeToken
            If Err Then log "ERR: " & Err.Description

            On Error Resume Next
            log String(79, "=")
         DeObfuscate.DeObfuscate
            If Err Then log "ERR: " & Err.Description
            
          Select Case Err
          Case 0, ERR_NO_OBFUSCATE_AUT
            
            If Chk_RestoreIncludes = vbChecked Then SeperateIncludes
          
          Case Else
            log Err.Description
          End Select
          
 '        End If
      Next


Err.Clear
GoTo Txt_Filename_err

' Decompile Err Handler

      
      
DeToken:
      log String(79, "=")
      DeToken

DeObfuscate:
      log String(79, "=")
      DeObfuscate.DeObfuscate
      
Txt_Filename_err:
  ' Note: Resume is necessary to reenable Errorhandler
  '       Else the VB-standard Handler will catch the error -> Exit Programm
    Select Case Err
    Case 0
    
    Case ERR_NO_AUT_EXE
       log Err.Description
       Resume DeToken
    
    Case NO_AUT_DE_TOKEN_FILE
       log Err.Description
       Resume DeObfuscate
    
    Case ERR_NO_OBFUSCATE_AUT
       log Err.Description
       Resume Txt_Filename_err
       
       
    Case Else
       log Err.Description
       Resume Txt_Filename_err
    End Select
   
    
    'Save Log Data
    On Error Resume Next
    
'    If UBound(ExtractedFiles) < 0 Then
    FileName = ExtractedFiles(1).FileName
    FileName.NameWithExt = "_myExeToAut.log"
    
    log ""
    log "Saving Logdata to : " & FileName.FileName
    File.Create FileName.FileName, True
    File.FixedString(-1) = GetLogdata
    File.CloseFile
    
    
    IsCommandlineMode = False
    
    If IsOpt_QuitWhenFinish Then Unload Me
   
   End If
   
End Sub


Private Function OpenFile(Target_FileName As ClsFilename) As Boolean
   
   On Error GoTo Scanfile_err
   log "------------------------------------------------"

   log Space(4) & Target_FileName.NameWithExt

   File.Create Target_FileName.mvarFileName, Readonly:=True
   
   Me.Show

Err.Clear
Scanfile_err:
Select Case Err
   Case 0

   Case Else
      log "-->ERR: " & Err.Description

End Select
   
End Function


Private Sub Txt_Filename_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, x As Single, y As Single)
   FilePath_for_Txt = Data.Files(1)
   Timer_OleDrag.Enabled = True
End Sub


Private Sub Txt_Script_Change()
  If Len(Txt_Script) >= 65535 Then
      Txt_Script.ToolTipText = "Notice: Display limited to 65535 Bytes. File is bigger."
  Else
      Txt_Script.ToolTipText = ""
  End If
End Sub

Private Sub Txt_Script_KeyDown(KeyCode As Integer, Shift As Integer)
   Cancel = KeyCode <> vbKeySpace
End Sub
