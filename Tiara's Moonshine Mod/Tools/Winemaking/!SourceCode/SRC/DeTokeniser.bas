Attribute VB_Name = "DeTokeniser"
Option Explicit

Const whiteSpaceTerminal$ = " "
Const ExcludePreWhiteSpaceTerminal$ = "(["
Const ExcludePostWhiteSpaceTerminal$ = ")]."

Const TokenFile_RequiredInputExtensions = ".tok .mem"

Dim Atom$, SourceCodeLine$
Dim bDontAddWhiteSpace As Boolean

Sub DeToken()

   With File
    
      log "Trying to DeTokenise: " & FileName.FileName
      
      If InStr(TokenFile_RequiredInputExtensions, FileName.Ext) = 0 Then
         Err.Raise NO_AUT_DE_TOKEN_FILE, , "STOPPED!!! Required FileExtension for Tokenfiles: '" & TokenFile_RequiredInputExtensions & "'" & vbCrLf & _
         "Rename this file manually to show that this should be detokenied."
      End If
      
      
'      If FrmMain.chk_NoDeTokenise.Value = vbChecked Then
'         Err.Raise NO_AUT_DE_TOKEN_FILE, , "STOPPED!!! Enable DeTokenise in Options to use it." & FileName.FileName
'
'      End If
      
      .Create FileName.FileName, False, False, True
      .Position = 0
      
      
      On Error GoTo 0
      .Position = 0
      
      Dim Lines&
      Lines = .longValue
      FL "Code Lines: " & Lines & "   0x" & H32(Lines)
      
    ' File shouldn't start with MZ 00 00 -> ExeFile
    ' &HDFEFFF -> Unicodemarker
      If ((Lines And 65535) = &H5A4D) Or (Lines = &HDFEFF) Then
         Err.Raise NO_AUT_DE_TOKEN_FILE, , "That's no Au3-TokenFile."
      
      ElseIf ((Lines And &H7FFFFFF) > &H3BFEFF) Then
         'It's highly unlikly that there are more that 16 Mio lines in a Sourcefile
         Err.Raise NO_AUT_DE_TOKEN_FILE, , "This seem to be no Au3-TokenFile."
      End If
      
      
            
      
      FrmMain.List_Source.Clear
      FrmMain.List_Source.Visible = True
   
      
      
      Dim Cmd&
      Dim size&

      Dim SourceCode ' As New Collection
      Dim SourceCodeLineCount&
      ReDim SourceCode(0 To Lines):     SourceCodeLineCount = 1:
      Dim TokenCount&: TokenCount = 0
      
      Dim RawString As StringReader: Set RawString = New StringReader
      Dim DecodeString As StringReader: Set DecodeString = New StringReader

      Do
      
      
         If (SourceCodeLineCount > Lines) Then
            Exit Do
         End If
         
         bDontAddWhiteSpace = False
         
         
         
       ' Read Token
         Cmd = .ByteValue
         Inc TokenCount
         
       ' Log it ''" & Chr(Cmd) & "'
         FL_verbose "Token: " & H8(Cmd) & "      (Line: " & SourceCodeLineCount & "  TokenCount: " & TokenCount & ")"
         
         
       ' Debug.Assert SourceCodeLineCount <> 447
         
         Select Case Cmd
         Case &H0 To &HF
            '&H5
            Dim int32&
            int32 = .longValue
            Atom = int32
            FL_verbose "Ini32: 0x" & H32(int32) & "   " & int32
            
'            Debug.Assert Cmd = 5
         
         Case &H10 To &H1F
            Dim int64 As Currency
            int64 = .int64Value
            'int64 = H32(.longValue)
            'int64 = H32(.longValue) & int64
            'Replace 123,45 -> 12345
            Atom = Replace(CStr(int64), ",", "")
            
            FL_verbose "int64: " & int64
            
            Debug.Assert Cmd = &H10
         
         Case &H20 To &H2F
            
           'Get DoubleValue
            Dim Double_$
            Double_ = .DoubleValue
           
           'Replace 123,11 -> 123.11
            Atom = Replace(CStr(Double_), ",", ".")
         
            FL_verbose "64Bit-float: " & Double_
         
            Debug.Assert Cmd = &H20
         
         Case &H30 To &H3F
            
            
           'Get StrLength and load it
            size = .longValue
            FL_verbose "StringSize: " & H32(size)
            
            RawString = .FixedString(size * 2)
           
           
           
           'XorDecode String
            Dim StrCharPos&, tmpBuff$, XorKey%
            XorKey = (size And &HFF)

'            tmpBuff$ = StrConv(RawString, vbFromUnicode)
            tmpBuff$ = RawString
            
            For StrCharPos = 1 To Len(RawString) Step 2
               MidB$(tmpBuff, StrCharPos, 1) = ChrB$(AscB(MidB$(tmpBuff, StrCharPos * 2 - 1, 1)) _
                     Xor XorKey)
               If 0 = (StrCharPos Mod &H8000) Then DoEvents
            Next
            
            DecodeString = Left(tmpBuff, size)
'            DecodeString = StrConv(tmpBuff, vbUnicode)
            
'Comment out due to bad performance
'            RawString.Position = 0
'            DecodeString = Space(RawString.Length \ 2)
'            Do Until RawString.EOS
'               DecodeString.int8 = RawString.int8 Xor Size
'               If Not (RawString.EOS) Then Debug.Assert RawString.int8 = 0
'            Loop
            
            Select Case Cmd
            
            Case &H30 'BlockElement (FUNC, IF...) and the Rest of 42 Elements: "AND OR NOT IF THEN ELSE ELSEIF ENDIF WHILE WEND DO UNTIL FOR NEXT TO STEP IN EXITLOOP CONTINUELOOP SELECT CASE ENDSELECT SWITCH ENDSWITCH CONTINUECASE DIM REDIM LOCAL GLOBAL CONST FUNC ENDFUNC RETURN EXIT BYREF WITH ENDWITH TRUE FALSE DEFAULT ENUM NULL"
               FL_verbose """" & DecodeString & """   Type: BlockElement"
               
               Atom = DecodeString
              
              'LineBreak after and before 'Functions'
               If Atom = "ENDFUNC" Then
                  Atom = Atom & vbCrLf
               ElseIf Atom = "FUNC" Then
                  Atom = vbCrLf & Atom
               End If

            
            Case &H31 'FunctionCall with params
               Atom = DecodeString
               FL_verbose """" & DecodeString & """   Type: AutoItFunction"
               
            Case &H32 'Macro
               Atom = "@" & DecodeString
               FL_verbose """" & DecodeString & """   Type: Macro"
            
            Case &H33 'Variable
               Atom = "$" & DecodeString
               FL_verbose """" & DecodeString & """   Type: Variable"
            
            Case &H34 'FunctionCall
               Atom = DecodeString
               FL_verbose """" & DecodeString & """   Type: UserFunction"
            
            Case &H35 'Property
               Atom = "." & DecodeString
               FL_verbose """" & DecodeString & """   Type: Property"
            
            Case &H36 'UserString
               
              'Handle UserString with Quotes...
               Dim HasDoubleQuote As Boolean, HasSingleQuote As Boolean
               HasDoubleQuote = InStr(DecodeString.Data, """")
               HasSingleQuote = InStr(DecodeString.Data, "'")
               If HasDoubleQuote Then
                  If (HasSingleQuote) Then
                   ' Scenario3: " This is a 'Example' on correct "Quoting" String "
                     Atom = """" & Replace(DecodeString.Data, """", """""") & """"
                  Else
                   ' Scenario2: " This is a "Example". "
                     Atom = "'" & DecodeString & "'"
                  End If
               Else
                ' ' Scenario1: " ExampleString "
                  Atom = """" & DecodeString & """"
               End If
               
               FL_verbose """" & DecodeString & """   Type: UserString"
            
            Case &H37 '# PreProcessor
               Atom = DecodeString
               FL_verbose """" & DecodeString & """   Type: PreProcessor"
            
            
            Case Else
               'Unknown StringToken
               Stop
            End Select
            
 '           log String(40, "_")
         
         Case &H40 To &H56
'            Atom = Choose((Cmd - &H40 + 1), ",", "=", ">", "<", "<>", ">=", "<=", "(", ")", "+", "-", "/", "", "&", "[", "]", "==", "^", "+=", "-=", "/=", "*=", "&=")
         '                     Au3Manual AcciChar
            Select Case Cmd
               Case &H40: Atom = ","  '        2C
               Case &H41: Atom = "="  ' 1  13  3D
               Case &H42: Atom = ">"  ' 16     3E
               Case &H43: Atom = "<"  ' 18     3C
               Case &H44: Atom = "<>" ' 15     3C
               Case &H45: Atom = ">=" ' 17     3E
               Case &H46: Atom = "<=" ' 19     3C
               Case &H47: Atom = "("  '        28
               Case &H48: Atom = ")"  '        29
               Case &H49: Atom = "+"  ' 7      2B
               Case &H4A: Atom = "-"  ' 8      2D
               Case &H4B: Atom = "/"  ' 10     2F
               Case &H4C: Atom = "*"  ' 9      2A
               Case &H4D: Atom = "&"  ' 11     26
               Case &H4E: Atom = "["  '        5B
               Case &H4F: Atom = "]"  '        5D
               Case &H50: Atom = "==" ' 14     3D
               Case &H51: Atom = "^"  ' 12     5E
               Case &H52: Atom = "+=" '2       2B
               Case &H53: Atom = "-=" '3       2D
               Case &H54: Atom = "/=" '5       2F
               Case &H55: Atom = "*=" '4       2A
               Case &H56: Atom = "&=" '6       26
            End Select
            
            bDontAddWhiteSpace = True


         Case &H7F
            'Execute
            
            
            LogSourceCodeLine SourceCodeLine
            
            log_verbose ">>>  " & SourceCodeLine
            log_verbose String(80, "_")
            log_verbose ""
 
            
          ' Add SourceCodeLine to SourceCode
            SourceCode(SourceCodeLineCount) = SourceCodeLine
            Inc SourceCodeLineCount
            
            SourceCodeLine = ""

         Case Else
            
           'Unknown Token
           log "ERROR: Unknown Token: " & Cmd & " at " & H32(.Position)
           Exit Do
           'qw
           Stop
           

         End Select
         
         If bDontAddWhiteSpace Then
           'Add to SourceLine
            SourceCodeLine = SourceCodeLine & Atom
         Else
              'Add to SourceLine
            SourceCodeLine = SourceCodeLine & AddWhiteSpace & Atom
         End If
         
         Atom = ""
         
      Loop Until .EOF
   .CloseFile
  End With
  
  If FrmMain.Chk_TmpFile = vbUnchecked Then
     log "Keep TmpFile is unchecked => Deleting '" & FileName.NameWithExt & "'"
     FileDelete (FileName)
  End If
  
  FileName.Ext = ".au3"
  SaveScriptData (Join(SourceCode, vbCrLf))
   
  log "Token expansion succeed."
   
  FrmMain.List_Source.Visible = False


End Sub



Private Sub LogSourceCodeLine(TextLine$)
   On Error Resume Next
   With FrmMain.List_Source
      
      .AddItem TextLine
    
    ' Process windows messages (=Refresh display)
      If Rnd < 0.01 Then
          ' Scroll to last item
         .ListIndex = .ListCount - 1
      End If
      
   End With

End Sub

' Add WhiteSpace Seperator to SourceCodeLine
Function AddWhiteSpace$()
   
   'No WhiteSpace at the Beginning
   If SourceCodeLine = "" Then Exit Function
   
   Dim LastChar$
   LastChar = Right(SourceCodeLine, 1)
   
   Dim NextChar$
   NextChar = Left(Atom, 1)
   
   'Don'Append WhiteSpace in cases like this :
   '"@CMDLIND ["   or   "@CMDLIND [0" <-"].."
   '         (^-PreCase)                (^-PostCase)
   If InStr(1, ExcludePreWhiteSpaceTerminal, LastChar) Or _
      InStr(1, ExcludePostWhiteSpaceTerminal, NextChar) Then
'      Stop
   ElseIf whiteSpaceTerminal <> LastChar Then
         AddWhiteSpace = whiteSpaceTerminal
   End If
   
End Function





Private Sub FL_verbose(text)
   FrmMain.FL_verbose (text)
End Sub
Private Sub log_verbose(TextLine$)
   FrmMain.log_verbose TextLine$
End Sub

Private Sub FL(text)
   FrmMain.FL text
End Sub

'/////////////////////////////////////////////////////////
'// log -Add an entry to the Log
Private Sub log(TextLine$)
   FrmMain.log TextLine$
End Sub

'/////////////////////////////////////////////////////////
'// log_clear - Clears all log entries
Private Sub log_clear()
   FrmMain.log_clear
End Sub

