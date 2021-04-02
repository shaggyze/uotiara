for %%A in ("C:\Nexon\Library\mabinogi\appdata\package\data\features.xml.compiled") do for %%B in ("C:\Users\Shaggy\Google Drive\Tiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\features.xml.compiled") do Copy %%~sA %%~sB
MabiFeatureTool.exe features.xml.compiled
for %%A in ("C:\Users\Shaggy\Google Drive\Tiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\UpdateFeatures.ps1") do PowerShell -ExecutionPolicy RemoteSigned -File %%~sA
MabiFeatureTool.exe features.xml
for %%A in ("C:\Users\Shaggy\Google Drive\Tiara\Tiara's Moonshine Mod\Tools\MabiFeatureTool\features.xml.compiled") do for %%B in ("C:\Users\Shaggy\Google Drive\Tiara\Tiara's Moonshine Mod\data\features.xml.compiled") do Copy %%~sA %%~sB