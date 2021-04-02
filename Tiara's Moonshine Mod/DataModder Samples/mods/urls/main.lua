-----------------------------------------------------------------------------
-- Aura URLs
-----------------------------------------------------------------------------
-- Description
-- 
-- Modifies URLs stored in the client for use with an Aura server, changing
-- all URLs used for Aura, based on the settings below. Change the locale
-- and the url to match your client and web server settings.
-----------------------------------------------------------------------------
-- Conf

local locale = 'usa'
local url = 'http://127.0.0.1:8080/'

-----------------------------------------------------------------------------

loadxmlfile('db/urls.xml')

setattributes('//Url[@Locale="' .. locale .. '"]', {
	['UploadUIPage'] = url .. 'upload_ui.cs',
	['DownloadUIAddress'] = url .. 'upload/ui/',
	['CreateAccountPage'] = url .. 'register/',
	['UploadVisualChatPage'] = url .. 'upload_visualchat.cs',
	['UploadAvatarPage'] = url .. 'upload_avatar.cs',
	['UserGuildHomePage'] = url .. 'guild_home.cs?guildid={0}&amp;userid={1}&amp;userserver={2}&amp;userchar={3}&amp;key={4}',
	['GuildListPage'] = url .. 'guild_list.cs?CharacterId={0}&amp;Name_Server={1}&amp;Page={2}&amp;SortField={3}&amp;SortType={4}&amp;GuildLevelIndex={5}&amp;GuildMemberIndex={6}&amp;GuildType={7}&amp;SearchWord={8}&amp;Passport={9}',
})
