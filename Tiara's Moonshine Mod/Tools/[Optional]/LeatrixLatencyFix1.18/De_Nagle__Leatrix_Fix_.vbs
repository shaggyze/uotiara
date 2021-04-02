' Leatrix Latency Fix 1.18 (Install Script)
' To use, simply run this script and restart your computer.
' To run from within batch files, use 'cscript Install.vbs"

  logo = "Leatrix Latency Fix"
  Leatrix_Version = "1.18"

  Const HKEY_LOCAL_MACHINE = &H80000002

  Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
  Set shell = CreateObject("Shell.Application")
  set wsnet = WScript.CreateObject("WScript.Network")
  computername = ucase(wsnet.computername)

  strKeyPath = "SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\"
  oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys

  if Wscript.Arguments.Count => 1 then
    if (WScript.Arguments.Item(0) = "uac") then Leatrix_Uac = 1 else Leatrix_Uac = 0
  end if
   
  If Instr(1, WScript.FullName, "cscript", vbTextCompare) > 1 Then
    Leatrix_Script = 1
  End If

' Show logo for script users
  if Leatrix_Script = 1 and Leatrix_Uac = 0 then
    wscript.echo "Leatrix Latency Fix " & Leatrix_Version & " Batch Mode."
    wscript.echo ""
  end if

' Latency fix has already been applied
  if CheckFix = true then
    msg = "Leatrix Latency Fix is already installed on this computer."
    if Leatrix_Script = 0 then
      msg = msgbox (msg,48,logo)
    else
      wscript.echo msg
    end if
    wscript.quit
  end if

' Show title for first run
  If Leatrix_Uac = 0 then
    if Leatrix_Script = 0 then
      msg = logo & " " & Leatrix_Version & chr(13) & chr(13) & "This script will reduce your latency in World of Warcraft and other online games.  It is designed for Windows XP (SP2 or higher), Windows Vista (SP1 or higher) and Windows 7 only." _
                       & chr(13) & chr(13) & "If you are not logged into your computer with an account which has Administrator privileges, or you are using Windows Vista or Windows 7 with User Account Control enabled, you will be prompted to enter the username and password of an account which has Administrator privileges." _
                       & chr(13) & chr(13) & "Leatrix Latency Fix is hosted at www.wowinterface.com/downloads/info13581-LeatrixLatencyFix.html." _
                       & chr(13) & chr(13) & "Click Ok to begin."
    else
      msg = "Installing..."
    end if

    if Leatrix_Script = 0 then
      msg = msgbox (msg,65,logo)

      ' Does user want to quit
        if msg = 2 then
          wscript.quit
        end if
    else
        wscript.echo msg
    end if  
  end if

' Attempt to apply latency fix
  For Each subkey In arrSubKeys
    err = oReg.SetDwordValue (HKEY_LOCAL_MACHINE,strKeyPath & subkey,"TcpAckFrequency","1")
  Next

' If fix completed successfully
  if CheckFix = true then
    Success
    wscript.quit
  end if

' If fix did not complete successfully, run it again with UAC prompt
  if CheckFix = false and Leatrix_Uac = 0 then
    if Leatrix_Script = 0 then
      msg = "Either your Windows account does not have Administrator privileges, or you are using Windows Vista or Windows 7 with User Account Control enabled."
      msg = msg + chr(13) + chr(13) & "User Account Control forces programs to run under regular user privileges, even if you are logged into your computer with an account which has Administrator privileges.  It's enabled by default on computers running Windows Vista and Windows 7."
      msg = msg + chr(13) + chr(13) & "To get around this, you will be prompted to enter your Windows logon details.  In the next window, check the radio button for 'The following user' and enter the username and password of a Windows account which has Administrator privileges.  The username must be in the format '" & computername & "\username'."
      msg = msg + chr(13) + chr(13) & "Click Ok to continue"
      msg = msgbox (msg,49,logo)

  ' Does user want to quit
    if msg = 2 then
      wscript.quit
    end if

  ' Rerun script with UAC prompt
    shell.ShellExecute "wscript.exe", Chr(34) & _
    WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
  else
    wscript.echo "Logon failure.  You must be logged in with Administrator privileges in order to use batch mode."
    wscript.quit
  end if
  end if

' Check if script completed successfully with UAC prompt
  if Leatrix_Uac = 1 then
    if CheckFix = false then
      msg = "There was an error (" & err.number & ")." & chr(13) & chr(13) & "Ensure that you entered a valid username and password.  The username must have Administrator privileges on this computer." & chr(13) & chr(13) & "Click Ok to close the script."
        if Leatrix_Script = 0 then
          msg = msgbox (msg,48,logo)
        end if
    else
      Success
    end if
  end if

  wscript.quit

  Function CheckFix()
  ' Checks to see if any of the settings have been applied
    StopCheck = 0
    For Each subkey In arrSubKeys
      oReg.GetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath & subkey,"TcpAckFrequency",CheckFix
      if CheckFix = 1 then 
      else StopCheck = 1
      end if
    Next
    if StopCheck = 1 then CheckFix = false else CheckFix = true
  end function

  Function Success()
    if Leatrix_Script = 0 then
      set shell = wscript.CreateObject("wscript.shell")
      msg = "Leatrix Latency Fix has been installed successfully."
      msg = msg & chr(13) & "You need to restart your computer for the changes to take effect." & chr(13)
      msg = msg & chr(13) & "Do you want to restart your computer now?"
      msg = msgbox (msg,68,logo)
      if msg = 6 then
        shell.Run "shutdown.exe /r /t 00"
      end if
    else
      wscript.echo "Leatrix Latency Fix has been installed successfully."
      wscript.echo "You need to restart your computer for the changes to take effect."
    end if
  end function
