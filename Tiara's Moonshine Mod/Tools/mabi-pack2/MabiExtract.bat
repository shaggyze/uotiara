@ECHO OFF
for %%f in (C:\Nexon\Library\mabinogi\appdata\package\*.it) do (
  C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe extract -i %%f -o .
)