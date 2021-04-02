Attribute VB_Name = "mod_Replace"
Option Explicit

Public Function Replace(ByRef Text As String, _
    ByRef sOld As String, ByRef sNew As String, _
    Optional ByVal Start As Long = 1, _
    Optional ByVal Count As Long = 2147483647, _
    Optional ByVal Compare As VbCompareMethod = vbBinaryCompare _
  ) As String

  If LenB(sOld) = 0 Then

    'Suchstring ist leer:
    Replace = Text

  ElseIf ContainsOnly0(sOld) Then

    'Unicode-Problem, also kein LenB und co. verwenden:
    ReplaceBin0 Replace, Text, Text, sOld, sNew, Start, Count

  ElseIf Compare = vbBinaryCompare Then

    'Groﬂ/Kleinschreibung unterscheiden:
    ReplaceBin Replace, Text, Text, sOld, sNew, Start, Count

  Else

    'Groﬂ/Kleinschreibung ignorieren:
    ReplaceBin Replace, Text, LCase$(Text), LCase$(sOld), sNew, Start, Count

  End If

End Function

Public Sub ReplaceDo(ByRef Text As String, _
    ByRef sOld As String, ByRef sNew As String, _
    Optional ByVal Start As Long = 1, _
    Optional ByVal Count As Long = 2147483647, _
    Optional ByVal Compare As VbCompareMethod = vbBinaryCompare _
  )

  If LenB(sOld) = 0 Then

    'Suchstring ist leer: Nix machen!

  ElseIf ContainsOnly0(sOld) Then

    'Unicode-Problem, also kein LenB und co. verwenden:
    ReplaceBin0 Text, Text, Text, sOld, sNew, Start, Count

  ElseIf Compare = vbBinaryCompare Then

    'Groﬂ/Kleinschreibung unterscheiden:
    If InStr(Start, Text, sOld, vbBinaryCompare) Then _
    ReplaceBin Text, Text, Text, sOld, sNew, Start, Count

  Else

    'Groﬂ/Kleinschreibung ignorieren:
    If InStr(Start, Text, sOld, vbTextCompare) Then _
    ReplaceBin Text, Text, LCase$(Text), LCase$(sOld), sNew, Start, Count

  End If

End Sub

Private Function ContainsOnly0(ByRef s As String) As Boolean

  Dim i As Long

  For i = 1 To Len(s)
    If Asc(Mid$(s, i, 1)) Then Exit Function
  Next i
  ContainsOnly0 = True

End Function

Private Static Sub ReplaceBin(ByRef Result As String, _
    ByRef Text As String, ByRef Search As String, _
    ByRef sOld As String, ByRef sNew As String, _
    ByVal Start As Long, ByVal Count As Long _
  )

  Dim TextLen As Long
  Dim OldLen As Long
  Dim NewLen As Long
  Dim ReadPos As Long
  Dim WritePos As Long
  Dim CopyLen As Long
  Dim Buffer As String
  Dim BufferLen As Long
  Dim BufferPosNew As Long
  Dim BufferPosNext As Long

  'Ersten Treffer bestimmen:
  If Start < 2 Then
    Start = InStrB(Search, sOld)
  Else
    Start = InStrB(Start + Start - 1, Search, sOld)
  End If
  If Start Then
  
    OldLen = LenB(sOld)
    NewLen = LenB(sNew)
    Select Case NewLen
    Case OldLen 'einfaches ‹berschreiben:
    
      Result = Text
      For Count = 1 To Count
        MidB$(Result, Start) = sNew
        Start = InStrB(Start + OldLen, Search, sOld)
        If Start = 0 Then Exit Sub
      Next Count
      Exit Sub
    
    Case Is < OldLen 'Ergebnis wird k¸rzer:
    
      'Buffer initialisieren:
      TextLen = LenB(Text)
      If TextLen > BufferLen Then
        Buffer = Text
        BufferLen = TextLen
      End If
      
      'Ersetzen:
      ReadPos = 1
      WritePos = 1
      If NewLen Then
      
        'Einzuf¸genden Text beachten:
        For Count = 1 To Count
          CopyLen = Start - ReadPos
          If CopyLen Then
            BufferPosNew = WritePos + CopyLen
            MidB$(Buffer, WritePos) = MidB$(Text, ReadPos, CopyLen)
            MidB$(Buffer, BufferPosNew) = sNew
            WritePos = BufferPosNew + NewLen
          Else
            MidB$(Buffer, WritePos) = sNew
            WritePos = WritePos + NewLen
          End If
          ReadPos = Start + OldLen
          Start = InStrB(ReadPos, Search, sOld)
          If Start = 0 Then Exit For
        Next Count
      
      Else
      
        'Einzuf¸genden Text ignorieren (weil leer):
        For Count = 1 To Count
          CopyLen = Start - ReadPos
          If CopyLen Then
            MidB$(Buffer, WritePos) = MidB$(Text, ReadPos, CopyLen)
            WritePos = WritePos + CopyLen
          End If
          ReadPos = Start + OldLen
          Start = InStrB(ReadPos, Search, sOld)
          If Start = 0 Then Exit For
        Next Count
      
      End If
      
      'Ergebnis zusammenbauen:
      If ReadPos > TextLen Then
        Result = LeftB$(Buffer, WritePos - 1)
      Else
        MidB$(Buffer, WritePos) = MidB$(Text, ReadPos)
        Result = LeftB$(Buffer, WritePos + LenB(Text) - ReadPos)
      End If
      Exit Sub
    
    Case Else 'Ergebnis wird l‰nger:
    
      'Buffer initialisieren:
      TextLen = LenB(Text)
      BufferPosNew = TextLen + NewLen
      If BufferPosNew > BufferLen Then
        Buffer = Space$(BufferPosNew)
        BufferLen = LenB(Buffer)
      End If
      
      'Ersetzung:
      ReadPos = 1
      WritePos = 1
      For Count = 1 To Count
        CopyLen = Start - ReadPos
        If CopyLen Then
          'Positionen berechnen:
          BufferPosNew = WritePos + CopyLen
          BufferPosNext = BufferPosNew + NewLen
          
          'Ggf. Buffer vergrˆﬂern:
          If BufferPosNext > BufferLen Then
            Buffer = Buffer & Space$(BufferPosNext)
            BufferLen = LenB(Buffer)
          End If
          
          'String "patchen":
          MidB$(Buffer, WritePos) = MidB$(Text, ReadPos, CopyLen)
          MidB$(Buffer, BufferPosNew) = sNew
        Else
          'Position bestimmen:
          BufferPosNext = WritePos + NewLen
          
          'Ggf. Buffer vergrˆﬂern:
          If BufferPosNext > BufferLen Then
            Buffer = Buffer & Space$(BufferPosNext)
            BufferLen = LenB(Buffer)
          End If
          
          'String "patchen":
          MidB$(Buffer, WritePos) = sNew
        End If
        WritePos = BufferPosNext
        ReadPos = Start + OldLen
        Start = InStrB(ReadPos, Search, sOld)
        If Start = 0 Then Exit For
      Next Count
      
      'Ergebnis zusammenbauen:
      If ReadPos > TextLen Then
        Result = LeftB$(Buffer, WritePos - 1)
      Else
        BufferPosNext = WritePos + TextLen - ReadPos
        If BufferPosNext < BufferLen Then
          MidB$(Buffer, WritePos) = MidB$(Text, ReadPos)
          Result = LeftB$(Buffer, BufferPosNext)
        Else
          Result = LeftB$(Buffer, WritePos - 1) & MidB$(Text, ReadPos)
        End If
      End If
      Exit Sub
    
    End Select
  
  Else 'Kein Treffer:
    Result = Text
  End If

End Sub

Private Static Sub ReplaceBin0(ByRef Result As String, _
    ByRef Text As String, ByRef Search As String, _
    ByRef sOld As String, ByRef sNew As String, _
    ByVal Start As Long, ByVal Count As Long _
  )

  Dim TextLen As Long
  Dim OldLen As Long
  Dim NewLen As Long
  Dim ReadPos As Long
  Dim WritePos As Long
  Dim CopyLen As Long
  Dim Buffer As String
  Dim BufferLen As Long
  Dim BufferPosNew As Long
  Dim BufferPosNext As Long

  'Ersten Treffer bestimmen:
  If Start < 2 Then
    Start = InStr(Search, sOld)
  Else
    Start = InStr(Start, Search, sOld)
  End If
  
  If Start Then
  
    OldLen = Len(sOld)
    NewLen = Len(sNew)
    Select Case NewLen
    Case OldLen 'einfaches ‹berschreiben:
    
      Result = Text
      For Count = 1 To Count
        Mid$(Result, Start) = sNew
        Start = InStr(Start + OldLen, Search, sOld)
        If Start = 0 Then Exit Sub
      Next Count
      Exit Sub
    
    Case Is < OldLen 'Ergebnis wird k¸rzer:
    
      'Buffer initialisieren:
      TextLen = Len(Text)
      If TextLen > BufferLen Then
        Buffer = Text
        BufferLen = TextLen
      End If
      
      'Ersetzen:
      ReadPos = 1
      WritePos = 1
      If NewLen Then
      
        'Einzuf¸genden Text beachten:
        For Count = 1 To Count
          CopyLen = Start - ReadPos
          If CopyLen Then
            BufferPosNew = WritePos + CopyLen
            Mid$(Buffer, WritePos) = Mid$(Text, ReadPos, CopyLen)
            Mid$(Buffer, BufferPosNew) = sNew
            WritePos = BufferPosNew + NewLen
          Else
            Mid$(Buffer, WritePos) = sNew
            WritePos = WritePos + NewLen
          End If
          ReadPos = Start + OldLen
          Start = InStr(ReadPos, Search, sOld)
          If Start = 0 Then Exit For
        Next Count
      
      Else
      
        'Einzuf¸genden Text ignorieren (weil leer):
        For Count = 1 To Count
          CopyLen = Start - ReadPos
          If CopyLen Then
            Mid$(Buffer, WritePos) = Mid$(Text, ReadPos, CopyLen)
            WritePos = WritePos + CopyLen
          End If
          ReadPos = Start + OldLen
          Start = InStr(ReadPos, Search, sOld)
          If Start = 0 Then Exit For
        Next Count
      
      End If
      
      'Ergebnis zusammenbauen:
      If ReadPos > TextLen Then
        Result = Left$(Buffer, WritePos - 1)
      Else
        Mid$(Buffer, WritePos) = Mid$(Text, ReadPos)
        Result = Left$(Buffer, WritePos + Len(Text) - ReadPos)
      End If
      Exit Sub
    
    Case Else 'Ergebnis wird l‰nger:
    
      'Buffer initialisieren:
      TextLen = Len(Text)
      BufferPosNew = TextLen + NewLen
      If BufferPosNew > BufferLen Then
        Buffer = Space$(BufferPosNew)
        BufferLen = Len(Buffer)
      End If
      
      'Ersetzung:
      ReadPos = 1
      WritePos = 1
      For Count = 1 To Count
        CopyLen = Start - ReadPos
        If CopyLen Then
          'Positionen berechnen:
          BufferPosNew = WritePos + CopyLen
          BufferPosNext = BufferPosNew + NewLen
          
          'Ggf. Buffer vergrˆﬂern:
          If BufferPosNext > BufferLen Then
            Buffer = Buffer & Space$(BufferPosNext)
            BufferLen = Len(Buffer)
          End If
          
          'String "patchen":
          Mid$(Buffer, WritePos) = Mid$(Text, ReadPos, CopyLen)
          Mid$(Buffer, BufferPosNew) = sNew
        Else
          'Position bestimmen:
          BufferPosNext = WritePos + NewLen
          
          'Ggf. Buffer vergrˆﬂern:
          If BufferPosNext > BufferLen Then
            Buffer = Buffer & Space$(BufferPosNext)
            BufferLen = Len(Buffer)
          End If
          
          'String "patchen":
          Mid$(Buffer, WritePos) = sNew
        End If
        WritePos = BufferPosNext
        ReadPos = Start + OldLen
        Start = InStr(ReadPos, Search, sOld)
        If Start = 0 Then Exit For
      Next Count
      
      'Ergebnis zusammenbauen:
      If ReadPos > TextLen Then
        Result = Left$(Buffer, WritePos - 1)
      Else
        BufferPosNext = WritePos + TextLen - ReadPos
        If BufferPosNext < BufferLen Then
          Mid$(Buffer, WritePos) = Mid$(Text, ReadPos)
          Result = Left$(Buffer, BufferPosNext)
        Else
          Result = Left$(Buffer, WritePos - 1) & Mid$(Text, ReadPos)
        End If
      End If
      Exit Sub
    
    End Select
  
  Else 'Kein Treffer:
    Result = Text
  End If

End Sub

