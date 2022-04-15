@echo off
setlocal EnableDelayedExpansion
rem Insert in the next line the list of files to skip
set skip=/data_99991/data_99993/data_99995/data_99997/data_99999/
set path=C:\Users\Shaggy\Documents\GitHub\uotiara\Temp
set /p path="Enter Path (Press Enter to keep <%path%>): "
for /r "%path%" %%f in (*.it) do (
   if /I "!skip:/%%~nf/=!" equ "%skip%" (
      echo Scanned %%f
      mabi-pack2.exe extract -i %%f -o .
	  del %%f
   ) else (
      echo Skipped %%f
   )
)
:endLoop
pause