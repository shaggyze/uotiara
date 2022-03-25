attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99991.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99993.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99995.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99997.it
attrib -r C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99991.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99993.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99995.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99997.it
del C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
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
xcopy "C:\Nexon\Library\mabinogi\appdata\data\code\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part1\data\local\code\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\xml\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part1\data\local\xml\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\db\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part5\data\db\" /q /s /y /c /e
mkdir C:\Nexon\Library\mabinogi\appdata\UOTiara\part2\data\gfx\gui\map_jpg
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_connous_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part2\data\gfx\gui\map_jpg\minimap_iria_connous_mgfree_eng.jpg" /y
mkdir C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\gui\map_jpg
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_connous_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\gui\map_jpg\minimap_iria_courcle_mgfree_eng.jpg" /y
mkdir C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_rano_new_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_iria_rano_new_mgfree_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_physis_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_iria_physis_mgfree_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_taillteann_eng_rep.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_taillteann_eng_rep.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_tara_eng_rep.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\gui\map_jpg\minimap_tara_eng_rep.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_rano_qilla_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_iria_rano_qilla_mgfree_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_connous_underworld.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_iria_connous_underworld.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_taillteann_abb_neagh_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_taillteann_abb_neagh_mgfree_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_n_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_n_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_s_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_iria_nw_tunnel_s_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_taillteann_sliab_cuilin_eng_rep.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_taillteann_sliab_cuilin_eng_rep.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_senmag_mgfree_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_senmag_mgfree_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_senmag_eng.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_senmag_eng.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_tara_n_field_eng_rep.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_tara_n_field_eng_rep.jpg" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\map_jpg\minimap_tara_castle_1f_eng_rep.jpg" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\map_jpg\minimap_tara_castle_1f_eng_rep.jpg" /y
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\login_screen\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\login-Screen\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\trading_ui\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\trading_ui\" /q /s /y /c /e
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\blacksmith.dds" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\blacksmith.dds" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\font_eng.dds" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\font_eng.dds" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\font_outline_eng.dds" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\font_outline_eng.dds" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\tailoring.dds" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\tailoring.dds" /y
copy "C:\Nexon\Library\mabinogi\appdata\data\gfx\gui\tailoring_2.dds" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\data\gfx\gui\tailoring_2.dds" /y
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\chapter3\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part5\data\gfx\chapter3\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\char\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\char\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\font\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part5\data\gfx\font\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\fx\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part5\data\gfx\fx\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\image\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\image\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\image2\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\image2\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\scene\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part5\data\gfx\scene\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\gfx\style\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\gfx\style\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\locale\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\locale\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\material\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\material\" /q /s /y /c /e
xcopy "C:\Nexon\Library\mabinogi\appdata\data\sound\" "C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\data\sound\" /q /s /y /c /e
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\part1\ -o C:\Nexon\Library\mabinogi\appdata\package\data_99991.it
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\part2\ -o C:\Nexon\Library\mabinogi\appdata\package\data_99993.it
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\part3\ -o C:\Nexon\Library\mabinogi\appdata\package\data_99995.it
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\part4\ -o C:\Nexon\Library\mabinogi\appdata\package\data_99997.it
C:\Nexon\Library\mabinogi\appdata\mabi-pack2\mabi-pack2.exe pack -i C:\Nexon\Library\mabinogi\appdata\UOTiara\part5\ -o C:\Nexon\Library\mabinogi\appdata\package\data_99999.it
rmdir /q /s  C:\Nexon\Library\mabinogi\appdata\UOTiara
copy ".\README.md" "C:\Users\%username%\Google Drive\Tiara\unofficialtiara\README.md"
@ECHO OFF
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