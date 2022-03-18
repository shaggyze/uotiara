for %%A in ("C:\Nexon\Library\mabinogi\appdata\package\data\features.xml.compiled") do for %%B in (".\features.xml.compiled") do Copy %%~sA %%~sB
".\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" ".\features.xml.compiled"
for %%A in (".\UpdateFeatures.ps1") do PowerShell -ExecutionPolicy RemoteSigned -File %%~sA
".\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" ".\features.xml"
for %%A in (".\features.xml.compiled") do for %%B in (".\Tiara's Moonshine Mod\data\features.xml.compiled") do Copy %%~sA %%~sB
copy /Y ".\Tiara's Moonshine Mod\data\local\code" ".\Tiara's Moonshine Mod\data\code"
copy /Y ".\Tiara's Moonshine Mod\data\local\xml" ".\Tiara's Moonshine Mod\data\xml"
xcopy ".\Tiara's Moonshine Mod\data\" "C:\Nexon\Library\mabinogi\appdata\data\" /q /s /y /c /e
cd C:\Nexon\Library\mabinogi\appdata
attrib -r "C:\Nexon\Library\mabinogi\appdata\package\data_99999.it"
xcopy "C:\Nexon\Library\mabinogi\appdata\data\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\" /q /s /y /c /e
del C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara -o C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
rmdir /q /s  C:\Nexon\Library\mabinogi\appdata\UOTiara
copy /Y ".\README.md" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\README.md"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\data_99999.it" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\data_99999.it"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\data_99999.it" "C:\Users\%username%\Documents\GitHub\uotiara\data_99999.it"
"%PROGRAMFILES(x86)%\NSIS\makensis.exe" "C:\Users\%username%\Documents\GitHub\uotiara\uotiara.nsi"
for %%I in ("%~dp0*.exe") do start "Running %%~nI" /wait "%%I"
attrib +r "C:\Nexon\Library\mabinogi\appdata\package\data_99999.it"