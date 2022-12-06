@ECHO OFF
ECHO Are you sure you meant to download the source?
ECHO Creating Unofficial Tiara's Moonshine Mod Installer, you should type 'y' for all questions.
if exist C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it attrib -r C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it
if exist C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it attrib -r C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it
if exist C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it del C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it
if exist C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it del C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it
set /p "yesno=Update Kanan y/n?:"
IF "%yesno%"=="y" (
@ECHO ON
powershell.exe -command "Invoke-WebRequest -OutFile ./kanan.zip https://github.com/cursey/kanan-new/releases/latest/download/kanan.zip"
powershell.exe -command "Invoke-WebRequest -OutFile ./unzip.exe https://shaggyze.website/files/unzip.exe"
unzip.exe -o kanan.zip -d .\Tiara'~1\Tools\Kanan
del unzip.exe
del kanan.zip
) ELSE IF "%yesno%"=="n" (
ECHO Skipping Update
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
@ECHO OFF
set /p "yesno=Copy data folder to mabinogi and build uotiara_00001.it y/n?:"
IF "%yesno%"=="y" (
@ECHO ON
xcopy ".\Tiara's Moonshine Mod\data\" "C:\Nexon\Library\mabinogi\appdata\data\" /q /s /y /c /e
@ECHO OFF
ECHO Building uotiara_00001.it
xcopy "C:\Nexon\Library\mabinogi\appdata\data\code\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\local\code\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\xml\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\local\xml\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\db\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\db\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\gfx\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\locale\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\locale\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\material\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\material\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\sound\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\sound\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\features.xml.compiled" "C:\Nexon\Library\mabinogi\appdata\UOTiara\data\features.xml.compiled" /q /s /y /c /e
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\ -o C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it -f .jpg -k "@6QeTuOaDgJlZcBm#9"
rmdir /q /s  C:\Nexon\Library\mabinogi\appdata\data\material\_define\
copy /y "C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it" "C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it"
) ELSE IF "%yesno%"=="n" (
ECHO Skipping Copy
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
@ECHO OFF
set /p "yesno=Compile Installer y/n?:"
IF "%yesno%"=="y" (
@ECHO ON
"%PROGRAMFILES(x86)%\NSIS\makensis.exe" ".\uotiara.nsi"
) ELSE IF "%yesno%"=="n" (
ECHO Skipping Compile
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
@ECHO OFF
set /p "yesno=Run Installer y/n?:"
IF "%yesno%"=="y" (
@ECHO ON
for %%I in ("%~dp0*.exe") do start "Running %%~nI" /wait "%%I"
) ELSE IF "%yesno%"=="n" (
ECHO Skipping Run
) ELSE (
ECHO Invalid Option: y or n
PAUSE
)
@ECHO OFF
attrib +r C:\Nexon\Library\mabinogi\appdata\package\uotiara_00001.it
PAUSE