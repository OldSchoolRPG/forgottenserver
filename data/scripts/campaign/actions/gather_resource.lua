-- Resource Gathering (GDD section 8): "use" a resource node tile/item (an
-- item carrying one of the actionIds in CampaignConfig.gathering.nodes) to
-- harvest it. If the node requires a tool, the player must be carrying it
-- (it is not consumed). Each node enters a cooldown (`respawnSeconds`)
-- after being harvested, tracked via a custom attribute on the node item
-- itself so it persists across save/reload.

local cfg = CampaignConfig.gathering

local DEPLETED_ATTRIBUTE = "campaign_depleted_until"

local gatherAction = Action()

function gatherAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local node = cfg.nodes[item:getActionId()]
	if not node then
		return false
	end

	if node.tool and player:getItemCount(node.tool) < 1 then
		player:sendCancelMessage("You need a " .. ItemType(node.tool):getName() .. " to gather here.")
		return true
	end

	local depletedUntil = item:getCustomAttribute(DEPLETED_ATTRIBUTE) or 0
	if depletedUntil > os.time() then
		player:sendCancelMessage("This " .. node.name .. " needs time to recover.")
		return true
	end

	local count = math.random(node.yieldMin, node.yieldMax)
	player:addItem(node.yield, count)
	item:setCustomAttribute(DEPLETED_ATTRIBUTE, os.time() + node.respawnSeconds)

	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You gather " .. count .. "x " .. ItemType(node.yield):getName() .. ".")
	return true
end

for actionId in pairs(cfg.nodes) do
	gatherAction:aid(actionId)
end

gatherAction:register()
