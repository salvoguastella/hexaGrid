local M = {}

local _tile = require("lib.tile")

local loadedDeck = {"magic", "alchemy", "vigor", "shell"}

function M.new(name)
	local _player = {}
	_player.deck = {}
	for i, v in ipairs(loadedDeck) do
		local newTile = _tile.new(v, _player)
		table.insert( _player.deck, newTile )
	end
	_player.hand = {}
	_player.name = name

	_player.addCardToHand = function()
		if #_player.deck > 0 then
			local newCardInHand = _player.deck[1]
			table.insert( _player.hand, newCardInHand )
			table.remove( _player.deck, 1 )

			--print("hand: "..#_player.hand)
			--print("deck: "..#_player.deck)

			return newCardInHand
		else
			print("no more cards")
			return false
		end
	end

	_player.playCard = function(tile)
		
		for i, v in ipairs(_player.hand) do
			if (tile == v) then
				table.remove( _player.hand, i )
				print(_player.name.." plays "..tile.name.." on "..tile.slot)
			end
		end
		print("hand: "..#_player.hand)
	end

	return _player

end

return M