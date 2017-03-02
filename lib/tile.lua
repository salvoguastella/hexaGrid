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
		local tileObj = display.newGroup( )
		--place deck tile outside the viewport
		tileObj.x = display.contentWidth + 100
		tileObj.y = display.contentHeight - 20

		local tileBg = display.newRect( 0, 0, tileW, tileH )
		tileBg.fill = paint
		tileBg.fill.effect = "composite.multiply"
		tileBg.x = 0
		tileBg.y = 0
		tileObj:insert( tileBg )

		--properties
		tileObj.name = cards[card].name or "no name"
		tileObj.slot = nil
		--tileObj.id ?
		tileObj.owner = owner or "none"
		tileObj.cost = cards[card].cost or 1
		tileObj.category = cards[card].category or "generic"
		tileObj.baseHealth = cards[card].baseHealth or "10"
		tileObj.buffedHealth = cards[card].baseHealth or "10"
		tileObj.currentHealth = cards[card].baseHealth or "10"
		tileObj.basePower = cards[card].basePower or "5"
		tileObj.buffedPower = cards[card].basePower or "5"
		tileObj.currentPower = cards[card].basePower or "5"
		tileObj.description = cards[card].description or "no description"
		tileObj.status = cards[card].status or { canAttack = true, taunt = false, stealth = false, immune = false, poisoned = false, burned = false, frozen = false, asleep = false, silenced = false }

		--parameters indicators
		local tileHealth = display.newCircle( -20,40,18 )
		tileHealth:setFillColor( 1,1,1 )
		tileHealth.strokeWidth = 4
		tileHealth:setStrokeColor( 0, 0, 0 )
		tileObj:insert( tileHealth )

		local tileHealthText = display.newText( {parent=tileObj, text=tileObj.currentHealth, font=native.systemFontBold, fontSize=24} )
		tileHealthText.x, tileHealthText.y = -20,40
		tileHealthText:setFillColor( 0,0,0 )

		local tilePower = display.newCircle( 20,40,18 )
		tilePower:setFillColor( 1,1,1 )
		tilePower.strokeWidth = 4
		tilePower:setStrokeColor( 0, 0, 0 )
		tileObj:insert( tilePower )

		local tilePowerText = display.newText( {parent=tileObj, text=tileObj.currentPower, font=native.systemFontBold, fontSize=24} )
		tilePowerText.x, tilePowerText.y = 20,40
		tilePowerText:setFillColor( 0,0,0 )

		--methods
		tileObj.onDamageDealt = cards[card].onDamageDealt or function(target)
			return "damage dealt to "..target
		end

		tileObj.onDamageReceived = cards[card].onDamageReceived or function(target)
			return "damage receive from "..target
		end

		tileObj.onDeath = cards[card].onDeath or function()
			tileObj.owner.sendToGrave(tileObj)
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
			if (tileObj.slot) then
				tileObj._onActivate("source", "target", "option")
				return true
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