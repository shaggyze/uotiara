-----------------------------------------------------------------------------
-- Mod itemdb
-----------------------------------------------------------------------------

loadxmlfile('db/itemdb.xml')

-- Rename 'Traveler's Guide' to 'Just some book'
setattributes('//Mabi_Item[@ID=1000]', 'Text_Name0', 'Just some booock')

-- Set multiple attributes
setattributes('//Mabi_Item[@ID=1001]', {
	['Text_Name0'] = 'And another book',
	['Price_Buy']  = '500',
})

-- Make all 1H swords look like Muramasa
setattributes('//Mabi_Item[@File_MaleMesh and contains(@Category, "/equip/righthand/weapon/edged/steel/blade/")]', 'File_MaleMesh', 'weapon_muramasa01')

-- Add an item
addelement('/Items', '<Mabi_Item ID="424242" Name="test" />')

-- Remove an item by id (221066)
removeelements('//Mabi_Item[@ID=221066]')

-- Remove multiple items by id via table (221063, 221064)
removeelements { '//Mabi_Item[@ID=221063]', '//Mabi_Item[@ID=221064]' }

-- Remove multiple items by id via loop (221058~221061)
for i = 221058, 221061 do
	removeelements('//Mabi_Item[@ID=' .. i .. ']')
end

-- Fix typo in renamed book via regex/replacing
replace('Just some booock', 'Just some book')

-- Reduce prices of all items by 10%, by removing the last digit via regex
-- (Just a regular expressions example, prices are server controlled)
replace([[Price_Buy="(\d+)\d"]], 'Price_Buy="$1"')


-----------------------------------------------------------------------------
-- Mod cutscenes
-----------------------------------------------------------------------------

-- Replace a file with a new file in the mod's folder
replacefile('db/cutscene/cutscene_waterfall.xml', 'my_improved_waterfall.xml')

-- Replace an image with a different one from the packs
replacefile('gfx/image/npc/npcportrait_manus_us.dds', 'gfx/image/npc/npcportrait_manus.dds')


-----------------------------------------------------------------------------
-- Mod feature settings
-----------------------------------------------------------------------------

loadxmlfile('features.xml.compiled')

-- Enable gfELDHalloween
setattributes('//Feature[@Hash="24934d26"]', 'Default', 'G0S0')
setattributes('//Feature[@Hash="24934d26"]', 'Enable', '')
setattributes('//Feature[@Hash="24934d26"]', 'Disable', '')


-----------------------------------------------------------------------------
-- Include another file
-----------------------------------------------------------------------------

include('another_mod.lua')
include('http://127.0.0.1/test.lua')
--require('http://127.0.0.1/test.lua')
