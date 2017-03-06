local M = {}

local _commonEffects = require("lib.common-effects")

function M.new()
	local _cards = {}
	local commonEffects = _commonEffects.new()
	_cards.images ={
		magic={
			path="/resources/images/tiles/magic.png", 
			name="Magic", 
			filter="blue",
			baseHealth=3,
			onActivate=commonEffects.die
		},
		alchemy={
			path="/resources/images/tiles/alchemy.png", 
			name="Alchemy", 
			filter="red",
			onActivate=commonEffects.silence
		},
		vigor={
			path="/resources/images/tiles/vigor.png", 
			name="Vigor", 
			filter="yellow"
		},
		shell={
			path="/resources/images/tiles/magic.png", 
			name="Shell", 
			filter="red"
		},
		shield={
			path="/resources/images/tiles/shield.png", 
			name="Shield", 
			filter="yellow"
		},
		turtle={
			path="/resources/images/tiles/shield.png", 
			name="Turtle", 
			filter="blue"
		}
	}

	_cards.filters ={
		blue={path="/resources/images/tiles/filters/blue.png"},
		red={path="/resources/images/tiles/filters/red.png"},
		yellow={path="/resources/images/tiles/filters/yellow.png"}
	}

	return _cards

end

return M