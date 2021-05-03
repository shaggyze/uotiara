set /P username=Enter User Name:
set /P version=Enter Version:
for %%A in ("C:\Nexon\Library\mabinogi\appdata\package\data\features.xml.compiled") do for %%B in ("C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\features.xml.compiled") do Copy %%~sA %%~sB
"C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" "C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\features.xml.compiled"
for %%A in ("C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\UpdateFeatures.ps1") do PowerShell -ExecutionPolicy RemoteSigned -File %%~sA
"C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" "C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\features.xml"
for %%A in ("C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\features.xml.compiled") do for %%B in ("C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\data\features.xml.compiled") do Copy %%~sA %%~sB
"C:\Program Files (x86)\NSIS\makensis.exe" "C:\Users\%username%\Documents\GitHub\uotiara\uotiara.nsi"
copy /Y "C:\Users\%username%\Documents\GitHub\uotiara\UO Tiaras Moonshine Mod V%version%.exe" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\UO Tiaras Moonshine Mod V%version%.exe"
Xcopy "C:\Users\%username%\Documents\GitHub\uotiara\Tiara's Moonshine Mod\data" "C:\Nexon\Library\mabinogi\appdata\data" /Y /E /H /C /I
cd C:\Nexon\Library\mabinogi\appdata
attrib -r C:\Nexon\Library\mabinogi\appdata\package\language.pack
attrib -r C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack
C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input C:\Nexon\Library\mabinogi\appdata\package\language.pack /output . /version 999 /level 1
copy C:\Nexon\Library\mabinogi\appdata\data\local\code C:\Nexon\Library\mabinogi\appdata\data\code
copy C:\Nexon\Library\mabinogi\appdata\data\local\xml C:\Nexon\Library\mabinogi\appdata\data\xml
copy C:\Nexon\Library\mabinogi\appdata\data\code C:\Nexon\Library\mabinogi\appdata\data\local\code
copy C:\Nexon\Library\mabinogi\appdata\data\xml C:\Nexon\Library\mabinogi\appdata\data\local\xml
copy C:\Nexon\Library\mabinogi\appdata\data\world.english.txt C:\Nexon\Library\mabinogi\appdata\data\local\world.english.txt
del C:\Nexon\Library\mabinogi\appdata\package\language.pack
del C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack
C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input C:\Nexon\Library\mabinogi\appdata\data /output C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack /version 999 /level 1
C:\Nexon\Library\mabinogi\appdata\MabiPacker\MabiPacker.exe /input C:\Nexon\Library\mabinogi\appdata\data\local /output C:\Nexon\Library\mabinogi\appdata\package\language.pack /version 999 /level 1
attrib +r C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack
copy /Y "C:\Users\%username%\Documents\GitHub\uotiara\README.md" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\README.md"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\UOTiara.pack"
copy /Y  "C:\Nexon\Library\mabinogi\appdata\package\language.pack" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\language.pack"
copy /Y "C:\Nexon\Library\mabinogi\appdata\package\UOTiara.pack" "C:\Users\%username%\Documents\GitHub\uotiara\UOTiara.pack"
copy /Y  "C:\Nexon\Library\mabinogi\appdata\package\language.pack" "C:\Users\%username%\Documents\GitHub\uotiara\language.pack"