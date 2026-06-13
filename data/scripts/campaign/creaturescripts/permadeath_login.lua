-- Death & Permadeath / PK System (GDD section 9): a character flagged as a
-- "shade" by permadeath_convert.lua is banished to CampaignConfig.permadeath
-- .shadePosition on every subsequent login and informed that the campaign is
-- over for this character.

local cfg = CampaignConfig.permadeath

local permadeathLogin = CreatureEvent("CampaignPermadeathLogin")

function permadeathLogin.onLogin(player)
	if player:getStorageValue(cfg.shadeStorage) ~= 1 then
		return true
	end

	local pos = cfg.shadePosition
	player:teleportTo(Position(pos.x, pos.y, pos.z))
	player:sendTextMessage(MESSAGE_STATUS_WARNING, "Your character perished permanently in the campaign and now wanders as a restless shade. Create a new character to continue.")
	return true
end

permadeathLogin:type("login")
permadeathLogin:register()
