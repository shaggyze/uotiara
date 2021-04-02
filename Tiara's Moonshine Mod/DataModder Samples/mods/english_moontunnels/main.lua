-----------------------------------------------------------------------------
-- English Moontunnels
-----------------------------------------------------------------------------
-- Description
-- 
-- Translates Moontunnels that appear as Korean in some places to English.
-- This isn't a problem on official servers, because those gates aren't
-- used in the Moongate rotation for pets anymore, and the names don't
-- appear in any other context, but on inofficial servers it will fix
-- some gate's names being in Korean.
-----------------------------------------------------------------------------

loadxmlfile('db/gate.xml')

local function setlocalname(name, localname)
	setattributes('/gates/moontunnels/moontunnel[@name="' .. name .. '"]', 'localname', localname)
end

setlocalname('_moontunnel_sidhe_sneachta', 'Sidhe Sneachta')
setlocalname('_moontunnel_alby_dungeon', 'Alby Dungeon')
setlocalname('_moontunnel_ciar_dungeon', 'Ciar Dungeon')
setlocalname('_moontunnel_loggingcamp', 'Logging Camp')
setlocalname('_moontunnel_duntir02', 'Dugald Aisle')
setlocalname('_moontunnel_cobh_harbor', 'Port Cobh')
setlocalname('_moontunnel_dragonruin', 'Dragon Ruins')
setlocalname('_moontunnel_fiodh_dungeon', 'Fiodh Dungeon')
setlocalname('_moontunnel_reighinalt', 'Reighinalt')
setlocalname('_moontunnel_morva_aisle', 'Morva Aisle')
setlocalname('_moontunnel_sliab_cuilin01', 'Stone Quarry')
setlocalname('_moontunnel_sliab_cuilin02', 'Sliab Cuilin')
setlocalname('_moontunnel_abb_neagh01', 'Bard Camp')
setlocalname('_moontunnel_abb_neagh02', 'Abb Neagh')
setlocalname('_moontunnel_sen_mag_plains', 'Sen Mag Plains')
setlocalname('_moontunnel_peaca_dungeon', 'Peaca Dungeon')
setlocalname('_moontunnel_tailteann_w', 'Taillteann West')
setlocalname('_moontunnel_tailteann_druid', 'Druid\'s House')
setlocalname('_moontunnel_tailteann_cemetery', 'Taillteann Graveyard')
setlocalname('_moontunnel_tailteann_e', 'Taillteann Trading Post')
setlocalname('_moontunnel_tailteann_farm01', 'Taillteann Farms')
setlocalname('_moontunnel_tailteann_s', 'Taillteann South')
setlocalname('_moontunnel_emain_macha_n', 'Emain Macha North')
setlocalname('_moontunnel_emain_macha_w', 'Emain Macha West')
setlocalname('_moontunnel_coill_dungeon', 'Coill Dungeon')
setlocalname('_moontunnel_tara_s', 'Tara South')
setlocalname('_moontunnel_tara_kingdom', 'Rath Royal Castle')
setlocalname('_moontunnel_tara_01', 'Jousting Arena')
setlocalname('_moontunnel_blago_prairie_01', 'Eluned Winery')
setlocalname('_moontunnel_blago_prairie_02', 'Lezarro Winery')
setlocalname('_moontunnel_blago_prairie_e', 'Blago Prairie East')
setlocalname('_moontunnel_belfast_01', 'Mykeeness Cliffs')
setlocalname('_moontunnel_belfast_02', 'Belfast Garden')
setlocalname('_moontunnel_scathach_01', 'Scathach Patrol Camp')
setlocalname('_moontunnel_scathach_02', 'Scathach Fishing Area')
setlocalname('_moontunnel_scathach_03', 'Scathach Springs')
setlocalname('_moontunnel_scathach_04', 'Black Beach')
setlocalname('_moontunnel_scathach_05', 'Witch\'s Cave')
