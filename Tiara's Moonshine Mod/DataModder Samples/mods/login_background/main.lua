-----------------------------------------------------------------------------
-- Login Background
-----------------------------------------------------------------------------
-- Description
-- 
-- Sets specific images and music for the login scene.
-----------------------------------------------------------------------------

loadxmlfile('db/layout2/login/loginscene.xml')

setattributes('//LoginScene[@__locale="usa"]', {     -- Use usa node
	['UseXML'] = 'true',
	['DurationTime'] = 'false',
	['Random'] = 'false',
	['Background'] = 'login_image_10th_jp.dds',      -- Background image to use
	['MainLogo'] = 'login_Logo_US.dds',              -- Logo to use
	['MainLogo_X_Ratio'] = 0.1,                      -- X position of the logo (0.0 = left border, 1.0 right border)
	['MainLogo_Y_Ratio'] = 0.02,                     -- Y position of the logo (0.0 = top border, 1.0 bottom border)
	['Copyright'] = 'login_copyright03_kr_w.dds',    -- Copyright notice image
	['Music'] = 'Title_10th_Remake_Shibuya_Ver.mp3', -- Background music
	['OriginalMainLogoSize'] = 'true',
})
