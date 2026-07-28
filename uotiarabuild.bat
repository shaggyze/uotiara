@ECHO OFF
ECHO Are you sure you meant to download the source? click releases on the right of github to download the compiled installer.
ECHO Creating Unofficial Tiara's Moonshine Mod Installer, you should type 'y' for all questions.
FOR /F "skip=2 tokens=2,*" %%A IN ('reg.exe query "HKCU\SOFTWARE\Nexon\Mabinogi" /v ""') DO set "MabiPath=%%B"
ECHO.
ECHO Checking latest Mabinogi version...
REM Tooling folder name in one place - change this if you rename the folder
set "TOOLS=.claude"
python "%~dp0%TOOLS%\check_api_version.py"
FOR /F "usebackq delims=" %%V IN (`python "%~dp0%TOOLS%\check_api_version.py" --bare`) DO set "LIVE_VER=%%V"
FOR /F "usebackq delims=" %%V IN (`python "%~dp0%TOOLS%\get_nsi_ver.py"`) DO set "NSI_VER=%%V"
ECHO NSI version: %NSI_VER%  ^|  Live version: %LIVE_VER%
IF NOT "%NSI_VER%"=="%LIVE_VER%" (
  ECHO WARNING: NSI version ^(%NSI_VER%^) does not match live version ^(%LIVE_VER%^). Update UOSHORTVERSION in uotiara.nsi before building!
  set /p "yesno=Continue anyway y/n?:"
  IF NOT "%yesno%"=="y" EXIT /B 1
) ELSE (
  ECHO Version OK.
)
cd C:\Nexon\Library\mabinogi\appdata
if exist %MabiPath%\package\uotiara_00001.it attrib -r %MabiPath%\package\uotiara_00001.it
if exist C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it attrib -r C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it
if exist %MabiPath%\package\uotiara_00001.it del %MabiPath%\package\uotiara_00001.it
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
set "PACK_KEY=})wWb4?-sVGHNoPKpc"
set /p "yesno=Copy data folder to mabinogi and build uotiara_00001.it y/n?:"
IF "%yesno%"=="y" (
@ECHO ON
xcopy "%MabiPath%\package\temp\data\features.xml.compiled" ".\Tiara's Moonshine Mod\data\features.xml.compiled" /q /s /y /c /e
xcopy ".\Tiara's Moonshine Mod\data" "%MabiPath%\data" /q /s /y /c /e /i
@ECHO OFF
ECHO Building uotiara_00001.it
xcopy "%MabiPath%\data\code" "%MabiPath%\UOTiara\data\local\code" /q /s /y /c /e /i
xcopy "%MabiPath%\data\xml" "%MabiPath%\UOTiara\data\local\xml" /q /s /y /c /e /i
xcopy "%MabiPath%\data\db" "%MabiPath%\UOTiara\data\db" /q /s /y /c /e /i
xcopy "%MabiPath%\data\gfx" "%MabiPath%\UOTiara\data\gfx" /q /s /y /c /e /i
xcopy "%MabiPath%\data\locale" "%MabiPath%\UOTiara\data\locale" /q /s /y /c /e /i
xcopy "%MabiPath%\data\material" "%MabiPath%\UOTiara\data\material" /q /s /y /c /e /i
xcopy "%MabiPath%\data\sound" "%MabiPath%\UOTiara\data\sound" /q /s /y /c /e /i
xcopy "%MabiPath%\data\features.xml.compiled" "%MabiPath%\UOTiara\data\features.xml.compiled" /q /s /y /c /e
"%MabiPath%\mabi-pack2\mabi-pack2.exe" pack -i %MabiPath%\UOTiara\ -o %MabiPath%\package\uotiara_00001.it -f .jpg -k "%PACK_KEY%"
rmdir /q /s "%MabiPath%\data\material\_define"
copy /y "%MabiPath%\package\uotiara_00001.it" "C:\Users\%username%\Documents\GitHub\uotiara\uotiara_00001.it"
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
attrib +r "%MabiPath%\package\uotiara_00001.it"
PAUSE