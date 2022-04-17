attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99991.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99993.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99995.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99997.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99991.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99993.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99995.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99997.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
del C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it
@ECHO OFF
set /p "yesno=Compile features.xml.compiled y/n?:"
IF "%yesno%"=="y" (
@ECHO ON
for %%f in (C:\Nexon\Library\mabinogi\appdata\package\*.it) do (
  C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe extract -i %%f -o . --filter "\.compiled"
)
".\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" ".\data\features.xml.compiled"
for %%A in (".\UpdateFeatures.ps1") do PowerShell -ExecutionPolicy RemoteSigned -File %%~sA
".\Tiara's Moonshine Mod\Tools\MabiFeatureTool\MabiFeatureTool.exe" ".\data\features.xml"
for %%A in (".\data\features.xml.compiled") do for %%B in (".\Tiara's Moonshine Mod\data\features.xml.compiled") do Copy %%~sA %%~sB
) ELSE IF "%yesno%"=="n" (
ECHO Skipping Compile
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
@ECHO OFF
set /p "yesno1=Copy data folder to mabinogi y/n?:"
IF "%yesno1%"=="y" (
xcopy ".\Tiara's Moonshine Mod\data\" "C:\Nexon\Library\mabinogi\appdata\data\" /q /s /y /c /e
) ELSE IF "%yesno1%"=="n" (
ECHO Skipping Copy
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
@ECHO ON
cd C:\Nexon\Library\mabinogi\appdata
xcopy "C:\Nexon\Library\mabinogi\appdata\data\code\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\local\code\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\xml\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\local\xml\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\db\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\db\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\gfx\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\locale\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\locale\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\material\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\material\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\sound\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\sound\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\features.xml.compiled" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\features.xml.compiled"
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\ -o C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it -f .jpg
rmdir /q /s  C:\Nexon\Library\mabinogi\appdata\data\material\_define\
copy /y "C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it" ".\uotiara_00001.it"
set /p "yesno2=Compile Installer y/n?:"
IF "%yesno2%"=="y" (
"%PROGRAMFILES(x86)%\NSIS\makensis.exe" "C:\Users\%username%\Documents\GitHub\uotiara\uotiara.nsi"
) ELSE IF "%yesno2%"=="n" (
ECHO Skipping Compile
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
set /p "yesno3=Run Installer y/n?:"
IF "%yesno3%"=="y" (
for %%I in ("%~dp0*.exe") do start "Running %%~nI" /wait "%%I"
) ELSE IF "%yesno3%"=="n" (
ECHO Skipping Run
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
attrib +r C:\Nexon\Library\mabinogi\appdata\package\data_99991.it
attrib +r C:\Nexon\Library\mabinogi\appdata\package\data_99993.it
attrib +r C:\Nexon\Library\mabinogi\appdata\package\data_99995.it
attrib +r C:\Nexon\Library\mabinogi\appdata\package\data_99997.it
attrib +r C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
attrib +r C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it