@ECHO OFF
for %%f in (C:\Nexon\Library\mabinogi\appdata\package\*.pack) do (
  C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input %%f /output .
)