ECHO Are you sure you meant to download the source? click releases on the right of github to download the compiled installer..
".\Tiara's Moonshine Mod\Tools\nsis-3.04-setup.exe" /S
ECHO Install NSIS manually if above command does not work.
if not exist "C:\Nexon\Library\mabinogi\appdata\mabi-patcher" mkdir "C:\Nexon\Library\mabinogi\appdata\mabi-patcher"
copy /Y "Tiara's Moonshine Mod\Tools\mabi-patcher\mabi-patcher.exe" "C:\Nexon\Library\mabinogi\appdata\mabi-patcher\mabi-patcher.exe"
uotiarabuild.bat                                                                              