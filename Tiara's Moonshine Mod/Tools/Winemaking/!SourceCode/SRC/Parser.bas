Attribute VB_Name = "Parser"
Option Explicit
   Dim Str As StringReader
   Dim Level&
   Dim StartSym$, EndSym$
Public Function CropParenthesis$(Expression$, Optional StartSym = "(", Optional EndSym = ")")
   Set Str = New StringReader
   Str = Expression
   
   Parser.StartSym = StartSym
   Parser.EndSym = EndSym
   
   Level = 0
   CropParenthesis = BB()
   
   If Level <> 0 Then Err.Raise vbObjectError, , "Parenthesis unembalanced: (" & Level & " too much) in expression: " & Str & vbCrLf & "ignored: " & Str.FixedString(-1)
   
End Function


Function BB$()
   Dim text$, char$
   text = ""
   
   Do While Str.EOS = False
      char = Str.FixedString(1)
      Select Case char
         Case StartSym '"("
            Inc Level
            BB
         
         '  dirty fix:
            text = text & char & EndSym

         Case EndSym ' ")"
            Dec Level
            Exit Do

         Case Else
            text = text & char
            
      End Select
      
   Loop
   
   BB = text
'   Debug.Print Space(Level * 2) & text
   
End Function





Function AddLineBreakToLongLines$(ByRef Lines)
' Adding a underscope '_' for lines longer than 2047
' so Tidy will not complain
   
'  Dim Lines
  Dim line, NewLine As New clsStrCat
'   Lines = Split(TextLine, vbCrLf)

   'Find place to break line
   '...total "&@CRLF& "fees....
   '                ^-NextAmpersandPos
   'Will be changed to
   '...total "&@CRLF&_
   '"fees....
   '
   Const MAX_CODE_LINE_LENGHT& = 2000
   For line = 0 To UBound(Lines)
      
      Dim lineLen&
      lineLen = Len(Lines(line))
      
      If lineLen > MAX_CODE_LINE_LENGHT Then
         
         NewLine.Clear
         
         Dim linePos&, LastPos&
         linePos = 1
         LastPos = 1
         Do While linePos + MAX_CODE_LINE_LENGHT < lineLen
            
            Dim NextAmpersandPos&
            NextAmpersandPos = InStrRev(Mid(Lines(line), linePos, MAX_CODE_LINE_LENGHT), "&")
            
            'if there is on Ampersand and line gets to big output a
            'notice in the log - user should manually fix this
            If (NextAmpersandPos <> 0) Then
                           
               NewLine.Concat Mid(Lines(line), linePos, NextAmpersandPos)
               NewLine.Concat " _" & vbCrLf
            
            Else
               
               NextAmpersandPos = MAX_CODE_LINE_LENGHT
               NewLine.Concat Mid(Lines(line), linePos, NextAmpersandPos)
               log " PROBLEM: Line " & line & " is longer than " & MAX_CODE_LINE_LENGHT & " Bytes. Tidy will refuse to work. Fix this manually an then apply Tidy."
            
            End If
            
            Inc linePos, NextAmpersandPos
         Loop
         
        'add last end
         NewLine.Concat Mid(Lines(line), linePos)
         
         
         Lines(line) = NewLine.Value
         
      End If
   Next
  
  AddLineBreakToLongLines = Join(Lines, vbCrLf)

End Function
