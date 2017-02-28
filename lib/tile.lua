local M = {}

local _cardsData = require("lib.cards")

function M.new(card,owner)
	local cardsData = _cardsData.new()
	local cards = cardsData.images
	local filters = cardsData.filters
	local tileW, tileH = 128, 147
	local exp = exp or 0
	if (cards[card]) then

		local path = cards[card].path
		local filter = cards[card].filter
		local paint = {
	    type = "composite",
	    paint1 = { type="image", filename=path },
	    paint2 = { type="image", filename=filters[filter].path }
		}
		local tileObj = display.newRect( 0, 0, tileW, tileH )
		tileObj.fill = paint
		tileObj.fill.effect = "composite.multiply"
		--place deck tile outside the viewport
		tileObj.x = display.contentWidth + 100
		tileObj.y = display.contentHeight - 20

		--properties
		tileObj.name = cards[card].name or "no name"
		tileObj.slot = nil
		tileObj.owner = owner or "none"
		tileObj.cost = cards[card].cost or 1
		tileObj.category = cards[card].category or "generic"
		tileObj.baseHealth = cards[card].baseHealth or "10"
		tileObj.buffedHealth = cards[card].baseHealth or "10"
		tileObj.currentHealth = cards[card].baseHealth or "10"
		tileObj.basePower = cards[card].baseHealth or "5"
		tileObj.buffedPower = cards[card].baseHealth or "5"
		tileObj.currentPower = cards[card].baseHealth or "5"
		tileObj.description = cards[card].baseHealth or "no description"
		tileObj.status = cards[card].status or { canAttack = true, taunt = false, stealth = false, immune = false, poisoned = false, burned = false, frozen = false, asleep = false, silenced = false }

		--methods
		tileObj.onDamageDealt = cards[card].onDamageDealt or function(target)
			return "damage dealt to "..target
		end

		tileObj.onDamageReceived = cards[card].onDamageReceived or function(target)
			return "damage receive from "..target
		end

		tileObj.onDeath = cards[card].onDeath or function()
			return tileObj.name.." is now dead"
		end

		tileObj.onPlay = cards[card].onPlay or function()
			return tileObj.name.." has been played"
		end

		tileObj.onTurnStart = cards[card].onTurnStart or function()
			return tileObj.name.." is idle at turn start"
		end

		tileObj.onTurnEnd = cards[card].onTurnEnd or function()
			return tileObj.name.." is idle at turn end"
		end

		tileObj.onPlayerPlayCard = cards[card].onPlayerPlayCard or function()
			return tileObj.name.." is idle when player plays one card"
		end

		tileObj.onOpponentPlayCard = cards[card].onOpponentPlayCard or function()
			return tileObj.name.." is idle when opponent plays one card"
		end

		tileObj.onHeal = cards[card].onHeal or function(target)
			return tileObj.name.." has been healed by"..target
		end

		tileObj._onActivate = cards[card].onActivate or function()
			print(tileObj.name.." doesn nothing if activated")
		end

		function tileObj.onActivate()
			--do magic here
			if (tileObj.placed) then
				tileObj._onActivate("source", "target", "option")
			else
				return false
			end
		end

		tileObj:addEventListener( "tap", tileObj.onActivate )

		return tileObj
	else
		print("no card found")
	end
end

return M