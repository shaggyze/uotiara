for %%A in ("C:\Nexon\Library\mabinogi\appdata\package\data\features.xml.compiled") do for %%B in (".\features.xml.compiled") do Copy %%~sA %%~sB
".\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" ".\features.xml.compiled"
for %%A in (".\UpdateFeatures.ps1") do PowerShell -ExecutionPolicy RemoteSigned -File %%~sA
".\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" ".\features.xml"
for %%A in (".\features.xml.compiled") do for %%B in (".\Tiara's Moonshine Mod\data\features.xml.compiled") do Copy %%~sA %%~sB
copy /Y ".\Tiara's Moonshine Mod\data\local\code" ".\Tiara's Moonshine Mod\data\code"
copy /Y ".\Tiara's Moonshine Mod\data\local\xml" ".\Tiara's Moonshine Mod\data\xml"
Xcopy ".\Tiara's Moonshine Mod\data" "C:\Nexon\Library\mabinogi\appdata\data" /Y /E /H /C /I
cd C:\Nexon\Library\mabinogi\appdata
attrib -r "C:\Nexon\Library\mabinogi\appdata\package\language.pack"
attrib -r "C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack"
C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input C:\Nexon\Library\mabinogi\appdata\package\language.pack /output . /version 999 /level 1
copy /Y "C:\Nexon\Library\mabinogi\appdata\data\local\code" "C:\Nexon\Library\mabinogi\appdata\data\code"
copy /Y "C:\Nexon\Library\mabinogi\appdata\data\local\xml" "C:\Nexon\Library\mabinogi\appdata\data\xml"
copy /Y "C:\Nexon\Library\mabinogi\appdata\data\code" "C:\Nexon\Library\mabinogi\appdata\data\local\code"
copy /Y "C:\Nexon\Library\mabinogi\appdata\data\xml" "C:\Nexon\Library\mabinogi\appdata\data\local\xml"
copy /Y "C:\Nexon\Library\mabinogi\appdata\data\world.english.txt" "C:\Nexon\Library\mabinogi\appdata\data\local\world.english.txt"
del C:\Nexon\Library\mabinogi\appdata\package\language.pack
del C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack
C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input C:\Nexon\Library\mabinogi\appdata\data /output C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack /version 999 /level 1
C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input C:\Nexon\Library\mabinogi\appdata\data\local /output C:\Nexon\Library\mabinogi\appdata\package\language.pack /version 999 /level 1
copy /Y ".\README.md" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\README.md"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\UOTiara.pack"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\language.pack" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\language.pack"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack" ".\UOTiara.pack"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\language.pack" ".\language.pack"
"%PROGRAMFILES(x86)%\NSIS\makensis.exe" uotiara.nsi
for %%I in ("%~dp0*.exe") do start "Running %%~nI" /wait "%%I"
attrib +r "C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack"