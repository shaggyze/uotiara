Attribute VB_Name = "Helper"
Option Explicit
Option Compare Text

Public Cancel As Boolean


'Konstantendeklationen für Registry.cls

'Registrierungsdatentypen
Public Const REG_SZ As Long = 1                         ' String
Public Const REG_BINARY As Long = 3                     ' Binär Zeichenfolge
Public Const REG_DWORD As Long = 4                      ' 32-Bit-Zahl

'Vordefinierte RegistrySchlüssel (hRootKey)
Public Const HKEY_CLASSES_ROOT = &H80000000
Public Const HKEY_CURRENT_USER = &H80000001
Public Const HKEY_LOCAL_MACHINE = &H80000002
Public Const HKEY_USERS = &H80000003

Public Const ERROR_NONE = 0


Public Const ERR_FILESTREAM = &H1000000
Public Const ERR_OPENFILE = vbObjectError + ERR_FILESTREAM + 1
Private i, j As Integer

Public Declare Sub MemCopyAnyToAny Lib "kernel32" Alias "RtlMoveMemory" (ByVal Dest As Any, src As Any, ByVal Length&)
Public Declare Sub MemCopy Lib "kernel32" Alias "RtlMoveMemory" (Dest As Any, ByVal src As Any, ByVal Length&)
Public Declare Sub MemCopyAnyToStr Lib "kernel32" Alias "RtlMoveMemory" (Dest As Any, src As Any, ByVal Length&)
Public Declare Sub MemCopyLngToStr Lib "kernel32" Alias "RtlMoveMemory" (ByVal Dest As String, src As Long, ByVal Length&)

Public Declare Sub MemCopyStrToLng Lib "kernel32" Alias "RtlMoveMemory" (Dest As Long, ByVal src As String, ByVal Length&)
'Public Declare Sub MemCopyLngToStr Lib "kernel32" Alias "RtlMoveMemory" (ByVal dest As String, src As Long, ByVal Length&)
Public Declare Sub MemCopyLngToInt Lib "kernel32" Alias "RtlMoveMemory" (Dest As Long, ByVal src As Integer, ByVal Length&)
    
Private Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer

Private Const SM_DBCSENABLED = 42
Private Declare Function GetSystemMetrics Lib "user32" (ByVal nIndex As Integer) As Integer


Private BenchtimeA&, BenchtimeB&


'Returns whether the user has DBCS enabled
Private Function isDBCSEnabled() As Boolean
   isDBCSEnabled = GetSystemMetrics(SM_DBCSENABLED)
End Function


Function LeftButton() As Boolean
    LeftButton = (GetAsyncKeyState(vbKeyLButton) And &H8000)
End Function

Function RightButton() As Boolean
    RightButton = (GetAsyncKeyState(vbKeyRButton) And &H8000)
End Function

Function MiddleButton() As Boolean
    MiddleButton = (GetAsyncKeyState(vbKeyMButton) And &H8000)
End Function

Function MouseButton() As Integer
    If GetAsyncKeyState(vbKeyLButton) < 0 Then
        MouseButton = 1
    End If
    If GetAsyncKeyState(vbKeyRButton) < 0 Then
        MouseButton = MouseButton Or 2
    End If
    If GetAsyncKeyState(vbKeyMButton) < 0 Then
        MouseButton = MouseButton Or 4
    End If
End Function

Function KeyPressed(Key) As Boolean
   KeyPressed = GetAsyncKeyState(Key)
End Function

Public Function HexStringToString$(ByVal HexString$)
   HexStringToString = Space(Len(HexString) \ 2)
   For i = 1 To Len(HexString) Step 2
      Mid$(HexStringToString, (i \ 2) + 1) = Chr("&h" & Mid$(HexString, i, 2))
   Next
End Function

Public Function HexvaluesToString$(Hexvalues$)
   Dim tmpchar
   For Each tmpchar In Split(Hexvalues)
      'HexvaluesToString = HexvaluesToString & ChrB("&h" & tmpchar) & ChrB(0)
      'Note ChrB("&h98") & ChrB(0) is not correct translated
      HexvaluesToString = HexvaluesToString & Chr("&h" & tmpchar)
   Next
End Function

Public Function ValuesToHexString$(Data As StringReader, Optional seperator = " ")
'ValuesToHexString = ""
   With Data
      .EOS = False
      Do Until .EOS
         ValuesToHexString = ValuesToHexString & H8(.int8) & seperator
      Loop
   End With
  
End Function


Function Max(ParamArray values())
   Dim item
   For Each item In values
      Max = IIf(Max < item, item, Max)
   Next
End Function

Function Min(ParamArray values())
   Dim item
   Min = &H7FFFFFFF
   For Each item In values
      Min = IIf(Min > item, item, Min)
   Next
End Function

Function limit(Value&, Optional ByVal upperLimit = &H7FFFFFFF, Optional lowerLimit = 0) As Long
   'limit = IIf(Value > upperLimit, upperLimit, IIf(Value < lowerLimit, lowerLimit, Value))

   If (Value > upperLimit) Then _
      limit = upperLimit _
   Else _
      If (Value < lowerLimit) Then _
         limit = lowerLimit _
      Else _
         limit = Value
   
End Function

Function RangeCheck(ByVal Value&, Max&, Optional Min& = 0, Optional errtext, Optional ErrSource$) As Boolean
   RangeCheck = (Min <= Value) And (Value <= Max)
   If (RangeCheck = False) And (IsMissing(errtext) = False) Then Err.Raise vbObjectError, ErrSource, errtext & " Value must between '" & Min & "'  and '" & Max & "' !"
End Function

Public Function H8(ByVal Value As Long)
   H8 = Right(String(1, "0") & Hex(Value), 2)
End Function

Public Function H16(ByVal Value As Long)
   H16 = Right(String(3, "0") & Hex(Value), 4)
End Function

Public Function H32(ByVal Value As Double)
   If Value <= &H7FFFFFFF Then
      H32 = Hex(Value)
   Else
    ' split Number in High a Low part...
      Dim High&, Low&
      High = Value / &H10000
      Low = Value - (CDbl(High) * &H10000)
      
      H32 = H16(High) & H16(Low)
   End If
   
   H32 = Right(String(7, "0") & H32, 8)
End Function

Public Function Swap(ByRef a, ByRef b)
   Swap = b
   b = a
   a = Swap
End Function

'////////////////////////////////////////////////////////////////////////
'// BlockAlign_l  -  Erzeugt einen linksbündigen BlockString
'//
'// Beispiel1:     BlockAlign_l("Summe",7) -> "  Summe"
'// Beispiel2:     BlockAlign_l("Summe",4) -> "umme"
Public Function BlockAlign_l(RawString, Blocksize) As String
  'String kürzen lang wenn zu
   RawString = Left(RawString, Blocksize)
  'mit Leerzeichen auffüllen
   BlockAlign_l = Space(Blocksize - Len(RawString)) & RawString
End Function

Public Function qw()
   Cancel = True
   Do
      DoEvents
   Loop While Cancel = True
End Function
Public Function szNullCut$(zeroString$)
   Dim nullCharPos&
   nullCharPos = InStr(1, zeroString, Chr(0))
   If nullCharPos Then
      szNullCut = Left(zeroString, nullCharPos - 1)
   Else
      szNullCut = zeroString
   End If
   
End Function


Public Function Inc(ByRef Value, Optional Increment& = 1)
   Value = Value + Increment
   Inc = Value
End Function

Public Function Dec(ByRef Value, Optional DeIncrement& = 1)
   Value = Value - DeIncrement
   Dec = Value
End Function



Public Function CollectionToArray(Collection As Collection) As Variant
   
   Dim tmp
   ReDim tmp(Collection.Count - 1)
   
   Dim i
   i = LBound(tmp)
   
   Dim item
   For Each item In Collection
      tmp(i) = item
      Inc i
   Next
   
   CollectionToArray = tmp
   
End Function
Public Function isString(StringToCheck) As Boolean
   'isString = False
   Dim i&
   For i = 1 To Len(StringToCheck)
      If RangeCheck(Asc(Mid$(StringToCheck, i, 1)), &H7F, &H20) Then
      
      Else
         Exit Function
      End If
   Next
   
   isString = True
   
End Function



'Searches for some string and then starts there to crop
Function strCropWithSeek$(text$, LeftString$, RightString$, Optional errorvalue, Optional SeektoStrBeforeSearch$)
   strCropWithSeek = strCrop1(text$, LeftString$, RightString$, errorvalue, _
            InStr(1, text, SeektoStrBeforeSearch))
End Function


Function strCrop1$(ByVal text$, LeftString$, RightString$, Optional errorvalue = "", Optional StartSearchAt = 1)
   
   Dim cutend&, cutstart&
      cutstart = InStr(StartSearchAt, text, LeftString)
   If cutstart Then
      cutstart = cutstart + Len(LeftString)
      cutend = InStr(cutstart, text, RightString)
      If cutend > cutstart Then
         strCrop1 = Mid$(text, cutstart, cutend - cutstart)
      Else
        'is Rightstring empty?
         If RightString = "" Then
            strCrop1 = Mid$(text, cutstart)
         Else
            strCrop1 = errorvalue
         End If
      End If
   Else
      strCrop1 = errorvalue
   End If

End Function

Function strCropAndDelete(text$, LeftString$, RightString$, Optional errorvalue = "", Optional StartSearchAt = 1)
   strCropAndDelete = strCrop1(text$, LeftString$, RightString$, errorvalue, StartSearchAt)
   text = Replace(text, LeftString & strCropAndDelete & RightString, "", , , vbTextCompare)
End Function

Function strCrop$(text$, LeftString$, RightString$, Optional errorvalue, Optional StartSearchAt = 1)
   
   Dim cutend&, cutstart&
      cutend = InStr(StartSearchAt, text, RightString)
   If cutend Then
      cutstart = InStrRev(text, LeftString, cutend, vbBinaryCompare) + Len(LeftString)
      strCrop = Mid$(text, cutstart, cutend - cutstart)
   Else
      strCrop = errorvalue
   End If

End Function

Function MidMbcs(ByVal Str As String, Start, Length)
    MidMbcs = StrConv(MidB$(StrConv(Str, vbFromUnicode), Start, Length), vbUnicode)
End Function


Function strCutOut$(Str$, pos&, Length&, Optional TextToInsert = "")
   strCutOut = Mid(Str, pos, Length)
   Str$ = Mid(Str, 1, pos - 1) & TextToInsert & Mid(Str, pos + Length)
End Function


Public Function Int16ToUInt32&(Value%)
      Const N_0x8000& = 32767
      If Value >= 0 Then
         Int16ToUInt32 = Value
      Else
         Int16ToUInt32 = CLng(Value And N_0x8000) + N_0x8000
      End If
      
End Function




Public Function BenchStart()

   BenchtimeA = GetTickCount

End Function
Public Function BenchEnd()

   BenchtimeB = GetTickCount
   Debug.Print BenchtimeB - BenchtimeA

End Function
