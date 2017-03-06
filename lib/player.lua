local M = {}

local _tile = require("lib.tile")

function M.new(name,loadedDeck)
	local _player = {}
	_player.deck = {}
	for i, v in ipairs(loadedDeck) do
		local newTile = _tile.new(v, _player)
		table.insert( _player.deck, newTile )
	end
	_player.hand = {}
	_player.grave = {}
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

	_player.shuffleDeck = function ()
		    local rand = math.random
		    assert( _player.deck, "shuffleTable() expected a table, got nil" )
		    local iterations = #_player.deck
		    local j
		    for i = iterations, 2, -1 do
		        j = rand(i)
		        _player.deck[i], _player.deck[j] = _player.deck[j], _player.deck[i]
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

	_player.sendToGrave = function(tile)
		tile.owner = _player.name
		table.insert( _player.grave, tile )
		print("grave: "..#_player.grave)
	end

	_player.burnCard = function ()
		local wastedTile = _player.hand[#_player.hand]
		table.remove( _player.hand, #_player.hand )
		print(_player.name.." hand is too full. "..wastedTile.name.." has been discarted")
		_player.sendToGrave(wastedTile)
	end

	return _player

end

return M